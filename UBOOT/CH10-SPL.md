[TOC]

# SPL

## 1 固件引导

SPL 的作用是代替miniloader完成 trust.img 和 uboot.img的加载和引导工作。SPL 目前支持引导两种固件：

- FIT 固件：默认使能；
- RKFW  固件：默认关闭，需要用户单独配置和使能；

### 1.1 FIT 固件

FIT（flattened image tree）格式是 SPL 支持的一种比较新颖的固件格式，支持多个 image 打包和校验。FIT 使用 DTS 的语法对打包的 image 进行描述，描述文件为 u-boot.its，最终生成的 FIT 固件为 u-boot.itb。

FIT的优点：复用 dts 的语法和编译规则，比较灵活，固件解析可以直接使用 libfdt 库。

**u-boot.its 文件：**

- `/images` ：静态定义了所有可获取的资源配置（最后可用、可不用），类似 dtsi 的角色；
- `/configurations`：每个 config 节点描述了一套可启动的配置，类似一个板级 dts。
- 使用`default =` 指定当前选用的默认配置；

范例：

```c
/dts-v1/;

/ {
	description = "Configuration to load ATF before U-Boot";
	#address-cells = <1>;

	images {
		uboot@1 {
			description = "U-Boot (64-bit)";
			data = /incbin/("u-boot-nodtb.bin");
			type = "standalone";
			os = "U-Boot";
			arch = "arm64";
			compression = "none";
			load = <0x00200000>;
		};

		atf@1 {
			description = "ARM Trusted Firmware";
			data = /incbin/("bl31_0x00010000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0x00010000>;
			entry = <0x00010000>;
		};

		atf@2 {
			description = "ARM Trusted Firmware";
			data = /incbin/("bl31_0xff091000.bin");
			type = "firmware";
			arch = "arm64";
			os = "arm-trusted-firmware";
			compression = "none";
			load = <0xff091000>;
		};

		optee@1 {
			description = "OP-TEE";
			data = /incbin/("bl32.bin");
			type = "firmware";
			arch = "arm64";
			os = "op-tee";
			compression = "none";
			load = <0x08400000>;
		};

		fdt@1 {
			description = "rk3328-evb.dtb";
			data = /incbin/("arch/arm/dts/rk3328-evb.dtb");
			type = "flat_dt";
			compression = "none";
		};
    };

	configurations {
		default = "config@1";
		config@1 {
			description = "rk3328-evb.dtb";
			firmware = "atf@1";
			loadables = "uboot@1", "atf@2", "optee@1" ;
			fdt = "fdt@1";
		};
	};
};
```

**u-boot.itb 文件：**

```
                          mkimage + dtc
[u-boot.its] + [images]        ==>         [u-boot.itb]
```

上述是itb文件的生成过程。FIT 固件可以理解为一种特殊的 DTB 文件，只是它的内容是 image。用户可以用 fdtdump 命令查看 itb文件：

```c
cjh@ubuntu:~/uboot-nextdev/u-boot$ fdtdump u-boot.itb | less

/dts-v1/;
// magic:               0xd00dfeed
// totalsize:           0x497 (1175)
// off_dt_struct:       0x38
// off_dt_strings:      0x414
// off_mem_rsvmap:      0x28
// version:             17
// last_comp_version:   16
// boot_cpuid_phys:     0x0
// size_dt_strings:     0x83
// size_dt_struct:      0x3dc

/ {
    timestamp = <0x5d099c85>;
    description = "Configuration to load ATF before U-Boot";
    #address-cells = <0x00000001>;
    images {
        uboot@1 {
            data-size = <0x0009f8a8>;
            data-offset = <0x00000000>;
            description = "U-Boot (64-bit)";
            type = "standalone";
            os = "U-Boot";
            arch = "arm64";
            compression = "none";
            load = <0x00600000>;
        };
        atf@1 {
            data-size = <0x0000c048>;   // 编译过程自动增加了该字段，描述atf@1固件大小
            data-offset = <0x0009f8a8>; // 编译过程自动增加了该字段，描述atf@1固件偏移
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0x00010000>;
            entry = <0x00010000>;
        };
        atf@2 {
            data-size = <0x00002000>;
            data-offset = <0x000ab8f0>;
            description = "ARM Trusted Firmware";
            type = "firmware";
            arch = "arm64";
            os = "arm-trusted-firmware";
            compression = "none";
            load = <0xfff82000>;
        };
        fdt@1 {
            data-size = <0x00005793>;
            data-offset = <0x000ad8f0>;
            description = "rk3308-evb.dtb";
            type = "flat_dt";
            ......
        };
        ......
    };
};
```

