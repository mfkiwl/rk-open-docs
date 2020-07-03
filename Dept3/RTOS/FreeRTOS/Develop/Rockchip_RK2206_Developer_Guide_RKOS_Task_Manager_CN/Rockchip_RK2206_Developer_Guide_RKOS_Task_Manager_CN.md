# RK2206 RKOS Task Manager Developer Guide

文件标识：RK-KF-YF-313

发布版本：1.0.1

日期：2020.2.14

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

| **日期**  | **版本** | **作者**           | **修改说明**               |
| --------- | -------- | ------------------- | -------------------------- |
| 2019.12.13 | V1.0.0  | Aaron. Sun          | 初始版本                   |
| 2020.2.14 | V1.0.1  | Aaron. Sun          | 修订单词，语法，标点符号                   |

---

## **目录**

[TOC]

---

## RKOS简要说明

RKOS是建立在FreeRTOS V10.0.1内核之上的一套操作系统，包括任务管理、设备管理、应用管理、电源管理、固件管理、GUI管理和shell命令，本文只讲述调度相关的API。

### FreeRTOS特性介绍

FreeRTOS是一个迷你的实时操作系统内核。作为一个轻量级的操作系统，包含：任务管理、时间管理、信号量、消息队列、内存管理、记录功能、软件定时器、协程等功能，可基本满足较小系统的需要。主要特性有：

* 用户可配置内核功能

* 多平台的支持

* 提供一个高层次的信任代码的完整性

* 目标代码小，简单易用，核心代码仅有3个C文件，典型内核配置仅需6K~12KByte内存

* 没有限制的任务数量

* 没有限制的任务优先级

* 多个任务可以分配相同的优先权

* 队列，二进制信号量，计数信号灯和递归通信和同步的任务

* 优先级继承

* 免费开源的源代码

如需了解详细的FreeRTOS信息，请参考FreeRTOS V7.4.2版本的相关文档。

### RKOS与FreeRTOS

RKOS使用FreeRTOS如下功能：

* 任务的创建与删除

* Timer的创建，启动，停止，删除，获取参数

* 消息队列的创建，删除，发送，接受

* 信号量的创建，删除，获取，释放

* 互斥量的创建，获取，释放使用信号量的获取，释放API, 删除使用队列删除的API.

* 任务释放CPU资源的Delay

* 临界区的进入和退出

* 内存的申请和释放

为了满足RKOS的功能需求，对FreeRTOS做了如下修改：

* 代码风格重定义

* 队列，信号量操作如遇到任务切换时，直接切换（FreeRTOS需要上层调用API）

* 任务优先级限制到30个

* 无LOG输出时，取消任务名

* 同等优先级的任务，不做轮转调度

* Heap分2个内存池，大池（供RKOS, 任务栈，消息队列大成员），小池（FreeRTOS 任务控制块，信号量，消息队列等）

### RKOS特点

* 面向对象的思维，用C语言来实现

* SEGMENT OVLERY的内存调度技术

* Shell命令，调试更方便

* 内存监控，及时提示内存泄漏，方便开发

* 即用即醒，不用则睡的三级休眠技术

* 独特的设备驱动框架，使得驱动编写更加容易

* 独特的任务管理框架，使得任务的实现更加容易

## RKOS基础API

### 任务的创建与删除

使用本章节的AP创建的任务，不受任务管理器管理，创建者负责管理被创建任务。

#### rkos_task_create

**功能：创建任务**

原型：HTC rkos_task_create(pRkosTaskCode TaskCode,char *name, uint32 StatckBase, uint32 StackDeep, uint32 Priority, void * para)*

| **Parameter** | **Type**      | **Description**                                              |
| ------------- | ------------- | ------------------------------------------------------------ |
| TaskCode      | pRkosTaskCode | typedef void (* pRkosTaskCode)( void * )任务入口函数         |
| name          | char *        | 任务名                                                       |
| StatckBase    | uint32        | typedef  unsigned long  uint32任务栈的基地址                 |
| StackDeep     | uint32        | typedef  unsigned long  uint32任务栈的大小，单位：字         |
| Priority      | uint32        | typedef  unsigned long  uint32任务的优先级，取值0-31，数值越大优先级越大 |
| para          | void *        | 任务入口参数                                                 |
| return        | HTC           | typedef void * HTC如果任务创建成功，返回的任务句柄，失败返回NULL |

