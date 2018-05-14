# RK3288 注意事项

发布版本：1.0

日期：2018.05

作者邮箱：

文件密级：内部资料

**修订记录**

| **日期**    | **版本** | **作者** | **修改说明**         |
| --------- | ------ | ------ | ---------------- |
| 2018.5.14  | V1.0   | 黄涛     | 初始版本 |

[TOC]

## Cortex-A12

需要处理 818325 821420 825619（未测试到）FOOBAR 等 4 个 Errata。

Generic/Arch Timer 的 CNTVOFF 是随机值（每个核都不一样），如果没有初始化（需要陷入到 Hyp mode），是不能使用 Virtual Counter。

每个核支持独立分频。

DBGPCSR (Program Counter Sampling Register) 可以读取其它核当前运行指令。

## Reset

CRU_GLB_RST_CON 需要配置 pmu reset by second global soft reset，否则复位时 PMU 没有复位，PD 不会开启