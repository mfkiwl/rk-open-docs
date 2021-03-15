# CGI API

文件标识：RK-SM-YF-383

发布版本：V1.0.1

日期：2021-03-15

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2021 瑞芯微电子股份有限公司**

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

本文提供CGI程序API输入输出介绍。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RV1126, RV1109 | Linux 4.19   |
| RK1808, RK1806 | Linux 4.4 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | Allen Chen | 2020-08-29 | 初始版本     |
| V1.0.1 | Ruby Zhang | 2021-03-15 | 完善产品版本信息 |

---

**目录**

[TOC]

---

## 须知

1.本文中所提供URL均省略<http://{{IP}}/cgi-bin/entry.cgi>，实际使用过程中需自行添加。

2.除/system/login 以及 /system/para/webPage 外，访问其他URL需携带login返回cookie。

3.request提供请求体需携带的信息示例，response中提供返回结果示例。

4.API是否对设备生效，详见docs/Linux/ApplicationNote/《Rockchip_Instructions_Linux_Web_Configuration》中对应功能是否生效。

## 常用功能导航

| **功能** | 说明 |
| ---------- | --------|
| [登录](#login) | 登录，并获取cookie。                                          |
| 用户管理 | [用户注册，修改，删除](#login)。  |
| [获取视频流](#stream-url) | 获取各个码流的RTSP/RTMP URL。                                 |
| [重启](#reboot) | 重启设备。                                                    |
| [恢复出厂设置](#factory-reset) | 数据库恢复出厂配置。                                          |
| [远程升级](#firmware-upgrade) | 1.申请断点续传id；<br>2.[查询剩余容量是否满足升级](#remain-space)；<br>3.断点续传上传升级文件；<br>4.发送完成信号；<br>5.[发送查询信号检测是否完成升级](#remain-space)；<br>6.删除升级文件。 |
| [获取/配置视频编码](#video) | 获取以及配置视频编码参数，如分辨率、图像质量、编码。         |
| [获取/配置局域网](#lan) | 获取和配置局域网，如IP，子网掩码。                         |
| WiFi配置 | 1.[WiFi基础配置](#wlan)；<br>2.[WiFi信息及连接](#Wi-Fi)。     |
| [端口设置](#network-port) | 获取及配置设备端口。           |
| [时间设置](#network-ntp) | 获取及配置设备时间，如时区，设备时间。   |
| [ISP配置](#isp) | 获取/设置isp，包含图像调节、曝光、<br>日夜转换、高动态、白平衡、<br>图像增强、视频调整等设置。 |
| [OSD字符](#overlays) | OSD字符样式，字符内容的获取与配置。 |

---

| **功能** | 说明 |
| ---------- | --------|
| [OSD隐私遮盖](#privacy-mask) | 获取及配置OSD隐私遮盖参数。 |
| [OSD图片遮盖](#image) | 1.上传遮盖图片；<br>2.获取设置图片遮盖参数。 |
| [音频设置](#audio) | 音频参数的获取和设置。 |
| 截图 | 1.[主码流实时截图](#take-photo)；<br>2.[截图记录查询](#search)。 |
| 录像                           | 1.主码流实时录像[开始](#start-record)/[结束](#stop-record)；<br>2.[录像查询](#search)；<br>3.[录像计划配置](#schedules)；<br>说明：若实时录像与计划冲突将会被终止。 |
| 人脸注册 | 1.[人脸检测以及人脸识别开启](#smart)；<br>2.注册信息上传并获取照片上传地址<br>（API：[/event/face](#face)， 携带note信息为undone）；<br>3.[人脸照片上传](#face-picture)；<br>4.人脸照片上传完成确认<br>（API：[/event/face](#face)， 携带note信息为空）；<br>说明：批量注册需[查询待处理照片数](#face-waiting)，<br>当待处理照片大于10时，<br>需等待处理buff后再上传。 |
| 人脸信息查询/管理 | 1.[注册人员清单](#face-list)；<br>2.[抓拍记录](#snapshot-record)<br>3.[控制记录](#control-record) |

---

## system

### <span id="login">login</span>

```shell
# GET /system/login 获取登录用户信息
# response iAuthLevel：认证等级（暂无使用），iUserLevel：用户权限（0管理员，1操作员，2普通用户），id：数据库id，sUserName：用户名
[
    {
        "iAuthLevel": 1,
        "iUserLevel": 0,
        "id": 0,
        "sUserName": "admin"
    }
]

# PUT/POST /system/login?expire 用户登录，cookie有效期一小时
# PUT/POST /system/login?expire=day 用户登录，cookie有效期一天
# PUT/POST /system/login?expire=week 用户登录，cookie有效期一周
# PUT/POST /system/login?expire=month 用户登录，cookie有效期一个月
# request sUserName：用户名，sPassword：密码（base64加密）
{
    "sUserName": "admin",
    "sPassword": "YWRtaW4="
}
# response auth：用户权限，status：登录状态（大于等于0为成功，-1密码错误，-2用户不存在）
# 登录成功后set-cookie中携带验证所需cookie
{
    "auth": 0,
    "status": 0
}

# PUT/POST /system/login/add 用户密码添加
# request sUserName：管理员用户名，sPassword：管理员密码（base64加密），newUserName：新用户名，newPassword：新用户密码（base64加密），secondNewPw：二次确认密码（base64加密），iUserLevel：用户权限
{
    "sUserName":"admin",
    "sPassword":"YWRtaW4=",
    "newUserName":"test",
    "newPassword":"dGVzdA==",
    "secondNewPw":"dGVzdA==",
    "iUserLevel":1
}
# respons status：注册状态（-2注册成功，>=0用户名重复）
{"status":-2}

# PUT/POST /system/login/modify 用户密码修改
# request 同/system/login/add
{
    "sUserName":"admin",
    "sPassword":"YWRtaW4=",
    "newUserName":"test",
    "newPassword":"dGVzdA==",
    "secondNewPw":"dGVzdA==",
    "iUserLevel":1
}
# respons status：修改状态（>=0注册成功，-2用户名不存在）
{"status":2}

# PUT/POST /system/login/delete 用户删除（管理员不可删除）
# request 管理员用户名，sPassword：管理员密码（base64加密），newUserName：删除用户名
{
    "sUserName":"admin",
    "sPassword":"YWRudWI=",
    "newUserName":"test"
}
# respons status：修改状态（>0删除成功，-2用户名不存在）
{"status":2}
```

### device-info

```shell
# GET /system/device-info 获取设备信息
# respons name：信息名称，value：信息值，ro：只读属性
[
    {
        "id": 0,
        "name": "deviceName",
        "ro": "false",
        "value": "RK IP Camera"
    },
    {
        "id": 1,
        "name": "telecontrolID",
        "ro": "false",
        "value": "88"
    },
    {
        "id": 2,
        "name": "model",
        "ro": "true",
        "value": "RK-003"
    },
    {
        "id": 3,
        "name": "serialNumber",
        "ro": "true",
        "value": "RK-003-A"
    },
    {
        "id": 4,
        "name": "firmwareVersion",
        "ro": "true",
        "value": "V0.2.6 build 200413"
    },
    {
        "id": 5,
        "name": "encoderVersion",
        "ro": "true",
        "value": "V1.0 build 200413"
    },
    {
        "id": 6,
        "name": "webVersion",
        "ro": "true",
        "value": "V1.12.2 build 200413"
    },
    {
        "id": 7,
        "name": "pluginVersion",
        "ro": "true",
        "value": "V1.0.0.0"
    },
    {
        "id": 8,
        "name": "channelsNumber",
        "ro": "true",
        "value": "1"
    },
    {
        "id": 9,
        "name": "hardDisksNumber",
        "ro": "true",
        "value": "1"
    },
    {
        "id": 10,
        "name": "alarmInputsNumber",
        "ro": "true",
        "value": "0"
    },
    {
        "id": 11,
        "name": "alarmOutputsNumber",
        "ro": "true",
        "value": "0"
    },
    {
        "id": 12,
        "name": "firmwareVersionInfo",
        "ro": "true",
        "value": "CP-3-B"
    },
    {
        "id": 13,
        "name": "manufacturer",
        "ro": "true",
        "value": "Rockchip"
    },
    {
        "id": 14,
        "name": "hardwareId",
        "ro": "true",
        "value": "c3d9b8674f4b94f6"
    }
]

# PUT/POST /system/device-info 修改设备信息
# requeset 修改的数据单元信息
{
    "id":1,
    "name":"telecontrolID",
    "value":"88",
    "ro":"false"
}
# response 修改后的数据单元信息
{
    "id":1,
    "name":"telecontrolID",
    "value":"88",
    "ro":"false"
}
```

### <span id="remain-space">remain-space</span>

```shell
# GET /system/remain-space 获取设备userdata剩余空间
# response 剩余空间，单位bytes
{
    "availableDisk": 1026608128
}
```

### para

```shell
# GET /system/remain-space/key 获取设备能力集 key为数据库SystemPara中的name
# response 为能力集json字符（即数据库SystemPara中的para），可转为json对象
```

### <span id="firmware-upgrade">firmware-upgrade</span>

```shell
# GET /system/firmware-upgrade?upload-type=resumable 断点续传id申请
# requeset
null
# response Headers/X-Location中携带申请到的id
Headers: X-Location: http://{{IP}}/cgi-bin/entry.cgi/system/firmware-upgrade?id=0

# POST/PUT /system/firmware-upgrade?id=0 升级断点续传，id为文件编号
# requeset
Headers: Content-Range: bytes 524288-1048575 #文件写入的起始和结束位置
Headers: Content-Type: text/plain
Body: text/plain 数据，大小小于1M
# response 当前文件写入情况
{"range":"bytes 0-1572863"}

# POST/PUT /system/firmware-upgrade?start=id id为数字，代表升级文件的断点续传id，开始系统升级
# requeset
null
# response 将无响应，超时后开始等待升级完成

# DELETE /system/firmware-upgrade?id=0 删除升级文件
```

### <span id="reboot">reboot</span>

```shell
# POST/PUT /system/reboot 重启
# requeset
null
```

### <span id="factory-reset">factory-reset</span>

```shell
# POST/PUT /system/factory-reset 恢复出厂设置
# requeset
null
```

### export-log

```shell
# POST/PUT /system/export-log 导出log
# requeset
null
# response log地址
{"location":"http://172.16.21.106/userdata/export.log"}
```

### import-db

```shell
# POST/PUT /system/import-db 上传数据库
# requeset 数据类型为multipart/form-data
Header:content-Type: multipart/form-data
Form Data：文件数据
# response
{}

# POST/PUT /system/import-db?start=1 开始导入数据库，并重启
# requeset
null
```

## <span id="video">video</span>

```shell
# GET /video 获取全部视频编码配置
#response iGOP：I帧间隔，iMaxRate：码率上限，iMinRate：码率下限，iStreamSmooth：码流平滑，TargetRate：目标码率，sFrameRate：视频帧率，sFrameRateIn：输入帧率，sH264Profile：编码复杂度，sOutputDataType：视频编码，sRCMode：码率类型，sRCQuality：图像质量，sResolution：分辨率，SVC：SVC开关，Smart：Smart开关，sStreamType：码流类型，sVideoType：视频类型，其余为数据token
[
    {
        "iGOP": 50,
        "iMaxRate": 8192,
        "iMinRate": 0,
        "iStreamSmooth": 50,
        "iTargetRate": 0,
        "id": 0,
        "sFrameRate": "25",
        "sFrameRateIn": "25",
        "sH264Profile": "high",
        "sOutputDataType": "H.265",
        "sRCMode": "CBR",
        "sRCQuality": "high",
        "sResolution": "2688*1520",
        "sSVC": "close",
        "Smart": "close",
        "sStreamType": "mainStream",
        "sVideoEncoderConfigurationName": "VideoEncoder_0",
        "sVideoEncoderConfigurationToken": "VideoEncoderToken_0",
        "sVideoSourceToken": "VideoSource_0",
        "sVideoType": "compositeStream"
    },
    {
        "iGOP": 50,
        "iMaxRate": 1024,
        "iMinRate": 0,
        "iStreamSmooth": 50,
        "iTargetRate": 0,
        "id": 1,
        "sFrameRate": "25",
        "sFrameRateIn": "25",
        "sH264Profile": "high",
        "sOutputDataType": "H.264",
        "sRCMode": "CBR",
        "sRCQuality": "high",
        "sResolution": "640*480",
        "sSVC": "close",
        "sSmart": "close",
        "sStreamType": "subStream",
        "sVideoEncoderConfigurationName": "VideoEncoder_1",
        "sVideoEncoderConfigurationToken": "VideoEncoderToken_1",
        "sVideoSourceToken": "VideoSource_0",
        "sVideoType": "compositeStream"
    },
    {
        "iGOP": 50,
        "iMaxRate": 2048,
        "iMinRate": 0,
        "iStreamSmooth": 50,
        "iTargetRate": 0,
        "id": 2,
        "sFrameRate": "25",
        "sFrameRateIn": "25",
        "sH264Profile": "high",
        "sOutputDataType": "H.265",
        "sRCMode": "CBR",
        "sRCQuality": "high",
        "sResolution": "1920*1080",
        "sSVC": "close",
        "sSmart": "close",
        "sStreamType": "thirdStream",
        "sVideoEncoderConfigurationName": "VideoEncoder_2",
        "sVideoEncoderConfigurationToken": "VideoEncoderToken_2",
        "sVideoSourceToken": "VideoSource_0",
        "sVideoType": "compositeStream"
    }
]

# GET /video/id 获取对应id视频编码配置，id需为0-2数字
#response 返回GET /video中单个id数据

# POST/PUT /video/id 配置对应id视频编码参数，id需为0-2数字
# requset 传入上述数据单元json
# response 得到设置完后数据单元json
```

### region-clip

```shell
# GET /video/2/region-clip 获取区域裁剪配置
# response normalizedScreenSize：归一化尺寸，regionClip：区域裁剪参数
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "regionClip": {
        "iHeight": 480,
        "iPositionX": 0,
        "iPositionY": 0,
        "iRegionClipEnabled": 0,
        "iWidth": 640
    }
}
```

### advanced-enc

```shell
# GET /video/0/advanced-enc 获取高级编码参数默认值
# response
[
    {
        "id": 0,
        "sFunction": "qp",
        "sParameters": "{\"qp_init\":24,\"qp_step\":4,\"qp_min\":12,\"qp_max\":48,\"min_i_qp\":10,\"max_i_qp\":20}",
        "sStreamType": "mainStream"
    },
    {
        "id": 1,
        "sFunction": "split",
        "sParameters": "{\"mode\":0,\"size\":1024}",
        "sStreamType": "mainStream"
    }
]
```

## <span id="stream-url">stream-url</span>

```shell
# GET /video/stream-url 获取RTSP/RTMP视频流地址
# response
[
    {
        "id":0,
        "sStreamProtocol":"RTSP",
        "sURL":"rtsp://172.16.21.106:554/mainstream"
    },
    {
        "id":1,
        "sStreamProtocol":"RTMP",
        "sURL":"rtmp://172.16.21.106:1935/live/substream"
    },
    {
        "id":2,
        "sStreamProtocol":"RTMP",
        "sURL":"rtmp://172.16.21.106:1935/live/thirdstream"
    }
]

# POST/PUT /video/stream-url/id 设置视频流协议
# request
{
    "sStreamProtocol":"RTSP",
}
# response
{
    "id":0,
    "sStreamProtocol":"RTSP",
    "sURL":"rtsp://172.16.21.106:554/mainstream"
}
```

## storage

### hdd-list

```shell
# GET /storage/hdd-list 获取所有磁盘信息
# response
[
    {
        "iFormatProg":0,
        "iFormatStatus":0,
        "iFreeSize":0,
        "iMediaSize":0,
        "iTotalSize":0,
        "id":1,
        "sDev":"",
        "sFormatErr":"",
        "sMountPath":"/mnt/sdcard",
        "sName":"SD Card",
        "sStatus":"unmounted",
        "sType":""
    },
    {
        "iFormatProg":0,
        "iFormatStatus":0,
        "iFreeSize":12.0438613891602,
        "iMediaSize":60972,
        "iTotalSize":12.1327171325684,
        "id":3,
        "sAttributes":"rw",
        "sDev":"/dev/block/by-name/media",
        "sFormatErr":"",
        "sMountPath":"/userdata/media",
        "sName":"Emmc",
        "sStatus":"mounted",
        "sType":"ext2"
    },
    {
        "iFormatProg":0,
        "iFormatStatus":0,
        "iFreeSize":0,
        "iMediaSize":0,
        "iTotalSize":0,
        "id":2,
        "sDev":"",
        "sFormatErr":"",
        "sMountPath":"/media/usb0",
        "sName":"U Disk",
        "sStatus":"unmounted",
        "sType":""
    }
]

# GET /storage/hdd-list/id id为数字，获取对应id磁盘信息
# response
{
    "iFormatProg":0,
    "iFormatStatus":0,
    "iFreeSize":0,
    "iMediaSize":0,
    "iTotalSize":0,
    "id":2,
    "sDev":"",
    "sFormatErr":"",
    "sMountPath":"/media/usb0",
    "sName":"U Disk",
    "sStatus":"unmounted",
    "sType":""
}
```

### quota

```shell
# GET /storage/quota 获取磁盘配额信息
# response
[
    {
        "iFreePictureQuota": 0.0,
        "iFreeVideoQuota": 0.0,
        "iPictureQuotaRatio": 5,
        "iTotalPictureVolume": 0.0,
        "iTotalVideoVolume": 0.0,
        "iVideoQuotaRatio": 45,
        "id": 1
    },
    {
        "iFreePictureQuota": 0.595100224018097,
        "iFreeVideoQuota": 5.42329835891724,
        "iPictureQuotaRatio": 5,
        "iTotalPictureVolume": 0.606635868549347,
        "iTotalVideoVolume": 5.45972299575806,
        "iVideoQuotaRatio": 45,
        "id": 2
    },
    {
        "iFreePictureQuota": 0.0,
        "iFreeVideoQuota": 0.0,
        "iPictureQuotaRatio": 5,
        "iTotalPictureVolume": 0.0,
        "iTotalVideoVolume": 0.0,
        "iVideoQuotaRatio": 45,
        "id": 3
    }
]

# GET /storage/quota/id id为数字，获取对应id磁盘配额信息
# response
{
    "iFreePictureQuota": 0.595100224018097,
    "iFreeVideoQuota": 5.42329835891724,
    "iPictureQuotaRatio": 5,
    "iTotalPictureVolume": 0.606635868549347,
    "iTotalVideoVolume": 5.45972299575806,
    "iVideoQuotaRatio": 45,
    "id": 2
}

# POST/PUT /storage/quota/id id为数字，设置对应id磁盘配额信息，并切换存储磁盘为id对应磁盘
# request
{
    "id":3,
    "iPictureQuotaRatio":5,
    "iVideoQuotaRatio":45
}
# response
{
    "iFreePictureQuota":0,
    "iFreeVideoQuota":0,
    "iPictureQuotaRatio":5,
    "iTotalPictureVolume":0,
    "iTotalVideoVolume":0,
    "iVideoQuotaRatio":45,
    "id":3
}
```

### snap-plan

```shell
# GET /storage/snap-plan/id id为数字，获取对应id的计划抓图参数
# response
{
    "iEnabled": 0,
    "iImageQuality": 10,
    "iShotInterval": 1000,
    "iShotNumber": 4,
    "sImageType": "JPEG",
    "sResolution": "2688*1520"
}

# POST/PUT /storage/snap-plan/id id为数字，配置对应id的计划抓图参数
# request
{
    "iEnabled":0,
    "sImageType":"JPEG",
    "sResolution":"2688*1520",
    "iImageQuality":10,
    "iShotInterval":10000
}
# response
{
    "iEnabled":0,
    "iImageQuality":10,
    "iShotInterval":10000,
    "sImageType":"JPEG",
    "sResolution":"2688*1520"
}
```

### current-path

```shell
# GET /storage/current-path 获取当前存储路径
# response
{
    "sMountPath": "/userdata/media"
}
```

### format

```shell
# POST/PUT /storage/format/id id为数字，格式化该id对应的磁盘
# requset
null
# response
{}
```

### <span id="search">search</span>

```shell
# POST/PUT /storage/search 查询录像/抓图存储记录
# request 查询条件，maxResults：返回的查询结果最大数目，searchResultPosition：返回查询结果的开始位置，order：0正序查询，1逆序查询
{
    "searchType":"video0",
    "startTime":"1970-01-01T00:00:00",
    "endTime":"2020-08-29T23:59:59",
    "maxResults":20,
    "searchResultPosition：返回查询结果的开始位置，":0,
    "order":0
}
# response
{
    "matchList":[
        {
			"fileAddress":"http://172.16.21.106//main_20200715200714_1.mp4",
            "fileId":0,
            "fileName":"main_20200715200714_1.mp4",
            "fileSize":0.82734203338623,
            "fileTime":"2020-07-15T20:07:16"
        },
        {
            "fileAddress":"http://172.16.21.106/main_20200715200335_6.mp4",
            "fileId":1,
            "fileName":"main_20200715200335_6.mp4",
            "fileSize":0.00182342529296875,
            "fileTime":"2020-07-15T20:03:35"
        }
    ],
    "numOfMatches":2
}
```

### advance-para

```shell
# GET /storage/advance-para/0 获取计划录像配置参数
{
    "iEnabled": 0,
    "id": 0
}

# POST/PUT /storage/advance-para/0 配置计划录像参数
# request
{
    "iEnabled": 1,
    "id": 0
}
# response
{
    "iEnabled": 1,
    "id": 0
}
```

### delete

```shell
# POST/PUT /storage/delete 删除指定类型的抓图/录像
# requset
{
    "type":"photo0",
    "name":[
        "main_19700101_085333_2.jpeg",
        "main_19700101_080219_1.jpeg"
    ]
}
# response 1成功删除，0删除失败
{"rst":1}
```

## roi

```shell
# GET /roi 获取所有码流的roi信息
# response
{
    "ROIRegionList": [
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 1,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "mainStream"
        },
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 2,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "mainStream"
        },
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 1,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "subStream"
        },
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 2,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "subStream"
        },
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 1,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "thirdStream"
        },
        {
            "iHeight": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iQualityLevelOfROI": 3,
            "iROIEnabled": 0,
            "iROIId": 2,
            "iStreamEnabled": 0,
            "iWidth": 0,
            "sName": "test",
            "sStreamType": "thirdStream"
        }
    ],
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}

# GET /roi/main-stream 获取主码流的roi信息
# GET /roi/subStream 获取子码流的roi信息
# GET /roi/thirdStream 获取第三码流的roi信息
# response
[
    {
        "iHeight": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iQualityLevelOfROI": 3,
        "iROIEnabled": 0,
        "iROIId": 1,
        "iStreamEnabled": 0,
        "iWidth": 0,
        "sName": "test",
        "sStreamType": "mainStream"
    },
    {
        "iHeight": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iQualityLevelOfROI": 3,
        "iROIEnabled": 0,
        "iROIId": 2,
        "iStreamEnabled": 0,
        "iWidth": 0,
        "sName": "test",
        "sStreamType": "mainStream"
    }
]

# GET /roi/main-stream/id 获得主码流对应id的roi信息，其他码流可参考此URL
# response
{
    "iHeight": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iQualityLevelOfROI": 3,
    "iROIEnabled": 0,
    "iROIId": 1,
    "iStreamEnabled": 0,
    "iWidth": 0,
    "sName": "test",
    "sStreamType": "mainStream"
}

# PUT/POST /roi/main-stream/id 配置主码流对应id的roi，其他码流可参考此URL
# request
{
    "iHeight": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iQualityLevelOfROI": 3,
    "iROIEnabled": 1,
    "iROIId": 1,
    "iStreamEnabled": 0,
    "iWidth": 0,
    "sName": "test",
    "sStreamType": "mainStream"
}
# response
{
    "iHeight": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iQualityLevelOfROI": 3,
    "iROIEnabled": 1,
    "iROIId": 1,
    "iStreamEnabled": 0,
    "iWidth": 0,
    "sName": "test",
    "sStreamType": "mainStream"
}
```

## peripherals

### gate

```shell
# GET /peripherals/gate 获取闸机外设配置
# response
{
    "relay": {
        "iDuration": 500,
        "iEnable": 0,
        "iIOIndex": 0,
        "iValidLevel": 1,
        "id": 0
    },
    "weigen": {
        "iDuration": 0,
        "iEnable": 0,
        "iWiegandBit": 26,
        "id": 0
    }
}

# POST/PUT /peripherals/gate 配置闸机参数
# request
{
    "relay": {
        "iDuration": 500,
        "iEnable": 0,
        "iIOIndex": 0,
        "iValidLevel": 1,
        "id": 0
    },
    "weigen": {
        "iDuration": 0,
        "iEnable": 0,
        "iWiegandBit": 26,
        "id": 0
    }
}
# response
{
    "relay": {
        "iDuration": 500,
        "iEnable": 0,
        "iIOIndex": 0,
        "iValidLevel": 1,
        "id": 0
    },
    "weigen": {
        "iDuration": 0,
        "iEnable": 0,
        "iWiegandBit": 26,
        "id": 0
    }
}
```

### fill-light

```shell
# GET /peripherals/fill-light 获取补光灯外设配置
# response
{
    "iNormalBrightness": 50,
    "iSaveEnergyBrightness": 50,
    "iSaveEnergyEnable": 0,
    "id": 0
}

# POST/PUT /peripherals/fill-light 配置补光灯参数
# request
{
    "iNormalBrightness": 50,
    "iSaveEnergyBrightness": 50,
    "iSaveEnergyEnable": 0,
    "id": 0
}
# response
{
    "iNormalBrightness": 50,
    "iSaveEnergyBrightness": 50,
    "iSaveEnergyEnable": 0,
    "id": 0
}
```

## osd

### <span id="overlays">overlays</span>

```shell
# GET /osd/overlays 获取OSD叠加配置
# response
{
    "attribute": {
        "iBoundary": 0,
        "sAlignment": "customize",
        "sOSDAttribute": "transparent/not-flashing",
        "sOSDFontSize": "32*32",
        "sOSDFrontColor": "fff799",
        "sOSDFrontColorMode": "customize"
    },
    "channelNameOverlay": {
        "iChannelNameOverlayEnabled": 1,
        "iPositionX": 560,
        "iPositionY": 432,
        "sChannelName": "Camera 01"
    },
    "characterOverlay": [
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 0,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 1,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 2,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 3,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 4,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 5,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 6,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 7,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        }
    ],
    "dateTimeOverlay": {
        "iDateTimeOverlayEnabled": 1,
        "iDisplayWeekEnabled": 1,
        "iPositionX": 16,
        "iPositionY": 16,
        "sDateStyle": "CHR-YYYY-MM-DD",
        "sTimeStyle": "24hour"
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}

# POST/PUT /osd/overlays 配置OSD叠加
# request
{
    "attribute": {
        "iBoundary": 0,
        "sAlignment": "customize",
        "sOSDAttribute": "transparent/not-flashing",
        "sOSDFontSize": "32*32",
        "sOSDFrontColor": "fff799",
        "sOSDFrontColorMode": "customize"
    },
    "channelNameOverlay": {
        "iChannelNameOverlayEnabled": 1,
        "iPositionX": 560,
        "iPositionY": 432,
        "sChannelName": "Camera 01"
    },
    "characterOverlay": [
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 0,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 1,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 2,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 3,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 4,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 5,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 6,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 7,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        }
    ],
    "dateTimeOverlay": {
        "iDateTimeOverlayEnabled": 1,
        "iDisplayWeekEnabled": 1,
        "iPositionX": 16,
        "iPositionY": 16,
        "sDateStyle": "CHR-YYYY-MM-DD",
        "sTimeStyle": "24hour"
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}
# response
{
    "attribute": {
        "iBoundary": 0,
        "sAlignment": "customize",
        "sOSDAttribute": "transparent/not-flashing",
        "sOSDFontSize": "32*32",
        "sOSDFrontColor": "fff799",
        "sOSDFrontColorMode": "customize"
    },
    "channelNameOverlay": {
        "iChannelNameOverlayEnabled": 1,
        "iPositionX": 560,
        "iPositionY": 432,
        "sChannelName": "Camera 01"
    },
    "characterOverlay": [
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 0,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 1,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 2,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 3,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 4,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 5,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 6,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        },
        {
            "iPositionX": 0,
            "iPositionY": 0,
            "iTextOverlayEnabled": 0,
            "id": 7,
            "sDisplayText": "",
            "sIsPersistentText": "true"
        }
    ],
    "dateTimeOverlay": {
        "iDateTimeOverlayEnabled": 1,
        "iDisplayWeekEnabled": 1,
        "iPositionX": 16,
        "iPositionY": 16,
        "sDateStyle": "CHR-YYYY-MM-DD",
        "sTimeStyle": "24hour"
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}
```

### <span id="osd-image">image</span>

```shell
# GET /osd/image 获取图像遮盖配置
# response
{
    "imageOverlay": {
        "iImageHeight": 80,
        "iImageOverlayEnabled": 1,
        "iImageWidth": 160,
        "iPositionX": 16,
        "iPositionY": 388,
        "iTransparentColorEnabled": 0
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}

# POST/PUT /osd/image 配置图像遮盖
# request
{
    "imageOverlay": {
        "iImageHeight": 80,
        "iImageOverlayEnabled": 1,
        "iImageWidth": 160,
        "iPositionX": 16,
        "iPositionY": 388,
        "iTransparentColorEnabled": 0
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}
# response
{
    "imageOverlay": {
        "iImageHeight": 80,
        "iImageOverlayEnabled": 1,
        "iImageWidth": 160,
        "iPositionX": 16,
        "iPositionY": 388,
        "iTransparentColorEnabled": 0
    },
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    }
}

# POST/PUT image/picture 设置遮盖图像
# request 图像须为64bit，宽高16对齐，大小小于256KB的bmp图像，传输格式如下
Content-Type: multipart/form-data
# response
{}
```

### <span id="privacy-mask">privacy-mask</span>

```shell
# GET /osd/privacy-mask 获取隐私遮盖配置
# response
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "privacyMask": [
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 0
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 1
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 2
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 3
        }
    ]
}

# POST/PUT /osd/privacy-mask 配置隐私遮盖
# request
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "privacyMask": [
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 0
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 1
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 2
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 3
        }
    ]
}
# response
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "privacyMask": [
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 0
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 1
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 2
        },
        {
            "iMaskHeight": 0,
            "iMaskWidth": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iPrivacyMaskEnabled": 0,
            "id": 3
        }
    ]
}
```

## network

### <span id="lan">lan</span>

```shell
# GET /network/lan 获取局域网配置
# response
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"dhcp",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "iDuplex":1,
        "iNicSpeed":1000,
        "iPower":1,
        "sAddress":"fa:40:a4:8b:ad:57",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
        "sInterface":"eth0",
        "sNicSpeed":"Auto",
        "sNicSpeedSupport":"Auto 10baseT/Half 10baseT/Full 100baseT/Half 100baseT/Full 1000baseT/Full "
    }
}

# POST/PUT /network/lan 配置局域网，自动获取IP
# request
{
    "ipv4":{
        "sV4Method":"dhcp"
    },
    "link":{
        "sNicSpeed":"Auto",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
    }
}
# response
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"dhcp",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "iDuplex":1,
        "iNicSpeed":1000,
        "iPower":1,
        "sAddress":"fa:40:a4:8b:ad:57",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
        "sInterface":"eth0",
        "sNicSpeed":"Auto",
        "sNicSpeedSupport":"Auto 10baseT/Half 10baseT/Full 100baseT/Half 100baseT/Full 1000baseT/Full "
    }
}

# POST/PUT /network/lan 配置局域网，手动设置IP
# request
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"manaual",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "sNicSpeed":"Auto",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
    }
}
# response
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"manaual",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "iDuplex":1,
        "iNicSpeed":1000,
        "iPower":1,
        "sAddress":"fa:40:a4:8b:ad:57",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
        "sInterface":"eth0",
        "sNicSpeed":"Auto",
        "sNicSpeedSupport":"Auto 10baseT/Half 10baseT/Full 100baseT/Half 100baseT/Full 1000baseT/Full "
    }
}
```

### <span id="wlan">wlan</span>

```shell
# GET /network/wlan 获取无线局域网配置，示例中为未连接Wi-Fi时的配置
# response
{
    "ipv4":{
        "sV4Address":"",
        "sV4Gateway":"",
        "sV4Method":"dhcp",
        "sV4Netmask":""
    },
    "link":{
        "iDuplex":-1,
        "iNicSpeed":-1,
        "iPower":0,
        "sAddress":"c0:84:7d:e1:ce:00",
        "sDNS1":"",
        "sDNS2":"",
        "sInterface":"wlan0",
        "sNicSpeed":""
    }
}

# POST/PUT /network/wlan 配置局域网，自动获取IP
# request
{
    "ipv4":{
        "sV4Method":"dhcp"
    },
    "link":{
        "sDNS1":"",
        "sDNS2":"",
    }
}
# response 为未连接Wi-Fi时的配置
{
    "ipv4":{
        "sV4Address":"",
        "sV4Gateway":"",
        "sV4Method":"dhcp",
        "sV4Netmask":""
    },
    "link":{
        "iDuplex":-1,
        "iNicSpeed":-1,
        "iPower":0,
        "sAddress":"c0:84:7d:e1:ce:00",
        "sDNS1":"",
        "sDNS2":"",
        "sInterface":"wlan0",
        "sNicSpeed":""
    }
}

# POST/PUT /network/wlan 配置局域网，手动设置IP
# request
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"manaual",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
    }
}
# response 为未连接Wi-Fi时的配置
{
    "ipv4":{
        "sV4Address":"172.16.21.106",
        "sV4Gateway":"172.16.21.1",
        "sV4Method":"manaual",
        "sV4Netmask":"255.255.255.0"
    },
    "link":{
        "iDuplex":-1,
        "iNicSpeed":-1,
        "iPower":0,
        "sAddress":"c0:84:7d:e1:ce:00",
        "sDNS1":"10.10.10.188",
        "sDNS2":"58.22.96.66",
        "sInterface":"wlan0",
        "sNicSpeed":""
    }
}
```

### <span id="Wi-Fi">Wi-Fi</span>

```shell
# GET /network/wifi 获取Wi-Fi配置
# response
{
    "iPower":0,
    "id":1,
    "sType":"wifi"
}

# POST/PUT /network/wifi?power=on 开启Wi-Fi
# request
null
# response
{
    "iPower":1,
    "id":1,
    "sType":"wifi"
}

# POST/PUT /network/wifi?power=off 关闭Wi-Fi
# request
null
# response
{
    "iPower":0,
    "id":1,
    "sType":"wifi"
}

# POST/PUT /network/wifi 连接Wi-Fi
# request
{
	"sName": "test",
    "sService": "sadgwegwe_sdgas",
    "sPassword": "test",
    "iFavorite": 1,
    "iAutoconnect": 1,
    "sState": "ready",
}
# response
{}

# DELETE /network/wifi?service=sadgwegwe_sdgas 删除Wi-Fi连接设置
# response
{}
```

### wifi-list

```shell
# GET /network/wifi-list 获取扫描到的Wi-Fi列表
# response
[
	{
        "Favorite": 1,
        "Strength": 90,
        "sName": "test"
        "sSecurity": "psk";
        "sService": "sadgwegwe_sdgas";
        "sState": "ready";
        "sType": "wifi";
	}
]
```

## <span id="network-ntp">network-ntp</span>

```shell
# GET /network-ntp 获取时间设置
# response
{
    "iAutoDst":0,
    "iAutoMode":1,
    "iRefreshTime":60,
    "id":0,
    "sNtpServers":"122.224.9.29 94.130.49.186",
    "sTimeZone":"ChinaStandardTime-8",
    "sTimeZoneFile":"posix/Etc/GMT-8",
    "sTimeZoneFileDst":"posix/Asia/Shanghai"
}

# PUT/POST /network-ntp 配置时间参数
# request
{
    "iAutoDst":0,
    "iAutoMode":1,
    "iRefreshTime":60,
    "id":0,
    "sNtpServers":"122.224.9.29 94.130.49.186",
    "sTimeZone":"ChinaStandardTime-8",
    "sTimeZoneFile":"posix/Etc/GMT-8",
    "sTimeZoneFileDst":"posix/Asia/Shanghai"
}
# response
{
    "iAutoDst":0,
    "iAutoMode":1,
    "iRefreshTime":60,
    "id":0,
    "sNtpServers":"122.224.9.29 94.130.49.186",
    "sTimeZone":"ChinaStandardTime-8",
    "sTimeZoneFile":"posix/Etc/GMT-8",
    "sTimeZoneFileDst":"posix/Asia/Shanghai"
}
```

### time

```shell
# GET /network-ntp/time 获取设备时间
# response
{
	"time":"2020-09-01T08:38:08"
}

# PUT/POST /network-ntp/time 设置设备时间，自动模式下无需设置
# request
{
	"time":"2020-09-01T08:38:08"
}
# response
{
	"time":"2020-09-01T08:38:08"
}
```

## <span id="network-port">network-port</span>

```shell
# GET /network-port 获取设备端口
# response
[
    {
        "iPortNo":80,
        "id":0,
        "sProtocol":"HTTP"
    },
    {
        "iPortNo":443,
        "id":1,
        "sProtocol":"HTTPS"
    },
    {
        "iPortNo":8080,
        "id":2,
        "sProtocol":"DEV_MANAGE"
    },
    {
        "iPortNo":554,
        "id":3,
        "sProtocol":"RTSP"
    },
    {
        "iPortNo":1935,
        "id":4,
        "sProtocol":"RTMP"
    }
]

# PUT/POST /network-port/id id为数字，对应获取到的端口id，设置端口
# request
{
    "iPortNo":80,
    "id":0,
    "sProtocol":"HTTP"
}
# response
{
    "iPortNo":80,
    "id":0,
    "sProtocol":"HTTP"
}
```

## <span id="isp">image</span>

```shell
# GET /image 获取ISP配置全部信息
# response
[
    {
        "BLC": {
            "iBLCRegionHeight": 92,
            "iBLCRegionWidth": 120,
            "iHDRLevel": 50,
            "iHLCLevel": 0,
            "iPositionX": 0,
            "iPositionY": 0,
            "iWDRLevel": 0,
            "sBLCRegion": "close",
            "sHDR": "open",
            "sHLC": "close",
            "sWDR": "close"
        },
        "exposure": {
            "iAutoIrisLevel": 5,
            "iExposureGain": 1,
            "sExposureTime": "1/6",
            "sIrisType": "auto"
        },
        "id": 0,
        "imageAdjustment": {
            "iBrightness": 50,
            "iContrast": 50,
            "iSaturation": 50,
            "iSharpness": 50
        },
        "imageEnhancement": {
            "iDehazeLevel": 0,
            "iDenoiseLevel": 0,
            "iImageRotation": 0,
            "iSpatialDenoiseLevel": 0,
            "iTemporalDenoiseLevel": 0,
            "sDIS": "close",
            "sDehaze": "close",
            "sFEC": "close",
            "sGrayScaleMode": "[0-255]",
            "sNoiseReduceMode": "general"
        },
        "nightToDay": {
            "iDistanceLevel": 1,
            "iLightBrightness": 1,
            "iNightToDayFilterLevel": 5,
            "iNightToDayFilterTime": 5,
            "sBeginTime": "07:00:00",
            "sBrightnessAdjustmentMode": "auto",
            "sEndTime": "18:00:00",
            "sFillLightMode": "IR",
            "sIrcutFilterAction": "day",
            "sNightToDay": "auto",
            "sOverexposeSuppress": "open",
            "sOverexposeSuppressType": "auto"
        },
        "videoAdjustment": {
            "sImageFlip": "close",
            "sPowerLineFrequencyMode": "PAL(50HZ)",
            "sSceneMode": "indoor"
        },
        "whiteBlance": {
            "iWhiteBalanceBlue": 50,
            "iWhiteBalanceRed": 50,
            "sWhiteBlanceStyle": "autoWhiteBalance"
        }
    }
]
```

### id

```shell
# GET /image/id id为数字，获取对应通道的ISP配置信息
# response
{
    "BLC": {
        "iBLCRegionHeight": 92,
        "iBLCRegionWidth": 120,
        "iHDRLevel": 50,
        "iHLCLevel": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iWDRLevel": 0,
        "sBLCRegion": "close",
        "sHDR": "open",
        "sHLC": "close",
        "sWDR": "close"
    },
    "exposure": {
        "iAutoIrisLevel": 5,
        "iExposureGain": 1,
        "sExposureTime": "1/6",
        "sIrisType": "auto"
    },
    "id": 0,
    "imageAdjustment": {
        "iBrightness": 50,
        "iContrast": 50,
        "iSaturation": 50,
        "iSharpness": 50
    },
    "imageEnhancement": {
        "iDehazeLevel": 0,
        "iDenoiseLevel": 0,
        "iImageRotation": 0,
        "iSpatialDenoiseLevel": 0,
        "iTemporalDenoiseLevel": 0,
        "sDIS": "close",
        "sDehaze": "close",
        "sFEC": "close",
        "sGrayScaleMode": "[0-255]",
        "sNoiseReduceMode": "general"
    },
    "nightToDay": {
        "iDistanceLevel": 1,
        "iLightBrightness": 1,
        "iNightToDayFilterLevel": 5,
        "iNightToDayFilterTime": 5,
        "sBeginTime": "07:00:00",
        "sBrightnessAdjustmentMode": "auto",
        "sEndTime": "18:00:00",
        "sFillLightMode": "IR",
        "sIrcutFilterAction": "day",
        "sNightToDay": "auto",
        "sOverexposeSuppress": "open",
        "sOverexposeSuppressType": "auto"
    },
    "videoAdjustment": {
        "sImageFlip": "close",
        "sPowerLineFrequencyMode": "PAL(50HZ)",
        "sSceneMode": "indoor"
    },
    "whiteBlance": {
        "iWhiteBalanceBlue": 50,
        "iWhiteBalanceRed": 50,
        "sWhiteBlanceStyle": "autoWhiteBalance"
    }
}

# POST/PUT /image/id id为数字，配置对应通道的ISP信息
# request
{
    "BLC": {
        "iBLCRegionHeight": 92,
        "iBLCRegionWidth": 120,
        "iHDRLevel": 50,
        "iHLCLevel": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iWDRLevel": 0,
        "sBLCRegion": "close",
        "sHDR": "open",
        "sHLC": "close",
        "sWDR": "close"
    },
    "exposure": {
        "iAutoIrisLevel": 5,
        "iExposureGain": 1,
        "sExposureTime": "1/6",
        "sIrisType": "auto"
    },
    "id": 0,
    "imageAdjustment": {
        "iBrightness": 50,
        "iContrast": 50,
        "iSaturation": 50,
        "iSharpness": 50
    },
    "imageEnhancement": {
        "iDehazeLevel": 0,
        "iDenoiseLevel": 0,
        "iImageRotation": 0,
        "iSpatialDenoiseLevel": 0,
        "iTemporalDenoiseLevel": 0,
        "sDIS": "close",
        "sDehaze": "close",
        "sFEC": "close",
        "sGrayScaleMode": "[0-255]",
        "sNoiseReduceMode": "general"
    },
    "nightToDay": {
        "iDistanceLevel": 1,
        "iLightBrightness": 1,
        "iNightToDayFilterLevel": 5,
        "iNightToDayFilterTime": 5,
        "sBeginTime": "07:00:00",
        "sBrightnessAdjustmentMode": "auto",
        "sEndTime": "18:00:00",
        "sFillLightMode": "IR",
        "sIrcutFilterAction": "day",
        "sNightToDay": "auto",
        "sOverexposeSuppress": "open",
        "sOverexposeSuppressType": "auto"
    },
    "videoAdjustment": {
        "sImageFlip": "close",
        "sPowerLineFrequencyMode": "PAL(50HZ)",
        "sSceneMode": "indoor"
    },
    "whiteBlance": {
        "iWhiteBalanceBlue": 50,
        "iWhiteBalanceRed": 50,
        "sWhiteBlanceStyle": "autoWhiteBalance"
    }
}
# response
{
    "BLC": {
        "iBLCRegionHeight": 92,
        "iBLCRegionWidth": 120,
        "iHDRLevel": 50,
        "iHLCLevel": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iWDRLevel": 0,
        "sBLCRegion": "close",
        "sHDR": "open",
        "sHLC": "close",
        "sWDR": "close"
    },
    "exposure": {
        "iAutoIrisLevel": 5,
        "iExposureGain": 1,
        "sExposureTime": "1/6",
        "sIrisType": "auto"
    },
    "id": 0,
    "imageAdjustment": {
        "iBrightness": 50,
        "iContrast": 50,
        "iSaturation": 50,
        "iSharpness": 50
    },
    "imageEnhancement": {
        "iDehazeLevel": 0,
        "iDenoiseLevel": 0,
        "iImageRotation": 0,
        "iSpatialDenoiseLevel": 0,
        "iTemporalDenoiseLevel": 0,
        "sDIS": "close",
        "sDehaze": "close",
        "sFEC": "close",
        "sGrayScaleMode": "[0-255]",
        "sNoiseReduceMode": "general"
    },
    "nightToDay": {
        "iDistanceLevel": 1,
        "iLightBrightness": 1,
        "iNightToDayFilterLevel": 5,
        "iNightToDayFilterTime": 5,
        "sBeginTime": "07:00:00",
        "sBrightnessAdjustmentMode": "auto",
        "sEndTime": "18:00:00",
        "sFillLightMode": "IR",
        "sIrcutFilterAction": "day",
        "sNightToDay": "auto",
        "sOverexposeSuppress": "open",
        "sOverexposeSuppressType": "auto"
    },
    "videoAdjustment": {
        "sImageFlip": "close",
        "sPowerLineFrequencyMode": "PAL(50HZ)",
        "sSceneMode": "indoor"
    },
    "whiteBlance": {
        "iWhiteBalanceBlue": 50,
        "iWhiteBalanceRed": 50,
        "sWhiteBlanceStyle": "autoWhiteBalance"
    }
}

# GET /image/id/type id为数字，获取对应通道的ISP配置对应type信息，以/image/0/blc为例
# response
{
    "iBLCRegionHeight": 92,
    "iBLCRegionWidth": 120,
    "iHDRLevel": 50,
    "iHLCLevel": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iWDRLevel": 0,
    "sBLCRegion": "close",
    "sHDR": "open",
    "sHLC": "close",
    "sWDR": "close"
}

# POST/PUT /image/id/type id为数字，配置对应通道的ISP对应type信息，以/image/0/blc为例
# request
{
    "iBLCRegionHeight": 92,
    "iBLCRegionWidth": 120,
    "iHDRLevel": 50,
    "iHLCLevel": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iWDRLevel": 0,
    "sBLCRegion": "close",
    "sHDR": "open",
    "sHLC": "close",
    "sWDR": "close"
}
# response
{
    "iBLCRegionHeight": 92,
    "iBLCRegionWidth": 120,
    "iHDRLevel": 50,
    "iHLCLevel": 0,
    "iPositionX": 0,
    "iPositionY": 0,
    "iWDRLevel": 0,
    "sBLCRegion": "close",
    "sHDR": "open",
    "sHLC": "close",
    "sWDR": "close"
}
```

## event

### triggers

```shell
# GET /event/triggers/vmd_0 获取移动侦测联动方式配置
# response
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 0,
    "sEventType": "VMD"
}

# POST/PUT /event/triggers/vmd_0 配置移动侦测联动方式
# request
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 0,
    "sEventType": "VMD"
}
# response
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 0,
    "sEventType": "VMD"
}

# GET /event/triggers/vri_0 获取区域入侵联动方式配置
# response
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 1,
    "sEventType": "VRI"
}

# POST/PUT /event/triggers/vri_0 配置区域入侵联动方式
# request
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 0,
    "sEventType": "VMD"
}
# response
{
    "iNotificationCenterEnabled": 0,
    "iNotificationEmailEnabled": 0,
    "iNotificationFTPEnabled": 0,
    "iNotificationIO1Enabled": 0,
    "iNotificationRecord1Enabled": 0,
    "iVideoInputChannelID": 0,
    "id": 0,
    "sEventType": "VMD"
}
```

### <span id="schedules">schedules</span>

```shell
# GET /event/schedules/motion 获取移动侦测布防时间配置
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# POST/PUT /event/schedules/motion 配置移动侦测布防时间
# request json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# GET /event/schedules/intrusion 获取区域入侵布防时间配置
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# POST/PUT /event/schedules/motion 配置区域入侵布防时间
# request json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# GET /event/schedules/video-plan 获取录像计划布防时间配置
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# POST/PUT /event/schedules/motion 配置录像计划布防时间
# request json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# GET /event/schedules/screenshot 获取抓图计划布防时间配置
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}

# POST/PUT /event/schedules/motion 配置抓图计划布防时间
# request json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}
# response json字符串
{
    "sSchedulesJson": "[[],[],[],[],[],[],[]]"
}
```

下述为sSchedulesJson解析方式：

eg：[[{"start":0.3134548611111111,"end":0.6328993055555551,"type":"timing"}],[],[],[],[],[],[]]"

1.整体为一个json数组包含7个json小数组，小数组按顺序代表星期一至星期日的布防时间配置；

2.每个小数组中包含最多8个字典，为布防单元，单元中的浮点数为布防时间秒数/24小时秒数得到，如开始时间为早上8点，则start为(8×60×60)/(24×60×60) = 0.3333333333333333；

3.type为布防类型，除录像计划/抓图计划外其他布防单元不携带type；

### motion-detection

```shell
# GET /event/motion-detection/0 获取移动侦测配置
# response
{
    "iColumnGranularity": 22,
    "iEndTriggerTime": 500,
    "iHighlightEnabled": 0,
    "iMotionDetectionEnabled": 0,
    "iRowGranularity": 18,
    "iSamplingInterval": 2,
    "iSensitivityLevel": 1,
    "iStartTriggerTime": 500,
    "id": 0,
    "sGridMap": "",
    "sRegionType": "grid"
}

# POST/PUT /event/motion-detection/0 配置移动侦测
# request sGridMap为16进制布防区域，需将其转为二进制。从左至右从上至下，罗列于iColumnGranularity*iRowGranularity个单元格内，0表示该单元格不进行移动侦测检测，1表示进行。全部单元格布满所有可检测区域。
{
    "iColumnGranularity": 22,
    "iEndTriggerTime": 500,
    "iHighlightEnabled": 0,
    "iMotionDetectionEnabled": 0,
    "iRowGranularity": 18,
    "iSamplingInterval": 2,
    "iSensitivityLevel": 1,
    "iStartTriggerTime": 500,
    "id": 0,
    "sGridMap": "00000000000000000000000000000000000007f80007f80007f80007f80007f80007f80007f80007f800000000000000000000000000",
    "sRegionType": "grid"
}
# response
{
    "iColumnGranularity": 22,
    "iEndTriggerTime": 500,
    "iHighlightEnabled": 0,
    "iMotionDetectionEnabled": 0,
    "iRowGranularity": 18,
    "iSamplingInterval": 2,
    "iSensitivityLevel": 1,
    "iStartTriggerTime": 500,
    "id": 0,
    "sGridMap": "",
    "sRegionType": "grid"
}
```

### regional-invasion

```shell
# GET /event/regional-invasion/0 获取区域入侵配置
# response
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "regionalInvasion": {
        "iEnabled": 0,
        "iHeight": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iProportion": 0,
        "iSensitivityLevel": 50,
        "iTimeThreshold": 0,
        "iWidth": 0
    }
}

# POST/PUT /event/regional-invasion/0 配置区域入侵
# request
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "regionalInvasion": {
        "iEnabled": 0,
        "iHeight": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iProportion": 0,
        "iSensitivityLevel": 50,
        "iTimeThreshold": 0,
        "iWidth": 0
    }
}
# response
{
    "normalizedScreenSize": {
        "iNormalizedScreenHeight": 480,
        "iNormalizedScreenWidth": 704
    },
    "regionalInvasion": {
        "iEnabled": 0,
        "iHeight": 0,
        "iPositionX": 0,
        "iPositionY": 0,
        "iProportion": 0,
        "iSensitivityLevel": 50,
        "iTimeThreshold": 0,
        "iWidth": 0
    }
}
```

### <span id="face-list">face-list</span>

```shell
# GET /event/face-list 获取所有已注册人脸信息
# response
[
    {
        "iAccessCardNumber": 11,
        "iAge": 50,
        "iFaceDBId": 1,
        "iLoadCompleted": 1,
        "id": 0,
        "sAddress": "",
        "sBirthday": "1970-01-01",
        "sCertificateNumber": "",
        "sCertificateType": "identityCard",
        "sGender": "male",
        "sHometown": "",
        "sListType": "permanent",
        "sName": "test",
        "sNation": "汉族",
        "sNote": "",
        "sPicturePath": "/userdata/media/white_list/test_0.jpg",
        "sRegistrationTime": "2020-08-27T16:11:06",
        "sTelephoneNumber": "",
        "sType": "whiteList"
    }
]

# POST/PUT /event/face-config?search=condition 条件查询已注册人脸信息
# request
{
    "beginTime":"1970-01-01T00:00:00",
    "endTime":"2020-08-29T23:59:59",
    "type":"all",
    "gender":"all",
    "minAge":0,
    "maxAge":100,
    "accessCardNumber":0,
    "beginPosition":0,
    "endPosition":19
}
# response
{
    "matchList":[
		{
            "iAccessCardNumber": 11,
            "iAge": 50,
            "iFaceDBId": 1,
            "iLoadCompleted": 1,
            "id": 0,
            "sAddress": "",
            "sBirthday": "1970-01-01",
            "sCertificateNumber": "",
            "sCertificateType": "identityCard",
            "sGender": "male",
            "sHometown": "",
            "sListType": "permanent",
            "sName": "test",
            "sNation": "汉族",
            "sNote": "",
            "sPicturePath": "/userdata/media/white_list/test_0.jpg",
            "sRegistrationTime": "2020-08-27T16:11:06",
            "sTelephoneNumber": "",
            "sType": "whiteList"
        }
    ],
    "numOfMatches":1
}

# POST/PUT /event/face-config?search=name 姓名模糊查询已注册人脸信息
# request
{
    "name":"t",
    "beginPosition":0,
    "endPosition":19
}
# response
{
    "matchList":[
		{
            "iAccessCardNumber": 11,
            "iAge": 50,
            "iFaceDBId": 1,
            "iLoadCompleted": 1,
            "id": 0,
            "sAddress": "",
            "sBirthday": "1970-01-01",
            "sCertificateNumber": "",
            "sCertificateType": "identityCard",
            "sGender": "male",
            "sHometown": "",
            "sListType": "permanent",
            "sName": "test",
            "sNation": "汉族",
            "sNote": "",
            "sPicturePath": "/userdata/media/white_list/test_0.jpg",
            "sRegistrationTime": "2020-08-27T16:11:06",
            "sTelephoneNumber": "",
            "sType": "whiteList"
        }
    ],
    "numOfMatches":1
}
```

### <span id="face">face</span>

```shell
# GET /event/face/id id为数字，获取对应id的人脸信息
# response
{
    "iAccessCardNumber": 11,
    "iAge": 50,
    "iFaceDBId": 1,
    "iLoadCompleted": 1,
    "id": 0,
    "sAddress": "",
    "sBirthday": "1970-01-01",
    "sCertificateNumber": "",
    "sCertificateType": "identityCard",
    "sGender": "male",
    "sHometown": "",
    "sListType": "permanent",
    "sName": "test",
    "sNation": "汉族",
    "sNote": "",
    "sPicturePath": "/userdata/media/white_list/test_0.jpg",
    "sRegistrationTime": "2020-08-27T16:11:06",
    "sTelephoneNumber": "",
    "sType": "whiteList"
}

# POST/PUT /event/face 人脸注册，返回人脸照片上传地址
# request
{
    "iAccessCardNumber":0,
    "sTelephoneNumber":"",
    "sAddress":"",
    "sBirthday":"1970-01-01",
    "sCertificateNumber":"",
    "sCertificateType":"identityCard",
    "sGender":"male",
    "sHometown":"",
    "sListType":"permanent",
    "sName":"test",
    "sNation":"汉族",
    "sNote":"undone",
    "sType":"whiteList",
    "iFaceDBId":-2
}
# response
{
    "id":2,
    "sPicturePath":"/userdata/media/white_list/test_2.jpg"
}

# POST/PUT /event/face/id id为数字，修改对应id的人脸信息
# request
{
    "iAccessCardNumber":0,
    "sTelephoneNumber":"",
    "sAddress":"",
    "sBirthday":"1970-01-01",
    "sCertificateNumber":"",
    "sCertificateType":"identityCard",
    "sGender":"male",
    "sHometown":"",
    "sListType":"permanent",
    "sName":"test",
    "sNation":"汉族",
    "sNote":"undone",
    "sType":"whiteList"
}
# response
{
    "iAccessCardNumber":0,
    "iAge":50,
    "iFaceDBId":2,
    "iLoadCompleted":1,
    "id":1,
    "sAddress":"",
    "sBirthday":"1970-01-01",
    "sCertificateNumber":"",
    "sCertificateType":"identityCard",
    "sGender":"male",
    "sHometown":"",
    "sListType":"permanent",
    "sName":"test",
    "sNation":"汉族",
    "sNote":"undone",
    "sPicturePath":"/userdata/media/white_list/test_1.jpg",
    "sRegistrationTime":"2020-08-29T16:06:52",
    "sTelephoneNumber":"",
    "sType":"whiteList"
}

# DELETE /event/face/id id为数字，删除对应id的人脸信息
# response
{}
```

### face-config

```shell
# GET /event/face-config 获取人脸参数配置（闸机）
# response
{
    "iDetectHeight": 1280,
    "iDetectWidth": 720,
    "iFaceDetectionThreshold": 55,
    "iFaceMinPixel": 144,
    "iFaceRecognitionThreshold": 50,
    "iLeftCornerX": 0,
    "iLeftCornerY": 0,
    "iLiveDetectThreshold": 50,
    "iNormalizedHeight": 1280,
    "iNormalizedWidth": 720,
    "iPromptVolume": 50,
    "id": 0,
    "sLiveDetect": "open",
    "sLiveDetectBeginTime": "00:00",
    "sLiveDetectEndTime": "23:59"
}

# POST/PUT /event/face-config 配置人脸参数
# request
{
    "iDetectHeight": 1280,
    "iDetectWidth": 720,
    "iFaceDetectionThreshold": 55,
    "iFaceMinPixel": 144,
    "iFaceRecognitionThreshold": 50,
    "iLeftCornerX": 0,
    "iLeftCornerY": 0,
    "iLiveDetectThreshold": 50,
    "iNormalizedHeight": 1280,
    "iNormalizedWidth": 720,
    "iPromptVolume": 50,
    "id": 0,
    "sLiveDetect": "open",
    "sLiveDetectBeginTime": "00:00",
    "sLiveDetectEndTime": "23:59"
}
# response
{
    "iDetectHeight": 1280,
    "iDetectWidth": 720,
    "iFaceDetectionThreshold": 55,
    "iFaceMinPixel": 144,
    "iFaceRecognitionThreshold": 50,
    "iLeftCornerX": 0,
    "iLeftCornerY": 0,
    "iLiveDetectThreshold": 50,
    "iNormalizedHeight": 1280,
    "iNormalizedWidth": 720,
    "iPromptVolume": 50,
    "id": 0,
    "sLiveDetect": "open",
    "sLiveDetectBeginTime": "00:00",
    "sLiveDetectEndTime": "23:59"
}
```

### <span id="face-waiting">face-waiting</span>

```shell
# GET /event/face-waiting 获取注册中的照片数量
# response
{
    "numOfWaiting": 0
}
```

### <span id="smart">smart</span>

```shell
# GET /event/smart/cover 获取人脸配置（IPC）
# response iFaceEnabled：人脸检测启用，iFaceRecognitionEnabled：人脸识别启用，iImageOverlayEnabled：报警抓图叠加开启，iStreamOverlayEnabled：码流叠加开启
{
    "iBodyHeightRatio": 100,
    "iFaceEnabled": 0,
    "iFaceHeightRatio": 100,
    "iFaceRecognitionEnabled": 0,
    "iImageOverlayEnabled": 0,
    "iInfoOverlayEnabled": 0,
    "iStreamOverlayEnabled": 0,
    "iWidthRatio": 100,
    "id": 0,
    "infoOverlay": [
        {
            "iEnabled": 0,
            "iOrder": 0,
            "id": 0,
            "sInfo": "",
            "sName": "deviceNum"
        },
        {
            "iEnabled": 0,
            "iOrder": 1,
            "id": 1,
            "sInfo": "",
            "sName": "snapTime"
        },
        {
            "iEnabled": 0,
            "iOrder": 2,
            "id": 2,
            "sInfo": "",
            "sName": "positonInfo"
        }
    ],
    "sImageQuality": "good",
    "sTargetImageType": "head"
}

# POST/PUT /event/smart/cover 配置人脸（IPC）
# request
{
    "iBodyHeightRatio": 100,
    "iFaceEnabled": 0,
    "iFaceHeightRatio": 100,
    "iFaceRecognitionEnabled": 0,
    "iImageOverlayEnabled": 0,
    "iInfoOverlayEnabled": 0,
    "iStreamOverlayEnabled": 0,
    "iWidthRatio": 100,
    "id": 0,
    "infoOverlay": [
        {
            "iEnabled": 0,
            "iOrder": 0,
            "id": 0,
            "sInfo": "",
            "sName": "deviceNum"
        },
        {
            "iEnabled": 0,
            "iOrder": 1,
            "id": 1,
            "sInfo": "",
            "sName": "snapTime"
        },
        {
            "iEnabled": 0,
            "iOrder": 2,
            "id": 2,
            "sInfo": "",
            "sName": "positonInfo"
        }
    ],
    "sImageQuality": "good",
    "sTargetImageType": "head"
}
# response
{
    "iBodyHeightRatio": 100,
    "iFaceEnabled": 0,
    "iFaceHeightRatio": 100,
    "iFaceRecognitionEnabled": 0,
    "iImageOverlayEnabled": 0,
    "iInfoOverlayEnabled": 0,
    "iStreamOverlayEnabled": 0,
    "iWidthRatio": 100,
    "id": 0,
    "infoOverlay": [
        {
            "iEnabled": 0,
            "iOrder": 0,
            "id": 0,
            "sInfo": "",
            "sName": "deviceNum"
        },
        {
            "iEnabled": 0,
            "iOrder": 1,
            "id": 1,
            "sInfo": "",
            "sName": "snapTime"
        },
        {
            "iEnabled": 0,
            "iOrder": 2,
            "id": 2,
            "sInfo": "",
            "sName": "positonInfo"
        }
    ],
    "sImageQuality": "good",
    "sTargetImageType": "head"
}
```

### get-record-status

```shell
# GET /event/get-record-status 获取录像状态
# response 0未录像，1录像中
0
```

### last-face

```shell
# GET /event/last-face 获取已注册人脸信息中最后一个的id
# response
{
    "id": 0
}
```

### <span id="snapshot-record">snapshot-record</span>

```shell
# POST/PUT /event/snapshot-record 条件查询抓拍记录
# request
{
    "beginTime":"1970-01-01T00:00:00",
    "endTime":"2020-08-29T23:59:59",
    "beginPosition":0,
    "endPosition":19
}
# response
{
    "matchList":[
    	"id": 0,
        "sNote": "",
        "sPicturePath": "test.jpg",
        "sStatus": "process",
        "sTime": "2020-08-27T16:11:06",
        ""sSnapshotName"": "test"
    ],
    "numOfMatches":1
}

# DELETE /event/snapshot-record/id id为数字，删除对应id的抓拍记录
# response
{}
```

### <span id="control-record">control-record</span>

```shell
# POST/PUT /event/control-record?search=condition 条件查询控制记录
# request
{
    "beginTime":"1970-01-01T00:00:00",
    "endTime":"2020-08-29T23:59:59",
    "type":"all",
    "gender":"all",
    "minAge":0,
    "maxAge":100,
    "accessCardNumber":0,
    "beginPosition":0,
    "endPosition":19
}
# response
{
    "matchList":[
		{
            "iAccessCardNumber":0,
            "iAge":50,
            "iFaceDBId":2,
            "iFaceId":2,
            "iLoadCompleted":1,
            "id":1,
            "sAddress":"",
            "sBirthday":"1970-01-01",
            "sCertificateNumber":"",
            "sCertificateType":"identityCard",
            "sGender":"male",
            "sHometown":"",
            "sListType":"permanent",
            "sName":"test",
            "sNation":"汉族",
            "sNote":"",
            "sPicturePath":"http://172.16.21.106/userdata/white_list/test_1.jpg",
            "sRegistrationTime":"2020-08-29T15:33:41",
            "sSimilarity":"0.4",
            "sSnapshotName":"",
            "sSnapshotPath":"http://172.16.21.106",
            "sStatus":"Processed",
            "sTelephoneNumber":"",
            "sTime":"2020-08-29T15:33:46",
            "sType":"whiteList"
        }
    ],
    "numOfMatches":1
}

# POST/PUT /event/control-record?search=name 姓名模糊查询控制记录
# request
{
    "name":"t",
    "beginPosition":0,
    "endPosition":19
}
# response
{
    "matchList":[
		{
            "iAccessCardNumber":0,
            "iAge":50,
            "iFaceDBId":2,
            "iFaceId":2,
            "iLoadCompleted":1,
            "id":1,
            "sAddress":"",
            "sBirthday":"1970-01-01",
            "sCertificateNumber":"",
            "sCertificateType":"identityCard",
            "sGender":"male",
            "sHometown":"",
            "sListType":"permanent",
            "sName":"test",
            "sNation":"汉族",
            "sNote":"",
            "sPicturePath":"http://172.16.21.106/userdata/white_list/test_1.jpg",
            "sRegistrationTime":"2020-08-29T15:33:41",
            "sSimilarity":"0.4",
            "sSnapshotName":"",
            "sSnapshotPath":"http://172.16.21.106",
            "sStatus":"Processed",
            "sTelephoneNumber":"",
            "sTime":"2020-08-29T15:33:46",
            "sType":"whiteList"
        }
    ],
    "numOfMatches":1
}

# DELETE /event/control-record/id id为数字，删除对应id的控制记录
# response
{}
```

### check-face

```shell
# POST/PUT /event/check-face?id=0 人脸数据检查，检查id大于0的人脸注册是否成功，若存在失败则删除并返回失败结果
# request
null
# response
[
    {
        "iLoadCompleted":-1,
        "sName":"test",
        "sPicturePath":"http://172.16.21.106/userdata/white_list/test_1.jpg",
    }
]
```

### reset-face

```shell
# POST/PUT /event/reset-face 重置人脸数据库
# request
null
# response
{}
```

### reset-snap

```shell
# POST/PUT /event/reset-snap 重置抓拍记录
# request
null
# response
{}
```

### reset-control

```shell
# POST/PUT /event/reset-control 重置控制记录
# request
null
# response
{}
```

### <span id="face-picture">face-picture</span>

```shell
# POST/PUT /event/face-picture?path=address address地址字符串，上传人脸图像
# request
Content-Type: multipart/form-data
Form Data：照片数据
# response
{}

# POST/PUT /event/face-picture?copy-path=address address地址字符串，复制人脸图像到address
# request
{
	"path": "old_address"
}
# response
{}
```

### <span id="take-photo">take-photo</span>

```shell
# POST/PUT /event/take-photo 抓拍主码流
# request
null
# response
{}
```

### <span id="start-record">start-record</span>

```shell
# POST/PUT /event/start-record 开始录像
# request
null
# response
{}
```

### <span id="stop-record">stop-record</span>

```shell
# POST/PUT /event/stop-record 停止录像
# request
null
# response
{}
```

## <span id="audio">audio</span>

```shell
# GET audio/0 获取音频配置
# response
{
    "iBitRate":32000,
    "iSampleRate":16000,
    "iVolume":50,
    "id":0,
    "sANS":"close",
    "sEncodeType":"MP2",
    "sInput":"micIn"
}

# POST/PUT audio/0 配置音频参数
# request
{
    "iBitRate":32000,
    "iSampleRate":16000,
    "iVolume":50,
    "id":0,
    "sANS":"close",
    "sEncodeType":"MP2",
    "sInput":"micIn"
}
# response
{
    "iBitRate":32000,
    "iSampleRate":16000,
    "iVolume":50,
    "id":0,
    "sANS":"close",
    "sEncodeType":"MP2",
    "sInput":"micIn"
}
```

## 常见异常响应

### 401

```shell
1.cookie过期，需重新登录申请cookie
{
    "error": {
        "code": 401,
        "message": "token verification failed: not found cookie"
    }
}

2.cookie中携带登录信息错误，需重新登录申请cookie
{
    "error": {
        "code": 401,
        "message": "Unauthorized"
    }
}
```

### 500

```shell
1.request中携带的json存在数据类型错误
{
    "error": {
        "code": 500,
        "message": "json.exception.type_error.304"
    }
}

2.请求的id或key不在规定范围内
{
    "error": {
        "code": 500,
        "message": "json.exception.out_of_range.403"
    }
}

```

### 501

```shell
1. 无效URL
{
    "error": {
        "code": 501,
        "message": "Not Implemented"
    }
}
```

