# ProductionTool用户手册

文件标识：RK-YH-YF-001

发布版本：1.0.2

日        期：2019.11

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2019福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com]

---

**前言**

**概述**

本文档主要介绍Rockchip ProductionTool工具使用和常见问题处理。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RK2206       |              |
| RK2106       |              |
| RV1108       |              |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**              |
| ---------- | -------- | -------- | -------------------------- |
| 2018.12.25 | 1.0      | LY       | 初始版本                |
| 2019.06.27 | 1.0.1    | cww      | 修改文件名以及客户服务邮箱 |
| 2019.11.29 | 1.0.2    | LY       | 修改文档排版 |

---

**目录**

[TOC]

---

## 概述

ProductionTool是应用在小系统解决方案上的厂线烧录工具,在usb带宽允许的情况下可以支持24台设备同时升级。

## 目录结构

- Language目录:语言文件

- Config.ini 工具配置文件

- ProductionTool.exe 烧录程序

## 常用设置

![](.\Rockchip-User-Guide-ProductionTool-CN\common_settings.png)

1. 模式选择:目前只支持”固件升级”,后续会支持”擦除Flash”功能

2. “重启设备”,勾选上,在固件升级完成后会重启设备

3. “回读校验”,勾选上,在固件烧写完后,会从设备端回读所有数据同原始固件进行比较

4. “Msc升级”,勾选上,工具支持扫描msc设备,当发现后,会去切换设备进入升级模式,开始正常升级

5. “不烧录未使用的分区空间”,勾选上,工具烧录固件时,只写入固件中各分区的有效数据,未使用的填充数据不进行烧写.

## 固件升级

### 点击”固件”,选择固件和Loader

![](.\Rockchip-User-Guide-ProductionTool-CN\firmware_upgrade_step1.png)

### 点击”启动”,开始等待升级设备接入

![](.\Rockchip-User-Guide-ProductionTool-CN\firmware_upgrade_step2.png)

**升级前准备:**

升级设备在第一次接入PC后,工具会记录下它的接入usb端口信息并分配它一个”ID”,以后接入这个usb端口的设备都使用这个ID.

点击”停止”后,用一台升级设备依次接入所有使用的usb端口,每接入一个usb端口,记录下工具给它分配的ID,然后用标签纸写上ID,贴在usb线上,以后工具都是用ID来表示设备.
![](.\Rockchip-User-Guide-ProductionTool-CN\firmware_upgrade_step3.png)

## 常见升级问题

### 下载Boot失败

![](.\Rockchip-User-Guide-ProductionTool-CN\boot_download_fail.png)
下载Boot操作分两步,一是下载ddr初始化代码到sram中运行,二是下载升级代码到ddr中运行,所以这个步骤失败:1查主控;2查ddr

### 测试设备失败

![](.\Rockchip-User-Guide-ProductionTool-CN\test_device_fail.png)
测试设备操作在下载Boot之后,如果测试设备失败,多数是DDR有问题,导致下载到ddr中的升级通讯代码运行不正常.

### 下载Firmware失败

![](.\Rockchip-User-Guide-ProductionTool-CN\down_firmware_fail.png)

“下载Firmware失败”主要是两种原因:

1. usb通讯不稳定,更换usb端口或者usb连接线,检查设备端usb硬件
2. 设备端写操作出错,连接串口,提供串口日志,排除flash硬件

### 校验Firmware失败

![](.\Rockchip-User-Guide-ProductionTool-CN\check_firmware_fail.png)
“校验Firmware失败”,校验过程主要是回读数据进行比较,失败的原因:

1. usb通讯不稳定,更换usb端口或者usb连接线,检查设备端usb硬件
2. 设备端读操作出错,连接串口,提供串口日志,排除flash硬件

### 校验Firmware失败,数据比较出错

![](.\Rockchip-User-Guide-ProductionTool-CN\check_firmware_data_compare_err.png)

当出现数据比较出错,会在工具的log目录下导出当时比较的两份数据,文件名中有file的是原数据,文件名中有flash的是设备回读的数据.对比两个文件:

1. 如果不同数据,是非常有规律的个别bit出错,检查ddr
2. 如果数据出现大块不同,检查flash

### 权限问题

当出现”下载Boot”失败情况,请先确认rockusb驱动是不是使用v4.6之前版本,如果是,需要右击程序以管理员权限打开工具.