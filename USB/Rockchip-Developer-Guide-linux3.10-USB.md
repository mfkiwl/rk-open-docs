# **Kernel 3.10 USB 开发指南**

发布版本：1.1

作者邮箱：wulf@rock-chips.com、frank.wang@rock-chips.com、daniel.meng@rock-chips.com

日期：2017.12

文件密级：公开资料

------
**前言**

**概述**

本文档为Rockchip Kernel 3.10 SDK USB开发指南，主要从USB相关的Kernel配置、DT配置、驱动开发和常见问题分析等方面介绍USB开发的基本方法。

**读者对象**

软件工程师，硬件工程师，技术支持工程师

**修订记录**

| **日期**     | **版本** | **作者**      | **修改说明**             |
| ---------- | ------ | ----------- | -------------------- |
| 2017-02-16 | v1.0   | 吴良峰 王明成 孟东阳 | 初始版本                 |
| 2017-12-20 | v1.1   | 王明成         | 支持MD格式，删除硬件电路并修订全文章节 |

-----
[TOC]

------
## 概述

Rockchip SOC通常内置多个USB控制器，不同控制器互相独立，请从芯片TRM中获取详细信息。由于部分USB控制器有使用限制，所以请务必明确方案的需求及控制器限制后，再确定USB的使用方案。

Rockchip SoC内置的USB控制器如下表：

| 芯片\控制器  | EHCI&OHCI | DWC2 | DWC3 |
| ------- | :-------: | :--: | :--: |
| RV1108  |     1     |  1   |  0   |
| RK312X  |     1     |  1   |  0   |
| RK3288  |     1     |  2   |  0   |
| RK322X  |     3     |  1   |  0   |
| RK322XH |     1     |  1   |  1   |
| RK3328  |     1     |  1   |  1   |
| RK3368  |     1     |  1   |  0   |

------
## Kernel模块配置

USB模块的配置及保存和其它内核模块的配置方法一样：

-   导入默认配置
  ```make ARCH=arm64 rockchip_defconfig```
-   选择kernel配置
  ```make ARCH=arm64 menuconfig```
-   保存default配置
  ```make ARCH=arm64 savedefconfig```
  保存default配置，然后用defconfig替换rockchip_defconfig

Rockchip默认配置通常有rockchip_defconfig和rockchip_linux_defconfig两个配置，前者用于Android平台，后者用于开源项目Linux平台。

### USB PHY相关配置

USB PHY子系统的配置菜单位于：

```
Location:
	-> Device Drivers
		-> PHY Subsystem
```
如下分别为USB2.0和USB3.0 PHY配置选项，其中"Rockchip USB2 PHY Driver"选项用于配置除RV1108 SoC外的Rockchip USB2.0 PHY；"Rockchip INNO USB3PHY Driver"选项用于配置Rockchip USB3.0 PHY(INNO IP)。

```
------------ PHY Subsystem -----------
[*] PHY Core
< > Broadcom Kona USB2 PHY Driver
< > Rockchip USB2 PHY Driver
< > RV1108 USB2PHY Driver
< > Rockchip INNO USB3PHY Driver
```

### USB HOST相关配置

USB HOST配置菜单位于：

```
Location:
	-> Device Drivers
		-> USB support
```

选上USB Support项后，进一步对USB子系统进行配置，如下为USB HOST的配置选项。

```
--- USB support
<*>   Support for Host-side USB
...

      *** USB Host Controller Drivers ***
<*>   xHCI HCD (USB 3.0) support
[ ]     Debugging for the xHCI host controller (NEW)
<*>   EHCI HCD (USB 2.0) support
[*]     Root Hub Transaction Translators
[*]     Improved Transaction Translator scheduling
< >   Support for Synopsys Host-AHB USB 2.0 controller
<*>   Generic EHCI driver for a platform device
<*>   OHCI HCD support
[*]     Generic OHCI driver for a platform device
```

需要支持USB HOST，首先需要选上"Support for Host-side USB"项，然后会出现如下的HOST相关的配置，其中，HOST1.1 选择"OHCI HCD support" 配置；HOST2.0 选择"EHCI HCD (USB 2.0) support"配置，HOST3.0选择"xHCI HCD (USB 3.0) support"配置。

### USB OTG相关配置

Rockchip OTG使用DWC2控制器，driver使用dwc_otg_310，config配置菜单如下：

```
Location:
	-> Device Drivers
		-> USB support (USB_SUPPORT [=y])
			-> ROCKCHIP USB Support
				-> RockChip USB 2.0 OTG controller
```

### USB Gadget配置

```
--- USB Gadget Support
...
<*>   USB Gadget Drivers (Android Composite Gadget)  --->
...
```

```
--------- USB Gadget Drivers -------
( ) Gadget Zero (DEVELOPMENT)
( ) Audio Gadget
( ) Ethernet Gadget (with CDC Ethernet support)
( ) Network Control Model (NCM) support
( ) Gadget Filesystem
( ) Function Filesystem
( ) Mass Storage Gadget
( ) Serial Gadget (with CDC ACM and CDC OBEX support)
( ) MIDI Gadget
( ) Printer Gadget
(X) Android Composite Gadget
( ) CDC Composite Device (Ethernet and ACM)
( ) CDC Composite Device (ACM and mass storage)
( ) Multifunction Composite Gadget
( ) HID Gadget
( ) EHCI Debug Device Gadget
( ) USB Webcam Gadget
```

目前，Rockchip支持MTP、PTP、Accessory、ADB、Audio、ACM等Gadget Function，通过Android Composite Gadget驱动管理。

### USB其它模块配置

#### Mass Storage Class（MSC）

U盘属于SCSI设备，所以在配置USB模块之前需要配置SCSI选项（默认配置已经选上）。
```
Location:
	-> Device Drivers
		-> SCSI device support

    *** SCSI support type (disk, tape, CD-ROM) ***
<*> SCSI disk support
< > SCSI tape support (NEW)
< > SCSI OnStream SC-x0 tape support (NEW)
< > SCSI CDROM support (NEW)
< > SCSI generic support (NEW)
< > SCSI media changer support (NEW)
...
```
配置完"SCSI disk support"后，可以在"USB support"中找到如下选项，选上即可。

```
 Location:
 -> Device Drivers
 	-> USB support (USB_SUPPORT [=y])
 		-> Support for Host-side USB (USB [=y])
 			-> USB_STORAGE
```

#### USB Serial Converter

-   支持USB 3G Modem

