# Linux RetroArch 使用指南

文件标识：RK-KF-YF-367

发布版本：V1.0.0

日期：2020-06-12

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

本文提供一个Retroarch的使用说明。

**产品版本**

| **芯片名称**                       | **内核版本** |
| ---------------------------------- | ------------ |
| RK3036/RK3128/RK3326/RK3328/RK3399 | Linux4.4     |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | Zack.Huang | 2020-06-12 | 初始版本     |

---

**目录**

[TOC]

---

## RetroArch介绍

RetroArch 是款功能强大的跨平台模拟器，不但能够模拟许多不同的游戏主机，并且提供开源代码，可以移植在Linux, Window, Android等主流操作平台上。RetroArch的API的实现包括视频游戏系统模拟器、媒体播放器、游戏引擎以及更通用的 3D 程序。程序实例化为动态库，称为“Libretro Core”。用 C 或 C++ 编写的 libretro core 可以在许多平台上无缝运行，几乎不需要移植。其中“Libretro Core”包含4do, 81, mane等主流的模拟器核心，完美运行gba等格式的游戏。

## RetroArch源码模块介绍和自定义编译

### RetroArch的源码模块介绍

RetroArch源码在SDK/buildroot/output/rockchip_rkxxxx/build/retroarch-xxxxxxx

RetroArch目录介绍(下面有选择性的介绍几个核心的模块)

```
audio                      音频模块代码
bootstrap                  bootstrap前端框架代码
camera                     摄像头模块代码
cores                      core中包含RetroArch自己支持的核心库，包含ffmpeg,imageviewer,mpr库等等
menu                       RetroArch的菜单代码
network                    网络模块代码
wifi                       wifi模块代码
```

还有许多模块详细介绍在官方文档 <https://docs.libretro.com/>, 如果有需要可以详细阅读。

### 自定义编译RetroArch

```shell
make menuconfig
```

选择 Target packages -> Libretro cores and retroarch -> retroarch

您可以在 Target packages -> Libretro cores and retroarch -> Retroarch Cores中选择您需要的模拟器核心。

您也可以选择 Target packages -> Libretro cores and retroarch -> retroarch assets可以加载默认的UI资源。

选择完毕后退出menuconfig

```shell
make savedefconfig
```

编译：

```shell
make retroarch
```

**请注意：当您使用自定义编译RetroArch时，包含RetroArch的rootfs所占的固件空间会变大，您需要修改SDK/device/rockchip/rkxxxx/parameter-buildroot.txt文件，（rkxxxx表示您使用的芯片型号）来扩大rootfs的分区，具体修改方法请参见docs/tools/《Rockchip-Parameter-File-Format-Version1.4.pdf》第三章“文件内容说明”。**

## 运行RetroArch

### 使用命令行启动RetroArch

进入目标板输入命令行：（启动RetroArch的主界面）

```shell
/usr/bin/retroarch -c /oem/retroarch.cfg
```

下面是RetroArch启动界面的截图：

![](resources\retromainmenu.png)

我们将配置好的配置文件retroarch.cfg存放在/oem内，模拟器核心文件存放在 /usr/lib/libretro/中，当然，您也可以在启动的时候指定加载核心文件和游戏ROM：（直接开始游戏）

``` shell
/usr/bin/retroarch -c /oem/retroarch.cfg` -L /usr/lib/libretro/*.so<emulator core> <game_rom>
```

### 使用鼠标设备启动RetroArch

连接目标板和鼠标，显示设备等外设。当系统启动后出现显示桌面，SDK会在桌面上自动生成RetroArch的图标，双击打开它即可。

在RetroArch启动界面里您需要先加载模拟器核心：

![](resources\core.png)

之后可以选择您需要的核心：

![corelistm](resources\corelista.png)

在加载模拟器核心之后，您需要选择加载游戏内容：

![](resources\game.png)

