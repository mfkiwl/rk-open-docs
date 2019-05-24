# RISC-V 核运行 RT-Thread

发布版本：1.0

作者邮箱：jason.zhu@rock-chips.com

日期：2019.05

文件密级：内部资料

------

**前言**

**概述**

本文介绍如何在 Hifive1 开发板和 SCR1 核上运行 RT-Thread。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

**修订记录**

| **日期**   | **版本** | **作者**  | **修改说明** |
| ---------- | -------- | --------- | ------------ |
| 2019-05-23 | V1.0     | Jason Zhu | 初始版本     |

------

[TOC]

------

## 1 引用参考

[1]. 《RISC-V 架构与嵌入式开发快速入门》

[2]. <https://riscv.org/>

[3]. <https://ring00.github.io/bbl-ucore/#/toolchain-overview?id=risc-v-tools>

[4]. 《Rockchip-Developer-Guide-Riscv-FreedomStudio-CN.md》

## 2 术语

RISC-V：是一个基于精简指令集（RISC）原则的开源指令集架构（ISA）

RT-Thread：是一款主要由中国开源社区主导开发的开源实时操作系统（许可证 GPLv2）。实时线程操作系统不仅仅是一个单一的实时操作系统内核，它也是一个完整的应用系统，包含了实时、嵌入式系统相关的各个组件：TCP/IP 协议栈，文件系统，libc 接口，图形用户界面等

Hifive1：一款基于 RISC-V 指令集芯片的开发板

SCR1：SCR1 is an open-source RISC-V compatible MCU core, designed by Syntacore

## 3 测试平台

Hifive1 开发板

带 SCR1 核的 FPGA 测试板

RT-Thread

## 4 简介

本文介绍如何在 Hifive1 开发板和 SCR1 核的 FPGA 测试板上运行 RT-Thread 的过程。

## 5 Hifive1 移植流程

### 5.1 环境搭建

编译链工具下载：

```
下载gnu-mcu-eclipse的编译链工具
https://github.com/gnu-mcu-eclipse/riscv-none-gcc/releases?tdsourcetag=s_pctim_aiomsg
从sifive官网下载
https://www.sifive.com/boards
```

这里测试使用从 sifive 官网下载的编译链工具 riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux-ubuntu14。

其他工具安装：

```
sudo apt-get install scons
```

源码下载：

```
git clone https://github.com/RT-Thread/rt-thread.git
```

### 5.2 编译

修改 bsp/hifive1/rtconfig.py：

```
--- a/bsp/hifive1/rtconfig.py
+++ b/bsp/hifive1/rtconfig.py
@@ -10,7 +10,7 @@ if os.getenv('RTT_CC'):

 if  CROSS_TOOL == 'gcc':
     PLATFORM    = 'gcc'
-    EXEC_PATH   = r'/opt/unknown-gcc/bin'
+    EXEC_PATH   = r'../../../prebuilts/gcc/linux-x86/riscv64/riscv64-unknown-elf-gcc-8.2.0-2019.05.3-x86_64-linux/bin'
 else:
     print('Please make sure your toolchains is GNU GCC!')
     exit(0)
@@ -29,7 +29,7 @@ TARGET_NAME = 'rtthread.bin'
 #------- GCC settings ----------------------------------------------------------
 if PLATFORM == 'gcc':
     # toolchains
-    PREFIX = 'riscv-none-embed-'
+    PREFIX = 'riscv64-unknown-elf-'
     CC = PREFIX + 'gcc'
     CXX= PREFIX + 'g++'
     AS = PREFIX + 'gcc'
```

其中 EXEC_PATH 给定编译链路劲，PREFIX 给定编译链工具名前缀。

在 bsp/hifive 目录下编译：

```
scons
```

最后编译出 rtthread.bin，rtthread.elf，可用于下载调试。

### 5.3 程序下载

#### 5.3.1 Linux 环境

新建文件 99-openocd.rules，写入如下内容：

```
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403",ATTRS{idProduct}=="6010", MODE="664", GROUP="plugdev"
SUBSYSTEM=="tty", ATTRS{idVendor}=="15ba",ATTRS{idProduct}=="002a", MODE="664", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403",ATTR{idProduct}=="6010", MODE="664", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="15ba",ATTR{idProduct}=="002a", MODE="664", GROUP="plugdev"
```

把该文件拷贝到 /etc/udev/rules.d/ 目录下，在 bsp/hifive 下运行：

```
./openocd.sh
```

程序下载完毕，可以利用 gdb 工具进行调试。

可以在串口上看到结果：

![result](./Rockchip-Developer-Guide-RISCV-RT-Thread/result.png)

#### 5.3.2 Windows 环境

运行 FreedomStudio，在工程下右击，点击 Debug As，如下配置：

![run-debug](./Rockchip-Developer-Guide-RISCV-RT-Thread/run-debug.png)

点击 run，可以看到结果：

![result](./Rockchip-Developer-Guide-RISCV-RT-Thread/result.png)

## 6 SCR1 移植流程

### 6.1 环境搭建

参考 5.1 章节。

### 6.2 代码编译

从服务器下载代码：

```
git clone ssh://username@10.10.10.29:29418/rtos/rt-thread/rt-thread
```

切换到 develop 分支：

```
git checkout develop
```

进入 bsp/scr1 编译：

```
scons
```

### 6.3 调试

参考 5.3.2 章节。
