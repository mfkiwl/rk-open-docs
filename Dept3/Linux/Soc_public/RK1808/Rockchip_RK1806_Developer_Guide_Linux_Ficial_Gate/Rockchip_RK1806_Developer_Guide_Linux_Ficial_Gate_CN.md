# Rockchip RK1806 Linux Ficial Gate Developer Guide

文档标识：RK-KF-YF-330

发布版本：V1.1.0

日期：2020-03-19

文件密级：公开资料

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

 RK1806 Facial Gate SDK主要针对门锁闸机类产品开发使用，采用32位的rootfs。该SDK包含Ficial Gate闸机应用，该应用利用RK自研算法rockface实现了人脸检测，人脸特征点提取，人脸识别，活体检测流程。该SDK默认使用PS5268 RGB摄像头做人脸识别，HM2056红外摄像头做活体检测。

**产品版本**

| **芯片名称** | **内核版本**  |
| ------------ | ------------- |
| RK1806       | Linux 4.4.185 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​    技术支持工程师

​    软件开发工程师

 **修订记录**

| **日期**   | **版本** | **作者**    | **修改说明**  |
| ---------- | -------- | :---------- | ------------- |
| 2020-02-11 | V1.0.0   | Jianhua Lin | 初始版本      |
| 2020-03-19 | V1.1.0   | Jianhua Lin | 修改uboot配置 |

---

## **目录**

---
[TOC]
---

## 1 **SDK** 获取

SDK 下载命令如下：

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/linux/rk/platform/manifests -b linux -m rk1808_linux_release.xml
```

RK1806编译烧写环境的搭建请参考：

docs/SoC platform related/RK1808/Rockchip_RK1808_Linux_SDK_Release_V1.1.0_20190808_CN.pdf

## 2 **配置环境变量**

执行./build.sh device/rockchip/rk1806/BoardConfig_ficial_gate.mk

```shell
1806/release_sdk$ ./build.sh device/rockchip/rk1806/BoardConfig_ficial_gate.mk
processing option: device/rockchip/rk1806/BoardConfig_ficial_gate.mk
switching to board: /home/ljh/1806/release_sdk/device/rockchip/rk1806/BoardConfig_ficial_gate.mk
```

## 3 **编译固件**

### 3.1 **自动编译所有固件**

执行./build.sh 编译固件

```shell
1806/release_sdk$ ./build.sh
```

### 3.2 **编译uboot**

进入工程 uboot 目录下执行 make.sh

```shell
1806/release_sdk/u-boot$ ./make.sh rk1806
```

### 3.3 **编译kernel**

进入kernel目录执行以下命令自动完成 kernel 的编译及打包：

```shell
1806/release_sdk/kernel$ make rk1806_linux_defconfig
1806/release_sdk/kernel$ make rk1806-ficial-gate-v10.img
```

### 3.4 **编译rootfs**

```shell
ljh@SYS3:~/1806/release_sdk$ ./build.sh rootfs
```

## 4 **Ficial Gate 应用**

SDK中包含了Ficial Gate 闸机应用，该应用利用RK自有算法rockface实现了人脸检测，人脸特征点提取，人脸识别，活体检测流程。

具体包含以下功能：

1. 获取RGB摄像头图像数据做人脸识别，获取IR摄像头图像数据做活体检测。

2. 使用SQLITE3作为数据库来存储人脸特征值和用户名。

3. 利用MiniGui实现用户注册，删除注册数据，人脸框跟踪及用户名显示等操作。

4. 利用ALSA接口实现各流程语音播报功能。

开机后在控制台运行下面命令启动应用：

```shell
ficial_gate -f 30000 -e -i -c
```

该应用的具体说明文档请参考：

 sdk/app/ficial_gate/doc/Rockchip_Instruction_Ficial_Gate_CN.pdf

注： SDK中包含了RK自研算法rockface，但需要获取授权使用。具体获取授权流程请 联系业务并参考sdk/external/rockface/auth/README.md文档。

## 5 **其它说明**

1:产品化的时候可以修改/etc/fstab文件，以只读模式挂载userdata分区提高开机速度。

```shell
13 /dev/block/by-name/userdata     /userdata               ext2            ro,noauto               0       2
```

如果要读写userdata分区，使用`mount /userdata -o rw,remount`命令，将userdata分区重挂载为读写模式，操作结束后再用`mount /userdata -o ro,remount`命令挂载为只读模式。

2:如果客户已经基于RK1808开发完毕自己的应用，想直接切换成RK1806的平台，可以针对kernel的dts做如下修改并重新编译烧写kernel：

```c
--- a/arch/arm64/boot/dts/rockchip/rk1808-evb.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk1808-evb.dtsi
@@ -6,7 +6,7 @@
 #include <dt-bindings/input/input.h>
 #include <dt-bindings/pinctrl/rockchip.h>
 #include <dt-bindings/sensor-dev.h>
-#include "rk1808.dtsi"
+#include "rk1806.dtsi"
```

3：RK1808的开发板想要运行RK1806 SDK，需要把BoardConfig_ficial_gate.mk中的uboot配置改成rk1808

```shell
--- a/rk1806/BoardConfig_ficial_gate.mk
+++ b/rk1806/BoardConfig_ficial_gate.mk
@@ -3,7 +3,7 @@
 # Target arch
 export RK_ARCH=arm64
 # Uboot defconfig
-export RK_UBOOT_DEFCONFIG=rk1806
+export RK_UBOOT_DEFCONFIG=rk1808
 # Kernel defconfig
 export RK_KERNEL_DEFCONFIG=rk1806_linux_defconfig
 # Kernel dts
```

 注： SDK版本必须升级到rk1808_linux_release_v1.1.2_20191120.xml及以上才支持RK1806。