# Rockchip_RK3568_Reference_SATA_Performance_CN

文件标识:  RK-KF-YF-138

发布版本：1.0.0

日期：2020-12-21

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

本文档描述RK3568 SATA性能测试和指标数据，测试基于RK3568 EVB1 开发板。

**各芯片 feature 支持状态**

| **芯片名称**  | **内核版本** |
| ------------- | ------------ |
| RK3568/RK3566 | 4.19         |

**读者对象**

本文档主要适用于以下工程师：

技术支持工程师

软件开发工程师

项目管理人员

测试工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.00      | 赵仪峰   | 2020-12-21   | 初始版本     |

---

**目录**

[TOC]

---

## SATA硬盘测试方法

固态硬盘每次测试写数据前建议先格式化一下磁盘或者删除测试文件，让固态硬盘恢复写性能，命令如下：

```
 mkfs.ext4 /dev/block/sda
 rm /mnt/sda/test
```

- dd 速率统计： 使用带有速率计算功能的 dd 命令进行统计；

- 使用格式化命令进行格式化， 如下：

  ```
  mkdosfs -F 32 /dev/block/sda
  mkfs.ext4 /dev/block/sda
  ```

- 挂载硬盘到/mnt/目录， 例如：

  ```
  mkdir /mnt/sda
  mount -t vfat /dev/block/sda /mnt/sda
  mount -t ext4 /dev/block/sda /mnt/sda
  ```

- 写速率：

  ```
  dd if=/dev/zero of=/mnt/sda/test bs=1024K count=2048
  ```

- 读速率：

  ```
  echo 3 > /proc/sys/vm/drop_caches
  dd if=/mnt/sda/test of=/dev/null bs=1024K count=2048
  ```

- FIO RAW写性能测试：

  ```
  fio -filename=/dev/block/sda -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=1024k -size=10G -numjobs=10 -runtime=180 -group_reporting -name=seq_100write_1024k
  ```

- FIO 写性能测试：

  ```
  fio -filename=/mnt/sda/test -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=1024k -size=10G -numjobs=10 -runtime=180 -group_reporting -name=seq_100write_1024k
  ```

- FIO RAW读性能测试：

  ```
  fio -filename=/dev/block/sda -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=1024k -size=10G -numjobs=10 -runtime=180 -group_reporting -name=seq_100read_1024k
  ```

- FIO 读性能测试：

  ```
  fio -filename=/mnt/sda/test -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=1024k -size=10G -numjobs=10 -runtime=180 -group_reporting -name=seq_100read_1024k
  ```

- FIO RAW读写性能测试：

  ```
  fio -filename=/dev/block/sda -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=128k -size=30G -numjobs=10 -runtime=180 -group_reporting -name=randrw_70read_128k
  ```

- FIO 读写性能测试：

  ```
  fio -filename=/mnt/sda/test -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=128k -size=30G -numjobs=10 -runtime=180 -group_reporting -name=randrw_70read_128k
  ```

- 1.5G、 3.0G 和 6.0G 速率配置：

  ```
  6G: io -w -4 0xfdc50000 0x33302220
  3G: io -w -4 0xfdc50000 0x33301110
  1.5G: io -w -4 0xfdc50000 0x33300000
  ```

## SATA机械硬盘测试性能

### 机械硬盘测试环境

| 型号     | 品牌 | 容量 | 模式            | 备注             |
| -------- | ---- | ---- | --------------- | ---------------- |
| WD10EZEX | WD   | 1TB  | SATA1.0&2.0&3.0 | 64MB 缓存，蓝 盘 |

### 机械硬盘测试数据

注：由于FIO测试命令采用10个线程读写同一个文件，部分读取会直接从硬盘内部缓存返回，读速度比单线读取要快很多。写数据时多线程会比单线程慢一点。

#### 1.5G测试数据

##### 机械硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 79MB/S  | 130MB/S |
| DD读   | 135MB/S | 117MB/S |

##### 机械硬盘FIO测试

| 测试项  | RAW                   | EXT4                  |
| ------- | --------------------- | --------------------- |
| FIO写   | 118MB/S               | 91.2MB/S              |
| FIO读   | 143MB/S               | 138MB/S               |
| FIO读写 | R:19.2MB/S W:8523KB/S | R:11.1MB/S W:4715KB/S |

#### 3G测试数据

##### 机械硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 98MB/S  | 174MB/S |
| DD读   | 186MB/S | 176MB/S |

##### 机械硬盘FIO测试

| 测试项  | RAW                   | EXT4                  |
| ------- | --------------------- | --------------------- |
| FIO写   | 193MB/S               | 163MB/S               |
| FIO读   | 276MB/S               | 262MB/S               |
| FIO读写 | R:20.3MB/S W:8601KB/S | R:12.7MB/S W:5447KB/S |

#### 6G测试数据

##### 机械硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 102MB/S | 176MB/S |
| DD读   | 187MB/S | 177MB/S |

##### 机械硬盘FIO测试

| 测试项  | RAW                   | EXT4                  |
| ------- | --------------------- | --------------------- |
| FIO写   | 238MB/S               | 188MB/S               |
| FIO读   | 451MB/S               | 463MB/S               |
| FIO读写 | R:19.3MB/S W:8567KB/S | R:11.7MB/S W:4967KB/S |

## 固态硬盘测试性能

### 固态硬盘测试环境

| 型号  | 品牌     | 容量  | 模式            | 备注         |
| ----- | -------- | ----- | --------------- | ------------ |
| SC001 | 长江存储 | 256GB | SATA1.0&2.0&3.0 | FW: YM013200 |

### 固态硬盘测试数据

#### 1.5G测试数据

##### 固态硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 83MB/S  | 135MB/S |
| DD读   | 135MB/S | 129MB/S |

##### 固态硬盘FIO测试

| 测试项  | RAW                   | EXT4                  |
| ------- | --------------------- | --------------------- |
| FIO写   | 132MB/S               | 110MB/S               |
| FIO读   | 142MB/S               | 142MB/S               |
| FIO读写 | R:95.1MB/S W:41.2MB/S | R:72.1MB/S W:30.8MB/S |

#### 3G测试数据

##### 固态硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 122MB/S | 251MB/S |
| DD读   | 267MB/S | 257MB/S |

##### 固态硬盘FIO测试

| 测试项  | RAW                  | EXT4                |
| ------- | -------------------- | ------------------- |
| FIO写   | 257MB/S              | 197MB/S             |
| FIO读   | 284MB/S              | 284MB/S             |
| FIO读写 | R:189MB/S W:81.2MB/S | R：121MB/S W:57MB/S |

#### 6G测试数据

##### 固态硬盘DD测试

| 测试项 | FAT32   | EXT4    |
| ------ | ------- | ------- |
| DD写   | 162MB/S | 287MB/S |
| DD读   | 403MB/S | 443MB/S |

##### 固态硬盘FIO测试

| 测试项  | RAW                  | EXT4                 |
| ------- | -------------------- | -------------------- |
| FIO写   | 378MB/s              | 313MB/S              |
| FIO读   | 567MB/s              | 547MB/S              |
| FIO读写 | R：339MB/S W:145MB/S | R:175MB/S W:74.9MB/S |

## SATA 硬盘测试结论

### 机械硬盘性能

测试了型号为 WD10EZEX 的一款 1TB SATA 机械硬盘在 fat32和ext4 文件系统下DD读写性能，以及ext4文件系统和无文件系统下FIO的读写性能。

#### DD读写性能

FAT32文件系统下，读速率在1.5Gbps模式可以达到135MB/S，  3.0Gbps 和 6.0Gbps 模式下可达到 186MB/s。

EXT4文件系统下，写速率在1.5Gbps模式可以达到130MB/S，  3.0Gbps 和 6.0Gbps 模式下可达到 174MB/s。

1.5Gbps模式时速率接近接口速率，3.0Gbps 和 6.0Gbps 模式时速率接近硬盘最高速率。

#### FIO读写性能

多线程读时，在6Gbps模式下读可以达到451MB/S,超过了机械硬盘实际速率，通过协议分析仪抓取数据，确定是多线程读取同一个文件，大部分读会命中硬盘的缓存。

多线程写时，在6Gbps模式下读可以达到180MB/S, 接近硬盘写性能。

多线程读写并发时，读写性能下降非常多，符合机械硬盘特性。详情可以参考测试原始数据。

#### 1.5G、 3.0G 和 6.0G 模式对比

6.0Gbps、 3.0Gbps、 1.5Gbps 的性能依次降低， 但是写速率差别不是很显著， 读速率 3.0Gbps 和 6.0Gbps 模式下显著高于 1.5Gbps。

#### fat32和ext4 文件系统对比

从整体来看， 写性能在 ext4文件系统下显著高于 fat32， 读性能相差不大。

### 固态硬盘性能

测试了型号为 SC001的一款 256GB SATA 固态硬盘（64层3D TLC）在 fat32和ext4 文件系统下DD读写性能，以及ext4文件系统和无文件系统下FIO的读写性能。

#### DD读写性能

FAT32文件系统下，读速率在1.5Gbps模式可以达到135MB/S，  3.0Gbps模式下可达到 267MB/s， 6.0Gbps模式下可以达到407MB/S 。

EXT4文件系统下，写速率在1.5Gbps模式可以达到135MB/S，  3.0Gbps模式下可达到 251MB/s， 6.0Gbps模式下可以达到287MB/S 。

1.5Gbps和3.0Gbps模式时速率接近接口速率，6.0Gbps 模式时速率接近硬盘单线程最高速率。

#### FIO读写性能

RAW模式下读写性能比EXT4文件系统要好一点，多线程读时，在6Gbps模式下读可以达到567MB/S,接近接口速率。

多线程写时，在6Gbps模式下读可以达到378MB/S, 接近硬盘写性能。在3Gbps和1.5Gbps模式下，速率接近接口速率。

