# RV1126/RV1109 Linux SDK Quick Start

ID: RK-JC-YF-360

Release Version: V1.2.1

Release Date: 2020-06-29

Security Level: □Top-Secret   □Secret   □Internal   ■Public

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

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

The document presents the basic usage of  Rockchip RV1126/RV1109 Linux SDK, aiming to help engineers get started with RV1126/RV1109 Linux SDK faster.
After the SDK is downloaded, you can check docs/RV1126_RV1109/RV1126_RV1109_Release_Note.txt to confirm the current SDK version.

**Product Version**

| **Chipset** | **Kernel Version** |
| ------------ | ------------ |
| RV1126/RV1109   | Linux 4.19 |

**Intended Audience**

This document (this guide) is mainly intended for:

- Technical support engineers
- Software development engineers

**Revision History**

| **Version** | **Author** | **Date** | Revision History |
| ---------- | --------| :--------- | ------------ |
| V0.0.1 | CWW | 2020-04-28 | Initial version  |
| V0.0.2 | CWW | 2020-05-09 | Update the interface of RK IPCamera Tool |
| V0.0.3 | CWW | 2020-05-20 | Add libssl-dev and expect for building environment |
| V1.0.0 | CWW | 2020-05-25 | 1. update chapter 3 & 4.4 & 4.5<br>2. add fast boot compile guide<br>3. add chapter 5.4 |
| V1.1.0 | CWW | 2020-06-08 | 1. update company name<br>2. update document style<br>3. update chapter 2|
| V1.1.1 | CWW | 2020-06-16 | fix company name |
| V1.2.0 | HJC | 2020-06-22 | Add smart usb camera product section |
| V1.2.1 | CWW | 2020-06-29 | 1. update chapter 4.4<br>2. Add install fakeroot for building environment |

---

**Contents**

[TOC]

---

## 1   Set up an Development Environment

**Ubuntu 16.04 system:**
Please install software packages with below commands to set up a building environment:

```shell
sudo apt-get install repo git-core gitk git-gui gcc-arm-linux-gnueabihf u-boot-tools device-tree-compiler gcc-aarch64-linux-gnu mtools parted libudev-dev libusb-1.0-0-dev python-linaro-image-tools linaro-image-tools autoconf autotools-dev libsigsegv2 m4 intltool libdrm-dev curl sed make binutils build-essential gcc g++ bash patch gzip gawk bzip2 perl tar cpio python unzip rsync file bc wget libncurses5 libqt4-dev libglib2.0-dev libgtk2.0-dev libglade2-dev cvs git mercurial rsync openssh-client subversion asciidoc w3m dblatex graphviz python-matplotlib libc6:i386 libssl-dev expect fakeroot
```

**Ubuntu 17.04 or later version system:**

In addition to the above software packages, the following dependencies is needed:

```shell
sudo apt-get install lib32gcc-7-dev  g++-7  libstdc++-7-dev
```

## 2 SDK Configuration Framework Introduction

### 2.1 SDK Project Directory Introduction

There are buildroot, app, kernel, u-boot, device, docs, external and other directories in the project directory. Each directory or its sub-directories will correspond to a git project, and the commit should be done in the respective directory.

- buildroot: customized root file system.
- app: store applications.
- external: related libraries, including audio and video.
- kernel: kernel code.
- device/rockchip: stores some scripts and prepared files for building and packaging firmware of each chip.
- docs: stores development guides, platform support lists, tool usage, Linux development guides, and so on.
- prebuilts: stores cross-compilation toolchain.
- rkbin: stores firmware and tools.
- rockdev: stores building output firmware.
- tools: stores some commonly used tools.
- u-boot: U-Boot code.

### 2.2 SDK Configuration Framework

![](resources/SDK_Configuration_Framework.jpg)

## 3 SDK Building Introduction

### 3.1 To Select Board Configure

SDK Download Address:

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/linux/rk/platform/manifests -b linux -m rv1126_rv1109_linux_release.xml
```

| Board Configuration                                 | Comment                |
| ----------------------------------------------- | ---------------------- |
| device/rockchip/rv1126_rv1109/BoardConfig.mk    | General Version        |
| device/rockchip/rv1126_rv1109/BoardConfig-tb.mk | Support Fast Boot      |

Command of select board configure:

```shell
### select general version board configuration
./build.sh device/rockchip/rv1126_rv1109/BoardConfig.mk