#### rkos_task_delete

**功能：删除任务**

原型：void rkos_task_delete(HTC hTask)

| **Parameter** | **Type** | **Description**                                        |
| ------------- | -------- | ------------------------------------------------------ |
| hTask         | HTC      | typedef void * HTC；任务句柄，rkos_task_create的返回值 |
| return        | void     | 无返回值                                               |

### Timer的创建，启动，停止，删除，获取参数

#### rkos_create_timer

**功能：创建Timer**

原型：pTimer rkos_create_timer(uint32 period, uint32 reload,void *param, pRkosTimerCallBack pfCall)

| **Parameter** | **Type**           | **Description**                                              |
| ------------- | ------------------ | ------------------------------------------------------------ |
| period        | uint32             | typedef  unsigned long  uint32系统tick的个数，rkos中1个tick 10ms |
| reload        | uint32             | typedef  unsigned long  uint321：重新启动定时器，0：不重新启动 |
| param         | void *             | 回调函数的参数                                               |
| pfCall        | pRkosTimerCallBack | typedef void (* pRkosTimerCallBack)(pTimer)typedef void * pTimerTimer回调函数，参数是rkos_create_timer返回值 |
| return        | pTimer             | typedef void * pTimer创建成功：Timer 句柄，创建失败返回NULL  |

#### rkos_start_timer

**功能：启动Timer**

原型：rk_err_t rkos_start_timer(pTimer timer)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| timer         | pTimer   | typedef void * pTimerTimer 句柄，rkos_create_timer返回值     |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:启动成功，RK_ERROR： 启动失败 |

#### rkos_stop_timer

**功能：停止Timer**

原型：rk_err_t rkos_stop_timer(pTimer timer)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| timer         | pTimer   | typedef void * pTimerTimer 句柄，rkos_create_timer返回值     |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:停止成功，RK_ERROR： 停止失败 |

#### rkos_get_timer_param

**功能：获取回调参数**

原型：void rkos_get_timer_param(pTimer timer)

| **Parameter** | **Type** | **Description**                                          |
| ------------- | -------- | -------------------------------------------------------- |
| timer         | pTimer   | typedef void * pTimerTimer 句柄，rkos_create_timer返回值 |
| return        | void *   | 创建Timer的时指定的参数rkos_create_timer 形参para        |

#### rkos_delete_timer

**功能：删除timer**

原型：rk_err_t rkos_delete_timer(pTimer timer)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| timer         | pTimer   | typedef void * pTimerTimer 句柄，rkos_create_timer返回值     |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:删除成功，RK_ERROR： 删除失败 |

#### rkos_mod_timer

**功能：改变Timer周期**

原型：rk_err_t rkos_mod_timer(pTimer timer, int NewPeriod, int BlockTime)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| timer         | pTimer   | typedef void * pTimerTimer 句柄，rkos_create_timer返回值     |
| NewPeriod     | int      | 系统tick的个数，rkos中1个tick 10ms                           |
| BlockTime     | int      | 调用此函数，最大允许的阻塞时间，-1为无穷大，单位tick, rkos中1个tick 10ms |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:删除成功，RK_ERROR： 删除失败 |

### 消息队列的创建、删除、发送、接收

#### rkos_queue_create

**功能：创建消息队列**

原型：pQueue rkos_queue_create(uint32 blockcnt, uint32 blocksize)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| blockcnt      | uint32   | typedef  unsigned long  uint32消息总个数                     |
| blocksize     | uint32   | typedef  unsigned long  uint32单个消息的大小                 |
| return        | pQueue   | typedef void * pQueue创建成功:返回消息队列的句柄，大池消耗内存blockcnt * blocksize 个字节。创建失败：返回NULL |

#### rkos_queue_delete

**功能：删除消息队列**

