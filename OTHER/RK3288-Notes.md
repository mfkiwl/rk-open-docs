# RK3288 注意事项

发布版本：1.1

日期：2018.12

作者邮箱：

文件密级：内部资料

**修订记录**

| **日期**    | **版本** | **作者** | **修改说明**         |
| --------- | ------ | ------ | ---------------- |
| 2018.5.14  | V1.0   | 黄涛     | 初始版本 |
| 2018.12.11 | V1.1 | 黄涛 | 增加 DBGPCSR 地址说明 |

[TOC]

## Cortex-A12

需要处理 818325/852422 821420 825619（未测试到）FOOBAR 等 4 个 Errata。其中 818325/852422 的 workaround 相同，归为同一个。

Generic/Arch Timer 的 CNTVOFF 是随机值（每个核都不一样），如果没有初始化（需要陷入到 Hyp mode），是不能使用 Virtual Counter。

每个核支持独立分频。

DBGPCSR (Program Counter Sampling Register) 可以读取其它核当前运行指令。
DBGPCSR 地址为 0xffbb00a0 + cpu * 0x2000
DS-5 中可以通过 APB_0: 访问

## Reset

CRU_GLB_RST_CON 需要配置 pmu reset by second global soft reset，否则复位时 PMU 没有复位，PD 不会开启

## OP-TEE|MUTEX死锁

**现象：**

​	OP-TEE开机初始化阶段的代码有获取mutex锁的操作，mutex里的本质实现是spinlock。拷机发现概率性出现这把锁已经被占用的情况，这样就导致cpu0死等，整个系统就卡住了。串口打印信息停留在“Enter Trust OS”：

```
......
Bus Width=32 Col=10 Bank=8 Row=14/14 CS=2 Die Bus-Width=32 Size=1024MB
OUT
Boot1 Release Time: 2017-06-15, version: 2.33
ChipType = 0x8, 186
SdmmcInit=2 0
BootCapSize=2000
UserCapSize=29820MB
FwPartOffset=2000 , 2000
SdmmcInit=0 20
StorageInit ok = 48433
Code check OK! theLoader 0x0, 68285
Code check OK! theLoader 0x8400000, 101286
Enter Trust OS
```

**原因：**

​	一开始比较怀疑cache的问题，后来通过一系列拷机排查，排除errata、cache、mmu等原因，但是最终没有结论，分析不出根本原因，比较怀疑是A12本身的未知bug。

**处理：**

​	只能采取workarund的办法：代码框架里几乎所有的mutex都是全局静态变量，且在定义时静态初始化，所以我们把mutex都改成运行时动态赋值初始化，这样修改可以解决问题。

​	一共有2个提交（从拷机排查的实验结果看，commit e18ec91071ded2fcc1704140049637ed8c05fc7e其实可以不需要，但是建议保留）。如下是remotes/origin/develop-rk3228上的提交信息：

```
commit e18ec91071ded2fcc1704140049637ed8c05fc7e
Author: Joseph Chen <chenjh@rock-chips.com>
Date:   Mon Apr 16 10:34:41 2018 +0800

    workaround: rockchip: invalidate dcache before enable MMU

    this patch fix rk3288 spinlock occupied issue when start up

    Change-Id: I435c159957f2ac5bf89a4bb6034e0c09b0588a85
    Signed-off-by: Joseph Chen <chenjh@rock-chips.com>

commit f5331c5630c158c8377fff210b3ef6436557d144
Author: Joseph Chen <chenjh@rock-chips.com>
Date:   Mon Apr 16 10:09:39 2018 +0800

    workaround: rockchip: use mutex_init() to initialize mutex

    this patch fix rk3288 spinlock occupied issue when start up

    Change-Id: If4414cb45c16ba028de0f1495ef827e70d6667ae
    Signed-off-by: Joseph Chen <chenjh@rock-chips.com>
```