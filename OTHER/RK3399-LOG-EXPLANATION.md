# **RK3399 LOG EXPLANATION**

发布版本：1.0

作者邮箱：xjq@rock-chips.com

日期：2017.12

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

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2017-12-26 | V1.0   | 许剑群    |          |

---

[TOC]

---


#  RK3399开机LOG说明

```c
 DDR Version 1.00 return(-1)
 DDR Version 1.00 return(-1)
 DDR Version 1.00 return(-1)
 DDR Version 1.00 return(-1)
 DDR Version 1.08 20170320     //DDR Loader 版本日期
 In                            //DDR Loader 开始标志
 Channel 0: LPDDR3, 800MHz
 CS = 0                        //DDR片选信息
 MR0=0x0
 MR1=0x0
 MR2=0x0
 MR3=0x0
 MR4=0x0
 MR5=0x0
 MR6=0x0
 MR7=0x0
 MR8=0x0
 MR9=0x0
 MR10=0x0
 MR11=0x0
 MR12=0x0
 MR13=0x0
 MR14=0x0
 MR15=0x0
 MR16=0x0
 CS = 1                        //DDR片选信息
 MR0=0x0
 MR1=0x0
 MR2=0x0
 MR3=0x0
 MR4=0x0
 MR5=0x0
 MR6=0x0
 MR7=0x0
 MR8=0x0
 MR9=0x0
 MR10=0x0
 MR11=0x0
 MR12=0x0
 MR13=0x0
 MR14=0x0
 MR15=0x0
 MR16=0x0
 Bus Width=32 Col=10 Bank=8 Row=15/15 CS=2 Die Bus-Width=32 Size=2048MB
 Channel 1: LPDDR3, 800MHz      //DDR通道信息
 CS = 0                         //DDR片选信息
 MR0=0x58
 MR1=0x58
 MR2=0x58
 MR3=0x58
 MR4=0x2
 MR5=0x1
 MR6=0x5
 MR7=0x0
 MR8=0x1F
 MR9=0x1F
 MR10=0x1F
 MR11=0x1F
 MR12=0x1F
 MR13=0x1F
 MR14=0x1F
 MR15=0x1F
 MR16=0x1F
 CS = 1                        //DDR片选信息
 MR0=0x58
 MR1=0x58
 MR2=0x58
 MR3=0x58
 MR4=0x2
 MR5=0x1
 MR6=0x5
 MR7=0x0
 MR8=0x1F
 MR9=0x1F
 MR10=0x1F
 MR11=0x1F
 MR12=0x1F
 MR13=0x1F
 MR14=0x1F
 MR15=0x1F
 MR16=0x1F
 Bus Width=32 Col=10 Bank=8 Row=15/15 CS=2 Die Bus-Width=32 Size=2048MB  //总线带宽信息
 256B stride                     //交织信息
 ch 0 ddrconfig = 0x101, ddrsize = 0x2020
 ch 1 ddrconfig = 0x101, ddrsize = 0x2020
 pmugrf_os_reg[2] = 0x3AA0DAA0, stride = 0xD  //PMUGRF信息
 OUT                              //DDR Loader 结束标志"OUT"
 Boot1: 2017-06-09, version: 1.09 //MINILOADER开始
 CPUId = 0x0
 ChipType = 0x10, 1828
 SdmmcInit=2 0
 BootCapSize=100000
 UserCapSize=14910MB
 FwPartOffset=2000 , 100000
 SdmmcInit=0 20
 StorageInit ok = 69117
 LoadTrustBL
 No find bl30.bin
 Load uboot, ReadLba = 2000
 Load OK, addr=0x200000, size=0x72b94 //MINILOADER结束
 RunBL31 0x10000                      //BL31的COMMIT号
 NOTICE:  BL31: v1.3(debug):9f93abc
 NOTICE:  BL31: Built : 10:18:20, Jul 27 2017
 NOTICE:  BL31: Rockchip release version: v1.1
 INFO:    GICv3 with legacy support detected. ARM GICV3 driver initialized in EL3
 INFO:    plat_rockchip_pmu_init(1089): pd status 3e
 INFO:    BL31: Initializing runtime services
 INFO:    BL31: Initializing BL32
 INF [0x0] TEE-CORE:init_primary_helper:337: Initializing (1.1.0-106-g2d5da6a #1 Fri Oct 20 01:35:40 UTC 2017 aarch64)

 INF [0x0] TEE-CORE:init_primary_helper:338: Release version: 1.1

 INF [0x0] TEE-CORE:init_teecore:83: teecore inits done
 INFO:    BL31: Preparing for EL3 exit to normal world
 INFO:    Entry point address = 0x200000  //UBOOT地址
 INFO:    SPSR = 0x3c9                    //BL31结束标志


 U-Boot 2014.10-RK3399-06-02526-g45a462c (Oct 25 2017 - 09:05:48) //UBOOT开始标志

 CPU: rk3399
 cpu version = 0
 CPU's clock information:
 aplll = 816000000HZ
 apllb = 24000000HZ
 gpll = 800000000HZ
 aclk_periph_h = 133333333HZ, hclk_periph_h = 66666666HZ, pclk_periph_h = 33333333HZ
 aclk_periph_l0 = 100000000HZ, hclk_periph_l0 = 100000000HZ, pclk_periph_l0 = 50000000HZ
 hclk_periph_l1 = 100000000HZ, pclk_periph_l1 = 50000000HZ
 cpll = 800000000HZ
 dpll = 800000000HZ
 vpll = 24000000HZ
 npll = 24000000HZ
 ppll = 676000000HZ
 Board:  Rockchip platform Board
 Uboot as second level loader
 DRAM:  Found dram banks: 1
 Adding bank:0000000000200000(00000000ffe00000)
 Reserve memory for trust os.
 dram reserve bank: base = 0x08400000, size = 0x01200000
 128 MiB
 SdmmcInit = 0 20
 storage init OK!
 Using default environment

 GetParam
 Load FDT from resource image.
 power key: bank-0 pin-5
 can't find dts node for fixed
 usb bc: can find node by path: /dwc-control-usb/usb_bc
 dwc_otg_check_dpdm: usb bc disconnected
 pmic:rk808
 can't find dts node for pwm1
 set pwm voltage ok,pwm_id =2 vol=900000,pwm_value=16
 CPU's clock information:
 aplll = 816000000HZ
 apllb = 24000000HZ
 gpll = 800000000HZ
 aclk_periph_h = 133333333HZ, hclk_periph_h = 66666666HZ, pclk_periph_h = 33333333HZ
 aclk_periph_l0 = 100000000HZ, hclk_periph_l0 = 100000000HZ, pclk_periph_l0 = 50000000HZ
 hclk_periph_l1 = 100000000HZ, pclk_periph_l1 = 50000000HZ
 cpll = 800000000HZ
 dpll = 800000000HZ
 vpll = 24000000HZ
 npll = 24000000HZ
 ppll = 676000000HZ
 Can't find dts node for fuel guage cw201x
 can't find dts node for ec-battery
 Can't find dts node for charger bq25700
 SecureBootEn = 0, SecureBootLock = 0

 #Boot ver: 2017-10-25#1.09
 empty serial no.
 normal boot.
 checkKey
 vbus = 0
 no fuel gauge found
 no fuel gauge found
 read logo on state from dts [1]
 no fuel gauge found
 Using display timing dts
 Detailed mode clock 160000 kHz, flags[a]
 H: 1200 1320 1340 1361
 V: 1920 1941 1944 1962
 bus_format: 100e
 rk lcdc - 0 dclk set: dclk = 160000000HZ, pll select = 1, div = 1
 final DSI-Link bandwidth: 1064 Mbps x 4
 failed to wait for phy lock state
 Hit any key to stop autoboot:  0
 load fdt from resouce.
 Secure Boot state: 0
 kernel   @ 0x00280000 (0x01238008)
 ramdisk  @ 0x05bf0000 (0x001e65b8)
 bootrk: do_bootm_linux...
 Loading Device Tree to 0000000005600000, end 00000000056160c3 ... OK
 Add bank:0000000000200000, 0000000008200000
 Add bank:0000000009600000, 00000000eea00000
 WARNING: could not set reg FDT_ERR_BADOFFSET.

 Starting kernel ...               //UBOOT结束标志

 [    0.000000] Booting Linux on physical CPU 0x0    //内核启动
 [    0.000000] Initializing cgroup subsys cpuset
 [    0.000000] Initializing cgroup subsys cpu
 [    0.000000] Initializing cgroup subsys cpuacct
 [    0.000000] Initializing cgroup subsys schedtune
 [    0.000000] Linux version 4.4.103 (wmc@ubuntu) (gcc version 4.9 20140514 (prerelease) (GCC) ) #1185 SMP PREEMPT Tue Dec 12 14:38:48 CST 2017 //内核固件编译者和时间信息
 [    0.000000] Boot CPU: AArch64 Processor [410fd034]
 [    0.000000] earlycon: Early serial console at MMIO32 0xff1a0000 (options '')
 [    0.000000] bootconsole [uart0] enabled
 [    0.000000] Reserved memory: failed to reserve memory for node 'stb-devinfo@00000000': base 0x0000000000000000, size 0 MiB
 [    0.000000] cma: Reserved 16 MiB at 0x00000000f7000000
 [    0.000000] psci: probing for conduit method from DT.
 [    0.000000] psci: PSCIv1.0 detected in firmware.
 [    0.000000] psci: Using standard PSCI v0.2 function IDs
 [    0.000000] psci: Trusted OS migration not required
 [    0.000000] PERCPU: Embedded 21 pages/cpu @ffffffc0f6ef0000 s45504 r8192 d32320 u86016
 [    0.000000] Detected VIPT I-cache on CPU0
 [    0.000000] CPU features: enabling workaround for ARM erratum 845719
 [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 994824
 [    0.000000] Kernel command line: earlycon=uart8250,mmio32,0xff1a0000 swiotlb=1 androidboot.baseband=N/A androidboot.selinux=permissive androidboot.hardware=rk30board0
 [    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
 [    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
 [    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
 [    0.000000] software IO TLB [mem 0xf6ea7000-0xf6ee7000] (0MB) mapped at [ffffffc0f6ea7000-ffffffc0f6ee6fff]
 [    0.000000] Memory: 3930820K/4042752K available (10878K kernel code, 1632K rwdata, 5268K rodata, 832K init, 1069K bss, 95548K reserved, 16384K cma-reserved)
 [    0.000000] Virtual kernel memory layout:
 [    0.000000]     modules : 0xffffff8000000000 - 0xffffff8008000000   (   128 MB)
 [    0.000000]     vmalloc : 0xffffff8008000000 - 0xffffffbdbfff0000   (   246 GB)
 [    0.000000]       .init : 0xffffff8009050000 - 0xffffff8009120000   (   832 KB)
 [    0.000000]       .text : 0xffffff8008080000 - 0xffffff8008b20000   ( 10880 KB)
 [    0.000000]     .rodata : 0xffffff8008b20000 - 0xffffff8009050000   (  5312 KB)
 [    0.000000]       .data : 0xffffff8009120000 - 0xffffff80092b8008   (  1633 KB)
 [    0.000000]     vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000   (     8 GB maximum)
 [    0.000000]               0xffffffbdc0008000 - 0xffffffbdc3e00000   (    61 MB actual)
 [    0.000000]     fixed   : 0xffffffbffe7fd000 - 0xffffffbffec00000   (  4108 KB)
 [    0.000000]     PCI I/O : 0xffffffbffee00000 - 0xffffffbfffe00000   (    16 MB)
 [    0.000000]     memory  : 0xffffffc000200000 - 0xffffffc0f8000000   (  3966 MB)
 [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=6, Nodes=1
 [    0.000000] Preemptible hierarchical RCU implementation.
 [    0.000000]  Build-time adjustment of leaf fanout to 64.
 [    0.000000]  RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=6.
 [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=6
 [    0.000000] NR_IRQS:64 nr_irqs:64 0  //GIC初始化
 [    0.000000] GIC: Using split EOI/Deactivate mode
 [    0.000000] ITS: /interrupt-controller@fee00000/interrupt-controller@fee20000
 [    0.000000] ITS: allocated 65536 Devices @9600000 (psz 64K, shr 0)
 [    0.000000] ITS: using cache flushing for cmd queue
 [    0.000000] GIC: using LPI property table @0x0000000009680000
 [    0.000000] ITS: Allocated 1792 chunks for LPIs
 [    0.000000] CPU0: found redistributor 0 region 0:0x00000000fef00000
 [    0.000000] CPU0: using LPI pending table @0x0000000009690000
 [    0.000000] GIC: using cache flushing for LPI property table
 [    0.000000] GIC: PPI partition interrupt-partition-0[0] { /cpus/cpu@0[0] /cpus/cpu@1[1] /cpus/cpu@2[2] /cpus/cpu@3[3] }
 [    0.000000] GIC: PPI partition interrupt-partition-1[1] { /cpus/cpu@100[4] /cpus/cpu@101[5] }
 [    0.000000] rockchip_clk_register_frac_branch: could not find dclk_vop0_frac as parent of dclk_vop0, rate changes may not work 		//CLK初始化
 [    0.000000] rockchip_clk_register_frac_branch: could not find dclk_vop1_frac as parent of dclk_vop1, rate changes may not work
 [    0.000000] rockchip_cpuclk_pre_rate_change: limiting alt-divider 33 to 31
 [    0.000000] Architected cp15 timer(s) running at 24.00MHz (phys). 		//CPU TIMER初始化
 [    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x588fe9dc0, max_idle_ns: 440795202592 ns
 [    0.000006] sched_clock: 56 bits at 24MHz, resolution 41ns, wraps every 4398046511097ns 	//EAS初始化
 [    0.001921] Calibrating delay loop (skipped), value calculated using timer frequency.. 48.00 BogoMIPS (lpj=80000)
 [    0.002907] pid_max: default: 32768 minimum: 301
 [    0.003438] Security Framework initialized
 [    0.003838] SELinux:  Initializing.
 [    0.004261] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
 [    0.004906] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
 [    0.006432] Initializing cgroup subsys freezer
 [    0.006871] Initializing cgroup subsys debug
 [    0.008196] sched-energy: Sched-energy-costs installed from DT
 [    0.008759] CPU0: update cpu_capacity 401
 [    0.009218] ASID allocator initialised with 65536 entries
 [    0.026042] PCI/MSI: /interrupt-controller@fee00000/interrupt-controller@fee20000 domain created
 [    0.027297] Platform MSI: /interrupt-controller@fee00000/interrupt-controller@fee20000 domain created
 [    0.039452] Detected VIPT I-cache on CPU1
 [    0.039484] CPU1: found redistributor 1 region 0:0x00000000fef20000
 [    0.039524] CPU1: using LPI pending table @0x00000000f1c00000
 [    0.039566] CPU1: update cpu_capacity 401
 [    0.039569] CPU1: Booted secondary processor [410fd034]
 [    0.049447] Detected VIPT I-cache on CPU2
 [    0.049467] CPU2: found redistributor 2 region 0:0x00000000fef40000
 [    0.049499] CPU2: using LPI pending table @0x00000000f1c30000
 [    0.049527] CPU2: update cpu_capacity 401
 [    0.049530] CPU2: Booted secondary processor [410fd034]
 [    0.059486] Detected VIPT I-cache on CPU3
 [    0.059505] CPU3: found redistributor 3 region 0:0x00000000fef60000
 [    0.059537] CPU3: using LPI pending table @0x00000000f1c70000
 [    0.059563] CPU3: update cpu_capacity 401
 [    0.059566] CPU3: Booted secondary processor [410fd034]
 [    0.069534] Detected PIPT I-cache on CPU4
 [    0.069562] CPU4: found redistributor 100 region 0:0x00000000fef80000
 [    0.069601] CPU4: using LPI pending table @0x00000000f1cb0000
 [    0.069643] CPU4: update cpu_capacity 1024
 [    0.069646] CPU4: Booted secondary processor [410fd082]
 [    0.079556] Detected PIPT I-cache on CPU5
 [    0.079574] CPU5: found redistributor 101 region 0:0x00000000fefa0000
 [    0.079610] CPU5: using LPI pending table @0x00000000f1cf0000
 [    0.079637] CPU5: update cpu_capacity 1024
 [    0.079639] CPU5: Booted secondary processor [410fd082]
 [    0.079726] Brought up 6 CPUs           //多核启动结束，已成功启动6核
 [    0.092124] SMP: Total of 6 processors activated.
 [    0.092578] CPU features: detected feature: GIC system register CPU interface
 [    0.093264] CPU: All CPU(s) started at EL2
 [    0.093695] alternatives: patching kernel code
 [    0.095819] devtmpfs: initialized
 [    0.115570] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
 [    0.116548] futex hash table entries: 2048 (order: 5, 131072 bytes)
 [    0.117868] pinctrl core: initialized pinctrl subsystem
 [    0.119931] Failed to find legacy iommu devices
 [    0.120748] NET: Registered protocol family 16
 [    0.121502] schedtune: init normalization constants...
 [    0.122008] schedtune: CLUSTER[0-3]      min_pwr:    56 max_pwr:   222
 [    0.122643] schedtune: CPU[0]            min_pwr:     0 max_pwr:   222
 [    0.123289] schedtune: CPU[1]            min_pwr:     0 max_pwr:   222
 [    0.123925] schedtune: CPU[2]            min_pwr:     0 max_pwr:   222
 [    0.124560] schedtune: CPU[3]            min_pwr:     0 max_pwr:   222
 [    0.125196] schedtune: CLUSTER[4-5]      min_pwr:    65 max_pwr:  1108
 [    0.125830] schedtune: CPU[4]            min_pwr:     0 max_pwr:  1108
 [    0.126465] schedtune: CPU[5]            min_pwr:     0 max_pwr:  1108
 [    0.127129] schedtune: SYSTEM            min_pwr:   121 max_pwr:  4434
 [    0.127765] schedtune: using normalization constants mul: 3862781856 sh1: 1 sh2: 12
 [    0.128507] schedtune: verify normalization constants...
 [    0.129023] schedtune: max_pwr/2^0: 4313 => norm_pwr:  1024
 [    0.129565] schedtune: max_pwr/2^1: 2156 => norm_pwr:   511
 [    0.130107] schedtune: max_pwr/2^2: 1078 => norm_pwr:   255
 [    0.130656] schedtune: max_pwr/2^3:  539 => norm_pwr:   127
 [    0.131198] schedtune: max_pwr/2^4:  269 => norm_pwr:    63
 [    0.131740] schedtune: max_pwr/2^5:  134 => norm_pwr:    31
 [    0.132282] schedtune: configured to support 5 boost groups
 [    0.140691] cpuidle: using governor ladder 		//CPUIDLE初始化
 [    0.150696] cpuidle: using governor menu
 [    0.151091] Registered FIQ tty driver 			//FIQ注册
 [    0.151731] vdso: 2 pages (1 code @ ffffff8008b26000, 1 data @ ffffff8009124000)
 [    0.152470] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
 [    0.153858] DMA: preallocated 256 KiB pool for atomic allocations
 [    0.175168] console [pstore0] enabled 			//PSTORE用于存储LASTLOG
 [    0.175768] pstore: Registered ramoops as persistent store backend
 [    0.176374] ramoops: attached 0xf0000@0x110000, ecc: 0/0
 [    0.177559] sip_fiq_debugger_uart_irq_tf_init error: -2
 [    0.178089] fiq debugger bind fiq to trustzone failed: -2
 <hit enter to activate fiq debugger>     			//FIQ CONSOLE
 [    0.178937] console [ttyFIQ0] enabled
 [    0.178937] console [ttyFIQ0] enabled
 [[     0.179799] bootconsole [uart0] disabled
 0.179799] bootconsole [uart0] disabled
 [    0.180707] Registered fiq debugger ttyFIQ0
 [    0.209178] Rockchip hdmi driver version 2.0
 .
 [    0.210895] iommu: Adding device ff650000.vpu_service to group 0
 [    0.210978] iommu: Adding device ff660000.rkvdec to group 1
 [    0.211045] iommu: Adding device ff670000.iep to group 2
 [    0.211142] iommu: Adding device ff8f0000.vop to group 3
 [    0.211219] iommu: Adding device ff900000.vop to group 4
 [    0.211935] rk_iommu ff670800.iommu: can't get aclk
 [    0.211955] rk_iommu ff670800.iommu: can't get hclk
 [    0.212531] SCSI subsystem initialized
 [    0.212706] usbcore: registered new interface driver usbfs
 [    0.212754] usbcore: registered new interface driver hub
 [    0.212826] usbcore: registered new device driver usb
 [    0.213164] media: Linux media interface: v0.10
 [    0.213209] Linux video capture interface: v2.00
 [    0.213367] pps_core: LinuxPPS API ver. 1 registered
 [    0.213378] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
 [    0.213404] PTP clock support registered
 [    0.214836] Advanced Linux Sound Architecture Driver Initialized.
 [    0.215365] Bluetooth: Core ver 2.21
 [    0.215400] NET: Registered protocol family 31
 [    0.215412] Bluetooth: HCI device and connection manager initialized
 [    0.215430] Bluetooth: HCI socket layer initialized
 [    0.215445] Bluetooth: L2CAP socket layer initialized
 [    0.215489] Bluetooth: SCO socket layer initialized
 [    0.216592] rockchip-cpuinfo cpuinfo: Serial         : 0000000000000000
 [    0.217016] clocksource: Switched to clocksource arch_sys_counter
 [    0.259836] thermal thermal_zone1: power_allocator: sustainable_power will be estimated
 [    0.260090] NET: Registered protocol family 2
 [    0.260552] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
 [    0.260734] TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
 [    0.260971] TCP: Hash tables configured (established 32768 bind 32768)
 [    0.261054] UDP hash table entries: 2048 (order: 4, 65536 bytes)
 [    0.261102] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
 [    0.261280] NET: Registered protocol family 1
 [    0.261782] Trying to unpack rootfs image as initramfs...
 [    0.359789] Freeing initrd memory: 1944K
 [    0.360263] hw perfevents: enabled with armv8_cortex_a53 PMU driver, 7 counters available
 [    0.360437] hw perfevents: enabled with armv8_cortex_a72 PMU driver, 7 counters available
 [    0.363044] audit: initializing netlink subsys (disabled)
 [    0.363110] audit: type=2000 audit(0.356:1): initialized
 [    0.368384] VFS: Disk quotas dquot_6.6.0
 [    0.368523] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
 [    0.369928] fuse init (API version 7.23)
 [    0.371118]
 [    0.371118] TEE Core Framework initialization (ver 1:0.1)
 [    0.371155] TEE armv7 Driver initialization
 [    0.371483] tz_tee_probe: name="armv7sec", id=0, pdev_name="armv7sec.0"
 [    0.371498] TEE core: Alloc the misc device "opteearmtz00" (id=0)
 [    0.371700] TEE Core: Register the misc device "opteearmtz00" (id=0,minor=62)
 [    0.375815] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 246)
 [    0.375842] io scheduler noop registered
 [    0.376010] io scheduler cfq registered (default)
 [    0.379828] backlight supply power not found, using dummy regulator
 [    0.380478] iep: failed to find iep power down clock source.
 [    0.380842] IEP Power ON
 [    0.381000] IEP Power OFF
 [    0.381079] IEP Driver loaded succesfully
 [    0.381183] Module initialized.
 [    0.381587] rk-vcodec ff650000.vpu_service: probe device 		//RKVDEC初始化
 [    0.381634] rk-vcodec ff650000.vpu_service: vpu mmu dec ffffffc0f1f01810
 [    0.381768] rk-vcodec ff650000.vpu_service: allocator is drm
 [    0.381820] rk-vcodec ff650000.vpu_service: checking hw id 0
 [    0.382263] rk-vcodec ff650000.vpu_service: init success
 [    0.382816] rk-vcodec ff660000.rkvdec: probe device
 [    0.382855] rk-vcodec ff660000.rkvdec: vpu mmu dec ffffffc0f1f02010
 [    0.382986] rk-vcodec ff660000.rkvdec: allocator is drm
 [    0.383041] rk-vcodec ff660000.rkvdec: checking hw id 6876
 [    0.383360] rk-vcodec ff660000.rkvdec: init success
 [    0.384733] dma-pl330 ff6d0000.dma-controller: Loaded driver for PL330 DMAC-241330 						//DMA PL330初始化
 [    0.384752] dma-pl330 ff6d0000.dma-controller:       DBUFF-32x8bytes Num_Chans-6 Num_Peri-12 Num_Events-12
 [    0.386095] dma-pl330 ff6e0000.dma-controller: Loaded driver for PL330 DMAC-241330
 [    0.386113] dma-pl330 ff6e0000.dma-controller:       DBUFF-128x8bytes Num_Chans-8 Num_Peri��  ˙Z��_Events-16  //console切换 可能显示乱码。
 [    0.387768] Serial: 8250/16550 driver, 5 ports, IRQ sharing disabled
 [    0.389354] console [ttyS0] disabled
 [    0.389403] ff180000.serial: ttyS0 at MMIO 0xff180000 (irq = 36, base_baud = 1500000) is a 16550A
 [    0.389971] ff1a0000.serial: ttyS2 at MMIO 0xff1a0000 (irq = 37, base_baud = 1500000) is a 16550A
 [    0.390400] [drm:drm_core_init] Initialized drm 1.1.0 20060810
 [    0.394776] ff960000.dsi.0 supply power not found, using dummy regulator
 [    0.395401] mali ff9a0000.gpu: Failed to get regulator 			//GPU初始化
 [    0.395423] mali ff9a0000.gpu: Power control initialization failed
 [    0.395709] Unable to detect cache hierarchy from DT for CPU 0
 [    0.403629] brd: module loaded
 [    0.408410] loop: module loaded
 [    0.408957] zram: Added device: zram0
 [    0.409523] SCSI Media Changer driver v0.25
 [    0.410130] tun: Universal TUN/TAP device driver, 1.6
 [    0.410148] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
 [    0.411221] rk_gmac-dwmac fe300000.ethernet: clock input or output? (input).  //GMAC初始化
 [    0.411251] rk_gmac-dwmac fe300000.ethernet: TX delay(0x28).
 [    0.411266] rk_gmac-dwmac fe300000.ethernet: RX delay(0x11).
 [    0.411294] rk_gmac-dwmac fe300000.ethernet: integrated PHY? (no).
 [    0.411461] rk_gmac-dwmac fe300000.ethernet: clock input from PHY
 [    0.416480] rk_gmac-dwmac fe300000.ethernet: init for RGMII
 [    0.416607] stmmac - user ID: 0x10, Synopsys ID: 0x35
 [    0.416617]  Ring mode enabled
 [    0.416627]  DMA HW capability register supported
 [    0.416635]  Normal descriptors
 [    0.416647]  RX Checksum Offload Engine supported (type 2)
 [    0.416656]  TX Checksum insertion supported
 [    0.416664]  Wake-Up On Lan supported
 [    0.416705]  Enable RX Mitigation via HW Watchdog Timer
 [    0.483193] libphy: stmmac: probed
 [    0.483230] eth%d: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
 [    0.483244] eth%d: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
 [    0.484036] PPP generic driver version 2.4.2
 [    0.484236] PPP BSD Compression module registered
 [    0.484252] PPP Deflate Compression module registered
 [    0.484283] PPP MPPE Compression module registered
 [    0.484307] NET: Registered protocol family 24
 [    0.484349] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256) (6 bit encapsulation enabled).
 [    0.484361] CSLIP: code copyright 1989 Regents of the University of California.
 [    0.484386] Rockchip WiFi SYS interface (V1.00) ...
 [    0.484471] usbcore: registered new interface driver catc
 [    0.484515] usbcore: registered new interface driver kaweth
 [    0.484532] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ethernet driver
 [    0.484573] usbcore: registered new interface driver pegasus
 [    0.484620] usbcore: registered new interface driver rtl8150
 [    0.484663] usbcore: registered new interface driver r8152
 [    0.484678] hso: drivers/net/usb/hso.c: Option Wireless
 [    0.484739] usbcore: registered new interface driver hso
 [    0.484791] usbcore: registered new interface driver asix
 [    0.484835] usbcore: registered new interface driver ax88179_178a
 [    0.484878] usbcore: registered new interface driver cdc_ether
 [    0.484920] usbcore: registered new interface driver cdc_eem
 [    0.484963] usbcore: registered new interface driver dm9601
 [    0.485014] usbcore: registered new interface driver smsc75xx
 [    0.485068] usbcore: registered new interface driver smsc95xx
 [    0.485110] usbcore: registered new interface driver gl620a
 [    0.485154] usbcore: registered new interface driver net1080
 [    0.485197] usbcore: registered new interface driver plusb
 [    0.485240] usbcore: registered new interface driver rndis_host
 [    0.485286] usbcore: registered new interface driver cdc_subset
 [    0.485329] usbcore: registered new interface driver zaurus
 [    0.485373] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
 [    0.485432] usbcore: registered new interface driver int51x1
 [    0.485475] usbcore: registered new interface driver kalmia
 [    0.485521] usbcore: registered new interface driver ipheth
 [    0.485569] usbcore: registered new interface driver sierra_net
 [    0.485613] usbcore: registered new interface driver cx82310_eth
 [    0.485666] usbcore: registered new interface driver cdc_ncm
 [    0.485709] usbcore: registered new interface driver qmi_wwan
 [    0.485756] usbcore: registered new interface driver cdc_mbim
 [    0.486891] rockchip-dwc3 usb@fe800000: failed to get drvdata dwc3
 [    0.487734] rockchip-dwc3 usb@fe900000: failed to get drvdata dwc3
 [    0.488412] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
 [    0.488430] ehci-pci: EHCI PCI platform driver
 [    0.488486] ehci-platform: EHCI generic platform driver
 [    0.489042] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
 [    0.489078] ohci-platform: OHCI generic platform driver
 [    0.489898] usbcore: registered new interface driver cdc_acm
 [    0.489910] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
 [    0.489968] usbcore: registered new interface driver usblp
 [    0.490016] usbcore: registered new interface driver cdc_wdm
 [    0.490067] usbcore: registered new interface driver uas
 [    0.490122] usbcore: registered new interface driver usb-storage
 [    0.490163] usbcore: registered new interface driver ums-alauda
 [    0.490204] usbcore: registered new interface driver ums-cypress
 [    0.490246] usbcore: registered new interface driver ums-datafab
 [    0.490287] usbcore: registered new interface driver ums_eneub6250
 [    0.490328] usbcore: registered new interface driver ums-freecom
 [    0.490395] usbcore: registered new interface driver ums-isd200
 [    0.490439] usbcore: registered new interface driver ums-jumpshot
 [    0.490480] usbcore: registered new interface driver ums-karma
 [    0.490521] usbcore: registered new interface driver ums-onetouch
 [    0.490562] usbcore: registered new interface driver ums-sddr09
 [    0.490603] usbcore: registered new interface driver ums-sddr55
 [    0.490645] usbcore: registered new interface driver ums-usbat
 [    0.490735] usbcore: registered new interface driver usbserial
 [    0.490773] usbcore: registered new interface driver usbserial_generic
 [    0.490804] usbserial: USB Serial support registered for generic
 [    0.490846] usbcore: registered new interface driver option
 [    0.490875] usbserial: USB Serial support registered for GSM modem (1-port)
 [    0.490924] usbcore: registered new interface driver trancevibrator
 [    0.490942] usb20_otg: version 3.10a 21-DEC-2012
 [    0.491104] usb20_host: version 3.10a 21-DEC-2012
 [    0.491571] usbcore: registered new interface driver xpad
 [    0.491622] usbcore: registered new interface driver usb_acecad
 [    0.491669] usbcore: registered new interface driver aiptek
 [    0.491719] usbcore: registered new interface driver gtco
 [    0.491766] usbcore: registered new interface driver hanwang
 [    0.491811] usbcore: registered new interface driver kbtab
 [    0.492208] sensor_register_slave:mma8452,id=17
 [    0.492227] sensor_register_slave:lis3dh,id=7
 [    0.492243] sensor_register_slave:mma7660,id=18
 [    0.492260] sensor_register_slave:lsm303d,id=22
 [    0.492275] sensor_register_slave:gs_mc3230,id=23
 [    0.492285] [Gsensor]   gsensor_init
 [    0.492301] sensor_register_slave:mpu6880_acc,id=24
 [    0.492317] sensor_register_slave:mpu6500_acc,id=25
 [    0.492334] sensor_register_slave:lsm330_acc,id=26
 [    0.492350] sensor_register_slave:bma2xx_acc,id=27
 [    0.492367] sensor_register_slave:akm8975,id=29
 [    0.492383] sensor_register_slave:akm8963,id=30
 [    0.492399] sensor_register_slave:l3g4200d,id=44
 [    0.492416] sensor_register_slave:l3g20d,id=45
 [    0.492432] sensor_register_slave:ewtsa,id=46
 [    0.492449] sensor_register_slave:lsm330_gyro,id=50
 [    0.492466] sensor_register_slave:cm3217,id=52
 [    0.492482] sensor_register_slave:cm3218,id=53
 [    0.492498] sensor_register_slave:ls_stk3410,id=61
 [    0.492515] sensor_register_slave:ps_stk3410,id=66
 [    0.493197] i2c /dev entries driver
 [    0.518694] fusb302 0-0022: port 0 probe success
 [    0.520308] fan53555-regulator 0-0040: FAN53555 Option[8] Rev[1] Detected! 					//SYR827初始化
 [    0.520446] fan53555-reg: supplied by vcc5v0_sys
 [    0.524987] fan53555-regulator 0-0041: FAN53555 Option[8] Rev[1] Detected!
 [    0.525055] fan53555-reg: supplied by vcc5v0_sys
 [    0.529535] rk808 0-001b: Pmic Chip id: 0x0  //RK808 PMIC初始化
 [    0.538833] rk808-regulator rk808-regulator: there is no dvs0 gpio
 [    0.538919] rk808-regulator rk808-regulator: there is no dvs1 gpio
 [    0.539037] DCDC_REG1: supplied by vcc3v3_sys
 [    0.540706] DCDC_REG2: supplied by vcc3v3_sys
 [    0.541840] DCDC_REG3: supplied by vcc3v3_sys
 [    0.542134] DCDC_REG4: supplied by vcc3v3_sys
 [    0.542912] LDO_REG1: supplied by vcc3v3_sys
 [    0.544707] LDO_REG2: supplied by vcc3v3_sys
 [    0.546055] LDO_REG3: supplied by vcc3v3_sys
 [    0.547384] LDO_REG4: supplied by vcc3v3_sys
 [    0.548712] LDO_REG5: supplied by vcc3v3_sys
 [    0.550060] LDO_REG6: supplied by vcc3v3_sys
 [    0.551392] LDO_REG7: supplied by vcc3v3_sys
 [    0.552717] LDO_REG8: supplied by vcc3v3_sys
 [    0.554044] SWITCH_REG1: supplied by vcc3v3_sys
 [    0.554374] SWITCH_REG2: supplied by vcc3v3_sys
 [    0.564394] rk808-rtc rk808-rtc: rtc core: registered rk808-rtc as rtc0
 [    0.565609] rk3x-i2c ff3c0000.i2c: Initialized RK3xxx I2C bus at ffffff800952e000 				//FF3C0000是I2C0
 [    0.566445] rk3x-i2c ff110000.i2c: Initialized RK3xxx I2C bus at ffffff800953a000 				//FF110000是I2C1
 [    1.567057] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF120000是I2C2
 [    2.567080] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF3D0000是I2C4
 [    3.567046] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF130000是I2C3
 [    4.567044] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF140000是I2C5
 [    5.567048] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF150000是I2C6
 [    6.567049] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //FF160000是I2C7
 [    7.567043] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [    8.567043] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1 //RK3399 EVB3 I2C6上有FUSB0
 [    9.567044] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   10.567044] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   11.567041] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   12.567042] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   13.567045] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   14.567041] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   15.567039] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   16.567043] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   17.567041] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   18.567040] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   19.567043] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   20.567039] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   21.567040] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   22.567045] rk3x-i2c ff150000.i2c: timeout, ipd: 0x00, state: 1
 [   22.567368] fusb302 6-0022: port 1 probe success
 [   22.567403] rk3x-i2c ff150000.i2c: Initialized RK3xxx I2C bus at ffffff800953c000
 [   22.568238] goodix_ts_probe() start   		//GOODIX是触摸屏,由于机器没有插屏 故触摸屏初始化I2C通讯失败
 [   22.697884] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset. 		
 [   22.781209] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset. 		
 [   22.864541] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset.
 [   22.947873] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset.
 [   23.031209] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset.
 [   23.114539] <<-GTP-ERROR->> I2C Read: 0x8000, 10 bytes failed, errcode: -6! Process reset.
 [   23.197047] <<-GTP-ERROR->> I2C read 0x8000, 10 bytes, double check failed!
 [   23.197068] <<-GTP-ERROR->> Failed to get chip-type, set chip type default: GOODIX_GT9
 [   23.197842] <<-GTP-ERROR->> I2C Read: 0x8047, 1 bytes failed, errcode: -6! Process reset.
 [   23.280380] <<-GTP-ERROR->> GTP i2c test failed time 1.
 [   23.294533] <<-GTP-ERROR->> I2C Read: 0x8047, 1 bytes failed, errcode: -6! Process reset.
 [   23.377047] <<-GTP-ERROR->> GTP i2c test failed time 2.
 [   23.391199] <<-GTP-ERROR->> I2C Read: 0x8047, 1 bytes failed, errcode: -6! Process reset.
 [   23.473712] <<-GTP-ERROR->> GTP i2c test failed time 3.
 [   23.487866] <<-GTP-ERROR->> I2C Read: 0x8047, 1 bytes failed, errcode: -6! Process reset.
 [   23.570380] <<-GTP-ERROR->> GTP i2c test failed time 4.
 [   23.584533] <<-GTP-ERROR->> I2C Read: 0x8047, 1 bytes failed, errcode: -6! Process reset.
 [   23.667045] <<-GTP-ERROR->> GTP i2c test failed time 5.
 [   23.680375] <goodix_ts_probe>_2749    I2C communication ERROR!
 [   23.680394]    <goodix_ts_probe>_2817  prob error !!!!!!!!!!!!!!! //GT911初始化失败
 [   23.681138] input: gsl3673 as /devices/platform/ff3d0000.i2c/i2c-4/4-0040/input/input0 // GSL3673是另一款触摸屏
 [   23.740544] gsl3673 4-0040: GSL3673 test_i2c error!
 [   23.740593] gsl3673 4-0040: gsl_probe: init_chip failed
 [   23.753842] gsl3673: probe of 4-0040 failed with error -1 //GSL3673也初始化失败
 [   23.753920] rk3x-i2c ff3d0000.i2c: Initialized RK3xxx I2C bus at ffffff800953e000
 [   23.754991] IR NEC protocol handler initialized
 [   23.755008] IR RC5(x/sz) protocol handler initialized
 [   23.755060] IR RC6 protocol handler initialized
 [   23.755079] IR JVC protocol handler initialized
 [   23.755096] IR Sony protocol handler initialized
 [   23.755112] IR SANYO protocol handler initialized
 [   23.755127] IR Sharp protocol handler initialized
 [   23.755143] IR MCE Keyboard/mouse protocol handler initialized
 [   23.755158] IR XMP protocol handler initialized
 [   23.755468] usbcore: registered new interface driver uvcvideo
 [   23.755480] USB Video Class driver (1.1.1)
 [   23.755499] CamSys driver version: v0.34.7, CamSys head file version: v0.14.0
 [   23.756126] __power_supply_register: Expected proper parent device for 'test_ac'
 [   23.756299] __power_supply_register: Expected proper parent device for 'test_battery'
 [   23.756615] thermal thermal_zone2: power_allocator: sustainable_power will be estimated
 [   23.756749] __power_supply_register: Expected proper parent device for 'test_usb'
 [   23.759868] rk_tsadcv2_temp_to_code: Invalid conversion table: code=1023, temperature=2147483647
 [   23.760770] device-mapper: uevent: version 1.0.3
 [   23.761226] device-mapper: ioctl: 4.34.0-ioctl (2015-10-28) initialised: dm-devel@redhat.com
 [   23.761475] Bluetooth: HCI UART driver ver 2.3
 [   23.761489] Bluetooth: HCI UART protocol H4 registered
 [   23.761501] Bluetooth: HCI UART protocol LL registered
 [   23.761517] rtk_btusb: RTKBT_RELEASE_NAME: 20170109_TV_ANDROID_6.x
 [   23.761527] rtk_btusb: Realtek Bluetooth USB driver module init, version 4.1.2
 [   23.761537] rtk_btusb: Register usb char device interface for BT driver
 [   23.761813] usbcore: registered new interface driver rtk_btusb
 [   23.762416] cpu cpu0: leakage=0       //CPU LEAKAGE信息
 [   23.780434] cpu cpu0: temp=24444, pvtm=144616 (146571 + -1955)
 [   23.781122] cpu cpu0: pvtm-sel=1
 [   23.781571] cpu cpu4: leakage=0
 [   23.794198] cpu cpu4: temp=24444, pvtm=151939 (153146 + -1207)
 [   23.794359] cpu cpu4: pvtm-sel=1
 [   23.801361] sdhci: Secure Digital Host Controller Interface driver
 [   23.801422] sdhci: Copyright(c) Pierre Ossman
 [   23.801443] Synopsys Designware Multimedia Card Interface Driver //EMMC初始化
 [   23.802660] dwmmc_rockchip fe310000.dwmmc: IDMAC supports 32-bit address mode.
 [   23.802820] dwmmc_rockchip fe310000.dwmmc: Using internal DMA controller.
 [   23.802842] dwmmc_rockchip fe310000.dwmmc: Version ID is 270a
 [   23.802898] dwmmc_rockchip fe310000.dwmmc: DW MMC controller at irq 25,32 bit host data width,256 deep fifo
 [   23.802933] dwmmc_rockchip fe310000.dwmmc: 'clock-freq-min-max' property was deprecated.
 [   23.802985] dwmmc_rockchip fe310000.dwmmc: No vmmc regulator found
 [   23.802998] dwmmc_rockchip fe310000.dwmmc: No vqmmc regulator found
 [   23.804134] dwmmc_rockchip fe320000.dwmmc: IDMAC supports 32-bit address mode.
 [   23.804243] dwmmc_rockchip fe320000.dwmmc: Using internal DMA controller.
 [   23.804263] dwmmc_rockchip fe320000.dwmmc: Version ID is 270a
 [   23.804312] dwmmc_rockchip fe320000.dwmmc: DW MMC controller at irq 26,32 bit host data width,256 deep fifo
 [   23.804337] dwmmc_rockchip fe320000.dwmmc: 'clock-freq-min-max' property was deprecated.
 [   23.804461] dwmmc_rockchip fe320000.dwmmc: No vmmc regulator found
 [   23.804774] vcc_sd: unsupportable voltage range: 3300000-3000000uV
 [   23.804803] rockchip-iodomain ff770000.syscon:io-domains: Setting to 3000000 done
 [   23.804821] rockchip-iodomain ff770000.syscon:io-domains: Setting to 3000000 done
 [   23.817159] mmc_host mmc0: Bus speed (slot 0) = 400000Hz (slot req 400000Hz, actual 400000HZ div = 0)
 [   23.831508] dwmmc_rockchip fe320000.dwmmc: 1 slots initialized
 [   23.831961] sdhci-pltfm: SDHCI platform and OF driver helper
 [   23.833982] sdhci-arasan fe330000.sdhci: No vmmc regulator found
 [   23.834038] sdhci-arasan fe330000.sdhci: No vqmmc regulator found
 [   23.860500] mmc1: SDHCI controller on fe330000.sdhci [fe330000.sdhci] using ADMA
 [   23.861497] hidraw: raw HID events driver (C) Jiri Kosina
 [   23.866060] usbcore: registered new interface driver usbhid
 [   23.866085] usbhid: USB HID core driver
 [   23.866274] inv_mpu_iio: inv_mpu_init:746
 [   23.867235] ashmem: initialized
 [   23.869035] rockchip-dmc dmc: unable to get devfreq-event device : dfi //DDR变频初始化失败
 [   23.872213] ff100000.saradc supply vref not found, using dummy regulator
 [   23.873494] rknandbase v1.1 2016-11-08
 [   23.874014] usbcore: registered new interface driver snd-usb-audio
 [   23.878213] u32 classifier
 [   23.879016]     Actions configured
 [   23.879360] Netfilter messages via NETLINK v0.30.
 [   23.879840] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
 [   23.880758] ctnetlink v0.93: registering with nfnetlink.
 [   23.881841] xt_time: kernel timezone is -0000
 [   23.883313] ip_tables: (C) 2000-2006 Netfilter Core Team
 [   23.883978] arp_tables: (C) 2002 David S. Miller
 [   23.885031] Initializing XFRM netlink socket
 [   23.885865] NET: Registered protocol family 10
 [   23.887306] mip6: Mobile IPv6
 [   23.887618] ip6_tables: (C) 2000-2006 Netfilter Core Team
 [   23.889689] sit: IPv6 over IPv4 tunneling driver
 [   23.890600] NET: Registered protocol family 17
 [   23.891039] NET: Registered protocol family 15
 [   23.891484] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this.
 [   23.893543] Bridge firewalling registered
 [   23.893921] Ebtables v2.0 registered
 [   23.894547] Bluetooth: RFCOMM TTY layer initialized
 [   23.894597] Bluetooth: RFCOMM socket layer initialized
 [   23.894639] Bluetooth: RFCOMM ver 1.11
 [   23.894674] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
 [   23.894686] Bluetooth: BNEP filters: protocol multicast
 [   23.894704] Bluetooth: BNEP socket layer initialized
 [   23.894724] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
 [   23.894739] Bluetooth: HIDP socket layer initialized
 [   23.894793] l2tp_core: L2TP core driver, V2.0
 [   23.894818] l2tp_ppp: PPPoL2TP kernel driver, V2.0
 [   23.894838] [WLAN_RFKILL]: Enter rfkill_wlan_init 		//WIFI初始化
 [   23.895296] [WLAN_RFKILL]: Enter rfkill_wlan_probe
 [   23.895388] [WLAN_RFKILL]: wlan_platdata_parse_dt: wifi_chip_type = ap6354
 [   23.895400] [WLAN_RFKILL]: wlan_platdata_parse_dt: enable wifi power control.
 [   23.895412] [WLAN_RFKILL]: wlan_platdata_parse_dt: wifi power controled by gpio.
 [   23.895519] [WLAN_RFKILL]: wlan_platdata_parse_dt: get property: WIFI,host_wake_irq = 1003, flags = 0.
 [   23.895530] [WLAN_RFKILL]: rfkill_wlan_probe: init gpio
 [   23.895545] [WLAN_RFKILL]: Exit rfkill_wlan_probe
 [   23.895640] [BT_RFKILL]: Enter rfkill_rk_init
 [   23.896165] [BT_RFKILL]: bluetooth_platdata_parse_dt: get property: uart_rts_gpios = 1083.
 [   23.896221] [BT_RFKILL]: bluetooth_platdata_parse_dt: get property: BT,reset_gpio = 1009.
 [   23.896262] [BT_RFKILL]: bluetooth_platdata_parse_dt: get property: BT,wake_gpio = 1090.
 [   23.896303] [BT_RFKILL]: bluetooth_platdata_parse_dt: get property: BT,wake_host_irq = 1004.
 [   23.897687] [BT_RFKILL]: Request irq for bt wakeup host
 [   23.897753] [BT_RFKILL]: ** disable irq
 [   23.897915] [BT_RFKILL]: bt_default device registered.
 [   23.898195] sensor_register_slave:mpu6500_gyro,id=48
 [   23.898217] sensor_register_slave:mpu6880_gyro,id=49
 [   23.899908] Registered cp15_barrier emulation handler
 [   23.899985] Registered setend emulation handler
 [   23.901466] mmc1: MAN_BKOPS_EN bit is not set
 [   23.910523] registered taskstats version 1
 [   23.911297] rockchip ion idev is NULL
 [   23.911318] rga2 ff680000.rga: rga ion client create success!
 [   23.911509] rga: Driver loaded successfully ver:3.02
 [   23.912418] rockchip-usb2phy ff770000.syscon:usb2-phy@e450: vbus_drv is not assigned
 [   23.913596] rockchip-usb2phy ff770000.syscon:usb2-phy@e460: vbus_drv is not assigned
 [   23.915565] rockchip-drm display-subsystem: bound ff900000.vop (ops vop_component_ops) //DRM显示系统启动
 [   23.915764] rockchip-drm display-subsystem: bound ff8f0000.vop (ops vop_component_ops)
 [   23.915833] rockchip-drm display-subsystem: bound ff960000.dsi (ops dw_mipi_dsi_ops)
 [   23.916198] i2c i2c-9: of_i2c: modalias failure on /hdmi@ff940000/ports
 [   23.916232] dwhdmi-rockchip ff940000.hdmi: registered DesignWare HDMI I2C bus driver 		//HDMI注册
 [   23.916300] dwhdmi-rockchip ff940000.hdmi: Detected HDMI TX controller v2.11a with HDCP (DWC HDMI 2.0 TX PHY)
 [   23.917159] rockchip-drm display-subsystem: bound ff940000.hdmi (ops dw_hdmi_rockchip_ops)
 [   23.917791] cdn-dp fec00000.dp: [drm:cdn_dp_pd_event_work] Not connected. Disabling cdn 	//DP注册
 [   23.917833] rockchip-drm display-subsystem: bound fec00000.dp (ops cdn_dp_component_ops)
 [   23.917850] [drm:drm_vblank_init] Supports vblank timestamp caching Rev 2 (21.10.2013).
 [   23.917864] [drm:drm_vblank_init] No driver support for vblank timestamp query.
 [   23.917880] mmc1: new HS400 MMC card at address 0001 //eMMC注册成功
 [   23.918463] mmcblk1: mmc1:0001 AWPD3R 14.6 GiB
 [   23.918712] mmcblk1boot0: mmc1:0001 AWPD3R partition 1 4.00 MiB
 [   23.918946] mmcblk1boot1: mmc1:0001 AWPD3R partition 2 4.00 MiB
 [   23.919189] mmcblk1rpmb: mmc1:0001 AWPD3R partition 3 4.00 MiB
 [   23.919645] rkpart: partition size too small (5)
 [   23.919663]      uboot: 0x000400000 -- 0x000800000 (4 MB)
 [   23.919676]      trust: 0x000800000 -- 0x000c00000 (4 MB)
 [   23.919687]       misc: 0x000c00000 -- 0x001000000 (4 MB)
 [   23.919699]   resource: 0x001000000 -- 0x002000000 (16 MB)
 [   23.919711]     kernel: 0x002000000 -- 0x003800000 (24 MB)
 [   23.919722]       boot: 0x003800000 -- 0x005800000 (32 MB)
 [   23.919734]   recovery: 0x005800000 -- 0x007800000 (32 MB)
 [   23.919745]     backup: 0x007800000 -- 0x00e800000 (112 MB)
 [   23.919757]      cache: 0x00e800000 -- 0x016800000 (128 MB)
 [   23.919769]     system: 0x016800000 -- 0x076800000 (1536 MB)
 [   23.919781]   metadata: 0x076800000 -- 0x077800000 (16 MB)
 [   23.919792] verity_mode: 0x077800000 -- 0x077808000 (0 MB)
 [   23.919804] baseparamer: 0x077808000 -- 0x077c08000 (4 MB)
 [   23.919816]        frp: 0x077c08000 -- 0x077c88000 (0 MB)
 [   23.919827]   userdata: 0x077c88000 -- 0x3a3a00000 (12989 MB)
 [   23.919900]  mmcblk1: p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 //分区挂载成功
 [   23.960872] rockchip-drm display-subsystem: fb0:  frame buffer device
 [   23.973531] mali ff9a0000.gpu: leakage=0  //GPU LEAKAGE信息
 [   23.999245] mali ff9a0000.gpu: temp=25000, pvtm=121768 (122504 + -736)
 [   24.001483] mali ff9a0000.gpu: pvtm-sel=1
 [   24.002828] mali ff9a0000.gpu: GPU identified as 0x0860 r2p0 status 0
 [   24.004313] I : [File] : drivers/gpu/arm/midgard/backend/gpu/mali_kbase_devfreq.c; [Line] : 284; [Func] : kbase_devfreq_init(); success initing power_model_simple.
 [   24.005638] mali ff9a0000.gpu: Probed as mali0
 [   24.012954] xhci-hcd xhci-hcd.8.auto: xHCI Host Controller
 [   24.013918] xhci-hcd xhci-hcd.8.auto: new USB bus registered, assigned bus number 1
 [   24.014948] xhci-hcd xhci-hcd.8.auto: hcc params 0x0220fe64 hci version 0x110 quirks 0x02030010
 [   24.015836] xhci-hcd xhci-hcd.8.auto: irq 223, io mem 0xfe800000
 [   24.016617] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
 [   24.017260] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.017936] usb usb1: Product: xHCI Host Controller
 [   24.018406] usb usb1: Manufacturer: Linux 4.4.103 xhci-hcd
 [   24.018926] usb usb1: SerialNumber: xhci-hcd.8.auto
 [   24.020251] hub 1-0:1.0: USB hub found
 [   24.020672] hub 1-0:1.0: 1 port detected
 [   24.021534] xhci-hcd xhci-hcd.8.auto: xHCI Host Controller
 [   24.022081] xhci-hcd xhci-hcd.8.auto: new USB bus registered, assigned bus number 2
 [   24.022887] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
 [   24.023831] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
 [   24.023871] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.023896] usb usb2: Product: xHCI Host Controller
 [   24.023918] usb usb2: Manufacturer: Linux 4.4.103 xhci-hcd
 [   24.023942] usb usb2: SerialNumber: xhci-hcd.8.auto
 [   24.027441] hub 2-0:1.0: USB hub found
 [   24.027854] hub 2-0:1.0: 1 port detected
 [   24.030758] xhci-hcd xhci-hcd.8.auto: remove, state 1
 [   24.030827] usb usb2: USB disconnect, device number 1
 [   24.055990] xhci-hcd xhci-hcd.8.auto: Host not halted after 16000 microseconds.
 [   24.056015] xhci-hcd xhci-hcd.8.auto: Host controller not halted, aborting reset.
 [   24.057469] xhci-hcd xhci-hcd.8.auto: USB bus 2 deregistered
 [   24.057994] xhci-hcd xhci-hcd.8.auto: remove, state 1
 [   24.058470] usb usb1: USB disconnect, device number 1
 [   24.059406] xhci-hcd xhci-hcd.8.auto: USB bus 1 deregistered
 [   24.065438] xhci-hcd xhci-hcd.9.auto: xHCI Host Controller
 [   24.065523] xhci-hcd xhci-hcd.9.auto: new USB bus registered, assigned bus number 1
 [   24.065818] xhci-hcd xhci-hcd.9.auto: hcc params 0x0220fe64 hci version 0x110 quirks 0x02030010
 [   24.065881] xhci-hcd xhci-hcd.9.auto: irq 224, io mem 0xfe900000
 [   24.066070] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
 [   24.066086] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.066100] usb usb1: Product: xHCI Host Controller
 [   24.066114] usb usb1: Manufacturer: Linux 4.4.103 xhci-hcd
 [   24.066126] usb usb1: SerialNumber: xhci-hcd.9.auto
 [   24.066757] hub 1-0:1.0: USB hub found
 [   24.066800] hub 1-0:1.0: 1 port detected
 [   24.067204] xhci-hcd xhci-hcd.9.auto: xHCI Host Controller
 [   24.067228] xhci-hcd xhci-hcd.9.auto: new USB bus registered, assigned bus number 2
 [   24.067311] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
 [   24.067437] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
 [   24.067454] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.067468] usb usb2: Product: xHCI Host Controller
 [   24.067481] usb usb2: Manufacturer: Linux 4.4.103 xhci-hcd
 [   24.067493] usb usb2: SerialNumber: xhci-hcd.9.auto
 [   24.068121] hub 2-0:1.0: USB hub found
 [   24.068160] hub 2-0:1.0: 1 port detected
 [   24.068692] xhci-hcd xhci-hcd.9.auto: remove, state 1
 [   24.068719] usb usb2: USB disconnect, device number 1
 [   24.069377] xhci-hcd xhci-hcd.9.auto: USB bus 2 deregistered
 [   24.069396] xhci-hcd xhci-hcd.9.auto: remove, state 1
 [   24.069416] usb usb1: USB disconnect, device number 1
 [   24.070047] xhci-hcd xhci-hcd.9.auto: USB bus 1 deregistered
 [   24.074245] ehci-platform fe380000.usb: EHCI Host Controller
 [   24.074279] ehci-platform fe380000.usb: new USB bus registered, assigned bus number 1
 [   24.074543] ehci-platform fe380000.usb: irq 28, io mem 0xfe380000
 [   24.083919] ehci-platform fe380000.usb: USB 2.0 started, EHCI 1.00
 [   24.084192] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
 [   24.084209] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.084223] usb usb1: Product: EHCI Host Controller
 [   24.084235] usb usb1: Manufacturer: Linux 4.4.103 ehci_hcd
 [   24.084247] usb usb1: SerialNumber: fe380000.usb
 [   24.085166] hub 1-0:1.0: USB hub found
 [   24.085259] hub 1-0:1.0: 1 port detected
 [   24.089706] ehci-platform fe3c0000.usb: EHCI Host Controller
 [   24.089763] ehci-platform fe3c0000.usb: new USB bus registered, assigned bus number 2
 [   24.089996] ehci-platform fe3c0000.usb: irq 30, io mem 0xfe3c0000
 [   24.097235] ehci-platform fe3c0000.usb: USB 2.0 started, EHCI 1.00
 [   24.097515] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
 [   24.097532] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.097546] usb usb2: Product: EHCI Host Controller
 [   24.097559] usb usb2: Manufacturer: Linux 4.4.103 ehci_hcd
 [   24.097571] usb usb2: SerialNumber: fe3c0000.usb
 [   24.098625] hub 2-0:1.0: USB hub found
 [   24.098721] hub 2-0:1.0: 1 port detected
 [   24.099832] ohci-platform fe3a0000.usb: Generic Platform OHCI controller
 [   24.099865] ohci-platform fe3a0000.usb: new USB bus registered, assigned bus number 3
 [   24.100107] ohci-platform fe3a0000.usb: irq 29, io mem 0xfe3a0000
 [   24.154853] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
 [   24.154918] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.154933] usb usb3: Product: Generic Platform OHCI controller
 [   24.154946] usb usb3: Manufacturer: Linux 4.4.103 ohci_hcd
 [   24.154959] usb usb3: SerialNumber: fe3a0000.usb
 [   24.155994] hub 3-0:1.0: USB hub found
 [   24.156037] hub 3-0:1.0: 1 port detected
 [   24.157125] ohci-platform fe3e0000.usb: Generic Platform OHCI controller
 [   24.157161] ohci-platform fe3e0000.usb: new USB bus registered, assigned bus number 4
 [   24.157398] ohci-platform fe3e0000.usb: irq 31, io mem 0xfe3e0000
 [   24.214981] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
 [   24.215084] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
 [   24.215114] usb usb4: Product: Generic Platform OHCI controller
 [   24.215139] usb usb4: Manufacturer: Linux 4.4.103 ohci_hcd
 [   24.215163] usb usb4: SerialNumber: fe3e0000.usb
 [   24.216704] hub 4-0:1.0: USB hub found
 [   24.216787] hub 4-0:1.0: 1 port detected
 [   24.219659] dwmmc_rockchip fe310000.dwmmc: IDMAC supports 32-bit address mode.
 [   24.219915] dwmmc_rockchip fe310000.dwmmc: Using internal DMA controller.
 [   24.219954] dwmmc_rockchip fe310000.dwmmc: Version ID is 270a
 [   24.220019] dwmmc_rockchip fe310000.dwmmc: DW MMC controller at irq 25,32 bit host data width,256 deep fifo
 [   24.220069] dwmmc_rockchip fe310000.dwmmc: 'clock-freq-min-max' property was deprecated.
 [   24.220159] dwmmc_rockchip fe310000.dwmmc: No vmmc regulator found
 [   24.220185] dwmmc_rockchip fe310000.dwmmc: No vqmmc regulator found
 [   24.220927] dwmmc_rockchip fe310000.dwmmc: allocated mmc-pwrseq
 [   24.234136] mmc_host mmc2: Bus speed (slot 0) = 400000Hz (slot req 400000Hz, actual 400000HZ div = 0)
 [   24.247461] dwmmc_rockchip fe310000.dwmmc: 1 slots initialized
 [   24.263666] rockchip-dmc dmc: fail to register notify to vop.
 [   24.298732] mmc2: queuing unknown CIS tuple 0x80 (2 bytes)
 [   24.301020] mmc2: queuing unknown CIS tuple 0x80 (3 bytes)
 [   24.303206] mmc2: queuing unknown CIS tuple 0x80 (3 bytes)
 [   24.306738] mmc2: queuing unknown CIS tuple 0x80 (7 bytes)
 [   24.366859] mmc_host mmc2: Bus speed (slot 0) = 150000000Hz (slot req 150000000Hz, actual 150000000HZ div = 0)
 [   24.410437] asoc-simple-card es8316-sound: ES8316 HiFi <-> ff880000.i2s mapping ok 					//声卡初始化
 [   24.410560] asoc-simple-card es8316-sound: ASoC: no source widget found for MICBIAS1
 [   24.410592] asoc-simple-card es8316-sound: ASoC: Failed to add route MICBIAS1 -> direct -> Mic Jack
 [   24.410627] asoc-simple-card es8316-sound: ASoC: no sink widget found for IN1P
 [   24.410657] asoc-simple-card es8316-sound: ASoC: Failed to add route Mic Jack -> direct -> IN1P
 [   24.411211] es8316 1-0011: ASoC: Failed to create Left Hp mixer debugfs file
 [   24.411251] es8316 1-0011: ASoC: Failed to create Right Hp mixer debugfs file
 [   24.411315] es8316 1-0011: ASoC: Failed to create HPCP L debugfs file
 [   24.411350] es8316 1-0011: ASoC: Failed to create HPCP R debugfs file
 [   24.411405] es8316 1-0011: ASoC: Failed to create HPVOL L debugfs file
 [   24.411439] es8316 1-0011: ASoC: Failed to create HPVOL R debugfs file
 [   24.416886] otg_wakelock_init: No USB transceiver found
 [   24.419733] rk808-rtc rk808-rtc: setting system clock to 2013-01-18 08:50:37 UTC (1358499037)
 [   24.423036] It doesn't contain Rogue gpu
 [   24.444988] vendor storage:20160801 ret = 0
 [   24.462371] I : [File] : drivers/gpu/arm/mali400/mali/linux/mali_kernel_linux.c; [Line] : 414; [Func] : mali_module_init(); svn_rev_string_from_arm of this mali_ko i.
 [   24.464906] Mali: Mali device driver loaded
 [   24.466091] input: rk29-keypad as /devices/platform/rockchip-key/input/input1
 [   24.468279] ALSA device list:
 [   24.468565]   #0: rockchip,es8316-codec 		//声卡初始化成功
 [   24.469767] Freeing unused kernel memory: 832K
 [   24.473279] init: init first stage started!
 [   24.497729] dwmmc_rockchip fe310000.dwmmc: Successfully tuned phase to 203 //ANDROID启动标志
 [   24.499117] mmc2: queuing unknown CIS tuple 0x91 (3 bytes)
 [   24.499150] mmc2: new ultra high speed SDR104 SDIO card at address 0001
 [   24.556542] audit: type=1403 audit(1358499037.633:2): policy loaded auid=4294967295 ses=4294967295
 [   24.558434] init: (Initializing SELinux non-enforcing took 0.08s.)
 [   24.563661] init: init second stage started!
 [   24.569053] init: Setting ro.rk.soc=rk3399
 [   24.569575] init: OK,EMMC DRIVERS INIT OK
 [   24.569968] init: property_set("ro.boot.mode", "emmc") failed
 [   24.570542] init: property_set("ro.hardware", "rk30board") failed
 [   24.573464] init: Running restorecon...
 [   24.664426] init: waitpid failed: No child processes
 [   24.664911] init: (Loading properties from /default.prop took 0.00s.)
 [   24.667572] init: (Parsing /init.environ.rc took 0.00s.)
 [   24.668067] init: (Parsing /init.usb.rc took 0.00s.)
 [   24.669185] init: (Parsing init.rk30board.bootmode.emmc.rc took 0.00s.)
 [   24.669837] init: (Parsing init.rk30board.usb.rc took 0.00s.)
 [   24.669891] init: (Parsing init.rk30board.environment.rc took 0.00s.)
 [   24.669971] init: could not import file '/init.stt_trace.rc' from '/init.debug.rc': No such file or directory
 [   24.670155] init: (Parsing /init.logs.rc took 0.00s.)
 [   24.670230] init: (Parsing /init.crashlogd.rc took 0.00s.)
 [   24.670311] init: (Parsing /init.coredump.rc took 0.00s.)
 [   24.670518] init: (Parsing /init.log-watch.rc took 0.00s.)
 [   24.670576] init: (Parsing /init.kernel.rc took 0.00s.)
 [   24.670679] init: (Parsing /init.debug-charging.rc took 0.00s.)
 [   24.670697] init: (Parsing /init.debug.rc took 0.00s.)
 [   24.670715] init: (Parsing init.rockchip.rc took 0.00s.)
 [   24.671121] init: (Parsing init.connectivity.rc took 0.00s.)
 [   24.671162] init: could not import file 'init.box.samba.rc' from '/init.rk30board.rc': No such file or directory
 [   24.671258] init: (Parsing init.rk3399.rc took 0.00s.)
 [   24.671362] init: (Parsing init.tablet.rc took 0.00s.)
 [   24.671396] init: could not import file 'init.car.rc' from '/init.rk30board.rc': No such file or directory
 [   24.671429] init: could not import file 'init.optee.rc' from '/init.rk30board.rc': No such file or directory
 [   24.671447] init: (Parsing /init.rk30board.rc took 0.00s.)
 [   24.672041] init: (Parsing /init.usb.configfs.rc took 0.00s.)
 [   24.672131] init: (Parsing /init.zygote64_32.rc took 0.00s.)
 [   24.672149] init: (Parsing /init.rc took 0.01s.)
 [   24.672755] init: Starting service 'ueventd'...
 [   24.677083] audit: type=1400 audit(1358499037.756:3): avc:  denied  { getattr } for  pid=1 comm="init" path="/sys/kernel/debug/tracing/trace_marker" dev="tracefs" in1
 [   24.686012] ueventd: ueventd started!
 [   24.686786] ueventd: invalid gid 'trace'
 [   24.895750] ueventd: Coldboot took 0.20s.
 [   24.919369] init: write_file: Unable to open '/proc/self/coredump_filter': No such file or directory
 [   24.919464] init: write_file: Unable to open '/proc/sys/kernel/panic_on_stackoverflow': No such file or directory
 [   24.919512] init: Waiting for /dev/.coldboot_done...
 [   24.919608] init: Waiting for /dev/.coldboot_done took 0.00s.
 [   24.919646] init: /dev/hw_random not found
 [   24.920278] keychord: using input dev rk29-keypad for fevent
 [   24.926933] init: write_file: Unable to open '/proc/cpu/alignment': No such file or directory
 [   24.937454] Registered swp emulation handler
 [   24.937724] init: write_file: Unable to open '/sys/module/rockchip_pm/parameters/policy': No such file or directory
 [   24.938588] fs_mgr: Warning: unknown flag resize
 [   25.284975] init: /dev/hw_random not found
 [   25.285156] init: write_file: Unable to open '/sys/block/mmcblk0/bdi/read_ahead_kb': No such file or directory
 [   25.286711] fs_mgr: Warning: unknown flag resize
 [   25.939503] fs_mgr: Enabling dm-verity for system (mode 2)
 [   25.940195] fs_mgr: loading verity table: '1 /dev/block/platform/fe330000.sdhci/by-name/system /dev/block/platform/fe330000.sdhci/by-name/system 4096 4096 387072 387'
 [   25.969515] EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: noauto_da_alloc
 [   25.970723] fs_mgr: __mount(source=/dev/block/dm-0,target=/system,type=ext4)=0
 [   25.972692] fs_mgr: check_fs(): mount(/dev/block/platform/fe330000.sdhci/by-name/cache,/cache,ext4)=-1: No such file or directory
 [   25.979705] fs_mgr: Running /system/bin/e2fsck on /dev/block/platform/fe330000.sdhci/by-name/cache
 [   25.995641] random: e2fsck: uninitialized urandom read (40 bytes read, 75 bits of entropy available)
 [   26.113420] e2fsck: e2fsck 1.42.9 (28-Dec-2013) //文件系统布置
 [   26.113420]
 [   26.113626] e2fsck: /dev/block/platform/fe330000.sdhci/by-name/cache: recovering journal
 [   26.113626]
 [   26.113754] e2fsck: Superblock last mount time is in the future.
 [   26.113754]
 [   26.113806] e2fsck:  (by less than a day, probably due to the hardware clock being incorrectly set)  Fix? yes
 [   26.113806]
 [   26.113852] e2fsck:
 [   26.113852]
 [   26.113897] e2fsck: /dev/block/platform/fe330000.sdhci/by-name/cache: clean, 23/8192 files, 1611/32768 blocks (check in 4 mounts)
 [   26.113897]
 [   26.121478] EXT4-fs (mmcblk1p9): mounted filesystem with ordered data mode. Opts: noauto_da_alloc,discard
 [   26.126613] fs_mgr: __mount(source=/dev/block/platform/fe330000.sdhci/by-name/cache,target=/cache,type=ext4)=0
 [   26.129054] EXT4-fs (mmcblk1p11): Ignoring removed nomblk_io_submit option
 [   26.136758] EXT4-fs (mmcblk1p11): recovery complete
 [   26.137805] EXT4-fs (mmcblk1p11): mounted filesystem with ordered data mode. Opts: errors=remount-ro,nomblk_io_submit
 [   26.138954] fs_mgr: check_fs(): mount(/dev/block/platform/fe330000.sdhci/by-name/metadata,/metadata,ext4)=0: Success
 [   26.150279] fs_mgr: check_fs(): unmount(/metadata) succeeded
 [   26.150621] fs_mgr: Running /system/bin/e2fsck on /dev/block/platform/fe330000.sdhci/by-name/metadata
 [   26.155247] random: e2fsck: uninitialized urandom read (40 bytes read, 81 bits of entropy available)
 [   26.184481] e2fsck: e2fsck 1.42.9 (28-Dec-2013)
 [   26.184481]
 [   26.184710] e2fsck: /dev/block/platform/fe330000.sdhci/by-name/metadata: clean, 12/1024 files, 1105/4096 blocks (check in 2 mounts)
 [   26.184710]
 [   26.190749] EXT4-fs (mmcblk1p11): mounted filesystem with ordered data mode. Opts: noauto_da_alloc,discard
 [   26.190969] fs_mgr: __mount(source=/dev/block/platform/fe330000.sdhci/by-name/metadata,target=/metadata,type=ext4)=0
 [   26.191173] fs_mgr: Running /system/bin/fsck.f2fs -a /dev/block/platform/fe330000.sdhci/by-name/userdata
 [   26.204001] fsck.f2fs: executing /system/bin/fsck.f2fs failed: No such file or directory
 [   26.204001]
 [   26.204958] fsck.f2fs: fsck.f2fs terminated by exit(255)
 [   26.204958]
 [   26.209577] F2FS-fs (mmcblk1p15): Magic Mismatch, valid(0xf2f52010) - read(0x60fe5652)
 [   26.210327] F2FS-fs (mmcblk1p15): Can't find valid F2FS filesystem in 1th superblock
 [   26.211674] F2FS-fs (mmcblk1p15): Magic Mismatch, valid(0xf2f52010) - read(0x9df872fc)
 [   26.212417] F2FS-fs (mmcblk1p15): Can't find valid F2FS filesystem in 2th superblock
 [   26.213162] F2FS-fs (mmcblk1p15): Magic Mismatch, valid(0xf2f52010) - read(0x60fe5652)
 [   26.213899] F2FS-fs (mmcblk1p15): Can't find valid F2FS filesystem in 1th superblock
 [   26.213938] F2FS-fs (mmcblk1p15): Magic Mismatch, valid(0xf2f52010) - read(0x9df872fc)
 [   26.213964] F2FS-fs (mmcblk1p15): Can't find valid F2FS filesystem in 2th superblock
 [   26.214215] fs_mgr: __mount(source=/dev/block/platform/fe330000.sdhci/by-name/userdata,target=/data,type=f2fs)=-1
 [   26.217457] fs_mgr: fs_mgr_mount_all(): possibly an encryptable blkdev /dev/block/platform/fe330000.sdhci/by-name/userdata for mount /data type f2fs )
 [   26.225533] init: (Parsing /system/etc/init/atrace.rc took 0.00s.)
 [   26.226359] init: (Parsing /system/etc/init/audioserver.rc took 0.00s.)
 [   26.226836] init: (Parsing /system/etc/init/bootanim.rc took 0.00s.)
 [   26.227458] init: (Parsing /system/etc/init/bootstat.rc took 0.00s.)
 [   26.227969] init: (Parsing /system/etc/init/cameraserver.rc took 0.00s.)
 [   26.228449] init: (Parsing /system/etc/init/debuggerd.rc took 0.00s.)
 [   26.228910] init: (Parsing /system/etc/init/debuggerd64.rc took 0.00s.)
 [   26.229401] init: (Parsing /system/etc/init/drmserver.rc took 0.00s.)
 [   26.230037] init: (Parsing /system/etc/init/dumpstate.rc took 0.00s.)
 [   26.230623] init: (Parsing /system/etc/init/gatekeeperd.rc took 0.00s.)
 [   26.231164] init: (Parsing /system/etc/init/init-debug.rc took 0.00s.)
 [   26.231681] init: (Parsing /system/etc/init/installd.rc took 0.00s.)
 [   26.232161] init: (Parsing /system/etc/init/keystore.rc took 0.00s.)
 [   26.232647] init: (Parsing /system/etc/init/lmkd.rc took 0.00s.)
 [   26.233663] init: (Parsing /system/etc/init/logcatd.rc took 0.00s.)
 [   26.235914] init: (Parsing /system/etc/init/logd.rc took 0.00s.)
 [   26.236422] init: (Parsing /system/etc/init/mdnsd.rc took 0.00s.)
 [   26.236909] init: (Parsing /system/etc/init/mediacodec.rc took 0.00s.)
 [   26.237508] init: (Parsing /system/etc/init/mediadrmserver.rc took 0.00s.)
 [   26.238001] init: (Parsing /system/etc/init/mediaextractor.rc took 0.00s.)
 [   26.238542] init: ignored duplicate definition of service 'media'init: (Parsing /system/etc/init/mediaserver.rc took 0.00s.)
 [   26.239089] init: (Parsing /system/etc/init/mtpd.rc took 0.00s.)
 [   26.239574] init: (Parsing /system/etc/init/netd.rc took 0.00s.)
 [   26.239959] init: (Parsing /system/etc/init/perfprofd.rc took 0.00s.)
 [   26.240387] init: (Parsing /system/etc/init/racoon.rc took 0.00s.)
 [   26.241091] init: ignored duplicate definition of service 'ril-daemon'init: (Parsing /system/etc/init/rild.rc took 0.00s.)
 [   26.241636] init: (Parsing /system/etc/init/servicemanager.rc took 0.00s.)
 [   26.242115] init: (Parsing /system/etc/init/surfaceflinger.rc took 0.00s.)
 [   26.242614] init: (Parsing /system/etc/init/uncrypt.rc took 0.00s.)
 [   26.243115] init: (Parsing /system/etc/init/vdc.rc took 0.00s.)
 [   26.243614] init: (Parsing /system/etc/init/vold.rc took 0.00s.)
 [   26.246165] init: Starting service 'logd'...
 [   26.261334] random: logd: uninitialized urandom read (40 bytes read, 85 bits of entropy available)
 [   26.268730] init: insmod: open("/system/lib/modules/ump.ko") failed: No such file or directoryinit: insmod: open("/system/lib/modules/mali.ko") failed: No such file e
 [   26.278412] zram0: detected capacity change from 0 to 533413888
 [   26.286518] random: mkswap: uninitialized urandom read (40 bytes read, 86 bits of entropy available)
 [   26.324320] random: mkswap: uninitialized urandom read (16 bytes read, 87 bits of entropy available)
 [   26.325523] logd.auditd: start
 [   26.325597] logd.klogd: 26321917163
 [   26.327870] Adding 520908k swap on /dev/block/zram0.  Priority:-1 extents:1 across:520908k SS
 [   26.332192] init: property_set("ro.board.platform", "rk3399") failed
 [   26.332978] init: property_set("ro.rk.screenshot_enable", "true") failed
 [   26.333223] init: (Loading properties from /system/build.prop took 0.00s.)
 [   26.333311] init: (Loading properties from /vendor/build.prop took 0.00s.)
 [   26.333405] init: (Loading properties from /factory/factory.prop took 0.00s.)
 [   26.333558] fs_mgr: Warning: unknown flag resize
 [   26.333740] init: /recovery not specified in fstab
 [   26.334809] init: Starting service 'debuggerd'...
 [   26.336563] init: Starting service 'debuggerd64'...
 [   26.338689] init: Starting service 'vold'...
 [   26.341710] init: Not bootcharting.
 [   26.344111] random: debuggerd64: uninitialized urandom read (40 bytes read, 88 bits of entropy available)
 [   26.352356] random: debuggerd: uninitialized urandom read (40 bytes read, 88 bits of entropy available)
 [   26.355525] random: vold: uninitialized urandom read (40 bytes read, 88 bits of entropy available)
 [   26.361691] random: vdc: uninitialized urandom read (40 bytes read, 89 bits of entropy available)
 [   26.495989] fs_mgr: Warning: unknown flag resize
 [   26.536908] init: Starting service 'exec 1 (/system/bin/tzdatacheck)'...
 [   26.542318] random: tzdatacheck: uninitialized urandom read (40 bytes read, 94 bits of entropy available)
 [   26.555665] init: Service 'exec 1 (/system/bin/tzdatacheck)' (pid 231) exited with status 0
 [   26.562770] tmpfs: Bad mount option background_gc
 [   26.563864] type=1400 audit(1358499039.640:4): avc: denied { create } for pid=1 comm="init" name="cifsmanager" scontext=u:r:init:s0 tcontext=u:object_r:cifsmanager_e1
 [   26.566680] init: write_file: Unable to open '/proc/sys/kernel/core_pattern': No such file or directory
 [   26.567171] type=1400 audit(1358499039.640:5): avc: denied { setattr } for pid=1 comm="init" name="cifsmanager" dev="tmpfs" ino=3507 scontext=u:r:init:s0 tcontext=u:1
 [   26.568042] init: (Loading properties from /data/local.prop took 0.00s.)
 [   26.570632] init: Starting service 'logd-reinit'...
 [   26.573275] init: write_file: Unable to open '/proc/sys/vm/min_free_order_shift': No such file or directory
 [   26.575905] init: Starting service 'healthd'...
 [   26.577441] init: cannot find '/system/bin/displayd' (No such file or directory), disabling 'displayd'
 [   26.579263] init: Starting service 'earlylogs'...
 [   26.581434] binder: 235:235 transaction failed 29189/-22, size 0-0 line 3008
 [   26.581727] init: Starting service 'lmkd'...
 [   26.583352] init: Starting service 'servicemanager'...
 [   26.586345] init: Starting service 'surfaceflinger'...
 [   26.590300] init: SELinux:  Could not stat /sys/devices/system/cpu/cpufreq/interactive: No such file or directory.
 [   26.594621] init: write_file: Unable to open '/proc/sys/vm/lazy_vfree_tlb_flush_all_threshold': No such file or directory
 [   26.603566] init: property 'ro.serialno' doesn't exist while expanding '${ro.serialno}'
 [   26.604450] init: write: cannot expand '${ro.serialno}'
 [   26.605181] init: Service 'earlylogs' (pid 236) exited with status 0
 [   26.608201] file system registered
 [   26.609726] using random self ethernet address
 [   26.610153] using random host ethernet address
 [   26.610633] init: write_file: Unable to open '/config/usb_gadget/g1/functions/rndis.gs4/wceis': Permission denied
 [   26.618941] init: Starting service 'console'...
 [   26.619950] type=1400 audit(1358499039.676:6): avc: denied { relabelto } for pid=1 comm="init" name="recovery" dev="tmpfs" ino=10040 scontext=u:r:init:s0 tcontext=u:1
 [   26.620279] type=1400 audit(1358499039.676:7): avc: denied { relabelto } for pid=1 comm="init" name="boot" dev="tmpfs" ino=10036 scontext=u:r:init:s0 tcontext=u:obje1
 [   26.621405] logd.daemon: reinit
 [   26.622083] init: Starting service 'adbd'...
 [   26.626065] init: Service 'logd-reinit' (pid 234) exited with status 0
 [   26.627176] init: Starting service 'exec 2 (/system/bin/vdc)'...
 [   26.642745] init: Service 'exec 2 (/system/bin/vdc)' (pid 243) exited with status 0
 rk3399_mid:/ $ [   27.338230] init: Starting service 'bootanim'... //ANDROID动画开始
 [   27.586005] healthd: BatteryCurrentNowPath not found
 [   27.586044] healthd: BatteryCycleCountPath not found
 [   27.586486] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   27.586881] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   27.587321] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   27.587696] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   27.709328] init: avc:  denied  { set } for property=ctl.bootanim pid=224 uid=0 gid=0 scontext=u:r:vold:s0 tcontext=u:object_r:ctl_bootanim_prop:s0 tclass=property_s1
 [   27.724849] fs_mgr: Running /system/bin/fsck.f2fs -a /dev/block/dm-1
 [   27.737113] fsck.f2fs: executing /system/bin/fsck.f2fs failed: No such file or directory
 [   27.737113]
 [   27.738045] fsck.f2fs: fsck.f2fs terminated by exit(255)
 [   27.738045]
 [   27.836446] F2FS-fs (dm-1): recover_inode: ino = 536, name = .temp.7kN7Pf
 [   27.837893] F2FS-fs (dm-1): recover_dentry: ino = 536, name = .temp.7kN7Pf, dir = 2e, err = 0
 [   27.871587] fs_mgr: __mount(source=/dev/block/dm-1,target=/data,type=f2fs)=0
 [   27.875185] init: (Loading properties from /data/local.prop took 0.00s.)
 [   27.903178] init: Starting service 'logd-reinit'...
 [   27.909327] init: Starting service 'ap_log_srv'...
 [   27.919508] init: Not bootcharting.
 [   27.940149] logd.daemon: reinit
 [   27.943390] init: Service 'logd-reinit' (pid 302) exited with status 0
 [   28.005049] init: Starting service 'exec 3 (/system/bin/tzdatacheck)'... //启动各种ANDROID服务
 [   28.019594] init: Starting service 'apk_logfs'...
 [   28.023342] init: Service 'ap_log_srv' (pid 303) exited with status 0
 [   28.024807] init: Service 'exec 3 (/system/bin/tzdatacheck)' (pid 309) exited with status 0
 [   28.035033] type=1400 audit(1358499041.113:8): avc: denied { setattr } for pid=1 comm="init" name="cifsmanager" dev="dm-1" ino=86 scontext=u:r:init:s0 tcontext=u:obj1
 [   28.046055] init: write_file: Unable to open '/proc/sys/kernel/core_pattern': No such file or directory
 [   28.047219] init: Starting service 'exec 4 (/system/bin/bootstat)'...
 [   28.075711] init: Service 'exec 4 (/system/bin/bootstat)' (pid 312) exited with status 0
 [   28.076529] init: cannot find '/system/bin/update_verifier' (No such file or directory), disabling 'exec 5 (/system/bin/update_verifier)'
 [   28.076580] init: cannot find '/system/bin/install-recovery.sh' (No such file or directory), disabling 'flash_recovery'
 [   28.077174] init: Starting service 'drmservice'...
 [   28.079267] init: cannot find '/system/bin/bplus_helper' (No such file or directory), disabling 'bplus_helper'
 [   28.079915] init: Service up_eth0 does not have a SELinux domain defined.
 [   28.079947] init: cannot find '/system/bin/rk_store_keybox' (No such file or directory), disabling 'rk_store_keybox'
 [   28.080218] init: Starting service 'akmd'...
 [   28.084184] init: Starting service 'media'...
 [   28.088216] init: Starting service 'zygote'...
 [   28.092223] init: Starting service 'zygote_secondary'...
 [   28.096382] init: Starting service 'audioserver'...
 [   28.099994] init: Starting service 'cameraserver'...
 [   28.101635] init: couldn't write 321 to /dev/cpuset/camera-daemon/tasks: No such file or directory
 [   28.103584] init: Starting service 'drm'...
 [   28.107808] init: Starting service 'installd'...
 [   28.113526] init: Starting service 'keystore'...
 [   28.121386] init: Starting service 'mediacodec'...
 [   28.125026] init: Starting service 'mediadrm'...
 [   28.130230] init: Starting service 'mediaextractor'...
 [   28.136504] init: Starting service 'netd'...
 [   28.148010] random: nonblocking pool is initialized
 [   28.174167] init: Starting service 'crashlogd'...
 [   28.176240] init: Starting service 'log-watch'...
 [   28.180606] init: Starting service 'gatekeeperd'...
 [   28.202351] init: Starting service 'perfprofd'...
 [   28.217467] init: Service 'drmservice' (pid 314) exited with status 0
 [   28.231108] read descriptors
 [   28.231159] read descriptors
 [   28.231168] read strings
 [   28.234740] akmd[315]: unhandled level 1 translation fault (11) at 0x00000000, esr 0x92000005 		//应用层非法使用
 [   28.234780] pgd = ffffffc0e8190000
 [   28.234787] [00000000] *pgd=0000000000000000, *pud=0000000000000000
 [   28.234800]
 [   28.234811] CPU: 2 PID: 315 Comm: akmd Not tainted 4.4.103 #1185
 [   28.234818] Hardware name: Rockchip RK3399 Evaluation Board v3 (Android) (DT)
 [   28.234827] task: ffffffc0e8220000 task.stack: ffffffc0e8210000
 [   28.234837] PC is at 0x799b4f47d8
 [   28.234843] LR is at 0x65478a7720
 [   28.234850] pc : [<000000799b4f47d8>] lr : [<00000065478a7720>] pstate: 60000000
 [   28.234857] sp : 0000007fc03adce0
 [   28.234862] x29: 0000007fc03adcf0 x28: 0000000000000000
 [   28.234873] x27: 0000007fc03add58 x26: e30d94d4d4dd6983
 [   28.234884] x25: 0000000000000000 x24: 0000000000000000
 [   28.234895] x23: 0000000000000000 x22: 0000007fc03ae688
 [   28.234906] x21: 00000065478a6e84 x20: 00000065478b4000
 [   28.234917] x19: 0000000000000000 x18: 0000000000000000
 [   28.234927] x17: 000000799b4f47c8 x16: 00000065478b3fe0
 [   28.234939] x15: 00001f0ffc89c449 x14: 000b532cf2c194a5
 [   28.234949] x13: 0000000050f90ce1 x12: 0000000000000018
 [   28.234960] x11: 0000000000000009 x10: 0000007fc03ad790
 [   28.234971] x9 : 0000000000000010 x8 : 0000000000000000
 [   28.234981] x7 : 0000000000000c7c x6 : 000000799b63d000
 [   28.234992] x5 : 0000800000000000 x4 : 000000000000004d
 [   28.235002] x3 : 0000000000000003 x2 : 0000000000000005
 [   28.235013] x1 : 0000007fc03ad600 x0 : 0000000000000000
 [   28.235023]
 [   28.257851] init: Service 'akmd' (pid 315) killed by signal 11
 [   28.451338] Freeing drm_logo memory: 660K
 [   31.193137] capability: warning: `main' uses 32-bit capabilities (legacy support in use)
 [   38.191997] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   39.993352] android_work: did not send uevent (0 0           (null))
 [   39.993466] configfs-gadget gadget: unbind function 'mtp'/ffffffc0ef13b400
 [   39.993530] configfs-gadget gadget: unbind function 'Function FS Gadget'/ffffffc0e71a6e38
 [   39.994133] init: Service 'adbd' is being killed...
 [   39.998168] init: Service 'adbd' (pid 242) killed by signal 9
 [   39.998282] init: Service 'adbd' (pid 242) killing any children in process group
 [   40.043397] init: Starting service 'adbd'...
 [   40.058164] read descriptors
 [   40.058330] read descriptors
 [   40.058361] read strings
 [   40.097118] acc_open
 [   40.097299] acc_release
 [   40.507346] rk_gmac-dwmac fe300000.ethernet: rk_get_eth_addr: mac address: 22:9a:18:a4:eb:d9
 [   40.507445] eth0: device MAC address 22:9a:18:a4:eb:d9
 [   42.019341] type=1400 audit(1358499055.096:9): avc: denied { read } for pid=320 comm="AudioOut_D" name="audioformat" dev="sysfs" ino=19012 scontext=u:r:audioserver:s1
 [   42.019794] type=1400 audit(1358499055.096:10): avc: denied { open } for pid=320 comm="AudioOut_D" path="/sys/devices/platform/display-subsystem/drm/card0/card0-HDMI1
 [   42.020004] type=1400 audit(1358499055.096:11): avc: denied { getattr } for pid=320 comm="AudioOut_D" path="/sys/devices/platform/display-subsystem/drm/card0/card0-H1
 [   42.605903] init: Service 'bootanim' is being killed... 		//ANDROID动画结束
 [   42.636539] init: cannot find '/system/bin/glgps' (No such file or directory), disabling 'gpsd'
 [   42.636879] init: Starting service 'exec 6 (/system/bin/bootstat)'...
 [   42.646035] init: Service 'bootanim' (pid 292) killed by signal 9
 [   42.655098] init: Service 'exec 6 (/system/bin/bootstat)' (pid 1062) exited with status 0
 [   42.656133] init: Starting service 'exec 7 (/system/bin/bootstat)'...
 [   42.671000] init: Service 'exec 7 (/system/bin/bootstat)' (pid 1065) exited with status 0
 [   42.671989] init: Starting service 'exec 8 (/system/bin/bootstat)'...
 [   42.688309] init: Service 'exec 8 (/system/bin/bootstat)' (pid 1066) exited with status 0
 [   42.689272] init: Starting service 'exec 9 (/system/bin/bootstat)'...
 [   42.731200] init: Service 'exec 9 (/system/bin/bootstat)' (pid 1067) exited with status 0 		//ANDROID动画结束
 [   53.838543] dw-mipi-dsi ff960000.dsi: vop BIG output to dsi0
 [   53.838705] dw-mipi-dsi ff960000.dsi: final DSI-Link bandwidth: 1064 x 4 Mbps
 [   53.849049] dw-mipi-dsi ff960000.dsi: failed to wait for phy lock state
 [   53.977794] PM: suspend entry 2013-01-18 08:51:07.058334719 UTC //待机启动标志
 [   53.977892] PM: Syncing filesystems ... done.
 [   54.025426] Freezing user space processes ... (elapsed 0.005 seconds) done.
 [   54.031296] Freezing remaining freezable tasks ... (elapsed 0.003 seconds) done.
 [   54.035404] Suspending console(s) (use no_console_suspend to debug)
 INFO:    sleep mode config[0xfe]:
 INFO:           AP_PWROFF
 INFO:           SLP_ARMPD
 INFO:           SLP_PLLPD
 INFO:           DDR_RET
 INFO:           SLP_CENTER_PD
 INFO:           OSC_DIS
 INFO:    wakeup source config[0x4]:
 INFO:           GPIO interrupt can wakeup system
 INFO:    PWM CONFIG[0x4]:
 INFO:           PWM: PWM2D_REGULATOR_EN
 INFO:    APIOS info[0x0]:
 INFO:           not config
 INFO:    GPIO POWER INFO:
 INFO:           GPIO1_C1
 INFO:    PMU_MODE_CONG: 0x1477bf79
 INFO:    RK3399 the wake up information:
 INFO:    wake up status: 0x4
 INFO:           GPIO interrupt wakeup
 INFO:           GPIO0: 0x0
 INFO:           GPIO1: 0x200000
 INFO:           GPIO2: 0x0
 INFO:           GPIO3: 0x0
 �[   54.241088] [WLAN_RFKILL]: Enter rfkill_wlan_suspend
 [   54.242183] PM: suspend of devices complete after 205.187 msecs
 [   54.254053] PM: late suspend of devices complete after 2.598 msecs
 [   54.256545] PM: noirq suspend of devices complete after 2.475 msecs
 [   54.256553] Disabling non-boot CPUs ...
 [   54.277766] CPU1: shutdown
 [   54.290360] psci: Retrying again to check for CPU kill
 [   54.290365] psci: CPU1 killed.
 [   54.344261] CPU2: shutdown
 [   54.357035] psci: Retrying again to check for CPU kill
 [   54.357039] psci: CPU2 killed.
 [   54.397515] CPU3: shutdown
 [   54.410365] psci: Retrying again to check for CPU kill
 [   54.410369] psci: CPU3 killed.
 [   54.444054] CPU4: shutdown
 [   54.457014] psci: Retrying again to check for CPU kill
 [   54.457018] psci: CPU4 killed.
 [   54.490618] CPU5: shutdown
 [   54.503682] psci: Retrying again to check for CPU kill
 [   54.503686] psci: CPU5 killed.
 [   54.516595] Enabling non-boot CPUs ...
 [   54.534909] Detected VIPT I-cache on CPU1
 [   54.534949] CPU1: found redistributor 1 region 0:0x00000000fef20000
 [   54.535017] CPU1: update cpu_capacity 401
 [   54.535021] CPU1: Booted secondary processor [410fd034]
 [   54.535706] CPU1 is up
 [   54.554700] Detected VIPT I-cache on CPU2
 [   54.554723] CPU2: found redistributor 2 region 0:0x00000000fef40000
 [   54.554761] CPU2: update cpu_capacity 401
 [   54.554764] CPU2: Booted secondary processor [410fd034]
 [   54.555426] CPU2 is up
 [   54.574932] Detected VIPT I-cache on CPU3
 [   54.574955] CPU3: found redistributor 3 region 0:0x00000000fef60000
 [   54.574994] CPU3: update cpu_capacity 401
 [   54.574998] CPU3: Booted secondary processor [410fd034]
 [   54.575801] CPU3 is up
 [   54.595191] Detected PIPT I-cache on CPU4
 [   54.595220] CPU4: found redistributor 100 region 0:0x00000000fef80000
 [   54.595280] CPU4: update cpu_capacity 1024
 [   54.595283] CPU4: Booted secondary processor [410fd082]
 [   54.598647] CPU4 is up
 [   54.622231] Detected PIPT I-cache on CPU5
 [   54.622249] CPU5: found redistributor 101 region 0:0x00000000fefa0000
 [   54.622289] CPU5: update cpu_capacity 1024
 [   54.622292] CPU5: Booted secondary processor [410fd082]
 [   54.625630] CPU5 is up
 [   54.627806] PM: noirq resume of devices complete after 2.017 msecs
 [   54.631002] PM: early resume of devices complete after 2.605 msecs
 [   54.637408] rk_gmac-dwmac fe300000.ethernet: init for RGMII
 [   54.716006] [WLAN_RFKILL]: Enter rfkill_wlan_resume
 [   54.721769] Suspended for 33.201 seconds
 [   54.722040] cdn-dp fec00000.dp: [drm:cdn_dp_pd_event_work] Not connected. Disabling cdn
 [   54.724641] usb usb1: root hub lost power or was reset
 [   54.726843] usb usb2: root hub lost power or was reset
 [   54.784794] usb usb3: root hub lost power or was reset
 [   54.841509] usb usb4: root hub lost power or was reset
 [   54.853801] mmc_host mmc2: Bus speed (slot 0) = 400000Hz (slot req 400000Hz, actual 400000HZ div = 0)
 [   54.912694] mmc2: queuing unknown CIS tuple 0x80 (2 bytes)
 [   54.914290] mmc2: queuing unknown CIS tuple 0x80 (3 bytes)
 [   54.915875] mmc2: queuing unknown CIS tuple 0x80 (3 bytes)
 [   54.918719] mmc2: queuing unknown CIS tuple 0x80 (7 bytes)
 [   54.975663] mmc_host mmc2: Bus speed (slot 0) = 150000000Hz (slot req 150000000Hz, actual 150000000HZ div = 0)
 [   55.104118] dwmmc_rockchip fe310000.dwmmc: Successfully tuned phase to 205
 [   55.104173] PM: resume of devices complete after 472.044 msecs
 [   55.105538] [BT_RFKILL]: ** disable irq
 [   55.109774] Restarting tasks ...
 [   55.125869] healthd: battery l=50 v=3 t=2.6 h=2 st=3 fc=100 chg=au
 [   55.151813] done.
 [   55.156142] PM: suspend exit 2013-01-18 08:51:41.437918253 UTC
 [   55.207785] binder: release 1350:1365 transaction 18865 in, still active
 [   55.207869] binder: send failed reply for transaction 18865 to 603:677
 [   55.307869] PM: suspend entry 2013-01-18 08:51:41.589653268 UTC
 [   55.307941] PM: Syncing filesystems ... done.
 [   55.319202] Freezing user space processes ... (elapsed 0.002 seconds) done.
 [   55.322026] Freezing remaining freezable tasks ... (elapsed 0.002 seconds) done.
 [   55.324154] Suspending console(s) (use no_console_suspend to debug)
```
