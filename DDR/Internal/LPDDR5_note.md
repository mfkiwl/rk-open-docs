# LPDDR5 note

文件标识：RK-KF-YF-126

发布版本：V1.0.0

日期：2020-09-02

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
公司内部学习资料

**概述**
该文档记录LPDDR5学习过程中的一些知识点以及疑问记录

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| null         | 所有内核版本 |

**读者对象**
DDR 小组内部工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2020.09.02 | V1.0.0   | 汤云平   |              |

**目录**

---
[TOC]
---

## 1 概况

1. 速度上达到了6400Mbps，CK频率800MHz，WCK频率3200MHz。
2. 容量上最大达到32Gb。默认x16一个channel，支持byte mode。
3. 内部16个bank，支持8bank/16bank/4BG&4Bank 模式可配。
4. FSP寄存器从LPDDR4的两组增加到了三组。
5. 除了正常的ZQ Calib外增加backgroud Calib功能。
6. 支持Command bus training，WCKCK Leveling(类似WRLVL)，Read DQ Calib，Write DQ Calib，RDQS training等training。
7. 支持post package repair。
8. 支持TCSR（额外补偿颗粒不同区域的温度差）。
9. WCK2DQ interval Oscillator用于纠正温度电压引起的WCK2DQI/WCK2DQO漂移，避免redo training。
10. CLK/WCK/RDQS 支持single ended mode。
11. deep sleep mode下依然会进行self-refresh动作。
12. 过度Actived命令会引起数据异常，引入Refresh management command避免该问题。
13. 引入了CAS命令来完成WCK信号需要与CK信号进行同步，以及实现Write X optional，RD/WRData copy。
14. 增加RD/WR link ECC功能。
15. 增加DVFSC/DVFSQ功能以降低功耗。
16. 增加Duty cycle adjuster以及Duty cycle monitor功能。
17. 行地址bank地址与其他类型的颗粒一样，但是列地址减少到了6个，同时增加了B0-B3一共4bit的burst addresses，实际上就是将10bit的列地址拆分成6bit的列地址加上4bit的burst 地址。

## 2 IO行为及供电

1. 取消了CKE pin，增加了RDQS_t/RDQS_c, WCK_t/WCK_c以替代原来的DQS。CA一共6跟，其中CS为单沿信号，CA为双沿信号。其中在低频下CK/RDQS/WCK可以选择为单端信号模式使用以降低功耗。
2. 新增的RDQS作为read 的DQ Strobe信号。
3. 新增的WCK在RD/WR时需要供着，作为DQ的工作时钟，而空闲时可以撤销，WCK同时也作为write DQ 的strobe信号。
4. CK信号在正常工作情况下需要常供，而CK频率可以是WCK频率的1/4或者1/2可配，这样可以降低功耗以及CA的信号要求。其中2：1的WCK:CK比例只能工作在3200Mbps以下的工作频率。
5. 供电上分VDD1，VDD2H，VDD2L和VDDQ。其中为core供电的VDD1 1.8v，VDD2H 1.05v，VDD2L 0.9v。为IO供电的VDDQ 0.5v。
6. IO上CS和Reset_n比较特殊是VDD2H电源域供电。 而其他CA和DQ一样为VDDQ电源域供电。CS的ODT和CA的ODT是分开的，只有RZQ/3一挡可选。而CS工作模式分同步和异步模式两种，同步模式是在正常工作下与CA类似，通过CK来采样CS，参考电平为VDD2H/3。异步模式是在进入power-down/self-refresh power down/deep sleep mode时CS的高低电平判断标准与reset类似，具体高低电平比例jesd209-5A中为TBD。

## 3 Read/Write行为

### 3.1 burst 行为

Burst length并不像以往的颗粒一样在MR里设置，而是在CA命令上做区分，分WRITE和WRITE 32，READ和READ32命令。在8Bank  mode下只支持BL32，而16Bank，Bank group模式下支持BL16/BL32。在只支持BL32的8Bank mode下READ/WRITE命令即为BL32的命令，而READ32/WRITE32命令在8Bank mode下无效。BG mode下的BL32实际上会先返回前16个UI数据中间空16个UI然后再返回剩下的16个UI数据，原因是因为只有16n预取又需要达到6400数据率BL32的情况下第二笔16个UI数据就需要额外时间准备，这个对效率就比较不友好了。如果有不同BG的其他bank的访问连续起来的话这中间的16个UI间隙可以穿插起来填满总线。

