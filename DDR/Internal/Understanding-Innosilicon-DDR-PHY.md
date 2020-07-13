----------------------------
**Rockchip**
# **Innosilicon DDR PHY解读**

发布版本：1.0

作者邮箱：typ@rock-chips.com

日期：2017.12.04

文件密级：内部资料

---------
# 前言
**提供RK内部同事了解inno DDR PHY的一个途径**

------
**产品版本**
| **芯片名称**                                 | **内核版本** |
| ---------------------------------------- | -------- |
| RK292x,RK3026,RK3028A,RK3036,RK312x,RK322x,RK322xH,RK3366,RK3368,RK1108,rk3326 | 所有内核版本   |

**读者对象**
RK内部工程师

**修订记录**
| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2017.12.04 | V1.0   | 汤云平    |          |

--------------------
[TOC]
------

# 芯片对应PHY的版本

| **平台**                          | **版本** |
| ------------------------------- | ------ |
| RK3036/RK3026/RK3028A/RK3126B/C | V2.62  |
| RK3126/RK3128                   | V2.63  |
| RK3368                          | V2.65  |
| RK3366                          | V2.66  |
| RK3228                          | V2.70  |
| RV1108                          | V2.72  |
| RK3228H/RK3328                  | V2.84  |

------

# DDR PHY 需要实现的功能

​	DDR 控制器和DDR PHY 之间是通过DFI接口连接的，DDR PHY的主要功能是将DDR控制器发出的各种数字信号转换成DDR颗粒能够识别的模拟型号，以及DDR颗粒发出的模拟信号转换成DDR控制器能够识别到的DFI信号。类似模数数模转换。所以主要就是Command/Address ，write信号的转发和Read信号的接收。

-----
# DLL

​	DDR PHY中的DLL与DDR颗粒中的DLL实现的目的完全不同，DDR颗粒中的DLL主要是为了ODT的开关timing和tDQSCK能够更精确。 而DDR PHY主要是为了CLK与CMD/ADDRESS 之间，read write DQS与DQ之间相位的精确控制。Inno DDR PHY的DLL 主要是一个MASTER DLL和9个SLAVE DLL：CMD/CLK共用一个SLAVE DLL, Write 每组DQS/DQ共用一个SLAVE DLL， Read 每组DQS/DQ共用一个SLAVE DLL。

1. CLK和CMD/ADDRESS 之间的相位

   1. 对DDR3/DDR2/DDR4 来说CMD和CLK之间的相位是180°，这个180°是通过4x clk 直接触发出来的，而不需要dll参与。
   2. 对于LPDDR2/LPDDR3来说 CMD与CLK之间90°的相位差是通过一个4x clk 固定的180°加上CMD DLL产生的90°来实现90°。如果是DLL bypass mode的话90°相位差是通过4x clk直接生成。

2. Write DQS与DQ之间的相位

   1. 在DLL normal mode下write DQS与DQ之间90°的相位差是通过DQS/DQ TX DLL直接实现90°相位差。
   2. 在DLL bypass mode下（寄存器地址0x290控制是否bypass）由4x CLK直接实现90°。 所以inno的dll bypass下也能够准确的实现write 相位控制。
   3. Inno建议Write DLL 调整方位不要超出67.5°到112.5°。否则存在不稳定现象。

3. Read DQS与DQ之间的相位

   1. Read DQS和DQ之间需要实现一个90°相位差，DQS与DQ之间的相位差是由DQS路径上一个固定的延迟加上DLL延迟组成。

      DQS路径上固定的延迟我们跑不了800M的PHY 一般在300ps左右， 能够跑800M的PHY在150ps左右。

      由于DQS存在一个固定的延迟所以DLL的设置需要根据频率来定0°，22.5°，45°或者67.5°。

   2. Read DLL无法工作在bypass 模式。

4. Master DLL lock状态查看

   寄存器地址0x3e4 bit[5:0]: DLL lock value. 如果为全0或者全1 则表示DLL 处于unlock状态。