更多 FIT 信息请参考：

```
./doc/uImage.FIT/
```

### 1.2 RKFW 固件

为了能更直接替换掉 miniloader 且不用修改后级固件的分区、打包格式。因此RK平台增加了RKFW 格式（即独立分区的固件：trust.img 和 uboot.img）的引导。

**配置：**

```c
CONFIG_SPL_LOAD_RKFW           // 使能开关
CONFIG_RKFW_TRUST_SECTOR       // trust.img分区地址，需要和分区表的定义保持一致
CONFIG_RKFW_U_BOOT_SECTOR      // uboot.img分区地址，需要和分区表的定义保持一致
```

**代码：**

```
./include/spl_rkfw.h
./common/spl/spl_rkfw.c
```

### 1.3 存储优先级

U-Boot dts 中通过`u-boot,spl-boot-order` 指定存储设备的启动优先级。

```
/ {
	aliases {
		mmc0 = &emmc;
		mmc1 = &sdmmc;
	};

	chosen {
		u-boot,spl-boot-order = &sdmmc, &nandc, &emmc;
		stdout-path = &uart2;
	};
	......
};
```

## 2 编译打包

### 2.1 代码编译

U-Boot 根据**不同的编译路径** 对同一份U-Boot代码编译获得SPL固件，当编译 SPL 时会自动生成`CONFIG_SPL_BUILD` 宏。U-Boot会在编译完 u-boot.bin 之后继续编译 SPL，并创建独立的输出目录`./spl/`。

```c
  // 编译u-boot
  ......
  DTC     arch/arm/dts/rk3399-puma-ddr1866.dtb
  DTC     arch/arm/dts/rv1108-evb.dtb
make[2]: `arch/arm/dts/rk3328-evb.dtb' is up to date.
  SHIPPED dts/dt.dtb
  FDTGREP dts/dt-spl.dtb
  CAT     u-boot-dtb.bin
  MKIMAGE u-boot.img
  COPY    u-boot.dtb
  MKIMAGE u-boot-dtb.img
  COPY    u-boot.bin

  // 编译spl，有独立的spl/目录
  LD      spl/arch/arm/cpu/built-in.o
  CC      spl/board/rockchip/evb_rk3328/evb-rk3328.o
  LD      spl/dts/built-in.o
  CC      spl/common/init/board_init.o
  COPY    tpl/u-boot-tpl.dtb
  CC      spl/cmd/nvedit.o
  CC      spl/env/common.o
  CC      spl/env/env.o
  .....
  LD      spl/drivers/block/built-in.o

  ......
```

编译结束后得到：

```
./spl/u-boot-spl.bin
```

### 2.3 固件打包

## 3 系统模块

### 3.1 GPT

SPL 使用GPT分区表。

配置：

```
CONFIG_SPL_LIBDISK_SUPPORT=y
CONFIG_SPL_EFI_PARTITION=y
CONFIG_PARTITION_TYPE_GUID=y
```

驱动：

```
./disk/part.c
./disk/part_efi.c
```

接口：

```c
int part_get_info(struct blk_desc *dev_desc, int part, disk_partition_t *info);
int part_get_info_by_name(struct blk_desc *dev_desc,
                          const char *name, disk_partition_t *info);