USB 3G Modem使用的是USB转串口，使用时需要选上如下选项：

```
Location:
	-> Device Drivers
		-> USB support (USB_SUPPORT [=y])
			-> USB Serial Converter support (USB_SERIAL [=y])
				<*>   USB driver for GSM and CDMA modems
```

-   支持PL2303

如果要使用PL2303，输出数据到串口，需要选择如下选项：

```
Location:
	-> Device Drivers
		-> USB support (USB_SUPPORT [=y])
			-> USB Serial Converter support (USB_SERIAL [=y])
				<*>   USB Prolific 2303 Single Port Serial Driver
```

-   支持USB GPS

如果要支持USB GPS，如u-blox 6 - GPS Receiver设备，需要选择如下选项：
```
Location:
	-> Device Drivers
		-> USB support (USB_SUPPORT [=y])
			-> Support for Host-side USB (USB [=y])
				<*>     USB Modem (CDC ACM) support
```
#### USB HID

USB键鼠的配置选项如下：
```
Location:
	-> Device Drivers
		-> HID support
			[*]   /dev/hidraw raw HID device support
			<*>   User-space I/O driver support for HID subsystem
			<*>   Generic HID driver
 			-> USB HID support
 				<*> USB HID transport layer
 				[ ] PID device support
 				[*] /dev/hiddev raw HID device support
```
#### USB Net

-   USB Bluetooth
```
Location:
	-> Networking support (NET [=y])
		-> Bluetooth subsystem support (BT [=y])
			-> Bluetooth device drivers
				< > HCI USB driver
				<*> RTK HCI USB driver
				< > HCI SDIO driver
				<*> HCI UART driver
				...
```

-   USB Wifi
  通常直接使用Vendor提供的驱动和配置。

```
Location:
	-> Device Drivers
		-> Network device support (NETDEVICES [=y])
			-> USB Network Adapters
				-> Multi-purpose USB Networking Framework (USB_USBNET [=y])
					...
```

#### USB Camera
```
Location:
	-> Device Drivers
		-> Multimedia support (MEDIA_SUPPORT [=y])
			-> Media USB Adapters (MEDIA_USB_SUPPORT [=y])
				<*>   USB Video Class (UVC)
				[*]     UVC input events device support
```
#### USB Audio
```
Device Drivers --->
[*]  Sound card support
[*]  Advanced Linux Sound Architecture --->
[*]  USB sound devices --->
[*]  USB Audio/MIDI driver
```
#### USB HUB

如果要支持USB HUB，请将“Disable external HUBs”配置选项去掉。
```
Device Drivers --->
[*]  USB support --->
[ ]     Disable external hubs
```
#### 其它USB设备配置

USB设备种类还有很多，如GPS，Printer等，部分USB设备需要Vendor定制的驱动，也有可能使用标准的Class驱动，这类驱动可以直接参考内核相似驱动的配置或在网络上搜索其配置方法，Rockchip平台本身没有限制。

------
## Device Tree开发

ARM Linux内核从Linux-3.x内核开始取消了传统的设备文件而用设备树（DT）取代，因此，Kernel 3.10有关硬件描述的信息都需要放入DTSI/DTS中配置，下面对涉及到USB模块相关的DT开发做以详细说明。

### USB PHY DTS

USB PHY的配置主要包括PHY的时钟、中断配置、Vbus Supply，Reset等的配置。

#### USB 2.0 PHY DTS

USB2.0 PHY详细配置可参考内核文档：
```Documentation/devicetree/bindings/phy/phy-rockchip-usb2.txt```

具体分为DTSI和DTS两部分配置，下面以RK3328的一个Host Port的PHY为例说明。

如下为DTSI的配置，通常配置PHY的公共属性。

```
usb2phy_grf: syscon@ff450000 {
	compatible = "rockchip,rk322xh-usb2phy-grf",
				 "rockchip,usb2phy-grf", "syscon", "simple-mfd";
	reg = <0x0 0xff450000 0x0 0x1000>;

	u2phy: usb2-phy@104 {
		compatible = "rockchip,rk322xh-usb-phy";
		#address-cells = <1>;
		#size-cells = <0>;
		status = "disabled";

		u2phy_host: host-port {
			#phy-cells = <0>;
			reg = <0x104>;
			interrupts =<GIC_SPI 62 IRQ_TYPE_LEVEL_HIGH>;
			interrupt-names = "linestate";
		};
	};
};
```

首先，USB PHY Driver中都是在操作GRF，所以USB PHY的节点必须作为GRF的一个子节点。

其次，USB PHY节点中包括USB PHY的硬件属性和PHY Port的硬件属性，其中PHY的属性为所有Port的共有属性，如Input时钟；Port属性主要包括各个Port所拥有的中断，如Linestate中断。

最后，需要注意的是Port的名称，HOST对应的Port要求命名为“host-port”，OTG对应的命名为“otg-port”，因为Driver中会根据这两个名字做不同Port的初始化。

DTS的配置，主要根据不同的产品形态，配置PHY的私有属性。目前SDK DTS的配置，主要包括phy-port的使能以及phy-Supply即Vbus Supply的配置。下面给出一个配置Vbus Supply的参考（有些产品形态Vbus 5V为常供电，不需要在DTS中配置）。

Vbus supply的配置一般有两种方式，一种是配置成GPIO形式，直接在驱动中通过操作GPIO，控制VBUS的供给；另外一种是目前内核比较通用的Regulator配置方式，其主要在Regulator及pinctrl两个节点中进行配置。

```
vcc_host: vcc-host-regulator {
	compatible = "regulator-fixed";
	enable-active-high;
	gpio = <&gpio3 20 GPIO_ACTIVE_HIGH>;
	pinctrl-names = "default";
	pinctrl-0 = <&host_vbus_drv>;
	regulator-name = "vcc_host";
	regulator-always-on;
	regulator-boot-on;
};

...

&pinctrl {
	...
	usb {
		host_vbus_drv: host-vbus-drv {
			rockchip,pins = <3 20 RK_FUNC_GPIO &pcfg_pull_none>;
		};
	};
};
```

上面为一个vbus-host regulator的配置实例，“enable-active-high”属性标识GPIO拉高使能；“pinctrl-0 = <&host_vbus_drv>;” Property代表这个regulator所引用的Pinctrl中节点的名称，具体Regulator的配置可参考Linux Kernel相关Regulator的文档。在host_vbus_drv的pinctrl节点中，“rockchip,pins” 属性即GPIO信息，需要从硬件原理图获知。

