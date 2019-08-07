# **DDR 颗粒验证流程说明**

发布版本:1.3

作者邮箱:cym@rock-chips.com

日期:2019.06.03

文件密级:公开资料

---

**前言**
​	对各个芯片平台 DDR 颗粒兼容性和稳定性的验证流程进行说明。文档分为 linux 3.10，linux 4.4，RV1108，RK3308 三个章节，请根据实际测试平台情况选择对应章节进行参考。

**概述**

**产品版本**

| **芯片名称** | **内核版本** |
| -------- | -------- |
| 所有芯片     | 所有内核版本   |

**读者对象**

本文档（本指南）主要适用于以下工程师：

品质测试工程师

技术支持工程师

软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**               |
| ---------- | -------- | -------- | -------------------------- |
| 2017.11.21 | V1.0     | 陈有敏   | 初版                       |
| 2018.03.22 | V1.1     | 陈有敏   | 公开资料                   |
| 2018.10.11 | V1.2     | 何智欢   | 增加 RK3308 颗粒验证流程说明 |
| 2019.06.03 | V1.3     | 陈有敏   | 修复关于 RebootTest 和 SleepTest 的描述错误 |

---

[TOC]

---

**NOTE**

1. RV1108 平台 DDR 颗粒验证流程与其它平台不同，RV1108 请详见本文档的"RV1108 DDR 颗粒验证流程说明"章节；RK3308 请详见本文档的"RK3308 DDR 颗粒验证流程说明"章节。其他平台，请根据 linux kernel 版本是 linux 3.10 还是 linux 4.4，选择对应章节进行参考。
2. 本文中所述颗粒验证过程需要的 DDR 测试资源文件随该文档提供。

---

## Linux 3.10 DDR 颗粒验证流程说明

### Linux 3.10 测试固件编译

​	配置 kernel 代码的 menuconfig，进入 System Type，选择打开 DDR Test 和 pm_tests。

```
  menuconfig
  System Type  --->
    [*]   /sys/pm_tests/ support
    [*]   DDR Test
```

​	如果 menuconfig 中没有`[] /sys/pm_tests/ support`选项，请参考《Rockchip-Developer-Guide-DDR-CN》的"DDR 如何定频"和"如何 enable/disable kernel 中的 DDR 变频功能"章节，分别编译定频固件和变频固件。

### Linux 3.10 测试环境搭建

#### 固件烧写

测试开始前，需要先明确测试过程需要的如下信息：

1. 测试固件 android 版本信息（eg: android4.4，android5.0，android6.0，android7.1 ...）
2. 测试固件操作系统位数（eg: 32bit or 64bit）
3. 测试机器 DDR 总容量（eg: 512MB or 1GB or 2GB ...）
4. 定频测试，DDR 要跑的最高频率（eg: 456MHz or 533MHz ...）
5. 变频测试，DDR 要跑的频率范围（eg: 200MHz - 456MHz or 200MHz-533MHz ...）

#### 自动搭建测试环境

​	进入 DDR 测试资源文件的"linux3.10_ddr_test_files"目录，直接双击 push_files.bat 脚本，根据脚本提示和固件类型信息进行选择输入 1 或者 2，自动完成测试环境搭建。自动搭建无异常，可以跳过下面的"手动搭建测试环境"这一章节。

#### 手动搭建测试环境

​	如果自动搭建测试环境失败，可以通过手动搭建来完成。请选择"linux3.10_ddr_test_files"目录里的测试文件进行安装。

1. 安装捕鱼达人

```
<adb_tool> adb.exe install fishingjoy1.apk
```

2. push google stressapptest
  请根据测试机器的固件 android 版本是不是 android4.4，选择对应版本的 stressapptest 进行 push。

```
<adb_tool> adb.exe root
<adb_tool> adb.exe remount
<adb_tool> adb.exe push libstlport.so /system/lib/libstlport.so
<adb_tool> adb.exe shell chmod 644 /system/lib/libstlport.so
```

* 如测试机器的固件 android 版本是 android4.4，则选择对应的 stressapptest_android4.4 进行 push

```
<adb_tool> adb.exe push stressapptest_android4.4 /data/stressapptest
<adb_tool> adb.exe shell chmod 0777 /data/stressapptest
```

* 如测试机器的固件 android 版本不是 android4.4，则选择对应的 stressapptest 进行 push

