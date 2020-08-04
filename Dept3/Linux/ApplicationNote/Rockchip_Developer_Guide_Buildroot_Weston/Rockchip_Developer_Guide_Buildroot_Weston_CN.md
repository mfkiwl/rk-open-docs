# Rockchip Buildroot Weston 开发指南

文件标识：RK-KF-YF-326

发布版本：V1.1.0

日期：2020-08-04

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

 本文主要描述了Buildroot SDK Weston显示服务的基本配置方法。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| 所有芯片     | 4.4          |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | Jeffy Chen | 2019-11-27 | 初始版本     |
| V1.0.1 | Ruby Zhang | 2020-07-22 | 更新公司名称和文档格式 |
| V1.1.0 | Jeffy Chen | 2020-08-04 | 适配最新SDK |

---

**目录**

[TOC]

---

## 简介

### 相关介绍

Weston是Wayland开源显示协议的官方参考实现，Rockchip Buildroot SDK的显示服务默认使用Weston 8.0 drm后端。

[^注]: Weston及Wayland相关资料可以参考官方网站：<https://wayland.freedesktop.org>

### 配置方式

Buildroot SDK中Weston的配置方式主要有以下几种：

a、启动参数

即启动Weston时命令所带参数，如weston --tty=2

b、weston.ini配置文件

位于/etc/xdg/weston/weston.ini，对应SDK代码中位置为：buildroot/board/rockchip/common/base/etc/xdg/weston/weston.ini

参考：<https://fossies.org/linux/weston/man/weston.ini.man>

c、特殊环境变量

此类环境变量一般设置于Weston的启动脚本内，SDK固件中位于/etc/init.d/S50launcher，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    export WESTON_DRM_MIRROR=1 # 需设置于启动weston前
                    ...
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
```

d、动态配置文件

对于drm后端，Buildroot SDK中的Weston提供一些动态配置支持，比如动态显示配置文件，默认路径为/tmp/.weston_drm.conf，可以通过环境变量WESTON_DRM_CONFIG指定。

e、udev rules

Weston中输入设备的部分配置需要通过udev rules。

## 具体配置

### 状态栏相关配置

Weston支持在weston.ini配置文件的shell段设置状态栏的背景色、位置，以及在launcher段设置快捷启动程序，如：

```ini
    # /etc/xdg/weston/weston.ini

    [shell]
    panel-color=0x90ff0000
    # 颜色格式为ARGB8888

    panel-position=bottom
    # top|bottom|left|right|none，none为禁止

    [launcher]
    icon=/usr/share/icons/gnome/24x24/apps/utilities-terminal.png
    # 图标路径

    path=/usr/bin/gnome-terminal
    # 快捷启动命令
