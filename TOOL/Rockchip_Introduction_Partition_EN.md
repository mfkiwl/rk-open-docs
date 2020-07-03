# **Rockchip Introduction Partition**

ID:  RK-SM-YF-016

Release Version: V1.5.0

Release Date: 2020-06-16

Security Level: □Top-Secret   □Secret   □Internal   ■Public

---

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. FUZHOU ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

**All rights reserved. ©2019. Fuzhou Rockchip Electronics Co., Ltd.**

Beyond the scope of fair use, neither any entity nor individual shall extract, copy, or distribute this document in any form in whole or in part without the written approval of Rockchip.

Fuzhou Rockchip Electronics Co., Ltd.

No.18 Building, A District, No.89, software Boulevard Fuzhou, Fujian,PRC

Website:     [www.rock-chips.com](http://www.rock-chips.com)

Customer service Tel:  +86-4007-700-590

Customer service Fax:  +86-591-83951833

Customer service e-Mail:  [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**Preface**

**Overview**

The Rockchip Android system platform uses a parameter file to configure some system parameters, such as firmware version, model name, memory partition information.

The Parameter file is a very important system configuration file. It is best to modify the configuration function after understand it completely,which avoid the system does not work properly due to incorrect configuration of the parameter file.

The size of the parameter file is limited to 64 KB.

**Chipset Version**

| **Chipset** | **SDK Version** |
| -------- | -------- |
| All chipset | All |

**Intended Audience**

This document (this guide) is mainly intended for:

Technical support engineers
Software development engineers

---

**Revision History**

| **Version** | **Author** | **Date** | **Change Description** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0 | Yifeng.Zhao | 2011-04-11 | parameter instruction |
| V1.1.0 | Yifeng.Zhao | 2011-09-05 | Complete functional documentation |
| V1.2.0 | Yifeng.Zhao | 2012-10-16 | Add RK30 and RK292X configurations |
| V1.3.0 | Yifeng.Zhao | 2013-04-15 | Add GPIO configurations |
| V1.4.0 | Yifeng.Zhao | 2018-01-23 | Add GPT configurations |
| V1.4.1 | Yifeng.Zhao | 2020-02-21 | Modify style |
| V1.5.0 | Jason.Zhu | 2020-06-16 | Add partition definition specification |

---

[TOC]

---

## Parameter Preview

The parameter file is mainly used to define partition table. It can support two partition formats: GPT partition and legacy CMDLINE partition. There will be some differences in the contents of parameter files for different projects and different platforms.

The document use the parameter file of RK3326 to explanation.

The parameter file for GPT：

```
FIRMWARE_VER:9.0
MACHINE_MODEL:RK3326
MACHINE_ID:007
MANUFACTURER: RK3326
MAGIC: 0x5041524B
ATAG: 0x00200800
MACHINE: 3326
CHECK_MASK: 0x80
PWR_HLD: 0,0,A,0,1
TYPE: GPT
CMDLINE:mtdparts=rk29xxnand:0x00002000@0x00004000(uboot),0x00002000@0x00006000(trust),0x00002000@0x00008000(misc),0x00002000@0x0000a000(dtb),0x00002000@0x0000c000(dtbo),0x00000800@0x0000e000(vbmeta),0x00010000@0x0000e800(boot),0x00030000@0x0001e800(recovery),0x00028000@0x0004e800(backup),0x00002000@0x00076800(security),0x00070000@0x00078800(cache),0x002d0000@0x000e8800(system),0x00008000@0x003b8800(metadata),0x00070000@0x003c0800(vendor),0x00020000@0x00430800(oem),0x00000400@0x00450800(frp),-@0x00450c00(userdata:grow)
uuid:system=af01642c-9b84-11e8-9b2a-234eb5e198a0
```

The parameter file for CMDLINE：

```
FIRMWARE_VER:9.0
MACHINE_MODEL:RK3326
MACHINE_ID:007
MANUFACTURER: RK3326
MAGIC: 0x5041524B
ATAG: 0x00200800
MACHINE: 3326
CHECK_MASK: 0x80
PWR_HLD: 0,0,A,0,1
CMDLINE:console=ttyFIQ0 androidboot.console=ttyFIQ0 initrd=0x62000000,0x00800000 mtdparts=rk29xxnand:0x00002000@0x00004000(uboot),0x00002000@0x00006000(trust),0x00002000@0x00008000(misc),0x00002000@0x0000a000(dtb),0x00002000@0x0000c000(dtbo),0x00000800@0x0000e000(vbmeta),0x00010000@0x0000e800(boot),0x00030000@0x0001e800(recovery),0x00028000@0x0004e800(backup),0x00002000@0x00076800(security),0x00070000@0x00078800(cache),0x002d0000@0x000e8800(system),0x00008000@0x003b8800(metadata),0x00070000@0x003c0800(vendor),0x00020000@0x00430800(oem),0x00000400@0x00450800(frp),-@0x00450c00(userdata)
```

The main differences between GPT partition and legacy CMDLINE partition are：

- Defined **"TYPE: GPT"**
- Add "grow" flag in Last partition, For example: **"userdata:grow"**
- Define UUID for system or rootfs, For example: **"uuid:system=af01642c-9b84-11e8-9b2a-234eb5e198a0"**
- Parameter files will not be burned into NVM (EMMC, NAND, etc.), and only mtdparts partition definitions and UUIDs will be used. Other informations are only defined for compatibility with upgrade tools.

## Details Information

### FIRMWARE_VER:9.0

| Item        | FIRMWARE_VER                                                 |
| ----------- | ------------------------------------------------------------ |
| Type        | Decimal number，format: X.X                                  |
| value       | 0 - 255                                                      |
| description | The firmware version will be used as packaging updata.img, and the upgrade tool will identify the firmware version based on this code. |

### MACHINE_MODEL:RK3326

| Item        | MACHINE_MODEL                                                |
| ----------- | ------------------------------------------------------------ |
| Type        | Strings                                                      |
| Length(max) | 255                                                          |
| description | Machine model, use for package updata.img, you can modify it for display  in upgrade tool according to different projects, which also determine whether the firmware matches correctly device as upgrading firmware in recovery. |

### MACHINE_ID:007

| Item        | MACHINE_ID                                                   |
| ----------- | ------------------------------------------------------------ |
| Type        | Strings                                                      |
| Length(max) | 255                                                          |
| description | The Product development ID, which consists of characters and numbers, use for package updata.img. There are different IDs in different projects,  which can be used to identify machine models. Also, determine if the firmware matches correctly  device as upgrading firmware in recovery. |

### MANUFACTURER:rk3326

| Item        | MANUFACTURER                                                 |
| ----------- | ------------------------------------------------------------ |
| Type        | Strings                                                      |
| Length(max) | 255                                                          |
| description | Vendor information, which use to package updata.img, can be modified by yourself for the upgrade tool display. |

### MAGIC:0x5041524B

| Item        | MAGIC                                                        |
| ----------- | ------------------------------------------------------------ |
| Type        | Hexadecimal number                                           |
| Value       | 0x5041524B(fix)                                              |
| description | Magic number can not be modified. Some new APs use DTS instead of magic number. But for compatibility, please do not delete or modify. |

### ATAG:0x60000800

| Item        | ATAG                                                         |
| ----------- | ------------------------------------------------------------ |
| Type        | Hexadecimal number                                           |
| value       | 32 bits ddr address                                          |
| description | ATAG data stroage address. Some new APs use DTS instead of this. But for compatibility, please do not delete or modify. |

### MACHINE:3226

| Item        | MACHINE                                                      |
| ----------- | ------------------------------------------------------------ |
| Type        | Strings                                                      |
| Length(max) | 255                                                          |
| description | This code uses to Kernel identification and match to the kernel, which can not be modified. |

The following table lists the values for several Chipset:

| Chipset | MACHINE |
| ------- | ------- |
| RK29xx  | 2929    |
| RK292X  | 2928    |
| RK3066  | 3066    |
| RK3126C | 3126c   |
| RK3326  | 3326    |
| RK3399  | 3399    |
| RK3308  | 3308    |

### CHECK_MASK:0x80

| Item        | MACHINE_MODEL                      |
| ----------- | ---------------------------------- |
| Type        | Hexadecimal number                 |
| Length(max) | 0x80(fix)                          |
| description | Reserved, please do not modify it. |

### TYPE:GPT

This code specify the partition defined in the file CMDLINE for the upgrade Tool to create GPT and write to NVM（NAND，EMMC，etc.） storage devices instead of the parameter file.

### CMDLINE：

"console=ttyFIQ0 androidboot.console=ttyFIQ0"，which is serial port definition。

initrd=0x62000000,0x00800000，The first parameter is the location where RAMDISK is loaded into SDRAM, the second parameter is the size of RAMDISK.

The definition of androidboot.xxx is used as android started. There are some platforms define in the dts of the kernel. This part of the definition is generally no need to modified and remain the value of the SDK default.

The partition preview:

```c
mtdparts=rk29xxnand:0x00002000@0x00002000(uboot),0x00002000@0x00004000(trust),0x00002000@0x00006000(misc),
0x00008000@0x00008000(resource),0x00010000@0x00010000(kernel),0x00010000@0x00020000(boot),0x00020000@0x00030000(recovery),
0x00038000@0x00050000(backup),0x00002000@0x00088000(security),0x00100000@0x0008a000(cache),0x00400000@0x0018a000(system),
0x00008000@0x0058a000(metadata),0x00080000@0x00592000(vendor),0x00080000@0x00612000(oem),0x00000400@0x00692000(frp),-@0x00692400(userdata)
```

Partition definition instruction:

1. For compatibility , all the Rockchip SOCs are identified by rk29xxnand.

2. Single partition description:

For example: 0x00002000@0x00008000(boot), the value before the @ symbol is the partition size, the value after the @ symbol is the starting position of the partition, and the characters in the brackets are the names of the partitions. The unit of all values is sector, and one sector is 512 bytes. In the above example, the start position of the boot partition is 0x8000 sectors, and the size is 0x2000 sectors (4MB).

3. For good performance, each partition start-address requires 32KB (64 sectors) alignment, and the size also requires an integer multiple of 32KB.

4. If you use the image in the format of sparse , the partition will be erased during the upgrade. For better compatibility, the corresponding partition is preferably aligned by 4MB, and the size is also configured as an integer multiple of 4MB.

5. Using GPT partition, the address defined in the parameter is the real logical address (LBA). For example, U-Boot is defined at 0x4000, as it loader into EMMC and NAND, the logical address is also 0x4000.

| Name    | Parameter Address | EMMC Logic Address | NAND Logic Address | Size     |
| ------- | ----------------- | ------------------ | ------------------ | -------- |
| GPT     | --                | 0                  | 0                  | 32KB     |
| LOADER  | --                | 0x40               | 0x40               | 4MB-32KB |
| Reserve | --                | 0x2000             | 0x2000             | 4MB      |
| UBOOT   | 0x4000            | 0x4000             | 0x4000             | 4MB      |
| TRUST   | 0x6000            | 0x6000             | 0x6000             | 4MB      |

The last partition needs to specify parameter "grow" , the tool will allocate the remaining space to the last partition.

6. Using the legacy cmdline partition, if it is EMMC , the space of 0-4MB is reserved for the loader. The partition defined in the parameter needs to add 4MB. For example, U-Boot is defined at 0x2000, as actually write into EMMC, the logical address to be the same with GPT partition, that is 0x4000. If it is NAND , in order to be compatible with the legacy, all addresses are real logical addresses. For example, U-Boot is defined at 0x2000, the logical address is also 0x2000, which is different from GPT.

| Name      | Parameter Address | EMMC Logic Address | NAND Logic Address | Size     |
| --------- | ----------------- | ------------------ | ------------------ | -------- |
| Reserve   | --                | 0                  | 0                  | 32KB     |
| LOADER    | --                | 0x40               | 0x40               | 4MB-32KB |
| parameter | --                | 0x2000             | 0x0                | 4MB      |
| UBOOT     | 0x2000            | 0x4000             | 0x2000             | 4MB      |
| TRUST     | 0x4000            | 0x6000             | 0x4000             | 4MB      |

Note:  Using NAND FLASH, The address 0x40 may write with the loader image，its share 0-4MB space with the parameter, and the valid data will not be overwritten.

## Partition Definition Specification

1. All partitions which are written by bootrom, pre-loader, uboot and trust must be palced before recovery partition.
2. Any new partitions added by the customer,  which are written by the pre-loader, uboot and trust, should be placed before the recovery partition;
3. The misc, vbmeta and security partitions which is used by rockchip should be placed before the recovery partition.