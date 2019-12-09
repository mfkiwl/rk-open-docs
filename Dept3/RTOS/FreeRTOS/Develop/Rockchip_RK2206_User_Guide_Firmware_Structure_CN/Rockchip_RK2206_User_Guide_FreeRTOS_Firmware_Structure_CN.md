# **Rockchip RK2206 Firmware Structure User Guide**

文件标识：RK-KF-YF-310

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

<div style="page-break-after: always;"></div>
## **前言**

**概述**

本文档主要介绍了Rockchip 2206芯片平台的固件结构形式，方便开发者直观的了解固件的构成。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**             |
| ---------- | -------- | -------- | ------------------------ |
| 2018-12-28 | 1.0.0    | MLC      | 初始版本                 |
| 2019-11-15 | 1.0.1    | MLC      | 支持RK2206，修改软件版本 |
|            |          |          |                          |

---

<div style="page-break-after: always;"></div>
## **目录**

[TOC]

---

<div style="page-break-after: always;"></div>
## **1 概述**

RK2206的固件采用分区表进行分区管理,支持AB固件备份。生成的固件文件是可以直接运行，只要从目标存储0地址开始烧录全部固件内容，就可完成固件升级。

### **1.1 固件结构**

固件分区结构具体详见下表：

| 0 – 7 扇区            | 分区表    |
| --------------------- | --------- |
| 8 -  63 扇区          | Vendor区  |
| 64 – 255 扇区         | IDBlock区 |
| 分区1起始 - 分区1结束 | 分区1     |
| …                     | …         |
| 分区n起始 - 分区n结束 | 分区n     |

![](resources/fw_structure.png)

### **1.2 分区表介绍**

分区表由分区表头(1个扇区)和分区表项(7个扇区)组成，一个扇区可以存放4个分区表项， RKOS最多可以支持28个分区。

分区表头结构具体如下：

```c
typedef struct {
	UINT	uiFwTag;
	STRUCT_DATETIME	dtReleaseDataTime;
	UINT	uiFwVer;
	UINT	uiSize;/*分区表头结构大小,字节单位,固定512*/
	UINT	uiPartEntryOffset;/*分区项偏移,扇区单位,固定1*/
	UINT	uiBackupPartEntryOffset;
	UINT	uiPartEntrySize;/*分区项大小,字节单位,固定128*/
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
	UINT	uiPartOffset;/*分区基址,单位扇区*/
	UINT	uiPartSize;/*分区大小,单位扇区*/
	ULONGLONG uiDataLength;/*分区数据大小*/
	UINT	uiPartProperty;/*分区属性*
	BYTE	reserved[72];
} STRUCT_PART_ENTRY, *PSTRUCT_PART_ENTRY;
```

### **1.3 分区表详细配置**

固件中各个分区表在固件中位置可在setting-story-machine-8M.ini文件中详细配置：

配置文件位置为：

```
Path_to_SDK/bin/RK2206/setting-story-machine-8M.ini
```

此处，根据Flash容量大小，配置了8M Flash的分区表，后续实际开发中可根据实际使用的Flash大小做配置上的调整。

分区大小的计算公式：
$$
PartSize * 512 （512为sector大小，单位Byte）
$$

该配置文件会在系统编译前拷贝至tools/firmware_merger/目录中。

分区表的选择可用menuconfig来配置。

```
(top menu)
    Partition Table  --->
        Partition Table (Two Firmware, Data, User for 8MB Flash)  --->
			( ) Two Firmware, Data, User for 4MB Flash
			(X) Two Firmware, Data, User for 8MB Flash
			( ) Two Firmware, Data, No User for 8MB Flash
			( ) Custom partition table
```

## **2 分区介绍**

### **2.1  Vendor区**

Vendor区是一块可读可写区域，可以在PC端工具和在系统的应用中进行读写，主要用于保存序列号,网卡地址等数据。在工具升级固件和OTA更新固件中都会对这部分数据进行保护。

### **2.2  IDBlock区**

IDBlock区是系统引导区，主要存储引导相关的数据和一级loader代码，系统上电后，芯片内的固化代码会查找这个数据,进行校验和引导。RK2206固件在IDBlock区存放着两份这样的引导数据，分别在64扇区和128扇区。

### **2.3  Firmware1区**

Firmware1分区是用来存放系统固件的区域，系统固件是指打包了可执行程序的代码与数据。系统运行起来后，会一直运行Firmware1分区中的程序与数据，当Firmware1分区损坏或者Firmware2分区通过OTA升级成功后需要Firmware2分区固件恢复到Firmware1分区。

### **2.4 Firmware2**

Firmware2分区是Firmware1固件分区的备份。通过OTA升级总是更新Firmware2固件分区。当Firmware1分区损坏或者OTA升级成功后，系统会从Firmware2分区启动，并恢复Firmware1固件分区。

### **2.5  Data区**

Data分区用来存放系统全局配置信息，wifi配置信息等数据。系统运行后会从该分区中读取全局配置信息及Wi-Fi配置信息等。

### **2.6  Userdata区**

Userdata分区是用来存放一些用户数据或者文件，比如提示音，歌曲文件等。该分区一定是最后一个分区。

### **2.7  其他分区**

用户可以根据使用场景增加其他一些分区，这些分区需要放在Data分区与Userdata分区之间。例如，如果使用带屏显示的使用场景，需要添加一些字库、菜单、UI等资源数据，可以在Data分区之后，Userdata分区前增加一些资源分区。
