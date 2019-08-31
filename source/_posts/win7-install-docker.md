---
title: 使用docker搭建游戏私服之win7下部署docker环境
date: 2017-09-24 21:51:01
tags: [docker,win7]
categories: 服务端开发
---
最近在忙着搭建游戏私服的事情，因此前面的关于游戏业务篇师徒系统的内容会迟一点写，这个坑怎么说都还是要填的，不要错过任何一次记录的机会。

简单介绍一下搭建游戏私服的需求，这主要是给策划和测试使用的，因为每个策划关注的内容，每个测试测试的点都不一样，都需要去修改测试服务器的配置或者策划表，以达到他们想要测试或验证的目的，这就不能都在一台测试服去频繁改动，当然也不可能为每个策划或者测试都配一台服务器（不要钱呀）。那么可不可以在他们的机器去搭建环境，在他们自己的机器部署游戏服务器呢？当然是可以的，不过这会搞死程序（O(∩_∩)O），比如说我们的游戏服务器使用的java，你感受到了为那么多个策划测试去部署java环境以及服务器依赖的组件的恐怖了吗！！！

真要这么做会有很多后续问题需要程序去收尾，这当然不是我们想要做的，于是我在接受到这个需求的时候立马想到了可以使用Docker解决这个问题，只要在机器上部署好了Docker环境，游戏服务器打包成docker镜像，需要使用的时候载入即可，镜像里面就是完整的游戏服务器内容，只依赖docker环境，不依赖其他任何外部条件，这样我们需要做的工作就是为策划的机器搭建docker环境，以及发布我们的游戏服镜像。
<!--more-->
既然使用了docker，为什么要在windows下使用呢？因为策划测试用的都是windows呀（O(∩_∩)O），镜像还是会发布在linux。

docker是什么？docker的应用以及非常广了，就不再这里介绍了，不知道的同学可以看看这个：http://www.docker.org.cn/book/docker/what-is-docker-16.html

本文主要介绍的在win7安装时遇到的问题以及简单使用。

