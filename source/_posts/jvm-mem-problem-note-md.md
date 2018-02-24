---
title: jvm内存泄漏问题排查分析笔记
date: 2018-02-24 10:25:00
tags: [jvm,内存泄漏] 
categories: 后端开发那些事儿
---
当发现服务器可能存在内存泄漏时（怎么发现？频繁gc但是堆内存降不下来，进程内存爆了就有可能是发生内存泄漏了），怎么去定位发生的原因以及解决的方法。

首先，在分析内存前可以先通过代码猜测一下可能存在内存泄漏的部分，因为线上要想拿到dump下来的出问题的服务器的内存文件一般会耗时很久，这个时间我们可以通过分析最近的版本更新内容、或者有没有新添加的代码导致了内存泄漏，这个可以通过查看svn或者git的提交，内存泄漏的问题也可能是跨版本的，比如更新的版本1出现的内存泄漏，但是内存增长很缓慢，到版本2停服更新前都没有暴露，然后版本2维护的时间比版本1要长一些，结果内存增长到瓶颈就挂了，当然这是比较特殊的情况。更多的还是当前版本更新的内容引起的。
<!--more-->
java服务器我们可以让运维使用：

```
jmap -histo:live pid 
```

命令，打印出异常进程的对象数量信息，同时找一个线上正常的进程的做对比，找出对象数量明显异常的对象，jvm gc无法回收的最大可能性就是存在大量强引用的异常对象，并且这些对象持续增长，因为某些原因没有被回收导致堆内存一直增加直到达到设置参数的极限。

如下图所示：
![image.png](http://upload-images.jianshu.io/upload_images/3981501-951ca6e123bea61c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



终端分屏的上面为异常的对象数量，下方为正常的，可以非常明显的看出这个对象数量肯定是存在问题的，于是我们可以基本定位到这个类的代码存在漏洞。然后引用也有可能是联动的，就是一个对象数量的增长会带动另外一个对象数量同样增长，因为对象1引用了对象2，对象1不释放，那么对象2同样也不会释放，所以我们在找寻异常对象时同样需要判断该对象是不是源头，是不是是被带动增长的。

这个需要怎么判断呢？每个服务端肯定会有一个数据实体的，当请求服务端时需要构造这么一个对象，这里以游戏服务端为例，在游戏服务端里面就是一个Player对象，玩家相关的模块都会挂在这个对象上面，那么其实我们首先需要观察的就是该对象数量是否异常，如果该对象数量明显不对，那么这个异常一般跟该对象的行为有关，因为即使相关模块出问题，很难反过来影响该对象的增长，如果有那就更好找了，没有则再继续分析。

如我们上面的分析，可以发现ActivityService这个对象数量不对，而且这个也是跟Player对象有关系的，那么我们就可以从这里入手。如果你在查阅ActivityService这个类的代码已经发现问题所在，那么当然是皆大欢喜，但是如果仍旧无法定位或者依旧存疑，那么这个时候内存应该dump下来了，我们可以通过分析内存进一步确认问题的原因。

dump内存可以使用指令：

```
jmap -dump:live,format=b,file=heap.bin <pid>
```

分析内存我们可以使用MAT（Memory Analysis Tools）工具，MAT工具的安装和使用网上已经有很多教程了，就不赘述了，该工具功能非常强大，是分析Java堆内存的利器。

我们先用MAT打开dump下来的二进制文件，然后点击 Histogram，查看内存中的对象数量：
![image.png](http://upload-images.jianshu.io/upload_images/3981501-5718a80aca67d049.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



我们先看我们首要怀疑的Player对象，可以看到目前有14437个对象，这个对象是否正常我们对比正常服的情况，这里明显是不对的，因此我们通过
MAT工具找到这些Player对象为什么不会被回收：

![image.png](http://upload-images.jianshu.io/upload_images/3981501-eafe4a127222a577.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

先分类一下该对象的引用，得出下图结果：
![image.png](http://upload-images.jianshu.io/upload_images/3981501-77d5d21f36d628ba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可以发现只有2个软引用的Player对象，其余的都是GC ROOT，如果存在GC ROOT，对象就不会被回收。

然后我们继续跟踪这些对象是被什么强引用：

![image.png](http://upload-images.jianshu.io/upload_images/3981501-4c82c35ee4518dd8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


得到的结果是：
![image.png](http://upload-images.jianshu.io/upload_images/3981501-b188f2a0d7027dc3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如图可知，有14425的定时器在引用着这些Player对象，因为这些future没有在执行完毕或者在玩家下线等条件去移除，导致这些定时器一直存在，这个时候问题的根源就找到了，至于怎么去定位更细节的问题产生原因，这个就涉及具体的业务细节了。

当然MAT的功能肯定不止这些，我们通过该工具查看到这些对象在内存中具体的值，
![image.png](http://upload-images.jianshu.io/upload_images/3981501-42707eb37ca1f9cc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
如里面的每个task的内容都可以查看到，同时还可以对比对象，这个工具非常好玩，有待继续挖掘！

希望对你有所帮助。

Regards，
codjust