对于write来说Burst不支持interleaved mode，也就是BL16的起始地址只能是0x10对齐（B3需要为0），BL32的起始地址只能是0x20对齐（B3，B4/C0都需要为0）。而read的地址支持起始地址0x8对齐(B0-B2恒为0，并不会在CA总线上体现出来)，但是READ/READ32命令并不带B3 bit信息，而是需要通过CAS命令额外的指定B3信息。

### 3.2 Read/Write行为

1. WCK2CK SYNC行为：由于增加WCK信号，WCK信号只在read/write时需要提供，在空闲时可以停止WCK信号这样可以节省一些功耗。而WCK是CK的2倍或者4倍频，颗粒内部会有一个分频器将WCK做二分频再与CK同步，而二分频后可能存在WCK和CK上升沿对齐，或者下降沿和上升沿对齐两种情况。所有需要一个sync动作让WCK和CK同步。所有用到WCK的Read/Wrtie相关的命令都需要WCK2CK SYNC动作，WCK2CK SYNC动作实际通过发送CAS命令来完成，分WS_RD/WS_WR/WS_FS三种。不理解的是只是WCK的同步动作为什么要区分read/write和fast。
2. WCK2CK SYNC有效期：WCK2CK SYNC后会在RL + BL/n + RD(t'WCKPST/tCK)（SYNC命令紧接read时，后续命令可以时read也可以是write）或WL + BL/n + RD(t'WCKPST/tCK)（SYNC命令紧接write时，后续命令可以是read也可以是write）个cycle后失效。也就是说在这个时间内再次发送Read/Write命令的话则不需要重新做Sync动作，如果在这个时间之后再次发起Read/Write的话则需要重新发送CAS命令完成WCK2CK 的Sync动作。新的有效期会从上一条read/write命令开始算，也就是说连续紧接着的read/write间隙都在有效期内的话，除第一条read/write需要sync外后续的read/write都不需要sync命令。
3. WCK always on mode：该模式即WCK一直常供，当不想一直做WCK2CK sync动作时可以打开该模式，该模式需要通过MR0[2] 确定是否支持，WCK always on对功耗会有一定影响。always on后可以通过CAS命令发送WS_OFF命令关闭WCK buffer来省电，但是再次需要read/write时还需要从新做WCK2CK Sync动作。或者发送CAS-WCK_SUSPEND命令来降低一些WCK tree的功耗，该命令会在空闲时自动让WCK进入suspend自动gating掉WCK tree上的一些时钟，而read/write时自动退出suspend。不同于关闭WCK buffer的是CAS-WCK_SUSPEND命令是自动的并不需要重新做WCK2CK Sync动作。
4. 对于read命令如果WCK不处于Sync状态的话，需要先发送CAS WS_RD或者WS_FS命令进行WCK2CK Sync。read时RDQS作为DQ的strobe信号。而RDQS可以选择作为差分信号或者单端信号输出，甚至RDQS也可以disable掉。read的第一笔DQ信号会在RL+tWCK2CK+tWCKDQO点回来。
5. Write命令和read命令类似的需要CAS WS_WR或者WS_FS命令进行WCK2CK Sync。对于masked write而言16B/BG mode下只支持BL16， 8Bank mode下只支持BL32。而masked write之间需要更长的tCCDMW的时间，间隙比正常的tCDD增加4倍。
6. data copy low power function：该功能为optional功能，分read data copy和write data copy功能。其中write data copy功能为当通过CAS命令enable该功能时紧接着的Wrtie命令DQ1-7不需要驱动，而颗粒会将DQ0的数据复制到DQ1-7上，而DQ8-15也类似的。CAS命令需要指定BL16/BL32中哪些数据需要enable该功能，最小粒度是8个UI。而read data copy功能通过MR21[5]来enable，enable之后颗粒如果发现DQ1-7上连续8个UI数据均与DQ0相同的话会将DMI pin的第一个UI拉高来告诉控制器接下来的8个UI数据是read data copy数据，然后颗粒只驱DQ0，而DQ1-7为高阻态，DQ8-15类似。read data copy可以与read DBI功能同时打开，当DBI和rd data copy同时打开时，burst的每8个UI数据的第一个UI所有DQ都会输出，如果1的个数大于4个的话 则DM 作为read data copy功能， 当1的个数小于等于4的话则DM作为DBI信号。
7. write X operation：为optional功能，该功能是不需要驱动WCK和DQS的情况下实现整个burst都写0或者都写1。该功能通过CAS命令发送，当CAS 的WXSA/WXSB对应为高则都写1，为低则都写0。WCK可以不需要提供，所以可以更省电。
8. write DM与DBI与LPDDR4类似可以同时enable。

