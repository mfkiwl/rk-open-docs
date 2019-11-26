# Rockchip RK2206 Secure Digital IO

文件标识：RK-KF-YF-049

发布版本：1.0.0

日期：2019-11-29

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2019福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

 **前言**

 **概述**

本文主要描述了RK2206 SDIO的配置和使用方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

 **修订记录**

| **日期**   | **版本** | **作者**  | **修改说明** |
| ---------- | -------- | :-------- | ------------ |
| 2019-11-26 | V1.0.0   | Shawn Lin | 初始版本     |

---

## **目录**

[TOC]

---

## **1 SDIO(Secure Digital IO)**

### **1.1 用途**

用于外接从设备的片外总线，可支持的外设类型有SD/TF卡，SDIO功能设备(常见Wi-Fi, BT等)，MMC（Multi-media card）, eMMC（embedded MMC）。

### **1.2 配置**

先将控制器的驱动勾选DRIVER_SDMMC

```c
    BSP Driver  --->
        [*] Enable SDMMC
```

根据所需外接的设备，勾选对应的协议栈(为了减小代码尺寸，请按需勾选)：

```c
    BSP Driver  --->
       [*] Enable SD
       [*] Enable SDIO
       [*] Enable EMMC
```

如果需要使用shell测试命令进行测试，勾选对应的测试工具：

```c
    Components Config --->
        Command shell  --->
            [*] Enable Sdmmc Shell
            [*] Enable SD Card Shell
            [*] Enable Sdio Shell
            [*] Enable Emmc Shell
```

如果需要修改板级配置，请修改对应工程的board.c文件

```c
INIT API void SdMmcDevHwInit(uint32 DevID, uint32 Channel, struct HAL_MMC_HOST *host)
{
    if (DevID != 0)
    {
        rk_printf("%s invalid DevID\n", __func__);
        return;
    }

    ClkEnableById(HCLK_SDMMC_GATE);
    ClkEnableById(CLK_SDMMC_DT50_GATE);
    /* 需要修改接口频率，请设置频率的2倍数值，目前工作在48MHz */
    ClkSetRate(CLK_SDMMC, 96000000);

    host->pReg = (struct MMC_REG *)SDMMC_BASE;
    host->irq = SD_MMC_IRQn;

    iomux_config_sdmmc();
    GRF->SOC_CON15 = GRF_SOC_CON15_GRF_SARADC_IEN_MASK << 16;
    /* 目前采样延时和输出延时都设定在clock的第一个下降沿，即90度，可自行修改 */
    CRU->SDMMC_CON[0] = CRU_SDMMC_CON00_INIT_STATE_MASK | CRU_SDMMC_CON00_INIT_STATE_MASK << 16;
    CRU->SDMMC_CON[0] = (0x2 << CRU_SDMMC_CON00_DRV_DEGREE_SHIFT) | (CRU_SDMMC_CON00_DRV_DEGREE_MASK << 17);
    CRU->SDMMC_CON[1] = (0x1 << CRU_SDMMC_CON01_SAMPLE_DEGREE_SHIFT) | (CRU_SDMMC_CON01_SAMPLE_DEGREE_MASK << 17);
    CRU->SDMMC_CON[0] = CRU_SDMMC_CON00_INIT_STATE_MASK << 16;

    rk_interrupt_register(host->irq, SdcIntIRQ0);
    rk_interrupt_pending_clear(host->irq);
    rk_interrupt_unmask(host->irq);
}

```

### **1.3 代码和API**

- 控制器驱动src/driver/sdmmc/SdMmcDevice.c，不允许协议栈之外引用
- SDIO枚举协议栈src/driver/sdio/SdioDevice.c
- SD/TF卡枚举协议栈src/driver/sd/SdDevice.c
- (e)MMC枚举协议栈src/driver/emmc/EmmcDevice.c