多线程读写时，在EXT4文件系统下，读写性能下降比较多，原因是文件系统小数据读写增加。无文件系统下读写速度加起来接近接口速率。

#### 1.5G、 3.0G 和 6.0G 模式对比

从整体来看， 1.5Gbps和3.0Gbps模式下读写性能都接近接口速率，6.0Gbps 的读写性能显著优于1.5Gbps和3.0Gbps模式性能。

#### fat32和ext4 文件系统对比

从整体来看， 写性能在 ext4文件系统下显著高于 fat32， 读性能相差不大。

## 测试原始数据

### 6G 固态FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1874: Tue Nov 24 18:01:16 2020
  write: IOPS=360, BW=361MiB/s (378MB/s)(63.4GiB/180053msec)
    clat (msec): min=6, max=499, avg=27.40, stdev=23.79
     lat (msec): min=6, max=499, avg=27.69, stdev=23.79
    clat percentiles (msec):
     |  1.00th=[   20],  5.00th=[   20], 10.00th=[   20], 20.00th=[   20],
     | 30.00th=[   20], 40.00th=[   20], 50.00th=[   20], 60.00th=[   20],
     | 70.00th=[   20], 80.00th=[   20], 90.00th=[   58], 95.00th=[   59],
     | 99.00th=[   61], 99.50th=[   89], 99.90th=[  306], 99.95th=[  338],
     | 99.99th=[  498]
   bw (  KiB/s): min= 4104, max=54113, per=0.01%, avg=37206.85, stdev=15908.21
    lat (msec) : 10=0.01%, 20=80.55%, 50=2.84%, 100=16.19%, 250=0.03%
    lat (msec) : 500=0.38%
  cpu          : usr=1.09%, sys=0.98%, ctx=68607, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,64943,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=361MiB/s (378MB/s), 361MiB/s-361MiB/s (378MB/s-378MB/s), io=63.4GiB (68.1GB), run=180053-180053msec

Disk stats (read/write):
  sda: ios=0/64908, merge=0/0, ticks=0/1759057, in_queue=1757523, util=100.00%
```

### 6G 固态FIO RAW读

```
seq_100read_1024k: (g=0): rw=read, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-1024KiB, ioengine=psync, iodepth=1
...
fio-2.20
Starting 10 threads
Jobs: 10 (f=10): [R(10)][100.0%][r=541MiB/s,w=0KiB/s][r=541,w=0 IOPS][eta 00m:00s]
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1795: Tue Nov 24 17:37:13 2020
   read: IOPS=540, BW=541MiB/s (567MB/s)(31.7GiB/60018msec)
    clat (usec): min=16345, max=27735, avg=18463.75, stdev=102.66
     lat (usec): min=16348, max=27737, avg=18466.33, stdev=102.57
    clat percentiles (usec):
     |  1.00th=[18304],  5.00th=[18304], 10.00th=[18304], 20.00th=[18304],
     | 30.00th=[18560], 40.00th=[18560], 50.00th=[18560], 60.00th=[18560],
     | 70.00th=[18560], 80.00th=[18560], 90.00th=[18560], 95.00th=[18560],
     | 99.00th=[18560], 99.50th=[18560], 99.90th=[18816], 99.95th=[18816],
     | 99.99th=[23936]
   bw (  KiB/s): min=53354, max=58040, per=0.01%, avg=55715.52, stdev=505.47
    lat (msec) : 20=99.97%, 50=0.03%
  cpu          : usr=0.19%, sys=1.69%, ctx=68267, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=32450,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=541MiB/s (567MB/s), 541MiB/s-541MiB/s (567MB/s-567MB/s), io=31.7GiB (34.0GB), run=60018-60018msec

Disk stats (read/write):
  sda: ios=35595/0, merge=0/0, ticks=642173/0, in_queue=635899, util=100.00%
```

### 6G 固态FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=2159: Tue Nov 24 21:58:19 2020
   read: IOPS=2589, BW=324MiB/s (339MB/s)(56.9GiB/180003msec)
    clat (usec): min=602, max=188853, avg=1267.86, stdev=937.61
     lat (usec): min=605, max=188854, avg=1269.76, stdev=937.65
    clat percentiles (usec):
     |  1.00th=[  684],  5.00th=[  732], 10.00th=[  900], 20.00th=[  932],
     | 30.00th=[  980], 40.00th=[ 1096], 50.00th=[ 1176], 60.00th=[ 1256],
     | 70.00th=[ 1368], 80.00th=[ 1496], 90.00th=[ 1704], 95.00th=[ 1896],
     | 99.00th=[ 4048], 99.50th=[ 4640], 99.90th=[ 5728], 99.95th=[ 6816],
     | 99.99th=[21376]
   bw (  KiB/s): min=16128, max=49250, per=0.01%, avg=33222.29, stdev=3878.80
  write: IOPS=1109, BW=139MiB/s (145MB/s)(24.4GiB/180003msec)
    clat (usec): min=496, max=196193, avg=5944.85, stdev=2379.55
     lat (usec): min=520, max=196229, avg=5974.87, stdev=2379.22
    clat percentiles (usec):
     |  1.00th=[ 2800],  5.00th=[ 3408], 10.00th=[ 3792], 20.00th=[ 4320],
     | 30.00th=[ 4768], 40.00th=[ 5216], 50.00th=[ 5664], 60.00th=[ 6112],
     | 70.00th=[ 6624], 80.00th=[ 7328], 90.00th=[ 8384], 95.00th=[ 9280],
     | 99.00th=[11456], 99.50th=[12608], 99.90th=[24960], 99.95th=[26496],
     | 99.99th=[29568]
   bw (  KiB/s): min= 7951, max=17255, per=0.01%, avg=14234.57, stdev=963.78
    lat (usec) : 500=0.01%, 750=4.07%, 1000=18.99%
    lat (msec) : 2=44.47%, 4=5.78%, 10=25.78%, 20=0.82%, 50=0.08%
    lat (msec) : 250=0.01%
  cpu          : usr=1.28%, sys=3.73%, ctx=1119108, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=466133,199726,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=324MiB/s (339MB/s), 324MiB/s-324MiB/s (339MB/s-339MB/s), io=56.9GiB (61.1GB), run=180003-180003msec
  WRITE: bw=139MiB/s (145MB/s), 139MiB/s-139MiB/s (145MB/s-145MB/s), io=24.4GiB (26.2GB), run=180003-180003msec

Disk stats (read/write):
  sda: ios=465784/199535, merge=0/0, ticks=550694/1168569, in_queue=1691665, util=100.00%
```

### 6G 固态FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=2258: Tue Nov 24 22:40:13 2020
  write: IOPS=298, BW=298MiB/s (313MB/s)(52.4GiB/180053msec)
    clat (msec): min=2, max=663, avg=33.19, stdev=17.39
     lat (msec): min=3, max=663, avg=33.49, stdev=17.39
    clat percentiles (msec):
     |  1.00th=[   28],  5.00th=[   30], 10.00th=[   31], 20.00th=[   31],
     | 30.00th=[   31], 40.00th=[   31], 50.00th=[   31], 60.00th=[   31],
     | 70.00th=[   31], 80.00th=[   33], 90.00th=[   34], 95.00th=[   46],
     | 99.00th=[   71], 99.50th=[  196], 99.90th=[  258], 99.95th=[  281],
     | 99.99th=[  660]
   bw (  KiB/s): min= 2052, max=36937, per=0.01%, avg=30764.35, stdev=4778.12
    lat (msec) : 4=0.05%, 10=0.01%, 20=0.01%, 50=95.77%, 100=3.52%
    lat (msec) : 250=0.53%, 500=0.09%, 750=0.02%
  cpu          : usr=0.75%, sys=4.72%, ctx=109396, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,53699,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=298MiB/s (313MB/s), 298MiB/s-298MiB/s (313MB/s-313MB/s), io=52.4GiB (56.3GB), run=180053-180053msec

Disk stats (read/write):
  sda: ios=1/63043, merge=0/268, ticks=1/189794, in_queue=192985, util=84.22%
```

### 6G 固态FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=2284: Tue Nov 24 22:47:02 2020
   read: IOPS=521, BW=521MiB/s (547MB/s)(91.7GiB/180019msec)
    clat (msec): min=6, max=767, avg=19.15, stdev= 8.45
     lat (msec): min=6, max=767, avg=19.15, stdev= 8.45
    clat percentiles (msec):
     |  1.00th=[   19],  5.00th=[   19], 10.00th=[   19], 20.00th=[   19],
     | 30.00th=[   19], 40.00th=[   19], 50.00th=[   19], 60.00th=[   19],
     | 70.00th=[   19], 80.00th=[   19], 90.00th=[   19], 95.00th=[   20],
     | 99.00th=[   37], 99.50th=[   48], 99.90th=[   65], 99.95th=[   74],
     | 99.99th=[  742]
   bw (  KiB/s): min=14336, max=58040, per=0.01%, avg=53712.45, stdev=4266.89
    lat (msec) : 10=0.01%, 20=95.02%, 50=4.53%, 100=0.43%, 250=0.01%
    lat (msec) : 750=0.01%, 1000=0.01%
  cpu          : usr=0.18%, sys=4.25%, ctx=95144, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=93858,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=521MiB/s (547MB/s), 521MiB/s-521MiB/s (547MB/s-547MB/s), io=91.7GiB (98.4GB), run=180019-180019msec

Disk stats (read/write):
  sda: ios=103230/486, merge=5/11, ticks=1915566/84958, in_queue=1976259, util=100.00%
```

