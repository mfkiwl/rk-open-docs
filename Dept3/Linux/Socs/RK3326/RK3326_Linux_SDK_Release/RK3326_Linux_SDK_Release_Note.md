# RK3326 Linux SDK Release Note

---

**Versions**

[TOC]

---
## rk3326_linux_release_v1.4.0_20201203.xml Release Note

**Buildroot (2018.02-rc3)**:

```
- Upgrade chromium to 86.0.4240.111
- Fix RGA blending error when global alpha too large
- qt5multimedia: Fix crash after finished playing
- Update weston to fix some bugs
```

**Debian (buster/10)**:

```
- Upgrade debian9 to debian10
```

**Yocto**:

```
- Upgrade Yocto from 3.0 to 3.2
```

**Kernel (4.4)**:

```
- Fix multivideo and wifi CVE issues
- Fix gsl3673 touch issue on standby
- Fix gcc9 stringop-truncation compilation error
```

**docs/tools**:

```
- Windows: RKDevTool: update V2.79 to support new loader format
- Linux: package-file: Drop out-dated :grow flag
- Upgrade Linux_Upgrade_Tool to V1.57
- Upgrade DriverAssitant to V5.0
- Update AVL documents
- Update Kernel documents
- Update Linux documents
- Add Benchmark KPI for rockchip linux
```

## rk3326_linux_release_v1.3.0_20200224.xml Release Note

**kernel**:

```
- Fixes the exception that is related with display
- Fixes wifi initialization failure
- Fixes wifi "pno scan failed"
```

**buildroot**:

```
- Fixes wrong capacity for mtp
- Use qsetting application instead of old setting applcation
- fix seek video error
- Support ums feature
- Support webrtc
- Support gcc 8.1.0
- Add a uvc_app for camera debug test
```

**debian 10**:

```
- aarch64 debian 10 buster release
```

## rk3326_linux_release_v1.2.2_20191205.xml Release Note

**kernel**:

```
- Fixes upgrade issue for nand flash
```

**rkbin**:

```
- Fixes IDB backup regions break up the FTL data region
```

**u-boot**:

```
- fixes IDB backup regions break up the FTL data region
```

**camera_engine_rkisp**:

```
- Remove dependancy with libdrm that fixes the crash whitout the display system
```

## rk3326_linux_release_v1.2.1_20191012.xml Release Note

**kernel**:

```
- Fix the low-propability crash whilst high cpu frequency and low ddr frequency at the same time
```

## rk3326_linux_release_v1.20_20190916.xml Release Note

**Buildroot(2018.02-rc3)**:

```
- Support up to Qt 5.12.2
- Support chromium brower
- Weston suoport rotate and scale
- Support x11 packages
- Mali support x11
- Provide a mali that has only opencl feature
- Add a customized configuration for robot product
- Enable ccahe to improve compile speed
- Fix compile error on ubuntu 19.04
- Support zstd compression algorithm for squashfs
- Upgrade glibc to 2.29
```

**kernel**:

```
- Upgrade to 4.4.189
- Fix logo blink issue
- Fix some power regulators can't turn off while suspending
- Add a customized configuration for robot product
```

**rkisp upgrade to v2.2.0**:

```
- Support blink light control
- Optimize capture process
```

**rkbin**:

```
- ddr.bin upgrade to v1.13
- bl32 upgrade to v1.12
    Fix ota upgrade failure
- bl31 upgrade to v1.16
    Support uart0 wakeup
    Support atags
    Support boot from secondary cpu
- miniloder upgrade to v1.15
```

**tools**:

```
- Androidtool upgrade to v2.69
```

**applications**:

```
- Remove the original gallery,video,music applications, provide the new application to replace
- Use the new camera application, that is compatible with the usb camera, and support the differents camera switching
- Various fix
```

## rk3326_linux_release_v1.10_20190425.xml Release Note

**Buildroot(2018.02-rc3)**:

```
- WiFi/BT compatibility support
- Bluetooth a2dp support
- Recovery image size optimization
- Support secure boot
- Fix sound playback issue for h264
- Fix video display issue for h264
```

**document**:

```
- Recovery guide
- pcba guide
- HDMI CEC guide
- drm display driver development guide
```

**tools**:

```
- DriverAssitant upgrade to v4.8
- AndroidTool upgrade to v2.67
- FactoryTool upgrade to v1.66
- Rename rk_provision_tool to RKDevInfoWriteTool, and upgrade to v1.0.4
```

**kernel**:

```
- Fix rkisp interrupt storm in some scenarios
- Fix kernel lockup after the system is resumed, it's caused by nand/sfc flash
- Fix kernel lockup while the watchdog is enable
- Memory log (pstore) support
- Fix loader upgradation fail upduring ota
- Fix powerup failure for ov5695
- Add the support for 4k page spi nand flash:ATO25D1GA, XT26G02B, XT26G01B, HYF4GQ4UAACBE
- Hardware crypto feature support
```

**Application**:

```
- Fix touch event invalid scenario
- Improve bluetooth feature
- mpeg4 video support
- Fix the hangup after takephotos continuously
- Fix the others device can't connect to AP
- wav and wma audio support
```

**rkbin**:

```
- ddr.bin upgrade to v1.11
```

**uboot**:

```
- Add the support for NandFlash H27TDG8T2D8R
- Support kernel compression image
- Add the low voltage protection for PMIC rk809/rk817
- Add the watchdog support
- Add the MEDIA_BUS_FMT_RGB666_1X7X3_JEIDA format support for lvds display
```

**rkisp**:

```
- Upgrade to v2.0.0
```

**libdrm**:

```
- Switch branch to rk33/mid/9.0/Develop
```

## rk3326_linux_release_v1.00_20190215.xml Release Note

**buildroot**:

```
- Add a simple configuration for robot product
- Fixup ssh error on squashfs filesystem
- camera_engine_rkisp upgrade to v1.6
- Add camera test scripts
- Imporve audio test scripts
```

**rkbin**:

```
- bl32 fix a low probability system hangup
```

**u-boot**:

```
- Enable OF_LIVE feature
- Add a new configuration without bl32
```

**kernel**:

```
- Support black/white camera
- Enable rockchip pvtm feature to optimize power consumption
- Support camera sensor:ov7750, 0v7251, ov7725
- RK817/RK809 codec support S32_LE
```

**document**:

```
- RKISP_Driver_User_Manual guide
- camera_engine_rkisp_user_manual guide
```
