---
title: SSM 框架学习笔记 4
date: 2020-06-30 16:46:49
tags:
- Java
- Spring
categories:
- 框架
---
[课程来源](https://www.bilibili.com/video/BV1d4411g7tv)

<!--more-->

# SpringMVC

## 拦截器

就是高级 filter。

```java
package net.yxchen.interceptor;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class HelloInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println("pre handle");
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        System.out.println("post handle");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        System.out.println("after completion");
    }
}
```

```xml
<mvc:interceptors><!-- 要拦截所有的请求直接在 interceptors 底下写一个 bean 就好了 -->
    <mvc:interceptor>
        <mvc:mapping path="/interceptor"/>
        <bean class="net.yxchen.interceptor.HelloInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

（/interceptor 将页面转发到 success.jsp）

可以看出，顺序是 pre-目标方法-post-加载页面-after。多拦截器就是谁先配谁先执行。谁不放行，以后就都没有了。但是以前放行了的拦截器的 afterCompletion 还会执行。

## 异常处理

可以直接写一个方法处理掉特定类型的异常：

```java
@ExceptionHandler(ArithmeticException.class)
public String arithmeticHandler() {
    System.out.println("算数错误");
    return "error";
}
```

自然也可以写一个异常处理类

```java
@ControllerAdvice
public class MyExceptionHandler {
    @ExceptionHandler(ArithmeticException.class)
    public ModelAndView arithmeticHandler(Exception e) {
        System.out.println("算数错误");
        ModelAndView mav = new ModelAndView("error");
        mav.addObject("e", e);
        return mav;
    }
}
```

可以使用 @ResponseStatus 做一个自定义异常状态，类似于`404-页面飞了` 这种感觉，自己搜。

## 工作流程

（非原创，来自课程的笔记）

1. 用户向服务器发送请求，请求被SpringMVC 前端控制器 DispatcherServlet捕获；
2. DispatcherServlet对请求URL进行解析，得到请求资源标识符（URI），判断请求URI对应的映射：
	- 不存在：再判断是否配置了mvc:default-servlet-handler：
		- 如果没配置，则控制台报映射查找不到，客户端展示404错误；
		- 如果有配置，则执行目标资源（一般为静态资源，如JSP，HTML）；
	- 存在：执行下面流程；
3. 根据该URI，调用HandlerMapping获得该Handler配置的所有相关的对象（包括Handler对象以及Handler对象对应的拦截器），最后以HandlerExecutionChain对象的形式返回；
4. DispatcherServlet 根据获得的Handler，选择一个合适的HandlerAdapter；
5. 如果成功获得HandlerAdapter后，此时将开始执行拦截器的preHandler(...)方法【正向】
6. 提取Request中的模型数据，填充Handler入参，开始执行Handler（Controller)方法，处理请求。在填充Handler的入参过程中，根据你的配置，Spring将帮你做一些额外的工作：
	1. HttpMessageConveter： 将请求消息（如Json、xml等数据）转换成一个对象，将对象转换为指定的响应信息；
	2. 数据转换：对请求消息进行数据转换。如String转换成Integer、Double等；
	3. 数据根式化：对请求消息进行数据格式化。 如将字符串转换成格式化数字或格式化日期等；
	4. 数据验证： 验证数据的有效性（长度、格式等），验证结果存储到BindingResult或Error中；
7. Handler执行完成后，向DispatcherServlet 返回一个ModelAndView对象；
8. 此时将开始执行拦截器的postHandle(...)方法【逆向】；
9. 根据返回的ModelAndView（此时会判断是否存在异常：如果存在异常，则执行HandlerExceptionResolver进行异常处理）选择一个适合的ViewResolver（必须是已经注册到Spring容器中的ViewResolver)返回给DispatcherServlet，根据Model和View，来渲染视图；
10. 在返回给客户端时需要执行拦截器的AfterCompletion方法【逆向】；
11. 将渲染结果返回给客户端。

## 整合问题

通常 Spring 和 SpringMVC 整合的时候会分别写配置文件，并且分容器。所以也不会写出来一个 xml import 另一个 xml 这种鬼东西。

显然不能把 component-scan 这种东西写两遍。我们让 Spring 容器管理业务逻辑组件，用 SpringMVC 容器管理控制器组件。

springmvc.xml
```xml
<context:component-scan base-package="net.yxchen" use-default-filters="false">
    <context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
    <context:include-filter type="annotation" expression="org.springframework.web.bind.annotation.ControllerAdvice"/>
</context:component-scan>
```
 
spring.xml
```xml
<context:component-scan base-package="com.atguigu.springmvc">
    <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
    <context:exclude-filter type="annotation" expression="org.springframework.web.bind.annotation.ControllerAdvice"/>
</context:component-scan>
<!-- 配置数据源, 整合其他框架, 事务等. -->
```

在 web.xml 里头用 dispatchservlet 写 springmvc 容器，用下面的写 spring 容器：

```xml
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:beans.xml</param-value>
</context-param>
```

两个容器同时存在，spring 容器为父容器，springmvc 容器为子容器。springmvc 能引用 spring 的 bean，反过来不能。

# MyBatis

MyBatis 是一种持久化层框架（SQL 映射框架）。

使用 jdbc 麻烦又要硬编码 sql 语句。Hibernate 是一种 ORM 框架（对象关系映射），这玩意太强了，居然写 bean 就能解决建表更新等等的糟心事情。它就是个黑箱，不会 sql 也行。但是也是因为黑箱，自己写 sql 也不太方便，所以也不太好。它还是个全映射框架。MyBatis 则是一台能把 sql 写在配置文件里头的半自动洗衣机。

```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.5</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.20</version>
</dependency>
```

从文档复制一份全局配置文件：

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.cj.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://localhost:3306/mybatislearn"/>
                <property name="username" value="root"/>
                <property name="password" value="你的密码"/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="EmployeeDao.xml"/> <!-- 自己写的映射文件。类路径开始 -->
    </mappers>
</configuration>
```

```java
public class Employee {
    private Integer id;
    private String empName;
    private String email;
    private Integer gender;
    //...
}
```

```java
public interface EmployeeDao {
    public Employee getEmpById(Integer id);
    public int updateEmployee(Employee employee);
    public int deleteEmployee(Integer id);
    public int insertEmployee(Employee employee);
}
```

然后写 sql 映射文件，就相当于接口的实现类：

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="net.yxchen.dao.EmployeeDao">
    <select id="getEmpById" resultType="net.yxchen.bean.Employee">
        select * from t_employee where id = #{id}
    </select>
    <update id="updateEmployee"><!-- 都不用写参数类型 -->
        update t_employee set empName=#{empName}, gender=#{gender}, email=#{email} where id=#{id}
    </update>
    <update id="deleteEmployee">
        delete from t_employee where id=#{id}
    </update>
    <update id="insertEmployee">
        insert into t_employee (`empName`, `gender`, `email`) values (#{empName}, #{gender}, #{email})
    </update>
</mapper>
```

```java
public class EmployeeDaoTest {
    @Test
    public void test1() throws Exception {
        String resource = "mybatis.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        EmployeeDao employeeDao = sqlSession.getMapper(EmployeeDao.class);//相当于一个实现类，是一个 proxy 对象

        System.out.println(employeeDao.getEmpById(1));

        Employee employee = new Employee(null, "poorpool", "poorpool@yxchen.net", 0);
        employeeDao.insertEmployee(employee);

        employeeDao.updateEmployee(new Employee(3, "poorpool", "poorpool@yxchen.net", 1));

        employeeDao.deleteEmployee(3);

        sqlSession.commit();//是事务
        sqlSession.close();
    }
}
```

太方便了 qwq。

## 全局配置文件

这些标签是有先后的：

可以使用 properties 标签指定外部配置文件。

settings 修改 mybatis 的运行时规则，比如可以自动驼峰（a_column 到 aColumn）。还有延迟加载和按需加载：

```xml
<settings>
    <setting name="lazyLoadingEnabled" value="true"/><!-- 延迟加载 -->
    <setting name="aggressiveLazyLoading" value="false"/><!-- 按需加载 -->
</settings>
```

typeAliases 给常用的类型起别名。不过 mybatis 给常用类型起好了，我们也没有必要给自己的 bean 起别名。

enviorments 可以配多个环境（然而还是 spring 的强）

mappers 里头的 mapper，可以用 resource 写类路径下的配置文件，可以用 class 指定接口的全类名（然后把配置文件放到同一个包里头），可以用 url 写磁盘或者网络上的配置。可以使用 package 批量注册，但是这时候配置文件要写在包里头。但是把 conf 标为源根以后创建一个同名包会和 src 的同名包合并，所以也不是什么大问题。

## sql 映射文件

获得自增主键的值：

```xml
<update id="insertEmployee" useGeneratedKeys="true" keyProperty="id">
    insert into t_employee (`empName`, `gender`, `email`) values (#{empName}, #{gender}, #{email})
</update>
```

没有自增也有相应的解决方法。

传参的时候，多个参数只能用 `#{1}` 或者 `#{param1}` 这种序号。这是因为 mybatis 将它们封装到了一个 map 中，key 是序号。可以用 @Param 指定参数封装时候的 key。可以传 map。传 pojo 就用属性名做 key。

`#{xxx}` 里头可以指定 jdbctype，这个好像跟 null 有关。其实 `#{xxx}` 和 `${xxx}` 都可以取值，但是前者是参数预编译，就是参数用`?`替代，不会出现 sql 注入问题。后者就是简单拼串。一般都是使用前者，不过表名这种不支持预编译的就用后者就可以了。

## 花式查询

查询 list 和查询 bean 的配置一模一样，只不过方法的返回值变成了 list。如果查询的是集合，那么 resultType 写的就是集合里的元素的全类名。

可以把查询结果封装到 map 里头，属性是 key，值是 value。

```xml
<select id="getEmpMapById" resultType="map"><!-- map 是 mybatis 起好的别名。这个方法返回 Map<String, Object> -->
    select * from t_employee where id=#{id}
</select>
```

上面的是查询结果一行的。如果多行呢？

```java
@MapKey("id")//指定谁作 key
public Map<Integer, Employee> getEmpsMap();
```

```xml
<select id="getEmpsMap" resultType="net.yxchen.bean.Employee"><!-- 写 value 的全类名 -->
    select * from t_employee
</select>
```

如果名字不一样呢，比如数据库是 youjian，java bean 是 email？可以使用 select 起别名：

```xml
<select id="getEmpById" resultType="net.yxchen.bean.Employee">
    select `id`, `empName`, `gender`, `youjian` email from t_employee where id = #{id}
</select>
```

也可以使用 resultmap 硬点对应：

```xml
<select id="getEmpById" resultMap="qwq" >
    select * from t_employee where id = #{id}
</select>
<resultMap id="qwq" type="net.yxchen.bean.Employee">
    <id property="id" column="id"/><!-- primary key -->
    <result property="email" column="youjian"/><!-- 其他 -->
</resultMap>
```

## 联合查询

```java
public class Key {
    private Integer id;
    private String keyName;
    private Lock lock;
    //...
}
```

```java
public class Lock {
private Integer id;
private String lockName;
```

数据库中 t_key 没有 lock，有一个外键 lockId。

如果想级联查询到这个 lock 怎么办？其实能猜出来，用 resultmap 把 lock 的 id map 到 lock.id 就差不多了。

```java
public interface KeyDao {
    public Key getKeyById(Integer id);
}
```

```xml
<select id="getKeyById" resultMap="mykey">
    select k.id kid, k.keyName, l.id lid, l.lockName from t_key k
        left join t_lock l on k.lockId = l.id
        where k.id = #{id};
</select>
<resultMap id="mykey" type="net.yxchen.bean.Key">
    <id property="id" column="kid"/>
    <result property="keyName" column="keyName"/>
    <result property="lock.id" column="lid"/>
    <result property="lock.lockName" column="lockName"/>
</resultMap>
```

更好的做法是使用 association，这样更清晰了：

```xml
<resultMap id="mykey" type="net.yxchen.bean.Key">
    <id property="id" column="kid"/>
    <result property="keyName" column="keyName"/>
    <association property="lock" javaType="net.yxchen.bean.Lock">
        <id property="id" column="lid"/>
        <result property="lockName" column="lockName"/>
    </association>
</resultMap>
```

如果要查询集合呢？比如 Lock 里头加一个 `List<Key> keys`。那就用 collection 呗。

```xml
<select id="getLockById" resultMap="mylock">
    select l.id lid, l.lockName, k.id kid, k.keyName from t_lock l
        left join t_key k on l.id = k.lockId
        where l.id = #{id};
</select>
<resultMap id="mylock" type="net.yxchen.bean.Lock">
    <id property="id" column="lid"/>
    <result property="lockName" column="lockName"/>
    <collection property="keys" ofType="net.yxchen.bean.Key">
        <id property="id" column="kid"/>
        <result property="keyName" column="keyName"/>
    </collection>
</resultMap>
```

（不要在意套娃）

如果嫌写 sql 麻烦可以用分步查询：

```xml
<select id="getLockByIdSimple" resultType="net.yxchen.bean.Lock">
    select * from t_lock where id=#{id}
</select>
```

```xml
<select id="getKeyByIdSimple" resultMap="mykey2">
    select * from t_key where id=#{id}
</select>
<resultMap id="mykey2" type="net.yxchen.bean.Key">
    <id property="id" column="id"/>
    <result property="keyName" column="keyName"/>
    <association property="lock" select="net.yxchen.dao.LockDao.getLockByIdSimple" column="lockId"/>
</resultMap>
```

其实也就是把自己钦点变成了再 select 一次，免去了 left join 之忧。但是效率低。

