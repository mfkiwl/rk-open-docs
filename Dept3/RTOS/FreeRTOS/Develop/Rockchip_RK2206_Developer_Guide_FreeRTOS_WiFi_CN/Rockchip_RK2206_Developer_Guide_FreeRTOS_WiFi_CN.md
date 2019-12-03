# **Rockchip_RK2206_Developer_Guide_FreeRTOS_WiFi_CN**

文件标识：RK-KF-YF-307

发布版本:1.2.0

日期:2019.12

文件密级：公开资料

---

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2019福州瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

## **前言**

**概述**

本文档主要介绍RK2206 WiFi开发方法。

**产品版本**

| **芯片名称** | **内核版本**    |
| ------------ | --------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **日期**   | **版本** | **作者**  | **修改说明**                                   |
| ---------- | -------- | --------- | ----------------------------------------------- |
| 2018.12.27 | 1.00     | Aaron.sun | 初始版本                                        |
| 2019.05.13 | 1.10     | Aaron.sun | 1. 增加扫描API的说明<br>2. 补充连接API的注意事项 |
| 2019.06.27 | 1.1.1    | Cww       | 修改文件名和客户服务邮箱                        |
| 2019.12.03 | 1.2.0    | Cww       | 针对RK2206进行修改文档|

---

## **目录**

[TOC]

---

## 1 Wi-Fi配置说明

``` c
Components Config  --->
    Wi-Fi  --->
        [*] Enable Wi-Fi
            [ ]     Wiced WiFi driver
            [ ]     RK912 WiFi driver
            [*]     RK2206 WiFi driver
```

以上配置3者只能选其一

## 2 Wi-Fi相关命令

| 命令               | 命令格式                             | 描述                                                         |
| ------------------ | ------------------------------------ | ------------------------------------------------------------ |
| 设置休眠触发时间   | system.idle1 100000                  | 100000 单位是S，可用其他数字取代                             |
| 启动Wi-Fi           | wifi.start sta                       | sta 是wifi 模式，可用 ap mp 取代。<br>  sta  --- sta 模式。 <br>  ap   --- ap 模式。 <br>  mp  --- 射频信号测试模式 |
| 关闭Wi-Fi           | wifi.delete                          |                                                              |
| 连接某个路由器     | wifi.connect cpsb-sch-test 123123123 | cpsb-sch-test --- 为路由器名称，命令不支持路由器名称带有“.”和空格，不支持中文。<br>123123123 ---- 为路由器密码，没密码随便输入，不输入密码会提示格式错误。 |
| 启动AirKiss配网    | wifi.configst                        | 启动成功会打印“rx sniff start   ok”，否则启动不成功，配网成功后自动退出配网模式。没有超时退出机制，需要上层发命令退出配网模式。 |
| 关闭AirKiss配网    | wifi.configsp                        | 关闭成功会打印“sniffer   disable”                            |
| 启动TX射频信号测试 | wifi.mp.tx -c 1 -t n -r 7            | -c 1 指定通道 1<br>-r 速率<br>不带-t n时指11b，11g速率，如1 2 55 11 6 9 12 18 24 36 48 54 <br>带-t n时，表示11n速率，需指定 0 -- 7 |
| 启动RX射频信号测试 | wifi.mp.rx -c 1                      | -c 1 指定通道 1                                              |
| 获取RX收包信息     | wifi.mp.get                          | 需要先启动wifi.mp.rx                                         |
| 清除保存Wi-Fi信息   | lun.test 1 0 512                     | 开启Wi-Fi会启动连接保存的Wi-Fi，可以使用此命令进行清除。        |
| 查看网络信息       | ip.config                            |                                                              |
| ping 命令          | ip.ping -n 5 192.168.1.1             | -n 次数，默认4次   ip地址默认，192.168.1.1                   |

## 3 API使用说明

在使用WiFi相关的API时，需要包含wifithread.h 和 wifi_api_internal.h，该文件在src\components\wireless\rk2206\api中。

WICE相关的头文件在 src\components\wireless\wice中。

### 3.1 启动Wi-Fi

#### 3.1.1 RKTaskCreate

功能：创建静态任务

原型：rk_err_t RKTaskCreate(uint32 TaskClassID, uint32 TaskObjectID, void * arg, uint32 Mode);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32   静态任务类ID                |
| TaskObjectID  | uint32   | typedef  unsigned long  uint32   静态任务对象ID              |
| arg           | void *   | 执行入口函数参数                                             |
| Mode          | uint32   | typedef  unsigned long  uint32   删除模式：   SYNC_MODE 同步托管模式   ASYNC_MODE 异步托管模式   DIRECT_MODE 非托管模式 |
| return        | rk_err_t | RK_SUCCESS:创建成功，RK_ERROR：创建失败 |

