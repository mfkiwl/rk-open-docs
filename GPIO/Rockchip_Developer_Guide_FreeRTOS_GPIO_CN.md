# Rockchip GPIO 开发说明

文件标识：RK-KF-YK-056

发布版本：V1.0.0

日期：2019-12-02

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2019 福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园 A 区 18 号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com]

---

**前言**

**概述**

本文提供 GPIO 模块接口使用说明文档，开发者可以根据本文档找到对应接口，详细信息可以直接参考模块实现。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | :--------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 许剑群   | 2019-12-02   | 初始版本     |

**目录**

---

[TOC]

## 1 概述

Rockchip FreeRTOS 的 GPIO 模块，提供用户层接口，控制 IO PAD 的方向以及电平，即配置输入模式，输出高电平模式，输出低电平模式。

有关 IO PAD 上下拉配置，在 PINCTRL 模块实现并说明。

## 2 软件框架

### 2.1 Driver 层驱动文件

驱动层的文件位于`src/driver/gpio/drv_gpio.c`，头文件位于`include/driver/drv_gpio.h`，提供如下接口

```C
int rk_pin_attach_irq(int pin, int mode, void (*hdr)(void *args), void *args);
int rk_pin_detach_irq(int pin);
int rk_pin_irq_enable(int pin, int enabled);
int rk_hw_gpio_init(void);
```

pin 是 GPIO 端口序号，硬件原理图通常标识为 GPIO0_A1_u，u 是端口默认内部弱上拉，d 是端口默认内部弱下拉。

软件上，GPIO 的端口序号是连续的，从 0~31 是 GPIO0，从 32~63 是 GPIO1，一次类推；从 0~7 是 A 端口，8~15 是 B 端口，16~23 是 C 端口，24~31 是 D 端口。

如上 GPIO0_A1_u 的端口序号是 1，即 0×32 + 0×8 + 1 = 1；如 GPIO1_B2_d 的端口序号是 1×32 + 1×8 + 2 = 42。

软件上，可以通过宏定义完成自动计算，`BANK_PIN(b,p)`，b 是 bank number，p 是 pin number。

示例：

`BANK_PIN(0, 1)`是 GPIO0_A1

`BANK_PIN(1, 10)`是 GPIO1_B2

### 2.2 HAL 层驱动文件

HAL 层文件位于`src/bsp/hal`，HAL 层的 GPIO 驱动位于 lib/hal/src/hal_gpio.c，头文件位于`lib/hal/inc/hal_gpio.h`

提供应用层的接口如下

```C
HAL_GPIO_GetPinDirection(struct GPIO_REG *pGPIO, uint32_t pin);
HAL_GPIO_GetPinLevel(struct GPIO_REG *pGPIO, uint32_t pin);
HAL_GPIO_SetPinLevel(struct GPIO_REG *pGPIO, uint32_t pin, eGPIO_pinLevel pinLevel);
HAL_GPIO_SetPinDirection(struct GPIO_REG *pGPIO, uint32_t pin, eGPIO_pinDirection pinDir);
HAL_GPIO_SetPinsLevel(struct GPIO_REG *pGPIO, uint32_t mPins, eGPIO_pinLevel pinLevel);
HAL_GPIO_SetPinsDirection(struct GPIO_REG *pGPIO, uint32_t mPins, eGPIO_pinDirection pinDir);
HAL_GPIO_GetPinData(struct GPIO_REG *pGPIO, uint32_t pin);
HAL_GPIO_GetBankLevel(struct GPIO_REG *pGPIO);
```

HAL 驱动中`lib/CMSIS/Device/RK2206/Include/rk2206.h`有定义芯片支持的 GPIOx，如

```C
#define GPIO0               ((struct GPIO_REG *) GPIO0_BASE)
#define GPIO1               ((struct GPIO_REG *) GPIO1_BASE)
```

HAL 层的 API，第一个参数就是 GPIO0 或者 GPIO1，其他参数见函数参数说明

### 2.3 Driver 层测试用例

在驱动层`src/subsys/shell/shell_gpio.c`，有 GPIO 相关测试用例，这个主要是提供给硬件自动化测试 GPIO 使用。

## 3 常用接口说明

由于 GPIO 模块相对简单，使用者有两种方式调用 API

### 3.1 HAL 层 API

如上 2.2 部分介绍的 API，HAL 的接口是直接操作寄存器。

### 3.2 Driver 层 API

如上 2.1 部分介绍的 API，Driver 层的 API 比较规范，便于拓展支持。

例如，如果增加动态开关 pclk_gpiox，那么 HAL 的 API 将可能因为 pclk 没有开而无法正确工作。
