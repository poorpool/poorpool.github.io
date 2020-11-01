---
title: Java的一些知识
date: 2020-05-07 21:01:37
tags:
- Java
- 面向对象
categories:
- 编程语言
---
杂项

<!--more-->

## 继承
继承的方法的公开程度，子类不得比父类局限。

如果父类的方法是private，那么其实哪怕子类写了一个参数名字一模一样的public也不算覆写。

## 泛型
```java
class Message<T> {
    private T content;
    public Message(T content) {
        this.content = content;
    }
    public void setContent(T content) {
        this.content = content;
    }
    public T getContent() {
        return this.content;
    }
}
public class qwq {
    public static void orz(Message<? extends Number> message) {//必须是Number或其子类
        //如果是Number或其父类就是 ? super Number
        // message.setContent(69); 这是不行的，改不了
        System.out.println(message.getContent());
    }
    public static void main(String[] args) {
        Message<Integer> message = new Message<Integer>(89);
        orz(message);
    }
}
```

## 枚举

java的枚举强得很。它这么强主要是靠Enum类。

```java
interface IMessage {
    public String getColor();
}
enum Color implements IMessage{
    RED("红色"), GREEN("绿色"), BLUE("蓝色");
    private String content;
    private Color(String content) {//没有无参构造了，并且不能是public。
        this.content = content;
    }
    @Override
    public String getColor() {
        return this.content;
    }
}
public class EnumDemo {
    public static void main(String[] args) {
        IMessage msg = Color.RED;
        System.out.println(msg.getColor());
    }
}
```

```java
interface IMessage {
    public String getColor();
}
enum Color implements IMessage{
    RED {
        @Override
        public String getColor() {
            return "红色";
        }
    },
    BLUE {
        @Override
        public String getColor() {
            return "蓝色";
        }
    },
    GREEN {
        @Override
        public String getColor() {
            return "绿色";
        }
    }
}
public class EnumDemo {
    public static void main(String[] args) {
        IMessage msg = Color.RED;
        System.out.println(msg.getColor());
        for(Color c : Color.values()) {
            System.out.println(c + " " + c.name() + " " + c.ordinal());
        }
    }
}

```

## 外部类

内部类访问外部类
```java
class Outer {
    public String msg = "poorpool";
    class Inner {
        public String getName() {
            return Outer.this.msg;
        }
    }
}
public class OuterDemo {
    public static void main(String[] args) {
        Outer.Inner in = new Outer().new Inner();
        System.out.println(in.getName());
    }
}
```
超级无敌内部类接口大杂烩
```java
interface IMessage {
    public void send(String message);
    public interface IChannel {
        public boolean build();
        public void close();
    }
    public abstract class AbstractHandle {
        public abstract String addPrefix(String value);
    }
    public static IChannel getDefaultChannel() {
        return new InternetChannel();
    }
    public static MessageHandle getDefaultHandle() {
        return new MessageHandle();
    }
    public class InternetChannel implements IMessage.IChannel {
        public boolean build() {
            System.out.println("创建连接……");
            return true;
        }
        public void close() {
            System.out.println("关闭连接……");
        }
    }
    public class MessageHandle extends IMessage.AbstractHandle {
        public String addPrefix(String value) {
            return "poorpool said: " + value;
        }
    }
}
class DksMessage implements IMessage {
    public void send(String message) {
        IMessage.IChannel channel = IMessage.getDefaultChannel();
        IMessage.MessageHandle handle = IMessage.getDefaultHandle();
        channel.build();
        System.out.println(handle.addPrefix(message));
        channel.close();
    }
}
class SplendidHandle extends IMessage.MessageHandle {
    public String addPrefix(String value) {
        return "可菲尔·欣·佳奈·璃莹殇·安洁莉娜·樱雪羽晗灵·血丽魑·魅·J·Q·安塔利亚·伤梦薰魅·海瑟薇 said: " + value;
    }
}
class MlsMessage implements IMessage {
    public void send(String message) {
        IMessage.IChannel channel = IMessage.getDefaultChannel();
        IMessage.MessageHandle handle = new SplendidHandle();
        channel.build();
        System.out.println(handle.addPrefix(message));
        channel.close();
    }
}
public class OuterDemo {
    public static void main(String[] args) {
        DksMessage dksMsg = new DksMessage();
        dksMsg.send("欢迎光临德克士");
        MlsMessage mlsMsg = new MlsMessage();
        mlsMsg.send("你好");
    }
}
```
输出结果
```
创建连接……
poorpool said: 欢迎光临德克士
关闭连接……
创建连接……
可菲尔·欣·佳奈·璃莹殇·安洁莉娜·樱雪羽晗灵·血丽魑·魅·J·Q·安塔利亚·伤梦薰魅·海瑟薇 said: 你好
关闭连接……
```

