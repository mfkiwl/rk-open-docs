# RK3308 开发汇总

发布版本：1.0

日期：2018.12

作者邮箱：

文件密级：内部资料

**修订记录**

| **日期**    | **版本** | **作者** | **修改说明**         |
| --------- | ------ | ------ | ---------------- |
| 2018.10.14 | V1.0   | 闫孝军  | 初始版本 |

[TOC]

## SOC Features

RK3308 CPU 为四核 A35。带VAD和其他丰富的音频接口，无GPU。SOC目前有4个变种。

| SOC     | Features                                                     |
| ------- | ------------------------------------------------------------ |
| RK3308  | 初始版本                                                     |
| RK3308G | 在RK3308的基础上合封64M DDR2                                 |
| RK3308B | 在RK3308的基础上增加更加灵活的IO复用，比如GMAC和LCDC高位分开，PWM增加到12路 |
| RK3308H | 在RK3308B的基础上合封64M DDR2                                |

以上4个变种还有对应的宽温版本，后缀加K。宽温版本主要是封装上做了增强，其他逻辑不变。

RK3308/RK3308G 与 RK3308B/RK3308H 可以通过GRF_CHIP_ID 区分：

RK3308/RK3308G: 0xcea (3306)

RK3308B/RK3308H: 0x3308

其他更进一步的区分通过OTP。

## AArch32 模式

为了满足64M小容量内存的需求，我们开发了32位的运行模式，具体实现方式为：在Trust 跳转到 U-Boot的时候将CPU从AArch64 切换到 AArch32 模式，之后U-Boot、Linux kernel、userspace都运行于AArch32模式。

## 频率电压

CPU最高运行频率为1296MHZ。

DDR运行频率为：393MHZ、451MHZ、589MHZ，主要考虑避开wifi 2.4G频段。DDR不变频。

ARM/LOGIC 分离供电。

## DS-5 连接

目前RK3308 所有的开发板 上都没有带JTAG接口，需要外接，而且不同的板子，连接方式不同：

RK3308-EVB-V10/V11/V12 通过扩展板接JTAG：

![](RK3308-Notes\RK3308-EVB-V10.jpg)

RK3308B-EVB-V10要通过板子右边预留过孔飞线，使用的时候要请硬件确认，因为还涉及到和其他复用跳线的情况。

![](RK3308-Notes\RK3308B-EVB-V10.jpg)

## 开发过程中遇到的问题

### 1、CPU Qos 优先级过高导致EMMC 读写超时

**现象**：

在运行memtest的时候同时做文件拷贝读写，内核hung timeout

通过如下stressapptest命令也很容易测到异常：

```c
while true; do stressapptest -f /data/1 -f /data/2 -f /data/3 -f /data/4; done
```

```c

38 copy /data/cfg/rockchip_test/flash_test/src_test_data to /data/cfg/rockchip_test/flash_test/des_test_data/4
38 clean /data/cfg/rockchip_test/flash_test/des_test_data/4 success
38 4 start copy data
38 cp  /data/cfg/rockchip_test/flash_test/src_test_data to /data/cfg/rockchip_test/flash_test/des_test_data/4 success
[  720.104706] INFO: task sync:1834 blocked for more than 120 seconds.
[  720.104788]       Not tainted 4.4.126 #1
[  720.104821] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  720.104858] sync            D ffffff8008084dfc     0  1834    391 0x00000008
[  720.104920] Call trace:
[  720.104968] [<ffffff8008084dfc>] __switch_to+0x84/0xa0
[  720.105017] [<ffffff8008581c90>] __schedule+0x428/0x45c
[  720.105053] [<ffffff8008581d38>] schedule+0x74/0x94
[  720.105091] [<ffffff8008584244>] schedule_timeout+0x28/0x178
[  720.105128] [<ffffff8008581830>] io_schedule_timeout+0x68/0xa0
[  720.105168] [<ffffff80085824c8>] bit_wait_io+0x18/0x60
[  720.105207] [<ffffff8008582194>] __wait_on_bit+0x6c/0xb8
[  720.105245] [<ffffff800810b0e4>] wait_on_page_bit+0x64/0x6c
[  720.105279] [<ffffff800810b1e8>] __filemap_fdatawait_range+0xa8/0x108
[  720.105320] [<ffffff800810d36c>] filemap_fdatawait_keep_errors+0x20/0x2c
[  720.105362] [<ffffff80081600bc>] sync_inodes_sb+0x160/0x174
[  720.105403] [<ffffff800816420c>] sync_inodes_one_sb+0x14/0x20
[  720.105442] [<ffffff80081401bc>] iterate_supers+0xb8/0xe0
[  720.105482] [<ffffff8008164518>] sys_sync+0x38/0x90
[  720.105519] [<ffffff8008082ef0>] el0_svc_naked+0x24/0x28
[  720.105657] Kernel panic - not syncing: hung_task: blocked tasks
[  720.114840] CPU: 0 PID: 30 Comm: khungtaskd Not tainted 4.4.126 #1
[  720.115401] Hardware name: Rockchip RK3308 evb digital-i2s mic board (DT)
```

