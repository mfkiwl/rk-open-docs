# Rockchip Buildroot Chromecast 使用说明

文件标识：RK-SM-YF-325

发布版本：V1.0.0

日期：2020-02-20

文件密级：□绝密   □秘密   □内部资料   ■公开

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有** **© 2019** **福州瑞芯微电子股份有限公司**

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

 本文主要描述了Buildroot SDK Chromecast的配置及基本使用方法。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 陈渐飞 | 2019-11-27 | 初始版本     |

**目录**

---
[TOC]
---

## 1 相关介绍

### 1.1 相关介绍

Chromecast是Google开发的一种远程内容流投射方式，支持投射音视频到任意Chromecast接收器（如Google Chromecast设备）。

最新Rockchip Buildroot SDK通过pychromecast、mkchromecast等开源python软件包提供Chromecast发送端支持。

## 2 使用方式

### 2.1 pychromecast

pychromecast是目前最流行的开源Chromecast协议（v2）实现软件包，支持设备发现、播放控制、程序控制等功能。

使用pychromecast需要确保Buildroot仓库更新到此commit之后：

```
    commit 19031dafae2437c79cca8120d310612061369cc0
    Author: Jeffy Chen <jeffy.chen@rock-chips.com>
    Date:   Thu Oct 10 10:57:10 2019 +0800

        packages: Add python-pychromecast

        Library for Python 3.6+ to communicate with the Google Chromecast.

        Change-Id: I2d90d51c27a38037c072fdc8c7f839c9dc079c32
        Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
```

并在Buildroot menuconfig中开启BR2_PACKAGE_PYTHON_PYCHROMECAST。

具体使用需要通过python脚本操作，官方示例：

```python
>> import time
>> import pychromecast

>> chromecasts = pychromecast.get_chromecasts()
>> [cc.device.friendly_name for cc in chromecasts]
['Dev', 'Living Room', 'Den', 'Bedroom']

>> cast = next(cc for cc in chromecasts if cc.device.friendly_name == "Living Room")
>> # Start worker thread and wait for cast device to be ready
>> cast.wait()
>> print(cast.device)
DeviceStatus(friendly_name='Living Room', model_name='Chromecast', manufacturer='Google Inc.', uuid=UUID('df6944da-f016-4cb8-97d0-3da2ccaa380b'), cast_type='cast')

>> print(cast.status)
CastStatus(is_active_input=True, is_stand_by=False, volume_level=1.0, volume_muted=False, app_id='CC1AD845', display_name='Default Media Receiver', namespaces=['urn:x-cast:com.google.cast.player.message', 'urn:x-cast:com.google.cast.media'], session_id='CCA39713-9A4F-34A6-A8BF-5D97BE7ECA5C', transport_id='web-9', status_text='')

>> mc = cast.media_controller
>> mc.play_media('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 'video/mp4')
>> mc.block_until_active()
>> print(mc.status)
MediaStatus(current_time=42.458322, content_id='http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', content_type='video/mp4', duration=596.474195, stream_type='BUFFERED', idle_reason=None, media_session_id=1, playback_rate=1, player_state='PLAYING', supported_media_commands=15, volume_level=1, volume_muted=False)

>> mc.pause()
>> time.sleep(5)
>> mc.play()
```

[^注]: 详细资料请参考官方说明 <https://github.com/balloob/pychromecast>

### 2.2 mkchromecast

mkchromecast是目前最流行的开源Chromecast应用，它基于pychromecast以及pyqt提供带有UI（如控制菜单）的Chromecast投射。

使用mkchromecast需要确保Buildroot仓库更新到此commit之后：

```
    commit 94a9402dcefeb9d5b8cf62d334a66cda9b5c92e6
    Author: Jeffy Chen <jeffy.chen@rock-chips.com>
    Date:   Mon Oct 14 09:25:30 2019 +0800

        packages: Add python-mkchromecast

        Cast audio/video to your Google Cast devices.

        Change-Id: If60f3f6590a355d09a6647f5ae3bc7d61d6bf449
        Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
```

并在Buildroot menuconfig中开启BR2_PACKAGE_PYTHON_PYCHROMECAST以及BR2_PACKAGE_PYTHON_MKCHROMECAST。

具体使用是通过mkchromecast程序，官方示例：

```shell
mkchromecast -y https://www.youtube.com/watch\?v\=VuMBaAZn3II --video
mkchromecast --source-url http://192.99.131.205:8000/pvfm1.ogg -c ogg --control
mkchromecast --video -i "/path/to/file.mp4"
```

[^注]: 详细资料请参考官方说明 <https://github.com/muammar/mkchromecast>
