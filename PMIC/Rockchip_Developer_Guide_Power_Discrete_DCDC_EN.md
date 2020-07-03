# Rockchip Power Discrete DCDC Development Guide

Release version:1.1

E-mail：zhangqing@rock-chips.com

Release Date：2019.11

Classifed Level：Publicity

---
**Preface**

**Overview**

**Product version**

| Chipset name | Kernel version |
| ------------ | -------------- |
| RK3399       | Linux4.4 & Linux4.19       |
| RK3328       | Linux4.4 & Linux4.19       |
| RK3368       | Linux4.4 & Linux4.19       |
| RK3288       | Linux4.4 & Linux4.19       |
| RK3036       | Linux4.4 & Linux4.19       |
| RK312X       | Linux4.4 & Linux4.19       |
| RK3326       | Linux4.4 & Linux4.19       |

**Applicable object**

This document(guide) is mainly suitable for below engineers:

Field Application Engineer

Software Development Engineer

**Revision history**

| **Date**   | **Version** | **Author** | **Revision description** |
| ---------- | ----------- | ---------- | ------------------------ |
| 2017-07-24 | V1.0        | ZhangQing  | The first   version        |
| 2019-11-12 | V1.1        | ZhangQing  | support linux 4.19 version |

---
[TOC]

---

## PWM Voltage Regulator

### The driver files and DTS node

The driver files location:

```c
drivers/regulator/PWM-regulator.c
```

DTS node:

```c
vdd_center: vdd-center {
	compatible = "pwm-regulator";
	rockchip,pwm_id = <2>;
	rockchip,pwm_voltage = <900000>;
	pwms = <&pwm2 0 25000 1>;
	regulator-name = "vdd_center";
	regulator-min-microvolt = <800000>;
	regulator-max-microvolt = <1400000>;
	regulator-always-on;
	regulator-boot-on;
};
```

The parameter description:

(1)

```c
rockchip,pwm_id = <2>;//pwm2
rockchip,pwm_voltage = <900000>;//Init voltage in U-Boot
```

These two parameters are mainly used by U-Boot but not kernel.

(2)

```c
pwms = <&pwm2 0 25000 1>;
```

PWM2 is using pwm2 node, 25000 is PWM cycle and 1 means PWM circuit polarity is reversed.

PWM circuit polarity:

Positive polarity: The larger the PWM duty ratio, the higher the output voltage

Reversed polarity: The larger the PWM duty ratio, the lower the output voltage

(3)

```c
regulator-name = "vdd_center";
```

The name of the PWM output power, invoked for voltage regulating.

(4)

```c
regulator-min-microvolt = <800000>;

regulator-max-microvolt = <1400000>;
```

The max and min voltages supported by PWM circuit hardware. They must be the actual hardware value. (Test method: The corresponding output voltage after pull PWM port up or down forcedly)

(5)

```c
regulator-always-on;
```

Whether the power always on or not. You can delete the attribute if need to manage the switch by yourself.

(6)

```c
regulator-boot-on;
```

Used in U-Boot if need to set the power on in U-Boot stage.

## SYR8XX Voltage Regulating

### The driver files and DTS node

The driver files location:

```c
drivers/regulator/fan53555.c
```

DTS node：

```c
vdd_cpu_b: syr827@40 {
	compatible = "silergy,syr827";
	reg = <0x40>;
	vin-supply = <&vcc5v0_sys>;
	regulator-compatible = "fan53555-reg";
	pinctrl-0 = <&vsel1_gpio>;
	vsel-gpios = <&gpio1 17 GPIO_ACTIVE_HIGH>;

	regulator-name = "vdd_cpu_b";
	regulator-min-microvolt = <712500>;
	regulator-max-microvolt = <1500000>;
	regulator-ramp-delay = <1000>;
	fcs,suspend-voltage-selector = <1>;
	regulator-always-on;
	regulator-boot-on;
	regulator-initial-state = <3>;
	regulator-state-mem {
		regulator-off-in-suspend;
	};
};
```

The parameter description:

(1)

```c
vin-supply = <&vcc5v0_sys>;
```

The hardware input voltage, no actual meaning, mainly used for constructing the power tree.

(2)

```c
pinctrl-0 = <&vsel1_gpio>;
vsel-gpios = <&gpio1 17 GPIO_ACTIVE_HIGH>;
fcs,suspend-voltage-selector = <1>;
```

