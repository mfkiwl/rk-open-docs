# Rockchip FreeRTOS Regulator Developer Guide

文件标识：RK-KF-YF-060

发布版本：V1.0.1

日期：2021-04-29

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2021 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文主要描述了RK2206 PMIC，Charger，Power key等驱动基本介绍与使用方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明**       |
| ---------- | -------- | ------------ | ------------------ |
| V1.0.0     | 黄小东   | 2019-12-02   | 初始版本           |
| V1.0.1     | 黄莹     | 2021-04-29   | 修改版权信息和格式 |

---

**目录**

[TOC]

---

## Regulator

### 概述

Regulator译为“稳定器”，有voltage regulator（稳压器）或者current regulator（稳流器），指可以自动维持恒定电压（或电流）的装置，相比较voltage regulator的使用更为常见。从驱动的角度看，regulator的控制主要有输出的enable/disable、输出电压或电流的大小的控制等。

### 配置

menuconfig中的配置：

使能regulator驱动：

```c
    BSP Driver  --->
        [*] Enable REGULATOR
```

regulator驱动是一个核心驱动，为其他相关驱动提供接口，所以单独使能regulator驱动并没有实际作用，需要根据具体的regulator类型使能其他驱动，如下所示：

```c
    BSP Driver  --->
        [*] Enable REGULATOR
        [*]     Enable PMIC REGULATOR
```

对于特定的一套硬件系统，需要填充struct regulator_desc以便为该系统下所有的regulator配置特定的信息，并且需要初始化全局变量const struct regulator_init regulator_inits[]，以便设置所有regulator的初始电压，如下：

```c
union U_PWR_REG_DESC
{
    struct PWR_INTREG_DESC intreg_desc; /* 如果该regulator为内部寄存器控制，则使用此结构描述 */
    struct pwr_i2cbus_desc i2c_desc; /* 如果该regulator由i2c总线控制，则使用此结构描述 */
};

struct regulator_desc
{
    uint8 flag;
    union U_PWR_REG_DESC desc; /* 硬件参数信息 */
    regulator_mutex_t lock; /* lock */
    uint16 setup_fixed; /* 固定升压延时uS */
    uint16 setup_step; /* 升压速度，mV/uS */
    uint32 currentVolt; /* 保存当前电压值uV */
};

struct regulator_init
{
    const char *name; /* 名称 */
    uint32 pwrId; /* id, 一个系统中的唯一标识 */
    uint32 init_voltage; /* 初始电压值uV */
    uint32 suspend_voltage; /* sleep模式时的电压值uV */
    uint32 suspend_enable; /* sleep模式时是否使能 */
};

/* 设置各路regulator初始化电压 */
const struct regulator_init regulator_inits[] =
{
    REGULATOR_INIT("buck1_out", PWR_ID_BUCK_1V8, 1800000, 0, 0),
    REGULATOR_INIT("vcc_3v3", PWR_ID_VCCIO_3V3, 3300000, 0, 0),
    REGULATOR_INIT("ldo2_out", PWR_ID_VDD_1V1, 1100000, 0, 0),
    REGULATOR_INIT("vcc_1v8", PWR_ID_VCCIO_1V8, 1800000, 0, 0),
    REGULATOR_INIT("vcc1v8_pmic", PWR_ID_VCCIO_1V8_PMU, 1800000, 0, 0),
    { 0 },
};
```

以RK812的regulator模块为例，可配置如下相关信息：

- src/bsp/RK2206/board/rk2206_evb/board.c

```c
#include "driver/drv_regulator.h"

#ifdef CONFIG_DRIVER_REGULATOR
/* 配置各路regulator基本信息 */
static struct regulator_desc regulators[] =
{
#if CONFIG_DRIVER_PMIC_REGULATOR
    /****** buck1_out **********/
    {
        .flag = REGULATOR_FLG_I2C8 | REGULATOR_FLG_LOCK,
        .desc.i2c_desc = RK812_BUCK(RK812_ID_DCDC1, I2C_DEV2, PWR_ID_BUCK_1V8),
    },
    /****** vcc_3v3 **********/
    {
        .flag = REGULATOR_FLG_I2C8 | REGULATOR_FLG_LOCK,
        .desc.i2c_desc = RK812_LDO(RK812_ID_LDO1, I2C_DEV2, PWR_ID_VCCIO_3V3),
    },
    /****** ldo2_out **********/
    {
        .flag = REGULATOR_FLG_I2C8 | REGULATOR_FLG_LOCK,
        .desc.i2c_desc = RK812_LDO2(RK812_ID_LDO2, I2C_DEV2, PWR_ID_VDD_1V1),
    },
    /****** vcc_1v8 **********/
    {
        .flag = REGULATOR_FLG_I2C8 | REGULATOR_FLG_LOCK,
        .desc.i2c_desc = RK812_LDO(RK812_ID_LDO4, I2C_DEV2, PWR_ID_VCCIO_1V8),
    },
    /****** vcc1v8_pmic **********/
    {
        .flag = REGULATOR_FLG_I2C8 | REGULATOR_FLG_LOCK,
        .desc.i2c_desc = RK812_LDO(RK812_ID_LDO5, I2C_DEV2, PWR_ID_VCCIO_1V8_PMU),
    },
#endif
};

/* 设置各路regulator初始化电压 */
const struct regulator_init regulator_inits[] =
{
    REGULATOR_INIT("buck1_out", PWR_ID_BUCK_1V8, 1800000, 0, 0),
    REGULATOR_INIT("vcc_3v3", PWR_ID_VCCIO_3V3, 3300000, 0, 0),
    REGULATOR_INIT("ldo2_out", PWR_ID_VDD_1V1, 1100000, 0, 0),
    REGULATOR_INIT("vcc_1v8", PWR_ID_VCCIO_1V8, 1800000, 0, 0),
    REGULATOR_INIT("vcc1v8_pmic", PWR_ID_VCCIO_1V8_PMU, 1800000, 0, 0),
    { 0 },
};
#endif

COMMON API void System_Power_Init(void)
{
    ...

/* 将上面填充好的struct regulator_desc注册到regulator驱动里 */
#if CONFIG_DRIVER_REGULATOR
    regulator_desc_init(regulators, HAL_ARRAY_SIZE(regulators));
#endif

    ...
}
```