## 多线程
### 继承Thread类
然而显然不推荐……因为java是单继承。
```java
package com.poorpool.demo;

class MyThread extends Thread {
    public String name;

    public MyThread(String name) {
        this.name = name;
    }

    @Override
    public void run() {
        for(int i=0; i<10; i++)
            System.out.println(name + i);
    }
}
public class HelloDemo {
    public static void main(String[] args) {
        Thread thread1 = new MyThread("first");
        Thread thread2 = new MyThread("second");
        Thread thread3 = new MyThread("third");
        thread1.start();
        thread2.start();
        thread3.start();
    }
}
```

### 使用Runnable接口
```java
package com.poorpool.demo;

class MyThread implements Runnable {
    public String name;

    public MyThread(String name) {
        this.name = name;
    }

    @Override
    public void run() {
        for(int i=0; i<10; i++)
            System.out.println(name + i);
    }
}
public class HelloDemo {
    public static void main(String[] args) {
        Runnable thread1 = new MyThread("first");
        Runnable thread2 = new MyThread("second");
        Runnable thread3 = new MyThread("third");
        new Thread(thread1).start();
        new Thread(thread2).start();
        new Thread(thread3).start();
    }
}
```
其实看源代码能发现Thread类里头有
```java
/* What will be run. */
private Runnable target;

public Thread(Runnable target) {
    this(null, target, "Thread-" + nextThreadNum(), 0);
}

@Override
public void run() {
    if (target != null) {
        target.run();
    }
}
```

### 共享数据
```java
package com.poorpool.demo;

class MyThread implements Runnable {
    public int ticket = 15;

    @Override
    public void run() {
        while(ticket>0) {
            System.out.println("sell ticket " + ticket);
            ticket--;
        }
    }
}
public class HelloDemo {
    public static void main(String[] args) {
        MyThread myT = new MyThread();
        new Thread(myT).start();
        new Thread(myT).start();
        new Thread(myT).start();
    }
}
```
用一个实现Runnable的类扔到多个Thread里头的方法比较常见。上面就是三线程卖票（虽然有一点碰撞）。

### Callable接口实现返回值
```java
package com.poorpool.demo;

import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

class MyThread implements Callable<String> {

    @Override
    public String call() throws Exception {
        String result = "";
        for(int i=0; i<5; i++)
            result += String.valueOf(i);
        return result;
    }
}

public class HelloDemo {
    public static void main(String[] args) throws Exception {
        MyThread myT = new MyThread();
        FutureTask<String> future = new FutureTask<>(myT);
        Thread thread = new Thread(future);
        thread.start();
        System.out.println(future.get());
    }
}
```
Callable是一个FunctionalInterface，FutureTask是一个实现了RunnableFuture接口的类，RunnableFuture继承了Runnable、Future接口。get方法会阻塞，从而实现异步返回。

### 生产者消费者模型实例
```java
package com.poorpool.demo;

class Message {
    private String title;
    private String content;
    private boolean flag = true;//true produce, false consume

    public synchronized void set(String title, String content) {
        if(!this.flag) {
            try {
                super.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        this.title = title;
        try {
            Thread.sleep(100);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        this.content = content;
        this.flag = false;
        super.notify();
    }
    public synchronized String get() {
        if(this.flag) {
            try {
                super.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        this.flag = true;
        super.notify();
        return "[" + this.title + "] " + this.content;
    }
}
class ProduceThread implements Runnable {
    private Message message;

    public ProduceThread(Message message) {
        this.message = message;
    }

    @Override
    public void run() {
        for(int i=0; i<10; i++) {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (i % 2 == 0)
                this.message.set("poorpool", "nihao");
            else
                this.message.set("qwqwq", "goodbye");
        }
    }
}

class ConsumeThread implements Runnable {
    private Message message;

    public ConsumeThread(Message message) {
        this.message = message;
    }

    @Override
    public void run() {
        for(int i=0; i<10; i++) {
            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(this.message.get());
        }
    }
}

public class HelloDemo {
    public static void main(String[] args) throws Exception {
        Message message = new Message();
        new Thread(new ProduceThread(message)).start();
        new Thread(new ConsumeThread(message)).start();
    }
}
```

## 资源文件
```java
package com.poorpool.demo;

import java.util.ResourceBundle;

public class HelloDemo {
    public static void main(String[] args) throws Exception {
        ResourceBundle resourceBundle = ResourceBundle.getBundle("com.poorpool.resource.Ds");
        String str = resourceBundle.getString("hello.msg");
        System.out.println(str);
    }
}
```
文件存放在相应位置的properties的文件，形如`hello.mgs=Ni hao`，等号不能有空格。