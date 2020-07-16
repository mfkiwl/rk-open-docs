# Rockchip Ramboot方案介绍

文件标识：RK-KF-YF-526

发布版本：V1.0.0

日期：2020-07-14

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

本文档旨在指导工程师如何快速使用Rockchip Linux 平台Ramboot方案。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RV1126/1109  | Linux 4.19   |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 林其浩   | 2020-07-14   | 初始版本     |
|            |          |              |              |
|            |          |              |              |

**目录**

[TOC]

---

## 简介

Rockchip Linux平台支持flash启动，及无flash ramboot启动方式。

1. flash启动方式，通过将固件烧写到flash中，上电后通过引导程序启动系统。

2. ramboot启动方式，通过将固件直接烧录到RAM中，通过引导程序启动系统。

这两种模式各有优缺点，用户根据需求选择使用。flash启动方式和无flash启动方式，在启动流程上无太大区别，主要在于loader和uboot引导位置差异，下面主要介绍RV1126/1109 SDK中无flash ramboot方案。

## Ramboot模式

### 概述

ramboot模式使用在无flash的机器上，但相应会在ram中常驻部分空间。ramboot模式主要由Loader、trust、uboot、boot（kernel+rootfs）组成，host端通过特定的烧脚本rv1126_rv1109_usb_upgrade.sh以及烧写工具upgrade_tool对连接在host端上的maskrom设备进行烧写，使无flash设备启动，正常工作。

### 配置和编译

device/rockchip/rv1126-1109/BoardConfig-ramboot-uvc.mk为参考ramboot config。

```shell
 1:  #!/bin/bash
 2:
 3:  # Target arch
 4:  export RK_ARCH=arm
 5:  # Uboot defconfig
 6:  export RK_UBOOT_DEFCONFIG=rv1126-ramboot
 7:  # Uboot image format type: fit(flattened image tree)
 8:  export RK_UBOOT_FORMAT_TYPE=fit
 9:  # Uboot SPL ini config
10:  export RK_SPL_INI_CONFIG=RV1126MINIALL_RAMBOOT.ini
11:  # Kernel defconfig
12:  export RK_KERNEL_DEFCONFIG=rv1126_defconfig
13:  # Kernel defconfig fragment
14:  export RK_KERNEL_DEFCONFIG_FRAGMENT=
15:  # Kernel dts
16:  #export RK_KERNEL, which must modify cmdline
17:  export RK_KERNEL_DTS=rv1126-ai-cam-ddr3-v1
18:  # boot image type
19:  export RK_BOOT_IMG=zboot.img
20:  # kernel image path
21:  export RK_KERNEL_IMG=kernel/arch/arm/boot/zImage
22:  # kernel image format type: fit(flattened image tree)
23:  export RK_KERNEL_FIT_ITS=boot.its
24:  # parameter for GPT table
25:  export RK_PARAMETER=parameter-buildroot-fit.txt
26:  # Buildroot config
27:  #export RK_CFG_BUILDROOT=rockchip_rv1126_rv1109_uvcc
28:  # Recovery config
29:  export RK_CFG_RECOVERY=
30:  # Recovery image format type: fit(flattened image tree)
31:  export RK_RECOVERY_FIT_ITS=boot4recovery.its
32:  # ramboot config
33:  export RK_CFG_RAMBOOT=rockchip_rv1126_rv1109_ramboot_uvcc
34:  # Pcba config
35:  export RK_CFG_PCBA=
36:  # Build jobs
37:  export RK_JOBS=12
38:  # target chip
39:  export RK_TARGET_PRODUCT=rv1126_rv1109
40:  # Set rootfs type, including ext2 ext4 squashfs
41:  export RK_ROOTFS_TYPE=cpio.gz
42:  # rootfs image path
43:  export RK_ROOTFS_IMG=rockdev/rootfs.${RK_ROOTFS_TYPE}
44:  # Set ramboot image type
45:  export RK_RAMBOOT_TYPE=CPIO
46:  # Set oem partition type, including ext2 squashfs
47:  export RK_OEM_FS_TYPE=ext2
48:  # OEM build on buildroot
49:  export RK_OEM_BUILDIN_BUILDROOT=YES
50:  # Set userdata partition type, including ext2, fat
51:  export RK_USERDATA_FS_TYPE=ext2
52:  #OEM config
```

