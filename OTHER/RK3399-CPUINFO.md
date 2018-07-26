# **RK3399 CPUINFO EXPLANATION**

发布版本：1.0

作者邮箱：xjq@rock-chips.com

日期：2018.08

文件密级：公开资料

---

**前言**

**概述**

**产品版本**

| **芯片名称** | **内核版本** |
| -------- | -------- |
| RK3399   | 4.4      |


**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

硬件开发工程师


**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | -------- | ------------ |
| 2018-08-01 | V1.0     | 许剑群   |              |

---

[TOC]

---


#  RK3399 CPUINFO 说明

```c
[    0.216592] rockchip-cpuinfo cpuinfo: Serial         : 0000000000000000
Rockchip芯片cpuinfo的serial信息输出，如果全0表示该颗芯片未烧写序列号
```

Rockchip芯片的cpuinfo有专门驱动，代码在内核的如下位置

*kernel\drivers\soc\rockchip\rockchip-cpuinfo.c*

```c#
static int rockchip_cpuinfo_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct nvmem_cell *cell;
	unsigned char *efuse_buf, buf[16];
	size_t len;
	int i;

	cell = nvmem_cell_get(dev, "cpu-version");
	if (!IS_ERR(cell)) {
		efuse_buf = nvmem_cell_read(cell, &len);
		nvmem_cell_put(cell);

		if (len == 1)
			rockchip_set_cpu_version(efuse_buf[0]);
		kfree(efuse_buf);
	}

	cell = nvmem_cell_get(dev, "id");// 从dts查找id获取寄存器偏移地址
	if (IS_ERR(cell)) {
		dev_err(dev, "failed to get id cell: %ld\n", PTR_ERR(cell));
		if (PTR_ERR(cell) == -EPROBE_DEFER)
			return PTR_ERR(cell);
		return PTR_ERR(cell);
	}
	efuse_buf = nvmem_cell_read(cell, &len);// 读取efuse
	nvmem_cell_put(cell);

	if (len != 16) {
		kfree(efuse_buf);
		dev_err(dev, "invalid id len: %zu\n", len);
		return -EINVAL;
	}

	for (i = 0; i < 8; i++) {
		buf[i] = efuse_buf[1 + (i << 1)];
		buf[i + 8] = efuse_buf[i << 1];
	}

	kfree(efuse_buf);

	system_serial_low = crc32(0, buf, 8);
	system_serial_high = crc32(system_serial_low, buf + 8, 8);

	dev_info(dev, "Serial\t\t: %08x%08x\n",
		 system_serial_high, system_serial_low);// 信息输出

	return 0;
}
```

*kernel\arch\arm64\boot\dts\rockchip\rk3399.dtsi*

```c#
efuse0: efuse@ff690000 {
	compatible = "rockchip,rk3399-efuse";
	reg = <0x0 0xff690000 0x0 0x80>;
	#address-cells = <1>;
	#size-cells = <1>;
	clocks = <&cru PCLK_EFUSE1024NS>;
	clock-names = "pclk_efuse";

	/* Data cells */
	cpu_id: cpu-id@7 {
		reg = <0x07 0x10>;
	};
	cpub_leakage: cpu-leakage@17 {
		reg = <0x17 0x1>;
	};
	gpu_leakage: gpu-leakage@18 {
		reg = <0x18 0x1>;
	};
	center_leakage: center-leakage@19 {
		reg = <0x19 0x1>;
	};
	cpul_leakage: cpu-leakage@1a {
		reg = <0x1a 0x1>;
	};
	logic_leakage: logic-leakage@1b {
		reg = <0x1b 0x1>;
	};
	wafer_info: wafer-info@1c {
		reg = <0x1c 0x1>;
	};
};
```
*kernel\arch\arm64\boot\dts\rockchip\rk3399-android.dtsi*

```c#
cpuinfo {
	compatible = "rockchip,cpuinfo";
	nvmem-cells = <&cpu_id>;
	nvmem-cell-names = "id";
};
```

