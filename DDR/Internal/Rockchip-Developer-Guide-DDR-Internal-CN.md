# **DDR 开发指南内部文档**

发布版本：1.1

作者邮箱：hcy@rock-chips.com

日期：2019.1.29

文件密级：内部资料

---------

**前言**
适用于所有平台的开发指南

**概述**

**产品版本**

| **芯片名称** | **内核版本** |
| -------- | -------- |
| 所有芯片     | 所有内核版本   |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**                 |
| ---------- | -------- | -------- | ---------------------------- |
| 2017.12.21 | V1.0     | 何灿阳   |                              |
| 2019.1.29  | V1.1     | 何智欢   | 增加 RK3308 modify deskew 工具 |

---------
[TOC]
------

## 如何修改 loader 中的 DDR 频率

1. 将 DDR bin 文件更新到最新
2. 通过 modify_ddr_bin.exe，查看该芯片是否支持修改 DDR 频率
3. 修改后，按后面的“如何将我们给的 DDR bin 合成成完整可用的 loader”生成新 loader

我们有提供工具 modify_ddr_bin.exe，用于修改 DDR bin 文件中的 DDR 频率，能支持修改频率的，只有 RK322x、RK322xh、RK3328、RK3368、RK3399、RV1108，而且有的芯片，只能修改成某些频率。详细见 modify_ddr_bin.exe 的使用说明。

```c
./modify_ddr_bin.exe		//能查看modify_ddr_bin.exe的使用说明
./modify_ddr_bin.exe -chip 3328		//能查看3328的DDR bin文件支持的参数，其他芯片类似
```

工具 modify_ddr_bin.exe 在路径：

\\10.10.10.164\Common_Repository\DDR 相关工具\modify_ddr_bin

## 如何修改 loader 中 DDR 打印的串口号和波特率

1. 将 DDR bin 文件更新到最新
2. 通过 modify_ddr_bin.exe，查看该芯片是否支持修改串口号和波特率
3. 修改后，按后面的“如何将我们给的 DDR bin 合成成完整可用的 loader”生成新 loader

我们有提供工具 modify_ddr_bin.exe，可用于修改 DDR bin 文件中的串口号和波特率，当然，不是所有芯片都支持。详细见 modify_ddr_bin.exe 的使用说明。

```c
./modify_ddr_bin.exe		//能查看modify_ddr_bin.exe的使用说明
./modify_ddr_bin.exe -chip 3328		//能查看3328的DDR bin文件支持的参数，其他芯片类似
```

工具 modify_ddr_bin.exe 在路径：

\\10.10.10.164\Common_Repository\DDR 相关工具\modify_ddr_bin

## 哪些芯片支持 DDR 变频功能

DDR 变频有在不同的阶段实现，也有在不同的 kernel 分支实现，总的支持情况如下

| 芯片              | uboot | kernel 4.4  | kernel 3.10 | kernel 3.0 |
| --------------- | ----- | ----------- | ----------- | ---------- |
| RK3026          |       |             |             | 支持         |
| RK3028A         |       |             |             | 支持         |
| RK3036          |       | 不支持         | 不支持         | 不支持        |
| RK3066          |       |             |             | 支持         |
| RK3126B、RK3126C |       |             | 支持，走 trust 流程 |            |
| RK3126B、RK3126C |       |             | 支持，非 trust 流程 |            |
| RK3126          |       |             | 支持          |            |
| RK3128          |       |             | 支持          |            |
| RK3188          |       |             | 支持          |            |
| RK3288          |       | 支持，走 trust 流程 | 支持          |            |
| RK322x          | 支持    |             | 支持，走 trust 流程 |            |
| RK322xh         |       |             | 支持，走 trust 流程 |            |
| RK3328          |       |             | 支持，走 trust 流程 |            |
| RK3368          |       | 支持，走 trust 流程 | 支持，走 trust 流程 |            |
| RK3399          |       | 支持，走 trust 流程 |             |            |
| RV1108          |       |             | 支持          |            |

## 如何查看 DDR 的容量--补充

除了对外开放的文档《DDR 开发指南》中对应章节讲到的内容，内部资料补充如下信息：

kernel 中的 DDR 容量信息，只要是走 trust 流程的，都没有打印这些信息，也正因为如此，kernel 4.4 中全部没有 DDR 容量信息的打印，kernel 3.10 走 trust 流程的也没有。对照上一部分的“哪些芯片支持 DDR 变频功能”，就可以知道哪些芯片是 kernel 3.10 走 trust 流程的。

