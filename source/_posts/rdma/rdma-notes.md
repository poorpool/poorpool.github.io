---
title: RDMA 学习笔记
date: 2022-10-10 15:50:06
tags:
- RDMA
- 笔记
- PDSL
categories:
- 笔记
typora-root-url: ../..
---



[知乎专题文章](https://www.zhihu.com/column/rdmatechnology)

[tutorial](https://github.com/jcxue/RDMA-Tutorial)

很多都是我复制的

<!--more-->

## RDMA概述

回忆一下组原有个dma，设备把数据直接发送到内存，不需要cpu参与

rdma：remote direct memory access

从一个主机的内存直接访问另一个主机的内存

将rdma协议固化到网卡上

优势：

- 零拷贝
- 内核旁路
- 不需要cpu干预
- 消息基于事务（数据不是流而是离散的）
- 支持分散聚合条目

### 三种硬件实现

- InfiniBand/IB，全新协议，全新交换机网卡
- RDMA over Ethernet/ RoCE，普通以太网交换机，新网卡(pdsl用这一套)
- iWARP/RDMA over TCP

![options](/images/rdma/1-options.png)

### 基本术语

Fabric: rdma lan

CA: channel adapter

- HCA, host ca, 支持verbs接口
- TCA, target ca, weak CA

verbs: 一组标准动作

### 内存注册

rdma对内存有特殊要求

应用程序不能修改数据所在内存

操作系统不能对内存进行page out操作

rdma要求物理地址连续

内存注册是RDMA中内存保护的方法。注册memory region后就有自己的属性：

- context : RDMA操作上下文
- addr : MR被注册的Buffer地址
- length : MR被注册的Buffer长度
- lkey：MR被注册的本地key
- rkey：MR被注册的远程key

### 队列和操作

RDMA一共支持三种队列，发送队列(SQ)和接收队列(RQ)，完成队列(CQ)。其中，SQ和RQ通常成对创建，被称为Queue Pairs(QP)。

![workflow](/images/rdma/2-workflow.png)

![image-20221010163943310](/../../../../.config/Typora/typora-user-images/image-20221010163943310.png)https://zhuanlan.zhihu.com/p/55142547

## rdma-tutorial 阅读

https://github.com/jcxue/RDMA-Tutorial/wiki

先看example1，主要就是看代码，不需要写东西。试着编译一下

在实验室s33服务器checkout到对应提交，然后make，提示两个错误

- atoi，要用stdlib.h
- 找不到ibv_xxx函数，链接命令要 -libverbs

在试图跑example1的时候，会出现create_qp参数错误的报错。不好debug。翻一下pr issue，https://github.com/jcxue/RDMA-Tutorial/pull/10 这个pr里面fix了一些RoCE的issue，我记得我们实验室刚好是roce,,,

把他clone下来，使用`-w -Wno-address-of-packed-membe`屏蔽掉一些报错，就可以运行了。

里面有一些参数，dev_index是`ibv_devinfo`命令列出的设备索引，服务器有两台，server/client我填了0/1

gid_index 是 `ibv_devinfo -v -d mlx5_XXX`显示出的索引，我看到了4个，所以都填了3，这个随缘吧

测试命令：

```bash
/rdma-tutorial 64 8 7283 0 3 &
/rdma-tutorial localhost 64 8 7283 1 3
```

上面的是服务端：message大小64，8个消息并发，监听7283端口，dev_index=0，gid_index=3，&为后台运行

下面的是客户端。测试是把他们放在一台服务器跑了，实际可能可以放好几台分开跑吧

如果看不到输出，像是卡在那里，两个log都不动，也不怕。打开debug模式，可以看到一直在发包，不过要发1000000个才结束，还是要很久的。

我觉得没有太大的必要跑前面的example