### 6G 固态FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=2314: Tue Nov 24 22:56:26 2020
   read: IOPS=1332, BW=167MiB/s (175MB/s)(29.3GiB/180006msec)
    clat (msec): min=1, max=41, avg= 5.15, stdev= 1.86
     lat (msec): min=1, max=41, avg= 5.15, stdev= 1.86
    clat percentiles (usec):
     |  1.00th=[ 2008],  5.00th=[ 2800], 10.00th=[ 3408], 20.00th=[ 3984],
     | 30.00th=[ 4448], 40.00th=[ 4768], 50.00th=[ 5024], 60.00th=[ 5344],
     | 70.00th=[ 5664], 80.00th=[ 6048], 90.00th=[ 6624], 95.00th=[ 7328],
     | 99.00th=[10176], 99.50th=[11840], 99.90th=[27008], 99.95th=[31872],
     | 99.99th=[37120]
   bw (  KiB/s): min=10773, max=22573, per=0.01%, avg=17081.38, stdev=1432.00
  write: IOPS=571, BW=71.4MiB/s (74.9MB/s)(12.5GiB/180006msec)
    clat (usec): min=485, max=40867, avg=5355.29, stdev=1888.80
     lat (usec): min=515, max=40904, avg=5395.19, stdev=1887.50
    clat percentiles (usec):
     |  1.00th=[ 2672],  5.00th=[ 3344], 10.00th=[ 3824], 20.00th=[ 4256],
     | 30.00th=[ 4640], 40.00th=[ 4960], 50.00th=[ 5216], 60.00th=[ 5472],
     | 70.00th=[ 5792], 80.00th=[ 6176], 90.00th=[ 6688], 95.00th=[ 7584],
     | 99.00th=[10304], 99.50th=[12352], 99.90th=[28288], 99.95th=[33024],
     | 99.99th=[38144]
   bw (  KiB/s): min= 2816, max=11286, per=0.01%, avg=7322.25, stdev=1135.78
    lat (usec) : 500=0.01%, 750=0.18%, 1000=0.04%
    lat (msec) : 2=0.70%, 4=17.46%, 10=80.40%, 20=0.95%, 50=0.27%
  cpu          : usr=0.98%, sys=6.38%, ctx=682432, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=239797,102799,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=167MiB/s (175MB/s), 167MiB/s-167MiB/s (175MB/s-175MB/s), io=29.3GiB (31.4GB), run=180006-180006msec
  WRITE: bw=71.4MiB/s (74.9MB/s), 71.4MiB/s-71.4MiB/s (74.9MB/s-74.9MB/s), io=12.5GiB (13.5GB), run=180006-180006msec

Disk stats (read/write):
  sda: ios=239570/106858, merge=0/78, ticks=287546/59409, in_queue=331198, util=75.19%
```

### 3G 固态FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1724: Tue Nov 24 15:28:01 2020
  write: IOPS=245, BW=246MiB/s (257MB/s)(43.2GiB/180036msec)
    clat (msec): min=8, max=409, avg=40.40, stdev=18.29
     lat (msec): min=8, max=409, avg=40.69, stdev=18.29
    clat percentiles (msec):
     |  1.00th=[   36],  5.00th=[   36], 10.00th=[   39], 20.00th=[   39],
     | 30.00th=[   39], 40.00th=[   39], 50.00th=[   39], 60.00th=[   39],
     | 70.00th=[   39], 80.00th=[   39], 90.00th=[   40], 95.00th=[   40],
     | 99.00th=[   60], 99.50th=[  128], 99.90th=[  322], 99.95th=[  322],
     | 99.99th=[  338]
   bw (  KiB/s): min= 6193, max=29138, per=0.01%, avg=25342.06, stdev=3108.25
    lat (msec) : 10=0.01%, 20=0.01%, 50=96.71%, 100=2.64%, 250=0.26%
    lat (msec) : 500=0.38%
  cpu          : usr=0.73%, sys=0.96%, ctx=46661, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,44207,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=246MiB/s (257MB/s), 246MiB/s-246MiB/s (257MB/s-257MB/s), io=43.2GiB (46.4GB), run=180036-180036msec

Disk stats (read/write):
  sda: ios=0/52957, merge=0/0, ticks=0/2106071, in_queue=2105193, util=100.00%
```

### 3G 固态FIO RAW读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1701: Tue Nov 24 15:25:18 2020
   read: IOPS=270, BW=271MiB/s (284MB/s)(47.6GiB/180034msec)
    clat (usec): min=20181, max=44303, avg=36903.07, stdev=139.02
     lat (usec): min=20183, max=44304, avg=36905.65, stdev=138.95
    clat percentiles (usec):
     |  1.00th=[36608],  5.00th=[36608], 10.00th=[36608], 20.00th=[37120],
     | 30.00th=[37120], 40.00th=[37120], 50.00th=[37120], 60.00th=[37120],
     | 70.00th=[37120], 80.00th=[37120], 90.00th=[37120], 95.00th=[37120],
     | 99.00th=[37120], 99.50th=[37120], 99.90th=[37120], 99.95th=[37120],
     | 99.99th=[38144]
   bw (  KiB/s): min=26624, max=29079, per=0.01%, avg=27866.93, stdev=1036.09
    lat (msec) : 50=100.00%
  cpu          : usr=0.10%, sys=1.02%, ctx=112243, majf=0, minf=2564
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=48741,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=271MiB/s (284MB/s), 271MiB/s-271MiB/s (284MB/s-284MB/s), io=47.6GiB (51.1GB), run=180034-180034msec

Disk stats (read/write):
  sda: ios=63286/0, merge=0/0, ticks=2289137/0, in_queue=2279921, util=100.00%
```

### 3G 固态FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1721: Tue Nov 24 15:33:54 2020
   read: IOPS=1445, BW=181MiB/s (189MB/s)(31.8GiB/180005msec)
    clat (usec): min=1108, max=31177, avg=1525.27, stdev=421.16
     lat (usec): min=1108, max=31179, avg=1527.61, stdev=421.16
    clat percentiles (usec):
     |  1.00th=[ 1320],  5.00th=[ 1352], 10.00th=[ 1368], 20.00th=[ 1384],
     | 30.00th=[ 1384], 40.00th=[ 1400], 50.00th=[ 1416], 60.00th=[ 1416],
     | 70.00th=[ 1448], 80.00th=[ 1816], 90.00th=[ 1896], 95.00th=[ 1928],
     | 99.00th=[ 2384], 99.50th=[ 3824], 99.90th=[ 4896], 99.95th=[ 5344],
     | 99.99th=[16320]
   bw (  KiB/s): min= 8464, max=31294, per=0.01%, avg=18547.76, stdev=3244.61
  write: IOPS=619, BW=77.4MiB/s (81.2MB/s)(13.6GiB/180005msec)
    clat (msec): min=4, max=47, avg=12.46, stdev= 3.57
     lat (msec): min=4, max=47, avg=12.50, stdev= 3.57
    clat percentiles (usec):
     |  1.00th=[ 6240],  5.00th=[ 7648], 10.00th=[ 8256], 20.00th=[ 9536],
     | 30.00th=[10432], 40.00th=[11328], 50.00th=[11968], 60.00th=[12864],
     | 70.00th=[13760], 80.00th=[15168], 90.00th=[17024], 95.00th=[18816],
     | 99.00th=[22912], 99.50th=[24448], 99.90th=[29568], 99.95th=[32128],
     | 99.99th=[38144]
   bw (  KiB/s): min= 6168, max= 9490, per=0.01%, avg=7944.42, stdev=491.15
    lat (msec) : 2=68.78%, 4=0.91%, 10=8.30%, 20=21.08%, 50=0.92%
  cpu          : usr=0.87%, sys=2.60%, ctx=635887, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=260174,111453,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=181MiB/s (189MB/s), 181MiB/s-181MiB/s (189MB/s-189MB/s), io=31.8GiB (34.1GB), run=180005-180005msec
  WRITE: bw=77.4MiB/s (81.2MB/s), 77.4MiB/s-77.4MiB/s (81.2MB/s-81.2MB/s), io=13.6GiB (14.6GB), run=180005-180005msec

Disk stats (read/write):
  sda: ios=259948/111345, merge=0/0, ticks=369841/1375732, in_queue=1725902, util=100.00%
```

### 3G 固态FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1764: Tue Nov 24 15:49:43 2020
  write: IOPS=187, BW=188MiB/s (197MB/s)(33.0GiB/180050msec)
    clat (msec): min=4, max=654, avg=52.85, stdev=18.20
     lat (msec): min=4, max=655, avg=53.17, stdev=18.20
    clat percentiles (msec):
     |  1.00th=[   48],  5.00th=[   50], 10.00th=[   50], 20.00th=[   50],
     | 30.00th=[   50], 40.00th=[   50], 50.00th=[   50], 60.00th=[   50],
     | 70.00th=[   50], 80.00th=[   57], 90.00th=[   57], 95.00th=[   58],
     | 99.00th=[   72], 99.50th=[  200], 99.90th=[  326], 99.95th=[  347],
     | 99.99th=[  652]
   bw (  KiB/s): min= 2052, max=27002, per=0.01%, avg=19407.14, stdev=2083.78
    lat (msec) : 10=0.07%, 20=0.01%, 50=70.37%, 100=28.93%, 250=0.41%
    lat (msec) : 500=0.18%, 750=0.03%
  cpu          : usr=1.04%, sys=2.36%, ctx=69291, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,33834,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=188MiB/s (197MB/s), 188MiB/s-188MiB/s (197MB/s-197MB/s), io=33.0GiB (35.5GB), run=180050-180050msec

Disk stats (read/write):
  sda: ios=1/40436, merge=0/244, ticks=1/204040, in_queue=192872, util=82.95%