对 DDR 的通道、行、列、bank、片选、数据位宽这些基本信息都不懂的，请找人力或助理要培训文档“DRAM 简单介绍.ppt”

## 如何查看 DDR 带宽利用率--补充

除了对外开放的文档《DDR 开发指南》中对应章节讲到的内容，内部资料补充如下信息：

不管哪个版本的 kernel 如果要查看每个端口的详细数据量信息，就需要 push 一个能得到带宽的软件进去（目前是一款芯片一个软件，比较乱，正在整理成一个软件），而且要求关闭负载变频功能。

1. 关闭负载变频，见“如何关闭 DDR 的负载变频功能，只留场景变频”，或者“DDR 如何定频”
2. push 对应软件。软件使用及结果查看，请看到软件的说明文档。

## 如何调整 ODT 和驱动强度

- DDR 控制器端的驱动强度(DS)和 ODT 调整

  芯片：RK3026、RK3028A

  代码位置：arch/arm/mach-rk2928/ddr.c 的 ddr_update_odt()函数

  芯片：RK3126、RK3128

  代码位置：arch/arm/mach-rockchip/ddr_rk3126.c 的 ddr_update_odt()函数

  芯片：RK3126B、RK3126C 非 trust 流程

  代码位置：arch/arm/mach-rockchip/ddr_rk3126b.c 的 ddr_update_odt()函数

  修改：

  所有用到 PHY_RTT_XXXohm，是 DDR 控制器端的 ODT

  所有用到 PHY_RON_XXX，是 DDR 控制器端的驱动强度(DS)

  这些设置的都是单端的上下拉阻值

  芯片：RK3066

  代码位置：arch/arm/mach-rk30/ddr.c 的 ddr_update_odt()函数

  芯片：RK3188

  代码位置：arch/arm/mach-rockchip/ddr_rk30.c 的 ddr_update_odt()函数

  芯片：RK3288 kernel 3.10

  代码位置：arch/arm/mach-rockchip/ddr_rk32.c 的 ddr_update_odt()函数

  修改：

  如下代码是负责修改 DDR 控制器端驱动强度和 ODT 的，改变传递给他的 tmp 值就可以

  ```c
  if(cs > 1)
  {
  	pPHY_Reg->ZQ1CR[0] = tmp;
  	dsb();
  }
  PHY_Reg->ZQ0CR[0] = tmp;
  dsb();
  ```

  tmp 各个 bit 的定义如下：

  [19:15]bit 用于配置 ODT pull-up

  [14:10]bit 用于配置 ODT pull-down

  [9:5]bit 用于配置 Output Impedance pull-up

  [4:0]bit 用于配置 Output Impedance pull-down

  ![CTL_DS_ODT](Rockchip-Developer-Guide-DDR-Internal/CTL_DS_ODT_Code.jpg)

  驱动强度(DS)和 ODT 的值可以分别根据下面两张配置表进行配置

  驱动强度(DS)配置表：![CTL_DS](Rockchip-Developer-Guide-DDR-Internal/CTL_DS.jpg)

  ODT 配置表：

  ![CTL_ODT](Rockchip-Developer-Guide-DDR-Internal/CTL_ODT.jpg)

  芯片：RK3126B、RK3126C 走 trust 流程

  代码位置：arch/arm/boot/dts/rk312x_ddr_default_timing.dtsi

  芯片：RK322x

  代码位置：arch/arm/boot/dts/rk322x_dram_default_timing.dtsi

  芯片：RK322xh、RK3328

  代码位置：

  arch/arm64/boot/dts/rk322xh-dram-default-timing.dtsi

  arch/arm64/boot/dts/rk322xh-dram-2layer-timing.dtsi

  芯片：RK3368

  代码位置：arch/arm64/boot/dts/rk3368_dram_default_timing.dtsi

  芯片：RV1108

  代码位置：arch/arm/boot/dts/rv1108_dram_default_timing.dtsi

  芯片：RK3288 走 trust 流程

  代码位置：arch/arm/boot/dts/rk3288-dram-default-timing.dtsi

  芯片：RK3399

  代码位置：arch/arm64/boot/dts/rockchip/rk3399-dram-default-timing.dtsi

  修改：

  phy_XXX_drv 表示控制器端的驱动强度

  phy_XXX_odt 表示控制器端的 ODT

