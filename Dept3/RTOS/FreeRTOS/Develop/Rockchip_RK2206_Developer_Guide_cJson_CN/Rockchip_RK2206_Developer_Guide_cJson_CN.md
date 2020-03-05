# RK2206 cJson开发指南

文件标识：RK-KF-YF-328

发布版本：V1.0.0

日期：2020-02-20

文件密级：□绝密   □秘密   □内部资料   ■公开

------

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

商标声明

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

版权所有 © 2020 福州瑞芯微电子股份有限公司

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

本文旨在介绍Cjson库的使用，并讲述JSON相关概念和工具，包含相关示例和注意事项。

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
| 2020-02-20 | V1.0.0   | Conway Chen    | 初始版本               |

## **目录**

[TOC]

## **1 JSON**

### **1.1 JSON定义**

json举例:

```json
{
	"name": "瑞芯微电子",
	"url": "http://www.rock-chips.com",
	"page": 88,
	"isNonProfit": true,
	"address": {
		"street": "软件园.",
		"city": "福州",
		"country": "中国"
	},
	"links": [{
		"name": "Google",
		"url": "http://www.google.com"
	}, {
		"name": "Baidu",
		"url": "http://www.baidu.com"
	}, {
		"name": "SoSo",
		"url": "http://www.SoSo.com"
	}]
}
```

JSON：JavaScript对象表示法（JavaScript Object Notation）。是一种轻量级的数据交换格式。它基于ECMAScript的一个子集。JSON采用完全独立于语言的文本格式，但是也使用了类似C语音家族的习惯（包括C、C++、C#、Java、JavaScript、Perl、Python等）。这些特性使JSON成为理想的数据交换语言。易于人阅读和编写，同时也易于机器解析和生成（一般用于提升网络传输速率）。

- JSON基于两种结构

  - 键-值对的集合（A collection of name/value pairs）。不同的编程语言中，它被理解为对象（object），纪录（record），结构（struct），字（dictionary），哈希表（hashtable），有键列表（keyed list），或者关联数组 （associative array）。
  - 值的有序列表（An ordered list of values）。在大部分语言中，它被实现为数组（array），矢量（vector），列表（list），序列（sequence）。

- JSON的三种语法

  - 键-值对（key:value），用半角冒号分割。比如 "company":"Rockchip"；
  - JSON对象写在花括号中，可以包含多个键-值对。比如{ "name":"RK" ,"address":"FuZhou" }。
  - JSON数组在方括号中书写,数组成员可以是对象，值，也可以是数组(只要有意义)。{"cpu": ["RK3399","RK3126C","RK2206","RK208"]}

### **1.2 JSON语法举例**

- JSON对象

```json
{
    "starcraft": {
        "INC": "RockChip",
        "price": 100
    }
}
```

- JSON对象数组

```json
{
    "person": [
        "conway",
        60
    ]
}
```

### **1.2 JSON文本处理**

介绍JSON数据的压缩，格式化。

```json
在线格式化工具
https://www.sojson.com
https://www.json.cn

一段JSON文本：

{"name":"BeJson","url":"http://www.bejson.com","page":88,"isNonProfit":true,"address":{"street":"科技园路.","city":"江苏苏州","country":"中国"},"links":[{"name":"Google","url":"http://www.google.com"},{"name":"Baidu","url":"http://www.baidu.com"},{"name":"SoSo","url":"http://www.SoSo.com"}]}

格式化后：
{
	"name": "BeJson",
	"url": "http://www.bejson.com",
	"page": 88,
	"isNonProfit": true,
	"address": {
		"street": "科技园路.",
		"city": "江苏苏州",
		"country": "中国"
	},
	"links": [{
		"name": "Google",
		"url": "http://www.google.com"
	}, {
		"name": "Baidu",
		"url": "http://www.baidu.com"
	}, {
		"name": "SoSo",
		"url": "http://www.SoSo.com"
	}]
}

压缩后：
{"name":"BeJson","url":"http://www.bejson.com","page":88,"isNonProfit":true,"address":{"street":"科技园路.","city":"江苏苏州","country":"中国"},"links":[{"name":"Google","url":"http://www.google.com"},{"name":"Baidu","url":"http://www.baidu.com"},{"name":"SoSo","url":"http://www.SoSo.com"}]}

转义后（数组存储JSON时,是一段压缩并转义过的字符串）：
{\"name\":\"BeJson\",\"url\":\"http://www.bejson.com\",\"page\":88,\"isNonProfit\":true,\"address\":{\"street\":\"科技园路.\",\"city\":\"江苏苏州\",\"country\":\"中国\"},\"links\":[{\"name\":\"Google\",\"url\":\"http://www.google.com\"},{\"name\":\"Baidu\",\"url\":\"http://www.baidu.com\"},{\"name\":\"SoSo\",\"url\":\"http://www.SoSo.com\"}]}
```