原型：rk_err_t rkos_queue_delete(pQueue pQue)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| pQue          | pQueue   | typedef void * pQueue消息队列的句柄，rkos_queue_create返回值 |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:删除成功，RK_ERROR： 删除失败 |

#### rkos_queue_send

**功能：向消息队列中发送消息**

原型：rk_err_t rkos_queue_send(pQueue pQue, void \* buf, uint32 time)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| pQue          | pQueue   | typedef void * pQueue消息队列的句柄，rkos_queue_create返回值 |
| buf           | void *   | 消息指针                                                     |
| time          | uint32   | 调用该函数，任务最大阻塞时间，单位tick,rkos中1个tick 10ms. MAX_DELAY表示永久性阻塞直到发送成功。 |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:发送成功，RK_ERROR： 发送失败 |

#### rkos_queue_receive

**功能：从消息对了中接收消息**

原型：rk_err_t rkos_queue_receive(pQueue pQue, void * buf, uint32 time)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| pQue          | pQueue   | typedef void * pQueue消息队列的句柄，rkos_queue_create返回值 |
| buf           | void *   | 消息指针                                                     |
| time          | uint32   | 调用该函数，任务最大阻塞时间，单位tick,rkos中1个tick 10ms. MAX_DELAY表示永久性阻塞直到接收成功。 |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS：接收成功，RK_ERROR： 接收失败 |

### 信号量的创建，删除，获取，释放

#### rkos_semaphore_create

**功能：创建信号量**

原型：pSemaphore rkos_semaphore_create(uint32 MaxCnt, uint32 InitCnt)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| MaxCnt        | uint32     | typedef  unsigned long  uint32信号的最大个数                 |
| InitCnt       | uint32     | typedef  unsigned long  uint32初始信号个数                   |
| return        | pSemaphore | typedef void * pSemaphore创建成功:返回信号量的句柄创建失败：返回NULL |

#### rkos_semaphore_delete

**功能：删除信量**

原型：rk_err_t rkos_semaphore_delete(pSemaphore pSem)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| pSem          | pSemaphore | typedef void * pSemaphore信号量的句柄，rkos_semaphore_create返回值 |
| return        | rk_err_t   | typedef  int   rk_err_tRK_SUCCESS:删除成功，RK_ERROR： 删除失败 |

#### rkos_semaphore_take

**功能：获取信号量**

原型：rk_err_t rkos_semaphore_take(pSemaphore pSem, uint32 time)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| pSem          | pSemaphore | typedef void * pSemaphore信号量的句柄，rkos_semaphore_create返回值 |
| time          | uint32     | 调用该函数，任务最大阻塞时间，单位tick,rkos中1个tick 10ms. MAX_DELAY表示永久性阻塞直到获取成功。 |
| return        | rk_err_t   | typedef  int   rk_err_tRK_SUCCESS:获取成功，RK_ERROR： 获取失败 |

#### rkos_semaphore_give

**功能：释放信号量**

原型：rk_err_t rkos_semaphore_give(pSemaphore pSem)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| pSem          | pSemaphore | typedef void * pSemaphore信号量的句柄，rkos_semaphore_create返回值 |
| return        | rk_err_t   | typedef  int   rk_err_tRK_SUCCESS：释放成功，RK_ERROR： 释放失败 |

#### rkos_semaphore_give_fromisr

**功能：中断服务程序中释放信号量**

原型：rk_err_t rkos_semaphore_give_fromisr(pSemaphore pSem)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| pSem          | pSemaphore | typedef void * pSemaphore信号量的句柄，rkos_semaphore_create返回值 |
| return        | rk_err_t   | typedef  int   rk_err_tRK_SUCCESS：释放成功，RK_ERROR： 释放失败 |

### 互斥量的创建

#### rkos_mutex_create

**功能：创建互斥量**

原型：pSemaphore rkos_mutex_create(void)

| **Parameter** | **Type**   | **Description**                                              |
| ------------- | ---------- | ------------------------------------------------------------ |
| return        | pSemaphore | typedef void * pSemaphore创建成功:返回互斥量的句柄创建失败：返回NULL |

### 任务释放CPU资源的Delay