```c
/* SD/TF卡和EMMC的len 均为sector单位，即512 Btyes */
extern rk_size_t SdDev_Write(HDC dev, rk_size_t LBA, const uint8 *buffer, rk_size_t len);
extern rk_size_t SdDev_Read(HDC dev, rk_size_t LBA, uint8 *buffer, rk_size_t len);
extern rk_size_t EmmcDev_Read(HDC dev, rk_size_t LBA, uint8 *buffer, rk_size_t len);
extern rk_size_t EmmcDev_Write(HDC dev, rk_size_t LBA, const uint8 *buffer, rk_size_t len);

/* SDIO的count是以Byte为单位 */
extern rk_err_t SdioDev_Memcpy_FromIo(HDC hSdioFun, void *dst, uint32 addr, uint32 count);
extern rk_err_t SdioDev_Memcpy_ToIo(HDC hSdioFun, uint32 addr, void *src, uint32 count);
extern rk_err_t SdioDevDelete(uint8 DevID, void *arg);
extern rk_err_t SdioDev_DisalbeInt(HDC dev, uint32 FuncNum);
extern rk_err_t SdioDev_EnableInt(HDC dev, uint32 FunNum);
extern HDC SdioDev_GetFuncHandle(HDC dev, uint32 FuncNum);
extern rk_err_t SdioDev_Writew(HDC hSdioFun, uint32 b, uint32 addr);
extern rk_err_t SdioDev_Readw(HDC hSdioFunc, uint32 addr);
extern rk_err_t SdioDev_Writel(HDC hSdioFun, uint32 b, uint32 addr);
extern rk_err_t SdioDev_Readl(HDC hSdioFun, uint32 addr);
extern rk_err_t SdioDev_SetBlockSize(HDC hSdioFun, uint32 BlockSize);
extern rk_err_t SdioDev_WriteSb(HDC hSdioFun, uint32 addr, void *src, uint32 count);
extern rk_err_t SdioDev_ReadSb(HDC hSdioFun, void *dst, uint32 addr, uint32 count);
extern rk_err_t SdioDev_Readb(HDC hSdioFunc, uint32 addr);
extern rk_err_t SdioDev_Writeb(HDC hSdioFunc, uint8 b, uint32 addr);
extern rk_err_t SdioDev_DisableFunc(HDC hSdioFunc);
extern rk_err_t SdioDev_EnalbeFunc(HDC hSdioFunc);
extern HDC SdioDev_Create(uint8 DevID, void *arg);
extern void SdioIrqTask(void *pvParameters);
extern rk_err_t SdioIntIrqInit(void *pvParameters, void *arg);
extern rk_err_t SdioIntIrqDeInit(void *pvParameters);
extern int SdioDev_Claim_irq(void *_func, sdio_irq_handler_t *handler);
extern int sdio_release_irq(void *func);

```

## **2 SHELL 测试与输出**

### **2.1 SD/TF卡测试命令**

*2.1.1 读写测试*

SD卡测试，可能导致SD卡文件系统被破坏,测试前请备份SD卡数据，测试后格式化使用。
SD卡测试命令中，请注意参数是否合法,如SD卡的操作地址。
SD卡的设备号，固定是0。

```c
RK2206>sd.write 0 0x8e9c 4 0x77
0代表设备号，在SD卡的地址0x8e9c(SD卡操作地址可以指定，需要在合法地址内)写入4个block的数据，数据填充为字节0x77（可指定为任意字节数据）。

RK2206>sd.read 0 0x8e9c 4
0代表设备号，在SD卡的地址0x8e9c(和上述写地址一致)，读出4个block的数据。
```

测试log:

