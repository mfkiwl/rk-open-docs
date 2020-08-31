# Rockchip QFacialGate Instruction

文件标识：RK-SM-YF-374

发布版本：V1.1.0

日期：2020-08-31

文件密级：□绝密   □秘密   □内部资料   ■公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有© 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

---

**前言**

**概述**

 本文主要描述了QFicialGate应用各个模块的使用说明。QFicialGate应用基于librkfacial.so，具体接口参考《Rockchip_Instruction_Rkfacial_CN.pdf》，源代码和文档路径位于SDK/external/rkfacial。

**产品版本**

| **平台名称** | **内核版本** |
| ------------ | ------------ |
| Linux        | 4.4          |

**读者对象**

本文档（本指南）主要适用于以下工程师：

​        技术支持工程师

​        软件开发工程师

 **修订记录**

| **日期**   | **版本** | **作者** | **修改说明**       |
| ---------- | -------- | :------- | ------------------ |
| 2020-07-24 | V1.0.0   | ctf      | 初始版本           |
| 2020-08-31 | V1.1.0   | ctf      | 添加Qt配置编译说明 |

---

**目录**

[TOC]

---

## 整体介绍

### 应用说明

QFicialGate通过librkfacial.so利用RK自有算法rockface实现了人脸检测，人脸特征点提取，人脸识别，活体检测流程。

具体包含以下功能：

- 获取RGB摄像头图像数据做人脸识别，获取IR摄像头图像数据做活体检测。

- 使用SQLITE3作为数据库来存储人脸特征值和用户名。

- 利用Qt实现用户注册，删除注册数据，人脸框跟踪及用户名显示等操作。

- 利用ALSA接口实现各流程语音播报功能。

注意： rockface的使用需要RK授权，请参考sdk/external/rockface/auth/README文档来申请授权；librkfacial.so 使用请参考：external/rkfacial/doc/Rockchip_Instruction_Rkfacial_CN.pdf 。

### 使用方法

QFacialGate -f num

-f：表示人脸底库最大支持的数量，没有配置的情况下默认人脸底库最大支持1000张

---

## Qt配置

### 配置

- 根目录下运行`make menuconfig` 开启如下配置

  ```cpp
  BR2_PACKAGE_QT5=y
  BR2_PACKAGE_QT5_VERSION_5_9=y
  BR2_PACKAGE_QT5BASE_EXAMPLES=n        //Qt examples
  BR2_PACKAGE_QT5BASE_WIDGETS=y
  BR2_PACKAGE_QT5BASE_GIF=y
  BR2_PACKAGE_QT5BASE_JPEG=y
  BR2_PACKAGE_QT5BASE_PNG=y
  BR2_PACKAGE_QT5MULTIMEDIA=y
  BR2_PACKAGE_QT5QUICKCONTROLS=y
  BR2_PACKAGE_QT5QUICKCONTROLS2=y
  BR2_PACKAGE_QT5BASE_LINUXFB_ARGB32=y
  BR2_PACKAGE_QT5BASE_USE_RGA=y         //RGA优化, 详见章节3.4.2, 运行Qt examples时关闭该配置

  # Fonts                               //字库配置
  BR2_PACKAGE_BITSTREAM_VERA=y
  BR2_PACKAGE_CANTARELL=y
  BR2_PACKAGE_DEJAVU=y
  BR2_PACKAGE_FONT_AWESOME=y
  BR2_PACKAGE_GHOSTSCRIPT_FONTS=y
  BR2_PACKAGE_INCONSOLATA=y
  BR2_PACKAGE_LIBERATION=y
  BR2_PACKAGE_QT5BASE_FONTCONFIG=y
  BR2_PACKAGE_SOURCE_HAN_SANS_CN=y
  ```

  如果想要运行Qt 自带示例程序，可以开启`BR2_PACKAGE_QT5BASE_EXAMPLES`，编译后会在`usr/lib/qt/examples` 目录下生成相应示例程序。

- 配置完成，需要运行`make savedefconfig` 将配置保存到`buildroot/configs` 目录下对应的xxx_defconfig文件。

### 编译

- 通过`make menuconfig`和 `make savedefconfig` 方式配置，可以直接使用 `make qt5base-dirclean && make qt5base-rebuild` 进行编译。
- 直接在`buildroot/configs/xxx_defconfig`中添加配置选项的，必须使用 `./build.sh rootfs` 编译，配置才会生效。

### 运行

- 以QFacialGate 运行为例

  ```cpp
  //配置使用drm还是fb的api操作显示, fb效率低且未优化, 均配置为1
  export QT_QPA_FB_DRM=1
  //显示终端配置: linuxfb显示, 不做旋转; 通过rotation设置屏幕旋转角度, 可配置为: 0、90、180、270
  export QT_QPA_PLATFORM=linuxfb:rotation=0
  //设置人脸底库最大支持30000张
  QFacialGate -f 30000 &
  ```