- DDR 颗粒端的驱动强度(DS)和 ODT 调整

  芯片：RK3026、RK3028A

  代码位置：arch/arm/mach-rk2928/ddr.c 的 ddr_get_parameter()函数

  修改：

  如下代码是负责设置 DDR 颗粒端的驱动强度和 ODT

  ```c
  /* DDR3的设置 */
  if(nMHz <= DDR3_DDR2_ODT_DISABLE_FREQ)
  {
      ddr_reg.ddrMR[1] = DDR3_DS_40 | DDR3_Rtt_Nom_DIS;
  }
  else
  {
      ddr_reg.ddrMR[1] = DDR3_DS_40 | DDR3_Rtt_Nom_120;
  }

  ......

  /* DDR2的设置 */
  if(nMHz <= DDR3_DDR2_ODT_DISABLE_FREQ)
  {
      ddr_reg.ddrMR[1] = DDR2_STR_REDUCE | DDR2_Rtt_Nom_DIS;
  }
  else
  {
      ddr_reg.ddrMR[1] = DDR2_STR_REDUCE | DDR2_Rtt_Nom_75;
  }
  ```

  DDR3\_DS\_XX、DDR2\_STR\_XXX，表示对应 DDR 颗粒端的驱动强度

  DDR3\_Rtt\_Nom\_XXX、DDR2\_Rtt\_Nom\_XXX，表示对应 DDR 颗粒端的 ODT

  芯片：RK3126、RK3128

  代码位置：arch/arm/mach-rockchip/ddr_rk3126.c 的 ddr_get_parameter()函数

  芯片：RK3126B、RK3126C 非 trust 流程

  代码位置：arch/arm/mach-rockchip/ddr_rk3126b.c 的 ddr_get_parameter()函数

  修改：

  如下代码是负责设置 DDR 颗粒端的驱动强度和 ODT

  ```c
  /* DDR3的设置 */
  if (nMHz <= DDR3_DDR2_ODT_DISABLE_FREQ) {
      p_ddr_reg->ddrMR[1] = DDR3_DS_40 | DDR3_Rtt_Nom_DIS;
  } else {
      p_ddr_reg->ddrMR[1] = DDR3_DS_40 | DDR3_Rtt_Nom_120;
  }

  ......

  /* LPDDR2的设置 */
  p_ddr_reg->ddrMR[3] = LPDDR2_DS_34;
  ```

  DDR3\_DS\_XX、LPDDR2\_DS\_XX 表示对应 DDR 颗粒端的驱动强度

  DDR3\_Rtt\_Nom\_XXX 表示对应 DDR 颗粒端的 ODT

  芯片：RK3066

  代码位置：arch/arm/mach-rk30/ddr.c 的 ddr_get_parameter()函数

  芯片：RK3188

  代码位置：arch/arm/mach-rockchip/ddr_rk30.c 的 ddr_get_parameter()函数

  芯片：RK3288 kernel 3.10

  代码位置：arch/arm/mach-rockchip/ddr_rk32.c 的 ddr_get_parameter()函数

  修改：

  如下代码是负责设置 DDR 颗粒端的驱动强度和 ODT

  ```c
  /* DDR3的设置 */
  if(nMHz <= DDR3_DDR2_ODT_DISABLE_FREQ)
  {
  	p_publ_timing->mr[1] = DDR3_DS_40 | DDR3_Rtt_Nom_DIS;
  }
  else
  {
  	p_publ_timing->mr[1] = DDR3_DS_40 | DDR3_Rtt_Nom_120;
  }

  .......

  /* LPDDR2的设置，LPDDR2颗粒端没有ODT */
  p_publ_timing->mr[3] = LPDDR2_DS_34;

  ......

  /* LPDDR3的设置 */
  p_publ_timing->mr[3] = LPDDR3_DS_34;
  if(nMHz <= DDR3_DDR2_ODT_DISABLE_FREQ)
  {
      p_publ_timing->mr11 = LPDDR3_ODT_DIS;
  }
  else
  {
      p_publ_timing->mr11 = LPDDR3_ODT_240;
  }
  ```

  DDR3\_DS\_XX、LPDDR2\_DS\_XX、LPDDR3\_DS\_XX，表示对应 DDR 颗粒端的驱动强度

  DDR3\_Rtt\_Nom\_XXX、LPDDR3\_ODT\_XXX，表示对应 DDR 颗粒端的 ODT

  芯片：RK3126B、RK3126C 走 trust 流程

  代码位置：arch/arm/boot/dts/rk312x_ddr_default_timing.dtsi

  芯片：RK322x

  代码位置：arch/arm/boot/dts/rk322x_dram_default_timing.dtsi

  芯片：RK322xh、RK3328

  代码位置：

  arch/arm64/boot/dts/rk322xh-dram-default-timing.dtsi

  arch/arm64/boot/dts/rk322xh-dram-2layer-timing.dtsi

  芯片：RK3368

  代码位置：arch/arm64/boot/dts/rk3368_dram_default_timing.dtsi

  芯片：RK1108

  代码位置：arch/arm/boot/dts/rv1108_dram_default_timing.dtsi

  芯片：RK3288 走 trust 流程

  代码位置：arch/arm/boot/dts/rk3288-dram-default-timing.dtsi

  芯片：RK3399

  代码位置：arch/arm64/boot/dts/rockchip/rk3399-dram-default-timing.dtsi

  修改：

  ddr3_drv，表示 DDR3 颗粒端的驱动强度

  ddr4_drv，表示 DDR4 颗粒端的驱动强度

  lpddr2_drv，表示 LPDDR2 颗粒端的驱动强度

  lpddr3_drv，表示 LPDDR3 颗粒端的驱动强度

  lpddr4_drv，表示 LPDDR4 颗粒端的驱动强度

  ddr3_odt，表示 DDR3 颗粒端的 ODT

  ddr4_odt，表示 DDR4 颗粒端的 ODT

  lpddr2 颗粒是没有 ODT 的

  lpddr3_odt，表示 LPDDR3 颗粒端的 ODT

  lpddr4_dq_odt，表示 LPDDR4 颗粒端的 DQ ODT

  lpddr4_ca_odt，表示 LPDDR4 颗粒端的 CA ODT