```

### 3G 固态FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1797: Tue Nov 24 16:08:02 2020
   read: IOPS=270, BW=271MiB/s (284MB/s)(47.6GiB/180035msec)
    clat (usec): min=18046, max=57894, avg=36882.02, stdev=309.35
     lat (usec): min=18049, max=57897, avg=36884.77, stdev=309.32
    clat percentiles (usec):
     |  1.00th=[36608],  5.00th=[36608], 10.00th=[36608], 20.00th=[37120],
     | 30.00th=[37120], 40.00th=[37120], 50.00th=[37120], 60.00th=[37120],
     | 70.00th=[37120], 80.00th=[37120], 90.00th=[37120], 95.00th=[37120],
     | 99.00th=[37120], 99.50th=[37120], 99.90th=[37120], 99.95th=[37632],
     | 99.99th=[54016]
   bw (  KiB/s): min=26624, max=28787, per=0.01%, avg=27804.70, stdev=1022.87
    lat (msec) : 20=0.01%, 50=99.98%, 100=0.01%
  cpu          : usr=0.11%, sys=2.26%, ctx=49150, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=48769,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=271MiB/s (284MB/s), 271MiB/s-271MiB/s (284MB/s-284MB/s), io=47.6GiB (51.1GB), run=180035-180035msec

Disk stats (read/write):
  sda: ios=48745/8, merge=0/1, ticks=1771129/824, in_queue=1761614, util=100.00%
```

### 3G 固态FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1866: Tue Nov 24 16:39:27 2020
   read: IOPS=919, BW=115MiB/s (121MB/s)(20.2GiB/180009msec)
    clat (usec): min=936, max=47371, avg=7464.51, stdev=2302.38
     lat (usec): min=939, max=47374, avg=7467.06, stdev=2302.40
    clat percentiles (usec):
     |  1.00th=[ 3184],  5.00th=[ 4640], 10.00th=[ 5536], 20.00th=[ 6176],
     | 30.00th=[ 6624], 40.00th=[ 6944], 50.00th=[ 7264], 60.00th=[ 7648],
     | 70.00th=[ 7968], 80.00th=[ 8384], 90.00th=[ 9024], 95.00th=[10304],
     | 99.00th=[15936], 99.50th=[17024], 99.90th=[30848], 99.95th=[35072],
     | 99.99th=[42752]
   bw (  KiB/s): min= 7182, max=15421, per=0.01%, avg=11792.56, stdev=1079.07
  write: IOPS=394, BW=49.3MiB/s (51.7MB/s)(8879MiB/180009msec)
    clat (usec): min=683, max=46903, avg=7791.02, stdev=2291.15
     lat (usec): min=707, max=46939, avg=7828.04, stdev=2291.56
    clat percentiles (usec):
     |  1.00th=[ 5088],  5.00th=[ 5600], 10.00th=[ 6112], 20.00th=[ 6560],
     | 30.00th=[ 6944], 40.00th=[ 7200], 50.00th=[ 7520], 60.00th=[ 7712],
     | 70.00th=[ 8096], 80.00th=[ 8384], 90.00th=[ 9024], 95.00th=[11072],
     | 99.00th=[16064], 99.50th=[17280], 99.90th=[34048], 99.95th=[38656],
     | 99.99th=[44800]
   bw (  KiB/s): min= 1285, max= 8481, per=0.01%, avg=5057.83, stdev=949.29
    lat (usec) : 750=0.01%, 1000=0.05%
    lat (msec) : 2=0.07%, 4=1.30%, 10=93.07%, 20=5.20%, 50=0.32%
  cpu          : usr=0.78%, sys=4.42%, ctx=471975, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=165608,71031,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=115MiB/s (121MB/s), 115MiB/s-115MiB/s (121MB/s-121MB/s), io=20.2GiB (21.7GB), run=180009-180009msec
  WRITE: bw=49.3MiB/s (51.7MB/s), 49.3MiB/s-49.3MiB/s (51.7MB/s-51.7MB/s), io=8879MiB (9310MB), run=180009-180009msec

Disk stats (read/write):
  sda: ios=165541/74271, merge=0/76, ticks=307094/72751, in_queue=357032, util=78.18%
```

### 1.5G 固态FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1906: Tue Nov 24 16:58:14 2020
  write: IOPS=125, BW=126MiB/s (132MB/s)(22.1GiB/180072msec)
    clat (msec): min=23, max=553, avg=79.24, stdev=21.42
     lat (msec): min=23, max=553, avg=79.52, stdev=21.42
    clat percentiles (msec):
     |  1.00th=[   63],  5.00th=[   71], 10.00th=[   71], 20.00th=[   78],
     | 30.00th=[   78], 40.00th=[   79], 50.00th=[   79], 60.00th=[   79],
     | 70.00th=[   79], 80.00th=[   79], 90.00th=[   79], 95.00th=[   86],
     | 99.00th=[   98], 99.50th=[  258], 99.90th=[  359], 99.95th=[  367],
     | 99.99th=[  537]
   bw (  KiB/s): min= 2072, max=16616, per=0.01%, avg=12944.93, stdev=1602.08
    lat (msec) : 50=0.48%, 100=98.62%, 250=0.14%, 500=0.75%, 750=0.01%
  cpu          : usr=0.38%, sys=0.39%, ctx=23915, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,22630,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=126MiB/s (132MB/s), 126MiB/s-126MiB/s (132MB/s-132MB/s), io=22.1GiB (23.7GB), run=180072-180072msec

Disk stats (read/write):
  sda: ios=0/22629, merge=0/0, ticks=0/1785919, in_queue=1785792, util=100.00%
```

### 1.5G 固态FIO RAW读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1926: Tue Nov 24 17:02:55 2020
   read: IOPS=135, BW=136MiB/s (142MB/s)(23.8GiB/180069msec)
    clat (msec): min=22, max=287, avg=73.70, stdev= 8.79
     lat (msec): min=22, max=287, avg=73.70, stdev= 8.79
    clat percentiles (msec):
     |  1.00th=[   60],  5.00th=[   67], 10.00th=[   74], 20.00th=[   74],
     | 30.00th=[   74], 40.00th=[   74], 50.00th=[   74], 60.00th=[   74],
     | 70.00th=[   74], 80.00th=[   75], 90.00th=[   75], 95.00th=[   75],
     | 99.00th=[   82], 99.50th=[   82], 99.90th=[  260], 99.95th=[  273],
     | 99.99th=[  289]
   bw (  KiB/s): min= 6168, max=16616, per=0.01%, avg=13960.30, stdev=1047.08
    lat (msec) : 50=0.25%, 100=99.50%, 250=0.12%, 500=0.13%
  cpu          : usr=0.05%, sys=0.49%, ctx=48939, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=24419,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=136MiB/s (142MB/s), 136MiB/s-136MiB/s (142MB/s-142MB/s), io=23.8GiB (25.6GB), run=180069-180069msec

Disk stats (read/write):
  sda: ios=24385/0, merge=0/0, ticks=1787374/0, in_queue=1783850, util=100.00%
```

### 1.5G 固态FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1942: Tue Nov 24 17:07:04 2020
   read: IOPS=731, BW=91.5MiB/s (95.9MB/s)(16.1GiB/180010msec)
    clat (msec): min=2, max=52, avg= 8.33, stdev= 2.94
     lat (msec): min=2, max=52, avg= 8.33, stdev= 2.94
    clat percentiles (usec):
     |  1.00th=[ 4704],  5.00th=[ 5728], 10.00th=[ 6560], 20.00th=[ 7456],
     | 30.00th=[ 7520], 40.00th=[ 7584], 50.00th=[ 8384], 60.00th=[ 8512],
     | 70.00th=[ 8512], 80.00th=[ 8640], 90.00th=[ 9536], 95.00th=[10432],
     | 99.00th=[27520], 99.50th=[29568], 99.90th=[33024], 99.95th=[34048],
     | 99.99th=[42240]
   bw (  KiB/s): min= 3591, max=14592, per=0.01%, avg=9377.67, stdev=1486.42
  write: IOPS=314, BW=39.3MiB/s (41.2MB/s)(7069MiB/180010msec)
    clat (msec): min=1, max=55, avg=12.29, stdev= 4.42
     lat (msec): min=1, max=55, avg=12.33, stdev= 4.42
    clat percentiles (usec):
     |  1.00th=[ 5600],  5.00th=[ 8384], 10.00th=[ 8512], 20.00th=[ 9408],
     | 30.00th=[ 9664], 40.00th=[10432], 50.00th=[11328], 60.00th=[12224],
     | 70.00th=[13120], 80.00th=[14272], 90.00th=[17024], 95.00th=[19840],
     | 99.00th=[31360], 99.50th=[34048], 99.90th=[39680], 99.95th=[42752],
     | 99.99th=[48384]
   bw (  KiB/s): min= 1282, max= 7182, per=0.01%, avg=4024.96, stdev=830.57
    lat (msec) : 2=0.04%, 4=0.36%, 10=74.25%, 20=22.65%, 50=2.70%
    lat (msec) : 100=0.01%
  cpu          : usr=0.43%, sys=1.28%, ctx=322893, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=131754,56549,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=91.5MiB/s (95.9MB/s), 91.5MiB/s-91.5MiB/s (95.9MB/s-95.9MB/s), io=16.1GiB (17.3GB), run=180010-180010msec
  WRITE: bw=39.3MiB/s (41.2MB/s), 39.3MiB/s-39.3MiB/s (41.2MB/s-41.2MB/s), io=7069MiB (7412MB), run=180010-180010msec

Disk stats (read/write):
  sda: ios=131642/56496, merge=0/0, ticks=1080048/687574, in_queue=1757585, util=100.00%
```

