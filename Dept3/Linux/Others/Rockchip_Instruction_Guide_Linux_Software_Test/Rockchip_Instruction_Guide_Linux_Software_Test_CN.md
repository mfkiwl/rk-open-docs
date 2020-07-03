# Rockchip Linux 系统测试操作指南

文档标识：RK-SM-YF-352

发布版本：V1.1.1

日期：2020-03-30

文件密级：□绝密   □秘密   □内部资料   ■公开

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有** **© 2020** **福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

---

## **前言**

**概述**

文档主要介绍 Rockchip Linux SDK 系统软件测试。旨在帮助工程师更快上手系统测试及开发中的相关调试方法。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**各芯片系统支持状态**

| **芯片名称**    | **Buildroot** | **Debian 9** | **Debian 10** | **Yocto** |
| ----------- | :-------------- | :------------- | :---------- | :---------- |
| PX30 | Y               | Y              | Y          | Y           |
| RK3326 | Y               | Y              | Y          | Y           |
| RK3288 | Y               | Y              | Y          | Y           |
| RK3399 | Y               | Y              | Y          | Y           |
| RK3399Pro | Y               | Y              | Y          | Y           |

 **修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| -----------| :-------------- | :------------- | :---------- |
| 2017-01-15 | V1.0.0 | 陈清	| 初始版本 |
| 2020-03-24 | V1.1.0 | 陈清	| 更新测试项 |
| 2020-03-30 | V1.1.1 | 王晓腾	| 修改格式 |

## **目录**

---
[TOC]
---

## 功能测试

### Buildroot

#### 图层下移恢复

当设备触屏无效，串口内可以输入时定为图层下移，可以用如下指令恢复：

```shell
/etc/init.d/S50launcher stop （先关闭lanucher）
/etc/init.d/S50launcher start （再开启lanucher）
```

#### 后台应用删除

例：删除后台音频
查找在播放的音频

```shell
ps | grep audio
[root@rk3399pro:/]# ps | grep audio
  569 root      557m S    /usr/bin/audioservice
 1248 root      2412 S    grep audio
```

删除后台音频播放 kill 569

#### 录像

录像：

```shell
rkisp_demo --device=/dev/video1 --output=/tmp/isp.yuv --iqfile=/etc/iqfiles/OV5695.xml
```

播放录像：
将/tmp/cif.yuv下的文件pull到电脑端： adb pull /tmp/cif.yuv /tmp/cif.yuv，通过 YUVPlayer.exe 工具播放。
YUVPlayer.exe 工具播放 YUV 录像文件时的设置如下：

![camera](resources/camera.png)

#### 录音

arecord -c 通道 -r 采样频率 –f 采样位数 –d 录音时长 /录音存放路径/录音文件名。
通道 ch_tbl="2 4 6 8"
采样频率 fs_tbl="8000 11025 16000 22050 32000 44100 48000 64000 88200 96000 176400 192000"
采样位数bits_tbl="S16_LE S24_LE S32_LE"
封装格式=”wmv、wav、mp3 等”
例：

**限时录音-录音10秒自动退出并保存**

```shell
arecord -c 2 -r 44100 -f S16_LE –d 10 /tmp/record.wav
```

**不限时录音-ctrl+c退出即可保存**

```shell
arecord -c 2 -r 44100 -f S16_LE /tmp/record.wav
```

**播放录音文件**

```shell
aplay /tmp/record.wav
```

#### WI-FI 连接

**方法1**

```shell
cp data/cfg/wpa_supplicant.conf userdata/
vi /userdata/cfg/wpa_supplicant.conf
```

添加如下配置项

```
network={
ssid="WiFi-AP" // WiFi 名字
psk="12345678" // WiFi 密码
key_mgmt=WPA-PSK // 加密方式
key_mgmt=NONE // 不加密
}

```

重新读取上述配置:wpa_cli reconfigure
并重新连接:wpa_cli reconnect
ping baidu.com

**方法2**

```
./usr/sbin/wpa_supplicant -D nl80211 -i wlan0 -c /etc/wpa_supplicant.conf &  #打开wifi
wpa_cli -i wlan0 add_network  #添加一个网络连接ID号，这里的ID号在第3-6步的时候用到
wpa_cli -i wlan0 set_network 0 ssid \"pzb\"    #添加要连接的路由器SSID，如：pzb
wpa_cli -iwlan0 set_network 0 psk \"123456789\"    #添加要连接的ap密码，如：123456789
wpa_cli -iwlan0 enable_network 0   #这里的0是根据第2步得来的，使该网络ID可以使用
wpa_cli -iwlan0 select_network 0  #这里的0是根据第2步得来的，连接该ID
wpa_cli -iwlan0 set_network 0 psk \""   （无密码）
ifconfig 以及ping baidu.com    #能获取正常ip地址以及能ping通就代表可以上网
```

