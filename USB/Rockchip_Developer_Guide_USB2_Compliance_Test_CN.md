# Rockchip USB 2.0 一致性测试指南

文件标识：RK-CS-YF-129

发布版本：V1.0.0

日期：2020-10-09

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2020瑞芯微电子股份有限公司**

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

本文档提供 Rockchip 平台 USB 2.0 的一致性测试方法。根据 USB-IF (USB  Implementers Forum) 发布的规范，USB 2.0 一致性测试包括如下三个部分^[1]^：

- 功能特性测试 Functional
- 电气特性测试 Electrical
- 互通特性测试 Interoperability

本文档将说明每一项 USB 2.0 测试的主要内容和测试方法。

同时，本文档还简单介绍了 USB 认证的流程。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| 所有芯片(包括 29 系列、30 系列、31 系列、32 系列、33 系列、PX 系列、RV 系列、MCU) | 所有内核版本 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

硬件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2020-10-09 | V1.0.0   | 吴良峰   | 初始版本     |

---

**目录**

[TOC]

---

## USB 2.0 功能特性测试

USB 2.0 功能性测试：主要测试产品的功能是否完整，USB-IF 提供了功能性测试工具 USB20CV (USB 2.0 Command Verifier) 用于评估高速，全速和低速 USB 设备是否符合 USB 设备框架（第 9 章），集线器设备类（第 11 章），HID 类和 OTG 规范。还包括大容量存储类和 USB 视频类测试规范。所有 USB 外设和集线器都必须通过设备框架测试才能获得认证。

USB20CV 工具只支持Windows系统，下载地址如下：