```

Weston目前不支持设置状态栏的大小，如要调整，必须进行代码级别的修改：

```c
    // weston-8.0.0/clients/desktop-shell.c

    static void
    panel_configure(void *data,
                    struct weston_desktop_shell *desktop_shell,
                    uint32_t edges, struct window *window,
                    int32_t width, int32_t height)
    {
            ...
            switch (desktop->panel_position) {
            case WESTON_DESKTOP_SHELL_PANEL_POSITION_TOP:
            case WESTON_DESKTOP_SHELL_PANEL_POSITION_BOTTOM:
                    height = 32; # 高度
                    break;
            case WESTON_DESKTOP_SHELL_PANEL_POSITION_LEFT:
            case WESTON_DESKTOP_SHELL_PANEL_POSITION_RIGHT:
                    switch (desktop->clock_format) {
                    case CLOCK_FORMAT_NONE:
                            width = 32;
                            break;
                    case CLOCK_FORMAT_MINUTES:
                            width = 150;
                            break;
                    case CLOCK_FORMAT_SECONDS:
                            width = 170;
                            break;
                    }
                    break;
            }
```

### 背景配置

Weston支持在weston.ini配置文件的shell段设置背景图案、颜色，如

```ini
    # /etc/xdg/weston/weston.ini

    [shell]
    background-image=/usr/share/backgrounds/gnome/Aqua.jpg
    # 背景图案（壁纸）绝对路径

    background-type=tile
    # scale|scale-crop|tile

    background-color=0xff002244
    # 颜色格式为ARGB8888，未设置背景图案时生效
```

### 待机及锁屏配置

Weston的超时待机时长可以在启动参数中配置，也可以在weston.ini的core段配置，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    weston --tty=2 -B=drm-backend.so --idle-time=0&  # 0为禁止待机，单位为秒
```

或者

```ini
    # /etc/xdg/weston/weston.ini

    [core]
    idle-time=10
```

Weston的锁屏可以在weston.ini的shell段配置，如：

```ini
    # /etc/xdg/weston/weston.ini

    [shell]
    locking=false
    # 禁止锁屏

    lockscreen-icon=/usr/share/icons/gnome/256x256/actions/lock.png
    # 解锁按钮图案

    lockscreen=/usr/share/backgrounds/gnome/Garden.jpg
    # 锁屏界面背景
```

### 显示颜色格式配置

Buildroot SDK内Weston目前默认显示格式为ARGB8888，对于某些低性能平台，可以在weston.ini的core段配置为RGB565，如：

```ini
    # /etc/xdg/weston/weston.ini

    [core]
    gbm-format=rgb565
    # xrgb8888|rgb565|xrgb2101010
```

也可以在weston.ini的output段单独配置每个屏幕的显示格式，如：

```ini
    # /etc/xdg/weston/weston.ini

    [output]
    name=LVDS-1
    # output的名字可以在weston启动log中看到，如：Output LVDS-1, (connector 71, crtc 60)

    gbm-format=rgb565
    # xrgb8888|rgb565|xrgb2101010
```

### 屏幕方向配置

Weston的屏幕显示方向可以在weston.ini的output段配置，如

```ini
    # /etc/xdg/weston/weston.ini

    [output]
    name=LVDS-1

    transform=90
    # normal|90|180|270|flipped|flipped-90|flipped-180|flipped-270
```

如果需要动态配置屏幕方向，可以通过动态配置文件，如：

```shell
    echo "output:all:rotate90" > /tmp/.weston_drm.conf # 所有屏幕旋转90度
    echo "output:eDP-1::rotate180" > /tmp/.weston_drm.conf # eDP-1旋转180度
```

### 分辨率及缩放配置

Weston的屏幕分辨率及缩放可以在weston.ini的output段配置，如：

```ini
    # /etc/xdg/weston/weston.ini

    [output]
    name=LVDS-1

    mode=1280x800
    # 需为屏幕支持的有效分辨率

    scale=2
    # 需为整数倍数，支持应用内部实现缩放
```

如需要缩放到特定分辨率，可以通过WESTON_DRM_VIRTUAL_SIZE环境变量配置，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    export WESTON_DRM_VIRTUAL_SIZE=1024x768
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
```

这种方式需要显示驱动支持硬件缩放。个别芯片平台不支持带alpha透明度的缩放，需要参考前面说明修改显示颜色格式为XRGB8888等格式。

如果需要动态配置分辨率及缩放，可以通过动态配置文件，如：

```shell
    echo "output:HDMI-A-1:mode=800x600" > /tmp/.weston_drm.conf # 修改HDMI-A-1分辨率为800x600
    echo "output:eDP-1:rect=<10,20,410,620>" > /tmp/.weston_drm.conf # eDP-1显示到(10,20)位置，大小缩放为400x600
```

这种方式缩放时，如果硬件VOP显示模块不支持缩放，则需要依赖RGA处理。

### 冻结屏幕

在启动Weston时，开机logo到UI显示之间存在短暂切换黑屏。如需要防止黑屏，可以通过以下方式短暂冻结Weston屏幕内容：

使用定制--warm-up运行参数在UI启动后开始显示

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    weston --tty=2 -B=drm-backend.so --idle-time=0 --warm-up&
```

或者

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    export WESTON_FREEZE_DISPLAY=/tmp/.weston_freeze # 设置特殊配置文件路径
                    touch /tmp/.weston_freeze # 冻结显示
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
                    ...
                    sleep 1 && rm /tmp/.weston_freeze& # 1秒后解冻
```

又或者

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    echo "output:all:freeze" > /tmp/.weston_drm.conf # 冻结显示
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
                    ...
                    sleep 1 && \
                        echo "output:all:unfreeze" > /tmp/.weston_drm.conf& # 1秒后解冻
```

### 多屏配置

Buildroot SDK的Weston支持多屏同异显及热拔插等功能，不同显示器屏幕的区分根据drm的name（通过Weston启动log或者/sys/class/drm/card0-\<name\>获取），相关配置通过环境变量设置，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    export WESTON_DRM_PRIMARY=HDMI-A-1 # 指定主显为HDMI-A-1
                    export WESTON_DRM_MIRROR=1 # 使用镜像模式（多屏同显），不设置此环境变量即为异显
                    export WESTON_DRM_KEEP_RATIO=1 # 镜像模式下缩放保持纵横比，不设置此变量即为强制全屏
                    export WESTON_DRM_PREFER_EXTERNAL=1 # 外置显示器连接时自动关闭内置显示器
                    export WESTON_DRM_PREFER_EXTERNAL_DUAL=1 # 外置显示器连接时默认以第一个外显为主显
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
```

镜像模式缩放时，如果硬件VOP显示模块不支持缩放，则需要依赖RGA处理。

同时也支持在weston.ini的output段单独禁用指定屏幕：

```ini
    # /etc/xdg/weston/weston.ini

    [output]
    name=LVDS-1

    mode=off
    # off|current|preferred|<WIDTHxHEIGHT@RATE>
```

### 输入设备相关配置

Weston服务默认需要至少一个输入设备，如无输入设备，则需要在weston.ini中的core段特殊设置：

```ini
    # /etc/xdg/weston/weston.ini

    [core]
    require-input=false
```

Weston中如存在多个屏幕，需要把输入设备和屏幕进行绑定，则可以通过weston.ini的output段进行配置，如：

```ini
    # /etc/xdg/weston/weston.ini

    [output]
    name=LVDS-1

    seat=default
    # 输入设备对于seat的id可以通过buildroot/output/*/build/weston-8.0.0/weston-info工具查询
```

Weston如果需要校准触屏，可以通过WESTON_TOUCH_CALIBRATION环境变量，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    export WESTON_TOUCH_CALIBRATION="1.013788 0.0 -0.061495 0.0 1.332709 -0.276154"
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
```

校准参数的获取可以使用Weston校准工具: weston-calibrator，工具运行后会生成若干随机点，依次点击后输出校准参数，如：Final calibration values: 1.013788 0.0 -0.061495 0.0 1.332709 -0.276154

### 无屏启动

Weston不支持无屏显示，需要将显示器设置成强制接入状态，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    echo on > /sys/class/drm/card0-HDMI-A-1/status # 强制HDMI-A-1为接入状态
                    weston --tty=2 -B=drm-backend.so --idle-time=0&
```

### 无GPU平台配置

SDK中的Weston默认使用GPU进行渲染合成加速，对于无GPU的平台，也可以选用RGA替代进行加速。

具体配置需要Buildroot SDK开启BR2_PACKAGE_LINUX_RGA和BR2_PACKAGE_PIXMAN，并且Weston启动参数加入--use-pixman，如：

```shell
    # /etc/init.d/S50launcher
      start)
                    ...
                    weston --tty=2 -B=drm-backend.so --idle-time=0 --use-pixman&
```
