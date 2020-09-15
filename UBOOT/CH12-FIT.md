[TOC]

# FIT 方案

## 简介

### 基础介绍

FIT（flattened image tree）是U-Boot支持的一种新固件类型的引导方案，支持任意多个image打包和校验。FIT 使用 its (image source file) 文件描述image信息，最后通过mkimage工具生成 itb (flattened image tree blob) 镜像。its文件使用 DTS 的语法规则，非常灵活，可以直接使用libfdt 库和相关工具。

FIT 是U-Boot默认支持且主推的固件格式，SPL和U-Boot阶段都支持对FIT格式的固件引导。更多信息请参考：

```
./doc/uImage.FIT/
```

因为官方的FIT功能无法满足实际产品需求，所以RK平台对FIT进行了适配和优化。所以FIT方案中必须使用RK U-Boot编译生的mkimage工具，不能使用PC自带的mkimage。

### 范例介绍

如下以u-boot.its和u-boot.itb作为范例进行介绍。

- `/images` ：静态定义了所有的资源，相当于一个 dtsi文件；
- `/configurations`：每个 config 节点都描述了一套可启动的配置，相当于一个板级dts文件。
- `default =` ：指明默认启用的config；

```c
/dts-v1/;

/ {
	description = "Simple image with OP-TEE support";
	#address-cells = <1>;

	images {
		uboot {
			description = "U-Boot";
			data = /incbin/("./u-boot-nodtb.bin");
			type = "standalone";
			os = "U-Boot";
			arch = "arm";
			compression = "none";
			load = <0x00400000>;
			hash {
				algo = "sha256";
			};
		};
		optee {
			description = "OP-TEE";
			data = /incbin/("./tee.bin");
			type = "firmware";
			arch = "arm";
			os = "op-tee";
			compression = "none";
			load = <0x8400000>;
			entry = <0x8400000>;
			hash {
				algo = "sha256";
			};
		};
		fdt {
			description = "U-Boot dtb";
			data = /incbin/("./u-boot.dtb");
			type = "flat_dt";
			compression = "none";
			hash {
				algo = "sha256";
			};
		};
	};

	// configurations 节点下可以定义任意多个不同的conf节点，但实际产品方案上我们只需要一个conf即可。
	configurations {
		default = "conf";
		conf {
			description = "Rockchip armv7 with OP-TEE";
			rollback-index = <0x0>;
			firmware = "optee";
			loadables = "uboot";
			fdt = "fdt";
			signature {
				algo = "sha256,rsa2048";
				key-name-hint = "dev";
			        sign-images = "fdt", "firmware", "loadables";
			};
		};
	};
};
```

使用mkimage工具和its文件可以生成itb文件：

```
                          mkimage + dtc
[u-boot.its] + [images]    =========>      [u-boot.itb]
```

fdtdump 命令可以查看 itb文件内容：

```c
cjh@ubuntu:~/uboot-nextdev/u-boot$ fdtdump fit/u-boot.itb | less

/dts-v1/;
// magic:		0xd00dfeed
// totalsize:		0x600 (1536)
// off_dt_struct:	0x48
// off_dt_strings:	0x48c
// off_mem_rsvmap:	0x28
// version:		17
// last_comp_version:	16
// boot_cpuid_phys:	0x0
// size_dt_strings:	0xc3
// size_dt_struct:	0x444

/memreserve/ 7f34d3411000 600;
/ {
    totalsize = <0x000bb600>;             // 新增字段描述整个itb文件的大小
    timestamp = <0x5ecb3553>;
    description = "Simple image with OP-TEE support";
    #address-cells = <0x00000001>;
    images {
        uboot {
            data-size = <0x0007ed54>;     // 新增字段描述固件大小
            data-position = <0x00000a00>; // 新增字段描述固件偏移
            description = "U-Boot";
            type = "standalone";
            os = "U-Boot";
            arch = "arm";
            compression = "none";
            load = <0x00400000>;
            hash {
                value = <0xeda8cd52 0x8f058118 0x00000003 0x35360000 0x6f707465 0x0000009f 0x00000091 0x00000000>;
                algo = "sha256";
            };
        };
        optee {
            data-size = <0x0003a058>;
            data-position = <0x0007f800>;
            description = "OP-TEE";
            type = "firmware";
            arch = "arm";
            os = "op-tee";
            compression = "none";
            load = <0x08400000>;
            entry = <0x08400000>;
            hash {
                value = <0xa569b7fc 0x2450ed39 0x00000003 0x35360000 0x66647400 0x00001686 0x000b9a00 0x552d426f>;
                algo = "sha256";
            };
        };
        fdt {
            data-size = <0x00001686>;
            data-position = <0x000b9a00>;
            description = "U-Boot dtb";
            type = "flat_dt";
            compression = "none";
            hash {
                value = <0x0f718794 0x78ece7b2 0x00000003 0x35360000 0x00000001 0x6e730000 0x636f6e66 0x00000000>;
                algo = "sha256";
            };
        };
    };
    configurations {
        default = "conf";
        conf {
            description = "Rockchip armv7 with OP-TEE";
            rollback-index = <0x00000000>;
            firmware = "optee";
            loadables = "uboot";
            fdt = "fdt";
            signature {
                algo = "sha256,rsa2048";
                key-name-hint = "dev";
                sign-images = "fdt", "firmware", "loadables";
            };
        };
    };
};
```