## **2 cJSON**

### **2.1 cJSON库**

cJSON是个轻量级的C语言JSON库，速度快，代码少，只有两个文件：cJSON.h和cJSON.c。

### **2.2 源码和编译**

- cJSON源码:

```
src/components/net/cjson
```

- 引用头文件

```
#include "net/cjson/cJSON.h"
```

- 编译cJSON和cJSON测试脚本

```
make distclean

make menuconfig
路径(top menu) → Components Config → NetWork → 使能CJSON
路径(top menu) → Components Config → Command → shellEnable cJson shell cmd （CJSON的测试脚本，根据需要打开）

make build -j32
```

### **2.3 cJSON测试脚本**

cJSON的测试脚本提供3个测试用例，供用户编译cJSON及其测试脚本后烧录运行测试。

```
cJSON测试脚本: src/subsys/shell/shell_cjson.c
cJSON测试命令:
cjson 1    //运行测试用例1
cjson 2    //运行测试用例2
cjson 3    //运行测试用例3
```

测试日志

```
RK2206>cjson 1
[cjson_test] name = rockchip
[A.14.00][000107.665481][cjson_test] address = Fuzhou
RK2206>cjson 2
[cjson_test] code = success
[A.14.00][000108.847380]
[A.14.00][000108.853413][cjson_test] msg = 成功
[A.14.00][000108.862993]
[A.14.00][000108.874260][cjson_test] token = rockchip
[A.14.00][000108.881047]
[A.14.00][000108.890315]
RK2206>cjson 3
[cjson_test] ## formatted print json:
[A.14.00][000109.046595][cjson_test] {
[A.14.00][000109.053688]        "semantic":     {
[A.14.00][000109.064129]                "slots":        {
[A.14.00][000109.068403]                        "name": "RockChip"
[A.14.00][000109.076435]                }
[A.14.00][000109.086956]        },
[A.14.00][000109.089476]        "rc":   200,
[A.14.00][000109.095668]        "operation":    "get",
[A.14.00][000109.105618]        "service":      "cpu",
[A.14.00][000109.109397]        "text": "company"
[A.14.00][000109.117177]}
[A.14.00][000109.127528]
[A.14.00][000109.129797][cjson_test] ## unformatted print json:
[A.14.00][000109.137341][cjson_test] {"semantic":{"slots":{"name":"RockChip"}},"rc":200,"operation":"get","service":"cpu","text":"company"}
[A.14.00][000109.157265]
[A.14.00][000109.159533][cjson_test] ## Get the name key value pair step by step:
[A.14.00][000109.168589][cjson_test] ## Get the cjson object under Semantic:
[A.14.00][000109.184230][cjson_test] {
[A.14.00][000109.193674]        "slots":        {
[A.14.00][000109.205862]                "name": "RockChip"
[A.14.00][000109.211810]        }
[A.14.00][000109.220246]}
[A.14.00][000109.231602][cjson_test] ## Get cjson object under slots
[A.14.00][000109.238566][cjson_test] {
[A.14.00][000109.249004]        "name": "RockChip"
[A.14.00][000109.253867]}
[A.14.00][000109.260219][cjson_test] ## Get cjson object under name
[A.14.00][000109.273105][cjson_test] "RockChip"
[A.14.00][000109.280305][cjson_test] ## Take a look at the meaning of these two members
[A.14.00][000109.294861][cjson_test] name:
[A.14.00][000109.302641][cjson_test] RockChip
[A.14.00][000109.314678]
[A.14.00][000109.318946][cjson_test]
[A.14.00][000109.326306]## Print all innermost key value pairs of JSON
[A.14.00][000109.340435]name->[cjson_test] "RockChip"
[A.14.00][000109.349141]
[A.14.00][000109.360410]rc->[cjson_test] 200
[A.14.00][000109.365358]
[A.14.00][000109.372625]operation->[cjson_test] "get"
[A.14.00][000109.384327]
[A.14.00][000109.388594]service->[cjson_test] "cpu"
[A.14.00][000109.397131]
[A.14.00][000109.408402]text->[cjson_test] "company"
RK2206>
```

