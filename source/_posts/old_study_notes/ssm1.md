---
title: SSM 框架学习笔记 1
date: 2020-06-18 16:06:34
tags:
- Java
- Spring
categories:
- 框架
---
[课程来源](https://www.bilibili.com/video/BV1d4411g7tv)

<!--more-->

# Spring

是一种容器框架。

## 第一个程序

记得先换 maven 源并且不出现傻叉错误。

还有注意添加 junit5 的时候检查一下模块那部分依赖的 junit 是不是 compile。

`src/net/yxchen/bean/People.java`
```java
package net.yxchen.bean;

public class People {
    private String name;
    private String gender;
    private String email;

    public People() {
        System.out.println("Person 创建了");
    }
    //有参构造，getter、setter、toString 省略
```

`src/applicationContext.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="people1" class="net.yxchen.bean.People">
        <property name="name" value="poorpool"/>
        <property name="gender" value="male"/>
        <property name="email" value="poorpool@yxchen.net"/>
    </bean>
</beans>
```

`src/net/yxchen/test/PeopleTest.java`
```java
package net.yxchen.test;

import net.yxchen.bean.People;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

class PeopleTest {
    @Test
    public void qwq() {
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
        System.out.println("容器创建完毕");
        People people = (People) applicationContext.getBean("people1");
        People people1 = (People) applicationContext.getBean("people1");
        System.out.println(people);
        System.out.println(people == people1);//单例
    }
}
```

输出结果：

```
Person 创建了
容器创建完毕
People{name='poorpool', gender='male', email='poorpool@yxchen.net'}
true
```

getBean 的时候也可以用 Person.class 这种东西，但要保证只有一个匹配。或者你全都要，名字和类型都写上。

自然可以用有参构造器。实在不想写甚至可以省略 name，或者使用 index 指定顺序。也可以用 `type="xxx"` 指定类型。只有神经病才会使用后头的东西。
```xml
<bean id="people2" class="net.yxchen.bean.People">
    <constructor-arg name="name" value="sheska"/>
    <constructor-arg name="gender" value="female"/>
    <constructor-arg name="email" value="sheska@yxchen.net"/>
</bean>
```

超级样例：
```xml
<bean id="people1" class="net.yxchen.bean.People">
    <!-- 赋空值 -->
    <property name="name">
        <null/>
    </property>
    <property name="gender" value="male"/>
    <!-- 引用 -->
    <property name="car" ref="car1"/>
    <!-- 当然你也可以在 property 标签里头嵌套一个 bean 标签，做内部 bean -->

    <property name="carList">
        <!-- 赋值一个 list，是 ArrayList -->
        <list>
            <!-- p 命名空间 -->
            <bean class="net.yxchen.bean.Car" p:color="red" p:carId="123"/>
            <bean class="net.yxchen.bean.Car" p:color="blue" p:carId="456"/>
        </list>
    </property>

    <!-- map 也差不多，是 LinkedHashMap。map 标签下是一个个 entry 标签 -->

    <!-- property 底下是 props，底下是 prop。key 和 value 都是字符串 -->

    <!-- 配置集合类型的 bean 可以使用 util 名称空间，util:list 下头一堆 bean 或者 value，这样的 list 可以写 id -->、
    
    <!-- 级联属性比如 car.color，就这么加点地写 name 就可以了 -->
</bean>
```

使用 parent="xxx" 可以继承一个 bean 的配置，这样就不用写好多。如果一个 bean 只想让别人继承，就加一个 abstract="true"。如果有依赖（就是谁要在谁之前创建），就写 depends-on="person1, book1" 之类的。

## bean 的 scope

加一个 scope="xxx" 可以指定 bean 的作用域，常用的为 prototype 多实例和 singleton 单实例。还有 request 和 session 但是用得少。prototype 在容器启动时候不会创建实例，每次取得才会。

## 工厂类取得 bean

静态工厂：

```java
public class CarStaticFactory {
    public static Car getCar(String color) {
        Car car = new Car();
        car.setCarId(1);
        car.setColor(color);
        return car;
    }
}
```

```xml
<bean id="car1" class="net.yxchen.factory.CarStaticFactory" factory-method="getCar">
    <constructor-arg value="yellow"/><!-- 可以写参数 -->
</bean>
```

实例工厂，先搞出来工厂再创建 bean：

```xml
<bean id="factory1" class="net.yxchen.factory.CarInstanceFactory"/>
<bean id="car1" class="net.yxchen.bean.Car" factory-bean="factory1" factory-method="getCar">
    <constructor-arg value="yellow"/>
</bean>
```

还有一个操作是实现 FactoryBean 接口：

`src/net/yxchen/factory/FactoryBeanImpl`
```java
package net.yxchen.factory;

import net.yxchen.bean.Car;
import org.springframework.beans.factory.FactoryBean;

public class FactoryBeanImpl implements FactoryBean<Car> {
    @Override
    public Car getObject() throws Exception {
        System.out.println("factory bean 创建对象");
        return new Car("red", 1);
    }

    @Override
    public Class<?> getObjectType() {
        return Car.class;
    }

    @Override
    public boolean isSingleton() {
        return false;
    }
}
```

```xml
<bean id="car1" class="net.yxchen.factory.FactoryBeanImpl"/>
```

别看长得像一个普通 bean，只要实现了 FactoryBean 接口就会被认为是一个工厂：

```java
Car car = (Car) applicationContext.getBean("car1");
Car car1 = (Car) applicationContext.getBean("car1");
System.out.println(car);
System.out.println(car1);
System.out.println(car == car1);
```

```
factory bean 创建对象
factory bean 创建对象
Car{color='red', carId=1}
Car{color='red', carId=1}
false
```

顺带一提，不要想着用 ${username} 这种东西，这是 Spring 的关键字……系统用户名。

## 生命周期

可以使用 init-method="xxx" 和 destroy-method="xxx" 来指定创建和销毁 bean 的时候的方法。

可以添加后置处理器，在调用初始化方法前后对 IOC 容器里头所有的实例都搞一遍。

1. 通过构造器或工厂方法创建 bean 实例；
2. 为 bean 的属性设置值和对其他 bean 的引用
3. 将 bean 实例传递给 bean 后置处理器的 postProcessBeforeInitialization() 方法；
4. 调用 bean 的初始化方法；
5. 将 bean 实例传递给 bean 后置处理器的 postProcessAfterInitialization() 方法；
6. bean 可以使用了；
7. 当容器关闭时调用 bean 的销毁方法。

## 自动装配

使用 autowire。有 byName，byType，constructor 等等。

```xml
<bean id="car" class="net.yxchen.factory.FactoryBeanImpl"/>
<bean id="people1" class="net.yxchen.bean.People" autowire="byName">
    <property name="name" value="poorpool"/>
</bean>
```

java bean 程序里头怎么写，这里的 id 就要怎么写。

constructor 的话，比如`public People(Car car)` 的话，首先按照有参构造器类型进行装配，没有就直接赋 null。有的话，如果有多个，就拿名作为 id，没有就直接赋 null。

## SpEL 

就和 EL 表达式差不多。写法是 `#{xxx}`。可以写字面量 `#{123.4*5}`，其他 bean 的属性 `#{book01.bookName}`，其他 bean `#{car01}`，甚至是静态方法 `#{T(全类名).静态方法名(args)}`。动态方法和其他 bean 的属性差不多。

## 注解配置

有四个注解：`@Repository` 给 dao /持久层，`@Service` 给业务层，`@Controller` 给控制层，`@Component` 给其他受 Spring IOC 容器管理的组件。

写的时候加上对应的注解：

```java
@Repository
public class BookDao {
}
```

当然也可以指定 bean 名和单例多例之类的：

```java
@Repository("qwqwq")
@Scope("prototype")
```

然后在配置 xml 里头写上自动扫描：

```xml
<context:component-scan base-package="net.yxchen"/>
```

可以排除不要包含的文件：

```xml
<context:component-scan base-package="net.yxchen">
    <!-- 按照注解排除文件，里头写上注解的全类名 -->
    <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Repository"/>
    <!-- 按照全类名排除文件 -->
    <context:exclude-filter type="assignable" expression="net.yxchen.dao.BookDao"/>
    <!-- 其实还能按照正则之类的排除文件 -->
</context:component-scan>
```

也可以指定要包含什么：

```xml
<context:component-scan base-package="net.yxchen" use-default-filters="false">
    <!-- 取消了默认的全扫描过滤器以后手动钦点谁要来 -->
    <context:include-filter type="annotation" expression="org.springframework.stereotype.Repository"/>
</context:component-scan>
```

## autowired 注解

通过 autowired 注解实现自动装配：

```java
@Repository
public class BookDao {
    public void saveBook() {
        System.out.println("bookDao-保存图书");
    }
}
```

```java
@Service
public class BookService {

    @Autowired
    private BookDao bookDao;

    public void saveBook() {
        System.out.println("bookService-保存图书");
        bookDao.saveBook();
    }
}
```

```java
@Controller
public class BookServlet {
    @Autowired
    private BookService bookService;

    public void doGet() {
        bookService.saveBook();
    }
}
```

Autowired 是根据类型自动装配，找到一个就装配一个，没找到就爆炸。找到多个就按照变量名的 id 找。如果找不到的话……用 Qualifier

例如：

```java
@Repository
public class BookDao {
```

```java
@Repository
public class BookDaoExt extends BookDao {
```

```java
@Service
public class BookService {

    @Autowired
    @Qualifier("bookDao")
    private BookDao bookDaoExt;

    public void saveBook() {
        System.out.println("bookService-保存图书");
        bookDaoExt.saveBook();
    }
}
```

如果没有那个 Qualifier，因为变量名叫 bookDaoExt，所以就会找一个叫这个的。但是有了 Qualifier，就会按照 Qualifier 钦点的找。

如果钦点了 Qualifier 居然还没找到就还是得报异常。可以钦点 @Autowired(required=false)，这样找不到就装配 null 不报异常了。

Qualifier 甚至可以在参数上写：

```java
@Controller
public class BookServlet {
    @Autowired
    private BookService bookService;

    public void doGet() {
        bookService.saveBook();
    }

    @Autowired
    public void func1(BookService bookService, @Qualifier("bookDao") BookDao bookDaoExt) {
        System.out.println(bookService + ", " + bookDaoExt);
    }
}
```

顺带一提，autowired 的方法，当 Spring 容器在创建这个方法的时候会自动调用这个方法。每一个参数都会自动注入值。

另外，@Resource 这个 java ee 中的注解也可以实现自动装配。比 @Autowired 要差，但是扩展性好（因为后者必须要 Spring）。

## 单元测试

如果想在单元测试中使用自动装配呢？是这样吗：

```java
@Component
public class IOCTest {
    ApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");

    @Autowired
    private BookService bookService;

    @Test
    public void test1() {
        System.out.println(bookService);
    }
}
```

发现死循环了……

其实要这么做：

```java
package net.yxchen.test;

import net.yxchen.service.BookService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)//指定用谁来单元测试
@ContextConfiguration(locations = "classpath:applicationContext.xml")//指定配置文件的位置
public class IOCTest {
    ApplicationContext applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");

    @Autowired
    private BookService bookService;

    @Test
    public void test1() {
        System.out.println(bookService);
    }
}
```

## 泛型注入

```java
package net.yxchen.dao;

public abstract class BaseDao<T> {
    public abstract void save();
}
```

```java
package net.yxchen.dao;

import net.yxchen.bean.Car;
import org.springframework.stereotype.Repository;

@Repository
public class CarDao extends BaseDao<Car> {

    @Override
    public void save() {
        System.out.println("carDao...save");
    }
}
```

```java
package net.yxchen.service;

import net.yxchen.dao.BaseDao;
import org.springframework.beans.factory.annotation.Autowired;

public class BaseService<T> {
    @Autowired
    BaseDao<T> baseDao;

    public void save() {
        System.out.println("baseService...save");
        baseDao.save();
    }
}
```

```java
package net.yxchen.service;

import net.yxchen.bean.Car;
import org.springframework.stereotype.Service;

@Service
public class CarService extends BaseService<Car> {

}
```

然后发现这玩意居然能够自动装配！结果是：

```
baseService...save
carDao...save
```

其实也很好理解。对一个 carService 执行 save()，自动装配的是 `BookDao<Car>`，自然回去找这样的类。
