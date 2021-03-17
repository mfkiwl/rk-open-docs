# Rockchip GEM5 Manual

文件标识：RK-KF-YF-166

发布版本：V1.0.0

日期：2021-02-23

文件密级：□绝密   □秘密   ■内部资料   □公开

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2021 瑞芯微电子股份有限公司**

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

本文提供了 GEM5 仿真器的基本介绍和使用，包括开发和调试方法。

**产品版本**

| **芯片名称** | **内核版本** |
| ------------ | ------------ |
| 通用  | 通用 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | --------| :--------- | ------------ |
| V1.0.0    | 陈谋春 | 2021-02-23 | 初始版本     |

---

**目录**

[TOC]

---

## 概述

   GEM5 是一个在工业和学术界比较流行的开源计算机体系架构仿真平台，是由密歇根大学的 m5 项目和威斯康星大学的 gems 项目在2011年合并完成。许多知名的实验室都采用 GEM5 做计算机体系架构研究，包括：ARM、AMD、Google、Micron、HP 和三星等。

   这里有必须要对仿真器和模拟器做一下概念上的区分，前者翻译自 simulator ，通常具有 cycle 精确的仿真模型，可以较为真实的仿真真实硬件的内部运行时序；而后者翻译自 emulator ，通常只会实现功能上的模拟，而忽略内部实现上的差异。GEM5 作为一个仿真器，同样具备了 cycle 精确的特性，可以用于性能和功耗的仿真。

   GEM5 支持四类 CPU 模型：simple、timing 、 O3（out of order）和 KVM ，simple 只实现了简单的指令翻译执行，没有严格的时序限制；而 timing 则提供了严格的时序限制，可以配置每个指令的 latency ；O3 则在 timing 的基础上，增加了乱序的支持；KVM 则是使用了虚拟化加速技术。

   另外 GEM5 的事件驱动模型，可以提供精确的 Memory 和 总线互联模型。同时还支持多种指令集的仿真：ARM、 X86、 RISC-V、 SPARC 和 ALPHA 。

## 环境搭建

### 代码下载

   Gem5 的代码目前是托管在 Google Source 上，所以在下载代码前，请确保你可以访问 Google，具体步骤如下：

```shell
git clone https://gem5.googlesource.com/public/gem5
```

### Docker

   使用 Docker 可以跳过一些繁琐的环境配置，只需要几步就可以完成所有配置，具体如下：

```shell
sudo apt install docker.io                                               ## 安装 Docker
sudo docker pull gcr.io/gem5-test/ubuntu-20.04_all-dependencies          ## 获取 Gem5 官方的 Docker 镜像
```

   截止本文撰写的时间，Gem5 的稳定版本是 V20，官方文档显示这个版本同时支持 Python 2 和 Python 3，对于 Ubuntu 18.04 推荐用 Python 2，而 Ubuntu 20.04 则默认用 Python 3，但实际测试过程中，我发现在 Python 2 的一些支持已经被废弃，所以上面采用的 Ubuntu 20.04 的镜像，如果你处于老版本的 Gem5 下，可能会需要一些其他镜像，下面是官方提供的镜像清单：

```shell
Ubuntu 18.04 with all optional dependencies (Python 2): gcr.io/gem5-test/ubuntu-18.04_all-dependencies (source Dockerfile).

Ubuntu 18.04 with the minimum set of dependencies (Python 2): gcr.io/gem5-test/ubuntu-18.04_min-dependencies (source Dockerfile).

Ubuntu 20.04 with all optional dependencies (Python 3): gcr.io/gem5-test/ubuntu-20.04_all-dependencies (source Dockerfile).

```

   如果遇到镜像下载失败，可以用我这边做好的镜像，方法如下：

```shell
wget http://10.10.10.110/shared/gem5_docker_ubuntu_20.tar.gz
sudo docker load -i gem5_docker_ubuntu_20.tar.gz
```

   默认 Docker 是需要 sudo 权限的，为了方便开发，可以给普通用户添加 Docker 权限，方法如下：

```shell
sudo usermod -G docker -a user_name               ## user_name 为你的用户名
```

   顺利完成后，可以看一下镜像是否安装成功，命令如下：

```shell
docker images
REPOSITORY                                       TAG                 IMAGE ID            CREATED             SIZE
gcr.io/gem5-test/ubuntu-20.04_all-dependencies   latest              7dfc9cd17d88        4 weeks ago         1.27GB
```

   镜像安装成功以后，就可以启动 Docker 了，命令如下：

```shell
gcr.io/gem5-test/ubuntu-20.04_all-dependenciesdocker run -u $UID:$GID --volume <gem5 directory>:/gem5 --rm -it <image>
## 其中 <gem5 directory> 指向你放置 Gem5 代码的目录，请确保使用绝对路径，docker 运行时会映射到 /gem5 目录下，
## <image> 则指定你之前安装成功的镜像，例如：gcr.io/gem5-test/ubuntu-20.04_all-dependencies
```

## 目录结构

```shell
gem5$ tree -L 1
.
├── CODE-OF-CONDUCT.md
├── CONTRIBUTING.md
├── COPYING
├── LICENSE
├── MAINTAINERS
├── README
├── RELEASE-NOTES.md
├── SConstruct
├── TESTING.md
├── build_opts
├── cloudbuild_presubmit.yaml
├── configs                   # 仿真配置脚本
├── ext                       # 第三方组件，如 dramsim2
├── include
├── site_scons
├── src                       # 仿真器的源码，注意：这个目录的 python 配置脚本如果要更新，需要重新编译仿真器
├── system
├── tests
└── util                      # 工具目录，例如：m5term
```

## 编译

   如果你的 Docker 运行正常，进到 Gem5 主目录就可以在 Docker 环境下执行编译了，具体命令如下：

```shell
cd gem5
scons build/{ISA}/gem5.{variant} -j {cpus}
```

   其中 {ISA} 即你要仿真的指令集，目前 Gem5 支持的指令集如下：

```shell
The valid ISAs are:

ARCH
ARM
NULL
MIPS
POWER
RISCV
SPARC
X86
```

   而 {variant} 则关联到各种编译开关，区别在于是否启用优化，以及是否支持 Debug 和 Profiling ，可以用一个表格来表示：

| Build variant | Optimizations | Run time debugging support | Profiling support |
| ------------- | ------------- | -------------------------- | ----------------- |
| **debug**     |               | X                          |                   |
| **opt**       | X             | X                          |                   |
| **fast**      | X             |                            |                   |
| **prof**      | X             |                            | X                 |
| **perf**      | X             |                            | X                 |

   最后是 {cpus} 指定了编译的 CPU 数量，这和 Makefile 是一样的，下面是一个具体的编译命令：

```shell
scons build/ARM/gem5.opt -j 8
## 编译 ARM 架构，opt 配置，8 线程并行编译
```

   编译成功后，可以在 Gem5 主目录下看到如下文件，即你后面要用的仿真器：

```shell
ls -l build/ARM/gem5.opt
-rwxr-xr-x 1 user user 1868622752 Jan 16 02:59 build/ARM/gem5.opt
```

## 仿真器选项

   仿真器有很多运行时选项，一些选项对我们接下来的仿真运行和调试非常重要，所以我们需要先来了解它，可以通过 `./build/ARM/gem5.opt --help` 命令来列出所有选项，其中重要的选项有特别标注出来，具体如下：

```shell
user@1dc5484c7277:/gem5$ ./build/ARM/gem5.opt --help
Usage
=====
  gem5.opt [gem5 options] script.py [script options]

gem5 is copyrighted software; use the --copyright option for details.

Options
=======
--version               show program's version number and exit
--help, -h              show this help message and exit
--build-info, -B        Show build information
--copyright, -C         Show full copyright information
--readme, -R            Show the readme
--outdir=DIR, -d DIR    设置输出目录，包括拓扑图、统计信息和串口输出都会在这个目录下 [Default: m5out]
--redirect-stdout, -r   Redirect stdout (& stderr, without -e) to file
--redirect-stderr, -e   Redirect stderr to file
--stdout-file=FILE      Filename for -r redirection [Default: simout]
--stderr-file=FILE      Filename for -e redirection [Default: simerr]
--listener-mode={on,off,auto}
                        Port (e.g., gdb) listener mode (auto: Enable if
                        running interactively) [Default: auto]
--listener-loopback-only
                        Port listeners will only accept connections over the
                        loopback device
--interactive, -i       Invoke the interactive interpreter after running the
                        script
--pdb                   Invoke the python debugger before running the script
--path=PATH[:PATH], -p PATH[:PATH]
                        Prepend PATH to the system path when invoking the
                        script
--quiet, -q             Reduce verbosity
--verbose, -v           Increase verbosity

Statistics Options
------------------
--stats-file=FILE       设置统计信息的文件名 [Default:
                        stats.txt]
--stats-help            Display documentation for available stat visitors

Configuration Options
---------------------
--dump-config=FILE      设置配置文件的文件名，ini 格式 [Default: config.ini]
--json-config=FILE      设置配置文件的文件名，json 格式 [Default:
                        config.json]
--dot-config=FILE       拓扑结构图的文件名
                        [Default: config.dot]
--dot-dvfs-config=FILE  Create DOT & pdf outputs of the DVFS configuration
                        [Default: none]

Debugging Options
-----------------
--debug-break=TICK[,TICK]
                        创建断点，如果仿真器没有和GDB连接，会直接退出仿真 (kills process if no
                        debugger attached)
--debug-help            Print help on debug flags
--debug-flags=FLAG[,FLAG]
                        设置调试标志，可以启用或关闭一些调试信息 (-FLAG disables a
                        flag)
--debug-start=TICK      输出调试信息的起点
--debug-end=TICK        输出调试信息的终点
--debug-file=FILE       调试信息输出的文件名 [Default: cout]
--debug-ignore=EXPR     Ignore EXPR sim objects
--remote-gdb-port=REMOTE_GDB_PORT
                        Remote gdb base port (set to 0 to disable listening)

Help Options
------------
--list-sim-objects      List all built-in SimObjects, their params and default
                        values
```