### **2.4 cJSON库使用例程**

- 嵌入式使用场景

嵌入式设备以HTTP协议与服务器通信，使用cJSON来创建JSON上传服务器，或解析服务器下发的JSON。

- 创建JSON

嵌入式设备将本地相关信息封装为JSON格式，放在HTTP的Body再上传服务器。

- JSON在线格式化工具

cJson编程中，可能需要对JSON格式文本处理。在线格式化工具举例：

```
https://www.sojson.com
https://www.json.cn
```

组建JSON举例：

```json
{
    "userId": 121212,
    "albumId": "12345"
}
```

```c
cJSON *root = cJSON_CreateObject();
cJSON_AddItemToObject(root, "userId", cJSON_CreateNumber(String2Num(dev_info->userId)));//用户ID
cJSON_AddItemToObject(root, "albumId", cJSON_CreateString(albumId));       //专辑ID
char *post_data = cJSON_Print(root); //json结构体转字符串，内部是malloc内存，使用字符串后务必free
```

- 解析JSON

嵌入式设备收到服务器的JSON是字符串形式，使用cJSON_Parse将字符串转为cJSON结构体，再使用像cJSON_GetObjectItem()的函数使用key获得对应的value。vule的类型判断使用 cJSON_IsNumber这样的函数。如果JSON里面包含元素数组，使用cJSON_GetArraySize获取数组大小，再通过cJSON_GetArrayItem逐个获取数组元素。对于布尔类型，ture就是1，false就是0。

解析JSON举例：

```json
{
        "msg":  "操作成功！",
        "code": 0,
        "data": {
                "hasUpdate":    true,
                "isForce":      false,
                "isAutoInstall":        false,
                "versionCode":  20191204,
                "packageName":  "name-x",
                "updateContent":        "",
                "url":  "https://www.baidu.com",
                "size": 1426
        }
}
```

```c
int parse(device *dev_info, cJSON *root)
{
    if (NULL == root || NULL == dev_info || NULL == dev_info->ota_info)
    {
        YHK_ERR("[parse_ota_remote_version] root is null");
        return -1;
    }
    cJSON *pJson, *pSub1, *pSub2;
    memset(dev_info->ota_info, 0, sizeof(ota_info_t));

    pJson = root;
    YHK_PUTS(cJSON_Print(pJson));

    pSub1 = cJSON_GetObjectItem(pJson, "code");
    if (pSub1)
        dev_info->ota_info->code = pSub1->valueint;

    pSub1 = cJSON_GetObjectItem(pJson, "msg");
    if (pSub1)
        memcpy(dev_info->ota_info->msg, pSub1->valuestring, strlen(pSub1->string));

    pSub1 = cJSON_GetObjectItem(pJson, "data");
    if (pSub1)
    {
        pSub2 = cJSON_GetObjectItem(pSub1, "hasUpdate");      //bool
        if (pSub2)
            dev_info->ota_info->hasUpdate  = pSub2->valueint;
        pSub2 = cJSON_GetObjectItem(pSub1, "isAutoInstall");  //bool
        if (pSub2)
            dev_info->ota_info->isAutoInstall = pSub2->valueint;
        pSub2 = cJSON_GetObjectItem(pSub1, "versionCode");
        if (pSub2)
            dev_info->ota_info->versionCode = pSub2->valueint;
        pSub2 = cJSON_GetObjectItem(pSub1, "packageName");
        if (pSub2)
            strcpy(dev_info->ota_info->packageName, pSub2->valuestring);
        pSub2 = cJSON_GetObjectItem(pSub1, "updateContent");
        if (pSub2)
            memcpy(dev_info->ota_info->updateContent, pSub2->valuestring, strlen(pSub1->string));
        pSub2 = cJSON_GetObjectItem(pSub1, "url");
        if (pSub2)
            strcpy(dev_info->ota_info->url, pSub2->valuestring);
        pSub2 = cJSON_GetObjectItem(pSub1, "size");
        if (pSub2)
            dev_info->ota_info->size = pSub2->valueint;
        ota_info_print(dev_info);
    }
    return 0;
}
```