## 4 功能描述

### 4.1 bank模式配置

1. LPDDR5内部一共有16个独立的Bank，可以组成3种Bank模式，16Bank，4Bank group每个bank group包含4个bank以及8Bank模式。
2. 16Bank模式为16n预取最高速率3200Mbps，支持BL16/BL32两种模式，page size为2048。
3. 4BG/4BK模式与DDR4类似，也为16n预取，工作数据率要求高于3200Mbps，支持BL16，BL32，page size为2048.
4. 8Bank模式是将2个bank组合成一个bank，这样原有的16bank变成8Bank，原每个bank是16n预取，组合起来后每个新bank为16n+16n=32n预取，不管数据率3200Mbps以上还是以下都支持，只支持BL32，page size 为4096。
5. 另外位宽也分为x8(byte mode)和x16两种位宽模式，如果是x8的位宽的话上面提到的page size需要减半。
6. 对于BG mode(4BG/4Bk)下如果是BL32的话DQ上的数据行为会是两比BL16在中间间隔BL16的间隙。

### 4.2 ZQ Calibration

ZQ Calibration分为Background Calibration和command-base Calibration两种模式。 在DVFSQ模式下不支持ZQ calibration。

1. command-base Calibration和以往的颗粒类似的，通过发送zqcalib start命令开始校准ZQ，通过zqcalib latch将校准的结果更新生效。对于颗粒而言分ZQ Master die和non-ZQ Master die, 只有ZQ Master die才响应zqcalib start命令，而non-ZQ Master die会忽略该命令，控制器可以对所有颗粒发送zqcalib start命令也可以只对ZQ master die发送该命令。当zqcalib完成后发送zqcalib latch命令同步更新calibration结果时需要对所有die都发送，此时ZQ master die会将calibration结果同步并更新生效到non-ZQ master die中。根据non-ZQ master die的个数zqcalib latch命令耗时分为tZQCAL4，tZQCAL8，tZQCAL16 。LPDDR5内部ZQ Master die可能会不止一个。
2. background mode：颗粒定期（tZQINIT,MR28[3:2])在后台校准阻抗，当发现阻抗变化时MR4[5]（ZQUF）将置位。当该bit变化时控制器需要发送ZQCal Latch命令将最新的calib得到的阻抗更新生效。上电复位后会自动完成zqcalib，在Tg时间后需要发送zqcal latch命令更新阻抗。 如果backgroud calib enable的话zqcalit start命令会被颗粒忽略。该模式下如果需要马上做calibration的话可以通过MRW命令设置MR28[1]=ZQ stop，然后重新设置该寄存器颗粒会马上重新做calibration。
3. 在DVFSQ模式下需要设置MR28 op1=ZQ stop停止background calibration，然后使用ZQ reset命令将ZQ复位成初始值。

### 4.3 Link ECC

Link ECC为optional功能，分为Write Link ECC和Read ECC。

1. Write link ECC： 使用RDQS_t作为ECC bit的传输。对于burst32来说会被分成2笔16bit burst来做ecc。其中16bit DMI生成6bit ecc数据，16*8=128bit DQ数据生成9bit ECC数据，ECC数据一共15bit，burst的第0UI为空。ECC错误的结果会被记录在MR43-45中，其中MR43是错误的counter。实际错误需要从MR42中读取，无法实时的上报ECC结果，所以更多的只能是作为debug手段，对系统稳定性并无太大帮助。在时序上enable write link ECC会导致tWR/tWTR/tWTR_S/tWTR_L增加4个cycle。
2. Read link ECC：与write类似，DQ生成的9bit ECC数据通过DMI pin输出给控制器，与Write相比没有DMI数据所以少了5bit的DMI的ECC数据。 read ECC和read DBI以及read data copy功能是互斥的，不能同时打开。Enable read link ECC会增加额外的RL，例如如4800Mbps下需要增加2tck（1：4模式下换算过来是8个twck）。

