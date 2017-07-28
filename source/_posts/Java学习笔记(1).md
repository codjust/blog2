---
title: Java学习笔记(1)
date: 2017-06-06 19:34:24
tags:
categories:
    - Java学习笔记
---

### 1、Java的两个基础特性
（1）所有对象都是继承字单根基类Object.

（2）只能以一种方式创建对象（在堆上创建）.

### 2、常见总结
（1）Java的逗号表达式只能用于for语句里，如
```java
for(int i = 0, j = i + 10; i<5 ; i++ )
{
    ;
}
```

（2）Java添加了foreach的用法，跟C++ STL里的范型极其类似，简单用法如下：
```java
for(int i : range())
    printnb(i + " ");
//:后面必须是一个数组，可以迭代数组的元素
```

（3）Java同样支持构造函数，在Java里称为构造器，使用方法与C++是一样的：
```java
class Test{
    Test(){PP
        System.out.println("Test constructor");
    }
    //重载
    Test(int i){
        System.out.println("Test constructor" + i);
    }
}

```
需要注意的是，如果没有声明构造器Java会调用默认的构造器，但是如果已经定义了构造器（无论是否有参数），编译器不会再自动创建默认构造器，如：
```java
class Test{
    Test(int i){}
]

Test t = new Test();//会报错，因为没有这个构造器
```

（4）static关键字：在static方法内部不能调用非静态方法，反过来可以调用。Java中禁止使用全局方法，static方法可以直接通过类调用，这点跟C++相同，static方法内部不存在this指针。
static初始化可以通过静态块中初始化，如：
```java

static int j;
static {
    j = 5;
}

```

（5）Java支持可变参数列表，如：
```java
public class Args{
    
    static void printArray(Object... args){
        for(Object obj: args){
            System.out.print(obj + " ");
        }
    }
    
    public static void main(String[] args){
        printArray(1, 2, 3);
        printArray("a", "b", "c");
    }
}

```
（6）public的类要放到单独的一个文件里面去，并以该类名作为文件名，如：
```java
//Test.java
//编译出错
public class Test{
    
}
public class Hello{
    
}

```
要想在同一个文件声明多个类，只能有一个public，private，protectes不能修饰类，只能修饰方法和变量:
```java
//Test.java
//合法
public class Test{
    
}

class Hello{
    
}
```
（7）Java与C++有个重要的不同，Java的每个类都可以含有自己的main函数，并且其他类可以调用其main函数，这个特性可使得每个类的单元测试都变得简便易行。而且在完成单元测试之后，也无需删除main()，可以留待下次单元测试。








