# RV1109 DDR note

文件标识：RK-KF-YF-092

发布版本：V1.1.0

日期：2020-05-28

文件密级：□绝密   □秘密   ■内部资料   □公开

---

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2020瑞芯微电子股份有限公司**

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
DDR 小组内部备忘录

**概述**
该文档作为记录rv1109 DDR PHY 相关疑问

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RV1109       | 所有内核版本 |

**读者对象**
DDR 小组内部工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2020.02.12 | V1.0.0   | 汤云平   |              |
| 2020.05.28 | V1.1.0   | 汤云平   | 增加说明     |

**目录**

---
[TOC]
---

## 1 NOC

​	msch : 如果是2个cs ，选的ddrconf一定要有带D的，这就导致了如果2个cs 的时候容量小于ddrconf的容量时ddr空间会有空洞的行为，而如果D位置在高位的话msch中的rank size也需要按ddrconf配置，如果D位置在Bank和col中间的话rank size则按实际大小配置。

## 2 关于IO对调

1. PHY支持除LPDDR4外的其他类型CMD线对调。
2. PHY支持DQ整组对调，并不支持组内DQ对调。
3. LPDDR4由于CA training用到的DQ是固定的如果DQ整组对调的话会导致CA training异常。
4. DDR4 read training用到MPR是staggered mode，如果DQ对调的话对应的check pattern也需要相应修改，详见《INNO_DDR_COMBO_PHY_DS_V1p8_TO_RK.pdf》 page86。check pattern并没有区分cs0，cs1。所以如果两个cs DQ顺序不一致的情况下可以先将check pattern设置为cs0的映射关系，做完training后再改为cs1的映射关系再做cs1的training。
5. LPDDR4的DQ8-15实际上可以对调，但是不建议硬件对调。CA training 和read training时可以对DQ8-15的对调顺序做fix。DQ0-7不可对调。
6. 关于DQ整组的对调，实际上是phy的byte送到DFI上时做了一次对调，如果是16bit mode的话DFI一定要选择低16bit有效，然后再根据DFI的byte选择对应phy byte相应应该enable哪几个byte。如phy reg0x4f设置为0xE4得话，bit[0:1]=3表示DDR PHY接口上的byte0整组映射到DFI接口上的byte3上。bit[2:3]=2表示DDR PHY接口上的byte1整组映射到DFI接口上的byte2上。依次类推DDR PHY接口上的byte2映射到DFI上的byte1，DDR PHY接口上的byte3映射到DFI上的byte0上。如果运行在16bit mode下的话此时为了让DFI的byte0，1enable，实际上对应到DDR PHY上是DDR PHY的byte2，3需要enable，reg0xf[3:0]需要配置为0xc. 如果是8bit mode的话DDR PHY的byte3需要enable，reg0xf[3:0]应该配置为0x8。

## 3 其他DDR PHY问题

1. 之前gf22上需要将reg0x8 fix成0xf 解决1x接口上hold time不足的问题, --rv1109上已经fix了该问题
2. PHY内部RX DQS相对DQ默认delay了80-120ps 约5个de-skew单位。作为对比1808上为7个de-skew单位。
4. RZQ确认接到GND。
6. read gate也有4组fsp：如果要更新对应fsp中的read gate值的话可以将read gate bypass，然后通过reg0xc[5]将bypass的值更新到fsp中。可以通过reg0xc0-0xc5，0xf0-0xf5读出fsp中的read 值。
8. write training DQS的默认值：wrlvl 有自己的fsp（datasheet框图中没画出来）,wr training 也有自己的fsp（perbit skew update会update 到wr training的fsp里）。做完wrlvl后会将结果存在wrlvl 的fsp中，当触发wr training时会自动以wrlvl的结果为dqs默认值做training，如果wrlvl没做的话wr training时dqs的默认值为7。如果想要改变wr training默认的dqs值的话可以reg_wr_train_dqs_default_bypass 打开然后 reg_l_train_dqs_default，reg_r_train_dqs_default这两个寄存器设置dqs 默认值。
9. 所有fsp中的default值和perbit skew register中的default值一样。
10. 关于LPDDR4的CA_ODT需要normal mode下正常是通过dfi_odt控制的，但是dfi_odt没法做到常拉dfi_odt。所以需要配置成PHY控制。set reg_lpddr4_ca_odt_sel=1 reg0x20[6] 打开使能，然后由 reg_lpddr4_ca_odt[1:0] reg0x20[5:4]控制 nomal 操作时的ca odt，若reg_lpddr4_ca_odt_sel=0,则由dfi_odt控制。
11. phy的rx vref通过reg0x118/128/138/148[0:7]以及reg0x71[5]配置，具体参考page79 table41。reg0x118,reg0x138由于设计问题读出来会是0，但是实际写入的值是有生效的。
18. read training，write training，wrlvl和read gate training一样必须一个个cs分开training，不能一次性training两个cs，也就是reg_rdtrain_cs_sel 和reg_wrtrain_cs_sel必须配成1或者2 不能够配成0。只有ca training可以两个cs配成同时触发完成training。
11. 控制器要求LPDDR4 mode下dfi_t_rddata_en,dfi_tphy_wrlat这两个timing根据phy提供的公式计算到的结果还需要额外减3才行。这导致了LPDDR4的CWL必须大于等于8。
12. PHY的vref out输出内阻时25Kohm左右，如果外部挂的电容太大的话会导致vref的建立时间特别长。

