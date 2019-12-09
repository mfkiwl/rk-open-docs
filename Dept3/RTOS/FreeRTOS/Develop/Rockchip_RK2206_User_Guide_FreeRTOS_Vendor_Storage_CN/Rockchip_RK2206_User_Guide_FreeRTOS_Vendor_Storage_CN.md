# **Rockchip RK2206 Vendor Storage User Guide**

文件标识：RK-KF-YF-312

发布版本：1.0.1

日       期：2019.11

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

本文档主要介绍Rockchip 2206芯片平台的vendor storage分区以及接口使用介绍。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| RK2206       | 10.0.1       |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**             |
| ---------- | -------- | -------- | ------------------------ |
| 2018-12-28 | 1.0.0    | MLC      | 初始版本                 |
| 2019-11-15 | 1.0.1    | MLC      | 支持RK2206，修改软件版本 |
|            |          |          |                          |

---

## **目录**

[TOC]

---

## **1 概述**

Vendor分区主要是用来存储机器的SN、 MAC、 LAN、BT、IMEI、用户自定义等信息，主要特性是这些信息在设备掉电或恢复出厂设置后不会丢失以及系统启动各个阶段都可以访问。

### **1.1 Vendor分区**

Vendor分区是指在 Flash 上划分出来用于存放Vendor数据的区域。开发者通过相关写号PC工具可以给该分区写入相关的Vendor数据，重启后或者掉电该分区数据不会丢失。可以通过相关接口读取该分区的数据用来做显示或者其他用途。如果整片擦除flash将会清除该分区中所写入的Vendor数据。

相关写号的PC工具详见开发说明文档《Rockchip_RK2206_Provision_tool_User_Guide_CN.pdf》。目前Vendor分区大小为8个扇区，4K Bytes。

```c
#define VENDOR_BLOCK_SIZE       512
#define VENDOR_PART_BLKS        8
#define VENDOR_INFO_SIZE        (VENDOR_PART_BLKS * VENDOR_BLOCK_SIZE)
```

### **1.2 Vendor分区数据相关结构体**

Vendor头部结构体与Vendor条目结构体具体如下：

```c
struct vendor_hdr {
    uint32	tag; /*the value is 0x524B5644.*/
    uint32	version;
    uint16	next_index;
    uint16	item_num;
    uint16	free_offset; /* Free space offset */
    uint16	free_size; /* Free space size */
};

struct vendor_item {
    uint16  id;
    uint16  offset;
    uint16  size;
    uint16  flag;
};

struct vendor_info {
    struct vendor_hdr *hdr;
    struct vendor_item *item;
    uint8 *data;
    uint32 *hash;
    uint32 *version2;
};
```

### **1.3 Vendor ID定义**

ID是每个Vendor分区中item的唯一标识。Vendor是根据ID号来找到对应的item，根据该item的相关值找到相对应的值。

```
#define VENDOR_SN_ID           1 /* serialno */
#define VENDOR_WIFI_MAC_ID     2 /* wifi mac */
#define VENDOR_LAN_MAC_ID      3 /* lan mac */
#define VENDOR_BLUETOOTH_ID    4 /* bluetooth mac */
```

## **2 使用说明**

### **2.1 代码位置**

相关代码请参考：

```
sdk-code/src/kernel/fwmgr/vendor_ops.h
sdk-code/src/kernel/fwmgr/vendor_ops.c
```

### **2.2 接口说明**

下面对 Vendor分区提供的相关接口进行简要说明。

1. 初始化 vendor storage变量。

   ```c
   int vendor_storage_init(void);
   ```

2. 初始化 vendor storage变量。

   ```c
   int vendor_storage_read(uint32 id, void *pbuf, uint32 size);
   ```

3. 根据id号，将pbuf指针所指位置中size大小的内容写入到vendor storage中。

   ```c
   int vendor_storage_write(uint32 id, void *pbuf, uint32 size);
   ```

4. 反初始化vendor storage的相关变量。

   ```c
   int vendor_storage_deinit(void);
   ```

### **2.3  使用示例**

下面是根据Vendor的接口封装的一个读取设备序列号的读取接口。

详见sdk-code/src/kernel/fwmgr/rkpart.c

```c
int get_device_sn(dev_sn_tpye_t dev_sn_type, char* strBuf, int len)
```

以下三个接口通过调用get_device_sn接口，用来分别获取SN，Wi-Fi MAC，BT MAC的具体内容。

```c
rk_err_t FW_GetProductSn(void *pSn)
rk_err_t FW_GetBtMac(void * pBtMac)
rk_err_t FW_GetWifiMac(void * pWifiMac)
```

RK2206 SDK中提供的shell工具，可以通过串口输入执行

```
fw.inf (回车)
```

查看固件相关信息，其中可以看到通过写号工具写入Vendor中的相关序列号或者MAC地址。
