# **RK2206 PCBA Developer Guide**

文件标识：RK-KF-YF-303

发布版本：1.0.0

日期：2019.11

文件密级：内部资料

------

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

商标声明

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

版权所有 © 2019 福州瑞芯微电子股份有限公司

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

------

## **前言**

**概述**

本文主要针对RK2206 Story Board 的工厂测试说明。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

1. 技术支持工程师
2. 软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**           |
| ---------- | -------- | --------  | ---------------------- |
| 2019-11-25 | V1.0.0   | conway    | 初始版本               |

## **目录**

[TOC]

## **1 工厂模式说明**

### **1.1 按键功能图**

工厂模式下按键分布图：

<img src="resources/factory.png" alt="factory" style="zoom:50%;" />

按键及功能：

| **按键**            | **功能**                                 |
| ----------          | --------                                  |
| 左按键 和右按键     |    同时按下不动，再开机，进入工厂模式     |
| 左按键              |    短按“滴”一声                           |
| 右按键              |    短按“滴”一声                           |
| 拍照键              |    短按“滴”一声，拍照完毕再“滴”一声       |
| 麦克录音键          |    长按录音，“滴”一声，眼灯闪烁。短按播放 |
| 话筒录音键          |    长按录音，“滴”一声，眼灯闪烁。短按播放 |

<div style="page-break-after: always;"></div>
### **1.2 进入工厂模式**

同时按下左右按键不动，紧接开机。

### **1.3 代码和编译说明**

#### **1.3.1 工厂测试代码**

```
src/components/factory_test
```

#### **1.3.2 编译固件**

工厂测试模式需在编译前配置开启，厂测和正常应用是同一固件。
烧录固件后，同时按下左右键不动再开机进入工厂测试模式，否则启动正常应用。

```bash
cd app/story_robot/gcc/
make distclean
make rk2206_story_defconfig
make menuconfig
#路径：(top menu) → Components Config → Enable FACTORY TEST 选上开启厂测功能
下面是默认配置项，根据需要修改
[*] Enable FACTORY TEST
[*]     Enable debug                                              #debug
[*]     Enable Wi-FI                                              #Wi-FI test module
-*-     Enable TF card                                            #TF card test module
[*]     Enable camera                                             #camera test module
[ ]         camera save multiple photos in TF card                #照片保存模式
[*]     Enable record                                             #record test module
[ ]         record data save in TF card                           #录音数据是否保存
(4)         record time                                           #录音时间设置
(32)    Set volumn                                                #音量设置
make build -j32                                                   #编译
```

### **1.4 测试原理**

| **测试项**   | **原理** |
| ----------   | -------- |
| TF卡         | 写字符串到TF卡再读出进行比较                           |
| Wi-Fi        | 扫描到Wi-Fi则成功，否则失败                            |
| 按键         | 功能按键是否有功能执行。非功能按键是否有提示音“滴”一声 |
| 眼灯/充电灯  | 是否点亮，或是否随相关应用闪烁                         |
| 录音         | 机身麦克风和话筒两种录音，录音后播放进行人工比较       |
| 摄像头       | 拍照保存在TF卡，电脑查看该文件                         |

### **1.5 测试流程**

建议工厂测试按以下流程:

1. 同时按左右按键，再开机，等待提示音“进入工厂测试模式”
2. 自动测试，播放“TF卡测试成功”，或“TF卡测试失败”
3. 自动测试，播放“Wi-Fi测试成功”，或“Wi-Fi测试失败”
4. 开机眼灯亮，充电灯一直闪烁
5. 三个功能按键按顺序测试：
    - 短按拍照键拍照，“滴”一声，拍照完毕再“滴”一声表示结束
    - 长按麦克录音键，“滴”一声，检查眼灯是否正常闪烁，表示在录音，录音完毕闪烁停止，短按该按键，播放录音
    - 长按话筒录音键，“滴”一声，检查眼灯是否正常闪烁，表示在录音，录音完毕闪烁停止，短按该按键，播放录音
6. 其他按键为非功能按键：短按，有提示音“滴”一声表示按键正常

### **1.6 测试时间**

完整工厂测试耗时1分钟左右。

| **测试单项**                      | **单项耗时** |
| ----------                        | --------     |
| 开机至进入工厂测试模式            |    7s        |
| TF卡                              |    3s        |
| Wi-Fi                             |    3s        |
| 摄像头                            |    3s        |
| 机身麦克风录音并播放              |    10s       |
| 话筒录音并播放                    |    10s       |
| 按键                              |    6s        |
| 眼灯充电灯观察                    |    3s        |

## **2 各个测试模块的相关说明以及配置**

### **2.1 工厂测试函数入口**

介绍开机启动的函数入口，及修改进入工厂测试的按键。

```C
app/story_robot/src/main_sever/MainSever.c
COMMON API void MainTask_Enter(void *pvParameters);    //判断启动工厂测试模式还是正常工作模式
MainTask_StartFactoryTest();                           //工厂测试函数入口
MainTask_StartApp();                                   //正常应用入口
if ((MainTaskAskQueue.event_type == MAINTASK_KEY_EVENT) && (MainTaskAskQueue.event == KEY_VAL_FFD_PRESS))
                                                       //此处修改进入工厂测试的按键
```

