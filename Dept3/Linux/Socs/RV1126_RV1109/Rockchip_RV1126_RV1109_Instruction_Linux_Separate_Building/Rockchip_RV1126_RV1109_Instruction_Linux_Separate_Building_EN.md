# Instructions to separate the build system image from the SDK

ID: RK-SM-YF-386

Release Version: V1.4.0

Release Date: 2020-09-15

Security Level: □Top-Secret   □Secret   □Internal   ■Public

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by      their respective owners.

**All rights reserved. ©2020. Rockchip Electronics Co., Ltd.**

Beyond the scope of fair use, neither any entity nor individual shall extract, copy, or distribute this document in any form in whole or in part without the written approval of Rockchip.

Rockchip Electronics Co., Ltd.

No.18 Building, A District, No.89, software Boulevard Fuzhou, Fujian,PRC

Website:     [www.rock-chips.com](http://www.rock-chips.com)

Customer service Tel:  +86-4007-700-590

Customer service Fax:  +86-591-83951833

Customer service e-Mail:  [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**Preface**

**Overview**

The document presents the separate compiling kernel U-Boot or Rootfs of Rockchip RV1126/RV1109 Linux SDK, aiming to help engineers get started with RV1126/RV1109 Linux SDK faster.

**Product Version**

| **Chipset**   | **Kernel Version** |
| ------------  | ------------       |
| RV1126/RV1109 | Linux 4.19         |

**Intended Audience**

This document (this guide) is mainly intended for:

- Technical support engineers
- Software development engineers

**Revision History**

| **Version** | **Author** | **Date** | Revision History |
| ---------- | --------| :--------- | ------------ |
| 2020-08-10 | V1.0.0 | CWW  |   alpha                                                      |
| 2020-08-12 | V1.1.0 | CWW  | 1. Add idblock.bin compile instructions<br>2. Add drivers insmod|
| 2020-09-01 | V1.2.0 | CWW  | 1. Support eMMC compile instructions                           |
| 2020-09-10 | V1.3.0 | CWW  | 1. Add Debug info chapter                           |
| 2020-09-15 | V1.4.0 | CWW  | 1. Support AB system compilation                           |

[TOC]

## U-Boot compilation

### Get U-Boot code from SDK

Get thses directories from root directory of SDK:

| Directory | Instructions                      |
| --------- | ------------                      |
| rkbin     | about DDR and prebuilt loader bin |
| u-boot    | U-Boot code                       |
| prebuilts | cross-compile tool                |

### For SPI NOR U-Boot compilation

``` shell
cd u-boot
./make.sh rv1126-spi-nor-tiny
./make.sh spl-s # or ./make.sh --spl
./make.sh --idblock --spl
```

### For eMMC U-Boot compilation

#### Non-support AB system

``` shell
cd u-boot
./make.sh rv1126
./make.sh spl-s  # or ./make.sh --spl
# parameter e.g.
# mtdparts=rk29xxnand:0x00002000@0x00004000(uboot),0x00010000@0x00006000(boot),0x00010000@0x00016000(rootfs),-@0x00026000(data:grow)
```

#### Support AB system

``` shell
cd u-boot
./make.sh rv1126-ab
./make.sh spl-s  # or ./make.sh --spl
# parameter e.g.
# mtdparts=rk29xxnand:0x00002000@0x00004000(uboot_a),0x00002000@0x00006000(uboot_b),0x00001000@0x00008000(misc),0x00010000@0x00009000(boot_a),0x00010000@0x00019000(boot_b),0x00020000@0x00029000(system_a),0x00020000@0x00049000(system_b),-@0x00069000(data:grow)
```

### Instructions to U-Boot images

| the name of image         | comment                                             |
| ------------------------- | --------------------------------------------        |
| rv1126_spl_loader_***.bin | loader file                                         |
| uboot.img                 | U-Boot image                                        |
| idblock.bin               | the IDBlock partition file for firmware_merger tool |

## Linux kernel compilation

### Get linux kernel code from SDK

Get thses directories from root directory of SDK:

| Directory | Instructions       |
| --------- | ------------       |
| kernel    | linux kernel code  |
| prebuilts | cross-compile tool |

### Build command explanation

Build command format:

```shell
# configure linux kernel
# args1: chip architecture (e.g. arm)
# args2: linux kernel defconfig filename (e.g. xxx_defconfig)
# args3: linux kernel defconfig fragment filename (option)
make ARCH=args1 args2 args3
make menuconfig # this step is optinal

# make kernel image
# args1: chip architecture (e.g. arm)
# args2: linux kernel dts's filename (e.g. arch/arm/boot/dts/rv1126-38x38-v10-emmc.dts)
# -j12: allow 12 jobs compilation at once
make ARCH=args1 args2.img -j12
```

### For SPI NOR linux kernel compilation

``` shell
make ARCH=arm rv1126_defconfig rv1126-spi-nor.config
make ARCH=arm rv1126-38x38-v10-spi-nor.img -j12
```

### For eMMC linux kernel compilation

#### Build eMMC kernel without peripheral drivers

``` shell
make ARCH=arm rv1126_defconfig rv1126-emmc-drivers-modules.config
make ARCH=arm rv1126-38x38-v10-emmc.img -j12
```

#### Build eMMC kernel with peripheral drivers

``` shell
make ARCH=arm rv1126_defconfig rv1126-emmc-drivers-builtin.config
make ARCH=arm rv1126-38x38-v10-emmc.img -j12
```

### Package drivers (only for building without peripheral drivers into kernel)

```shell
make modules_install ARCH=arm INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=./drivers-ko
# remove unused soft link
rm -f drivers-ko/lib/modules/4.19.111/build drivers-ko/lib/modules/4.19.111/source
```

### Instructions to linux kernel image

| the name of image | comment                               |
| ---------         | ---------------------                 |
| zboot.img         | linux kernel image                    |
| drivers-ko        | the directory of linux kernel drivers |

### Instructions to drivers insmod (only for building without peripheral drivers into kernel)

``` shell
# insmod videobuf2
insmod kernel/drivers/media/common/videobuf2/videobuf2-memops.ko
insmod kernel/drivers/media/common/videobuf2/videobuf2-dma-contig.ko
insmod kernel/drivers/media/common/videobuf2/videobuf2-common.ko
insmod kernel/drivers/media/common/videobuf2/videobuf2-v4l2.ko
insmod kernel/drivers/media/common/videobuf2/videobuf2-vmalloc.ko

# insmod drm
insmod kernel/drivers/gpu/drm/drm_kms_helper.ko
insmod kernel/drivers/gpu/drm/rockchip/rockchipdrm.ko

# insmod audio
insmod kernel/sound/soundcore.ko
insmod kernel/sound/core/snd.ko
insmod kernel/sound/core/snd-timer.ko
insmod kernel/sound/core/snd-pcm.ko
insmod kernel/sound/core/snd-pcm-dmaengine.ko
insmod kernel/sound/soc/snd-soc-core.ko
insmod kernel/sound/soc/codecs/snd-soc-dummy-codec.ko
insmod kernel/sound/soc/codecs/snd-soc-rk817.ko
insmod kernel/sound/soc/rockchip/snd-soc-rockchip-i2s-tdm.ko
insmod kernel/sound/soc/generic/snd-soc-simple-card-utils.ko
insmod kernel/sound/soc/generic/snd-soc-simple-card.ko

# insmod isp ispp cif rk_ircut and sensor
insmod kernel/drivers/media/v4l2-core/v4l2-fwnode.ko
insmod kernel/drivers/media/i2c/os04a10.ko
insmod kernel/drivers/media/i2c/imx415.ko
insmod kernel/drivers/media/i2c/rk_ircut.ko
insmod kernel/drivers/phy/rockchip/phy-rockchip-mipi-rx.ko
insmod kernel/drivers/media/platform/rockchip/cif/video_rkcif.ko
insmod kernel/drivers/media/platform/rockchip/isp/video_rkisp.ko
insmod kernel/drivers/media/platform/rockchip/ispp/video_rkispp.ko
echo 1 > /sys/module/video_rkisp/parameters/clr_unready_dev
echo 1 > /sys/module/video_rkispp/parameters/mode

# insmod vcodec
insmod kernel/drivers/video/rockchip/mpp/rk_vcodec.ko

# insmod usb for adb
insmod kernel/drivers/phy/rockchip/phy-rockchip-naneng-usb2.ko
insmod kernel/drivers/usb/dwc3/dwc3-of-simple.ko
insmod kernel/drivers/usb/dwc3/dwc3.ko

# insmod for adc key
insmod kernel/drivers/input/keyboard/adc-keys.ko

# insmod for led flash
insmod kernel/drivers/leds/led-class-flash.ko
insmod kernel/drivers/leds/leds-rgb13h.ko

# insmod sdcard ko
insmod kernel/drivers/mmc/host/dw_mmc.ko
insmod kernel/drivers/mmc/host/dw_mmc-pltfm.ko
insmod kernel/drivers/mmc/host/dw_mmc-rockchip.ko
insmod kernel/drivers/mmc/host/rk_sdmmc_ops.ko

# audio codec
insmod kernel/sound/soc/codecs/snd-soc-es8311.ko

# rtc
insmod kernel/drivers/rtc/rtc-pcf8563.ko

# pwm fill light
insmod kernel/drivers/leds/leds-pwm.ko
```

## Root filesystem compilation

### Get tarball of build-busybox and compile

Get busybox tarball from path: `device/rockchip/rv1126_rv1109/prebuilt-packages/build-busybox`

``` shell
# unpackage busybox tarball
tar xjf busybox-1.27.2-patch-reboot-arg.tar.bz2

# copy rockchip's busybox defconfig
# busybox_spi_nor_defconfig used for spi nor
# busybox_emmc_defconfig used for eMMC (default)
cp busybox-1.27.2-patch/configs/busybox_defconfig busybox-1.27.2/configs/busybox_defconfig

# change directory to busybox
cd busybox-1.27.2

# config defconfig
make busybox_defconfig

# compile, Notice: the cross compile tool is in the prebuilts directory of SDK
make ARCH=arm install CROSS_COMPILE=~/RV1109-SDK/prebuilts/gcc/linux-x86/arm/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf/bin/arm-linux-gnueabihf- -j32

# unpackage base root filesystem which is prebuilt bin, e.g. target-emmc-v1.0.0.tar.bz2
tar xjf target-emmc-v1.0.0.tar.bz2

# copy busybox target bin and libs to target directory (option)
cp busybox-1.27.2/_install/* target/ -rfa

# package root filesystem with squashfs
mksquashfs target rootfs.squashfs -noappend -comp xz

# package root filesystem with ext4, e.g.
tar xjf tools.tar.bz2
./tools/mkfs-ext4/do-mkfs.ext4.sh target rootfs.ext4 64M

# the command of unpackage squashfs filesystem : unsquashfs ./rootfs.squashfs
```

**NOTICE: The library named /usr/lib/libv4l/plugins/libv4l-mplane.so MUST be placed in the rootfs.**

### Instructions to auto mount partition

target-emmc-v1.0.0.tar.bz2 support auto mount the partitions which config in the file of /etc/fstab.
Auto mount script: target/etc/init.d/S21mountall.sh

Refer to the partition of userdata

```shell
cat target/etc/fstab
# <file system> <mount pt>      <type>  <options>       <dump>  <pass>
/dev/root       /               ext2    rw,noauto       0       1
proc            /proc           proc    defaults        0       0
devpts          /dev/pts        devpts  defaults,gid=5,mode=620 0    0
tmpfs           /dev/shm        tmpfs   mode=0777       0       0
tmpfs           /tmp            tmpfs   mode=1777       0       0
tmpfs           /run            tmpfs   mode=0755,nosuid,nodev  0   0
sysfs           /sys            sysfs   defaults        0       0
debug           /sys/kernel/debug  debugfs  defaults   0       0
/dev/block/by-name/userdata     /userdata  ext2  defaults   0       2
```

## Manufacture programmer firmware image for SPI NOR

Get firmware_merger from path: `device/rockchip/rv1126_rv1109/prebuilt-packages/firmware_merger`

``` shell
# Instructions to the tool of firmware_merger
# -P : assign the config of partition and input image
# ./ : config output file Firmware.img
./firmware_merger -P setting.ini ./

# Instructions to the directory of firmware_merger
firmware_merger
├── Firmware.img                     # Generate firmware image
├── firmware_merger                  # Execute binary
├── Readme.txt                       #
├── RKDevTool_Release_v2.74          # Download program
│   ├── RKDevTool.exe                #
│   ├── RKDevTool_manual_v1.2_cn.pdf #
│   └── RKDevTool_manual_v1.2_en.pdf #
├── rockdev                          # Images for package
│   ├── idblock.bin                  # Get from SDK's u-boot directory
│   ├── rootfs.squashfs              #
│   ├── rv1126_spl_loader_***.bin    # Get from SDK's u-boot directory
│   ├── uboot.img                    # Get from SDK's u-boot directory
│   └── zboot.img                    # Get from SDK's kernel directory
├── setting.ini                      #
├── user_manual.txt                  #
└── burn-screenshot.png              #
```

## Instructions to compile the libraries of BSP

Get thses directories from root directory of SDK:

| Directory | Instructions       |
| --------- | ------------       |
| buildroot | buildroot's source |
| external  | rockchip BSP codes |
| prebuilts | cross-compile tool |

### Command to build BSP's libraries

```shell
source envsetup.sh rockchip_rv1126_rv1109_libs

make -j12
```

### BSP's files

```shell
tree buildroot/output/rockchip_rv1126_rv1109_libs/BSP/
buildroot/output/rockchip_rv1126_rv1109_libs/BSP/
├── example
│   ├── CMakeLists.txt
│   ├── common
│   │   ├── sample_common.h
│   │   └── sample_common_isp.c
│   ├── iqfiles
│   │   ├── FEC_mesh_2688_1520_imx347_4IR
│   │   │   ├── meshxf_level0.bin
│   │   │   ├── meshxf_level1.bin
│   │   │   ├── meshxf_level2.bin
│   │   │   ├── meshxf_level3.bin
│   │   │   ├── meshxf_level4.bin
│   │   │   ├── meshxi_level0.bin
│   │   │   ├── meshxi_level1.bin
│   │   │   ├── meshxi_level2.bin
│   │   │   ├── meshxi_level3.bin
│   │   │   ├── meshxi_level4.bin
│   │   │   ├── meshyf_level0.bin
│   │   │   ├── meshyf_level1.bin
│   │   │   ├── meshyf_level2.bin
│   │   │   ├── meshyf_level3.bin
│   │   │   ├── meshyf_level4.bin
│   │   │   ├── meshyi_level0.bin
│   │   │   ├── meshyi_level1.bin
│   │   │   ├── meshyi_level2.bin
│   │   │   ├── meshyi_level3.bin
│   │   │   └── meshyi_level4.bin
│   │   ├── FEC_mesh_2688_1520_os04a10_4IR
│   │   │   ├── meshxf_level0.bin
│   │   │   ├── meshxf_level1.bin
│   │   │   ├── meshxf_level2.bin
│   │   │   ├── meshxf_level3.bin
│   │   │   ├── meshxf_level4.bin
│   │   │   ├── meshxi_level0.bin
│   │   │   ├── meshxi_level1.bin
│   │   │   ├── meshxi_level2.bin
│   │   │   ├── meshxi_level3.bin
│   │   │   ├── meshxi_level4.bin
│   │   │   ├── meshyf_level0.bin
│   │   │   ├── meshyf_level1.bin
│   │   │   ├── meshyf_level2.bin
│   │   │   ├── meshyf_level3.bin
│   │   │   ├── meshyf_level4.bin
│   │   │   ├── meshyi_level0.bin
│   │   │   ├── meshyi_level1.bin
│   │   │   ├── meshyi_level2.bin
│   │   │   ├── meshyi_level3.bin
│   │   │   └── meshyi_level4.bin
│   │   ├── FEC_mesh_2688_1520_os04a10_6IR
│   │   │   ├── meshxf_level0.bin
│   │   │   ├── meshxf_level1.bin
│   │   │   ├── meshxf_level2.bin
│   │   │   ├── meshxf_level3.bin
│   │   │   ├── meshxf_level4.bin
│   │   │   ├── meshxi_level0.bin
│   │   │   ├── meshxi_level1.bin
│   │   │   ├── meshxi_level2.bin
│   │   │   ├── meshxi_level3.bin
│   │   │   ├── meshxi_level4.bin
│   │   │   ├── meshyf_level0.bin
│   │   │   ├── meshyf_level1.bin
│   │   │   ├── meshyf_level2.bin
│   │   │   ├── meshyf_level3.bin
│   │   │   ├── meshyf_level4.bin
│   │   │   ├── meshyi_level0.bin
│   │   │   ├── meshyi_level1.bin
│   │   │   ├── meshyi_level2.bin
│   │   │   ├── meshyi_level3.bin
│   │   │   └── meshyi_level4.bin
│   │   ├── FEC_mesh_3840_2160_imx415_3.6mm
│   │   │   ├── meshxf_level0.bin
│   │   │   ├── meshxf_level1.bin
│   │   │   ├── meshxf_level2.bin
│   │   │   ├── meshxf_level3.bin
│   │   │   ├── meshxf_level4.bin
│   │   │   ├── meshxi_level0.bin
│   │   │   ├── meshxi_level1.bin
│   │   │   ├── meshxi_level2.bin
│   │   │   ├── meshxi_level3.bin
│   │   │   ├── meshxi_level4.bin
│   │   │   ├── meshyf_level0.bin
│   │   │   ├── meshyf_level1.bin
│   │   │   ├── meshyf_level2.bin
│   │   │   ├── meshyf_level3.bin
│   │   │   ├── meshyf_level4.bin
│   │   │   ├── meshyi_level0.bin
│   │   │   ├── meshyi_level1.bin
│   │   │   ├── meshyi_level2.bin
│   │   │   ├── meshyi_level3.bin
│   │   │   └── meshyi_level4.bin
│   │   ├── gc2053_CMK-OT1726-PG1_29IR-2MP-F25.xml
│   │   ├── gc2053_YT-RV1109-2-V1_40IR-2MP-F20.xml
│   │   ├── gc2093_YT-RV1109-2-V1_40IR-2MP-F20.xml
│   │   ├── gc4c33_PCORW0009A_40IRC-4M.xml
│   │   ├── imx307_CMK-OT0837-PT2_YT-2929_UNV-40IRC-2M-F20.xml
│   │   ├── imx334_CMK-OT1522-FG3_CS-P1150-IRC-8M-FAU.xml
│   │   ├── imx347_JSD3425-C1_40IRC.xml
│   │   ├── imx378_A12N01B_48IRC-12M-F18.xml
│   │   ├── imx415_YT10092_IR0147-28IRC-8M-F20-hdr3.xml
│   │   ├── imx415_YT10092_IR0147-28IRC-8M-F20.xml
│   │   ├── imx415_YT10092_IR0147-36IRC-8M-F20-hdr3.xml
│   │   ├── imx415_YT10092_IR0147-36IRC-8M-F20.xml
│   │   ├── imx415_YT10092_IR0147-60IRC-8M-F20-hdr3.xml
│   │   ├── imx415_YT10092_IR0147-60IRC-8M-F20.xml
│   │   ├── LDCH_mesh_2688_1520_imx347_4IR
│   │   │   ├── mesh_level0.bin
│   │   │   ├── mesh_level1.bin
│   │   │   ├── mesh_level2.bin
│   │   │   ├── mesh_level3.bin
│   │   │   └── mesh_level4.bin
│   │   ├── LDCH_mesh_2688_1520_os04a10_4IR
│   │   │   ├── mesh_level0.bin
│   │   │   ├── mesh_level1.bin
│   │   │   ├── mesh_level2.bin
│   │   │   ├── mesh_level3.bin
│   │   │   └── mesh_level4.bin
│   │   ├── LDCH_mesh_2688_1520_os04a10_6IR
│   │   │   ├── mesh_level0.bin
│   │   │   ├── mesh_level1.bin
│   │   │   ├── mesh_level2.bin
│   │   │   ├── mesh_level3.bin
│   │   │   └── mesh_level4.bin
│   │   ├── LDCH_mesh_3840_2160_imx415_3.6mm
│   │   │   ├── mesh_level0.bin
│   │   │   ├── mesh_level1.bin
│   │   │   ├── mesh_level2.bin
│   │   │   ├── mesh_level3.bin
│   │   │   └── mesh_level4.bin
│   │   ├── os04a10_CMK-OT1607-FV1_M12-40IRC-4MP-F16.xml
│   │   ├── os04a10_CMK-OT1607-FV1_M12-60IRC-4MP-F16.xml
│   │   ├── ov02k10_O2F0068_2D2A-40IRC-2M-F18.xml
│   │   ├── ov02k10_ORCF-0249-00-PD-V1_xuye.xml
│   │   ├── ov2718_YT-RV1109-3-V1_M43-4IR-2MP-F2.xml
│   │   ├── ov4689_JSD3425-C1_JSD3425-C1-36IRC-4M-F20.xml
│   │   ├── s5kgm1sp_PCORW0009A_4mm-4M.xml
│   │   ├── s5kgm1sp_S5KGM1ST03_40IR-12M-F20.xml
│   │   └── sc200ai_CMK-OT1607-FV1_M12-40IRC-4MP-F16_tmp2_addnr3.xml
│   ├── Makefile
│   ├── rkmedia_audio_test.c
│   ├── rkmedia_isp_test.c
│   ├── rkmedia_main_stream_with_jpeg_test.c
│   ├── rkmedia_venc_avbr_test.c
│   ├── rkmedia_venc_cover_test.c
│   ├── rkmedia_venc_jpeg_test.c
│   ├── rkmedia_venc_mjpeg_test.c
│   ├── rkmedia_venc_offline_test.c
│   ├── rkmedia_venc_osd_test.c
│   ├── rkmedia_venc_roi_osd_test.c
│   ├── rkmedia_venc_smartp_test.c
│   ├── rkmedia_vi_double_cameras_test.c
│   ├── rkmedia_vi_get_frame_test.c
│   ├── rkmedia_vi_md_test.c
│   ├── rkmedia_vi_multi_bind_test.c
│   ├── rkmedia_vi_od_test.c
│   ├── rkmedia_vi_rga_test.c
│   ├── rkmedia_vi_venc_change_resolution_test.c
│   ├── rkmedia_vi_venc_test.c
│   ├── rkmedia_vi_vo_test.c
│   ├── rkmedia_vi_work_mode_test.c
│   ├── uintTest
│   │   ├── buffer
│   │   │   ├── buffer_pool_test.cc
│   │   │   └── CMakeLists.txt
│   │   ├── CMakeLists.txt
│   │   ├── ffmpeg
│   │   │   ├── CMakeLists.txt
│   │   │   └── ffmpeg_enc_mux_test.cc
│   │   ├── flow
│   │   │   ├── audio_decoder_flow_test.cc
│   │   │   ├── audio_encoder_flow_test.cc
│   │   │   ├── audio_loop_test.cc
│   │   │   ├── audio_process_test.cc
│   │   │   ├── CMakeLists.txt
│   │   │   ├── flow_event_test.cc
│   │   │   ├── flow_stress_test.cc
│   │   │   ├── FlowTest.cc
│   │   │   ├── link_flow_test.cc
│   │   │   ├── move_detection_flow_test.cc
│   │   │   ├── muxer_flow_test.cc
│   │   │   ├── occlusion_detection_flow_test.cc
│   │   │   ├── rga_filter_flow_test.cc
│   │   │   ├── through_guard_jpeg_test.cc
│   │   │   ├── video_encoder_bps_test.cc
│   │   │   ├── video_encoder_flow_test.cc
│   │   │   ├── video_encoder_osd_test.cc
│   │   │   ├── video_encoder_roi_test.cc
│   │   │   └── video_smart_encoder_test.cc
│   │   ├── live555
│   │   │   ├── CMakeLists.txt
│   │   │   ├── h264_frames
│   │   │   │   ├── 0.h264_frame
│   │   │   │   ├── 10.h264_frame
│   │   │   │   ├── 1.h264_frame
│   │   │   │   ├── 2.h264_frame
│   │   │   │   ├── 3.h264_frame
│   │   │   │   ├── 4.h264_frame
│   │   │   │   ├── 5.h264_frame
│   │   │   │   ├── 6.h264_frame
│   │   │   │   ├── 7.h264_frame
│   │   │   │   ├── 8.h264_frame
│   │   │   │   └── 9.h264_frame
│   │   │   ├── rtsp_multi_server_test.cc
│   │   │   └── rtsp_server_test.cc
│   │   ├── ogg
│   │   │   ├── CMakeLists.txt
│   │   │   ├── ogg_decode_test.cc
│   │   │   └── ogg_encode_test.cc
│   │   ├── rkmpp
│   │   │   ├── CMakeLists.txt
│   │   │   ├── mpp_dec_test_320_240.jpg
│   │   │   ├── mpp_dec_test.cc
│   │   │   ├── mpp_dec_test.h264
│   │   │   ├── mpp_dec_test.hevc
│   │   │   ├── mpp_enc_test_320_240.nv12
│   │   │   └── mpp_enc_test.cc
│   │   ├── stream
│   │   │   ├── camera_capture_test.cc
│   │   │   ├── CMakeLists.txt
│   │   │   └── drm_display_test.cc
│   │   └── uvc
│   │       ├── CMakeLists.txt
│   │       └── uvc_flow_test.cc
│   └── vqefiles
│       ├── 16k
│       │   └── RKAP_AecPara.bin
│       └── 8k
│           └── RKAP_AecPara.bin
├── include
│   ├── rga
│   │   ├── drmrga.h
│   │   ├── RgaApi.h
│   │   ├── rga.h
│   │   ├── RockchipRga.h
│   │   └── RockchipRgaMacro.h
│   ├── rkaiq
│   │   ├── algos
│   │   │   ├── a3dlut
│   │   │   │   ├── rk_aiq_types_a3dlut_algo.h
│   │   │   │   ├── rk_aiq_types_a3dlut_algo_int.h
│   │   │   │   ├── rk_aiq_types_a3dlut_hw.h
│   │   │   │   └── rk_aiq_uapi_a3dlut_int.h
│   │   │   ├── ablc
│   │   │   │   ├── rk_aiq_types_ablc_algo.h
│   │   │   │   ├── rk_aiq_types_ablc_algo_int.h
│   │   │   │   ├── rk_aiq_types_ablc_hw.h
│   │   │   │   └── rk_aiq_uapi_ablc_int.h
│   │   │   ├── accm
│   │   │   │   ├── rk_aiq_types_accm_algo.h
│   │   │   │   ├── rk_aiq_types_accm_algo_int.h
│   │   │   │   ├── rk_aiq_types_accm_hw.h
│   │   │   │   └── rk_aiq_uapi_accm_int.h
│   │   │   ├── acp
│   │   │   │   ├── rk_aiq_types_acp_algo.h
│   │   │   │   ├── rk_aiq_types_acp_algo_int.h
│   │   │   │   └── rk_aiq_uapi_acp_int.h
│   │   │   ├── adebayer
│   │   │   │   ├── rk_aiq_types_algo_adebayer.h
│   │   │   │   ├── rk_aiq_types_algo_adebayer_int.h
│   │   │   │   └── rk_aiq_uapi_adebayer_int.h
│   │   │   ├── adehaze
│   │   │   │   ├── rk_aiq_types_adehaze_algo.h
│   │   │   │   ├── rk_aiq_types_adehaze_algo_int.h
│   │   │   │   ├── rk_aiq_types_adehaze_hw.h
│   │   │   │   └── rk_aiq_uapi_adehaze_int.h
│   │   │   ├── adpcc
│   │   │   │   ├── rk_aiq_types_adpcc_algo.h
│   │   │   │   ├── rk_aiq_types_adpcc_algo_int.h
│   │   │   │   ├── rk_aiq_types_adpcc_hw.h
│   │   │   │   └── rk_aiq_uapi_adpcc_int.h
│   │   │   ├── ae
│   │   │   │   ├── rk_aiq_types_ae_algo.h
│   │   │   │   ├── rk_aiq_types_ae_algo_int.h
│   │   │   │   ├── rk_aiq_types_ae_hw.h
│   │   │   │   ├── rk_aiq_uapi_ae_int.h
│   │   │   │   └── rk_aiq_uapi_ae_int_types.h
│   │   │   ├── af
│   │   │   │   ├── rk_aiq_af_hw_v200.h
│   │   │   │   ├── rk_aiq_types_af_algo.h
│   │   │   │   ├── rk_aiq_types_af_algo_int.h
│   │   │   │   └── rk_aiq_uapi_af_int.h
│   │   │   ├── afec
│   │   │   │   ├── fec_algo.h
│   │   │   │   ├── rk_aiq_types_afec_algo.h
│   │   │   │   ├── rk_aiq_types_afec_algo_int.h
│   │   │   │   └── rk_aiq_uapi_afec_int.h
│   │   │   ├── agamma
│   │   │   │   ├── rk_aiq_types_agamma_algo.h
│   │   │   │   ├── rk_aiq_types_agamma_algo_int.h
│   │   │   │   ├── rk_aiq_types_agamma_hw.h
│   │   │   │   └── rk_aiq_uapi_agamma_int.h
│   │   │   ├── agic
│   │   │   │   ├── rk_aiq_types_algo_agic.h
│   │   │   │   ├── rk_aiq_types_algo_agic_int.h
│   │   │   │   └── rk_aiq_uapi_agic_int.h
│   │   │   ├── ahdr
│   │   │   │   ├── rk_aiq_types_ahdr_algo.h
│   │   │   │   ├── rk_aiq_types_ahdr_algo_int.h
│   │   │   │   ├── rk_aiq_types_ahdr_stat_v200.h
│   │   │   │   └── rk_aiq_uapi_ahdr_int.h
│   │   │   ├── aie
│   │   │   │   ├── rk_aiq_types_aie_algo.h
│   │   │   │   └── rk_aiq_types_aie_algo_int.h
│   │   │   ├── aldch
│   │   │   │   ├── rk_aiq_types_aldch_algo.h
│   │   │   │   ├── rk_aiq_types_aldch_algo_int.h
│   │   │   │   └── rk_aiq_uapi_aldch_int.h
│   │   │   ├── alsc
│   │   │   │   ├── rk_aiq_types_alsc_algo.h
│   │   │   │   ├── rk_aiq_types_alsc_algo_int.h
│   │   │   │   ├── rk_aiq_types_alsc_hw.h
│   │   │   │   └── rk_aiq_uapi_alsc_int.h
│   │   │   ├── anr
│   │   │   │   ├── rk_aiq_types_anr_algo.h
│   │   │   │   ├── rk_aiq_types_anr_algo_int.h
│   │   │   │   ├── rk_aiq_types_anr_hw.h
│   │   │   │   └── rk_aiq_uapi_anr_int.h
│   │   │   ├── aorb
│   │   │   │   ├── rk_aiq_orb_hw.h
│   │   │   │   └── rk_aiq_types_orb_algo.h
│   │   │   ├── asd
│   │   │   │   ├── rk_aiq_types_asd_algo.h
│   │   │   │   └── rk_aiq_uapi_asd_int.h
│   │   │   ├── asharp
│   │   │   │   ├── rk_aiq_types_asharp_algo.h
│   │   │   │   ├── rk_aiq_types_asharp_algo_int.h
│   │   │   │   ├── rk_aiq_types_asharp_hw.h
│   │   │   │   └── rk_aiq_uapi_asharp_int.h
│   │   │   ├── awb
│   │   │   │   ├── rk_aiq_types_awb_algo.h
│   │   │   │   ├── rk_aiq_types_awb_algo_int.h
│   │   │   │   ├── rk_aiq_types_awb_stat_v200.h
│   │   │   │   ├── rk_aiq_types_awb_stat_v201.h
│   │   │   │   ├── rk_aiq_types_awb_stat_v2xx.h
│   │   │   │   └── rk_aiq_uapi_awb_int.h
│   │   │   └── rk_aiq_algo_des.h
│   │   ├── common
│   │   │   ├── gen_mesh
│   │   │   │   ├── genMesh.h
│   │   │   │   ├── genMesh_static_32bit
│   │   │   │   └── genMesh_static_64bit
│   │   │   ├── linux
│   │   │   │   ├── compiler.h
│   │   │   │   ├── rk-camera-module.h
│   │   │   │   ├── rk-led-flash.h
│   │   │   │   ├── v4l2-controls.h
│   │   │   │   └── videodev2.h
│   │   │   ├── mediactl
│   │   │   │   ├── mediactl.h
│   │   │   │   ├── mediactl-priv.h
│   │   │   │   ├── tools.h
│   │   │   │   └── v4l2subdev.h
│   │   │   ├── opencv2
│   │   │   │   ├── calib3d
│   │   │   │   │   └── calib3d_c.h
│   │   │   │   ├── core
│   │   │   │   │   ├── core_c.h
│   │   │   │   │   ├── cuda
│   │   │   │   │   │   └── detail
│   │   │   │   │   ├── cv_cpu_dispatch.h
│   │   │   │   │   ├── cv_cpu_helper.h
│   │   │   │   │   ├── cvdef.h
│   │   │   │   │   ├── detail
│   │   │   │   │   ├── hal
│   │   │   │   │   │   ├── interface.h
│   │   │   │   │   │   └── msa_macros.h
│   │   │   │   │   ├── opencl
│   │   │   │   │   │   └── runtime
│   │   │   │   │   │       └── autogenerated
│   │   │   │   │   ├── types_c.h
│   │   │   │   │   └── utils
│   │   │   │   ├── cvconfig.h
│   │   │   │   ├── dnn
│   │   │   │   │   └── utils
│   │   │   │   ├── features2d
│   │   │   │   │   └── hal
│   │   │   │   │       └── interface.h
│   │   │   │   ├── flann
│   │   │   │   │   ├── all_indices.h
│   │   │   │   │   ├── allocator.h
│   │   │   │   │   ├── any.h
│   │   │   │   │   ├── autotuned_index.h
│   │   │   │   │   ├── composite_index.h
│   │   │   │   │   ├── config.h
│   │   │   │   │   ├── defines.h
│   │   │   │   │   ├── dist.h
│   │   │   │   │   ├── dummy.h
│   │   │   │   │   ├── dynamic_bitset.h
│   │   │   │   │   ├── general.h
│   │   │   │   │   ├── ground_truth.h
│   │   │   │   │   ├── hdf5.h
│   │   │   │   │   ├── heap.h
│   │   │   │   │   ├── hierarchical_clustering_index.h
│   │   │   │   │   ├── index_testing.h
│   │   │   │   │   ├── kdtree_index.h
│   │   │   │   │   ├── kdtree_single_index.h
│   │   │   │   │   ├── kmeans_index.h
│   │   │   │   │   ├── linear_index.h
│   │   │   │   │   ├── logger.h
│   │   │   │   │   ├── lsh_index.h
│   │   │   │   │   ├── lsh_table.h
│   │   │   │   │   ├── matrix.h
│   │   │   │   │   ├── nn_index.h
│   │   │   │   │   ├── object_factory.h
│   │   │   │   │   ├── params.h
│   │   │   │   │   ├── random.h
│   │   │   │   │   ├── result_set.h
│   │   │   │   │   ├── sampling.h
│   │   │   │   │   ├── saving.h
│   │   │   │   │   ├── simplex_downhill.h
│   │   │   │   │   └── timer.h
│   │   │   │   ├── gapi
│   │   │   │   │   ├── cpu
│   │   │   │   │   ├── fluid
│   │   │   │   │   ├── gpu
│   │   │   │   │   ├── infer
│   │   │   │   │   ├── ocl
│   │   │   │   │   ├── own
│   │   │   │   │   ├── plaidml
│   │   │   │   │   ├── render
│   │   │   │   │   ├── streaming
│   │   │   │   │   └── util
│   │   │   │   ├── highgui
│   │   │   │   │   └── highgui_c.h
│   │   │   │   ├── imgcodecs
│   │   │   │   │   ├── imgcodecs_c.h
│   │   │   │   │   ├── ios.h
│   │   │   │   │   └── legacy
│   │   │   │   │       └── constants_c.h
│   │   │   │   ├── imgproc
│   │   │   │   │   ├── detail
│   │   │   │   │   ├── hal
│   │   │   │   │   │   └── interface.h
│   │   │   │   │   ├── imgproc_c.h
│   │   │   │   │   └── types_c.h
│   │   │   │   ├── lib
│   │   │   │   │   └── 3rdparty
│   │   │   │   ├── ml
│   │   │   │   ├── objdetect
│   │   │   │   ├── photo
│   │   │   │   │   └── legacy
│   │   │   │   │       └── constants_c.h
│   │   │   │   ├── stitching
│   │   │   │   │   └── detail
│   │   │   │   ├── video
│   │   │   │   │   └── legacy
│   │   │   │   │       └── constants_c.h
│   │   │   │   └── videoio
│   │   │   │       ├── cap_ios.h
│   │   │   │       ├── legacy
│   │   │   │       │   └── constants_c.h
│   │   │   │       └── videoio_c.h
│   │   │   ├── rk_aiq_comm.h
│   │   │   ├── rk_aiq.h
│   │   │   ├── rk_aiq_pool.h
│   │   │   ├── rk_aiq_types.h
│   │   │   └── shared_item_pool.h
│   │   ├── iq_parser
│   │   │   └── RkAiqCalibDbTypes.h
│   │   ├── rkisp_api.h
│   │   ├── uAPI
│   │   │   ├── rk_aiq_user_api_a3dlut.h
│   │   │   ├── rk_aiq_user_api_ablc.h
│   │   │   ├── rk_aiq_user_api_accm.h
│   │   │   ├── rk_aiq_user_api_acp.h
│   │   │   ├── rk_aiq_user_api_adebayer.h
│   │   │   ├── rk_aiq_user_api_adehaze.h
│   │   │   ├── rk_aiq_user_api_adpcc.h
│   │   │   ├── rk_aiq_user_api_ae.h
│   │   │   ├── rk_aiq_user_api_afec.h
│   │   │   ├── rk_aiq_user_api_af.h
│   │   │   ├── rk_aiq_user_api_agamma.h
│   │   │   ├── rk_aiq_user_api_agic.h
│   │   │   ├── rk_aiq_user_api_ahdr.h
│   │   │   ├── rk_aiq_user_api_aldch.h
│   │   │   ├── rk_aiq_user_api_alsc.h
│   │   │   ├── rk_aiq_user_api_anr.h
│   │   │   ├── rk_aiq_user_api_asd.h
│   │   │   ├── rk_aiq_user_api_asharp.h
│   │   │   ├── rk_aiq_user_api_awb.h
│   │   │   ├── rk_aiq_user_api_debug.h
│   │   │   ├── rk_aiq_user_api_imgproc.h
│   │   │   └── rk_aiq_user_api_sysctl.h
│   │   └── xcore
│   │       └── base
│   │           ├── xcam_common.h
│   │           └── xcam_defs.h
│   └── rkmedia
│       ├── rkmedia_adec.h
│       ├── rkmedia_aenc.h
│       ├── rkmedia_ai.h
│       ├── rkmedia_ao.h
│       ├── rkmedia_api.h
│       ├── rkmedia_buffer.h
│       ├── rkmedia_common.h
│       ├── rkmedia_event.h
│       ├── rkmedia_move_detection.h
│       ├── rkmedia_occlusion_detection.h
│       ├── rkmedia_rga.h
│       ├── rkmedia_venc.h
│       ├── rkmedia_vi.h
│       └── rkmedia_vo.h
└── lib
    ├── libasound.so -> libasound.so.2.0.0
    ├── libasound.so.2 -> libasound.so.2.0.0
    ├── libasound.so.2.0.0
    ├── libavcodec.so -> libavcodec.so.58.35.100
    ├── libavcodec.so.58 -> libavcodec.so.58.35.100
    ├── libavcodec.so.58.35.100
    ├── libavformat.so -> libavformat.so.58.20.100
    ├── libavformat.so.58 -> libavformat.so.58.20.100
    ├── libavformat.so.58.20.100
    ├── libavutil.so -> libavutil.so.56.22.100
    ├── libavutil.so.56 -> libavutil.so.56.22.100
    ├── libavutil.so.56.22.100
    ├── libdrm.so -> libdrm.so.2.4.0
    ├── libdrm.so.2 -> libdrm.so.2.4.0
    ├── libdrm.so.2.4.0
    ├── libeasymedia.so -> libeasymedia.so.1
    ├── libeasymedia.so.1 -> libeasymedia.so.1.0.1
    ├── libeasymedia.so.1.0.1
    ├── libmd_share.so
    ├── libod_share.so
    ├── librga.so -> librga.so.2
    ├── librga.so.2 -> librga.so.2.0.0
    ├── librga.so.2.0.0
    ├── librkaiq.so
    ├── libRKAP_AEC.so
    ├── libRKAP_ANR.so
    ├── libRKAP_Common.so
    ├── librockchip_mpp.so -> librockchip_mpp.so.1
    ├── librockchip_mpp.so.0
    ├── librockchip_mpp.so.1 -> librockchip_mpp.so.0
    ├── libswresample.so -> libswresample.so.3.3.100
    ├── libswresample.so.3 -> libswresample.so.3.3.100
    ├── libswresample.so.3.3.100
    ├── libv4l2.so -> libv4l2.so.0.0.0
    ├── libv4l2.so.0 -> libv4l2.so.0.0.0
    ├── libv4l2.so.0.0.0
    ├── libv4lconvert.so -> libv4lconvert.so.0.0.0
    ├── libv4lconvert.so.0 -> libv4lconvert.so.0.0.0
    └── libv4lconvert.so.0.0.0
```

## Debug info

### CPU debug info

#### CPU frequency debug

##### Print CPU frequency

```shell
# print current cpu frequency
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
1008000

# print cpu available frequencies
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
408000 600000 816000 1008000 1200000 1296000
```

##### Set CPU fixed frequency

```shell
# set CPU 600MHz fixed frequency
echo userspace > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 600000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
```

#### Print CPU thermal

`cat /sys/class/thermal/thermal_zone0/temp`

#### Disable CPU thermal control

```shell
# diable thermal control
echo user_space > /sys/class/thermal/thermal_zone0/policy
# disable frequency limit
echo 0 > /sys/class/thermal/thermal_zone0/cdev0/cur_state
echo 0 > /sys/class/thermal/thermal_zone0/cdev1/cur_state
```

### Encode debug info

#### Print encode frame rate

```shell
# enable print fps log
echo 0x100 > /sys/module/rk_vcodec/parameters/mpp_dev_debug

# disable print fps log
echo 0 > /sys/module/rk_vcodec/parameters/mpp_dev_debug
```

#### Print encode summary info

` cat /proc/mpp_service/session_summary `

### Print ISPP info

`cat /proc/rkispp0`

```shell
cat /proc/rkispp0
rkispp0    Version:v00.01.05
Input      rkisp0 Format:FBC420 Size:3840x2160 (frame:15441 rate:41ms delay:20ms)
Output     rkispp_m_bypass Format:FBC0 Size:3840x2160 (frame:15440 rate:41ms delay:45ms)
Output     rkispp_scale0 Format:NV12 Size:1280x720 (frame:15440 rate:41ms delay:45ms)
Output     rkispp_scale1 Format:NV12 Size:720x480 (frame:15440 rate:41ms delay:45ms)
Output     rkispp_scale2 Format:NV12 Size:1280x720 (frame:15440 rate:41ms delay:45ms)
TNR        ON(0xd00000d) (mode: 2to1) (global gain: disable) (frame:15441 time:12ms) CNT:0x0 STATE:0x1e000000
NR         ON(0x47) (external gain: enable) (frame:15441 time:12ms) 0x5f0:0x0 0x5f4:0x0
SHARP      ON(0x1b) (YNR input filter: ON) (local ratio: ON) 0x630:0x0
FEC        OFF(0x2) (frame:0 time:0ms) 0xc90:0x0
ORB        OFF(0x0)
Interrupt  Cnt:46278 ErrCnt:0
clk_ispp   500000000
aclk_ispp  500000000
hclk_ispp  250000000
```

### Print ISP info

`cat /proc/rkisp0`

```shell
cat /proc/rkisp0
rkisp0     Version:v00.01.05
Input      rkcif_mipi_lvds Format:SGBRG10_1X10 Size:3840x2160@30fps Offset(0,0) | RDBK_X1(frame:15584 rate:40ms)
Output     rkispp0 Format:FBC420 Size:3840x2160 (frame:15583 rate:39ms)
Interrupt  Cnt:62011 ErrCnt:0
clk_isp    594000000
aclk_isp   500000000
hclk_isp   250000000
DPCC0      ON(0x40000005)
DPCC1      ON(0x40000005)
DPCC2      ON(0x40000005)
BLS        ON(0x40000001)
SDG        OFF(0x80446197)
LSC        ON(0x1)
AWBGAIN    ON(0x80446197) (gain: 0x010d010d, 0x02260227)
DEBAYER    ON(0xf000111)
CCM        ON(0xc0000001)
GAMMA_OUT  ON(0xc0000001)
CPROC      ON(0xf)
IE         OFF(0x0) (effect: BLACKWHITE)
WDR        OFF(0x30cf0)
HDRTMO     ON(0xc8505a25)
HDRMGE     OFF(0x0)
RAWNR      ON(0xc0100001)
GIC        OFF(0x0)
DHAZ       ON(0xc0001009)
3DLUT      OFF(0x2)
GAIN       ON(0xc0010010)
LDCH       OFF(0x0)
CSM        FULL(0x80446197)
SIAF       OFF(0x0)
SIAWB      OFF(0x0)
YUVAE      ON(0x400100f3)
SIHST      ON(0x38000107)
RAWAF      ON(0x7)
RAWAWB     ON(0x4037e887)
RAWAE0     ON(0x40000003)
RAWAE1     ON(0x400000f5)
RAWAE2     ON(0x400000f5)
RAWAE3     ON(0x400000f5)
RAWHIST0   ON(0x40000501)
RAWHIST1   ON(0x60000501)
RAWHIST2   ON(0x60000501)
RAWHIST3   ON(0x60000501)
```
