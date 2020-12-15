# Rockchip RT-THREAD GPIO Developer Guide

ID: RK-KF-YK-137

Release Version: V1.0.0

Release Date: 2020-12-15

Security Level: □Top-Secret   □Secret   □Internal   ■Public

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

**All rights reserved. ©2020. Rockchip Electronics Co., Ltd.**

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

This document introduces how to use pin module APIs of RT-Thread os.

Since the rt-thread lacks of iomux related API currently, user must to call HAL_PINCTRL_* APIs to do iomux and io configure.

**Product Version**

| **Chipset**                | **Kernel Version** |
| -------------------------- | ------------------ |
| RK625/RK2108/RK2206/RV1126 | RT-Thread          |

**Intended Audience**

This document (this guide) is mainly intended for:

Technical support engineers

Software development engineers

---

**Revision History**

| **Version** | **Author** | **Date** | **Change Description** |
| --------- | ---------- | :-------- | ------------ |
| V1.0.0    | Jianqun Xu | 2020-12-15 | Initial version |

---

**Contents**

[TOC]

---

## PIN

The eGPIO_bankId is the index for gpio group.

On Rockchip SoCs, there are several gpio controllers, each one has max to 32 pins.

The gpio controllers are sorted in an index called bank id:

- GPIO0 called to bank0,
- GPIO1 called to bank1,
- GPIO2 called to bank2,
- ...

### PIN Index

```c
typedef enum {
    GPIO0_A0 = 0,
    GPIO0_A1,
    GPIO0_A2,
    GPIO0_A3,
    GPIO0_A4,
    GPIO0_A5,
    GPIO0_A6,
    GPIO0_A7,
    GPIO0_B0 = 8,
    GPIO0_B1,
    GPIO0_B2,
    GPIO0_B3,
    GPIO0_B4,
    GPIO0_B5,
    GPIO0_B6,
    GPIO0_B7,
    GPIO0_C0 = 16,
    GPIO0_C1,
    GPIO0_C2,
    GPIO0_C3,
    GPIO0_C4,
    GPIO0_C5,
    GPIO0_C6,
    GPIO0_C7,
    GPIO0_D0 = 24,
    GPIO0_D1,
    GPIO0_D2,
    GPIO0_D3,
    GPIO0_D4,
    GPIO0_D5,
    GPIO0_D6,
    GPIO0_D7,
    GPIO1_A0 = 32,
    ...
    GPIO2_A0 = 64,
    ...
    GPIO3_A0 = 96,
    ...
    GPIO4_A0 = 128,
    ...
    GPIO4_D0 = 152,
    GPIO4_D1,
    GPIO4_D2,
    GPIO4_D3,
    GPIO4_D4,
    GPIO4_D5,
    GPIO4_D6,
    GPIO4_D7,
    GPIO_NUM_MAX = 160
} ePINCTRL_PIN;
```

### PIN Bit

The mPins is used by multiply pins to configure once time, each bit in uint32 type indicates on pin.

```
#define GPIO_PIN_A0 (0x00000001U)  /*!< Pin 0 selected    */
#define GPIO_PIN_A1 (0x00000002U)  /*!< Pin 1 selected    */
#define GPIO_PIN_A2 (0x00000004U)  /*!< Pin 2 selected    */
#define GPIO_PIN_A3 (0x00000008U)  /*!< Pin 3 selected    */
#define GPIO_PIN_A4 (0x00000010U)  /*!< Pin 4 selected    */
#define GPIO_PIN_A5 (0x00000020U)  /*!< Pin 5 selected    */
#define GPIO_PIN_A6 (0x00000040U)  /*!< Pin 6 selected    */
#define GPIO_PIN_A7 (0x00000080U)  /*!< Pin 7 selected    */
#define GPIO_PIN_B0 (0x00000100U)  /*!< Pin 8 selected    */
#define GPIO_PIN_B1 (0x00000200U)  /*!< Pin 9 selected    */
#define GPIO_PIN_B2 (0x00000400U)  /*!< Pin 10 selected   */
#define GPIO_PIN_B3 (0x00000800U)  /*!< Pin 11 selected   */
#define GPIO_PIN_B4 (0x00001000U)  /*!< Pin 12 selected   */
#define GPIO_PIN_B5 (0x00002000U)  /*!< Pin 13 selected   */
#define GPIO_PIN_B6 (0x00004000U)  /*!< Pin 14 selected   */
#define GPIO_PIN_B7 (0x00008000U)  /*!< Pin 15 selected   */
#define GPIO_PIN_C0 (0x00010000U)  /*!< Pin 16 selected   */
#define GPIO_PIN_C1 (0x00020000U)  /*!< Pin 17 selected   */
#define GPIO_PIN_C2 (0x00040000U)  /*!< Pin 18 selected   */
#define GPIO_PIN_C3 (0x00080000U)  /*!< Pin 19 selected   */
#define GPIO_PIN_C4 (0x00100000U)  /*!< Pin 20 selected   */
#define GPIO_PIN_C5 (0x00200000U)  /*!< Pin 21 selected   */
#define GPIO_PIN_C6 (0x00400000U)  /*!< Pin 22 selected   */
#define GPIO_PIN_C7 (0x00800000U)  /*!< Pin 23 selected   */
#define GPIO_PIN_D0 (0x01000000U)  /*!< Pin 24 selected   */
#define GPIO_PIN_D1 (0x02000000U)  /*!< Pin 25 selected   */
#define GPIO_PIN_D2 (0x04000000U)  /*!< Pin 26 selected   */
#define GPIO_PIN_D3 (0x08000000U)  /*!< Pin 27 selected   */
#define GPIO_PIN_D4 (0x10000000U)  /*!< Pin 28 selected   */
#define GPIO_PIN_D5 (0x20000000U)  /*!< Pin 29 selected   */
#define GPIO_PIN_D6 (0x40000000U)  /*!< Pin 30 selected   */
#define GPIO_PIN_D7 (0x80000000U)  /*!< Pin 31 selected   */

#define GPIO_PIN_ALL (0xFFFFFFFFU)  /*!< All pins selected */
```

