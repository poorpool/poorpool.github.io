---
title: go语言中方法的接收者
date: 2020-03-26 20:34:25
tags:
- go
categories:
- 编程语言
---
玄之又玄

<!--more-->

最近在看go语言实战，这书太猛了，看得我整个人都倒过来了。

先看一段能正常运行的代码。没有什么特别的，不说了。

```go
package main

import (
	"fmt"
)

type user struct {
	name string
}

func (u user) notify1() {
	fmt.Println(u.name)
}

func (u *user) notify2() {
	fmt.Println(u.name)
}

func baozhuang1(u user) {
	u.notify1()
	u.notify2()
}

func baozhuang2(u *user) {
	u.notify1()
	u.notify2()
}

func main() {
	xiaoming := user{"xiaoming"}
	fmt.Println("TEST 1")
	xiaoming.notify1()
	xiaoming.notify2()
	fmt.Println("TEST 2")
	baozhuang1(xiaoming)
	fmt.Println("TEST 3")
	baozhuang2(&xiaoming)
}
```

然后是第二段，也能运行
```go
package main

import (
	"fmt"
)

type notifier interface {
	notify()
}

type user struct {
	name string
}

func (u user) notify() {
	fmt.Println(u.name)
}

func baozhuang(u notifier) {
	u.notify()
}

func main() {
	xiaoming := user{"xiaoming"}
	baozhuang(xiaoming)
}
```
接着是第三段
```go
package main

import (
	"fmt"
)

type notifier interface {
	notify()
}

type user struct {
	name string
}

func (u *user) notify() {
	fmt.Println(u.name)
}

func baozhuang(u notifier) {
	u.notify()
}

func main() {
	xiaoming := user{"xiaoming"}
	baozhuang(xiaoming)
}
```
慢着。前两段是大扒鸭，第三段变成了奥利给。run它会出错
```bash
$ go run test3.go 
# command-line-arguments
./test3.go:25:11: cannot use xiaoming (type user) as type notifier in argument to baozhuang:
	user does not implement notifier (notify method has pointer receiver)
```

这个涉及到一个叫方法集的玩意。讲一讲它的规则：
```
--------------------------
值　　　　　接收者
--------------------------
T　　　　　 (t T)
*T　　　　　(t T) and (t *T)
--------------------------
```
比较好理解的是下面这个
```
--------------------------
接收者　　　　　值
--------------------------
(t T)        T and *T
(t *T)       *T
--------------------------
```
也就是说值类型的接收者可以用那个类型的值和指针实现对应的接口，指针类型的接收者只能用那个类型的指针实现对应的接口。

这个也比较好理解。假设你是go run工具人，要搞一个值类型的接收者，那么传进来值直接用，传进来指针的话*操作也能用。

但是获取一个值的指针并不是总能成功的。比如要搞一个指针类型的接收者，那么传进来指针直接用，传进来值呢？有时候编译器并不能自动获取一个值的地址。再想一个例子，传个24进去，难不成编译器还能晓得24的地址咯……