## 仿真模式

   Gem5 支持两种仿真模式：FS(full system) 和 SE(syscall emulation)，二者的区别在于：前者可以跑 Linux Kernel，整个流程非常接近真实系统，包括完整的 Boot 流程；而 SE 只能运行用户态的程序，其系统调用都是模拟出来的，不保证 Cycle 精确，并且 MMU 和真实场景也会有差异。但是 FS 的优点也带来了更多的工作量，你需要去调试甚至编译内核，要配置更复杂更真实的拓扑结构，同时运行速度也更慢，因此，选用哪个仿真模式是根据需求来的，如果你要仿真的场景完全都在用户态，并且不在意 Memory 性能的精度，则可以选用 SE 模式来加快进度，如果你的场景中真实的内核行为非常重要，则只能选择 FS 模式。

   实际使用中，经常是两种模式交叉，SE 用于从大量配置中筛选中较优的配置，然后 FS 用于精确验证性能功耗的收益。

## FS例子

   因为 FS 完全模拟了真实的 Boot 流程，所以要移植 Boot Loader，Kernel 和 Root FS，不过为了简化流程，可以直接用 Gem5 官方提供的镜像，根据自己的需求去替换自己的镜像。Loader & Kernel 的编译和移植方式会在另外一份文档做介绍，本文都是直接使用官方现成的镜像。

   第一步，你要有一个配置文件，这个配置文件定义了你的硬件拓扑结构，以及软件镜像位置和启动脚本等。Gem5 的所有配置文件都是以 Python 脚本的形式存在，只要熟悉 Python 的基础语法，入门是非常容易的，并且为了进一步简化配置流程，Gem5 提供了一些常见的拓扑结构配置例子，具体如下：

```shell
configs/example/
├── apu_se.py
├── arm                           # ARM 架构的相关配置
│   ├── baremetal.py              # Bare metal 的配置例子
│   ├── devices.py                # CPU & Memory 的配置例子，其他配置可以引用它来简化 CPU 和 Memory的配置
│   ├── dist_bigLITTLE.py         # 分布式大小核配置例子
│   ├── fs_bigLITTLE.py           # 大小核 FS 仿真例子，32位
│   ├── fs_power.py               # 功耗 FS 仿真例子
│   ├── starter_fs.py             # 64位 FS 仿真例子
│   ├── starter_se.py             # 64位 SE 仿真例子
│   └── workloads.py              # ARM Trust 仿真例子
├── etrace_replay.py
├── fs.py
├── garnet_synth_traffic.py
├── hmc_hello.py
├── hmc_tgen.cfg
├── hmctest.py
├── hsaTopology.py
├── memcheck.py
├── memtest.py
├── read_config.py
├── ruby_direct_test.py
├── ruby_gpu_random_test.py
├── ruby_mem_test.py
├── ruby_random_test.py
├── sc_main.py
└── se.py
```

   我们这里选择 fs_bigLITTLE.py 作为我们的配置文件，首先，直接运行它，看有哪些命令行选项可以配置，具体如下：

```shell
user@1dc5484c7277:/gem5$ ./build/ARM/gem5.opt configs/example/arm/fs_bigLITTLE.py --help
gem5 Simulator System.  http://gem5.org
gem5 is copyrighted software; use the --copyright option for details.

gem5 version 20.1.0.2
gem5 compiled Jan 16 2021 02:59:26
gem5 started Feb  8 2021 01:36:45
gem5 executing on 1dc5484c7277, pid 398
command line: ./build/ARM/gem5.opt configs/example/arm/fs_bigLITTLE.py --help

usage: fs_bigLITTLE.py [-h] [--restore-from RESTORE_FROM] [--dtb DTB] --kernel KERNEL [--root ROOT]
                       [--machine-type {RealView,VExpress_EMM,VExpress_EMM64,VExpress_GEM5_Base,VExpress_GEM5_Foundation,VExpress_GEM5_V1,VExpress_GEM5_V1_Base,VExpress_GEM5_V2,VExpress_GEM5_V2_Base,VExpress_GEM5}]
                       [--disk DISK] [--bootscript BOOTSCRIPT] [--cpu-type {atomic,timing,exynos}] [--kernel-init KERNEL_INIT]
                       [--big-cpus BIG_CPUS] [--little-cpus LITTLE_CPUS] [--caches] [--last-cache-level LAST_CACHE_LEVEL]
                       [--big-cpu-clock BIG_CPU_CLOCK] [--little-cpu-clock LITTLE_CPU_CLOCK] [--sim-quantum SIM_QUANTUM]
                       [--mem-size MEM_SIZE] [--kernel-cmd KERNEL_CMD] [--bootloader BOOTLOADER] [-P PARAM] [--vio-9p]

Generic ARM big.LITTLE configuration

optional arguments:
  -h, --help            show this help message and exit
  --restore-from RESTORE_FROM
                        Restore from checkpoint
  --dtb DTB             DTB file to load
  --kernel KERNEL       Linux kernel
  --root ROOT           Specify the kernel CLI root= argument
  --machine-type {RealView,VExpress_EMM,VExpress_EMM64,VExpress_GEM5_Base,VExpress_GEM5_Foundation,VExpress_GEM5_V1,VExpress_GEM5_V1_Base,VExpress_GEM5_V2,VExpress_GEM5_V2_Base,VExpress_GEM5}
                        Hardware platform class
  --disk DISK           Disks to instantiate
  --bootscript BOOTSCRIPT
                        Linux bootscript
  --cpu-type {atomic,timing,exynos}
                        CPU simulation mode. Default: timing
  --kernel-init KERNEL_INIT
                        Override init
  --big-cpus BIG_CPUS   Number of big CPUs to instantiate
  --little-cpus LITTLE_CPUS
                        Number of little CPUs to instantiate
  --caches              Instantiate caches
  --last-cache-level LAST_CACHE_LEVEL
                        Last level of caches (e.g. 3 for L3)
  --big-cpu-clock BIG_CPU_CLOCK
                        Big CPU clock frequency
  --little-cpu-clock LITTLE_CPU_CLOCK
                        Little CPU clock frequency
  --sim-quantum SIM_QUANTUM
                        Simulation quantum for parallel simulation. Default: 1ms
  --mem-size MEM_SIZE   System memory size
  --kernel-cmd KERNEL_CMD
                        Custom Linux kernel command
  --bootloader BOOTLOADER
                        executable file that runs before the --kernel
  -P PARAM, --param PARAM
                        Set a SimObject parameter relative to the root node. An extended Python multi range slicing syntax can
                        be used for arrays. For example: 'system.cpu[0,1,3:8:2].max_insts_all_threads = 42' sets
                        max_insts_all_threads for cpus 0, 1, 3, 5 and 7 Direct parameters of the root object are not accessible,
                        only parameters of its children.
  --vio-9p              Enable the Virtio 9P device and set the path to share. The default 9p path is m5ou5/9p/share, and it can
                        be changed by setting VirtIO9p.root with --param. A sample guest mount command is: "mount -t 9p -o
                        trans=virtio,version=9p2000.L,aname=<host-full-path> gem5 /mnt/9p" where "<host-full-path>" is the full
                        path being shared on the host, and "gem5" is a fixed mount tag. This option requires the diod 9P server
                        to be installed in the host PATH or selected with with: VirtIO9PDiod.diod.
```

   比较重要的选项具体如下：