## IOMUX

### API

#### PIN MUX

```
HAL_PINCTRL_SetIOMUX(eGPIO_bankId bank, uint32_t mPins, ePINCTRL_configParam param);
```

#### PIN CONFIG

```
HAL_PINCTRL_SetParam(eGPIO_bankId bank, uint32_t mPins, ePINCTRL_configParam param);
```

#### Other

```c
HAL_Status HAL_PINCTRL_Suspend(void);
HAL_Status HAL_PINCTRL_Resume(void);
HAL_Status HAL_PINCTRL_Init(void);
HAL_Status HAL_PINCTRL_DeInit(void);
```

### Params

#### eGPIO_bankId

```c
typedef enum {
#ifdef GPIO0
    GPIO_BANK0 = 0,
#endif
#ifdef GPIO1
    GPIO_BANK1 = 1,
#endif
#ifdef GPIO2
    GPIO_BANK2 = 2,
#endif
#ifdef GPIO3
    GPIO_BANK3 = 3,
#endif
#ifdef GPIO4
    GPIO_BANK4 = 4,
#endif
    GPIO_BANK_NUM
} eGPIO_bankId;
```

#### mPins

See above.

### Example

#### Set iomux for i2c0

```c
#define FUNC_GPIO0B4_FUNC1_I2C0_SDA GPIO_BANK0,GPIO_PIN_B4,PIN_CONFIG_MUX_FUNC1
#define FUNC_GPIO0B5_FUNC1_I2C0_SCL GPIO_BANK0,GPIO_PIN_B5,PIN_CONFIG_MUX_FUNC1

void i2c0_iomux_config(void)
{
    HAL_PINCTRL_SetIOMUX(FUNC_GPIO0B4_FUNC1_I2C0_SDA);
    HAL_PINCTRL_SetIOMUX(FUNC_GPIO0B5_FUNC1_I2C0_SCL);
}
```

## GPIO

### API

#### PIN MODE

```c
void rt_pin_mode(rt_base_t pin, rt_base_t mode);
```

#### PIN WRITE

```c
void rt_pin_write(rt_base_t pin, rt_base_t value);
```

#### PIN READ

```c
int  rt_pin_read(rt_base_t pin);
```

#### PIN IRQ

ATTACH

```c
rt_err_t
rt_pin_attach_irq(rt_int32_t pin, rt_uint32_t mode, void (*hdr)(void *args), void  *args);
```

DETACH

```c
rt_err_t rt_pin_detach_irq(rt_int32_t pin);
```

ENABLE

```c
rt_err_t rt_pin_irq_enable(rt_base_t pin, rt_uint32_t enabled);
```

### Example

#### Set INPUT

```c
HAL_PINCTRL_SetIOMUX(GPIO_BANK0, GPIO_PIN_B0, PIN_CONFIG_MUX_FUNC0);
rt_pin_mode(GPIO0_B0, PIN_MODE_INPUT);
```

#### Set OUT HIGH

```c
HAL_PINCTRL_SetIOMUX(GPIO_BANK0, GPIO_PIN_B0, PIN_CONFIG_MUX_FUNC0);
rt_pin_mode(GPIO0_B0, PIN_MODE_OUTPUT);
rt_pin_write(GPIO0_B0, GPIO_HIGH);
```

#### Set IRQ

```c
pin_info = BANK_PIN(bank, pin);
rt_pin_attach_irq(pin_info, PIN_IRQ_MODE_RISING_FALLING, isr, NULL);
rt_pin_irq_enable(pin_info, PIN_IRQ_ENABLE);
```

