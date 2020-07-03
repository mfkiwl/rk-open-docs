# Rockchip FreeRTOS SPIFLASH

文件标识：RK-KF-YF-052

发布版本：V1.0.2

日期：2020-02-21

文件密级：□绝密   □秘密   □内部资料   ■公开

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
| V1.0.1 | 林鼎强 | 2019-12-12 | 添加 SPI Flash 框架章节 |
| V1.0.2 | 林鼎强 | 2020-02-21 | 调整标题层级 |

**目录**

---

[TOC]

---

## 简介

### 支持器件

RK MCU 产品使用的 SPI flash 仅为 SPI Nor，不支持 SPI Nand。

SPI Nor 具有封装小、读速率相较其他小容量非易失存储更快、引脚少和协议简单等优势，市面通用的 SPI Nor 支持1线、2线和4线传输，且 SPI Nor 具有不易位翻转、byte 寻址和读操作无等待延时（发送 cmd 和 address 下一拍就传输数据）的特点，所以支持使用 XIP技术 （Excute In Place）。

RK RTOS SPI flash 框架提供通用的 SPI Nor 接口和自动化的 XIP 方案。

### 主控控制器

RK 平台 SPI Flash 可选用的控制器包括 FSPI 和 SPI 两种方案。

FSPI   (Flexible Serial Peripheral Interface)  是一个灵活的串行传输控制器，有以下主要特性：

- 支持 SPI Nor、SPI Nand、SPI 协议的 Psram 和 SRAM
- 支持 SPI Nor 1线、2线和4线传输
- XIP 技术
- DMA 传输

SPI （ Serial Peripheral Interface ）为通用的 串行传输控制器，可以支持外挂 SPI Nor、SPI Nand，RK RTOS 平台目前仅支持 SPI Nor 的实现。

### XIP 技术

XIP（eXecute In Place），即芯片内执行，指 CPU 直接通过映射地址的 memory 空间取指运行，即应用程序可以直接在 flash 闪存内运行，不必再把代码读到系统 RAM 中，所以片内执行代码的运行地址为相应的映射地址。由于 SPI Nor XIP 仅支持读，所以只能将代码段和只读信息置于 SPI Nor 中。

FSPI 除支持 CPU XIP 访问 SPI flash，还支持如DSP 等其他模块以相近方式获取 flash 数据，如同访问一片“只读的 sram”空间，详细 FSPI 信息参考 TRM 中 FSPI 章节。

### 驱动框架

考虑到要适配 FSPI 和 SPI 两种控制器，所以抽象出控制器层，从而将整个驱动框架分为三个层次 ：

- RTOS Driver 层，完成以下逻辑:
  - RTOS 设备框架注册
  - 注册控制器及操作接口到 HAL_SNOR 协议层
  - 封装读写擦除接口给用户
- 基于 SPI Nor 传输协议的 HAL_SNOR 协议层
- 控制器层

![SPIMemory_Layer](Rockchip_Developer_Guide_RTOS_SPIFLASH_CN/SPIFLASH_Layer.png)

**基于 FSPI 控制器的 FreeRTOS 实现**：

- OS 驱动层：SpiFlashDev.c 实现:
  - 基于 FSPI HAL层读写接口封装 SPI_Xfer，并注册 FSPI host 及 SPI_Xfer 至 HAL_SNOR 协议层
  - 封装 HAL_SNOR 协议层提供的读写擦除接口
  - 注册 OS 设备驱动
- 协议层：HAL 开发包中的 hal_snor.c 实现 SPI Nor flash 的协议层
- 控制器层：HAL 开发包中的 hal_fspi.c 实现 FSPI 控制器驱动代码

**基于 SPI 控制器的 FreeRTOS 实现**：

- OS 驱动层：SpiFlashDev.c 实现:
  - 基于 SPI OS driver 读写接口封装 SPI_Xfer，并注册 SPI host 和 SPI_Xfer 至 HAL_SNOR 协议层；
  - 封装 HAL_SNOR 协议层提供的读写擦除接口
  - 注册 OS 设备驱动
- 协议层：HAL 开发包中的 hal_snor.c 实现 SPI Nor flash 的协议层
- 控制器层：HAL 开发包中的 hal_spi.c 实现 SPI 控制器 low layer 驱动代码，SpiDevice.c 代码实现 RTOS SPI DRIVER 的设备注册和接口封装

注意：

1. 以上实现一一对应附图，可结合阅读
2. 由于 RK SPI DMA 传输相关代码在 OS Driver 层，且 SPI 控制器除了应用在 SPI Nor 上，还支持较多其他器件，存在硬件资源边界保护，所以在 SPI Flash 框架中的 SPI 控制器不应直接套接 HAL 层 hal_spi.c 驱动，而应使用 OS Driver 中的 SPI 接口。

## 配置

SPI Flash 驱动框架所有配置都能通过 Kconfig 进行灵活调整，如 1.4 章节所讲，SPI flash 完整的驱动框架由三个抽象层构成，相应的配置也分为三个层次：

**RTOS Driver 驱动层配置：**

```c
    BSP Driver  --->
        [*] Enable SPIFASLH  --->
        (80000000) Reset the speed of SPI Nor flash in H
```

