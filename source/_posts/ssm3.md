---
title: SSM 框架学习笔记 3
date: 2020-06-25 11:13:12
tags:
- Java
- Spring
categories:
- 框架
---
[课程来源](https://www.bilibili.com/video/BV1d4411g7tv)

<!--more-->

# SpringMVC

## REST

以前我们用 `addBook?id=2` 来表示添加图书 id 为 2 的图书一本，现在用 `book/2` 发 PUT 来修改。用 get、post、put、delete。一个 url 就是一个资源。

这么写：

```java
@Controller
public class RestController {

    @RequestMapping(value = "/book/{bid}", method = RequestMethod.GET)
    public String getBook(@PathVariable("bid") Integer id) {
        System.out.println("获得图书 id " + id);
        return "success";
    }

    @RequestMapping(value = "/book/{bid}", method = RequestMethod.POST)
    public String addBook(@PathVariable("bid") Integer id) {
        System.out.println("添加图书 id " + id);
        return "success";
    }

    @RequestMapping(value = "/book/{bid}", method = RequestMethod.PUT)
    public String modifyBook(@PathVariable("bid") Integer id) {
        System.out.println("修改图书 id " + id);
        return "success";
    }

    @RequestMapping(value = "/book/{bid}", method = RequestMethod.DELETE)
    public String deleteBook(@PathVariable("bid") Integer id) {
        System.out.println("删除图书 id " + id);
        return "success";
    }
}
```

jsp 页面这么写：

```html
<body>
    <a href="book/1">get</a>
    <form action="book/1" method="post">
        <button type="submit">post</button>
    </form>
    <form action="book/1" method="put">
        <button type="submit">put</button>
    </form>
    <form action="book/1" method="delete">
        <button type="submit">delete</button>
    </form>
</body>
```

然后惊喜地发现，put 和 delete 不能用……tomcat 只支持 get 和 post 似乎。也许还有一个 head。这时候就要使用 spring 的 HiddenHttpMethodFilter。

```xml
<filter>
  <filter-name>HiddenHttpMethodFilter</filter-name>
  <filter-class>org.springframework.web.filter.HiddenHttpMethodFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>HiddenHttpMethodFilter</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>
```

并且加上 _method 隐藏域，写下真正的参数。

```html
<form action="book/1" method="post">
    <input type="hidden" name="_method" value="put"/>
    <button type="submit">put</button>
</form>
<form action="book/1" method="post">
    <input type="hidden" name="_method" value="delete"/>
    <button type="submit">delete</button>
</form>
```

这时候 success.jsp 还会 405，这是因为经过那个 filter，http 请求的类型就变成了 put 之类的 jsp 不支持的内容。只要在被转发的页面加上一个 isErrorPage="true" 就好了（这个方法感觉一点也不优雅……）

## 炫酷传参

获得参数：直接在参数列表里头写就好了：

```java
@RequestMapping("/hello")
// 这个是获得参数 user 给 username。如果不用改名删掉 RequestParam 就行了。
// 也可以使用组合拳 @RequestParam(value = "user", required = false, defaultValue = "qwq")，此时 user 不再必须有，没有的时候有一个默认值 qwq。
public String hello(@RequestParam("user") String username) {
    System.out.println("username 是 " + username);
    return "success";
}
```

可以使用 `@RequestHeader("User-Agent")` 之类的东西获得请求头。可以使用 `@CookieValue(value = "JSESSIONID", required = false)` 之类的东西获得 Cookie（再也不用自己遍历辣！）

甚至能直接传 pojo！

```java
public class Book {
    private String title;
    private Integer price;
    // getter, setter, 构造函数，tostring 略
}
```

```java
@RequestMapping("/hello")
public String hello(Book book) {
    System.out.println(book);
    return "success";
}
```

```html
<form action="hello" method="post">
    <label>标题：</label>
    <input type="text" name="title"/>
    <br/>
    <label>价格：</label>
    <input type="text" name="price"/>
    <br/>
    <button type="submit">submit</button>
</form>
```

（SpringMVC 真强） 

甚至可以写级联属性。直接把 name 写成 inner.attr 就可以了。

还可以写原生 api，HttSession HttpServletRequest 之类的。

解决乱码问题，只要使用 CharacterEncodingFilter 就好了。注意这个 filter **一定要写在所有 filter 的前头**：

```xml
<filter>
  <filter-name>CharacterEncodingFilter</filter-name>
  <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
  <init-param><!-- 参数这么写的原因直接看源码就知道了，很简单的 -->
    <param-name>encoding</param-name>
    <param-value>UTF-8</param-value>
  </init-param>
  <init-param>
    <param-name>forceEncoding</param-name>
    <param-value>true</param-value>
  </init-param>
</filter>
```

## 把数据带给页面

可以在方法传入 Map（jdk 接口）、Model（spring 接口） 或 ModelMap（spring 类）。

```java
@RequestMapping("/hello")
public String hello(Map<String, Object> map) {
    map.put("msg", "message1");
    return "success";
}

// Model 和 ModelMap 这么写：
@RequestMapping("/hello")
public String hello(Model model) {
    model.addAttribute("msg", "message2");
    return "success";
}
```

success.jsp 里头就正常写 el 表达式。这里存放的数据都在 request 域中。

其实不管是哪一个，真正的类都是 BindingAwareModelMap……

也可以使用 ModelAndView 取代返回值 String 从而实现携带数据。

```java
@RequestMapping("/hello")
public ModelAndView hello() {
    ModelAndView mav = new ModelAndView("success");
    mav.addObject("msg", "message3");
    return mav;
}
```

~~怎样往 session 域放数据？在**类**处写注解 `@SessionAttributes("msg")`，这样给 request 中的 msg 放数据的时候也会给 session 放一份。也可以在里头使用 `value = {"msg", "qwq"}` 钦点多个。使用 `types={String.class}` 可以同时钦定要放到 session 域中的数据的类型。同时满足 value 和 types 才会放进去。~~

**这么写可能会出异常，就用原生 HttpSession 就行了**……

## 全字段更新

考虑这样的场景：一个书城允许管理更改书的信息，其中书名是不能改的。这样一来，修改的表单里头就是写死一个书名，不会有一个书名的 input 框。在 SpringMVC 里头使用参数 Book book 接收，接收到的这个 book 唯独书名是 null。

如果此时用写了每一个字段的 update 更新，那直接就把书名给搞没了，完蛋了。造成这样惨重后果的原因是 book 原来就都是默认值，看着 post 上来的信息一个一个 set 的。如果能根据书的 id 获得这个 id 的书的对象，就有原来的所有信息了。然后哪个要改，就 set 哪个。这样就好了。使用 ModelAttribute。

解决思想是，这个 book 不应该是 new 出来的，而是一个准备好的对象。然后使用这个对象封装请求参数。

```java
@Controller
public class HelloController {

    @ModelAttribute//ModelAttribute 写在方法上，比 hello 更先执行。
    public void qwqModelAttribute(Map<String, Object> map) {
        Book book = new Book("title", 12);
        map.put("book", book);//放进去，以便 hello 方法能用。
        System.out.println("model attribute");
    }

    @RequestMapping("/hello")
    public String hello(@ModelAttribute("book") Book book) {
        System.out.println(book);
        return "success";
    }
}
```

顺带一提，这里的 map 也是 BindingAwareModelMap，页面中都能取得这个 request 域中的对象。

ModelAttribute 方法会在该类任何方法之前执行！

## 请求转发和重定向

`return "redirect:/hello.jsp";` 是请求转发到 hello.jsp，`return "redirect:/hello.jsp";` 是重定向到 hello.jsp。不加斜线就是相对路径。顺带一提，原生 Servlet 中 sendRedirect 的时候要有项目名，这里不用。还有这里不用拼串。

## form 自定义标签

```html
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!-- SpringMVC 认为表单中的每一项都是要回显的，要求必须有一个对象（command）有这些属性（path 们）
    可以钦定 modelAttribute 成别的，例如底下的 employee。
    如果你不想写一个 Employee 来扔到 employee 里头，就 new 一个空的呗（）
-->
<form:form action="/emp" method="post" modelAttribute="employee">
    <!-- path 就是原来的 name，还可以自动回显隐含模型中某个对象对应的属性的值 -->
    lastName: <form:input path="lastName"/><br/>
    email: <form:input path="email"/><br/>
    gender: 男<form:radiobutton path="gender" value="1"/>，女<form:radiobutton path="gender" value="0"/><br/>
    <!-- items 会自动遍历，每一个元素是一个 department 对象。
        itemLabel 指定哪个属性是作为 option 标签体的值。
        itemValue 指定哪个属性是提交的值。
    -->
    dept: <form:select path="department.id" items="${depts}" itemLabel="departmentName" itemValue="id"/><br/>
    <button type="submit">submit</button>
</form:form> 
```

顺带提一下，如果想访问静态资源，在 applicationContext.xml 里头加上：

```xml
<mvc:default-servlet-handler/><!-- SpringMVC 处理不了的都交给 tomcat -->
<mvc:annotation-driven/>
```

都不加的时候，动态资源能访问，静态资源不能；只加第一个，静态资源能了，动态不行了；都加上才动静态都可以。

## 数据转换

传了一个字符串，却想获得一个对象，那就自己写转换器。

```java
package net.yxchen.component;

import net.yxchen.dao.DepartmentDao;
import net.yxchen.entities.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.convert.converter.Converter;

public class StringToEmployeeConverter implements Converter<String, Employee> {
    @Autowired
    DepartmentDao departmentDao;

    @Override
    public Employee convert(String s) { // 编写自定义的转换规则
        Employee employee = new Employee();
        // 具体转换方式略
        return employee;
    }
}
```

添加进转换 service：

```xml
<mvc:annotation-driven conversion-service="conversionService"/>
<bean id="conversionService" class="org.springframework.format.support.FormattingConversionServiceFactoryBean">
<!-- 这个相比 org.springframework.context.support.ConversionServiceFactoryBean 有格式化功能 -->
    <property name="converters">
        <set>
            <bean class="net.yxchen.component.StringToEmployeeConverter"/>
        </set>
    </property>
</bean>
```

使用的时候跟取出来一个字符串一样：

```java
@RequestMapping("/simpleAdd")
public String simpleAdd(@RequestParam("empinfo") Employee employee) {
    employeeDao.save(employee);
    return "redirect:/emps";
}
```

顺带一提，一个 Date 的属性，可以使用 @DateTimeFormat 注解钦点格式。

## 数据校验

用 jsr303 规范来实现数据校验。

使用 hibernate validator。

```xml
<dependency>
    <groupId>org.hibernate.validator</groupId>
    <artifactId>hibernate-validator</artifactId>
    <version>6.1.5.Final</version>
</dependency>
```

校验非常方便，首先在要校验的字段加上需要的注解

```java
@NotEmpty
@Length(min = 4, max = 18, message = "用户名长度在4-18个字符之间")
private String lastName;

@Email
private String email;
//甚至还能用 @Future 指定 Date 要是未来的 Date
```

在要校验的方法添加 @Valid 和 BindResult

```java
@RequestMapping(value = "/emp", method = RequestMethod.POST)
public String addEmp(@Valid Employee employee, BindingResult result) {// result 紧跟要校验的东西
    if (result.hasErrors()) {
        System.out.println("校验失败");
        return "add";
    }
    employeeDao.save(employee);
    return "redirect:/emps";
}
```

这样就好啦。你甚至可以方便地显示错误信息：

```html
lastName: <form:input path="lastName"/><form:errors path="lastName"/><br/>
email: <form:input path="email"/><form:errors path="email"/><br/>
```

（这也太方便了……）

如果要原生的呢？result 有个 getFieldErrors 得到的 list 一个一个遍历过去丢进一个 map 传过去也很方便。

## ajax

原来的 java web 还要引入 gson 转成字符串再写回去，现在 springmvc 引入 jackson 就非常方便了：

```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-core</artifactId>
    <version>2.11.1</version>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.11.1</version>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-annotations</artifactId>
    <version>2.11.1</version>
</dependency>
```

```java
@ResponseBody
@RequestMapping("ajaxEmployee")
public Collection<Employee> ajaxEmployee() {
    Collection<Employee> all = employeeDao.getAll();
    return all;
}
```

哪个是 ajax 方法，就加上一个 responsebody 就好了，对象会自动转换为 json 传回去。这就是将返回的数据放在响应体里头。

有哪个属性不想传，用 @JsonIgnore 注解。指定日期格式也有相应的注解。

使用 `@RequestBody String reqb` 可以获得表单 post 上来的东西，样式就是 `username=poorpool&password=123456` 这种。

如果 post 的时候是用的 ajax post 过来一个 json，也可以当成对象获取。ajax 差不多这么写：

```javascript
var emp = {
    lastName: "张三",
    email: "poorpool@yxchen.net",
    gender: 1
};
var empStr = JSON.stringify(emp);
$.ajax({
    url: "/reqbody",
    type: "POST",
    data: empStr,
    success: function (data) {
        //...
    },
    dataType: "json",
    contentType: "application/json"
});
```
## 上传下载文件

可以用 ResponseEntity 返回数据和定制响应头。用 HttpEntity 获得请求头。这个自己百度吧。

例如下载文件：

```java
@RequestMapping("/download")
public ResponseEntity<byte[]> download(HttpServletRequest request) throws Exception {
    ServletContext context = request.getServletContext();
    String realPath = context.getRealPath("/script/jquery-3.4.1.min.js");
    FileInputStream fileInputStream = new FileInputStream(realPath);
    byte[] bytes = new byte[fileInputStream.available()];
    fileInputStream.read(bytes);
    fileInputStream.close();
    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.set("Content-Disposition", "attachment; filename=jquery-3.4.1.min.js");
    return new ResponseEntity<byte[]>(bytes, httpHeaders, HttpStatus.OK);
}
```

上传文件还是 commons 的那一套，但是更方便。

设置一些属性：

```xml
<bean id="multipartResolver" class="org.springframework.web.multipart.commons.CommonsMultipartResolver">
    <property name="maxUploadSize" value="#{1024*1024*20}"/>
    <property name="defaultEncoding" value="utf-8"/>
</bean>
```

```java
@Controller
public class MainController {
    @RequestMapping("/uploadOne")
    public String uploadOne(@RequestParam(value = "username", required = false) String username,
                            @RequestParam("avatar") MultipartFile file, Model model) {
        System.out.println("username is " + username);
        System.out.println("filename is " + file.getOriginalFilename());
        try {
            file.transferTo(new File("uploads/" + file.getOriginalFilename()));// 别问我存哪儿了，这只是一个例子。可以获得 context 然后存到 real path 底下去。
            model.addAttribute("msg", "upload succeed");
        } catch (Exception e) {
            model.addAttribute("msg", e.getMessage());
        }
        return "forward:/index.jsp";
    }
}
```

```html
<h1>${requestScope.msg}</h1>
<form action="/uploadOne" method="post" enctype="multipart/form-data">
    <input type="text" name="username"/><br/>
    <input type="file" name="avatar"/><br/>
    <button type="submit">submit</button>
</form>
```

获得文件就像获得一个 String 一样，多方便啊。