# **Bug list for Innosilicon DDR PHY**

发布版本：1.0

日期：2019.04.03

作者邮箱：typ@rock-chips.com

文件密级：内部资料

---
**前言**
DDR 小组内部备忘录

**概述**
该文档作为备忘录记录 Inno DDR PHY 遇到过的 BUG，仅限 DDR 小组内部查阅。

**产品版本**
| **芯片名称**                            | **内核版本** |
| ----------------------------------- | -------- |
| RK322x,RK322xH,RK3368,rk3326,RK1808 | 所有内核版本   |

**读者对象**
DDR 小组内部工程师

**修订记录**
| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2019.04.03 | V1.0   | 汤云平    |          |

---

[TOC]

---

## RK322x

​	1. logic 电压 1.0v 无法运行 800M， 实测发现 1.0v 下 800MHz clk 断断续续， 提高 PLL 的 VCO 后 clk 不连续现象有有改善，对降低 logic 电压也有改善，但是依然无法达到 800MHz 1.0v 的目标。

​	2. cs 之间的 read gate 切换有问题，当两个 cs 的 read gate training 出来的结果在 1x clk 上不同时，比如一个 cs 的结果是 0x2f 另一个 cs 的结果是 0x30 时，两个 cs 切换时 1x 也需要切换，而 1x 切换时间很长，会导致 read 异常。增大 diff\_cs\_rd\_gap 能够解决。

## RK3368

​	1. 与 RK322x 一样的问题。

​	2. 信号 slew rate 偏低， lpddr3 下的信号下的 marin 很小。

## RK3228H/RK3328

​	1. rk de-skew 切换存在毛刺，以及不同的 dq 之间的切换时间不同，最大可能接近 800ps。表现现象为如果所有的 rx de-skew 都设置为 0 的话有效的窗口比较大，而所有的 rx de-skew 设为 7 的时候有效窗口就变小了。
解决方法：将 de-skew 的切换时序与 read gate training 结果联动起来。利用 read gate training 的结果来控制 de-skew 切换的时序。详细说明可见文档“\\10.10.10.111\ddr_group\DDR_Documents\09_RK_DDR_Design_Documents\RK3228H\RANK 切换问题说明及处理方案.pdf”

​	2. read gate 切换依然有问题，如果用各自的 gate 的话 dfi\_cs\_rd\_gap 需要加大。目前的解决方案还是固定用 cs0 的 read gate 结果。
​	3. DDR4 mode 下由于 PHY 内部 ACT0 与 CS0 在做 remap 的时候搞错，会影响 PHY 内部 read gate 和 de-skew cs 之间的切换对外部的 CS0 和 ACT 信号并无影响。实际上 DDR PHY 上电之后默认使用的 de-skew 和 read gate 是 CS0，当 CS1 上有访问行为时（既 dfi\_act\_n[1]/dfi\_cs\_n[1]有动作时）de-skew 和 read gate 会切换到 CS1 之后再也无法切换回来。所以 2 个 CS 的时候 CS0 的 de-skew 和 read gate 其实都不生效。当一个 CS 的时候实际上 CS0 的 read gate 和 de-skew 会起作用。

## RK3326/PX30

​	1. Fix 了 read gate 切换时间过长的问题，每个 cs 只能用各自的 read gate 结果，也无法像之前那样将一个 cs 的 training 结果用在所有 cs 上。
​	2. Read gate 实际值存在随电压变化而变化的问题，需要保证 logic 电压不要变化过大。
​	3. Fix rd de-skew 问题， 做去毛刺处理，切换时间对齐， 并且默认切换时间为 training 的结果-1，要对切换时间进行调整的话需要将 0x6e 的 bit4 设置为 1 bypss 掉才能手动调整。
实际上默认切换时间并非最佳， 实际上依然配置成 read gate 结果+1，而高频下和低频下切换的最佳时间点并不相同， 所以实际上还是将 dfi\_cs\_rd\_gap 加大到 2。
​	4. DDR4 mode 下由于 PHY 内部 ACT0 与 CS0 在做 remep 的时候搞错，会影响 PHY 内部 read gate 和 de-skew cs 之间的切换对外部的 CS0 和 ACT 信号并无影响。实际上 DDR PHY 上电之后默认使用的 de-skew 和 read gate 是 CS0，当 CS1 上有访问行为时（既 dfi\_act\_n[1]/dfi\_cs\_n[1]有动作时）de-skew 和 read gate 会切换到 CS1 之后再也无法切换回来。所以 2 个 CS 的时候 CS0 的 de-skew 和 read gate 其实都不生效。当一个 CS 的时候实际上 CS0 的 read gate 和 de-skew 会起作用。

## RK1808

​	1. LPDDR3 ODT pin map 错误实际输出恒为 0，ECO 后正常。
​	2. DDR3/4 的 PD\_IDLE 和 SR\_IDLE 进入 dfi\_low\_power 对功耗没有改善，因为 PHY 设计时漏 gatining 了相关电路，ECO 后正常。
​	3. LPDDR3 下 PD\_IDLE 进入 dfi\_low\_power，800MHz 时 dfi\_lp\_wakeup 需要加大到 4 才能够正常，随着 ddr 频率的降低 dfi\_lp\_wakeup 可以减小。原因是 PHY 内部 wakeup 时 VREF 唤醒更晚导致 read 数据出错。

​	4. PHY 内部模拟与数字之间接口的 Hold time 不够，表现现象为低频高压无法正常运行，通过 phyreg0x8[3:0]设置为 0xf 解决。
​	5. LPDDR2/LPDDR3 CKE 信号相位不对，与 CLK 同沿，导致进入 Self-refresh 命令变为了 Power down 命令。ECO 后解决，ECO 前通过配置 phyreg0x16[3:0]为 9 将 CKE 相位改为-180 度解决。
​	6. ECO 后的芯片存在 RX de-skew 切换存在问题，需要像以前的 PHY 一样通过 read gate 的值来调整 RX de-skew 切换 timing。