| 选项                           | 用途                                                         | 必选 |
| ------------------------------ | ------------------------------------------------------------ | ---- |
| machine-type                   | 这个选项决定了仿真的目标平台，目前 Gem5 现成的目标平台主要是 ARM  官方推出的 VExpress 平台的模型，在这基础上有一些不同的变种和延伸，例如不同的 CPU 或中断控制器，不同的地址映射等 | 否   |
| dtb                            | 指定你要用的dtb文件，如果不指定的话，会自动根据前面设置的 machine-type 生成一个默认的dtb | 否   |
| kernel                         | 指定你的内核镜像                                             | 是   |
| root                           | 指定根文件系统的设备节点，这个会被 loader 传给内核           | 否   |
| disk                           | 指定磁盘镜像，镜像里要包含分区表                             | 是   |
| bootscript                     | 启动脚本，内核在启动完成后会自动执行该脚本，一般可以把测试脚本放这里 | 否   |
| cpu-type                       | 选择 CPU 模型，目前有 atomic,timing,exynos 可选，三个模型的差异后面会单独介绍，默认是 timing | 否   |
| kernel-init                    | 指定 init 程序的路径，默认是 /sbin/init                      | 否   |
| big-cpus/little-cpus           | 指定大小核数目，默认都是1                                    | 否   |
| caches                         | 是否启用 cache                                               | 否   |
| last-cache-level               | 最后一级 cache 位置，默认是2，即最后一级 cache 是 L2         | 否   |
| big-cpu-clock/little-cpu-clock | 大小核频率，默认分别是 2GHz 和 1GHz                          | 否   |
| mem-size                       | 指定内存大小                                                 | 否   |
| kernel-cmd                     | 指定内核命令行                                               | 否   |
| bootloader                     | 指定 Boot Loader 镜像                                        | 是   |
| param                          | 可以覆盖任意仿真对象的参数                                   | 否   |
|                                |                                                              |      |

   下面是一个运行命令的例子：

```shell
export IMG_ROOT=/gem5/arm_images/kernel_loader
./build/ARM/gem5.opt configs/example/arm/fs_bigLITTLE.py \
    --caches \
    --bootloader="$IMG_ROOT/binaries/boot.arm" \
    --kernel="$IMG_ROOT/binaries/vmlinux.arm" \
    --disk="$IMG_ROOT/../disk_images/linux-aarch32-ael.img" \
    --bootscript="$IMG_ROOT/benchmark.rcS" \
    --cpu-type="exynos" \
    --big-cpu-clock=4GHz \
    --little-cpu-clock=2GHz \
    --mem-size=2GB
```

   如果成功运行，可以看到如下log：

```shell
gem5 Simulator System.  http://gem5.org
gem5 is copyrighted software; use the --copyright option for details.

gem5 version 20.1.0.2
gem5 compiled Jan 16 2021 02:59:26
gem5 started Feb 21 2021 06:22:49
gem5 executing on b4f7be019b73, pid 13
command line: ./build/ARM/gem5.opt configs/example/arm/fs_bigLITTLE.py --caches --bootloader=/gem5/arm_images/kernel_loader/binaries/boot.arm --kernel=/gem5/arm_images/kernel_loader/binaries/vmlinux.arm --disk=/gem5/arm_images/kernel_loader/../disk_images/linux-aarch32-ael.img --bootscript=/gem5/arm_images/kernel_loader/benchmark.rcS --cpu-type=exynos --big-cpu-clock=4GHz --little-cpu-clock=2GHz --mem-size=2GB

Global frequency set at 1000000000000 ticks per second
info: Simulated platform: VExpress_GEM5_V1
...
info: kernel located at: /gem5/arm_images/kernel_loader/binaries/vmlinux.arm
warn: No functional unit for OpClass SimdPredAlu
system.vncserver: Listening for connections on port 5900
system.terminal: Listening for connections on port 3456        # 这是控制台转发的端口号
...
```

   仿真器运行的时候，我们可以通过串口转发的端口号，来连接控制台查看内核的 log ，以及做一些交互。GEM5 提供了一个 telnet 程序来连接，所以需要先编译一下这个程序，方法如下：

```shell
# 先进 docker 环境
cd /gem5/util/term
make
ls -l m5term
-rwxrwxr-x 1 user user 18168 Dec 31 02:53 m5term
```

   有了 `m5term` 就可以连接控制台了，现在前面仿真器启动 log 中，找到如下输出：

```shell
system.terminal: Listening for connections on port 3456        # 这是控制台转发的端口号
```

   然后执行如下命令：

```shell
/gem5/util/term/m5term 3456
# 执行成功的话，可以看到如下 log，说明仿真正常
==== m5 terminal: Terminal 0 ====
[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.18.0+ (arm-employee@arm-computer) (gcc version 7.4.0 (Ubuntu/Linaro 7.4.0-1ubuntu1~18.04.1)) #1 SMP PREEMPT Wed Nov 6 14:11:58 GMT 2019
[    0.000000] CPU: ARMv7 Processor [410fc0f0] revision 0 (ARMv7), cr=14c5387d
[    0.000000] CPU: div instructions available: patching division code
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
[    0.000000] OF: fdt: Machine model: V2P-CA15
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] earlycon: pl11 at MMIO 0x1c090000 (options '')
[    0.000000] Booting Linux on physical CPU 0x0
```

   为了方便仿真器自动执行我们的测试程序，fs_bigLITTLE.py 提供了 `bootscript` 选项来指定脚本文件的路径，这个脚本文件可以用来调用你的测试程序，这个脚本会在内核启动 `init` 程序后被调用，下面是脚本的例子：

```shell
#!/bin/sh

#Author: Anthony Gutierrez
# run script for benchmark

echo "enter lmbench test"
m5 dumpresetstats         # dump 并重置统计信息，m5是仿真器自带的命令
bw_mem 128M wr
m5 dumpresetstats
bw_mem 128M rd
m5 dumpresetstats
bw_mem 128M fwr
m5 dumpresetstats
bw_mem 128M frd
m5 dumpresetstats
echo "leave lmbench test"
```

   最后，在仿真结束后，你可以在 `m5out` 目录（可以通过 outdir 选项指定目录）下找到仿真的输出，具体如下：

```shell
ls m5out/ -l
总用量 784
-rw-rw-r-- 1 cmc cmc 201317 Feb 21 14:22 config.dot              # 拓扑结构图
-rw-rw-r-- 1 cmc cmc  35489 Feb 21 14:22 config.dot.pdf          # 同上
-rw-rw-r-- 1 cmc cmc 137510 Feb 21 14:22 config.dot.svg          # 同上
-rw-rw-r-- 1 cmc cmc  98391 Feb 21 14:22 config.ini              # 同上
-rw-rw-rw- 1 cmc cmc 269062 Feb 21 14:22 config.json             # 同上
drwxr-xr-x 5 cmc cmc   4096 Jan 15 17:12 fs
-rwxrwxr-x 1 cmc cmc    796 Dec 30 09:24 simerr                  # 仿真器错误 log
-rw-rw-r-- 1 cmc cmc      0 Feb 21 14:22 stats.txt               # 统计信息
-rw-rw-r-- 1 cmc cmc   6392 Feb 21 14:22 system.dtb              # 仿真平台的 dtb
-rw-rw-r-- 1 cmc cmc      0 Feb 21 14:22 system.realview.uart1.device
-rw-rw-r-- 1 cmc cmc      0 Feb 21 14:22 system.realview.uart2.device
-rw-rw-r-- 1 cmc cmc      0 Feb 21 14:22 system.realview.uart3.device
-rw-rw-r-- 1 cmc cmc  13651 Feb 21 14:42 system.terminal         # 仿真平台控制台输出
-rw-rw-r-- 1 cmc cmc  12730 Dec 31 11:32 system.workload.dmesg   # 内核 dmesg
```

   比较重要的是 `config.dot.pdf` 和 `config.json`，这是拓扑结构图和每个仿真对象的配置参数，在配置完平台的时候，一般需要从这两个文件确认配置是否符合预期。`stats.txt` 是仿真器运行期间的统计信息，`m5 dumpresetstats` 命令每次执行都会 dump 当前的统计信息到这个文件，并重新清0。

## SE例子

   SE 则会更简单一些，其配置方法和 FS 一样，因为其所有的内核系统调用都是模拟出来的，所以不需要提供系统镜像，只需要一个标准的 ELF 即可，下面是一个具体的运行命令：

```shell
# 运行docker，cd /gem5
build/ARM/gem5.opt configs/example/se.py --cpu-type=ex5_big --l1d_size=64kB --l1i_size=64kB --l2_size=1MB --l1d_assoc=4 --l1i_assoc=4 --l2_assoc=16 --caches --l2cache --mem-type=DDR4_3200_1x16 --mem-channels=2 --mem-ranks=2 --mem-size=2GB --sys-clock=4GHz --cpu-clock=4GHz -c /path/to/lat_mem_rd -o "1"
```

   测试程序的打印输出会直接转发到命令行，同时仿真的结果也会输出 `m5out` (可以通过 outdir 选项更改) 目录下。

