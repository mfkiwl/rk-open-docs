# Rockchip USB Initialization Log Analysis

文件标识：RK-KF-YF-099

发布版本：V1.1.1

日期：2020-02-19

文件密级：□绝密   □秘密   □内部资料   ■公开

---
**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2019福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文档主要提供 Rockchip SDK 平台 Kernel 3.10 和 Kernel 4.4 USB 子系统初始化时相关的日志分析。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师
硬件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**                       |
| ---------- | -------- | -------- | ---------------------------------- |
| 2017-12-12 | V1.0     | 王明成   | 初始版本                           |
| 2019-01-09 | V1.1     | 吴良峰   | 使用 markdownlint 修订格式         |
| 2020-02-19 | V1.1.1   | 吴良峰   | 增加免责声明，商标声明以及版权声明 |

**目录**

---
[TOC]
---

## 1 Linux USB 子系统简介

在 Linux 系统中，提供了主机侧和设备侧视角的 USB 驱动框架及通用驱动程序。

- 主机侧分为 USB Core、HOST 控制器驱动，HUB 驱动和各设备类驱动。
- 设备侧分为 Gadget 框架、Devices 控制器驱动和各设备类 Function 驱动。

---
## 2 Rockchip SoC USB 控制器列表

| 芯片\控制器  | EHCI&OHCI | DWC2 | DWC3 |
| ------- | :-------: | :--: | :--: |
| RV1108  |     Y     |  Y   |  N   |
| RK312X  |     Y     |  Y   |  N   |
| RK3288  |     Y     |  Y   |  N   |
| RK322X  |     Y     |  Y   |  N   |
| RK322XH |     Y     |  Y   |  Y   |
| RK3328  |     Y     |  Y   |  Y   |
| RK3366  |     Y     |  Y   |  Y   |
| RK3368  |     Y     |  Y   |  N   |
| RK3399  |     Y     |  N   |  Y   |

---
## 3 Kernel 3.10

### 3.1 适用芯片

本章节介绍 Linux Kernel 3.10 初始化日志，主要适用于 RV1108、RK312X、RK3288、RK322X、RK322XH、RK3328、RK3368 等有运行 Kernel 3.10 SDK 的平台。

### 3.2 主机侧日志

#### 3.2.1 USB CORE

```Log

01 [    0.959817]  usbcore: registered new interface driver usbfs
02 [    0.959890]  usbcore: registered new interface driver hub
03 [    0.960070]  usbcore: registered new device driver usb
...

```

以上是 Linux Kernel 3.10 启动阶段 USB 模块最早输出的 3 句 log。01 行表示注册 USB 文件系统，系统正常启动后，对应生成/sys/bus/usb/目录；02 行表示成功注册 USB HUB 驱动；03 行表明注册 USB 通用设备驱动，即 usb_generic_driver。通常 USB 设备都是以设备的身份先与 usb_generic_driver 匹配，成功之后，会分裂出接口，当对接口调用 device_add()后，会引起接口和接口驱动的匹配。

#### 3.2.2 设备类驱动

```Log

01 [    1.234947]  usbcore: registered new interface driver catc
02 [    1.235015]  usbcore: registered new interface driver kaweth
03 [    1.235109]  usbcore: registered new interface driver pegasus
04 [    1.235180]  usbcore: registered new interface driver rtl8150
05 [    1.235246]  usbcore: registered new interface driver r8152
06 [    1.235379]  usbcore: registered new interface driver hso
07 [    1.235451]  usbcore: registered new interface driver asix
08 [    1.235515]  usbcore: registered new interface driver ax88179_178a
09 [    1.235586]  usbcore: registered new interface driver cdc_ether
10 [    1.235656]  usbcore: registered new interface driver cdc_eem
11 [    1.235727]  usbcore: registered new interface driver dm9601
12 [    1.235793]  usbcore: registered new interface driver dm9620
13 [    1.235867]  usbcore: registered new interface driver smsc75xx
14 [    1.235996]  usbcore: registered new interface driver smsc95xx
15 [    1.236065]  usbcore: registered new interface driver gl620a
16 [    1.236132]  usbcore: registered new interface driver net1080
17 [    1.236197]  usbcore: registered new interface driver plusb
18 [    1.236266]  usbcore: registered new interface driver rndis_host
...

```