通常对于USB模块而言，vbus-regulator应该放在板级DTS中做配置。

在配置完Regulator及pinctrl两个节点后，USB2 PHY port就可以引用该节点，对Vbus的属性“phy-supply”进行配置，如下所示。

```
&u2phy_host {
        phy-supply = <&vcc_host>;
};
```

#### USB 3.0 PHY DTS

目前，3.10内核仅支持Innosilicon USB3.0 IP这一种USB PHY，详细的配置说明可查看如下内核文档：
```Documentation/devicetree/bindings/phy/phy-rockchip-inno-usb3.txt```

以RK3328为例，

```
u3phy: usb3-phy@ff470000 {
	compatible = "rockchip,rk322xh-u3phy";
	reg = <0x0 0xff470000 0x0 0x0>;
	rockchip,u3phygrf = <&usb3phy_grf>;
	rockchip,grf = <&grf>;
	clocks = <&clk_gates28 1>, <&clk_gates28 2>;
	clock-names = "usb3phy-otg", "usb3phy-pipe";
	interrupts = <GIC_SPI 77 IRQ_TYPE_LEVEL_HIGH>;
	interrupt-names = "linestate";
	resets = <&reset RK322XH_SRST_USB3PHY_U2>,
			 <&reset RK322XH_SRST_USB3PHY_U3>,
			 <&reset RK322XH_SRST_USB3PHY_PIPE>,
			 <&reset RK322XH_SRST_USB3OTG_UTMI>,
			 <&reset RK322XH_SRST_USB3PHY_OTG_P>,
			 <&reset RK322XH_SRST_USB3PHY_PIPE_P>;
	reset-names = "u3phy-u2-por", "u3phy-u3-por",
				  "u3phy-pipe-mac", "u3phy-utmi-mac",
				  "u3phy-utmi-apb", "u3phy-pipe-apb";
	usb30-drv-gpio = <&gpio0 GPIO_A0 GPIO_ACTIVE_LOW>;
	#address-cells = <2>;
	#size-cells = <2>;
	ranges;
	status = "disabled";

	u3phy_utmi: utmi@ff470000 {
		reg = <0x0 0xff470000 0x0 0x8000>;
		#phy-cells = <0>;
		status = "disabled";
	};

	u3phy_pipe: pipe@ff478000 {
		reg = <0x0 0xff478000 0x0 0x8000>;
		#phy-cells = <0>;
		status = "disabled";
	};
};
```

DTSI关键属性说明：

reset-names :
```
* "u3phy-u2-por" for the USB 2.0 logic of USB 3.0 PHY
* "u3phy-u3-por" for the USB 3.0 logic of USB 3.0 PHY
* "u3phy-pipe-mac" for the USB 3.0 PHY pipe MAC
* "u3phy-utmi-mac" for the USB 3.0 PHY utmi MAC
* "u3phy-utmi-apb" for the USB 3.0 PHY utmi APB
* "u3phy-pipe-apb" for the USB 3.0 PHY pipe APB
* "u3phy_utmi" : USB 2.0 utmi phy.
* "u3phy_pipe" : USB 3.0 pipe phy.
```
此外，“usb30-drv-gpio” 用于控制USB 3.0的VBUS 5V输出，需要根据实际的硬件设计进行配置，通过可放在板级DTS中配置。其余属性建议不要更改。

### USB Controller DTS

USB2.0控制器主要包括EHCI、OHCI、DWC-OTG。其中EHCI和OHCI，Rockchip采用Linux 内核Generic驱动，一般开发时只需要对DT作相应配置，即可正常工作。

#### USB 2.0 HOST Controller DTS

如下所示，为Rockchip平台上EHCI控制器的一个典型配置，主要包括register、interrupts、clocks的配置。需要注意，EHCI相关的时钟，通常需要配置EHCI控制器和EHCI/OHCI仲裁器这两个时钟。此外，phys直接引用对应phy-port的名称即可。

```
usb_ehci: usb@ff5c0000 {
	compatible = "generic-ehci";
	reg = <0x0 0xff5c0000 0x0 0x10000>;
	interrupts = <GIC_SPI 16 IRQ_TYPE_LEVEL_HIGH>;
	clocks = <&clk_gates19 6>, <&clk_gates19 7>;
	clock-names = "hclk_host0", "hclk_host0_arb";
	phys = <&u2phy_host>;
	phy-names = "usb";
	status = "disabled";
};
```

下面为Rockchip平台一个OHCI控制器的典型配置，需要配置的属性基本跟EHCI相同。

```
usb_ohci: usb@ff5d0000 {
	compatible = "generic-ohci";
	reg = <0x0 0xff5d0000 0x0 0x10000>;
	interrupts = <GIC_SPI 17 IRQ_TYPE_LEVEL_HIGH>;
	phys = <&u2phy_host>;
	phy-names = "usb";
	status = "disabled";
};
```

#### USB 2.0 OTG Controller DTS

Kernel 3.10 USB 2.0 OTG DTS包含“usb2_otg”和“dwc_control_usb”两个节点。其中，“usb2_otg”对应OTG控制器的硬件信息，而“dwc_control_usb”对应USB 2.0 OTG PHY的硬件信息，“dwc_control_usb”节点中包括一个充电检测子节点“usb_bc”。

节点中涉及相关硬件信号，如中断、时钟等可参阅对应芯片的TRM手册，详细的配置说明可参考如下内核文档：
```Documentation/devicetree/bindings/usb/rockchip-usb.txt```