### 1.5G 固态FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1993: Tue Nov 24 17:26:43 2020
  write: IOPS=104, BW=104MiB/s (110MB/s)(18.4GiB/180081msec)
    clat (msec): min=8, max=492, avg=95.33, stdev=19.82
     lat (msec): min=8, max=492, avg=95.66, stdev=19.82
    clat percentiles (msec):
     |  1.00th=[   88],  5.00th=[   90], 10.00th=[   90], 20.00th=[   90],
     | 30.00th=[   90], 40.00th=[   90], 50.00th=[   90], 60.00th=[   90],
     | 70.00th=[  103], 80.00th=[  104], 90.00th=[  104], 95.00th=[  104],
     | 99.00th=[  119], 99.50th=[  124], 99.90th=[  445], 99.95th=[  478],
     | 99.99th=[  494]
   bw (  KiB/s): min= 4104, max=14539, per=0.01%, avg=10772.55, stdev=1206.94
    lat (msec) : 10=0.06%, 50=0.03%, 100=68.38%, 250=31.16%, 500=0.37%
  cpu          : usr=0.59%, sys=1.39%, ctx=38861, majf=0, minf=2
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,18815,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=104MiB/s (110MB/s), 104MiB/s-104MiB/s (110MB/s-110MB/s), io=18.4GiB (19.7GB), run=180081-180081msec

Disk stats (read/write):
  sda: ios=1/21167, merge=0/221, ticks=12/204862, in_queue=199912, util=90.91%
```

### 1.5G 固态FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=2024: Tue Nov 24 17:46:28 2020
   read: IOPS=135, BW=136MiB/s (142MB/s)(23.8GiB/180067msec)
    clat (msec): min=21, max=294, avg=73.70, stdev=14.09
     lat (msec): min=21, max=294, avg=73.70, stdev=14.09
    clat percentiles (msec):
     |  1.00th=[   60],  5.00th=[   67], 10.00th=[   67], 20.00th=[   74],
     | 30.00th=[   74], 40.00th=[   74], 50.00th=[   74], 60.00th=[   74],
     | 70.00th=[   74], 80.00th=[   75], 90.00th=[   75], 95.00th=[   75],
     | 99.00th=[   82], 99.50th=[  237], 99.90th=[  260], 99.95th=[  273],
     | 99.99th=[  273]
   bw (  KiB/s): min= 6168, max=18468, per=0.01%, avg=13981.93, stdev=1298.81
    lat (msec) : 50=0.38%, 100=98.94%, 250=0.34%, 500=0.34%
  cpu          : usr=0.05%, sys=1.15%, ctx=24777, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=24418,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=136MiB/s (142MB/s), 136MiB/s-136MiB/s (142MB/s-142MB/s), io=23.8GiB (25.6GB), run=180067-180067msec

Disk stats (read/write):
  sda: ios=24401/12, merge=0/1, ticks=1784470/1085, in_queue=1781073, util=100.00%
```

### 1.5G 固态FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=2249: Tue Nov 24 21:04:13 2020
   read: IOPS=549, BW=68.7MiB/s (72.1MB/s)(12.1GiB/180028msec)
    clat (msec): min=2, max=58, avg=12.57, stdev= 3.81
     lat (msec): min=2, max=58, avg=12.58, stdev= 3.81
    clat percentiles (usec):
     |  1.00th=[ 5536],  5.00th=[ 8512], 10.00th=[ 9920], 20.00th=[10816],
     | 30.00th=[11328], 40.00th=[11840], 50.00th=[12096], 60.00th=[12480],
     | 70.00th=[12864], 80.00th=[13376], 90.00th=[14272], 95.00th=[17280],
     | 99.00th=[28800], 99.50th=[29824], 99.90th=[41728], 99.95th=[43776],
     | 99.99th=[55552]
   bw (  KiB/s): min= 3855, max= 9767, per=0.01%, avg=7054.99, stdev=797.76
  write: IOPS=234, BW=29.4MiB/s (30.8MB/s)(5287MiB/180028msec)
    clat (msec): min=1, max=56, avg=12.99, stdev= 3.72
     lat (msec): min=1, max=56, avg=13.03, stdev= 3.72
    clat percentiles (usec):
     |  1.00th=[ 9792],  5.00th=[10432], 10.00th=[10816], 20.00th=[11328],
     | 30.00th=[11712], 40.00th=[11968], 50.00th=[12352], 60.00th=[12480],
     | 70.00th=[12864], 80.00th=[13376], 90.00th=[14016], 95.00th=[18304],
     | 99.00th=[28800], 99.50th=[29568], 99.90th=[42240], 99.95th=[43264],
     | 99.99th=[55040]
   bw (  KiB/s): min=  769, max= 5654, per=0.01%, avg=3014.60, stdev=724.07
    lat (msec) : 2=0.04%, 4=0.07%, 10=8.38%, 20=87.10%, 50=4.39%
    lat (msec) : 100=0.02%
  cpu          : usr=0.40%, sys=2.71%, ctx=282229, majf=0, minf=2
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=98969,42292,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=68.7MiB/s (72.1MB/s), 68.7MiB/s-68.7MiB/s (72.1MB/s-72.1MB/s), io=12.1GiB (12.0GB), run=180028-180028msec
  WRITE: bw=29.4MiB/s (30.8MB/s), 29.4MiB/s-29.4MiB/s (30.8MB/s-30.8MB/s), io=5287MiB (5543MB), run=180028-180028msec

Disk stats (read/write):
  sda: ios=98936/44649, merge=0/74, ticks=336017/83716, in_queue=410934, util=88.31%
```

### 6G 机械FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1685: Tue Nov 24 15:24:39 2020
  write: IOPS=226, BW=227MiB/s (238MB/s)(39.8GiB/180037msec)
    clat (msec): min=7, max=6827, avg=43.82, stdev=120.95
     lat (msec): min=8, max=6827, avg=44.11, stdev=120.95
    clat percentiles (msec):
     |  1.00th=[   21],  5.00th=[   21], 10.00th=[   21], 20.00th=[   21],
     | 30.00th=[   39], 40.00th=[   39], 50.00th=[   39], 60.00th=[   40],
     | 70.00th=[   40], 80.00th=[   40], 90.00th=[   56], 95.00th=[   79],
     | 99.00th=[  176], 99.50th=[  243], 99.90th=[ 1057], 99.95th=[ 1582],
     | 99.99th=[ 6849]
   bw (  KiB/s): min= 2048, max=41541, per=0.01%, avg=24787.27, stdev=6090.58
    lat (msec) : 10=0.01%, 20=0.29%, 50=89.51%, 100=6.26%, 250=3.45%
    lat (msec) : 500=0.27%, 750=0.05%, 1000=0.03%, 2000=0.12%, >=2000=0.03%
  cpu          : usr=0.72%, sys=0.95%, ctx=42976, majf=0, minf=2
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,40780,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=227MiB/s (238MB/s), 227MiB/s-227MiB/s (238MB/s-238MB/s), io=39.8GiB (42.8GB), run=180037-180037msec

Disk stats (read/write):
  sda: ios=0/52941, merge=0/0, ticks=0/2293956, in_queue=2293911, util=100.00%
```

### 6G 机械FIO RAW读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1770: Tue Nov 24 15:42:48 2020
   read: IOPS=430, BW=431MiB/s (451MB/s)(75.7GiB/180019msec)
    clat (msec): min=2, max=64, avg=23.19, stdev= 6.02
     lat (msec): min=2, max=64, avg=23.20, stdev= 6.02
    clat percentiles (usec):
     |  1.00th=[11456],  5.00th=[18816], 10.00th=[19072], 20.00th=[19072],
     | 30.00th=[19072], 40.00th=[19072], 50.00th=[19328], 60.00th=[23680],
     | 70.00th=[26240], 80.00th=[30080], 90.00th=[31104], 95.00th=[31872],
     | 99.00th=[41216], 99.50th=[44288], 99.90th=[51968], 99.95th=[55040],
     | 99.99th=[60672]
   bw (  KiB/s): min=32768, max=56195, per=0.01%, avg=44230.76, stdev=4049.64
    lat (msec) : 4=0.01%, 10=0.03%, 20=56.78%, 50=43.03%, 100=0.15%
  cpu          : usr=0.15%, sys=1.30%, ctx=162770, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=77513,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=431MiB/s (451MB/s), 431MiB/s-431MiB/s (451MB/s-451MB/s), io=75.7GiB (81.3GB), run=180019-180019msec

Disk stats (read/write):
  sda: ios=85192/0, merge=0/0, ticks=1943514/0, in_queue=1930157, util=99.68%
```

### 6G 机械FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1803: Tue Nov 24 15:58:47 2020
   read: IOPS=154, BW=19.3MiB/s (20.2MB/s)(3467MiB/180082msec)
    clat (msec): min=4, max=751, avg=63.50, stdev=66.70
     lat (msec): min=4, max=751, avg=63.51, stdev=66.70
    clat percentiles (msec):
     |  1.00th=[    8],  5.00th=[   10], 10.00th=[   13], 20.00th=[   18],
     | 30.00th=[   24], 40.00th=[   31], 50.00th=[   41], 60.00th=[   53],
     | 70.00th=[   71], 80.00th=[   96], 90.00th=[  147], 95.00th=[  198],
     | 99.00th=[  322], 99.50th=[  375], 99.90th=[  529], 99.95th=[  611],
     | 99.99th=[  709]
   bw (  KiB/s): min=  256, max= 5130, per=0.01%, avg=1981.30, stdev=721.91
  write: IOPS=65, BW=8366KiB/s (8567kB/s)(1471MiB/180082msec)
    clat (usec): min=405, max=452016, avg=3178.54, stdev=4599.31
     lat (usec): min=420, max=452043, avg=3212.31, stdev=4599.72
    clat percentiles (usec):
     |  1.00th=[  588],  5.00th=[  604], 10.00th=[  660], 20.00th=[  964],
     | 30.00th=[ 1004], 40.00th=[ 2416], 50.00th=[ 3696], 60.00th=[ 4128],
     | 70.00th=[ 4576], 80.00th=[ 4960], 90.00th=[ 5472], 95.00th=[ 5984],
     | 99.00th=[ 7328], 99.50th=[ 8512], 99.90th=[11968], 99.95th=[12096],
     | 99.99th=[12992]
   bw (  KiB/s): min=  256, max= 4360, per=0.01%, avg=931.25, stdev=584.42
    lat (usec) : 500=0.01%, 750=3.36%, 1000=5.39%
    lat (msec) : 2=2.90%, 4=5.19%, 10=17.52%, 20=12.70%, 50=23.22%
    lat (msec) : 100=16.37%, 250=11.60%, 500=1.63%, 750=0.10%, 1000=0.01%
  cpu          : usr=0.09%, sys=0.29%, ctx=66008, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=27736,11770,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=19.3MiB/s (20.2MB/s), 19.3MiB/s-19.3MiB/s (20.2MB/s-20.2MB/s), io=3467MiB (3635MB), run=180082-180082msec
  WRITE: bw=8366KiB/s (8567kB/s), 8366KiB/s-8366KiB/s (8567kB/s-8567kB/s), io=1471MiB (1543MB), run=180082-180082msec

Disk stats (read/write):
  sda: ios=27707/11763, merge=0/0, ticks=1755482/36079, in_queue=1761213, util=98.44%
```