## UI 介绍

### UI 控件

- Register按键：实时注册摄像头采集到人脸特征值到数据库。
- Delete按键：实时从数据库删除摄像头采集到人脸特征值。
- RGB/IR按键：RGB/IR摄像头显示切换按键；当按键显示RGB时，屏幕显示RGB图像和人脸检测结果；当按键切换到IR时，屏幕仅显示IR图像，不显示人脸检测结果。
- Capture按键：保存屏幕当前显示的30帧图像数据，保存的文件以当前时间命名，RGB图像保存在/data/rgb/目录下，IR图像保存在/data/ir/目录下。
- Setting 图标按键：设置IP地址，点击会弹出IP地址设置窗，输入IP地址、子网掩码、网关地址。
- 人脸框：红色表示非活体；蓝色表示未注册到数据库的活体；绿色表示活体，并且是已注册到数据库的白名单；黑色表示活体，并且是已注册到数据库的黑名单。
- 底部信息显示区：显示时间，检测到的用户信息，如果设备连接以太网，还会显示IP地址，在PC端浏览器输入该IP地址，可以登录web端管理工具， web管理工具具体操作请参考：docs/Linux/ApplicationNote/Rockchip_Instructions_Linux_Web_Configuration_CN.pdf 。

### Camera图像显示

- RV1109 平台QFacialGate 只负责UI控件的显示，Camera图像数据直接在librkfacial.so中通过DRM接口送显，具体流程请参考代码中的TWO_PLANE 宏控制的流程。
- RK1808/1806 平台VOP只有单层，所以Camera图像数据在QFacialGate 中通过RGA和UI控件合成后送显，具体流程请参考代码中的ONE_PLANE宏控制的流程。

### 代码模块说明

#### class desktopview

- QFacialGate  入口类，实现UI布局管理，librkfacial.so 初始化。

- `initRkfacial`

  librkfacial.so 初始化函数，调用set_isp_param 和 set_cif_param设置相应摄像头参数，及Camera图像数据回调；调用register_rkfacial_paint_box 注册人脸框坐标回调；调用register_rkfacial_paint_info 注册用户信息回调。

#### class videoitem

- 实现人脸框、检测到的用户信息、时间、IP地址的显示，对于RK1808/1806 平台还包含Camera 图像数据的显示。

- `rgaDrawImage`

  RGA合成函数，具体见本文第2.4.1章节，RGA使用请参考：external/linux-rga/Linux rga说明文档.pdf。

- `drawBox`

  绘制人脸框

- `drawSnapshot`

  当检测到已注册到数据库的活体时，使用RGA合成数据库中活体的照片。

- `drawInfoBox`

  绘制底部信息显示区，包含时间、IP地址显示；当检测到已注册到数据库的活体时，还会显示用户名和数据库中活体的照片。

#### class snapshotthread

- 获取数据库中活体的照片，通过调用turbojpeg_decode_get 获取照片信息，turbojpeg_decode_put 释放资源。

#### class savethread

- 保存屏幕当前显示的图像数据，点击Capture按键开始保存，保存30帧后自动停止。

#### class qtkeyboard

- 自定义键盘。支持0 ~ 9 ，26个字母大小写，删除、空格、斜杠等常见符号按键，键盘布局位于qtkeyboard.ui

### 性能优化

#### QFacialGate 优化

- 使用RGA 合成，代替直接使用Qt 的drawRect、drawImage，具体包含：
  1. 合成底部信息显示区的半透阴影框。
  2. 当检测到已注册到数据库的活体时，还用于合成数据库中的活体照片。
  3. 对于RK1808/1806 平台还包含Camera 图像数据合成。
- 对比测试显示：RGA合成降低了CPU占用，并且帧率提升明显。如果UI有类似的大面积阴影或图像数据显示时，请参考videoItem.cpp中的rgaDrawImage api使用RGA合成。

#### Qt 优化

- 使用RGA 合成优化drawImage，提升帧率，降低CPU，由BR2_PACKAGE_QT5BASE_USE_RGA 宏控制。该宏必须开启，否则帧率下降严重，画面会有明显卡顿。

- UI 数据直接绘制到Linuxfb buffer，跳过涂黑和两次neon合成，进一步降低CPU，由BR2_PACKAGE_QT5BASE_LINUXFB_DIRECT_PAINTING 宏控制，该优化只在单窗口有效。如果UI使用多窗口显示，请关闭该宏，CPU占用会略微升高，可能导致帧率小幅度下降。

- 以上宏开关均可在根目录下运行`make menuconfig` 配置，修改后需要`make savedefconfig` 保存配置，并运行`make qt5base-dirclean && make qt5base-rebuild`重新编译Qt，运行`make QFacialGate-dirclean && QFacialGate-rebuild`重新编译QFacialGate，使配置生效。
