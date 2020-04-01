# Rockchip RK2108 RT-Thread SDK 发布说明

文档标识：RK-FB-YF-356

发布版本：V0.1.0

日期：2020-03-30

文件密级：□绝密   □秘密   □内部资料   ■公开

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有** **© 2020** **福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

---

## **前言**

**概述**

文档主要介绍 Rockchip RK2108 RT-Thread SDK发布说明，旨在帮助工程师更快上手RK2108 RT-Thread SDK开发及相关调试方法。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**各芯片系统支持状态**

| **芯片名称**    | **内核版本** |
| ----------- | :-------------- |
| RK2108 | RT-Thread v3.1.x |

 **修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| -----------| :-------------- | :------------- | :---------- |
| V0.0.1   | 钟勇汪   | 2019-09-05 | 初始版本     |
| V0.1.0   | 钟勇汪   | 2020-03-30 | 修改文档目录 |

## **目录**

---
[TOC]
---

## 1  概述

本SDK是基于RT-Thread v3.1.2 的软件开发包，包含RT-Thread系统开发用到的系统源码、驱动、工具、应用软件包。本SDK还包含开发文档，工具使用文档。适配RK2108芯片平台，适用于RK2108 EVB开发板及基于RK2108平台开发的所有产品。

## 2 主要支持功能

| **功能**    | **模块名** |
| ----------- | :-------------- |
| 数据通信 | Wi-Fi、BT、USB |
| 音频接口     | 模拟MIC、数字MIC（PDM、I2S）、Audio PWM、VAD |
| 显示接口 | MCU panel、SPI panel |
| 应用程序Demo | 语音控制模块，录音笔 |

## 3 SDK 获取说明

SDK通过瑞芯微代码服务器对外发布。其编译开发环境，参考第5节 SDK编译说明。

获取RK2108 RT-Thread软件包，需要有一个帐户访问Rockchip提供的源代码仓库。客户向瑞芯微技术窗口( 邮箱地址fae@rock-chips.com)申请SDK，同步提供SSH公钥进行服务器认证授权，获得授权后即可同步代码。关于瑞芯微代码服务器SSH公钥授权，请参考第6节 SSH公钥操作说明。

### 3.1 SDK下载命令

repo 是Google用 Python 脚本写的调用 git 的一个脚本，主要是用来下载、管理项目的软件仓库，其下载地址如下：

```shell
git clone ssh://git@www.rockchip.com.cn/repo/rk/tools/repo
```

