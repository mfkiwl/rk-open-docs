# Rockchip RV1126/RV1109 Linux Smart Camera SDK 发布说明

文档标识：RK-FB-YF-515

发布版本：V0.2.0

日期：2020-05-19

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

文档主要介绍RV1126/RV1109 智慧屏Smart CAMERA SDK发布说明，旨在帮助工程师更快上手RV1126/RV1109 智慧屏Smart CAMERA SDK开发及相关调试方法。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| -----------| :-------------- | :------------- | :---------- |
| 2020-05-11 | V0.1.0 | HJC | 初始 Alpha版本 |
| 2020-05-19 | V0.2.0 | HJC | 更新文档路径 |
|            |          |          |                |

## **目录**

---
[TOC]
---

## 概述

本SDK基于 Buildroot 2018.02-rc3开发，内核基于 Kernel 4.19，引导基于 U-boot v2017.09，适配 RV1126/RV1109 EVB 开发板及基于此开发板进行二次开发的版型。
开发包适用但不限于电视AI camera产品，提供灵活的数据通路组合接口，满足客户自由组合的客制化需求。具体功能调试和接口说明，请阅读工程目录 docs/ 下文档。

## SDK 获取说明

SDK通过瑞芯微代码服务器对外发布获取。其编译开发环境，参考第 3节 [软件开发指南](## 3 软件开发指南)。

**获取 SDK 方法: 从瑞芯微代码服务器获取源码**

获取 RV1126/RV1109 Linux 软件包，需要有一个帐户访问 Rockchip 提供的源代码仓库。客户向瑞芯微技术窗口申请SDK，同步提供SSH公钥进行服务器认证授权，获得授权后即可同步代码。关于瑞芯微代码服务器 SSH公钥授权，请参考第 5 节  [SSH 公钥操作说明](## 5 SSH 公钥操作说明)。

RV1109_Linux_SDK 下载命令如下：

```shell
repo init --repo-url ssh://git@www.rockchip.com.cn/repo/rk/tools/repo -u ssh://git@www.rockchip.com.cn/linux/rk/platform/manifests -b linux -m rv1126_rv1109_linux_ai_camera_release.xml
```

repo 是 google 用 Python 脚本写的调用 git 的一个脚本，主要是用来下载、管理项目的软件仓库，其下载地址如下：

```shell
git clone ssh://git@www.rockchip.com.cn/repo/rk/tools/repo
```

为方便客户快速获取 SDK 源码，瑞芯微技术窗口通常会提供对应版本的 SDK 初始压缩包，开发者可以通过这种方式，获得 SDK 代码的初始压缩包，该压缩包解压得到的源码，进行同步后与通过 repo 下载的源码是一致的。
以 rv1126_rv1109_linux_sdk_alpha_v0.1_20200428.tar.bz2 为例，拷贝到该初始化包后，通过如下命令可检出源码：

```shell
mkdir rv1109
tar xjf  rv1126_rv1109_linux_sdk_alpha_v0.1_20200428.tar.bz2 -C rv1109
cd rv1109
.repo/repo/repo sync -l
.repo/repo/repo init -m rv1126_rv1109_linux_ai_camera_release.xml
.repo/repo/repo sync -c
```

后续开发者可根据 FAE 窗口定期发布的更新说明，通过 “.repo/repo/repo sync -c”命令同步更新。

## 软件开发指南

软件相关开发可以参考工程目录下的快速入门文档：

```shell
<SDK>/docs/RV1126_RV1109/Rockchip_RV1126_RV1109_Quick_Start_Linux_Smart_Camera_CN.pdf
```

## 硬件开发指南

硬件相关开发可以参考工程目录下的用户使用指南文档：

```shell
<SDK>/docs/RV1126_RV1109/Rockchip_RV1126_RV1109_EVB_User_Guide_V1.0_CN.pdf
```

## SSH 公钥操作说明

请根据《Rockchip SDK 申请及同步指南》文档说明操作，生成 SSH 公钥，发邮件至fae@rock-chips.com，申请开通 SDK 代码。
该文档会在申请开通权限流程中，释放给客户使用。

### 多台机器使用相同 SSH 公钥

在不同机器使用，可以将你的 SSH 私钥文件 id_rsa 拷贝到要使用的机器的 “~/.ssh/id_rsa” 即
可。
在使用错误的私钥会出现如下提示，请注意替换成正确的私钥

![ssh1](resources/ssh1.png)</left>

添加正确的私钥后，就可以使用 git 克隆代码，如下图。

![ssh2](resources/ssh2.png)</left>

添加 SSH 私钥可能出现如下提示错误。

```
Agent admitted failture to sign using the key
```

在 console 输入如下命令即可解决。

```shell
ssh-add ~/.ssh/id_rsa
```

### 一台机器切换不同 SSH 公钥

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

### 密钥权限管理

服务器可以实时监控某个 key 的下载次数、IP  等信息，如果发现异常将禁用相应的 key 的下
载权限。
请妥善保管私钥文件。并不要二次授权与第三方使用。

### 参考文档

更多详细说明，可参考文档 <SDK>/docs/Others/Rockchip_User_Guide_SDK_Application_And_Synchronization_CN.pdf。