```
<3>[ 4800.114806] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
<6>[ 4800.114828] kworker/u8:2    D ffffff8008084dfc     0   411      2 0x00000000
<6>[ 4800.115094] Workqueue: writeback wb_workfn (flush-179:0)
<4>[ 4800.115148] Call trace:
<4>[ 4800.115227] [<ffffff8008084dfc>] __switch_to+0x84/0xa0
<4>[ 4800.115341] [<ffffff8008581c90>] __schedule+0x428/0x45c
<4>[ 4800.115443] [<ffffff8008581d38>] schedule+0x74/0x94
<4>[ 4800.115494] [<ffffff8008584244>] schedule_timeout+0x28/0x178
<4>[ 4800.115547] [<ffffff8008581830>] io_schedule_timeout+0x68/0xa0
<4>[ 4800.115610] [<ffffff80081ce700>] get_request+0x1c8/0x400
<4>[ 4800.115659] [<ffffff80081d0c30>] blk_queue_bio+0x70/0x258
<4>[ 4800.115683] [<ffffff80081cf1c0>] generic_make_request+0xbc/0x1d8
<4>[ 4800.115713] [<ffffff80081cf31c>] submit_bio+0x40/0x168
<4>[ 4800.115783] [<ffffff800816f214>] mpage_bio_submit+0x30/0x40
<4>[ 4800.115810] [<ffffff800816ff88>] __mpage_writepage+0x4c8/0x514
<4>[ 4800.115886] [<ffffff8008113a44>] write_cache_pages+0x22c/0x2c8
<4>[ 4800.115906] [<ffffff800816f9fc>] mpage_writepages+0x7c/0xa0
<4>[ 4800.115976] [<ffffff800819dff0>] ext2_writepages+0x14/0x1c
<4>[ 4800.116018] [<ffffff8008114db0>] do_writepages+0x24/0x3c
<4>[ 4800.116042] [<ffffff80081603b4>] __writeback_single_inode+0x38/0x168
<4>[ 4800.116061] [<ffffff8008160688>] writeback_sb_inodes+0x1a4/0x32c
<4>[ 4800.116086] [<ffffff8008160890>] __writeback_inodes_wb+0x80/0xc4
<4>[ 4800.116109] [<ffffff8008160b08>] wb_writeback+0x194/0x198
<4>[ 4800.116130] [<ffffff8008160f58>] wb_workfn+0x134/0x234
<4>[ 4800.116200] [<ffffff80080abbac>] process_one_work+0x1b0/0x294
<4>[ 4800.116226] [<ffffff80080ac904>] worker_thread+0x2d8/0x398
<4>[ 4800.116266] [<ffffff80080b0f04>] kthread+0xc8/0xd8
<4>[ 4800.116298] [<ffffff8008082e80>] ret_from_fork+0x10/0x50
<0>[ 4800.116343] Kernel panic - not syncing: hung_task: blocked tasks
<4>[ 4800.129690] CPU: 0 PID: 30 Comm: khungtaskd Not tainted 4.4.126 #1
<4>[ 4800.130261] Hardware name: Rockchip RK3308 evb digital-i2s mic board (DT)
```

