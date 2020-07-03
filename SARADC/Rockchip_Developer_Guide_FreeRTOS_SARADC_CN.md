# Rockchip Developer Guide FreeRTOS SARADC

文件标识：RK-KF-YF-062

发布版本：V1.0.0

日期：2019-12-03

文件密级：公开资料

------

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

------

**前言**

**概述**

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**   |
| ---------- | -------- | -------- | -------------- |
| 2019-12-03 | V1.0.0   | Simon    | 第一次版本发布 |

------

[TOC]

------

## HAL SARADC 配置

### HAL CONFIG

依赖driver开启：

```c
#ifdef CONFIG_MCU_HAL_SARADC
#define HAL_SARADC_MODULE_ENABLED
#endif
```

### HAL 差异部分

不同芯片差异主要在CLK ID，CLK频率，可以在rk2206.h或者soc.h中查找

CLK_SARADC_GATE：SCLK GATE ID，用于CLK开关；

PCLK_SARADC_CONTROL_GATE：PCLK GATE ID，用于CLK开关；

### HAL 常用 API

```c
HAL_Status HAL_SARADC_Start(struct SARADC_REG *reg, eSARADC_mode mode, uint32_t chn)；
HAL_Status HAL_SARADC_Stop(struct SARADC_REG *reg)；
void HAL_SARADC_IrqHandler(struct SARADC_REG *reg)；
void HAL_SARADC_ClearIrq(struct SARADC_REG *reg)；
uint32_t HAL_SARADC_GetRaw(struct SARADC_REG *reg)；
```

## RKOS SARADC配置

### RKOS SARADC CONFIG

```c
make menuconfig

→ BSP Driver
	-*- Enable ADC
```

### RKOS 常用API

```c
COMMON FUN rk_err_t ADCDev_Start(ADC_DEVICE_CLASS *ADCDevHandler)；
static COMMON FUN rk_err_t ADCDev_Stop(ADC_DEVICE_CLASS *ADCDevHandler)；
COMMON API rk_err_t ADCDev_Read(HDC dev, uint16 channel, uint16 size, uint16 clk)；
COMMON API rk_err_t ADCDev_GetAdcBufData(HDC dev, uint16 *buf, uint16 size, uint16 clk, uint16 channel)；
```

### RKOS 使用示例

使用示例：

```c
ADCDev_Start(ADCDevHandler)； /* 配置采样通道，打开中断模式，开始采样 */

HAL_SARADC_GetRaw(SARADC)；/* 获取采样值 */

HAL_SARADC_Stop(SARADC)；/* 清除中断，关闭SARADC */
```

## TEST

### CONFIG配置

```c
Components Config  --->
    Command shell  --->
        [*]     Enable SARADC shell cmd
```

### USAGE

使用示例：

```c
adc.create 0 /* 创建SARADC设备0 */
adc.test 0 /* 获取SARADC设备0对应通道的值 */，打印如下：
Adc channel 3 read value = 254
```