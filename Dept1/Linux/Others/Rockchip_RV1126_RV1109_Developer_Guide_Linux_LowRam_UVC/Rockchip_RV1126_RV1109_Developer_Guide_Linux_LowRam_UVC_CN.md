# Rockchip 低内存UVC功能方案介绍

文件标识：RK-KF-YF-534

发布版本：V1.1.0

日期：2020-11-05

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

本文档旨在指导工程师如何快速使用Rockchip Linux 平台低内存UVC功能方案。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RV1126/1109  | Linux 4.19   |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者**  | **修改日期** | **修改说明** |
| ---------- | --------- | :----------- | ------------ |
| V1.0.0     | kevin.lin | 2020-11-03   | 初始版本     |
| V1.1.0     | Martin.Cheng | 2020-11-05 | 摄像头的配置 |
|            |           |              |              |

---

**目录**

[TOC]

---

## 简介

Rockchip Linux平台支持128M Flash、256M DDR规格的UVC全功能预览，在对外release SDK上，添加部分配置即可实现128M Flash、256M DDR规格的UVC功能。

## 低内存方案配置说明

### kernel

1. 配置最优的cma内存

cma 内存是系统启动时，预留给指定设备的专用连续内存块。cma 内存的大小配置，需要考虑以下几点：

- 物理摄像头分辨率: 3840x2160, 建议配置512M, 即: 0x10000000
- 物理摄像头分辨率: 2560x1440, 建议配置128M, 即: 0x8000000
- 物理摄像头分辨率: 1920x1080, 建议配置 64M, 即: 0x4000000

以256M内存和1080P摄像头为例，对于isp_reserved cma buffer，需要修改板级配置，比如在rv1126-ai-cam-ddr3-v1.dts中添加:

```diff
diff --git a/arch/arm/boot/dts/rv1126-ai-cam-ddr3-v1.dts b/arch/arm/boot/dts/rv1126-ai-cam-ddr3-v1.dts
index cb5c2c3..f349f0a 100644
--- a/arch/arm/boot/dts/rv1126-ai-cam-ddr3-v1.dts
+++ b/arch/arm/boot/dts/rv1126-ai-cam-ddr3-v1.dts
@@ -104,3 +104,7 @@
        };

 };
+
+&isp_reserved {
+    size = <0x4000000>;
+};
```

2. 配置摄像头驱动的CROP分辨率

对于低内存(256M)的硬件，特别是16bit 256M内存的配置。如果摄像头不是1080P的输出，建议将摄像头驱动默认按照1080P CROP优先输出。1080P CROP输出能够显著减低ISP的DDR的带宽消耗，使系统的DDR带宽消耗更加均衡。2560x1440分辨率图像输出时，ISP需要消耗 1500M的DDR带宽；1920x1080分辨率图像输出时，ISP仅需要消耗800M的DDR带宽；

1080P CROP优先输出，需要做以下配置:

- 找到对应的摄像头驱动文件，即 kernel/drivers/media/i2c/xxxx.c
- 修改摄像头驱动，配置1080 CROP优先输出。

### device/rockchip

zram 是Linux内核的一项功能，可提供虚拟内存压缩。zram swap 主要原理就是从内存分配一块区域出来用作 swap 分区，当程序的内存数据被切换到zram swap分区时，程序的内存数据将被压缩(压缩系数0.4)。对于低内存(256M)的硬件，使用zram swap可以节省内存，并且能够提高低内存切换效率。

查看zram使用情况，可使用命令：

`$ cat /proc/meminfo | grep Swap`

对于低内存(256M)的硬件，我们可以做如下zram配置。

```diff
diff --git a/oem/oem_uvcc/RkLunch.sh b/oem/oem_uvcc/RkLunch.sh
index 71cb4c9..931c8fc 100755
--- a/oem/oem_uvcc/RkLunch.sh
+++ b/oem/oem_uvcc/RkLunch.sh
@@ -1,6 +1,11 @@
 #!/bin/sh
 #

+#set zram swapon
+echo 64M > /sys/block/zram0/disksize
+mkswap /dev/zram0
+swapon /dev/zram0
+
 #vi_aging adjust
 io -4 0xfe801048 0x40
```

### external/rockit

external/rockit/sdk/conf 目录包含多种规格配置。具体使用任务图配置，需要考虑以下几点：

- 不同的json配置文件包含有不同拓扑结构的任务图。
- 相对简单的任务图配置占用的内存比较小, 256M内存建议使用简单的配置。
- 自定义任务图配置，可选配符合功能的最小任务图配置。

以256M内存为例，我们选择单纯UVC的任务图配置，修改方法如下：

```diff
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 2a31939..5a8a362 100755
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -3,12 +3,7 @@ cmake_minimum_required(VERSION 3.8)

 include(sdk/RockitConfig.cmake)

-option(USE_STASTERIA  "enable stasteria" OFF)
-if (${USE_STASTERIA})
-    set(AI_CAMERA_CONF ${ROCKIT_FILE_CONFIGS}/aicamera_stasteria.json)
-else()
-    set(AI_CAMERA_CONF ${ROCKIT_FILE_CONFIGS}/aicamera_rockx.json)
-endif()
+set(AI_CAMERA_CONF ${ROCKIT_FILE_CONFIGS}/aicamera_uvc_zoom.json)

 install(FILES ${AI_CAMERA_CONF} DESTINATION ../../oem/usr/share/aiserver/  RENAME  "aicamera.json")
```