#### rkos_sleep

**功能：释放时间片的延迟**

原型：void rkos_sleep(uint32 ms)

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| ms            | uint32   | typedef  unsigned long  uint32延迟时间，单位MS，当小于1个TICK的值时，延迟1个TICK，RKOS中1个TICK等于10MS |

### 临界区的进入和退出

#### rkos_critical_enter

**功能：进入临界区**

原型：void rkos_critical_enter(void)

#### rkos_critical_exit

**功能：退出临界区**

原型：void rkos_critical_exit(void)

### 内存的申请和释放

#### rkos_memory_malloc

**功能：申请内存资源**

原型：void \* rkos_memory_malloc(uint32 size)

| **Parameter** | **Type** | **Description**                                             |
| ------------- | -------- | ----------------------------------------------------------- |
| size          | uint32   | typedef  unsigned long  uint32申请内存的期望SIZE, 单位BYTE. |
| return        | void *   | 申请成功：返回内存的地址申请失败：返回NULL                  |

#### rkos_memory_free

**功能：释放内存资源**

原型：void rkos_memory_free(void \* buf)

| **Parameter** | **Type** | **Description**                                             |
| ------------- | -------- | ----------------------------------------------------------- |
| buf           | void *   | 内存地址，rkos_memory_malloc或者rkos_memory_realloc的返回值 |

#### rkos_memory_realloc

**功能：改变内存资源的大小**

原型：

```c
void  * rkos_memory_realloc(void * pv, uint32 size)
```

| **Parameter** | **Type** | **Description**                                             |
| ------------- | -------- | ----------------------------------------------------------- |
| pv            | void *   | 内存地址，rkos_memory_malloc或者rkos_memory_realloc的返回值 |
| size          | uint32   | typedef  unsigned long  uint32期望SIZE，单位BYTE.           |
| return        | void *   | 改变成功：返回内存的地址改变失败：返回NULL                  |

### RKOS任务状态迁移图

![img](.\resources\State_transition.png)

说明：任务调度器启动之前创建的线程都是Ready状态，启动之后，从Ready状态找个最高优先级的task运行，紧接着就会按上图发生状态迁移，现将上图18种事件举例说明如下：

1. X任务调用rkos_semaphore_give释放信号量引起Y任务从Suspend状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件10处于Suspend状态。

![img](.\resources\State_transition_1.png)

2. X中断服务程序调用rkos_semaphore_give_fromisr释放信号量引起Y任务从Suspend状态迁移到Ready状态，退出中断服务程序后，调度器检查17、18事件是否发生。Y任务必须是因为事件10处于Suspend状态。

![img](.\resources\State_transition_2.png)

3. X任务调用rkos_queue_receive取走Z消息队列中的一个消息，引起Y任务从Suspend状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件12处于Suspend状态。Z消息队列必须满。

![img](.\resources\State_transition_3.png)

4. X任务调用rkos_queue_send向Z消息队列发送一个消息，引起Y任务从Suspend状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件11处于Suspend状态。Z消息队列必须空。

![img](.\resources\State_transition_4.png)

5. X任务调用rkos_semaphore_give释放信号量引起Y任务从Blocked状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件13处于Blocked状态。

![img](.\resources\State_transition_5.png)

6. X中断服务程序调用rkos_semaphore_give_fromisr释放信号量引起Y任务从Blocked状态迁移到Ready状态，退出中断服务程序后，调度器检查17、18事件是否发生。Y任务必须是因为事件13处于Blocked状态。

![img](.\resources\State_transition_6.png)

7. X任务调用rkos_queue_receive取走Z消息队列中的一个消息，引起Y任务从Blocked状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件15处于Blocked状态。Z消息队列必须满。

![img](.\resources\State_transition_7.png)

8. X任务调用rkos_queue_send向Z消息队列发送一个消息，引起Y任务从Blocked状态迁移到Ready状态，同时检查17、18事件是否产生，Y任务必须是因为事件14处于Blocked状态。Z消息队列必须空。

![img](.\resources\State_transition_8.png)

