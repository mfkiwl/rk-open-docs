# Rockchip RV1126/RV1109 Linux SDK Release Note

ID: RK-FB-YF-359

Release Version: V0.1

Release Date: 2020-04-28

Security Level: □Top-Secret   □Secret   □Internal   ■Public

---

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. FUZHOU ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

**All rights reserved. ©2020. Fuzhou Rockchip Electronics Co., Ltd.**

Beyond the scope of fair use, neither any entity nor individual shall extract, copy, or distribute this document in any form in whole or in part without the written approval of Rockchip.

Fuzhou Rockchip Electronics Co., Ltd.

No.18 Building, A District, No.89, software Boulevard Fuzhou, Fujian,PRC

Website:     [www.rock-chips.com](http://www.rock-chips.com)

Customer service Tel:  +86-4007-700-590

Customer service Fax:  +86-591-83951833

Customer service e-Mail:  [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

<div style="page-break-after: always;"></div>

**Preface**

**Overview**

The document presents Rockchip RV1126/RV1109 Linux SDK release notes, aiming to help engineers get started with  RV1126/RV1109 Linux SDK development and debugging faster.

**Intended Audience**

This document (this guide) is mainly intended for:

- Technical support engineers
- Software development engineers

**Revision History**

| **Date** | **Version** | **Author** | **Revision History** |
| -----------| :-------------- | :------------- | :---------- |
| 2020-04-28 | V0.1 | CWW | Initial Alpha version |
|            |          |          |                |

<div style="page-break-after: always;"></div>

**Contents**

---
[TOC]
---

<div style="page-break-after: always;"></div>

## 1 Overview

This SDK is based on Buildroot 2018.02-rc3, with kernel 4.19 and U-boot v2017.09. It is suitable for RV1126/RV1109 EVB development boards and all other Linux products developed based on it. For detailed functions debugging and interface introductions, please refer to the documents under the project's docs/ directory.

## 2 How to Get the SDK

SDK is released by Rockchip server. Please refer to [Chapter 3 Software Development Guide](## 3 Software Development Guide) to build a development environment.

**The way to get the SDK source code from Rockchip code server:**

To get RV1126/RV1109 Linux SDK software package, customers need an account to access the source code repository provided by Rockchip. In order to be able to obtain code synchronization, please provide SSH public key for server authentication and authorization when apply for SDK from Rockchip technical window. About Rockchip server SSH public key authorization, please refer to [Chapter 5 SSH  Public Key Operation Introduction](## 5 Public Key Operation Introduction).

The command for downloading RV1126_RV1109_Linux_SDK is as follows:

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/linux/rk/platform/manifests -b linux -m rv1126_rv1109_linux_release.xml
```

Repo, a tool built on Python script by Google to help manage git repositories, is mainly used to download and manage software repository of projects. The download address is as follows:

```shell
git clone ssh://git@www.rockchip.com.cn/repo/rk/tools/repo
```

For quick access to SDK source code, Rockchip Technical Window usually provides corresponding version of SDK initial compression package. In this way, developers can get SDK source code through decompressing the initial compression package, which is the same as the one downloaded by repo.
Take rv1126_rv1109_linux_sdk_alpha_v0.1_20200428.tar.bz2  as an example. After getting an initialization package, you can get the source code by running the following command:

```shell
mkdir rv1126_rv1109
tar xjf rv1126_rv1109_linux_sdk_alpha_v0.1_20200428.tar.bz2 -C rv1126_rv1109
cd rv1126_rv1109
.repo/repo/repo sync -l
.repo/repo/repo sync
```

Developers can update via `.repo/repo/repo sync` command according to update instructions that are regularly released by FAE window.

## 3 Software Development Guide

For software development, you can refer to the quick start document in the project directory:

```shell
<SDK>/docs/Soc_internal/RV1109/Rockchip_RV1126_RV1109_Quick_Start_Linux_CN.pdf
```

## 4 Hardware Development Guide

Please refer to user guides in the project directory for hardware development:

```shell
<SDK>/docs/Soc_internal/RV1109/Rockchip_RV1126_RV1109_User_Guide_CN.pdf
```

## 5 SSH Public Key Operation Introduction

Please follow the introduction in the “Rockchip SDK Application and Synchronization Guide” to generate an SSH public key and send the email to [fae@rock-chips.com](mailto:fae@rock-chips.com), applying for permission to download SDK code.
This document will be released to customers during the process of applying for permission.

### 5.1 Multi-device Use the Same SSH Public Key

If the same SSH public key should be used in different devices, you can copy the SSH private key file id_rsa to “~/.ssh/id_rsa” of the device you want to use.

If the following prompt appears when using a wrong private key, please be careful to replace it with the correct private key.

![ssh1](resources/ssh1.png)</left>

After adding the correct private key, you can use git to clone code, as shown below.

![ssh2](resources/ssh2.png)</left>

Adding SSH private key may result in the following error.

```
Agent admitted failture to sign using the key
```

Please enter the following command in console to solve:

```shell
ssh-add ~/.ssh/id_rsa
```

### 5.2 Switch Different SSH Public Keys on the Same Device

You can configure SSH according to the ssh_config documentation.

```shell
~$ man ssh_config
```

![ssh3](resources/ssh3.png)</left>

Run the following command to configure SSH configuration of current user.

```shell
~$ cp /etc/ssh/ssh_config ~/.ssh/config
~$ vi .ssh/config
```

As shown in the figure, SSH uses the file “~/.ssh1/id_rsa” of another directory as an authentication private key. In this way, different keys can be switched.

![ssh4](resources/ssh4.png)</left>

### 5.3 Key Authority Management

Server can monitor download times and IP information of a key in real time. If an abnormality is found, download permission of the corresponding key will be disabled.

Keep the private key file properly. Do not grant second authorization to third parties.

### 5.4 Reference Documents

For more details, please refer to document “sdk/docs/Tools/Rockchip SDK Kit Application GuideV1.6-201905.pdf”.