### **2.2 增加厂测按键功能**

相关代码：

```C
src/components/factory_test/factory_test.c
COMMON FUN int FacToryTestTask_KeyEvent(uint32 KeyVal, void *arg); /*函数中switch语句，在此新增按键及其功能*/
```

### **2.3 音量设置**

编译配置:

```
make menuconfig 配置路径：(top menu) → Components Config → Factory Test → Set volumn
```

### **2.4 录音播放**

- 录音：包括机身麦克风录音和话筒录音。长按某个录音键，录音。眼灯闪烁，录音时间可配置n秒，可在n秒内提前短按录音键，结束录音并播放。
- 播放：播放录音，可多次播放。

#### **2.4.1 编译配置**

```
make menuconfig 配置路径：(top menu) → Components Config → Factory Test → Enable record
子菜单 record data save in TF card               #录音保存选项: 录音数据默认不保存，可设置自动保存
子菜单 record time                               #输入时长设置: 录音时长默认4s，可设置
```

#### **2.4.2 相关代码**

```C
src/components/factory_test/factory_test.c
int record_test(void);
void record_play(void);
```

### **2.5 camera测试**

camera测试照片保存在TF卡，格式为jpeg。照片默认只保留最新一张，可设置为保存多张。

#### **2.5.1 编译配置**

```
make menuconfig 配置路径：(top menu) → Components Config → Factory Test → Enable camera
子菜单camera save multiple photos in TF card选上，则照片保留多张。
```

#### **2.5.2 相关代码**

```C
src/components/factory_test/factory_test.c
void camera_test();
```

### **2.6 TF卡测试**

开机自动测试。测试成功，提示音“TF卡测试成功”;测试失败,提示音“TF卡测试失败”。

#### **2.6.1 编译配置**

```
make menuconfig 配置路径：(top menu) → Components Config → Factory Test → Enable TF card
```

#### **2.6.2 相关代码**

```C
src/components/factory_test/factory_test.c
void sdcard_test(void);
```

### **2.7 Wi-Fi测试**

开机自动测试。测试成功,提示音“Wi-Fi测试成功”;测试失败，提示音“Wi-Fi测试失败”。

#### **2.7.1 编译配置**

```
make menuconfig 配置路径：(top menu) → Components Config → Factory Test → Enable Wi-FI
```

#### **2.7.2 相关代码**

```C
src/components/factory_test/factory_test.c
void create_wifi_thread_entry(void);
void wifi_test(void);
```

### **2.8 眼灯和充电灯**

#### **2.8.1 编译配置**

```
make menuconfig 配置路径：(top menu) → Components Config → LED → Enable LED
```

#### **2.8.2 相关代码**

```C
src/components/factory_test/factory_test.c
LedInit(BOARD_LED_STORY_EYE_ID);            //初始化
LedControl(BOARD_LED_STORY_EYE_ID, 1);      //电平控制
LedFlashingOn(BOARD_LED_STORY_CHARGE_ID);   //LED闪烁线程

src/bsp/RK2206/board/rk2206_story/board.c
struct led led_config[] =                   //LED配置数组
{
    {BOARD_LED_STORY_EYE_ID, BOARD_LED_STORY_EYE_PIN, NULL, GPIO_LOW},         //LED_CONTROL
    {BOARD_LED_STORY_CHARGE_ID, BOARD_LED_STORY_CHARGE_PIN, NULL, GPIO_HIGH},  //Charge_LED
                                            //数组元素代表了 LED设备id、引脚、电平控制
                                            //新增LED控制，在此增加数组元素
};

src/bsp/RK2206/board/rk2206_story/board.h
/*led id*/                                  //定义LED设备id,为0开始顺序整数
#define BOARD_LED_STORY_EYE_ID      0
#define BOARD_LED_STORY_CHARGE_ID   1
/*led pin*/                                 //定义LED相关bank和引脚
#define BOARD_LED_STORY_EYE_GPIO      GPIO0
#define BOARD_LED_STORY_EYE_PIN       GPIO_PIN_C7
#define BOARD_LED_STORY_CHARGE_GPIO   GPIO0
#define BOARD_LED_STORY_CHARGE_PIN    GPIO_PIN_C5
/*level  control*/
#define BOARD_LED_OFF      0
#define BOARD_LED_ON       1

src/bsp/hal/lib/hal/inc/hal_pinctrl.h       //引脚定义
#define GPIO_PIN_C5 (0x00200000U)
#define GPIO_PIN_C7 (0x00800000U)

src/bsp/RK2206/board/rk2206_story/iomux.c   //led配置iomux
void iomux_config_led(void)
{
    HAL_PINCTRL_SetIOMUX(GPIO_BANK0,
                         GPIO_PIN_C7 |
                         GPIO_PIN_C5,
                         PIN_CONFIG_MUX_FUNC0);
}
```