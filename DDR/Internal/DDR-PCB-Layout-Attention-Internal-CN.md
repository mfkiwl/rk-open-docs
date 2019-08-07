# **DDR 布板注意事项**

发布版本：1.3

作者邮箱：hcy@rock-chips.com

日期：2018.10.08

文件密级：内部资料

---------

**前言**
记录所有平台的 DDR 布板注意事项

**概述**

**产品版本**

| **芯片名称**                                 | **内核版本** |
| ---------------------------------------- | -------- |
| 所有芯片(包括 28 系列、29 系列、30 系列、31 系列、32 系列、33 系列、PX 系列、1108A) | 所有内核版本   |


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

--------------------
[TOC]
------
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

-----
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

----
##  RK3399 特殊要求
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

-----
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