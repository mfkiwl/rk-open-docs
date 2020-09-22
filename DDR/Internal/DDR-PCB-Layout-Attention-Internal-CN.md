# DDR 布板注意事项

文件标识：RK-SM-YF-38

发布版本：V1.5.0

日期：2021-01-21

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
记录所有平台的 DDR 布板注意事项

**概述**

**产品版本**

| **芯片名称**                                                 | **内核版本** |
| ------------------------------------------------------------ | ------------ |
| 所有芯片(包括 28 系列、29 系列、30 系列、31 系列、32 系列、33 系列、PX 系列、1108A、RV11系列) | 所有内核版本 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

硬件工程师

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明**                   |
| ---------- | ------ | ------ | -------------------------- |
| 2017.11.02 | V1.0   | 何灿阳    |                            |
| 2017.11.09 | V1.1   | 陈炜     | 更改某些表述                     |
| 2017.01.14 | V1.2   | 汤云平    | 增加 RK3326 描述及 LPDDR2/LPDDR3 要求 |
| 2018.10.08 | V1.3   | 陈有敏    | 增加总容量 3GB 说明和 RK3399 单通道布线要求   |
| 2020.06.02 | V1.4.0 | 汤云平 | 增加RV1126/RV1109相关要求 |
| 2020.01.21 | V1.5.0 | 汤云平 | 增加RK3566/RK3568相关要求，以及更新RV1126/1109描述 |

**目录**

---
[TOC]
---

## 名词说明

- **颗粒**：指各种 DDR memory，DDR3 memory、DDR4 memory、LPDDR3 memory、LPDDR4 memory、LPDDR2 memory

- **CS**：主控或 DDR memory 的片选信号

- **rank**：就是 CS，就是片选信号

- **byte**：主控每 8 根 DDR 信号线，成为一个 byte。所以 byte0 指 DQ0-DQ7，byte1 指 DQ8-DQ15，byte2 指 DQ16-DQ23，byte3 指 DQ24-DQ31。注意，这里的 DQ 都是说主控的，颗粒的 DQ 不一定跟主控的 DQ 是一一对应连接的。

- **bank**：是指 DDR memory 的 bank 数量

- **column**：是指 DDR memory 的 column 数量

- **row**：是指 DDR memory 的 row 数量

- **AXI SPLIT**：非对称容量组合模式，如高位寻址区为 16bit 位宽，低位寻址区为 32bit 位宽。例如常规的组合为 256x16+256x16，而 AXI SPLIT 的组合为 256x16+128x16=768MB，在高位寻址区只剩 16bit 位宽，示意图如下图。

  ![AXI_SPLIT](DDR-PCB-Layout-Attention-Internal\AXI_SPLIT.png)

---
## 总的要求
总的要求适用于所有平台，各款主控的特殊要求，后面单独列出

**1、DQ 的交换，不能超出该组 byte，只能在 byte 内部进行交换。有些主控有特殊要求，byte 内部都不能交换，见具体主控的特殊要求**

原因：因为 DDR 协议，每组 byte 的 DQ 信号，总是与该组的 DQS 信号同步。如果 DQ 被换到另一组 byte，会导致 DQS 同步信号用错。

**2、用到 2 个 CS 上的 bank、column 数量不同的 DDR 颗粒，需要跟软件确认是否支持**

原因：不同的 bank、column 数量需要有 2 个 CS 的 ddr_config 来选择，而我们的 ddr_config 和控制器，都是采用一个寄存器来控制 2 个 CS，因此要求 2 个 CS 的 column 必须一样。
某些主控有对 1-2 个不同 column 的配置有支持，还有些是 DDR 颗粒不同的 bank 或 column 刚好可以找到一个 ddr_config 配置项可以用，要看 column 不同的情况。所以，具体情况还请找软件确认。

**3、如果颗粒只有一个 CS，只能接在主控的 CS0 上**

原因：控制器的设计限制

**4、如果只用一个通道，只支持通道 0**