上面为主机侧设备类驱动，即各个 USB 设备 HOST 端的驱动程序，可通过 menuconfig 进行配置。

```Kconfig

 Location:
  |     -> Device Drivers
  |        -> USB support
  |        *** USB Device Class drivers ***
  |        < > xxx
  |        < > xxx

```

#### 3.2.3 Host 控制器驱动

##### 3.2.3.1 EHCI

```Log

01 [    1.243691]  ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
02 [    1.243722]  ehci-platform: EHCI generic platform driver
03 [    1.244307]  ehci-platform ff5c0000.usb: EHCI Host Controller
04 [    1.244358]  ehci-platform ff5c0000.usb: new USB bus registered, assigned bus number 3
05 [    1.244875]  ehci-platform ff5c0000.usb: irq 48, io mem 0xff5c0000
06 [    1.252401]  ehci-platform ff5c0000.usb: USB 2.0 started, EHCI 1.00
07 [    1.252526]  usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
08 [    1.252561]  usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
09 [    1.252593]  usb usb3: Product: EHCI Host Controller
10 [    1.252623]  usb usb3: Manufacturer: Linux 3.10.104 ehci_hcd
11 [    1.252654]  usb usb3: SerialNumber: ff5c0000.usb
12 [    1.253238]  hub 3-0:1.0: USB hub found
13 [    1.253284]  hub 3-0:1.0: 1 port detected
...

```

