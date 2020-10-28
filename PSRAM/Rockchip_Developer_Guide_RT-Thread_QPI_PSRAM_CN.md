# Rockchip RT-Thread QPI PSRAM

文件标识：RK-KF-YF-131

发布版本：V1.0.0

日期：2020-10-28

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文主要描述了 ROCKCHIP RT-Thread SPI / QPI Psram （下面简称 QPI Psram）的原理和使用方法。

**产品版本**

| **芯片名称**                          | **内核版本** |
| ------------------------------------- | ------------ |
| 所有使用 RK RT-Thread  SDK 的芯片产品 | RT-Thread    |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 林鼎强   | 2020-10-28   | 初始版本     |

---

**目录**

[TOC]

---

## 简介

### 支持器件

QPI Psram，伪静态存储器，有以下特点：

* 最高支持 4 个I/O引脚，以 SPI（串行外围接口）或 QPI（四个外围接口）模式工作；
* 频率可达 144 MHz；
* 集成了自刷新机制。

### 主控控制器

RK 平台 支持 QPI Psram 器件的控制器包括 FSPI 和 SPI。

FSPI (Flexible Serial Peripheral Interface)  是一个灵活的串行传输控制器，有以下主要特性：

* 支持 SPI Nor、SPI Nand、SPI 协议的 Psram 和 SRAM
* 支持 QPI Psram 1线、2线和4线传输
* XIP 技术
* DMA 传输

SPI （ Serial Peripheral Interface ）为通用的 串行传输控制器，可以支持外挂 SPI Nor、SPI Nand、QPI Psram（仅 1 线数据传输）。

### XIP 技术

XIP（eXecute In Place），即芯片内执行， 指 CPU 直接通过映射地址的 memory 空间取指运行，即应用程序可以直接在 flash 闪存内运行，不必再把代码读到系统 RAM 中，所以片内执行代码的运行地址为相应的映射地址。

对于 QPI Psram 来说，在 XIP 技术支持下实现 sram 一般的存在，即总线或其他 master 直接访问 QPI Psram，支持读和写操作。

FSPI 除支持 CPU XIP 访问 QPI Psram，还支持如DSP 等其他模块以相近方式获取 QPI Psram 数据，如同访问 sram，详细 FSPI 信息参考 TRM 中 FSPI 章节。

### 驱动框架

整个驱动框架分为四个层次 ：

* Psram 框架层
* RTOS Driver 层，完成以下逻辑:
    * RTOS 设备框架
    * 注册控制器及操作接口到 HAL_QPIPSRAM 协议层
    * 封装读写擦除接口给用户
* 基于 QPI Psram 传输协议的 HAL_QPIPSRAM 协议层
* 控制器层

**基于 FSPI 控制器的 RT-Thread 实现**：

* OS 驱动层：drv_qpipsram.c 实现:
    * 基于 FSPI HAL层读写接口封装 SPI_Xfer，并注册 FSPI host 及 SPI_Xfer 至 HAL_QPIPSRAM 协议层
    * 封装 HAL_QPIPSRAM 协议层提供的读写擦除接口
    * 注册 OS 设备驱动到 MTD 框架层
* 协议层：HAL 开发包中的 hal_qpipsram.c 实现 QPI Psram 的协议层
* 控制器层：HAL 开发包中的 hal_fspi.c 实现 FSPI 控制器驱动代码

**基于 SPI 控制器的 RT-Thread 实现**：

* OS 驱动层：drv_qpipsram.c 实现:
    * 基于 SPI OS driver 读写接口封装 SPI_Xfer，并注册 SPI host 和 SPI_Xfer 至 HAL_QPIPSRAM 协议层；
    * 封装 HAL_QPIPSRAM 协议层提供的读写擦除接口
    * 注册 OS 设备驱动到 Psram 框架层
* 协议层：HAL 开发包中的 hal_qpipsram.c 实现 QPI Psram 的协议层
* 控制器层：HAL 开发包中的 hal_spi.c 实现 SPI 控制器 low layer 驱动代码，SpiDevice.c 代码实现 RTOS SPI DRIVER 的设备注册和接口封装