```
<adb_tool> adb.exe push stressapptest /data/stressapptest
<adb_tool> adb.exe shell chmod 0777 /data/stressapptest
```

3. push memtester
  请根据测试机器的固件为 linux 64bit 还是 linux 32bit，选择对应的 memtester 进行 push。
  Eg：

* 如测试机器的固件为 linux  32bit，则选择对应的 memtester_32bit

```
<adb_tool> adb.exe push memtester_32bit /data/memtester
<adb_tool> adb.exe shell chmod 644 /data/memtester
```

* 如测试机器的固件为 linux 64bit，则选择对应的 memtester_64bit

```
<adb_tool> adb.exe push memtester_64bit /data/memtester
<adb_tool> adb.exe shell chmod 644 /data/memtester
```

4. sync

```
<adb_tool> adb.exe shell sync
```

### Linux 3.10 确认容量是否正确

通过`<rkxxxx:/ $>  cat /proc/meminfo`查看 MemTotal 容量是否与测试机器实际容量相符。
log eg：

```
<rkxxxx:/ $> cat /proc/meminfo
MemTotal:        2038904 kB
```

512MB 约等于 533504kB

1GB 约等于 1048576kB

1.5GB 约等于 1582080kB

2GB 约等于 2097152kB

3GB 约等于 3145728kB

4GB 约等于 4194304kB

由于系统内存分配管理差异的原因，得到的容量有些偏差，属于正常。

### Linux 3.10 定频测试

1. 开启捕鱼达人 APK

2. 串口控制台上输入 su 命令

```
<rkxxxx:/ $> su
```

3. DDR 定频到拷机频率

   请根据测试机器所支持的 DDR 最高频率，进行设置。

   Eg：

   如果测试机器所支持的 DDR 最高频率为 533MHz。

```
<rkxxxx:/ #> echo set clk_ddr 533000000 > /sys/pm_tests/clk_rate
```

4. google stressapptest 拷机，拷机时间 12 小时以上

* 如果总容量是 512MB 则申请 64MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 64
```

* 如果总容量是 1GB 则申请 128MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 128
```

* 如果总容量是 2GB 则申请 256MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 256
```

* 如果总容量是 4GB 则申请 512MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 512
```

5. 确认拷机结果
  ​	拷机结束，确认机器是否正常，捕鱼达人是否正常运行，stressapptest 结果是 PASS 还是 FAIL。stressapptest 每隔 10 秒会打印一条 log，log 显示测试剩余时间。测试完成后会打印测试结果，如果测试通过打印 Status: PASS，测试失败打印 Status: FAIL。

6. memtester 拷机，拷机时间 memtester 12 小时以上

* 如果总容量是 512MB 则申请 64MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 64m
```

* 如果总容量是 1GB 则申请 128MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 128m
```

* 如果总容量是 2GB 则申请 256MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 256m
```

* 如果总容量是 4GB 则申请 512MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 512m
```

7. 确认拷机结果
  ​	拷机结束，确认机器是否正常，捕鱼达人是否正常运行，memtester 是否在正常运行。DDR 测试资源文件目录里的 memtester 程序进行过修改，测试过程如果有发现错误会自动停止测试，如果持续测试 12 小时以上后，memtester 仍在继续运行，说明测试过程没有发现错误。

* memtester 运行过程如果没有发现错误，会持续打印如下 log：

  ```
  Loop 10:
    Stuck Address       : ok
    Random Value        : ok
    Compare XOR         : ok
    Compare SUB         : ok
    Compare MUL         : ok
    Compare DIV         : ok
    Compare OR          : ok
    Compare AND         : ok
    Sequential Increment: ok
    Solid Bits          : ok
    Block Sequential    : ok
    Checkerboard        : ok
    Bit Spread          : ok
    Bit Flip            : ok
    Walking Ones        : ok
    Walking Zeroes      : ok
  ```

* memtester 运行过程如果有发现错误，会自动停止测试并退出，退出时打印如下 log：

  ```
  FAILURE: 0xffffffff != 0xffffbfff at offset 0x03b7d9e4.
  EXIT_FAIL_OTHERTEST
  ```

### Linux 3.10 变频测试

如果机器前面做过定频测试，要重启机器，否则后续的变频命令会无法进行。

1. 开启捕鱼达人 APK

2. 串口控制台上输入 su 命令