- [USB20CV 32-bit Windows](https://usb.org/document-library/usb20cv-x32-bit)

- [USB20CV 64-bit Windows](https://usb.org/document-library/usb20cv-x64-bit)

注意：仅 Windows 7 和更高版本支持 USB20CV 工具，并且该工具需要计算机支持增强型主机控制器接口 EHCI。

## USB 2.0 电气特性测试

USB 2.0 电气特性测试：主要测试产品的电气信号，USB 2.0 电气测试规范为 USB 2.0 产品定义了一组电气测试标准^[2][3]^ ，所有 USB 产品都必须通过 USB 电气特性测试，才能获得 USB-IF 的认证。

USB 2.0 的电气特性测试需要覆盖高速，全速和低速三种信号，对应的测试规范如下：

- 低速/全速电气测试规范：[《USB-IF Full and Low Speed Electrical and Interoperability Compliance Test Procedure》](https://usb.org/document-library/usb-if-full-and-low-speed-electrical-and-interoperability-compliance-test)
- 高速电气测试规范：[《USB 2.0 Electrical Compliance Test Specification》](https://usb.org/document-library/usb-20-electrical-compliance-test-specification-version-107)

测试 USB 2.0 电气特性，需要使用 USB-IF 认可的示波器供应商

- Keysight
- Rohde & Schwarz
- Tektronix
- Teledyne LeCroy

根据 USB 2.0 电气特性规范的要求，建议执行如下表1的测试项。

表1 USB 2.0 电气特性主要测试项

| 测试项                                | 测试要求                                                     |
| ------------------------------------- | ------------------------------------------------------------ |
| Device HS Signal Quality Test         | 参考文献[2]<br />EL_2 EL_4 EL_5 Data Eye and Mask Test<br/>EL_6 Device Rise Time<br/>EL_6 Device Fall Time<br/>EL_7 Device Non-Monotonic Edge Test |
| Device HS Packet Parameters           | 参考文献[2]<br />EL_21 Sync Field Length Test<br/>EL_25 EOP Length Test<br/>EL_22 Measure Interpacket Gap Between Second and Third Packets<br/>EL_22 Measure Interpacket Gap Between First and Second Packets |
| Device HS Device CHIRP Timing         | 参考文献[2]<br />EL_28 Measure Device CHIRP-K Latency<br/>EL_29 Measure Device CHIRP-K Duration<br/>EL_31 Hi-Speed Terminations Enable and D+ Disconnect Time |
| Device HS Suspend/Resume/Reset Timing | 参考文献[2]<br />EL_38 EL_39 Suspend Timing Response<br/>EL_40 Resume Timing Response<br/>EL_27 Device CHIRP Response to Reset from Hi-Speed<br />EL_28 Device CHIRP Response to Reset from Suspend |
| Device HS Test J/K, SE0_NAK           | 参考文献[2]<br />EL_8 J Test<br/>EL_8 K Test<br/>EL_9 SE0_NAK Test |
| Device HS Receiver Sensitivity        | 参考文献[2]<br />EL_18 Receiver sensitivity Test - Minimum SYNC Field<br/>EL_17 Receiver sensitivity Test<br/>EL_16 Receiver sensitivity Test @ Squelch |
| Host HS Signal Quality                | 参考文献[2]<br />EL_6 Rise Time<br/>EL_6 Fall Time<br/>EL_3 Data Eye and Mask Test<br/>EL_7 Non-Monotonic Edge Test |
| Host HS Packet Parameters             | 参考文献[2]<br />EL_21 Sync Field Length Test<br/>EL_25 EOP Length Test<br/>EL_23 Inter-packet Gap Between First 2 Packets Test<br/>EL_22 Inter-packet Gap Between 2nd and 3rd Packet Test<br/>EL_55 SOF EOP Width Test |
| Host HS Disconnect Detect             | 参考文献[2]<br />EL_37 Disconnect Detect Test At 525mV Threshold<br/>EL_36 Disconnect Detect Test At 625mV Threshold |
| Host  HS CHIRP Timing                 | 参考文献[2]<br />EL_33 CHIRP Timing Response<br/>EL_34 CHIRP K Width<br/>EL_34 CHIRP J Width<br/>EL_35 SOF Timing Response |
| Host HS Suspend/Resume Timing         | 参考文献[2]<br />EL_39 Suspend Timing Response<br/>EL_41 Resume Timing Response |
| Host HS Test J/K, SE0_NAK             | 参考文献[2]<br />EL_8 J Test<br/>EL_8 K Test<br/>EL_9 SE0_NAK Test |
| Host LS/FS Inrush Current Test        | 参考文献[3]<br />B.4 Inrush Current Testing                  |
| Host FS Signal Quality Test           | 参考文献[3]<br />B.3.3.1 Low-speed Downstream Signal Quality Test |
| Host LS Signal Quality Test           | 参考文献[3]<br />B.3.3.2 Full-speed Downstream Signal Quality Test |

根据表1，可以看出 USB 2.0 的电气特性测试，主要是测试高速信号质量。USB-IF 提供了基于 Windows 的 HSETT  (High-Speed Electrical Test Tool) 实用程序，用于测试 USB 高速信号，下载地址如下：

- [EHSETT 32-bit version](https://usb.org/document-library/usbhset-ehci-32-bit)
- [EHSETT 64-bit version](https://usb.org/document-library/usbhset-ehci-64-bit)
- [XHSETT 32-bit version](https://usb.org/document-library/xhsett-x32)
- [XHSETT 64-bit version](https://usb.org/document-library/xhsett-x64)

工具的使用说明，请参考如下的文档：

[HSET Documentation](https://usb.org/document-library/hset-documentation-version-041-ehci-and-xhci) version 0.41 for EHCI and xHCI

注意：

在进行 Device/Host HS Signal Quality 测试时，需要设置待测 USB 设备进入测试模式（Test Packet Mode），才能触发正确的测试信号。Rockchip 平台的 USB 控制器支持使用测试命令和测试工具 HSETT 两种方式，具体要求如下：

- USB 2.0 Device，可以使用测试命令或者测试工具设置 USB 控制器进入 Test Packet Mode
- USB 2.0 Host，只能使用测试命令设置 USB 控制器进入 Test Packet Mode

测试命令请参考文档 《Rockchip_Developer_Guide_USB_SQ_Test_CN》的章节"USB 2.0 测试命令和测试工具"。

## USB 2.0 互通特性测试

USB 2.0 互通特性测试：主要测试 USB 设备在不同的软件操作系统和不同硬件控制器下的兼容性。可能会使用"Gold Tree"上的一些设备来做互操作性测试，以测试设备和不同主机的兼容性，如设备在使用 EHCI 控制器的主机下能否枚举成功等。

因为 USB-IF 对 USB 2.0 互通性测试没有强制性要求，所以本文档不对互通性测试作详细说明。如果读者想进一步了解 USB 2.0 的互通特性的测试方法，请参考如下规范：

[《xHCI Interoperability Test Procedures For Peripherals, Hubs and Hosts Version》](https://usb.org/document-library/xhci-interoperability-test-procedures-peripherals-hubs-and-hosts-version)

## USB 2.0 认证

USB 2.0 认证是指 USB 产品通过 USB-IF 所规定的特定测试，并获得使用 USB 标志的授权。产品接收测试的方法有两种：

- 参加 USB-IF 赞助的兼容性测试大会
- USB-IF 认可的测试实验室

可以从网站 <https://www.usb.org/labs> 找到符合 USB-IF 要求的独立测试实验室。当产品通过兼容性测试后，它就会获得一个 USB 协会测试号（TESTING ID, TID），通过这个 TID，可以在 USB-IF 官网上查到这个测试设备的相关信息，并有权使用 USB 标志。

USB 兼容性测试认证的一般流程如下：

- 申请成为 USB-IF 会员，获取供应商识别码（Vendor ID, VID）；
- 准备 USB 兼容性测试清单；
- 送 USB-IF 授权的独立测试实验室进行测试；
- 获得合格报告及证书；
- 使用相应的 USB 标志；

注意：Rockchip 是 USB-IF 的会员，VID 为 0x2207，并且，SDK USB 默认配置的 VID 也是 0x2207，但该 VID 供产品开发和调试使用，无法授权给开发者使用。如果产品需要过 USB-IF 认证，需要开发者独立申请成为 USB-IF 会员，以获取唯一的 Vendor ID。

## 参考文献

1. [USB 2.0 Testing Information](https://usb.org/usb2)
2. [USB 2.0 Electrical Compliance Test Specification](https://usb.org/document-library/usb-20-electrical-compliance-test-specification-version-107)
3. [USB-IF Full and Low Speed Electrical and Interoperability Compliance Test Procedure](https://usb.org/document-library/usb-if-full-and-low-speed-electrical-and-interoperability-compliance-test)
4. [HSET Documentation version 0.41 for EHCI and xHCI](https://usb.org/document-library/hset-documentation-version-041-ehci-and-xhci)
5. 《Rockchip_Developer_Guide_USB_SQ_Test_CN》