## 自定义Linux内核

   编译内核的流程和我们常规的内核开发流程并无什么不同，首先我们要下载已经移植了 GEM5 支持的 Kernel 源码，具体如下：

```shell
git clone https://gem5.googlesource.com/arm/linux
```

   交叉编译器也没有特殊要求，修改 Makefile 或在执行 make 命令的时候去指定都可以，例如：

```shell
CROSS_COMPILE   ?= /path/to/toolchain/rk_android_11/prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
```

   编译命令如下：

```shell
make ARCH=arm gem5_defconfig
make ARCH=arm -j8
ls -l vmlinux
-rwxrwxr-x 1 user user 140895136 Feb 22 16:19 vmlinux      # 这就是仿真需要的内核镜像了
```

## 调试与技巧

### 多个配置并行仿真

   GEM5 作为纯软件的仿真，运行速度可想而之是非常慢的，例如在我当前的机器配置：I7-7700K + 16GB DDR3200下，仿真一个：大核4GHz + 小核 2GHz 的 Cotex-A15 + 2CH DDR4 3200 ，差不多速度要放慢 13850 倍。因为仿真是单线程运行的，所以加速仿真的方法目前只有两个：多个配置并行仿真 和 checkpoint。

   为了发挥当前 host 多核的优势，我们可以并发运行我们要仿真的多个配置，例如：你当前的研究是想看看不同的 DRAM Addr Mapping 配置对某个 benchmark 的影响，就可以并发运行你要比较的配置，可以看下面两组运行命令：

```shell
export IMG_ROOT=/gem5/arm_images/kernel_loader
# 注意并发运行的时候要修改仿真结果的输出目录
./build/ARM/gem5.opt --outdir=DDR4_3200_1x16_RoCoRaBaCh_4CH_xor_9_intlv_64_out configs/example/arm/fs_big_little.py \
    --caches \
    --bootloader="$IMG_ROOT/binaries/boot.arm" \
    --kernel="$IMG_ROOT/binaries/vmlinux.arm" \
    --disk="$IMG_ROOT/../disk_images/linux-aarch32-ael.img" \
    --bootscript="$IMG_ROOT/benchmark.rcS" \
    --cpu-type="exynos" \
    --big-cpu-clock=4GHz \
    --little-cpu-clock=2GHz \
    --mem-type=DDR4_3200_1x16 \
    --mem-channels=4 \
    --mem-size=2GB \
    --xor_low_bit=9 \
    --mem_channels_intlv=64 \
    --param='system.clk_domain.clock="4GHz"' \
    --param='system.mem_ctrls[0,1,2,3].dram.addr_mapping="RoCoRaBaCh"' \    # 配置地址映射
    --param='system.bigCluster.l2.prefetcher.prefetch_on_access="false"' \
```

```shell
export IMG_ROOT=/gem5/arm_images/kernel_loader
# 注意并发运行的时候要修改仿真结果的输出目录
./build/ARM/gem5.opt --outdir=DDR4_3200_1x16_RoRaBaChCo_4CH_xor_9_intlv_64_out configs/example/arm/fs_big_little.py \
    --caches \
    --bootloader="$IMG_ROOT/binaries/boot.arm" \
    --kernel="$IMG_ROOT/binaries/vmlinux.arm" \
    --disk="$IMG_ROOT/../disk_images/linux-aarch32-ael.img" \
    --bootscript="$IMG_ROOT/benchmark.rcS" \
    --cpu-type="exynos" \
    --big-cpu-clock=4GHz \
    --little-cpu-clock=2GHz \
    --mem-type=DDR4_3200_1x16 \
    --mem-channels=4 \
    --mem-size=2GB \
    --xor_low_bit=9 \
    --mem_channels_intlv=64 \
    --param='system.clk_domain.clock="4GHz"' \
    --param='system.mem_ctrls[0,1,2,3].dram.addr_mapping="RoRaBaChCo"' \    # 配置地址映射
    --param='system.bigCluster.l2.prefetcher.prefetch_on_access="false"' \
```

   需要注意的是，在你更改配置的时候，请同步修改 `outdir` ，确保不同配置的仿真结果输出不会互相覆盖，并且目录名最好能直接体现出配置上的差异，方便记录数据。

   checkpoint 则只适用于仿真配置不变的情况下，快速快进到你要仿真的位置，例如跳过漫长的 android 启动过程，直接从指定位置开始仿真。其前提是你要先用一份稳定的仿真配置，跑到指定的位置并保存一份快照，后面只要仿真配置不变，就可以一直用这个快照来跑。下面是具体步骤：

- 创建快照：在运行到指定位置后，在串口控制台或者启动脚本中执行命令 `m5 checkpoint delay period` ， delay 和 period 都是可选的，分别控制延迟和周期快照，快照默认会存放在仿真结果的输出目录（默认是 m5out）。

- 载入快照：这个需要配置脚本在运行仿真的时候去指定快照的路径，可以参考 `configs/example/arm/fs_bigLITTLE.py` 的例子，具体如下：

    ```python
    if options.restore_from:
            if checkpoint_dir and not os.path.isabs(options.restore_from):
                cpt = os.path.join(checkpoint_dir, options.restore_from)
            else:
                cpt = options.restore_from

            m5.util.inform("Restoring from checkpoint %s", cpt)
            m5.instantiate(cpt)
        else:
            m5.instantiate()
    ```

    所以，我们只要在运行仿真器的时候通过命令行选项去指定快照路径即可，具体如下：

    ```shell
    export IMG_ROOT=/gem5/arm_images/kernel_loader
    ./build/ARM/gem5.opt --outdir=DDR4_3200_1x16_RoCoRaBaCh_4CH_xor_9_intlv_64_out configs/example/arm/fs_big_little.py \
        --caches \
        --bootloader="$IMG_ROOT/binaries/boot.arm" \
        --kernel="$IMG_ROOT/binaries/vmlinux.arm" \
        --disk="$IMG_ROOT/../disk_images/linux-aarch32-ael.img" \
        --bootscript="$IMG_ROOT/benchmark.rcS" \
        --cpu-type="exynos" \
        --big-cpu-clock=4GHz \
        --little-cpu-clock=2GHz \
        --mem-type=DDR4_3200_1x16 \
        --mem-channels=4 \
        --mem-size=2GB \
        --xor_low_bit=9 \
        --mem_channels_intlv=64 \
        --restore_from="/path/to/your/checkpoint"
    ```

### 调试输出

   GEM5 本身就提供了大量的调试输出，为了定位问题，或则分析性能，有时候你可能需要打开这些调试信息，或者增加自己的调试信息，下面分别举个例子来看。

   要打开调试信息，直接通过命令行选项即可，下面是一个具体例子：

```shell
export IMG_ROOT=/gem5/arm_images/kernel_loader
./build/ARM/gem5.opt --debug-flags=MemCtrl \  # 只启动 MemCtrl 的调试输出
    --debug-start=800036671000 \      # 只记录这个时间之后的调试输出，单位是 tick
    --debug-end=1000036671000 \       # 在这个时间之后停止调试输出，单位也是 tick
    --debug-file=mem_debug.log \      # 调试输出的文件名，默认是放 outdir 下
    --outdir=DDR4_3200_1x16_RoCoRaBaCh_2CH_xor_9_intlv_64_debug_out \
    configs/example/arm/fs_big_little.py \
    --caches \
    --bootloader="$IMG_ROOT/binaries/boot.arm" \
    --kernel="$IMG_ROOT/binaries/vmlinux.arm" \
    --disk="$IMG_ROOT/../disk_images/linux-aarch32-ael.img" \
    --bootscript="$IMG_ROOT/benchmark.rcS" \
    --cpu-type="exynos" \
    --big-cpu-clock=4GHz \
    --little-cpu-clock=2GHz \
    --mem-type=DDR4_3200_1x16 \
    --mem-channels=2 \
    --mem-size=2GB \
    --xor_low_bit=9 \
    --mem_channels_intlv=64 \
    --param='system.clk_domain.clock="4GHz"' \
    --param='system.mem_ctrls[0,1].dram.addr_mapping="RoCoRaBaCh"' \
    --param='system.bigCluster.l2.prefetcher.prefetch_on_access="false"' \
    --param='system.bigCluster.l2.write_buffers=64' \
```

​    因为仿真器是 cycle 精确的仿真，所以调试输出是巨量的，例如上面的命令只是抓取 lmbench 的 wr 测试中一小段的内存控制器的调试输出，就有差不多30GB ，所以调试输出有几个小技巧要注意：

- 尽量输出到 ssd 上，防止写文件成为瓶颈，影响仿真运行速度

- 尽量只启用你关心的模块的调试信息，例如上面就只启用 MemCtrl （内存控制器）的调试输出