```
<rkxxxx:/ $> su
```

3. 后台执行 memtester

* 如果总容量是 512MB 则申请 64MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 64m > /data/_log.txt &
```

* 如果总容量是 1GB 则申请 128MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 128m > /data/memtester_log.txt &
```

* 如果总容量是 2GB 则申请 256MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 256m > /data/memtester_log.txt &
```

* 如果总容量是 4GB 则申请 512MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 512m > /data/memtester_log.txt &
```

4. 执行变频命令
  根据测试机器支持的 DDR 频率范围进行设置。
  Eg：
  如果测试机器支持的 DDR 频率范围为 200MHZ 到 533MHz。

```
<rkxxxx:/ #> echo 'a:200M-533M-1000000T' > proc/driver/ddr_ts
```

5. 确认拷机结果，拷机时间 12 小时以上
* 确认捕鱼达人是否正常运行，机器是否正常
* 确认变频程序运行是否正常，变频 log 是否在正常打印
* 确认 memtester 是否正常运行
  在串口输入`<rkxxxx:/ #> ps | grep memtester`，看 memtester 进程是否存在。
  Eg：

```
<rkxxxx:/ #>  ps | grep memtester
root      14309 1730  74332  68156          0 5e980bf564 R /data/memtester
```

### Linux 3.10 reboot 拷机

​	开启计算器 Calculator,输入 "83991906=",点击"RebootTest"，拷机时间 12 小时以上。

---

## Linux 4.4 DDR 颗粒验证流程说明

### Linux 4.4 测试固件编译

​	使能 DDR 变频功能，打开测试机器对应的板级 DTS 文件，找到 dfi 和 dmc 节点，配置 status = "okay"。

```
&dfi {
    status = "okay";
};

&dmc {
	status = "okay";
	........
};
```

​	关于测试固件编译这里只做简单说明，详细介绍请参考《Rockchip-Developer-Guide-DDR-CN》的"如何 enable/disable kernel 中的 DDR 变频功能"章节。

### Linux 4.4 测试环境搭建

#### 固件烧写

测试开始前，需要先明确测试过程需要的如下信息：

1. 测试固件操作系统位数（32bit or 64bit）
2. 测试机器 DDR 总容量（512MB or 1GB or 2GB ...）
3. 定频测试，DDR 要跑的最高频率（456MHz or 533MHz ...）

#### 自动搭建测试环境

1. 进入 DDR 测试资源文件的"linux4.4_ddr_test_files"目录，双击 push_files.bat 脚本文件，根据脚本提示和固件类型信息进行选择输入 1 或者 2，自动完成测试环境搭建。
  Note:运行脚本后，需要通过打印的 log 检查是否每项都有被正常执行，确认是否有报错信息。
2. 自动搭建无异常，可以跳过下面的"手动搭建测试环境"这一章节。

#### 手动搭建测试环境

如果自动搭建测试环境失败，可以通过手动搭建来完成。请选择"linux4.4_ddr_test_files"目录里的测试文件进行安装。

1. 安装捕鱼达人

```
<adb_tool> adb.exe install fishingjoy1.apk
```

2. push google stressapptest

```
<adb_tool> adb.exe root
<adb_tool> adb.exe disable-verity
<adb_tool> adb.exe reboot
/* 等机器完成重启，adb出来后，再输入 */
<adb_tool> adb.exe root
<adb_tool> adb.exe push stressapptest /data/stressapptest
<adb_tool> adb.exe shell chmod 0777 /data/stressapptest
<adb_tool> adb.exe remount
<adb_tool> adb.exe push libstlport.so /system/lib/libstlport.so
<adb_tool> adb.exe shell chmod 644 /system/lib/libstlport.so
<adb_tool> adb.exe shell sync
```

3. push memtester
  请根据测试机器固件为 linux 64bit 还是 linux 32bit，选择对应的 memtester 进行 push。
  Eg：

* 如测试固件为 linux  32bit，则选择对应的 memtester_32bit

```
<adb_tool> adb.exe push memtester_32bit /data/memtester
<adb_tool> adb.exe shell chmod 644 /data/memtester
```

* 如测试固件为 linux 64bit，则选择对应的 memtester_64bit

```
<adb_tool> adb.exe push memtester_64bit /data/memtester
<adb_tool> adb.exe shell chmod 644 /data/memtester
```

