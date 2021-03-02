# RK356X Linux SATA 开发指南

文件标识：RK-KF-YF-148

发布版本：V1.0.0

日期：2021-02-26

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2021 瑞芯微电子股份有限公司**

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

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RK356X       | 4.19         |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2021-02-26 | V1.0.0   | 赵仪峰   | 初始版本     |

---

**目录**

[TOC]

---

## 芯片资源介绍

RK3566

| 资源  | 模式       | 支持PM芯片扩展 | PHY复用     | 备注 |
| ----- | ---------- | -------------- | ----------- | ---- |
| SATA0 | 6G/3G/1.5G | 支持           | USB         |      |
| SATA1 | 6G/3G/1.5G | 支持           | USB、QSGMII |      |

RK3568

| 资源  | 速率       | 支持PM芯片扩展 | PHY复用      | 备注 |
| ----- | ---------- | -------------- | ------------ | ---- |
| SATA0 | 6G/3G/1.5G | 支持           | USB          |      |
| SATA1 | 6G/3G/1.5G | 支持           | USB、QSGMII  |      |
| SATA2 | 6G/3G/1.5G | 支持           | PCIE、QSGMII |      |

## DTS 配置

RK3566

| 资源  | 参考配置    | 控制器节点 | PHY节点      |
| ----- | ----------- | ---------- | ------------ |
| SATA0 | rk3568.dtsi | sata0      | combphy0_us  |
| SATA1 | rk3568.dtsi | sata1      | combphy1_usq |

RK3568

| 资源  | 参考配置    | 控制器节点 | PHY节点      |
| ----- | ----------- | ---------- | ------------ |
| SATA0 | rk3568.dtsi | sata0      | combphy0_us  |
| SATA1 | rk3568.dtsi | sata1      | combphy1_usq |
| SATA2 | rk3568.dtsi | sata2      | combphy2_psq |

1. `compatible = "snps,dwc-ahci";`

**必须配置项**：默认配置，对应驱动：drivers/ata/ahci_platform.c。

2. `phy-names = "sata-phy“;`

**必须配置项**：不可以修改，AHCI驱动会根据"sata-phy“名字找到对应combphy节点。

3. `status = <okay>;`

**必须配置项**：此配置需要在 SATA控制器节点和对应的 phy 节点同时使能。

4. `assigned-clock-rates = <24000000>;`

**必须配置项**：可以配置的参考时钟频率值有：24000000、25000000和100000000.

5. `pinctrl-0 = <&sata_pm_reset>;`

```
sata_pm_reset: sata-pm-reset {
	rockchip,pins = <4 RK_PD2 RK_FUNC_GPIO &pcfg_output_high>;
};
```

**可选配置项**：外接PM芯片扩展SATA口时，可能需要一个GPIO来复位PM芯片，具体可以参考“rk3568-nvr-demo-v10.dtsi”里面设置。

## menuconfig 配置

需要确保如下配置打开，方可正确的使用 SATA相关功能。

```
CONFIG_ATA=y
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
CONFIG_PHY_ROCKCHIP_NANENG_COMBO_PHY=y
```

## 常见问题

**Q1**： 是否支持通过SATA接口给PM芯片下载固件？

A1： 目前验证过JMB575，没法下载固件。需要外接一个SPI NOR用于存放JMB575最新固件。

**Q2**： SATA性能怎么测试？

A2： 参考文档 RK-KF-YF-138 《Rockchip_RK3568_Reference_SATA_Performance_CN》。

**Q3**:  默认SDK代码认不到SATA设备，什么原因？

A3:   目前已知的情况是第一版SDK代码再单独更新uboot后，会出现这个问题，需要更新一下kernel下phy驱动。

```
commit b3f78165e536d35b2337063093bb33a018ff518d
Author: Shawn Lin <shawn.lin@rock-chips.com>
Date:   Wed Dec 23 16:17:31 2020 +0800

	phy: rockchip: naneng-combphy: Reset phy if not being used

	Change-Id: Ia62481ebf5aa5684c359fd00a3933bb02e2caaff
	Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
```