将**RK_KERNEL_DTS**和**RK_CFG_RAMBOOT**修改为需要的板级配置及文件系统配置，并将kernel dts的cmdline修改为如下命令即可：

```shell
bootargs = "earlycon=uart8250,mmio32,0xff570000 console=ttyFIQ0 snd_aloop.index=7"
```

按照如下进行编译：

```shell
1:  ./build.sh device/rockchip/rv1126-1109/BoardConfig-ramboot-uvc.mk
2:  ./build.sh kernel
3:  ./build.sh uboot
4:  ./build.sh ramboot
```

编译完成后在./rockdev/目录下生产相应镜像文件，MiniLoaderAll.bin, trust.img, uboot.img, boot.img 。

### host端操作说明

![ramboot1](resources/ramboot1.png)

ramboot固件烧录流程如上图所示，具体的操作如下：

1. 通过usb将rv1126/1109设备连接至host设备，host识别到rv1126/1109 maskrom状态。

2. 将upgrade_tool, rv1126_rv1109_usb_upgrade.sh以及./rockdev/目录的MiniLoaderAll.bin, trust.img, uboot.img, boot.img 文件，通过adb 或其他方式推到host端的**同一目录下**。

3. 在host端修改upgrade_tool和rv1126_rv1109_usb_upgrade.sh可执行权限。

4. 在host端对应目录下，执行以下命令烧录：

   ```shell
   ./rv1126_rv1109_usb_upgrade.sh MiniLoaderAll.bin uboot.img trust.img boot.img
   ```

## 附录

1. rv1126_rv1109_usb_upgrade.sh：

```shell
#!/system/bin/sh
PROGRAM=${0##*/}

if [ $# -ne 4 ]; then
	echo 'Usage: '$PROGRAM' loader uboot trust boot'
	exit
fi
DIR=$(cd `dirname $0`; pwd)
UPGRADE_TOOL=$DIR/upgrade_tool
LOADER=$DIR/$1
UBOOT=$DIR/$2
TRUST=$DIR/$3
BOOT=$DIR/$4
UBOOT_ADDR=0x2000
TRUST_ADDR=0x42000
BOOT_ADDR=0x80000

if [ ! -f $UPGRADE_TOOL ]; then
	echo $UPGRADE_TOOL 'is not existed!'
	exit
fi

if [ ! -f $LOADER ]; then
	echo $LOADER 'is not existed!'
	exit
fi

if [ ! -f $UBOOT ]; then
	echo $UBOOT 'is not existed!'
	exit
fi

if [ ! -f $TRUST ]; then
	echo $TRUST 'is not existed!'
	exit
fi

if [ ! -f $BOOT ]; then
	echo $BOOT 'is not existed!'
	exit
fi

echo 'start to wait device...'
i=0
while [ $i -lt 5 ]; do
	$UPGRADE_TOOL ld > /dev/null
	if [ $? -ne 0 ]; then
		i=$(($i+1))
		echo $i
		sleep 0.01
	else
		break
	fi
done
if [ $i -ge 5 ]; then
	echo 'failed to wait device!'
	exit
fi
echo 'device is ready'

echo 'start to download loader...'
$UPGRADE_TOOL db $LOADER > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to download loader!'
	exit
fi
echo 'download loader ok'

echo 'start to wait loader...'
$UPGRADE_TOOL td > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to wait loader!'
	exit
fi
echo 'loader is ready'

echo 'start to write uboot...'
$UPGRADE_TOOL wl $UBOOT_ADDR $UBOOT > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to write uboot!'
	exit
fi
echo 'write uboot ok'

echo 'start to write trust...'
$UPGRADE_TOOL wl $TRUST_ADDR $TRUST > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to write trust!'
	exit
fi
echo 'write trust ok'

echo 'start to write boot...'
$UPGRADE_TOOL wl $BOOT_ADDR $BOOT > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to write boot!'
	exit
fi
echo 'write boot ok'

echo 'start to run system...'
$UPGRADE_TOOL rs $UBOOT_ADDR $TRUST_ADDR $BOOT_ADDR $UBOOT $TRUST $BOOT > /dev/null
if [ $? -ne 0 ]; then
	echo 'failed to run system!'
	exit
fi
echo 'run system ok'
```

2. ramboot烧写工具**upgrade_tool**请联系对应SDK负责人员或FAE提供。
