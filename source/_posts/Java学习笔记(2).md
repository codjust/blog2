---
title: Java学习笔记(2)- Java的重写总结
date: 2017-06-07 11:28:59
tags:
categories:
    - Java学习笔记
---

### 常见总结
1、Java的重写
与C++不同的是，如果基类具有某个方法，继承的子类使用重载的形式重写了这个方法，这时子类并不会覆盖基类的方法，依旧可以实现重载机制，如
```java
public class A {
    A(){
        System.out.println("A Object Create.");
    }

    int doIt(int i){
        System.out.println("do int i");
        return i;
    }

}

class B  extends A{
    B(){
        System.out.println("B Object Create.");
    }
    double doIt(double i){
        System.out.println("do double i.");
        return i;
    }
}

class C {
    C(){
        System.out.println("C Object Create.");
    }
    public static void main(String[] args){
        B b = new B();
        b.doIt(1);
        b.doIt(1.2);
    }
}

```
输出结果是：
```java
A Object Create.
B Object Create.
do int i
do double i.
```
子类需要覆盖屏蔽时，为了避免自己手贱写成重载的形式，可以加@Override注解，当写成上面的形式的时候就会报错，重写只需要跟基类的定义一样即可，正确的写法：
```java
public class A {
    A(){
        System.out.println("A Object Create.");
    }

    int doIt(int i){
        System.out.println("do int i");
        return i;
    }

}

class B  extends A{
    B(){
        System.out.println("B Object Create.");
    }
    @Override int doIt(int i){
        System.out.println("do B i:" + i);
        return i;
    }
}


class C {
    C(){
        System.out.println("C Object Create.");
    }
    public static void main(String[] args){
        B b = new B();
        b.doIt(1);

        //重写非静态方法实现多态
        A a = new B();
        a.doIt(2);
    }
}
```
输出结果：
```java
A Object Create.
B Object Create.
do B i:1
A Object Create.
B Object Create.
do B i:2
```

2、Java的静态方法和变量可以被继承但不可以被重写实现多态
基类的静态方法和成员变量都可以被继承，如果导出类（子类，java一般称子类为导出类）没有重写，则可以通过导出类直接访问静态方法和变量（当然前提是继承的静态方法访问权限不是private）
注意-> 静态方法子类无法被重写从而实现多态：
```java
public class Instrument {
    public void play(){
        System.out.println("playing...");
    }

    public static void tune(){
        System.out.println("In base tune");
    }

    public static void change(){
        System.out.println("In base change");
    }
    protected static int i = 3;
}

class Wind extends Instrument {

    //尝试重写静态方法tune，实现多态
    static void change(){
        System.out.println("In inert change");
    }
    public static void main(String[] args){
       //继承了父类的静态方法
        Wind w = new Wind();
        Wind.tune();

        Wind.i = 5;
        System.out.println(Instrument.i);

        //父类尝试调用子类重写的静态方法
        Instrument base = new Wind();
        base.change();
    }
}
```
输出结果：
```
Error:(22, 17) java: Wind中的change()无法覆盖Instrument中的change()
  正在尝试分配更低的访问权限; 以前为public

```
注释掉非法的操作之后的输出结果为：
```java
public class Instrument {
    public void play(){
        System.out.println("playing...");
    }

    public static void tune(){
        System.out.println("In base tune");
    }

    public static void change(){
        System.out.println("In base change");
    }
    protected static int i = 3;
}

class Wind extends Instrument {

    //尝试重写静态方法tune，实现多态
//    static void change(){
//        System.out.println("In inert change");
//    }
    public static void main(String[] args){
       //继承了父类的静态方法
        Wind w = new Wind();
        Wind.tune();

        Wind.i = 5;
        System.out.println(Instrument.i);

        //父类尝试调用子类重写的静态方法
        //Instrument base = new Wind();
        //base.change();
    }
}
```

```
In base tune
5
```

3、总结
（1）静态方法和属性是属于类的，调用的时候直接通过类名.方法名完成对，不需要继承机制及可以调用。如果子类里面定义了静态方法和属性，那么这时候父类的静态方法或属性称之为"隐藏"。如果你想要调用父类的静态方法和属性，直接通过父类名.方法或变量名完成，至于是否继承一说，子类是有继承静态方法和属性，但是跟实例方法和属性不太一样，存在"隐藏"的这种情况。  
（2） 多态之所以能够实现依赖于继承、接口和重写、重载（继承和重写最为关键）。有了继承和重写就可以实现父类的引用指向不同子类的对象。重写的功能是："重写"后子类的优先级要高于父类的优先级，但是“隐藏”是没有这个优先级之分的。  
（3） 静态属性、静态方法和非静态的属性都可以被继承和隐藏而不能被重写，因此不能实现多态，不能实现父类的引用可以指向不同子类的对象。非静态方法可以被继承和重写，因此可以实现多态。


