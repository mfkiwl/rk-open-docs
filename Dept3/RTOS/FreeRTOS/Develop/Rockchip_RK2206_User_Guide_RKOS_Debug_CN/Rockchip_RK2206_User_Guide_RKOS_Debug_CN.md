# **RK2206 RKOS Debug User Guide**

文件标识：RK-YH-YF-315

发布版本：1.0.0

日期：2019.12

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

## **前言**

**概述**

本文档主要介绍RK2206 RKOS 相关开发方法。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师

软件开发工程师

**修订记录**

| **日期**  | **版本** | **作者**            | **修改说明**|
| --------- | -------- | ------------------- | ---------------------------------- |
| 2019.12.13 | V1.0.0   | Aaron Sun           | 初始版本 |

---

## **目录**

[TOC]

---

## 系统死机分析

系统死机最常见的原因是访问非法内存，会触发硬FAULT中断，硬FAULT中会打印死机现场，结合响应的工具，可以还原死机的堆栈，详细请参考《Rockchip_RK2206_User_Manual_Panic_Info_CN.pdf》或者本文第4节，中断现场打印完之后，会打印RKOS相关信息，LOG如下：

```
 stackremain    totalmemory     cpu    state   name
-----------------------------------------------------
892     0       969     Re      idle
880     0       0       S       osTimer
944     22688   5       S       taskm
284     11704   44      S       dm
912     1732    55      B       gui/0
332     0       0       S       bcore/0
3612    8272    0       S       Main/0
1380    0       0       Ru      shell/0 (当前运行的线程)
5752    36336   1       B       story
5824    1024    1       S       preprocess_task
1444    19608   143     S       decode_task
388     8280    5       S       play_task
648     0       0       B       bbt_addr
636     23276   26      S       wifi/0
880     0       0       S       sdio_irq/0
404     4728    236     B       wificonnect
2500    5532    13      Re      rk912_rx_thr
1836    0       0       B       lwip/0
3096    0       0       B       rk912_tx_thr
3912    0       0       B       ota_task
3668    28836   65      S       asr_task
3892    0       0       B       EchoRcv_task
3880    0       11      B       ytv_asr_thread
680     3160    1       S       asr_record_task


512                     03029fb0                rk912_rx_thr
116                     0302806c                rk912_rx_thr
2048                    03029790                rk912_rx_thr
120                     03025e28                rk912_rx_thr
552                     03028100                rk912_rx_thr
92                      03025574                wificonnect
120                     030254dc                wificonnect
864                     03025aa8                wificonnect
64                      0302547c                wificonnect
1024                    03019ee0                taskm
80                      03019e70                dm
300                     03019d24                dm
108                     03019c98                dm
2048                    03019478                taskm
604                     030191fc                taskm
184                     03009490                taskm
2048                    03008c70                deleted
164                     03008bac                deleted
    total used memory block cnt = 150totalsize = 179860  Remaining = 97932
```

如上：当前运行的线程是SHELL，后面是内存监控显示内存正常。

如果冲内存，内存监控会触发异常死机，输出现场，分析同上。

如果栈不够，FreeRTOS会上报异常到RKOS, RKOS触发异常死机，输出现场，分析同上。

## 线程死锁分析

线程死锁卡死，通过LOG不好分析，可以通过命令task.list 先查看所有的线程状态：