### select fast boot board configuration
./build.sh device/rockchip/rv1126_rv1109/BoardConfig-tb.mk
```

### 3.2 To View Building Commands

Execute the following command in the root directory: `./build.sh -h|help`

```shell
./build.sh help
Usage: build.sh [OPTIONS]
Available options:
BoardConfig*.mk    -switch to specified board config
uboot              -build uboot
spl                -build spl
kernel             -build kernel
modules            -build kernel modules
toolchain          -build toolchain
rootfs             -build default rootfs, currently build buildroot as default
buildroot          -build buildroot rootfs
ramboot            -build ramboot image
multi-npu_boot     -build boot image for multi-npu board
yocto              -build yocto rootfs
debian             -build debian9 stretch rootfs
distro             -build debian10 buster rootfs
pcba               -build pcba
recovery           -build recovery
all                -build uboot, kernel, rootfs, recovery image
cleanall           -clean uboot, kernel, rootfs, recovery
firmware           -pack all the image we need to boot up system
updateimg          -pack update image
otapackage         -pack ab update otapackage image
save               -save images, patches, commands used to debug
allsave            -build all & firmware & updateimg & save

Default option is 'allsave'.
```

To view detailed building commands for some modules, for example: `./build.sh -h kernel`

```shell
./build.sh -h kernel
###Current SDK Default [ kernel ] Build Command###
cd kernel
make ARCH=arm rv1126_defconfig
make ARCH=arm rv1126-evb-ddr3-v10.img -j12
```

[^Note]: The detailed compilation commands are based on the actual SDK version, mainly because the configuration may be different. build.sh compilation command is fixed.

### 3.3 U-Boot Building

```shell
### U-Boot building command
./build.sh uboot

### to view detailed U-Boot build command
./build.sh -h uboot
```

### 3.4 Kernel Building

```shell
### Kernel building command
./build.sh kernel

### to view detailed Kernel build command
./build.sh -h kernel
```

### 3.5 Recovery Building

```shell
### Recovery building command
./build.sh recovery

### to view detailed Recovery build command
./build.sh -h recovery
```

### 3.6 Rootfs Building

```shell
### Rootfs building command
./build.sh rootfs

###  to view detailed Rootfs build command
./build.sh -h rootfs
```

### 3.7 Firmware Package

Firmware packaging command: `./mkfirmware.sh`

Firmware directory: rockdev

### 3.8 Full Automatic Building

Enter the project root directory and execute the following command to automatically complete all buildings:

```shell
./build.sh all
```

## 4 Upgrade Introduction

### 4.1 TOP Surface of the EVB

![](resources/EVB-front-view.jpg)

### 4.2 Bottom Surface of the EVB

![](resources/EVB-back-view.jpg)

### 4.3 EVB Function Table

![](resources/EVB-function-interfaceEN.png)

### 4.4 Windows Upgrade Introduction

The SDK provides a windows flash tool (this tool should be V2.71 or later version) which is located in project root directory:

```shell
tools/
├── windows/RKDevTool
```

As shown below, after building and generating the firmware, device needs to enter MASKROM or BootROM  mode for flashing. After connecting USB cable, long press the "Update" button and press "RESET" button at the same time and then release, device will enter MASKROM mode. Then you should load the paths of the corresponding images and click "Run" to start update. You can also press the "recovery" button and press “RESET" button "RESET" then release to enter loader mode to update. Partition offset and update files of MASKROM Mode are shown as follows (Note: you have to run the tool as an administrator in Windows PC):

![](resources/window-flash-firmwareEN.png)

Note:

1. In addition to MiniLoader All.bin and parameter.txt, the actual partition to be burned is based on rockdev / parameter.txt configuration.

2. before upgrade, please install the latest USB driver, which is in the below directory:

```shell
<SDK>/tools/windows/DriverAssitant_v4.91.zip
```

### 4.5 Linux Upgrade Introduction

The Linux upgrade tool (Linux_Upgrade_Tool should be v1.49 or later versions) is located in "tools/linux" directory. Please make sure your board is connected to MASKROM/loader rockusb, if the generated firmware is in rockdev directory, upgrade commands are as below:

```shell
### In addition to MiniLoader All.bin and parameter.txt, the actual partition to be burned is based on rockdev / parameter.txt configuration.
sudo ./upgrade_tool ul rockdev/MiniLoaderAll.bin
sudo ./upgrade_tool di -p rockdev/parameter.txt
sudo ./upgrade_tool di -u rockdev/uboot.img
sudo ./upgrade_tool di -misc rockdev/misc.img
sudo ./upgrade_tool di -b rockdev/boot.img
sudo ./upgrade_tool di -recovery rockdev/recovery.img
sudo ./upgrade_tool di -oem rockdev/oem.img
sudo ./upgrade_tool di -rootfs rocdev/rootfs.img
sudo ./upgrade_tool di -userdata rockdev/userdata.img
sudo ./upgrade_tool rd
```

Or upgrade the whole update.img firmware after packaging:

```shell
sudo ./upgrade_tool uf rockdev/update.img
```

Or in root directory, run the following command on your device to upgrade in MASKROM state:

```shell
./rkflash.sh
```

## 5 EVB Function Introduction

The EVB supports the following functions:

- Support 3 RTSP and 1 RTMP network stream
- Support 1280x720 local screen display
- Support to save the main stream to the device
- Support access device from web
- Support face recognition

### 5.1 How to Access 3 RTSP and 1 RTMP Network Stream

Connect a network cable to the network port of the EVB, power on and start. It will obtain the IP address automatically by default.

#### 5.1.1 Get Device IP Address by Serial Port or ADB of the EVB

```shell
ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:E0:F9:16:7E:E9
          inet addr:172.16.21.218  Bcast:172.16.21.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:199225 errors:0 dropped:2231 overruns:0 frame:0
          TX packets:372371 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:20874811 (19.9 MiB)  TX bytes:522220899 (498.0 MiB)
          Interrupt:56