## 4 关于CA training

1. CA training的clk 的默认值：以对应fsp中的default值为基准值。在training之前需要先将clk 的default值update到fsp中。clk保持在中间值相对ca training会更准一些。
2. CA training 2cs下的流程Figure8的流程中有误，实际有4次变频需要等待4次dfi_cat_freq_change_req，也就是Frequency change from x to y和Frequency change from y to x这8步需要再重复一遍。
3. CA training 时PHY写入到LP4中的FSP-WR为PHY 中的MR13寄存器决定的， PHY在做Training是会先发送MR13 然后再发送其他MR。
4. CA training时的Vref（CA）使用的range是通过reg0x1e[6],reg0x1f[6]来决定时哪个range，实际result reg0x3ae/0x3af/0x3be/0x3bf/0x3ce/0x3cf/0x3de/0x3df中只有bit[0:5] 有效，并不包含range信息。
5. reg0x55/reg0x56寄存器对CS 75%的Modulation cs training mode进行补偿是实时生效的，就算Modulation cs training mode disable掉也依然生效，所以如果disable该功能的话需要将reg0x55/reg0x56设置为0。而在CA training的过程中是不会补偿CS，所以training前不需要清0该寄存器。
7. reg_train_reg_update_en用于控制ca training中的部分逻辑，当training完成后可以gating掉training逻辑以省功耗。
7. ca training和write dq training中的vref training时inno实际时找vref的min值和max值取平均，而lp4mode下的vref最大值只到42%，而我们的write信号vref最佳值很可能在40%附件，这导致了vref training出的结果很可能偏离最佳位置比较大。

## 5 关于Read training

1. read training 只有predefine mode 才支持vref training。

2. 关于read training的pattern

   LPDDR3: MR32 MR40交替发送实际为0xcc55.

   DDR4: 为page0 MPR0-3 staggered mode.

3. training时dqs 的默认值：通过reg_l_rd_train_dqs_default，reg_r_rd_train_dqs_default 来设置。

4. read training时DQS基于寄存器reg_*_rd_train_dqs_default的设置值不动DQ动扫描，当DQ触发到边界时DQS默认会相反方向移动一个单位，如果DQS移动到边界的话则会报错。 最终training完成后如果reg0x242，reg0x243,reg0x2c2,reg0x2c3表示training的DQS结果。

## 6 关于de-skew：

1. 关于cmd perbit de-skew：只有LPDDR4有4组，其他类型的颗粒只有一组，直接register输出。对于LPDDR4 read fsp中的cmd de-skew的话，通过reg_cmd_invdelaysel_sel(reg0x386[5:0])选择 值从reg0x3e0输出。如果要更新fsp中的cmd de-skew配置的话通过reg22[6]将所有cmd de-skew register的值直接更新到对应的FSP中,reg0x10[7:6] 来选择更新到哪个 cs,bit7对应cs1,bit6 对应cs0,0有效。
2. 关于tx/rx DQ的perbit de-skew register的值没法直接使用，必须更新到对应的FSP中才能生效使用。
3. 所有update的行为包括cmd/rx/tx de-skew/read gate以及rx vref等的更新都需要DFI clk正常work，也就是phy的system reset以及auto low power也需要退出才能正常update到phy中。
4. 1808上遇到的rx de-skew切换的bug问题 --inno给的回复是后端实现的时候已经fix。
5. perbit de-skew test function可以通过内部的counter得到每单位de-skew的延迟信息，配置reg0xa5[7]=0等待一段时间后清0，然后通过 reg0xbe，reg0xbf计算得到delay值。per de-skew delay=32/(63 * freq1x * （reg0xbf[2:0] << 8 | reg0xbe[7:0]）)。其中freq1x为1x时钟频率即1/2 DDR freq。需要注意的是再次开启统计时一直无法更新，需要重启才能看到新的统计结果。
6. de-skew的延时受电压影响较大，实测vdd_logic提高100mv，每单位de-skew延时加快20%左右，作为对比RK1808上电压提高100mv实际只是加快10%。
7. 信号线上串入的de-skew越多功耗也越大。所有不管是因为功耗还是因为de-skew受电压温度影响，实际能将de-skew设置多小就尽量设置多小。

## 7 关于wrlvl