------

# DQS gate calibration

​	又称作Read gate training，原理上是DDR PHY的DQS/DQ pin脚是双向的，DQS/DQ需要在Rx，Tx，高阻态之间切换，而当Read命令发出后到DQS/DQ数据回来的这个时间不同的板子是不一样的，DDR  PHY需要根据不同的板子training出一个确定的窗口来讲DQS/DQ pin设置为Input 状态来采样回正确的数据。换句话说这个DQS gate 就是DDR PHY DQS/DQ pin设置为Input状态的一个gate 窗口。Inno的DDR PHY 在做DQS gate calibration 时仅仅采样了DQS的信号，并不关心DQ的数据是否正确，所以Inno 的DDR PHY DQS gate calibration的结果只能是反应DQS的连接性，而不能反应DQ的连接性。

1. 292x,302x,312x,3036 的DQS gate calibration

   默认只training cs0 的DQS作为所有cs gate结果，无法区别cs来training。

2. rk3368,rk3366,rk322x,rk1108,rk322xh 的DQS gate calibration

   ​	增加了两个cs分开来training的功能，寄存器地址0x8 的bit[4:5] 控制对哪个cs做training。 不过该training存在bug。

   ​	偏移0x8 的地址bit4-5 如果选择00 的话实际上是有两个training窗口，cs0 一个cs1一个，在实际的访问过程中phy会自动切换cs0的窗口和cs1的窗口。如果bit4-5设置为cs0 或者cs1的话使用的过程中只会使用选中的那个cs的窗口，并不会根据cs做窗口切换。实际上寄存器上能观察到的值只有最后一次training的cs 的值，前一次training的另一个cs的窗口值没法通过寄存器知道。

   ​	training的时候如果是training cs0 的话，偏移0x8 的地址需要配置为0x20->0x21->training ->0x20->0x00  同样的cs1 也是  如果training完之后直接从0x21或者0x11 切到0x0 会导致竞争问题。如果只用cs0的training 结果应用到所有cs上的话可以0x20->0x21->training->0x20 结束training，同理用cs1的话 就是0x10->0x11->training->0x10.

   ​	两个cs training存在如下bug：当两个cs的training结果在1xclk cycle上差1的话 gate 在两个cs直接切换需要一定的时间，所以read to read in different rank需要额外的加入cycle 来避免这个问题。