注意：

1. 由于 RK SPI DMA 传输相关代码在 OS Driver 层，且 SPI 控制器除了应用在 QPI Psram 上，还支持较多其他器件，存在硬件资源边界保护，所以在 QPI Psram 框架中的 SPI 控制器不应直接套接 HAL 层 hal_spi.c 驱动，而应使用 OS Driver 中的 SPI 接口。

## 配置

在进行配置前，需明确硬件上所选用的 QPI Psram 相应的主控类型，以选择相应方案。

### FSPI 控制器方案

通用配置：

```
RT-Thread rockchip common drivers  --->
    [*] Enable ROCKCHIP QPI Psram  --->
    (80000000) Reset the speed of QPI Psram in Hz
    Choose QPI Psram Adapter (Attach FSPI controller to QPI Psram)  --->
      Attach FSPI controller to QPI Psram
    [*]       Extend QPI Psram on FSPI cs1
    [*]         Extend QPI Psram on FSPI cs1 with cs-gpio
    [*]       Extend QPI Psram on FSPI cs2
    [*]         Extend QPI Psram on FSPI cs2 with cs-gpio
    [*]       Extend QPI Psram on FSPI cs3
    [*]         Extend QPI Psram on FSPI cs3 with cs-gpio
```

cs-gpio 扩展配置：

cs-gpio 扩展是通过 gpio 模拟 cs 实现 FSPI 控制器上挂载多 QPI Psram 设备的方案。

1. defconfig 配置参考：

   ```
   +CONFIG_RT_USING_QPIPSRAM=y
   +CONFIG_RT_QPIPSRAM_SPEED=133000000
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST=y
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS1=y
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS1_GPIO=y		/* 扩展 gpio 为 cs1  */
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS2=y
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS2_GPIO=y		/* 扩展 gpio 为 cs2  */
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS3=y
   +CONFIG_RT_USING_QPIPSRAM_FSPI_HOST_CS3_GPIO=y		/* 扩展 gpio 为 cs3  */
   ```

2. 添加 cs-gpio 相关函数实现（必要）：

   函数引用已在 drv_qpipsram.c 中声明。

   函数名要求如下:

   ```c
   void rt_hw_qpipsram_cs##ID##_gpio_take(void) //（##ID## 为对应 cs）。
   {
       // to-do;
   }
   void rt_hw_qpipsram_cs##ID##_gpio_release(void)
   {
       // to-do;
   }
   ```

   以 GPIO1_C0 模拟 cs1 为例，在相应的 iomux.c 中添加以下函数：

   ```c
   RT_UNUSED void rt_hw_qpipsram_cs1_gpio_init(void)
   {
       HAL_PINCTRL_SetIOMUX(GPIO_BANK1,
                            GPIO_PIN_C0,
                            PIN_CONFIG_MUX_FUNC0);
       HAL_GPIO_SetPinDirection(GPIO1, GPIO_PIN_C0, GPIO_OUT);
       HAL_GPIO_SetPinLevel(GPIO1, GPIO_PIN_C0, GPIO_HIGH);
   }

   RT_UNUSED void rt_hw_qpipsram_cs1_gpio_take(void)
   {
       HAL_GPIO_SetPinLevel(GPIO1, GPIO_PIN_C0, GPIO_LOW);
   }

   RT_UNUSED void rt_hw_qpipsram_cs1_gpio_release(void)
   {
       HAL_GPIO_SetPinLevel(GPIO1, GPIO_PIN_C0, GPIO_HIGH);
   }
   ```

3. 在 iomux.c 中添加 cs-gpio 初始化

   ```c
   void rt_hw_iomux_config(void)
   {
   	...
   #ifdef RT_USING_QPIPSRAM_FSPI_HOST_CS1_GPIO
       rt_hw_qpipsram_cs1_gpio_init();
   #endif
   }
   ```

