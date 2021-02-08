# Rockchip DDR DQ 眼图工具开发指南

文件标识：RK-KF-YF-168

发布版本：V1.0.0

日期：2021-03-05

文件密级：□绝密   □秘密   ■内部资料   □公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2021 瑞芯微电子股份有限公司**

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

**概述**

Rockchip DDR DQ 眼图工具提供了在 U-Boot 下输入命令查看各 DQ 读写眼图的功能，供客户检查自己设计的板子 DQ 眼宽是否足够。

**产品版本**

| **芯片名称** | **软件版本** |
| ------------ | ------------ |
| RV1126  | U-Boot 2017.09 |
| RK356x | U-Boot 2017.09 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

软件开发工程师

技术支持工程师

硬件工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 姚旭伟 | 2021-03-05 | 初始版本     |

---

**目录**

[TOC]

---

## Rockchip DDR DQ 眼图工具工作原理

本工具其实是在 Loader 阶段将 DDR read eye training 和 write eye training 的结果保存下来，在 U-Boot 中通过 ddr_dq_eye 命令以图形化眼图的形式展示出来。

### Loader 保存 DDR read & write eye training 结果

（u-boot 工程 drivers/ram/rockchip/sdram_rxxxxx.c，如 drivers/ram/rockchip/sdram_rv1126.c）

1. 每次 read & write eye training 完成后，save_rw_trn_min_max() 函数将各 DQ 的 deskew 最大值和最小值保存至 rw_trn_result.rd_fsp[x].cs[x] 或 rw_trn_result.wr_fsp[x].cs[x] 中，注意每个 cs 做完都要保存 deskew min & max，否则结果会被下次 training 覆盖。

2. 每个 fsp 所有 cs 的 training 完成后，save_rw_trn_deskew() 函数将各 DQ 的 deskew 保存至 rw_trn_result.rd_fsp[x] 或 rw_trn_result.wr_fsp[x] 中；RV1126 平台下同时保存 modify_dq_deskew() 所用的 min_value 用于还原 training 确定的采样位置。

3. DDR 初始化完成后，save_rw_trn_result_to_ddr() 将 training 结果 rw_trn_result 存储至 DDR 中（地址 RW_TRN_RESULT_ADDR）。

### U-Boot 下查看 DDR DQ 读写眼图

（u-boot 工程 cmd/ddr_tool/ddr_dq_eye.c）

1. 检查 RW_TRN_RESULT_ADDR 地址处的 flag 是否等于 FSP_FLAG；若不是，说明 Loader 没有保存 training 结果，返回 CMD_RET_FAILURE。
2. 获取 ddr_dq_eye 的输入参数，选择对应 fsp 的 training 结果，若参数为空则选择最高频；Rockchip-User-Guide-DDR-DQ-Eye-Tool 中规定 ddr_dq_eye 的输入参数是 DDR 时钟频率（单位 MHz），其实输入参数也可以是 fsp 或 DDR 时钟频率（单位 Hz）。
3. 由于 RK356x 平台有 128 个 rd deskew、256 个 wr deskew，将眼图完整地打印出来可能会超出屏幕范围，宏定义 PRINT_RANGE_MAX 规定了眼图最大打印长度，眼图的长度被等比例缩小至 PRINT_RANGE_MAX。
4. 以图形化眼图形式打印 DDR read & write eye training 结果。

## DDR DQ 最小眼宽限制值的确定

测试多块 EVB 后获取 EVB 的最小眼宽，取 EVB 测试结果的最小眼宽和 JEDEC 规定的最小眼宽（向上取整折算成 deskew）的平均值作为最小眼宽限制值。

### RV1126 DDR DQ 最小眼宽限制值

#### LPDDR4

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1056MHz      | 读       | 18               | 6                    | 12                 |
| 1056MHz      | 写       | 19               | 6                    | 13                 |
| 924MHz       | 读       | 23               | 7                    | 15                 |
| 924MHz       | 写       | 22               | 7                    | 15                 |
| 784MHz       | 读       | 27               | 8                    | 18                 |
| 784MHz       | 写       | 26               | 8                    | 17                 |

> LPDDR4 共测试 15 块 EVB。

#### DDR4

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1056MHz      | 读       | 19               | 6                    | 13                 |
| 1056MHz      | 写       | 11               | 6                    | 9                  |
| 924MHz       | 读       | 22               | 7                    | 15                 |
| 924MHz       | 写       | 14               | 7                    | 11                 |
| 784MHz       | 读       | 27               | 8                    | 18                 |
| 784MHz       | 写       | 19               | 8                    | 14                 |

> DDR4 共测试 14 块 EVB。

#### LPDDR3

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1056MHz      | 读       | 22               | 7                    | 15                 |
| 1056MHz      | 写       | 18               | 7                    | 13                 |
| 924MHz       | 读       | 24               | 8                    | 16                 |
| 924MHz       | 写       | 22               | 8                    | 15                 |
| 784MHz       | 读       | 29               | 10                   | 20                 |
| 784MHz       | 写       | 27               | 10                   | 19                 |

