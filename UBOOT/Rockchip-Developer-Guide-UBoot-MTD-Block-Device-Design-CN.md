# U-Boot MTD Block Device Design

发布版本：1.0

作者邮箱：jason.zhu@rock-chips.com

日期：2019.05

文件密级：内部资料

------

**前言**

**概述**

U-Boot下MTD block device设计介绍。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

**修订记录**

| **日期**   | **版本** | **作者**  | **修改说明** |
| ---------- | -------- | --------- | ------------ |
| 2019-05-20 | V1.0     | Jason Zhu | 初始版本     |

------

[TOC]

------

## 1 引用参考

[1].《Rockchip-Developer-Guide-UBoot-nextdev-CN.md》

[2].《Rockchip-Developer-Guide-Uboot-mmc-device-driver-analysis.md》

## 2 术语

MTD：Memory Technology Device即内存技术设备。

## 3 简介

设计MTD block层，兼容目前block设备接口。

## 4 设计

### 4.1 MTD block设计

设计mtd bread & bwrite & berase三个函数，通过desc->devnum来区分挂接的不同MTD设备，这样上层可以直接调用blk_dread & blk_dwrite & blk_derase操作MTD设备。代码位于drivers/mtd/mtd_blk.c。

### 4.2 多设备挂接设计

对于block设备，会依据if_type与devnum来找挂接在block设备下的驱动。对于挂接在block设备下的MTD驱动，定义if_type为IF_TYPE_MTD。devnum在设备驱动在与block层bind时传递。例：

```c
static int rockchip_nandc_bind(struct udevice *udev)
{
    ...
	blk_create_devicef(udev, "mtd_blk", "blk", IF_TYPE_MTD,
                    devnum, 512, 0, &bdev);
    ...
｝
```

devnum为不同设备，目前nand设备有nand，spi nand, spi nor分别为0，1，2。

MTD block不同设备间切换：

```
mtd dev <devnum>
```

读写擦除接口挂接：

```c
ulong mtd_dread(struct udevice *udev, lbaint_t start,
		lbaint_t blkcnt, void *dst)
{
	struct blk_desc *desc = dev_get_uclass_platdata(udev);

	if (desc->devnum == BLK_MTD_NAND) {
		/* nand驱动*/
	} else if (desc->devnum == BLK_MTD_SPI_NAND) {
		/* spi nand驱动 */
	} else if (desc->devnum == BLK_MTD_SPI_NOR) {
		/* spi nor驱动 */
	}
}

ulong mtd_dwrite(struct udevice *udev, lbaint_t start,
		 lbaint_t blkcnt, const void *src)
{
	struct blk_desc *desc = dev_get_uclass_platdata(udev);

	if (desc->devnum == BLK_MTD_NAND) {
		/* nand驱动*/
	} else if (desc->devnum == BLK_MTD_SPI_NAND) {
		/* spi nand驱动 */
	} else if (desc->devnum == BLK_MTD_SPI_NOR) {
		/* spi nor驱动 */
	}
}

ulong mtd_derase(struct udevice *udev, lbaint_t start,
		 lbaint_t blkcnt)
{
	struct blk_desc *desc = dev_get_uclass_platdata(udev);

	if (desc->devnum == BLK_MTD_NAND) {
		/* nand驱动*/
	} else if (desc->devnum == BLK_MTD_SPI_NAND) {
		/* spi nand驱动 */
	} else if (desc->devnum == BLK_MTD_SPI_NOR) {
		/* spi nor驱动 */
	}
}
```

### 4.3 分区表设计

为了兼容原有的block设备分区表，这里不使用mtd part table，在原有的rockchip parameter表基础上支持block设备分区表。原有分区表位置为存储偏移0x2000 sectors位置，这个位置保持不变。

对于MTD设备，在往kernel传递分区表的分区起始地址及大小单位都是byte，所以在U-Boot下对分区表需要做一次转换。当检测到设备为mtd block时，对分区表进行转换。

### 4.4 新增CONFIG

增加CONFIG_MTD_BLK，支持mtd block device。

### 4.5 驱动挂接框图

![mtd-block](.\Rockchip-Developer-Guide-UBoot-MTD-Block-Device-Design\mtd-block.png)

## 5 step by step

to-do
