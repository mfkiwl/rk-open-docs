# Protocol Buffers C实现库Nanopb使用指南

文件标识：RK-KF-YF-384

发布版本：V1.0.0

日期：2020-09-01

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

介绍Protocol Buffers的嵌入式C语言实现库Nanopb。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **版本号** | **作者**    | **修改日期** | **修改说明** |
| ---------- | ----------- | :----------- | ------------ |
| V1.0.0     | Conway.Chen | 2020-09-01   | 初始版本     |

---

**目录**

[TOC]

---

## Protocol Buffers介绍

Protocol Buffers 是Google提供的一个开源序列化框架。它是一种数据交换的格式，与语言无关，与平台无关。仅需要自定义一次你所需的数据格式，然后使用Protocol Buffers 编译器（脚本）自动生成各种语言的源码，方便的读写用户自定义的格式化的数据。

Protocol Buffers 主要应用于通信协议，数据存储中的结构化数据的序列化。它类似于XML，JSON等数据表示语言，其最大特点是基于二进制，比传统的XML表示高效短小得多。

Protocol Buffersf结构化数据转化为二进制流举例：

```
struct Msg
{
  Int val;
};
Unsigned char streambuf[128];
Msg A;
A.val = 9;
Protobuf.encode(streambuf,A);//编码
Msg B;
Protobuf.decode(streambuf,B);//解码
则B.val制就是A.val了
```

## Nanopb 介绍

Nanopb 是用C语言实现，是用于嵌入式领域的Protocol Buffers 源码库，它仅需很小的资源就能运行，编译后代码空间需要2~10K，RAM只需要300字节。

Nanopb（V0.3.9.2）源码：

````
src\components\net\nanopb
````

编译前`make menuconfig`开启：

````
COMPONENTS_NET_NANOPB
````

### 开发流程

1. 首先得到`*.proto`命名的描述协议字段信息文件。通常是由服务器开发工程师提供给嵌入式开发工程师。如果想自定义`*.proto`文件查看章节 **2.4**。

2. `*.proto`文件用脚本转化为对应的语言文件，如转为C文件。查看章节**2.2**。

利用Nanopb的脚本生成对应的两个C语言协议描述文件: 如simple.pb.c、simple.pb.h。

3. 在嵌入式应用中使用转化出来的文件simple.pb.c、simple.pb.h，配合Nanopb的源文件即可使用。查看章节**2.3**。

### 生成协议描述文件

src/components/net/nanopb/examples/simple目录下是官方测试用例。

目录下simple.proto该文件描述结构体的字段信息（通常为服务器端工程师提供）。

```shell
src/components/net/nanopb/examples/simple$ ls
Makefile  README.txt  simple.c  simple.proto
```

执行脚本../../generator-bin/protoc --nanopb_out=. simple.proto。执行该脚本后，将simple.proto转化为simple.pb.c和simple.pb.h。

```shell
src/components/net/nanopb/examples/simple$ ../../generator-bin/protoc --nanopb_out=. simple.proto
cw@SYS3:~/story/8_2206/src/components/net/nanopb/examples/simple$ ls
Makefile  README.txt  simple.c  simple.pb.c  simple.pb.h  simple.proto
```

执行make并运行Linux编译出的可运行程序

```shell
src/components/net/nanopb/examples/simple make
src/components/net/nanopb/examples/simple ./simple
Your lucky number was 13!
```

### 嵌入式平台下使用

使用的源文件：

```
Nanopb运行库（src/components/net/nanopb/）：
pb.h
pb_common.h和pb_common.c（始终需要）
pb_decode.h和pb_decode.c（用于解码消息）
pb_encode.h和pb_encode.c（编码消息所需）

协议描述（可以有多个.proto）：
simple.proto（仅作为示例，由服务器端工程师提供）
simple.pb.c（脚本自动生成协议描述文件一，包含const数组的初始化程序）
simple.pb.h（脚本自动生成协议描述文件二，包含类型声明）
```

嵌入式应用只需要使用章节**2.2**中生成的simple.pb.c、simple.pb.h，再使用Nanopb运行库中的四个头文件即可。

### 自定义消息协议

message.proto

```C
message Example {
   required int32 value = 111;
}
```

利用脚本生成对应的协议描述文件

```C
src/components/net/nanopb/examples/simple$ ../../generator-bin/protoc --nanopb_out=. message.proto

//注意脚本和.proto件路径
```

自动生成message.pb.h的内容如下

```C
typedef struct {
   int32_t value;
} Example;

extern const pb_msgdesc_t Example_msg;
#define Example_fields &Example_msg
```

使用时包括Nanopb 头文件和生成的头文件，对消息编码程序示例：

```C
#include <pb_encode.h>
#include "message.pb.h"
Example mymessage = {66};
uint8_t buffer[15];
pb_ostream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));
pb_encode(&stream, Example_fields, &mymessage);
```