> 品质部正常运行的 RV1126 EVB 中只有 5 块 LPDDR3，测试样本较少。

#### DDR3

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1056MHz      | 读       | 21               | 6                    | 14                 |
| 1056MHz      | 写       | 22               | 6                    | 14                 |
| 924MHz       | 读       | 26               | 8                    | 17                 |
| 924MHz       | 写       | 25               | 8                    | 17                 |
| 784MHz       | 读       | 31               | 5                    | 18                 |
| 784MHz       | 写       | 31               | 5                    | 18                 |

> DDR3 共测试 20 块 EVB。

### RK356x DDR DQ 最小眼宽限制值

#### LPDDR4

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1560MHz      | 读       | 33               | 16                   | 25                 |
| 1560MHz      | 写       | 32               | 16                   | 24                 |
| 1332MHz      | 读       | 41               | 15                   | 28                 |
| 1332MHz      | 写       | 37               | 15                   | 26                 |
| 1184MHz      | 读       | 44               | 15                   | 30                 |
| 1184MHz      | 写       | 42               | 15                   | 29                 |
| 1056MHz      | 读       | 46               | 15                   | 31                 |
| 1056MHz      | 写       | 44               | 15                   | 30                 |

> LPDDR4 共测试 14 块 EVB。

#### DDR4

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1560MHz      | 读       | 44               | 15                   | 30                 |
| 1560MHz      | 写       | 29               | 15                   | 22                 |
| 1332MHz      | 读       | 46               | 15                   | 31                 |
| 1332MHz      | 写       | 34               | 15                   | 25                 |
| 1184MHz      | 读       | 50               | 13                   | 32                 |
| 1184MHz      | 写       | 38               | 13                   | 26                 |
| 1056MHz      | 读       | 52               | 13                   | 33                 |
| 1056MHz      | 写       | 41               | 13                   | 27                 |

> DDR4 共测试 13 块 EVB。

#### LPDDR3

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1184MHz      | 读       | 49               | 18                   | 34                 |
| 1184MHz      | 写       | 32               | 18                   | 25                 |
| 1056MHz      | 读       | 52               | 16                   | 34                 |
| 1056MHz      | 写       | 34               | 16                   | 25                 |
| 920MHz       | 读       | 60               | 17                   | 39                 |
| 920MHz       | 写       | 39               | 17                   | 28                 |
| 780MHz       | 读       | 72               | 18                   | 45                 |
| 780MHz       | 写       | 38               | 18                   | 28                 |

> LPDDR3 共测试 7 块 EVB。

#### DDR3

| DDR 时钟频率 | 读写方向 | EVB 测试最小眼宽 | JEDEC 规定的最小眼宽 | 确定最小眼宽限制值 |
| ------------ | -------- | ---------------- | -------------------- | ------------------ |
| 1184MHz      | 读       | 47               | 17                   | 32                 |
| 1184MHz      | 写       | 44               | 17                   | 31                 |
| 1056MHz      | 读       | 52               | 15                   | 34                 |
| 1056MHz      | 写       | 46               | 15                   | 31                 |
| 920MHz       | 读       | 60               | 17                   | 39                 |
| 920MHz       | 写       | 51               | 17                   | 24                 |
| 780MHz       | 读       | 73               | 9                    | 41                 |
| 780MHz       | 写       | 53               | 9                    | 31                 |

> DDR3 共测试 9 块 EVB。

## 注意事项

1. Rockchip DDR DQ Eye Tool 集成在 DDR Test Tool 中，编译 U-Boot 前请在 menuconfig 中开启 Command line interface -> Enable ddr test tool 来使能本工具。
2. RV1126 的 DDR 初始化代码（drivers/ram/rockchip/sdram_rv1126.c）已开源，Loader 中 DDR 初始化时保存 Read/Write Eye Training 结果的相关代码通过 CONFIG_CMD_DDR_TEST_TOOL 宏定义使能，可以直接烧写 menuconfig 使能本工具后打包的 Loader；RK356x 的 DDR 初始化代码未开源，更新后的 u-boot-ddr 工程中 dram_init 下编译的 Loader 已支持本工具。
3. Loader 将 training 结果保存在 RW_TRN_RESULT_ADDR 处；RW_TRN_RESULT_ADDR 现定义为 (0x2000000 | 0x8000)，0x2000000（32M）处是 Kernel 的位置，在 Loader 到 U-Boot 阶段是相对安全的；前 0x8000（32K）的空间预留给 FSP_PARAM_STORE_ADDR，用于 Trust 中 DDR 休眠唤醒功能。
4. 不同平台 deskew 的单位延迟时间不同；RV1126 每个 deskew 约 18.5ps，具体请参考 internal-docs\DDR\Internal\RV1126_DDR_note 文档中“关于 de-skew”的第 5 点和第 6 点；RK356x 单位 deskew 为 UI / 64。
5. 本工具所打印的眼图中，RV1126 的 Sample 的位置其实不是最终使用的 DQ perbit deskew；为了节省功耗，Loader 阶段的 modify_dq_deskew() 函数将所有 deskew 一起平移至尽可能小的位置。