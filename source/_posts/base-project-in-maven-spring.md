---
title: 使用maven+spring构建服务端基础工程
date: 2017-10-26 15:52:59
tags: [java,maven,spring]
categories: 游戏服务端开发
---
简单记录下自己常用的项目基础工程，基础工程包括常用的spring使用的配置形式和项目结构，结合maven，以后新建项目都可以直接基于此基础工程。

### 1 新建Maven工程

![1.png](http://upload-images.jianshu.io/upload_images/3981501-409d2206f0f71964.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
<!--more-->
新建的Java工程，不是web：
![2.png](http://upload-images.jianshu.io/upload_images/3981501-07646685637bc55e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

根据自己的实际情况填写：
![3.png](http://upload-images.jianshu.io/upload_images/3981501-c447d141e8c26dda.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后生成的工程结构如下图所示：
![4.png](http://upload-images.jianshu.io/upload_images/3981501-96ead9ea38e3abe1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 2 下载spring
因为使用的是maven管理jar包，所以使用spring就不需要单独的去下载spring，直接在maven的pom.xml文件引入即可，spring的maven 依赖可以在中央仓库查找，如果是内网的maven仓库也是一样，这里直接去中央仓库查找：http://mvnrepository.com/


![5.png](http://upload-images.jianshu.io/upload_images/3981501-31299db1f88f0485.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

引入常用的spring-core、spring-beans、spring-context等spring核心jar包，这里需要注意的是要选择central（中央仓库），不然其他的第三方仓库会无法访问，出现报错的情况：



![6.png](http://upload-images.jianshu.io/upload_images/3981501-b19f49e02f08b6e7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

并且所有jar包的版本最好保持一致，spring的版本最新好像和jdk8有点问题，我选择的是统一的3.2.18版本：

![7.png](http://upload-images.jianshu.io/upload_images/3981501-3a97b04f86d41b79.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

将需要下载的包的dependency复制下来，粘贴到pom.xml文件，保存即可。

### 3 配置spring
常用的spring配置，在src/main/java新建一个spring配置文件：

![8.png](http://upload-images.jianshu.io/upload_images/3981501-762bd3ffd9a321c1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

命名为：applicationContext
![9.png](http://upload-images.jianshu.io/upload_images/3981501-57332ea8d0e862a8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)，

会自动生成一个applicationContext.xml文件，这个作为spring启动的核心配置文件，常用的配置如下：

![10.png](http://upload-images.jianshu.io/upload_images/3981501-3ad1ad1a0a597bd8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中，
```xml
<context:component-scan 
		base-package="com.codjust.demo.common" >
	</context:component-scan>
```
配置的是spring自动扫描bean的路径，这里配置的是路径"com.codjust.demo.common"，也就是说在此路径的bean会被扫描进来，扫描的bean需要具备特殊的注解，如常用的@Component等。

context:annotation-config配置的是支持注解自动装配，常用自动装配注解有：	@Autowired，	@Inject等
```xml
	<context:annotation-config/>
```

### 4 单元测试配置
研发过程中离不开单元测试，我们把src/test/java作为测试用例的目录，我们编写一个BaseCase的基类：

![11.png](http://upload-images.jianshu.io/upload_images/3981501-c5ac1e1ac6a2dd45.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中，
```java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
```
表示单元测试基于跟工程同样的配置启动，基于applicationContext.xml配置文件，这样单元测试用例可以测试项目的各种各样的情况。

### 5 小小的demo
这里以一个Hello和Fight类作为演示，我们新建一个Fight类，
```java
package com.codjust.demo.common;

import org.springframework.stereotype.Component;

@Component
public class Fight {
	private String text;

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}
	
	public void sayHello() {
		System.out.println("Hello Figghting!");
	}
}
```
使用@Component打上注解，并且有一个sayhello的公用方法。

再新建一个Hello类：
```java
package com.codjust.demo.common;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Hello {	
	
	@Autowired
	private Fight fight;
	
	private int Id;
	
	private String text;
	
	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public void setId(int id) {
		this.Id = id;
	}
	
	public int getId() {
		return Id;
	}

	public void say() {
		fight.sayHello();
	}
}
```
同样Hello也是打上@Component，同时在Hello类引用Fight bean，通过@Autowired自动装配fight，这样就能在Hello里面拿到Fight的bean，然后在say()方法去使用这个bean。

最后App类去启动spring，并且使用拿到Hello的bean，调用say()方法，打印输出：

```java
package com.codjust.demo;


import org.springframework.context.ApplicationContext;

import org.springframework.context.support.ClassPathXmlApplicationContext;


import com.codjust.demo.common.Hello;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
    	ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");		
		Hello obj1 = (Hello)ctx.getBean("hello");
		obj1.say();    	
    }
}
 
```
输出如下图所示：

![12.png](http://upload-images.jianshu.io/upload_images/3981501-9b85e699cb9fee9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

编写hello的测试类，TestHello，继承自BaseCase：
```java
package hello;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import com.codjust.demo.BaseCase;
import com.codjust.demo.common.Hello;
import org.junit.Assert;

public class Testhello extends BaseCase{

	@Autowired
	private Hello hello;
	
	@Test
	public void test_01() throws Exception {
		hello.say();
		hello.setText("nihao");
		Assert.assertEquals(hello.getText(), "nihao");
	}
}

```

![13.png](http://upload-images.jianshu.io/upload_images/3981501-5717b3c3a2b9e742.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 6 最后

以上的demo很粗糙，但是麻雀虽小，五脏俱全，一个项目的结构基本就如此，以后有新的配置在此基础上加即可，无论是netty还是hibernate等常用框架都可以通过spring来整合，配合maven管理包，无疑是非常方便的。

希望此文对大家有所帮助！

demo地址：
https://github.com/huchangwei/project_demo

Regards，

codjust