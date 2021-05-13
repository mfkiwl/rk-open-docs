# RK356X Linux SDK Note

---

**Versions**

[TOC]

---
## rk356x_linux_release_v1.1.0_20210520.xml Note

**Buildroot (2018.02-rc3)**:

```
- Adjust the new buildroot project
- Support buildroot 32 bits for rk356x
- Support RKNN SDK 1.0.0 Version
```

**Debian10 (buster)**:

```
- Use the new debian project
```

**Kernel (4.19)**:

```
- Enable optee by default
- Update USB/DRM/Wireless/Media/Video/Clock driver
```

**docs/tools**:

```
- Use the new docs project
```

**rkbin**:

```
- rk3568/rk3566: bl31: update version to v1.22
- rk3568/rk3566: bl32: update version to v1.05
- rk3568/rk3566: ddr: update ddr bin to v1.07
- rk3568/rk3566: spl: update version to v1.11
- rk356x: loader: update version to v1.08
```

## rk356x_linux_release_v1.0.0_20210410.xml Note

**Buildroot (2018.02-rc3)**:

```
- Upgrade libmali to g2p0
- Upgrade Chromium to 88.0.4324.150
- Support RKNN SDK 0.7 Version
- Update weston to support multi-screen
- Update mpp and gstreamer for mpeg4
- Update rockit
- Fixes qTbase/qt5multimedia/waylandsink/qt5declarative/qt5virtualkeyboard some bugs
- Support lxc and pcl
- Fixes qt5webengine on qt5.15
```

**Yocto**:

```
- Upgrade libmali to g2p0
- Upgrade Chromium to 88.0.4324.1502
```

**Debian10 (buster)**:

```
- Upgrade libmali to g2p0
- Upgrade Chromium to 88.0.4324.1502
- Support multi-screen
- Update rga/libmali/mpp packages
```

**Kernel (4.19)**:

```
- Upgrade Kernel to 4.19.172 from rockchip inside
```

**docs/tools**:

```
- Integrate AVL/DDR/DISPLAY/NVM/PCIe/UART/USB/U-BOOT documents to Common directory
- Update camera and audio documents and directory structure
- Add some rk356x documents
- Update rk_sign_tool to v1.41
- Update RKDevTool to V2.81
- Update SDDiskTool to v1.64
- Update SecureBootTool to v1.99
```

## rk356x_linux_beta_v0.2.0_20210226.xml Note

**Buildroot (2018.02-rc3)**:

```
- Use QT5.14 by default, and support QT5.15
- Upgrade Chromium to 87.0.4280.141
- Fixes qt5webengine HW video decode error on 5.15
- Update weston to fix some bugs
- Update power-key.sh for suspend and resume
- Add rockchip_rk356x_libs_defconfig for small system
```

**Yocto**:

```
- Fixes some issues on Yocto3.2
```

**Debian10 (buster)**:

```
- Fixes some issues on Debian10
```

**Kernel (4.19)**:

```
- Update Kernel from rockchip inside
```

## rk356x_linux_beta_v0.1.0_20210118.xml Note

```
- The first beta version
```

## rk356x_linux_alpha_v0.0.1_20201211.xml Note

```
- The first alpha version
```