Pay attention to this:This IO is used to change two groups of different voltages, but currently it is used to quickly change the switch.

```c
fcs,suspend-voltage-selector = <1>;
```

Enable voltage when vsel pin is low, disable the voltage when it is high. IO is pulled down by default.

```c
fcs,suspend-voltage-selector = <0>;
```

Enable voltage when vsel pin is high, disable the voltage when it is low. IO is pulled up by default.

The value should match with the actual hardware.

**Note:**

VSEL pin function can also be used to change voltage for sleep-resume instead of quickly changing the switch. Only need to delete:

```c
pinctrl-0 = <&vsel1_gpio>;

vsel-gpios = <&gpio1 17 GPIO_ACTIVE_HIGH>;
```

Now vsel pin is connected to pmic_sleep. The function:

```c
fcs,suspend-voltage-selector = <1>;
```

Output running voltage when vsel pin is low and output standby voltage when it is high(also can set to off for standby). IO is pulled down by default.

```c
fcs,suspend-voltage-selector = <0>;
```

Output running voltage when vsel pin is high and output standby voltage when it is low(also can set to off for standby). IO is pulled up by default.

(3)

```c
regulator-name = "vdd_cpu_b";
```

The name of the PWM output power, invoked for voltage regulating.

(4)

```c
regulator-min-microvolt = <712500>;
regulator-max-microvolt = <1500000>;
```

The max and min values limited by software, it is not allowable to set the values out of the range.

(5)

```c
regulator-always-on;
```

Whether the power always on or not. You can delete the attribute if need to manage the switch by yourself.

(6)

```c
regulator-boot-on;
```

Used in U-Boot to if need to set the power on in U-Boot stage.

(7)

```c
regulator-ramp-delay = <1000>;
```

It is to control the ascending speed of voltage regulating. Normally no need to change as it is already the optimal value.

## XZ321X Voltage Regulating

### The driver files and DTS node

The driver files location:

```c
drivers/regulator/xz3216.c
```

DTS node：

```c
xz3216: xz3216@60 {
	compatible = "xz3216";
	reg = <0x60>;
	status = "okay";
	regulators {
		#address-cells = <1>;
		#size-cells = <0>;
		xz3216_dc1: regulator@0 {
			reg = <0>;
			regulator-compatible = "xz_dcdc1";
			regulator-name = "vdd_cpu_l";
			regulator-min-microvolt = <712500>;
			regulator-max-microvolt = <1400000>;
			regulator-always-on;
			regulator-boot-on;
			regulator-initial-state = <3>;
			regulator-state-mem {
				regulator-off-in-suspend;
				regulator-suspend-microvolt = <1100000>;
			};
		};
	};
};
```

The parameter description:

**Note**:

(1)

```c
regulator-name = "vdd_cpu_l";
```

The name of the output power, invoked for voltage regulating.

(2)

```c
regulator-min-microvolt = <712500>;
regulator-max-microvolt = <1500000>;
```

The max and min values limited by software, it is not allowable to set the values out of the range.

(3)

```c
regulator-always-on;
```

Whether the power always on or not. You can delete the attribute if need to manage the switch by yourself.

(4)

Pay attention to the changes for frequency and voltage regulating:

If it is used for CPU little core, also need to modify:

```c
&cpu_l0 {
cpu-supply = <&xz3216_dc1>;
};
&cpu_l1 {
cpu-supply = <&xz3216_dc1>;
};
&cpu_l2 {
cpu-supply = <&xz3216_dc1>;
};
&cpu_l3 {
cpu-supply = <&xz3216_dc1>;
};
```

If it is used for CPU big core, also need to modify:

```c
&cpu_b0 {
	cpu-supply = <&xz3216_dc1>;
};
&cpu_b1 {
	cpu-supply = <&xz3216_dc1>;
};
```

If it is used for GPU, also need to modify:

```c
&gpu {
	status = "okay";
	mali-supply = <&xz3216_dc1>;
};
```

The configuration depends on the actual power supply situation of XZ3126.(configured according to the released hardware circuit by default)

## DEBUG Interface

### Read out the Power Tree

```c
cat sys/kernel/debug/regulator/regulator_summary
```

### Set the voltage manually

Enable the macro:

```c
Device Drivers ->
SOC (System On Chip) specific Drivers ->
Select Rockchip pm_test support
```

Set the voltage interface:

```c
echo  vdd_center 1000000 > sys/pm_tests/clk_volt
```