```
RK2206>sd.write 0 0x8e9c 4 0x77create thread classId = -1, objectid = 8, name = SdTestTask, remain = 4085528
[A.14.00][001588.482627]
RK2206>DevID = 0, LBA = 36508, blks = 4 value = 0x77
[A.SdTes][001588.489430]
[A.SdTes][001588.503002]  sd Write Data success
[A.SdTes][001588.507076]delete thread classId = -1, objectid = 8, name = SdTestTask, remain = 4069136.
[A.SdTes][001588.519801]

RK2206>sd.read 0 0x8e9c 4create thread classId = -1, objectid = 3, name = SdTestTask, remain = 6211448
[A.14.00][000029.571868]
RK2206>DevID = 0, LBA = 36508, blks = 4
[A.SdTes][000029.581561]
[A.SdTes][000029.587681]  sd Read Data success
[A.SdTes][000029.594030]
[A.SdTes][000029.603383][381109c0]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.619609][381109d0]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.632840][381109e0]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.643058][381109f0]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.651280][38110a00]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.666512][38110a10]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.678728][38110a20]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.687951][38110a30]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
[A.SdTes][000029.704184][38110a40]77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77
```

*2.1.2 一致性测试*

测试命令：

```
sd.test 0 0x8e9c 4
设备号0,在SD卡的地址0x8e9c(SD卡操作地址可以指定，需要在合法地址内)，对4个block，进行读写一致性测试。
```

测试log:

```
RK2206>
RK2206>sd.test 0 0x8e9c 4create thread classId = -1, objectid = 4, name = SdTestTask, remain = 6146584
[A.14.00][005590.823303]
RK2206>DevID = 0, LBA = 36508, blks = 4
[A.SdTes][005590.837009]
[A.SdTes][005590.851304]  Sd write-read-compare Test Successfully 0
[A.SdTes][005590.855812]
[A.SdTes][005590.863215]  Sd write-read-compare Test Successfully 1
[A.SdTes][005590.876049]
[A.SdTes][005590.882452]  Sd write-read-compare Test Successfully 2
[A.SdTes][005590.893286]
[A.SdTes][005590.900238]  Sd write-read-compare Test Successfully 3
[A.SdTes][005590.909515]
[A.SdTes][005590.921914]  Sd write-read-compare Test Successfully 4
```

*2.1.3 性能测试*

```
RK2206>file.setpath C:\

RK2206>file.test 512 512 1
总共测试512个block,每个block大小512字节,每次测试1个block（也可改为每次测试4block）。
```

[^注]: 读写速度测试时，将自动比较数据读写一致性，若不一致，log将显示文件数据错误。

测试log:

```
[A.14.00][000068.429157]total clk = 3022, 6853, 6853read: LBA = 0x000001fc, Len = 1, readus = 34497
[A.14.00][000068.442706]total clk = 2410, 6854, 6854read: LBA = 0x000001fd, Len = 1, readus = 34557
[A.14.00][000068.454297]total clk = 2790, 6855, 6855read: LBA = 0x000001fe, Len = 1, readus = 34626
[A.14.00][000068.464846]total clk = 2558, 6856, 6856read: LBA = 0x000001ff, Len = 1, readus = 34689
  test end: totalsize = 262144, blocksize = 512, writerate = 30577 byte/s, readrate = 7710117 byte/s
```

### **2.2 eMMC 测试 **

eMMC测试仅需将SD卡测试命令中的“sd.write/sd.read”，修改成“emmc.write/emmc.read”即可，其他参数不变。

### **2.3 SD/TF卡自动枚举输出信息**

一般带着SD/TF卡的设备，开机后会进行自动枚举，如果正确枚举，则可见如下打印，输出具体卡的
类型和对应容量信息

```c
***************************************************************************
*    Copyright (C) Fuzhou Rockchips Electronics CO.,Ltd                   *
*                                                                         *
*        Welcome to Use RKOS V2.0.0(D):a9b6f04d, 195d803                   *
*        Built : 08:41:43, Nov 13 2019                                    *
***************************************************************************
RK2206>
[a][000000.593663] sdc resp timout
[a][000000.601058]
[A.19.00][000000.760803]30.01GB SDHC Card

```