创建Wi-Fi使用此API，方法如下：

【RK2206/WICE】STA模式：

RKTaskCreate(TASK_ID_WIFI_APPLICATION, 0, (void *)WLAN_MODE_STA, SYNC_MODE);

【WICE】AP模式：

RKTaskCreate(TASK_ID_WIFI_APPLICATION, 0, (void *)WLAN_MODE_AP, SYNC_MODE);

【RK2206】MP模式：

RKTaskCreate(TASK_ID_WIFI_APPLICATION, 0, (void *)WLAN_MODE_MP, SYNC_MODE);

### 3.2 删除Wi-Fi

#### 3.2.1 RKTaskDelete

**功能：删除静态任务**

**原型：rk_err_t RKTaskDelete(uint32 TaskClassID, uint32 TaskObjectID, uint32 Mode);**

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32   静态任务类ID                |
| TaskObjectID  | uint32   | typedef  unsigned long  uint32   静态任务对象ID              |
| Mode          | uint32   | typedef  unsigned long  uint32   删除模式：   SYNC_MODE 同步托管模式   ASYNC_MODE 异步托管模式   DIRECT_MODE 非托管模式 |
| return        | rk_err_t | RK_SUCCESS:删除成功，RK_ERROR：删除失败                      |

#### 3.2.2 rk_wifi_deinit

**功能：反初始化Wi-Fi模块**

**原型：rk_err_t rk_wifi_deinit();**

| **Parameter** | **Type** | **Description**                                 |
| ------------- | -------- | ----------------------------------------------- |
| return        | rk_err_t | RK_SUCCESS:反初始化成功，RK_ERROR：反初始化失败 |

删除Wi-Fi：使用以上API，方案如下：

rk_wifi_deinit();

RKTaskDelete(TASK_ID_WIFI_APPLICATION,0,SYNC_MODE);

### 3.3 启动AirKiss

#### 3.3.1 rk_wifi_smartconfig

**功能：启动AirKiss配网**

**原型：rk_err_t rk_wifi_smartconfig();**

| **Parameter** | **Type** | **Description**                         |
| ------------- | -------- | --------------------------------------- |
| return        | rk_err_t | RK_SUCCESS 启动成功，RK_ERROR：启动失败 |

### 3.4 停止AirKiss

#### 3.4.1 rk_easy_smartconfig_stop

**功能：停止AirKiss配网**

**原型：rk_err_t rk_easy_smartconfig_stop();**

| **Parameter** | **Type** | **Description**                         |
| ------------- | -------- | --------------------------------------- |
| return        | rk_err_t | RK_SUCCESS 停止成功，RK_ERROR: 停止失败 |

### 3.5 检测AirKiss是否配置成功

#### 3.5.1 wifi_easy_setup_flag

**功能：检查AirKiss是否配置成功**

**原型：int wifi_easy_setup_flag(void)**

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| return        | int      | WIFI_TRUE：配置成功 ，WIFI_WAIT: 等待配置，WIFI_WAIT：配置失败 |

### 3.6 设置路由器

#### 3.6.1 rk_wifi_usartconfig

**功能：设置路由器信息**

**原型：rk_err_t rk_wifi_usartconfig(uint8 \*ssid_value, uint8 ssid_length, uint8 \*password_value, uint8 password_length)**

| **Parameter**   | **Type** | **Description**                         |
| --------------- | -------- | --------------------------------------- |
| ssid_value      | uint8 *  | ssid，UTF8编码，最大32个字节            |
| ssid_length     | uint8    | ssid长度，不超过32个字节                |
| password_value  | uint8 *  | 密码，UTF8编码，最大64个字节             |
| password_length | uint8    | 密码长度，不超过64个字节                |
| return          | rk_err_t | RK_SUCCESS 设置成功，RK_ERROR: 设置失败 |

路由器信息设置成功后，会自动启动连接，连上AP后，会保存此信息，连不上，不保存。

Wi-Fi连接不成功，1分钟之后才可以重新连接。

shell命令对特殊字符串的支持不好，测试此函数，请使用AirKiss。

### 3.7 扫描路由器

#### 3.7.1 wifi_start_scan_internal

**功能：设置路由器信息**

