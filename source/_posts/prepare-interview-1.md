---
title: 面试突击人
date: 2021-02-12 10:22:15
tags:
- 杂
categories:
- 笔记
password: 123456
---

本文虽然有密码，但是不算什么要紧的内容，只是做了简单的加密。

<!--more-->

> 面试官你好，我的名字是chenyixiao。我来自华中科技大学计算机科学与技术学院。我现在在上大二。
> 技能方面，高中时我参加过NOI并获得铜牌，所以我能够比较熟练的使用一些常用的数据结构和算法。我能够比较熟练地使用C和C++语言，也使用过一段时间的Java和Go。我日常使用Linux，熟悉Linux和Shell的常用操作。
> 知识方面，虽然我们还没有开始主要专业课的学习，但我也自学过计算机网络，使用过数据库。
> 能力方面，我认为最突出的一点是我有比较强的编程能力。寒假的时候我参加了PingCAP的Talent Plan，学习并实现了raft算法、分布式事务等知识，并借助Raft算法构建了一个简要版本的分布式KV数据库。我还用五天左右的时间做了CS144的Lab，深化了对计算机网络的认知。平常我也喜欢自己编一些小程序。
> 性格方面，我有比较强的团队协作能力，加入了华中科技大学联创团队lab组，并且无论是作为课程设计的小组长还是组员，都能按时完成自己的工作。我还有比较强的沟通能力，是华中科技大学的网络助管之一。如果我有幸进入腾讯实习，我一定努力学习，积极工作，争取保质保量地完成任务。