​	wrlvl实际上是颗粒用DQS的上升沿去采样CLK，如果DQS和CLK上升沿或者下降沿刚好对上的整个区间采样到的结果可能是不确定的。inno在wrlvl的设计上在对找到0到1变化的点并没有反复确认，如果初始位置刚好是DQS和CLK下降沿对齐的话有概率开始由于采样的电平不确定被误判为找到wrlvl成功的点。针对这个问题建议CLK和DQS之间的相位差尽量控制在半个cycle范围内比较安全。由于CLK和DQS的相位差不受频率影响，可以在低频下（如333MHz)下完成wrlvl。高频下不做wrlvl直接使用333MHz 下wrlvl的结果。

## 8 驱动强度相关配置

1. cmd和clk的驱动强度最低bit实际是常开的。只有高4bit可调整。

2. 实际的驱动强度odt强度需要参考“DDR_PHY IO_simulation_guide_RockChip.pdf”。“INNO_DDR_COMBO_PHY_DS_V1p9_TO_RK.pdf”中所提供的驱动强度odt强度并不准。

3. zqcalib的结果通过reg_odtpu_zqcalib_sel[1:0]和（reg6d[3:2]）reg_drvpu_zqcalib_sel[1:0]（reg6d[1:0]）来读取四个档位的训练值。00  --->40ohm，01  --->60ohm，10  --->80ohm，11  --->120ohm。

4. slew rate：byte0:reg0x117[4:0],byte1:reg0x127[4:0],byte2:reg0x137[4:0],byte3:reg0x147[4:0]。clk/ca:reg0x106[4:0]。slewrate调节的趋势是0则slewrate最大，0x1f时 slewrate最小。实际发现配置为0x0、0x1、0x8、0x9、0xc、0xd时，基本无效，配置为0x2、0x3、0x6、0x7、0xa、0xb、0xe、0xf时，slewrate功能正常。

5. LPDDR4 DQ驱动下拉常开通过reg0x114[3]/reg0x124[3]/reg0x134[3]/reg0x144[3]配置，0：enable，1：disable。默认disable。

6. 关于弱上下拉如下：

   实际上DQS 的300ohm 弱上下拉设计存在bug，正常情况下无法挂起。而ECO后的芯片为了解决DQS正脉宽偏宽的问题将这300ohm的弱上下拉移到了tx端，rx端不再存在这组弱上下拉。Inno的read gate training在DDR4 mode下需要让DQS的弱上下拉提前挂起在read信号回来之前一直让DQS保持高电平状态，而这组弱上下拉移走也导致了DDR4在read gate training时也无法挂起这组弱上下拉，需要用到read preamble training mode或者2tck的read preamble才能够正常完成read gate  training。

   reg0x103[7]  :  cmd 弱上拉，为 0 时开启，reg0x103[6]  ：cmd 弱下拉，为 1 时开启。

   byte0：reg0x115[1]  : dq 弱上拉，为 0 是开启，reg0x115[0]  : dq 弱下拉，为 1 是开始。

   reg0x114[5]  dqsb弱上拉，为0时开启 （2K ohm），reg0x114[4]  dqs弱下拉，为1时开启 （2K ohm）。

   reg0x114[1]  dqs弱上拉，同时dqsb弱下拉，为0时开启 （300 ohm），reg0x114[0]  dqs弱下拉，同时dqsb弱上拉，为1时开启（300 ohm）。

   byte1：reg0x125[1]  : dq 弱上拉，为 0 是开启，reg0x125[0]  : dq 弱下拉，为 1 是开始。

   reg0x124[5]  dqsb弱上拉，为0时开启 （2K ohm），reg0x124[4]  dqs弱下拉，为1时开启 （2K ohm）。

   reg0x124[1]  dqs弱上拉，同时dqsb弱下拉，为0时开启 （300 ohm），reg0x124[0]  dqs弱下拉，同时dqsb弱上拉，为1时开启（300 ohm）。

   byte2：reg0x135[1]  : dq 弱上拉，为 0 是开启，reg0x135[0]  : dq 弱下拉，为 1 是开始。

   reg0x134[5]  dqsb弱上拉，为0时开启 （2K ohm），reg0x134[4]  dqs弱下拉，为1时开启 （2K ohm）。

   reg0x134[1]  dqs弱上拉，同时dqsb弱下拉，为0时开启 （300 ohm），reg0x134[0]  dqs弱下拉，同时dqsb弱上拉，为1时开启（300 ohm）。

   byte3：reg0x145[1]  : dq 弱上拉，为 0 是开启，reg0x145[0]  : dq 弱下拉，为 1 是开始。

   reg0x144[5]  dqsb弱上拉，为0时开启 （2K ohm），reg0x144[4]  dqs弱下拉，为1时开启 （2K ohm）。

   reg0x144[1]  dqs弱上拉，同时dqsb弱下拉，为0时开启 （300 ohm），reg0x144[0]  dqs弱下拉，同时dqsb弱上拉，为1时开启（300 ohm）。

## 9 关于WRITE TRAINING

1. 由于PHY设计问题，Write training必须保证WL大于3。
2. 没有对DM做training，而DM实际值与各自组内的DQ0使用一样的de-skew值。所以需要保证DM与DQ0等长。

