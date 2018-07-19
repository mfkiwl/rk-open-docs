# DS5快速连接指南

发布版本：1.0

作者邮箱：hhb@rock-chips.com

日期：2018.05

文件密级：公开资料

---

**概述**

本文档主要是简单介绍如何创建一个芯片对应的连接，帮助读者快速使用DS5软件连接设备。

**读者对象**

本文档（本指南）主要适用于以下工程师：
技术支持工程师
软件开发工程师

**修订记录**

| **日期**     | **版本** | **作者** | **修改说明** |
| ---------- | ------ | ------ | -------- |
| 2017-12-21 | V1.0   | 洪慧斌    | 初始发布     |
|            |        |        |          |
|            |        |        |          |



-----

打开Debug Configurations



![Alt text](/Rockchip-Developer-Guide-DS5/7c79d228-d79b-40b8-958a-98022c9a30a8.png)



右击DS-5 Debugger 新建一个Debugger


![Alt text](/Rockchip-Developer-Guide-DS5/3616ddec-2501-4c8c-aad5-c61c3d287a11.png)



输入新连接名称，选择对应的SOC配置，可以在第二个红色框输入芯片型号进行搜索。Bare Metal Debug是裸系统调试，Linux Kernel Debug是linux内核调试，会更好的支持带系统调试功能。 


![Alt text](/Rockchip-Developer-Guide-DS5/229f8222-a69c-4057-9d96-5f6cab6a6a61.png)



选择连接的CPU组合，仅连接某个核，或者4个核都连接


![Alt text](/Rockchip-Developer-Guide-DS5/3337bedd-fb93-4869-831f-58472df5c7cd.png)



选择DS-5连接器


![Alt text](/Rockchip-Developer-Guide-DS5/6ffedb89-97a5-429c-86d6-f65a5c8963b1.png)

选择已经通过USB或网口连接到电脑的DS-5 调试器


![Alt text](/Rockchip-Developer-Guide-DS5/39bbc86f-ec27-4a4a-b96e-904d9349050e.png)

在Debugger菜单栏下选择Connect only，点击右下脚的Apply 保存配置，再点击Debug开始连接设备


![Alt text](/Rockchip-Developer-Guide-DS5/b34e585b-8880-490f-b135-43154a52b893.png)

连接上设备


![Alt text](/Rockchip-Developer-Guide-DS5/496ffff7-0bdd-495e-9c44-363341e0dfd9.png)




