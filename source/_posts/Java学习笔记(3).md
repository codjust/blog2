---
title: Java学习笔记(3)- final 和 c++ const的区别
date: 2017-06-07 17:22:06
tags:
categories:
    - Java学习笔记
autoThumbnailImage: yes
---

(1)final在java中定义常量，可作用于基本类型或者类类型，若是作用于类类型，则此类类型不能作为父类被继承，也就是说它的下面不能有子类，这样的类叫做原子类。  
C＋＋中的const定义常量.

(2)Java中的final如果是对于基本类型，那和C++ const是一样的；但是如果是对对象而言，那就不同了。  
   
(3)final表示这个句柄是不可改变的  
```java
final Object obj=(Object)new String("a");  
obj=(Object)new String("hello");//是非法的  
```
<!--more-->
但是依然可以调用obj的方法。如((String)obj).length()是合法的；而C++如果一个对象被定义成const，就不能调用对象的方法。除非这个方法被定义成const.

```java
package test;
/*final表示这个句柄是不可改变的 
final Object obj=(Object)new String("a"); 
obj=(Object)new String("hello");//是非法的 
但是依然可以调用obj的方法。如((String)obj).length()是合法的   */
public class Test {
    public static void main(String[] args) {
        final Object obj=(Object)new String("a");
        //obj=(Object)new String("hello");//不能对终态局部变量obj赋值
        System.out.println(((String)obj).length());//但是依然可以调用obj的方法
    }
}
```
