# **RKupgrade二次开发库用户手册**

发布版本：1.0

作者邮箱：liuyi@rock-chips.com

日期：2017-11-06

文档密级：公开资料

---

**前言**

**概述**

RKUpgrade.dll二次开发库,是基于VS2008开发,支持Ansi和Unicode编码.提供读写读序列号、蓝牙地址、网卡地址等接口,方便客户定制工具.

**支持产品**

| **芯片名称**             |
| -------------------- |
| RK3399 RK3368        |
| RK3288 RK3228 RK3229 |
| RK3188 RK3126 RK3128 |
| RK3066               |

**读者对象**

  工具开发工程师

**修订记录**

|   **日期**   | **版本** | **作者** | **修改说明** |
| :--------: | :----: | :----: | :------: |
| 2017.11.06 |  1.0   |   刘翊   |    初稿    |
|            |        |        |          |
|            |        |        |          |

---
[TOC]
---

## 1.二次开发步骤

### 1.1导入库和头文件

**采用Vs2008开发环境,请按以下步骤:**
步骤1:包含头文件(#include "RKUpgradeDll.h")
步骤2:导入库文件(#pragma comment(lib,"RKUpgrade.lib"))
**采用其他windows开发平台,请按以下步骤:**
步骤1:参考RKUpgradeDll.h文件,声明使用到的数据类型和函数
步骤2:调用系统的LoadLibrary函数,加载RKUpgrade.dll
步骤3.调用系统的GetProcAddress函数,引入使用到的函数指针

### 1.2初始化RKUpgrade库

步骤1：初始化INIT_DEV_INFO变量为全零, bScan4FsUsb成员和uiRockusbTimeout成员根据实际情况设置
步骤2: 初始化InitLogInfo变量,设置是否要记录日志和日志保存位置
步骤3: 初始化InitCallbackInfo变量 为全零
步骤4: 调用RK_Initialize初始化函数
注:在程序初始化时调用

### 1.3扫描设备

步骤1：调用RK_ScanDevice函数,扫描设备
步骤2: 判断nDeviceCounts参数,0没有发现设备,1发现1台设备,>1发现多台设备默认只操作最前面的那台
步骤3: 判断bExistMsc参数和bExistAdb,如果bExistMsc为真,开始读写操作前需要先调用RK_SwitchToRockusb函数切换到rockusb,如果bExistAdb为真,需要先调用外部工具adb.exe执行adb reboot loader

### 1.4操作设备(以写序列号为例)

步骤1:调用RK_WriteSN函数

### 1.5反初始化RKUpgrade.dll库

步骤1:所有调用RK_Uninitialize函数

## 2.操作接口

### 2.1 读写自定义数据

说明:自定义数据保存在IDBLOCK的扇区3中,有512个字节空间
函数:RK_WriteCustomData 和RK_ReadCustomData
参数:
`pCustomData`:分配512字节buffer
`nCustomDataOffset`:自定义数据在512空间中的偏移
`nCustomDataLen`:自定义数据的长度,字节单位
**注:读取成功后,返回的是整个sector3数据,要通过nCustomDataOffset偏移到自定义数据.**
**写入的数据是从pCustomData + nCustomDataOffset开始的nCustomDataLen数据**

### 2.2 读写序列号

说明:序列号在sector3中2-61位置,0-1是序列号长度
函数:RK_WriteSN和RK_ReadSN
参数:
`pSN`:序列号,字符串数据
`nSNLen`:序列号长度,字节单位

### 2.3 读写网卡地址

说明:网卡地址在sector3中506-511位置,每4位代表一个字符,一共表示12个字符网卡地址,
函数:RK_WriteMAC和RK_ReadMAC
参数:
`pMac`:6个字节转换后的地址
`nMacLen`:长度为6

### 2.4 读写WifiMac地址

说明:WifiMac地址在sector3中445-450位置,每4位代表一个字符,一共表示12个字符网卡地址,
函数:RK_WriteWifi和RK_ReadWifi
参数:
`pWifi`:6个字节转换后的地址
`nWifiLen`:长度为6

### 2.5读写蓝牙地址

说明:蓝牙地址在sector3中499-504位置,每4位代表一个字符,一共表示12个字符网卡地址,
函数:RK_WriteBT和RK_ReadBT
参数:
`pBT`:6个字节转换后的地址
`nBTLen`:长度为6

### 2.6清空Sector3数据

说明:sector3中全部512字节清零
函数:RK_ClearAllInfo

### 2.7读写Vendor数据

说明:有两个Vendor区,分别是vendor0和vendor1,每个区504个字节,这个区域的性质是升级后数据不会丢失,设备端可读可写。
函数:RK_WriteVendorInfo和RK_ReadVendorInfo
参数:
`pVendorBuffer`:504为单位的buffer
`sectorOffset`:指定vendor号,只有0或者1
`sectorCount`: 指定读写访问的vendor数

## 2.8读写Provision数据

说明:Provision区,大概1-1.5M大小的空间,按ID来访问每个读写项,每个项数据不能超过62K.目前只有新的芯片方案有这个接口,请与系统工程师确认后使用。
函数: RK_WriteProvisioningData和RK_ReadProvisioningData
参数:
`pDataBuffer`:数据项的访问buffer
`nBufferSize`:数据项buffer大小,字节单位
`nID`:数据项ID

### 2.9读写KeyHash数据

说明:芯片内部有一块efuse存储空间,里面有块区域保存的是公钥的hash.这部分空间只能写一次.写入公钥hash后,芯片激活安全机制。
函数:RK_WriteKeyHashToEfuse和RK_ReadKeyHashFromEfuse
参数:
`pKeyHash`:32字节内存空间
`usKeyHashSize`:读取到的keyhash长度
**注:调用RK_WriteKeyHashToEfuse前,要先调用RK_SetFirmware设置签名后的update.img固件**

### 2.10读写Efuse数据

说明:芯片内部有一块efuse存储空间,去掉被占用的空间外还有一些空间是开放给客户使用.这部分空间只能写一次.具体每个芯片开放的空间大小都不同,请与系统工程师确认后使用。
函数: RK_WriteDataToEfuse和RK_ReadDataFromEfuse
参数:
`pBuffer`:内存空间,每个bit占用一个字节,最多读写512比特
`usPos`:读写的起始比特
`usWriteSize`:写入的比特数
`usReadSize`:读取的比特数

### 2.11重启rockusb设备

说明:重启rockusb设备
函数: RK_ResetRockusb
参数:
`Subcode`:0为正常重启,3为重启进入maskrom

## 3.常见问题

### 3.1 日志文件提示'ERROR:CheckUsbDevice->Usb type mismatch'

原因:上面除efuse相关的操作外,都需要在loader状态下进行。
注:maskrom和loader都属于rockusb,maskrom下的操作有限.当通过RK_ScanDevice扫描到Rockusb设备后,可以通过调用RK_GetDeviceInfo函数中pUsbtypeArray参数来判断,值为1是maskrom,值为2是loader

### 3.2 日志文件提示'ERROR:WriteSN-->SN Size is Wrong'

原因:SN超过60个字节

### 3.3 日志文件提示'ERROR:WriteSN-->CheckIDBData failed'

原因:IDBLock数据被破坏,校验失败,需要重新升级固件后才能再写

### 3.4 日志文件提示'ERROR:TestDevice-->RKU_TestDeviceReady failed,Total is zero'

原因:设备安全机制被Enable,无法读写sector3.需要将签名后的固件发给我司系统工程师,生成授权证书,再在所有读写操作前调用RK_OpenChannel函数

### 3.5 日志文件提示' ERROR:PrepareIDB-->No Found 1st Flash CS'

原因:loader上报没有找到flash,请跟系统工程师确认flash型号是否在支持列表中,硬件检查flash有没有存在虚焊

### 3.6 RK_ScanDevice找不到设备

原因:

1. 先打开设备管理器,确认是不是有rockusb设备
2. 存在rockusb设备,那么检查库初始化时是不是有指定bScan4FsUsb为TRUE
3. 存在未知设备,查看此设备硬件ID,我们的rockusb设备vid是0x2207,pid是0x3xxx,0x2xxx,0x1xxx
4. 如果属于上面范围,使用DriverAssistant工具安装驱动
5. 未知设备(获取描述符失败),请更新产品最新loader