### itb结构

itb本质是fdt_blob + images的文件集合，有如下两种打包方式，RK平台方案采用结构2方式。

```C
	        fdt blob
|-----------------------------------|
|   |------|  |------|  |------|    |
|   | img0 |  | img1 |  | img2 |    | 结构1：image在fdt_blob内，即:itb = fdt_blob(含img)
|   |------|  |------|  |------|    |
|-----------------------------------|

|--------------|------|------|------|
|              |      |      |      |
|   fdt blob   | img0 | img1 | img2 | 结构2：image在fdt_blob外，即itb = fdt_blob + img
|              |      |      |      |
|--------------|------|------|------|
```

## 平台配置

### 代码配置

代码：

```c
// 框架代码
./common/image.c
./common/image-fit.c
./common/spl/spl_fit.c

// 平台代码：
./arch/arm/mack-rockchip/fit.c
./cmd/bootfit.c

// 工具代码
./tools/mkimage.c
./tools/fit_image.c
```

配置：

```c
// U-Boot阶段支持FIT
CONFIG_ROCKCHIP_FIT_IMAGE=y

// U-Boot阶段：安全启动、防回滚、硬件crypto
CONFIG_FIT_SIGNATURE=y
CONFIG_FIT_ROLLBACK_PROTECT=y
CONFIG_FIT_HW_CRYPTO=y

// SPL阶段：安全启动、防回滚、硬件crypto
CONFIG_SPL_FIT_SIGNATURE=y
CONFIG_SPL_FIT_ROLLBACK_PROTECT=y
CONFIG_SPL_FIT_HW_CRYPTO=y

// uboot.img镜像包含几份uboot.itb，单份uboot.itb多大
CONFIG_SPL_FIT_IMAGE_KB=2048
CONFIG_SPL_FIT_IMAGE_MULTIPLE=2

// uboot工程编译后默认输出fit格式的uboot.img; 否则为传统的RK格式uboot.img和trust.img。
CONFIG_ROCKCHIP_FIT_IMAGE_PACK=y
```

如果FIT方案是作为SDK正式发布的feature，那么大部分基础配置已使能，用户需要自己配置的选项有：

```c
// U-Boot 安全启动和防回滚机制
CONFIG_FIT_SIGNATURE=y
CONFIG_FIT_ROLLBACK_PROTECT=y

// SPL 安全启动和防回滚机制
CONFIG_SPL_FIT_SIGNATURE=y
CONFIG_SPL_FIT_ROLLBACK_PROTECT=y
```

- CONFIG_FIT_SIGNATURE没有使能：uboot可以同时支持引导三种格式的固件：android、uimage、fit（发布的SDK会根据平台需求选择开启哪几种支持）。
- CONFIG_FIT_SIGNATURE使能：uboot只支持引导fit固件。

### 镜像文件

FIT方案上最终输出两个FIT格式的固件用于烧写，分别是uboot.img和boot.img，还有一个SPL文件用于打包成loader。

- uboot.img 文件

  uboot.itb = trust + u-boot.bin + mcu.bin(option)

  uboot.img  = uboot.itb * N份（N一般是2）

  > trust 和 mcu 文件来自rkbin工程，编译脚本会自动从rkbin工程索引并获取它们。

- boot.img 文件

  boot.itb = kernel + fdt + resource + ramdisk(optional)

  boot.img  = boot.itb * M份（M一般是1）

- SPL 文件

  SPL文件指的是编译完成后生成的`spl/u-boot-spl.bin`，负责引导FIT格式的uboot.img。用户需要用它替换RK平台上不开源的miniloader，最终打包出loader。

- `./fit`目录

  U-Boot编译完成后会在目录下生成`./fit`文件夹，包含了一些中间文件，后续章节会介绍。

boot.img和uboot.img分别在sdk工程和uboot工程下被编译生成。但是支持安全启动的boot.img必须放在 U-Boot工程下重新打包签名，后续章节会介绍。

### its 文件

- uboot的its文件为./u-boot.its，由defconfig中`CONFIG_SPL_FIT_GENERATOR`指定的脚本动态创建，固件编译成功够可见。

