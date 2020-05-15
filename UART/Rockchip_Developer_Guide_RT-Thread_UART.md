# RT-Thread UART开发指南

文件标识：RK-KF-YF-90

发布版本：V1.1.0

日期：2020-05-15

文件密级：□绝密   □秘密   □内部资料   ■公开

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

| **支持芯片**  | **RT-Thread 版本** |
| -------------- | ---------------------- |
| RK2108  | lts-v3.1.x/master  |
| RK2206  | lts-v3.1.x/master  |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师、软件开发工程师

**修订记录**

| **版本** | **作者** | **日期**   | **修改说明** |
| --------- | --------- | ---------- | -------- |
|  V1.0.0   | 洪慧斌 | 2019-06-13 | 初始版本     |
|  V1.1.0  | 刘诗舫 | 2020-05-15 | 格式修订     |

---
[TOC]
---

## 1 Rockchip UART 功能特点

UART （Universal Asynchronous Receiver/Transmitter）

* 兼容16550A
* 部分串口支持硬件自动流控，部分不支持，详细参看数据手册
* 支持中断传输模式和DMA传输模式
* 最高支持4M波特率兼容16550A

## 2 软件

### 2.1 代码路径

串口框架：

```c
components/drivers/include/drivers/serial.h
components/drivers/serial/serial.c 设备驱动
components/libc/termios/posix_termios.c 类似linux的tty配置
components/libc/termios/posix_termios.h
```

串口驱动适配层：

```c
bsp/rockchip-pisces/drivers/drv_uart.c
bsp/rockchip-pisces/drivers/drv_uart.h
```

串口测试命令，串口用户程序完全可以参照以下驱动：

```c
bsp/rockchip-common/tests/termios_test.c
```

### 2.2 配置

打开串口配置，同时会生成/dev/uart0..9设备。

```c
RT-Thread bsp drivers  --->
    RT-Thread rockchip common drivers  --->
        [*] Enable UART
        [*]   Enable UART0
        [ ]   Enable UART1
        [*]   Enable UART2
        [ ]   Enable UART3
        [ ]   Enable UART4
        [ ]   Enable UART5
        [ ]   Enable UART6
        [ ]   Enable UART7
        [ ]   Enable UART8
        [ ]   Enable UART9
```

执行命令可以看到已经生成的串口设备：

~~~c
msh >list_device
device         type         ref count
------ -------------------- ----------
uart7  Character Device     0
uart6  Character Device     0
uart5  Character Device     0
uart4  Character Device     2
uart3  Character Device     0
uart2  Character Device     0
uart1  Character Device     0
uart0  Character Device     0
~~~

### 2.3 串口测试

使能串口测试程序：

~~~c
RT-Thread bsp test case  --->
    [*] Enable BSP Common TEST
    [*] Enable BSP Common UART TEST

RT-Thread bsp test case  --->
    [*] Enable BSP Private TEST

RT-Thread Components  --->
    Device virtual file system  --->
        [*] Using device virtual file system
        -*- Using devfs for device objects
    POSIX layer and C standard library  --->
        [*] Enable termios feature
~~~

串口测试命令：

~~~c
    receive data:
    termtest r /dev/uart4 115200
    send data:
    termtest s /dev/uart4 115200
    receive then send:
    termtest t /dev/uart4 115200
~~~

### 2.4 波特率支持

1.5M以下的波特率都可以支持，1.5M以上的波特率需要实际测试看支不支持，因为这跟CLK 时钟树有关。

### 2.5 console配置

~~~c
RT-Thread Kernel  --->
    Kernel Device Object  --->
    [*] Using console for rt_kprintf
        (128) the buffer size for console log printf
        (uart2) the device name for console
        (1500000) the baud rate for console
~~~