![docker.png](http://upload-images.jianshu.io/upload_images/3981501-9b0d194ee2e13e13.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 1 下载与安装Docker Toolbox
首先介绍一下docker在windows的支持，引用Docker 中文指南的描述：
```
因为Docker 引擎使用的是Linux内核特性，所以我们需要在 Windows 上使用一个轻量级的虚拟机 (VM) 来运行 Docker。我们使用 Windows的Docker客户端来控制 Docker 虚拟化引擎的构建、运行和管理 。
为了简化这个过程，我们设计了一个叫 Boot2Docker 的应用程序，你可以通过它来安装虚拟机和运行 Docker。
虽然你使用的是 Windows 的 Docker 客户端，但是 docker 引擎容器依然是运行在 Linux 宿主主机上（现在是通过Virtual box）。
```
目前docker对win10的支持已经做的很好了，但是对于低版本的win7相对来说还是有很多问题，win10直接下载https://www.docker.com/docker-windows Docker for Windows直接安装即可，但是win7的安装方法完全不同。

首先我们需要下载官方提供的Docker Toolbox安装包，地址为：https://www.docker.com/products/docker-toolbox
该安装包含了所需要的所有内容。

然后点击安装，出现如图示：
![安装界面1.png](http://upload-images.jianshu.io/upload_images/3981501-a2df9bf080600c04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![安装界面2.png](http://upload-images.jianshu.io/upload_images/3981501-442c56ef554d0edd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

安装路径可以选择其它盘，我安装在了D盘。
![安装界面3.png](http://upload-images.jianshu.io/upload_images/3981501-b27dcaa47349b5ed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这是安装包具备的组件，其中Docker client，Docker Machine是一定要安装的，Virtualbox和Git如果事先安装了可以不勾，不过virtualbox需要5.0版本以上，版本4是不行的，Kitematic是Docker的图形化管理界面，也勾上吧，虽然我不用。

![安装界面4.png](http://upload-images.jianshu.io/upload_images/3981501-ca717aad103a7990.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后一直Next，点finish就完成了安装。

### 2 初始化Docker ToolBox
安装完毕后会在桌面出现三个快捷方式：

![快捷方式](http://upload-images.jianshu.io/upload_images/3981501-aa06f098d2f16b57.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中Docker Quickstart Terminal是初始化脚本，可以去安装目录查看所有的组件：

![安装目录.png](http://upload-images.jianshu.io/upload_images/3981501-1df00fe217c96c9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

里面的start.sh就是桌面上的Docker Quickstart Terminal，可以看到是这是一个shell脚本，也就是需要bash来执行，因此在安装的时候如果win7没有安装Git的话一定要勾上，并且记住其安装位置，一般会在：

![bash](http://upload-images.jianshu.io/upload_images/3981501-3cbaae0e9cadc8ec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在执行这个脚本之前，我们先打开该脚本简单看看其做了什么事：

![start.sh.png](http://upload-images.jianshu.io/upload_images/3981501-e8291c5b8eb2314f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

简单理解一下发现脚本主要初始化了各个工具的状态，以及设置了代理，其中virtualbox是第一个被检查的，因为需要通过VBoxManage创建虚拟机，因此在执行脚本之前我们先看看virtualbox是否正常，打开桌面的：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-f89b9bf79e9582a7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果出现下图所示

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-f469f7bebe419d07.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

那么恭喜你，可以进入下一步执行脚本了。（第一次的打开是都没有的，只要打开不报错就表示虚拟机没问题）
但是有部分机器可能会出现一些错误，比如我的机器就出现了：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-524a3bae5fc89bea.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

获取 VirtualBox COM 对象失败，应用程序将被中断。
这个错误的解决方法有几种，
（1）兼容性问题

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-f15049ba2d63e0c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

右击virtualbox图标属性中，兼容模式运行这个程序，选择除了win7之外的版本。

（2）a. 打开开始菜单----然后点击运行---输入
```"D:\Program Files\Oracle\VirtualBox\VBoxSVC.exe“  /reregserver```
然后按回车，（注意virtualbox的安装目录,我这里安装在D:\Program Files\Oracle\VirtualBox目录,视情况而定，改成自己的目录）
b.再打开开始菜单---运行---输入
```regsvr32 "C:\Program Files\Oracle\VirtualBox\VBoxC.dll"```
regsvr32如果提示不存在可以去找一下自己系统的存放路径，使用绝对路径来使用，一般会在：
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-6eec7f59de89a6bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

（3）修改注册表，一般这个方法是最有效的
引用这位博主的博文：http://blog.csdn.net/zp_00000/article/details/70207445

主要是修改修改注册表中如下的两项：
```
HKEY_CLASSES_ROOT\CLSID\{00020420-0000-0000-C000-000000000046}
HKEY_CLASSES_ROOT\CLSID\{00020424-0000-0000-C000-000000000046}
```
分别修改上面两项中的 InprocServer32的默认值为
```
C:\Windows\system32\oleaut32.dll
```
具体操作可以跳转到上面链接，我这里就不赘述了。

virtualBox可以正常运行之后我们点击执行启动脚本，可以点击桌面上的快捷方式也可以点击start.sh，我启动的是桌面的，
启动后如图示;

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-52c1a7eb1ad549df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这个过程会提示创建虚拟机，ssh等内容，在创建虚拟机过程时需要提供boot2docker.iso镜像，路径默认是在

```
C:\Users\用户名\.docker\machine\cache
```

启动脚本时会提示找不到，需要在线下载，这个过程会非常慢，其实Docker ToolBox安装包是已经提供了boot2docker.iso了的，

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-6be296b776a4615a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们只要手动将该文件拷贝到指定目录再重新去启动就不需要再联网下载了。

可能还会有同学拷贝了boot2docker.iso镜像，启动脚本时会提示该镜像不是最新的版本，并且会告诉你最新的版本，还是需要联网下载，这个如果是在外网搭建的话就直接让其联网下载，不过可能会很慢，因为我是在内网搭建，所以需要在外网下载好最新的boot2docker.iso镜像，再拷贝到

```
C:\Users\用户名\.docker\machine\cache
```

下载路径为：https://github.com/boot2docker/boot2docker/releases
选择最新的：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-9dc639189e1b6018.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

再次启动start.sh脚本，这个时候等待其初始化完毕即可，应该不会再遇到什么问题了，最后初始化成功如下：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-15232fac95eb02eb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 3 关注的概念
上面的步骤已经完成了docker在win7上的安装，现在已经可以使用了，在使用之前我们先理清楚需要经常关注的几个概念，Linux上使用docker和win7还是有区别的，主要是平台的问题。

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-be751e23a493db87.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先，我们的docker daemon是运行在virtualBox虚拟机上的，virtualbox安装了boot2docker Linux，里面集成了Docker引擎，win7主机上安装了Docker client，可以执行docker命令：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-785430d02e9d842c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

但是是不能直接访问docker Daemon的：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-5f1fbd094150d889.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

你很容易会想到，要想在win7的终端使用docker 操作镜像容器只需要通过ssh连接上虚拟机就可以实现我们想要的操作，就像连接远程服务器一样，boot2docker默认的账户和密码是docker, tcuser，虚拟机的ip为192.168.99.100如图示：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-9593cc2413e8e9bf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

但是这样做和直接在虚拟机安装linux，再安装docker也没什么区别是吧，为了简化这个过程，Docker官方提供了一个强大的工具：docker-machine

官方描述：
```
Docker Machine so you can run Docker Engine commands from Windows terminals
```
docker-machine 主要用于管理虚拟机，包括虚拟机的创建、删除、环境变量设置以及可以直接连接到虚拟机进行对docker的操作。

我们通过使用windows的powershell来尝试下docker-machine命令，（dos的cmd实在体验太差了），“windows” + r，输入运行程序：powershell。

比如查看当前的docker虚拟机的状态：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-856fcd6000dfd181.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

可以看到当前有一台名为default的docker虚拟机在运行，设备为virtualbox，并且其ip为192.168.99.100。

查看docker虚拟机的ip可以直接通过
```
docker-machine ip
```

![提示.png](http://upload-images.jianshu.io/upload_images/3981501-94dac1d989ee4ef2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在本机访问docker里面的服务不能直接通过127.0.0.1，需要通过虚拟机的ip来访问。

查看虚拟机的环境变量：
```
docker-machine env default
```


![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-a690336d99cbe78e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

由上面命令的提示可以知道，可以通过
```
docker-machine env default | Invoke-Expression
```
命令建立powershell与linux虚拟机的连接，就像通过ssh连接一样，但是不用通过密码验证，这个时候就可以在windows终端直接使用docker命令了：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-59b007b246d7a747.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

到了这里你应该知道要想部署镜像只需要写一个powershell脚本就能满足需求了吧（^_^）。

### 4 使用示例
docker环境搭建好之后，我们来跑一个web容器，然后在win7本地浏览器访问试试，在外网可以直接通过
```
docker pull nginx
```
拉取nginx镜像，我的已经拉好了，然后通过载入镜像，运行容器
```
docker run --name some-nginx -d -p 8080:80 nginx
```
-name 表示给容器取别名，用于区分，名字不能重复

-d 表示容器在后台运行

-p 表示映射本地端口8080到容器的80端口，注意这里的本地指的是虚拟机ip，不是127.0.0.1

然后我们在本地浏览器访问：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-7510932cddb73a49.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 5 映射本地目录到容器
前面提到，策划测试需要频繁去改动静态文件，比如策划表，改改道具的数量，属性等，所以需要将容器的目录映射到windows的本地文件夹，这个目录假设用来存放策划表，那么就可以实现在windows查看修改文件，而服务运行在docker容器。

docker提供了数据卷来达到映射的目的，通过-v选项指定，如果是在Linux上使用docker，比如想要映射本地/home/tmp目录到容器的/tmp，可以这样:
```
docker run --name some-nginx  -v /home/tmp:/tmp -d -p 8080:80 nginx
```

但是在windows能不能直接在powershell直接通过-v指定本地目录呢？比如
```
 docker run -ti  -v /d/users:/tmp centos /bin/bash
```
映射d盘的users目录，这样能达到映射的目的吗？答案肯定是不行的，为什么呢？因为容器是运行在virtualbox虚拟机内的，指定的 /d/users目录virtualbox是不知道的，它无法识别。

玩过虚拟机的都知道要想虚拟机和主机共享目录需要对虚拟机进行设置，将主机的目录共享到虚拟机的某个目录，这也是目录映射，然后再将该目录映射到容器，这样就达到映射本地目录到容器的目的。

我们打开virtualbox，点击“”设置“，再点击“共享文件夹”，点击右边的“+”标志

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-4f42fbeafcbab417.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后设置共享文件夹的路径和名称，并且选择“自动挂载”和固定分配，然后在这个设置的共享目录里面就可以随意创建想要的目录，然后映射到容器了。

有同学不禁会问这个还要去打开图形界面设置共享文件夹很麻烦，Docker Toolbox安装完成是默认共享了c/Users到虚拟机的，所以不想重新设置可以映射/c/Users的目录，像我需要在部署的时候直接通过运行脚本的形式运行容器，就不会再去重新设置了，虽然也可以通过VBoxManage命令来直接创建共享文件夹，但是不再去研究这个了，/c/Users已经可以满足需求。

来试试：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-11340a573db913f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在Users创了Docker的目录，并新建了cv.txt文件，然后挂载到容器：
```
docker run -ti  -v /c/Users/docker:/home centos /bin/bash
```
-t 表示开启伪终端
-i 表示打开标准输入
/bin/bash 表示运行bash程序

执行成功之后会直接进入centos容器内部，然后我们去/home看看能不能找到cv.txt文件：
![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-6efb1542a251e98e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

发现cv.txt文件出现了容器的home目录下，然后在该目录创建一个文件，
```
     touch test.sh
```

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-6d1edcba0bfae377.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

再看windows目录下的变化：

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/3981501-120e06d622c90d9a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

大功告成！

结语：
ok，到此为止就介绍完毕了搭建过程，写的有点啰嗦，有同学可能会觉得你这个整个过程下来也是很麻烦呀，是的，第一次安装的时候确实需要费点时间的，但是只要把常见的错误总结下，安装完Docker Toolbox安装包之后的行为，可以通过脚本去控制所有的操作，这样部署docker环境策划只需要安装一个软件，执行一个脚本，以后更新游戏服的时候只需要拉取一下服务器上的镜像或者通过其他的形式去更新，这种简捷只有你真正用过了才会领略到，关于使用docker还有诸多好处，在这就不一一列举了，实在是表达能力不太好呀。

接下来还会介绍配置基础环境镜像，以及最后整个基于Docker私服的搭建过程，嗯，在这里又埋了一个坑了，一定会填的O(∩_∩)O。

以上是在win7部署docker的过程，希望对大家有所帮助，有什么问题可以留言讨论，大家一起学习。

Regards,
codejust.

参考文章：
http://blog.csdn.net/tina_ttl/article/details/51372604
http://www.jianshu.com/p/d809971b1fc1
http://www.cnblogs.com/studyzy/p/6113221.html
https://bjddd192.github.io/docker/2017/02/28/win7%E4%B8%8B%E4%BD%BF%E7%94%A8docker-toolbox.html
http://www.widuu.com/chinese_docker/installation/windows.html