### 4.4 Duty cycle adjuster 与duty cycle monitor

1. Duty cycle adjuster（DCA）：该模块位于颗粒内部WCK分频器前，可通过MR30来改变WCK的占空比用于补偿占空比异常的情况。从-7到7可调，值的调整并非线性的。调整WCK的占空比同样会影响到read输出的RDQS和DQ的占空比。所以调整WCK占空比的话实际上可以通过测量RDQS的占空比来观察DCA的效果。需要注意的是修改完WCK的占空比后建议重新做WCKCK leveling来重新对齐WCK与CK相位。
2. Duty cycle monitor（DCM）：用于监测WCK的占空比，结果通MR26输出，对应结果为1则表明占空比大于50%，为0则表明占空比小于50%。为了提高占空比统计的准确性增加了一个flip功能位于MR26[1]。当该功能enable之后会将WCK反转后再做DCM，也就是enable后统计的正脉宽的宽度是实际WCK负脉宽的宽度。可将enable Flip和disable Flip的结果做对比参考得到更准确的占空比值。Enable Flip功能后再通过DCA调整占空比的话实际DCA为正值则是加大Flip后WCK的正脉宽宽度。实际可以通过DCM和DCA结合起来调整使WCK的占空比尽量保持在50%。

### 4.5 DVFS

DVFS功能分DVFSC和DVFSQ功能。

1. DVFSC是动态调整core电压，当enable DVFSC时颗粒的core电压会自动在VDD2H和VDD2L之间切换，DVFSC功能需要通过在FSP的变频来enable或者disable。DVFSC只能在DQ数据率1600Mbps以下时才可以被enable。该功能enable的话tRCD/tRBTP会增加1ns，而tWR/tWTR需要增加7ns。
2. DVFSQ enable的话可以将VDDQ电压从正常的0.5v降低到0.3v。DVFSQ的变化也是建议跟随着FSP一起改变，而在DVFSQ enable的情况下ZQ calibration无法生效，所以需要用zq reset命令将阻抗reset到默认值。VDDQ切换后建议重新做training。

### 4.6 RDQS toggle mode

该模式下RDQS会持续输出，WCK也需要一直常供。在这个过程中read,write,power down,deep sleep,mrr等命令不允许被执行。不知道该模式具体是拿来做什么用的。

### 4.7 refresh management command

频繁的active命令会导致颗粒数据异常，所以需要管理ACT(active)命令的个数，当ACT命令达到一定程度时需要发送RFM或者refresh（REF）命令来避免这个问题。read MR27[0]描述当前是否需要RFM命令。

当RFMTH大于tREFIe时不需要额外的发送RFM/REF命令。当RFMTH小于tREFIe时控制器需要统计RAA的个数，当RAA达到RAAMMT时表明颗粒无法再接受ACT命令，这时候需要发送REF/RFM命令来减少RAA的值。

RAA：ACT command counter，需要控制器去统计ACT命令的个数。

RAAIMT: MR27[5:1] 需要RFM 命令的RAA counter阈值数，当RAA达到该值表明需要发送REF/RFM命令，但这时候还可以继续发active命令。

RAADEC: MR57[1:0]，表明RFM命令可以减少RAA counter的个数。每条RFM命令能减少的RAA counter的个数为RAADEC*RAAIMT。对于REF命令而言每条REF命令能减少的RAA counter个数为RAAIMT，而selfrefresh的进出并不会影响RAA counter的值。

RAAMMT：最大允许的RAA个数RAAMMT，当RAA counter达到该值时后续任何ACT命令都是不允许的。RAAMMT = RAAIMT*RAAMULT（MR27[7:6]）。

RFMTH=RAAIMT*tRC absolute min。

RFMSB：sub-banks支持的个数，如果为1表不支持sub-banks模式。

颗粒支持两种类型RFM模式，per-bank mode和sub-bank模式：

