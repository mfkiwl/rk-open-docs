# DSP 开发指南

发布版本：1.0

作者邮箱：huaping.liao@rock-chips.com

日期：2019.6

文件密级：公开资料

------

**前言**

**概述**

本文档主要介绍Rockchip DSP开发的基本方法。

**产品版本**

| **芯片名称** | **RT Thread版本** |
| :----------- | ----------------- |
| RK2108       |                   |
| X1           |                   |
| RK2206       |                   |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2019-06-24 | V1.0     | 廖华平   | 初始版本     |

------

[TOC]

------

## 1 Rockchip DSP简介

DSP 即数字信号处理技术。DSP 作为数字信号处理器将模拟信号转换成数字信号，用于专用处理器的高速实时处理。 它具有高速，灵活，可编程，低功耗的界面功能，在图形图像处理，语音处理，信号处理等通信领域起到越来越重要的作用。如下为Cadence® Tensilica® HiFi3 DSP 的简介。

- HiFi3 DSP是一种ISA，支持2-way SIMD处理 。
- HiFi3 DSP支持同时处理两个32x32或24x32 bit数据，4个24x24、16x32或16x16 bit数据。
- HiFi3 DSP支持同时处理两个IEEE-754浮点数据。

目前，Rockchip SoC上集成的DSP说明如下：

- RK2108、RK2206和X1集成HIFI3 DSP。

------

## 2 HIFI3软件环境搭建

### 2.1 Xploere工具安装

Cadence 开发工具全称为“RUN Xplorer 8.0.8”，下载工具需要到Cadence官网，LICENSE需要联系Cadence获取。

工具安装好后，需要安装先安装数据包“HiFi3Dev181203_win32.tgz”，数据包基于RG-2018.9的基础工具安装包“XtensaTools_RG_2018_9_win32.tgz”。相关安装包都需要找开发人员获取。

安装方法是在Xplorer中，"File->New->Xtensa Configuration",找到下图的配置页面并点击Install选项：

![Xtensa_Configuration](Rockchip_Developer_Guide_RT-Thread_DSP/Xtensa_Configuration.png)

点击Next并且选择文件“HiFi3Dev181203_win32.tgz”后，会提示安装RG-2018.9，这时候点击“Manage Xtensa Tools”安装“XtensaTools_RG_2018_9_win32.tgz”，安装完成后，就可以进行数据包的安装操作。

数据包安装完成后，会在工具栏看到"C:(Active configuration)"栏目中看到HiFi3Dev181304，点击并选中：

![HiFi3Dev181304](Rockchip_Developer_Guide_RT-Thread_DSP/HiFi3Dev181304.png)

这时候软件左下角的System Overivew就会看到相关HiFi3Dev181304的配置文件，点击相关文件，会看到当前Core的配置信息。可以看到对应的ITCM、DTCM、中断号等。连接外部INTC的中断为INterrupt0.

![HiFi3Dev181304_Detail](Rockchip_Developer_Guide_RT-Thread_DSP/HiFi3Dev181304_Detail.png)

### 2.2 DSP代码下载及编译

Git仓库路径：

- ssh://git@10.10.10.29:29418/rk/dsp/hifi3

工程目录在根目录的projects下，存放不同工程的配置文件和工程文件。

通过"File->Import->Genaral->Existing Projects into Workspace"导入工程代码，不同项目对应不同的工程名称，RK2108对应工程名是PISCES，RK2206对应工程名是CANARY。

在工具栏选择编译的优化等级，分为Debug、Release和ReleaseSize。不同优化等级对代码有不同程度的优化，具体的优化内容可以进入配置选项查看。点击工具栏的“Build Active”即可正常进行编译，编译结果存放在工程目录的bin目录下。

### 2.3 DSP固件生成

工具生成的执行文件只能用于工具仿真，不能直接跑在设备上。运行cmd控制台，找到工程根目录，运行固件生成脚本“generate_dsp_fw.bat 项目名“，如果是PISCES项目，项目名对应的就是PISCES，脚本会将对应工程目录的FwConfig.xml和执行程序拷贝到tool目录下，运行HifiFirmwareGenerator.exe进行固件打包，最终固件存放于tools/HifiFirmwareGenerator/output/rkdsp.bin。HifiFirmwareGenerator.exe的源码存于：

- ssh://git@10.10.10.29:29418/rk/dsp/DspFirmwareGenerator
- <https://github.com/LiaoHuaping/DspFirmwareGenerator>

### 2.4 固件打包配置文件

在每个工程目录下，均有一个FwConfig.xml文件，该文件采用xml定义一些固件配置。当运行HifiFirmwareGenerator.exe时，会解析当前目录的FwConfig.xml，这里列出几个关键字段的含义：

- CoreName：编译的Core的名称，当前使用的是HiFi3Dev181203。
- ToolsPath：安装Xplorer 的工具目录，进行固件打包时，会使用到安装的工具包。
- ExecutableFile：输入固件名。
- ExternalFile：除DSP固件外，额外需要打包的文件名。如没有，置空即可。
- ExternalAddr：额外需要打包的文件需要加载的地址。
- SourceCodeMemStart：DSP端代码内存空间的起始地址。
- SourceCodeMemEnd: DSP端代码内存空间的结束地址。
- DestinationCodeMemStart：MCU端对应的代码内存空间的地址，因为可能存在内存空间映射情况不同的情况。比如同一块物理内存地址TCM，DSP的访问的地址是0x30000000，MCU访问的地址是0x20400000，它们分别对应SourceCodeMemStart和DetinationCodeMemStart。如果地址映射相同，那么填入对应即可。

