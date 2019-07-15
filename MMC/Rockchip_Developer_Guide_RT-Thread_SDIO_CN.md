# **SDIO**开发指南

发布版本：1.0

作者邮箱：shawn.lin@rock-chips.com

日期：2019.07

文件密级：公开资料

---
**前言**

**概述**

**产品版本**
| **芯片名称**            | **RT Thread版本** |
| ----------------------- | :---------------- |
| 全部采用RT Thread的芯片 |                   |

**读者对象**

本文档（本指南）主要适用于以下工程师：
技术支持工程师
软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2019-07-11 | V1.0     | 林涛     | 初始发布     |
|            |          |          |              |
|            |          |          |              |

---
[TOC]
---

## 1 RT-Thread Rockchip SDIO 功能特点

SDIO （Secure Digital Input and Output）

* 兼容SDIO/SD card/eMMC
* 仅支持Highspeed模式, 1/4/8 线宽
* 支持DMA传输模式

## 2 软件

### 2.1 代码路径

SDIO框架：

```c
components/drivers/include/drivers/mmcsd_*.h
components/drivers/sdio/block_dev.c SD卡、eMMC与RTT block层对接的代码
components/drivers/sdio/mmcsd_core.c SD卡、SDIO、eMMC协议栈公共部分
components/drivers/sdio/sdio.c SDIO协议栈
components/drivers/sdio/sd.c SD卡协议栈
components/drivers/sdio/mmc.c eMMC协议栈

```

SDIO驱动适配层：

```c
bsp/rockchip-common/drivers/drv_sdio.c
bsp/rockchip-common/drivers/drv_sdio.h
```

### 2.2 配置

打开SDIO配置，如果是SD卡和eMMC，会生成/dev/sdioX设备；如果是SDIO设备，需要SDIO的
function driver(例如wifi驱动)里面调用sdio_register_driver后才会出现对应的wifi驱动节点

```c
RT-Thread bsp drivers  --->
    RT-Thread rockchip common drivers  --->
        [*] Enable SDIO

```

```c
RT-Thread components  --->
    Device Drivers  --->
        [*] Using SD/MMC device drivers
        (512) The stack size for sdio irq thread
        (15)  The priority level value of sdio irq thread
        (1024) The stack size for mmcsd thread
        (22)  The priority level value of mmcsd thread
        (16)  mmcsd max partition
        [ ]   Enable SDIO debug log output
```

执行命令可以看到已经生成的串口设备：

~~~c
msh >list_device
device         type         ref count
------ -------------------- ----------
sd0           Block Device     0
sd1           Block Device     0

~~~

### 2.3 调试

(1)  将RT_SDIO_DEBUG配置选上后，则会输出更多SDIO/SD/EMMC协议栈的执行流程信息。
(2)  将bsp/rockchip-common/drivers/drv_sdio.c中的RK_MMC_DBG配置后，则会输出更多控制器驱动执行信息。
(3)  请务必在板级配置中设置好IOMUX，IO电源设置，卡电源设置，对应gpio bank的io domain，以及确保控制器的输出时钟为偶数分频所得。