4. push ddr_freq_scan.sh 脚本

```
<adb_tool> adb.exe push ddr_freq_scan.sh /data/ddr_freq_scan.sh
<adb_tool> adb.exe shell chmod 0777 /data/ddr_freq_scan.sh
```

#### 通过 U 盘和串口搭建测试环境

​	如果测试机器的 ADB 无法连接，可以通过 U 盘将测试过程需要用到文件拷贝到测试板，然后通过串口搭建测试环境。

1. 准备工作
* 开机后，添加 wake_lock 防止机器进入二级待机`echo 1 > /sys/power/wake_lock`，或者通过设置 Setting->Dsiplay->Sleep->Never sleep 让机器保持唤醒状态
* U 盘接入电脑，将"linux4.4_ddr_test_files"目录拷贝到 U 盘

* 测试板串口控制台上输入 su 命令

```
<rk3399:/ $> su
```

* U 盘接入测试板，将"linux4.4_ddr_test_files"目录下的测试所需文件拷贝到机器/data 目录。U 盘正常是加载在/mnt/media_rw/\*\*\*目录下（\*\*\*：每块 U 盘的挂载节点名有不同，请用 tab 键补全）。
  Eg:

```
<rk3399:/ #> cp /mnt/media_rw/B4FE-5315/linux4.4_ddr_test_files/*   /data/
```

2. 自动搭建测试环境

```
<rk3399:/ #> chmod 777 /data/test_files_install.sh
<rk3399:/ #> /data/test_files_install.sh
```

​	需要通过打印的 log 检查是否每项都有被正常执行。自动搭建无异常，可以跳过下面的"手动搭建测试环境"这一部分。

3. 手动搭建测试环境
  如果自动搭建测试环境失败，可以通过手动搭建来完成。

* 将 libstlport.so 拷贝到/system 目录

```
<rk3399:/ #> mount -o rw,remount /system
<rk3399:/ #> cp /data/libstlport.so /system/lib/
<rk3399:/ #> chmod 644 /system/lib/libstlport.so
```

* 更改文件权限

```
<rk3399:/ #> chmod 777 /data/memtester /data/stressapptest /data/ddr_freq_scan.sh
```

* 安装捕鱼达人 APK

```
<rk3399:/ #> pm install /data/fishingjoy1.apk
```

* sync

```
<rk3399:/ #> sync
```

### Linux 4.4 确认颗粒容量

通过`<rkxxxx:/ #>  cat /proc/meminfo`查看 MemTotal 项所示容量是否与测试机器 DDR 总容量一致。
log eg：

```
rkxxxx:/ # cat /proc/meminfo
MemTotal:        2038904 kB
```

512MB 约等于 533504kB

1GB 约等于 1048576kB

1.5GB 约等于 1582080kB

2GB 约等于 2097152kB

3GB 约等于 3145728kB

4GB 约等于 4194304kB

由于系统内存分配管理差异的原因，得到的容量有些偏差，属于正常。

### Linux 4.4 定频拷机

1. 开启捕鱼达人 APK

2. 先输入 su 命令

```
<rkxxxx:/ $> su
```

3. 定频到拷机频率
  根据测试机器 DDR 要跑的最高频率进行设置。
  Eg：

* 如果是跑 928MHz

```
<rkxxxx:/ #> /data/ddr_freq_scan.sh 933000000
```

* 如果是跑 800MHz

```
<rkxxxx:/ #> /data/ddr_freq_scan.sh 800000000
```

* 如果是跑 600MHz

```
<rkxxxx:/ #> /data/ddr_freq_scan.sh 600000000
```

4. 通过 log 确认频率是否正确
  log eg:

```
130|rkxxxx:/ # /data/ddr_freq_scan.sh 800000000
already change to 800000000 done.
change frequency to available max frequency done.
```

5. google stressapptest 拷机，拷机时间 12 小时以上

* 如果总容量是 512MB 则申请 64MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 64
```

* 如果总容量是 1GB 则申请 128MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 128
```