- 尽量减少调试输出的区间，即可以通过一些手段去定位你关心的时间区间，例如可以记录 benchmark 的起始和结束的 tick ，然后预估你要抓的区间，通过 `debug-start` 和 `debug-end` 去指定

   要增加自己的调试输出也非常简单，下面是一个具体例子：

   输出调试信息前，需要有一个调试开关，可以沿用现有的调试开关，例如前面的 `MemCtrl`，也可以定义自己的调试开关，这是在编译脚本中指定的，具体如下：

```c++
   Import('*')

   SimObject('HelloObject.py')

   Source('hello_object.cc')

   DebugFlag('HelloExample', "For Learning gem5 Part 2. Simple example debug flag")
```

   定义完调试开关，就可以直接在代码中使用 `DPRINTF` 函数来打印调试信息，这个函数的第一个参数可以指向这个开关，具体如下：

```c++
   void
   HelloObject::processEvent()
   {
       timesLeft--;
       // 如果仿真命令中带有 --debug-flags=HelloExample 选项，就会开启这个调试输出
       DPRINTF(HelloExample, "Hello world! Processing the event! %d left\n",
                             timesLeft);

       if (timesLeft <= 0) {
           DPRINTF(HelloExample, "Done firing!\n");
           goodbye->sayGoodbye(myName);
       } else {
           schedule(event, curTick() + latency);
       }
   }
```

## 配置文件解析

   为了简化仿真流程，我们前面直接用了现成的 fs_bigLITTLE.py 作为我们的配置文件，但这个配置文件肯定不能满足我们所有的需求，我们有时候需要根据自己的需求去改造它，或者重写我们自己的配置文件，这就要求我们要先看懂这个配置文件，所以本节就让我们以 fs_bigLITTLE.py 为例，学习 FS 仿真的配置流程，至于 SE 仿真的配置流程差异非常小，就不重复介绍了。

   我们首先从入口函数开始，具体如下：

```python
def main():
    parser = argparse.ArgumentParser(
        description="Generic ARM big.LITTLE configuration")   # 声明一个解析器
    addOptions(parser)                                        # 添加一些命令行可配置选项
    options = parser.parse_args()                             # 解析这些可配置选项
    root = build(options)                                     # 根据这些选项来构建系统，包括硬件拓扑结构、镜像等
    root.apply_config(options.param)                          # 根据命令行的参数，覆盖硬件配置参数
    instantiate(options)                                      # 实例化仿真系统
    run()                                                     # 运行仿真
```

   `addOptions` 是为了简化配置，把一些我们关心的配置都作为选项添加到脚本中，这些选项通常是指定拓扑结构各个仿真对象的可配置参数，我们可以在启动仿真器的时候通过命令行参数来给这些选项赋值，这对于并发运行多个配置非常有意义。下面是这个函数的具体实现：

```python
def addOptions(parser):
    parser.add_argument("--restore-from", type=str, default=None,
                        help="Restore from checkpoint")
    parser.add_argument("--dtb", type=str, default=None,
                        help="DTB file to load")
    parser.add_argument("--kernel", type=str, required=True,
                        help="Linux kernel")
    parser.add_argument("--root", type=str, default="/dev/vda1",
                        help="Specify the kernel CLI root= argument")
    parser.add_argument("--machine-type", type=str,
                        choices=ObjectList.platform_list.get_names(),
                        default="VExpress_GEM5",
                        help="Hardware platform class")
    parser.add_argument("--disk", action="append", type=str, default=[],
                        help="Disks to instantiate")
    parser.add_argument("--bootscript", type=str, default=default_rcs,
                        help="Linux bootscript")
    parser.add_argument("--cpu-type", type=str, choices=list(cpu_types.keys()),
                        default="timing",
                        help="CPU simulation mode. Default: %(default)s")
    parser.add_argument("--kernel-init", type=str, default="/sbin/init",
                        help="Override init")
    parser.add_argument("--big-cpus", type=int, default=1,
                        help="Number of big CPUs to instantiate")
    parser.add_argument("--little-cpus", type=int, default=1,
                        help="Number of little CPUs to instantiate")
    parser.add_argument("--caches", action="store_true", default=False,
                        help="Instantiate caches")
    parser.add_argument("--last-cache-level", type=int, default=2,
                        help="Last level of caches (e.g. 3 for L3)")
    parser.add_argument("--big-cpu-clock", type=str, default="2GHz",
                        help="Big CPU clock frequency")
    parser.add_argument("--little-cpu-clock", type=str, default="1GHz",
                        help="Little CPU clock frequency")
    parser.add_argument("--sim-quantum", type=str, default="1ms",
                        help="Simulation quantum for parallel simulation. " \
                        "Default: %(default)s")
    parser.add_argument("--mem-size", type=str, default=default_mem_size,
                        help="System memory size")
    parser.add_argument("--kernel-cmd", type=str, default=None,
                        help="Custom Linux kernel command")
    parser.add_argument("--bootloader", action="append",
                        help="executable file that runs before the --kernel")
    parser.add_argument("-P", "--param", action="append", default=[],
        help="Set a SimObject parameter relative to the root node. "
             "An extended Python multi range slicing syntax can be used "
             "for arrays. For example: "
             "'system.cpu[0,1,3:8:2].max_insts_all_threads = 42' "
             "sets max_insts_all_threads for cpus 0, 1, 3, 5 and 7 "
             "Direct parameters of the root object are not accessible, "
             "only parameters of its children.")
    parser.add_argument("--vio-9p", action="store_true",
                        help=Options.vio_9p_help)
    return parser
```

   `build` 函数也是我们需要具体看一下的函数，在这里会完成仿真拓扑结构的配置，镜像的导入等，下面是具体实现：

```python
def build(options):
    m5.ticks.fixGlobalFrequency()

    # 传给内核的命令行参数，可以看到我们可以通过选项来制定内存大小，根文件系统和init的路径
    kernel_cmd = [
        "earlyprintk",
        "earlycon=pl011,0x1c090000",
        "console=ttyAMA0",
        "lpj=19988480",
        "norandmaps",
        "loglevel=8",
        "mem=%s" % options.mem_size,
        "root=%s" % options.root,
        "rw",
        "init=%s" % options.kernel_init,
        "vmalloc=768MB",
    ]

    # 指定构建 FS 仿真器
    root = Root(full_system=True)

    # 指定磁盘镜像，镜像包括了分区表
    disks = [default_disk] if len(options.disk) == 0 else options.disk
    # 构建拓扑结构，连接各个仿真对象，并指定镜像
    system = createSystem(options.caches,
                          options.kernel,
                          options.bootscript,
                          options.machine_type,
                          disks=disks,
                          mem_size=options.mem_size,
                          bootloader=options.bootloader)

    root.system = system
    if options.kernel_cmd:
        system.workload.command_line = options.kernel_cmd
    else:
        system.workload.command_line = " ".join(kernel_cmd)

    if options.big_cpus + options.little_cpus == 0:
        m5.util.panic("Empty CPU clusters")

    # 指定大小核的模型，可选模型有三种："atomic","timing","exynos"
    # "atomic" 和 "timing" 的差异可以参见 ‘SimObject 章节’，"exynos" 是基于 O3 模型做的 Cortex-A15 模型
    big_model, little_model = cpu_types[options.cpu_type]

    all_cpus = []
    # big cluster
    if options.big_cpus > 0:
        system.bigCluster = big_model(system, options.big_cpus,
                                      options.big_cpu_clock)
        system.mem_mode = system.bigCluster.memoryMode()
        all_cpus += system.bigCluster.cpus

    # little cluster
    if options.little_cpus > 0:
        system.littleCluster = little_model(system, options.little_cpus,
                                            options.little_cpu_clock)
        system.mem_mode = system.littleCluster.memoryMode()
        all_cpus += system.littleCluster.cpus

    # Figure out the memory mode
    if options.big_cpus > 0 and options.little_cpus > 0 and \
       system.bigCluster.memoryMode() != system.littleCluster.memoryMode():
        m5.util.panic("Memory mode missmatch among CPU clusters")


    # create caches
    system.addCaches(options.caches, options.last_cache_level)
    if not options.caches:
        if options.big_cpus > 0 and system.bigCluster.requireCaches():
            m5.util.panic("Big CPU model requires caches")
        if options.little_cpus > 0 and system.littleCluster.requireCaches():
            m5.util.panic("Little CPU model requires caches")

    # Create a KVM VM and do KVM-specific configuration
    if issubclass(big_model, KvmCluster):
        _build_kvm(system, all_cpus)

    # Linux device tree
    if options.dtb is not None:
        system.workload.dtb_filename = SysPaths.binary(options.dtb)
    else:
        system.workload.dtb_filename = \
            os.path.join(m5.options.outdir, 'system.dtb')
        system.generateDtb(system.workload.dtb_filename)

    if devices.have_fastmodel and issubclass(big_model, FastmodelCluster):
        from m5 import arm_fast_model as fm, systemc as sc
        # setup FastModels for simulation
        fm.setup_simulation("cortexa76")
        # setup SystemC
        root.systemc_kernel = m5.objects.SystemC_Kernel()
        m5.tlm.tlm_global_quantum_instance().set(
            sc.sc_time(10000.0 / 100000000.0, sc.sc_time.SC_SEC))

    if options.vio_9p:
        FSConfig.attach_9p(system.realview, system.iobus)

    return root
```

   `root.apply_config` 是根据给定的参数修改仿真对象的配置参数，主要是仿真对象的可配置参数太多，我们不可能每一个都用 `addOption` 加到选项里，那些不在选项里的参数就可以通过 `param` 选项的方式来修改。例如下面这行配置可以把0，1，2，3四个内存控制器的 dram 地址映射都改成 RoCoRaBaCh ：