原因：代码写死，否则代码变复杂

**5、如果颗粒 2 个 CS 的容量不同，则容量小的应该放在主控的 CS1 上**

原因：软件设定的前提，否则要改软件，软件变复杂，而且有的芯片本身不支持

**6、所有平台，不支持大于 2 个 CS 的颗粒**

LPDDR4 有大于 2 个 CS 的颗粒，如果使用，只能用到 2 个 CS

**7、如果颗粒只有一个 ODT（像 LPDDR3），应该连到 ODT0 上**

原因：控制器的设计限制

**8、6Gb、12Gb 的使用比较特殊（8Gb、4Gb、2Gb 没有这条限制）**

目前只支持一个通道上的 2 个 CS 都是 6Gb 或者 2 个 CS 都是 12Gb 的，不支持 6Gb、12Gb 与 8Gb、4Gb、2Gb 混合在 2 个 CS 中使用。
比如：

| CS0  | CS1  | 支持情况                  |
| ---- | ---- | --------------------- |
| 6Gb  | 6Gb  | 支持                    |
| 12Gb | 12Gb | 支持                    |
| 6Gb  | 12Gb | 不支持  违反要求 5，并且这样组合也不支持 |
| 12Gb | 6Gb  | 不支持，  这种组合也不支持        |
| 8Gb  | 6Gb  | 不支持  8Gb 和 6Gb 混合在 2 个 CS 中  |
| 12Gb | 8Gb  | 不支持  12Gb 和 8Gb 混合在 2 个 CS 中 |
| 6Gb  | 4Gb  | 不支持  6Gb 和 4Gb 混合在 2 个 CS 中  |
| 12Gb | 4Gb  | 不支持  12Gb 和 4Gb 混合在 2 个 CS 中 |

**9、颗粒的 RZQ 不能共用**

一块板子上贴多颗颗粒或者一个颗粒上有多个 RZQ pin（如 dual die 的 LPDDR3）的话，必须每个 RZQ pin 单独接一个 240ohm 的电阻。

**10、DDR4 目前连接方式暂无特殊要求**

**11、外接 LPDDR2 或 LPDDR3 时，DDR0 的 DQ0-DQ7 应该一一对应的连接到 DRAM 的 DQ0-DQ7**

由于 LPDDR2/LPDDR3 Mode Register read 的数据是通过 DQ0-DQ7 读回来，所以需要保证 DQ0-DQ7 的连接是一一对应的。如无法保证 DQ0-DQ7 一一对应的话需与软件确认。

**12、双通道 DRAM 总容量 3GB 支持情况**
双通道 DRAM 总容量 3GB 支持的颗粒组合如下图：

  ![DRAM_3GB](DDR-PCB-Layout-Attention-Internal\2x_channel_DRAM_3GB.png)
  说明：1）RK3288，RK3399 支持双通道。

**13、单通道 DRAM 总容量 3GB 支持情况**
单通道 DRAM 总容量 3GB 支持的颗粒组合如下图：

  ![DRAM_3GB](DDR-PCB-Layout-Attention-Internal\1x_channel_DRAM_3GB.png)

---
## RK3399 特殊要求
**1、 CS2 是 CS0 的复制信号，CS3 是 CS1 的复制信号，其行为与被复制信号完全一样**

因此对于 DDR3，LPDDR3，实际只能使用 2 个 CS。CS2，CS3 主要是给 LPDDR4 使用的，因为 LPDDR4 颗粒一个 channel 是 16bit，当要让主控达到 32bit、2CS 时，就需要用到 4 根 CS 信号。

**2、CLK 走线必须比该通道任意一组 DQS 都长，ddr PHY 的要求**

原因：Vendor 无法提供准确的 CLK 需要比 DQS 长多少的数据，layout 上能长多少尽量长多少。

**3、LPDDR3 的 D0-D15 必须和主控完全一一对应的连接**

原因：因为有用到 LPDDR3 的 CA training，数据会按顺序输出到 D0-D15，所以这些信号不能对调，必须一一对应的连接