#### 音频播放

```shell
aplay /media/usb0/musicdemo.wmv
```

#### 系统时间查看/设置

```shell
date  （查看系统时间）
date --set='2018-12-24 15:17:42'   （设置系统时间）
hwclock --show  （查看硬件时间）
hwclock --systohc  （硬件时间同步显示系统时间）
```

#### RTC 时钟测试

cat /路径/time 查看当前状态下或重启后时间是否有变化
如：
RK3399 挖掘机 EVB：

```shell
cat /sys/devices/platform/ff3c0000.i2c/i2c-0/0-001b/rk808-rtc/rtc/rtc0/time
```

PX30 EVB：

```shell
cat /sys/devices/platform/ff3c0000.i2c/i2c-0/0-001b/rk808-rtc/rtc/rtc0/time
```

RK3399Pro EVB：

```shell
cat /sys/devices/platform/ff3c0000.i2c/i2c-0/0-0020/rk808-rtc/rtc/rtc0/time
```

不同平台对应的time所在节点路径不同，可以通过find ./ -name time 来查找以上类似节点。

![RTC](resources/RTC.png)

#### 屏幕旋转问题

在/etc/xdg/weston/weston.ini 配置文件中写入：

```ini
[output]
name=eDP-1
transform=90
```

其中name需要根据实际的情况写入，通过 ls /sys/class/drm 获取：

```shell
[root@rk3399:/]# ls /sys/class/drm/
card0 card0-HDMI-A-1  controlD64    version card0-DP-1     card0-eDP-1    renderD128
```

比如这里用的drm设备是card0-eDP-1， 那么name="eDP-1"。

#### 视频播放

**单窗口视频播放**

```shell
gst-play-1.0 /oem/SampleVideo_1280x720_5mb.mp4
```

**多窗口视频播放**

先找着多窗口的脚本再执行，
cd rockchip_test/video/
sh test_gst_multivideo.sh test  (pro,有可能名称不是这个，可能是test_multivideo.sh )

**停止多窗口**

```shell
killall videowidget
etc/init.d/S50launcher stop
etc/init.d/S50launcher start
```

#### SD 卡升级、启动

- SD 卡插入 PC 端，在 PC 端执行SD_Firmware_Tool.exe，选择固件升级/SD启动，选择固件-update.img，开始创建。
- 将 SDK 进入maskrom擦除flash后，断电。
- 插入制作好的 SD 卡，将 SDK 上电开机，会自动烧写固件。

![sd_update](resources/sd_update.png)

#### 查找文件

```shell
find ./ -name \*.sh
```

#### 查内存

```shell
cat /proc/meminfo或 free –h
```

![mem](resources/mem.png)

#### 查磁盘空间使用情况

df -h：

![df-h](resources/df-h.png)

#### U盘/SD卡自动挂载默认路径

U盘：/media/usb0/
SD卡：/sdcard/

#### 文件拷贝

从U盘拷贝文件至机器

```shell
cp -r /media/usb0/3399-linux/ /userdata
```

### Debian

#### 禁止待机

在Debian终端上输入命令：

```shell
sudo xset –dpms
sudo xset s off
xset dpms force off (立即关闭屏幕)
```

备注：重启样机后，以上设置就失效
终端位置：主界面左下角开始-> System Tools -> LXTerminal

#### 连接 WI-FI

在串口输入如下命令：

```shell
1. 开启WI-FI：nmcli r wifi on
2. 扫描附近AP：nmcli dev wifi
3. 连接AP：nmcli dev wifi connect "DIR-803" password "839919060" ifname wlan0
4. 关闭WI-FI：nmcli r wifi off
```

#### 双屏异显

使用 hdmi-toggle 来确定有几个显示设备，比如下面可以检测到 HDMI-1 和 DP-1 两个设备：

![hdmi-toggle](resources/hdmi-toggle.png)

xrandr 来设置两个屏幕的关系：

```shell
su linaro-c "DISPLAY=:0xrandr--outputHDMI-1--aboveDP-1" 其中--above
```

其中 --above 可以代换成 right-of, left-of,below,same-as,preferred,off 等等
这样就可以完成双屏异显的功能。

#### 双屏异声

打开左下角的 Sound&Video---->PulseAudio Volume Control，然后选择歌曲播放，使用哪个声卡播放可以参考如下选择：

![Volume_Control](resources/Volume_Control.png)

也可以使用 aplay 来确认声卡和选择声卡播放：

 aplay-l

![aplay-l](resources/aplay-l.png)

```shell
rt5640: aplay-Dplughw:0,0/dev/urandom
hdmiaudio: aplay-Dplughw:1,0/dev/urandom
DPaudio: aplay-Dplughw:2,0/dev/urandom
```

