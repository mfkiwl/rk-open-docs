# Rockchip Developer Guide RTOS TSADC

文件标识：RK-KF-YF-050

发布版本：V1.0.0

日期：2019-11-29

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

**产品版本**

| **芯片名称** | **内核版本**    |
| ------------ | --------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**       |
| ---------- | -------- | -------- | ------------------ |
| 2019-11-26 | V1.0.0   | Elaine   | 第一次版本发布     |

---

[TOC]

---

## 1  HAL TSADC 配置

### 1.1  HAL CONFIG

依赖driver开启：

```c
#ifdef CONFIG_MCU_HAL_TSADC
#define HAL_TSADC_MODULE_ENABLED
#endif
```

### 1.2  HAL 差异部分

不同芯片差异部分在hal_bsp.c,主要定义tsadc的CLK ID，CLK频率，还有一些硬件信息：

```c
#ifdef HAL_TSADC_MODULE_ENABLED
const struct HAL_TSADC_DEV g_tsadcDev =
{
    .sclkID = CLK_TSADC,
    .sclkGateID = CLK_TSADC_GATE,
    .pclkGateID = PCLK_TSADC_GATE,
    .sclkResetID = SRST_TSADC,
    .pclkResetID = SRST_P_TSADC,
    .speed = 650000,
    .polarity = TSHUT_LOW_ACTIVE,
    .mode = TSHUT_MODE_CRU,
};
#endif
```

- `sclkID`: CLK ID，不同芯片可能会有差异，可以在rk2206.h或者soc.h中查找，用于频率设置；
- `sclkGateID`：SCLK GATE ID，用于CLK开关；
- `pclkGateID`：PCLK GATE ID，用于CLK开关；
- `sclkResetID`：SCLK RESET ID，用于CLK SOFT RESET；
- `pclkResetID`：PCLK GATE ID，用于CLK SOFT RESET；
- `speed`：CLK RATE，用于频率设置；
- `polarity`：TSHUT脚极性，根据硬件信息设置，TSHUT_LOW_ACTIVE：TSHUT默认高电平，高温是TSHUT拉低， TSHUT_HIGH_ACTIVE：TSHUT默认低电平，高温是TSHUT拉高；
- `mode`：TSHUT后行为，根据硬件信息设置，TSHUT_MODE_CRU：TSHUT产生后复位CRU方式重启系统，TSHUT_MODE_GPIO： TSHUT后拉高或者拉低TSHUT脚复位硬件电路；

### 1.3  HAL 常用 API

```c
HAL_Status HAL_TSADC_Enable_AUTO(int chn, eTSADC_tshutPolarity polarity, eTSADC_tshutMode mode);
HAL_Status HAL_TSADC_Disable_AUTO(int chn);
HAL_Check HAL_TSADC_IsEnabled_AUTO(int chn);
int HAL_TSADC_GetTemperature_AUTO(int chn);
```

## 2 RKOS TSADC配置

### 2.1  RKOS TSADC CONFIG

```c
make menuconfig

→ BSP Driver
	-*- Enable TSADC
```

### 2.2  RKOS 常用API

```c
rk_err_t TsadcEnable(void);
rk_err_t TsadcDisable(void);
int TsadcGetTempByAutoMode(int chn);
```

### 2.3  RKOS 使用示例

使用示例：

```c
int temp;

temp = TsadcGetTempByAutoMode(0);/* 通道0温度 */
```

## 3 TEST

### 3.1  CONFIG配置

```c
Components Config  --->
    Command shell  --->
        [*]     Enable PM_TEST Shell
```

### 3.2  USAGE

```c
"    tsadc <channel>    get the temperature of <channel>\r\n"
```

使用示例：

```c
/* 读取通道0温度 */
tsadc 0
```