### **2.5 cJSON注意事项**

cJson使用的内存为malloc方式申请，使用后请free释放相关指针指向的内存，否则长时间运行可能造成设备内存泄漏。

## **3 cJSON API**

### **3.1 cJSON API 速查表格形式**

| cJSON  API                                | 说明                                                         |
| ----------------------------------------- | ------------------------------------------------------------ |
| cJSON_Version()                           | 获得cJSON的版本                                              |
| cJSON_InitHooks();                        | 初始化cJSON_Hooks结构体，<br/>移植CSJON时,向cJSON提供malloc、realloc和free函数 |
| cJSON_Parse();                            | 将字符串解析成cJSON结构体<br/>使用后务必调用cJSON_Delete     |
| cJSON_ParseWithOpts()                     | 使用一些配置解析字符串                                       |
| cJSON_Print()                             | 将cJSON结构体转换成格式化的字符串。<br/>char* pstr = cJSON_Print(json);<br/>free(pstr); 使用后请free，不然可能造成内存泄漏 |
| cJSON_PrintUnformatted()                  | 将cJSON结构体转换成未格式化的字符串                          |
| cJSON_PrintBuffered()                     | 将cJSON结构体使用buffer的字符串，格式化可选                  |
| cJSON_PrintPreallocated()                 | 将cJSON结构体使用预分配的内存的字符串，格式化可选            |
| cJSON_Delete()                            | 删除cJSON结构体                                              |
| cJSON_GetArraySize()                      | 返回Array类型的大小,对Object类型也是有效的                   |
| cJSON_GetArrayItem()                      | 返回Array类型的index的值，对Object类型也有效                 |
| cJSON_GetObjectItem()                     | 使用key获得对应的value                                       |
| cJSON_GetObjectItemCaseSensitive()        | 使用对大小写敏感的key获得对应的value                         |
| cJSON_HasObjectItem()                     | 判断是否ObjectItem存在                                       |
| cJSON_GetErrorPtr()                       | 获得错误信息                                                 |
| cJSON_IsInvalid()                         | 类型判断                                                     |
| cJSON_IsFalse()                           | 类型判断                                                     |
| cJSON_IsTrue()                            | 类型判断                                                     |
| cJSON_IsBool()                            | 类型判断                                                     |
| cJSON_IsNull()                            | 类型判断                                                     |
| cJSON_IsNumber()                          | 类型判断                                                     |
| cJSON_IsString()                          | 类型判断                                                     |
| cJSON_IsArray()                           | 类型判断                                                     |
| cJSON_IsObject()                          | 类型判断                                                     |
| cJSON_IsRaw()                             | 类型判断                                                     |
| cJSON_CreateNull()                        | 创造对应类型的cJSON                                          |
| cJSON_CreateTrue()                        | 创造对应类型的cJSON                                          |
| cJSON_CreateFalse()                       | 创造对应类型的cJSON                                          |
| cJSON_CreateBool()                        | 创造对应类型的cJSON                                          |
| cJSON_CreateNumber()                      | 创造对应类型的cJSON                                          |
| cJSON_CreateString()                      | 创造对应类型的cJSON                                          |
| cJSON_CreateRaw()                         | 创造对应类型的cJSON                                          |
| cJSON_CreateArray()                       | 创造对应类型的cJSON                                          |
| cJSON_CreateObject()                      | 创造对应类型的cJSON                                          |
| cJSON_CreateIntArray()                    | 批量创造对应类型的cJSON                                      |
| cJSON_CreateFloatArray()                  | 批量创造对应类型的cJSON                                      |
| cJSON_CreateDoubleArray()                 | 批量创造对应类型的cJSON                                      |
| cJSON_CreateStringArray()                 | 批量创造对应类型的cJSON                                      |
| cJSON_AddItemToArray()                    | 在指定Array后面增加Item                                      |
| cJSON_AddItemToObject()                   | 在指定Object后面增加Item                                     |
| cJSON_AddItemToObjectCS()                 | 在指定Object后面增加const Item                               |
| cJSON_AddItemReferenceToArray()           | 在指定Array后面增加Item引用                                  |
| cJSON_DetachItemFromArray()               | 从Array删除Item的引用                                        |
| cJSON_DeleteItemFromArray()               | 从Array删除Item                                              |
| cJSON_DetachItemFromObject()              | 从Object删除Item的引用                                       |
| cJSON_DetachItemFromObjectCaseSensitive() | 大小写敏感的从Object删除Item的引用                           |
| cJSON_DeleteItemFromObject()              | 从Object删除Item                                             |
| cJSON_DeleteItemFromObjectCaseSensitive() | 大小写敏感的从Object删除Item                                 |
| cJSON_InsertItemInArray()                 | 在Array指定位置插入Item                                      |
| cJSON_ReplaceItemInArray()                | 替换Array的Item                                              |
| cJSON_ReplaceItemInObject()               | 替换Object的Item                                             |
| cJSON_ReplaceItemInObjectCaseSensitive()  | 大小写敏感的替换Object的Item                                 |
| cJSON_Duplicate()                         | 复制cJSON结构体                                              |
| cJSON_Minify()                            | 将格式化的字符串压缩                                         |
| cJSON_AddNullToObject()                   | 调用cJSON_AddItemToObject和cJSON_CreateNull                  |
| cJSON_AddTrueToObject()                   | 调用cJSON_AddItemToObject和cJSON_CreateTrue                  |
| cJSON_AddFalseToObject()                  | 调用cJSON_AddItemToObject和cJSON_CreateFalse                 |
| cJSON_AddBoolToObject()                   | 调用cJSON_AddItemToObject和cJSON_CreateBool                  |
| cJSON_AddNumberToObject()                 | 调用cJSON_AddItemToObject和cJSON_CreateNumber                |
| cJSON_AddStringToObject()                 | 调用cJSON_AddItemToObject和cJSON_CreateString                |
| cJSON_AddRawToObject()                    | 调用cJSON_AddItemToObject和cJSON_CreateRaw                   |
| cJSON_SetIntValue()                       | 设置int的值或double的值                                      |
| cJSON_SetNumberValue()                    | 后台会调用cJSON_SetNumberHelper                              |
| cJSON_SetNumberHelper()                   | 设置cJSON的number类型的值                                    |
| cJSON_ArrayForEach()                      | 遍历数组                                                     |