9. 由于超时引起Y任务从Blocked状态迁移到Ready状态，同时检查17.18事件是否产生，Y必须满足是因为13、14、15、16事件进入Blocked状态，同时对应的6（13）、7（13）、9（14）、8（15）未发生，此事件例子为6、7、8、9的例子。

10. X任务调用rkos_semaphore_take获取信号量Z引起X任务从Runnig状态迁移到Suspend状态，同时检查17、18事件是否产生。X获取信号量的阻塞时间必须无穷大，Z的当前信号个数必须为0

![img](.\resources\State_transition_10.png)

11. X任务调用rkos_queue_receive取走Z消息队列中的一个消息，引起X任务从Running状态迁移到Suspend状态，同时检查17、18事件是否产生，X获取消息的阻塞时间必须无穷大，Z消息队列必须为空。

![img](.\resources\State_transition_11.png)

12. X任务调用rkos_queue_send向Z消息队列发送一个消息，引起X任务从Running状态迁移到Suspend状态，同时检查17、18事件是否产生，X获取消息的阻塞时间必须无穷大，Z消息队列必须为满。

![img](.\resources\State_transition_12.png)

13. X任务调用rkos_semaphore_take获取信号量Z引起X任务从Runnig状态迁移到Blocked状态，同时检查17、18事件是否产生。X获取信号量的阻塞时间必须是n ticks，Z的当前信号个数必须为0

![img](.\resources\State_transition_13.png)

14. X任务调用rkos_queue_receive取走Z消息队列中的一个消息，引起X任务从Running状态迁移到Blocked状态，同时检查17、18事件是否产生，X获取信号量的阻塞时间必须是n ticks，Z消息队列必须为空。

![img](.\resources\State_transition_14.png)

15. X任务调用rkos_queue_send向Z消息队列发送一个消息，引起X任务从Running状态迁移到Blocked状态，同时检查17、18事件是否产生，X获取信号量的阻塞时间必须是n ticks，Z消息队列必须为满。目前代码中无相关的使用。

16. X任务调用rkos_sleep, 引起X任务从Running状态迁移到Blocked状态，同时检查17、18事件是否发生。

![img](.\resources\State_transition_16.png)

17. 和18事件同时发生，1-16事件产生，可能产生17事件。

18. 和17事件同时发生，1-16事件产生，可能产生18事件。

## 任务管理

### 任务类

RKOS的任务分为2种，一种是静态任务，另一种是动态任务，2种任务仅仅是注册接口不相同，其他的完全一样。

静态任务：必须静态注册到任务管理器当中，每个类分配一个ID以及初始化所需要的参数。此类任务在创建时必须由创建者指定对象ID。优点：方便管理，使用者很容易通过类ID和对象ID来区分任务，可由任务管理器托管创建，进行复杂的模块组合。缺点：静态注册，不便于移植程序。

动态任务：此任务不需要实现注册，没有类ID和对象ID， 通过单一API创建即可。优点：方便移植，不用静态注册。缺点：无法支持托管创建，复杂模块组合由创建者和被创建者自己实现。只能通过句柄来辨识任务，句柄是实时的，第三者无法辨识任务。

以上2种任务共用一种控制块：

![img](.\resources\task_class.png)

| **Parameter**  | **Type**                | **Description**                                              |
| -------------- | ----------------------- | ------------------------------------------------------------ |
| NextTCB        | struct _RK_TASK_CLASS * | 下一个控制块指针                                             |
| TaskInitFun    | pTaskInitFunType        | 线程初始化入口，可以为NULL                                   |
| TaskFun        | pTaskFunType            | 线程体入口，不能为NULL                                       |
| TaskDeInitFun  | pTaskDeInitFunType      | 线程反初始化入口，可以为NULL                                 |
| TaskSuspendFun | pTaskSuspendFunType     | 线程休眠入口，可以为NULL                                     |
| TaskResumeFun  | pTaskResumeFunType      | 线程唤醒入口，可以为NULL                                     |
| hTask          | HTC                     | 第三方操作系统的线程句柄                                     |
| TaskFlag       | uint8                   | 保留                                                         |
| OverlayModule  | uint32                  | 任务段ID                                                     |
| TaskPriority   | uint32                  | 任务优先级                                                   |
| TaskStackSize  | uint32                  | 任务栈大小                                                   |
| TaskClassID    | uint32                  | 任务类ID                                                     |
| TaskObjectID   | uint32                  | 任务对象ID                                                   |
| taskname       | uint8 *                 | 任务名                                                       |
| TotalMemory    | uint32                  | 任务所申请的内存总空间                                       |
| State          | uint32                  | 任务状态                                                     |
| IdleTick       | uint32                  | 休眠TICK                                                     |
| Idle1EventTime | uint32                  | 一级休眠触发时间                                             |
| Idle2EventTime | uint32                  | 二级休眠触发时间                                             |
| suspendmode    | uint32                  | 休眠模式：DISABLE_MODE    0X00  拒绝休眠ENABLE_MODE     0x01  使能休眠FORCE_MODE      0X02  强制休眠 |