* 如果总容量是 2GB 则申请 256MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 256
```

* 如果总容量是 4GB 则申请 512MB 进行 stressapptest

```
<rkxxxx:/ #> /data/stressapptest -s 43200 -i 4 -C 4 -W --stop_on_errors -M 512
```

6. 确认拷机结果
  ​	拷机结束，确认机器是否正常，捕鱼达人是否正常运行，stressapptest 结果是 PASS 还是 FAIL。stressapptest 每隔 10 秒会打印一条 log，log 显示测试剩余时间。测试完成后会打印测试结果，如果测试通过打印 Status: PASS，测试失败打印 Status: FAIL。

7. memtester 拷机，拷机时间 12 小时以上

* 如果总容量是 512MB 则申请 64MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 64m
```

* 如果总容量是 1GB 则申请 128MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 128m
```

* 如果总容量是 2GB 则申请 256MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 256m
```

* 如果总容量是 4GB 则申请 512MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 512m
```

8. 确认拷机结果
  ​	拷机结束，确认机器是否正常，捕鱼达人是否正常运行，memtester 是否正常运行。"DDR 测试资源文件"目录里的 memtester 程序进行过修改，测试过程如果有发现错误会自动停止测试，如果持续测试 12 小时后，memtester 仍在继续运行，说明测试过程没有发现错误。

* memtester 运行过程如果没有发现错误，会持续打印如下 log：

  ```
  Loop 10:
    Stuck Address       : ok
    Random Value        : ok
    Compare XOR         : ok
    Compare SUB         : ok
    Compare MUL         : ok
    Compare DIV         : ok
    Compare OR          : ok
    Compare AND         : ok
    Sequential Increment: ok
    Solid Bits          : ok
    Block Sequential    : ok
    Checkerboard        : ok
    Bit Spread          : ok
    Bit Flip            : ok
    Walking Ones        : ok
    Walking Zeroes      : ok

  ```

* memtester 运行过程如果有发现错误，会自动停止测试并退出，退出时打印如下 log：

  ```
  FAILURE: 0xffffffff != 0xffffbfff at offset 0x03b7d9e4.
  EXIT_FAIL_OTHERTEST
  ```

### Linux 4.4 变频拷机

1. 开启捕鱼达人 APK

2. 先输入 su 命令

```
<rkxxxx:/$> su
```

3. 后台执行 memtester

* 如果总容量是 512MB 则申请 64MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 64m > /data/memtester_log.txt &
```

* 如果总容量是 1GB 则申请 128MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 128m > /data/memtester_log.txt &
```

* 如果总容量是 2GB 则申请 256MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 256m > /data/memtester_log.txt &
```

* 如果总容量是 4GB 则申请 512MB 进行 memtester

```
<rkxxxx:/ #> /data/memtester 512m > /data/memtester_log.txt &
```

4. 执行测试脚本

```
<rkxxxx9:/ #> /data/ddr_freq_scan.sh
```

5. 确认拷机结果，拷机时间 12 小时以上
* 确认捕鱼达人是否正常运行，机器是否正常
* 确认 memtester 是否正常运行
  在串口输入`<rkxxxx:/ #> ps | grep memtester`，看 memtester 进程是否存在。
  Eg：

```
<rkxxxx:/ #>  ps | grep memtester
root      14309 1730  74332  68156          0 5e980bf564 R /data/memtester
```

* 确认变频脚本运行是否正常运行，变频 log 是否在正常打印
  log eg:

```

DDR freq will change to 600000000 8786
already change to 600000000 done
DDR freq will change to 800000000 8787
already change to 800000000 done
DDR freq will change to 200000000 8788
already change to 200000000 done
```

### Linux 4.4 reboot 拷机

​	==为防止做 reboot 过程机器进入休眠，影响测试，请通过设置 setting->security->set screen lock->None，让机器一开机跳过锁屏界面，直接进入主界面。同时通过设置 Setting->Dsiplay->Sleep->Never sleep 让机器保持唤醒状态。==

​	开启计算器 Calculator,输入 "83991906=",点击"RebootTest"，拷机时间 12 小时以上。

### Linux 4.4 sleep 拷机

​	拔掉连接 ADB 的 USB 线，开启计算器 Calculator,输入 "83991906=",点击"SleepTest"，拷机时间 12 小时以上。3399 LPDDR4，这项测试是必须的；其他 DDR 类型及其他平台是 optional。

---

## RV1108 DDR 颗粒验证流程说明

### RV1108 测试固件编译

​	打开 DDR Test 和 pm_tests 配置。配置 kernel 代码的 menuconfig，进入 System Type，选择打开 DDR Test 和 pm_tests。