### 2.5 Map配置信息修改

Xplorer在链接阶段需要根据Map配置信息进行各个数据段的空间分配。在"T:(active build target)->Modify"，选择Linker。可以看到Standard选项，可以选择默认的Map配置，Xplorer为开发者提供了min-rt、sim等配置，这些配置文件目录存放在“<工具安装目录>\explor8\XtDevTools\install\builds\RG-2018.9-win32\HiFi3Dev181203\xtensa-elf\lib”目录下。配置相关信息可以查看文档“<工具安装目录>\XtDevTools\downloads\RI-2018.0\docs\lsp_rm.pdf”。

段配置文件为“memmap.xmm”。text、data等会存放在sram0中，这是Share Memory的地址空间，需要将这些段存放在TCM中。可以参考“<工程目录>\rkdsp\projects\PISCES\map\min-rt\memmap.xmm”中的相关修改。修改完后，需要使用命令“<工具安装目录>\XtDevTools\install\tools\RG-2018.9-win32\XtensaTools\bin\xt-genldscripts.exe -b <map目录> --xtensa-core=HiFi3Dev181203”。这时候可以在Linker中指定map目录，重新编译即可。如果选中“Generate linker map file”，那么就会在编译完成后生成“.map”文件，里面记录了具体函数分配到的地址空间，以验证上述修改是否生效。

## 3 MCU端软件

### 3.1 代码路径

DSP框架：

```
bsp/rockchip-common/drivers/dsp.c
bsp/rockchip-common/drivers/dsp.h
```

DSP驱动适配层：

```
bsp/rockchip-common/drivers/drv_dsp.c
bsp/rockchip-common/drivers/drv_dsp.h
```

DSP驱动调用流程可以参考以下测试用例：

```
bsp/rockchip-common/tests/dsp_test.c
```

### 3.2 配置

打开DSP driver配置如下：

```
RT-Thread bsp drivers  --->
    RT-Thread rockchip common drivers  --->
        [*] Enable DSP
        [ ]   Enable firmware loader to dsp
        [ ]   Enable dsp send trace to cm4
```

选中”Enable firmware loader to dsp“表示dsp驱动启动的时候，会下载dsp固件；“Enable dsp send trace to cm4”表示使能trace功能，使得部分dsp中的打印log可以在mcu中打印出来，那么打印log就不需要依赖于单独的串口。

打开dsp test case配置如下：

```
RT-Thread bsp test case  --->
   RT-Thread Common Test case  --->
        [*] Enable BSP Common DSP TEST
```

执行命令可以看下已经生成的测试命令

```
msh >help
RT-Thread shell commands:
shutdown         - Shutdown System
reboot           - Reboot System
dsp_test        -dsp_test test. e.g: dsp_test()
```

执行“dsp_test”命令即可进行DSP驱动代码测试。

## 4 MCU驱动分析

### 4.1 驱动调用

驱动调用方式可以参考“bsp/rockchip-common/tests/dsp_test.c”。

```
struct rt_device *dsp_dev = rt_device_find("dsp0");
rt_device_open(dsp_dev, RT_DEVICE_OFLAG_RDWR);
rt_device_control(dsp_dev, RKDSP_CTL_QUEUE_WORK, work);
rt_device_control(dsp_dev, RKDSP_CTL_DEQUEUE_WORK, work);
rt_device_close(dsp_dev);
```

调用rt_device_open时候，会调用到驱动的“rk_dsp_open”函数，会执行启动DSPcore以及下载固件，并且将DSP 代码运行起来。

调用“rt_device_control(dsp_dev, RKDSP_CTL_QUEUE_WORK, work)”的时候，传入work指针，驱动会通过mailbox将work发送给dsp，dsp解析work，并进行相应的算法操作，将work处理结果传回来。调用“rt_device_control(dsp_dev, RKDSP_CTL_DEQUEUE_WORK, work)”可以取回DSP的算法处理结果，如果DSP仍在处理中，那么该函数会阻塞，直到dsp处理完成。

### 4.2 通信协议

MCU和DSP通过Mailbox进行通信，Mailbox包含4个通道，一个通道传输32bit的cmd和data数据。每次发送消息，cmd通道传输命令码，表示这次消息进行哪些操作；data通道传输数据，一般为work或者config的buffer指针。命令码存于在drv_dsp.h中，DSP_CMD_WORK、DSP_CMD_READY、DSP_CMD_CONFIG等。

当DSP启动后，DSP会进行自身的初始化等操作。初始化完成后，DSP会发送DSP_CMD_READY命令，MCU端接收到后，会调用“rk_dsp_config”函数对dsp进行trace等相关信息的配置。DSP接收到DSP_CMD_CONFIG并且配置完成后，会发送DSP_CMD_CONFIG_DONE，表示配置已经完成，可以进行算法工作。这三次消息发送相当于一个握手过程，握手完成后就可以进行算法调用。
