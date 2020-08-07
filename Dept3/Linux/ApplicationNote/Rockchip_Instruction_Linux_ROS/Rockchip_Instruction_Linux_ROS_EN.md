# Rockchip ROS Introduction

ID: RK-SM-YF-377

Release Version: V1.0.2

Release Date: 2020-08-06

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

Customer service e-Mail:  [fae@rock-chips.com**Preface**

**Overview**

This document mainly introduces how to use ROS of Rockchip Linux SDK.

**Product Version**

| **Chipset** | **Kernel Version** |
| ------------ | ------------ |
| RK3XXX | 4.4 |

**Intended Audience**

This document (this guide) is mainly intended for:

Technical support engineers

Software development engineers

**Revision History**

| **Version** | **Author** | **Date** | **Change Description** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | WZZ | 2018-12 | ROS has been porting into buildroot, <br/>removing the original building method <br/>and switching to the new one. |
| V1.0.1    | WZZ | 2019-12 | Fix beginner_tutorials building issue |
| V1.0.2   | Ruby Zhang | 2020-08-06 | Update the company name and document format |

---

**目录**

[TOC]

---

## Overview

Rockchip Linux SDK integrated ROS which provides a range of libraries and tools to help software developers create robotic applications.

ROS version which Rockchip integrated are Indigo and kinetic.

## Build

There are two default configurations of ros_indigo.config and ros_kinetic.config under buildroot/configs/rockchip directory. Before building rootfs, add ros_xxx.config to the config corresponding to rootfs.

Take RK3308 Linux SDK as an example. Others are similar, modify buildroot/configs/rockchip_rk3308_release_defconfig:

```diff
diff --git a/configs/rockchip_rk3308_release_defconfig
b/configs/rockchip_rk3308_release_defconfig
index f905f16..a2afac1 100644
--- a/configs/rockchip_rk3308_release_defconfig
+++ b/configs/rockchip_rk3308_release_defconfig
@@ -135,3 +135,4 @@ BR2_TARGET_ROOTFS_SQUASHFS=y
 # BR2_TARGET_ROOTFS_TAR is not set
 BR2_PACKAGE_HOST_MKE2IMG=y
 BR2_PACKAGE_HOST_VBOOT_UTILS=y
+#include "ros_indigo.config"
```

And then run`./build.sh`.

Or first select the rockchip_rk3308_release corresponding to source envsetup.sh, then run `make`.

The compilation for the first time will take a few hours. After the compilation is complete, buildroot/output/rockchip_rk3308_release/images/rootfs.squashfs which is the rootfs firmware will be generated.

## Add the New ROS Code

There is a ros_sample provided: <https://github.com/DZain/ROS_Sample.git>

Put the project to external, and rename to beginner_tutorials.

Then add the following files and modifications in buildroot:

1. `vi buildroot/package/rockchip/ros/beginner_tutorials/Config.in`, add the following contents:

```shell
config BR2_PACKAGE_BEGINNER_TUTORIALS
bool "beginner tutorials"
select BR2_PACKAGE_ROSCPP
select BR2_PACKAGE_ROSPY
select BR2_PACKAGE_STD_MSGS
select BR2_PACKAGE_GENMSG
help
beginner tutorials
```

The select option in the Config depends on the dependencies in the project.

2. `vi buildroot/package/rockchip/ros/beginner_tutorials/beginner_tutorials.mk`

```shell
BEGINNER_TUTORIALS_VERSION = 1.0.0
BEGINNER_TUTORIALS_SITE_METHOD = local
BEGINNER_TUTORIALS_SITE = $(TOPDIR)/../external/beginner_tutorials

BEGINNER_TUTORIALS_DEPENDENCIES = roscpp rospy std-msgs genmsg

${eval ${catkin-package}}
```

3. Add beginner_tutorials to buildroot:

```diff
@@ -46,6 +46,7 @@ source diff --git a/package/rockchip/ros/Config.in b/package/rockchip/ros/Config.in
index e26003aa9f..cb6f6c18e6 100644
--- a/package/rockchip/ros/Config.in
+++ b/package/rockchip/ros/Config.in
@@ -46,6 +46,7 @@ source "package/rockchip/ros/cmake_modules/Config.in"
 source "package/rockchip/ros/rospack/Config.in"
 source "package/rockchip/ros/orocos_kinematics_dynamics/Config.in"
 source "package/rockchip/ros/image-common/Config.in"
+source "package/rockchip/ros/beginner_tutorials/Config.in"
 source "package/rockchip/ros/bond-core/Config.in"
 source "package/rockchip/ros/nodelet-core/Config.in"
```

4. Build

Run the source envsetup.sh in the SDK root directory, select rockchip_rk3308_release (If you have already ran it, don't have to run again).

Configure `make menuconfig`, use '/' opening search menu, search BEGINNER_TUTORIALS (in step 1, defined in Config.in), and select.

Save the configuration.

Build with make.

(Or use `make beginner_tutorials` directly. Rebuild using `make beginner_tutorials-dirclean && make beginner_tutorials`)

## Flashing

Please refer to the release documentations of Rockchip Linux SDK for instructions on how to flash firmware. It won't go into details here. Just download the Rootfs.img generated by ROS building to the corresponding rootfs partition.

## Run

The steps to run ROS are as follows:

1. Configure environment variables

```shell
source /opt/ros/indigo/setup.sh
```

2. Run roscore

```shell
roscore &
```

3. Run the code

Take the beginner_tutorials as an example:

```shell
rosrun beginner_tutorials talker
```

Running result:

```shell
[ INFO] [1501923947.458788791]: hello world 0
[ INFO] [1501923947.558904332]: hello world 1
[ INFO] [1501923947.658774958]: hello world 2
[ INFO] [1501923947.758644458]: hello world 3
[ INFO] [1501923947.858779666]: hello world 4
[ INFO] [1501923947.958779291]: hello world 5
```

 (The beginner_tutorials code is a pair of programs, "talker" is used to send and "listener" is used to listen, open talker alone, number will accumulate continuously, and there is no phenomenon when opening listener alone, but when talker is opened at the same time, two programs number print simultaneously)