### **3.2 CJSON API 详细形参形式**

- 返回cJSON版本（字符串）

```c
cJSON_Version(void);
```

- 移植CSJON时，向cJSON提供malloc、realloc和free函数

```c
cJSON_InitHooks(cJSON_Hooks* hooks);
```

- JSON字符串转cJSON结构体，使用后务必调用cJSON_Delete

```c
cJSON_Parse(const char *value);
```

- 将cJSON结构体转换成格式化的字符串，获取字符串指针使用这段内存后，记得free释放内存，否者可能导致内存泄漏

```c
cJSON_Print(const cJSON *item);
```

如

```c
char* pstr = cJSON_Print(json);
free(pstr);
```

- 将cJSON结构体转换成字符串

```c
cJSON_PrintUnformatted(const cJSON *item);
cJSON_PrintBuffered(const cJSON *item, int prebuffer, cJSON_bool fmt);
cJSON_PrintPreallocated(cJSON *item, char *buffer, const int length, const cJSON_bool format);
```

- 删除一个cJSON实体和所有子实体

```c
cJSON_Delete(cJSON *c);
```

- 返回数组长度,对Object类型也有效

```c
CJSON_PUBLIC(int) cJSON_GetArraySize(const cJSON *array);
```

- 返回数组的某个元素

```c
cJSON_GetArrayItem(const cJSON *array, int item);
```

- 使用key获得对应的value

```c
cJSON_GetObjectItem(const cJSON *object, const char *string);
```

- 使用对大小写敏感的key获得对应的value

```c
cJSON_GetObjectItemCaseSensitive(const cJSON *object, const char *string);
```

- 判断ObjectItem是否存在

```c
cJSON_HasObjectItem(const cJSON *object, const char *string);
```

- 当cJSON_Parse（）返回0时成功，非0时为失败，失败则cJSON_GetErrorPtr将返回指向分析错误的指针

```c
cJSON_GetErrorPtr(void);
```

- 判断数据类型

```c
cJSON_IsInvalid(const cJSON * const item);
cJSON_IsFalse(const cJSON * const item);
cJSON_IsTrue(const cJSON * const item);
cJSON_IsBool(const cJSON * const item);
cJSON_IsNull(const cJSON * const item);
cJSON_IsNumber(const cJSON * const item);
cJSON_IsString(const cJSON * const item);
cJSON_IsArray(const cJSON * const item);
cJSON_IsObject(const cJSON * const item);
cJSON_IsRaw(const cJSON * const item);
```

