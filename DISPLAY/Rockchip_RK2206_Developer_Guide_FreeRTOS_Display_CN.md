# Rockchip RK2206 Display

文件标识：RK-KF-YF-401

发布版本：V1.0.0

日期：2019-11-29

文件密级：内部资料

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

**前言**

**概述**

本文提供一个标准模板供套用。后续模板以此份文档为基础改动。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明** |
| ---------- | -------- | :------- | ------------ |
| 2019-11-29 | V1.0.0   | 黄家钗   | 初始版本     |

---

## **目录**

[TOC]

---

## **1 代码路径**

### **1.1 驱动代码路径**

RKOS Display 包括以下模块驱动

| 模块    | 路径                                                         |
| ------- | ------------------------------------------------------------ |
| display | src/driver/display/DisplayDevice.c                           |
| vop     | src/driver/vop/VopDevice.c                                   |
| panel   | src/driver/lcd/LCDDriver.c<br />src/driver/lcd/GC9306Driver.c |

### **1.2 测试代码路径**

```c
src/subsys/shell/shell_vop.c
src/subsys/shell/shell_vop_test_data.h
src/subsys/shell/display_test_pattern/
```

## **2 配置方法**

### **2.1 Display driver 配置方法**

```c
cd app/wlan_demo/gcc
make rk2206_defconfig
make menuconfig
BSP Driver  --->
		[*] Enable DISPLAY
		[*] Enable LCD
		[*]     Enable LCD GC9306
		[ ]     Enable LCD ST7735
		[*] Enable VOP
```

### **2.2 Display test 配置方法**

```c
Components Config  --->
	Command shell  --->
		[*]     Enable Display Shell
		[*]     Enable Lcd Shell
```

## **3 API 及使用说明**

### **3.1 Display driver API**

| API                                                          | 使用说明            |
| :----------------------------------------------------------- | ------------------- |
| DisplayDev_SetWindow(HDC dev, int x, int y, int xSize, int ySize) | 设置窗口大小和位置  |
| DisplayDev_ClrRect(HDC dev, uint8 R, uint8 G, uint8 B, uint8 transparency) | 指定RGB数据清除窗口 |
| DisplayDev_Write(HDC dev, void *color, uint32 size, uint8 Mode) | 向屏发送数据        |

### **3.2 Display test 说明**

```c
    /* 打开dma设备 */
    stVopDevArg.hDma = rkdev_open(DEV_CLASS_DMA, dmaId, NOT_CARE);
    if (stVopDevArg.hDma <= 0)
    {
        shell_output(dev, "\r\n  Open dma device %d failure", 0);
        goto err;
    }
    /* 创建VOP设备 */
    ret = rkdev_create(DEV_CLASS_VOP, 0, &stVopDevArg);
    if (ret != RK_SUCCESS)
    {
        shell_output(dev, "\r\n  Create Vop device failure\n", 0);
        goto err;
    }
    /* 打开VOP设备 */
    stLcdDevArg.hBus = rkdev_open(DEV_CLASS_VOP, 0, NOT_CARE);
    if (stLcdDevArg.hBus == NULL)
    {
        shell_output(dev, "\r\n  Open Lcd device failure\n", 0);
        goto err;
    }
    /* 创建LCD设备 */
    ret = rkdev_create(DEV_CLASS_LCD, 0, &stLcdDevArg);
    if (ret != RK_SUCCESS)
    {
        shell_output(dev, "\r\n  Create Lcd device failure\n", 0);
        rkdev_close(stLcdDevArg.hBus);
        goto err;
    }
    /* 打开LCD设备 */
    stDisplayDevArg.h_lcd = rkdev_open(DEV_CLASS_LCD, 0, NOT_CARE);
    if (stDisplayDevArg.h_lcd == NULL)
    {
        shell_output(dev, "\r\n  Open DEV_CLASS_LCD failure", 0);
        goto err;
    }
    /* 创建display设备 */
    ret = rkdev_create(DEV_CLASS_DISPLAY, 0, &stDisplayDevArg);
    if (ret != RK_SUCCESS)
    {
        shell_output(dev, "\r\n  Display device0 create failure", 0);
        rkdev_close(stDisplayDevArg.h_lcd);
        goto err;
    }
    /* 打开display设备 */
    hDisplay = rkdev_open(DEV_CLASS_DISPLAY, 0, NOT_CARE);
    if (hDisplay == NULL)
    {
        shell_output(dev, "Open Display device failure\n", 0);
        goto err;
    }
    /* 设置窗口的大小和位置 */
    DisplayDev_SetWindow(hDisplay, 0, 0, VOP_WIDTH, VOP_HEIGHT);

    /* 发送一帧全红的数据 */
    DisplayDev_SendData(hDisplay, 255, 0, 0, 0);
```

### **3.3 shell 使用**

```c
vop.create
vop.test
```

## **4 新屏配置说明**

可以参考 ST7735SDriver.c 实现新屏的配置文件:

1. 根据屏厂给的参考代码更新屏的初始化命令

   ```c
   LCD_INIT_CONFIG InitTab[] = {
   	//data, cmd,
   	……
   };
   ```

2. 修改分辨率大小

   ```c
   #define LCD_WIDTH  240 //depend on lcd spec
   #define LCD_HEIGHT 320 //depend on lcd spec
   ```