```
  menuconfig
  System Type  --->
    [*]   /sys/pm_tests/ support
    [*]   DDR Test
```

​	如果 menuconfig 中没有`[] /sys/pm_tests/ support`选项，请参考《Rockchip-Developer-Guide-DDR-CN》的"DDR 如何定频"和"如何 enable/disable kernel 中的 DDR 变频功能"章节，分别编译定频固件和变频固件。

### RV1108 测试环境搭建

​	将"rv1108_ddr_test_files"目录下的 stressapptest 和 memtester\_32bit 考到 SD 卡根目录，把卡插到测试板上。

### RV1108 确认容量是否正确

通过`<rv1108:/ #>  cat /proc/meminfo`查看 MemTotal 项所示容量是否与测试机器 DDR 总容量相符。

log eg：

```
<rv1108:/ #> cat /proc/meminfo
MemTotal:        133376 kB
```

64MB 约等于 66688kB

128MB 约等于 133376kB

256MB 约等于 266752kB

512MB 约等于 533504kB

由于系统内存分配管理差异的原因，得到的容量有些偏差，属于正常。

### RV1108 定频测试

1. DDR 定频到拷机频率

   请根据测试机器要跑的 DDR 最高频率，进行设置。

   Eg：

   如果测试机器要跑的 DDR 最高频率为 800MHz。

```
<rv1108:/ #> echo set clk_ddr 800000000 > /sys/pm_tests/clk_rate
```

2. google stressapptest 拷机，拷机时间 12 小时以上
  如果总容量是 128MB 则申请 16MB 进行 stressapptest，一般是总容量的八分之一

```
<rv1108:/ #> /mnt/sdcard/stressapptest -s 500 -i 1 -C 1 -W --stop_on_errors -M 16
```

3. 确认拷机结果

   ​	拷机结束，确认机器是否正常，stressapptest 结果是 PASS 还是 FAIL。stressapptest 每隔 10 秒会打印一条 log，log 显示测试剩余时间。测试完成后会打印测试结果，如果测试通过打印 Status: PASS，如果测试失败打印 Status: FAIL。

4. memtester 拷机，拷机时间 12 小时以上

   如果总容量是 128MB 则申请 16MB 进行 memtester，一般是总容量的八分之一

```
<rv1108:/ #> /mnt/sdcard/memtester_32bit 16m
```

5. 确认拷机结果

   ​	拷机结束，确认机器是否正常，memtester 是否正常运行。"DDR 测试资源文件"目录里的 memtester 程序进行过修改，测试过程如果有发现错误会自动停止测试，如果持续测试 12H+后，memtester 仍在继续运行，说明测试过程没有发现错误。

* memtester 运行过程如果没有发现错误，会持续打印如下 log：

   ```
   Loop 10:
     Stuck Address       : ok
     Random Value        : ok
     Compare XOR         : ok
     Compare SUB         : ok
     Compare MUL         : ok
     Compare DIV         : ok
     Compare OR          : ok
     Compare AND         : ok
     Sequential Increment: ok
     Solid Bits          : ok
     Block Sequential    : ok
     Checkerboard        : ok
     Bit Spread          : ok
     Bit Flip            : ok
     Walking Ones        : ok
     Walking Zeroes      : ok
   ```

* memtester 运行过程如果有发现错误，会自动停止测试并退出，退出时打印如下 log：

   ```
   FAILURE: 0xffffffff != 0xffffbfff at offset 0x03b7d9e4.
   EXIT_FAIL_OTHERTEST
   ```

### RV1108 变频测试

如果机器前面做过定频测试，要重启机器，否则后续的变频命令会无法进行。

1. 后台执行 memtester

如果总容量是 128MB 则申请 16MB 进行 memtester，一般是总容量的十六分之一

```
<rv1108:/ #> /mnt/sdcard/memtester_32bit 16m > /data/memtester_log.txt &
```

2. 执行变频命令
  变频测试频率范围为 400MHz 到测试机器要跑的 DDR 最高频率之间进行。
  Eg：
  如果测试机器 DDR 要跑的最高频率为 800MHz。

```
<rv1108:/ #> echo 'a:400M-800M-1000000T' > proc/driver/ddr_ts
```

3. 确认拷机结果，拷机时间 12 小时以上

