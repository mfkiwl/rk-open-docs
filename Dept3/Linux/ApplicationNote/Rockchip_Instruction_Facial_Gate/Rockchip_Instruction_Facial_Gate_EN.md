# Rockchip Facial Gate Instruction

ID: RK-SM-YF-329

Release Version: V2.0.3

Release Date: 2021-03-15

Security Level: □Top-Secret   □Secret   □Internal   ■Public

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

**All rights reserved. ©2021. Rockchip Electronics Co., Ltd.**

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

This document mainly introduces the usage of each module of the ficial_gate application. The ficial_gate application is based on librkfacial.so. For the detailed interfaces introduction, please refer to "Rockchip_Instruction_Rkfacial_CN.pdf". The source code and document path are located in SDK/external/rkfacial.

**Product Version**

| **Platform**   | **Kernel Version** |
| -------------- | ------------------ |
| RK1808，RK1806 | Linux 4.4          |
| RV1126，RV1109 | Linux 4.19         |

**Intended Audience**

This document (this guide) is mainly intended for:

Technical support engineers

Software development engineers

**Revision History**

| **Date**    | **Version** | **Author**  | **Change Description**                             |
| ----------- | ----------- | :---------- | -------------------------------------------------- |
| 2020-02-11  | V0.0.1      | Zhihua Wang | Initial version                                    |
| 2020-02-24  | V0.0.2      | Zhihua Wang | Add description to command parameter -i, -c        |
| 2020-03-10  | V1.0.0      | Zhihua Wang | Add application flow chart                         |
| 2020-04-29  | V1.0.1      | Zhihua Wang | Modify the key.lic path                            |
| 2020-05-21  | V2.0.0      | Zhihua Wang | Divide the code into ui and librkfacial.so         |
| 2020-05-22  | V2.0.1      | Zhihua Wang | Add rkfacial description                           |
| 2020-07-23  | V2.0.2      | Ruby Zhang  | Update company name, document format and file name |
| 22021-03-15 | V2.0.3      | Ruby Zhang  | Update product version information                 |

---

**Contents**

[TOC]

---

## Overview

### Application Introduction

The ficial_gate application takes RK's own algorithm rockface through librkfacial.so to realize face detection, face feature point extraction, face recognition, and live detection process.

It includes the following functions:

1. Get RGB camera image data for face recognition, and IR camera image data for live detection .

2. Use SQLITE3 as a database to store facial feature values and user names.

3. Use MiniGUI to realize user registration, delete registration data, face frame tracking and user name display and other operations.

4. Use the ALSA interface to realize the voice broadcast function of each process.

**Note:** rockface usage requires RK authorization, please refer to sdk/external/rockface/auth/README to apply for authorization.

### Usage

ficial_gate [-f num] [-e] [-i] [-c]

-f: indicates the maximum number of face database supported. If there is no configuration, the default face database supports a maximum of 1000

-e: indicates supported partial exposure of RGB camera face coordinates, partial exposure is not supported by default without configuration

-i: means the RGB camera on ISP driver

-c: indicates the IR camera on CIF driver

Examples:

Both ISP and CIF: ficial_gate -f 30000 -e -i -c, the screen displays RGB images, which can be used to detect  faces and with live detection;

Only ISP: ficial_gate -f 30000 -e -i, the screen displays RGB images, which can be used to detect faces without live detection

Only CIF: ficial_gate -f 30000 -e -c, the screen displays IR images, which can be used to debug live algorithms

## Code Modules  Introduction

### UI

Register button: registration of facial feature values collected by the camera to the database in real time.

Delete button: delete the facial feature values collected by the camera from the database in real time.

Face frame: red means it has not been registered in the database, yellow means it has been registered in the database but not alive, and green means it has been registered in the database and it is alive.