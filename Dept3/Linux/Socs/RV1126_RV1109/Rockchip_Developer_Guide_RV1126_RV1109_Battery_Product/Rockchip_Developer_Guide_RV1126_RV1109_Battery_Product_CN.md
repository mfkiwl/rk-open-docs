# RV1126/RV1109 低功耗/快速启动产品开发指南

文档标识：RK-JC-YF-***

发布版本：V1.0.0

日期：2020-12-12

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2020 瑞芯微电子股份有限公司**

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

本文主要描述了RV1126/RV1109 Linux SDK用来开发低功耗/快速启动相关产品的技术要点，希望能够帮助客户快速上手开发低功耗相关产品，比如：电池IPC、智能门铃、智能猫眼、智能门锁等。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RV1126/RV1109   | Linux 4.19 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

- 技术支持工程师
- 软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0 | Zhichao Yu, Ziyuan Xu, Hans Yang, Tao Huang | 2020-12-22 | 初始版本     |

---

**目录**

[TOC]

---

## 产品方案基本介绍

### 低功耗产品方案介绍

​    低功耗带电池产品都有一个共同特点就是在用电池的情况下，需要使用的时间长达半年甚至一年的时间。目前已经有很多非常类似的产品，比如：电池IPC、智能猫眼、智能门铃、人脸门锁等等。

​    为了延长电池使用时间，在做这类产品的时候我们就要求，设备不工作时SoC必须处于关机状态，DDR也完全掉电。当外部条件（比如PIR或者Wi-Fi远程唤醒）触发的时候，通过快速冷启动的方式，快速进入到工作模式。所以冷启动时间也成为了这种产品非常关键的指标。

​    RV1126/RV1109芯片采用14nm工艺，运行电压0.8V，功耗和温升相比前一代的芯片都有极大的提升。另外，RV1126/RV1109内部有专门针对快速启动做了硬件优化设计，可以极大得降低快速启动时间，比如RV1126/RV1109芯片内置硬件解压缩模块，可以快速解压rootfs和kernel。

### RV1126/RV1109开发低功耗产品方案的优势

- 14nm制程，运行电压低，功耗低；
- 快速冷启动，250ms快速抓拍，350ms可以启动应用服务；
- ISP2.0，去噪模块强化，可以实现暗光全彩；
- 支持H264 Smart编码，可以实现更低的码率更高的画质；
- 支持Wi-Fi低功耗保活和远程唤醒机制；
- 支持全双工语音对讲，支持语音3A算法；
- 目前支持阿里云、涂鸦等云平台；

### 电池IPC产品框图

​    基于目前RV1126/RV1109芯片，开发电池IPC产品的框图如下：

![](./resources/battery-ipc-diagram.png)

## RV1126/RV1109快速启动SDK介绍

### 快速启动/低功耗软件框架基本介绍

#### 基础板级配置介绍

TBD

#### 镜像分区说明

ramboot打包方式说明，TBD

## 快速启动

   RV1126/RV1109系列芯片内置硬件解压缩模块，可以极大得提升系统启动速度。另外，RV1126/RV1109内置一个MCU，MCU在SoC上电后就会快速启动，迅速初始化Camera和ISP，然后尽可能快得把前几帧图像保存下来。本章主要介绍了RV1126/RV1109快速启动的优化方法和注意事项。

### 快速启动基本流程

TBD

​    从图中的基本流程可以看到，快速启动版本的启动流程是没有跑uboot的，kernel、rootfs以及MCU的系统均通过SPL加载。其中kernel的配置的经过极大的裁剪，rootfs也是经过精简的。

### SPL快速启动流程介绍（底层同事）

TBD

### 硬件解压缩机制（底层同事）

TBD

### 驱动并行加载机制（底层同事）

TBD

### kernel裁剪

   快速启动的kernel是通过kernel的config fragment机制来裁剪的。

### rootfs裁剪

TBD

### 快速抓拍

​    设备上电后，MCU会立即对Camera进行采集前几帧的数据进DDR中。设备系统启动完成后，可由应用主动送该数据到ISP+ISPP进行处理。ISP/ISPP从DDR读取RKRAW数据进行处理的机制，我们称之为离线帧处理。

#### MCU启动机制（孙传虎）

TBD

#### 离线帧处理（池琳）

TBD

### 快速启动硬件设计注意事项

​    不同的Flash对启动速度有比较明显的影响，因为Flash的读取速度直接影响到rootfs镜像以及算法模型的读取时间。这里列出每一种Flash读取速度，以及参考启动时间，客户在进行产品设计的时候需要综合考虑成本，存储大小，启动速度等因素进行谨慎选择：

