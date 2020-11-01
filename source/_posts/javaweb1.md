---
title: Java Web 学习札记1
date: 2020-05-28 21:09:47
tags:
- Java
- Web
categories:
- Web
---
建议改名游记.jpg

课程[来源](https://www.bilibili.com/video/BV1Y7411K7zz)。

<!--more-->

# HTML、CSS和JavaScript

## iframe
就相当于页面里的一个页面，套 娃。
```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>poorpool</title>
</head>
<body>
<iframe src="test.html" width="700" height="700" name="abc"></iframe>
<a href="test2.html" target="abc">link</a>
</body>
```
点击link，iframe里头的东西就会变成test2.html。这是伟大的target的功劳。（顺便一提，target里头_blank是新标签页，_self是本页面切换）。

## JS的可变参数
其实是隐形参数，用arguments数组就可以啦。（顺带一提，JS没有重载。如果妄图这么写，后头的函数会覆盖前头的）。
```javascript
function fun() {
    var result = 0;
    for(var i = 0; i < arguments.length; i++)
        if(typeof(arguments[i]) == "number")
            result += arguments[i];
    return result;
}
alert(fun(1, 2, "a", 34));
```

## JS的对象
弱类型的秘宝。
```javascript
var obj1 = new Object();
obj1.name = "poorpool";
obj1.age = 18;
obj1.fun = function() {
    alert("名字" + this.name + "，年龄" + this.age);
}
obj1.fun();

var obj2 = {
    name: "poorpool",
    age: 19,
    fun: function() {
        alert("名字" + this.name + "，年龄" + this.age);
    }
}
obj2.fun();
```

## 事件
onload（页面加载完触发）
```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>poorpool</title>
    <script>
        function onloadFun() {
            alert('静态注册onload');
        }
        window.onload = function() {
            alert('动态注册onload');
        }
    </script>
</head>
<!--
静态注册用法
<body onload="onloadFun();">
-->
<body>
hello
</body>
```

onclick点击按钮，onblur失去焦点，onchange发生改变，onsubmit表单提交的时候。只写前三个的动态注册。
```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>poorpool</title>
    <script>
        window.onload = function () {
            var obj = document.getElementById("btn1");
            obj.onclick = function () {
                alert('click!');
            }
            var obj2 = document.getElementById("qwq");
            obj2.onblur = function () {
                alert('失去焦点');
            }
            var obj3 = document.getElementById("orz");
            obj3.onchange = function () {
                alert('变了啊啊啊啊啊啊啊啊啊啊啊啊');
            }
        }
    </script>
</head>
<body>
<!--onclick-->
<button id="btn1">click me</button>

<!--onblur-->
输入：<input type="text" id="qwq"/>
输入2：<input type="text"/>

<!--onchange-->
<select id="orz">
    <option>---国家---</option>
    <option>中国</option>
    <option>日本</option>
    <option>美国</option>
</select>
</body>
```

## DOM
Document Object Model 文档对象模型，把标签文本啥的统统作为对象来管理。

优先getElementById，然后getElementsByName，然后getElementsByTagName。也可以document.createElement(tagName)创建标签对象。要加载完才执行。

相当于这种结构
```java
class Dom{
    private String id;
    // id 属性
    private String tagName; //表示标签名
    private Dom parentNode; //父亲
    private List<Dom> children; // 孩子结点
    private String innerHTML; // 起始标签和结束标签中间的内容
}
```

看一个用户名校验的例子
```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>poorpool</title>
    <script>
        function checkFun() {
            var obj = document.getElementById("username");
            var username = obj.value;
            var pattern = /\w{5,12}/

            var spanObj = document.getElementById("usernameSpan");
            if(pattern.test(username)) {
                spanObj.innerHTML = "用户名合法";
            }
            else {
                spanObj.innerHTML = "用户名不合法";
            }
        }
    </script>
</head>
<body>
用户名：<input type="text" id="username" value="poorpool"/>
<span id="usernameSpan" style="color: red;"></span>
<button onclick="checkFun();">校验</button>
</body>
```
多选
```html
<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>poorpool</title>
    <script>
        var objs = document.getElementsByName("hobby");
        function selectAll() {
            for(var i=0; i<objs.length; i++)
                objs[i].checked = true;
        }
        function selectNo() {
            for(var i=0; i<objs.length; i++)
                objs[i].checked = false;
        }
        function selectReverse() {
            for(var i=0; i<objs.length; i++)
                objs[i].checked = !objs[i].checked;
        }
    </script>
</head>
<body>
<!--懒得写value了-->
<input type="checkbox" name="hobby" checked="true"/> C++
<input type="checkbox" name="hobby"/> Java
<input type="checkbox" name="hobby"/> GO
<button onclick="selectAll();">全选</button>
<button onclick="selectNo();">全不选</button>
<button onclick="selectReverse();">反选</button>
</body>
```
```javascript
window.onload = function () {
    var divObj = document.createElement("div");
    var li1 = document.createTextNode("poorpool");
    divObj.appendChild(li1);
    document.body.appendChild(divObj);
}
```

## jQuery
jQuery里有个奇妙函数`$()`。

1. 传入参数为函数时：表示页面加载完成之后。相当于`window.onload = function(){}`
2. 传入参数为HTML字符串时：创建HTML标签对象。
3. 传入参数为选择器字符串：可以是`$("#someID)`，`$("someTagName)`和`$(".class someClassName")`。
4. 传入参数为DOM对象时:会把这个DOM对象转换为 jQuery 对象

jQuery对象是DOM对象数组加上一些操作方法。DOM对象转jQuery对象用`$(DOM对象)`，jQuery对象转DOM对象用`$obj[下标]`。

### 选择器

`#idName`，`.className`，`typeName`，`name1, #id2, .class3`……之类的。`*`所有。

`$("span, #two")`就是选中所有span以及所有id是two的元素。

```
ancestor descendant 所有后代（包括孙子）
parent > child 直系子女
prev + next 紧跟prev的next
prev ~ siblings prev之后所有sibling
```

jQuery 还有一些杂七杂八的过滤器，比如`:first`，`:last`，`:not(选择器)`，甚至可以`$("div:not(:animated):last")`选择没有执行动画的最后一格div。

还有一些内容过滤器、属性过滤器`[attribute]`，`[attribute=value]`，`[attribute!=value]`（不含该属性或者含有属性但不为value的都被选中）。

还有一些表单过滤器，匹配文本框密码框选中的东西之类的……太多了自己翻文档吧。

还有一些元素筛选方法。`$("p").eq(1)`和`$("p:eq(1)")`就是一样的。太多了不写了。

### jQuery属性

```javascript
$(function () {
    alert($("div").html());
    $("div").html("<h1>orztql</h1>");
});
```
html()是获得里头的html代码（dom的innerHTML），如果带上参数，就成了设置。同样的还有text()（dom的innerText）以及表单中的val()。

val有诸多妙处：
```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>poorpool</title>
        <script src="Demo/script/jquery-1.7.2.js"></script>
        <script>
            $(function () {
                $(":radio").val(["radio2"]);
                $(":checkbox").val(["checkbox1", "checkbox3"]);
                $("#multiple").val(["mul3, mul4"]);
                $("#single").val(["sin2"]);
            });
        </script>
    </head>
    <body>
        单选:
        <input name="radio" type="radio" value="radio1" />radio1
        <input name="radio" type="radio" value="radio2" />radio2
        <br/>
        多选:
        <input name="checkbox" type="checkbox" value="checkbox1" />checkbox1
        <input name="checkbox" type="checkbox" value="checkbox2" />checkbox2
        <input name="checkbox" type="checkbox" value="checkbox3" />checkbox3
        <br/>
        下拉多选 :
        <select id="multiple" multiple="multiple" size="4">
            <option value="mul1">mul1</option>
            <option value="mul2">mul2</option>
            <option value="mul3">mul3</option>
            <option value="mul4">mul4</option>
        </select>
        <br/>
        下拉单选 :
        <select id="single">
            <option value="sin1">sin1</option>
            <option value="sin2">sin2</option>
            <option value="sin3">sin3</option>
        </select>
    </body>
</html>
```

attr()一个参数是获取属性，两个参数是设置。例如`attr("name")`和`attr("name", "checkbox")`。

但是attr有一个问题，
```html
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>poorpool</title>
        <script src="Demo/script/jquery-1.7.2.js"></script>
        <script>
            $(function () {
                alert($(":checkbox").attr("checked"));
            });
        </script>
    </head>
    <body>
        <input type="checkbox" name="checkbox"/>C++
        <input type="checkbox" name="checkbox"/>Java
    </body>
</html>
```
alert出来居然是undefined，这到底是未定义还是false？这种情况用prop()。prop只推荐操作 checked、readOnly、selected、disabled 等等。

使用jQuery的全选反选不选：
```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="../../script/jquery-1.7.2.js"></script>
<script type="text/javascript">
	
	$(function(){
		var allBox = $("#checkedAllBox");
		var items = $(":checkbox[name='items']");

		function isSelectAll() {
			return items.length == $(":checkbox[name='items']:checked").length;
		}

		$("#checkedAllBtn").click(function () {
			allBox.prop("checked", true);
			items.prop("checked", true);
		});

		$("#checkedNoBtn").click(function () {
			allBox.prop("checked", false);
			items.prop("checked", false);
		});

		$("#checkedRevBtn").click(function () {
			items.each(function () {
				this.checked = !this.checked;
			});
			allBox.prop("checked", isSelectAll());
		});

		$("#sendBtn").click(function () {
			$(":checkbox[name='items']:checked").each(function () {
				alert(this.value);
			});
		});

		items.click(function () {
			allBox.prop("checked", isSelectAll());
		});

		allBox.click(function () {
			items.prop("checked", this.checked);
		});
	});
	
</script>
</head>
<body>

	<form method="post" action="">
	
		你爱好的运动是？<input type="checkbox" id="checkedAllBox" />全选/全不选 
		
		<br />
		<input type="checkbox" name="items" value="足球" />足球
		<input type="checkbox" name="items" value="篮球" />篮球
		<input type="checkbox" name="items" value="羽毛球" />羽毛球
		<input type="checkbox" name="items" value="乒乓球" />乒乓球
		<br />
		<input type="button" id="checkedAllBtn" value="全　选" />
		<input type="button" id="checkedNoBtn" value="全不选" />
		<input type="button" id="checkedRevBtn" value="反　选" />
		<input type="button" id="sendBtn" value="提　交" />
	</form>

</body>
</html>
```

### 增删改查
a.appendTo(b) 把 a 插入到 b 子元素末尾，成为最后一个子元素。
a.prependTo(b) 把 a 插到 b 所有子元素前面，成为第一个子元素。
a.insertAfter(b) 得到 ba。
a.insertBefore(b) 得到 ab。
a.replaceWith(b) 用 b 替换掉 a。
a.replaceAll(b) 用 a 替换掉所有 b。
a.remove() 删除 a 标签。
a.empty() 清空 a 标签里的内容。

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
	<style type="text/css">
		select {
			width: 100px;
			height: 140px;
		}
		
		div {
			width: 130px;
			float: left;
			text-align: center;
		}
	</style>
	<script type="text/javascript" src="script/jquery-1.7.2.js"></script>
	<script type="text/javascript">
		$(function () {
			$("button:eq(0)").click(function () {
				$("select[name=sel01] :selected").each(function () {
					$(this).appendTo($("select[name=sel02]"));
				});
			});
			$("button:eq(1)").click(function () {
				$("select[name=sel01] option").appendTo($("select[name=sel02]"));
			});
			$("button:eq(2)").click(function () {
				$("select[name=sel02] :selected").each(function () {
					$(this).appendTo($("select[name=sel01]"));
				});
			});
			$("button:eq(3)").click(function () {
				$("select[name=sel02] option").appendTo($("select[name=sel01]"));
			});
		});
	</script>
</head>
<body>

	<div id="left">
		<select multiple="multiple" name="sel01">
			<option value="opt01">选项1</option>
			<option value="opt02">选项2</option>
			<option value="opt03">选项3</option>
			<option value="opt04">选项4</option>
			<option value="opt05">选项5</option>
			<option value="opt06">选项6</option>
			<option value="opt07">选项7</option>
			<option value="opt08">选项8</option>
		</select>
		
		<button>选中添加到右边</button>
		<button>全部添加到右边</button>
	</div>
	<div id="rigth">
		<select multiple="multiple" name="sel02">
		</select>
		<button>选中删除到左边</button>
		<button>全部删除到左边</button>
	</div>

</body>
</html>
```

### 实例：表单添加和删除
```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Untitled Document</title>
<link rel="stylesheet" type="text/css" href="styleB/css.css" />
<script type="text/javascript" src="../../script/jquery-1.7.2.js"></script>
<script type="text/javascript">
	$(function () {
		var delFun = function () {
			// 在事件响应的function函数中，有一个this对象。这个this对象是当前正在响应事件的dom对象。
			// 也就是<a>。
			var $delObj = $(this).parent().parent();
			if (confirm("确定要删除" + $delObj.find("td:first").text() + "吗？")) {
				$delObj.remove();
			}
			return false;
		};

		$("#addEmpButton").click(function () {
			var name = $("#empName").val();
			var email = $("#email").val();
			var salary = $("#salary").val();
			var $trObj = $("<tr>" +
					"<td>" + name +"</td>" +
					"<td>" + email +"</td>" +
					"<td>" + salary +"</td>" +
					"<td><a href=\"deleteEmp\">Delete</a></td>" +
					"</tr>");
			$trObj.appendTo($("#employeeTable"));
			$trObj.find("a").click(delFun);
		});

		$("a").click(delFun);
	});
</script>
</head>
<body>

	<table id="employeeTable">
		<tr>
			<th>Name</th>
			<th>Email</th>
			<th>Salary</th>
			<th>&nbsp;</th>
		</tr>
		<tr>
			<td>Tom</td>
			<td>tom@tom.com</td>
			<td>5000</td>
			<td><a href="deleteEmp">Delete</a></td>
		</tr>
		<tr>
			<td>Jerry</td>
			<td>jerry@sohu.com</td>
			<td>8000</td>
			<td><a href="deleteEmp">Delete</a></td>
		</tr>
		<tr>
			<td>Bob</td>
			<td>bob@tom.com</td>
			<td>10000</td>
			<td><a href="deleteEmp">Delete</a></td>
		</tr>
	</table>

	<div id="formDiv">
	
		<h4>添加新员工</h4>

		<table>
			<tr>
				<td class="word">name: </td>
				<td class="inp">
					<input type="text" name="empName" id="empName" />
				</td>
			</tr>
			<tr>
				<td class="word">email: </td>
				<td class="inp">
					<input type="text" name="email" id="email" />
				</td>
			</tr>
			<tr>
				<td class="word">salary: </td>
				<td class="inp">
					<input type="text" name="salary" id="salary" />
				</td>
			</tr>
			<tr>
				<td colspan="2" align="center">
					<button id="addEmpButton" value="abc">
						Submit
					</button>
				</td>
			</tr>
		</table>

	</div>

</body>
</html>
```

### 操作CSS样式
addClass("someClass1 someClass2") 添加样式。
removeClass()删除样式（有参数就删参数，没参数就全删掉）。
toggleClass("someClass") 有就删除，没有就加。
offset() 获取和设置元素的坐标。不加参数返回一个`{top: xx; left: yy;}`，加上这样的参数就是设置。

### 动画
show()，hide()，toggle()是显示隐藏切换（像是连续调整div长宽），fadeIn()，fadeOut()，fadeTo()，fadeToggle()是淡入单出淡入到切换。都能接收两个可选参数，第一个时长（毫秒），第二个回调函数。fadeTo接收0-1之间的半透明值。fadeToggle也可以有"slow"、"linear"。之类的东西。自己翻文档吧。

### 和原生js区分

jQuery的页面加载完成是创建好dom对象之后。原生js的页面加载完成是dom对象创建好和显示的内容也加载好了才执行。

jQuery多注册几个页面加载完成的都执行，window.onload就最后的执行。

### 其他事件

click带参数就是绑定click事件，不带就是触发。还有鼠标移入移出之类的。

bind可以绑定事件，例如bind("mouseover mouseout", someFunction)之类的，unbind解绑。one是绑定但只执行一次。

live也绑定，它可以用来绑定选择器匹配的所有元素的事件。哪怕这个元素是后面动态创建出来的也有效。

### 事件

父子元素同时监听同一个事件。当触发子元素的事件的时候,同一个事件也被传递到了父元素的事件里去响应。

在子元素事件函数体内,return false; 可以阻止事件的冒泡传递。

至于function获得事件，加一个event参数就行了。下面是“鼠标放到小图上的时候就会出现跟随着小图的大图”的实例。

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<style type="text/css">
	body {
		text-align: center;
	}
	#small {
		margin-top: 150px;
	}
	#showBig {
		position: absolute;
		display: none;
	}
</style>
<script type="text/javascript" src="script/jquery-1.7.2.js"></script>
<script type="text/javascript">
	$(function(){
		$("#small").bind("mouseover mouseout mousemove", function (event) {
			var $qwq = $("#showBig");
			if (event.type=="mouseover") {
				$qwq.show();
			}
			else if (event.type=="mousemove") {
				$qwq.offset({
					top: event.pageY + 10,
					left: event.pageX + 10,
				});
			}
			else {
				$qwq.hide();
			}
		});
	});
</script>
</head>
<body>

	<img id="small" src="img/small.jpg" />
	
	<div id="showBig">
		<img src="img/big.jpg">
	</div>

</body>
</html>
```





