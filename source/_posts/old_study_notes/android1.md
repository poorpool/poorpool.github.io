---
title: 关于 Android 的笔记 1
date: 2020-08-15 16:30:22
tags:
- Android
categories:
- 笔记
---

来自《第一行代码》

<!--more-->

# 基础

## 控制语句

Kotlin 的 if 可以有返回值，就是花括号里头最后一行代码。

when 比 switch 更高级。也能有返回值。如果不写小括号和里头的东西，就可以在条件的地方写上 `someParam == 1` 这种东西。不必使用 equals。

```kotlin
fun qwq(name: String) = when (name) {
    "tom" -> 1
    "jack" -> 3
    "poorpool" -> -1
    else -> 0
}
fun checkNumber(num: Number) {
    when (num) {
        is Int -> println("int")
        is Double -> println("double")
        else -> println("others")
    }
}
```

for-i 循环没了（震撼我妈，用：

```kotlin
for (i in 0..10) {
    println(i)
}
```

两个点是闭区间。until 是左闭右开区间。在后头加上 `step 2` 可以设置步长。`for (i in 10 downTo 1)` 倒序。

## 对象

定义类就：

```kotlin
class Person {
    var name = ""
    var age = 0
    fun eat() {
        println("name is " + name + ", age is " + age)
    }
}
```

直接点运算符访问、修改对象和执行函数。注意，类默认不可继承。要继承的话父类 class 前头加 open,子类用 `class Student : Person() {...` 这种东西。

构造函数分为主构造函数和次构造函数。主构造函数可以写参数

```kotlin
open class Person(val name: String, var age: Int) {
    fun eat() {
        println("name is " + name + ", age is " + age)
    }
}
```

加了 val/var 以后的参数自动成为本类的字段。所以说 Student 可以改造为 `class Student(val school: String, name: String, age: Int) : Person(name, age) {...` 这种东西，不加 val/var 就能把作用域限定在主构造函数里头。

顺带一提每个类都可以写个 `init{ ... }` 执行一些代码。所有次构造函数都必须调用主构造函数。例如 Person 写一个 `constructor() : this("", 0) {}`。可以没有主构造函数。

修饰符就是把 java 四种修饰符的 default 变成了 internal。public 变成了什么都不写的默认项目（java 是 default），internal 是同一模块可见。protected 去掉了同一包路径可见。

数据类就像 java bean，前面加个 data 就行了，equals 什么的都不用写了……没有代码的话花括号都不用了（喜

单例类直接把 class 换成 object 完事（tql

```kotlin
data class CellPhone(val brand: String, val price: Double)
```

## 接口

没有 extends 和 implements 了，直接冒号后头跟上继承的类和实现的接口。逗号隔开。`@Override` 变成了扎起 fun 前头加 `override`。接口也可以有默认的实现函数。

## Lambda

listOf(a, b, c) 创建不可变集合，mutableListOf 创建可变的（当然也可以一个一个 add）。

lambda 表达式：`{param1: Type, xxx -> 函数体}`。


函数式 api：

```kotlin
val list = listOf("apple", "banana", "billy")
println(list.maxBy({fruit: String -> fruit.length}))
```

lambda 表达式是函数最后一个参数可以把 lambda 表达式移到外头，小括号也可以省略，一个参数也可以直接用 it 表示。所以上面的可以写成 `list.maxBy {it.length}`

和 js 一样，也有 filter 和 map。用 any 和 all 做判断。这东西自行百度吧。来一段省略带师：

```kotlin
Thread(object: Runnable {// java 的 new 变成了 object
    override fun run() {
        println("new thread")
    }
}).start()
// 省略 object:
// 因为就一个待实现方法，所以 run 那一行也能省略
// 因为参数列表只有一个单抽象方法接口参数，Runnable 也可以省略
// 还能把 lambda 提到外头
Thread {
    println("new thread")
}.start()
```

对一个对象使用 let 可将调用对象传递到 lambda里头，例子看下头。


## 空指针

kotlin 把空指针异常消灭在编译期。`Int` 不为空，`Int?` 表示可以为空。敢写第二种就要判空了。

