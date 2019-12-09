# **Rockchip RK2206 Firmware Merge User Guide**

文件标识：RK-KF-YF-309

发布版本：1.0.1

日       期：2019.11

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有** **© 2019** **福州瑞芯微电子股份有限公司**

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

本文档主要介绍了Rockchip 2206芯片平台使用FirmwareMerge工具生成固件的方法与流程。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2018-12-25 | 1.0.0    | LY       | 初始版本     |
| 2019-11-15 | 1.0.1    | MLC      | 支持RK2206   |
|            |          |          |              |

---

## **目录**

[TOC]

---

## **1 概述**

FirmwareMerger 是用来生成可运行固件的工具，生成的固件可以通过 Rockchip 提供的工具进行烧录或者使用烧录器烧录，固件采用 Rockchip 自定义的分区表进行分区管理。

### **1.1 固件结构**

固件分区结构具体详见下表：

| 0 – 7 扇区            | 分区表    |
| --------------------- | --------- |
| 8 -  63 扇区          | Vendor区  |
| 64 – 255 扇区         | IDBlock区 |
| 分区1起始 - 分区1结束 | 分区1     |
| …                     | …         |
| 分区n起始 - 分区n结束 | 分区n     |

### **1.2 分区表介绍**

分区表由分区表头(1个扇区)和分区表项(7个扇区)组成，一个扇区可以存放4个分区表项，RKOS最多可以支持28个分区。

分区表头结构具体如下:

```c
typedef struct {
	UINT	uiFwTag;
	STRUCT_DATETIME	dtReleaseDataTime;
	UINT	uiFwVer;
	UINT	uiSize;/*分区表头结构大小，字节单位，固定512*/
	UINT	uiPartEntryOffset;/*分区项偏移，扇区单位，固定1*/
	UINT	uiBackupPartEntryOffset;
	UINT	uiPartEntrySize;/*分区项大小，字节单位，固定128*/
	UINT	uiPartEntryCount;
	UINT	uiFwSize;/*unit of byte*/
	BYTE    noBackupHeader;
	char	szChip[4];
	char    szModel[32];
	BYTE	reserved[427];
	UINT	uiPartEntryCrc;/*所有分区项Crc*/
	UINT	uiHeaderCrc;
} STRUCT_FW_HEADER, *PSTRUCT_FW_HEADER;
```

分区表项结构：

```c
typedef struct {
	char	szName[32];
	ENUM_PARTITION_TYPE emPartType;/*分区类型*/
	UINT	uiPartOffset;/*分区基址，单位扇区*/
	UINT	uiPartSize;/*分区大小，单位扇区*/
	ULONGLONG uiDataLength;/*分区数据大小*/
	UINT	uiPartProperty;/*分区属性*
	BYTE	reserved[72];
} STRUCT_PART_ENTRY, *PSTRUCT_PART_ENTRY;
```

## **2 工具配置**

### **2.1 分区表详细配置**

固件中各个分区表在固件中位置可在setting-story-machine-8M.ini 文件中详细配置：

配置文件位置为：

```
Path_to_SDK/bin/RK2206/
```

工具下的setting-story-machine-8M.ini文件主要包含两类配置：

- 基本配置
- 分区表配置

#### **2.1.1 基本配置**

FwVersion=1.0	//指定固件版本
Gpt_Enable= 	//0：gpt 固件， 1：紧凑 gpt 固件， RK2206 当前项为空值
Backup_Partition_Enable= 	//RK2206 没有使用备份分区表，设为空值
Nano= 	//RK2206 设为空值，如果使用 NanoD 芯片，设置为 1
Loader_Encrypt= //如果 loader 代码使用 rc4 加密，设置为 1， RK2206 当前项为空值
Chip=	//芯片信息
Model=	//产品型号

```
[System]
FwVersion=1.0
Gpt_Enable=
Backup_Partition_Enable=
Nano=
Loader_Encrypt=
Chip=
Model=
```

若想写入文件系统数据，可按如下方式配置：

```
[UserPart5]
Name=User
Type=0x80000000	/*最后一个分区Type必须为0x80000000*/
PartOffset=0x2200
PartSize=
Flag=4
File=./userdata.img	/*带文件系统的分区数据*/
```

## **3  使用事例**

固件打包：

```
Firmware_merger –P setting.ini
```

根据 setting.ini 中的配置在当前目录下生成 firmware.img 固件。

固件解包：

```
Firmware_merger –U firmware.img out OFFCHECK
```

 解包前不进行 md5 校验，将解包后的数据保存到out 目录下。
