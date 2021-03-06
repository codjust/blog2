---
title: 浅析进程与线程
date: 2017-03-07 22:52:33
tags: [操作系统] 
categories: 基础知识
---
![进程与线程.png](http://upload-images.jianshu.io/upload_images/3981501-20c7eb4c3c1ed335.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
进程与线程的概念经常遇到，虽然脑海里是知道怎么回事，编程开发也能写出多进程、多线程的程序，但是对于理论上的描述一直不是很明确，今日闲暇，找到了以前的书籍，好好的看了一遍，记录下进程、线程简单的理论概念。
<!--more-->
操作系统的教材里面进程一章的内容还是很多的，描述的相当详细，但是对于开发者而言，知道其核心的概念即可解答常见的进程相关的问题，如果需要深究的，再去翻阅文献也是可以的。

### 进程的定义
进程的实体是由：程序段、相关的数据段和PCB 三部分构成的。其中，进程实体其实就是我们常说的进程，因此，创建进程，其实就是创建进程实体中的PCB，撤消进程也就是撤消进程的PCB。

归结一下常见的进程的定义：

```
（1）进程是程序的一次执行
（2）进程是具有独立功能的程序在一个数据集合上运行的过程，它是系统进行资源分配和调度的一个独立单元。
（3）进程是一个程序及其数据在处理机上顺序执行时所发生的活动。
```

这里顺便介绍一下进程和程序的区别：

```
（1）程序是永存的；进程是暂时的，是程序在数据集上的一次执行，有创建有撤销，存在是暂时的；
（2）程序是静态的观念，进程是动态的观念；
（3）进程具有并发性，而程序没有；
（4）进程是竞争计算机资源的基本单位，程序不是。
（5）进程和程序不是一一对应的： 一个程序可对应多个进程即多个进程可执行同一程序； 一个进程可以执行一个或几个程序
```

进程和程序是两个截然不同的概念，除了进程具有程序所没有的PCB结构外，还具有一下特征：

```
（1）动态性
（2）并发性
（3）独立性
（4）异步性
```
### 进程的状态
进程一般具备三种状态：

```
（1）就绪态。即进程处于准备好运行的状态，进程已分配到除CPU以外的所有资源
（2）执行态，进程已获得CPU，其程序正在执行的状态
（3）阻塞态，正在执行的进程由于发生某事件（如IO请求等）暂时无法继续执行时的状态
```

状态转换图：


![状态转换图.png](http://upload-images.jianshu.io/upload_images/3981501-6665b0cf664247ca.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

图中的创建状态和退出是进程的开始和终止这里不再解释。

### 进程的PCB
OS为每个进程专门定义了一个数据结构--进程控制块（Process Control Block）PCB，用于描述进程的当前情况以及管理进程运行的全部信息，是OS最重要的记录型数据结构，线程与之相对的是TCB（下文介绍）。

PCB的作用：

```
（1）作为独立运行基本单位的标志。当一个程序（含数据）配置了PCB后，就表示它是一个能在多道程序环境下独立运行的、合法的基本单位。当系统创建一个进程时，就为它创建了一个PCB，进程结束时又回收其PCB，进程于是也随之消灭，即系统是通过PCB感知进程的存在的。
（2）能实现间断性运行方式。当进程因阻塞而暂停运行时，可以将CPU现场信息等保存在PCB中，供该进程再次被调度时恢复现场使用。
（3）提供进程管理所需要的信息。
（4）提供进程调度所需要的信息。
（5）实现与其他进程的同步与通信
```

### 线程的定义
线程，有时被称为轻量级进程(Lightweight Process，LWP），是程序执行流的最小单元。
一个标准的线程由线程ID，当前指令[指针]，[寄存器]集合和[堆栈]组成。

另外，线程是进程中的一个实体，是被系统独立调度和分派的基本单位，线程自己不拥有系统资源，只拥有一点儿在运行中必不可少的资源，但它可与同属一个进程的其它线程共享进程所拥有的全部资源。

和进程一样，线程同样有三种状态：执行状态、就绪状态、阻塞状态，线程之间的转换与进程一样的，这里不再赘述。

系统同样为线程分配了一个线程控制块TCB，将所有用于控制和管理线程的信息记录在线程控制块中，TCB通常包括：

```
（1）线程标示符 （2）一组寄存器 （3）线程运行状态 （4）优先级 （5）线程专有存储区 （6）信号屏蔽
```

### 线程与进程的区别
进程是资源分配的基本单位。所有与该进程有关的资源，都被记录在进程控制块PCB中，以表示该进程拥有这些资源或正在使用它们。
另外，进程也是抢占处理机的调度单位，它拥有一个完整的虚拟地址空间。当进程发生调度时，不同的进程拥有不同的虚拟地址空间，而同一进程内的不同线程共享同一地址空间。

与进程相对应，线程与资源分配无关，它属于某一个进程，并与进程内的其他线程一起共享进程的资源。

线程只由相关堆栈（系统栈或用户栈）寄存器和线程控制表TCB组成。寄存器可被用来存储线程内的局部变量，但不能存储其他线程的相关变量。

通常在一个进程中可以包含若干个线程，它们可以利用进程所拥有的资源。在引入线程的操作系统中，通常都是把进程作为分配资源的基本单位，而把线程作为独立运行和独立调度的基本单位。

由于线程比进程更小，基本上不拥有系统资源，故对它的调度所付出的开销就会小得多，能更高效的提高系统内多个程序间并发执行的程度，从而显著提高系统资源的利用率和吞吐量。

因而近年来推出的通用操作系统都引入了线程，以便进一步提高系统的并发性，并把它视为现代操作系统的一个重要指标。

线程与进程的区别可以归纳为以下4点：

```
1）地址空间和其它资源（如打开文件）：进程间相互独立，同一进程的各线程间共享。某进程内的线程在其它进程不可见。
2）通信：进程间通信，IPC，线程间可以直接读写进程数据段（如全局变量）来进行通信——需要进程同步和互斥手段的辅助，以保证数据的一致性。
3）调度和切换：线程上下文切换比进程上下文切换要快得多。
4）在多线程OS中，进程不是一个可执行的实体。

```


关于线程和进程的概念简单介绍到这里，有个基本的认识即可。

欢迎大家评论一起交流。