```shell
--param='system.mem_ctrls[0,1,2,3].dram.addr_mapping="RoCoRaBaCh"'
```

   `instantiate` 是实例化仿真器，如果选项有指定快照，则会同时指定快照。在完成实例化以后，`run` 会调用 `m5.simulate()` 开始仿真。

## 实现仿真模块

### SimObject 仿真对象

   在 GEM5 中几乎所有的仿真对象都继承自 SimObject 对象，包括 CPU、CACHE  或 Memory 等。所以要实现一个仿真模块，一般都会继承这个基类，下面我们会以一个 Memory 对象为例，看如何创建一个自己的仿真模块。

### master and slave ports

   在实现 Memory 对象前，我们要首先明白 GEM5 的 master 和 slave ports ，所有的 Memory 对象都是通过这些 ports 互联，这些接口实现了三种不同的 Memory 子系统的模型：atomic、timing 和 functional ，他们的主要差别如下：

- atomic: 这个模型通常只用于 FS 仿真的 Bring up 阶段，它假设内存子系统之间不会产生任何事件，所有的内存请求都是通过函数调用链来完成，也就不会有精准的时序模型。

- timing: 这是唯一提供了精准时序的模型，所有的内存请求都是通过事件来驱动，尽量模拟真实环境中每个环节的 latency ，也是唯一能产生正确结果的模型，由于速度非常的慢，通常用于 FS 仿真调试完成后的精确仿真。

- functional: 这个模式有时候也叫做调试模式，主要用在 SE 仿真中，例如：从 host 加载二进制程序到仿真器的内存中。

   master 和 slave 的差异，类似于真实世界中总线互联的 master 和 slave 接口的差异。master 可以主动发起请求，而 slave 只能被动响应 master 的请求。下面是我们这个例子的拓扑结构图：

![simple_memobj](./simple_memobj.png)

   图中的 `simple memory object` 就是我们要实现的仿真模块，它有两个 slave ports：data_port 和 inst_port 分别连到 CPU 的 dcache_port 和 icache_port，同时它还有一个 master port：mem_side 则是连到 membus 。所以我们的仿真模块是被动接收 CPU 发出的请求，但是可以主动向 membus 发送请求。

   三种内存模型里，最重要的是 timing 模型，其他两个模型相对简单，所以这里只介绍了 timing 模型的交互模式，具体如下：

![master_slave_1](./master_slave_1.png)

   首先，每次都是 Master 先通过 `sendTimingReq` 函数发出一个请求，对端的 Slave 的 `recvTimingReq` 函数就会被调用，如果 Slave 判断到当前自己可以响应这个请求，就会返回一个 `true` ，然后开始处理这个请求，处理完成之后会调用 `sendTimingResq` 函数来告诉 Master 已经完成，这会触发 Master 的 `recvTimingResq` 函数，如果 Master 可以处理这个响应，则返回 `true` ，至此这个内存请求就算完成了。

   以上这个时序图比较简单，我们没有考虑双方 busy 的情况，如果 Slave 在收到请求时候处于 busy 状态，则需要在 `recvTimingReq`  函数返回 `false` ，并且在退出 busy 状态的时候还需要调用 `sendReqRetry` ，这会同步触发 Master 的 `recvReqRetry` 函数，此时 Master 就可以重新调用 `sendTimingReq` 函数重发请求了，时序图具体如下：

![master_slave_2](./master_slave_2.png)

   反之，如果 Master 在 `recvTimingResq` 的时候处于 busy 状态，则同样需要返回 `false` 给 Slave ，并且在退出 busy 状态的时候，调用 `sendRespRetry` 函数告诉 Slave 可以重发响应了，具体时序图如下：

![master_slave_3](./master_slave_3.png)

### Packets

   在 GEM5 中，所有的 Ports 之间都是通过 Packet 来收发数据，每个 Packet 都有一个 Request 来存放原始请求，其包括：地址和请求类型等信息。同时还有一个 MemCmd 来描述当前命令，在 Packet 的生命周期中，当前命令是会变化，例如：一旦请求得到服务以后，就会从 request 变成 response 命令，下面是常见的 MemCmd 类型：

```c
        InvalidCmd,
        ReadReq,
        ReadResp,
        ReadRespWithInvalidate,
        WriteReq,
        WriteResp,
        WriteCompleteResp,
        WritebackDirty,        // 上级 cache 写回到下级 cache，并且这条 cache 是脏的
        WritebackClean,        // 同时，只是 cache 是干净的，通常是驱逐引发的
        WriteClean,            // cache 写回脏数据到 memory ，并且不从当前 cache 中驱逐
        CleanEvict,
        SoftPFReq,
        SoftPFExReq,
        HardPFReq,
        SoftPFResp,
        HardPFResp,
        WriteLineReq,
        UpgradeReq,
        SCUpgradeReq,           // Special "weak" upgrade for StoreCond
        UpgradeResp,
        SCUpgradeFailReq,       // Failed SCUpgradeReq in MSHR (never sent)
        UpgradeFailResp,        // Valid for SCUpgradeReq only
        ReadExReq,
        ReadExResp,
        ReadCleanReq,
        ReadSharedReq,
        LoadLockedReq,
        StoreCondReq,
        StoreCondFailReq,       // Failed StoreCondReq in MSHR (never sent)
        StoreCondResp,
        SwapReq,
        SwapResp,
        // MessageReq and MessageResp are deprecated.
        MemFenceReq = SwapResp + 3,
        MemSyncReq,  // memory synchronization request (e.g., cache invalidate)
        MemSyncResp, // memory synchronization response
        MemFenceResp,
        CleanSharedReq,
        CleanSharedResp,
        CleanInvalidReq,
        CleanInvalidResp,
        // Error responses
        // @TODO these should be classified as responses rather than
        // requests; coding them as requests initially for backwards
        // compatibility
        InvalidDestError,  // packet dest field invalid
        BadAddressError,   // memory address invalid
        FunctionalReadError, // unable to fulfill functional read
        FunctionalWriteError, // unable to fulfill functional write
        // Fake simulator-only commands
        PrintReq,       // Print state matching address
        FlushReq,      //request for a cache flush
        InvalidateReq,   // request for address to be invalidated
        InvalidateResp,
        // hardware transactional memory
        HTMReq,
        HTMReqResp,
        HTMAbort,
```

### 声明一个仿真对象

   首先我们需要声明一下仿真对象，这样才能在配置文件中去引用它，具体如下：

```python
from m5.params import *
from m5.SimObject import SimObject

class SimpleMemobj(SimObject):    # 首先我们要继承 SimObject
    type = 'SimpleMemobj'         # 指向你要封装的 C++ 类名，参见下一小节 ‘定义仿真类’
    cxx_header = "learning_gem5/part2/simple_memobj.hh" # 指向我们要封装的 C++ 类的头文件，参见下一小节 ‘定义仿真类’

    inst_port = ResponsePort("CPU side port, receives requests")  # slave port，用于连接 CPU 的 icache_port
    data_port = ResponsePort("CPU side port, receives requests")  # slave port，用于连接 CPU 的 dcache_port
    mem_side = RequestPort("Memory side port, sends requests")    # master port，用于连接 membus
```

   代码路径：src/learning_gem5/part2/SimpleMemobj.py

### 定义仿真类

```c++
#include "mem/port.hh"
#include "params/SimpleMemobj.hh"
#include "sim/sim_object.hh"

class SimpleMemobj : public SimObject
{
  private:

  public:
    /** constructor
     */
    SimpleMemobj(SimpleMemobjParams *params);
};
```

   代码路径：src/learning_gem5/part2/simple_memobj.hh

### 定义 slave port

   SimpleMemobj 有两种 ports，用于和 CPU 互联的 slave port，以及用于和 membus 互联的 master port ， 考虑到没有其他类会调用这两种 ports ， 我们就直接在仿真类内部直接定义了，下面先看看 slave port 的定义：