**原型：int wifi_start_scan_internal(rkwifi_scan_result_handler_t scan_hadler, void\* user_data, unsigned char \*ssid, int ssid_len, int channel);**

| **Parameter** | **Type**                     | **Description**                                              |
| ------------- | ---------------------------- | ------------------------------------------------------------ |
| scan_hadler   | rkwifi_scan_result_handler_t | 扫描结果回调，具体请参考下文扫描结果相关结构体描述           |
| user_data     | Void *                       | 用户定义数据，将在扫描结果中返回，具体请参考下文扫描结果相关结构体描述 |
| ssid          | unsigned char *              | 指定SSID， UTF8编码，最大32字节                               |
| ssid_len      | int                          | ssid 长度，不超过32个字节                                    |
| channel       | int                          | 指定扫描通道，0 --- 全通道   1-14代表14个通道，第14到通道仅在日本使用。 |

调用这个函数需要先调用 wifi_switch_overlay_status(WIFI_OVERLAY_SCAN);来加载SCAN驱动。

#### 3.7.2 扫描结果相关结构体

```c
typedef struct rkwifi_scan_result
{
    rkwifi_ssid_t      SSID;           /**< Service Set Identification (i.e. Name of Access Point)  */
    rkwifi_mac_t       BSSID;          /**< Basic Service Set Identification (i.e. MAC address of Access Point) */
    int16              signal_strength;/**< Receive Signal Strength Indication in dBm. <-90=Very poor,>-30=Excellent */
    rkwifi_bss_type_t  bss_type;       /**< Network type  */
    rkwifi_security_t  security;       /**< Security type */
    uint8              channel;        /**< Radio channel that the AP beacon was received on */
    rkwifi_802_11_band_t  band;        /**< Radio band    */
    uint32             max_data_rate;  /**< Maximum data rate in kilobits/s  */
    rkwifi_bool_t      on_channel;     /**< True if scan result was recorded on the channel advertised in the packet */
    struct rkwifi_scan_result *next;   /**< Pointer to the next scan result  */
} rkwifi_scan_result_t;
```

rkwifi_scan_result_t结构体说明

| **Parameter**   | **Type**                   | **Description**                                              |
| --------------- | -------------------------- | ------------------------------------------------------------ |
| SSID            | rkwifi_ssid_t       | SSID|
| BSSID           | rkwifi_mac_t       | SSID对应的MAC地址|
| signal_strength | int16                      | 信号强度                |
| bss_type        | rkwifi_bss_type_t          | 网络类型：<br>RKWIFI_BSS_TYPE_INFRASTRUCTURE   <br>RKWIFI_BSS_TYPE_ADHOC   <br>RKWIFI_BSS_TYPE_ANY   <br>RKWIFI_BSS_TYPE_UNKNOWN |
| security        | rkwifi_security_t          | 加密类型                |
| channel         | uint8                      | 信道                   |
| band            | rkwifi_802_11_band_t       | 基带中心频率            |
| max_data_rate   | uint32                     | 最大速率                |
| on_channel      | rkwifi_bool_t              | 保留， 应用不关注        |
| next            | struct rkwifi_scan_result* | 保留， 应用不关注        |

### 3.8 检查路由器是否连上

#### 3.8.1 MainTask_GetStatus

**功能：获取某个状态信息**

**原型：uint8 MainTask_GetStatus (uint32 StatusID, uint32 Delay)**

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| StatusID      | uint32   | 状态ID，Wi-Fi相关状态   <br>MAINTASK_WIFI_OPEN_OK，   ---- 打开成功   <br>MAINTASK_WIFI_ERROR，     ---- 打开失败   <br>MAINTASK_WIFI_CONNECT_OK，  ----   连接成功   <br>MAINTASK_WIFI_CONNECTING，  ----   连接中   <br>MAINTASK_WIFI_SUSPEND，    -----   休眠   <br>MAINTASK_WIFI_AP_SUSPEND，    ----- AP模式休眠   <br>MAINTASK_WIFI_AP_OPEN_OK， ----- AP模式打开成功   <br>MAINTASK_WIFI_AP_CONNECT_OK， ----- AP模式连接成功 |
| Delay         | uint32   | 等待时间 -1， 永久等待                                        |
| return        | uint8    | 1 状态已设置，0 状态未设置                   |

使用此命令可以检查路由器是否连上

MainTask_GetStatus（MAINTASK_WIFI_CONNECT_OK， MAX_DELAY）; --- 同步模式

MainTask_GetStatus（MAINTASK_WIFI_CONNECT_OK， 0）; --- 异步模式