**4、LPDDR3 的 D16、D24 这 2 根数据线也必须和主控完全一一对应连接**

原因：cadence 方案的 training 有用到 DQ Calibration，而 DQ Calibration LPDDR3 一定是从 D0、D8、D16、D24 吐出数据，其他数据线不一定有数据吐出，所以额外还需要 D16、D24 要一一对应。（D0、D8 在前一条规则已经要求了）。

**5、注意主控一个通道与 LPDDR4 颗粒 2 个通道的组成关系**

​    a. LPDDR4 366/272 球封装均为 64bit 带宽，每 16bit 为一个 channel，RK3399 为 32bit 一个 channel，所以 RK3399 每个通道挂 2*channel 的 LPDDR4

​    b. LPDDR4 366/272 颗粒每 2 个 channel 共用一个 ZQ。

​    c. 设计要求不共用 ZQ 的 channel 组合成一个 32bit 连接到 RK3399。如下图，不能把 Channel A 和 Channel D 拿来组合。也不能把 Channel B 和 Channel C 拿来组合。这 2 组 Channel 都是共用一个 ZQ 的。

![LPDDR4_ZQ](DDR-PCB-Layout-Attention-Internal/LPDDR4_ZQ.png)
目前通过 Micron、Samsung、Hynix 三家颗粒的 Channel A\B\C\D 定义来看，采用颗粒的 Channel A + Channel C 组成一个 32bit，和 Channel B + Channel D 组成一个 32bit，这种方法，能做到三家颗粒都可以避免 ZQ 共用的问题。所以，改版后的 LPDDR4 都采用这种方式的连线。

**6、LPDDR4 的 RZQ 要通过 240 电阻接 VDDQ，而不是 GND，这点要注意，RK3399 主控端没有变，还是一样 RZQ 通过 240 电阻接 GND**

**7、接 LPDDR4 时，主控端的 DDR0_ODT0/1，DDR1_ODT0/1 悬空，不用连到 LPDDR4 颗粒。而颗粒端的 ODT_CA_X 默认通过 10K 电阻上拉到 VDDQ，暂时预留 DNP 的下拉电阻**

**8、LPDDR4 所有数据线（DQ）都不能对调，不管组内，还是组间**

​    即 DDRx_D0-D15 必须一一对应的连接到一个 LPDDR4 颗粒通道的 D0-D15；DDRx_D16-D31 必须一一对应的连接到另一个 LPDDR4 颗粒通道的 D0-D15；原因：

​    对单个 LPDDR4 channel 来说（16bit），MRR 功能需要用到 DQ[0：7]；CA training 功能需要用到 DQS0、DQ[0:6]、DQ[8:13]；RD DQ Calibration 用到 DQ[0:15]和 DMI[1:0]。所以，所有数据线都不能对调。

   额外说明：

​    假设原来 DDRx_D0-D15 是连到 LPDDR4 颗粒的 channel A，DDRx_D16-D31 是连到 LPDDR4 颗粒的 channel C。
如果希望将 A/C 通道的互连关系对调，即 DDRx_D0-D15 连到 LPDDR4 颗粒的 channel C，DDRx_D16-D31 连到 LPDDR4 颗粒的 channel A。则这种对调方式，是允许的。但需要满足上面第 5 点的要求，保证 LPDDR4 上共用 ZQ 的通道不组合成 32bit。

**9、如果只用 channel 0，channel 1 也需要供电**

原因：RK3399 DDR 变频时是通过 CIC 模块控制 DDR 频率切换，而 CIC 模块要求两个 channel 要同时切换。即使 channel 1 上没有接 DRAM，也需要对 channel 1 的 controller 和 PHY 进行初始化，否则 CIC 模块控制 DDR 频率切换时，会出现由于 channel 1 异常，导致 CIC 模块状态出错，DDR 变频失败。

 因此对于单通道使用场景（channel 0 有接 DRAM，channel 1 没有接 DRAM），也需要对 channel 1 进行供电（DDR1_AVDD_0V9,DDR1_CLK_VDD,DDR1_VDD），否则 channel 1 上的 controller 和 PHY 无法完成初始化，影响 DDR 变频功能。