上述为 EHCI 控制器初始化完整打印，从 log 可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器版本等信息。
- EHCI 控制器被枚举为一个 USB2.0 Root HUB (hub 3-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (3)。

##### 3.2.3.2 OHCI

```Log

01 [    1.253939]  ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
02 [    1.253970]  ohci-platform: OHCI generic platform driver
03 [    1.254316]  ohci-platform ff5d0000.usb: Generic Platform OHCI controller
04 [    1.254366]  ohci-platform ff5d0000.usb: new USB bus registered, assigned bus number 4
05 [    1.254456]  ohci-platform ff5d0000.usb: irq 49, io mem 0xff5d0000
06 [    1.308870]  usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
07 [    1.308909]  usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
08 [    1.308942]  usb usb4: Product: Generic Platform OHCI controller
09 [    1.308973]  usb usb4: Manufacturer: Linux 3.10.104 ohci_hcd
10 [    1.309004]  usb usb4: SerialNumber: ff5d0000.usb
11 [    1.309601]  hub 4-0:1.0: USB hub found
12 [    1.309648]  hub 4-0:1.0: 1 port detected
...

```

上述为 OHCI 控制器初始化完整打印，同 EHCI，从 log 也可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器版本等信息。
- OHCI 控制器被枚举为一个 USB1.1 Root HUB (hub 4-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (4)。

##### 3.2.3.3 DWC2 Host

```Log

01 [    1.313609]  usb20_otg ff580000.usb: DWC OTG Controller
02 [    1.313660]  usb20_otg ff580000.usb: new USB bus registered, assigned bus number 5
03 [    1.313719]  usb20_otg ff580000.usb: irq 55, io mem 0x00000000
04 [    1.313833]  usb usb5: New USB device found, idVendor=1d6b, idProduct=0002
05 [    1.313868]  usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
06 [    1.313900]  usb usb5: Product: DWC OTG Controller
07 [    1.313931]  usb usb5: Manufacturer: Linux 3.10.104 dwc_otg_hcd
08 [    1.313962]  usb usb5: SerialNumber: ff580000.usb
09 [    1.314523]  hub 5-0:1.0: USB hub found
10 [    1.314568]  hub 5-0:1.0: 1 port detected
11 [    1.315013]  usb20_host: version 3.10a 21-DEC-2012
...

```

上述为 DWC2 HOST 控制器初始化完整打印，同其它 Host 控制器，从 log 也可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器版本（version 3.10a 21-DEC-2012）等信息。
- DWC2 HOST 控制器被枚举为一个 USB2.0 Root HUB (hub 5-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (5)。

##### 3.2.3.4 DWC3 Host

```Log

01 [    1.240046]  xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
02 [    1.240104]  xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 1
03 [    1.241268]  xhci-hcd xhci-hcd.0.auto: irq 99, io mem 0xff600000
04 [    1.241409]  usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
05 [    1.241443]  usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
06 [    1.241477]  usb usb1: Product: xHCI Host Controller
07 [    1.241508]  usb usb1: Manufacturer: Linux 3.10.104 xhci-hcd
08 [    1.241539]  usb usb1: SerialNumber: xhci-hcd.0.auto
09 [    1.242232]  hub 1-0:1.0: USB hub found
10 [    1.242282]  hub 1-0:1.0: 1 port detected
11 [    1.242570]  xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
12 [    1.242617]  xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 2
13 [    1.242734]  usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
14 [    1.242771]  usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
15 [    1.242803]  usb usb2: Product: xHCI Host Controller
16 [    1.242834]  usb usb2: Manufacturer: Linux 3.10.104 xhci-hcd
17 [    1.242865]  usb usb2: SerialNumber: xhci-hcd.0.auto
18 [    1.243408]  hub 2-0:1.0: USB hub found
19 [    1.243451]  hub 2-0:1.0: 1 port detected
...

```

DWC3 Host 集成 XHCI 控制器，上述为 XHCI 控制器初始化完整打印，从 log 可以获取到如下信息：

- 控制器基本信息，包括中断号、控制器物理地址等信息。

- XHCI 控制器分别被枚举为一个 USB3.0 Root HUB (hub 1-0:1.0)和一个 USB2.0 Root HUB (hub 2-0:1.0)，同时也可以看出两个 HUB 分别被分配到的 BUS Number。

## 3.3 设备侧日志

目前，运行 Kernel 3.10 SDK 的 Rockchip 芯片上仅集成 DWC2 IP，所以 Devices 控制器仅 DWC2 一个，内核使用 dwc_otg_310 驱动，位于 drivers/usb/dwc_otg_310 目录。

### 3.3.1 DWC2 Peripheral

```Log

01 [    1.312160]  usb20_otg: version 3.10a 21-DEC-2012
02 [    1.312963]  Core Release: 3.10a
03 [    1.312992]  Setting default values for core params
04 [    1.313179]  Using Buffer DMA mode
05 [    1.313207]  Periodic Transfer Interrupt Enhancement - disabled
06 [    1.313233]  Multiprocessor Interrupt Enhancement - disabled
07 [    1.313262]  OTG VER PARAM: 0, OTG VER FLAG: 0
08 [    1.313288]  ^^^^^^^^^^^^^^^^^Device Mode
...

```

上面为 Devcies 控制器初始化 log，从 log 也可以得到一些控制器信息。

- 01-02 行：控制器软件版本（version 3.10a 21-DEC-2012），IP 版本：3.10a
- 控制器当前的工作模式和部分参数的配置。

### 3.3.2 DWC2 Peripheral 枚举日志

```Log
01 [    9.208851]  [otg id chg] last id -1 current id 64
02 [    9.208971]  rk_battery_charger_detect_cb , battery_charger_detect 6
03 [    9.308586]  Using Buffer DMA mode
04 [    9.308692]  Periodic Transfer Interrupt Enhancement - disabled
05 [    9.308710]  Multiprocessor Interrupt Enhancement - disabled
06 [    9.308729]  OTG VER PARAM: 0, OTG VER FLAG: 0
07 [    9.308745]  ^^^^^^^^^^^^^^^^^Device Mode
08 [    9.308774]  dwc_otg_hcd_resume, usb device mode
09 [    9.409073]  wc_otg_hcd_suspend, usb device mode
10 [    9.799241]  ***************vbus detect*****************
11 [    9.801964]  rk_battery_charger_detect_cb , battery_charger_detect 1
12 [    9.924721]  Using Buffer DMA mode
13 [    9.924755]  Periodic Transfer Interrupt Enhancement - disabled
14 [    9.924772]  Multiprocessor Interrupt Enhancement - disabled
15 [    9.924790]  OTG VER PARAM: 0, OTG VER FLAG: 0
16 [    9.924807]  ^^^^^^^^^^^^^^^^^Device Mode
17 [    9.924873]  *******************soft connect!!!*******************
18 [   10.038883]  USB RESET
19 [   10.129663]  ndroid_work: sent uevent USB_STATE=CONNECTED
20 [   10.133049]  USB RESET
21 [   10.256977]  android_usb gadget: high-speed config #1: android
22 [   10.257999]  android_work: sent uevent USB_STATE=CONFIGURED
23 [   10.297006]  mtp_open
...
```

上面 log 为 DWC2 peripheral 枚举的完整日志。

- 01 行表示检测到 USB ID 变化，有 USB 线接入；
- 03-07 为控制器重新初始化 log；
- 10 行表示检测到 VBUS；
- 18－22 行为 USB 枚举成功，并通过 UEVENT 事件通知 Android 层 Gadget 连接成功。

---
## 4 Kernel 4.4

### 4.1 适用芯片

本章节介绍 Linux Kernel 4.4 初始化日志，主要适用于 RK312X、RK3288、RK322X、RK322XH、RK3328、RK3366、RK3368，RK3399 等有运行 Kernel 4.4 SDK 的平台。

### 4.2 主机侧日志

#### 4.2.1 USB CORE 及设备类驱动

跟 Linux Kernel 3.10 相同，usbcore 注册 USB 文件系统、注册 USB HUB 驱动，以及注册 USB 通用设备驱动，log 同[Linux Kernel 3.10](#3.2.1 USB CORE) 。

设备类驱动亦同[Kernel 3.10](#3.2.2 设备类驱动)，log 和配置方式也相同。

#### 4.2.2 Host 控制器驱动

##### 4.2.3.1 EHCI

```Log
01 [    0.869076] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
02 [    0.869099] ehci-pci: EHCI PCI platform driver
03 [    0.869191] ehci-platform: EHCI generic platform driver
04 [    0.873032] ehci-platform ff5c0000.usb: EHCI Host Controller
05 [    0.873078] ehci-platform ff5c0000.usb: new USB bus registered, assigned bus number 2
06 [    0.873322] ehci-platform ff5c0000.usb: irq 44, io mem 0xff5c0000
07 [    0.883191] ehci-platform ff5c0000.usb: USB 2.0 started, EHCI 1.00
08 [    0.883418] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
09 [    0.883438] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
10 [    0.883454] usb usb2: Product: EHCI Host Controller
11 [    0.883469] usb usb2: Manufacturer: Linux 4.4.103 ehci_hcd
12 [    0.883484] usb usb2: SerialNumber: ff5c0000.usb
13 [    0.884226] hub 2-0:1.0: USB hub found
14 [    0.884291] hub 2-0:1.0: 1 port detected
...

```

上述为 EHCI 控制器初始化完整打印，从 log 也可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器驱动版本等信息。
- EHCI 控制器被枚举为一个 USB2.0 Root HUB (hub 2-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (2)。

##### 4.2.3.2 OHCI

```Log

01 [    0.884853] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
02 [    0.884897] ohci-platform: OHCI generic platform driver
03 [    0.885315] ohci-platform ff5d0000.usb: Generic Platform OHCI controller
04 [    0.885352] ohci-platform ff5d0000.usb: new USB bus registered, assigned bus number 3
05 [    0.885551] ohci-platform ff5d0000.usb: irq 45, io mem 0xff5d0000
06 [    0.940734] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
07 [    0.940763] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
08 [    0.940783] usb usb3: Product: Generic Platform OHCI controller
09 [    0.940800] usb usb3: Manufacturer: Linux 4.4.103 ohci_hcd
10 [    0.940815] usb usb3: SerialNumber: ff5d0000.usb
11 [    0.941546] hub 3-0:1.0: USB hub found
12 [    0.941597] hub 3-0:1.0: 1 port detected
...

```

上述为 OHCI 控制器初始化完整打印，同 EHCI，从 log 也可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器驱动版本等信息。
- OHCI 控制器被枚举为一个 USB1.1 Root HUB (hub 3-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (3)。

##### 4.2.3.3 DWC2 Host

```Log

01 [    0.579425] ff580000.usb supply vusb_d not found, using dummy regulator
02 [    0.579500] ff580000.usb supply vusb_a not found, using dummy regulator
03 [    0.866540] dwc2 ff580000.usb: EPs: 10, dedicated fifos, 972 entries in SPRAM
04 [    0.867120] dwc2 ff580000.usb: DWC OTG Controller
05 [    0.867163] dwc2 ff580000.usb: new USB bus registered, assigned bus number 1
06 [    0.867211] dwc2 ff580000.usb: irq 43, io mem 0x00000000
07 [    0.867428] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
08 [    0.867449] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
09 [    0.867466] usb usb1: Product: DWC OTG Controller
10 [    0.867480] usb usb1: Manufacturer: Linux 4.4.103 dwc2_hsotg
11 [    0.867495] usb usb1: SerialNumber: ff580000.usb
12 [    0.868254] hub 1-0:1.0: USB hub found
13 [    0.868303] hub 1-0:1.0: 1 port detected
...

```

上述为 DWC2 HOST 控制器初始化完整打印，同其它 Host 控制器，从 log 也可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器部分配置信息。
- DWC2 HOST 控制器被枚举为一个 USB2.0 Root HUB (hub 1-0:1.0)，同时也可以看出该 HUB 被分配的 BUS Number (1)。

##### 4.2.3.4 DWC3 Host

```Log
01 [    0.942624] xhci-hcd xhci-hcd.7.auto: xHCI Host Controller
02 [    0.942662] xhci-hcd xhci-hcd.7.auto: new USB bus registered, assigned bus number 4
03 [    0.943032] xhci-hcd xhci-hcd.7.auto: hcc params 0x0220fe64 hci version 0x110 quirks 0x00210010
04 [    0.943107] xhci-hcd xhci-hcd.7.auto: irq 185, io mem 0xff600000
05 [    0.943357] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
06 [    0.943378] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
07 [    0.943395] usb usb4: Product: xHCI Host Controller
08 [    0.943410] usb usb4: Manufacturer: Linux 4.4.103 xhci-hcd
09 [    0.943425] usb usb4: SerialNumber: xhci-hcd.7.auto
10 [    0.944176] hub 4-0:1.0: USB hub found
11 [    0.944226] hub 4-0:1.0: 1 port detected
12 [    0.944647] xhci-hcd xhci-hcd.7.auto: xHCI Host Controller
13 [    0.944676] xhci-hcd xhci-hcd.7.auto: new USB bus registered, assigned bus number 5
14 [    0.944779] usb usb5: We don't know the algorithms for LPM for this host, disabling LPM.
15 [    0.944943] usb usb5: New USB device found, idVendor=1d6b, idProduct=0003
16 [    0.944963] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
17 [    0.944979] usb usb5: Product: xHCI Host Controller
18 [    0.944994] usb usb5: Manufacturer: Linux 4.4.103 xhci-hcd
19 [    0.945009] usb usb5: SerialNumber: xhci-hcd.7.auto
20 [    0.945718] hub 5-0:1.0: USB hub found
21 [    0.945766] hub 5-0:1.0: 1 port detected
...

```

DWC3 Host 集成 XHCI 控制器，上述为 XHCI 控制器初始化完整打印，从 log 可以获取到如下信息：

- 控制器基本信息，包括中断号、设备虚拟地址、控制器版本等信息。
- XHCI 控制器分别被枚举为一个 USB3.0 Root HUB (hub 4-0:1.0)和一个 USB2.0 Root HUB (hub 5-0:1.0)，同时也可以看出两个 HUB 被分配到的 BUS Number。

## 4.3 设备侧日志

目前，Rockchip SoC 除 RK3399 芯片外，其它芯片都是集成 DWC2 OTG IP，RK3399 集成 DWC3 OTG IP，支持 USB3.0，所以设备侧 log 分 dwc2 和 dwc3 阐述。

Kernel 4.4，DWC2 使用 drivers/usb/dwc2 目录驱动；DWC3 使用 drivers/usb/dwc3 目录驱动。

### 4.3.1 DWC2/DWC3 Peripheral

Kernel 4.4，开机在没有连接 USB 线的情况下，对于 DWC2，如果控制器为 OTG 模式，日志同[DWC2 Host](#4.2.3.3 DWC2 Host)；如果为 Peripheral 模式，则没有特别 log 输出；DWC3 跟 DWC2 类似。

### 4.3.2 DWC2 Peripheral 枚举日志

```Log
01 [   18.566773] read descriptors
02 [   18.566811] read descriptors
03 [   18.566820] read strings
04 [   18.631141] dwc2 ff580000.usb: bound driver configfs-gadget
05 [   18.767106] dwc2 ff580000.usb: new device is high-speed
06 [   18.796143] android_work: sent uevent USB_STATE=CONNECTED
07 [   18.807125] dwc2 ff580000.usb: new device is high-speed
08 [   18.835990] dwc2 ff580000.usb: new address 1
09 [   18.871528] configfs-gadget gadget: high-speed config #1: b
10 [   18.871732] android_work: sent uevent USB_STATE=CONFIGURED
...
```

上面 Log 为 DWC2 Peripheral 枚举的完整日志。

- 01-03 行 Android 层开始配置 Gadget；
- 04-05 为控制器枚举信息；
- 06 行表示枚举成功，Gadget 通过 Uevent 向 Android 发送 Connected 消息；
- 10 行 Gadget 通过 Uevent 向 Android 发送 Configured 消息；表示 Gadget 配置成功。

### 4.3.3 DWC3 Peripheral 枚举日志

```Log
01 [   13.924130] fusb302 4-0022: CC connected in 1 as UFP
02 [   14.061902] phy phy-ff770000.syscon:usb2-phy@e450.5: charger = USB_SDP_CHARGER
03 [   15.633013] fusb302 4-0022: PD disabled
04 [   15.635514] cdn-dp-fb fec00000.dp-fb: lanes count does not change: 0
05 [   15.651643] rockchip-dwc3 usb@fe800000: USB peripheral connected
06 [   19.811878] read descriptors
07 [   19.811923] read strings
08 [   19.938589] android_work: sent uevent USB_STATE=CONNECTED
09 [   19.973662] configfs-gadget gadget: super-speed config #1: b
10 [   19.974071] android_work: sent uevent USB_STATE=CONFIGURED
...
```

上面 log 为 DWC3 Peripheral 枚举的完整日志。

- 01 行 FUSB302 检测到 USB 线有接入；
- 02 行充电检测启动，因为接着 PC，所以为标准充电器；
- 06-07 行 Android 层开始配置 Gadget；
- 08 行表示枚举成功，Gadget 通过 Uevent 向 Android 发送 Connected 消息；
- 09-10 行，USB Config 配置成功，Gadget 通过 Uevent 向 Android 发送 Configured 配置成功消息。
