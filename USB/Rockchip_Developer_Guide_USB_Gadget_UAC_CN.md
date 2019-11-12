# **Rockchip USB Gadget UAC**

发布版本：1.1

作者邮箱：wulf@rock-chips.com

日期：2019-11-11

文档密级：公开资料

------
**概述**

本文档提供 Rockchip 平台基于 Linux 内核的 USB Gadget UAC（USB Audio Class）驱动的使用方法。Rockchip 平台可以支持 UAC1（兼容 USB Audio Class specification 1.0）和 UAC2（兼容 USB Audio Class specification 2.0）驱动，并且，这两个驱动都可以支持基础的录音和放音功能。此外，Rockchip 平台还提供了 UAC1 Legacy （需要实际的声卡支持，只支持放音功能）和 Audio Source（只支持录音功能，但可以支持多达 15 种不同的采样率）。开发人员可以根据产品的实际需求来选择合适的 UAC 驱动。

如果要支持音量调节/静音功能，需要添加 HID 的控制，目前发布的 SDK 还没有支持。开发人员可以参考如下的文档，进行 HID 功能的开发。

Kernel/Documentation/usb/gadget-testing.txt （参考 6. HID function）

Kernel/Documentation/ABI/testing/configfs-usb-gadget-hid

[Universal Serial Bus Audio Device Class Specification for Basic Audio Devices](https://usb.org/document-library/audio-device-class-spec-basic-audio-devices-v10-and-adopters-agreement) （参考 8 HID Support in Basic Audio Devices）

**产品版本**

| **芯片名称**                                                 | **内核版本**          |
| ------------------------------------------------------------ | --------------------- |
| RK3399、RK3368、RK3366、RK3328、RK3288、RK312X、RK3188、RK30XX、RK3308、RK3326、PX30 | Linux-4.4、Linux-4.19 |

**读者对象**
本文档（本指南）主要适用于以下工程师：

软件工程师

技术支持工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**                 |
| ---------- | -------- | -------- | ---------------------------- |
| 2019-03-13 | V1.0     | 吴良峰   | 初始版本                     |
| 2019-11-11 | V1.1     | 吴良峰   | 修改文档名称，支持Linux-4.19 |

------
[TOC]
------

## 1 Kernel UAC CONFIG

### 1.1 Related Kernel Commits

如果要正常使用 Kernel-4.4 的 UAC1/UAC2 的功能，需要先确认所使用的内核已经包含如下的系列补丁，如果未找到补丁，请提交问题到 Rockchip Redmine 平台，或者发邮件给本文档的作者。

请参考补丁简报：

[1] [Kernel 4.4 支持USB Gadget UAC1/UAC2 录音和放音功能](https://redmine.rockchip.com.cn/issues/198281)

问题描述:
Kernel-4.4 的 USB Gadget UAC1/UAC2 驱动存在如下的问题:

- UAC1 只支持放音功能，并且需要实际声卡配合使用
- UAC2 无法兼容 Windows，虽然可以支持录音和放音，但是功能不完善

补丁列表：

```
5e962a0 usb: gadget: f_uac2: fix some issues for Windows recognized
14e0a40 UPSTREAM: usb: gadget: f_uac2: disable IN/OUT ep if unused
a90af74 UPSTREAM: usb: gadget: u_audio: protect stream runtime fields with stream spinlock
7335245 UPSTREAM: usb: gadget: u_audio: remove cached period bytes value
deb045e UPSTREAM: usb: gadget: u_audio: remove caching of stream buffer parameters
6ec0a4d UPSTREAM: usb: gadget: u_audio: update hw_ptr in iso_complete after data copied
f81ce6a UPSTREAM: usb: gadget: u_audio: fix pcm/card naming in g_audio_setup()
bbd7715 UPSTREAM: usb: gadget: f_uac2: fix error handling in afunc_bind (again)
1adbd21 UPSTREAM: usb: gadget: make snd_pcm_hardware const
de6e281 UPSTREAM: usb: gadget: f_uac2: constify snd_pcm_ops structures
0106bd0 UPSTREAM: usb: gadget: f_uac2: endianness fixes.
98492ac UPSTREAM: usb: gadget: f_uac1: endianness fixes.
45e29d4 UPSTREAM: usb: gadget: add f_uac1 variant based on a new u_audio api
55f51fc UPSTREAM: usb: gadget: function: make current f_uac1 implementation legacy
ef10d9e UPSTREAM: usb: gadget: f_uac2: split out audio core
dc16803 UPSTREAM: usb: gadget: f_uac2: remove platform driver/device creation
7d1ddce UPSTREAM: usb: gadget: f_uac2: calculate wMaxPacketSize before endpoint match
4f76843 UPSTREAM: usb: gadget: uac2: add req_number as parameter
2b9c1a8 UPSTREAM: usb: gadget: f_uac2: improve error handling
70f4537 UPSTREAM: usb: gadget: uac2: Drop unused device qualifier descriptor
```

[2] [解决Kernel USB Gadget UAC1拔插无法识别的问题](https://redmine.rockchip.com.cn/issues/198516)

问题描述:

USB Gadget UAC1 连接到 PC，实现 USB 声卡播放音乐的功能。在放音开始的任意过程中，拔出 USB 线，再重新插入，会大概率出现 PC 无法重新识别 USB UAC1 设备的问题。

补丁列表:

```
cafb671 UPSTREAM: usb: dwc2: gadget: Disable enabled HW endpoint in dwc2_hsotg_ep_disable
9b54359 UPSTREAM: usb: dwc2: gadget: Correct dwc2_hsotg_ep_stop_xfr() function
```

### 1.2 Related CONFIGs

CONFIG_USB_CONFIGFS_F_UAC1 (enable UAC1 Function )

CONFIG_USB_CONFIGFS_F_UAC2 (enable UAC2 Function )

CONFIG_USB_CONFIGFS_F_UAC1_LEGACY (enable UAC1 Legacy Function )

CONFIG_USB_CONFIGFS_F_ACC （Audio Source depends on it）

CONFIG_USB_CONFIGFS_F_AUDIO_SRC (enable Audio Source Function)

### 1.3 Related Documents

- Documentation/usb/gadget_configfs.txt
- Documentation/usb/gadget-testing.txt
- Documentation/ABI/testing/configfs-usb-gadget-uac1
- Documentation/ABI/testing/configfs-usb-gadget-uac1_legacy
- Documentation/ABI/testing/configfs-usb-gadget-uac2

## 2 UAC1 Usage and Test

### 2.1 UAC1 Usage

**USB Audio Class 1 standard (1998)**

- This standard allows for 24 bits/96 kHz max.

- The standard itself doesn't impose any limitation on sample rate.

  Class 1 is tied to USB 1 Full Speed = 12 MHz

- Every millisecond a package is send.
  Maximum package size is 1024 bytes.
  2 channel x 24 bit x 96000 Hz sample rate= 4608000 bits/s or 576 Byte/ms
  This fits in the 1024 byte limit.
  Any higher popular sample rate e.g. 176 kHz needs 1056 bytes so in excess of the maximum
  package size.

- All operating systems (Win, OSX, and Linux) support USB Audio Class 1 natively.
  This means you don’t need to install drivers, it is plug&play.
  All support 2 channel audio with 24 bit words and 96 kHz sample rate

参考 [The Well-Tempered Computer (An introduction to computer audio) - USB](http://www.thewelltemperedcomputer.com/KB/USB.html)

**Note：**

*USB Audio 1.0 Specification 在 USB 2.0 core Specification 之前完成，因此 USB Audio 1.0 Specification 没有高速模式(High Speed)这一概念。可以通过一些经验规则使得 Audio 1.0 兼容设备在特定的操作系统上实现高速模式。比如修改 isochronous endpoint descriptor 的 **bInterval=4**。目前尚没有详尽的经验规则保证在所有的操作系统上都能正常工作在高速模式下。*

Rockchip 平台 UAC1 驱动支持 USB Audio Class specification 1.0，支持录音和放音，并且**不需要实际的声卡**。

UAC1 驱动设置 bInterval=4。

默认支持：

速率：High Speed

采样率：playback 和 capture 都为 48 KHz，可以通过内核提供的接口配置为其他采样率

声道数：playback 和 capture 都为 2 Channels，最多支持双声道，可以通过内核提供的接口配置为单声道

位深度：playback 和 capture 都为 16 bits

**UAC1 使用方法如下：**

添加 CONFIG_USB_CONFIGFS_F_UAC1=y 到内核的 defconfig

以 3308 EVB 为例

配置 UAC1 的脚本参考如下：

```shell
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/rockchip  -m 0770
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
mkdir /sys/kernel/config/usb_gadget/rockchip/strings/0x409   -m 0770
echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "USB Audio Device"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1  -m 0770
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409  -m 0770
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
echo "uac1" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac1.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/uac1.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/uac1.gs0
echo ff400000.usb > /sys/kernel/config/usb_gadget/rockchip/UDC
```

假如 3308 开机后，默认运行了 ADB 配置脚本，会导致上述的配置方法出错，在调试阶段，可以手动执行如下命令来配置 UAC1 功能。最终产品的 USB 配置脚本，需要根据实际的需求来整合 ADB 和 UAC1 的配置脚本。

```shell
rm -rf /sys/kernel/config/usb_gadget/rockchip/configs/b.1/ffs.adb

mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac1.gs0
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
echo "USB Audio Device" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
echo "uac1" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
cd /sys/kernel/config/usb_gadget/rockchip/configs/b.1
ln -s ../../functions/uac1.gs0

echo ff400000.usb > ../../UDC
```

**Note：**

*“idProduct ” 可以根据产品自行定义，但不能与产品的其他 USB Function idProduct 冲突*

*“UDC” 为 USB 控制器名称，对应 /sys/class/udc/控制器名称*

*Windows 会对设备驱动记忆，更改配置后最好卸载驱动，让 Windows 重新识别设备*

配置脚本执行成功后，连接 USB 到 PC，PC 端可以识别到 USB Audio 设备，如下图 2-1 Windows-USB-Audio-Class1，图 2-2 Ubuntu-USB-Audio-Class1-Output 和图 2-3 Ubuntu-USB-Audio-Class1-Input。

![Windows-USB-Audio-Class1](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-USB-Audio-Class1.png)

图 2-1 Windows-USB-Audio-Class1

![Ubuntu-USB-Audio-Class1-Output](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-USB-Audio-Output.png)

图 2-2 Ubuntu-USB-Audio-Class1-Output

![Ubuntu-USB-Audio-Class1-Input](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-USB-Audio-Input.png)

图 2-3 Ubuntu-USB-Audio-Class1-Input

3308 端的串口打印如下 USB UAC1 正常枚举的日志：

```
dwc2 ff400000.usb: new device is high-speed
dwc2 ff400000.usb: new address 19
android_work: sent uevent USB_STATE=CONNECTED
configfs-gadget gadget: high-speed config #1: b
android_work: sent uevent USB_STATE=CONFIGURED
```

UAC1 驱动提供如下的配置接口：

如下**配置无法动态生效**，也即必须添加在 UAC 的配置脚本中执行。

```shell
# ls -lh /sys/kernel/config/usb_gadget/rockchip/functions/uac1.gs0
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 c_chmask
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 c_srate
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 c_ssize
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 p_chmask
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 p_srate
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 p_ssize
-rw-r--r--    1 root     root        4.0K Dec 31 19:11 req_number

c_chmask - capture channel mask 默认设置为 3
c_srate - capture sampling rate 默认设置为 48000
c_ssize - capture sample size (bytes) 默认设置为 2
p_chmask - playback channel mask 默认设置为 3
p_srate - playback sampling rate 默认设置为 48000
p_ssize - playback sample size (bytes) 默认设置为 2
req_number - the number of pre-allocated request for both capture and playback
默认设置为 2
```

查看 UAC1 声卡信息的方法：

如下显示的结果，UAC1 对应 card2 （UAC1Gadget），具有一个 playback 设备节点 - pcmC2D0p 和一个 capture 设备节点 - pcmC2D0c。

```shell
# cat /proc/asound/cards
 0 [rockchiprk3308v]: rockchip_rk3308 - rockchip,rk3308-vad
                      rockchip,rk3308-vad
 1 [rockchiprk3308p]: rockchip_rk3308 - rockchip,rk3308-pcm
                      rockchip,rk3308-pcm
 2 [UAC1Gadget     ]: UAC1_Gadget - UAC1_Gadget
                      UAC1_Gadget 0
 7 [Loopback       ]: Loopback - Loopback
                      Loopback 1

# ls -lh /proc/asound/card2
-r--r--r--    1 root     root           0 Dec 31 19:14 id
dr-xr-xr-x    3 root     root           0 Dec 31 19:14 pcm0c
dr-xr-xr-x    3 root     root           0 Dec 31 19:14 pcm0p

# ls /dev/snd/
controlC0  controlC7  pcmC1D0c   pcmC2D0p   pcmC7D1c
controlC1  pcmC0D0c   pcmC1D0p   pcmC7D0c   pcmC7D1p
controlC2  pcmC0D0p   pcmC2D0c   pcmC7D0p   timer
```

### 2.2 UAC1 Test

#### 2.2.1 UAC1 Test on Windows

打开 Windows 声音设置，如下图 2-4 Windows-Audio-Setting，分别选择 USB-Audio 作为声音输出设备和声音输入设备（麦克风）。

![Windows-Audio-Setting](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-Audio-Setting.png)

图 2-4 Windows-Audio-Setting

**测试 Windows UAC1 放音功能：**

在 3308 端的串口执行如下的 UAC1 放音命令：

```shell
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 | aplay -f dat -r 48000 -c 2 -D hw:0,0
```

上述命令表示从 Card2（USB Audio）录音，然后从本地声卡 Card0 播放声音

执行完命令后，Windows PC 端播放音乐，3308 本地声卡可以实时放音。

**测试 Windows UAC1 录音功能：**

测试录音功能，需要使用可以播放的音频文件。通过 ADB push 或者 arecord 的方法，保存测试使用的音频文件（要求 48KHz，2 channels，16 bits）

比如，3308 端的串口执行 arecord 命令，保存测试使用的音频文件 test.wav

```
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 /tmp/test.wav
```

保存音频文件 test.wav 成功后，再执行如下的 UAC1 录音命令：

```
aplay /tmp/test.wav -c 2 -r 48000 -D hw:2,0
```

执行完上述命令后，PC 端可以使用 Windows 自带的 “Voice Recorder”软件保存录音文件，如下图 2-5 Windows-Voice-Recorder。

![Windows-Voice-Recorder](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-Voice-Recorder.png)

图 2-5 Windows-Voice-Recorder

除了上述的录音测试方法，也可以使用 Windows 的录音侦听功能，实时播放录音的音频，方法如下：

打开“声音设置” --> “声音控制面板” --> "录制" --> “属性” --> "侦听" ，勾选“侦听此设备”，并选择播放的扬声器。

如下图 2-6 Windows-Capture-Listen-1 和图 2-7 Windows-Capture-Listen-2。

![Windows-Capture-Listen-1](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-Capture-Listen-1.png)

图 2-6 Windows-Capture-Listen-1

![Windows-Capture-Listen-2](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-Capture-Listen-2.png)

图 2-7 Windows-Capture-Listen-2

#### 2.2.2 UAC1 Test on Ubuntu

打开 Ubuntu 声音设置，如下图 2-8 Ubuntu-Audio-Setting-Output 和图 2-9 Ubuntu-Audio-Setting-Input，分别选择 USB-Audio 作为声音输出设备和声音输入设备（麦克风）。

![Ubuntu-Audio-Setting-Output](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-Audio-Setting-Output.png)

图 2-8 Ubuntu-Audio-Setting-Output

![Ubuntu-Audio-Setting-Input](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-Audio-Setting-Input.png)

图 2-9 Ubuntu-Audio-Setting-Input

**测试 Ubuntu UAC1 放音功能：**

在 3308 端的串口执行如下的 UAC1 放音命令：

```shell
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 | aplay -f dat -r 48000 -c 2 -D hw:0,0
```

上述命令表示从 Card2（USB Audio）录音，然后从本地声卡 Card0 播放声音

执行完命令后，Ubuntu PC 端播放音乐，3308 本地声卡可以实时放音。

**测试 Ubuntu UAC1 录音功能：**

测试录音功能，需要使用可以播放的音频文件。通过 ADB push 或者 arecord 的方法，保存测试使用的音频文件（要求 48KHz，2 channels，16 bits）

比如，3308 端的串口执行 arecord 命令，保存测试使用的音频文件 test.wav

```
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 /tmp/test.wav
```

保存音频文件 test.wav 成功后，再执行如下的 UAC1 录音命令：

```
aplay /tmp/test.wav -c 2 -r 48000 -D hw:2,0
```

执行完上述命令后，在 Ubuntu 端打开录音软件，如“audacity”，进行录音功能测试。

audacity 安装命令：

```shell
sudo apt install audacity
```

audacity 录音界面如下图 2-10 所示。

![Ubuntu-audacity](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-audacity.png)

图 2-10 Ubuntu-audacity

## 3 UAC2 Usage and Test

### 3.1 UAC2 Usage

**USB Audio Class 2 standard (2009)**

- USB Audio Class 2 additionally supports 32 bit and all common sample rates > 96 kHz
  Class 2 uses High Speed (480 MHz). This requires USB 2 or 3.
  As the data rate of High Speed is 40 X Full speed, recording a 60 channel using 24 bits at 96 kHz  (132 Mbit/s) is not a problem.

- Using High Speed USB for playback  there are no limits in resolution.

- It is downwards compatible with class 1.

- From mid-2010 on USB audio class 2 drivers are available in OSX 10.6.4 and Linux.
  Both support sample rates up to 384 kHz.

- Microsoft simply didn’t support UAC2.

  In April 2017, an update of Win10 finally brought native mode drivers.

  If you use older versions of Win, you still need a third party driver.

**Note：**

*从 Windows 10（1703 版）开始，Windows 才默认支持 UAC 2.0 驱动程序。*

*Windows 和 Linux 对音频事件的响应流程稍有不同，要做兼容性处理，Linux 和 Android 一样。*

*Windows 会对设备驱动记忆，更改配置后最好卸载驱动，让 Windows 重新识别设备*

Rockchip 平台 UAC2 驱动支持 USB Audio Class specification 2.0，支持录音和放音，并且**不需要实际的声卡**。

默认支持：

速率：High Speed

采样率：playback 为 48K Hz， capture 为 64 KHz，可以通过内核提供的接口配置为其他采样率

声道数：playback 和 capture 都为 2 Channels，最多支持双声道，可以通过内核提供的接口配置为单声道

位深度：playback 和 capture 都为 16 bits

**UAC2 使用方法如下：**

添加 CONFIG_USB_CONFIGFS_F_UAC2=y 到内核的 defconfig

以 3308 EVB 为例

配置 UAC2 的脚本参考如下：

```shell
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/rockchip  -m 0770
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0200 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
mkdir /sys/kernel/config/usb_gadget/rockchip/strings/0x409   -m 0770
echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "USB Audio Device"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1  -m 0770
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409  -m 0770
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
echo "uac2" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac2.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/uac2.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/uac2.gs0
echo ff400000.usb > /sys/kernel/config/usb_gadget/rockchip/UDC
```

假如 3308 开机后，默认运行了 ADB 配置脚本，会导致上述的配置方法出错，在调试阶段，可以手动执行如下命令来配置 UAC2 功能。最终产品的 USB 配置脚本，需要根据实际的需求来整合 ADB 和 UAC2 的配置脚本。

```shell
rm -rf /sys/kernel/config/usb_gadget/rockchip/configs/b.1/ffs.adb

mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac2.gs0
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0200 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
echo "USB Audio Device" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
echo "uac2" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
cd /sys/kernel/config/usb_gadget/rockchip/configs/b.1
ln -s ../../functions/uac2.gs0

echo ff400000.usb > ../../UDC
```

**Note：**

*“idProduct ” 可以根据产品自行定义，但不能与产品的其他 USB Function idProduct 冲突*

*“UDC” 为 USB 控制器名称，对应 /sys/class/udc/控制器名称*

*Windows 会对设备驱动记忆，更改配置后最好卸载驱动，让 Windows 重新识别设备*

配置脚本执行成功后，连接 USB 到 PC，PC 端可以识别到 USB Audio 设备，如下图 3-1 Windows-USB-Audio-Class2，图 3-2 Ubuntu-USB-Audio-Class2-Output 和图 3-3 Ubuntu-USB-Audio-Class2-Input。

![Windows-USB-Audio-Class2](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-USB-Audio-Class2.png)

图 3-1 Windows-USB-Audio-Class2

![Ubuntu-USB-Audio-Class2-Output](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-USB-Audio-Output.png)

图 3-2 Ubuntu-USB-Audio-Class2-Output

![Ubuntu-USB-Audio-Class2-Input](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-USB-Audio-Input.png)

图 3-3 Ubuntu-USB-Audio-Class2-Input

3308 端的串口打印如下 USB UAC2 正常枚举的日志：

```
dwc2 ff400000.usb: new device is high-speed
dwc2 ff400000.usb: new address 21
android_work: sent uevent USB_STATE=CONNECTED
configfs-gadget gadget: high-speed config #1: b
android_work: sent uevent USB_STATE=CONFIGURED
```

UAC2 驱动提供如下的配置接口：

如下**配置无法动态生效**，也即必须添加在 UAC 的配置脚本中执行。

比如，配置 c_srate 为 48KHz 的命令为：

echo 48000 > /sys/kernel/config/usb_gadget/rockchip/functions/uac2.gs0/c_srate

```shell
# ls -lh /sys/kernel/config/usb_gadget/rockchip/functions/uac2.gs0
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 c_chmask
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 c_srate
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 c_ssize
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 p_chmask
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 p_srate
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 p_ssize
-rw-r--r--    1 root     root        4.0K Dec 31 19:01 req_number

c_chmask - capture channel mask 默认设置为 3
c_srate - capture sampling rate 默认设置为 64000
c_ssize - capture sample size (bytes) 默认设置为 2
p_chmask - playback channel mask 默认设置为 3
p_srate - playback sampling rate 默认设置为 48000
p_ssize - playback sample size (bytes) 默认设置为 2
req_number - the number of pre-allocated request for both capture and playback
默认设置为 2
```

查看 UAC2 声卡信息的方法：

如下显示的结果，UAC2 对应 card2 （UAC2Gadget），具有一个 playback 设备节点 - pcmC2D0p 和一个 capture 设备节点 - pcmC2D0c。

```shell
# cat /proc/asound/cards
 0 [rockchiprk3308v]: rockchip_rk3308 - rockchip,rk3308-vad
                      rockchip,rk3308-vad
 1 [rockchiprk3308p]: rockchip_rk3308 - rockchip,rk3308-pcm
                      rockchip,rk3308-pcm
 2 [UAC2Gadget     ]: UAC2_Gadget - UAC2_Gadget
                      UAC2_Gadget 0
 7 [Loopback       ]: Loopback - Loopback
                      Loopback 1

# ls -lh /proc/asound/card2
-r--r--r--    1 root     root           0 Dec 31 19:04 id
dr-xr-xr-x    3 root     root           0 Dec 31 19:04 pcm0c
dr-xr-xr-x    3 root     root           0 Dec 31 19:04 pcm0p

# ls /dev/snd/
controlC0  controlC7  pcmC1D0c   pcmC2D0p   pcmC7D1c
controlC1  pcmC0D0c   pcmC1D0p   pcmC7D0c   pcmC7D1p
controlC2  pcmC0D0p   pcmC2D0c   pcmC7D0p   timer
```

### 3.2 UAC2 Test

#### 3.2.1 UAC2 Test on Windows

Windows PC 端的设置请参考[2.2.1 UAC1 Test on Windows](#2.2.1 UAC1 Test on Windows)

**测试 Windows UAC2 放音功能：**

在 3308 端的串口执行如下的 UAC2 放音命令：

```shell
arecord -f dat -t wav -r 64000 -c 2 -D hw:2,0 | aplay -f dat -r 64000 -c 2 -D hw:0,0
```

上述命令表示从 Card2（USB Audio）录音，然后从本地声卡 Card0 播放声音，采样率为 64KHz（默认）。

如果通过 UAC1 驱动提供的内核接口，配置采样率为 48KHz，则放音命令为：

```shell
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 | aplay -f dat -r 48000 -c 2 -D hw:0,0
```

执行完命令后，Windows PC 端播放音乐，3308 本地声卡可以实时放音。

**测试 Windows UAC2 录音功能：**

测试录音功能，需要使用可以播放的音频文件。通过 ADB push 或者 arecord 的方法，保存测试使用的音频文件（要求 48KHz，2 channels，16 bits）

比如，3308 端的串口执行 arecord 命令，保存测试使用的音频文件 test.wav

（以录音和放音的采样率都为 48KHz 的配置为例）

```
arecord -f dat -t wav -r 48000 -c 2 -D hw:2,0 /tmp/test.wav
```

保存音频文件 test.wav 成功后，再执行如下的 UAC1 录音命令：

```
aplay /tmp/test.wav -c 2 -r 48000 -D hw:2,0
```

执行完上述命令后，PC 端可以使用 Windows 自带的 “Voice Recorder”软件保存录音文件，使用方法参考[2.2.1 UAC1 Test on Windows](#2.2.1 UAC1 Test on Windows)

#### 3.2.2 UAC2 Test on Ubuntu

Ubuntu PC 端的设置请参考[2.2.2 UAC1 Test on Ubuntu](#2.2.2 UAC1 Test on Ubuntu)

Ubuntu PC 环境下， 3308 端的 UAC2 录音和放音测试命令，请直接参考[3.2.1 UAC2 Test on Windows](#3.2.1 UAC2 Test on Windows)

## 4 UAC1 Legacy Usage and Test

### 4.1 UAC1 Legacy Usage

Rockchip 平台 UAC1 Legacy 驱动兼容 USB Audio Class specification 1.0，但只支持放音功能，并且**需要实际的声卡支持（默认使用 /dev/snd/pcmC0D0p）**。

默认支持：

速率：High Speed

采样率：playback 48 KHz，不可配置

声道数：playback 2 Channels，不可配置

位深度：playback 16 bits

**UAC1 Legacy 使用方法如下：**

添加 CONFIG_USB_CONFIGFS_F_UAC1_LEGACY=y  到内核的 defconfig

以 3308 EVB 为例

配置 UAC1 Legacy 的脚本参考如下：

```shell
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/rockchip  -m 0770
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
mkdir /sys/kernel/config/usb_gadget/rockchip/strings/0x409   -m 0770
echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "USB Audio Device"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1  -m 0770
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409  -m 0770
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
echo "uac1" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac1_legacy.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/uac1_legacy.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/uac1_legacy.gs0
echo ff400000.usb > /sys/kernel/config/usb_gadget/rockchip/UDC
```

假如 3308 开机后，默认运行了 ADB 配置脚本，会导致上述的配置方法出错，在调试阶段，可以手动执行如下命令来配置  UAC1 Legacy 功能。最终产品的 USB 配置脚本，需要根据实际的需求来整合 ADB 和 UAC1 Legacy 的配置脚本。

```shell
rm -rf /sys/kernel/config/usb_gadget/rockchip/configs/b.1/ffs.adb

mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac1_legacy.gs0
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
echo "USB Audio Device" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
echo "uac1" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
cd /sys/kernel/config/usb_gadget/rockchip/configs/b.1
ln -s ../../functions/uac1_legacy.gs0

echo ff400000.usb > ../../UDC
```

**Note：**

*“idProduct ” 可以根据产品自行定义，但不能与产品的其他 USB Function idProduct 冲突*

*“UDC” 为 USB 控制器名称，对应 /sys/class/udc/控制器名称*

*Windows 会对设备驱动记忆，更改配置后最好卸载驱动，让 Windows 重新识别设备*

配置脚本执行成功后，连接 USB 到 PC，PC 端可以识别到 USB Audio 设备，如图 4-1

![Windows-USB-Audio-Class1-Legacy](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-USB-Audio-Class1-Legacy.png)

图 4-1 Windows-USB-Audio-Class1-Legacy

3308 端的串口打印如下 USB UAC1 Legacy 正常枚举的日志：

```
configfs-gadget gadget: Hardware params: access 3, format 2, channels 2, rate 48000
dwc2 ff400000.usb: bound driver configfs-gadget
dwc2 ff400000.usb: new device is high-speed
dwc2 ff400000.usb: new address 25
android_work: sent uevent USB_STATE=CONNECTED
configfs-gadget gadget: high-speed config #1: b
android_work: sent uevent USB_STATE=CONFIGURED
```

UAC1 Legacy 驱动提供如下的配置接口：

如下**配置无法动态生效**，也即必须添加在 UAC 的配置脚本中执行。

```shell
# ls -lh /sys/kernel/config/usb_gadget/g1/functions/uac1_legacy.gs0/
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 audio_buf_size
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 fn_cap
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 fn_cntl
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 fn_play
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 req_buf_size
-rw-r--r--    1 root     root        4.0K Dec 31 19:08 req_count

audio_buf_size - audio buffer size 默认设置为 48000
fn_cap - capture pcm device file name 默认设置为 /dev/snd/pcmC0D0c
fn_cntl - control device file name 默认设置为 /dev/snd/controlC0
fn_play - playback pcm device file name 默认设置为 /dev/snd/pcmC0D0p
req_buf_size - ISO OUT endpoint request buffer size 默认设置为 200
req_count - ISO OUT endpoint request count 默认设置为 256
```

UAC1 Legacy 不会在 3308 端创建对应的声卡设备节点。

### 4.2 UAC1 Legacy Test

Windows PC 端的放音设置请参考 [2.2.1 UAC1 Test on Windows](#2.2.1 UAC1 Test on Windows)

Ubuntu PC 端的放音设置请参考 [2.2.2 UAC1 Test on Ubuntu](#2.2.2 UAC1 Test on Ubuntu)

3308 端不需要执行任何命令，连接 USB 到 PC 后，UAC1 Legacy 驱动默认会打开 3308 本地 Card0 声卡播放声音。

## 5 Audio Source Usage and Test

### 5.1  Audio Source Usage

Rockchip 平台 Audio Source 驱动兼容 USB Audio Class specification 1.0，但只支持录音功能。

默认支持：

速率：High Speed

采样率：playback 默认使用 44.1KHz，总共支持如下 15 种不同的采样率，PC 端可以动态配置

```
8000, 11025, 16000, 22050, 24000,
32000, 40000, 44100, 48000, 56000,
64000, 72000, 80000, 88200, 96000,
```

声道数：playback 2 Channels，不可配置

位深度：playback 16 bits

**Audio Source 使用方法如下：**

添加 CONFIG_USB_CONFIGFS_F_ACC=y（Audio Source depends on it）到内核的 defconfig

添加 CONFIG_USB_CONFIGFS_F_AUDIO_SRC=y  到内核的 defconfig

以 3308 EVB 为例

配置 Audio Source 的脚本参考如下：

```shell
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/rockchip  -m 0770
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
mkdir /sys/kernel/config/usb_gadget/rockchip/strings/0x409   -m 0770
echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "USB Audio Device"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1  -m 0770
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409  -m 0770
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
echo "audio" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/audio_source.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/audio_source.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/audio_source.gs0
echo ff400000.usb > /sys/kernel/config/usb_gadget/rockchip/UDC
```

假如 3308 开机后，默认运行了 ADB 配置脚本，会导致上述的配置方法出错，在调试阶段，可以手动执行如下命令来配置  Audio Source 功能。最终产品的 USB 配置脚本，需要根据实际的需求来整合 ADB 和 Audio Source 的配置脚本。

```shell
rm -rf /sys/kernel/config/usb_gadget/rockchip/configs/b.1/ffs.adb

mkdir /sys/kernel/config/usb_gadget/rockchip/functions/audio_source.gs0
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
echo "USB Audio Device" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
echo "audio" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
cd /sys/kernel/config/usb_gadget/rockchip/configs/b.1
ln -s ../../functions/audio_source.gs0

echo ff400000.usb > ../../UDC
```

**Note：**

*“idProduct ” 可以根据产品自行定义，但不能与产品的其他 USB Function idProduct 冲突*

*“UDC” 为 USB 控制器名称，对应 /sys/class/udc/控制器名称*

*Windows 会对设备驱动记忆，更改配置后最好卸载驱动，让 Windows 重新识别设备*

配置脚本执行成功后，连接 USB 到 PC，PC 端可以识别到 USB Audio 设备，如下图 5-1 Windows-USB-Audio-Source 和图 5-2 Ubuntu-USB-Audio-Source

![Windows-USB-Audio-Source](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-USB-Audio-Source.png)

图 5-1 Windows-USB-Audio-Source

![Ubuntu-USB-Audio-Input](Rockchip-Developer-Guide-USB-Gadget-UAC\Ubuntu-USB-Audio-Input.png)

图 5-2 Ubuntu-USB-Audio-Source

3308 端的串口打印如下 USB Audio Source 正常枚举的日志：

```
dwc2 ff400000.usb: new device is high-speed
dwc2 ff400000.usb: new address 23
android_work: sent uevent USB_STATE=CONNECTED
configfs-gadget gadget: high-speed config #1: b
android_work: sent uevent USB_STATE=CONFIGURED
```

Audio Source 驱动没有提供可配置的内核接口。

查看 Audio Source 信息的方法：

如下显示的结果，Audio Source 对应 card2 （audiosource），只有一个 playback 设备节点 - pcmC2D0p。

```shell
# cat /proc/asound/cards
 0 [rockchiprk3308v]: rockchip_rk3308 - rockchip,rk3308-vad
                      rockchip,rk3308-vad
 1 [rockchiprk3308p]: rockchip_rk3308 - rockchip,rk3308-pcm
                      rockchip,rk3308-pcm
 2 [audiosource    ]: audio_source - audio_source
                      USB accessory audio source
 7 [Loopback       ]: Loopback - Loopback
                      Loopback 1

# ls -lh /proc/asound/card2
-r--r--r--    1 root     root           0 Dec 31 19:06 id
dr-xr-xr-x    3 root     root           0 Dec 31 19:06 pcm0p

# ls /dev/snd/
controlC0  controlC2  pcmC0D0c   pcmC1D0c   pcmC2D0p   pcmC7D0p   pcmC7D1p
controlC1  controlC7  pcmC0D0p   pcmC1D0p   pcmC7D0c   pcmC7D1c   timer
```

### 5.2  Audio Source Test

**测试 Audio Source 录音功能：**

Windows PC 端的录音设置请参考 [2.2.1 UAC1 Test on Windows](#2.2.1 UAC1 Test on Windows)

Ubuntu PC 端的录音设置请参考 [2.2.2 UAC1 Test on Ubuntu](#2.2.2 UAC1 Test on Ubuntu)

3308 端的测试命令（假设采样率使用默认的 44.1KHz）：

```shell
aplay /tmp/test.wav -r 44100 -c 2 -D hw:2,0
```

**Note：**

*测试使用的音频文件 test.wav 的采样率，应与录音的采样率一致，否则，测试时可能出现杂音或者无声音*

此外，因为 Audio Source 支持 15 种不同的采样率，所以 PC 端可以动态配置采样率，方法如下：

打开“声音设置” --> “声音控制面板” --> "录制" --> “属性” --> “高级”，选择对应的采样率。

如下图 5-3 所示。

![Windows-USB-Audio-Source-Setting](Rockchip-Developer-Guide-USB-Gadget-UAC\Windows-USB-Audio-Source-Setting.png)

图 5-3 Windows-USB-Audio-Source-Setting

## 6 UAC1 Legacy and Audio Source Composite Usage and Test

### 6.1 UAC1 Legacy and Audio Source Composite Usage

**UAC1 Legacy +  Audio Source 使用方法如下：**

UAC1 Legacy 和 Audio Source 可以组合为一个 USB 复合设备，支持录音和放音功能。

添加 CONFIG_USB_CONFIGFS_F_UAC1_LEGACY=y  到内核的 defconfig

添加 CONFIG_USB_CONFIGFS_F_ACC=y（Audio Source depends on it）到内核的 defconfig

添加 CONFIG_USB_CONFIGFS_F_AUDIO_SRC=y  到内核的 defconfig

此外，需要单独更新补丁“**support_uac1_legacy_and_audio_source.patch**”。

以 3308 EVB 为例

配置 UAC1 Legacy +  Audio Source  的脚本参考如下：

```shell
mount -t configfs none /sys/kernel/config
mkdir /sys/kernel/config/usb_gadget/rockchip  -m 0770
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0019 > /sys/kernel/config/usb_gadget/rockchip/idProduct
echo 0x0100 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
mkdir /sys/kernel/config/usb_gadget/rockchip/strings/0x409   -m 0770
echo "0123456789ABCDEF" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "USB Audio Device"  > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1  -m 0770
mkdir /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409  -m 0770
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
echo "uac1" > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/uac1_legacy.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/uac1_legacy.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/uac1_legacy.gs0
mkdir /sys/kernel/config/usb_gadget/rockchip/functions/audio_source.gs0
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/audio_source.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/audio_source.gs0
echo ff400000.usb > /sys/kernel/config/usb_gadget/rockchip/UDC
```

其他配置和调试方法，请参考 [4.1 UAC1 Legacy Usage](#4.1 UAC1 Legacy Usage) 和 [5.1  Audio Source Usage](#5.1  Audio Source Usage)

### 6.2 UAC1 Legacy and Audio Source Composite Test

请参考 [4.2 UAC1 Legacy Test](#4.2 UAC1 Legacy Test) 和 [5.2  Audio Source Test](#5.2  Audio Source Test)

## 7 Composite with ADB

当 UAC1 和 ADB 一起使用时，UAC1 必须放在前面。否则，可能会导致在 Windows 系统上，UAC 设备驱动无法识别的问题。

比如：UAC1，ADB 同时使用时，脚本的 link 顺序应该为：UAC1，ADB

```sh
ln -s /sys/kernel/config/usb_gadget/rockchip/functions/uac1.gs0 /sys/kernel/config/usb_gadget/rockchip/configs/b.1/uac1.gs0

ln -s /sys/kernel/config/usb_gadget/rockchip/functions/ffs.adb /sys/kernel/config/usb_gadget/rockchip/configs/b.1/ffs.adb
```

## 8 Reference Documentation

**USB Protocol (from USB Implementers Forum)**

- [Universal Serial Bus Specification, Revision 2.0](https://usb.org/document-library/usb-20-specification)

- [Universal Serial Bus Audio Device Class Specification for Basic Audio Devices](https://usb.org/document-library/audio-device-class-spec-basic-audio-devices-v10-and-adopters-agreement)

- [Universal Serial Bus Device Class Definition for Audio Devices, Release 1.0](https://usb.org/document-library/audio-device-document-10)

  [Universal Serial Bus Device Class Definition for Audio Devices, Release 2.0](https://usb.org/document-library/audio-devices-rev-20-and-adopters-agreement)

- [Universal Serial Bus Device Class Definition for Audio Data Formats(referred to in this document as
  USB Audio Data Formats)](https://usb.org/document-library/audio-data-formats-10)

- [Universal Serial Bus Device Class Definition for Terminal Types(referred to in this document as USB
  Audio Terminal Types)](https://usb.org/document-library/audio-terminal-types-10)

**Others**

- [The Well-Tempered Computer (An introduction to computer audio) - USB](http://www.thewelltemperedcomputer.com/KB/USB.html)
- [Windows USB Audio 2.0 Drivers](https://docs.microsoft.com/en-us/windows-hardware/drivers/audio/usb-2-0-audio-drivers)

## 9 Appendix A UAC1 Device Descriptor

```
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x2207
  idProduct          0x0019
  bcdDevice            1.00
  iManufacturer           1 rockchip
  iProduct                2 USB Audio Device
  iSerial                 3 0123456789ABCDEF
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength          174
    bNumInterfaces          3
    bConfigurationValue     1
    iConfiguration          4 audio
    bmAttributes         0x80
      (Bus Powered)
    MaxPower              500mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      1 Control Device
      bInterfaceProtocol      0
      iInterface              5 AC Interface
      AudioControl Interface Descriptor:
        bLength                10
        bDescriptorType        36
        bDescriptorSubtype      1 (HEADER)
        bcdADC               1.00
        wTotalLength           52
        bInCollection           2
        baInterfaceNr( 0)       1
        baInterfaceNr( 1)       2
      AudioControl Interface Descriptor:
        bLength                12
        bDescriptorType        36
        bDescriptorSubtype      2 (INPUT_TERMINAL)
        bTerminalID             1
        wTerminalType      0x0101 USB Streaming
        bAssocTerminal          0
        bNrChannels             2
        wChannelConfig     0x0003
          Left Front (L)
          Right Front (R)
        iChannelNames           7 Playback Channels
        iTerminal               6 Playback Input terminal
      AudioControl Interface Descriptor:
        bLength                 9
        bDescriptorType        36
        bDescriptorSubtype      3 (OUTPUT_TERMINAL)
        bTerminalID             2
        wTerminalType      0x0301 Speaker
        bAssocTerminal          0
        bSourceID               1
        iTerminal               8 Playback Output terminal
      AudioControl Interface Descriptor:
        bLength                12
        bDescriptorType        36
        bDescriptorSubtype      2 (INPUT_TERMINAL)
        bTerminalID             3
        wTerminalType      0x0201 Microphone
        bAssocTerminal          0
        bNrChannels             2
        wChannelConfig     0x0003
          Left Front (L)
          Right Front (R)
        iChannelNames          10 Capture Channels
        iTerminal               9 Capture Input terminal
      AudioControl Interface Descriptor:
        bLength                 9
        bDescriptorType        36
        bDescriptorSubtype      3 (OUTPUT_TERMINAL)
        bTerminalID             4
        wTerminalType      0x0101 USB Streaming
        bAssocTerminal          0
        bSourceID               3
        iTerminal              11 Capture Output terminal
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol      0
      iInterface             12 Playback Inactive
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       1
      bNumEndpoints           1
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol      0
      iInterface             13 Playback Active
      AudioStreaming Interface Descriptor:
        bLength                 7
        bDescriptorType        36
        bDescriptorSubtype      1 (AS_GENERAL)
        bTerminalLink           1
        bDelay                  1 frames
        wFormatTag              1 PCM
      AudioStreaming Interface Descriptor:
        bLength                11
        bDescriptorType        36
        bDescriptorSubtype      2 (FORMAT_TYPE)
        bFormatType             1 (FORMAT_TYPE_I)
        bNrChannels             2
        bSubframeSize           2
        bBitResolution         16
        bSamFreqType            1 Discrete
        tSamFreq[ 0]        48000
      Endpoint Descriptor:
        bLength                 9
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            9
          Transfer Type            Isochronous
          Synch Type               Adaptive
          Usage Type               Data
        wMaxPacketSize     0x00c8  1x 200 bytes
        bInterval               4
        bRefresh                0
        bSynchAddress           0
        AudioControl Endpoint Descriptor:
          bLength                 7
          bDescriptorType        37
          bDescriptorSubtype      1 (EP_GENERAL)
          bmAttributes         0x01
            Sampling Frequency
          bLockDelayUnits         1 Milliseconds
          wLockDelay              1 Milliseconds
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol      0
      iInterface             14 Capture Inactive
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       1
      bNumEndpoints           1
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol      0
      iInterface             15 Capture Active
      AudioStreaming Interface Descriptor:
        bLength                 7
        bDescriptorType        36
        bDescriptorSubtype      1 (AS_GENERAL)
        bTerminalLink           4
        bDelay                  1 frames
        wFormatTag              1 PCM
      AudioStreaming Interface Descriptor:
        bLength                11
        bDescriptorType        36
        bDescriptorSubtype      2 (FORMAT_TYPE)
        bFormatType             1 (FORMAT_TYPE_I)
        bNrChannels             2
        bSubframeSize           2
        bBitResolution         16
        bSamFreqType            1 Discrete
        tSamFreq[ 0]        48000
      Endpoint Descriptor:
        bLength                 9
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            5
          Transfer Type            Isochronous
          Synch Type               Asynchronous
          Usage Type               Data
        wMaxPacketSize     0x00c8  1x 200 bytes
        bInterval               4
        bRefresh                0
        bSynchAddress           0
        AudioControl Endpoint Descriptor:
          bLength                 7
          bDescriptorType        37
          bDescriptorSubtype      1 (EP_GENERAL)
          bmAttributes         0x01
            Sampling Frequency
          bLockDelayUnits         0 Undefined
          wLockDelay              0 Undefined
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0000
  (Bus Powered)
```

## 10 Appendix B UAC2 Device Descriptor

```
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  idVendor           0x2207
  idProduct          0x0019
  bcdDevice            2.00
  iManufacturer           1 rockchip
  iProduct                2 USB Audio Device
  iSerial                 3 0123456789ABCDEF
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength          219
    bNumInterfaces          3
    bConfigurationValue     1
    iConfiguration          4 audio
    bmAttributes         0x80
      (Bus Powered)
    MaxPower              500mA
    Interface Association:
      bLength                 8
      bDescriptorType        11
      bFirstInterface         0
      bInterfaceCount         3
      bFunctionClass          1 Audio
      bFunctionSubClass       0
      bFunctionProtocol      32
      iFunction               5 Source/Sink
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      1 Control Device
      bInterfaceProtocol     32
      iInterface              6 Topology Control
      AudioControl Interface Descriptor:
        bLength                 9
        bDescriptorType        36
        bDescriptorSubtype      1 (HEADER)
        bcdADC               2.00
        bCategory               8
        wTotalLength           83
        bmControl            0x00
      AudioControl Interface Descriptor:
        bLength                 8
        bDescriptorType        36
        bDescriptorSubtype     10 (CLOCK_SOURCE)
        bClockID                6
        bmAttributes         0x01 Internal fixed Clock
        bmControls           0x01
          Clock Frequency Control (read-only)
        bAssocTerminal          0
        iClockSource            7 48000Hz
      AudioControl Interface Descriptor:
        bLength                 8
        bDescriptorType        36
        bDescriptorSubtype     10 (CLOCK_SOURCE)
        bClockID                5
        bmAttributes         0x01 Internal fixed Clock
        bmControls           0x01
          Clock Frequency Control (read-only)
        bAssocTerminal          0
        iClockSource            8 64000Hz
      AudioControl Interface Descriptor:
        bLength                17
        bDescriptorType        36
        bDescriptorSubtype      2 (INPUT_TERMINAL)
        bTerminalID             1
        wTerminalType      0x0101 USB Streaming
        bAssocTerminal          0
        bCSourceID              5
        bNrChannels             2
        bmChannelConfig   0x00000003
          Front Left (FL)
          Front Right (FR)
        bmControls    0x0003
          Copy Protect Control (read/write)
        iChannelNames           0
        iTerminal               9 USBH Out
      AudioControl Interface Descriptor:
        bLength                17
        bDescriptorType        36
        bDescriptorSubtype      2 (INPUT_TERMINAL)
        bTerminalID             2
        wTerminalType      0x0201 Microphone
        bAssocTerminal          0
        bCSourceID              6
        bNrChannels             2
        bmChannelConfig   0x00000003
          Front Left (FL)
          Front Right (FR)
        bmControls    0x0003
          Copy Protect Control (read/write)
        iChannelNames           0
        iTerminal              10 USBD Out
      AudioControl Interface Descriptor:
        bLength                12
        bDescriptorType        36
        bDescriptorSubtype      3 (OUTPUT_TERMINAL)
        bTerminalID             4
        wTerminalType      0x0101 USB Streaming
        bAssocTerminal          0
        bSourceID               2
        bCSourceID              6
        bmControls         0x0003
          Copy Protect Control (read/write)
        iTerminal              11 USBH In
      AudioControl Interface Descriptor:
        bLength                12
        bDescriptorType        36
        bDescriptorSubtype      3 (OUTPUT_TERMINAL)
        bTerminalID             3
        wTerminalType      0x0301 Speaker
        bAssocTerminal          0
        bSourceID               1
        bCSourceID              5
        bmControls         0x0003
          Copy Protect Control (read/write)
        iTerminal              12 USBD In
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol     32
      iInterface             13 Playback Inactive
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        1
      bAlternateSetting       1
      bNumEndpoints           1
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol     32
      iInterface             14 Playback Active
      AudioStreaming Interface Descriptor:
        bLength                16
        bDescriptorType        36
        bDescriptorSubtype      1 (AS_GENERAL)
        bTerminalLink           1
        bmControls           0x00
        bFormatType             1
        bmFormats         0x00000001
          PCM
        bNrChannels             2
        bmChannelConfig   0x00000003
          Front Left (FL)
          Front Right (FR)
        iChannelNames           0
      AudioStreaming Interface Descriptor:
        bLength                 6
        bDescriptorType        36
        bDescriptorSubtype      2 (FORMAT_TYPE)
        bFormatType             1 (FORMAT_TYPE_I)
        bSubslotSize            2
        bBitResolution         16
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x02  EP 2 OUT
        bmAttributes            9
          Transfer Type            Isochronous
          Synch Type               Adaptive
          Usage Type               Data
        wMaxPacketSize     0x0100  1x 256 bytes
        bInterval               4
        AudioControl Endpoint Descriptor:
          bLength                 8
          bDescriptorType        37
          bDescriptorSubtype      1 (EP_GENERAL)
          bmAttributes         0x00
          bmControls           0x00
          bLockDelayUnits         0 Undefined
          wLockDelay              0
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       0
      bNumEndpoints           0
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol     32
      iInterface             15 Capture Inactive
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        2
      bAlternateSetting       1
      bNumEndpoints           1
      bInterfaceClass         1 Audio
      bInterfaceSubClass      2 Streaming
      bInterfaceProtocol     32
      iInterface             16 Capture Active
      AudioStreaming Interface Descriptor:
        bLength                16
        bDescriptorType        36
        bDescriptorSubtype      1 (AS_GENERAL)
        bTerminalLink           4
        bmControls           0x00
        bFormatType             1
        bmFormats         0x00000001
          PCM
        bNrChannels             2
        bmChannelConfig   0x00000003
          Front Left (FL)
          Front Right (FR)
        iChannelNames           0
      AudioStreaming Interface Descriptor:
        bLength                 6
        bDescriptorType        36
        bDescriptorSubtype      2 (FORMAT_TYPE)
        bFormatType             1 (FORMAT_TYPE_I)
        bSubslotSize            2
        bBitResolution         16
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes           13
          Transfer Type            Isochronous
          Synch Type               Synchronous
          Usage Type               Data
        wMaxPacketSize     0x00c0  1x 192 bytes
        bInterval               4
        AudioControl Endpoint Descriptor:
          bLength                 8
          bDescriptorType        37
          bDescriptorSubtype      1 (EP_GENERAL)
          bmAttributes         0x00
          bmControls           0x00
          bLockDelayUnits         0 Undefined
          wLockDelay              0
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass            0 (Defined at Interface level)
  bDeviceSubClass         0
  bDeviceProtocol         0
  bMaxPacketSize0        64
  bNumConfigurations      1
Device Status:     0x0000
  (Bus Powered)
```

