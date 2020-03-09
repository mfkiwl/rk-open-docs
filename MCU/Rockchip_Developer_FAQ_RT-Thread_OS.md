# Rockchip RT-Thread FAQ For OS

文件标识：RK-XX-XX-nnn

发布版本：V1.0.0

日期：2020-03-09

文件密级：□绝密   □秘密   □内部资料   ■公开

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

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文提供一个标准模板供套用。后续模板以此份文档为基础改动。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| 通用    | RT-Thread 3.1.x |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 陈谋春 | 2020-03-09 | 初始版本     |

**目录**

---

[TOC]

---

## 1. 浮点打印

   官方的 RT-Thread （后面简称 RTT ）不支持浮点打印，毕竟相当一部分 MCU 甚至连浮点指令都不支持，如果在调试过程中需要用到浮点打印，可以通过如下步骤实现：

- Step1: 把 libc 从nano版本切换到标准版本：

```shell
    # 修改 BSP 主目录下的 rtconfig.py，例如：bsp/rockchip/rk2108/rtconfig.py
    # 删掉 LFLAGS 中 ‘--specs=nano.specs’ 的标志，具体如下：
    # LFLAGS = DEVICE + ' -lm -lgcc -lc' + ' --specs=nano.specs -nostartfiles -Wl,--gc-sections,-Map=rtthread.map,-cref,-u,Reset_Handler '
    LFLAGS = DEVICE + ' -lm -lgcc -lc' + ' -nostartfiles -Wl,--gc-sections,-Map=rtthread.map,-cref,-u,Reset_Handler '
```

- Step2: 用 sprintf 函数把浮点输出到字符串，再通过 rtprintf 打印：

```c
    float mem_bw;
    uint32_t time_ms;
    uint32_t bytes;
    char buf[16];

    mem_bw = ((bytes * 1.0) / time_ms) * 1000;
    sprintf(buf, "%.4f", mem_bw);
    rtprintf("memory bandwidth: %s\n", buf);
```

## 2. 64位长整型打印

   官方的 RTT 支持64位的长整型打印，不过这个功能默认没有打开，可以通过如下方式启用：

```c
/* 修改 /path/to/rt-thread/src/kservice.c，在头部添加如下宏定义 */
#define RT_PRINTF_LONGLONG
```

## 3. 配置界面无法启动

   正常执行 `scons --menuconfig` 会弹出配置界面，如果无法弹出，可能是下面三个原因：

- 没有正确配置编译环境

    menuconfig 命令依赖于两个开发包 `libncurses5-dev build-essential`，所以在执行 menuconfig 之前需要先正确配置你的编译环境，具体可以参考[开发指南](../../quick-start/Rockchip_Developer_Guide_RT-Thread/Rockchip_Developer_Guide_RT-Thread_CN.html#2)。

- 在 Windows 平台上打开过 Kconfig 文件

    menuconfig 命令目前只支持 unix 风格的换行符，即 `\n` 作为换行，Windows 上的一些编辑工具会自动把 `\n` 替换成 `\r\n` ，此时可以看到如下错误日志：

    `./../../Kconfig:1:warning: ignoring unsupported character`

    此时，可以用如下命令把换行符改回来：

```shell
    # 用 vi 打开文件
    :set fileformat=unix
    :w
```

- 添加或修改的 Kconfig 不符合语法规范

    这种错误通常在错误日志里都会列出出错的位置，根据错误提示修改即可，这里不详细介绍。
