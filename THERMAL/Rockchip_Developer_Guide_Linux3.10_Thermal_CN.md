# Thermal 开发指南

文件标识：RK-KF-YF-154

发布版本：V1.1.1

日期：2021-03-02

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

本文档主要介绍 RK 平台 Thermal 配置的调试方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
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

| **版本号** | **作者** | **修改日期** | **修改说明**                                 |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 郝永志   | 2017-02-16   | 初始版本       |
| V1.1.0     | 陈亮     | 2018-07-24   | 内容及格式调整  |
| V1.1.1     | 黄莹     | 2021-03-02   |  修改格式   |

---

**目录**

[TOC]

---

## 概述

本文档主要描述 Thermal 的相关的重要概念、配置方法和调试接口。

## 重要概念

在 Linux 内核中，定义一套温控（thermal）框架，在 3.10 内核 arm64 版本，我们使用 thermal 框架的 sysfs 接口读取当前的温度。温控策略是自定义的方式：

- performance 策略：当前温度超过了目标温度，CPU 会设定在固定的频率，具体的数值配置在芯片级 dtsi 文件。

- normal 策略：当前温度超过目标温度不同的温度值时，CPU 会降低相应的频率，具体的数值配置在芯片级 dtsi 文件。

## 配置方法

### TSADC 配置

#### Menuconfig 配置

```
make ARCH=arm64 menuconfig
```

![thermal-Menuconfig01](./Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig01.jpg)

![thermal-Menuconfig02](././Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig02.jpg)

![thermal-Menuconfig03](././Rockchip_Developer_Guide_Linux3.10_Thermal/thermal-Menuconfig03.jpg)

#### dts 配置

如下是芯片级的 dtsi 的配置：

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

配置温度超过关机温度的复位方式，配置 0 是通过复位 SoC 的 CRU 模块，配置 1 是通过配置上文提到的 pinctrl = "tsadc_int"来实现，tsadc_int 引脚一般会接入 pmic 的 reset 引脚（如下图），至于这个引脚是高有效还是低有效，需要配置 hw-tshut-polarity 来实现。

![image005](././Rockchip_Developer_Guide_Linux3.10_Thermal/image005.jpg)

注：有的芯片，这个引脚没有引出来，具体请参考 TRM 手册。

TSADC 模块，默认在 dtsi 中是 disabled 状态，要启用的时候，需要在板级的 dts 中配置，如：

```c
&tsadc {
	rockchip,hw-tshut-mode = <1>; /* tshut mode 0:CRU 1:GPIO */
	rockchip,hw-tshut-polarity = <1>; /* tshut polarity 0:LOW 1:HIGH */
	status = "okay";
};
```

### 策略配置

#### 默认使用 Normal 策略，以 CPU 为例说明

```c
echo 1 > /sys/module/rockchip_pm/parameters/policy
```

在 init.rc 脚本里面配置 policy 参数为 1

温控参数配置在 dvfs 里面，具体配置参数如下：

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

#### 使用 Performance 策略，以 CPU 为例说明

```c
echo 0 > /sys/module/rockchip_pm/parameters/policy
```

配置 policy 为 0，或者不用配置这个参数，policy 默认是 0。

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

#### Thermal\_zone 配置

以 RK3328 的配置为例

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

## 调试接口

### 关温控

主控默认开启温控，即 dvfs 的 dts 里面配置 temp-limit-enable = <1>。如果要关闭温控，dvfs 的 dts 里面配置 temp-limit-enable = <0>。

### 获取当前温度

以 RK3328 为例，获取 CPU 温度，在串口中输入如下命令：

```c
cat /sys/class/thermal/thermal_zone0/temp
```