```
usb2_otg: usb@ff580000 {
	compatible = "rockchip,rk322xh_usb20_otg";
	reg = <0x0 0xff580000 0x0 0x40000>;
	interrupts = <GIC_SPI 23 IRQ_TYPE_LEVEL_HIGH>;
	clocks = <&clk_gates17 14>, <&clk_gates19 8>, <&clk_gates19 9>;
	clock-names = "pclk_usb2grf", "hclk_otg", "hclk_otg_pmu";
	resets = <&reset RK322XH_SRST_USB2OTG_H>,
	<&reset RK322XH_SRST_USB2OTG_UTMI>,
	<&reset RK322XH_SRST_USB2OTG>;
	reset-names = "otg_ahb", "otg_phy", "otg_controller";
	/*0 - Normal, 1 - Force Host, 2 - Force Device*/
	rockchip,usb-mode = <0>;
	status = "disabled";
};

...

dwc_control_usb: dwc-control-usb {
	compatible = "rockchip,rk322xh-dwc-control-usb";
	rockchip,grf = <&usb2phy_grf>;
	interrupts = <GIC_SPI 59 IRQ_TYPE_LEVEL_HIGH>,
				 <GIC_SPI 60 IRQ_TYPE_LEVEL_HIGH>,
				 <GIC_SPI 61 IRQ_TYPE_LEVEL_HIGH>,
				 <GIC_SPI 62 IRQ_TYPE_LEVEL_HIGH>;
	interrupt-names = "otg_bvalid", "otg_id",
					  "otg_linestate", "host0_linestate";
	status = "disabled";

	usb_bc {
		compatible = "inno,phy";
		regbase = &dwc_control_usb;
		rk_usb,bvalid     = <0x120 9 1>;
		rk_usb,iddig      = <0x120 6 1>;
        rk_usb,vdmsrcen   = <0x108 12 1>;
        rk_usb,vdpsrcen   = <0x108 11 1>;
        rk_usb,rdmpden    = <0x108 10 1>;
        rk_usb,idpsrcen   = <0x108  9 1>;
        rk_usb,idmsinken  = <0x108  8 1>;
        rk_usb,idpsinken  = <0x108  7 1>;
        rk_usb,dpattach   = <0x120 25 1>;
        rk_usb,cpdet      = <0x120 24 1>;
        rk_usb,dcpattach  = <0x120 23 1>;
	};
};
```

#### USB 3.0 HOST Controller DTS

USB3.0 HOST控制器为XHCI，集成于DWC3 OTG IP中，所以不用单独配置dts，只需要配置DWC3，并且设置DWC3 的dr_mode属性为dr_mode = "host"，即可使能XHCI控制器。“phys”属性需要引用USB 3.0 PHY的u3phy_utmi和u3phy_pipe节点。

详细的配置说明，可参考如下内核文档：
```Documentation/devicetree/bindings/usb/rockchip,dwc3.txt```

```
usbdrd3: usb@ff600000 {
	compatible = "rockchip,rk322xh-dwc3";
	clocks = <&clk_usb3otg_ref>, <&clk_usb3otg0_s>,
			 <&clk_gates19 14>;
	clock-names = "ref_clk", "suspend_clk",
				  "bus_clk";
	#address-cells = <2>;
	#size-cells = <2>;
	ranges;
	status = "disabled";

    usbdrd_dwc3: dwc3@ff600000 {
    	compatible = "snps,dwc3";
    	reg = <0x0 0xff600000 0x0 0x100000>;
    	interrupts = <GIC_SPI 67 IRQ_TYPE_LEVEL_HIGH>;
    	dr_mode = "host";
    	phys = <&u3phy_utmi>, <&u3phy_pipe>;
    	phy-names = "usb2-phy", "usb3-phy";
    	phy_type = "utmi_wide";
    	snps,dis_enblslpm_quirk;
    	snps,dis-u2-freeclk-exists-quirk;
    	snps,dis_u2_susphy_quirk;
    	snps,dis-del-phy-power-chg-quirk;
    	snps,dis-u3-autosuspend-quirk;
    	snps,tx-ipgap-linecheck-dis-quirk;
    	status = "disabled";
    };
};
```

------
##  驱动开发

本章节主要对USB 控制器和PHY的驱动框架以及驱动的调试接口作简要描述。

### USB PHY Drivers

USB PHY drivers基于Generic PHY Framework (Documentation/phy.txt)，代码位于Kernel drivers/phy目录。

#### USB 2.0 PHY Driver

##### 驱动代码路径
  ```drivers/phy/phy-rockchip-usb.c```

该驱动主要实现USB 2.0 HOST PHY的Power控制， USB 2.0 PHY信号的tuning等操作。

##### 主要函数说明

```c
// 回调函数，控制不同SoC USB2.0 PHY的suspend/resume，以节省功耗；
rk3*_usb_phy_power()

// PHY Framework的power on/off 回调函数，供USB2.0 HOST控制器驱动调用；
rockchip_usb_phy_power_on()/rockchip_usb_phy_power_off()

// USB 2.0 PHY信号的tuning接口
rk3*_usb_phy_tuning()
```

#### USB 3.0 PHY Driver

##### 驱动代码路径
  ```drivers/phy/phy-rockchip-inno-usb3.c```

  该驱动主要实现USB 3.0 HOST PHY的Power控制，USB 3.0 PHY信号的tuning及USB3.0 PHY CLK的管理等。
##### 主要函数说明

```c
// USB3.0强制为USB2.0相关API
rockchip_u3phy_usb2_only_*()

// 复位USB3.0 PHY
rockchip_u3phy_rest_*()

// USB3.0 PHY clock的控制
rockchip_u3phy_clk_*()

// PHY Framework power on/off回调函数
rockchip_u3phy_power_on()/rockchip_u3phy_power_off()

// 检测USB3.0 PHY UTMI的line state及disconnect状态
rockchip_u3phy_um_sm_work()

// USB3.0 PHY硬件初始化
rockchip_u3phy_port_init()

// USB3.0 PHY的信号tuning
rk322xh_u3phy_tuning()
```

##### 主要数据结构

```c
// 描述USB3.0 PHY状态和控制寄存器；
static const struct rockchip_u3phy_cfg rk322xh_u3phy_cfgs[];
```

##### 内核调试接口

USB 3.0 PHY驱动提供了一个u3phy_mode节点，用于enable/disable USB 3.0 PHY的super-speed，路径位于
```/sys/kernel/debug/ff470000.usb3-phy/u3phy_mode```

使用方法如下：

```
1. Config to usb3.0 mode （enable super-speed）
echo u3 > /sys/kernel/debug/ff470000.usb3-phy/u3phy_mode

2. Config to usb2.0 only mode （disable super-speed）
echo u2 > /sys/kernel/debug/ff470000.usb3-phy/u3phy_mode
```

**Note：**其中ff470000为USB PHY的基地址，不同芯片基地址可能不同，调试时需要注意。 

### USB Controller Drivers

#### USB 2.0 HOST Controller Driver

##### 驱动代码路径

```
drivers/usb/host/ehci-*.c
drivers/usb/host/ohci-*.c
```

其中，板级相关的platform文件为：ehci-platform.c和ohci-platform.c。

Rockchip EHCI&OHCI控制器为标准控制器，采用Kernel EHCI&OHCI Generic驱动，具体驱动的框架分析，可以自行查阅相关开源资料。

#### USB 2.0 OTG Controller Driver

##### 驱动代码路径
  ```drivers/usb/dwc_otg_310/```