打开一个音乐歌曲从主屏拖到副屏，然后在主屏中同样方式选择一个声卡来播放，完成双屏异声功能。

#### 显示屏旋转

旋转 normal/left/right

```shell
vi /etc/X11/xorg.conf.d/20-modesetting.conf
```

可以把normal改为left/right/，reboot后生效。

#### U盘自动挂载默认路径

/media/linaro/B4EA-8716
备注：不同U盘名称不同,实际名称为准。

## 性能测试

### 磁盘读写测试

测试前先查一下节点：fdisk –l
查看分区可读写的是mmcblk1p9,这个分区容量最大13.5G,其它P1-8的容量比较小，P8的容量3.5G ,在此盘读写后易造成系统损坏，重启机器发现无法开机,所以选择p9。

#### e读写

写磁盘：

```shell
dd if=/dev/zero of=/dev/mmcblk1p9 bs=1M count=2000 oflag=direct,nonblock
```

读磁盘：

```shell
dd if=/dev/mmcblk1p9 of=/dev/null bs=1M count=2000 iflag=direct,nonblock
```

#### U盘读写

写磁盘：

```shell
dd if=/dev/zero of=/dev/sda1 bs=1M count=2000 oflag=direct,nonblock
```

读磁盘：

```shell
dd if=/dev/sda1 of=/dev/null bs=1M count=2000 iflag=direct,nonblock

```

### 设置性能模式

方法1：

```shell
echo performance | tee $(find /sys/ -name *governor)
```

方法2：

分别设置小核和大核：

```shell
echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo performance > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor
```

### 查看当前CPU频率

```shell
cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq
cat /sys/devices/system/cpu/cpufreq/policy4/scaling_cur_freq
```

### glmark2 跑分

**Buildroot glmark2**

显示屏幕跑分：

```shell
sh /rockchip_test/gpu/test_glmark2_fullscreen.sh
```

屏幕不显示跑分：

```shell
sh /rockchip_test/gpu/test_glmark2_offscreen.sh
```

**Debian glmark2**

显示屏幕跑分：

```shell
cd /usr/local/bin/
sh test_glmark2_fullscreen.sh
```

屏幕不显示跑分：

```shell
cd /usr/local/bin/
sh test_glmark2_offscreen.sh
```

## 压力测试

压力测试列表

![linux_rockchip_test](resources/linux_rockchip_test.png)

### glmark2

**Buildroot**

压力测试表下的脚本无法循环拷机，用指令测试：

```shell
while true; do /rockchip_test/gpu/test_glmark2_fullscreen.sh sleep 2; done
```

**Debian**

```shell
while true; do /usr/local/bin/test_glmark2_fullscreen.sh sleep 2; done
```

### reboot test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）

开始测试
压力测试列表内选择测试项对应序号10

退出测试

```shell
echo off > /data/cfg/rockchip_test/reboot_cnt
```

### recovery test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）

开始测试：
压力测试列表内选择测试项对应序号6

退出测试：

```shell
echo off > /oem/rockchip_test/reboot_cnt
```

### memtester test

方法1
sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号1
再选择memtester test对应序号（默认memtester 128M）

方法2
直接执行 memtester 300M
注：300MB 是可以根据实际的 DDR 大小设置，例如：100MB、200MB，但是这个值不能大于 DDR 的大小。

### stressapptest

方法1：

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号1
再选择 stressapptest 对应序号（默认48小时）。

方法2：

```shell
stressapptest -s 86400 -i 4 -C 4 -W --stop_on_errors -M 300 （测试24小时自动停止）
```

### cpufreq test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号2
再选择 cpu freq stress test 以及 cpu freq test:(with out stress test) 对应序号。

### flash stress test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号3。

### bluetooth test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号4。

### suspend_resume test

**Buildroot**

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号7
再选择auto suspend (resume by rtc) 对应序号3开始测试。

**Debian**

cd /usr/local/bin/
sh test_suspend_resume.sh
再选择auto suspend (resume by rtc) 对应序号3开始测试。

### WI-FI test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号8

### ddr freq scaling test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号11

### npu stress test

SDK 端串口连接到 NPU 端口：

![pro_npu_debug](resources/pro_npu_debug.png)

```shell
stressapptest -s 86400 -i 4 -C 4 -W --stop_on_errors -M 300 （测试24小时自动停止）。
```

### camera test

sh rockchip_test/rockchip_test.sh（打开压力测试列表）
压力测试列表内选择测试项对应序号13
再选择camera stresstest 对应序号3开始测试。

### video test

播放放器无法设备循环所有视频播放，用脚本执行。
先把全英文视频文件的视频文件夹及脚本拷入设备内，再执行脚本测试：

```shell
cp -r /media/usb0/video /userdata
cp /media/usb0/video.sh /userdata
chmod 777 /userdata/video.sh
./video.sh
```
