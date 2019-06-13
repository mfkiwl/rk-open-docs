# **UART**开发指南

发布版本：1.0

作者邮箱：hhb@rock-chips.com

日期：2019.06

文件密级：公开资料

---
**前言**

**概述**

**产品版本**
| **芯片名称**            | **RT Thread版本** |
| ----------------------- | :---------------- |
| 全部采用RT Thread的芯片 |                   |

**读者对象**

本文档（本指南）主要适用于以下工程师：
技术支持工程师
软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2019-06-13 | V1.0     | 洪慧斌   | 初始发布     |
|            |          |          |              |
|            |          |          |              |

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