---
title: Java Web 学习札记4
date: 2020-06-09 18:21:57
tags:
- Java
- Web
categories:
- Web
---
建议改名游记.jpg

课程[来源](https://www.bilibili.com/video/BV1Y7411K7zz)。

<!--more-->

# Filter

filter是个接口。

可以做权限检查、日记操作、事务管理……比如某个文件夹下的东西只有登录了才可以访问之类的。

```java
public class AdminFilter implements Filter {
    @Override//拦截请求，过滤响应
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpSession session = ((HttpServletRequest) servletRequest).getSession();
        Object user = session.getAttribute("user");//有就是登录了
        if (user==null) {
            servletRequest.getRequestDispatcher("/login.jsp").forward(servletRequest, servletResponse);
        } else {
            filterChain.doFilter(servletRequest, servletResponse);
        }
    }
}
```

然后web.xml里头照猫画虎：
```xml
<filter>
    <filter-name>AdminFilter</filter-name>
    <filter-class>com.atguigu.fliter.AdminFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>AdminFilter</filter-name>
    <url-pattern>/admin/*</url-pattern>
</filter-mapping>
```

除了目录匹配，精准匹配，还有后缀名匹配。用法显然。

生命周期也是启动的时候init，每次doFilter，结束的时候destory。

就好像Servlet有ServletConfig，Filter也有FilterConfig。可以类比第二篇札记内容。

![images](/images/javaknows/6.png)

重点是右下角蓝字。

过滤器并不关心请求的资源是否存在。

# JSON

json对象和字符串互转：
```html
<script type="text/javascript">
    var jsonObj = {
        "key1": 12,
        "key2": "abc"
    };
    var jsonStr = JSON.stringify(jsonObj);
    alert(jsonStr);
    var jsonObj2 = JSON.parse(jsonStr);
    alert(jsonObj2.key1);
    alert(jsonObj2.key2);
</script>
```

值可以是对象，数组，map……之类的。

和JavaBean互转：
```java
public class JsonTest {
    public static void main(String[] args) {
        Person person = new Person(1, "poorpool");//是个JavaBean
        Gson gson = new Gson();
        String jsonStr = gson.toJson(person);
        System.out.println(jsonStr);
        Person person1 = gson.fromJson(jsonStr, Person.class);
        System.out.println(person1);
    }
}
```

要用到Gson.jar。

也可以实现list和json互转，map和json互转。不写了。

# AJAX
用例：
```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="pragma" content="no-cache" />
		<meta http-equiv="cache-control" content="no-cache" />
		<meta http-equiv="Expires" content="0" />
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<title>Insert title here</title>
		<script type="text/javascript">
			function ajaxRequest() {
// 				1、我们首先要创建XMLHttpRequest 
				var xmlHttpRequest = new XMLHttpRequest();
// 				2、调用open方法设置请求参数
				xmlHttpRequest.open("GET", "http://localhost:8080/13_cookie/ajaxServlet?action=javascriptAjax", true);
// 				3、在send方法前绑定onreadystatechange事件，处理请求完成后的操作
				xmlHttpRequest.onreadystatechange = function () {
					if (xmlHttpRequest.readyState == 4 && xmlHttpRequest.status == 200) {
						//4-请求已完成，响应已就绪
						var jsonObj = JSON.parse(xmlHttpRequest.responseText);
						document.getElementById("div01").innerHTML = xmlHttpRequest.responseText;
					}
				};
// 				4、调用send方法发送请求
				xmlHttpRequest.send();
			}
		</script>
	</head>
	<body>	
		<button onclick="ajaxRequest()">ajax request</button>
		<div id="div01">
			d
		</div>
	</body>
</html>
```

```java
public class AjaxServlet extends BaseServlet {
    protected void javascriptAjax(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("收到ajax请求");
        Person person = new Person(1, "poorpool");
        Gson gson = new Gson();
        String jsonStr = gson.toJson(person);
        resp.getWriter().write(jsonStr);
    }
}
```

使用jquery：
```html
<script type="text/javascript">
    function ajaxRequest() {
        $.ajax({
            url: "http://localhost:8080/13_cookie/ajaxServlet",
            data: {action: "javascriptAjax"},//或者就是跟get方法"action=xx"一样的
            type: "GET",
            success: function (msg) {//回调函数
                alert("sir yes sir");
                $("#div01").html(msg.id + "," + msg.name);
            },
            dataType: "json"//json的话msg是json对象，text的话是字符串
        });
    }
</script>
```

非常方便。

有更进一步的封装，`$.get(url, data, callback, dataType)`和`$.post(...)`，顾名思义。参数变成了url, data, callback和dataType。

更进一步是`$.getJSON`，显然是get一个json。参数变成了url, data和callback。

如果你想用ajax做提交表单之类的功能，可以考虑使用`$("#form01").serialize()`之类的东西。序列化可以将表单项变成`name=value&name=value`。

tomcat 只会将 post 的请求的数据封装到 map 里头，put 都不会。可以自己配了 httpmethodfilter 以后加上 `_method`，也可以再配一个 httpputformcontentfilter。
