# Rockchip RK2206 开发文档

文件标识：RK-KF-YF-065

发布版本：V1.0.0

日期：2019-12-02

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

本文提供一个标准模板供套用。后续模板以此份文档为基础改动。

**产品版本**

| **芯片名称** | **内核版本**         |
| -------- | ---------------- |
| RK2206   | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

---

**修订记录**

| **版本号** | **作者**   | **修改日期**   | **修改说明** |
| ------- | -------- | :--------- | -------- |
| V1.0.0  | David.Wu | 2019-12-02 | 初始版本     |

**目录**

---
[TOC]
---
## 1  I2C 总线接口用途

用于外接 I2C 外设的总线规范，方便用户实现对不同外接设备的控制和访问I2C 总线控制器通过串行数据（SDA）线和串行时钟 （SCL）线在连接到总线的器件间传递信息。Rockchip I2C 控制器支持下列功能:

- 兼容 I2C 与 SMBus 总线
- 仅支持主模式下的 I2C 总线
- 软件可编程时钟频率支持 Standard mode(100K)， Fast mode(400K)， Fast+ mode(1000K)

## 2  I2C  配置

### 2.1 menuconfig 配置

在 menuconfig 里面将控制器的驱动勾选 DRIVER_I2C，并同时根据当前的硬件情况，勾选所使用的 I2C bus, 可多选。

```c
    BSP Driver  --->
        [*] Enable I2C
```

例如选中 I2C0 和 I2C2:

```c
[*] Enable I2C0 (NEW)
[ ]  Enable I2C1 (NEW)
[*] Enable I2C2
```

如果需要使用 shell 测试命令进行测试，勾选 I2C 测试shell：

```c
    Components Config --->
        Command shell  --->
            [*] Enable I2C Shell
```

### 2.2 板级文件配置

板级配置，请修改对应工程的 board.c 文件里的 I2cDevHwInit() 函数，主要包含两个配置：

- 配置正确的 iomux，需要注意的是一路 I2C 可能有几种 iomux 选择(m0, m1...)， 根据实际硬件原理图选择正确的配置。

- 配置 I2C 速度，推荐配置100, 400, 1000 (后面两种速度，请确认上升沿时间是符合该模式下的时序规范)。

```c
INIT API void I2cDevHwInit(uint32 DevID, uint16 *speed)
{
    switch (DevID)
    {
    case I2C_DEV0:
        *speed = 100; //100K
        iomux_config_i2c0_m0(); //i2c0 m0 iomux
        break;
    case I2C_DEV1:
        break;
    case I2C_DEV2:
        *speed = 100;
        iomux_config_i2c2_m0();
        break;
    default:
        break;
    }
}
```

## 3 代码和 API 使用

### 3.1 代码位置

- 控制器驱动层代码 ./src/driver/i2c/I2cDevice.c
- 控制器 HAL 层代码 ./src/bsp/hal/lib/hal/src/hal_i2c.c
- I2C shell 测试代码 ./src/subsys/shell/shell_i2c.c

### 3.2 I2C API 接口

```c
extern rk_err_t I2CDev_Delete(uint8 DevID, void *arg);
extern HDC I2CDev_Create(uint8 DevID, void *arg);
extern void I2cDevHwInit(uint32 DevID, uint16 *speed);
extern void I2cDevHwDeInit(uint32 DevID);
extern rk_err_t I2cDev_SendData(HDC dev, uint8 *RegCmd, uint32 size, I2C_CMD_ARG *Tx_arg);
extern rk_size_t I2cDev_ReadData(HDC dev, uint8 *DataBuf, uint32 size, I2C_CMD_ARG *Rx_arg);
```

### 3.3  API 接口使用

#### 3.3.1 创建 I2C 实例

使用 I2CDev_Create() 创建，rkdev_open()得到 I2C device，再这个动作之前可以先 find，如果已经创建了，可以直接使用，例子:

```c
    i2c_dev = rkdev_find(DEV_CLASS_I2C, DevID);
    if (i2c_dev == NULL)
    {
        rkdev_create(DEV_CLASS_I2C, DevID, NULL);
        i2c_dev = rkdev_open(DEV_CLASS_I2C, DevID, NOT_CARE);
        if (i2c_dev == NULL)
        {
            shell_output(dev, "\r\n Can't find i2c%d dev", DevID);
            return RK_ERROR;
        }
    }
```

#### 3.3.2 I2C Write

调用 I2cDev_SendData() 往I2C 总线发送数据，函数参数依次为 I2C device，数据 buffer 指针，数据长度(单位byte)，设备地址，寄存器地址，寄存器地址长度格式， 返回值为寄存器地址长度 + 数据长度。以下是实例:

```c
int i2c_write(uint16 addr, uint16 reg_addr, size_t reg_len,
                           void *data_buf, size_t data_len)
{
    I2C_CMD_ARG stArg;
    int ret;

    stArg.SlaveAddress = addr; //设备地址
    stArg.RegAddr = reg_addr; //寄存器地址
    if (reg_len == 2) //8bit or 16 bit
        stArg.addr_reg_fmt = I2C_7BIT_ADDRESS_16BIT_REG;
    else
        stArg.addr_reg_fmt = I2C_7BIT_ADDRESS_8BIT_REG;

    ret = I2cDev_SendData(i2c_dev, data_buf, data_len, &stArg);
    if (ret == (data_len + reg_len))  //寄存器地址长度 + 数据长度
    {
        return RK_SUCCESS;
    }
    else
    {
        shell_output(dev, "\r\n i2c_shell_write error: %d\n", ret);
        return RK_ERROR;
    }
}
```

#### 3.3.3 I2C Read

调用 I2cDev_ReadData() 从I2C 总线接收数据，函数参数依次为 I2C device，数据 buffer 指针，数据长度(单位byte)，设备地址，寄存器地址，寄存器地址长度格式， 返回值为数据长度。以下是实例:

```c
int i2c_read(uint16 addr, uint16 reg_addr, size_t reg_len,
                          void *data_buf, size_t data_len)
{
    I2C_CMD_ARG stArg;
    int ret;

    stArg.SlaveAddress = addr; //设备地址
    stArg.RegAddr = reg_addr; //寄存器地址
    if (reg_len == 2) //8bit or 16 bit
        stArg.addr_reg_fmt = I2C_7BIT_ADDRESS_16BIT_REG;
    else
        stArg.addr_reg_fmt = I2C_7BIT_ADDRESS_8BIT_REG;

    ret = I2cDev_ReadData(i2c_dev, data_buf, data_len, &stArg);
    if (ret == data_len)  //数据长度
    {
        return RK_SUCCESS;
    }
    else
    {
        shell_output(dev, "\r\n i2c_shell_read error: %d\n", ret);
        return RK_ERROR;
    }
}
```

## 4 SHELL 测试与输出

### 4 .1 I2C 读测试

依次输入 i2c，设备地址，i2c 寄存器地址，i2c 寄存器地址长度，所读取的字节数．以下例子为测试 codec 读测试。

```c
RK2206>i2c_test read i2c2 0x51 0x10 1 1
 recv[0]: 0x8
```

### 4 .1 I2C 写测试

依次输入 i2c，设备地址，i2c 寄存器地址，i2c 寄存器地址长度，所发送的数据，所发送的字节数．以下例子为测试 codec 写测试。

```c
RK2206>i2c_test write i2c2 0x51 0x10 1 0x5a 1
 send[0]: 0x5a
```