```
rkos://task.list
    this cmd will list all task info!!
 state-----task state
 TCBAddr-----task control block address
 IdlTck-----when system enter 2 level, idletick start conuter, unit ms
 Idle1-----task 1 level suspend threshold, unit ms
 idle2-----task 2 level suspend threshold, unit ms
 Event-----if task freertos state is suspend, this value is the address of queue or semaphore this task be suspend
 cpu-----from power on or previous execute cmd "task.list", this task run time, unit 10ms
 StackSize-----this task use stack totalsize
 RemainStack-----this task unuse stack size
 MemorySize-----this task malloc memory total size with rkos_memory_malloc api
 Priority-----this task priority 0 - 31 ,the value is more large, the priority is more high
 ClassID-----task class id, if use RKTaskCreate2 Api create, the value is -1
 ObjectID-----task object id, if use RKTaskCreate2 Api create, the value is -1
 name-----task name, the max size is 16
     State       TCBAddr  IdlTck Idle1  Idle2  Event    cpu StackSize RemainStack MemorySize Priority ClassID ObjectID Name
---------------------------------------------------------------------------------------------------------------------------
Ready  [Wroking] 03003dd4 000000 000000 000000 unknow   34376 00000512   00000892    000000    000000     19     00     idle
Blocked[Wroking] 03003e80 000000 000000 000000 unknow   0001 00002048   00000936    000000    000025     18     00     osTimer
Suspend[Wroking] 03003d1c 000000 000000 000000 03003b98 0004 00002048   00000944    022688    000024     20     00     taskm
Suspend[Wroking] 03003fb0 000000 001000 000000 03003ed8 0047 00002304   00000284    011704    000023     21     00     dm
Blocked[Wroking] 03004ddc 000000 001000 000000 unknow   0124 00002560   00000872    001552    000002     11     00     gui/0
Suspend[Wroking] 03005374 000000 001000 000000 0300529c 0000 00000512   00000324    000000    000027     13     00     bcore/0
Suspend[Wroking] 03005644 000000 001000 000000 03005438 0000 00004096   00003612    008272    000002     04     00     Main/0
Runing [Wroking] 0300569c 000000 001000 000000 unknow   0000 00004096   00001380    000000    000029     16     00     shell/0
Blocked[Wroking] 030056f4 000000 001000 000000 unknow   0001 00008192   00005752    056464    000002     -1     -1     story
Suspend[Wroking] 030060a4 000000 001000 000000 030059b0 0268 00008192   00005824    000000    000028     -1     -1     preprocess_task
Suspend[Wroking] 0300611c 000000 001000 000000 03005b30 8001 00002048   00001444    000000    000028     -1     -1     decode_task
Suspend[Wroking] 0300618c 000000 001000 000000 03005cb0 0527 00001024   00000384    000000    000028     -1     -1     play_task
Suspend[Wroking] 0300653c 000000 001000 000000 030063cc 0025 00002048   00000636    023276    000010     09     00     wifi/0
Suspend[Wroking] 03006794 000000 000000 000000 0300671c 0000 00001024   00000880    000000    000012     17     00     sdio_irq/0
Blocked[Wroking] 030067ec 000000 001000 000000 unknow   0236 00002048   00000404    003704    000010     -1     -1     wificonnect
Suspend[Wroking] 03006904 000000 001000 000000 030068a4 0607 00004096   00002500    004752    000016     -1     -1     rk912_rx_thr
Blocked[Wroking] 03006b64 000000 012000 000000 unknow   0167 00002048   00001460    006084    000017     05     00     lwip/0
Blocked[Wroking] 03006bbc 000000 001000 000000 unknow   0000 00004096   00003088    000000    000017     -1     -1     rk912_tx_thr
Blocked[Wroking] 03006c14 000000 001000 000000 unknow   0000 00004096   00003880    000000    000003     -1     -1     ota_task
Blocked[Wroking] 03006f90 000000 001000 000000 unknow   4494 00004096   00003668    000000    000027     -1     -1     asr_task
Blocked[Wroking] 03007158 000000 001000 000000 unknow   0039 00004096   00002700    008520    000001     -1     -1     EchoRcv_task
Blocked[Wroking] 03007b20 000000 001000 000000 unknow   0000 00004096   00003356    000000    000002     -1     -1     mqtt
Suspend[Wroking] 0300756c 000000 001000 000000 03007458 0001 00008192   00007100    007512    000002     -1     -1     echo-ai
Suspend[Wroking] 030073b0 000000 001000 000000 03004ee8 0001 00008192   00006700    016184    000002     -1     -1     rec
Blocked[Wroking] 03007500 000000 001000 000000 unknow   0000 00004096   00003628    000000    000002     -1     -1     rech
total task cnt = 25, total suspend cnt = 0
```

首先看第一列， Suspend/Blocked是FreeRTOS的线程状态，[Working]是RKOS的线程状态。

具体意义，请参考Rockchip_RK2206_Developer_Guide_RKOS_Task_Manager_CN.pdf。

第二个列是线程控制块的指针，可以使用task.stack 03007b20命令读出MQTT栈信息。

```
rkos://task.stack 03007b20
 stack = 03030eb8The exception call: 03030eb8
PC call-2: 0307c72c: f7e5 f880 6828 6863 1ac3 6820
PC call-3: 03054530: f3bf 8f6f 4770 bf00 ed04 e000
PC call-4: 0307c120: f000 fafa 2800 d0f7 7f2c b9b4
PC call-5: 0307c2f2: f7ff ff0d 2800 d033 481c e002
PC call-6: 0307c72c: f7e5 f880 6828 6863 1ac3 6820
PC call-7: 03054530: f3bf 8f6f 4770 bf00 ed04 e000
PC call-8: 0307c39a: f000 f9bd 2800 d0f4 2000 b003
```

然后参考《Rockchip_RK2206_User_Manual_Panic_Info_CN.pdf》 或者本文第4节的方法可以打印。

## 看门狗复位分析

RKOS在IDLE线程进行喂狗，引起看门狗复位原因是看门狗长时间获取不到时间片，具体情况如下：

1，某个线程长时间占用时间片，下图LOG中线程Ru线程为异常线程。

2，中断异常一直产生

