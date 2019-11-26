# Rockchip FreeRTOS SPI

文件标识：RK-KF-YF-047

发布版本：V1.0.0

日期：2019-12-03

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

本文主要描述了 ROCKCHIP FreeRTOS SPI的原理和使用方法。

**产品版本**

| **芯片名称** | **内核版本**    |
| ------------ | --------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 林鼎强 | 2019-12-03 | 初始版本     |

**目录**

---
[TOC]
---

## **1 SPI**

### **1.1 原理**

SPI 设备接口是 APB 从设备，这是 Motorola 的四线全双工串行协议，串行时钟相位和极性有四种可能的组合，时钟相位（SCPH）确定串行传输是从选择信号的下降沿还是串行时钟的第一沿开始，当SPI空闲或禁用时，从选择线保持高电平， 该 SPI 控制器可以在主模式或从模式下工作。

### **1.2 配置**

宏配置：

```c
    BSP Driver  --->
        [*] Enable SPI  --->
            [*] Enable SPI0
            [*] Enable SPI1
```

### **1.3 代码和函数接口**

**代码**

"src/driver/spi/SpiDevice.c"
"include/driver/SpiDevice.h"

**所有公共函数接口**

```c
rk_err_t SpiDev_Configure(HDC dev, struct RK_SPI_CONFIG *config);

/*
 * SPI data transfer
 * Send only: sendBuf valid, recvBuf invalid
 * Receive only: sendBuf invalid, recvBuf valid
 * Duplex: sendBuf and recvBuf both valid
 */
rk_size_t SpiDev_Transfer(HDC dev, uint8_t ch, const void *sendBuf, void *recvBuf, rk_size_t length);
rk_size_t SpiDev_Write(HDC dev, uint8_t cs, const void *sendBuf, uint32_t length);
rk_size_t SpiDev_Read(HDC dev, uint8_t cs, void *recvBuf, uint32_t length);
rk_err_t SpiDev_SendThenSend(HDC dev, uint8_t ch, const void *sendBuf0, rk_size_t len0, const void *sendBuf1, rk_size_t len1);
rk_err_t SpiDev_SendThenRecv(HDC dev, uint8_t ch, const void *sendBuf, rk_size_t len0, void *recvBuf, rk_size_t len1);
HDC SpiDev_Create(uint8 DevID, void *arg);
```

**创建设备接口**

```c
HDC SpiDev_Create(uint8 DevID, void *arg);
```

其中，arg 参数暂无实际意义，可不传递，所有 SPI 设备的参数调整，通过参数配置专用接口。

**参数配置接口**

```c
rk_err_t SpiDev_Configure(HDC dev, struct RK_SPI_CONFIG *config);
```

Spidev_Configure 中 config 参数结构体如下：

```c
/* Rockchip SPI configuration */
struct RK_SPI_CONFIG
{
    uint8_t mode;      /* SPI 通用配置 */
    uint8_t dataWidth; /* 每笔数据最小传输位数，可配 8bits, 16bits */
    uint8_t reserved;
    uint32_t maxHz;    /* SPI 频率，但实际频率受限于 CRU 可配频率范围 */
};
```

通过配置 mode 参数相应位域可以配置 SPI 极性、采样相位、大小端、主从模式和 CSM 参数，具体位域信息如下：

