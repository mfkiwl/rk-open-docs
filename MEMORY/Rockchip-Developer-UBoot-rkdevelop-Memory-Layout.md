# U-Boot rkdevelop 内存分布指南

发布版本：1.0

作者邮箱：chenjh@rock-chips.com

日期：2018.02

文件密级：内部资料

-----------

**前言**

**概述**

​	本文档对Rockchip平台的内存分布做一个简要说明，仅针对使用U-Boot rkdevelop分支的平台。

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**产品版本**

| **芯片名称**                                 | **U-Boot分支** |
| ---------------------------------------- | :----------- |
| RK3036/RK3126C/RK3288/RK322X/RK3368/RK3328/RK3399 | rkdevelop    |

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2018-02-26 | V1.0   | 陈健洪    | 初始版本     |

-----------

[TOC]

## 1.  加载Kernel<u>之前</u>

### 1.1 ARM 64位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)      | reserved  memory                         |
| .....                     | 无                                        | /                                        |
| 132M ~ 148M(max)          | OP-TEE运行空间                               | 16M是预估Max值；内核完全不可见（被U-Boot挖掉）            |
| ......                    | 无                                        | /                                        |
| 128M (占用8KB)              | HDMI参数地址                                 | reserved  memory；用于传递HDMI配置信息            |
| 56M ~ 128M                | LMB内存池 + U-Boot自身代码（relocate之后）+ 烧写buffer + idb buffer + malloc | /                                        |
| 48M (占用 8MB)              | Miniloader运行空间                           | 8MB是预估Max值                               |
| ......                    | 无                                        | /                                        |
| 34M (占用120byte)           | OP-TEE内存信息的传参起始地址                        | 120byte是固定值；用于传递OP-TEE占用的内存信息；           |
| ......                    | 无                                        | /                                        |
| 32M (占用120byte)           | DDR容量信息的传参起始地址                           | 120byte是预估Max值（可以传递7个bank块）；用于传递DDR颗粒总容量信息； |
| .......                   | 无                                        | /                                        |
| 2M (占用800KB)              | U-Boot自身的代码                              | 800KB是预估Max值                             |
| 1M ~ 2M                   | ATF和kernel的共享内存、Last log                 | kernel完全不可见（被U-Boot挖掉）                   |
| 0M ~ 1M                   | ATF运行空间                                  | kernel完全不可见（被U-Boot挖掉）                   |



### 1.2 ARM 32位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)      | reserved  memory                         |
| .....                     | 无                                        | /                                        |
| 132M ~ 148M(max)          | OP-TEE运行空间                               | 16M是预估Max值；内核完全不可见（被U-Boot挖掉）            |
| ......                    | 无                                        | /                                        |
| 128M (占用8KB)              | HDMI参数地址                                 | reserved  memory；用于传递HDMI配置信息            |
| 56M ~ 128M                | LMB内存池 + U-Boot代码（relocate之后） + 烧写buffer + idb buffer + malloc | /                                        |
| 48M (占用 8MB)              | Miniloader运行空间                           | 8MB是预估Max值                               |
| 46M-48M                   | Last log空间                               | /                                        |
| ......                    | 无                                        | /                                        |
| 34M (占用120byte)           | OP-TEE 内存信息的传参地址                         | 120byte是固定值；用于传递OP-TEE占用的内存信息；           |
| ......                    | 无                                        | /                                        |
| 32M (占用120byte)           | DDR容量信息的传参地址                             | 120byte是预估Max值（可以传递7个bank块）；用于传递DDR颗粒总容量信息； |
| ......                    | 无                                        | /                                        |
| 0M(占用800KB)               | U-Boot自身的代码                              | 800KB是预估Max值                             |



总结：上述1.1、1.2两点主要区别：

（1）0~2M空间：64位平台下被ATF使用，32位平台下被U-Boot使用；

（2）46~48M空间：64位平台下没有使用，32位平台下作为last log使用（64位平台last log在1~2M空间）；



## 2. 加载Kernel<u>之后</u>

### 2.1 ARM 64位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)  ( Kernel使用! ) | reserved memory，logo显示完毕后由显示驱动释放，然后由kernel使用 |
| .......                   | kernel 使用                                | /                                        |
| 132M ~ 148M(max)          | OP-TEE运行空间                               | kernel 完全不可见（被U-Boot挖掉）                  |
| ......                    | kernel 使用                                | /                                        |
| 128M (占用8KB)              | HDMI参数地址 ( Kernel使用! )                   | reserved  memory，会被HDMI驱动释放，然后kernel使用   |
| ......                    | kernel 使用                                | /                                        |
| 2M+512K(占用32M)            | kernel被U-Boot 加载到2M+512K位置，不进行自解压，直接开始运行 | 目前预估kernel最大32M（可调整）                     |
| 2M ~ 2M+512K              | 64位kernel启动时的地址要求（kernel代码前预留512K）       | 必须保留                                     |
| 1M ~ 2M                   | ATF和kernel的共享内存、Last log                 | kernel完全不可见（被U-Boot挖掉）                   |
| 0M ~ 1M                   | ATF运行空间                                  | kernel 完全不可见（被U-Boot挖掉）                  |



### 2.2 ARM 32位平台

| Start                     | Usage                                    | Description                              |
| ------------------------- | ---------------------------------------- | ---------------------------------------- |
| (DDR_END - 48M) ~ DDR_END | U-Boot logo(16M) + kernel logo(32M)  ( Kernel使用! ) | reserved memory，logo显示完毕后由显示驱动释放，然后由kernel使用 |
| .......                   | kernel 使用                                | /                                        |
| 132M ~ 148M(max)          | OP-TEE运行空间                               | kernel 完全不可见（被U-Boot挖掉）                  |
| ......                    | kernel使用                                 | /                                        |
| 128M (占用8KB)              | HDMI参数地址 ( Kernel使用! )                   | reserved  memory，会被HDMI驱动释放，然后kernel使用   |
| ......                    | kernel 使用                                | /                                        |
| 46M ~ 48M                 | Last log                                 | /                                        |
| 32M ~ 46M                 | 压缩过的kernel被U-Boot 加载在32M的位置              | kerne压缩后最大14M                            |
| 0M ~ 32M                  | kernel自解压在0M位置，然后开始运行                    | kernel自解压后最大32M                          |



总结：上述2.1、2.2两点主要区别：

（1）0~2M空间：64位平台下被ATF使用，32位平台下被U-Boot使用；

（2）内核加载地址：32位平台内核被加载在32M，然后内核自解压到0M开始运行，64位平台内核被加载在2M+512K，不进行自解压，直接开始运行；

（3）针对（2）点需要注意，32位平台下32M、34M地址有个复用的过程，即整个开机过程：U-Boot先从32M，34M先获取DDR、OP-TEE的参数信息，获取完了之后会把内核加载到32M的地方；

（4）46~48M的空间：64位平台下没有使用，32位平台下作为last log使用（64位平台last log在1~2M的空间）；

（5）针对（4）点需要注意，32位平台下因为46~48M永远都是被last log占据，所以必须保证kernel未解压前的size最大只能是14M，即32~46M之间。否则将会破坏last log !!