* 确认机器是否正常
* 确认变频程序运行是否正常，变频 log 是否在正常打印
* 确认 memtester 是否正常运行
  在串口输入`<rkxxxx:/ #> ps | grep memtester`，看 memtester 进程是否存在。
  Eg：

```
<rkxxxx:/ #>  ps | grep memtester
root      14309 1730  74332  68156          0 5e980bf564 R /data/memtester
```

### RV1108 reboot 拷机

​	可用 1108 自带 reboot 功能，menu -> debug -> reboot test。

---

## RK3308 DDR 颗粒验证流程说明

### RK3308 确定容量是否正确

通过`<rk3308:/ #>  cat /proc/meminfo`查看 MemTotal 项所示容量是否与测试机器 DDR 总容量相符。

log eg：

```
<rk3308:/ #> cat /proc/meminfo
MemTotal:         246832 kB
MemFree:          201800 kB

```

64MB 约等于 66688kB

128MB 约等于 133376kB

256MB 约等于 266752kB

512MB 约等于 533504kB

由于系统内存分配管理差异的原因，得到的容量有些偏差，属于正常。

### RK3308 拷机测试

由于 3308 当前不支持变频功能，ddr 频率由 loader 初始化期间设置的频率，到后面是不会修改 ddr 频率的。DDR 颗粒测试请使用最高频率的设置，即 800MHz 的 loader。

1. memtester 拷机，拷机时间 12 小时以上

首先要确认测试文件是否存在：

```
<rk3308:/ #> ls usr/bin/memtester
usr/bin/memtester
```

* 如果有测试文件，memtester 测试命令如下：（如果总容量是 128MB 则申请 16MB 进行 memtester，一般是总容量的八分之一。）

```
<rk3308:/ #> memtester 16m > /data/memtester_log.txt &
```

* 如果没有测试文件，则请将随此文件一同发布的 memtester_32bit.32bit（或 memtester_64bit.64bit） 文件通过 adb push 到 data 分区：（memtester_32bit.32bit 适用于 32 位系统，memtester_64bit.64bit 适用于 64 位系统）

32 位系统命令：

```
adb push \*文件路径*\memtester_32bit.32bit data/memtester
```

64 位系统命令：

```
adb push \*文件路径*\memtester_64bit.64bit data/memtester
```

将 memtester_32bit.32bit 文件修改权限为可执行：

```
<rk3308:/ #> chmod 777 /data/memtester
```

memtester 测试命令如下：（如果总容量是 128MB 则申请 16MB 进行 memtester，一般是总容量的八分之一。）

```
<rk3308:/ #> /data/memtester 16m > /data/memtester_log.txt &
```

​    2.确认拷机结果

* 拷机结束，确认机器是否正常。
* 确认 memtester 打印是否正常：（注意，memtester 出错==**不会**==停止测试，需要查看所有打印是否正确）

正确打印

```
Loop 1:
  Stuck Address       : ok
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok
  Block Sequential    : ok
  Checkerboard        : ok
  Bit Spread          : ok
  Bit Flip            : ok
  Walking Ones        : ok
  Walking Zeroes      : ok
  8-bit Writes        : ok
  16-bit Writes       : ok

```

出错打印

```
Loop 92:
  Stuck Address       : ok
  Random Value        : FAILURE: 0x37fe0f4190f6b999 != 0x37fe0f4196f6b999 at offset 0x0027a958.
FAILURE: 0x2823d0d6f62a4b01 != 0x2823d0d6f02a4b01 at offset 0x0027a958.
  Compare XOR         : FAILURE: 0x4c4f418e764340e8 != 0x4c4f418e704340e8 at offset 0x0027a958.
  Compare SUB         : FAILURE: 0x2856fb8ee22bd230 != 0xfe5ee503ee2bd230 at offset 0x0027a958.
  Compare MUL         : FAILURE: 0x00000000 != 0x00000001 at offset 0x0027a958.
  Compare DIV         : FAILURE: 0xefb2eceaffbf9604 != 0xefb2eceaffbf9605 at offset 0x0027a958.
  Compare OR          : FAILURE: 0xcbb2a0e8cfbb8200 != 0xcbb2a0e8cfbb8201 at offset 0x0027a958.
  Compare AND         :   Sequential Increment: ok
  Solid Bits          : ok
  Block Sequential    : ok
  Checkerboard        : ok
  Bit Spread          : ok
  Bit Flip            : ok
  Walking Ones        : ok
  Walking Zeroes      : ok
  8-bit Writes        : ok
  16-bit Writes       : ok

```

