---
title: Java Web 学习札记2
date: 2020-05-30 18:38:58
tags:
- Java
- Web
categories:
- Web
---
建议改名游记.jpg

课程[来源](https://www.bilibili.com/video/BV1Y7411K7zz)。

<!--more-->

# XML
和html挺像。用dom4j（第三方来解析吧）。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<books>
    <book sn="SN12341232">
        <name>辟邪剑谱</name>
        <price>9.9</price>
        <author>班主任</author>
    </book>
    <book sn="SN12341231">
        <name>葵花宝典</name>
        <price>99.99</price>
        <author>班长</author>
    </book>
</books>
```
```java
package com.poorpool.orz;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.junit.Test;

import java.util.List;

public class Dom4jTest {
    @Test
    public void test1() throws Exception {
        SAXReader saxReader = new SAXReader();
        Document document = saxReader.read("src/books.xml");
        Element root = document.getRootElement();
//        System.out.println(root.asXML()); 输出了整个xml字符串
        List<Element> books = root.elements("book");//通过标签查找子元素
        for(Element book : books) {
            String nameText = book.element("name").getText();
            String priceText = book.elementText("price");//都可以
            String authorText = book.elementText("author");
            System.out.println(nameText + priceText + authorText);
            System.out.println(book.attributeValue("sn"));
        }
    }
}

```

# Servlet
用tomcat容器。
## 生命周期
构造方法，init()最开始调用一次。

service()每次访问都调用。

destory()销毁时候执行。

## 使用
实际开发很少写一个类去实现Servlet接口，而是继承HttpServlet类，重写doGET()和doPOST()，然后添加到xml里头。

`src/com/poorpool/servlet/HelloServlet2.java`
```java
package com.poorpool.servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class HelloServlet2 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("doget");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("dopost");
    }
}
```

`web/WEB-INF/web.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    <servlet>
        <servlet-name>HelloServlet2</servlet-name>
        <servlet-class>com.poorpool.servlet.HelloServlet2</servlet-class>
    </servlet>
    <servlet-mapping><!--配置访问地址-->
        <servlet-name>HelloServlet2</servlet-name>
        <url-pattern>/hello2</url-pattern>
    </servlet-mapping>
</web-app>
```

浏览器中访问`http://地址（可能端口后面还有工程路径）/hello2`就能在控制台看到doget了。

## 继承结构
GenericServlet抽象类实现Servlet接口，HttpServlet类继承GenericServlet抽象类。HttpServlet类抛没有实现doGet()和doPost()异常，用户自己继承HttpServlet类override这俩。

## ServletConfig
比方说
```java
public class HelloServlet implements Servlet {
    @Override
    public void init(ServletConfig servletConfig) throws ServletException {
        System.out.println(servletConfig.getServletName());
        System.out.println(servletConfig.getInitParameter("username"));
        System.out.println(servletConfig.getServletContext());
    }
    ...
```
```xml
<servlet>
    <servlet-name>HelloServlet</servlet-name><!--别名-->
    <servlet-class>com.poorpool.servlet.HelloServlet</servlet-class><!--全类名-->
    <init-param>
        <!--初始参数-->
        <param-name>username</param-name>
        <param-value>root</param-value>
    </init-param>
</servlet>
...
```
输出就是
```
HelloServlet
root
org.apache.catalina.core.ApplicationContextFacade@1249e65c
```
getServletConfig()也可以获得ServletConfig。

不过注意如果继承HttpServlet的类（其实是GenericServlet抽象类）要重写init()方法的话一定要super.init(config)。有操作哒。

## ServletContext
是个接口，表示Servlet上下文对象。一个工程只有一个实例。它是一个域对象。

域对象是可以像 Map 一样存取数据的对象。用setAttribute()，getAttribute()和removeAttribute()。

四大功能：

1. 获取 web.xml 中配置的上下文参数 context-param。
2. 获取当前的工程路径。格式: /工程路径。
3. 获取工程部署后在服务器硬盘上的绝对路径。
4. 像 Map 一样存取数据。
`web.xml`
```xml
<context-param><!--属于整个web工程的上下文参数-->
    <param-name>username</param-name>
    <param-value>qwq</param-value>
</context-param>
```

`ContextServlet.java`
```java
package com.poorpool.servlet;

import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ContextServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ServletContext sc = getServletConfig().getServletContext();
        System.out.println("name is " + sc.getInitParameter("username"));
        System.out.println("工程路径 " + sc.getContextPath());//  /05_web_war_exploded3
        System.out.println("部署的路径 " + sc.getRealPath("/"));// /home/.../out/artifacts/05_web_war_exploded3/
        System.out.println("资源的路径 " + sc.getRealPath("/a.html"));// /home/.../out/artifacts/05_web_war_exploded3/a.html
    }
}
```

我感觉这个的用处就是比如自己想要根据请求修改一些文件，例如`/img/1.jpg`，但是我又不可能在代码中硬编码一个`/home/.../web/img/1.jpg`进去，所以就可以`getRealPath("/img/1.jpg")`这样的。

