# **Bug list for Innosilicon DDR PHY**

发布版本：1.0

日期：2019.04.03

作者邮箱：typ@rock-chips.com

文件密级：内部资料

---
** 前言**
DDR小组内部备忘录

**概述**
该文档作为备忘录记录Inno DDR PHY遇到过的BUG，仅限DDR小组内部查阅。

**产品版本**
| **芯片名称**                            | **内核版本** |
| ----------------------------------- | -------- |
| RK322x,RK322xH,RK3368,rk3326,RK1808 | 所有内核版本   |

**读者对象**
DDR小组内部工程师

**修订记录**
| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2019.04.03 | V1.0   | 汤云平    |          |

---

[TOC]

---

## RK322x

​	1. logic电压1.0v无法运行800M， 实测发现1.0v下800MHz clk断断续续， 提高PLL的VCO后clk不连续现象有有改善，对降低logic电压也有改善，但是依然无法达到800MHz 1.0v的目标。

​	2. cs之间的read gate切换有问题，当两个cs的read gate training出来的结果在1x clk上不同时，比如一个cs的结果是0x2f 另一个cs的结果是0x30时，两个cs切换时1x也需要切换，而1x切换时间很长，会导致read异常。增大diff\_cs\_rd\_gap能够解决。

## RK3368

​	1. 与RK322x一样的问题。

​	2. 信号slew rate偏低， lpddr3下的信号下的marin很小。

## RK3228H/RK3328

​	1. rk de-skew 切换存在毛刺，以及不同的dq之间的切换时间不同，最大可能接近800ps。表现现象为如果所有的rx de-skew都设置为0的话有效的窗口比较大，而所有的rx de-skew设为7的时候有效窗口就变小了。
解决方法：将de-skew的切换时序与read gate training结果联动起来。利用read gate training的结果来控制de-skew切换的时序。详细说明可见文档“\\10.10.10.111\ddr_group\DDR_Documents\09_RK_DDR_Design_Documents\RK3228H\RANK切换问题说明及处理方案.pdf”

​	2. read gate切换依然有问题，如果用各自的gate的话dfi\_cs\_rd\_gap需要加大。目前的解决方案还是固定用cs0的read gate结果。
​	3. DDR4 mode下由于PHY内部ACT0 与CS0在做remap的时候搞错，会影响PHY内部read gate和de-skew cs之间的切换对外部的CS0和ACT信号并无影响。实际上DDR PHY上电之后默认使用的de-skew和read gate是CS0，当CS1上有访问行为时（既dfi\_act\_n[1]/dfi\_cs\_n[1]有动作时）de-skew和read gate会切换到CS1之后再也无法切换回来。所以2个CS的时候CS0的de-skew和read gate其实都不生效。当一个CS的时候实际上CS0的read gate 和de-skew会起作用。

## RK3326/PX30

​	1. Fix了read gate切换时间过长的问题，每个cs只能用各自的read gate结果，也无法像之前那样将一个cs的training结果用在所有cs上。
​	2. Read gate实际值存在随电压变化而变化的问题，需要保证logic电压不要变化过大。
​	3. Fix rd de-skew问题， 做去毛刺处理，切换时间对齐， 并且默认切换时间为training的结果-1，要对切换时间进行调整的话需要将0x6e的bit4设置为1 bypss掉才能手动调整。
实际上默认切换时间并非最佳， 实际上依然配置成read gate结果+1，而高频下和低频下切换的最佳时间点并不相同， 所以实际上还是将 dfi\_cs\_rd\_gap加大到2。
​	4. DDR4 mode下由于PHY内部ACT0 与CS0在做remep的时候搞错，会影响PHY内部read gate和de-skew cs之间的切换对外部的CS0和ACT信号并无影响。实际上DDR PHY上电之后默认使用的de-skew和read gate是CS0，当CS1上有访问行为时（既dfi\_act\_n[1]/dfi\_cs\_n[1]有动作时）de-skew和read gate会切换到CS1之后再也无法切换回来。所以2个CS的时候CS0的de-skew和read gate其实都不生效。当一个CS的时候实际上CS0的read gate 和de-skew会起作用。

## RK1808

​	1. LPDDR3 ODT pin map错误实际输出恒为0，ECO后正常。
​	2. DDR3/4的PD\_IDLE和SR\_IDLE进入dfi\_low\_power对功耗没有改善，因为PHY设计时漏gatining了相关电路，ECO后正常。
​	3. LPDDR3下PD\_IDLE进入dfi\_low\_power，800MHz时dfi\_lp\_wakeup需要加大到4才能够正常，随着ddr频率的降低dfi\_lp\_wakeup可以减小。原因是PHY内部wakeup时VREF唤醒更晚导致read数据出错。

​	4. PHY内部模拟与数字之间接口的Hold time不够，表现现象为低频高压无法正常运行，通过phyreg0x8[3:0]设置为0xf解决。
​	5. LPDDR2/LPDDR3 CKE信号相位不对，与CLK同沿，导致进入Self-refresh命令变为了Power down命令。ECO后解决，ECO前通过配置phyreg0x16[3:0]为9将CKE相位改为-180度解决。
​	6. ECO后的芯片存在RX de-skew切换存在问题，需要像以前的PHY一样通过read gate的值来调整RX de-skew切换timing。