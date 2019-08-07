# RK818/816 电量计打印信息说明

发布版本：1.0

作者邮箱：chenjh@rock-chips.com

日期：2018.05.28

文件密级：公开资料

---

**前言**

**概述**

​	RK818/RK816 自身提供了 fuel gauge 和 charge 的功能，即电池电量检测和电池充电管理，两颗芯片关于这部分的功能实现非常类似。在本文主要以 RK818 作为例子，介绍驱动在各阶段打印出来的重要信息。RK816 的打印信息与之类似，可直接参考，不再重复增加单独文档。

**产品版本**

| **芯片名称**    | **内核版本** |
| ----------- | :------- |
| RK818、RK816 | Linux4.4 |

**读者对象**

本文档（本指南）主要适用于以下工程师：
技术支持工程师
软件开发工程师

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2018.05.28 | V1.0   | 陈健洪    | 初始版本     |

---

[TOC]

---

## 1 充电器/OTG 检测

### 1.1 驱动文件

```c
drivers/power/rk818_charger.c
```

本驱动主要实现了充电器/OTG 拔插事件的检测和充电电流的配置。打印信息都以 "rk818-charger: " 作为前缀方便识别，打印中出现的 "ac"、"usb"、"dc"、"otg" 分别代表了不同的设备，1 表示当前处于连接状态，0 表示断开连接。需要注意的是：PMIC 本身没有能力检测充电器/OTG 拔插事件，所以对于充电类型的检测实际上都是依赖 USB 的通知链消息。

### 1.2 probe 阶段

DC 充电器注册情况：

```c
rk818-charger: support dc
rk818-charger: not support dc
```

注册 type-c 口充电器的通知链：

```c
rk818-charger: register typec extcon evt notifier
```

注册传统 usb 口充电器的通知链：

```c
rk818-charger: register bc evt notifier
```

probe 结束时各设备连接状态：

```c
rk818-charger: ac=1, usb=0, dc=0, otg=0
```

驱动版本号：

```c
rk818-charger: driver version: 2.0
```

### 1.3 running 阶段

来自于 USB 通知链的充电器/OTG 设备插拔消息：

```c
rk818-charger: receive bc notifier event: DISCNT	// 充电器拔出
rk818-charger: receive bc notifier event: USB		// 电脑充电插入
rk818-charger: receive bc notifier event: AC		// 标准充电器插入
rk818-charger: receive bc notifier event: CDP1.5A	// CDP类型充电器插入
rk818-charger: receive bc notifier event: UNKNOWN	// 不识别的充电器插入
rk818-charger: receive bc notifier event: OTG ON	// OTG插入
rk818-charger: receive bc notifier event: OTG OFF	// OTG拔出
rk818-charger: detect dc charger in					// DC插入
rk818-charger: detect dc charger out				// DC拔出
```

PMIC 本身无法判断充电器类型，但是可以判断是否有充电设备插入：

```c
rk818-charger: pmic: plug out
rk818-charger: pmic: plug in
```

拔插 OTG 设备时，5V 供电变化情况：

```c
rk818-charger: disable otg5v
rk818-charger: enable otg5v
```

每次插拔充电器/OTG 后都会更新设备和电流信息：

```c
rk818-charger: ac=1 usb=0 dc=0 otg=0 v=4200 chrg=1000 input=1800 virt=0
```

### 1.4 suspend 阶段

suspend 时 OTG 设备的 5V 供电变化情况：

```c
rk818-charger: suspend: otg 5v on
rk818-charger: suspend: otg 5v off
```

### 1.5 shutdown 阶段

shutdown 时当前各设备的连接情况：

```c
rk818-charger: shutdown: ac=1 usb=0 dc=0 otg=0
```

## 2 电池电量检测

### 2.1 驱动文件

```c
drivers/power/rk818_battery.c
drivers/power/rk818_battery.h
```

本驱动主要实现了 fuel gauge 的功能，提供了一套用于统计电池电量信息的驱动程序。打印信息都以 "rk818-bat: " 作为前缀方便识别。

### 2.2 probe 阶段

当接电池后第一次上电开机，会有 "first on" 的提示：

```c
rk818-bat: first on: dsoc=24, rsoc=24 cap=960, fcc=4000, ov=3840
```

当异常关机（比如：死机后持续耗电）导致库仑计出现异常时，再次开机会进行库仑计的强制校正：

```c
rk818-bat: system halt last time... cap: pre=2400, now=120
```

当 U-Boot 已经初始化过电量计时，内核电量计驱动可以跳过部分初始化流程，防止重复初始化：

```c
rk818-bat: initialized yet..
```

probe 阶段的库仑计初始状态：

```c
rk818-bat: dsoc=32 cap=1000 v=3780 ov=3900 rv=3890 min=25 psoc=32 pcap=1000
```

电量计版本号:

```c
rk818-bat: driver version 7.1
```

### 2.3 running 阶段

每次电量变化的时候驱动向框架上报电量时都有如下打印，第一句话表示各参数的实时状态；第二句话表示开机初始化时的参数状态量，主要用于 debug

```c
rk818-bat: changed: dsoc=22, rsoc=24, v=3820, ov=3770 c=1018, cap=960, f=4000, st=cc cv, hotdie=0
rk818-bat: dl=10, rl=12, v=3670, halt=0, halt_n=0, max=0, init=0, sw=0, calib=0, below0=0, force=0
```

### 2.4 suspend 阶段

系统进入深度休眠后，如果待机过长时间后导致电池低电至关机电压以下，则会产生一个 PMIC 唤醒的中断，然后关机：

```c
rk818-bat: lower power yet, power off system! v=3350, c=-125, dsoc=0
```

### 2.5 shutdown 阶段

shutdown 的时候显示相关重要信息：

```c
rk818-bat: shutdown: dl=0 rl=2 c=-1220 v=3460 cap=88 f=4000 ch=1 n=0 mode=1 rest=128
打印含义：<显示soc> <真实soc> <电流> <电压> <剩余容量> <满充容量> <是否有charger> <其余忽略....>
```

## 3 关于 RK816 电量计

RK816 电量计的功能实现基本和 RK818 差别不大，把充电器识别和电量计改动都统一在：

```c
drivers/power/rk816_battery.c
```

打印信息的内容基本和 RK818 非常类似，打印信息以“rk816-bat:”作为前缀便于识别。因此 RK816 部分，请参考上述关于 RK818 的说明即可。