### 任务对象

任务类本身无法运行，必须被实例化成对象才能运行，每个任务对象在堆里有一个控制块，任务管理器将这些对象用指针串接在一起，构成一个对象链，如下图：

![img](.\resources\task_obj_1.png)

任务管理器所有的操作都是基于这个对象链表，此链表可以通过Shell命令查看。

![img](.\resources\task_obj_2.png)

### 任务管理器

任务管理器本身也是一个任务，优先级比较高，但比实时性要求高的任务（如播放任务）的优先级要低，任务管理负责RKOS上所有任务的创建，删除，休眠等操作。

#### 任务的创建

l 非托管模式：创建者直接在自己栈里创建任务，没有任务切换。

l 同步托管模式：创建者将要创建的任务信息发送到任务管理器，任务管理器创建任务，创建者被挂起，直到任务创建结束，有任务切换。

l 异步托管模式：创建者将要创建的任务信息发送到任务管理器后，直接退出，有任务切换。

以上3种模式只是封装不一样，其核心实现方式是一致的，流程图如下：

![img](.\resources\task_create_process.png)

#### 任务删除

l 非托管模式：删除者直接在自己栈里删除任务，没有任务切换。

l 同步托管模式：删除者将要删除的任务信息发送到任务管理器，任务管理器删除任务，删除者被挂起，直到任务删除结束，有任务切换。

l 异步托管模式：删除者将要删除的任务信息发送到任务管理器后，直接退出，有任务切换。

以上3种模式只是封装不一样，其核心实现方式是一致的，流程图如下：

![img](.\resources\task_delete.png)

#### 任务的休眠

任务管理器会在休眠时钟的驱动下，逐个对任务列表上任务进行检查，达到休眠条件的任务将被休眠。休眠时钟是RKOS休眠模块产生的，详见休眠机制。

task_sleep
![img](.\resources\task_sleep.png)

### 任务管理器API

#### rktm_enable_task_suspend

**功能：打开任务休眠功能**

原型：void rktm_enable_task_suspend(HTC hTask);

| **Parameter** | **Type** | **Description**              |
| ------------- | -------- | ---------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄 |

#### rktm_disable_task_suspend

**功能：关闭任务休眠功能**

原型：void rktm_disable_task_suspend(HTC hTask);

| **Parameter** | **Type** | **Description**              |
| ------------- | -------- | ---------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄 |

#### rktm_disable_create_task

**功能：禁止创建任务**

原型：void rktm_disable_create_task(void);

#### rktm_enable_create_task

**功能：使能创建任务**

原型：void rktm_enable_create_task(void);

#### rktm_idle_tick

**功能：任务管理器休眠时钟，调用一次视为1个CLK**

原型：rk_err_t rktm_idle_tick(void);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| return        | rk_err_t | typedef  int   rk_err_tRK_SUCCESS:发送成功，RK_ERROR： 发送失败 |

#### rktm_get_task_runtime

**功能：获取任务消耗CPU时间，单位为TICK，获取之后清零。**

原型：uint32 rktm_get_task_runtime(HTC hTask);

| **Parameter** | **Type** | **Description**              |
| ------------- | -------- | ---------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄 |
| return        | uint32   | tick                         |

