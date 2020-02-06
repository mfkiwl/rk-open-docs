# ** RK2206 Developer Guide HTTP Client **

文件标识：RK-KF-YF-336

发布版本：V1.0.0

日期：2020-02-14

文件密级：公开资料

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

本文旨在帮助开发者了解RK2206 SDK网络组件HTTP Client的使用方法及说明，及调试配置的一些注意事项。

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
| 2020-02-14 | V1.0.0   | Conway Chen | 初始版本               |

## **目录**

[TOC]

## **1 HTTP_Client 介绍**

本SDK移植了开源HTTP_Client,支持get和post请求。
开源软件地址[https://fossies.org/dox/MediaInfo_CLI_19.09_GNU_FromSource/dir_3ff5d6b844deaccf71fc87eb699a5715.html](https://fossies.org/dox/MediaInfo_CLI_19.09_GNU_FromSource/dir_3ff5d6b844deaccf71fc87eb699a5715.html)。
为了使该HTTP_Client支持HTTPS功能，本SDK移植了openssl和mbedtls组件支持HTTPS，在HTTP_Client增加HTTPS相关接口。用户不需要关心这部分接口，使用HTTPS前开启相关组件即可。

- openssl

openssl是一个强大的安全套接字密码库，囊括主要的密码算法、常用的密钥和证书封装管理功能及SSL协议，并提供丰富的应用程序供测试或其他目的使用。本SDK的openssl实际上是openssl的一套外壳，实际调用是mbedtls源码。
这样的好处是，早期使用openssl接口的应用无需改动，就能将openssl接口转换为实际调用mbedtls源码。

- mbedtls

ARM mbedtls使开发人员可以非常轻松地在嵌入式产品中加入加密和 SSL/TLS 功能。它提供了具有直观的API和可读源代码的SSL库。该工具即开即用，可以在大部分系统上直接构建它，也可以手动选择和配置各项功能。

[^注]: SDK如果使用HTTP_Client时，只需要HTTP服务，则无需开启openssl和mbedtls组件来支持HTTPS，避免增加内存负担。

### **1.1 源码和编译**

HTTP_Client源码:

```
src/components/net/HTTPClient
HTTPClient.c
HTTPClient.h
HTTPClientAuth.c
HTTPClientAuth.h
HTTPClientCommon.h
HTTPClientString.c
HTTPClientString.h
HTTPClientWrapper.c
HTTPClientWrapper.h
```

HTTPClient编译：

```
make menuconfig
路径：(top menu) → Components Config → NetWork，开启LWIP 1.4.1，HTTP Client，需要支持HTTPS功能，还需要开启mbedTLS和OpenSSL
make build -j32
```

### **1.2 HTTP_Client测试脚本**

开启HTTP_Client相关组件后，SDK提供测试脚本，开发时可参考该脚本。

编译时开启脚本：

```
app/wlan_demo/gcc$ make distclean
app/wlan_demo/gcc$ make menuconfig
路径：(top menu) → Components Config → Command shell → Enable HTTP Client shell cmd
app/wlan_demo/gcc$ make build -j32
```

重启开发板并连接上网络（如wifi），再输入以下命令：

```
测试http功能
http http://www.xioa.com
测试https功能
http https://www.baidu.com

请注意http和https作为网址前缀，是必须包含的。
```

### **1.3 项目开发建议**

嵌入式网络开发，建议先在PC调试网络连通性等，排除服务器端的相关问题。用户可用网络监视工具，如Postman，可调试简单的css、html、脚本等简单的网页基本信息，还能发送几乎所有类型的HTTP请求!

## **2 HTTP相关知识**

### **2.1 HTTP协议介绍**

HTTP（超文本传输协议），用于传输超媒体文档（例如 HTML）的应用层协议。该协议虽然通常基于 TCP/IP 层，但可以在任何可靠的传输层上使用；
规定了浏览器与服务器之间消息传输的数据格式。

HTTP特性：

- 基于请求响应。HTTP 遵循经典的客户端-服务端模型，客户端打开一个连接以发出请求，然后等待它收到服务器端响应。
- 基于TCP/IP 之上的作用于应用层的协议。
- 无状态（服务端无法保存用户的状态，一个人来一千次，都是和第一次一样)。这意味着服务器不会在两个请求之间保留任何数据（状态）。
- 无连接（请求来一次响应一次，之后立马断开连接，两者之间就再无任何关系。websocket相当于http协议的一个大补丁，可以长连接。

### **2.2 HTTP方法**

HTTP方法：

HTTP1.0定义了三种请求方法：GET,POST和HEAD方法。HTTP1.1新增了五种请求方法：OPTIONS,PUT,DELETE,TRACE,CONNECT方法。

HTTP_Client支持常用GET和POST方法，GET：从指定的资源请求数据。POST： 向指定的资源提交要被处理的数据。

|                 |**GET**        | **POST **|
| ----------      | -------     | --------     |
| 缓存            | 能被缓存    | 不能缓存|
| 编码类型        | application | 多为二进制数据使用多重编码|
| 历史            | 会保留参数在历史中 | 不会保存在历史数据中|
| 对长度的限制    | 最大为2048  | 无限制 |
| 对数据类型的限制| ASCII       | 没有限制，也可以为二进制数据|
| 安全性          | 安全性较差，敏感数据，密码请勿使用后 | 安全性较高|
| 可见性          | 数据在URL中对所有人可见 | 不会限制在URL中|

