# RK3288 Linux SDK Release Note

---

**Versions**

[TOC]

---

## rk3288_linux_release_v2.3.0_20201203.xml Release Note

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

## rk3288_linux_release_v2.2.0_20200708.xml Release Note

**Buildroot (2018.02-rc3)**:

```
- Add rktof to app_demo
- Update dviceio to fix some bugs
- Gstreamer supports dmabuf direct import
- Fixes the fonts with buildroot
- Fixes wifi/bt on buildroot
- Support qt5webengine on buildroot
- Fixes camera 3A server
- Support multivideoplayer and qsetting apps
- Update xserver: fix wrong rga format map and fix random crash
- Fixes some weston render issues
- Support rockchip RGA 2D accel
- The logs output on br.log
- Fix date time isn't updated by default
- Support more shells and feature in power-key.sh
- Fix crash when hotplugging monitors
- Updtae rockchip_test to fix weston config
- Support mali egl client and egl buffer attaching on weston
- Support rsa authentication and tcp for adb
- Support ntfs for recovery
- gst1-plugins-bad: kmssink/waylandsink: Bump to gst upstream
- qt5wayland: Update patches to fix some bugs
```

**Distro (debian10)**:

```
- Support Yocto
- Fixes the dual screen display
- Upgrade mali to r18
- Fix date time isn't updated by default
- Fix U disk with NTFS that's not display on QT
```

**Debian (stretch-9.12)**:

```
- Update xserver to improve the performance
- Add pcmanfm with outline selection
- Support the xvimagesink for gstreamer
- Update mpv with hardware decode
- Fixes jpeg's decode to 60fps
- Update test_camera for uvc
- Update mpp to fix the encode
- Update rga/ffmpeg to support the chromium hardware accelerate
- Upgrade mali to r18
- Fix the power key with halt
```

**Yocto (3.0)**:

```
- Upgrade to 3.0.3
```

**Kernel (4.4)**:

```
- Adjust bin-scaling-sel table
- Adjust pvtm-voltage-sel table
- Add vcc_otg_vbus control for rk3288-evb-rk808-linux
- Fixes the pwm-cells of pwm3 on rk3288 SoCs
- Fixes wifi wakeup issue
- Upgrade mali t76x to r18
- Supoort legacy api to set propert
- Fix gcc9 stringop-truncation compilation error
```

**libmali**:

```
- Upgrade Midgard DDK to r18p0-01rel0
```

**rkbin (Rockchip binary)**:

```
- rk3288: tee with ta: update optee version to v1.45
```

**docs/tools**:

```
- Add RMSL developer guide
- Add mpp/weston/chromecast/debian10 document
- Update Kernel/Linux/AVL/Socs/Others documents
- Update window/linux upgrade tools
  AndroidTool: update from v2.69 to v2.71
  Linux_Upgrade_Tool: update from v1.38 to v1.49
- Secureboottool: update to v1.95
- SecurityAVB: update to v2.7
- Upgrade SDDiskTool to v1.62
- Rename AndroidTool to RKDevTool, and version upgrade too v2.73
- Update DDR/ NAND/ eMMC AVL
- Remove unused documents
- Update adb to support the env variable
- Updtae MPV to support drm hwdec
- Updtae Xserver to fix the wrong transfrom
```
