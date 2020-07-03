# Rockchip RK2206 FreeRTOS OTA User Guide

文件标识：RK-KF-YK-308

发布版本：1.0.1

日       期：2019.12

文件密级：公开资料

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

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

---

## **前言**

 **概述**

 本文主要介绍Rockchip RK2206芯片平台适用的RTOS系统OTA 升级开发的一些接口操作说明。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RK2206       | 10.0.1       |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | :------- | ------------ |
| 2019-01-03 | V1.0.0   | MLC      | 初始版本     |
| 2019-12-23 | V1.0.1   | MLC      | 更新第一章节 |

---

<div style="page-break-after: always;"></div>
## **目录**

[TOC]

---

<div style="page-break-after: always;"></div>
## **1 OTA概述**

OTA模块为系统提供在线升级固件的功能。此文档旨在解释说明 OTA 模块相关概念和定义，介绍并指导开发者使用 SDK 中的 OTA 方案。OTA 模块的开发需要开发者了解固件分区结构，相关的内容可以参考文档Path_to_SDK/Docs/Rockchip_RK2206_User_Guide_FreeRTOS_Firmware_Structure_CN.md.pdf。

### **1.1 OTA升级原理**

SDK 中的 OTA 方案通过对两个 Image 区域进行乒乓操作实现对固件的升级，两个 Firmware image区域如下图所示。

![](resources/ota_fw_struct.png)

两个 Firmware固件区域大小相同，均为 Image size。 Image  size应该大于或等于实际固件的大小。此外，Image区域应该与Flash可擦除块对齐。每份Firmware均由Firmware Head 与Firmware data两部分组成。Firmware Head大小为512字节，一个sector大小，记录了Firmware的相关信息。该部分的详细说明见后面章节。Firmware data是可执行的程序与数据。

Firmware1与Firmware2数据与实际固件数据相同。Firmware2作为Firmware1的分区的备份。OTA升级时总是将最新固件升级至Firmware2分区，并校验通过后，软复位再将Firmware2分区的数据包括Firmware head 与data均拷贝一份写到Firmware1的起始位置。如果固件更新或校验失败，则不会重启，下次启动时仍会从Firmware1分区启动，加载OTA升级前的固件数据。

系统总是从Firmware1分区加载程序与数据，并在启动时校验两份Firmware的哈希值，如果某一分固件无效，则会用另一份固件去恢复。

### **1.2 相关概念与定义**

#### **1.2.1 OTA protocol**

OTA protocol 表示 OTA 升级时下载固件的协议。在 ota.h 中定义如下：

```c
typedef enum ota_protocol {
    OTA_PROTOCOL_FILE   = 0,
    OTA_PROTOCOL_HTTP   = 1,
} ota_protocol;
```

其中OTA_PROTOCOL_FILE 表示从文件升级，即本地升级，将制作好的升级包update.img放在sd中，调用升级接口写入固件分区进行本地升级。

OTA_PROTOCOL_HTTP 表示通过http协议升级，即下载升级，通过http协议获取到update.img的升级包数据然后写入固件分区升级。

#### **1.2.2 OTA verify**

OTA verify 表示对下载完固件的校验算法。为保证固件在 OTA 下载和烧写 Flash 过程中不出错，可采用 Jhash 算法对固件进行校验。

```c
typedef enum ota_verify {
    OTA_VERIFY_NONE     = 0,
    OTA_VERIFY_JHASH    = 1,
} ota_verify;
```

哈希校验的接口在 Fwupdate.c中定义如下：

```
unsigned int jshash(unsigned int hash, char *str, unsigned int len)
```

#### **1.2.3 Firmware header结构体**

```c
typedef struct _FIRMWARE_HEADER
{
	unsigned char  magic[8]; //'RESC'
	unsigned char  chip[16];
	unsigned char  model[32];
	unsigned char  desc[16]; //description
	STRUCT_VERSION version;
	STRUCT_DATE release_date;
	unsigned int data_offset; //raw firmware offset
	unsigned int data_size;  //raw firmware size
	unsigned char  reserved1[4];
	unsigned char  digest_flag; //digest algorithm,default is 1(js_hash)
	unsigned char  reserved2[421];
}FIRMWARE_HEADER, *PFIRMWARE_HEADER;//head is 512 bytes
```

#### **1.2.4 升级包的固件版本**

##### **1.2.4.1 固件版本定义**