4. 调整 IO 驱动强度

   由于 FSPI 多片选存在 IO 复用情况，速率较高的情况下 IO 可能无法正常驱动，需要提高驱动强度。

5. 驱动挂载成功标志

   RK QPI Psram 驱动将每一个 cs 上的 psram 单独挂载到设备驱动框架上，如 psram0 为 cs0 上设备，psram1 为 cs1 上设备。

注意事项：

1. cs-gpio 对应的设备只能通过 Psram 框架层接口进行访问，不支持 XIP 访问。

### SPI 控制器方案

```
RT-Thread rockchip common drivers  --->
    [*] Enable ROCKCHIP QPI Psram  --->
    (50000000) Reset the speed of QPI Psram in Hz
    Choose QPI Psram Adapter (Attach SPI controller to QPI Psram)  --->
      Attach SPI controller to QPI Psram
    (spi2_0)  the name of the SPI device which is used as QPIPSRAM adapter (NEW)
```

```
RT-Thread rockchip RK2108 drivers  --->
        Enable SPI  --->
        [*] Enable SPI2 /* 配置相应的 SPI 控制器 */
```

## XIP 访问

前面已经介绍 XIP 功能，如果满足以下条件，驱动会自动开启 XIP 功能，CPU 或部分 master 可以通过 XIP map address 直接读写 QPI Psram：

* 选用 FSPI 主控方案
* QPI Psram 设备对应的 cs 为 FSPI_CS 而非 gpio 模拟的片选

## 函数接口调用范例

QPI Psram 驱动上有一层 Psram 框架层。

代码：

```c
drv_psram.c/h
```

主要接口如下：

```c
rt_size_t rk_psram_read(struct rk_psram_device *dev, rt_off_t pos, rt_uint8_t *data, rt_size_t size);  /* 读接口 */
rt_size_t rk_psram_write(struct rk_psram_device *dev, rt_off_t pos, const rt_uint8_t *data, rt_size_t size);  /* 写接口 */
rt_err_t rk_psram_suspend(void); /* 休眠下挂的所有 Psram 设备 */
rt_err_t rk_psram_resume(void);  /* 唤醒下挂的所有 Psram 设备 */
```

具体调用接口可以参考 psram_test.c。

## 测试驱动

建议 QPI Psram 开发流程中引入以下测试流程，做简单的读写测试判断。

### 测试驱动配置

```
    RT-Thread bsp test case  --->
        RT-Thread Common Test case  --->
            [*] Enable BSP Common TEST
            [*]   Enable BSP Common PSRAM TEST (NEW)
```

如配置成功，在 msh 中会有 psram_test 的 命令选项。

### 设备挂载成功

```
msh />list_device
device           type         ref count
-------- -------------------- ----------
...
psram3   Character Device     0    /* QPI Psram 挂载于 FSPI cs3 */
psram2   Character Device     0    /* QPI Psram 挂载于 FSPI cs2 */
psram1   Character Device     0    /* QPI Psram 挂载于 FSPI cs1， */
psram0   Character Device     0    /* QPI Psram 挂载于 FSPI cs0，挂载于 SPI 设备上 */
...
```

### 测试命令

输入命令 psram_test 可以获取详细的说明，以下命令单位皆为 byte。

```
1. psram_test dev write offset size loop
2. psram_test dev read offset size loop
3. psram_test dev stress offset size loop
4. psram_test dev suspend(code should be place in sram)
5. psram_test dev resume(code should be place in sram)
6. psram_test dev read_test offset loop
like:
        psram_test psram0 write 2097152 4096 2000
        psram_test psram0 read 2097152 4096 2000
        psram_test psram0 stress 2097152 2097152 5000
        psram_test psram0 suspend
        psram_test psram0 resume
        psram_test psram0 read_test 0 1000
```

通常使用，以下命令完成对应 QPI Psram 的简单测试：

```
psram_test psram0 stress 2097152 2097152 1
```
