# UART开发指南

文件标识：RK-KF-YF-053

发布版本：V1.0.0

日期：2019-12-02

文件密级：内部资料

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
| V1.0.0    | 刘诗舫 | 2019-12-02 | 初始版本  |

**目录**

---

[TOC]

---

## 1 Rockchip UART功能特点

UART（Universal Asynchronous Receiver/Transmitter）

* 兼容16550A。
* UART0两组iomux，UART1三组iomux，UART2两组iomux。
* 支持硬件自动流控（UART1_M2除外）。
* 支持中断传输模式和DMA传输模式。
* 最高支持4M波特率。

## 2 软件开发

### 2.1 代码路径

串口驱动：

```c
src/driver/uart/UartDevice.c //串口驱动
include/driver/UartDevice.h
src/bsp/hal/lib/hal/src/hal_uart.c //串口硬件抽象层
src/bsp/hal/lib/hal/inc/hal_uart.h
```

串口测试命令（用户程序可参考）：

```c
src/subsys/shell/shell_uart.c
```

### 2.2 串口配置

在板级配置iomux.c中，可以查看所有UART设备的iomux配置。在板级配置board.c中，可以通过`UartDevHwInit(uint32 DevID, uint32 Channel)`函数配置UART设备，可以通过`DebugInit(void)`函数配置UART Console设备。

在menuconfig下，可以配置需要使用的uart设备。

```c
BSP Driver --->
    [*] Enable UART --->
        [*] Enable UART0
        [ ] Enable UART1
        [ ] Enable UART2
```

可以使用command shell命令`dev.list`可以查看已经生成的UART设备。

### 2.3 串口测试

使能串口测试程序：

```c
Components Config --->
    Command shell --->
        [*] Enable Uart Shell

/* 请打开DMA设备驱动 */
BSP Driver --->
    Enable DMA --->
        [*] Enable DesignWare DMA Controlle
```

串口测试命令：

```c
/* send data */
uart_test w uart<value> baudrate [dma] [autoflow]
Example: uart_test w uart1 115200 1 0
/* receive data */
uart_test r uart<value> baudrate [dma] [autoflow]
Example: uart_test r uart1 115200 1 0
```

可以使用command shell命令`io`读写UART设备寄存器值，检查是否符合预期。UART设备寄存器相关内容请参考数据手册。

### 2.4 波特率支持

1.5M以下的波特率都可以支持，1.5M以上的波特率需要实际测试是否支持，因为这跟CLK时钟树有关。RK2206能稳定支持的最高波特率为4M。

### 2.5 console配置

在menuconfig下，可以配置需要使用作为console的uart设备。

```c
Target Options --->
    Board Options --->
        (0) DEBUG_UART
```
