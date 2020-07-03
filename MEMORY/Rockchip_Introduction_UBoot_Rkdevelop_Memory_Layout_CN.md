# U-Boot rkdevelop 内存分布指南

发布版本：1.0

作者邮箱：chenjh@rock-chips.com

日期：2018.02

文件密级：内部资料

---

**前言**

**概述**

​	本文档对 Rockchip 平台的内存分布做一个简要说明，仅针对使用 U-Boot rkdevelop 分支的平台。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

| **芯片名称**                                 | **U-Boot 分支** |
| ---------------------------------------- | :----------- |
| RK3036/RK3126C/RK3288/RK322X/RK3368/RK3328/RK3399 | rkdevelop    |

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2018-02-26 | V1.0   | 陈健洪    | 初始版本     |

---

[TOC]

---

## 加载 Kernel<u>之前</u>

### ARM 64 位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)      | reserved  memory                         |
| ……                     | 无                                        | /                                        |
| 132M ~ 148M(max)          | OP-TEE 运行空间                               | 16M 是预估 Max 值；内核完全不可见（被 U-Boot 挖掉）            |
| ……                    | 无                                        | /                                        |
| 128M (占用 8KB)              | HDMI 参数地址                                 | reserved  memory；用于传递 HDMI 配置信息            |
| 56M ~ 128M                | LMB 内存池 + U-Boot 自身代码（relocate 之后）+ 烧写 buffer + idb buffer + malloc | /                                        |
| 48M (占用 8MB)              | Miniloader 运行空间                           | 8MB 是预估 Max 值                               |
| ……                    | 无                                        | /                                        |
| 34M (占用 120byte)           | OP-TEE 内存信息的传参起始地址                        | 120byte 是固定值；用于传递 OP-TEE 占用的内存信息；           |
| ……                    | 无                                        | /                                        |
| 32M (占用 120byte)           | DDR 容量信息的传参起始地址                           | 120byte 是预估 Max 值（可以传递 7 个 bank 块）；用于传递 DDR 颗粒总容量信息； |
| ……                   | 无                                        | /                                        |
| 2M (占用 800KB)              | U-Boot 自身的代码                              | 800KB 是预估 Max 值                             |
| 1M ~ 2M                   | ATF 和 kernel 的共享内存、Last log                 | kernel 完全不可见（被 U-Boot 挖掉）                   |
| 0M ~ 1M                   | ATF 运行空间                                  | kernel 完全不可见（被 U-Boot 挖掉）                   |

### ARM 32 位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)      | reserved  memory                         |
| ……                     | 无                                        | /                                        |
| 132M ~ 148M(max)          | OP-TEE 运行空间                               | 16M 是预估 Max 值；内核完全不可见（被 U-Boot 挖掉）            |
| ……                    | 无                                        | /                                        |
| 128M (占用 8KB)              | HDMI 参数地址                                 | reserved  memory；用于传递 HDMI 配置信息            |
| 56M ~ 128M                | LMB 内存池 + U-Boot 代码（relocate 之后） + 烧写 buffer + idb buffer + malloc | /                                        |
| 48M (占用 8MB)              | Miniloader 运行空间                           | 8MB 是预估 Max 值                               |
| 46M-48M                   | Last log 空间                               | /                                        |
| ……                    | 无                                        | /                                        |
| 34M (占用 120byte)           | OP-TEE 内存信息的传参地址                         | 120byte 是固定值；用于传递 OP-TEE 占用的内存信息；           |
| ……                    | 无                                        | /                                        |
| 32M (占用 120byte)           | DDR 容量信息的传参地址                             | 120byte 是预估 Max 值（可以传递 7 个 bank 块）；用于传递 DDR 颗粒总容量信息； |
| ……                    | 无                                        | /                                        |
| 0M(占用 800KB)               | U-Boot 自身的代码                              | 800KB 是预估 Max 值                             |

总结：上述 1.1、1.2 两点主要区别：