| 存储类型                 | 读取速度 | 参考启动时间 | 参考板级配置          |
| ------------------------ | -------- | ------------ | --------------------- |
| eMMC                     | 120MB/S  | TBD          | BoardConfig-tb-v13.mk |
| SPI Nor Flash（4线模式） | TBD      | TBD          | TBD                   |
| SPI Nand Flash           | TBD      | TBD          | TBD                   |

## 功耗优化

​    我们在设计低功耗电池产品方案的时候，功耗是一个非常重要的指标。本章节会重点介绍，在功耗优化面，我们有哪些方法和注意事项。

### 功耗优化方法介绍

TBD

### 系统带宽评估

TBD

### 功耗优化硬件设计注意事项

#### 硬件选型指引

​    开发低功耗产品的时候，外设功耗也是需要我们重点评估的，为了帮助客户整体方案上能够快速达到低功耗的效果，我们提供了目前我们认为功耗比较低的器件列表，客户可以根据自身产品情况来选择（其他没有在这里列出的外设，不代表我们不支持，只是它们的功耗属于正常水平，不需要额外列出）：

**Camera选型列表**

| Sensor型号 | 分辨率 | 参考功耗 |
| ---------- | ------ | -------- |
| SC210IoT   | 200M   | 63mW     |
| GC2053     | 200M   | 93mW     |
|            |        |          |

**Wi-Fi选型列表**

| Wi-Fi型号 | 低功耗保活功耗 | Wi-Fi推流功耗 |
| --------- | -------------- | ------------- |
| CYW43438  | TBD            | TBD           |
| AP6203    | TBD            | TBD           |
| Hi3861    | TBD            | TBD           |
| ABTM6441  | TBD            | TBD           |
| T2        | TBD            | TBD           |

​    注意：以上Wi-Fi低功耗保活功耗都是在屏蔽房，DTIM=10的情况下测试，在正常环境下测试功耗会更高。

## 快速启动功能扩展

​    快速启动的配置都是经过极大精简的，客户在调试的时候难免会遇到各种问题，比如一些库或者工具没有。调试的便利性和rootfs镜像大小是矛盾的关系，想要达到最快的启动速度，肯定会增加产品调试和开发的难度。因此，本章就需要着重介绍，一些客户常用的功能如何使能和配置。

### 快速启动增加MiniGUI支持

TBD

### 快速启动增加双目Camera支持（王智华）

TBD

### busybox定制化配置（许自缘）

TBD

### 常用调试方法使能

#### adb使能（王增征）

TBD

#### iperf使能（许自缘）

TBD

#### gdb使能（许自缘）

TBD

## Wi-Fi低功耗保活和远程唤醒

​    低功耗电池产品，非常注重产品的便携性。因此这类产品往往使用Wi-Fi来传输控制命令或者视频流数据。设备在不工作的时候，SoC处于掉电关机状态，此时为了让设备处于在线状态，Wi-Fi必须处于低功耗保活模式。Wi-Fi在低功耗保活模式下会定时唤醒接收来自云端的唤醒包。当用户需要通过手机查看设备端视频的时候，云端会发送唤醒包给Wi-Fi，Wi-Fi收到唤醒包之后，会通过GPIO给SoC上电，然后SoC快速启动把视频流推送给用户。

   Wi-Fi低功耗保活和远程唤醒的基本流程如下：

   TBD

   本章会着重介绍低功耗电池产品Wi-Fi开发相关内容。

### Wi-Fi配网

​    目前RV1126/RV1109实现了以下几种配网方式：

- 命令行配网；
- 二维码配网；

#### 命令行配网（肖垚）

#### 二维码配网

**1. 二维码的使用**

请详见[Rockchip_Instruction_Linux_Battery_IPC_CN](../RV1126_RV1109/Rockchip_Instruction_Linux_Battery_IPC)。

**2. 二维码扫描设备端接口介绍**

请详见[Rockchip_Instruction_Qrcode_CN](../Rockchip_RV1126_RV1109_Qrcode/Rockchip_Instruction_Qrcode_CN.md)

### Wi-Fi低功耗保活（肖垚）

TBD

### Wi-Fi远程唤醒（肖垚）

TBD

## 云平台对接

​    目前瑞芯微的低功耗产品方案对接了两种云平台：阿里云、涂鸦。本章节的内容旨在给客户提供一个指引，帮助客户快速上手对接云平台。

### 阿里云对接说明