##### 主要文件功能描述

```c
// USB2.0 OTG 相关DTS解析与配置，主要包括clock、vbus gpio、linestate/bvalid/id中断管理及OTG PHY
// 相关的GRF配置
usbdev_rk322xh.c

// 该文件为controller驱动入口，主要包括controller Register Config、Controller probe、
// Controller Supsend/Resume、Controller Mode Switch等功能
dwc_otg_driver.c

// 该系列文件为Controller Peripheral模式驱动功能
dwc_otg_pcd_*.c

// 该系列文件为Controller Host模式驱动功能
dwc_otg_hcd_*.c

// 实现充电检测功能
usbdev_bc.c
```

##### 内核调试接口

###### 控制器寄存器dump

调试接口位于如下路径：
```/sys/devices/ff580000.usb/```

执行如下命令打印OTG所有寄存器的状态
```cat /sys/devices/ff580000.usb/regdump```

###### 控制器device/host强制切换

USB2.0 OTG控制器的模式一般由USB ID电平决定，也可以由软件进行强制切换。

调试接口为
```echo xxxx > /sys/devices/ff580000.usb/driver/force_usb_mode```

其中xxxx为force\_usb\_mode的值，可配置为如下：

```
0: force to OTG
1: force to Host
2: force to Peripheral
```

除此，PeriPheral模式也可以通过UI界面进行设置，具体是：勾选Android系统设置设备USB连接到PC来设置。

**Note：**其中ff580000为USB2.0 OTG控制器的基地址，不同芯片基地址可能不同，调试时需要注意。

#### USB 3.0 HOST Controller Driver

##### 驱动代码路径

```
drivers/usb/dwc3
driver/usb/host/xhci-*.c
```

##### 主要文件功能描述

```
// rk3328/rk322xh platform驱动
drivers/usb/dwc3/dwc3-rk322xh.c

// DesignWare USB3 DRD Controller Core file，实现dwc3 寄存器的初始化
drivers/usb/dwc3/core.c

// 实现dwc3 peripheral模式的驱动功能
drivers/usb/dwc3/gadget.c

// 实现dwc3 host模式的驱动功能
drivers/usb/dwc3/host.c

// xHCI host controller driver platform Bus Glue
drivers/usb/host/xhci-plat.c
```

##### 内核调试接口

###### DWC3控制器寄存器dump

执行如下命令打印DWC3控制器的所有寄存器状态
```cat /sys/kernel/debug/ff600000.dwc3/regdump```

######  设置控制器进入compliance mode，用于USB 2.0/3.0信号质量测试
```/sys/kernel/debug/usb.24/host_testmode```

使用方法：
1. set test packet for the USB2 port of USB3 interface:
  ```echo test_packet > /sys/kernel/debug/usb.23/host_testmode```

2. set compliance mode for the USB3 port of USB3 interface:
  ```echo test_u3 > /sys/kernel/debug/usb.23/host_testmode```

3. check the testmode status:
  ```cat /sys/kernel/debug/usb.23/host_testmode```

The log maybe like this:
```
U2: test_packet /* means that U2 in test mode */
U3: compliance mode /* means that U3 in test mode */
```

**Note：**其中ff600000为DWC3控制器的基地址，不同芯片基地址可能不同，调试时需要注意。 

------
##  Android Gadget配置

### Gadget驱动配置