## 如何调整 DQ、DQS、CA、CLK 的 de-skew--补充

除了对外开放的文档《DDR 开发指南》中对应章节讲到的内容，内部资料补充如下信息：

要调整 loader 中的 de-skew，需要借助工具，目前只有 RK322xh、RK3328、RK3308 支持。

- RK322xh、RK3328

  工具路径在

  \\\10.10.10.164\Kitkat_Repository\rk3228h\SDK_IMAGE\loader\修改 3228H DDR 参数工具_V1.04.7z

  机器都能开机，就不需要调整 loader 中的 de-skew，直接去调整 kernel 中的 de-skew

- RK3308

  工具路径在\\\\10.10.10.164\Common_Repository\DDR 相关工具\modify_ddr_bin_deskew\rk3308_modify_deskew\3308_deskew.exe

内部存放“deskew 自动扫描工具”的路径在

\\\10.10.10.164\Common_Repository\DDR 相关工具\deskew 自动扫描工具

请按照《3228H deskew 自动扫描工具使用说明.pdf》来做

## 所有平台 DDR 已经实现的 feature

==这里只列出 TRM 没有写出的 feature，凡事 TRM 写的，我们都已经实现==

3399 已实现 feature：

- 单通道支持
- 最大容量 4GB
- DDR3 最高频率 933MHz
- LPDDR3 最高频率 933MHz

3328、322xh 已实现 feature：

- DDR3 最高频率 933MHz
- LPDDR3 最高频率
- DDR4 最高频率 1066MHz

1108 已实现 feature：

- LPDDR2 支持
- DDR3 支持
- DDR3 最高频率 800MHz
- LPDDR2 最高频率 533MHz
- DDR3 只支持 64MB、128MB、256MB、512MB 这 4 种容量

3368 已实现 feature：

- 不支持 LPDDR2
- DDR3 最高频率 800MHz
- LPDDR3 最高频率 666MHz

3288 已实现 feature：

- 最大容量 8GB，目前所有 RK 芯片，只有 3288 能支持 8GB
- 3GB 支持
- 1.5GB 支持
- 单通道支持
- DDR3 最高频率 533MHz
- LPDDR2、LPDDR3 最高频率 533MHz

3036 已实现 feature：

- DDR2 支持
- DDR3、DDR2 最高频率 533MHz

3066 已实现 feature：

- DDR2 支持
- DDR3、LPDDR2 最高频率 533MHz
- DDR2 最高频率目前只验证到 400MHz

3128 已实现 feature：

- DDR2 支持
- DDR3、DDR2、LPDDDR2 最高频率 533MHz

3126B、3126C 已实现 feature：

- DDR2 支持

- DDR2、DDR3 最高频率 480MHz

322x 已支持的 feature：

- DDR2 支持
- DDR3、LPDDR3 最高频率 800MHz
- DDR2、LPDDR2 最高频率 533MHz

3188 已实现 feature：

- DDR3、LPDDR2 最高频率 533MHz

3066 已实现 feature：

- DDR3、LPDDR2 最高频率 533MHz