[八股1](https://github.com/huihut/interview)。

倾听问题，样本确认， 动口不动手的暴力天然解， 动口也动手的最优解，路演你的思路，结构化的编码，单元测试

# 知识

## 计算机网络

协议栈：![xieyizhan](https://camo.githubusercontent.com/ae61b7eaf557549d449c8658c14fd8917c22242dcdb50325b164896a0d7a709e/68747470733a2f2f67697465652e636f6d2f6875696875742f696e746572766965772f7261772f6d61737465722f696d616765732f2545382541452541312545372541452539372545362539432542412545372542442539312545372542422539432545342542442539332545372542332542422545372542422539332545362539452538342e706e67)

### 三次握手四次挥手

三次握手回想一下 cs144，先发一个 syn，回一个 syn+ack，回一个 syn+ack。

四次挥手发一个 fin，回一个 ack。等一会儿回一个 fin+ack，发一个 ack。

> 为什么连接的时候是三次握手，关闭的时候却是四次握手？
> 答：因为当Server端收到Client端的SYN连接请求报文后，可以直接发送SYN+ACK报文。其中ACK报文是用来应答的，SYN报文是用来同步的。但是关闭连接时，当Server端收到FIN报文时，很可能并不会立即关闭SOCKET，所以只能先回复一个ACK报文，告诉Client端，"你发的FIN报文我收到了"。只有等到我Server端所有的报文都发送完了，我才能发送FIN报文，因此不能一起发送。故需要四步握手。

发送 fin 表示不会再**主动**发送数据了。

三次握手的核心是知道对方的 seq。所以要三次。accept过程发生在三次握手之后，三次握手完成后，客户端和服务器就建立了tcp连接并可以进行数据交互了。这时可以调用accept函数获得此连接。

### TCP 流量控制

怎么避免对方发太多？用滑动窗口（cs144 的 win）。把可以发送的内容限制在这个窗口里。流量控制（flow control）就是让发送方的发送速率不要太快，要让接收方来得及接收。

### TCP 拥塞控制

怎么避免对方发太快？慢开始、拥塞避免、快速重传、快速恢复。[详见](https://github.com/huihut/interview#tcp-%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6)。还有个 bbr 算法。拥塞控制就是防止过多的数据注入到网络中，这样可以使网络中的路由器或链路不致过载。

### TCP 和 UDP 的区别

[看这里](https://github.com/huihut/interview#tcp-%E4%B8%8E-udp-%E7%9A%84%E5%8C%BA%E5%88%AB)

UDP 包最大长度 64k 左右（长度字段决定），但是局域网中建议不超过1472，因特网 548（MTU 最大传输单元）决定。

### 浏览器输入 url

回答要点：假设这个 url 是合法的，那么

1. 浏览器的资源缓存。如果没有缓存自然就跳过了。缓存有两种情况，一种是浏览器通过Cache-control告诉你max-age为多少，那么在这个没过期的时间里就不会去发请求协商缓存，这是强缓存。
[一个比较好的有图的版本](https://www.jianshu.com/p/c1dfc6caa520)。否则，就要发 HTTP 请求去协商缓存了。协商缓存一会儿讲。
2. DNS查询。浏览器DNS缓存、操作系统DNS缓存、ISP的DNS服务器（电脑上常设的114.114.114.114），如果还没有就要由本地DNS服务器去迭代查询DNS了。查根域名DNS服务器，com这种顶级域dns服务器，baidu.com等权威dns服务器。dns服务器常常用anycast技术设置多个站点，dns使用的是udp。
3. 发起http请求。通过dns获取到ip地址以后，TCP三次握手建立连接。GET / HTTP/1.1 之类的。它会带一些 header。比如前面说的缓存有协商缓存。请求带上一个if-modified-since这样的header，如果服务器发现没有修改，就返回304 not modified。否则就返回 HTTP/1.1 200 OK 之类的。
4. 如果使用长连接的话，那么下一个http请求还会使用同一条TCP连接。否则就四次挥手结束连接。

[一个版本](https://www.cnblogs.com/jin-zhe/p/11586327.html)，[另一个版本](https://zhuanlan.zhihu.com/p/43369093)。

### time-wait close-wait 2MSL

看[这里](https://www.cnblogs.com/huenchao/p/6266352.html)，讲得非常好。

## 操作系统

### 进程线程协程

[这里](https://zhuanlan.zhihu.com/p/354251307)

操作系统会以进程为单位，分配系统资源（CPU时间片、内存等资源），进程是资源分配的最小单位。

线程是程序执行中一个单一的顺序控制流程：

1）是程序执行流的最小单元；2）是处理器调度和分派的基本单位。

一个标准的线程由线程ID、当前指令指针（PC）、寄存器和堆栈组成。而进程由内存空间（代码、数据、进程空间、打开的文件）和一个或多个线程组成。

1）线程是程序执行的最小单位，而进程是操作系统分配资源的最小单位；2）一个进程由一个或多个线程组成，线程是一个进程中代码的不同执行路线；3）进程之间相互独立，但同一进程下的各个线程之间共享程序的内存空间（包括代码段、数据集、堆等）及一些进程级的资源（如打开文件和信号），某进程内的线程在其它进程不可见；4）线程上下文切换比进程上下文切换要快得多。

我们平常说的线程是用户线程，四核八核心是内核线程。两者之间多对多的关系。

1）线程的切换由操作系统负责调度，协程由用户自己进行调度，因此减少了上下文切换，提高了效率；2）线程的默认Stack大小是1M，而协程更轻量，接近1K。因此可以在相同的内存中开启更多的协程；3）由于在同一个线程上，因此可以避免竞争关系而使用锁；4）适用于被阻塞的，且需要大量并发的场景。但不适用于大量计算的多线程，遇到此种情况，更好实用线程去解决。

开发者在每个线程中只做非常轻量的操作，比如访问一个极小的文件，下载一张极小的图片，加载一段极小的文本等。但是，这样”轻量的操作“的量却非常多。在有大量这样的轻量操作的场景下，即使可以通过使用线程池来避免创建与销毁的开销，但是线程切换的开销也会非常大，甚至于接近操作本身的开销。对于这些场景，就非常需要一种可以减少这些开销的方式。于是，协程就应景而出，非常适合这样的场景。https://www.zhihu.com/question/20511233

协程的直观好处：https://www.zhihu.com/question/20511233 里头游戏开发的例子。

## 系统架构

### 限频

主要是站在 Server 端的视角：

- 固定窗口法。就比方说一秒里头最多接受100个请求。缺点是无法处理尖峰流量和窗口切换时可能产生两倍阈值的流量。
- 滑动窗口法。这玩意不要讲了。
- 漏斗法。有一个漏斗缓存请求，以恒定速率吐请求出来处理。
- 令牌桶算法。以恒定速率放令牌到桶里，请求拿到令牌才能执行。可以处理尖峰流量。

### 消息队列

主要是为了实现异步、削峰、解耦。

## C++

### static

主要是 static 局部变量，全局变量，函数，成员变量，成员函数。看[这里](https://blog.csdn.net/lwbeyond/article/details/6184035)。

### 多态

虚函数。

每个类的实例化对象都会拥有虚函数指针并且都排列在对象的地址首部。而它们也都是按照一定的顺序组织起来的，从而构成了一种表状结构，称为虚函数表 (virtual table) 。0

### 智能指针

https://www.cnblogs.com/bruce1992/p/14490176.html

## Java

### 反射

原理可以看[这个](https://zhuanlan.zhihu.com/p/162971344)，看不太懂（）。

## 算法

### KMP

看[这个](https://www.zhihu.com/question/21923021)，牢记 next 数组记录的是每一个位置上，从开始到目前的字符串，前缀等于后缀的最长长度（不能为本身）。

我的实现，字符串从0开始，nxt从1开始（`nxt[0]=-1`）。

### LRU

经典实现是哈希表+双向链表。

```cpp
struct Node {
    Node *left;
    Node *right;
    int key;
    int val;
};
class LRUCache {
public:
    int now;
    int cap;
    unordered_map<int, Node *> mp;
    Node *head, *tail;
    LRUCache(int capacity) {
        cap = capacity;
        now = 0;
        head = new Node{nullptr, nullptr, -0x3f3f3f3f, -0x3f3f3f3f};
        tail = new Node{nullptr, nullptr, -0x3f3f3f3f, -0x3f3f3f3f};
        head->right = tail;
        tail->left = head;
    }

    void use(Node *nd) {
        nd->left->right = nd->right;
        nd->right->left = nd->left;
        tail->left->right = nd;
        nd->left = tail->left;
        nd->right = tail;
        tail->left = nd;
    }

    int get(int key) {
        if (mp.count(key) == 0) return -1;
        Node *nd = mp[key];
        use(nd);
        return nd->val;
    }
    
    void put(int key, int value) {
        if (mp.count(key)) {
            mp[key]->val = value;
            use(mp[key]);
            return ;
        }
        now++;
        Node *nd = new Node{nullptr, nullptr, key, value};
        tail->left->right = nd;
        nd->left = tail->left;
        nd->right = tail;
        tail->left = nd;
        mp[key] = nd;
        if (now > cap) {
            head->right->right->left = head;
            mp.erase(head->right->key);
            head->right = head->right->right;
            now--;
        }
    }
};
```

### memmove

可以重叠的 memcpy，可以看[这里](https://blog.csdn.net/yzy1103203312/article/details/81006029)，分三类讨论，看是正着拷贝还是反着拷贝。

# 从面试中学习

## 算法题

输出 $n\times m$ 的蛇形矩阵。可以先用 min 算出圈数，然后判断是在这条圈的四条边中的哪一条边，加一加就行了。

如果是正方形的话，用两条对角线划分出四个区域，每个区域的数字是按一定的方向增增减减的，把位置和它所在的行列的数字增增减减就好了。看[这里](https://www.cnblogs.com/zhangbaoqiang/p/3534512.html)。

## 简历项目

我觉得以后写不下了，可以把一些东西放到自我介绍里头。

### tinykv

重点是 raft。

一是注意领导人选举，可以看这里的[图解](https://blog.csdn.net/weixin_30924239/article/details/95962901)，把握领导人选举的时机、操作等。

二是注意日志复制。可以看[这里](https://www.cnblogs.com/richaaaard/p/6351705.html)的中间部分，但是有点太详细了。

三是注意配置变更，三机变五机之类的。

Multi-Raft 部分，主要是处理数据分片。将数据根据 key 分成不同的 key region。[这里](https://blog.csdn.net/qq_38289815/article/details/107682089)大概介绍了一下 multi-raft。[这里](https://segmentfault.com/a/1190000008007027)为 PingCAP 的 TiKV 的 multi-raft。总的就是一个 store 存放多个 raft group 的副本。

Percolator 是 2PC（两阶段提交）的强化版。[这里](https://blog.csdn.net/maxlovezyy/article/details/88572692)介绍了一下 percolator。[这里](https://pingcap.com/blog-cn/percolator-and-txn/)是 TiDB 的操作。这些 lock，write，data 是写在不同的 column family 里头。COLUMN_LOCK 放锁，COLUMN_WRITE 放写/删操作记录，COLUMN_FAMILY 放真正的数据。[这里](https://github.com/poorpool/TinyKV-of-poorpool/blob/course/doc/project4-Transaction.md)是实验文档。先上锁，再写。

调度能力是啥，，？add node delete node。multi-raft 是 region split 那一套。

Raft：心跳、选举（自增任期号，请求投票）。操作都是领导做。多于半数才提交。follower可能拒绝leader的同步。

### CS144 TCP

主要的框架都是课程搭好的。这里注重一下 seq、ack、syn、fin 的逻辑。

[为什么要三次握手而不是两次握手](https://blog.csdn.net/lengxiao1993/article/details/82771768)。简答：知道对方的 seq 且确定对方知道自己的 seq。

为什么第二次握手不顺带发个数据？面试官提了一下连接都没建立为啥要发数据，所以答案应该是连接未完成。不过我觉得我答的防洪泛攻击也有一点点道理。（其实 tls 1.3 有 early data 这种东西（））

### C Formatter

递归下降法是为每一个语法成分编写一个可递归调用的分析子程序进行自顶向下分析的语法分析方法。