- boot的its文件位于SDK工程下：

```c
device/rockchip/[platform]/xxx.its  // [platform]是平台目录
```

### 相关工具

```c
// 核心打包工具，编译完成后会自动生成，U-Boot和rkbin仓库下都有（U-Boot仓库下是实时编译生成）。
./tools/mkimage
// 固件打包脚本
./make.sh
// 固件重签名脚本
scripts/fit-resign.sh
// 固件解包脚本
scripts/fit-unpack.sh
```

脚本工具的使用在后续章节会介绍，此处先重点介绍make.sh的参数：

- `--spl-new`：传递此参数，表示使用当前编译的spl文件打包loader；否则使用rkbin工程里的spl文件。**由用户根据实际情况决定是否传递 **
- `--rollback-index-uboot [n]`：指定uboot.img 固件版本号，n必须是十进制正整数；
- `--rollback-index-boot [n]`：指定boot.img 固件版本号，n必须是十进制正整数；
- `--no-check`：打包安全固件时被使用，用于跳过安全固件打包脚本的自校验。

## 非安全启动

### uboot.img

编译命令：

```c
./make.sh rv1126 --spl-new  // 可不指定 --spl-new
```

编译结果：

```c
  ......
  CC      spl/common/spl/spl.o
  CC      spl/lib/display_options.o
  LD      spl/common/spl/built-in.o
  LD      spl/lib/built-in.o
  LD      spl/u-boot-spl
  OBJCOPY spl/u-boot-spl-nodtb.bin
  CAT     spl/u-boot-spl-dtb.bin
  COPY    spl/u-boot-spl.bin
  CFGCHK  u-boot.cfg

out:rv1126_spl_loader_v1.00.100.bin
fix opt:rv1126_spl_loader_v1.00.100.bin
merge success(rv1126_spl_loader_v1.00.100.bin)
/home4/cjh/uboot-nextdev

// 生成 rv1126_spl_loader_v1.00.100.bin（用spl替代了RK平台传统的miniloader
// loader ini 文件来源
pack loader(SPL) okay! Input: /home4/cjh/rkbin/RKBOOT/RV1126MINIALL.ini
// 来自 --spl-new 参数的提示；用户可以选择不加这个参数。
pack loader with new: spl/u-boot-spl.bin

// 生成 uboot.img（包含trust和uboot）
Image(no-signed):  uboot.img (FIT with uboot, trust) is ready
// trust ini文件来源
pack uboot.img okay! Input: /home4/cjh/rkbin/RKTRUST/RV1126TOS.ini

Platform RV1126 is build OK, with exist .config
```

打包备份：通过defconfig配置指定uboot.img的多备份：

```c
CONFIG_SPL_FIT_IMAGE_KB=2048    // 单份itb大小
CONFIG_SPL_FIT_IMAGE_MULTIPLE=2 // 打包的份数
```

SPL根据这个配置去探测和引导U-Boot和trust，主要是应对OTA升级过程中异常掉电引起的固件损坏，而无法启动的问题。

### boot.img

FIT方案如果作为SDK正式发布的feature，SDK编译完成后会生成FIT格式的boot.img。

如果要生成安全启动用的boot.img，必须把SDK生成的boot.img放到U-Boot工程下重新打包并签名，因为安全固件打包的签名工具、配置、参数等都来源于U-Boot工程。

## 安全启动

FIT方案支持安全启动，相关的feature：

- sha256 + rsa2048
- 固件防回滚
- 固件重签名(远程签名)
- Crypto硬件加速

### 原理

#### 校验流程

- Maskrom 校验 loader（包含SPL, ddr, usbplug）
- SPL 校验uboot.img（包含trust、U-Boot...）
- U-Boot校验boot.img（包含kernel，fdt，ramdisk...）

目前默认只支持 sha256+rsa2048 的安全校验模式。

#### key存放

RSA key被mkimage打包在u-boot.dtb和u-boot-spl.dtb中，然后它们再被打包进u-boot.bin和u-boot-spl.bin。

u-boot.dtb里RSA key的格式如下（同理u-boot-spl.dtb）：