```c
/* RK_SPI_CONFIG mode */
#define RK_SPI_CPHA             (1<<0)                         /* bit[0]:CPHA, clock phase */
#define RK_SPI_CPOL             (1<<1)                         /* bit[1]:CPOL, clock polarity */
/**
 * At CPOL=0 the base value of the clock is zero
 *  - For CPHA=0, data are captured on the clock's rising edge (low->high transition)
 *    and data are propagated on a falling edge (high->low clock transition).
 *  - For CPHA=1, data are captured on the clock's falling edge and data are
 *    propagated on a rising edge.
 * At CPOL=1 the base value of the clock is one (inversion of CPOL=0)
 *  - For CPHA=0, data are captured on clock's falling edge and data are propagated
 *    on a rising edge.
 *  - For CPHA=1, data are captured on clock's rising edge and data are propagated
 *    on a falling edge.
 */
#define RK_SPI_MODE_0           (0 | 0)                        /* CPOL = 0, CPHA = 0 */
#define RK_SPI_MODE_1           (0 | RK_SPI_CPHA)              /* CPOL = 0, CPHA = 1 */
#define RK_SPI_MODE_2           (RK_SPI_CPOL | 0)              /* CPOL = 1, CPHA = 0 */
#define RK_SPI_MODE_3           (RK_SPI_CPOL | RK_SPI_CPHA)    /* CPOL = 1, CPHA = 1 */
#define RK_SPI_MODE_MASK        (RK_SPI_CPHA | RK_SPI_CPOL | RK_SPI_MSB)

#define RK_SPI_LSB              (0<<2)                         /* bit[2]: 0-LSB */
#define RK_SPI_MSB              (1<<2)                         /* bit[2]: 1-MSB */

#define RK_SPI_MASTER           (0<<3)                         /* SPI master device */
#define RK_SPI_SLAVE            (1<<3)                         /* SPI slave device */

#define RK_SPI_CSM_SHIFT        (4)
#define RK_SPI_CSM_MASK         (0x3 << 4)                     /* SPI master ss_n hold cycles for MOTO SPI master */
```

**数据传输接口**

```c
/*
 * SpiDev_Transfer 为灵活的 SPI 传输接口，支持单工和双工传输，传输起始会相应使能 cs 脚：
 * Send only: sendBuf valid, recvBuf invalid
 * Receive only: sendBuf invalid, recvBuf valid
 * Duplex: sendBuf and recvBuf both valid
 */
rk_size_t SpiDev_Transfer(HDC dev, uint8_t ch, const void *sendBuf, void *recvBuf, rk_size_t length);
```

```C
/* 封装后的 SpiDev_Transfer 单工传输写接口，传输起始会相应使能 cs 脚 */
rk_size_t SpiDev_Write(HDC dev, uint8_t cs, const void *sendBuf, uint32_t length);
/* 封装后的 SpiDev_Transfer 单工传输读接口，传输起始会相应使能 cs 脚 */
rk_size_t SpiDev_Read(HDC dev, uint8_t cs, void *recvBuf, uint32_t length);
```

```c
/* SPI 单工传输，一次 cs 有效区间内先完成 SPI 写，再进行 SPI 写 */
rk_err_t SpiDev_SendThenSend(HDC dev, uint8_t ch, const void *sendBuf0, rk_size_t len0, const void *sendBuf1, rk_size_t len1);
/* SPI 单工传输，一次 cs 有效区间内先完成 SPI 写，再进行 SPI 读 */
rk_err_t SpiDev_SendThenRecv(HDC dev, uint8_t ch, const void *sendBuf, rk_size_t len0, void *recvBuf, rk_size_t len1);
```

### 1.4 函数接口调用范例

参考 shell_spi.c。

### **1.5 shell使用范例**

**创建设备**

```c
spi.create <spi devid>   /*例如： spi.create 0 */
```

**配置设备**

```c
spi.config <spi devid> <mode> <data width> <clk> /* 例如 spi.config 0 0 8 10000 */
```

具体可配参数参考 1.3 章节。

例2:配置 SPI0 为master，mode3，csm 3, data width 8，speed 50MHz。

```c
spi.config 0 0x33 8 50000000
```

**检查配置**

```c
spi.pcb <spi devid> /* 例如  spi.pcb 1 */

RK2206>spi.pcb 1

  .gSpiDevISR[1]
      .stSpiDevice
          .next = 00000000
          .use_cnt = 1
          .suspend_cnt = 0
          .dev_class_id = 1
          .dev_object_id = 1
          .suspend = 0008ef6d
          .resume = 0008ef69
      .osSpiOperReqSem = 537119200
      .osSpiOperSem = 537119280
      .status = 0
      .hDma = 20028dcc
      cr0 = 00002c00
      cr0->opmode = 00000000
      cr0->nBytes = 00000000
      cr0->clkPolarity = 00000000
      cr0->clkPhase = 00000000
      cr0->firstBit = 00000000
      cr0->csm = 00000000
```

**读写设备**

```c
spi.read <spi devid> <cs> <data length> <loop> /* 例如  spi.read 0 0 256 1 */

spi.write <spi devid> <cs> <data length> <loop> /* 例如 spi.write 0 0 256 1 */
```