### 6G 机械FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1840: Tue Nov 24 16:08:16 2020
  write: IOPS=179, BW=179MiB/s (188MB/s)(31.5GiB/180064msec)
    clat (msec): min=3, max=189, avg=55.47, stdev=17.47
     lat (msec): min=3, max=189, avg=55.77, stdev=17.47
    clat percentiles (msec):
     |  1.00th=[   31],  5.00th=[   32], 10.00th=[   32], 20.00th=[   45],
     | 30.00th=[   47], 40.00th=[   50], 50.00th=[   55], 60.00th=[   56],
     | 70.00th=[   61], 80.00th=[   67], 90.00th=[   77], 95.00th=[   85],
     | 99.00th=[  119], 99.50th=[  130], 99.90th=[  155], 99.95th=[  163],
     | 99.99th=[  178]
   bw (  KiB/s): min=10240, max=26947, per=0.01%, avg=18461.36, stdev=2820.78
    lat (msec) : 4=0.04%, 20=0.02%, 50=40.76%, 100=56.69%, 250=2.49%
  cpu          : usr=0.50%, sys=2.80%, ctx=65524, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,32261,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=179MiB/s (188MB/s), 179MiB/s-179MiB/s (188MB/s-188MB/s), io=31.5GiB (33.8GB), run=180064-180064msec

Disk stats (read/write):
  sda: ios=1/38549, merge=0/243, ticks=11/196614, in_queue=189871, util=87.77%
```

### 6G 机械FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1858: Tue Nov 24 16:12:50 2020
   read: IOPS=441, BW=442MiB/s (463MB/s)(77.7GiB/180024msec)
    clat (msec): min=2, max=120, avg=22.60, stdev= 7.44
     lat (msec): min=2, max=120, avg=22.60, stdev= 7.44
    clat percentiles (msec):
     |  1.00th=[   15],  5.00th=[   20], 10.00th=[   20], 20.00th=[   20],
     | 30.00th=[   20], 40.00th=[   20], 50.00th=[   20], 60.00th=[   20],
     | 70.00th=[   21], 80.00th=[   25], 90.00th=[   32], 95.00th=[   40],
     | 99.00th=[   49], 99.50th=[   55], 99.90th=[   76], 99.95th=[   82],
     | 99.99th=[  103]
   bw (  KiB/s): min=28729, max=53461, per=0.01%, avg=45371.18, stdev=4391.10
    lat (msec) : 4=0.02%, 10=0.21%, 20=66.16%, 50=32.86%, 100=0.74%
    lat (msec) : 250=0.01%
  cpu          : usr=0.17%, sys=3.64%, ctx=80690, majf=2, minf=2568
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=79560,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=442MiB/s (463MB/s), 442MiB/s-442MiB/s (463MB/s-463MB/s), io=77.7GiB (83.4GB), run=180024-180024msec

Disk stats (read/write):
  sda: ios=87461/2861, merge=0/42, ticks=1921401/67756, in_queue=1956591, util=99.36%
```

### 6G 机械FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1883: Tue Nov 24 16:20:06 2020
   read: IOPS=89, BW=11.2MiB/s (11.7MB/s)(2008MiB/180056msec)
    clat (msec): min=4, max=308, avg=79.74, stdev=38.98
     lat (msec): min=4, max=308, avg=79.75, stdev=38.98
    clat percentiles (msec):
     |  1.00th=[   14],  5.00th=[   30], 10.00th=[   41], 20.00th=[   51],
     | 30.00th=[   59], 40.00th=[   67], 50.00th=[   73], 60.00th=[   81],
     | 70.00th=[   89], 80.00th=[  102], 90.00th=[  130], 95.00th=[  163],
     | 99.00th=[  210], 99.50th=[  227], 99.90th=[  258], 99.95th=[  269],
     | 99.99th=[  297]
   bw (  KiB/s): min=  256, max= 2313, per=0.01%, avg=1146.01, stdev=357.97
  write: IOPS=37, BW=4850KiB/s (4967kB/s)(853MiB/180056msec)
    clat (usec): min=656, max=307631, avg=75962.42, stdev=32347.37
     lat (usec): min=691, max=307652, avg=75999.63, stdev=32347.41
    clat percentiles (msec):
     |  1.00th=[   32],  5.00th=[   43], 10.00th=[   48], 20.00th=[   55],
     | 30.00th=[   60], 40.00th=[   64], 50.00th=[   70], 60.00th=[   75],
     | 70.00th=[   81], 80.00th=[   89], 90.00th=[  111], 95.00th=[  151],
     | 99.00th=[  198], 99.50th=[  217], 99.90th=[  245], 99.95th=[  249],
     | 99.99th=[  310]
   bw (  KiB/s): min=  256, max= 1542, per=0.01%, avg=552.43, stdev=264.13
    lat (usec) : 750=0.04%, 1000=0.01%
    lat (msec) : 10=0.38%, 20=1.22%, 50=15.49%, 100=64.23%, 250=18.50%
    lat (msec) : 500=0.12%
  cpu          : usr=0.07%, sys=0.45%, ctx=46120, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=16063,6823,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=11.2MiB/s (11.7MB/s), 11.2MiB/s-11.2MiB/s (11.7MB/s-11.7MB/s), io=2008MiB (2105MB), run=180056-180056msec
  WRITE: bw=4850KiB/s (4967kB/s), 4850KiB/s-4850KiB/s (4967kB/s-4967kB/s), io=853MiB (894MB), run=180056-180056msec

Disk stats (read/write):
  sda: ios=16046/9823, merge=0/76, ticks=458841/35050, in_queue=464929, util=93.20%
```

### 3G 机械FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1913: Tue Nov 24 16:33:27 2020
  write: IOPS=184, BW=184MiB/s (193MB/s)(32.4GiB/180036msec)
    clat (msec): min=4, max=470, avg=53.89, stdev=11.89
     lat (msec): min=5, max=470, avg=54.17, stdev=11.89
    clat percentiles (msec):
     |  1.00th=[   39],  5.00th=[   44], 10.00th=[   45], 20.00th=[   45],
     | 30.00th=[   46], 40.00th=[   47], 50.00th=[   55], 60.00th=[   57],
     | 70.00th=[   60], 80.00th=[   64], 90.00th=[   67], 95.00th=[   74],
     | 99.00th=[   75], 99.50th=[   75], 99.90th=[   86], 99.95th=[  104],
     | 99.99th=[  469]
   bw (  KiB/s): min= 4096, max=20770, per=0.01%, avg=18986.94, stdev=1492.77
    lat (msec) : 10=0.01%, 20=0.01%, 50=46.60%, 100=53.33%, 250=0.02%
    lat (msec) : 500=0.03%
  cpu          : usr=0.57%, sys=0.57%, ctx=37035, majf=0, minf=3
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,33204,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=184MiB/s (193MB/s), 184MiB/s-184MiB/s (193MB/s-193MB/s), io=32.4GiB (34.8GB), run=180036-180036msec

Disk stats (read/write):
  sda: ios=0/33205, merge=0/895, ticks=0/1777898, in_queue=1746829, util=98.40%
```

### 3G 机械FIO RAW读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1843: Sat Nov 14 02:12:49 2020
   read: IOPS=262, BW=263MiB/s (276MB/s)(46.2GiB/180036msec)
    clat (msec): min=9, max=79, avg=38.01, stdev= 3.31
     lat (msec): min=9, max=79, avg=38.02, stdev= 3.31
    clat percentiles (usec):
     |  1.00th=[36608],  5.00th=[36608], 10.00th=[36608], 20.00th=[36608],
     | 30.00th=[36608], 40.00th=[37120], 50.00th=[37120], 60.00th=[37120],
     | 70.00th=[37120], 80.00th=[37120], 90.00th=[43264], 95.00th=[46848],
     | 99.00th=[47872], 99.50th=[48384], 99.90th=[62720], 99.95th=[70144],
     | 99.99th=[77312]
   bw (  KiB/s): min=20480, max=29079, per=0.01%, avg=27047.76, stdev=1790.16
    lat (msec) : 10=0.01%, 20=0.06%, 50=99.71%, 100=0.22%
  cpu          : usr=0.09%, sys=0.76%, ctx=99482, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=47316,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=263MiB/s (276MB/s), 263MiB/s-263MiB/s (276MB/s-276MB/s), io=46.2GiB (49.6GB), run=180036-180036msec

Disk stats (read/write):
  sda: ios=51994/0, merge=0/0, ticks=1951402/0, in_queue=1948913, util=100.00%