例如一个 `student: Student?`，直接 `student.study()` 是不行的。要么包一个 if 判 null，要么就用 `student?.study()`，非空才执行。用 `a ?: b` 表示 a 非空的时候为 a，a 为空则为 b。

```kotlin
student?.let {stu -> 
    stu.study()
}
```

字符串可以内嵌表达式，比如 

```kotlin
val a = 1
println("a is ${a} or $a")。
```

可以用 lateinit 告诉编译器某个变量是延迟初始化的。

## 一些标准函数

with 接收一个对象和一个 lambda 表达式，在表达式中提供那个对象的上下文并以最后一行语句为返回值。

```kotlin
fun main() {
    val list = listOf("apple", "banana")
    val result = with(StringBuilder()) {
        append("Start eating fruits\n")
        for (fruit in list) {
            append("eating $fruit\n")
        }
        toString()
    }
    print(result)
}
```

run 差不多，不过是要 obj.run {xxx}，不能直接用。

apply 和 run 差不多，但是没有返回值而是返回对象本身。

## 静态方法

kotlin 弱化了静态方法的概念，要么用单例类，要么套一个 companion object。（其实调用的就是这个伴生类的方法）。真正的静态方法加 @JvmStatic 或者是顶层方法。

## 高阶函数

在参数列表里里头写 `func: (String, Int) -> Unit`，表示接受一个以 String 和 Int 为参数并什么也不返回（Unit 类比 void）的函数（lambda）。引用一个函数可以使用 `::funcName`。

## 输入输出

对一个 writer 使用 use，例如 `writer.use { xxx }`，会在 lambda 执行完毕以后关闭外面的流。

# Activity

可以使用 Intent 来调起别的 activity。可以通过指定一个 action 多个 category（不一定都要有）来让系统找出合适的 activity 启动（隐式的），也可以直接钦点 activity（显式的）。自己的 activity 在 AndroidManifest.xml 里头对应的 activity 标签下写 intent-filter，用处看名字就能猜出来。

比如：

```kotlin
button1.setOnClickListener {
    val intent = Intent(Intent.ACTION_VIEW)
    intent.data = Uri.parse("https://www.baidu.com")
    startActivity(intent)
}
```

可以自己在 intent-filter 标签里头写上 data 标签响应 https 协议，之类的操作。（感觉这就是实现用别的应用打开的方式啊2333

intent 还能携带额外的 data。也可以用 startActivityForResult 来调用一个 activity 让它返回数据。

## 生命周期

使用任务栈来管理 activity。activity 有运行、暂停、停止、销毁状态。

![activity](/images/android/1.png)

## 启动模式

standard，singleTop（栈顶是当前 activity 就不会再创建一个了），singleTask（返回栈里就一个），singleInstance（存放在单独的返回栈）

## 类委托

使用 by 关键字。

# BroadcastReceiver

属于四大组件。就像 activity 一样，继承 BroadcastReceiver 并重写 onReceive 方法即可。动态注册也一定要取消注册。

intent setPackage 以后变成显式广播，静态注册的 BroadcastReceiver 可以收到，然后 sendBroadcast。

有序广播可以截断，同步执行，标准广播不行。有序广播用 sendOrderBroadcast，在 AndroidManifest 中设置优先级，在 onReceive 中用 abortBroadcast 截断。

# 持久化

存文件，SharedPreferences 存储键值对，数据库。

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val inputText = load()
        if (inputText.isNotEmpty()) {
            editText.setText(inputText)
            editText.setSelection(inputText.length)
            Toast.makeText(this, "Restoring succeeded", Toast.LENGTH_SHORT).show()
        }
    }

    private fun load(): String {
        val content = StringBuilder()
        try {
            val input = openFileInput("data")
            val reader = BufferedReader(InputStreamReader(input))
            reader.use {
                reader.forEachLine {
                    content.append(it)
                }
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return content.toString()
    }

    override fun onDestroy() {
        super.onDestroy()
        val inputText = editText.text.toString()
        save(inputText)
    }

    fun save(inputText: String) {
        try {
            val output = openFileOutput("data", Context.MODE_PRIVATE)
            val writer = BufferedWriter(OutputStreamWriter(output))
            writer.use {
                it.write(inputText)
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
}
```