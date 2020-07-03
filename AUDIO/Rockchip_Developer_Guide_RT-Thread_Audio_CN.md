# RT-Thread 音频开发指南

文件标识：RK-KF-YF-349

发布版本：V1.1.0

日期：2020-03-29

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

## 前言

**概述**

本文档主要介绍RT-Thread音频开发的基本方法。

**产品版本**

| **芯片名称** | **内核版本**    |
| :----------- | --------------- |
| RK2108       | RT-Thread 3.1.3 |
|              |                 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 吴佳健   | 2019-09-03   | 初始版本     |
| V1.1.0     | 吴佳健   | 2020-03-29   | 随SDK更新    |

## 目录

---

[TOC]

---

## 文档及音频模块简介

RK2108上的音频相关模块有Analog MIC， PDM Digital MIC，VAD，AudioPWM和ES8388 CODEC，ES8311 CODEC等。其中ES8388 CODEC同时具备录音、播放、回采功能。Analog MIC和PDM Digital MIC可以配合VAD使用。本文档主要介绍RK2108上音频模块的配置及简单测试命令的使用。

## 开发基础

### 音频配置

#### Analog MIC配置

在menuconfig中开启RT_USING_AUDIO_CARD和RT_USING_AUDIO_CARD_ACDCDIG，随之出现的`iface type (I2STDM1)  --->`项可选择ADC的DAI（Digital Audio Interface）。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[*]   Enable Internal ADC audio card
        iface type (I2STDM1)  --->
[ ]   Enable AUDIOPWM audio card
[ ]   Enable I2S Ditigal Mic audio card
[ ]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[ ]   Enable Everest Semi ES8311 audio card
[ ]   Enable Everest Semi ES8388 audio card
[ ]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用时对应声卡名为`adcc`，如使用rt_device_read接口主动获取Analog MIC数据，需关闭RT_USING_VAD选项，否则无法正常获取数据。

#### PDM Digital MIC配置

在menuconfig中开启RT_USING_AUDIO_CARD和RT_USING_AUDIO_CARD_PDM_MIC。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[ ]   Enable Internal ADC audio card
[ ]   Enable AUDIOPWM audio card
[ ]   Enable I2S Ditigal Mic audio card
[*]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[ ]   Enable Everest Semi ES8311 audio card
[ ]   Enable Everest Semi ES8388 audio card
[ ]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用时对应声卡名为`pdmc`。

#### ES8388 CODEC配置

在menuconfig中开启RT_USING_AUDIO_CARD和RT_USING_AUDIO_CARD_ES8388，如需使用录音功能则需使能RT_USING_AUDIO_CARD_I2S_MIC。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[ ]   Enable Internal ADC audio card
[ ]   Enable AUDIOPWM audio card
[*]   Enable I2S Ditigal Mic audio card
        i2s select (I2STDM1)  --->
[ ]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[ ]   Enable Everest Semi ES8311 audio card
[*]   Enable Everest Semi ES8388 audio card
[ ]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用时对应声卡名为`es8388c`和`es8388p`，分别对应录音和播放。

#### ES8311 CODEC配置

在menuconfig中开启RT_USING_AUDIO_CARD和RT_USING_AUDIO_CARD_ES8311，如需使用录音功能则需使能RT_USING_AUDIO_CARD_I2S_MIC。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[ ]   Enable Internal ADC audio card
[ ]   Enable AUDIOPWM audio card
[*]   Enable I2S Ditigal Mic audio card
        i2s select (I2STDM1)  --->
[ ]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[*]   Enable Everest Semi ES8311 audio card
[ ]   Enable Everest Semi ES8388 audio card
[ ]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用时对应声卡名为`es8311c`和`es8311p`，分别对应录音和播放。

注：ES8311或ES8388只在指定板型上可用，使用前请先配置正确的`RT_BOARD_NAME`。

#### Audio PWM配置

在menuconfig中开启RT_USING_AUDIO_CARD和RT_USING_AUDIO_CARD_AUDIOPWM。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[ ]   Enable Internal ADC audio card
[*]   Enable AUDIOPWM audio card
[ ]   Enable I2S Ditigal Mic audio card
[ ]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[ ]   Enable Everest Semi ES8311 audio card
[ ]   Enable Everest Semi ES8388 audio card
[ ]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用RK2108B_EVB_V10板子时，使用Audio PWM需要将喇叭接至PWM out接口，并使用跳帽将PWM TRIODE引脚短接。