RK2108 RT-Thread SDK下载命令如下：

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/rtos/rt-thread/rk/platform/release/manifests -b master -m rk2108_release.xml
```

代码仓库初始化完成后，可用如下命令进行代码的同步：

```shell
.repo/repo/repo sync
```

### 3.2 SDK代码压缩包

为方便客户快速获取SDK源码，瑞芯微技术窗口通常会提供对应版本的SDK初始压缩包，开发者可以通过这种方式，获得SDK代码的初始压缩包，该压缩包解压得到的源码，与通过repo下载的源码是一致的。

以RK2108_RT-Thead_SDK_Beta_V0.1.0_20200330.tar.gz为例，获取到该初始压缩包后，通过如下命令可检出源码：

```shell
tar zxvf RK2108_RT-Thead_SDK_Beta_V0.1.0_20200330.tar.gz
cd RK2108_RT-Thead_SDK_Beta_V0.1.0_20200330
.repo/repo/repo sync -l
.repo/repo/repo sync
```

### 3.3 SDK版本查看

SDK每次版本更新都会同步对应的版本xml，可通过以下命令查看SDK软件版本：

```shell
cd .repo/manifests
git log rk2108_release.xml
```

### 3.4 SDK代码更新

```shell
.repo/repo/repo sync
```

## 4 RK2108 RT-Thread工程目录介绍

工程目录下的bsp/rockchip/common/hal，components/hifi3， applications/rk_iot_app，Rockchip-docs-release这几个目录各自对应一个git工程，提交需要在各自的目录下进行。以下是SDK主要目录对应的说明：

- ChangeLog.md : RT-Thread的官方版本记录
- applications：此目录是Rockchip提供的各种应用demo源码
- bsp: 所有的芯片相关代码都在这个目录，只需要关注下一级rockchip目录
- bsp/rockchip/rk2108/: rk2108目录，编译脚本需要在此目录下运行
- bsp/rockchip/tools: Rockchip升级工具和打包工具
- components: 系统各个组件。其中hifi3 子目录是DSP源码，使用方法请参考文档User Guide->Driver->DSP
- examples: RTT例子程序和测试代码
- include: RTT官方头文件目录
- Rockchip-docs-release/：Rockchip工程文档目录
- src: RTT内核源码
- third_party: 第三方代码目录
- third_party/audio/audio_server: Rockchip 提供的音频编解码库和播放器
- tools: RTT官方工具目录，包括menuconfig和编译脚本

## 5 SDK编译说明

### 5.1 开发环境搭建

本SDK推荐的编译环境是64位的 Ubuntu16.04 或 Ubuntu18.04 ， 在其它 Linux 上尚未测试过, 因此推荐安装与Rockchip开发者一致的发行版。

编译工具选用的是RT-Thread官方推荐的 SCons + GCC，SCons 是一套由 Python 语言编写的开源构建系统， GCC 交叉编译器由ARM官方提供，可直接使用以下命令安装所需的所有工具：

```shell
sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa
sudo apt-get update
sudo apt-get install gcc-arm-embedded scons clang-format astyle libncurses5-dev build-essential python-configparser
```

如无法安装 toolchain ，还可从 ARM 官网下载编译器，通过环境变量指定 toolchain 的路径即可，具体如下：

```shell
wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
tar xvf gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2
export RTT_EXEC_PATH=/path/to/toolchain/gcc-arm-none-eabi-7-2018-q2-update/bin
```

### 5.2 基础编译打包命令

编译命令如下：

```shell
cd RK2108_RT-Thead_SDK_Beta_V0.1.0_20200330
cd bsp/rockchip/rk2108
cp board/开发板名称/defconfig .config
scons --menuconfig  //修改参加编译的模块开关，退出后会生成rtconfig.h文件，此文件参与最终的编译
./build.sh
```

生成的固件在：

```
Image/Firmware.img
```

RK2108 RT-Thread SDK更详细编译、调试以及刷机说明，使用浏览器打开Rockchip-docs-release/index.html文档，跳转到Quick Start章节。

## 6 SSH 公钥操作说明

请根据《Rockchip SDK 申请及同步指南》文档说明操作，生成 SSH 公钥，发邮件至fae@rock-chips.com，申请开通 SDK 代码。
该文档会在申请开通权限流程中，释放给客户使用。

### 6.1 多台机器使用相同 SSH 公钥

在不同机器使用，可以将你的 SSH 私钥文件 id_rsa 拷贝到要使用的机器的 “~/.ssh/id_rsa” 即可。
在使用错误的私钥会出现如下提示，请注意替换成正确的私钥

![ssh1](resources/ssh1.png)</left>

添加正确的私钥后，就可以使用 git 克隆代码，如下图。

![ssh2](resources/ssh2.png)</left>

添加 ssh 私钥可能出现如下提示错误。

```
Agent admitted failture to sign using the key
```

在 console 输入如下命令即可解决。

```shell
ssh-add ~/.ssh/id_rsa
```

### 6.2 一台机器切换不同 SSH 公钥

可以参考 ssh_config 文档配置 SSH。

```shell
~$ man ssh_config
```

![ssh3](resources/ssh3.png)</left>

通过如下命令，配置当前用户的 SSH 配置。

```shell
~$ cp /etc/ssh/ssh_config ~/.ssh/config
~$ vi .ssh/config
```

如图，将 SSH 使用另一个目录的文件 “~/.ssh1/id_rsa” 作为认证私钥。通过这种方法，可以切换
不同的的密钥。

![ssh4](resources/ssh4.png)</left>

### 6.3 密钥权限管理

服务器可以实时监控某个 key 的下载次数、IP  等信息，如果发现异常将禁用相应的 key 的下
载权限。
请妥善保管私钥文件。并不要二次授权与第三方使用。

### 6.4 参考文档

更多详细说明，可参考文档 sdk/docs/RKTools manuals/Rockchip SDK Kit 申请指南 V1.6-
201905.pdf。
