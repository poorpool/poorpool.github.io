---
title: 《计算机网络：自顶向下方法》笔记2 应用层
date: 2020-05-01 10:00:01
tags:
- 笔记
- 计算机网络
categories:
- 笔记
---
第二章

<!--more-->

## 应用层协议原理

#### 应用程序体系结构

有客户-服务器体系结构和P2P体系结构。

#### 进程通信

任何给定的一对进程之间的通信会话场景都能将一个进程标识为客户，另一个标识为服务器。发起通信的是客户，在会话开始的时候等待联系的进程是服务器。

socket是同一台主机内应用层与运输层之间的接口，也是应用程序和网络之间的API。

#### 一些对应用程序服务要求的分类

可靠数据传输、吞吐量、定时、安全性。

### TCP

SSL（安全套接字层）不是和TCP、UDP同级的，而是一种对TCP的加强。

## Web和HTTP

#### 基本信息

web页面是由对象组成的。一个html文件，jpg图形，一个视频片段都是对象。并且它们都可以通过一个URL地址寻址。一般是一个HTML基本文件和几个引用对象。

```
http://www.someSchool.edu/someDepartment/picture.gif
```

`www.someSchool.edu` 是主机名hostname，`/someDepartment/picture.gif` 是路径名path。

http是一个无状态协议，因为http服务器并不保存关于客户的任何信息。

#### 非持续连接和持续连接

每个请求/响应对是经过一个单独的tcp连接发送就是非持续连接，每个都经一个单独的tcp连接被称为持续连接。

http默认使用持续连接，但是客户和服务器也能配置成使用非持续连接。

#### 往返时间RTT

一个短分组从客户到服务器然后再返回客户所花的时间。

![RTT](/images/topdown/cpt2-1.png)

三次握手的前两部分占用了一个RTT，第三部分（确认）发出的请求和响应用去了另一个RTT。

#### 请求报文

```
GET /somedir/page.html HTTP/1.1
Host: www.someschool.edu
Connection: close
User-agent: Mozilla/5.0
Accept-language: fr
```

第一行叫请求行，包含方法、URL和HTTP版本三个字段。

后面的行叫首部行。

第三行是高速服务器不要使用持续连接。发送完请求的对象就关闭这条连接。

![请求报文](/images/topdown/cpt2-2.png)

在首部行（和回车换行）以后还有一个实体体entity body。GET方法的时候它为空，POST字段时候才使用这个。例如用户在表单字段中的输入值。

#### 响应报文

```
HTTP/1.1 200 OK
Connection: close
Date: Tue, 18 Aug 2015 15:44:04 GMT
Server: Apache/2.2.3 (CentOS)
Last-Modified: Tue, 18 Aug 2015 15:11:03 GMT
Content-Length: 6821
Content-Type: text/html
(data data data data data ...)
```

状态行：协议版本、状态码、相应状态。

date是服务器产生并发送该相应报文的日期和时间。

last-modified是对象创建或者最后修改的日期和时间（对缓存来说很重要）

![相应报文](/images/topdown/cpt2-3.png)

#### cookie

![cookie](/images/topdown/cpt2-4.png)

cookie计数有四个组件：

- 在http响应报文中一个cookie首部行
- 在http请求报文中一个cookie首部行
- 在用户端系统中保留一个cookie文件并由用户的浏览器进行管理
- 在web站点的一个后端数据库。

书上说的挺清楚的。想一想这个是不是能用来做没有登录情况下的购物网站购物车。

#### web缓存

web缓存器也叫代理服务器。工作过程大概就是浏览器先向web缓存器问问有没有某对象，缓存器有就给它发来，没有就去获得这个对象缓存下来然后发来。

#### 条件GET

缓存器发送一个条件GET，首部行有一个：

```
If-modified-since: Wed, 9 Sep 2015 09:23:24
```

意义显然。然后要是没有修改，服务器就返回一个：

```
HTTP/1.1 304 Not Modified
```

没有修改过，也不用重新传一遍对象了。

## 因特网中的电子邮件

