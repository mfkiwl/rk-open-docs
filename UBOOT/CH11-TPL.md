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
| ------------ | --------- |
| DDR2         | 2         |
| DDR3         | 3         |
| DDR4         | 0         |
| LPDDR2       | 5         |
| LPDDR3       | 6         |
| LPDDR4       | 7         |

Example:

RV1126配置TPL DRAM TYPE为支持DDR3。

方式1）通过修改rv1126_defconfig文件

```
CONFIG_ROCKCHIP_TPL_INIT_DRAM_TYPE=3
```

方式2）通过make menuconfig

```
Device Drivers ---> (3) TPL select DRAM type
```

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

编译生成tpl后，需要跟spl或miniloader进行打包后，生成的Loader文件才能通过烧写工具进行烧写。

- 将编译得到的tpl与spl或miniloader进行打包，生成Loader。

```
./make.sh tpl
```