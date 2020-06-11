# RK3399 系统待机配置指南

文档标识：RK-KF-YF-120

发布版本：V1.0.0

日期：2020-07-08

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址： 福建省福州市铜盘路软件园A区18号

网址： www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文档用于指导用户如何根据产品需求，配置 RK3399 系统待机模式。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | :----------- |
| RK3399       | 4.4、4.19    |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**    |
| ---------- | -------- | -------- | --------------- |
| 2020-07-08 | V1.0.0     | 许盛飞   | 初始版本        |

---

[TOC]

---

## 系统待机

凡是带有 trust 的 SoC 平台，系统待机（system suspend）的工作都在 trust 中完成。因为各个平台的 trust 对于系统待机实现各不相同，所以**不同平台之间的待机配置选项/方法没有任何关联性和参考性，本文档仅适用于 RK3399 平台**。

系统待机流程一般会有如下操作：关闭 power domain、时钟、PLL、ddr 进入自刷新、系统总线切到低速时钟（24M 或 32K）、控制PMIC进入休眠模式、配置唤醒源等。为了满足不同产品对待机模式的需求，目前都是通过 DTS 节点把相关配置在开机阶段传递给 trust。

### 驱动文件

```
./drivers/soc/rockchip/rockchip_pm_config.c
./drivers/firmware/rockchip_sip.c
./include/dt-bindings/suspend/rockchip-rk3399.h
```

### DTS 节点

```c
rockchip_suspend: rockchip-suspend {
	compatible = "rockchip,pm-rk3399";
	status = "okay";
	// 常规配置
	rockchip,sleep-mode-config = <
		(0
		| RKPM_SLP_ARMPD
		| RKPM_SLP_PERILPPD
		| RKPM_SLP_DDR_RET
		| RKPM_SLP_CENTER_PD
		)
	>;
	// 唤醒源配置
	rockchip,wakeup-config = <
		(0
		| RKPM_GPIO_WKUP_EN
		)
	>;
	// 电源配置
	rockchip,pwm-regulator-config = <
		(0
		| PWM2_REGULATOR_EN
		)
	>;
	// 对应APIO断电
	rockchip,apios-suspend = <
		(0
		| RKPM_APIOxxx
		)
	>;
	// 休眠控制GPIO的电平，关断对应供电
	rockchip,power-ctrl =
                <&gpioX RK_PXX GPIO_ACTIVE_HIGH>;
};
```

## DTS 配置

目前已支持的配置选项都定义在：

```
./include/dt-bindings/suspend/rockchip-rk3399.h
```

### 常规配置

配置项：

```
rockchip,sleep-mode-config = <...>;
```

配置源：

```c
// 休眠 CPU 处在 WFI 状态，只有调试时用到
#define RKPM_SLP_WFI                            (1 << 0)
// 休眠 cpu_pd power down
#define RKPM_SLP_ARMPD                          (1 << 1)
// 休眠perilp_pd power down
#define RKPM_SLP_PERILPPD                       (1 << 2)
// 休眠 ddr 进入自刷新且处在 retention 状态
#define RKPM_SLP_DDR_RET                        (1 << 3)
// 休眠 PLL power down
#define RKPM_SLP_PLLPD                          (1 << 4)
// 休眠 OSC disable，系统时钟切到 32K
#define RKPM_SLP_OSC_DIS                        (1 << 5)
// 休眠 center_pd power down
#define RKPM_SLP_CENTER_PD                      (1 << 6)
// 休眠 AP_OFF 会被拉高，用于控制 PMIC 或者其他分立电源进入休眠态
#define RKPM_SLP_AP_PWROFF                      (1 << 7)
```

### 电源配置

配置项：

```
rockchip,pwm-regulator-config = <...>;
```

配置源：

```c
// 使用 pwm-regulator
#define PWM0_REGULATOR_EN                       (1 << 0)
#define PWM1_REGULATOR_EN                       (1 << 1)
#define PWM2_REGULATOR_EN                       (1 << 2)
#define PWM3A_REGULATOR_EN                      (1 << 3)
#define PWM3B_REGULATOR_EN                      (1 << 4)
```

电源注意点：

- 根据外部硬件电路设计确定是否使用 pwm-regulator，必须与硬件对应。

### 唤醒配置

配置项：

```
rockchip,wakeup-config = <...>;
```

配置源：