**HAL_SNOR 协议层套接控制器配置：**

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

**控制器驱动配置**

FSPI 控制器配置：

```c
[*] Use HAL FSPI Module
	[*]     Enable FSPI XIP
```

SPI 控制器配置：

请参考《Rockchip_Developer_Guide_Linux_SPI_CN.md》文档。

### 代码和接口

#### 代码

"src/driver/spiflash/SpiFlashDev.c"
"include/driver/SpiFlashDev.h"

#### 函数接口

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

- 支持 block size 对齐的读写接口，例如 FAT fs；
- 支持最小 byte 为单位的读写接口和 block size 的擦除接口，例如 spifs、littlefs。

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

## XIP 实现方案须知

前面已经介绍 SPI Nor 支持 XIP 功能，如果选用 FSPI 主控实现的 SPI Nor 方案，会自动开启 XIP 功能，以下介绍产品应用中涉及到 XIP 的一些须知。

### 添加 XIP 支持

当选用 FSPI 实现的 SPI Flash 方案，并按照 1.2 章节中关于 FSPI 配置方法去配置，SPI Flash 将默认配置使用 XIP 功能，如要关闭该功能，应则关闭配置 “Enable FSPI XIP”

### XIP 使用过程的开关

RK SPI Flash 框架会在需求的场景自动开关 XIP 功能，客户无需调用开关接口，详细如下:

**XIP 开**

由于 SPI Nor 擦除/写耗时长的特点， SPI Nor 不支持 XIP 下的擦除/写，所以当 SPI Nor flash 有擦除和写请求的时候，如文件系统写请求， 软件会调用 XIP suspend 接口切换 SPI nor 主控 FSPI 到 normal mode，期间将无法使用 XIP 功能，完整的 suspend XIP 切换流程如下：

1. 通知所有受 XIP disable 影响的 master 模块挂起 XIP 操作
2. 关闭全局中断，避免产生中断导致 CPU 执行放在 SPI Nor 中的 XIP 的代码
3. 关闭 XIP

**XIP 关**

当 SPI Nor flash 擦除/写完成且 FSPI idle 后 SPI Flash 驱动将重新恢复 XIP 功能，也就是在没有擦除写操作的情况下， FSPI 一直将使能 XIP 功能，完整的 XIP resume 流程如下：

1. 开启XIP
2. 使能全局终端
3. 通知所有 XIP suspend 设备恢复使用 XIP

以上所述操作入口如下：

```c
static void SpiFlashDev_xipSuspend(void)
static void SpiFlashDev_xipResume(void)
```

**总结**

- 如果 SPI Nor 颗粒由 FSPI 主控驱动，默认使能 XIP 功能
- SPI Nor 主控 FSPI 在 idle 状态默认开启 XIP 功能，此时支持 XIP 通路的设备都可访问 XIP memory 映射地址获取 SPI Nor 上的数据
- SPI Nor 主控 FSPI 在进行擦除和写行为时关闭 XIP 功能
- SPI Nor 主控 FSPI 开关 XIP 过程，需通知相应设备停止/恢复 XIP 访问，具体按照上文 “XIP 关” 所述操作
- XIP 关，同时会关闭全局中断

## 函数接口调用范例

参考 shell_spiflash.c。

## shell使用范例

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

## 常见问题

- **如何判断 SPI flash 已经挂载成功？**

  通过 shell 窗口中查看是否有 spiflash 设备节点。

- **Init adapte error ret= -19 是什么报错？**

  “Init adapte error ret= -19” 为存储驱动的初始化函数 snor_adapt 的返回结果打印，相应的错误码解释如下：

  a. -1: SPI Nor ID 为 0xff，可能为 SPI Nor 没有焊接良好，请检查一下电路和信号；

  b. -19: 该颗粒不在支持列表，请联系 RK 工程师，添加相应颗粒支持；

  c. -22: SPI 控制器没有找到。

- **常开 XIP 功能是否有多余功耗？**

  FSPI 有 time out 机制，主控 idle 一定时长后，自动释放 cs，SPI Nor 将进入 idle 的低功耗状态，所以不会有较大功耗差异。

- **如果多个 master 同时通过 XIP 访问 SPI Nor，是否会有冲突？**

  多个 master 同时访问 XIP，总线会做仲裁，串行完成传输，请求会挂在总线上。

- **对于频繁读写文件系统的产品，是否应该使用 XIP 功能？**

  对于频繁写文件系统的产品，建议将代码段至于 sram 或 psram 中，然后关闭 FSPI XIP 功能，否则将影响 RTOS 系统实时性，同样，使用 XIP 运行 code 段的方案，应减少 SPI Nor 的擦除和写。

- **使能 XIP 功能后，文件系统读，是否关 XIP ？**

  使能 XIP 功能后，文件系统读，驱动实现直接通过 XIP 访问，所以不关 XIP。

- **如果 SPI Nor 上没有分区表，还能挂载分区吗？**

  必须固化 flash 分区到 flash 前端，RK 目前 SPI Nor flash 存储驱动仅做固化在 flash 中的分区解析挂载方案。