```

### 3.2 A/B system

SPL 支持A/B 系统启动。

配置：

```
CONFIG_SPL_AB=y
```

驱动：

```
./common/spl/spl_ab.c
```

接口：

```c
int spl_get_current_slot(struct blk_desc *dev_desc, char *partition, char *slot);
int spl_get_partitions_sector(struct blk_desc *dev_desc, char *partition,u32 *sectors);
```

### 3.3 启动优先级

- SPL 使用 `u-boot,spl-boot-order` 定义的启动顺序，位于rkxxxx-u-boot.dtsi：

  ```
  chosen {
	stdout-path = &uart2;
	u-boot,spl-boot-order = &sdmmc, &sfc, &nandc, &emmc;
  };
  ```

- Maskrom 的启动优先级：

  ```
   spi nor > spi nand > emmc > sd
  ```

- Pre-loader(SPL) 的启动优先级：

  ```
  sd > spi nor > spi nand > emmc
  ```

  把 sd 卡的优先级提到最高可以方便系统从 sd 卡启动。

### 3.4 ATAGS

SPL 与 U-Boo 通过 ATAGS 机制实现传参。传递的信息有：启动的存储设备、打印串口等。

配置：

```
CONFIG_ROCKCHIP_PRELOADER_ATAGS=y
```

驱动：

```
./arch/arm/include/asm/arch-rockchip/rk_atags.h
./arch/arm/mach-rockchip/rk_atags.c
```

接口：

```c
int atags_set_tag(u32 magic, void *tagdata);
struct tag *atags_get_tag(u32 magic);
```

### 3.5 kernel boot

通常kernel是由U-Boot加载和引导，SPL 也可以支持加载 kernel。目前支持加载 android head version 2 的 boot.img，支持 RK格式固件。

启动顺序：

```
Maskrom -> ddr -> SPL -> Trust -> Kernel
```

### 3.6 pinctrl

配置：

```
CONFIG_SPL_PINCTRL_GENERIC=y
CONFIG_SPL_PINCTRL=y
```

驱动：

```
./drivers/pinctrl/pinctrl-uclass.c
./drivers/pinctrl/pinctrl-generic.c
./drivers/pinctrl/pinctrl-rockchip.c
```

DTS 配置：

以 sdmmc 为例：

```
&pinctrl {
	u-boot,dm-spl;
};

&pcfg_pull_none_4ma {
	u-boot,dm-spl;
};

&pcfg_pull_up_4ma {
	u-boot,dm-spl;
};

&sdmmc {
	u-boot,dm-spl;
};

&sdmmc_pin {
	u-boot,dm-spl;
};

&sdmmc_clk {
	u-boot,dm-spl;
};

&sdmmc_cmd {
	u-boot,dm-spl;
};

&sdmmc_bus4 {
	u-boot,dm-spl;
};

&sdmmc_pwren {
	u-boot,dm-spl;
};
```

**注意事项：**

SPL 启用pinctrl时要修改 defconfig 里的 `CONFIG_OF_SPL_REMOVE_PROPS` 定义，删除其中的`pinctrl-0 pinctrl-names` 字段。

### 3.7 secure boot

[TODO]

## 4 驱动模块

### 4.1 MMC

配置：

```c
CONFIG_SPL_MMC_SUPPORT=y  // 默认已使能
```

驱动：

```
./common/spl/spl_mmc.c
```

接口：

```c
int spl_mmc_load_image(struct spl_image_info *spl_image,
                       struct spl_boot_device *bootdev);
```

### 4.2 MTD block

SPL 统一 nand、spi nand、spi nor 接口到 block 层。

配置：

```c
// MTD 驱动支持
CONFIG_MTD=y
CONFIG_CMD_MTD_BLK=y
CONFIG_SPL_MTD_SUPPORT=y
CONFIG_MTD_BLK=y
CONFIG_MTD_DEVICE=y

