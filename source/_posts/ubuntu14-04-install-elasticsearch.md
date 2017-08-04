---
title: ubuntu14.04安装Elasticsearch
date: 2017-01-17 21:31:08
tags: [ubuntu14, elk, elasticsearch] 
categories: 后端开发那些事儿
---

最近想要为自己写的一个小型服务端搭建个日志管理，服务端使用的是OpenResty框架构建的，主要用来学习和练手（有兴趣的可以看看，适合入门看：https://github.com/huchangwei/orskycloud-openresty.）

做的比较简单，日志管理主要是为了方便查看error日志，ELK是个非常不错的工具，扩展性非常的强，虽然我没有什么实践经验，当然我的服务端其实也没必要用elk，只不过为了体验体验，所以就大材小用了一把。

ubuntu安装ELK网上有很多相关的博客，我这里就不在重复写了，我这里主要记录下安装过程中出现的一些问题，这篇文章记录的是ubuntu14.04安装elasticsearch。

ubuntu安装elasticsearch也有很多种方法，这里主要介绍我安装成功的，其他方法或许更简洁，但是若是读者安装也是跟我一样的或许会遇到同样的错误，这篇文章也许能给你提供些参考。
<!--more-->
首先，我们从官网下载deb包：
（官网：https://www.elastic.co/downloads/elasticsearch）

![e1.png](http://upload-images.jianshu.io/upload_images/3981501-911c05a672fde886.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

直接使用浏览器下载可能会很慢，我一般会copy下载链接，然后wget下来：

![e2.png](http://upload-images.jianshu.io/upload_images/3981501-0941c62f16f341df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

然后使用dpkg命令安装（注意：安装之前确保ubuntu已经安装好了java环境，否则会报错）：

![e3.png](http://upload-images.jianshu.io/upload_images/3981501-d56fb30ca16ed629.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如无意外应该可以安装成功。

接下来就是运行了，这是关键所在，首先我们前往安装目录elasticsearch的安装目录，一般会在：
cd /usr/share/elasticsearch

这个时候如果你直接运行elasticsearch会报以下错误：
 执行：   
bin/elasticsearch
错误信息：

```
Exception in thread "main" org.elasticsearch.bootstrap.BootstrapException: java.nio.file.NoSuchFileException: /usr/share/elasticsearch/config
Likely root cause: java.nio.file.NoSuchFileException: /usr/share/elasticsearch/config ...
```
见图：

![e4.png](http://upload-images.jianshu.io/upload_images/3981501-eb5bf05a5ff631b1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

elasticsearch github上有这个错误的issue（https://github.com/elastic/ansible-elasticsearch/issues/58）
感兴趣的可以看看这个错误的具体原因，我这里主要提供解决方法。

这个错误我觉得主要是因为找不到配置文件，deb包安装好之后配置文件默认在: 
/etc/elasticsearch,
但是如果你直接在安装目录里去启动elasticsearch的话，elasticsearch是不会去/etc找配置文件的，elasticsearch只会在当前目录找config文件夹，如果安装成service的形式应该是可以找到配置文件，但我没去尝试，后面试试。

问题知道了，我们可以直接把/etc目录下的elasticsearch配置文件copy过来：

```
 cp -r /etc/elasticsearch /usr/share/elasticsearch/config
```

这个时候我们再启动就不会报刚才的错误了，我们再试一遍：

``` 
bin/elasticsearch 
```

意料之中，这时候会提示以下错误：

```
[2017-01-17T21:54:48,798][WARN ][o.e.b.ElasticsearchUncaughtExceptionHandler] [] uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.RuntimeException: can not run elasticsearch as root
        at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:125) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:112) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.cli.SettingCommand.execute(SettingCommand.java:54) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:122) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.cli.Command.main(Command.java:88) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:89) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:82) ~[elasticsearch-5.1.2.jar:5.1.2]
Caused by: java.lang.RuntimeException: can not run elasticsearch as root
        at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:100) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:176) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:306) ~[elasticsearch-5.1.2.jar:5.1.2]
        at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:121) ~[elasticsearch-5.1.2.jar:5.1.2]
        ... 6 more

```

这个错误的原因是elasticsearch不允许使用root启动，因此我们要解决这个问题需要新建一个用户来启动elasticsearch(参考：https://my.oschina.net/topeagle/blog/591451?fromerr=mzOr2qzZ)

具体操作如下：

```
➜  ~ groupadd elsearch
➜  ~ useradd elsearch -g elsearch -p elsearch
➜  ~ cd /usr/share  
➜   chown -R elsearch:elsearch elasticsearch 
➜  su elsearch
```

这个时候在这个用户去启动elasticsearch，一般情况下这个时候就能成功起来了，可能还会出现一些错误，如：

```
hcw-X450VC% ./elasticsearch
2017-01-17 21:03:31,158 main ERROR Could not register mbeans java.security.AccessControlException: access denied ("javax.management.MBeanTrustPermission" "register")
    at java.security.AccessControlContext.checkPermission(AccessControlContext.java:472)
    at java.lang.SecurityManager.checkPermission(SecurityManager.java:585)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.checkMBeanTrustPermission(DefaultMBeanServerInterceptor.java:1848)
    at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.registerMBean(DefaultMBeanServerInterceptor.java:322)
    at com.sun.jmx.mbeanserver.JmxMBeanServer.registerMBean(JmxMBeanServer.java:522)
    at org.apache.logging.log4j.core.jmx.Server.register(Server.java:389)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:167)
    at org.apache.logging.log4j.core.jmx.Server.reregisterMBeansAfterReconfigure(Server.java:140)
    at org.apache.logging.log4j.core.LoggerContext.setConfiguration(LoggerContext.java:541)
    at org.apache.logging.log4j.core.LoggerContext.start(LoggerContext.java:258)
    at org.apache.logging.log4j.core.impl.Log4jContextFactory.getContext(Log4jContextFactory.java:206)
    at org.apache.logging.log4j.core.config.Configurator.initialize(Configurator.java:220)
    at org.apache.logging.log4j.core.config.Configurator.initialize(Configurator.java:197)
    at org.elasticsearch.common.logging.LogConfigurator.configureStatusLogger(LogConfigurator.java:125)
    at org.elasticsearch.common.logging.LogConfigurator.configureWithoutConfig(LogConfigurator.java:67)
    at org.elasticsearch.cli.Command.main(Command.java:85)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:89)
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:82)

```

这是因为elasticsearch需要读写配置文件，我们需要给予config文件夹权限，上面新建了elsearch用户，elsearch用户不具备读写权限，因此还是会报错，解决方法是切换到管理员账户，赋予权限即可：

```
sudo -i
chmod -R 775 config
```
这个时候就可以起来了，来看看效果：



![e5.png](http://upload-images.jianshu.io/upload_images/3981501-1b56b3a873ad2a37.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



在浏览器查看：

![e6.png](http://upload-images.jianshu.io/upload_images/3981501-4a10d519c1877c9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

到这里为止，ubuntu安装elasticsearch就完成了，接下来怎么玩耍就看各位看官的心情啦！

文章错漏之处或有其他建议欢迎评论交流，大家共同进步，谢谢！