1. per-bank模式是按bank来统计ACT命令，每个bank一个RAA counter统计ACT命令的个数，当RAA超过极限值RAAMMT时就不能够发送active命令。这时候就需要REF/RFM来减少RAA的值后才能继续发ACT。
2. sub-bank模式是每个bank平均分成2（假设RFMSB=2）份，如有16384个row的话，则分成低8192row和高8192个row分开来统计ACT命令个数。每个bank需要2个RAA counter。如果其中一半row的ACT达到了RAAMMT后不影响另外一半row的正常ACT。RFM命令也会针对减小相应的RAA，不影响另一个RAA。计算方式与per-bank mode一样。

### 4.8 PASR＆PARC

PASR：通过MR23控制，共8bit对应容量的最高8个row的控制。如果对应bit为1的话则所有bank对应的row在selfrefresh下不会被刷新。

PARC：通过MR25[6]控制正常状态下的refresh命令如果遇到PASR中被mask的row直接跳过不执行refresh操作。

### 4.9 ODT行为

1. CA/CLK ODT对地。没有odt pin，通过寄存器配置直接生效，打开的话就一直处于enable状态了。
2. DQ odt：在write命令时会自动打开odt，结束之后关闭odt。odt值于MR11中配置，开启时间 ODTLon + tODTon,min. 关闭时间ODTLoff + tODToff.
3. WCK odt: 于MR18中配置。和CA odt类似的，只要enable后一直常开。不同的是pd/sr-pd/deep sleep下odt会被关闭。
4. CS odt：只有RZQ/3和disable可选(MR17[4])。在CA/CLK odt pd，sr，sr-pd，deep sleep下均保持原来的状态。
5. NT-ODT: 实际上就是总线空闲时enable的一个odt，在read/write时对应用到的信号线odt disbale掉。不允许sync odt disable，而nt-odt enable的情况。如果NT-ODT enable的话MR17中的soc odt的设置值需要设置为NT-ODT和真正SOC 端ODT并联的等效值。

### 4.10 TCSR

由于lp5和主控贴一起可能导致soc的高温传到到LP5上，而高温点离Lp5的温度传感器较远，无法感知到，这会导致刷新率不够引起数据不可靠。可以通过TCSR（MR13[0:1]）让颗粒的温度传感器采样到的值加一个固定的温差来补偿。

### 4.11 single-ended mode

 在1600Mbps下CLK,WCK,RDQS可以工作在单端模式下来减小功耗，ODT/NT-ODT在该模式下需要disable。而RDQS甚至可以disable掉，这需要PHY确保自己能够正确采样到DQ。

WCK/RDQS单端差分的切换可以直接通过MRW 或者fsp修改， 而clk只能是FSP变频下修改。

## 5 training功能

### 5.1 command bus training

CBT与LPDDR4类似，但是由于需要支持Byte mode，实际只有DQ0-7在CBT时有效。DQ8-DQ15不起作用，由于少了CKE pin，所以发送完MRW后通过驱高DQ７来进入CBT。分mode1和mode2两种模式。其中mode1只对CA进行training而不能设置Vrefca。mode2多了一个Vrefca的设置功能，同DMI来选DQ是作为output还是input，在DMI的上升沿将DQ的值更新入VrefCA中。

### 5.2 read dq calibration

与LPDDR4类似，通过read dq calib 命令从read 回MR34/MR33的值， 而MR31/32 MR20[7]的值决定对应的DQ是invert或者为0 。

### 5.3 WCK-DQ training

1. 类似Write DQ training。为了达到更高的速度和省功耗的目的，DQ在颗粒内部的路径会比DQS更短。通过write/read FIFO来training。在Write FIFO时DBI的功能和DQ一致。也就是DMI的值会被写入到FIFO，而Read FIFO能够读出写入的DMI值。FIFO深度为BL16*8 per pin（DMI也有）。read/write FIFO固定BL16 模式。read FIFO是循环的读出FIFO[0]-[7]的数据。 如果write FIFO 命令写入少于8个FIFO的话，read 读出来的只有前几个写过的是写入的值。而后面的fifo读出来是undefined的值。例如write FIFO只写入3个的话， read依然是0..7->0...7循环，只有0-2读出来是写入的值，而3-7是undefined值。在WR/RD FIFO时 DM，WR/RD/DBI/ ECC/ DATA copy 均无效。FIFO指针在上电，reset，pd，deep sleep，sr-pd下会被复位。
2. DMI输出模式在read FIFO和read dq calib时支持两种控制模式（optional），模式1是受rd dbi/ecc/ copy的mr配置决定。模式2是只要write DM或者DBI enable的话，就算read DBI/ECC，read data copy的配置是disable，read DMI output也会被enable。这样的好处是不需要在做write training的时候特地去修改RX DMI的配置。
3. WCK-RDQS_t/pariyt training mode：enable write link ECC的话RDQS_t会作为ECC信号，所以rdqs_t也需要被training。可以通过MR46[2]=1enable RDQS_t的training。Enable后RDQS_t的数据会被写入到原来DMI写入到FIFO的位置，读FIFO的话数据则会通过DMI返回。也就是说该模式enable的话DMI就没法被training了。该模式只能在超过1.6G的WCK 频率下才能enable。