### **2.3 HTTP 上传数据**

#### **2.3.1 HTTP 表单**

- **Post提交表单有两种enctype类型**

1. enctype=”application/x-www-form-urlencoded”

```http
POST http://www.example.com HTTP/1.1
Content-Type: application/x-www-form-urlencoded;charset=utf-8

username=xiaoming&password=123456789
```

消息头中的Content-Type: application/x-www-form-urlencoded
消息体中内容以key=value的形式拼接username=xiaoming&password=123456789

2. enctype=”multipart/form-data”

需要上传附件时，必须为”multipart/form-data”。这种方式一般用来上传文件，各大服务端语言对它也有着良好的支持。

提交表单时，HTTP请求协议如下：

```http
POST http://www.example.com HTTP/1.1
Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA

------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="text"

title
------WebKitFormBoundaryrGKCBY7qhFd3TrwA
Content-Disposition: form-data; name="file"; filename="chrome.png"
Content-Type: image/png

PNG ... content of chrome.png ...
------WebKitFormBoundaryrGKCBY7qhFd3TrwA--
```

请求消息头中,Content-Type: multipart/form-data; boundary=- - - -WebKitFormBoundarykALcKBgBaI9xA79y
boundary为分隔符;消息体中的每个参数都会以“- -”+boundary 隔开，最后一个分隔符末尾需要加”- -“，即”- -“+boundary+”- -“

- **Get提交表单**
  表单内容

```
<form action="user/login.do" method="get" >
    用户名:<input type="text" name="username"><br>
    密码:<input type="text" name="password"><br>
    <input type="submit" value="登录"/>
</form>
```

Get方式提交，消息体里面的URL以[http://localhost:8080/springmvc/user/login.do?username=xiaoming&password=123456789](http://localhost:8080/springmvc/user/login.do?username=xiaoming&password=123456789)这种形式请求服务器

#### **2.3.2 HTTP JSON**

请求消息头中, 提交JSON类型数据：Content-Type: application/json;
application/json用来告诉服务端消息主体是序列化后的 JSON 字符串。JSON 格式支持比键值对复杂得多的结构化数据。
各大抓包工具如 Chrome 自带的开发者工具、Firebug、Fiddler，都会以树形结构展示 JSON 数据，非常友好。

提交JSON时，Http请求协议如下：

```HTTP
POST http://www.example.com HTTP/1.1
Content-Type: application/json;charset=utf-8

{"title":"test","sub":[1,2,3]}
```

#### **2.3.3 HTTP text/xml**

XML 作为编码方式的远程调用规范。HTTP,典型的 XML-RPC 请求是这样的：

```http
POST http://www.example.com HTTP/1.1
Content-Type: text/xml

<?xml version="1.0"?>
<methodCall>
    <methodName>examples.getStateName</methodName>
    <params>
        <param>
            <value><i4>41</i4></value>
        </param>
    </params>
</methodCall>
```

### **2.4 HTTP状态码**

当浏览者访问一个网页时，浏览者的浏览器会向网页所在服务器发出请求。当浏览器接收并显示网页前，此网页所在的服务器会返回一个包含HTTP状态码的信息头（server header）用以响应浏览器的请求。
HTTP状态码的英文为HTTP Status Code。状态代码由三位数字组成，第一个数字定义了响应的类别，且有五种可能取值。

1xx：指示信息--表示请求已接收，继续处理。
2xx：成功--表示请求已被成功接收、理解、接受。
3xx：重定向--要完成请求必须进行更进一步的操作。
4xx：客户端错误--请求有语法错误或请求无法实现。
5xx：服务器端错误--服务器未能实现合法的请求。

常见状态代码、状态描述的说明如下。

200 OK：客户端请求成功。
400 Bad Request：客户端请求有语法错误，不能被服务器所理解。
401 Unauthorized：请求未经授权，这个状态代码必须和WWW-Authenticate报头域一起使用。
403 Forbidden：服务器收到请求，但是拒绝提供服务。
404 Not Found：请求资源不存在，举个例子：输入了错误的URL。
500 Internal Server Error：服务器发生不可预期的错误。
503 Server Unavailable：服务器当前不能处理客户端的请求，一段时间后可能恢复正常，举个例子：HTTP/1.1 200 OK（CRLF）。

### **2.5 HTTP同步嵌入式设备时间**

嵌入式设备如果没有NTP服务，可以通过http响应消息，获取网络时间同步本地设备。

```
HTTP/1.1 206 OK
Content-Length:  801
Content-Type:  application/octet-stream
Content-Location: http://www.onlinedown.net/hj_index.htm
Content-Range:  bytes  0-100/2350        //2350:文件总大小
Last-Modified: Mon, 16 Feb 2009 16:10:12 GMT
Accept-Ranges: bytes
ETag: "d67a4bc5190c91:512"
Date: Wed, 18 Feb 2009 07:55:26 GM
```

### **2.6 HTTP和HTTPS区别**

本SDK移植了openssl和mbedtls组件，这两个组件提供了加密算法，使得HTTP_Client增加了HTTPS通信功能，如果用户在HTTPS通信遇到相关加密问题，可以查看openssl或者是mbedtls
部分代码调式。

HTTP和HTTPS区别：

1. HTTP是超文本传输协议，信息是明文传输，HTTPS 则是具有安全性的ssl加密传输协议。
2. HTTP和HTTPS使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443。
3. HTTP的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络，比HTTP协议安全。
