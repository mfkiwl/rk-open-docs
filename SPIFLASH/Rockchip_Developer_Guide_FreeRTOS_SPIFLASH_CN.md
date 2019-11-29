# Rockchip FreeRTOS SPIFLASH

文件标识：RK-KF-YF-052

发布版本：V1.0.0

日期：2019-12-03

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

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文主要描述了 ROCKCHIP FreeRTOS SPI Flash 的原理和使用方法。

**产品版本**

| **芯片名称** | **内核版本**    |
| ------------ | --------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 林鼎强 | 2019-12-03 | 初始版本     |

**目录**

---
[TOC]
---

## 1 SPIFLASH

### 1 简介

#### 1.1 SPI Nor

RK MCU 产品使用的 SPI flash 仅为 SPI Nor，不支持 SPI Nand。

SPI Nor 具有封装小、读速率相较其他小容量非易失存储更快、引脚少和协议简单等优势，市面通用的 SPI Nor 支持1线、2线和4线传输，且 SPI Nor 具有不易位翻转、byte 寻址和读操作无等待延时（发送 cmd 和 address 下一拍就传输数据）的特点，所以支持使用 XIP技术 （Excute In Place）。

RK RTOS SPI flash 框架提供通用的 SPI Nor 接口和自动化的 XIP 方案。

#### 1.2 FSPI 和 SPI 控制器

RK 平台 SPI Flash 可选用的控制器包括 FSPI 和 SPI 两种方案。

FSPI   (Flexible Serial Peripheral Interface)  是一个灵活的串行传输控制器，主要支持 SPI Nor、SPI Nand、SPI 协议的 Psram 和 SRAM，支持 SPI Nor 1线、2线和4线传输和 XIP 实现。RK RTOS 平台目前仅实现 SPI Nor 和 Psram 的实现。

SPI （ Serial Peripheral Interface ）为通用的 串行传输控制器，可以支持外挂 SPI Nor、SPI Nand，RK RTOS 平台目前仅支持 SPI Nor 的实现。

#### 1.3 XIP 技术

XIP（eXecute In Place），即芯片内执行，指 CPU 直接通过映射地址的 memory 空间取指运行，即应用程序可以直接在 flash 闪存内运行，不必再把代码读到系统 RAM 中，所以片内执行代码的运行地址为相应的映射地址。由于 SPI Nor XIP 仅支持读，所以只能将代码段和只读信息置于 SPI Nor 中。

FSPI 除支持 CPU XIP 访问 SPI flash，还支持如DSP 等其他模块以相近方式获取 flash 数据，如同访问一片“只读的 sram”空间，详细 FSPI 信息参考 TRM 中 FSPI 章节。

### 2 配置

SPI flash 完整的驱动由以下三个抽象层构成：

* RTOS Driver 驱动层，完成以下逻辑：
  * RTOS 设备注册
  * HAL_SNOR 协议层套接控制器 HAL 驱动 实现
  * 提供 HAL_SNOR 读写擦除接口的封装的 RTOS 驱动接口
* HAL_SNOR 协议层
* 控制器 HAL 驱动

![SPIFLASH_Layer](Rockchip_Developer_Guide_FreeRTOS_SPIFLASH_CN/SPIFLASH_Layer.png)

**RTOS Driver 驱动层配置：**

```c
    BSP Driver  --->
        [*] Enable SPIFASLH  --->
        (80000000) Reset the speed of SPI Nor flash in H
```

**HAL_SNOR 协议层及控制器 HAL 驱动配置：**

FSPI 控制器方案：

```c
	HAL Options	--->
        -*- Use HAL SNOR Module
        	Choose SPI Nor Flash Adapter (Attach FSPI controller to SNOR)  --->
        		(X) Attach FSPI controller to SNOR
        		( ) Attach FSPI controller to SNOR
```

SPI 控制器方案：

```c
	HAL Options	--->
        -*- Use HAL SNOR Module
        	Choose SPI Nor Flash Adapter (Attach SPI controller to SNOR)  --->
        		( ) Attach FSPI controller to SNOR
        		(X) Attach SPI controller to SNOR
        		(0)     the id of the SPI device which is used as SPIFLASH adapter (NEW)
```

### 3 代码和接口

#### 3.1 代码

"src/driver/spiflash/SpiFlashDev.c"
"include/driver/SpiFlashDev.h"

#### 3.2 函数接口

**创建设备接口**

```c
HDC SpiFlashDev_Create(uint8 DevID, void *arg);
rk_err_t SpiFlashDev_Delete(uint8 DevID, void *arg);
```

其中，arg 参数暂无实际意义，目前仅作为接口预留，可不传递。

**获取SPI Flash 设备信息**

