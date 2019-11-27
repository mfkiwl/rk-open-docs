# RKOS Link Script 开发指南

文件标识：RK-KF-YF-048

发布版本：V1.0.0

日期：2019-11-27

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

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文主要描述了RKOS链接脚本的开发和使用方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0     | 王明成 | 2019-11-27 | 初始版本     |
**目录**

---
[TOC]
---

## 1 简介

目前，RKOS的Link Script就要针对GCC编译器设计，支持预编译，宏定义，多内存分布等。

## 2 原理

RKOS Link Script以.S为扩展名的脚本组织GCC LD规则，同时可包含多个宏定义的H文件，这些H文件里主要将多种公用的LD规则抽象为宏定义，同时在Makefile中加入了预编译处理。其原理同Linux内核链接脚本。

RKOS Link Script整体框架在与GCC LD脚本保持一致的基础上，引入了多内存方案的支持，即不同的代码段或数据段会收入不同的内存段中，无论哪种内存方案，其Link Script文件都将包含如下几个Sections：

- .xip.text
- .psram.text
- .psram.data
- .psram.bss
- .sram.text
- .sram.data
- .sram.bss
- STACK_SECTION
- HEAP_SECTION

其中，".*.text"定义对应memory的text段，data，bss同理。这些段的VMA根据实际方案配置，LMA必须以头接尾的形式顺序向ROM存储地址增长；这些段虽然必须定义在LD脚本中，但其内容可以留空，必须定义的原因是可统一生成C代码中所要使用的变量，提高代码的兼容性和可维护性。STACK_SECTION定义stack段，HEAP_SECTION定义heap段。

每个Section中的特殊的规则以如下格式的宏定义在Linker_spcific.h文件中，RKOS Link Script支持以文件的形式（如"*.o", "*.a"）和特殊标签的形式收入到特殊段中。

- XIP_TEXT_SECTION
- PSRAM_TEXT_SECTION
- ... ...

系统默认Section的规则则以如下格式的宏定义在linker_common.h文件中：

- TEXT_SECTION
- DATA_SECTION
- STACK_SECTION
- HEAP_SECTION

## 3 配置

进入RKOS工程编译目录，执行make menuconfig命令打开Link Script的配置项，以选择当前工程采用哪种存储做为主memory，以RK2206 SoC为例，支持SRAM，PSRAM和XIP三种方案。

```c
    Compiler Options  --->
        Linker Section Features  --->
            Linker Script Name (SRAM)  --->
                (X) SRAM
                ( ) PSRAM
                ( ) XIP
```

## 4 代码实现

如[第2章节](#2 原理)所述，Linker Script的代码实现分为.S脚本和.H文件两部分，如下分别介绍其实现：

app/linker_script/gcc/RK2206/sram.ld.S

```c
#include <linker/linker_common.h>
#include <linker/linker_specific.h>

MEMORY
{
    /* 定义各个可用内存的ORIGIN和LENGTH属性*/
}

/* VMA, LMA等常量的定义 */
SRAM_CODE_BASE      = 0x04000000;
PSRAM_CODE_BASE     = 0x18000000;
// ...
PROVIDE(xMainStackSize  = 4K);
PROVIDE(xHeapSize       = 16K);
// ...

/* LD时需要链接的符号定义 */
EXTERN(_write _close _fstat _isatty _lseek _read)
// ...

/* 指定链接的入口函数或地址 */
ENTRY(Main)

/* 内存分布定义 */
SECTIONS
{
    /* text, data, bss段定义*/
    .xip.text :
    {
        XIP_TEXT_SECTION
    }

    .psram.text (PSRAM_CODE_BASE) : AT (LOADADDR(.xip.text) + SIZEOF(.xip.text))
    {
        PSRAM_TEXT_SECTION
    }

    // ...

    .sram.text (SRAM_CODE_BASE) : AT (LOADADDR(.psram.data) + SIZEOF(.psram.data))
    {
        SRAM_TEXT_SECTION
        TEXT_SECTION
    }
    // ...

    /* stack, heap段定义*/
    ucIdleStack = ADDR(.sram.bss) + SIZEOF(.sram.bss);
    IDLE_STACK_SECTION(ucIdleStack, xIdleStackSize, SRAM)
    // ...
}

```

include/linker/linker_common.h

```c
/* 包含config头文件 */
#include <sdkconfig.h>

/* VMA, LMA生成宏定义 */
#define PROVIDE_BASE(BASE, OFFSET) \
    HIDDEN(BOOT_VMA_BASE = ALIGN((BASE) + (OFFSET), 4)); \
    HIDDEN(BOOT_LMA_BASE = ALIGN((BASE) + (OFFSET), 4));
// ...

/* stack, heap通用段定义 */
#define STACK_SECTION(vma, ssize, mem)                          \
    .stack (vma) (COPY) :                                       \
    {                                                           \
        . = ALIGN(8);                                           \
        . += ssize;                                             \
        . = ALIGN(8);                                           \
        PROVIDE(__StackTop = .);                                \
    } > ##mem                                                   \
    PROVIDE(Image$$stack$$ZI$$Base = ADDR(.stack));             \
    PROVIDE(Image$$stack$$ZI$$Length = SIZEOF(.stack));
// ...

/* 默认段定义 */
#define TEXT_SECTION                                            \
    KEEP(*(.bcore_vector))                                      \
    . = ALIGN(4);                                               \
    __text_start__ = .;                                         \
    *(.text*)                                                   \
    *(.got*)                                                    \
// ...

/* 导出变量定义 */
#define DEFINE_PROVIDE_CODE_SECTION(name)                       \
  PROVIDE(Load$$##name##$$Base = LOADADDR(.##name##.text));     \
  PROVIDE(Image$$##name##$$Base = ADDR(.##name##.text));        \
  PROVIDE(Image$$##name##$$Length = SIZEOF(.##name##.text));
// ...
```

include/linker/linker_specific.h

```c
/* 特殊段定义 */
#define XIP_TEXT_SECTION                                        \
    . = ALIGN(4);                                               \
    *(.xip_code)

#define PSRAM_TEXT_SECTION                                      \
    . = ALIGN(4);                                               \
    *(.psram_code)
// ...
```
