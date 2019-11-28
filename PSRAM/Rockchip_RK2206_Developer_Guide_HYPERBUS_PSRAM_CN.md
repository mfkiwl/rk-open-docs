# Rockchip RK2206 Developer Guide HYPERBUS PSRAM

文件标识：RK-KF-YF-051

发布版本：V1.0.0

日       期：2019-11-28

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

本文主要描述了RK2206 HYPERBUS PSRAM的原理和使用方法。

**产品版本**

| **芯片名称** | **内核版本**    |
| ------------ | --------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 何智欢   | 2019-11-28   | 初始版本     |

**目录**

---

[TOC]

---

## **1 HYPERBUS PSRAM**

### **1.1 原理**

HYPERBUS 接口属于Low Signal Count Spec的一种，支持挂载FLASH和PSRAM。此文档只介绍挂载PSRAM的情况。

PSRAM、Pseudo SRAM、假静态随机存储器，具有类似SRAM的稳定接口，内部存储是DRAM架构（刷新由内部产生）。HYPER PSRAM（即HYPERBUS PSRAM）接口位宽为8bit，Double-Data Rate（DDR）数据传输。

### **1.2 HYPER PSRAM作为内存使用**

如果一些模块需要使用大容量内存作为缓存buffer，可以考虑使用HYPER PSRAM。

#### **1.2.1 配置**

需要打开CONFIG_DRIVER_HYPERPSRAM宏。

```c
    BSP Driver  --->
        [*] Enable HYPERBUS psram
```

#### **1.2.2 代码和API**

- src/driver/hyperbus/HyperPsramDevice.c

- include/driver/HyperPsramDevice.h

```c
/* 初始化HYPERPSRAM */
INIT API rk_err_t HYPERPSRAM_Init(void);
/* 修改HYPERPSRAM Init 参数，在初始化完成后，以及每次HYPERPSRAM频率变化后调用 */
COMMON API rk_err_t HYPERPSRAM_ModifyInit(void);
```

#### **1.2.3 使用范例**

RK2206 使用示例

```c
#include "driver/HyperPsramDevice.h"

HYPERPSRAM_Init();
HYPERPSRAM_ModifyInit();

```

### **1.3 在HYPER PSRAM上运行RKOS**

可以使用HYPER PSRAM作为内存，跑RKOS代码。

#### **1.3.1 配置**

选择链接脚本的名字为PSRAM

```c
    Compiler Options  --->
        Linker Section Features  --->
        	Linker Script Name (SRAM)  --->
        		( ) SRAM
				(X) PSRAM
				( ) XIP
```

打开CONFIG_DRIVER_HYPERPSRAM宏。

```c
    BSP Driver  --->
        [*] Enable HYPERBUS psram
```

#### **1.3.2 代码和API**

- src/bsp/RK2206/common/chip.c

- src/driver/hyperbus/HyperPsramDevice.c
- include/driver/HyperPsramDevice.h

```c
/* 初始化HYPERPSRAM */
INIT API rk_err_t HYPERPSRAM_Init(void);
/* 修改HYPERPSRAM Init 参数，在初始化完成后，以及每次HYPERPSRAM频率变化后调用 */
COMMON API rk_err_t HYPERPSRAM_ModifyInit(void);

```

#### **1.3.3 使用范例**

以上操作即可。

### **1.4 shell调试命令**

打开COMPONENTS_SHELL_PM_TEST宏：

```c
Components Config  --->
    Command shell  --->
        [*]     Enable HYPERPSRAM shell command
```

命令：

```c
RK2206>hyperpsram

        help            <command>    get help informastion
        memtest         memtest hyperpsram
        performtest     performtest hyperpsram
        q               <command>    exit package
```

```c
RK2206>hyperpsram.memtest 0x38300000 0x100000 0

[A.14.00][000019.557480]Loop 1:
[A.14.00][000019.564805]  Random Value        : ok
[A.14.00][000019.598206]  Compare XOR         : ok
[A.14.00][000019.610904]  Compare SUB         : ok
[A.14.00][000019.621590]  Compare MUL         : ok
[A.14.00][000019.631275]  Compare DIV         : ok
[A.14.00][000019.640299]  Compare OR          : ok
[A.14.00][000019.658005]  Compare AND         : ok
[A.14.00][000019.674690]  Sequential Increment: ok
[A.14.00][000019.688740]  Solid Bits          : ok
[A.14.00][000020.357231]  Block Sequential    : ok
[A.14.00][000022.994510]  Checkerboard        : ok
[A.14.00][000023.652442]  Bit Spread          : ok
[A.14.00][000024.324932]  Bit Flip            : ok
[A.14.00][000026.956999]  Walking Ones        : ok
[A.14.00][000027.623273]  Walking Zeroes      : ok
[A.14.00][000028.294573]  8-bit Writes        : ok
[A.14.00][000028.346596]  16-bit Writes       : ok
```