```c++
/**
     * Port on the CPU-side that receives requests.
     * Mostly just forwards requests to the owner.
     * Part of a vector of ports. One for each CPU port (e.g., data, inst)
     */
    class CPUSidePort : public ResponsePort
    {
      private:
        /// The object that owns this object (SimpleMemobj)
        SimpleMemobj *owner;

        /// True if the port needs to send a retry req.
        bool needRetry;

        /// If we tried to send a packet and it was blocked, store it here
        PacketPtr blockedPacket;

      public:
        /**
         * Constructor. Just calls the superclass constructor.
         */
        CPUSidePort(const std::string& name, SimpleMemobj *owner) :
            ResponsePort(name, owner), owner(owner), needRetry(false),
            blockedPacket(nullptr)
        { }

        /**
         * Send a packet across this port. This is called by the owner and
         * all of the flow control is hanled in this function.
         *
         * @param packet to send.
         */
        void sendPacket(PacketPtr pkt);

        /**
         * Get a list of the non-overlapping address ranges the owner is
         * responsible for. All response ports must override this function
         * and return a populated list with at least one item.
         *
         * @return a list of ranges responded to
         */
        AddrRangeList getAddrRanges() const override;

        /**
         * Send a retry to the peer port only if it is needed. This is called
         * from the SimpleMemobj whenever it is unblocked.
         */
        void trySendRetry();

      protected:
        /**
         * Receive an atomic request packet from the request port.
         * No need to implement in this simple memobj.
         */
        Tick recvAtomic(PacketPtr pkt) override
        { panic("recvAtomic unimpl."); }

        /**
         * Receive a functional request packet from the request port.
         * Performs a "debug" access updating/reading the data in place.
         *
         * @param packet the requestor sent.
         */
        void recvFunctional(PacketPtr pkt) override;

        /**
         * Receive a timing request from the request port.
         *
         * @param the packet that the requestor sent
         * @return whether this object can consume the packet. If false, we
         *         will call sendRetry() when we can try to receive this
         *         request again.
         */
        bool recvTimingReq(PacketPtr pkt) override;

        /**
         * Called by the request port if sendTimingResp was called on this
         * response port (causing recvTimingResp to be called on the request
         * port) and was unsuccesful.
         */
        void recvRespRetry() override;
    };
```

   代码路径：src/learning_gem5/part2/simple_memobj.hh

### 定义 master port

```c++
/**
     * Port on the memory-side that receives responses.
     * Mostly just forwards requests to the owner
     */
    class MemSidePort : public RequestPort
    {
      private:
        /// The object that owns this object (SimpleMemobj)
        SimpleMemobj *owner;

        /// If we tried to send a packet and it was blocked, store it here
        PacketPtr blockedPacket;

      public:
        /**
         * Constructor. Just calls the superclass constructor.
         */
        MemSidePort(const std::string& name, SimpleMemobj *owner) :
            RequestPort(name, owner), owner(owner), blockedPacket(nullptr)
        { }

        /**
         * Send a packet across this port. This is called by the owner and
         * all of the flow control is hanled in this function.
         *
         * @param packet to send.
         */
        void sendPacket(PacketPtr pkt);

      protected:
        /**
         * Receive a timing response from the response port.
         */
        bool recvTimingResp(PacketPtr pkt) override;

        /**
         * Called by the response port if sendTimingReq was called on this
         * request port (causing recvTimingReq to be called on the responder
         * port) and was unsuccesful.
         */
        void recvReqRetry() override;

        /**
         * Called to receive an address range change from the peer responder
         * port. The default implementation ignores the change and does
         * nothing. Override this function in a derived class if the owner
         * needs to be aware of the address ranges, e.g. in an
         * interconnect component like a bus.
         */
        void recvRangeChange() override;
    };
```

   代码路径：src/learning_gem5/part2/simple_memobj.hh

### 定义 SimObject 接口

   完成两种 Port 的定义后，我们就可以在 SimpleMemobj 中声明三个 ports 。同时，我们也要声明 SimObject 的纯虚函数 getPort ，这个函数用于在 GEM5 初始阶段通过 ports 连接各个内存对象。新的定义如下：

```c++
class SimpleMemobj : public SimObject
{
  private:

    <CPUSidePort declaration>
    <MEMSidePort declaration>

    /// Instantiation of the CPU-side ports
    CPUSidePort instPort;
    CPUSidePort dataPort;

    /// Instantiation of the memory-side port
    MemSidePort memPort;

  public:
    /** constructor
     */
    SimpleMemobj(SimpleMemobjParams *params);
};
```

   代码路径：src/learning_gem5/part2/simple_memobj.hh

### 实现 SimObject 基础函数

   在 SimpleMemobj 的构造函数中，我们只是简单的调用父类的构造函数，并初始化所有的 ports ，ports 的名字可以是任意字符串，只是习惯上我们更愿意保持和前面 Pyhton 声明时一致，具体如下：

```c++
#include "learning_gem5/part2/simple_memobj.hh"

#include "base/trace.hh"
#include "debug/SimpleMemobj.hh"

SimpleMemobj::SimpleMemobj(SimpleMemobjParams *params) :
    SimObject(params),
    instPort(params->name + ".inst_port", this),
    dataPort(params->name + ".data_port", this),
    memPort(params->name + ".mem_side", this),
    blocked(false)
{
}
```

   同时，我们还需要实现 SimObject 的纯虚函数 getPort ，这个函数有两个参数，其中 if_name 就是这个类的 Python 变量名，所以这个函数里必须根据这个变量名来返回对象，具体如下：

```c++
Port &
SimpleMemobj::getPort(const std::string &if_name, PortID idx)
{
    panic_if(idx != InvalidPortID, "This object doesn't support vector ports");

    // 这些名字必须和前面的 Python 仿真对象声明一致 (SimpleMemobj.py)
    if (if_name == "mem_side") {
        return memPort;
    } else if (if_name == "inst_port") {
        return instPort;
    } else if (if_name == "data_port") {
        return dataPort;
    } else {
        // pass it along to our super class
        return SimObject::getPort(if_name, idx);
    }
}
```

   代码路径：src/learning_gem5/part2/simple_memobj.cc

### 实现 master 和 slave port 函数

   本例中的 slave port 实现非常简单，大多数情况都是直接转发给 SimpleMemobj 对象，具体如下：

```c++
AddrRangeList
SimpleMemobj::CPUSidePort::getAddrRanges() const
{
    return owner->getAddrRanges();
}

void
SimpleMemobj::CPUSidePort::recvFunctional(PacketPtr pkt)
{
    // Just forward to the memobj.
    return owner->handleFunctional(pkt);
}
```

   而 SimpleMemobj 的这些函数实现也很简单，只是直接转发给 membus 而已，具体如下：

```c++
void
SimpleMemobj::handleFunctional(PacketPtr pkt)
{
    // Just pass this on to the memory side to handle for now.
    memPort.sendFunctional(pkt);
}

AddrRangeList
SimpleMemobj::getAddrRanges() const
{
    DPRINTF(SimpleMemobj, "Sending new ranges\n");
    // Just use the same ranges as whatever is on the memory side.
    return memPort.getAddrRanges();
}
```

   代码路径：src/learning_gem5/part2/simple_memobj.cc

### 实现请求接收

   前面我们只实现了简单的 functional 模型，本节我们看看 timing 模型的实现，同样只是做一层简单的转发，即可以认为 SimpleMemobj 这一层没有 latency 存在，CPU 读写的 latency 完全受下一级 membus 的影响。具体如下：

```c++
bool
SimpleMemobj::CPUSidePort::recvTimingReq(PacketPtr pkt)
{
    // 直接转发给 SimpleMemobj
    if (!owner->handleRequest(pkt)) {
        needRetry = true; // 如果 busy 返回 false
        return false;
    } else {
        return true;      // 成功转发返回 true
    }
}
```

```c++
bool
SimpleMemobj::handleRequest(PacketPtr pkt)
{
    if (blocked) {
        // There is currently an outstanding request. Stall.
        return false;
    }

    DPRINTF(SimpleMemobj, "Got request for addr %#x\n", pkt->getAddr());

    // This memobj is now blocked waiting for the response to this packet.
    blocked = true;

    // Simply forward to the memory port
    memPort.sendPacket(pkt);

    return true;
}
```

```c++
void
SimpleMemobj::MemSidePort::sendPacket(PacketPtr pkt)
{
    // Note: This flow control is very simple since the memobj is blocking.

    panic_if(blockedPacket != nullptr, "Should never try to send if blocked!");

    // If we can't send the packet across the port, store it for later.
    if (!sendTimingReq(pkt)) {
        blockedPacket = pkt;
    }
}
```

   代码路径：src/learning_gem5/part2/simple_memobj.cc