如果是像Map一样保存数据的话：
```java
public class ContextServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ServletContext sc = getServletConfig().getServletContext();
        System.out.println("保存以前key1 " + sc.getAttribute("key1"));
        sc.setAttribute("key1", "qwq");
        System.out.println("保存以后key1 " + sc.getAttribute("key1"));
    }
}
```
```java
public class ContextServlet2 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ServletContext sc = getServletConfig().getServletContext();
        System.out.println("另一个Servlet key1 " + sc.getAttribute("key1"));
    }
}
```

```
保存以前key1 null
保存以后key1 qwq
另一个Servlet key1 qwq
```

## 获得请求信息
```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    System.out.println("URI => " + request.getRequestURI());
    System.out.println("URL => " + request.getRequestURL());
    System.out.println("客户端 ip 地址 => " + request.getRemoteHost());
    System.out.println("请求头 User-Agent ==>> " + request.getHeader("User-Agent"));
    System.out.println( "请求的方式 ==>> " + request.getMethod() );
}
```

```
URI => /07_web_war_exploded/hello1
URL => http://localhost:8080/07_web_war_exploded/hello1
客户端 ip 地址 => 127.0.0.1
请求头 User-Agent ==>> Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:76.0) Gecko/20100101 Firefox/76.0
请求的方式 ==>> GET
```

获得GET的表单信息
```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String[] hobby = request.getParameterValues("hobby");
    System.out.println("名字 " + username);
    System.out.println("密码 " + password);
    System.out.println(Arrays.asList(hobby));
}
```
```html
<form action="http://localhost:8080/07_web_war_exploded/hello1" method="get">
    用户名：<input type="text" name="username"><br/>
    密码：<input type="password" name="password"><br/>
    兴趣爱好：<input type="checkbox" name="hobby" value="cpp">C++
    <input type="checkbox" name="hobby" value="java">Java
    <input type="checkbox" name="hobby" value="js">JavaScript<br/>
    <input type="submit">
</form>
```

post也一样，但是如果post直接搞含中文的会乱码，要设置`req.setCharacterEncoding("UTF-8");`。

## 请求转发

1. 地址栏不变化
2. 是一次转发
3. 共享Request域数据
4. 甚至可以访问WEB-INF。
5. 但是仍然不能访问工程之外的东西。

关于第四条：
> 因为web-inf下,应用服务器把它指为禁访目录,即直接在浏览器里是不能访问到的.
但是可以让servlet进行访问,如web-inf下有a.jsp则可以用request.getrequestdispatcher("/web-inf/a.jsp").forward(request,response);  
补充一下，如果你想访问web-inf下的htm文件的话，用request.getrequestdispatcher("/web-inf/a.htm").forward(request,response);是访问不了的。
原因很简单，jsp就是servlet，会被编译成class文件，而htm的就不行了。
所以需要配置以下conf下的web.xml文件才能去访问htm。
具体实现如下：
用打开tomcat安装目录下conf下的web.xml文件，找到
\<servlet-mapping>
\<servlet-name>jsp\</servlet-name>
\<url-pattern>*.jsp\</url-pattern>
\</servlet-mapping>
然后在它下面添加
\</servlet-mapping>
\<servlet-mapping>
\<servlet-name>jsp\</servlet-name>
\<url-pattern>*.html\</url-pattern>
\</servlet-mapping>


`Servlet1.java`
```java
package com.poorpool.demo;

import javax.servlet.RequestDispatcher;
import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class Servlet1 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("username " + request.getParameter("username"));
        request.setAttribute("key1", "qwq");
        RequestDispatcher rd = request.getRequestDispatcher("/servlet2");// 要以/开头
        rd.forward(request, response);// 还有不要以为 forward 以后就跟 return 一样了，不要在 forward 后又搞出来 forward 之类的操作
    }
}
```

`Servlet2.java`
```java
package com.poorpool.demo;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class Servlet2 extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("username " + request.getParameter("username"));
        System.out.println(request.getAttribute("key1"));
    }
}
```

## base标签

设想这样的场景：web/index.html，web/a/b/c.html。index到c的超链接可以用`a/b/c.html`，c到index可以`../../index.html`。

但是如果使用请求转发，index.html中有一个朝向`http://localhost:8080/xxx/forwardC`的链接，用这个链接转发到`a/b/c.html`，是可以的。但是如果c仍然使用`../../index.html`，因为此时的地址仍然是那个Servlet的，而不是`http://localhost:8080/xxx/a/b/c.html`，所以就不能正常返回了。

所以要么使用绝对路径，要么在使用相对路径的时候加上一个base标签。在head中加入
```
<base href="http://localhost:8080/xxx/a/b/c.html"/>
```

注意一下：`/`斜杠被浏览器解析就是ip+端口。被web服务器解析就是`http://ip:port/工程路径`，但是如果要让它被服务器解析，就是`response.sendRediect("/");`

## HttpServletResponse

它可以获得字节流getOutputStream()或者是字符流getWriter()，二选一，不能都取得。用法显然。

但是写中文会有乱码，可以用它解决：
```
// 它会同时设置服务器和客户端都使用 UTF-8 字符集,还设置了响应头
// 此方法一定要在获取流对象之前调用才有效
resp.setContentType("text/html; charset=UTF-8");
```

## 请求重定向

1. 地址栏变化
2. 两次请求
3. 不共享Request域数据
4. 不能访问WEB-INF数据
5. 可以访问工程外数据

直接
```java
response.sendRedirect("http://localhost:8080/xxx");
```
就好。