---
title: 源码安装tmux遇到的一些问题
date: 2017-01-30 22:32:19
tags: [tmux] 
categories: 后端开发那些事儿
---
后端开发必备利器：zsh + vim + tmux。下面记录下以前安装tmux时遇到的一些问题，之前写在我的github仓库上，https://github.com/huchangwei/openresty-study#%E6%BA%90%E7%A0%81%E5%AE%89%E8%A3%85tmux%E9%81%87%E5%88%B0%E7%9A%84%E4%B8%80%E4%BA%9B%E9%97%AE%E9%A2%98，
希望对大家有所帮助。
<!--more-->
### clone 源代码仓库：
```
$ git clone https://github.com/tmux/tmux.git
```
### 编译之前先安装libevent，去官网下载tar包：
[http://libevent.org](http://libevent.org)

选择需要下载的版本复制链接地址，使用wget下载到本地（图形化的也可以直接下载），如（选择合适的版本，一般选stable即可）：
```
    wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
```

```
    tar -xzf  libevent-2.0.22-stable.tar.gz
    cd  libevent-2.0.22-stable/
    $ ./configure && make
    $ sudo make install
```

### 编译tmux：
```
    cd tmux/
    sh autogen.sh
   ./configure && make
```
安装编译过程可能会提示一些错误：<br>
#### aclocal command not found
原因：自动编译工具未安装，安装上即可：
```
centOS： yum install automake
```
#### configure: error: "curses or ncurses not found"
```
ubuntu：apt-get install libncurses5-dev
centos: yum install ncurses-devel
```

### 编译成功之后会在tmux下生成一个可执行程序：tmux
```
    ./tmux
```
执行的时候可能会出现找不到库的情况：
```shell
./tmux: error while loading shared libraries: libevent-2.0.so.5: cannot open shared object file: No such file or directory
```
把安装好的libevent库的路径使用软链接到对应的目录：
```
    64位：
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
    32位：
        ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
```

### 设置环境变量
    现在使用tmux必须在编译好的目录下执行才可以，我们设置个环境变量即可：


    ln -s /home/hcw/Package/tmux/tmux /usr/bin/

    /home/hcw/Package/tmux/ 为你编译好的路径，因为/usr/bin/已经添加到系统环境变量，所以不需要再设置，如此即可使用tmux


### 下面是我常用的tmux配置：
```
    wget https://github.com/huchangwei/dotfiles/raw/master/.tmux.conf  -P ~
```

其中需要用到插件管理，需要先安装插件管理器：
[https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
```
    $ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
在.tmux.conf添加：（如果你是使用我的配置，下面可以省略）
```
#List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'git@github.com/user/plugin'
# set -g @plugin 'git@bitbucket.com/user/plugin'
```
```
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
Reload TMUX environment so TPM is sourced:

# type this in terminal
$ tmux source ~/.tmux.conf
```
### 最后看看效果：
 
![t1.png](http://upload-images.jianshu.io/upload_images/3981501-11b15a431dd1ad51.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