---
## RK3326、PX30 特殊要求
**1、支持的位宽组合方式**

1. 32bit 最大位宽（大容量 16bit+小容量 16bit），举例：256x16+128x16=768MB。
2. 16bit 最大位宽（大容量 8bit+小容量 8bit），举例：512x8+256x8=768MB。

**2、颗粒要求**

AXI SPLIT 模式下，要求所有颗粒的 column,bank 是相同的。

**3、连接要求**

1. AXI SPLIT 模式下，要求在使用 16bit 位宽的颗粒时，需要将 AP DDR 控制器的 byte0/1 接在一个颗粒上，将 byte2/3 接在一个颗粒上。
2. AXI SPLIT 模式下，要求较大容量的颗粒连接到 AP DDR 控制器的低位区，如 byte0 或 byte0/1,举例：16bit a 颗粒+16bit b 颗粒组成 32bit 位宽，如果 a 颗粒的容量大，则 a 颗粒连接到 byte0/1。
3. 如果使用 2 个 CS，则只有 CS1 支持 AXI SPLIT，允许两种方式：
   1. CS1 上采用非对称容量，如 CS0 上为 32bit 总位宽，则 CS1 上采用大容量 16bit+小容量 16bit 颗粒拼接成 32bit，如 CS0 上为 16bit 总位宽，则 CS1 上采用大容量 8bit+小容量 8bit 颗粒拼接成 16bit。
   2. CS1 上只贴一半位宽的颗粒，要求其 row<=CS0 上的颗粒。如 CS0 为 32bit 总位宽，则 CS1 贴 16bit 的颗粒，如 CS0 为 16bit 总位宽，则 CS1 贴 8bit 的颗粒。

**4、下表列举出了所有支持的 AXI SPLIT 的容量组合。该表格之外的 AXI SPLIT 组合都不支持。**

| NO.  | CS0                          | CS1                                 | 支持情况 |
| ---- | ---------------------------- | ----------------------------------- | ---- |
| 1    | 16bit 最大位宽（大容量 8bit+小容量 8bit）   | 无颗粒                                 | 支持   |
| 2    | 32bit 最大位宽（大容量 16bit+小容量 16bit） | 无颗粒                                 | 支持   |
| 3    | 32bit 固定位宽                    | 32bit 最大位宽（大容量 16bit+小容量 16bit）        | 支持   |
| 4    | 32bit 固定位宽                    | 16bit 固定位宽，接 Byte0/1（row<=cs0 上的颗粒 row） | 支持   |
| 5    | 16bit 固定位宽                    | 16bit 最大位宽（大容量 8bit+小容量 8bit）          | 支持   |
| 6    | 16bit 固定位宽                    | 8bit 固定位宽，接 Byte0（row<=cs0 上的颗粒 row）    | 支持   |

**5、常规应用同其他平台一致。**

---

## RV1126/RV1109需求

**1、DQ对调**

1. DDR3：所有DQ顺序组内可任意对调，DQS组间可任意对调。

2. DDR4：由于read training使用了MPR的stagger mode，DDR4颗粒不同DQ上返回的数据会有4种类型，假设将返回的4种数据类型分别命名为pattern0-3的话，颗粒的DQ0，DQ4，DQ8，DQ12返回pattern0。DQ1，DQ5，DQ9，DQ13返回pattern1。DQ2，DQ6，DQ10，DQ14返回pattern2。DQ3，DQ7，DQ11，DQ15返回pattern3。在做read training时PHY可以配置每个DQ返回的数据类型。由于loader代码中在做read training时每个DQ的pattern是写死的，为了保证一个loader能够兼容所有的模板，确定其中一种连接方式的pattern顺序写入到loader中后，后续其他DDR4模板需要保证PHY DQ上连接的DQ与loader中设置的返回pattern一致，否则read training会报错。例如当前PHY DQ0连接到颗粒的DQ14，实际返回的是pattern2，则新模板可以将DQ0连接到DQ10，DQ14均可。目前Loader是按模板“RV1126_RV1109_EVB_DDR4P216DD6_V10_2020219”设置的。