3. rk3368,rk3366,rk322x,rk1108,rk322xh DQS gate calibration bypass

   1. 寄存器偏移地址0x8 bit[1]设置为1 为bypass mode

      | **ADDR** | **BIT** | **DEFAULT** | **DESCRIPTIONS**                         |
      | -------- | ------- | ----------- | ---------------------------------------- |
      | 8’h2c    | [7:5]   | 3’b001      | Use to control the cyc_dly of the left channels A for CS0.cyc_dly = CFG * 1x clock cycle. |
      | 8’h2c    | [4:3]   | 2’b11       | Use to control the oph_dly of the left channels A for CS0.oph_dly = CFG * 4x clock cycle. |
      | 8’h2c    | [2:0]   | 3’b100      | Use to control the dll_dly of the left channels A for CS0.dll_dly = CFG * DLL step. |
      | 8’h2d    | [7:5]   | 3’b001      | Use to control the cyc_dly of the left channels A for CS1.cyc_dly = CFG * 1x clock cycle. |
      | 8’h2d    | [4:3]   | 2’b11       | Use to control the oph_dly of the left channels A for CS1.oph_dly = CFG * 4x clock cycle. |
      | 8’h2d    | [2:0]   | 3’b100      | Use to control the dll_dly of the left channels A for CS1.dll_dly = CFG * DLL step. |
      | 8’h3c    | [7:5]   | 3’b001      | Use to control the cyc_dly of the right channels A for CS0.cyc_dly = CFG * 1x clock cycle. |
      | 8’h3c    | [4:3]   | 2’b11       | Use to control the oph_dly of the right channels A for CS0.oph_dly = CFG * 4x clock cycle. |
      | 8’h3c    | [2:0]   | 3’b100      | Use to control the dll_dly of the right channels A for CS0.dll_dly = CFG * DLL step. |
      | 8’h3d    | [7:5]   | 3’b001      | Use to control the cyc_dly of the right channels A for CS1.cyc_dly = CFG * 1x clock cycle. |
      | 8’h3d    | [4:3]   | 2’b11       | Use to control the oph_dly of the right channels A for CS1.oph_dly = CFG * 4x clock cycle. |
      | 8’h3d    | [2:0]   | 3’b100      | Use to control the dll_dly of the right channels A for CS1.dll_dly = CFG * DLL step. |
      | 8’h4c    | [7:5]   | 3’b001      | Use to control the cyc_dly of the left channels B for CS0.cyc_dly = CFG * 1x clock cycle. |
      | 8’h4c    | [4:3]   | 2’b11       | Use to control the oph_dly of the left channels B for CS0.oph_dly = CFG * 4x clock cycle. |
      | 8’h4c    | [2:0]   | 3’b100      | Use to control the dll_dly of the left channels B for CS0.dll_dly = CFG * DLL step. |
      | 8’h4d    | [7:5]   | 3’b001      | Use to control the cyc_dly of the left channels B for CS1.cyc_dly = CFG * 1x clock cycle. |
      | 8’h4d    | [4:3]   | 2’b11       | Use to control the oph_dly of the left channels B for CS1.oph_dly = CFG * 4x clock cycle. |
      | 8’h4d    | [2:0]   | 3’b100      | Use to control the dll_dly of the left channels B for CS1.dll_dly = CFG * DLL step. |
      | 8’h5c    | [7:5]   | 3’b001      | Use to control the cyc_dly of the right channels B for CS0.cyc_dly = CFG * 1x clock cycle. |
      | 8’h5c    | [4:3]   | 2’b11       | Use to control the oph_dly of the right channels B for CS0.oph_dly = CFG * 4x clock cycle. |
      | 8’h5c    | [2:0]   | 3’b100      | Use to control the dll_dly of the right channels B for CS0.dll_dly = CFG * DLL step. |
      | 8’h5d    | [7:5]   | 3’b001      | Use to control the cyc_dly of the right channels B for CS1.cyc_dly = CFG * 1x clock cycle. |
      | 8’h5d    | [4:3]   | 2’b11       | Use to control the oph_dly of the right channels B for CS1.oph_dly = CFG * 4x clock cycle. |
      | 8’h5d    | [2:0]   | 3’b100      | Use to control the dll_dly of the right channels B for CS1.dll_dly = CFG * DLL step. |

------

# VREF/RZQ

​	VREF：Inno DDR PHY的VREF并未引出，PHY内部直接生成使用的。而Inno之前提供的调整VREF的方式实际上也是没效果的。所以Inno的DDR PHY VREF是内部生成且不可调。

​	RZQ：固化在PHY内部且不可调。

------

# DFI lowpower功能

​	rk322xh/rk3328 DDR PHY 新增功能，在enable控制器中的DFILPCFG寄存器之后，控制器在进入pd_idle/sr_idle时也会让PHY进入low_power状态， 这时候PHY会gating掉不必要的clk来最大限度的节约功耗。

​	需要注意的是DDR3/DDR4 power_down mode下DDR CLK是不能够停止的，所以DDR3/DDR4 pd_idle下不能够enbale dfi lowpower功能。

​	PHY 寄存器偏移0x24 bit[6] 也能够直接bypass掉该low power 功能。

------

# Test pin功能

​	ODT0可以作为test pin观测内部信号的，具体设置如下：

