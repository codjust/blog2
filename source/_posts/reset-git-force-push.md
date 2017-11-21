---
title: 记一次git push -f 后的回滚操作
date: 2017-10-31 22:32:08
tags: [git] 
categories: 后端开发那些事儿
---

![c695382b4b441bd7fc1ebd082506a8d4.png](http://upload-images.jianshu.io/upload_images/3981501-6c912ed8bebc348a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们的内网有使用gitlab作为我们的版本控制工具，最近组里出现了一次误操作，没有更新服务器的代码到本地仓库，直接使用git push -f 强制将本地的修改覆盖了远程仓库的版本，将其他人的commit都给冲掉了，而且无法使用通常的git reset方式回滚，因为使用 git log查看远程仓库的提交历史已经没有其他同事在这之前提交的commit记录了。
<!--more-->
一般遇到这种情况，如果同事A将本地覆盖了远程，覆盖了同事B和同事C的commit，而同事B和C本地仓库依旧有他们的提交，这个时候同事B和C只需要同步一下远程，然后再git push -f一下他们的提交，这样就能将被覆盖的commit重新合并到远程仓库里面。

但是我遇到的情况比较特殊，因为当时同事B和同事C是在gitlab的网页版直接编辑的文件，并通过Gitlab提交，也就是说所有人本地都没有同事B和同事C提交的内容，这个时候同事A使用git push -f直接就冲掉了记录，所以就没办法通过上面的办法来回滚了。

废话那么多，下面记录下找回的过程：

### 1 场景
```bash
Original:
(remote origin:)
    branch master -> commit 111111

(local)
    branch master -> commit 22222
After git push -f:

(remote origin:)
    branch master -> commit 22222
```

### 2 找回步骤
（1）这个方法的前提是你有权限登陆部署了Gitlab的服务器，我们需要找到Gitlab保存仓库的目录，首先通过ssh登陆上Gitlab的服务器，然后找到gitlab的存放仓库的地方，默认是在```/var/opt/gitlab/git-data/repositories```。

在这个目录下找到自己要回滚的仓库，并cd到该仓库。

（2）在执行回滚操作前一定要先进行仓库备份：
```bash
tar cvzf project-backup.tgz  /path/to/project.git
```
备份好之后才可以进行下面的操作。

首先gitlab的仓库的目录是这样的：
```
config description HEAD hooks hooks.old.xxx info objects refs
```

在当前目录使用```git fsck```工具找回上次执行的危险操作，直接执行```git fsck```命令，该命令显示所有未被其他对象引用 (指向) 的所有对象，会有如下输出：
```bash
dangling commit ab1afef80fac8e34258ff41fc1b867c702daa24b
```
ab1afef80fac8e34258ff41fc1b867c702daa24就是可能被丢弃的commit，也就是被冲掉的commit，具体是自己想要的哪个，可以：
```
git log ab1afef80fac8e34258ff41fc1b867c702daa24
```
查看在这之前的commit历史，找到自己想要回滚的commit。

（3）找到了想要回滚的commit 哈希值，是不是可以在本地仓库执行
```
git reset --HEAD  ab1afef80fac8e34258ff41fc1b867c702daa24
```
实现回滚了呢？答案是不可以的，因为仓库关于被覆盖的对象已经被清除了，所以clone下来的仓库是没有被覆盖的对象可以回滚的，所以回滚操作还是需要在gitlab的实际仓库里操作。

```
echo ab1afef80fac8e34258ff41fc1b867c702daa24 > refs/heads/master
```

将commit 哈希值直接添加到refs/heads/master文件里，然后克隆远程仓库到本地，你会发现以前的commit又神奇的回来了。

具体的原理需要大家自己去了解git的原理，参考这几篇文章：

https://git-scm.com/book/zh/v1/Git-内部原理-维护及数据恢复
https://superuser.com/questions/297973/how-can-i-recover-from-an-accidental-git-push-f/298015#298015

希望对大家有所帮助。

Regards，
codjust  





