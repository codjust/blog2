---
title: 使用supervisor管理beego应用
date: 2017-01-05 22:41:04
tags: [supervisord, beego] 
categories: 后端开发那些事儿
---
开源中国原文：https://my.oschina.net/spotless/blog/818857

使用beego开发的应用一般会涉及多个进程，如http服务、redis-server（或mysql等数据库），如果使用nginx做反向代理还需要配置nginx，这样应用每次启动都要依次去开启每个服务非常的麻烦，而且如果redis、http挂了还需要手动去重启，虽然可以写个脚本代替上面这些工作，但是我们有supervisor这个现成的工具可以解决以上问题。
<!--more-->
supervisor是linux后台进程管理的一大利器，如果是一个服务程序，要可靠地在后台运行，我们就要把它做成daemon，最好还能监控进程状态，在意外结束时能自动重启。在ubuntu14.04上安装supervisor,其他平台大同小异：

```
sudo apt-get install supervisor
```
可以运行

```
echo_supervisord_conf > /etc/supervisord.conf
```
生成默认的配置文件。

我们打开配置文件，添加我们要管理的进程，这里以我的应用为例，总共有三个进程：
beego、nginx、redis-server，而且redis-server必须比beego先启动，复制beego启动连接redis失败会报错，下面是配置文件的内容：supervisord.conf:

```
[unix_http_server]
file=/tmp/supervisor.sock   ; (the path to the socket file)
[inet_http_server]             ; inet (TCP) server disabled by default
port=127.0.0.1:9001        ;  这个是配置web界面的端口和地址
username=user              ; 登录web用的用户名和密码
password=123               ; (default is no password (open server))
[supervisord]
logfile=/tmp/supervisord.log ; (main log file;default $CWD/supervisord.log)
logfile_maxbytes=50MB       ; (max main logfile bytes b4 rotation;default 50MB)
logfile_backups=10             ; (num of main logfile rotation backups;default 10)
loglevel=info                        ; (log level;default info; others: debug,warn,trace)
pidfile=/tmp/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
nodaemon=false               ; (start in foreground if true;default false)
minfds=1024                  ; (min. avail startup file descriptors;
minprocs=200                 ; (min. avail process descriptors;default 200)
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
[program:openresty]
command=/opt/openresty/nginx/sbin/nginx -p /home/hcw/workdir/orskycloud-openresty/nginx/main_server   ;nginx的执行目录和对应的配置文件
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
numprocs=1                  ; number of processes copies to start (def 1)
priority=1                       ;  设置启动的优先级为第一
autostart=true               ;  设置supervisord启动nginx自动启动
startsecs=10                ; # of secs prog must stay up to be running 
startretries=3                ; max # of serial start failures when starting 
autorestart=true           ; 设置nginx错误退出自动重启
user=root
[program:redis-server]
command=/usr/bin/redis-server  /etc/redis/redis.conf  
process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
priority=2                         ;  配置redis启动优先级，这里一定要比beego的小
autostart=true                ; start at supervisord start (default: true)
startsecs=10                   ; # of secs prog must stay up to be running 
user=root
startretries=3
autorestart=true
[program:webadmin-beego]
command=/home/go/src/orskycloud-go/main   ;beego执行程序，这是我的示例
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
numprocs=1                    ; number of processes copies to start (def 1)
directory=/home/go/src/orskycloud-go      ;  注意，这个是进程的工作目录，beego是web应用要把工作目录指定，否则网页找不到静态资源
;umask=022                     ; umask for process (default None)
priority=3                         ; the relative start priority (default 999)
autostart=true                ; start at supervisord start (default: true)
autorestart=true
```
保存好上述配置之后，启动supervisotd服务：

```
supervisord  -c /etc/supervisord.conf
```
指定上述的配置文件即可启动。

服务启动之后可以使用 :

```
supervisorctl
```
进入客户端，常用的操作有：reload  start stop
等，当你修改了配置文件之后可以直接在客户端reload一下即可重新载入配置文件，不需要去重启服务。

supervisord常见的进程状态：RUNNING 、BACKOFF 、STARTING 、FATAL，详细的介绍可以查看官方的文档：http://supervisord.org/subprocess.html#process-states；
其中FATAl常见的错误是：

```
FATAL Exited too quickly
```
这是因为supervisor管理的进程必须在前台运行，不能以daemon的形式，否则无法管理，类似nginx需要在配置文件里加上：

```
daemon off;
```
redis需要在把配置文件的：

```nginx
daemonize no
```
不能设置为yes，否则就会出现上述的错误。

不明白的可以查阅我的github上的docker的配置：https://github.com/huchangwei/orskycloud-docker/blob/master/orskycloud/supervisord.conf

有疑惑之处欢迎留言。