由于部分文件系统需要获取 SPI Nor 的信息，所以 SPI Flash 驱动参考 MTD 框架做法，将 SPI Flash 句柄设定为全局变量，可以通过 dev 转型 struct _SPIFLASH_DEVICE_CLASS 来获取最小擦除块大小、容量信息。

```c
typedef  struct _SPIFLASH_DEVICE_CLASS
{
    DEVICE_CLASS stSpiFlashDevice;
    pSemaphore osSpiFlashOperSem;
    uint32 blockSize;	// 该 SPI Nor flash 最小擦除大小，单位 byte
    uint32 blockStart;	// 默认为 0 地址；
    uint32 blockEnd;	// SPI Nor size, 单位 byte；
} SPIFLASH_DEVICE_CLASS;
```

除了全局句柄，还提供了通用的获取 SPI Nor flash 容量信息的接口，单位为 byte：

```c
rk_err_t SpiFlashDev_GetSize(HDC dev, uint32_t *Size);
```

**数据传输接口**

SPI  Nor 常用的文件系统需求两种数据读写接口。

* 支持 block size 对齐的读写接口，例如 FAT fs；
* 支持最小 byte 为单位的读写接口和 block size 的擦除接口，例如 spifs、littlefs。

由于 SPI Nor flash 容量较小，128KB 的 block 擦除使用效率较差，所以对上 block size 设定为最小擦除单位 —— sector（4KB）。

Block 接口：

对于类似 FAT 的文件系统，需求的 block write 实际上是 overwrite 的实现，所以 RK SPI Flash 提供的 block write 接口内完成了 block write（在 SPI Nor 中实际为 sector） 和 block write 的结合操作。

```c
/* For block write/read, maybe good for FAT fs */
rk_size_t SpiFlashDev_WriteBlk(HDC dev, rk_size_t sec, const uint8_t *data, rk_size_t nSec);
rk_size_t SpiFlashDev_ReadBlk(HDC dev, rk_size_t sec, uint8_t *data, rk_size_t nSec);
```

Byte 接口：

```c
/* For byte write/read/erase, maybe good for small fs */
rk_size_t SpiFlashDev_Write(HDC dev, rk_size_t off, const uint8_t *data, rk_size_t len);
rk_size_t SpiFlashDev_Read(HDC dev, rk_size_t off, uint8_t *data, rk_size_t len);
rk_err_t SpiFlashDev_Erase(HDC dev, rk_size_t off, rk_size_t len);
```

### 4 XIP 实现方案

前面已经介绍 SPI Nor 支持 XIP 功能，而如果选用 FSPI 主控实现的 SPI Nor 方案，会自动开启 XIP 功能，以下介绍产品应用上涉及到 XIP 的一些要求。

**XIP 支持**

当选用 FSPI 实现的 SPI Flash 方案，并按照 1.2 章节中关于 FSPI 配置方法去配置，SPI Flash 将默认开启 XIP 功能。

**XIP 开关**

由于颗粒自身原因， SPI Nor 不支持 XIP 下的擦除/写的，所以当 SPI Nor flash 有擦除和写请求的时候，如文件系统写请求，则 SPI flash 需要切换到 normal mode，期间将无法使用 XIP 功能，完整的 suspend XIP 切换流程如下：

1. 通知所有受 XIP disable 影响的 master 模块挂起 XIP 操作
2. 关闭全局中断，避免产生中断导致 CPU 执行放在 SPI Nor 中的 XIP 的代码
3. 关闭 XIP

当 SPI Nor flash 擦除/写完成且 FSPI idle 后 SPI Flash 驱动将重新恢复 XIP 功能，也就是在没有擦除写操作的情况下， FSPI 一直将使能 XIP 功能，完整的 XIP resume 流程如下：

1. 开启XIP
2. 使能全局终端
3. 通知所有 XIP suspend 设备恢复使用 XIP

以上所述操作入口如下：

```c
static void SpiFlashDev_xipSuspend(void)
static void SpiFlashDev_xipResume(void)
```

### 5 函数接口调用范例

参考 shell_spiflash.c。

### 6 shell使用范例

**创建设备**

```c
spiflash.create <spi devid>   /*例如： spi.create 0 */
```

**数据传输**

数据传输接口对应 1.2 章节中描述的读写接口。

```c
    "readblk",   SpiFlashDevShellReadBlk,  "block read data from spiflash device", "spiflash.read <devID> <from> <size>",
    "writeblk",  SpiFlashDevShellWriteBlk, "block over write data to spiflash device", "spiflash.write <devID> <from> <size> <value>",
    "read",      SpiFlashDevShellRead,     "read data from spiflash device", "spiflash.read <devID> <from> <size>",
    "write",     SpiFlashDevShellWrite,    "write data to spiflash device", "spiflash.write <devID> <from> <size> <value>",
    "erase",     SpiFlashDevShellErase,    "erase spiflash device by sector size", "spiflash.erase <devID> <from> <size>",
```

