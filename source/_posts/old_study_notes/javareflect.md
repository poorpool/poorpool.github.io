---
title: Java反射胡探
date: 2020-04-25 19:00:14
tags:
- Java
- 面向对象
categories:
- 编程语言
---

先康康[这个视频](https://www.bilibili.com/video/BV1C4411373T?p=7)。

<!--more-->

## 获取一系列信息

`domain/Person.java`
```java
package domain;

public class Person {
    private String name;
    private int age;
    public String a;
    public Person() {

    }

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public void eat() {
        System.out.println("eating");
    }

    public void eat(String food) {
        System.out.println("eating " + food);
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", a='" + a + '\'' +
                '}';
    }
}
```

`reflect/ReflectDemo.java`
反射应用：从配置文件里执行任意类的任意方法
```java
package reflect;

import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.Properties;

public class ReflectDemo {
    public static void main(String[] args) throws Exception {
        Properties pro = new Properties();
        ClassLoader classLoader = ReflectDemo.class.getClassLoader();
        InputStream is = classLoader.getResourceAsStream("pro.properties");
        pro.load(is);

        String className = pro.getProperty("className");
        String methodName = pro.getProperty("methodName");

        Class cls = Class.forName(className);
        Constructor cons = cls.getConstructor();
        Object obj = cons.newInstance();
        Method mtd = cls.getMethod(methodName);
        mtd.invoke(obj);
    }
}
```

`reflect/ReflectDemo1.java`
获得class
```java
package reflect;

import domain.Person;
import domain.Student;

public class ReflectDemo1 {
    public static void main(String[] args) throws Exception {
        Class cls1 = Class.forName("domain.Person");
        System.out.println(cls1);

        Class cls2 = Person.class;
        System.out.println(cls2);

        var p = new Person();
        Class cls3 = p.getClass();
        System.out.println(cls3);

        System.out.println(cls1 == cls2);
        System.out.println(cls1 == cls3);

        var s = new Student();
        Class cls4 = s.getClass();
        System.out.println(cls4);
    }
}
```

`reflect/ReflectDemo2.java`
获得field。
```java
package reflect;

import domain.Person;

import java.lang.reflect.*;

public class ReflectDemo2 {
    public static void main(String[] args) throws Exception {
        Class personClass = Person.class;
        Field[] fields = personClass.getFields();
        for (Field field : fields) {
            System.out.println(field);
        }

        Field a = personClass.getField("a");
        Person p = new Person();
        Object value = a.get(p);
        System.out.println(value);

        a.set(p, "zhangsan");
        System.out.println(p.a);

        Field name = personClass.getDeclaredField("name");
        name.setAccessible(true);//暴力反射，哪管你是私有……
        Object v2 = name.get(p);
        System.out.println(v2);
    }
}
```

`reflect/ReflectDemo3.java`
获得constructor。
```java
package reflect;

import domain.Person;

import java.lang.reflect.*;

public class ReflectDemo3 {
    public static void main(String[] args) throws Exception {
        Class personClass = Person.class;
        Constructor cons = personClass.getConstructor(String.class, int.class);
        Object obj = cons.newInstance("zhangsan", 15);
        System.out.println(obj);
    }
}
```

工厂类
```java
package com.poorpool.demo;

import java.lang.reflect.InvocationTargetException;

interface IBook {
    public void read();
}

class MathBook implements IBook {

    @Override
    public void read() {
        System.out.println("阅读数学书");
    }
}

class ProgramBook implements IBook {

    @Override
    public void read() {
        System.out.println("阅读编程书");
    }
}

class Factory {
    private Factory() {}
    public static IBook getBook(String name) {
        try {
            Object obj = Class.forName(name).getDeclaredConstructor().newInstance();
            if(obj instanceof IBook)
                return (IBook)obj;
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
public class HelloDemo {
    public static void main(String[] args) throws Exception {
        IBook qwq = Factory.getBook("com.poorpool.demo.MathBook");
        IBook pwp = Factory.getBook("com.poorpool.demo.ProgramBook");
        qwq.read();
        pwp.read();
    }
}
```

多线程和单例设计模式
```java
package com.poorpool.demo;

class Book {
    private static volatile Book instance = null;
    private Book() {
        System.out.println(Thread.currentThread().getName() + " 实例化对象");
    }
    public static Book getInstance() {
        if(instance==null) {
            synchronized (Book.class) {
                if(instance==null) {
                    instance = new Book();
                }
            }
        }
        return instance;
    }
}
public class HelloDemo {
    public static void main(String[] args) throws Exception {
        for(int i=0; i<10; i++) {
            new Thread(()->{
                Book book = Book.getInstance();
                System.out.println(book);
            }, "线程"+i).start();
        }
    }
}
```

`reflect/ReflectDemo4.java`
获得method。
```java
package reflect;

import domain.Person;

import java.lang.reflect.*;

public class ReflectDemo4 {
    public static void main(String[] args) throws Exception {
        Class personClass = Person.class;
        Method met = personClass.getMethod("eat", String.class);
        Person p = new Person();
        met.invoke(p, "apple");

    }
}
```

## ClassLoader

### 类加载器。

有三个：Bootstrap、PlatformClassLoader（以前叫ExtClassLoader）、AppClassLoader。分别为JVM系统提供的、平台类的、应用程序类的加载器。
```java
package com.poorpool.demo;

class Book {}
public class HelloDemo {
    public static void main(String[] args) throws Exception {
        Class<?> book = Book.class;
        Class<?> string = String.class;
        System.out.println(book.getClassLoader());
        System.out.println(book.getClassLoader().getParent());
        System.out.println(book.getClassLoader().getParent().getParent());
        System.out.println();
        System.out.println(string.getClassLoader());
    }
}
```
```
jdk.internal.loader.ClassLoaders$AppClassLoader@42a57993
jdk.internal.loader.ClassLoaders$PlatformClassLoader@5b2133b1
null

null
```

null就是Bootstrap。

### 自定义类加载器

先编一个`Message.class`丢到合适的地方。
```java
package com.poorpool.demo;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

class FileClassLoader extends ClassLoader {
    private static String CLASS_PATH = "Message.class";
    public Class<?> loadData(String className) throws Exception {
        byte[] re = this.loadFileClassData();
        if(re!=null)
            return super.defineClass(className, re, 0, re.length);//important
        return null;
    }
    private byte[] loadFileClassData() throws Exception {
        InputStream ins = new FileInputStream(new File(CLASS_PATH));
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ins.transferTo(bos);
        byte[] re = bos.toByteArray();
        ins.close();
        bos.close();
        return re;
    }
}

public class HelloDemo {
    public static void main(String[] args) throws Exception {
        FileClassLoader fcl = new FileClassLoader();
        Class<?> clazz = fcl.loadData("com.poorpool.demo.Message");
        Object qwq = clazz.getConstructor().newInstance();
        System.out.println(qwq);
        System.out.println(fcl);
        System.out.println(fcl.getParent());
        System.out.println(fcl.getParent().getParent());
        System.out.println(fcl.getParent().getParent().getParent());
    }
}
```
```
com.poorpool.demo.Message@19469ea2
com.poorpool.demo.FileClassLoader@72ea2f77
jdk.internal.loader.ClassLoaders$AppClassLoader@42a57993
jdk.internal.loader.ClassLoaders$PlatformClassLoader@13221655
null
```

## 动态代理

推荐一下java3y的文章，讲得很棒。转载的[一个链接](https://www.jianshu.com/p/366f7b8a6200)。

```java
package com.poorpool.demo;

import java.lang.reflect.Proxy;

interface IProgrammer {
    public void coding();
}

class Poorpool implements IProgrammer {

    @Override
    public void coding() {
        System.out.println("写奥利给代码");
    }
}


public class HelloDemo {
    public static void main(String[] args1) throws Exception {
        Poorpool ppl = new Poorpool();
        IProgrammer prog = (IProgrammer)Proxy.newProxyInstance(ppl.getClass().getClassLoader(),
                ppl.getClass().getInterfaces(),
                (proxy, method, args) -> {//这是一个FunctionalInterface，InvocationHandler
                    if(method.getName().equals("coding")) {
                        method.invoke(ppl, args);
                        System.out.println("代理完毕");
                    }
                    else {
                        method.invoke(ppl, args);
                    }
                    return null;
                });
        prog.coding();
    }
}
```

使用CGLIB可以避免上面使用接口的情况，避免了代理设计模式和接口的强制耦合。

## 自定义Annotation
```java
package com.poorpool.demo;

import java.lang.annotation.Annotation;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)//运行时有效
@interface Action {//自定义一个Annotation
    public String title() default "poorpool qwq";//可以有default
    public String value();
}

//@Action(title = "poorpool orz", value = "233")
//@Action("233") default可以省略。如果有属性名称为value的，value=也可以省略
@Action("pvp")
class Message {
    public void send(String msg) {
        System.out.println(msg);
    }
}

public class HelloDemo {
    public static void main(String[] args1) throws Exception {
        Class<?> clazz = Message.class;
        Annotation[] annos = clazz.getAnnotations();
        for(var anno : annos)
            System.out.println(anno);
    }
}
```
自定义Annotation和工厂类结合，取消Message和Factory任何直接耦合。
```java
package com.poorpool.demo;

import java.lang.annotation.*;
import java.lang.reflect.InvocationTargetException;

@Target({ElementType.TYPE})//用在类定义上
@Retention(RetentionPolicy.RUNTIME)
@interface Action{
    public String value();
}

@Target({ElementType.CONSTRUCTOR})//用在类定义上
@Retention(RetentionPolicy.RUNTIME)
@interface Instance{
    public String value();
}

interface IChannel extends AutoCloseable {
    public boolean build();
}

class InternetChannel implements IChannel {

    @Override
    public boolean build() {
        System.out.println("建立互联网信道");
        return true;
    }

    @Override
    public void close() throws Exception {
        System.out.println("关闭互联网信道");
    }
}

class RadioChannel implements IChannel {

    @Override
    public boolean build() {
        System.out.println("建立无线电信道");
        return true;
    }

    @Override
    public void close() throws Exception {
        System.out.println("关闭无线电信道");
    }
}

class Factory {
    private Factory() {}
    public static <T> T getInstance(String className) {
        try {
            return (T) Class.forName(className).getDeclaredConstructor().newInstance();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}

@Action("com.poorpool.demo.RadioChannel")
class Message {
    private IChannel channel;
    @Instance("com.poorpool.demo.Factory")
    public Message() {
        try {
            Action actAnno = super.getClass().getAnnotation(Action.class);
            //super(Object)中的getClass方法，仍然是运行时类。
            Instance ins = super.getClass().getConstructor().getAnnotation(Instance.class);
            String facName = ins.value();
            String actName = actAnno.value();
            Class<?> facClazz = Class.forName(facName);
            this.channel = (IChannel)facClazz.getMethod("getInstance", String.class).invoke(null, actName);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void echo(String qwq) throws Exception {
        if(this.channel.build())
            System.out.println(qwq);
        this.channel.close();
    }
}

public class HelloDemo {
    public static void main(String[] args) throws Exception {
        Message msg = new Message();
        msg.echo("hello");
    }
}
```