```c
cjh@ubuntu:~/uboot-nextdev$ fdtdump u-boot.dtb | less
/dts-v1/;
....

/ {
    #address-cells = <0x00000001>;
    #size-cells = <0x00000001>;
    compatible = "rockchip,rv1126-evb", "rockchip,rv1126";
    model = "Rockchip RV1126 Evaluation Board";

    // signature节点由mkimage工具自动插入生成，节点里保存了RSA-SHA算法类型、RSA核心因子参数等信息。
    signature {
        key-dev {
            required = "conf";
            algo = "sha256,rsa2048";
            rsa,np = <0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x1327f633 0x00000003 0x00000003 0x00000003 0xc7aead6a 0xb4c79f40 0xa82bdf76 0xfb2f8387 0xa1e06dce 0xd451a706 0xc7f865e3 0x3e2d7ca8 0x6a71762e 0x125f1828 0x36ab1a41 0xb7e9e852 0x7bd0011a 0x7279e0b8 0xf37e189c 0x8cf00963 0x00000100 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000377 0x00000004 0x00000004 0x00000004 0x00000002 0x00000003 0x69616c40 0x00000003 0x6d634066 0x00000010 0x66633630 0x73797363>;
            rsa,c = <0x00000000>;
            rsa,r-squared = <0x00000000>;
            rsa,modulus = <0xc25ae693 0xc359f2a4 0xa866c89d 0xb7b1994f 0xf9f9f690 0x518d54a7 0xda0b83e8 0x06606e12 0x6ad1cbf9 0x92438edd 0x81e039c0 0x5d7322cc 0x124cdc80 0xa0c3288a 0x9265c3ae 0x6ac47a4b 0x00000003 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000008 0x00000003 0x00000003 0x00000003 0x00000002 0x73657300 0x2f736572 0x00000000 0x2f64776d 0x00000003 0x6d634066 0x00000001 0x30303000 0x726f636b 0x67726600 0x00000008 0x00000003 0x00000004 0x00000001 0x30303000 0x726f636b 0x706d7567 0x00000003 0x00001000 0x00000003 0x00000002 0x6e616765 0x30000000 0x726f636b 0x706d7500 0x00000008>;
            rsa,exponent-BN = <0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000003 0x00010001 0xe95771c5 0x00000800 0x64657600 0x616c6961 0x0000002c 0x30303030 0x00000034 0x30303000 0x2f64776d 0x00000002 0x65303030 0x0000001b 0x3132362d 0x00000003 0x00020000 0x00000003 0x00000002 0x65303230 0x0000001b 0x3132362d 0x6e000000 0xfe020000 0x00000042 0x0000006d 0x722d6d61 0x65303030 0x0000001b 0x3132362d 0x00000003 0x00001000 0x00000002 0x6e74726f 0x30000000 0x726f636b 0x706d7563 0x0000003e 0x00000004 0x00000004 0x00000004 0x00000000 0x00000050 0x636c6f63 0x40666634 0x00000014 0x2c727631 0x00000008>;
            rsa,exponent = <0x00000000 0x00000368>;
            rsa,n0-inverse = <0xe95771c5>;
            rsa,num-bits = <0x00000800>;
            key-name-hint = "dev";
        };
    };
```

#### key使用

从Maskrom到kernel为止的安全启动，统一使用一把RSA公钥完成安全校验：

- Maskrom校验loader。

  RSA公钥需要使用PC工具`SecureBootTool` 写入loader的文件头中；安全启动时Maskrom从loader文件头中拿RSA公钥（会对公钥进行合法性校验）对loader进行安全校验。

- SPL校验U-Boot和trust。

  SPL把RSA公钥保存在u-boot-spl.dtb中，u-boot-spl.dtb会被打包进u-boot-spl.bin文件（最后打包进loader）；安全启动时SPL从自己的dtb文件中拿出RSA公钥对uboot.img进行安全校验。

- U-Boot校验boot。

  U-Boot把RSA公钥保存在u-boot.dtb中，u-boot.dtb会被打包进u-boot.bin文件（最后打包为uboot.img）；安全启动时U-Boot从自己的dtb文件中拿RSA公钥对boot.img进行校验。

所以当前的RSA Key已经作为自身固件的一部分，由前一级loader完成了安全校验，从而保证了Key 的安全。

#### 签名存放

RSA的签名结果被保存在itb文件中；被签名内容由`hashed-nodes`指定：包括了整个`conf`节点的属性、被打包固件的节点等。

如下是u-boot.itb的签名信息，同理boot.itb：

