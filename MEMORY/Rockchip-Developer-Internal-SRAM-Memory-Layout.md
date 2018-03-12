# Internal SRAM使用情况

发布版本：1.0

作者邮箱：chenjh@rock-chips.com

日期：2018.03

文件密级：内部资料

-----------

**前言**

**概述**

​	本文档对Rockchip各平台上的Internal SRAM（不包含PMU SRAM）使用情况做一个简要说明。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

| **芯片名称**                                 |
| ---------------------------------------- |
| RK3036/RK312X/RK322X/RK3288/RK3328/RK3368/RK3399/RK3326/PX30 |

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2018-03-22 | V1.0   | 陈健洪    | 初始版本     |



## 各平台Internal SRAM使用情况：

| 芯片      | 全部大小（byte） | 起始地址       | 结束地址（已占用）  | 已使用大小（byte）    |
| ------- | ---------- | ---------- | ---------- | -------------- |
| RK3036  | 8 * 1024   | 0x10080000 | 0x100805ac | 1452           |
| RK312X  | 8 * 1024   | 0x10080000 | 0x10081584 | 5508           |
| RK322X  | 32 * 1024  | 0x10080000 | 0x10081d70 | 7536           |
| RK3288  | 96 * 1024  | 0xff700000 | 0xff7017c8 | 6088           |
| RK322XH | 32 * 1024  | 0xff090000 | 0xff095000 | 20480          |
| RK3328  | 32 * 1024  | 0xff090000 | 0xff093000 | 12288          |
| RK3368  | 64 * 1024  | 0xff8c0000 | 0xff8c2000 | 8192           |
| RK3399  | 192 * 1024 | 0xff8c0000 | 0xff8c6000 | 24576          |
| RK3326  | 16 * 1024  | 0xff0e0000 | 0xff0e4000 | 16 * 1024 (已满) |
| PX30    | 16 * 1024  | 0xff0e0000 | 0xff0e4000 | 16 * 1024 (已满) |

- 目前各平台的Internal SRAM主要用途：休眠唤醒代码、DDR变频代码。


- 上述32位平台数据，基于OPTEE仓库提交点：

分支：remotes/origin/develop-rk3228
提交：25074da plat-rockchip: add configure uart port function

- 上述64位平台数据（不包含RK3326/PX30），基于ATF仓库提交点：

分支：remotes/origin/develop-rk3399
提交：6aa5f84 plat: px30: suspend: support SLP_PLLS_DEEP option