```

Connect to the EVB through the serial port, you have to configure as follows:

```shell
Baud rate: 1500000
Data bits: 8
Stop bit: 1
Parity: none
Flow control: none
```

#### 5.1.2 Get Device IP Address by RK IPCamera Tool

Install the tool in the SDK directory `tools/windows/RK_IPCamera_Tool-V1.1.zip`. Open the tool and connect the EVB board to the computer through the network port. In the local area network, check the RK IPCamera Tool device list to obtain the device IP address.

![](resources/RK_IPCamera_ToolCN.png)

**Note:**

- Step 1: click "开启搜索" to search devices
- Step 2: select a device
- Step 3: cancel "自动获取" and change to static IP
- Step 4: set a static IP
- Step 5: set the IP to device
- Step 6: open to preview

#### 5.1.3 Access Network Stream

Use a player that supports RTSP or RTMP to access, for example (VLC player).

RTSP access address:

- rtsp://**IP address of the device**/live/mainstream

- rtsp://**IP address of the device**/live/substream

- rtsp://**IP address of the device**/live/thirdstream

RTMP access address:

- rtmp://**IP address of the device**:1935/live/substream

### 5.2 How to Access Device Information via Web

Open a web browser (Chrome browser is recommended ) to access the address:

```shell
http://IP address of the device
```

For detailed operation instructions on the web, please refer to the documents under the SDK docs directory.

### 5.3 How to Test Face Recognition Function

Use a player to access RTSP main stream: rtsp://**IP address of the device**/live/mainstream.

The default authorization test time of the SDK's face recognition function is 30 ~ 60 minutes. When the authorization is invalid, the main stream preview will prompt "gace algorithm software is not authorized", and you have to restart to test again.

### 5.4 How to Debug With EVB via Network

#### 5.4.1 Debug With SSH

Connect EVB with network, get EVB board's IP address with the Chapter 5.1.2 [Get Device IP Address by RK IPCamera Tool](#### 5.1.2 Get Device IP Address by RK IPCamera Tool). Ensure that the PC can ping the EVB board.

```shell
### Clean last login message (EVB IP address: 192.168.1.159)
ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.1.159
### Command of SSH
ssh root@192.168.1.159
### input the default passwd：rockchip
```

#### 5.4.2 Debug With SCP

```shell
### Upload the test-file from PC to EVB board dirctory /userdata
scp test-file root@192.168.1.159:/userdata/
root@192.168.1.159's password:
### input the default passwd：rockchip