```c
cjh@ubuntu:~/uboot-nextdev$ fdtdump uboot.img | less
/dts-v1/;
......

	configurations {
        default = "conf";
        conf {
            description = "Rockchip armv7 with OP-TEE";
            // 当前的固件版本号
            rollback-index = <0x0000001c>;
            firmware = "optee";
            loadables = "uboot";
            fdt = "fdt";

            // 被签名内容和签名结果，由mkimage自动插入
            signature {
                hashed-strings = <0x00000000 0x000000da>;
                // 指定被签名内容
                hashed-nodes = "/", "/configurations/conf", "/images/fdt", "/images/fdt/hash", "/images/optee", "/images/optee/hash", "/images/uboot", "/images/uboot/hash";
                // 进行签名的时间、签名者、版本
                timestamp = <0x5e9427b4>;
                signer-version = "2017.09-g8bb63db-200413-dirty #cjh";
                signer-name = "mkimage";
                // 签名结果！！(采用sha256+rsa2048)
                value = <0x78397d5d 0xb9219a0b 0xa7cb91a7 0xe1f32867 0x62719d9b 0x8901200c 0xfcbac03a 0x1295ccc8 0x1cff9608 0xdf5f69d2 0x21391225 0x7af10ca7 0x5527864f 0xb13f527e 0xddf9ee62 0xea50199d 0x00000003 0x35362c72 0x00000004 0x00000017 0x77617265 0x00000002 0x00000009 0x23616464 0x6d616765 0x73006172 0x6f6e006c 0x72790064 0x61636b2d 0x7265006c 0x006b6579 0x69676e2d 0x706f7369 0x7a650074 0x75650073 0x69676e65 0x73686564 0x642d7374 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000 0x00000000>;
                algo = "sha256,rsa2048";
                key-name-hint = "dev";
                sign-images = "fdt", "firmware", "loadables";
            };
        };
    };
```

#### 防回滚

- 安全启动支持对boot.img和uboot.img分别指定当前固件版本号，如果当前固件版本号小于机器上的最小版本号，则不允许启动。

- 最小版本号的更新：完成安全校验且确认系统可以正常启动后，被更新到OTP中。

### 前期准备

#### key

U-Boot工程下执行如下三条命令可以生成签名用的RSA密钥对。

```c
// 1. 放key的目录：keys
mkdir -p keys

// 2. 使用RK的"SecureBootTool"工具生成RSA2048的私钥，存放为：keys/dev.key
...

// 使用-x509和私钥生成一个自签名证书：keys/dev.crt （实际等同于公钥）
openssl req -batch -new -x509 -key keys/dev.key -out keys/dev.crt
```

查看结果：

```
cjh@ubuntu:~/uboot-nextdev$ ls keys/
dev.crt  dev.key
```

> 注意：上述的"keys"、"dev.key"、"dev.crt" 名字都不可变。因为这些名字已经在its文件中静态定义，如果改变则会打包失败。

#### 配置

U-Boot的defconfig打开如下配置：

```c
// 必选。
CONFIG_FIT_SIGNATURE=y
CONFIG_FIT_SPL_SIGNATURE=y

// 可选。
CONFIG_FIT_ROLLBACK_PROTECT=y       // boot.img防回滚
CONFIG_SPL_FIT_ROLLBACK_PROTECT=y   // uboot.img防回滚
```

#### 固件

把SDK工程下生成的boot.img复制一份到U-Boot根目录下。

### 编译打包

#### 不防回滚

编译命令：

```c
./make.sh rv1126 --spl-new --boot_img boot.img
```

编译结果：

```c
......

Signature check OK
out:rv1126_spl_loader_v1.00.100.bin
fix opt:rv1126_spl_loader_v1.00.100.bin
merge success(rv1126_spl_loader_v1.00.100.bin)
/home4/cjh/uboot-nextdev
pack loader(SPL) okay! Input: /home4/cjh/rkbin/RKBOOT/RV1126MINIALL.ini
pack loader with new: spl/u-boot-spl.bin

// 编译完成后，生成已签名的uboot.img和boot.img。
// rv1126_spl_loader_v1.00.100.bin需要用RK的"SecureBootTool"工具单独签名。
Image(signed):  uboot.img (FIT with uboot, trust) is ready
Image(signed):  boot.img (FIT with kernel, fdt, resource...) is ready
Image(no-signed):  rv1126_spl_loader_v1.00.100.bin (with spl, ddr, usbplug) is ready

Platform RV1126 is build OK, with new .config(make rv1126-secure_defconfig)
```

#### 防回滚

编译命令：

```c
// 指定 uboot.img和boot.img的最小版本号分别为10、12.
./make.sh rv1126 --spl-new --boot_img boot.img --rollback-index-uboot 10 --rollback-index-boot 12
```

编译结果：

```c
......
Signature check OK
out:rv1126_loader_v1.00.100.bin
fix opt:rv1126_loader_v1.00.100.bin
merge success(rv1126_loader_v1.00.100.bin)
/home4/cjh/uboot-nextdev
pack loader(SPL) okay! Input: /home4/cjh/rkbin/RKBOOT/RV1126MINIALL.ini
./rv1126_spl_loader_v1.00.100.bin

// 编译完成后，生成已签名的uboot.img和boot.img，且包含防回滚版本号。
// rv1126_spl_loader_v1.00.100.bin需要用RK的"SecureBootTool"工具单独签名。
Image(signed, rollback-index=10):  uboot.img (FIT with uboot, trust) is ready
Image(signed, rollback-index=12):  boot.img (FIT with kernel, fdt, resource...) is ready
Image(no-signed):  rv1126_spl_loader_v1.00.100.bin (with spl, ddr, usbplug) is ready
```