​    3.google stressapptest 拷机，拷机时间 12 小时以上

首先要确认测试文件是否存在：

```
<rk3308:/ #> ls usr/bin/stressapptest
usr/bin/stressapptest
```

* 如果有测试文件，stressapptest 测试命令如下：（如果总容量是 128MB 则申请 16MB 进行 stressapptest，一般是总容量的八分之一。时间设置由-s 后面的参数控制，单位是秒。如下为拷机 24 小时的命令）

```
<rk3308:/ #> stressapptest -s 86400 -i 4 -C 4 -W --stop_on_errors -M 16
```

* 如果没有测试文件，则请将随此文件一同发布的 stressapptest_32bit（或 stressapptest_64bit） 文件通过 adb push 到 data 分区：（stressapptest_32bit 适用于 32 位系统，stressapptest_64bit 适用于 64 位系统）

32 位系统命令：

```
adb push \*文件路径*\stressapptest_32bit data/stressapptest
```

64 位系统命令：

```
adb push \*文件路径*\stressapptest_64bit data/stressapptest
```

将 stressapptest_32bit 文件修改权限为可执行：

```
<rk3308:/ #> chmod 777 /data/stressapptest
```

stressapptest 测试命令如下：（如果总容量是 128MB 则申请 16MB 进行 stressapptest，一般是总容量的八分之一。时间设置由-s 后面的参数控制，单位是秒。如下为拷机 24 小时的命令）

```
<rk3308:/ #> /data/stressapptest -s 86400 -i 4 -C 4 -W --stop_on_errors -M 16
```

​    4.确认拷机结果

* 拷机结束，确认机器是否正常。
* stressapptest 结果是 PASS 还是 FAIL。stressapptest 每隔 10 秒会打印一条 log，log 显示测试剩余时间。测试完成后会打印测试结果，如果测试通过打印 Status: PASS，如果测试失败打印 Status: FAIL。

### RK3308 休眠唤醒测试

休眠唤醒需要 kernel 使能自动唤醒功能。打开 rk3308.dtsi 文件，找到休眠唤醒节点 rockchip_suspend,位或上 RKPM_TIMEOUT_WAKEUP_EN，使能自动唤醒：

```
rockchip_suspend: rockchip-suspend {
				...
                rockchip,wakeup-config = <
                        (0
                        | RKPM_GPIO0_WAKEUP_EN
                        | RKPM_TIMEOUT_WAKEUP_EN
                        )
                >;
        };

```

编译好固件后，建议使用 3308 测试脚本的休眠唤醒测试。首先要确认测试文件是否存在：

```
<rk3308:/ #> ls rockchip_test/rockchip_test.sh
rockchip_test/rockchip_test.sh
```

* 若有测试文件，则休眠自动唤醒测试命令如下：

```
<rk3308:/ #> /rockchip_test/rockchip_test.sh
...
please input your test moudle: //串口先输入8<enter>，再输入1<enter>
8
1

```

* 若没有测试文件，可以在串口命令行直接输入命令进行休眠唤醒测试，命令如下：

```
<rk3308:/ #> while true; do echo mem >  /sys/power/state; sleep 5; done
```

拷机时间 12h+，确认机器是否正常。

### RK3308 reboot 拷机

建议使用 3308 测试脚本的 reboot 测试命令。首先要确认测试文件是否存在：

```
<rk3308:/ #> ls rockchip_test/rockchip_test.sh
rockchip_test/rockchip_test.sh
```

* 若有测试文件，reboot 测试命令如下：

```
<rk3308:/ #> /rockchip_test/rockchip_test.sh
...
please input your test moudle: //串口输入13<enter>
13
```

* 若无测试文件，则请将随此文件一同发布的 auto_reboot_test.sh 文件通过 adb push 到 data 分区：

```
adb push \*文件路径*\auto_reboot_test.sh data/.
```

将 auto_reboot_test.sh 文件修改权限为可执行：

```
<rk3308:/ #> chmod 777 /data/auto_reboot_test.sh
```

reboot 测试命令如下：

```
<rk3308:/ #> /data/auto_reboot_test.sh
```

拷机时间 12h+，确认机器是否正常。
