---
title: 华科 Java 笔记 1
date: 2021-03-01 14:12:20
tags:
- Java
- 笔记
categories:
- 笔记
---
随便记一下

<!--more-->

# 基础

源代码 .java，编译成 .class。

applet 只能在网页里面运行。

javac 编译，java 运行，jdb 调试 java 程序。

Java 没有全局函数，没有全局变量。

main 函数签名一定是 `public static void main(String[] args)`。

.class 是字节码，可以在任何装有 jvm 的机器上运行。

命令行运行 java 程序的时候要指定 classpath。

```bash
java -classpath . net.yxchen.test.Main
```

在存放 net 文件夹的地方输入上述命令。

Java 有三种注释，第三种是 JavaDoc 注释

```java
/**

*/
```

可以注释类，类的方法，类的数据成员之类的。

# 输入输出和成员

System.in InputStream 的对象。

java.util.Scanner 读入。

Scanner scanner = new Scanner(System.in)

scanner.nextDouble() 之类的。

java 标识符可以有美元号。

常量用 final。

函数里的**局部变量**在使用前必须赋值。成员变量有默认值。

值类型作为方法调用参数的时候是传值调用，引用类型作为方法调用参数的时候是**传引用调用**。

值类型 boolean,char, byte, short,int, long, float,double,void。

引用类型有 class，interface，**array**。

代码风格检查工具可以用 CheckStyle。

&& 和 & 的区别（除了位运算）：前者会截断。

boolean 类型和其他任何类型不能相互转换！

二元运算符必定先算左边，这个有规定，不像 cpp。

switch 不支持 long，只支持 char byte short int 及其包裹类、String、枚举。

从大类型转小类型要显示说明。

一个 Java 源文件可以包含多个类定义，但最多只能包含一个 public 类定义；如果 Java 源文件里包含 public 类定义，则该源文件的文件名必须与这个 public 类的类名相同。

# 函数和字符串

Math.random方法生成[0.0,1.0)之间的double类型的随机数

由于字符串是不可变的，为了提高效率和节省内存，Java中的字符串字面值维护在字符串常量池中）。这样的字符串称为规范字符串(canonical string)。

可以使用字符串对象（假设内容为Welcome to Java）的intern方法返回规范化字符串。intern方法会在字符串常量池中找是否已存在”Welcome to Java”,如果有返回其地址。如果没有，在池中添加“Welcome to java”再返回地址。即intern方法一定返回一个指向常量池里的字符串对象引用。

字符串对象创建之后，其内容是不可修改的。

StringBuilder与StringBuffer(final类）初始化后还可以修改字符串。

StringBuffer修改缓冲区的方法是同步（synchronized）的，更适合多线程环境。StringBuilder 快。

形参不允许有默认值，最后一个可为变长参数（可用…或数组定义，参见第7章数组）。方法里不允许定义static局部变量。

子类实例函数里用” super.方法名“调用父类实例方法。

```java
String s5 = "Wel";
String s6 = "come";
String s7 = s5 + s6;
// s7 != "Welcome" !!!!!!
//"Wel" + "come" == "Welcome"
```

> 引用类型的实参传递给形参后，实参、形参指向同一个对象。
> 但是，对于String类、基本数据类型的包装类型的实参传递给形参，形参变了不会导致实参变化。这是为什么？
> 这是因为String、Integer的内容是不可更改的（里头是 final）
> 赋值实际上是创建一个新对象，也就是指向变了
> 包装类要和基本数据类型行为一致

java.util.Arrays类包括各种静态方法，其中实现了数组的排序和查找

二维数组每一行的的列数可以不同。也就是只指定第一维大小。不指定的为 null。

# 对象

当创建对象数组时，数组元素的缺省初值为null。

二义性只有当名字被使用时才被检测到。

数组的长度用 length，字符串长度 length()。