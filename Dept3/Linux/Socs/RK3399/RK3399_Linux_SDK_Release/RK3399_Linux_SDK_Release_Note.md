# RK3399 Linux SDK Release Note

---

**Versions**

[TOC]

---

## rk3399_linux_release_v2.5.0_20201013.xml Release Note

**Buildroot (2018.02-rc3)**:

	- Fix date time isn't updated by default
	- Support more shells and feature in power-key.sh
	- Fix crash when hotplugging monitors
	- Updtae rockchip_test to fix weston config
	- Support mali egl client and egl buffer attaching on weston
	- Support rsa authentication and tcp for adb
	- support ntfs for recovery
	- Upgrade mali to r18
	- Support QT 5.14.2 version
	- Update weston to v8.0.0
	- Update chromium-wayland to 85.0.4183.102

**Distro (debian10)**:

	- Fixes the dual screen display
	- Upgrade mali to r18
	- Fix date time isn't updated by default
	- Fix U disk with NTFS that's not display on QT

**Debian (stretch-9.12)**:

	- Update xserver to improve the performance
	- Add pcmanfm with outline selection
	- Support the xvimagesink for gstreamer
	- Update mpp to fix the encode
	- Upgrade mali to r18
	- Fix the power key with halt
	- Update adb to fix the shell command and login
	- Update npu fw to v1.4.0
	- Update libmali/ffmpeg/mpp/mpv/xserver to fix some bugs
	- Update xserver to fix some bugs
	- Update gst-rkmpp to fix the mppvideodec

**Yocto (3.0)**:

	- Upgrade to 3.0.3

**Kernel (4.4)**:

	- Upgrade mali t76x to r18
	- Supoort legacy api to set propert

**libmali**:

	- Upgrade Midgard DDK to r18p0-01rel0

**rkbin (Rockchip binary)**:

	- Fix sd card boot fail
	- Fix the ATF AVE issue

**docs/tools**:

	- Update recovery/Graphics document
	- Add deviceIo Bluetooth document
	- Add mpp/weston/chromecast/debian10 document
	- Update Kernel/Linux/AVL/Socs/Others documents
	- Update Linux_Upgrade_Tool: update from v1.38 to v1.49
	- Secureboottool: update to v1.95
	- SecurityAVB: update to v2.7
	- Upgrade SDDiskTool to v1.62
	- Rename AndroidTool to RKDevTool, and version upgrade too v2.73
	- Update DDR/ NAND/ eMMC AVL
	- Remove unused documents
	- Windows: add tool for modify parameter
	- Add RMSL developer guide

## rk3399_linux_release_v2.4.0_20200430.xml Release Note

**Buildroot (2018.02-rc3)**:

	- Add rktof to app_demo
	- Update dviceio to fix some bugs
	- Gstreamer supports dmabuf direct import
	- Fixes the fonts with buildroot

**Distro (debian10)**:

	- Fixes e2fsck error with generating rootfs

**Yocto (2.6)**:

	- The source code used the rockchip inside server to instead of  github

**Kernel (4.4)**:

	- Support the rk3399 evb ind board

**rkbin (Rockchip binary)**:

	- rk3399: bl31: update version to v1.33
	    Build from ATF commit:
	    51fa19792 plat: rk3399: enable stimer1
	    update feature:
	    51fa19792 plat: rk3399: enable stimer1
	- rk3399: bl32: update version to 1.24
	    Build from optee commit in develop branch:
	    ebb61ff5 core: arm64.S: spectre workaround
	    Update feature:
	    f8d366cb core: arm64: pad vector with illegal instruction
	    8ed4c89a core: thread_a64.S: cleanup vector entries
	- rk3399: loader: update loader bin to 1.24.
	    build from:
	    67c868 update rk3399 loader to 1.25.
	    update feature:
	    Add program key to efuse in miniloader
	    fix some security hole