#### 注意事项

- rv1126_spl_loader_v1.00.100.bin 由maskrom完成安全校验，所以需要打包成loader后由"SecureBootTool"工具单独签名（增加maskrom可识别的RK签名头）。

- 必须通过`--boot_img`指定boot.img，目的是让U-Boot重新打包并签名，否则会提示失败：

  ```c
  ERROR: No images/rk-kernel.dtb  // 即没有指定 --boot_img参数，也没有在默认目录存放子固件
  ```

- 开启防回滚功能后必须指定`--rollback-index-uboot`和`--rollback-index-boot`参数。

- `--spl-new`：如果编译命令不带此参数，则默认使用rkbin中的spl文件打包生成loader；否则使用当前编译的spl文件打包loader。

  因为u-boot-spl.dtb中需要被打包进RSA公钥（来自于用户），所以RK发布的SDK不会在rkbin仓库提交支持安全启动的spl文件。因此，用户编译时要指定该参数。但是用户也可以把自己的spl版本提交到rkbin工程，此后编译固件时就可以不再指定此参数，每次都使用这个稳定版的spl文件。

- 编译后会生成三个固件：loader、uboot.img、boot.img，只要RSA key 没有更换，就允许单独更新其中的任意固件，而不需要全部更新。

### 启动信息

如下是安全启动的信息：

```c
BW=32 Col=10 Bk=8 CS0 Row=15 CS=1 Die BW=16 Size=1024MB
out
U-Boot SPL board init
U-Boot SPL 2017.09-gacb99c5-200408-dirty #cjh (Apr 09 2020 - 20:51:21)
unrecognized JEDEC id bytes: 00, 00, 00

Trying to boot from MMC1
// SPL完成签名校验
sha256,rsa2048:dev+
// 防回滚检测：当前uboot.img固件版本号是10，本机的最小版本号是9
rollback index: 10 >= 9, OK
// SPL完成各子镜像的hash校验
## Checking optee ... sha256+ OK
## Checking uboot ... sha256+ OK
## Checking fdt ... sha256+ OK

Jumping to U-Boot via OP-TEE
I/TC:
E/TC:0 0 plat_rockchip_pmu_init:2003 0
E/TC:0 0 plat_rockchip_pmu_init:2006 cpu off
E/TC:0 0 plat_rockchip_pmusram_prepare:1945 pmu sram prepare 0x14b10000 0x8400880 0x1c
E/TC:0 0 plat_rockchip_pmu_init:2020 pmu sram prepare
E/TC:0 0 plat_rockchip_pmu_init:2056 remap
I/TC: OP-TEE version: 3.6.0-233-g35ecf936 #1 Tue Mar 31 08:46:13 UTC 2020 arm
I/TC: Next entry point address: 0x00400000
I/TC: Initialized


U-Boot 2017.09-gacb99c5-200408-dirty #cjh (Apr 09 2020 - 20:51:21 +0800)

Model: Rockchip RV1126 Evaluation Board
PreSerial: 2
DRAM:  1023.5 MiB
Sysmem: init
Relocation Offset: 00000000, fdt: 3df404e0
Using default environment

dwmmc@ffc50000: 0
Bootdev(atags): mmc 0
MMC0: HS200, 200Mhz
PartType: EFI
boot mode: normal
conf: sha256,rsa2048:dev+
resource: sha256+
DTB: rk-kernel.dtb
FIT: signed, conf required
HASH(c): OK

I2c0 speed: 400000Hz
PMIC:  RK8090 (on=0x10, off=0x00)
vdd_logic 800000 uV
vdd_arm 800000 uV
vdd_npu init 800000 uV
vdd_vepu init 800000 uV
......

Hit key to stop autoboot('CTRL+C'):  0
## Booting FIT Image at 0x3d8122c0 with size 0x0052b200
Fdt Ramdisk skip relocation
## Loading kernel from FIT Image at 3d8122c0 ...
   Using 'conf' configuration
   // uboot完成签名校验
   Verifying Hash Integrity ... sha256,rsa2048:dev+ OK
   // 防回滚检测：当前boot.img固件版本号是22，本机的最小版本号是21
   Verifying Rollback-index ... 22 >= 21, OK
   Trying 'kernel' kernel subimage
     Description:  Kernel for arm
     Type:         Kernel Image
     Compression:  uncompressed
     Data Start:   0x3d8234c0
     Data Size:    5349248 Bytes = 5.1 MiB
     Architecture: ARM
     OS:           Linux
     Load Address: 0x02008000
     Entry Point:  0x02008000
     Hash algo:    sha256
     Hash value:   64b4a0333f7862967be052a67ee3858884fcefebf4565db5c3828a941a15f34a
   Verifying Hash Integrity ... sha256+ OK  // 完成kernel的hash校验
## Loading ramdisk from FIT Image at 3d8122c0 ...
   Using 'conf' configuration
   Trying 'ramdisk' ramdisk subimage
     Description:  Ramdisk for arm
     Type:         RAMDisk Image
     Compression:  uncompressed
     Data Start:   0x3dd3d4c0
     Data Size:    0 Bytes = 0 Bytes
     Architecture: ARM
     OS:           Linux
     Load Address: 0x0a200000
     Entry Point:  unavailable
     Hash algo:    sha256
     Hash value:   e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
   Verifying Hash Integrity ... sha256+ OK  // 完成ramdisk的hash校验
   Loading ramdisk from 0x3dd3d4c0 to 0x0a200000
## Loading fdt from FIT Image at 3d8122c0 ...
   Using 'conf' configuration
   Trying 'fdt' fdt subimage
     Description:  Device tree blob for arm
     Type:         Flat Device Tree
     Compression:  uncompressed
     Data Start:   0x3d812ec0
     Data Size:    66974 Bytes = 65.4 KiB
     Architecture: ARM
     Load Address: 0x08300000
     Hash algo:    sha256
     Hash value:   8fb1f170766270ed4f37cce4b082a51614cb346c223f96ddfe3526fafc5729d7
   Verifying Hash Integrity ... sha256+ OK // 完成fdt的hash校验
   Loading fdt from 0x3d812ec0 to 0x08300000
   Booting using the fdt blob at 0x8300000
   Loading Kernel Image from 0x3d8234c0 to 0x02008000 ... OK
   Using Device Tree in place at 08300000, end 0831359d
Adding bank: 0x00000000 - 0x08400000 (size: 0x08400000)
Adding bank: 0x0848a000 - 0x40000000 (size: 0x37b76000)
Total: 236.327 ms

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0xf00
[    0.000000] Linux version 4.19.111 (cjh@ubuntu) (gcc version 6.3.1 20170404 (Linaro GCC 6.3-2017.05)) #28 SMP PREEMPT Wed Mar 25 16:03:27 CST 2020
[    0.000000] CPU: ARMv7 Processor [410fc075] revision 5 (ARMv7), cr=10c5387d
```

