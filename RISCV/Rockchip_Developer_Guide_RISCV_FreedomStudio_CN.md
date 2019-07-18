# Risc-v FreedomStudio IDE 调试

发布版本：1.0

作者邮箱：jason.zhu@rock-chips.com

日期：2018.12

文件密级：内部资料

------

**前言**

**概述**

本文参考《FreedomStudio IDE 使用说明》，供 risc-v 调试使用。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

**修订记录**

| **日期**   | **版本** | **作者**  | **修改说明** |
| ---------- | -------- | --------- | ------------ |
| 2018-12-27 | V1.0     | Jason Zhu | 初始版本     |

------

[TOC]

------

## Hifive1 调试

### 安装 HIFIVE1 上的 FTDI 驱动

HiFive 插到电脑，windows 默认把 FTDI 识别成两个 UART，如下：

![uart](./Rockchip_Developer_Guide_RISCV_FreedomStudio/uart.png)

这会导致 IDE 无法连接设备进行调试，需要把其中一个 Dial RS232-HS，解决方法如下：

1. 从<https://sourceforge.net/projects/libusbk/>下载 libusbk
2. 安装 libusbk
3. 在安装目录下找到 libusbK-inf-wizard.exe，运行。
4. 选择安装的 libusbk，下一步

![usb](./Rockchip_Developer_Guide_RISCV_FreedomStudio/usb.png)

5. 选中 Show All Device，可以看到三个 Dual RS232-HS。 第一个是父节点， 第二和第三个是两个子节点。如果选中父节点， 则生成的驱动会应用到父节点上。 如果选中某个子节点， 则生成的驱动只应用到相应的子节点上。 HiFive1 的第一个 FTDI 口用作 JTAG， 第二个 FTDI 口作 UART。 所以生成驱动时，选择第一个子节点就可以。
6. 运行生成目录 Dual_RS232-HS_Interface_0 下的 InstallDriver.exe
7. 最后可以在设备管理器上查找到对应的设备，如下：

![dual-usb](./Rockchip_Developer_Guide_RISCV_FreedomStudio/dual-usb.png)

至此，驱动安装完成。

### 基于 IDE 的工程建立与调试

1.File->New->Project->C Project

![c-project](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c-project.png)

2.点开 C Project，选择 SiFive C/C++ Project，Project name 输入工程名，如 hello_fifive：

![hello_sifive](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_sifive.png)

3.点击 next

![hello_sifive1](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_sifive1.png)

4.后续都采用默认操作，点击 next，最后点击 finish。

![hello_project2](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_project2.png)

5.点击 hello_sifive，右键点击 build project，编译工程。

![compile_result](./Rockchip_Developer_Guide_RISCV_FreedomStudio/compile_result.png)

6.调试：连接板子，点击 hello_sifive，右键点击 Debug configurations

![debug_configure](./Rockchip_Developer_Guide_RISCV_FreedomStudio/debug_configure.png)

7.点击 debug，调试工程。

![debug](./Rockchip_Developer_Guide_RISCV_FreedomStudio/debug.png)

## SCR1 调试

### 安装调试器驱动

参考安装 HIFIVE1 上的 FTDI 驱动章节安装驱动。

### 基于 FreedomStudio IDE 的工程建立与调试

1.File->New->Project->C Project，Project name 输入 hello_scr1，选择 Hello World RISC-V C Project

![hello_scr1](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_scr1.png)

2.一直点击 next，finish

![hello_scr2](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_scr2.png)

3.拷贝 hello_ncore 内的 include 与 lib 文件夹到工程目录 src 下，然后点击右键 Refresh

![hello_scr3](./Rockchip_Developer_Guide_RISCV_FreedomStudio/hello_scr3.png)

4.点击工程名右键 Properties，选择 C/C++ Build->Settings，如下配置 Target Processor

![c_build](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c_build.png)

5.选择 GNU RISC-V Cross C Compiler->Includes，配置如下

![c_build1](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c_build1.png)

6.选择 GNU RISC-V Cross C Linker->General，配置如下

![c_build3](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c_build3.png)

![c_build4](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c_build4.png)

7.选择 GNU RISC-V Cross C Linker->Miscellaneous

![c_build5](./Rockchip_Developer_Guide_RISCV_FreedomStudio/c_build5.png)

8.将 main.c 中的 printf 改为 sc_printf, 同时添加**#include** "sc_print.h"，编译成功。

9.调试：连接板子，点击 hello_scr1，右键点击 Debug configurations

![debug_scr1](./Rockchip_Developer_Guide_RISCV_FreedomStudio/debug_scr1.png)

如果连接错误，可以尝试使用绝对路径，配置如下：

![debug_scr2](./Rockchip_Developer_Guide_RISCV_FreedomStudio/debug_scr2.png)

10.Debug