请参考[Link Visual设备端开发-Linux SDK](#https://help.aliyun.com/document_detail/131156.html?spm=a2c4g.11186623.6.697.11e73a09g9L0XO)。

## 误唤醒优化方法

### PIR性能优化

TBD

### 通过AI过滤误唤醒

#### AI算法适配

目前支持人形检测和人脸检测，已经集成在mediaserver中，在mediaserver的conf中配置相应的flow即可使用。

人形的例子：

```json
    "Flow_1": {
        "flow_index": {
            "flow_index_name": "rocktest_0",
            "flow_type": "io",
            "in_slot_index_of_down": "0",
            "out_slot_index": "0",
            "stream_type": "filter",
            "upflow_index_name": "source_0"
        },
        "flow_name": "filter",
        "flow_param": {
            "input_data_type": "image:nv12",
            "output_data_type": "image:nv12",
            "name": "rockx_filter"
        },
        "stream_param": {
            "enable": "1",
            "input_data_type": "image:nv12",
            "rockx_model": "rockx_object_detect"
        }
    }
```

人脸的例子：

```json
 "Flow_1": {
      "flow_index": {
        "flow_index_name": "rockx_0",
        "flow_type": "io",
        "in_slot_index_of_down": "0",
        "out_slot_index": "0",
        "stream_type": "filter",
        "upflow_index_name": "rga_0"
      },
      "flow_name": "filter",
      "flow_param": {
        "name": "rockx_filter",
        "output_data_type": "image:rgb888"
      },
      "stream_param": {
        "enable": "1",
        "input_data_type": "image:rgb888",
        "rockx_model": "rockx_face_detect"
      }
    }
```

#### Vendor分区

Vendor分区是指在 Flash 上划分出来用于存放Vendor数据的区域。开发者通过相关写号PC工具可以给该分区写入相关的Vendor数据，重启后或者掉电该分区数据不会丢失。可以通过相关接口读取该分区的数据用来做显示或者其他用途。如果整片擦除flash将会清除该分区中所写入的Vendor数据。

目前Vendor分区主要用作两个用途，存放设备四元组证书和wifi信息。

**注意事项：目前每台设备需要先烧录四元组证书，才能成功连云。使用工具为SDK根目录下的tools\windows\RKDevInfoWriteTool，需要保证每台设备的四元组唯一且已在云端添加。**

Vendor分区ID 255，用于保存阿里云认证所需的四元组。样例如下：

`{"product_key":"a139oQFoEu6","product_secret":"LKDLOI0nJmp8m7aH","device_name":"rk10","device_secret":"77d2838182fbb2f32acc4e9298612989"}`

Vendor分区ID 30，用于保存wifi信息，加快联网速度。样例如下：

`1,fanxing,12345678,192.168.1.122,255.255.255.0,192.168.1.1,192.168.1.1`

### 开机自启脚本

### OEM、Data分区打包

## 软件功能接口（林刘迪铭）

### ISP

详细请参考docs/Socs/RV1126_RV1109/Camera/Rockchip_Development_Guide_ISP2x_CN_v1.5.0.pdf。

初始化与反初始化的示例代码如下：

```c
char *iq_file_dir = "/etc/iqfiles/";
rk_aiq_working_mode_t enWDRMode = RK_AIQ_WORKING_MODE_NORMAL;
rk_aiq_sys_ctx_t *aiq_ctx;
rk_aiq_static_info_t aiq_static_info;

//枚举AIQ获取到的静态信息。
rk_aiq_uapi_sysctl_enumStaticMetas(0, &aiq_static_info);
printf("sensor_name is %s, iqfiles is %s\n", aiq_static_info.sensor_info.sensor_name, iq_file_dir);

// 初始化AIQ上下文。
aiq_ctx = rk_aiq_uapi_sysctl_init(aiq_static_info.sensor_info.sensor_name,iq_file_dir, NULL, NULL);
// 准备AIQ运行环境。
if (rk_aiq_uapi_sysctl_prepare(aiq_ctx, 0, 0, enWDRMode)) {
    printf("rkaiq engine prepare failed !\n");
    return -1;
}
printf("rk_aiq_uapi_sysctl_init/prepare succeed\n");
// 启动AIQ控制系统。AIQ启动后，会不断的从ISP驱动获取3A统计信息，运行3A算法，并应用计算出的新参数。
if (rk_aiq_uapi_sysctl_start(aiq_ctx)) {
    printf("rk_aiq_uapi_sysctl_start  failed\n");
    return -1;
}
printf("rk_aiq_uapi_sysctl_start succeed\n");

while (true) {
    // 主程序
}

//反初始化
if (!aiq_ctx)
    return -1;
// 停止AIQ控制系统。
rk_aiq_uapi_sysctl_stop(aiq_ctx, false);
// 反初始化AIQ上下文环境。
rk_aiq_uapi_sysctl_deinit(aiq_ctx);
aiq_ctx = NULL;
```

### Video

详细请参考docs/Socs/RV1126_RV1109/Multimedia/Rockchip_Instructions_Linux_Rkmedia_CN.pdf。

一般数据流为 ISP→VI→VENC→网络推流或本地保存。

#### VI

初始化与反初始化的示例代码如下：

```c
VI_CHN_ATTR_S vi_chn_attr;
vi_chn_attr.pcVideoNode = "rkispp_scale1";
vi_chn_attr.u32BufCnt = 4;
vi_chn_attr.u32Width = 720;
vi_chn_attr.u32Height = 576;
vi_chn_attr.enPixFmt = IMAGE_TYPE_NV12;
vi_chn_attr.enWorkMode = VI_WORK_MODE_NORMAL;
VI_PIPE ViPipe = 0;
VI_CHN ViChn = 0;

// vi init
RK_MPI_VI_SetChnAttr(ViPipe, ViChn, vi_chn_attr);
RK_MPI_VI_EnableChn(ViPipe, ViChn);

// vi deinit
RK_MPI_VI_DisableChn(ViPipe, ViChn);
```

#### VENC

初始化与反初始化的示例代码如下：

```c
VENC_CHN_ATTR_S venc_chn_attr;
venc_chn_attr.stVencAttr.enType = RK_CODEC_TYPE_H264;
venc_chn_attr.stVencAttr.imageType = IMAGE_TYPE_NV12;
venc_chn_attr.stVencAttr.u32PicWidth = 720;
venc_chn_attr.stVencAttr.u32PicHeight = 576;
venc_chn_attr.stVencAttr.u32VirWidth = 720;
venc_chn_attr.stVencAttr.u32VirHeight = 576;
venc_chn_attr.stVencAttr.u32Profile = 77;
venc_chn_attr.stRcAttr.enRcMode = VENC_RC_MODE_H264CBR;
venc_chn_attr.stRcAttr.stH264Cbr.u32Gop = 30;
venc_chn_attr.stRcAttr.stH264Cbr.u32BitRate = 720 * 576 * 30 / 14;
venc_chn_attr.stRcAttr.stH264Cbr.fr32DstFrameRateDen = 1;
venc_chn_attr.stRcAttr.stH264Cbr.fr32DstFrameRateNum = 30;
venc_chn_attr.stRcAttr.stH264Cbr.u32SrcFrameRateDen = 1;
venc_chn_attr.stRcAttr.stH264Cbr.u32SrcFrameRateNum = 30;
// venc init
RK_MPI_VENC_CreateChn(0, &venc_chn_attr);

// venc deinit
RK_MPI_VENC_DestroyChn(VencChn);
```

VENC从VI获取数据目前有两种方式：

1.使用RK_MPI_SYS_Bind(&ViChn, &VencChn)函数，数据流将自动从VI流向VENC。**但注意反初始化时要用RK_MPI_SYS_UnBind先解绑**，然后先销毁Venc再销毁Vi。

2.VI的工作模式设为VI_WORK_MODE_GOD_MODE。可使用RK_MPI_SYS_RegisterOutCb在VI的输出回调函数中，发送buffer给VENC处理。或者主动调用RK_MPI_SYS_GetMediaBuffer，从VI通道获取buffer再调用RK_MPI_SYS_SendMediaBuffer给VENC处理。**此方式可以将VI→VENC的通路改为VI→画框→VENC，或者一路VI送给多路VENC处理。**

VENC的输出数据也可以使用RK_MPI_SYS_RegisterOutCb或RK_MPI_SYS_GetMediaBuffer，由用户自行进行处理。

### Audio

详细请参考docs/Socs/RV1126_RV1109/Multimedia/Rockchip_Instructions_Linux_Rkmedia_CN.pdf。

一般数据流有capture和playback两种：

capture：AI→AENC→网络推流或本地保存。

playback：网络接收流或读取本地文件→ADEC→AO。

#### AI和VQE

初始化与反初始化的示例代码如下：

```c
mpp_chn_ai.enModId = RK_ID_AI;
mpp_chn_ai.s32ChnId = 0;
AI_CHN_ATTR_S ai_attr;
ai_attr.pcAudioNode = "default";
ai_attr.enSampleFormat = RK_SAMPLE_FMT_S16;
ai_attr.u32NbSamples = 1024;
ai_attr.u32SampleRate = 16000;
ai_attr.u32Channels = 1;
ai_attr.enAiLayout = AI_LAYOUT_MIC_REF;

// AI init
RK_MPI_AI_SetChnAttr(mpp_chn_ai.s32ChnId, &ai_attr);
RK_MPI_AI_EnableChn(mpp_chn_ai.s32ChnId);
// VQE Enable
AI_TALKVQE_CONFIG_S stAiVqeTalkAttr;
memset(&stAiVqeTalkAttr, 0, sizeof(AI_TALKVQE_CONFIG_S));
stAiVqeTalkAttr.s32WorkSampleRate = 16000;
stAiVqeTalkAttr.s32FrameSample = 320;
stAiVqeTalkAttr.aParamFilePath = "/usr/share/rkap_aec/para/16k/RKAP_AecPara.bin";
stAiVqeTalkAttr.u32OpenMask = AI_TALKVQE_MASK_AEC | AI_TALKVQE_MASK_ANR | AI_TALKVQE_MASK_AGC;
RK_MPI_AI_SetTalkVqeAttr(mpp_chn_ai.s32ChnId, &stAiVqeTalkAttr);
RK_MPI_AI_EnableVqe(mpp_chn_ai.s32ChnId);

// VQE Disable
RK_MPI_AI_DisableVqe(mpp_chn_ai.s32ChnId);
// AI Disable
RK_MPI_AI_DisableChn(mpp_chn_ai.s32ChnId);
```

#### AENC

初始化与反初始化的示例代码如下：

```c
mpp_chn_aenc.enModId = RK_ID_AENC;
mpp_chn_aenc.s32ChnId = 0;
AENC_CHN_ATTR_S aenc_attr;
aenc_attr.enCodecType = RK_CODEC_TYPE_AAC;
aenc_attr.u32Bitrate = 64000;
aenc_attr.u32Quality = 1;
aenc_attr.stAencAAC.u32Channels = 1;
aenc_attr.stAencAAC.u32SampleRate = 16000;
// AENC init
RK_MPI_AENC_CreateChn(mpp_chn_aenc.s32ChnId, &aenc_attr);

// AENC deinit
RK_MPI_AENC_DestroyChn(mpp_chn_aenc.s32ChnId);
```

绑定使用RK_MPI_SYS_Bind(&mpp_chn_ai, &mpp_chn_aenc)即可。

反初始化时，需要先RK_MPI_SYS_UnBind(&mpp_chn_ai, &mpp_chn_aenc)。

#### ADEC

初始化与反初始化的示例代码如下：

```c
mpp_chn_adec.enModId = RK_ID_ADEC;
mpp_chn_adec.s32ChnId = 0;
ADEC_CHN_ATTR_S stAdecAttr;
stAdecAttr.enCodecType = RK_CODEC_TYPE_AAC;
if (stAdecAttr.enCodecType == G711A) {
	stAdecAttr.stAdecG711A.u32Channels = 1;
    stAdecAttr.stAdecG711A.u32SampleRate = 16000;
}
// ADEC init
RK_MPI_ADEC_CreateChn(mpp_chn_adec.s32ChnId, &stAdecAttr);

// ADEC deinit
RK_MPI_ADEC_DestroyChn(mpp_chn_adec.s32ChnId);
```

#### AO

初始化与反初始化的示例代码如下：

```c
mpp_chn_ao.enModId = RK_ID_AO;
mpp_chn_ao.s32ChnId = 0;
AO_CHN_ATTR_S stAoAttr;
stAoAttr.u32Channels = 1;
stAoAttr.u32SampleRate = 16000;
stAoAttr.u32NbSamples = 1024;
stAoAttr.pcAudioNode = "default";
stAoAttr.enSampleFormat = RK_SAMPLE_FMT_S16;
stAoAttr.u32NbSamples = 1024;
// AO init
RK_MPI_AO_SetChnAttr(mpp_chn_ao.s32ChnId, &stAoAttr);
RK_MPI_AO_EnableChn(mpp_chn_ao.s32ChnId);

// AO deinit
RK_MPI_AO_DisableChn(mpp_chn_ao.s32ChnId);
```

绑定使用RK_MPI_SYS_Bind(&mpp_chn_adec, &mpp_chn_ao)即可。

反初始化时，需要先RK_MPI_SYS_UnBind(&mpp_chn_adec, &mpp_chn_ao)。