// spi nand 驱动支持
CONFIG_MTD_SPI_NAND=y
CONFIG_ROCKCHIP_SFC=y
CONFIG_SPL_SPI_FLASH_SUPPORT=y
CONFIG_SPL_SPI_SUPPORT=y

// nand 驱动支持
CONFIG_NAND=y
CONFIG_CMD_NAND=y
CONFIG_NAND_ROCKCHIP=y
CONFIG_SPL_NAND_SUPPORT=y
CONFIG_SYS_NAND_U_BOOT_LOCATIONS=y
CONFIG_SYS_NAND_U_BOOT_OFFS=0x8000
CONFIG_SYS_NAND_U_BOOT_OFFS_REDUND=0x10000

// spi nor 驱动支持
CONFIG_CMD_SF=y
CONFIG_CMD_SPI=y
CONFIG_SPI_FLASH=y
CONFIG_SF_DEFAULT_MODE=0x1
CONFIG_SF_DEFAULT_SPEED=50000000
CONFIG_SPI_FLASH_GIGADEVICE=y
CONFIG_SPI_FLASH_MACRONIX=y
CONFIG_SPI_FLASH_WINBOND=y
CONFIG_SPI_FLASH_MTD=y
CONFIG_ROCKCHIP_SFC=y
CONFIG_SPL_SPI_SUPPORT=y
CONFIG_SPL_MTD_SUPPORT=y
CONFIG_SPL_SPI_FLASH_SUPPORT=y
```

驱动：

```
./common/spl/spl_mtd_blk.c
```

接口：

```c
int spl_mtd_load_image(struct spl_image_info *spl_image,
                       struct spl_boot_device *bootdev);
```

### 4.3 OTP

用于存储不可更改数据，secure boot 中用到。

 配置：

```
CONFIG_SPL_MISC=y
CONFIG_SPL_ROCKCHIP_SECURE_OTP=y
```

驱动：

```
./drivers/misc/misc-uclass.c
./drivers/misc/rockchip-secure-otp.S
```

接口：

```c
int misc_read(struct udevice *dev, int offset, void *buf, int size);
int misc_write(struct udevice *dev, int offset, void *buf, int size);
```

### 4.4 Crypto

Secure-boot 会使用crypto完成hash、ras的计算。

配置：

```c
CONFIG_SPL_DM_CRYPTO=y

// crypto v1 支持平台：rk3399/rk3368/rk3328/rk3229/rk3288/rk3128
CONFIG_SPL_ROCKCHIP_CRYPTO_V1=y

// crypto v2 支持平台：px30/rk3326/rk1808/rk3308
CONFIG_SPL_ROCKCHIP_CRYPTO_V2=y
```

驱动：

```
./drivers/crypto/crypto-uclass.c
./drivers/crypto/rockchip/crypto_v1.c
./drivers/crypto/rockchip/crypto_v2.c
./drivers/crypto/rockchip/crypto_v2_pka.c
./drivers/crypto/rockchip/crypto_v2_util.c
```

接口：

```c
u32 crypto_algo_nbits(u32 algo);
struct udevice *crypto_get_device(u32 capability);
int crypto_sha_init(struct udevice *dev, sha_context *ctx);
int crypto_sha_update(struct udevice *dev, u32 *input, u32 len);
int crypto_sha_final(struct udevice *dev, sha_context *ctx, u8 *output);
int crypto_sha_csum(struct udevice *dev, sha_context *ctx,
                    char *input, u32 input_len, u8 *output);
int crypto_rsa_verify(struct udevice *dev, rsa_key *ctx, u8 *sign, u8 *output);
```

### 4.5 Uart

SPL 串口通过 `rkxxxx-u-boot.dtsi` 的 chosen 节点指定。以 rk3308 为例：

```
chosen {
	stdout-path = &uart2;
};

&uart2 {
	u-boot,dm-pre-reloc;
	clock-frequency = <24000000>;
	status = "okay";
};
```