### 代码和API

- src/driver/regulator/drv_regulator.c
- include/driver/drv_regulator.h

```c
/* 设置指定regulator的电压 */
rk_err_t regulator_set_voltage(struct regulator_desc *desc, int volt);
/* 获取指定regulator的电压 */
uint32 regulator_get_voltage(struct regulator_desc *desc);
/* 设置指定regulator的sleep模式电压 */
rk_err_t regulator_set_suspend_voltage(struct regulator_desc *desc, int volt);
/* 获取指定regulator的sleep模式电压 */
uint32 regulator_get_suspend_voltage(struct regulator_desc *desc);
/* 设置指定regulator的电压 */
uint32 regulator_get_real_voltage(struct regulator_desc *desc);
/* 打开指定regulator */
rk_err_t regulator_enable(struct regulator_desc *desc);
/* 关闭指定regulator */
rk_err_t regulator_disable(struct regulator_desc *desc);
/* 设置sleep模式时打开指定regulator */
rk_err_t regulator_suspend_enable(struct regulator_desc *descs);
/* 设置sleep模式时关闭指定regulator */
rk_err_t regulator_suspend_disable(struct regulator_desc *descs);
/* 根据pwrid获取regulator_desc */
struct regulator_desc *regulator_get_desc_by_pwrid(ePWR_ID pwrId);
/* 根据名称获取regulator_desc */
struct regulator_desc *regulator_get_desc_by_name(const char *name);
/* 初始化regulator_desc */
void regulator_desc_init(struct regulator_desc *descs, uint32 cnt);
/* 初始化regulator */
void regulator_setup(void);
```

### 使用范例

regulator的API由特定模块进行调用，以dvfs为例：

- src/driver/dvfs/drv_dvfs.c

```c
#include "driver/drv_regulator.h"

rk_err_t regulator_req_set_voltage(struct req_pwr_desc *req_pwr, uint8_t req_id,
                                   uint32_t volt)
{
    ...

    volt_new = req_val_updata_val(req_ctrl, req_id, volt);

    if (volt_new)
        ret = regulator_set_voltage(req_pwr->desc, volt_new);

    ...
}
```

## PMIC Regulator

### 概述

某些类型的regulator的寄存器是通过i2c访问的，PMIC内部集成的regulator通常是此类型，我们统一抽象为pmic regulator。

### 配置

menuconfig中的配置：

使能pmic regulator驱动（需要先使能regulator驱动）：

```c
    BSP Driver  --->
        [*] Enable REGULATOR
        [*]     Enable PMIC REGULATOR
```

上述配置后pmic regulator驱动既可使用。

### 代码和API

- src/driver/regulator/drv_pmic_regulator.c
- include/driver/drv_pmic_regulator.h

```c
/* 获取指定pmic regulator电压 */
uint32 pmic_get_voltage(struct pwr_i2cbus_desc *desc);
/* 设置指定pmic regulator电压 */
rk_err_t pmic_set_voltage(struct pwr_i2cbus_desc *desc,
                          uint32 voltUv);
/* 获取sleep模式时指定pmic regulator电压 */
uint32 pmic_get_suspend_voltage(struct pwr_i2cbus_desc *desc);
/* 设置sleep模式时指定pmic regulator电压 */
rk_err_t pmic_set_suspend_voltage(struct pwr_i2cbus_desc *desc,
                                  uint32 voltUv);
/* 开关指定pmic regulator */
rk_err_t pmic_set_enable(struct pwr_i2cbus_desc *desc, uint32 enable);
/* 设置sleep模式时是否打开指定pmic regulator */
rk_err_t pmic_set_suspend_enable(struct pwr_i2cbus_desc *desc, uint32 enable);
/* 判断指定pmic regulator是否打开 */
uint32 pmic_is_enabled(struct pwr_i2cbus_desc *desc);
/* 判断指定pmic regulator与指定pwrid是否相符 */
rk_err_t pmic_check_desc_by_pwrId(struct pwr_i2cbus_desc *pdesc, ePWR_ID pwrId);
```

### 使用范例

pmic regulator的API通常由regulator驱动调用，如下所示：

- src/driver/regulator/drv_regulator.c

```c
#include "driver/drv_pmic_regulator.h"

static rk_err_t __regulator_set_voltage(struct regulator_desc *descs, int volt)
{
    ...

#ifdef CONFIG_DRIVER_PMIC_REGULATOR
    if (REGULATOR_CHK_I2C8(descs))
    {
        return pmic_set_voltage(&descs->desc.i2c_desc, volt);
    }
#endif

    ...
}
```