请参阅[USB Gadget配置章节](#USB Gadget配置)。

### Android rc脚本配置

在Android boot.img中与USB相关的rc脚本主要有：

```
init.usb.rc
init.rk30board.usb.rc
init.usbstorage.rc
```

其中，

1.  init.usb.rc为Android标准rc文件，一般不需要改动。
2.  init.rk30board.usb.rc为Rockchip平台Gadget功能的配置管理文件，其内容主要包括usb gadget function部分描述符的定义、function节点的使能等，下面是一个典型配置举例：

```
on init
   # write /sys/class/android_usb/android0/iSerial ${ro.serialno}
   # write /sys/class/android_usb/android0/f_rndis/manufacturer RockChip
   # write /sys/class/android_usb/android0/f_rndis/vendorID 2207
   # write /sys/class/android_usb/android0/f_rndis/wceis 1

on boot
    # write /sys/class/android_usb/android0/iSerial ${ro.serialno}
    write /sys/class/android_usb/android0/f_rndis/manufacturer RockChip
    write /sys/class/android_usb/android0/f_rndis/vendorID 2207
    write /sys/class/android_usb/android0/f_rndis/wceis 1
    write /sys/class/android_usb/android0/iManufacturer ${ro.product.manufacturer}
    write /sys/class/android_usb/android0/iProduct ${ro.product.model}
    write /sys/class/android_usb/android0/f_mass_storage/inquiry_string $ro.product.usbfactory

on fs
    mkdir /dev/usb-ffs 0770 shell shell
    mkdir /dev/usb-ffs/adb 0770 shell shell
    mount functionfs adb /dev/usb-ffs/adb uid=2000,gid=2000
    write /sys/class/android_usb/android0/f_ffs/aliases adb

on property:sys.usb.config=adb
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 2207
    write /sys/class/android_usb/android0/idProduct 0006
    write /sys/class/android_usb/android0/functions ${sys.usb.config}
    write /sys/class/android_usb/android0/enable 1
    start adbd
    setprop sys.usb.state ${sys.usb.config}

on property:sys.usb.config=mtp
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 2207
    write /sys/class/android_usb/android0/idProduct 0001
    write /sys/class/android_usb/android0/functions ${sys.usb.config}
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state ${sys.usb.config}

on property:sys.usb.config=mtp,adb
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 2207
    write /sys/class/android_usb/android0/idProduct 0011
    write /sys/class/android_usb/android0/functions ${sys.usb.config}
    write /sys/class/android_usb/android0/enable 1
    start adbd
    setprop sys.usb.state ${sys.usb.config}

on property:sys.usb.config=ptp
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 2207
    write /sys/class/android_usb/android0/idProduct 0002
    write /sys/class/android_usb/android0/functions ${sys.usb.config}
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state ${sys.usb.config}

on property:sys.usb.config=mass_storage
    write /sys/class/android_usb/android0/enable 0
    write /sys/class/android_usb/android0/idVendor 2207
    write /sys/class/android_usb/android0/idProduct 0000
    write /sys/class/android_usb/android0/functions ${sys.usb.config}
    write /sys/class/android_usb/android0/enable 1
    setprop sys.usb.state ${sys.usb.config}
```

其中，on init/on boot节点为Android USB描述符配置；iSerial、iManufacturer、iProduct三个属性由Android配置。如果iSerial没有配置成功，可能会造成ADB无法使用。

on property节点为setprop提供配置，主要用于Gadget composite function的切换。目前Rockchip SDK支持的function主要有如下几种。

```
adb/mtp/adb,mtp/rndis/rndis,adb/ptp/ptp,adb/mass_storage/
mass_storage,adb/accessory/accessory,adb/acm/acm,adb
```

------
## 常见问题分析

### 设备枚举日志

更详细的USB子系统初始化日志可参阅《USB-Initialization-Log-Analysis 》。

#### USB 2.0 OTG正常开机日志

开机未连线，默认为device模式
```
[9.215340]  [0: kworker/0:1: 30] [otg id chg] last id -1 current id 64
[9.215421]  [0: kworker/0:1: 30] PortPower off
[9.215462]  [0: kworker/0:1: 30] rk_battery_charger_detect_cb , battery_charger_detect 6
[9.314944]  [0: kworker/0:1: 30] Using Buffer DMA mode
[9.314977]  [0: kworker/0:1: 30] Periodic Transfer Interrupt Enhancement - disabled
[9.314993]  [0: kworker/0:1: 30] Multiprocessor Interrupt Enhancement - disabled
[9.315012]  [0: kworker/0:1: 30] OTG VER PARAM: 0, OTG VER FLAG: 0
[9.315028]  [0: kworker/0:1: 30] ^^^^^^^^^^^^^^^^^Device Mode
[9.315057]  [0: kworker/0:1: 30] dwc_otg_hcd_resume, usb device mode
[9.415639]  [2: kworker/2:1: 33] dwc_otg_hcd_suspend, usb device mode
```
#### USB 2.0 OTG Device正常枚举日志

连接USB线，mtp,adb 模式
```
[16.245909][0: kworker/0:1: 30] ************vbus detect*************
[16.370776][0: kworker/0:1: 30] Using Buffer DMA mode
[16.370800][0: kworker/0:1: 30] Periodic Transfer Interrupt Enhancement - disabled
[16.370828][0: kworker/0:1: 30] Multiprocessor Interrupt Enhancement - disabled
[16.370847][0: kworker/0:1: 30] OTG VER PARAM: 0, OTG VER FLAG: 0
[16.370863][0: kworker/0:1: 30] ^^^^^^^^^^^^^^^^^Device Mode
[16.370931][0: kworker/0:1: 30] ***********soft connect!!!************
[16.479209][0  swapper/0:    0] USB RESET
[16.574008][0: kworker/0:1: 30] android_work: sent uevent USB_STATE=CONNECTED
[16.576041][0  swapper/0:    0] USB RESET
[16.706051][0: swapper/0:    0] android_usb gadget: high-speed config #1: android
[16.706356][0: kworker/0:1: 30] android_work: sent uevent USB_STATE=CONFIGURED
[16.733446][3:d.process.media: 735] mtp_open
```
####  USB 2.0 OTG Device正常断开日志
```
[22.817708][0: swapper/0: 0] ********session end ,soft disconnect***********
[22.818011][0: kworker/0:1: 30] android_work: sent uevent USB_STATE=DISCONNECTED
[22.818062][0: kworker/0:1: 30] android_work: did not send uevent (0 0           (null))
[22.818319][0: MtpServer:  922] mtp_release
```
#### USB 2.0 OTG HOST设备正常连接日志

LS设备

```
[71.985341][2: khubd: 40] usb 5-1: new low-speed USB device number 2 using usb20_otg
[71.986121][0  khubd: 40] Indeed it is in host mode hprt0 = 00041901
[72.166594][0  khubd: 40] usb 5-1: New USB device found, idVendor=046d, idProduct=c077
[72.166655][0: khubd: 40] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[72.166706][0: khubd: 40] usb 5-1: Product: USB Optical Mouse
[72.166752][0: khubd: 40] usb 5-1: Manufacturer: Logitech
[72.175046][0: khubd: 40] input: Logitech USB Optical Mouse as /devices/ff580000.usb/usb5/5-1/5-1:1.0/input/input2
```

FS设备

```
[40.452561][3: khubd: 40] usb 5-1: new full-speed USB device number 2 using usb20_otg
[40.632926][0: khubd: 40] usb 5-1: New USB device found, idVendor=1915, idProduct=0199
[40.632993][0: khubd: 40] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[40.633042][0: khubd: 40] usb 5-1: Product: Memsart controller
[40.633088][0: khubd: 40] usb 5-1: Manufacturer: Memsart
[40.644143][0: khubd: 40] input: Memsart Memsart controller as /devices/ff580000.usb/usb5/5-1/5-1:1.0/input/input2
```
HS设备

```
[26.943532][2: khubd: 40] usb 5-1: new high-speed USB device number 2 using usb20_otg
[26.943885][0: khubd: 40] Indeed it is in host mode hprt0 = 00001101
[27.055019][0: khubd: 40] Indeed it is in host mode hprt0 = 00001501
[27.383456][0: khubd: 40] usb 5-1: New USB device found, idVendor=0951, idProduct=1687
[27.383520][0: khubd: 40] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[27.383570][0: khubd: 40] usb 5-1: Product: DT R400
[27.383614][0: khubd: 40] usb 5-1: Manufacturer: Kingston
```
#### USB 2.0 HOST设备正常连接日志

LS设备
```
[38.707972]  [3: khubd: 40] usb 4-1: new low-speed USB device number 2 using ohci-platform
[38.895308]  [0: khubd: 40] usb 4-1: New USB device found, idVendor=03f0, idProduct=2c24
[38.895369]  [0: khubd: 40] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[38.895422]  [0: khubd: 40] usb 4-1: Product: HP USB Laser Mouse
[38.895467]  [0: khubd: 40] usb 4-1: Manufacturer: HP
[38.907013]  [0: khubd: 40] input: HP HP USB Laser Mouse as /devices/ff5d0000.usb/usb4/4-1/4-1:1.0/input/input2
[38.909237]  [0: khubd: 40] hid-generic 0003:03F0:2C24.0001: input,hidraw0: USB HID v1.10 Mouse [HP HP USB Laser Mouse] on usb-ff5d0000.usb-1/input0
```
FS设备
```
[1: khubd: 40] usb 4-1: new full-speed USB device number 3 using ohci-platform
[79.655165]  [0: khubd: 40] usb 4-1: New USB device found, idVendor=045e, idProduct=07b2
[79.655225]  [0: khubd: 40] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[79.655276]  [0: khubd: 40] usb 4-1: Product: MicrosoftÂ® Nano Transceiver v1.0
[79.655323]  [0: khubd: 40] usb 4-1: Manufacturer: Microsoft
[79.676566]  [0: khubd: 40] input: Microsoft MicrosoftÂ® Nano Transceiver v1.0 as /devices/ff5d0000.usb/usb4/4-1/4-1:1.0/input/input3
```
HS设备
```
[3: khubd: 40] usb 3-1: new high-speed USB device number 3 using ehci-platform
[ 80.957315]  [0: khubd: 40] usb 3-1: New USB device found, idVendor=0930, idProduct=6544
[ 80.957402]  [0: khubd: 40] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[ 80.957452]  [0: khubd: 40] usb 3-1: Product: TransMemory
[ 80.957496]  [0: khubd: 40] usb 3-1: Manufacturer: TOSHIBA
[ 80.957541]  [0: khubd: 40] usb 3-1: SerialNumber: 322EA08DAD86CF111837E2EC
[ 80.959008]  [0: khubd: 40] usb-storage 3-1:1.0: USB Mass Storage device detected
[ 80.960465]  [0: khubd: 40] scsi0 : usb-storage 3-1:1.0
  ...
[ 81.085812]  [3: kworker/u8:4: 913] sd 0:0:0:0: [sda] Attached SCSI removable disk
```
#### USB 2.0 HOST-LS/FS/HS设备断开日志
```
[  443.151067] usb 4-1: USB disconnect, device number 3
```
#### USB 3.0 HOST-SS设备正常连接日志
```
[22.019722]  [0: khubd:40] usb 2-1: new SuperSpeed USB device number 2 using xhci-hcd
[22.033189]  [0: khubd:40] usb 2-1: Parent hub missing LPM exit latency info.  Power management will be impacted.
[22.034154]  [0: khubd:40] usb 2-1: New USB device found, idVendor=0781, idProduct=5581
[22.034207]  [0: khubd:40] usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[22.034258]  [0:khubd:40] usb 2-1: Product: SanDisk Ultra
[22.034306]  [0:khubd:40] usb 2-1: Manufacturer: SanDisk
[22.034350]  [0:khubd:40] usb 2-1: SerialNumber: A2004BD1F8067C73
[22.039137]  [0:khubd:40] usb-storage 2-1:1.0: USB Mass Storage device detected
[22.039896]  [0:khubd:40] scsi2 : usb-storage 2-1:1.0
[23.027377]  [1:kworker/u8:4:923] scsi 2:0:0:0: Direct-Access     SanDisk  SanDisk Ultra    PMAP PQ: 0 ANSI: 6
```

------
### USB常见问题分析

#### 软件配置

必须明确项目中USB控制器是如何分配的，并确保kernel的配置是正确的，请参考第3、4章的配置说明，根据项目的实际使用情况进行配置。

#### 硬件电路

在同时使用多个控制器对应同一个USB口，或者一个控制器对应多个USB口时，可能会使用电子开关来切换USB信号及电源。需要确保不同控制器的电源控制是互相独立的，通过电子开关后，控制器与USB口之间的连接是有效的。

**Case 1**

一个硬件USB口同时支持HOST和device功能，使用USB2.0 HOST控制器作为HOST和USB2.0 OTG控制器作为device，可通过硬件电子开关进行切换。需要保证工作于HOST状态时，USB信号是切换到USB2.0 HOST控制器，而VBUS是由HOST供电电路提供，而不影响device的VBUS电平检测电路；工作于device状态时，USB信号是切换到USB2.0 OTG控制器，VBUS由PC通过USB线供给。

**Case 2**

使用一个USB2.0 OTG控制器，对应使用两个硬件USB口分别是HOST和Device。通过电子开关进行信号切换。

工作于HOST状态时，USB2.0 OTG的DP/DM信号线是切换到HOST口，且HOST口VBUS提供5V 500MA的供电；工作于device状态时DP/DM信号是切换到device口，VBUS电平检测电路只检测PC提供的5V供电。

#### Device功能异常分析

**USB Device正常连接至PC的现象主要有:**

1. 串口输出正常log见[ USB 2.0 OTG Device正常连接日志](#USB 2.0 OTG Device正常枚举日志)；

2. PC出现盘符，但默认不能访问(windows 7和MAC OS可能只出现在设备管理器)；

3. 设备UI状态栏出现”USB已连接”标识；

4. 打开USB已连接的提示窗口，默认为charger only模式，选择“MTP”或者“PTP”后，PC可以访问盘符。

**常见异常排查：**

**1. 连接USB时串口完全没有log：**

(1) USB硬件信号连接正确；

(2) USB控制器确保工作在device状态；

(3) 测量USB\_DET信号电压，USB连接时应该由低到高。

**2. 连接失败，PC显示不可识别设备，log一直重复打印：**

```
[36.682587] DWC_OTG: ********soft connect!!!*****************************************
[36.688603] DWC_OTG: USB SUSPEND
[36.807373] DWC_OTG: USB RESET
```
但是没有正常log中的后面几条信息，一般为USB硬件信号差，无法完成枚举。

**3. 连接PC后，kernel log正常，并且设备为出现“USB已连接”标识，但PC无法访问设备**

驱动工作正常，请先确认是否有选择USB为“MTP”或“PTP”，如果已选择，则可能是Android层异常，请截取logcat内容，并请负责维护Android的工程师帮忙debug。

**4. 连接PC正常，并能正常访问，拷贝文件过程中提示拷贝失败。**

可能原因是：

(1) USB信号质量差。可测试下USB眼图，并使用USB分析仪抓取数据流后分析。

(2) flash/sd卡读写超时，log一般为连接window xp时约10S出现一次重新连接的log。

(3) flash/sd磁盘分区出错，导致每次拷贝到同一个点时失败。可使用命令检查并修复磁盘分区。假设挂载的磁盘分区为E，则打开windows命令提示符窗口，输入命令：
```chkdsk E: /f```

**5. USB线拔掉后UI状态栏仍然显示“USB已连接” 或 USB线拔掉时只有以下log：**
```[25.330017] DWC_OTG: USB SUSPEND```
而没有下面的log，
```
[25.514407] DWC_OTG: ********session end intr, soft disconnect***********************
```
这种现象一般是VBUS异常，一直为高，影响到USB检测及系统休眠唤醒，请硬件工程师排查问题。

#### Host功能异常分析

USB HOST正常工作情况如下：

1. 首先 HOST电路提供5V，至少500mA的供电；

2. 如果有USB设备连接进来，串口首先会打印HOST枚举USB设备的log，表明USB设备已经通过HOST枚举。

**常见异常及排查**

**1. HOST口接入设备后，串口无任何打印：**

(1) 首先需要确认通过电子开关后的电路连接正确；

(2) 确认控制器工作于HOST状态，并确认供电电路正常。

**2. 串口有 HOST枚举USB设备内容，但是没有出现class驱动的打印信息。**

Kernel没有加载class驱动，需要重新配置kernel，加入对应class驱动支持。

**3. Kernel打印信息完整(USB标准枚举信息及CLASS驱动信息)，已在Linux对应位置生成节点，但是android层无法使用。**

Android层支持不完善，如U盘在kernel挂载完成/dev/block/sda节点后，需要android层vold程序将可存储介质挂载到/udisk提供媒体库，资源管理器等访问，同样鼠标键盘等HID设备也需要android层程序支持。

U盘枚举出现/dev/block/sda后仍然无法使用，一般是fstab.rk30board中U盘的mount路径有问题，fstab.rk30board的代码如下(系统起来后可直接 cat fstab.rk30board查看)：

```
/devices/ff5c0000.usb /mnt/usb_storage/USB_DISK0 vfat defaults voldmanaged=usb_storage:auto
/devices/ff5d0000.usb /mnt/usb_storage/USB_DISK1 vfat defaults voldmanaged=usb_storage:auto
/devices/ff580000.usb /mnt/usb_storage/USB_DISK2 vfat defaults voldmanaged=usb_storage:auto
/devices/usb. /mnt/usb_storage/USB_DISK3 vfat defaults voldmanaged=usb_storage:auto
```

而实际的device路径可能改变，与fstab.rk30board中的配置不一致。如果设备属于这种情况的无法正常使用，需要联系Android工程师帮忙debug。

**4. OTG口作为host时，无法识别接入的设备**

(1) 检查kernel的OTG配置是否正确；

(2) 检查OTG电路的ID电平(作host，为低电平)和VBUS 5V供电是否正常；

(3) 如果确认1和2都正常，仍无法识别设备，请提供设备插入后无法识别的错误log给我们。

#### USB Camera异常分析

**1. 使用Camera应用，无法打开USB camera**

首先，检查/dev目录下是否存在camera设备节点video0或video1，如果不存在，请检查kernel的配置是否正确，如果存在节点，请确认USB camera是在系统开机前插入的，因为RK平台的SDK，默认是不支持USB camera热拔插的。如果要支持USB camera热拔插，请联系负责camera的工程师修改Android相关代码，USB驱动不需要做修改。

如果仍无法解决，请提供log给负责USB驱动工程师或者负责Camera的工程师，进一步分析。

**2. 出现概率性闪屏、无图像以及camera应用异常退出的问题 **

可能是USB驱动丢帧导致的。需要使用USB分析仪抓实际通信的数据进行分析，如果无法定位，请联系负责USB驱动的工程师。

#### USB充电检测

目前，Rockchip USB2 PHY支持BC1.2标准的充电检测，代码实现请参考如下Kernel文件，

```
drivers/usb/dwc_otg_310/usbdev_bc.h
drivers/usb/dwc_otg_310/usbdev_bc.c
```

 可以检测SDP、CDP、标准DCP(D+/D-短接)和非标准DCP(D+/D-未短接)四种充电类型。

-   SDP (Standard Downstream Port)

根据USB2.0规范，当USB外设处于未连接(un-connect)或休眠(suspend)的状态时，一个Standard Downstream Port可向该外设提供不超过2.5mA的平均电流;当外设处于已经连接并且未休眠的状态时，电流可以至最大100mA(USB3.0 150mA);而当外设已经配置(configured )并且未休眠时，最大可从VBUS获得500mA(USB3.0 900mA)电流。

-   CDP (Charging Downstream Port)

即兼容 USB2.0 规范，又针对 USB 充电作出了优化的下行USB 接口，提供最大1.5A的供电电流，满足大电流快速充电的需求。

-   DCP (Dedicated Charging Port)

BC1.2 spec要求将USB Charger中的D+和D-进行短接，以配合USB外设的识别动作，但它不具备和USB设备通信的能力。USB充电检测流程详见[《Battery Charging Specification Revision 1.2》](http://www.usb.org/developers/docs/devclass_docs/)章节3.2.3 Data Contact Detect。

**USB充电检测常见问题**

1. 如果连接USB充电器，发现充电慢，有可能是DCP被误检测为SDP，导致充电电流被设置为500mA。当USB线连接不稳定或者充电检测驱动出错，都可能会产生该问题。解决方法：抓取USB充电器连接的log，通过log的提示判断检测的充电类型，正常应为DCP；


2. 如果连接的是USB充电器，但log提示为SDP，则表示发生了误检测。请先更换USB线测试，并使用万用表确认D+/D-是否短接。如果仍无法解决，请将检测的log发给我们测试。同时，如果有条件，请使用示波器抓USB插入时的D+/D-波形，并连同log一起发送给我们分析和定位问题。
3. 如果连接的是USB充电器，并且log提示为DCP，但充电仍然很慢，则表明软件检测正常，可能是充电IC或者电池的问题。

#### PC驱动问题

所有USB设备要在PC上正常工作都是需要驱动的，有些驱动是标准且通用的，而有些驱动是需要额外安装的。对于Rockchip的设备连接到PC后，需要安装的驱动分为两类：

1.  生成后未烧写的裸片或者进入升级模式后的rockusb设备，会以rockusb模式连接到PC，需要在PC端使用Rockchip平台专门的驱动安装助手DriverAssitant安装后才能识别到USB设备；根据摁不同的按键，会被识别为maskrom或loader设备。

2.  Rockchip设备正常运行时，在设置里面打开USB debugging选项，连接时会以ADB的模式连接PC，需要在PC端安装adb interface usb driver后才能正常识别到ADB Gadget设备。

------
## USB信号测试

USB2.0/3.0信号测试方法及常见问题分析请参阅《Rockchip-USB-SQ-Test-Guide》。

------
## 参考文档

USB 2.0 Specification  
USB 3.1 Specification  
Battery Charging Specification Revision 1.2  
Rockchip-USB-SQ-Test-Guide  
USB-Initialization-Log-Analysis
