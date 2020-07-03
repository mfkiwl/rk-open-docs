# Rockchip Buildroot Chromecast Introduciton

ID: RK-SM-YF-325

Release Version: V1.0.0

Release Date: 2020-02-20

Security Level: □Top-Secret   □Secret   □Internal   ■Public

---

**DISCLAIMER**

THIS DOCUMENT IS PROVIDED “AS IS”. FUZHOU ROCKCHIP ELECTRONICS CO., LTD.(“ROCKCHIP”)DOES NOT PROVIDE ANY WARRANTY OF ANY KIND, EXPRESSED, IMPLIED OR OTHERWISE, WITH RESPECT TO THE ACCURACY, RELIABILITY, COMPLETENESS,MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE OR NON-INFRINGEMENT OF ANY REPRESENTATION, INFORMATION AND CONTENT IN THIS DOCUMENT. THIS DOCUMENT IS FOR REFERENCE ONLY. THIS DOCUMENT MAY BE UPDATED OR CHANGED WITHOUT ANY NOTICE AT ANY TIME DUE TO THE UPGRADES OF THE PRODUCT OR ANY OTHER REASONS.

**Trademark Statement**

"Rockchip", "瑞芯微", "瑞芯" shall be Rockchip’s registered trademarks and owned by Rockchip. All the other trademarks or registered trademarks mentioned in this document shall be owned by their respective owners.

**All rights reserved. ©2019. Fuzhou Rockchip Electronics Co., Ltd.**

Beyond the scope of fair use, neither any entity nor individual shall extract, copy, or distribute this document in any form in whole or in part without the written approval of Rockchip.

Fuzhou Rockchip Electronics Co., Ltd.

No.18 Building, A District, No.89, software Boulevard Fuzhou, Fujian,PRC

Website:     [www.rock-chips.com](http://www.rock-chips.com)

Customer service Tel:  +86-4007-700-590

Customer service Fax:  +86-591-83951833

Customer service e-Mail:  [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**Preface**

**Overview**

This document presents configuration methods and basic usage of Buildroot SDK Chromecast.

**Intended Audience**

This document (this guide) is mainly intended for:

Technical support engineers
Software development engineers

**Revision History**

| **Version** | **Author** | **Date** | **Revision History** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | Jeff Chen | 2019-11-27 | Initial version |

**Contents**

---
[TOC]
---

## Introduction

Chromecast is a line of digital media players developed by Google. The devices enable users to cast streamed audio-visual content to any Chromecast receiver that support Google Cast technology (such as Google Chromecast devices).

The latest Rockchip Buildroot SDK provides Chromecast sender support through open source python packages such as pychromecast and mkchromecast.

## Usage

### pychromecast

Currently, pychromecast is the most popular open source Chromecast protocol (v2) implementation software package, supporting device discovery, playback control, program control and other functions.

Please ensure that Buildroot repository is updated to this commit before using pychromecast:

```
    commit 19031dafae2437c79cca8120d310612061369cc0
    Author: Jeffy Chen <jeffy.chen@rock-chips.com>
    Date:   Thu Oct 10 10:57:10 2019 +0800

        packages: Add python-pychromecast

        Library for Python 3.6+ to communicate with the Google Chromecast.

        Change-Id: I2d90d51c27a38037c072fdc8c7f839c9dc079c32
        Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
```

And enable BR2_PACKAGE_PYTHON_PYCHROMECAST in Buildroot menuconfig.

Detailed usage should be operated through the python script, an official example is showed below:

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

[^Note]: Please refer to official introduction for details <https://github.com/balloob/pychromecast>

### mkchromecast

mkchromecast is the most popular open source Chromecast application currently. It provides Chromecast casting with UI (such as control menu) based on pychromecast and pyqt.

Please ensure that the Buildroot repository is updated to this commit before using mkchromecast:

```
    commit 94a9402dcefeb9d5b8cf62d334a66cda9b5c92e6
    Author: Jeffy Chen <jeffy.chen@rock-chips.com>
    Date:   Mon Oct 14 09:25:30 2019 +0800

        packages: Add python-mkchromecast

        Cast audio/video to your Google Cast devices.

        Change-Id: If60f3f6590a355d09a6647f5ae3bc7d61d6bf449
        Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
```

And enable BR2_PACKAGE_PYTHON_PYCHROMECAST and BR2_PACKAGE_PYTHON_MKCHROMECAST in Buildroot menuconfig.

Please refer to mkchromecast program for detailed usage, an official example is showed below:

```shell
mkchromecast -y https://www.youtube.com/watch\?v\=VuMBaAZn3II --video
mkchromecast --source-url http://192.99.131.205:8000/pvfm1.ogg -c ogg --control
mkchromecast --video -i "/path/to/file.mp4"
```

[^Note]: For detailed information, please refer to the official description: <https://github.com/muammar/mkchromecast>