```

### 3G 机械FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1864: Sat Nov 14 02:19:47 2020
   read: IOPS=154, BW=19.3MiB/s (20.3MB/s)(3486MiB/180168msec)
    clat (msec): min=4, max=862, avg=63.07, stdev=64.99
     lat (msec): min=4, max=862, avg=63.08, stdev=64.99
    clat percentiles (msec):
     |  1.00th=[    8],  5.00th=[   10], 10.00th=[   13], 20.00th=[   18],
     | 30.00th=[   24], 40.00th=[   32], 50.00th=[   41], 60.00th=[   53],
     | 70.00th=[   70], 80.00th=[   95], 90.00th=[  143], 95.00th=[  194],
     | 99.00th=[  318], 99.50th=[  371], 99.90th=[  498], 99.95th=[  545],
     | 99.99th=[  619]
   bw (  KiB/s): min=  256, max= 4626, per=0.01%, avg=1991.20, stdev=714.46
  write: IOPS=65, BW=8400KiB/s (8601kB/s)(1478MiB/180168msec)
    clat (usec): min=626, max=13245, avg=3373.21, stdev=2033.05
     lat (usec): min=638, max=13266, avg=3408.54, stdev=2034.17
    clat percentiles (usec):
     |  1.00th=[  836],  5.00th=[  852], 10.00th=[  884], 20.00th=[ 1176],
     | 30.00th=[ 1224], 40.00th=[ 2736], 50.00th=[ 3952], 60.00th=[ 4384],
     | 70.00th=[ 4768], 80.00th=[ 5152], 90.00th=[ 5728], 95.00th=[ 6240],
     | 99.00th=[ 7968], 99.50th=[ 8896], 99.90th=[12096], 99.95th=[12480],
     | 99.99th=[13248]
   bw (  KiB/s): min=  256, max= 4369, per=0.01%, avg=929.73, stdev=579.06
    lat (usec) : 750=0.03%, 1000=4.45%
    lat (msec) : 2=7.00%, 4=3.64%, 10=18.32%, 20=12.96%, 50=24.15%
    lat (msec) : 100=16.50%, 250=11.29%, 500=1.60%, 750=0.06%, 1000=0.01%
  cpu          : usr=0.10%, sys=0.27%, ctx=68262, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=27889,11823,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=19.3MiB/s (20.3MB/s), 19.3MiB/s-19.3MiB/s (20.3MB/s-20.3MB/s), io=3486MiB (3655MB), run=180168-180168msec
  WRITE: bw=8400KiB/s (8601kB/s), 8400KiB/s-8400KiB/s (8601kB/s-8601kB/s), io=1478MiB (1550MB), run=180168-180168msec

Disk stats (read/write):
  sda: ios=27886/11823, merge=0/0, ticks=1754898/38561, in_queue=1792906, util=100.00%
```

### 3G 机械FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1945: Tue Nov 24 16:40:06 2020
  write: IOPS=136, BW=136MiB/s (143MB/s)(23.0GiB/180105msec)
    clat (msec): min=4, max=242, avg=73.01, stdev=16.29
     lat (msec): min=4, max=242, avg=73.31, stdev=16.29
    clat percentiles (msec):
     |  1.00th=[   50],  5.00th=[   58], 10.00th=[   63], 20.00th=[   63],
     | 30.00th=[   64], 40.00th=[   64], 50.00th=[   70], 60.00th=[   72],
     | 70.00th=[   75], 80.00th=[   82], 90.00th=[   94], 95.00th=[  101],
     | 99.00th=[  135], 99.50th=[  157], 99.90th=[  188], 99.95th=[  194],
     | 99.99th=[  235]
   bw (  KiB/s): min= 8192, max=18580, per=0.01%, avg=14107.55, stdev=1484.39
    lat (msec) : 10=0.04%, 20=0.02%, 50=1.72%, 100=93.07%, 250=5.15%
  cpu          : usr=0.50%, sys=2.03%, ctx=50021, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,24546,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=136MiB/s (143MB/s), 136MiB/s-136MiB/s (143MB/s-143MB/s), io=23.0GiB (25.7GB), run=180105-180105msec

Disk stats (read/write):
  sda: ios=1/29607, merge=0/236, ticks=9/216452, in_queue=205944, util=88.47%
```

### 3G 机械FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1984: Tue Nov 24 16:55:43 2020
   read: IOPS=250, BW=250MiB/s (262MB/s)(43.0GiB/180035msec)
    clat (msec): min=7, max=119, avg=39.94, stdev= 8.79
     lat (msec): min=7, max=119, avg=39.94, stdev= 8.79
    clat percentiles (msec):
     |  1.00th=[   19],  5.00th=[   34], 10.00th=[   37], 20.00th=[   37],
     | 30.00th=[   37], 40.00th=[   37], 50.00th=[   37], 60.00th=[   38],
     | 70.00th=[   38], 80.00th=[   45], 90.00th=[   49], 95.00th=[   57],
     | 99.00th=[   76], 99.50th=[   81], 99.90th=[   98], 99.95th=[  105],
     | 99.99th=[  120]
   bw (  KiB/s): min=18432, max=30781, per=0.01%, avg=25692.11, stdev=1972.95
    lat (msec) : 10=0.02%, 20=1.36%, 50=89.64%, 100=8.90%, 250=0.07%
  cpu          : usr=0.10%, sys=2.10%, ctx=45599, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=45037,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=250MiB/s (262MB/s), 250MiB/s-250MiB/s (262MB/s-262MB/s), io=43.0GiB (47.2GB), run=180035-180035msec

Disk stats (read/write):
  sda: ios=44989/2325, merge=0/40, ticks=1771943/96460, in_queue=1834482, util=99.18%
```

### 3G 机械FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1821: Sat Nov 14 02:04:53 2020
   read: IOPS=97, BW=12.1MiB/s (12.7MB/s)(2187MiB/180115msec)
    clat (msec): min=5, max=227, avg=72.72, stdev=27.60
     lat (msec): min=5, max=227, avg=72.72, stdev=27.60
    clat percentiles (msec):
     |  1.00th=[   15],  5.00th=[   31], 10.00th=[   41], 20.00th=[   51],
     | 30.00th=[   59], 40.00th=[   65], 50.00th=[   72], 60.00th=[   79],
     | 70.00th=[   85], 80.00th=[   93], 90.00th=[  106], 95.00th=[  120],
     | 99.00th=[  155], 99.50th=[  174], 99.90th=[  198], 99.95th=[  206],
     | 99.99th=[  223]
   bw (  KiB/s): min=  256, max= 2313, per=0.01%, avg=1247.62, stdev=352.57
  write: IOPS=41, BW=5319KiB/s (5447kB/s)(936MiB/180115msec)
    clat (usec): min=817, max=197771, avg=70451.12, stdev=20182.61
     lat (usec): min=842, max=197809, avg=70490.22, stdev=20182.64
    clat percentiles (msec):
     |  1.00th=[   35],  5.00th=[   43], 10.00th=[   48], 20.00th=[   55],
     | 30.00th=[   60], 40.00th=[   65], 50.00th=[   70], 60.00th=[   74],
     | 70.00th=[   79], 80.00th=[   85], 90.00th=[   94], 95.00th=[  102],
     | 99.00th=[  143], 99.50th=[  159], 99.90th=[  180], 99.95th=[  184],
     | 99.99th=[  198]
   bw (  KiB/s): min=  256, max= 1799, per=0.01%, avg=583.17, stdev=285.13
    lat (usec) : 1000=0.03%
    lat (msec) : 2=0.02%, 10=0.36%, 20=1.10%, 50=16.03%, 100=70.92%
    lat (msec) : 250=11.55%
  cpu          : usr=0.09%, sys=0.47%, ctx=50401, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=17494,7485,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=12.1MiB/s (12.7MB/s), 12.1MiB/s-12.1MiB/s (12.7MB/s-12.7MB/s), io=2187MiB (2293MB), run=180115-180115msec
  WRITE: bw=5319KiB/s (5447kB/s), 5319KiB/s-5319KiB/s (5447kB/s-5447kB/s), io=936MiB (981MB), run=180115-180115msec

Disk stats (read/write):
  sda: ios=17490/7557, merge=0/36, ticks=433099/10178, in_queue=436335, util=97.52%
```

### 1.5G 机械FIO RAW写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=1954: Sat Nov 14 02:52:00 2020
  write: IOPS=112, BW=112MiB/s (118MB/s)(19.7GiB/180085msec)
    clat (msec): min=8, max=412, avg=88.71, stdev=11.99
     lat (msec): min=8, max=412, avg=89.01, stdev=11.99
    clat percentiles (msec):
     |  1.00th=[   77],  5.00th=[   78], 10.00th=[   78], 20.00th=[   78],
     | 30.00th=[   87], 40.00th=[   88], 50.00th=[   90], 60.00th=[   91],
     | 70.00th=[   92], 80.00th=[   95], 90.00th=[  100], 95.00th=[  106],
     | 99.00th=[  115], 99.50th=[  133], 99.90th=[  206], 99.95th=[  215],
     | 99.99th=[  396]
   bw (  KiB/s): min= 6156, max=14422, per=0.01%, avg=11580.72, stdev=1067.37
    lat (msec) : 10=0.01%, 20=0.01%, 50=0.05%, 100=92.78%, 250=7.11%
    lat (msec) : 500=0.05%
  cpu          : usr=0.36%, sys=0.36%, ctx=24231, majf=0, minf=2
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,20214,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=112MiB/s (118MB/s), 112MiB/s-112MiB/s (118MB/s-118MB/s), io=19.7GiB (21.2GB), run=180085-180085msec

Disk stats (read/write):
  sda: ios=0/20284, merge=0/747, ticks=0/1788377, in_queue=1783124, util=99.91%
```