**docs/tools**:

	- Add RMSL developer guide
	- Update Kernel documents
	- Update rk3399 release document to v2.4.0
	- Add mpp/weston/chromecast/debian10 document
	- Update window/linux upgrade tools
		AndroidTool: update from v2.69 to v2.71
		Linux_Upgrade_Tool: update from v1.38 to v1.49

**Debian (stretch-9.11)**:

	- Update xserver
	- Add pcmanfm with outline selection
	- Support the xvimagesink for gstreamer
	- Update mpv with hardware decode

## rk3399_linux_release_v2.3.0_20191203.xml Release Note

**Buildroot (2018.02-rc3)**:

	- Support multivideoplayer and qsetting apps
	- Update xserver: fix wrong rga format map and fix random crash
	- Fixes some weston render issues
	- Support rockchip RGA 2D accel
	- The logs output on br.log  - Support the freerdp with X11
	- Upgrade QT verison from 5.9.4 to 5.12.2
	- Support Chromium Browser (74.0.3729.157)
	- Upgrade Xserver-xorg to v1.20.4
	- change the new qt app to instead the old apps
		new apps: qcamera  qfm  QLauncher+  qplayer  qsetting
		old apps: camera gallery  music  QLauncher  settings  video
	- Add the missing license/copyright with legal-info
	- Support x11 packages
	- Support weston rotate and scale
	- Upgrade camera_engine_rksip
	- Support the freerdp with X11
	- Upgrade QT verison from 5.9.4 to 5.12.2
	- Support Chromium Browser (74.0.3729.157)
	- Upgrade Xserver-xorg to v1.20.4
	- Change the new qt app to instead the old apps
		new apps: qcamera  qfm  QLauncher+  qplayer  qsetting
		old apps: camera gallery  music  QLauncher  settings  video
	- Add the missing license/copyright with legal-info
	- Support x11 packages
	- Support weston rotate and scale
	- Upgrade camera_engine_rksip

**Kernel (4.4)**:

	- Upgrade to 4.4.194
		enable iep for rk3399 sapphire excavator linux
		correct voltage for rk3399-firefly
		Fixup wrong swap uv on YCrCb_420_P
		In order to more stable, increase the minimum voltage to from 800mv to 825mv.
		Fixes the HDMI status in resume
		Add the rk3399 lpddr4 dts for reference
		Fixes nvme/p-cie interface sdd
		camera stuff update...etc

**rkbin (Rockchip binary)**:

	- rk3399: bl32: update version to 1.21
		Update feature:
			07ae323c scripts: optimize checkbuild.sh
			a87d3b09 scripts: optimize build scripts
		- rk3399: bl31: update version to 1.30
			42583b6 plat: rk3399: change bl31_base to 0x40000
		- rk3399: ddr: update ddr version to v1.24 20191016
			5ed0e6d lpddr4: add support multi frequency
			1eb26fb RK3399: ddr: support choice uart by g_uart_info

**docs/tools**:

	- Update AVL
	- Update Soc_public
	- Secureboottool: update to v1.95
	- Add Docker document
	- Update PWM document
	- Remove internal docs
	- Add Rockchip SDK Kit document
	- Update avb tool to v2.6
	- Add window/linux secure sign tool
	- Add DM tools
	- Upgrade AndroidTool from v2.67 to v2.69, support for ubifs
	- Update rk_provision_tool to RKDevInfoWriteTool_V1.0.4
		V1.0.4:
		1.add two custom id
		2.the rk_provision_tool rename to RKDevInfoWriteTool
	- Upgrade SDDiskTool to v1.59

**Debian (stretch-9.11)**:

	- Update xserver
	- Fixes jpeg's decode to 60fps
	- Update test_camera for uvc
	- Update mpp
	- Update rga
	- Support exa/glamor hw acceleration on xserver
	- Update camera_engine_rksip to v2.2.0
	- Add LICENSE.txt
	- QT upgraded to v5.11
	- Fixes system suspend/resume for rk3399pro Socs
	- Add glmark2 normal mode
	- Add video hardware acceleration for chromium

