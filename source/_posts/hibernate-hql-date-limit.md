---
title: Hibernate字段比较时间以及实现limit操作
date: 2017-09-02 23:32:44
tags: [hibernate]
categories: 杂七杂八
---
最近在做业务开发的时候需要对数据库进行索引操作，主要实现的是根据时间字段取出最近一个月登录的数据，并且限制取出的数量。本来使用原生的SQL语句是非常容易实现的，可是项目使用的是Hibernate，Hibernate对数据库的操作使用的是HQL，是一种面向对象的查询语言，类似于 SQL，但不是去对表和列进行操作，而是面向对象和它们的属性。 HQL 查询被 Hibernate 翻译为传统的 SQL 查询从而对数据库进行操作。

在下使用Java时间还不是很长，对Hibernate还不是很熟悉，结果发现原生的SQL语句Hibernate是不完全支持的，所以在此记录下这个过程。
<!--more-->
### 1 sql语句时间比较和数量限制
先来复习一下sql语句实现的方法，假设数据库的playerent表和playerstat通过guid字段主外健关联，其中playerstat表有字段lastlogintime记录上次登录时间，java定义的类为Date，持久化到 数据库后的数据格式为：‘2017-07-22 14:22:12’。

要实现判断最近一个月的区间有两种方法，一是可以直接计算出当前的时间，以及一个月前的时间，然后直接判断即可；第二种可以使用mysql提供的DATE_SUB()函数，DATE_SUB()的文档描述为：
```
定义和用法:
DATE_SUB() 函数从日期减去指定的时间间隔。

DATE_SUB(date,INTERVAL expr type)
date 参数是合法的日期表达式。expr 参数是您希望添加的时间间隔。
```
其中type有以下常用的可选（文档地址：http://www.w3school.com.cn/sql/func_date_sub.asp）：
```
MICROSECOND
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
...
```

最终实现的sql语句为：
```sql
SELECT ent.guid FROM playerent ent, playerstat stat 
WHERE ent.guid = stat.guid
AND DATE_SUB(CURDATE(), INTERVAL 30 DAY) <= stat.lastlogintime
LIMIT 1000
```
其中CURDATE()为mysql获取当前时间的函数。

### 2 Hibernate的实现

其实Hibernate要是直接支持mysql的日期操作函数上面的语句其实可以直接就用了，既然不支持就要看看Hibernate是怎么做日期的操作的。

关于hql的知识这里就不展开说了，大家可以网上找找相关资料，下图是Hibernate的架构图，大家可以看看这里相关介绍：http://wiki.jikexueyuan.com/project/hibernate/architecture.html

![Hibernate架构图.png](http://upload-images.jianshu.io/upload_images/3981501-631498dc7021ce96.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先先建立查询的hql语句：
```sql
SELECT ent.guid FROM PlayerEnt ent, PlayerStat stat 
WHERE ent.guid = stat.guid
AND stat.lastlogintime >=:beginDate AND stat.lastlogintime < :endDate
```

可以看到查询语句不会直接查询数据库的表了，而是查询Java的对象，关于Hibernate这方面的知识在下后面再整理一篇博文出来，这里先讲述本文的主题。

下面是Hibernate实现的代码：
```java
String hql = "SELECT ent.guid FROM PlayerEnt ent, PlayerStat stat 
WHERE ent.guid = stat.guid
AND stat.lastlogintime >=:beginDate AND stat.lastlogintime < :endDate";
Query query = session.createQuery(hql);

query.setDate("beginDate", beginDate);
query.setDate("endDate", endDate);

query.setMaxResults(1000);
List<Long> list = query.list();
```

简单解释一下上面的代码，session是Hibernate的会话，通过传进来的hql字符串session可以创建一个查询，hql语句可以通过参数绑定引用占位符，“:beginDate”和“:endDate”就是上面的引用占位符，然后通过Query可以将hql语句的参数补全，最后使用query.setMaxResults(1000) 限制查询数量，这里可以指定区间，配合setFirstResult方法。

以上内容就是使用Hibernate字段比较时间以及实现limit操作，只是记录下一些操作，权当笔记，说不定也有跟在下一样刚入手java的朋友也会遇到同样的问题，这里可以提供一些参考。
