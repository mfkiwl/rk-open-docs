# **RV1109 DDR note**

发布版本：1.0

日期：2020.02.12

作者邮箱：typ@rock-chips.com

文件密级：内部资料

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
| 2020.02.12 | V1.0     | 汤云平   |              |

---

[TOC]

---

## NOC

​	msch : 如果是2个cs ，选的ddrconf一定要有带D的，这就导致了如果2个cs 的时候容量小于ddrconf的容量时ddr空间会有空洞的行为， 而如果D位置在高位的话msch中的rank size 也需要按ddrconf配置，如果D位置在Bank和col中间的话rank size则按实际大小配置。

## 关于IO对调

 	1. PHY支持除LPDDR4外的其他类型CMD线对调。
 	2. PHY支持DQ整组对调，并不支持组内DQ对调。
 	3. LPDDR4由于CA training 用到的DQ是固定的如果DQ整组对调的话会导致CA training异常。
 	4. DDR4 read training 用到MPR 是staggered mode，如果DQ对调的话对应的check pattern也需要相应修改，详见《INNO_DDR_COMBO_PHY_DS_V1p8_TO_RK.pdf》 page86。check pattern并没有区分cs0，cs1。所以如果两个cs DQ顺序不一致的情况下可以先将check pattern设置为cs0的映射关系做完training后再改为cs1的映射关系再做cs1的training。
 	5. LPDDR4 的DQ8-15实际上可以对调，CA training 和read training时可以对DQ8-15的对调顺序做fix。DQ0-7不可对调。

## 其他DDR PHY问题

1. 之前gf22上需要将reg0x8 fix成0xf 解决1x接口上hold time不足的问题, -- rv1109上已经fix了该问题

2. PHY内部RX DQS相对DQ 默认delay了80-120ps 约5个de-skew单位。作为对比1808上为7个de-skew单位。

3. 1808上遇到的rx de-skew切换的bug问题 - -inno给的回复是后端实现的时候已经fix。

4. RZQ确认接到GND。

5. LPDDR4 DQ驱动下拉常开通过reg0x114[3]/reg0x124[3]/reg0x134[3]/reg0x144[3]配置，0：enable，1：disable。默认disable。

6. 关于read training的pattern

   LPDDR3: MR32 MR40交替发送实际为0xcc55.

   DDR4: 为page0 MPR0-3 staggered mode.

7. 关于cmd perbit de-skew：只有LPDDR4有4组，其他类型的颗粒只有一组直接register输出。对于LPDDR4 read fsp中的cmd de-skew的话，通过reg_cmd_invdelaysel_sel(reg0x386[5:0])选择 值从reg0x3e0输出。如果要更新fsp中的cmd de-skew配置的话通过reg22[6]将所有cmd de-skew register的值直接更新到对应的FSP中。

8. read gate也有4组fsp：如果要更新对应fsp中的read gate值的话可以将read gate bypass，然后通过reg0xc[5]将bypass的值更新到fsp中。可以通过reg0xc0-0xc5，0xf0-0xf5读出fsp中的read 值。

9. 关于tx/rx DQ的perbit de-skew register的值没法直接使用，必须更新到对应的FSP中才能生效使用。

10. ca training的clk 的默认值：以对应fsp中的default值为基准值。在training之前需要先将clk 的default值update到fsp中。clk保持在中间值相对ca training会更准一些。

11. write training DQS的默认值：wrlvl 有自己的fsp（datasheet框图中没画出来）,wr training 也有自己的fsp（perbit skew update会update 到wr training的fsp里）。做完wrlvl后会将结果存在wrlvl 的fsp中，当触发wr training时会自动以wrlvl的结果为dqs默认值做training，如果wrlvl没做的话wr training时dqs的默认值为7。如果想要改变wr training默认的dqs值的话可以reg_wr_train_dqs_default_bypass 打开然后 reg_l_train_dqs_default，reg_r_train_dqs_default这两个寄存器设置dqs 默认值。

12. rd training dqs 的默认值：通过reg_l_rd_train_dqs_default reg_r_rd_train_dqs_default 来设置。

13. reg_train_reg_update_en用于节约功耗，当training完成后可以gating掉training逻辑以省功耗。

14. 所有fsp中的default值和perbit skew register中的default值一样。

15. 关于LPDDR4的CA_ODT需要normal mode下正常是通过dfi_odt控制的，但是dfi_odt没法做到常拉dfi_odt。所以需要配置成PHY控制。set reg_lpddr4_ca_odt_sel=1 reg0x20[6] 打开使能，然后由 reg_lpddr4_ca_odt[1:0] reg0x20[5:4]控制 nomal 操作时的ca odt，若reg_lpddr4_ca_odt_sel=0,则由dfi_odt控制。

16. phy的rx vref通过reg0x118/128/138/148[0:7]以及reg0x71[5]配置，具体参考page79 table41.

17. CA training 2cs下的流程Figure8的流程中有误，实际有4次变频需要等待4次dfi_cat_freq_change_req，也就是Frequency change from x to y和Frequency change from y to x这8步需要再重复一遍。

18. read training，write training，wrlvl和read gate training一样必须一个个cs分开training不能一次性training两个cs，也就是reg_rdtrain_cs_sel 和reg_wrtrain_cs_sel必须配成1或者2 不能够配成0。只有ca training可以两个cs配成同时触发完成training。

19. read training 只有predefine mode 才支持vref training。
