---
title: Java反射-Field和Annotations
date: 2017-08-20 18:05:57
tags: [java]
categories:
    - Java学习笔记
---

写了差不多两个月的Java业务代码，Java的基础还不够牢靠，导致在工作过程中遇到很多问题，虽然不知道为什么也能把需求撸出来，但这不是吾辈之作风。

公司的项目代码还没完全吃透，只是对业务层比较熟悉，但是底层的还不是很了解，这主要还是因为基础不够，在看底层代码时发现项目中大量运用了Java的反射，于是周末的时候简单看了下。其中公司项目中用到最多的是反射的Field，注解（Annotation）以及动态代理，这基本是整个工程的核心，Java的反射及其强大，不过我也只是管中窥豹，从项目中看到了反射的用处，这里只是写几个小的例子，记录下Field和Annotations的用法。

<!--more-->
### 1、什么是反射？
	简单介绍一下什么是Java的反射，在Java运行时环境中，对于任意一个类，能否知道这个类有哪些属性和方法？对于任意一个对象，能否调用其方法？当然是可以的，这种动态获取类的信息，以及动态调用类的方法的功能来源于JAVA的反射。

Java的反射主要提供以下类，用于获取不同场景的类的信息,位于java.lang.reflect包中:
        --Class类：代表一个类
        --Filed类：代表类的成员变量
        --Method类：代表类的方法
        --Constructor类：代表类的构造方法
        --Array类：提供了动态创建数组，以及访问数组的元素的静态方法。该类中的所有方法都是静态方法.

### 2、Field
关于Field的用法，参考了这篇博文的例子，http://www.360doc.com/content/17/0820/17/46591991_680655030.shtml
我觉得她的例子写的还是很生动，好理解的，所以我就不费脑筋了。

Field类主要是用来获取类的成员变量信息的，不管是私有的还是公有的都可以通过反射获取到，并且还可以改变变量的值，这在很多场景是非常有用的，项目中使用场景太大不好拿出去当例子使用。
```java
package com.ncs;    
public class Point {        
  private int x;      
  public int y;            
  public Point(int x, int y) {          
  super();          
  this.x = x;          
  this.y = y;      
  }        
}  
```
```java
package com.ncs;  
import java.lang.reflect.Field;  
//need another bean Point  
public class ReflectTest {  
    //这里说的Field都是 类 身上的，不是实例上的  
    public static void main(String[] args) throws Exception {  
          
        Point pt1 = new Point(3,5);  
          
        //得到一个字段  
        Field fieldY = pt1.getClass().getField("y"); //y 是变量名  
        //fieldY的值是5么？？ 大错特错  
        //fieldY和pt1根本没有什么关系，你看，是pt1.getClass()，是 字节码 啊  
        //不是pt1对象身上的变量，而是类上的，要用它取某个对象上对应的值  
        //要这样  
        System.out.println(fieldY.get(pt1)); //这才是5  
        //现在要x了    
        /*  
        Field fieldX = pt1.getClass().getField("x"); //x 是变量名 
        System.out.println(fieldX.get(pt1));  
        */  
          
        //运行 报错 私有的，找不到  
        //NoSuchFieldException  
        //说明getField 只可以得到 公有的  
        //怎么得到私有的呢？？  
          
        /* 
        //这个管你公的私的，都拿来 
        Field fieldX = pt1.getClass().getDeclaredField("x");
        //然后轮到这里错了 
        // java.lang.IllegalAccessException: 
        //Class com.ncs.ReflectTest can not access a member of class com.ncs.Point with modifiers "private" 
        System.out.println(fieldX.get(pt1)); 
        */           
        //三步曲 一是不让你知道我有钱 二是把钱晃一下，不给用  三是暴力抢了  
        //暴力反射    
        Field fieldX = pt1.getClass().getDeclaredField("x"); //这个管你公的私的，都拿来  
        fieldX.setAccessible(true);//上面的代码已经看见钱了，开始抢了  
        System.out.println(fieldX.get(pt1));             
    }  
}  

```

### 3、Annotations注解
Java的注解我觉得最大的用处是标示一个类，或者一个方法，下面是一个简单的Demo：

定义一个注解的接口：
```Java
package reflection;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)

public @interface MyAnnotation {
	public String name();
	public String value();
}
```


标示一个MyObject类：
```java
package reflection;

@MyAnnotation(name="myannotation", value="hello annotation")
public class MyObject {
	private int count;
	public void printInfo() {
		System.out.println("Class Info:" + MyObject.class.getName());
	}
	public void setCount(int count) {
		this.count = count;
	}
	public int getCount() {
		return count;
	}	
}
```


```java
Class cls = MyObject.class;
Annotation[] annotations = cls.getAnnotations();
for(Annotation an: annotations){
if(an instanceof MyAnnotation) {
	MyAnnotation myan = (MyAnnotation)an;
	System.out.println("Annotation:" + myan.name());
	System.out.println("Annotation:" + myan.value());	
	}
}
```

输出结果：
```
Annotation:myannotation
Annotation:hello annotation
```

通过定义不同的注解，标示一个类或者方法，可以为某些处理指定相应的函数，比如服务端和客户端的通讯，约定好协议，当客户端发请求消息过来时，可以指定@HandlerAnno（自定义的注解）标示的方法对消息进行处理。

本文主要记录下Field和Annotations的用法，以备不时之需，看了概念没有实践很容易就忘了，工作写的代码基本也用不上自己写这些约定的底层的东西，所以得记录下来，哪怕只是很简单的一个Demo，嗯，好吧，就这样了！！