升级包的固件版本是根据配置文件config.json定义的。config.json文件在Path_to_SDK/tools/firmware_merger/目录下。

根据此配置文件生成固件头，并定义了固件版本号。固件版本号用来在OTA升级中做比较。若当前设备中固件版本号与OTA下载的固件版本号相同或者小于设备当前固件版本号是不做OTA升级的。故，每次更新服务器版本时，需修改该配置文件中的固件版本号。

config.json的具体内容如下：

```json
{
    MAGIC: RESC,
    CHIP: RK2206,
    MODEL: EVB,
    DESC: RKOS,
    VERSION: 1.00.0000,
    DIGEST: JSHASH
}
```

**1.2.4.2 版本号的获取与比较**

ota.c中ota_need_update接口实现了获取当前设备版本号与服务器update.img升级包固件版本号并比较的过程。

```c
int ota_need_update(ota_protocol protocol, void *url)
{
	......
	unsigned char magic[8] = {'R', 'E', 'S', 'C', 0, 0, 0, 0};
    PFIRMWARE_HEADER pFWHead1 = NULL;
    PFIRMWARE_HEADER pFWHead2 = NULL;

    uint8 *fw_head_buf = NULL;
    uint8 *dataBuf = NULL;
    bool bNeedUpdate = FALSE;

    OTA_DBG("### %s() Enter ###", __func__);

    hLunFW = rkdev_open(DEV_CLASS_LUN, 0, NOT_CARE);
    if (!hLunFW)
        OTA_ERR("open Lun device Error");

    fw_head_buf = rkos_memory_malloc(FW_HEAD_SIZE);
    if (fw_head_buf == NULL)
    {
        OTA_ERR("No mem\n");
        goto END;
    }

#ifdef CONFIG_FILESYSTEM_SUPPORT
    dataBuf = rkos_memory_malloc(FW_HEAD_SIZE);
    if (dataBuf == NULL)
    {
        OTA_ERR("No mem\n");
        if (fw_head_buf)
            rkos_memory_free(fw_head_buf);
        goto END;
    }

    addr = firmware_addr1 << 9;
    if (RK_SUCCESS != FwRead(hLunFW, addr, dataBuf, FW_HEAD_SIZE))
    {
        goto END;
    }

    pFWHead1 = (PFIRMWARE_HEADER)dataBuf;
    if (0 != memcmp(pFWHead1->magic, magic, 4))
    {
        OTA_DBG("FW magic ERR addr:0x%x\n", firmware_addr1);
        goto END;
    }
#endif
    ......
    case OTA_PROTOCOL_HTTP:
        if (ota_update_http_init(url) != OTA_STATUS_OK)
        {
            OTA_ERR("ota_update_http_init fail \n");
            goto END;
        }

        ret = ota_fw_head_http_get(fw_head_buf, FW_HEAD_SIZE, &recvSize, &eof_flag);
        ......
        uint32 devFwVer = pFWHead1->version.major << 24 | pFWHead1->version.minor << 16 |pFWHead1->version.small;
        uint32 devFwDate = pFWHead1->release_date.year << 16 | pFWHead1->release_date.month << 8 |pFWHead1->release_date.day;

        uint32 targetFwVer = pFWHead2->version.major << 24 | pFWHead2->version.minor << 16 | pFWHead2->version.small;
        uint32 targetFwDate = pFWHead2->release_date.year << 16 | pFWHead2->release_date.month << 8 |pFWHead2->release_date.day;

}
```

**1.2.4.3 固件的校验**

通过OTA下载固件成功后，需要校验固件的正确性，SDK中使用jhash校验算法，在制作update.img升级包时会将jhash计算得出的校验值4个字节写入升级包文件的最后位置。下载完成后需要重新计算下载固件的jhash值与下载固件的最后4个字节做比较，判断当前OTA下载的固件是否正确无误。

OTA固件校验：

```c
ota_status ota_verify_img(ota_verify verify)
```



## **2 OTA接口使用说明**

### OTA配置

打开menuconfig ，Components Config中选中OTA配置，可配置OTA的打开与关闭。

```
(top menu)
	Components Config --->
		OTA --->
			[*] Enable Ota
```

### **2.2 代码位置**

OTA相关代码请参考：

Path_to_SDK/src/components/ota/

```
├── Kconfig
├── Makefile
├── ota.c
├── ota_debug.h
├── ota_file.c
├── ota_file.h
├── ota.h
├── ota_http.c
├── ota_http.h
└── ota_opt.h
```