```
 stackremain    totalmemory     cpu    state   name
-----------------------------------------------------
892     0       0      Re      idle
880     0       0       S       osTimer
944     22688   0       S       taskm
284     11704   0      S       dm
912     1732    0      B       gui/0
332     0       0       S       bcore/0
3612    8272    0       S       Main/0
1380    0       0       Ru      shell/0
5752    36336   0       B       story
5824    1024    0       S       preprocess_task
1444    19608   0     S       decode_task
388     8280    0       S       play_task
648     0       0       B       bbt_addr
636     23276   0     S       wifi/0
880     0       0       S       sdio_irq/0
404     4728    0     B       wificonnect
2500    5532    0     Re      rk912_rx_thr
1836    0       0       B       lwip/0
3096    0       0       B       rk912_tx_thr
3912    0       0       B       ota_task
3668    28836   0      S       asr_task
3892    0       0       B       EchoRcv_task
3880    0       0      B       ytv_asr_thread
680     3160    0       S       asr_record_task


512                     03029fb0                rk912_rx_thr
116                     0302806c                rk912_rx_thr
2048                    03029790                rk912_rx_thr
120                     03025e28                rk912_rx_thr
552                     03028100                rk912_rx_thr
92                      03025574                wificonnect
120                     030254dc                wificonnect
864                     03025aa8                wificonnect
1024                    0302b290                asr_task
80                      03025408                asr_task
2048                    030285b0                asr_task
4096                    0302a270                asr_task
80                      03025398                asr_task
20480                   030338f0                asr_task
4096                    03026f2c                story
80                      030257b8                story
4096                    03025f0c                story
0164                     03008bac                deleted
    total used memory block cnt = 150totalsize = 179860  Remaining = 97932
```

## make dump命令

在app/test_demo/gcc,  app/story_robot/gcc,  app/wlan_demo/gcc目录下执行make dump, 复制堆栈信息回车，然后CRTL+D可以快速定位出问题的函数, 如果要dump其他固件的信息，需要将同名elf文件复制到该目录下.

```
sch@SYS3:~/rkos_repo/app/story_robot/gcc$ make dump
Input dump log: (Enter CTRL-D To Analytic Log)
The exception call: 382157c8
PC call-0: 1811af6a: e7fe f04f 30ff bd10 0000 b570
PC call-1: 1811af66: f012 fda3 e7fe f04f 30ff bd10
PC call-2: 18111fcc: 4798 4604 e7db 0000 e92d 4ff0
PC call-3: 18112070: 4798 f8d5 3a18 3301 f8c5 3a18
PC call-4: 1811065a: 0a0d 0a0d 0d00 200a 6574 706d
PC call-5: 1811249a: f7ff fd9b b110 4620 f7ff fb8b
PC call-6: 1008157e: 4618 f7ff fec4 2800 d0ab 235b
The normal call: 20008800
PC call_normal-1: 000891f2: f7ff ffd7 4a0e 6813 b95b f240
PC call_normal-2: 0008922a: f380 8814 bd08 d290 2000 92d2
PC call_normal-3: 00089e8e: f7ff f9af 4620 e8bd 83f8 6823
PC call_normal-4: 00089400: f000 fd28 2c01 4603 d005 f3ef
PC call_normal-5: 1811cd82: f7e4 fef3 682b 6839 6822 3301
PC call_normal-6: 1811cd1e: 000a e92d 43f8 f8df 8084 4c1c
PC call_normal-7: 1811ce1a: 4798 4b07 6818 b118 e8bd 4008
PC call_normal-8: 00088c4a: f003 fe45 e7f5 f000 fab2 f8d4
PC call_normal-9: 00089300: 7974 4600 6572 5265 4f54 3c53
PC call_normal-10: 000892d0: 0072 5076 726f 4574 6978 4374
PC call_normal-11: 00088ef8: 5253 0a00 610a 7373 7265 2074
PC call_normal-12: 000892e2: 006c 5076 726f 5674 6c61 6469
PC call_normal-13: 00088ef8: 5253 0a00 610a 7373 7265 2074
******** begin to checking the following file! ****
/home/sch/rkos_repo/app/story_robot/gcc/../../../image/debug/dump.log
./rkos_as_file_elf.as
**** The exception call: ****
PC call-3: 18112070: 4798 f8d5 3a18 3301 f8c5 3a18
  18111fd4 <ShellRootParsing>:
  18112070:     4798            blx     r3
PC call-5: 1811249a: f7ff fd9b b110 4620 f7ff fb8b
  181123cc <ShellTask>:
  1811249a:     f7ff fd9b       bl      18111fd4 <ShellRootParsing>
**** The normal call: ****
PC call_normal-5: 1811cd82: f7e4 fef3 682b 6839 6822 3301
  1811cd20 <CpuIdle>:
  1811cd82:     f7e4 fef3       bl      18101b6c <rkos_scheduler_resume>
PC call_normal-7: 1811ce1a: 4798 4b07 6818 b118 e8bd 4008
  1811cdf8 <vApplicationIdleHook>:
  1811ce1a:     4798            blx     r3
```