### 1.5G 机械FIO RAW读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=1973: Sat Nov 14 02:57:32 2020
   read: IOPS=135, BW=136MiB/s (143MB/s)(23.9GiB/180067msec)
    clat (usec): min=22151, max=132908, avg=73528.77, stdev=763.20
     lat (usec): min=22154, max=132909, avg=73531.63, stdev=763.17
    clat percentiles (usec):
     |  1.00th=[73216],  5.00th=[73216], 10.00th=[73216], 20.00th=[73216],
     | 30.00th=[73216], 40.00th=[73216], 50.00th=[73216], 60.00th=[73216],
     | 70.00th=[73216], 80.00th=[73216], 90.00th=[73216], 95.00th=[73216],
     | 99.00th=[73216], 99.50th=[73216], 99.90th=[74240], 99.95th=[74240],
     | 99.99th=[96768]
   bw (  KiB/s): min=12312, max=14451, per=0.01%, avg=13991.68, stdev=831.22
    lat (msec) : 50=0.02%, 100=99.98%, 250=0.01%
  cpu          : usr=0.05%, sys=0.43%, ctx=49106, majf=0, minf=2560
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=24473,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=136MiB/s (143MB/s), 136MiB/s-136MiB/s (143MB/s-143MB/s), io=23.9GiB (25.7GB), run=180067-180067msec

Disk stats (read/write):
  sda: ios=24444/10, merge=0/0, ticks=1788949/42, in_queue=1788252, util=100.00%
```

### 1.5G 机械FIO RAW读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=1991: Sat Nov 14 03:02:31 2020
   read: IOPS=153, BW=19.2MiB/s (20.1MB/s)(3454MiB/180115msec)
    clat (msec): min=5, max=939, avg=63.43, stdev=63.35
     lat (msec): min=5, max=939, avg=63.44, stdev=63.35
    clat percentiles (msec):
     |  1.00th=[   10],  5.00th=[   13], 10.00th=[   15], 20.00th=[   20],
     | 30.00th=[   26], 40.00th=[   33], 50.00th=[   42], 60.00th=[   54],
     | 70.00th=[   70], 80.00th=[   95], 90.00th=[  141], 95.00th=[  188],
     | 99.00th=[  306], 99.50th=[  363], 99.90th=[  510], 99.95th=[  562],
     | 99.99th=[  758]
   bw (  KiB/s): min=  256, max= 4360, per=0.01%, avg=1970.27, stdev=665.76
  write: IOPS=65, BW=8323KiB/s (8523kB/s)(1464MiB/180115msec)
    clat (msec): min=1, max=13, avg= 3.89, stdev= 2.04
     lat (msec): min=1, max=13, avg= 3.92, stdev= 2.04
    clat percentiles (usec):
     |  1.00th=[ 1352],  5.00th=[ 1368], 10.00th=[ 1400], 20.00th=[ 1448],
     | 30.00th=[ 1880], 40.00th=[ 3440], 50.00th=[ 4448], 60.00th=[ 4896],
     | 70.00th=[ 5280], 80.00th=[ 5664], 90.00th=[ 6176], 95.00th=[ 6816],
     | 99.00th=[ 8640], 99.50th=[ 9408], 99.90th=[11840], 99.95th=[12736],
     | 99.99th=[12992]
   bw (  KiB/s): min=  256, max= 3598, per=0.01%, avg=924.03, stdev=563.43
    lat (msec) : 2=10.35%, 4=2.91%, 10=17.53%, 20=13.25%, 50=25.97%
    lat (msec) : 100=17.03%, 250=11.43%, 500=1.45%, 750=0.07%, 1000=0.01%
  cpu          : usr=0.09%, sys=0.28%, ctx=67701, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=27634,11712,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=19.2MiB/s (20.1MB/s), 19.2MiB/s-19.2MiB/s (20.1MB/s-20.1MB/s), io=3454MiB (3622MB), run=180115-180115msec
  WRITE: bw=8323KiB/s (8523kB/s), 8323KiB/s-8323KiB/s (8523kB/s-8523kB/s), io=1464MiB (1535MB), run=180115-180115msec

Disk stats (read/write):
  sda: ios=27633/11722, merge=0/0, ticks=1749080/43881, in_queue=1791393, util=100.00%
```

### 1.5G 机械FIO EXT4写

```
seq_100write_1024k: (groupid=0, jobs=10): err= 0: pid=2019: Sat Nov 14 03:10:51 2020
  write: IOPS=86, BW=86.0MiB/s (91.2MB/s)(15.3GiB/180155msec)
    clat (msec): min=8, max=245, avg=114.59, stdev=16.52
     lat (msec): min=9, max=245, avg=114.92, stdev=16.52
    clat percentiles (msec):
     |  1.00th=[   89],  5.00th=[   95], 10.00th=[  103], 20.00th=[  105],
     | 30.00th=[  106], 40.00th=[  111], 50.00th=[  114], 60.00th=[  115],
     | 70.00th=[  116], 80.00th=[  122], 90.00th=[  131], 95.00th=[  139],
     | 99.00th=[  190], 99.50th=[  198], 99.90th=[  225], 99.95th=[  231],
     | 99.99th=[  245]
   bw (  KiB/s): min= 6144, max=12487, per=0.01%, avg=8981.66, stdev=1120.68
    lat (msec) : 10=0.03%, 20=0.02%, 50=0.01%, 100=7.19%, 250=92.75%
  cpu          : usr=0.34%, sys=1.31%, ctx=32281, majf=0, minf=0
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,15666,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
  WRITE: bw=86.0MiB/s (91.2MB/s), 86.0MiB/s-86.0MiB/s (91.2MB/s-91.2MB/s), io=15.3GiB (16.4GB), run=180155-180155msec

Disk stats (read/write):
  sda: ios=1/19046, merge=0/214, ticks=0/217398, in_queue=211239, util=93.40%
```

### 1.5G 机械FIO EXT4读

```
seq_100read_1024k: (groupid=0, jobs=10): err= 0: pid=2042: Sat Nov 14 03:18:10 2020
   read: IOPS=131, BW=131MiB/s (138MB/s)(23.1GiB/180070msec)
    clat (msec): min=15, max=157, avg=76.17, stdev= 7.91
     lat (msec): min=15, max=157, avg=76.17, stdev= 7.91
    clat percentiles (msec):
     |  1.00th=[   60],  5.00th=[   74], 10.00th=[   74], 20.00th=[   74],
     | 30.00th=[   74], 40.00th=[   74], 50.00th=[   74], 60.00th=[   74],
     | 70.00th=[   74], 80.00th=[   74], 90.00th=[   89], 95.00th=[   89],
     | 99.00th=[  100], 99.50th=[  117], 99.90th=[  141], 99.95th=[  149],
     | 99.99th=[  157]
   bw (  KiB/s): min=10240, max=16616, per=0.01%, avg=13491.35, stdev=1056.88
    lat (msec) : 20=0.01%, 50=0.50%, 100=98.46%, 250=1.03%
  cpu          : usr=0.05%, sys=1.04%, ctx=24344, majf=0, minf=2564
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=23626,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=131MiB/s (138MB/s), 131MiB/s-131MiB/s (138MB/s-138MB/s), io=23.1GiB (24.8GB), run=180070-180070msec

Disk stats (read/write):
  sda: ios=23614/1575, merge=0/35, ticks=1785211/125916, in_queue=1884301, util=100.00%
```

### 1.5G 机械FIO EXT4读写

```
randrw_70read_128k: (groupid=0, jobs=10): err= 0: pid=2062: Sat Nov 14 03:26:19 2020
   read: IOPS=84, BW=10.6MiB/s (11.1MB/s)(1913MiB/180072msec)
    clat (msec): min=6, max=297, avg=83.62, stdev=32.09
     lat (msec): min=6, max=298, avg=83.62, stdev=32.09
    clat percentiles (msec):
     |  1.00th=[   17],  5.00th=[   35], 10.00th=[   46], 20.00th=[   59],
     | 30.00th=[   68], 40.00th=[   75], 50.00th=[   81], 60.00th=[   89],
     | 70.00th=[   96], 80.00th=[  108], 90.00th=[  126], 95.00th=[  141],
     | 99.00th=[  176], 99.50th=[  192], 99.90th=[  235], 99.95th=[  245],
     | 99.99th=[  285]
   bw (  KiB/s): min=  256, max= 2565, per=0.01%, avg=1092.47, stdev=338.82
  write: IOPS=35, BW=4604KiB/s (4715kB/s)(810MiB/180072msec)
    clat (msec): min=1, max=237, avg=80.21, stdev=23.97
     lat (msec): min=1, max=237, avg=80.25, stdev=23.97
    clat percentiles (msec):
     |  1.00th=[   41],  5.00th=[   50], 10.00th=[   56], 20.00th=[   62],
     | 30.00th=[   68], 40.00th=[   72], 50.00th=[   76], 60.00th=[   81],
     | 70.00th=[   88], 80.00th=[   97], 90.00th=[  114], 95.00th=[  126],
     | 99.00th=[  153], 99.50th=[  172], 99.90th=[  202], 99.95th=[  227],
     | 99.99th=[  239]
   bw (  KiB/s): min=  256, max= 1542, per=0.01%, avg=527.19, stdev=253.77
    lat (msec) : 2=0.05%, 10=0.13%, 20=0.94%, 50=9.42%, 100=65.63%
    lat (msec) : 250=23.81%, 500=0.02%
  cpu          : usr=0.07%, sys=0.44%, ctx=43966, majf=0, minf=1
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=15305,6477,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=10.6MiB/s (11.1MB/s), 10.6MiB/s-10.6MiB/s (11.1MB/s-11.1MB/s), io=1913MiB (2006MB), run=180072-180072msec
  WRITE: bw=4604KiB/s (4715kB/s), 4604KiB/s-4604KiB/s (4715kB/s-4715kB/s), io=810MiB (849MB), run=180072-180072msec

Disk stats (read/write):
  sda: ios=15301/8281, merge=0/74, ticks=465486/44059, in_queue=500849, util=97.88%
```