### **2.3 接口说明**

下面简要说明 OTA 模块提供的接口。

1. 初始化 OTA 模块的私有全局参数结构体指针。根据当前正在运行的系统固件信息初始化image分区的大小，当前正在运行的分区编号、以及需要升级的分区的起始地址。

   ```c
   ota_status ota_init(void)
   ```

2. 反初始化 OTA 模块。

   ```c
   void ota_deinit(void)
   ```

3. 通过指定协议下载固件。输入参数 protocol 为所选择的下载固件的协议。输入参数 url 为固件统一资源定位符。下载成功，返回 OTA_STATUS_OK；下载失败，返回 OTA_STATUS_ERROR。

   ```c
   ota_status ota_update_image(ota_protocol protocol, void *url)
   ```

4. 通过指定算法校验下载的固件，输入参数 verify 为指定的校验算法，hLunDev Lun设备的设备句柄。执行成功（指函数执行成功，不等价于校验通过），返回OTA_STATUS_OK；执行失败（指函数执行失败，不等价于校验不通过），返回 OTA_STATUS_ERROR。

   ```c
   ota_status ota_verify_img(ota_verify verify, HDC hLunDev)
   ```

5. 恢复另外一个分区的固件

   ```c
   ota_status ota_recovery(void)
   ```

6. 重启系统。

   ```c
   void ota_reboot(void)
   ```

### **2.4 使用示例**

#### **2.4.1 协议扩展**

OTA 模块已提供 Http 和 File 两种协议下载固件，此外还支持扩展其他协议。

扩展协议的方式为：

1. 在文件 ota.h 中将扩展的协议补充到数据类型 ota_protocol。

   ```c
   typedef enum ota_protocol {
   OTA_PROTOCOL_FILE = 0,
   OTA_PROTOCOL_HTTP = 1,
   OTA_PROTOCOL_XXXX = 2,
   } ota_protocol;
   ```

2. 实现扩展协议下载固件的两个回调函数，回调函数类型在文件 ota.h 中定义如下。可参考 Http 协议和File 协议对两个回调函数的实现（相关具体接口实现见ota_http.h、ota_http.c、ota_file.h、ota_file.c）。

   ```c
   typedef ota_status (*ota_update_init)(void *url);
   typedef ota_status (*ota_update_get)(uint8 *buf, uint32 buf_size,uint32* recv_size, uint8 *eof_flag);
   ```

3. 将扩展协议的两个回调函数注册到文件 ota.c 的函数 ota_update_image()中。

   ```c
   case OTA_PROTOCOL_FILE:
   return ota_update_image_todo(url, ota_update_file_init, ota_update_file_get);
   case OTA_PROTOCOL_HTTP:
   return ota_update_image_todo(url, ota_update_http_init, ota_update_http_get);
   case OTA_PROTOCOL_XXXX:
   return ota_update_image_todo(url, ota_update_xxxx_init, ota_update_xxxx_get);
   ```

#### 升级固件

1、以本地升级为例。

 假设固件存放在SD卡中，固件路径path为“C：\update.img”,升级固件的示例如下：

```c
if (isUpdateFromFile) {
    #if !OTA_TEST
    ota_update_image(OTA_PROTOCOL_FILE, L"C:\\update.img");
    #else
    ota_update_image(OTA_PROTOCOL_FILE, L"C:\\update.img");
    #endif
}
```

 RK2206 SDK中提供的shell 命令工具，可以通过串口输入，执行以下命令：

   ```
fw.update -t f 或者 fw.update -t file
   ```

 会调用shell的测试接口FWShellUpdate。

 2、以http协议进行OTA升级为例。

假设固件的 url 为：http://10.10.10.163:2301/OtaUpdater/android?product=rk2206&version=1.0.1

升级固件的示例如下：

```c
char * file_url = "http://10.10.10.163:2301/OtaUpdater/androidproduct=rk2206&version=1.0.1";
rk_printf("\nurl = %s",file_url);
#if !OTA_TEST
	ota_update_image(OTA_PROTOCOL_HTTP, file_url);
#else
	ota_update_image(OTA_PROTOCOL_HTTP, file_url);
#endif
```

RK2206 SDK中提供的shell 命令工具，可以通过串口输入，执行以下命令：

```
fw.update -t h 或者 fw.update -t http
```

**注意事项：**

执行从http进行固件升级时，需先做好Wi-Fi配网并连接成功的操作。

