# Rockchip FreeRTOS TIMER

文件标识：RK-KF-YF-072

发布版本：V1.0.0

日期：2019-12-13

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

**前言**

**概述**

本文主要描述了 ROCKCHIP FreeRTOS TIMER的原理和使用方法。

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

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 林鼎强 | 2019-12-13 | 初始版本     |

**目录**

---
[TOC]
---

## **1 TIMER**

### **1.1 原理**

定时器是可编程定时器外设。 该组件是APB从设备。

FreeRTOS 下的 Timer 驱动实现以下功能：

- 设定为 free running 的定时器，固定周期触发一次中断，并调用注册的回调函数
- 基于 us 为分度值，设定定时器周期，获取定时器计数寄存器时间信息（递增性时钟，获取已走时长，递减性时钟，获取剩余时长）
- 基于 timer clock 为分度值，设定定时器周期，获取定时器计数寄存器时间信息（同有递增递减性区别）

### **1.2 配置**

宏配置：

```c
    BSP Driver  --->
        [*] Enable TIMER
```

### **1.3 代码和函数接口**

**代码**

"src/driver/timer/TimerDevice.c"
"include/driver/TimerDevice.h"

**所有公共函数接口**

```c
void TimerIntIsr(uint32 devID);
__irq void TimerIntIsr0(void);
__irq void TimerIntIsr1(void);
__irq void TimerIntIsr2(void);
__irq void TimerIntIsr3(void);
__irq void TimerIntIsr4(void);
__irq void TimerIntIsr5(void);
__irq void TimerIntIsr6(void);
rk_err_t TimerDev_Start(HDC dev);
rk_err_t TimerDev_Stop(HDC dev);
rk_err_t TimerDev_SetTimeCount(HDC dev, uint64 cnt);
uint64_t TimerDev_GetTimeCount(HDC dev);
rk_err_t TimerDev_Register(HDC dev, uint64 usTick, pFunc TimerCallBack);
rk_err_t TimerDev_PeriodSet(HDC dev, uint64 usTick);
rk_err_t TimerDev_UnRegister(HDC dev);

rk_err_t TimerDev_Task_Init(void *pvParameters, void *arg);
rk_err_t TimerDev_Task_DeInit(void *pvParameters);
void TimerDev_Task_Enter(void *pvParameters);

HDC TimerDev_Create(uint8 DevID, void *arg);
rk_err_t TimerDev_Delete(uint8 DevID, void *arg);
```

**创建/删除设备接口**

```c
HDC TimerDev_Create(uint8 DevID, void *arg);
rk_err_t TimerDev_Delete(uint8 DevID, void *arg);
```

其中，arg 参数暂无实际意义，可不传递。

**Timer 通用接口**

Timer 中断处理函数：

```c
void TimerIntIsr(uint32 devID);  /* 通用 Timer 中断处理函数 */
__irq void TimerIntIsr0(void);  /* Timer0 中断处理函数 */
__irq void TimerIntIsr1(void);  /* Timer1 中断处理函数 */
__irq void TimerIntIsr2(void);  /* Timer2 中断处理函数 */
__irq void TimerIntIsr3(void);  /* Timer3 中断处理函数 */
__irq void TimerIntIsr4(void);  /* Timer4 中断处理函数 */
__irq void TimerIntIsr5(void);  /* Timer5 中断处理函数 */
__irq void TimerIntIsr6(void);  /* Timer6 中断处理函数 */
```

注册时钟设备为定时器：

```c
rk_err_t TimerDev_Register(HDC dev, uint64 usTick, pFunc TimerCallBack); /* 回调函数可为空 */
rk_err_t TimerDev_UnRegister(HDC dev);
```

调整定时器参数，获取定时器信息：

```c
rk_err_t TimerDev_CountSetReloadNum(HDC dev, uint64 cnt); /* 基于 Timer clock 调整定时器周期 */
uint64_t TimerDev_CountGetCurNum(HDC dev);
rk_err_t TimerDev_PeriodSetReloadVal(HDC dev, uint64 usTick); /* 基于 us 调整定时器周期 */
uint64 TimerDev_PeriodGetCurVal(HDC dev);
```

开关定时器：

```c
rk_err_t TimerDev_Start(HDC dev);
rk_err_t TimerDev_Stop(HDC dev);
```

### 函数接口调用范例

参考 shell_timer.c。

### **1.5 shell使用范例**

**创建设备**

```c
timer.create <timer devid>   /*例如： timer.create 0 */
```

**测试定时器功能**

```c
timer.test <timer devid> <period in us> /* 例如 timer.test 0 1000000  */
```