0x40的[1]设为1, cmd相关的obs信号enable
0x294的[4]设为1, ODT0变为test pin
0x294的[3:0]选择不同的信号送到ODT0观测，其中
0x294的[3:0]设为0101, 可以观测cmd DLL之前的4xclk
0x294的[3:0]设为0110, 可以观测cmd DLL之后的4xclk，默认是0度，可以通过调节cmd dll的相位观测90度， 135度信号
0x294的[3:0]设为1100, 可以观测送给CK driver的内部CK信号
0x294的[3:0]设为1101, 可以观测送给CK driver的内部enb信号，正常CK输出的时候，这个信号为低

-------

# PHY soft reset

PHY寄存器偏移地址0中的bit[2]:reset analog logic， bit[3]:reset digital core

对于Inno DDR PHY当频率改变时（也就是变频时）需要对DDR PHY 的analog和digital部分进行重新reset，这个reset并不会影响寄存器的值。reset后需要先将analog部分释放至少500个DFI CLK 保证DLL lock后后再释放digital部分。

------

# write leveling

V2.65以后版本的DDR PHY带有WRLVL功能。但是WRLVL都是以调整de-skew来实现功能，本身de-skew可移动范围就不大，实际上并没有使用的意义，而从目前的几个平台验证的结果看WRLVL还存在一些bug无法使用。

配置偏移0x14,0x18寄存器为需要开启write leveling 的MR1的值 然后配置偏移0x8寄存器开启write leveling 判断偏移0x3c0寄存器是否完成write leveling， 完成write leveling滞后配置偏移0x8寄存器停止write leveling 并且需要手动发送MR1 让DDR退出write leveling。
​	如果是两个CS时 jedec规定 对一个cs做write leveling时需要将另一个cs 设置为output disable（MR1 bit12 设置为1）
​	write leveling 和data training类似的，可以选择对哪个cs做write leveling，leveling的结果在0x3c4,0x3c8中显示，该组寄存器仅显示最后一个做write leveling的cs的结果。如果Write leveling CS select signal 选为cs0和cs1的话 实际上写每个cs的时候内部会自动切换write leveling的值。这时候per bit de-skew无法使用，只能讲write leveling bypass之后才能使用per bit de-skew。

------

# de-skew

1. de-skew功能就是PHY内部串联在信号线上的一个个延迟单元，可以通过de-skew寄存器控制各个信号线上串联的延迟单元的个数来改变每个信号线的延迟。

2. 对于差分信号TX部分如CLK，DQS 是有两个寄存器可分开调整正负线的延迟。而RX部分de-skew是串在差分放大器之后，所以RX部分差分信号只有一个寄存器调整。

3. 对于V2.65以后版本支持WRLVL的DDR PHY 由于WRLVL也是使用de-skew功能来实现的，所以要手动改变de-skew需要将WRLVL bypass后寄存器设置的de-skew方会生效。而所有的DQS/DQ  TX，RX都是可以两个CS分开来设置不同的值的。

4. de-skew存在的问题：

   由于V2.65以后的版本RX de-skew是两个cs 有两组de-skew的。Inno再rx de-skew 两个cs之间的切换时序上存在设计上的缺陷：1. 切换的时间点不对，不同信号之间有些提前切换有些推后切换，最大的时间差可能有800ps。2.切换电路存在毛刺。这导致了两个cs之间切换的read的时候由于rx de-skew切换问题引起信号采样出错。避开该问题的方法有三个：

   1. 根据read gate training的结果来设置rx de-skew切换时序，将rx de-skew切换的时机控制在diff_cs_rd_gap间隙内。
   2. 寄存器上将rx de-skew 设置为不切换， 将其中一个cs 的de-skew值用在两个cs上，这样就不存在切换问题。0x270 bit[0:1] 控制使用哪个cs的de-skew。  00: cs0 cs1 都用， 01：只用cs1 的de-skew 02：只用cs0 的de-skew。
   3. 将DDR 控制器中的diff_cs_rd_gap拉大。