## 远程签名

从上述的章节可以看出，制作安全固件时要求用户在本地PC上完成，即用户必须持有：RSA密钥对和固件。但在实际场景中，用户可能需要把固件上传到远程服务器，由服务器持有RSA私钥完成签名，然后把签名过的固件返回给本地用户。对于这种情况，RK的FIT方案上需要通过"重签名"实现。

### 实现思路

- 因为只能拿到服务器的公钥，所以用户先用临时私钥+服务器公钥在本地PC上对固件进行一次打包签名，会生成带有临时签名的安全固件和被签名数据；

  > 公钥的作用是为了把公钥打包进dtb文件，在安全启动流程时使用；私钥的作用是做临时签名。

- 用户把被签名数据发送给服务器即可（不需整个固件，更节省时间），服务器使用私钥对被签名数据进行签名，然后把签名返回给用户；

- 用户使用这份签名替换安全固件中的临时签名即可获得最后用于烧写的安全固件。

### 被签名数据

上述章节提到的被签名数据包含：fdt blob配置 + 子镜像hash集合。

- fdt blob 节点配置

  `hashed-nodes`指定了一系列节点，这些节点的内容都会纳入被签名数据。

  ```c
  cjh@ubuntu:~/uboot-nextdev$ fdtdump uboot.img | less
  /dts-v1/;
  ......

  configurations {
          default = "conf";
          conf {
              description = "Rockchip armv7 with OP-TEE";
              rollback-index = <0x0000001c>;
              firmware = "optee";
              loadables = "uboot";
              fdt = "fdt";

              signature {
                  hashed-strings = <0x00000000 0x000000da>;
                  // 这些节点的内容都会纳入被签名数据
                  hashed-nodes = "/", "/configurations/conf", "/images/fdt", "/images/fdt/hash", "/images/optee", "/images/optee/hash", "/images/uboot", "/images/uboot/hash";
                  ......
  ```