3. LPDDR3：由于MRR的数据是从DQ0-7返回，Loader中目前将MRR返回的数据按模板“RV1126_RV1109_EVB_LP3S178P132SD6_V10_20191227”的连接顺序对调后得到正确的MRR值。所以后续模板必须与该模板的DQ0-7保持一致的连接顺序，否则MRR的结果会出错。

4. LPDDR4：由于CA Training会用到所有的DQ，所以所有的DQ需要保持一一对应。PHY端LPDDR4的Byte顺序和其他类型颗粒并不同，具体参考“RV1126_RV1109_EVB_LP4S200P132SD6_V10_20200205.pdf”。

5. DDR3/4有高低16bit贴不同容量颗粒需求的模版、总位宽16bit的模版、以及16bit/32bit兼容的模版，这3种模版必须保持一样的PHY和DQS对应关系，不允许这3种模版对应关系变化。

   原因：对于16bit位宽模式颗粒必须连接在DQS0和DQS1上，高低16bit贴不同容量颗粒必须是DQS0和DQS1上贴大容量的那颗颗粒。而这一版本的PHY提供了PHY的BYTE整组对调的功能，具体参考PHY文档“4.4.1 DQ PAD Map”章节。如loader设置上将PHY的DQS2组和DQS1组对调的话，可以看做PHY IO上命名的DQS2组实际上已经是DQS1组了。这时候16bit模式实际上就需要将PHY的DQS0和DQS2连接到颗粒上。目前DDR3/DDR4 loader配置是按模板“RV1126&RV1109_EVB_DDR3P216SD6_V10_20191227”和“RV1126_RV1109_EVB_DDR4P216DD6_V10_2020219”配置的，其他模板也需要遵循这两个模板的顺序。

**2、等长控制**

1. 对于CA/CMD：LPDDR4由于目前CA training还未搞定所以也需要做等长，待CA training搞定后LP4的CA可以不做等长。其他类型的颗粒必须等长。虽然DDR3/DDR4可以开2T mode，但是在做read/write training，wrlvl，read gate时PHY并不会使用2T mode所以也不能因为可以开2T mode来放宽。

2. CLK和DQS之间的相位差控制在±640ps左右。

   原因：1. 颗粒wrlvl的原理决定DQS和CLK的相位差不能超过1个cycle。2. PHY wrlvl的原理是CLK固定一个de-skew值，DQS的de-skew从0开始增大寻找DQS与CLK上升沿对齐的点。PHY的de-skew一共64个单位每个单位20ps。目前CLK de-skew的default值设置为0x20，所以CLK与DQS之间的相位差可以是-640ps到640ps。但是还需要考虑为DQS和DQ training留下一些de-skew余量，CLK/CMD留下一些de-skew余量，与硬件约定CLK和DQS之间的相位差控制在±150ps内。

3. 对于DQS/DQ所有类型的颗粒都可以不做等长，但是需要保证如下几点：

   1. DQS和DQ之间的长度差控制在200ps内。

      原因：read training和write training时DQS的de-skew保持在中间值0x20附近，DQ从0增大到0x3f。为了给DQ左右各留到400ps左右的margin以取到中间值。所以实际DQ相对DQS的长度差需要控制在±200ps内。

   2. 由于de-skew受温度电压影响会有±20%的误差。De-skew每个单位典型值是20ps实际值可能是16-24ps。由于不等长是通过de-skew来补偿的，当DQS和DQ之间的长度差200ps时，DQS和DQ设置的de-skew差为10个。这时候实际补偿值可能会是160-240ps。会吃掉±40ps的margin，需要保证在极限频率下能够多预留这±40ps的margin出来，否则的话需要考虑减小DQS与DQ的长度差。

   3. 由于write training PHY没做DM的training，PHY直接将DM和组内的DQ0设置为一样的de-skew值。所以实际需要让DM0和DQ0，DM1和DQ8，DM2和DQ16，DM3和DQ24等长。