### 实现响应接收

   成功发送给 membus 以后，就要等接收到 membus 响应后，再转发给 CPU，具体如下：

```c++
bool
SimpleMemobj::MemSidePort::recvTimingResp(PacketPtr pkt)
{
    // Just forward to the memobj.
    return owner->handleResponse(pkt);
}

bool
SimpleMemobj::handleResponse(PacketPtr pkt)
{
    assert(blocked);
    DPRINTF(SimpleMemobj, "Got response for addr %#x\n", pkt->getAddr());

    // The packet is now done. We're about to put it in the port, no need for
    // this object to continue to stall.
    // We need to free the resource before sending the packet in case the CPU
    // tries to send another request immediately (e.g., in the same callchain).
    blocked = false;

    // Simply forward to the memory port
    if (pkt->req->isInstFetch()) {
        instPort.sendPacket(pkt);
    } else {
        dataPort.sendPacket(pkt);
    }

    // 检查是否有 outstanding 请求需要重发
    instPort.trySendRetry();
    dataPort.trySendRetry();

    return true;
}
```

   代码路径：src/learning_gem5/part2/simple_memobj.cc

### 创建配置文件并执行仿真

   最后，还需要把前面创建的仿真对象加入到编译脚本中，具体如下：

```python
Import('*')

SimObject('SimpleMemobj.py')

Source('simple_memobj.cc')

DebugFlag('SimpleMemobj', "For Learning gem5 Part 2.")
```

   重新编译仿真器后，就可以通过配置文件来搭建一个仿真平台来引用这个仿真对象，并验证最终结果了，下面是具体的配置文件：

```python
""" This file creates a barebones system and executes 'hello', a simple Hello
World application. Adds a simple memobj between the CPU and the membus.

This config file assumes that the x86 ISA was built.
"""

from __future__ import print_function
from __future__ import absolute_import

# import the m5 (gem5) library created when gem5 is built
import m5
# import all of the SimObjects
from m5.objects import *

# create the system we are going to simulate
system = System()

# Set the clock fequency of the system (and all of its children)
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '1GHz'
system.clk_domain.voltage_domain = VoltageDomain()

# Set up the system
system.mem_mode = 'timing'               # Use timing accesses
system.mem_ranges = [AddrRange('512MB')] # Create an address range

# Create a simple CPU
system.cpu = TimingSimpleCPU()

# 创建我们的仿真对象
system.memobj = SimpleMemobj()

# 连接 cpu 和仿真对象
system.cpu.icache_port = system.memobj.inst_port
system.cpu.dcache_port = system.memobj.data_port

# Create a memory bus, a coherent crossbar, in this case
system.membus = SystemXBar()

# 连接仿真对象和 membus
system.memobj.mem_side = system.membus.slave

# create the interrupt controller for the CPU and connect to the membus
system.cpu.createInterruptController()
system.cpu.interrupts[0].pio = system.membus.master
system.cpu.interrupts[0].int_master = system.membus.slave
system.cpu.interrupts[0].int_slave = system.membus.master

# Create a DDR3 memory controller and connect it to the membus
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.master

# Connect the system up to the membus
system.system_port = system.membus.slave

# Create a process for a simple "Hello World" application
process = Process()
# Set the command
# grab the specific path to the binary
thispath = os.path.dirname(os.path.realpath(__file__))
binpath = os.path.join(thispath, '../../../',
                       'tests/test-progs/hello/bin/x86/linux/hello')
# cmd is a list which begins with the executable (like argv)
process.cmd = [binpath]
# Set the cpu to use the process as its workload and create thread contexts
system.cpu.workload = process
system.cpu.createThreads()

# set up the root SimObject and start the simulation
root = Root(full_system = False, system = system)
# instantiate all of the objects we've created above
m5.instantiate()

print("Beginning simulation!")
exit_event = m5.simulate()
print('Exiting @ tick %i because %s' % (m5.curTick(), exit_event.getCause()))
```

## 事件驱动模型

   GEM5 是一个事件驱动的仿真器，通过事件驱动模型可以很方便地模拟时序。下面是就以 GEM5 提供的 SimpleCache 为例，演示一下事件驱动模型的编程方法，代码路径在：src/learning_gem5/part2/simple_cache.cc

   从前面的 Timing 模型的时序图，我们可以看到，CPU 要读写 CACHE 的时候会调用  `recvTimingReq` 函数，下面我们先看看这个函数的实现：

```c++
bool
SimpleCache::CPUSidePort::recvTimingReq(PacketPtr pkt)
{
    DPRINTF(SimpleCache, "Got request %s\n", pkt->print());

    if (blockedPacket || needRetry) {
        // The cache may not be able to send a reply if this is blocked
        DPRINTF(SimpleCache, "Request blocked\n");
        needRetry = true;
        return false;
    }
    // Just forward to the cache.
    if (!owner->handleRequest(pkt, id)) {
        DPRINTF(SimpleCache, "Request failed\n");
        // stalling
        needRetry = true;
        return false;
    } else {
        DPRINTF(SimpleCache, "Request succeeded\n");
        return true;
    }
}
```

   可以看到，SimpleCache 的 slave port 只是直接把 CPU 的请求转发给了 SimpleCache 去处理，我们进一步跟下去看看：

```c++
bool
SimpleCache::handleRequest(PacketPtr pkt, int port_id)
{
    if (blocked) {
        // There is currently an outstanding request so we can't respond. Stall
        return false;
    }

    DPRINTF(SimpleCache, "Got request for addr %#x\n", pkt->getAddr());

    // This cache is now blocked waiting for the response to this packet.
    blocked = true;

    // Store the port for when we get the response
    assert(waitingPortId == -1);
    waitingPortId = port_id;

    // 通过 schedule 函数在指定的 latency 以后触发一个 event ，event 触发后会自动
    // 回调 accessTiming 函数
    schedule(new EventFunctionWrapper([this, pkt]{ accessTiming(pkt); },
                                      name() + ".accessEvent", true),
             clockEdge(latency));

    return true;
}
```

   从上面的代码可以看到，SimpleCache 是通过 schedule 函数来确保在固定的 latency 后产生一个 event ，这里为了方便直接用来 EventFunctionWrapper 这个类来实例化这个 event ，它的构造函数有三个参数，第一个参数是一个回调函数，在 event 触发时会被自动调用。schedule 的第二个参数 clockEdge(latency) 会把 latency 换算成 tick 数，以保证正确的 tick 延迟后触发。下面我们来看一下 accessTiming 函数，具体如下：

```c++
void
SimpleCache::accessTiming(PacketPtr pkt)
{
    bool hit = accessFunctional(pkt);

    DPRINTF(SimpleCache, "%s for packet: %s\n", hit ? "Hit" : "Miss",
            pkt->print());

    if (hit) {
        // Respond to the CPU side
        stats.hits++; // update stats
        DDUMP(SimpleCache, pkt->getConstPtr<uint8_t>(), pkt->getSize());
        pkt->makeResponse();
        sendResponse(pkt);
    } else {
        stats.misses++; // update stats
        missTime = curTick();
        // Forward to the memory side.
        // We can't directly forward the packet unless it is exactly the size
        // of the cache line, and aligned. Check for that here.
        Addr addr = pkt->getAddr();
        Addr block_addr = pkt->getBlockAddr(blockSize);
        unsigned size = pkt->getSize();
        if (addr == block_addr && size == blockSize) {
            // Aligned and block size. We can just forward.
            DPRINTF(SimpleCache, "forwarding packet\n");
            memPort.sendPacket(pkt);
        } else {
            DPRINTF(SimpleCache, "Upgrading packet to block size\n");
            panic_if(addr - block_addr + size > blockSize,
                     "Cannot handle accesses that span multiple cache lines");
            // Unaligned access to one cache block
            assert(pkt->needsResponse());
            MemCmd cmd;
            if (pkt->isWrite() || pkt->isRead()) {
                // Read the data from memory to write into the block.
                // We'll write the data in the cache (i.e., a writeback cache)
                cmd = MemCmd::ReadReq;
            } else {
                panic("Unknown packet type in upgrade size");
            }

            // Create a new packet that is blockSize
            PacketPtr new_pkt = new Packet(pkt->req, cmd, blockSize);
            new_pkt->allocate();

            // Should now be block aligned
            assert(new_pkt->getAddr() == new_pkt->getBlockAddr(blockSize));

            // Save the old packet
            originalPacket = pkt;

            DPRINTF(SimpleCache, "forwarding packet\n");
            memPort.sendPacket(new_pkt);
        }
    }
}
```

   可以看到 SimpleCache 的处理非常简单，只是直接转发给下一级的 Memory ，毕竟只是为了演示事件驱动模型而已，如果要看更贴近真实的 Cache 仿真逻辑，可以参考代码：src/mem/cache 。