#### rktm_get_current_task_handle

**功能：获取当前任务的句柄**

原型：HTC rktm_get_current_task_handle(void);

| **Parameter** | **Type** | **Description**                  |
| ------------- | -------- | -------------------------------- |
| return        | HTC      | typedef void * HTC；当前任务句柄 |

#### rktm_get_task_name

**功能：获取当前任务的名称**

原型：void \* rktm_get_task_name(HTC hTask);

| **Parameter** | **Type** | **Description**              |
| ------------- | -------- | ---------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄 |
| return        | void *   | 任务名指针                   |

#### rktm_delete_task

**功能：删除动态任务**

原型：rk_err_t rktm_delete_task(HTC hTask);

| **Parameter** | **Type** | **Description**                                      |
| ------------- | -------- | ---------------------------------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄，为NULL表示当前任务句柄 |
| return        | rk_err_t | RK_SUCCESS：删除成功，RK_ERROR：删除失败             |

#### rktm_create_task

**功能：创建动态任务**

原型：HTC rktm_create_task(pTaskFunType TaskCode,

pTaskSuspendFunType SuspendCode,

pTaskResumeFunType ResumeCode,

char \*name, uint32 StackDeep,

uint32 Priority,

void \* para);

| **Parameter** | **Type**            | **Description**                                              |
| ------------- | ------------------- | ------------------------------------------------------------ |
| TaskCode      | pTaskFunType        | typedef void (*pTaskFunType)(void *)任务执行入口函数指针     |
| SuspendCode   | pTaskSuspendFunType | typedef rk_err_t (*pTaskSuspendFunType)(void *, uint32)任务休眠入口函数指针 |
| ResumeCode    | pTaskResumeFunType  | typedef rk_err_t (*pTaskResumeFunType)(void *)任务唤醒入口函数指针 |
| name          | char *              | 任务名                                                       |
| StackDeep     | uint32              | typedef  unsigned long  uint32任务栈大小，单位字             |
| Priority      | uint32              | typedef  unsigned long  uint32任务优先级0-31，数字越大优先级越高 |
| para          | void *              | 执行入口函数参数                                             |
| return        | HTC                 | typedef void * HTC：任务句柄，为NULL表示创建失败             |

#### rktm_delete_static_task

**功能：删除静态任务**

原型：rk_err_t rktm_delete_static_task(uint32 TaskClassID, uint32 TaskObjectID, uint32 Mode);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32静态任务类ID                   |
| TaskObjectID  | uint32   | typedef  unsigned long  uint32静态任务对象ID                 |
| Mode          | uint32   | typedef  unsigned long  uint32删除模式：SYNC_MODE 同步托管模式ASYNC_MODE 异步托管模式DIRECT_MODE 非托管模式 |
| return        | rk_err_t | RK_SUCCESS：删除成功，RK_ERROR：删除失败                     |

#### rktm_create_static_task

**功能：创建静态任务**

原型：rk_err_t rktm_create_static_task(uint32 TaskClassID, uint32 TaskObjectID, void \* arg, uint32 Mode);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32静态任务类ID                   |
| TaskObjectID  | uint32   | typedef  unsigned long  uint32静态任务对象ID                 |
| arg           | void *   | 执行入口函数参数                                             |
| Mode          | uint32   | typedef  unsigned long  uint32删除模式：SYNC_MODE 同步托管模式ASYNC_MODE 异步托管模式DIRECT_MODE 非托管模式 |
| return        | rk_err_t | RK_SUCCESS:创建成功，RK_ERROR：创建失败                      |

#### rktm_get_next_handle

**功能：获取下一个任务句柄**

原型：HTC rktm_get_next_handle(HTC hTask, uint32 TaskClassID);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| hTask         | HTC      | typedef void * HTC参考节点的任务句柄                         |
| TaskClassID   | uint32   | typedef  unsigned long  uint32赛选条件，不满足此条件的不被获取， 0XFFFFFFFF表示获取所有 |
| return        | HTC      | typedef void * HTC要获取的任务句柄，为NULL表示获取失败       |

#### rktm_get_first_handle