- 子镜像hash的集合。

  mkimage会为各个子镜像自动生成hash值，并追加进hash节点。`sign-images`指定的所有子镜像hash值都会纳入被签名数据（本质是通过`hashed-nodes`进行指定了hash节点）。例如：

  ```c
  cjh@ubuntu:~/uboot-nextdev/u-boot$ fdtdump fit/u-boot.itb | less

  /dts-v1/;
  ......

  / {
      totalsize = <0x000bb600>;
      timestamp = <0x5ecb3553>;
      description = "Simple image with OP-TEE support";
      #address-cells = <0x00000001>;
      images {
          uboot {
              data-size = <0x0007ed54>;
              data-position = <0x00000a00>;
              description = "U-Boot";
              type = "standalone";
              os = "U-Boot";
              arch = "arm";
              compression = "none";
              load = <0x00400000>;
              hash {
                  // uboot镜像的hash，由mkimage工具自动计算生成
                  value = <0xeda8cd52 0x8f058118 0x00000003 0x35360000 0x6f707465 0x0000009f 0x00000091 0x00000000>;
                  algo = "sha256";
              };
          };
          ......
  ```

### 具体步骤

用于签名固件的RSA密钥对是：dev.key和dev.crt，dev.key作为私钥由远程服务器持有，用户只有公钥dev.crt。

**步骤1：**

在本地U-Boot工程环境下：用户把dev.crt放到keys目录下，然后用RK的"SecureBootTool"工具随机生成一把临时私钥，命名为dev.key放到keys目录下。参考上面的章节（但是编译参数要追加`--no-check`）生成签名固件uboot.img和boot.img（实际最后不会被使用，用户需要的是中间文件）。

注意：**编译命令要指定参数`--no-check`**，否则会因为dev.key和dev.crt不匹配导致打包脚本自校验失败。比如：

```c
./make.sh rv1126 --spl-new --boot_img boot.img --rollback-index-uboot 10 --rollback-index-boot 12 --no-check
```

除了生成签名固件uboot.img和boot.img，用户还可以在`fit/`目录下得到中间文件：

```c
// 被签名内容(data2sign意为：data to sign)
fit/uboot.data2sign
fit/boot.data2sign

// 已签名itb文件（使用临时私钥），我们的img文件由它们进行多备份后获得。
fit/uboot.itb
fit/boot.itb
```

**步骤2：**

用户把uboot.data2sign发送给远程服务器。假设远程服务器持有的私钥为dev.key，使用如下命令签名并输出签名结果：uboot.sig

```
openssl dgst -sha256 -sign dev.key -out  uboot.sig  uboot.data2sign
```

服务器把签名结果文件uboot.sig返回给用户，用户使用uboot.sig替换uboot.itb中的临时签名：

```c
./scripts/fit-resign.sh -f fit/uboot.itb -s uboot.sig // 会生成新的uboot.img，用于烧写
```

同理boot.itb文件。由此用户获得了最终有效的签名固件uboot.img和boot.img。

**注意事项**：

- fit-resign.sh时-f 指定的itb文件，不是img文件。脚本会对itb重签名后生成img文件。
- 执行fit-resign.sh时用的itb文件必须是步骤1编译生成的，即itb文件和data2sign文件是一对一对应的，因为data2sign信息中包含了生成itb文件的时间戳，即`/timestamp = <...>` 。所以即使当前没有任何代码改动，重新编译获得一个新的uboot.itb，把uboot.sig替换进新的uboot.itb中也会引起安全启动失败！

### 其它方案

除了"重签名"方式，是否可以直接上传整个固件（boot.img, uboot.img）或分立镜像（u-boot.bin, fdt, ramdisk, kernel ...）给服务器进行签名？

基于FIT的设计原理和实现，其它方案的实现比较困难。如下进行说明：

- 方案一：上传非安全的boot.img, uboot.img给服务器重新打包+签名

  问题点：还需要上传本地U-Boot编译环境下的配置信息、u-boot-spl.bin文件等。

- 方案二：上传安全的boot.img, uboot.img给服务器重新打包+签名

  问题点：本地编译固件时已经打包了RSA公钥，服务器会进行RSA公钥二次打包。

- 方案三：上传所有分立镜像（kernel, dtb, ramdisk, resource...）进行打包+签名

  问题点：上传文件太多，比较繁琐，而且同样存在方案一的问题。

> 以上方案的共同问题点：服务器端必须使用RK的mkimage工具，而这个工具有可能被RK更新。

所以目前的"重签名"是操作最简便、没有依赖、最不容易出错的方案：用户只需上传被签名数据，服务器使用openssl命令签名即可。

## 固件解包

用户可以借助脚本对固件解包，例如boot.img：

```c
cjh@ubuntu:~/uboot-nextdev$ ./scripts/fit-unpack.sh -f boot.img -o out
Unpack to directory out:
  fdt                 : 82813 bytes... sha256+
  kernel              : 5844640 bytes... sha256+
  ramdisk             : 0 bytes... sha256+
  resource            : 120832 bytes... sha256+
```

> 如果img包含多备份，脚本只解包第一份itb；sha256+表示固件没有损坏，否则显示sha256-。