（1）0~2M 空间：64 位平台下被 ATF 使用，32 位平台下被 U-Boot 使用；

（2）46~48M 空间：64 位平台下没有使用，32 位平台下作为 last log 使用（64 位平台 last log 在 1~2M 空间）；

注意：

系统上电的时候，maskrom 会把 miniloader 加载到 ddr 的 0x0 偏移的地址，然后 miniloader 会把自己再 relocate 到 48M 偏移的地址进行（原因：历史遗留的做法）。所以在内存空间要求比较严苛的平台上，对于低地址的使用要特别注意（比如：last log 不可以放在太低的地址，否则会被 miniloader 冲掉）。

## 加载 Kernel<u>之后</u>

### ARM 64 位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)  ( Kernel 使用! ) | reserved memory，logo 显示完毕后由显示驱动释放，然后由 kernel 使用 |
| ……                   | kernel 使用                                | /                                        |
| 132M ~ 148M(max)          | OP-TEE 运行空间                               | kernel 完全不可见（被 U-Boot 挖掉）                  |
| ……                    | kernel 使用                                | /                                        |
| 128M (占用 8KB)              | HDMI 参数地址 ( Kernel 使用! )                   | reserved  memory，会被 HDMI 驱动释放，然后 kernel 使用   |
| ……                    | kernel 使用                                | /                                        |
| 2M+512K(占用 32M)            | kernel 被 U-Boot 加载到 2M+512K 位置，不进行自解压，直接开始运行 | 目前预估 kernel 最大 32M（可调整）                     |
| 2M ~ 2M+512K              | 64 位 kernel 启动时的地址要求（kernel 代码前预留 512K）       | 必须保留                                     |
| 1M ~ 2M                   | ATF 和 kernel 的共享内存、Last log                 | kernel 完全不可见（被 U-Boot 挖掉）                   |
| 0M ~ 1M                   | ATF 运行空间                                  | kernel 完全不可见（被 U-Boot 挖掉）                  |

### ARM 32 位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)  ( Kernel 使用! ) | reserved memory，logo 显示完毕后由显示驱动释放，然后由 kernel 使用 |
| ……                   | kernel 使用                                | /                                        |
| 132M ~ 148M(max)          | OP-TEE 运行空间                               | kernel 完全不可见（被 U-Boot 挖掉）                  |
| ……                    | kernel 使用                                 | /                                        |
| 128M (占用 8KB)              | HDMI 参数地址 ( Kernel 使用! )                   | reserved  memory，会被 HDMI 驱动释放，然后 kernel 使用   |
| ……                    | kernel 使用                                | /                                        |
| 46M ~ 48M                 | Last log                                 | /                                        |
| 32M ~ 46M                 | 压缩过的 kernel 被 U-Boot 加载在 32M 的位置              | kerne 压缩后最大 14M                            |
| 0M ~ 32M                  | kernel 自解压在 0M 位置，然后开始运行                    | kernel 自解压后最大 32M                          |

总结：上述 2.1、2.2 两点主要区别：

（1）0~2M 空间：64 位平台下被 ATF 使用，32 位平台下被 U-Boot 使用；

（2）内核加载地址：32 位平台内核被加载在 32M，然后内核自解压到 0M 开始运行，64 位平台内核被加载在 2M+512K，不进行自解压，直接开始运行；

（3）针对（2）点需要注意，32 位平台下 32M、34M 地址有个复用的过程，即整个开机过程：U-Boot 先从 32M，34M 先获取 DDR、OP-TEE 的参数信息，获取完了之后会把内核加载到 32M 的地方；

（4）46~48M 的空间：64 位平台下没有使用，32 位平台下作为 last log 使用（64 位平台 last log 在 1~2M 的空间）；

（5）针对（4）点需要注意，32 位平台下因为 46~48M 永远都是被 last log 占据，所以必须保证 kernel 未解压前的 size 最大只能是 14M，即 32~46M 之间。否则将会破坏 last log !!