- 创建对应类型的cJSON

```c
cJSON_CreateNull(void);
cJSON_CreateTrue(void);
cJSON_CreateFalse(void);
cJSON_CreateBool(cJSON_bool boolean);
cJSON_CreateNumber(int num);
cJSON_CreateString(const char *string);
cJSON_CreateRaw(const char *raw);
cJSON_CreateArray(void);
cJSON_CreateObject(void);
```

- 批量创建对应类型的cjson

```c
cJSON_CreateIntArray(const int *numbers, int count);
cJSON_CreateFloatArray(const float *numbers, int count);
cJSON_CreateDoubleArray(const int *numbers, int count);
cJSON_CreateStringArray(const char **strings, int count);
```

- 在指定Array后面增加Item

```c
cJSON_AddItemToArray(cJSON *array, cJSON *item);
```

- 在指定Object后面增加Item

```c
cJSON_AddItemToObject(cJSON *object, const char *string, cJSON *item);
```

- 在指定Object后面增加const Item

```c
cJSON_AddItemToObjectCS(cJSON *object, const char *string, cJSON *item);
```

- 在指定Array后面增加Item引用

```c
cJSON_AddItemReferenceToArray(cJSON *array, cJSON *item);
```

- 通过指针从Array删除Item的引用

```c
cJSON_AddItemReferenceToObject(cJSON *object, const char *string, cJSON *item);
```

- 从Array删除Item的引用

```c
cJSON_DetachItemFromArray(cJSON *array, int which);
```

- 从Array删除Item

```c
cJSON_DeleteItemFromArray(cJSON *array, int which);
```

- 从Object删除Item的引用

```c
cJSON_DetachItemFromObject(cJSON *object, const char *string);
```

- 从Object删除Item

```c
cJSON_DeleteItemFromObject(cJSON *object, const char *string);
```

- 在Array指定位置插入Item

```c
cJSON_InsertItemInArray(cJSON *array, int which, cJSON *newitem);
```

- 替换Array的Item

```c
cJSON_ReplaceItemInArray(cJSON *array, int which, cJSON *newitem);
```

- 替换Object的Item

```c
cJSON_ReplaceItemInObject(cJSON *object,const char *string,cJSON *newitem);
```

- 复制cJSON结构体

```c
cJSON_Duplicate(const cJSON *item, cJSON_bool recurse);
```

- 使用一些配置解析字符串

```c
cJSON_ParseWithOpts(const char *value, const char **return_parse_end, cJSON_bool require_null_terminated);
```

- 将格式化的字符串压缩

```c
CJSON_PUBLIC(void) cJSON_Minify(char *json);
```

- 用于快速creating things的宏

```c
#define cJSON_AddNullToObject(object,name) cJSON_AddItemToObject(object, name, cJSON_CreateNull())
#define cJSON_AddTrueToObject(object,name) cJSON_AddItemToObject(object, name, cJSON_CreateTrue())
#define cJSON_AddFalseToObject(object,name) cJSON_AddItemToObject(object, name, cJSON_CreateFalse())
#define cJSON_AddBoolToObject(object,name,b) cJSON_AddItemToObject(object, name, cJSON_CreateBool(b))
#define cJSON_AddNumberToObject(object,name,n) cJSON_AddItemToObject(object, name, cJSON_CreateNumber(n))
#define cJSON_AddStringToObject(object,name,s) cJSON_AddItemToObject(object, name, cJSON_CreateString(s))
#define cJSON_AddRawToObject(object,name,s) cJSON_AddItemToObject(object, name, cJSON_CreateRaw(s))
```

- 设置int的值，设置double的值

```c
#define cJSON_SetIntValue(object, number) ((object) ? (object)->valueint = (object)->valuedouble = (number) : (number))
```

- 调用cJSON_SetNumberHelper

```c
CJSON_PUBLIC(int) cJSON_SetNumberHelper(cJSON *object, int number);
#define cJSON_SetNumberValue(object, number) ((object != NULL) ? cJSON_SetNumberHelper(object, (int)number) : (number))
```

- 遍历数组

```c
#define cJSON_ArrayForEach(element, array) for(element = (array != NULL) ? (array)->child : NULL; element != NULL; element = element->next)
```
