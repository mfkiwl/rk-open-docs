# **Thermal开发指南**

发布版本：1.1

作者邮箱：rocky.hao@rock-chips.com, cl@rock-chips.com

日期：2018.07.24

文件密级：公开资料

---

**前言**

**概述**

本文档主要介绍RK平台Thermal配置的调试方法。

**产品版本**

| **产品名称** | **内核版本**  |
| -------- | --------- |
| RK312x   | Linux3.10 |
| RK322x   | Linux3.10 |
| RK3288   | Linux3.10 |
| RK3368   | Linux3.10 |
| RK3328   | Linux3.10 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

 **修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2017.02.16 | V1.0   | 郝永志    | 初始版本     |
| 2018.07.24 | V1.1   | 陈亮     | 内容及格式调整  |

---

[TOC]

---

## 概述

本文档主要描述Thermal的相关的重要概念、配置方法和调试接口。

## 重要概念

在Linux内核中，定义一套温控（thermal）框架，在3.10内核arm64版本，我们使用thermal框架的sysfs接口读取当前的温度。温控策略是自定义的方式：

- performance策略：当前温度超过了目标温度，CPU会设定在固定的频率，具体的数值配置在芯片级dtsi文件。

- normal策略：当前温度超过目标温度不同的温度值时，CPU会降低相应的频率，具体的数值配置在芯片级dtsi文件。

---

## 配置方法

### TSADC配置

#### Menuconfig配置

```
make ARCH=arm64 menuconfig
```

![thermal-Menuconfig01](./Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig01.jpg)

![thermal-Menuconfig02](././Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig02.jpg)

![thermal-Menuconfig03](././Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig03.jpg)

#### dts配置

如下是芯片级的dtsi的配置：

```c
tsadc: tsadc@ff250000 {
	compatible = "rockchip,rk322xh-tsadc"; /* 驱动加载的标识字符串 */
	reg = <0x0 0xff250000 0x0 0x100>;      /* 寄存器基地址和寄存器地址总长度 */
	interrupts = <GIC_SPI 58 IRQ_TYPE_LEVEL_HIGH>; /* 中断号 */
	clock-frequency = <50000>; /* 工作时钟是50000，配置时间周期是以这个时钟为基准的 */
	clocks = <&clk_tsadc>, <&clk_gates16 14>;
	clock-names = "tsadc", "apb_pclk";      /* "tsadc"是工作时钟，"apb_pclk" 配置时钟 */
	pinctrl-names = "default", "tsadc_int"; /* "default"是GPIO口功能,
						   "tsadc_int"请参考下面rockchip,hw-tshut-mode配置 */
	pinctrl-0 = <&tsadc_gpio>;
	pinctrl-1 = <&tsadc_int>;
	resets = <&reset RK322XH_SRST_TSADC_P>;
	reset-names = "tsadc-apb";   /* reset控制，用于reset TSADC模块 */
	hw-shut-temp = <120000>;     /* 设定关机温度是120度 */
	tsadc-tshut-mode = <0>;      /* tshut mode 0:CRU 1:GPIO */
	tsadc-tshut-polarity = <1>;  /* tshut polarity 0:LOW 1:HIGH */
	#thermal-sensor-cells = <1>; /* 引用tsadc节点的模块，需要传递一个参数给tsadc */
	status = "disabled";
};
```

```c
	rockchip,hw-tshut-mode = <1>;
```

配置温度超过关机温度的复位方式，配置0是通过复位SoC的CRU模块，配置1是通过配置上文提到的pinctrl = "tsadc_int"来实现，tsadc_int引脚一般会接入pmic的reset引脚（如下图），至于这个引脚是高有效还是低有效，需要配置hw-tshut-polarity来实现。

![image005](././Rockchip_Developer_Guide_Linux3.10_Thermal/image005.jpg)

注：有的芯片，这个引脚没有引出来，具体请参考TRM手册。

TSADC模块，默认在dtsi中是disabled状态，要启用的时候，需要在板级的dts中配置，如：

```c
&tsadc {
	rockchip,hw-tshut-mode = <1>; /* tshut mode 0:CRU 1:GPIO */
	rockchip,hw-tshut-polarity = <1>; /* tshut polarity 0:LOW 1:HIGH */
	status = "okay";
};
```

### 策略配置

#### 默认使用Normal策略，以CPU为例说明

```c
echo 1 > /sys/module/rockchip_pm/parameters/policy
```

在init.rc脚本里面配置policy参数为1

温控参数配置在dvfs里面，具体配置参数如下：

```c
temp-limit-enable = <1>; /* 使能温控 */
tsadc-ch = <0>;          /* 温度采集的tsadc通道 */
target-temp = <95>;      /* 设定温控目标温度是95度 */

/*
 * 温度超过目标温度后，CPU的最小工作频率是600M。
 * 比如，按照该温控策略，计算得知需要降频到400M，但CPU还是会设定工作频率600M。
 */
min_temp_limit = <600000>;

/*
 * 温度超过目标温度后，CPU的最大工作频率是1200M。
 * 例如，当前CPU的工作频率是1400M，当温度超过目标温度95度，CPU会急剧降到1200M以内。
 */
max_temp_limit = <1200000>;

/*
 * Normal策略:
 * 温度超过设定的温控目标温度3度，就以96M的步进来降低CPU频率，其他值类似。
 */
normal-temp-limit = <
/*delta-temp    delta-freq*/
        3       96000
        6       144000
        9       192000
        15      384000
>;
```

#### 使用Performance策略，以CPU为例说明

```c
echo 0 > /sys/module/rockchip_pm/parameters/policy
```

配置policy为0，或者不用配置这个参数，policy默认是0。

```c
/*
 * Performance策略:
 * 温度超过110度，频率会限制在816M以下。
 */
performance-temp-limit = <
        /*temp    freq*/
        110     816000
>;
```

#### Thermal\_zone配置

以RK3328的配置为例

```c
thermal-zones {
	cpu_thermal: cpu-thermal {
		/* 温度超过阀值时，每隔1000ms查询温度，并限制频率, 单位：milliseconds */
		polling-delay-passive = <1000>;
		/* 温度未超过阀值时，每隔5000ms查询温度, 单位：milliseconds */
		polling-delay = <5000>;
		/* 指定thermal-zone使用的tsadc */
				/* sensor	ID */
		thermal-sensors = <&tsadc	0>;
	};
};
```

---

## 调试接口

### 关温控

主控默认开启温控，即dvfs的dts里面配置temp-limit-enable = <1>。如果要关闭温控，dvfs的dts里面配置temp-limit-enable = <0>。

### 获取当前温度

以RK3328为例，获取CPU温度，在串口中输入如下命令：

```c
cat /sys/class/thermal/thermal_zone0/temp
```