### Download the EVB file (/userdata/test-file) to PC
scp root@192.168.1.159:/userdata/test-file test-file
root@192.168.1.159's password:
### input the default passwd：rockchip
```

## 6 Smart USB Camera Product

The smart USB camera product supports the following functions:

- Support standard UVC camera function, up to 4K preview (RV1126)
- Support a variety of NN algorithms, including face detection, human posture or bone detection, face key point detection and tracking, and support third-party algorithm expansion
- Support USB composite device stable transmission (RNDIS/ UAC / ADB, etc.)
- Support NN preprocessing and data post-processing path
- Support preview of multiple terminal devices such as smart TV or PC
- Support for eptz function

### 6.1 Product Building Introduction

The compilation and configuration of the smart USB camera product is based on the public SDK and adopts the separate rv1126_rv1109_linux_Ai_camera_release.xml Code list management update.

#### 6.1.1 To Select Board Configure

SDK download address ：

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/linux/rk/platform/manifests -b linux -m rv1126_rv1109_linux_ai_camera_release.xml
```

| Board Configuration                               | Comment                       |
| ------------------------------------------------- | ----------------------------- |
| device/rockchip/rv1126_rv1109/BoardConfig-uvcc.mk | Smart USB Camera board config |
|                                                   |                               |

Command of selecting board configure :

```shell
### To select Smart USB Camera board config
./build.sh device/rockchip/rv1126_rv1109/BoardConfig-uvcc.mk
```

#### 6.1.2 Building

The building command of the intelligent USB camera product is the same as that of the SDK. Please refer to the SDK Building Introduction in Section 3.

### 6.2 Product Software Framework

The overall structure is as follows：

![](resources/uvcc/smart_display_ai_camera_module_sw_arch.png)

The corresponding relationship between rv1109 / rv1126 end application and source code program is as follows:

> **1.main app : source code patch:<SDK>/app/smart_display_service：Responsible for RNDIS server function implementation, command processing, NN data forwarding and other operations；**
>
> **2.AI app : source code patch: <SDK>/app/mediaserver： Responsible for sending all camera data to NPU for corresponding NN algorithm processing, and passing it to main app through shared memory mechanism ;**
>
> **3.uvc app:source code patch:  <SDK>/external/uvc_app: Responsible for the implementation and control of the complete functions of UVC camera.**

#### 6.2.1 uvc_app

Please refer to：

```shell
<SDK>/external/uvc_app/doc/zh-cn/uvc_app.md
```

#### 6.2.2 mediaserver

Please refer to：

```shell
<SDK>/docs/Linux/AppcationNote/Rockchip_Instructions_Linux_MediaServer_CN.pdf
```

#### 6.2.3 Other

For other Linux application framework or module materials, please refer to the corresponding documents in the following directory：

```shell
<SDK>/docs/Linux/
```

### 6.3  Function Introduction

#### 6.3.1 How To Preview For USB Camera

Use USB cable to connect the USB OTG port of EVB with the host computer, such as the USB host port of TV or PC, and power on. By default, the UVC camera application and rndis service will be started automatically. Use serial port to connect EVB board and run ifconfig usb0 to obtain the pre configured IP address of rndis virtual network port.

```shell
RK $ ifconfig usb0
usb0      Link encap:Ethernet  HWaddr 8E:F3:7D:36:13:34
          inet addr:172.16.110.6  Bcast:172.16.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:4884 errors:0 dropped:16 overruns:0 frame:0
          TX packets:4843 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:257305 (251.2 KiB)  TX bytes:787936 (769.4 KiB)
```

Use serial port to connect the PC end of EVB board as follows：

```shell
Baud rate：1500000
Data bits：8
Stop bit：1
Parity：none
Flow control：none
```

Android smart TV uses RKAICameraTest application or other standard camera applications. PC side recommends the use of a third-party UVC camera application such as Amcap or Potplayer. When it is opened, you can see the preview, and the switching format or resolution can refer to the application switching of upper computer.

![](/resources/uvcc/uvc_camera_open.jpg)

#### 6.3.2 How To Test AI Model Post-processing

Open the RKAICameraTest application on the TV terminal, click the rndis button to connect with rndis after seeing the preview, click the settings button to select the "model algorithm switching" option after success, select the model algorithm to be used, which is the face detection algorithm by default, and then click the "Ai post-processing switch", when the face appears in front of the camera, you can see the AI processing effect:

![](resources/uvcc/uvc_camera_ai.jpg)

![](resources/uvcc/uvc_camera_setting.jpg)

#### 6.3.3 How To Test EPTZ

Open the RKAICameraTest application at the TV end, click the rndis button to connect to rndis after seeing the preview, click the settings button to select the "eptz mode switch" option after the countdown is completed, and then open the application, at this time, the top left corner of the interface will display whether it is the eptz model or the general intelligent preview mode:

![](resources/uvcc/uvc_camera_eptz.jpg)