**功能：获取第一个任务句柄**

原型：HTC rktm_get_first_handle(uint32 TaskClassID);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32赛选条件，不满足此条件的不被获取， 0XFFFFFFFF表示获取所有 |
| return        | HTC      | typedef void * HTC要获取的任务句柄，为NULL表示获取失败       |

#### rktm_get_total_cnt

**功能：获取任务个数**

原型：uint32 rktm_get_total_cnt(uint32 TaskClassID);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| TaskClassID   | uint32   | typedef  unsigned long  uint32赛选条件，不满足此条件的不被获取，0XFFFFFFFF表示获取所有 |
| return        | uint32   | typedef  unsigned long  uint32满足条件的任务总数             |

#### rktm_find_task

**功能：查找任务**

原型：HTC rktm_find_task(uint32 TaskClassID, uint32 TaskObjectID);

| **Parameter** | **Type** | **Description**                                |
| ------------- | -------- | ---------------------------------------------- |
| TaskClassID   | uint32   | typedef  unsigned long  uint32静态任务类ID     |
| TaskObjectID  | uint32   | typedef  unsigned long  uint32静态任务对象ID   |
| return        | HTC      | typedef void * HTC任务句柄，为NULL表示查找失败 |

#### rktm_get_heap_totalsize

**功能：获取Heap总量**

原型：uint32 rktm_get_heap_totalsize(void);

| **Parameter** | **Type** | **Description**                                    |
| ------------- | -------- | -------------------------------------------------- |
| return        | uint32   | typedef  unsigned long  uint32堆的总大小，单位字节 |

#### rktm_get_heap_freesize

**功能：获取Heap剩余总量**

原型：uint32 rktm_get_heap_freesize(void);

| **Parameter** | **Type** | **Description**                                    |
| ------------- | -------- | -------------------------------------------------- |
| return        | uint32   | typedef  unsigned long  uint32堆的总大小，单位字节 |

#### rktm_get_task_stack_totalsize

**功能：获取任务栈总SIZE**

原型：uint32 rktm_get_task_stack_totalsize(HTC hTask);

| **Parameter** | **Type** | **Description**                                        |
| ------------- | -------- | ------------------------------------------------------ |
| hTask         | HTC      | typedef void * HTC；任务句柄                           |
| return        | uint32   | typedef  unsigned long  uint32任务栈的总大小，单位字节 |

#### rktm_get_task_stack_freesize

**功能：获取任务栈剩余**

原型：uint32 rktm_get_task_stack_freesize(HTC hTask);

| **Parameter** | **Type** | **Description**                                          |
| ------------- | -------- | -------------------------------------------------------- |
| hTask         | HTC      | typedef void * HTC；任务句柄                             |
| return        | uint32   | typedef  unsigned long  uint32任务栈的剩余大小，单位字节 |

#### rktm_get_task_state

**功能：获取任务状态**

原型：uint32 rktm_get_task_state(HTC hTask);

| **Parameter** | **Type** | **Description**                                              |
| ------------- | -------- | ------------------------------------------------------------ |
| hTask         | HTC      | typedef void * HTC；任务句柄                                 |
| return        | uint32   | typedef unsigned long uint32 0：Runing --- 运行态 1：Ready --- 就绪态 2：Blocked --- 阻塞态 3: Suspend --- 挂起态 4: Deleted --- 删除态 |

### 种任务创建API对比说明

本文所指的任务统称为线程，但是每个API创建出来任务性质不同，使用场景不同。

2. rktm_create_static_task任务管理定义的静态任务类，需要将任务信息静态注册到系统中，每个任务指定一个类ID，创建的对象指定对象ID, 需要和其他任务进行OVERLAY的，有明显的初始化和反初始化入口，不能被强行删除的等需要使用此接口，此接口繁琐，而且影响系统代码。

3. rktm_create_task为了弥补rktm_create_static_task的缺陷，方便外来代码移植，设计此API，此API没有类ID和对象ID，使用名称或者句柄来区分任务，优点不影响系统代码，不受任务管理器框架制约，缺点是OVERLAY和强制删除需要任务本身处理。
