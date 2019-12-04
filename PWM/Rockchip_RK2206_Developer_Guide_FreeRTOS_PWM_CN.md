# Rockchip RK2206 PWM 开发文档

文件标识：RK-KF-YF-064

发布版本：V1.0.0

日期：2019-12-03

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改．

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

本文主要描述 RK2206 PWM 的配置和使用方法。

**产品版本**

| **芯片名称** | **内核版本**         |
| -------- | ---------------- |
| RK2206   | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者**   | **修改日期**   | **修改说明** |
| ------- | -------- | :--------- | -------- |
| V1.0.0  | David.Wu | 2019-12-03 | 初始版本     |

**目录**

---
[TOC]
---
## 1 PWM 总线接口用途

脉宽调制（PWM，Pulse Width Modulation）功能在嵌入式系统中是非常常见的，它是利用微处理器的数字输出来对模拟电路进行控制的一种非常有效的技术，广泛应用在从测量、通信到功率控制与变换的许多领域中。
Rockchip PWM 支持三种模式: Continuous mode、One-shot mode 和 Capture mode,另外一个 PWM 控制器有 4 通道 built-in。

## 2 PWM 配置

### 2.1 munuconfig 配置

在 menuconfig 里面将控制器的驱动勾选 DRIVER_PWM，并同时根据当前的硬件情况，勾选所使用的 PWM 控制器, 可多选。

```c
    BSP Driver  --->
        [*] Enable PWM
```

例如选中 PWM1 控制器:

```c
[ ]  Enable PWM0 (NEW)
[*]  Enable PWM1
[ ]  Enable PWM2 (NEW)
```

如果需要使用 shell 测试命令进行测试，勾选 PWM 测试shell:

```c
    Components Config --->
        Command shell  --->
            [*] Enable PWM Shell
```

### 2.2 板级文件配置

板级配置，请修改对应工程的 board.c 文件里的 PwmDevHwInit() 函数，主要就是 iomux 配置配置，需要注意的是一个 PWM channel 可能有几种 iomux 选择(m0, m1...)， 根据实际硬件原理图选择正确的配置。

```c
void PwmDevHwInit(uint32 DevID)
{
    switch (DevID)
    {
    case PWM_DEV0:
        break;
    case PWM_DEV1:
        iomux_config_pwm7_m1();
        break;
    case PWM_DEV2:
        break;
    default:
        break;
    }
}
```

这里我们用 pwm0~pwm3 pin 对应着第一个 PWM 控制器的四个通道的四个 pin 脚，pwm4~pwm7 表示第二个，以此类推。

## 3 代码和 API 使用

### 3.1 代码位置

- 控制器驱动层代码 ./src/driver/pwm/PwmDevice.c
- 控制器 HAL 层代码 ./src/bsp/hal/lib/hal/src/hal_pwm.c
- PWM shell 测试代码 ./src/subsys/shell/shell_pwm.c

### 3.2 PWM API 接口

```c
extern rk_err_t PwmDev_Control(HDC dev, RK_PWM_CMD cmd, void *arg);
extern rk_err_t PwmDev_Write(HDC dev);
extern rk_err_t PwmDev_Read(HDC dev);
extern rk_err_t PwmDev_Delete(uint8 DevID, void *arg);
extern HDC PwmDev_Create(uint8 DevID, void *arg);
extern void PwmDevHwInit(uint32 DevID);
extern void PwmDevHwDeInit(uint32 DevID);
```

### 3.3  API 接口使用

#### 3.3.1 创建 PWM 实例

使用 PwmDev_Create() 创建，rkdev_open()得到 PWM device，在这个动作之前可以先 find，如果已经创建了，可以直接使用，例如:

```c
    pwm_dev = rkdev_find(DEV_CLASS_PWM, DevID);
    if (pwm_dev == NULL)
    {
        rkdev_create(DEV_CLASS_PWM, DevID, NULL);
        pwm_dev = rkdev_open(DEV_CLASS_PWM, DevID, NOT_CARE);
        if (pwm_dev == NULL)
        {
            shell_output(dev, "\r\n Can't find pwm%d dev", DevID);
            return RK_ERROR;
        }
    }
```

#### 3.3.2 PWM Configurate

调用 PwmDev_Control() 配置 PWM 的占空比，周期和极性。
Continous mode 配置

```c
RK_PWM_CONFIG *config

config->channel = channel; //channel number
config->period = period; //PWM 周期时间，单位 ns
config->pulse = duty; //占空时间，单位 ns

if (polarity) //pwm 极性
    polarity = RK_PWM_POLARITY_INVERTED;

config->polarity = polarity;
PwmDev_Control(g_pwm_dev, RK_PWM_CMD_SET, config);
```

Oneshot mode 配置，前面配置与 Continous mode 一致，多了 count 的配置。

```c
RK_PWM_ONESHOT_CONFIG oneshot_config;
RK_PWM_CONFIG *config = &oneshot_config.config;

config->channel = channel; //channel number
config->period = period; //pwm 周期时间，单位 ns
config->pulse = duty; //占空时间，单位 ns

if (polarity) //pwm 极性
    polarity = RK_PWM_POLARITY_INVERTED;

config->polarity = polarity;
oneshot_config.count = count;
PwmDev_Control(g_pwm_dev, RK_PWM_CMD_SET_ONESHOT, &oneshot_config);
```

原则上先配置 PWM，再使能。

#### 3.3.3 PWM 开关

Enable:

```c
RK_PWM_ENABLED_CONFIG config;

config.channel = channel; //channel number
config.mode = mode;
PwmDev_Control(g_pwm_dev, RK_PWM_CMD_ENABLE, &config);
```

Disable:

```c
PwmDev_Control(g_pwm_dev, RK_PWM_CMD_DISABLE, channel);
```

## 4 SHELL 测试与输出

### 4 .1 PWM continous mode 测试

配置命令依次输入 pwm 设备号，pwm  channel number，period ns，duty ns, 极限(1 为负极性，0为正极性)。以下例子为测试pwm1控制器第3通道，频率10K，占空比 50%，极性负极性。
先配置

```c
RK2206>pwm_test set pwm1 3 100000 50000 1
```

再使能该 pwm，依次输入 pwm 设备号，pwm  channel number， PWM mode(0:Continuous Mode，1:Oneshot Mode，2:Capture Mode)

```c
RK2206>pwm_test enable pwm1 3 0
```

### 4 .2 PWM oneshot mode 测试

配置命令依次输入 pwm 设备号，pwm  channel number，period ns，duty ns，极限(1 为负极性，0为正极性)，count。以下例子为测试 pwm0 控制器第0通道，频率100K，占空比 20%，极性正极性，count 为10(输出10+1个波形)。
先配置

```c
RK2206>pwm_test set pwm0 0 10000 2000 0 10
```

再使能该 pwm，依次输入 pwm 设备号，pwm  channel number， PWM mode(0:Continuous Mode，1:Oneshot Mode，2:Capture Mode)

```c
RK2206>pwm_test enable pwm0 0 1
```