```c
// 支持所有的中断唤醒
#define RKPM_CLUSTER_L_WKUP_EN                  (1 << 0)
// 支持所有被指定到大核的中断唤醒
#define RKPM_CLUSTER_B_WKUPB_EN                 (1 << 1)
// 支持 GPIO 唤醒
#define RKPM_GPIO_WKUP_EN                       (1 << 2)
// 支持 SDIO 唤醒
#define RKPM_SDIO_WKUP_EN                       (1 << 3)
// 支持 SDMMC 唤醒
#define RKPM_SDMMC_WKUP_EN                      (1 << 4)
// 支持 TIMER 唤醒
#define RKPM_TIMER_WKUP_EN                      (1 << 6)
// 支持插拔 USB 唤醒
#define RKPM_USB_WKUP_EN                        (1 << 7)
// 支持 SOFTWARE 唤醒
#define RKPM_SFT_WKUP_EN                        (1 << 8)
// 支持 WDT 唤醒
#define RKPM_WDT_M0_WKUP_EN                     (1 << 9)
// 支持 TIMEOUT 唤醒，一般用于调试
#define RKPM_TIME_OUT_WKUP_EN                   (1 << 10)
// 支持 PWM 唤醒
#define RKPM_PWM_WKUP_EN                        (1 << 11)
// 支持 PCIE 唤醒
#define RKPM_PCIE_WKUP_EN                       (1 << 13)
// 支持 USB 协议唤醒
#define RKPM_USB_LINESTATE_WKUP_EN              (1 << 14)
```

唤醒源注意点：

  在 kernel 阶段没有 enable_irq_wake()注册到 GIC 的中断无法唤醒系统。

### debug 配置

配置项：

```
rockchip,sleep-debug-en = <...>;
```

debug 注意点：

- 赋值1则打开debug功能，在休眠唤醒中会打印出ATF中休眠和唤醒的log。

### 关闭APIO配置

配置项：

```
rockchip,apios-suspend = <...>;
```

配置源：

```c
/* APIO 电压域 */
#define RKPM_APIO0_SUSPEND                      (1 << 0)
#define RKPM_APIO1_SUSPEND                      (1 << 1)
#define RKPM_APIO2_SUSPEND                      (1 << 2)
#define RKPM_APIO3_SUSPEND                      (1 << 3)
#define RKPM_APIO4_SUSPEND                      (1 << 4)
#define RKPM_APIO5_SUSPEND                      (1 << 5)
```

APIO配置注意点：

RK3399 GPIO所在的APIO分成，APIO1~APIO5，在硬件电路支持的情况下，APIO休眠可以单独断电。

### GPIO 控制电源

配置项：

```
rockchip,power-ctrl = <...>
```

配置范例：

```c
// 休眠将GPIO1_C1拉高，控制外部电源断电
rockchip,power-ctrl = <&gpio1 RK_PC1 GPIO_ACTIVE_HIGH>,
```

## 打印信息

如下简要介绍系统待机和唤醒时的 trust 打印信息含义。为注释方便，如下对一些打印内容进行分行，不同的待机功耗模式同样也会带来不同的打印，所有打印信息内容以实际显示为主。

**RK3399 系统待机打印：**

```c
// 休眠模式
INFO:    sleep mode config[0xde]:
INFO:           AP_PWROFF
INFO:           SLP_ARMPD
INFO:           SLP_PLLPD
INFO:           DDR_RET
INFO:           SLP_CENTER_PD
// 支持的唤醒源
INFO:    wakeup source config[0x804]:
INFO:           GPIO interrupt can wakeup system
INFO:           PWM interrupt can wakeup system
// 休眠需要控制的pwm regulator
INFO:    PWM CONFIG[0x4]:
INFO:           PWM: PWM2D_REGULATOR_EN
// 休眠需要控制的APIO
INFO:    APIOS info[0x0]:
INFO:           not config
// 通过GPIO控制的电源
INFO:    GPIO POWER INFO:
INFO:           GPIO1_C1
INFO:           GPIO1_B6
// 休眠模式寄存器的值
INFO:    PMU_MODE_CONG: 0x1466bf51
```

**RK3399 系统唤醒打印：**

```c
// 唤醒打印
INFO:    RK3399 the wake up information:
INFO:    wake up status: 0x4
INFO:           GPIO interrupt wakeup
INFO:           GPIO0: 0x0
INFO:           GPIO1: 0x200000
INFO:           GPIO2: 0x0
INFO:           GPIO3: 0x0
INFO:           GPIO4: 0x0
// 唤醒源
GPIO interrupt wakeup
gpio1_c5中断唤醒系统
```