#### 构成

![构成](/images/topdown/cpt2-5.png)

三部分：用户代理、邮件服务器和简单邮件传输协议（SMTP）。

邮件发送过程：发送方用户代理--发送方邮件服务器--接收方邮件服务器--接收方用户代理。发不成就在发送方的报文队列中保持这个邮件。

#### SMTP

![smtp](/images/topdown/cpt2-6.png)

SMTP也要建立TCP连接，使用持续连接。

邮件并不在中间的某个邮件服务器停留。

http主要是一个“拉协议”，smtp是“推协议”。smtp要求每个报文（包括体）采用7bit ASCII编码。smtp还把所有报文对象通通放在一个报文当中。

#### 邮件访问协议

主要是POP3和IMAP。

## DNS：因特网的目录服务

#### 定义

域名系统dns是：

- 一个由分层的dns服务器实现的分布式数据库
- 一个使得主机能够查询分布式数据库的应用层协议

dns协议运行在udp上，使用53号端口。

#### 过程

1. 主机上运行着dns应用的客户端
2. 浏览器抽出主机名`www.someschool.edu`，将主机名传给dns应用的客户端
3. dns客户向dns服务器发送一个包含主机名的请求
4. dns客户最终收到一个含有主机名对应的ip地址的报文
5. 浏览器接收到ip地址便可以发起一个tcp连接

#### dns一些重要服务

- 主机别名。比如说给规范主机名`dala.bongba.qwqwqwqwq.bandebeidi.com`起个主机别名叫`tank.com`，多棒多好记。
- 邮件服务器别名
- 负载分配。比如繁忙的站点`cnn.com`冗余地分配在多台服务器上，有不同的ip地址。所以一个ip地址集合对应同一个规范主机名。客户发起dns请求的时候服务器以整个ip地址集合响应，但是**在每个回答中循环这些地址次序**。而客户总是向排在前面的ip地址发起http请求。

#### dns服务器

![dnsserver](/images/topdown/cpt2-7.png)

由上到下为根dns服务器，顶级域服务器，权威dns服务器。

当然还有本地dns服务器。

![localserver](/images/topdown/cpt2-8.png)

图例是`cse.nyu.edu`想知道`gaia.cs.umass.edu`的ip地址的过程。

#### dns缓存

在一个请求链中，某个dns服务器接收一个dns回答时它能将映射缓存在本地服务器中。然后下一次对相同主机名的查询到达该dns服务器时就能提供ip地址了。不过dns服务器将在一段时间丢弃缓存的信息（两天）。

#### dns资源记录

形如：

```
(Name, Value, Type, TTL)
```

ttl是记录的生存时间。

- Type=A，则name是主机名，value是对应的ip地址
- Type=NS，则name是个域（`foo.com`），value是个知道如何获得该域中主机ip地址的权威dns服务器主机名。例如`dns.foo.com`
- Type=CNAME，value是别名为name的主机对应的规范主机名
- Type=MX，value是别名为name的邮件服务器的规范主机名

如果一台dns服务器是用于某特定主机名的权威dns服务器，则其含有用于该主机名的A记录。

如果不是，则将包含一条NS记录，对应包含主机名的域；还包含一条A记录，提供NS记录中value字段dns服务器的ip地址。

例如一台服务器不是`gaia.cs.umass.edu`的权威dns服务器，则它含`(umass.edu, dns.umass.edu, NS)`和`(dns.umass.edu, 128.119.40.111, A)`之类的。

## CDN

cdn是内容分发网。

两种服务器安置原则：深入和邀请做客。邀请做客就是在IXP之类的关键位置建造大集群来邀请ISP做客。

![cdn](/images/topdown/cpt2-9.png)

这是netcinema雇佣kingcdn的例子。第三步中netcinema的权威dns服务器并不是返回ip地址，而是向ldns返回一个kingcdn域的主机名，例如`a1105.kingcdn.com`。

## 套接字编程：生成网络应用

#### udp和tcp

tcp中server往往是一个欢迎套接字listen，然后accept出一个连接套接字。