使用RK2108 AudioDemo板时，需要将喇叭接至核心板上SPEAKER接口。

修改bsp/rockchip/rk2108/board/<board>/iomux.c的rt_hw_iomux_config()函数，在其中添加`audio_iomux_config()`函数的调用。

使用时对应声卡名为`audpwmp`。

#### 声卡拼接配置

以Analog MIC与ES8311拼接为例，在menuconfig中开启RT_USING_AUDIO_CARD并按如下配置。

```c
RT-Thread rockchip rk2108 drivers > Enable Audio > Audio Cards
[*] Audio Cards
[*]   Enable Internal ADC audio card
        iface type (PDM0)  --->
[ ]   Enable AUDIOPWM audio card
[ ]   Enable I2S Ditigal Mic audio card
[*]   Enable PDM Digital Mic audio card
[ ]   Enable Everest Semi ES7243 audio card
[ ]   Enable Everest Semi ES8311 audio card
[ ]   Enable Everest Semi ES8388 audio card
[*]   Enable mix audio card with Interal ADC + ES8311
[ ]   Enable mix audio card with PDM Mics + ES8388
```

使用时对应声卡名为`echoc`和`echop`，支持回采功能。

### 测试用例

需要在menuconfig中开启RT_USING_AUDIO_SERVER。目前Audio Server以库的形式提供，有如下三个库：

```
libAudio_server_gcc.a       支持本地或网络mp3、wav播放，支持wav录音，需开启RT_USING_NET_HTTP
libAudio_server_gcc_cpu.a   支持本地mp3、wav、opus播放，支持wav、opus录音，编解码跑在cpu上
libAudio_server_gcc_dsp.a   支持本地mp3、wav、opus播放，支持wav、opus录音，编解码跑在dsp上，
                            需开启RT_USING_DSP，并使用rkdsp_fw_opus.h替换rkdsp_fw.h
```

编辑third_party/audio/audio_server/SConscript中的`libs = ['libAudio_server_gcc']`指定所使用的库。

#### 播放

需要在menuconfig中开启AUDIO_ENABLE_PLAYER_TEST。

播放测试函数的实现在third_party/audio/audio_server/player_test.c。

测试命令如下：

```
create_player -D es8311p -r 48000
              -D 必选项，指定声卡，默认为es8311p
              -r 可选项，指定重采样率，支持16k、44.1k、48k
start_player -f <filepath>
             -f 必选项，指定文件路径
stop_player
delete_player
```

调用create_player后即可使用start_player和stop_player开始播放或停止播放，delete_player删除播放器。

注：如需使用某一声卡播放，请确认相关宏已配置，并使用list_device查看是否存在对应设备，录音设备以`c`结尾，放音设备以`p`结尾。

#### 录音

需要在menuconfig中开启AUDIO_ENABLE_RECORDER_TEST。

录音测试函数的实现在third_party/audio/audio_server/recorder_test.c。

测试命令如下：

```
record_start test.wav -D pdmc -r 16000 -c 2 -l 10
             必选项，命令后第一个参数认作文件名
             -D 必选项，指定声卡
             -r 可选项，指定采样率
             -c 可选项，指定通道数
             -l 可选项，指定是否自动循环录音及循环周期，新文件会覆盖旧文件，时长单位s
record_stop
```

### Tinycap和Tinyplay

需要在menuconfig中开启RT_USING_COMMON_TEST_AUDIO。

函数的具体实现在bsp/rockchip/common/test目录下的tinycap.c和tinyplay.c。该命令仅支持wav文件的录放。

测试命令如下：

```
tinycap test.wav -D pdmc -r 16000 -b 16 -c 2 -t 5 -p 1024 -n 4
        必选项，命令后第一个参数认作文件名
        -D 必选项，指定声卡
        -r 可选项，指定采样率
        -b 可选项，指定位深
        -c 可选项，指定通道数
        -t 可选项，指定录音时长
        -p 可选项，指定DMA帧大小
        -n 可选项，指定DMA帧数
tinyplay test.wav -D audpwmp -t 5 -p 1024 -n 4
        必选项，命令后第一个参数认作文件名
        -D 必选项，指定声卡
        -t 可选项，指定播放时长
        -p 可选项，指定DMA帧大小
        -n 可选项，指定DMA帧数
```