**处理：**

查阅TRM发现，RK3308 默认CPU Qos优先级位2，一般普通外设优先级位1、比CPU低。在DDR初始化阶段把CPU Qos优先级设置为1，其他外设Qos 优先级设置为2、问题解决。

### 2、Soft Reset方案选择

Glb_srstn_1 resets almost all logic

Glb_srstn_2 resets almost all logic except GRF and GPIOs

理论上一般希望Reset尽可能干净彻底，但是RK3308 在应用中会使用GPIO做电源的power hold控制，Soft reset的时候希望这个状态能保持，所以RK3308使用Glb_srstn_2.

RK3308B做了改进，在Glb_srstn_1的情况下，提供了GRF_SOC_CON14可以独立控制在reset的时候不reset GPIO和PWM。所以RK3308B使用Glb_srstn_1.

### 3、VCCIO3 电源域控制

电源域VCCIO3控制着eMMC/NAND FLASH/SFC的工作电压、根据外部颗粒的不同，有的工作电压为3.3V、有的为1.8V。系统上电，默认情况下，这几个控制器通过采集GPIO0_A4的电压来判断供电模式，GPIO0_A4这时候处于输入模式，高电平标示该电源域位1.8V供电，低电平标示该电源域位3.3V供电。

系统启动，软件可以介入控制后，可以通过配置GRF_SOC_CON0的io_vsel3位来控制VCCIO3的电源域，将GPIO0_A4解放出来，用作其他用途。再配置io_vsel3之前，不能切GPIO0_A4, 否则存储模块工作会异常。

### 4、PWM regulator pin脚在Glb_srstn_2 模式下的下拉设置

在低温reboot拷机的过程中，部分机器表现不稳定，在内核随机崩溃。最后发现把调制ARM core电压的pwm pin脚设置为下拉状态，问题解决。

```
commit 7e0f993c89113500144f8b68ed96dd160f37487e
Author: David Wu <david.wu@rock-chips.com>
Date:   Fri May 4 17:30:14 2018 +0800

    dts: rockchip: Set pwm pin pull down when used for negative pwm regulator

    As a second global reset, the GRF is not reset, the iomux and
    pull of PWM pin is still keeping, but PWM controller is reset,
    PWM pin goes into input mode. However, the pull is still none
    changed in kernel, which can cause voltage problems, so should
    always keep the PWM pin pull down mode, with 0~50 μA power
    increase.

    Change-Id: Ibbb9465f7c550d49d416bc3438c5199434df6eba
    Signed-off-by: David Wu <david.wu@rock-chips.com>
diff --git a/arch/arm64/boot/dts/rockchip/rk3308-evb-v10.dtsi b/arch/arm64/boot/dts/rockchip/rk3308-evb-v10.dtsi
index 5882595bb7dd..c86ac1ce8b37 100644
--- a/arch/arm64/boot/dts/rockchip/rk3308-evb-v10.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3308-evb-v10.dtsi
@@ -707,6 +707,8 @@

 &pwm0 {
        status = "okay";
+       pinctrl-names = "active";
+       pinctrl-0 = <&pwm0_pin_pull_down>;
 };
```

主要原因是：在硬件设计上，该pwm regulator是负极性的（既低电平时间越长，调制出的电压越高）。在系统采用Second soft reset的时候，pwm控制器会被复位，而且pwm管脚会被复位到输入状态，但是Second soft reset不会复位控制IOMUX的GRF寄存器，即这时候管脚还保持在pwm输入状态，如果不设置为下拉模式，得到的电压会偏低。