### 5.4 read/write base WCK-RDQS_t training

除了前面5.3中WCK-DQ training中用rd/wr FIFO来实现wck-rdqs_t/parity training 外，还支持通过Read/Write 命令来实现WCK-RDQS_t的training（optional的，需要通过MR26[6]来确认是否支持），通过MR26[7]来enable。该功能其实就是在在正常read/write命令时让rdqs_t pin替代DMI pin的功能来实现training，training过程中的数据是真实写入到ddr中的，不管Write DBI是否enable DMI pin都会被颗粒忽略。

## 6 timing对比

1. 影响RL功能：RL受byte mode，RD DBI and/or RD data copy，DVFSC，read link ECC影响。

  同样的MR设置值，不同的功能enable的情况下对应的RL不同。见JESD209-5A Page244. 7.4.8。

2. WL不受Byte Mode, Write DBI/ Data copy, ECC影响，分Set A和Set B，通过MR3[5]来选择。

3. DVFSC enable的话除了RL受到影响外，tRCD/tRBTP增加1ns, tWR/tWTR 增加7ns。

4. 8 bank mode相对16B，BG mode tFAW从20ns增加到40ns，tRRD从max(5ns,2tck)增加到max(10ns, 2tck)。

5. byte mode相对x16 mode, tWR和tWTR 增加了2ns。

6. write link ECC：使tWR/ tWTR增加4ns。

7. 同样3200数据率下RL等效36个cycle，WL等效20个cycle。相比LPDDR4对应的28/14，差距还是比较明显。

## 7 遗留的疑问

1. WCK-DQ training 如果enable wck-rdqs_t/parity training的话DMI的输入会被忽略掉，那是否意味着要做RDQS的training的话就必须做两次training，一次做DMI一次做RDQS呢。
2. 既然WCK2CK fast sync的时间又快，又可以用于RD/WR又可以同时作用与多rank这么好，为什么还需要存在WCK2CK sync WR/RD呢。
3. WCK2CK sync fast如果工作在多rank的情况下rank0/rank1的WCK都需要供着，而Rank0，Rank0的tWCK2CK如果不一样的话怎么同时供呢。
4. WCK2CK sync WR和RD内内部实现原理上有什么区别呢，为什么需要分开来两个命令呢。
5. 关于tRRD_L的描述Page263中有tRRD_L 而Page219中并没有tRRD_L而Page416有L, Page455又没有L。对于BG mode到底有tRRD_L这个timing么。
6. 关于MR25定义中的note2描述，当MR25的op5所有的CA odt都是disable的话vref ca用一个固定的值，这个值是多少呢？而不是vrefca么？
7. CS RTT怎么算呢。
8. WCK2DQ Oscillator结果怎么看呢，如何换算成时间值。
9. DFE是拿来作什么的，说明的时序图里只是write时DQ多发了2个UI的0电平。Read的行为是什么样的呢？
10. 关于rdqs当单端信号使用的时候，Page404的note7描述可以让rdqs_c作为rdqs的单端信号。page236中的描述只有rdqs_t才可以作为rdqs的单端信号使用？
11. page392中MR27的描述和page173中MR27的描述不同。
12. 关于RFM，是否FMTH > trefie的话就算RAA超过RAAMMT也不需要额外发RFM命令是么。
13. WL 的Set A和Set B 的目的是什么 为什么要多一个Set B呢。
14. RDQS toggle mode一般拿来干嘛呢。
15. 以上均是JESD209-5A中的疑问，JESD209-5A是最新版本的么，其中还有很多错误以及很多TBD。

