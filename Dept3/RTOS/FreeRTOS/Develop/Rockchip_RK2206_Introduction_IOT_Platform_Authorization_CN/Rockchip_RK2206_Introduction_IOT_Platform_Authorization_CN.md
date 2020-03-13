# RK2206 IOT平台授权码接口开发指南

文件标识：RK-SM-YF-333

发布版本：V1.0.1

日期：2020-03-13

文件密级：□绝密   □秘密   □内部资料   ■公开

------

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

商标声明

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

版权所有 © 2020 福州瑞芯微电子股份有限公司

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

------

## **前言**

**概述**

本文主要介绍物联网平台授权码使用方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

1. 技术支持工程师
2. 软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**           |
| ---------- | -------- | --------  | ---------------------- |
| 2020-03-13 | V1.0.0   | Conway Chen | 初始版本               |
| 2020-03-13 | V1.0.1   | Conway Chen | SDK授权码更改为make menuconfig配置，文档同步更新 |

## **目录**

[TOC]

## 1 物联网平台介绍

### 1.1 RK2206 SDK 物联网平台

瑞芯微RK2206芯片目前支持物联网平台如下：

- 思必驰物联网平台：思必驰专注人性化的智能语音交互技术，为企业和开发者提供自然语言交互解决方案，包括DUI开放平台、企业级智能服务、人机对话操作系统、人工智能芯片模组等。
- 顽童科技物联网平台：玩瞳科技是一家为摄像头赋能教育智慧的企业，致力于采用AI视觉算法平板电脑的摄像头进行赋能，帮助其具有教育智慧。
- EchoCloud回声云：零秒科技EchoCloud回声云是一个语音AI云接入平台，具备上下文记忆、多场景识别、无监督学习等技术能力，可快速提升智能设备的跨领域识别和多轮交互式体验。

物联网平台选择：

```
make menuconfig
配置路径： (top menu) → IoT Function
(top menu) → IoT Function Rockchip RKOS V2.0.0 SDK Configuration
[*] AiSpeech Platfrom
(10)    ai dialog exit of timeout
[ ] Dueros Cloud
[*] Echo Cloud
[ ] Tuling Platfrom
[*] Wan Tong Platfrom
[ ]     Device ID get from SN(otherwise use default test id)
[*] YHK Platfrom
```

### 1.2 物联网平台授权码介绍

目前RK2206SDK 支持的物联网平台，使用的是测试授权码，仅供测试使用。测试授权码不能用于量产（试产），测试授权码可授权的设备数量有限。OEM生产时，请务必联系对应物联网平台，获取官方正式授权码。

## 2 物联网平台授权码软件配置

获取官方物联网平台的正式授权码等信息，在make  menuconfig对应物联网平台选项卡处修改

如果你选择了物联网平台

- 不填入相关授权码，将会默认使用测试授权码(不能用于量产、试产)

- 填入向物联网平台申请的官方授权码，将会使用填入的授权码

### 2.1 玩瞳科技授权码

make menuconfig
配置路径： (top menu) → IoT Function → Wan Tong Platfrom → Wan Tong Platfrom
填入两项官方授权信息，对应wan tong platform license / wan tong device id

```
(top menu) → IoT Function
                              Rockchip RKOS V2.0.0 SDK Configuration
[] AiSpeech Platfrom
()    ai dialog exit of timeout
[ ]     AiSpeech platform info setting
[ ] Dueros Cloud
[ ] Echo Cloud
[ ] Tuling Platfrom
[*] Wan Tong Platfrom
[ ]     Device ID get from SN(otherwise use default test id)  #选上代表设备ID使用烧录的SN，否则是使用默认测试ID
[*]     Wan Tong Platform info setting  #向官方云平台申请的授权码设置
()          wan tong platform license   #申请的license
()          wan tong device id          #申请的device id
[] YHK Platfrom
```

### 2.2 思必驰授权码

make menuconfig
配置路径： (top menu) → IoT Function →AiSpeech Platfrom
填入三项官方授权信息，对应AiSpeech product ID / AiSpeech product key / Aispeech product secret

```
(top menu) → IoT Function
                              Rockchip RKOS V2.0.0 SDK Configuration
[] AiSpeech Platfrom
()    ai dialog exit of timeout
[*]     AiSpeech platform info setting
()          AiSpeech product ID     #"产品ID"，最大24byte
()          AiSpeech product key    #"产品key"，最大24byte
()          Aispeech product secret #"产品加密的key"，最大64byte
[ ] Dueros Cloud
[ ] Echo Cloud
[ ] Tuling Platfrom
[ ] Wan Tong Platfrom
[] YHK Platfrom
```

### 2.3 EchoCloud授权码

make menuconfig
配置路径： (top menu) → IoT Function → EchoCloud
填入三项官方授权信息，对应echo cloud produt channel uuid / echo cloud device id / echo cloud hash key

```
(top menu) → IoT Function
                              Rockchip RKOS V2.0.0 SDK Configuration
[] AiSpeech Platfrom
()    ai dialog exit of timeout
[ ]     AiSpeech platform info setting
[ ] Dueros Cloud
[*] Echo Cloud
[*]     echo cloud platform info setting
()          echo cloud produt channel uuid  #"产品UUID"，最大40byte
()          echo cloud device id            #"产品设备ID"，最大40byte
()          echo cloud hash key             #"产品HASH_KEY"，最大64byte
()                                          #这个空不用管，是使用SDK内部固件版本号
[ ] Tuling Platfrom
[] Wan Tong Platfrom
[]     Device ID get from SN(otherwise use default test id)
[ ]     Wan Tong Platform info setting
[] YHK Platfrom
```