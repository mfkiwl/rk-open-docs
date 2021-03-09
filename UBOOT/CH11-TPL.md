[TOC]

# TPL

TPL是比U-Boot更早阶段的Loader，TPL运行在SRAM中，其作用是代替ddr bin负责完成DRAM的初始化工作。TPL是代码开源的版本，ddr bin是代码闭源的版本。

## 编译打包

### 配置

- UART配置

CONFIG_DEBUG_UART_BASE：UART基地址。

CONFIG_ROCKCHIP_UART_MUX_SEL_M：UART IOMUX GROUP。

Example:

RV1126配置UART2 M2用于打印DEBUG LOG。

方式1）通过修改rv1126_defconfig文件

```
CONFIG_DEBUG_UART_BASE=0xff570000
CONFIG_ROCKCHIP_UART_MUX_SEL_M=2
```

方式2）通过make menuconfig

```
Device Drivers ---> Serial drivers ---> (0xff570000) Base address of UART
ARM architecture ---> (2) UART mux select
```

- DRAM TYPE配置

通过CONFIG_ROCKCHIP_TPL_INIT_DRAM_TYPE配置TPL支持的DRAM TYPE。

| **DDR TYPE** | **配置值** |
| ------------ | ---------- |
| DDR2         | 2          |
| DDR3         | 3          |
| DDR4         | 0          |
| LPDDR2       | 5          |
| LPDDR3       | 6          |
| LPDDR4       | 7          |

Example:

RV1126配置TPL DRAM TYPE为支持DDR3。

方式1）通过修改rv1126_defconfig文件

```
CONFIG_ROCKCHIP_TPL_INIT_DRAM_TYPE=3
```

方式2）通过make menuconfig，需要注意的是编译时如果make.sh后面有带上芯片型号的话，make时会有一个make xxxdefconfig的动作，会覆盖menuconfig的改动。可不带参数的执行make.sh编译，来防止menuconfig的改动被覆盖。

```
Device Drivers ---> (3) TPL select DRAM type
```

Example:

make rv1126_defconfig或者./make.sh rv1126 -> make menuconfig修改相关配置 -> ./make.sh。

- 快速开机配置

如果需要编译生成支持快速开机的tpl.bin，可以通过打开CONFIG_SPL_KERNEL_BOOT来编译生成。

当前仅支持RV1126/RV1109平台。

- 宽温的支持

如果需要编译生成支持宽温的tpl.bin，可以通过打开CONFIG_ROCKCHIP_DRAM_EXTENDED_TEMP_SUPPORT来编译生成。

当前仅支持RV1126/RV1109平台。

- 其他参数修改

ddr初始化源码位于drivers/ram/rockchip目录下，其他ddr相关参数如频率，驱动强度，ODT强度等均需要在源码中修改。对于RV1126/RV1109来说有将ddr相关参数集中到该目录下的“sdram_inc/rv1126/sdram-rv1126-loader_params.inc”中，可以直接在该文件中修改对应的参数。其他平台参数修改需要在对应sdram_xxx.c中修改。

### 编译

U-Boot 根据不同的编译路径对同一份U-Boot代码编译获得TPL固件，当编译 TPL 时会自动生成`CONFIG_TPL_BUILD` 宏。U-Boot会在编译完 u-boot.bin 之后继续编译 TPL，并创建独立的输出目录`./tpl/`。

```c
  // 编译u-boot
  ......
  DTC     arch/arm/dts/rv1108-evb.dtb
  DTC     arch/arm/dts/rk3399-puma-ddr1866.dtb
  DTC     arch/arm/dts/rv1126-evb.dtb
  FDTGREP dts/dt.dtb
  FDTGREP dts/dt-spl.dtb
  FDTGREP dts/dt-tpl.dtb
  CAT     u-boot-dtb.bin
  MKIMAGE u-boot.img
  COPY    u-boot.dtb
  MKIMAGE u-boot-dtb.img
  COPY    u-boot.bin
  ALIGN   u-boot.bin

  // 编译tpl，有独立的tpl/目录
  ......
  CC      tpl/common/init/board_init.o
  CC      tpl/disk/part.o
  LD      tpl/common/init/built-in.o
  ......
  LD      tpl/u-boot-tpl
  ......
  OBJCOPY tpl/u-boot-tpl-nodtb.bin
  COPY    tpl/u-boot-tpl.bin
```

编译结束后得到：

```
./tpl/u-boot-tpl.bin
```

Example:
编译 RV1126 uboot。

```
./make.sh rv1126
```

### 打包

1. 编译生成的u-boot-tpl.bin需要将头4个byte替换成相应平台的tag后才是一个合法的ddr bin。如RV1126/RV1109平台该tag是“110B”。如果只需要ddr bin的话需要自己手动完成该步骤tag的替换动作，该动作可参考scripts/spl.sh脚本。

Example：替换RV1126 u-boot-tpl.bin的tag。

```
dd bs=4 skip=1 if=tpl/u-boot-tpl.bin of=tpl/u-boot-tpl-tag.bin && sed -i '1s/^/110B&/' tpl/u-boot-tpl-tag.bin
```

2. 如果需要生成完整的可烧写入板子的Loader文件的话，可通过下面命令自动完成u-boot-tpl.bin tag的替换动作以及和spl.bin打包成一个完整的Loader文件动作。

```
./make.sh tpl
```