---

## RK3566/3568需求

### DQ的对调

除DDR4的DQ变为可以任意对调外，其他和RV1126类似。具体规则如下。

1. DDR3：所有DQ顺序组内可任意对调，DQS组间可任意对调。

2. DDR4：使用提前写入到DDR的数据来做read training，所以不带ECC的版本所有DQ顺序组内可任意对调，DQS组间可任意对调。带ECC的版本由于写入到ECC byte的数据是自动生成的不受控，所以无法使用提前写入到DDR中的数据来做read training，还是和RV1126一样的通过MPR寄存器来做read training，所以所有带ECC的DDR4板子所有的DQ需要保持一样的顺序。

3. LPDDR3：由于MRR的数据是从颗粒的DQ0-7返回，Loader需要对返回的数据按照PCB的DQ连接顺序对调一遍。所以所有的LPDDR3模板颗粒的DQS0以及DQ0-DQ7连接到主控的顺序需要保持一致。其他DQS/DQ的顺序不做要求。

4. LPDDR4/LPDDR4x：由于CA Training会用到所有的DQ，所以所有的DQ需要保持一一对应。具体Byte顺序需要按照硬件同事与Inno沟通的最终结果对应连接。

5. DDR3/4总位宽16bit的模版、以及16bit/32bit兼容的模版，这2种模版必须保持一样的PHY和DQS对应关系，不允许这2种模版对应关系变化。

   原因：对于16bit位宽模式颗粒必须连接在DQS0和DQS1上，高低16bit贴不同容量颗粒必须是DQS0和DQS1上贴大容量的那颗颗粒。而这一版本的PHY提供了PHY的BYTE整组对调的功能。如loader设置上将PHY的DQS2组和DQS1组对调的话，可以看做PHY IO上命名的DQS2组实际上已经是DQS1组了。这时候16bit模式实际上就需要将PHY的DQS0和DQS2连接到颗粒上。

### 长度的控制

**1. CMD/Address线**

1. DDR3/DDR4：默认开启2T mode，这版芯片的2T可以做到前后各增加半个cycle的margin。所以除CS/CKE/ODT外的其他CMD/ADDRESS线可以不做等长，延迟需要控制在半个cycle以内。而CS/CKE/ODT由于没有2T mode依然需要对CLK做等长。
2. LPDDR3：由于没有2T以及CA traininng，所以需要对CA做严格等长。
3. LPDDR4/4x：1/2cs的情况有做CA training，CA可以不需要等长。
4. LPDDR4/4x 4CS的情况：4cs CA training异常，CA需要严格等长。

**2. CLK于DQS的长度差**

RK3566/RK3568的CLK和DQS的de-skew为4UI，考虑到需要为CA/DQ training留够magrin，建议CLK/DQS之间的长度差控制在±1UI内。UI：半个CLK cycle，如1.6GHz(3200Mbps)下为312ps。

**3. DQS/DQ的等长**

RK3566/RK3568做了如下优化：1. 对de-skew进行了PVT补偿，2. 调整范围增加到了4UI，3. 所有类型的颗粒增加TX方向的DM training，而RX方向只有LPDDR4/LPDDR4x有DM的training。

RX方向的DM在DDR4 开启DBI功能下也需要使用到，所以如果DDR4开启DBI功能的话需要保证DM和组内的第一个DQ等长，否则DM也不需要等长。而当前暂时没有开启DBI功能的需求，所以DDR4 DM也可以不需要做等长处理。后续如果有DBI需求的话再考虑重新layout。

DQS/DQ处上面描述提到的DDR4可能存在的DM的特殊需求外均可不做等长。