**Yocto (thud 2.6.2)**:

	- add rockchip-rkisp
	- chromium-ozone-wayland: Support 78.0.3904.97g
	- Support adding extra volumes
	- Gstreamer-rockchip: Update source and patches
	- Gstreamer1.0-plugins-base: xvimagesink: Support dma buffer 			  rendering
	- Xserver-xorg: glamor: Update patches

## rk3399_linux_release_v2.2.0_20190628.xml Release Note

**Buildroot**:

	- Support dual panel with the same display or different display
	- Fix suspend and resume input-event-daemo abnormal issue
	- Fix gstreamer play video abnormally and support more format

**Debian**:

	- Optimize adb/glmark2
	- Gstreamer/mpp/qt and other update synchronization with buildroot and Yocto system

**Kernel (4.4)**:

	- Changed the EDP/MIPI/.. Monitor display in VOPL, and HDMI monitor
	  display put in VOPB
	- Support audio/headphone jack in debian os
	- Fix host mode resume fail for rk3399's usb3

**uboot/rkbin**:

	- The ddr bin update to v1.22, bl31 update to v1.288.
	- Fix lpddr4 abnormal issue k3399: ddr: update ddr version to v1.22 20190506
		build from:
			8132b62 Version: DDR Version 1.22 20190506
		update feature:
        	ce4c893 lpddr4: fix lpddr4 some timing error
	- rk3399: bl31: update version to 1.28
		Build from ATF commit:
			51f2096 plat: rk3399: ddr: fix lpddr4 some timing error
		update feature:
			this bl31 is match ddr bin Version "DDR Version 1.22 20190506"

## rk3399_linux_release_v2.1.0_20190124.xmlRelease Note

**Buildroot**:

	- Fix the qt5.6 compile issue
	- Fix the qt5wayland random xdg_shell error
	- Fix some rockchip_test bugs, mainly include adding multi-channel video and app demo
	- Support for mount resizing read-only ext2 rootfs
	- Add gst-plugins-rockchip, fix the issue that usb camera and mipi camera can not coexist
	- Synchronize the internal latest buildroot version
	- Fix some rockchip_test issues
	- Fix some issues in qt5 wayland application
	- Add support for qt5 wayland multi-channel video playback
	- Fix some camera 3a issues
	- Fix some recovey updates issues

**Debian**:

	- The blueman issue
	- Scripts: fixes blueman error
	- Dpkg: error processing package blueman (--configure):
	- Subprocess installed post-installation script returned error exit status 1
	- Fix the drm hotplug issue£º
		1/ Avoid force changing resolution
		2/ Be able to handle it before login

**Documents and tools**:

	- Update uboot/dvfs/mmc/rkisp drive user manual
	- Update pcba/recovery/secureboot
	- Add camera opencv support
	- Tools driver upgrade
	- Add efusetool, ddr tool, spi image tool, secureboottools

**Kernel**:

	- Fix the issue that very time you start, error warning of Pmic regulator
	- Fix recovery button invalid to enter loader issue
	- Enable rk rga by default
	- Fix PCCI failed to enter L2 link state
	- Enable ramoops
	- Fix rk3399 dwc3 host power on fail
	- Fix some rockchip isp1 bugs
	- Fix the camera 3a issue and support for some other cameras
	- Fix some PCIe issues
	- Synchronize to the latest internal kernel version.

**uboot/rkbin**:

	- The ddr bin update to v1.18
	- rk3399: ddr: update version to v1.18
		built from ddr init project commit:
			d91c3eb Version: DDR Version 1.18 20190218
		Update feature:
			d91c3eb Version: DDR Version 1.18 20190218
			9eae850 rk3399: using unify global argument for uart, dram info config
	- miniloader version update
	- evb-rk3399_defconfig was changed to rk3399_defconfig
	- Support serial port baud rate modification during loader process
	- Synchronize to the latest internal uboot code
	- Support for rk optee and avb

## rk3399_linux_release_v2.0.0_20180517.xml Release Note

	- The first release version
