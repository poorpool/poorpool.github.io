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

[八股1](https://github.com/huihut/interview)。

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

怎么避免对方发太多？用滑动窗口（cs144 的 win）。把可以发送的内容限制在这个窗口里。

### TCP 拥塞控制

怎么避免对方发太快？慢开始、拥塞避免、快速重传、快速恢复。[详见](https://github.com/huihut/interview#tcp-%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6)。还有个 bbr 算法。

### TCP 和 UDP 的区别

[看这里](https://github.com/huihut/interview#tcp-%E4%B8%8E-udp-%E7%9A%84%E5%8C%BA%E5%88%AB)

### 浏览器输入 url

[一个比较好的有图的版本](https://www.jianshu.com/p/c1dfc6caa520)。

[一个版本](https://www.cnblogs.com/jin-zhe/p/11586327.html)，[另一个版本](https://zhuanlan.zhihu.com/p/43369093)。

### time-wait close-wait 2MSL

看[这里](https://www.cnblogs.com/huenchao/p/6266352.html)，讲得非常好。

## C++

### static

主要是 static 局部变量，全局变量，函数，成员变量，成员函数。看[这里](https://blog.csdn.net/lwbeyond/article/details/6184035)。

### 多态



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

Percolator 是 2PC（两阶段提交）的强化版。[这里](https://blog.csdn.net/maxlovezyy/article/details/88572692)介绍了一下 percolator。[这里](https://pingcap.com/blog-cn/percolator-and-txn/)是 TiDB 的操作。这些 lock，write，data 是写在不同的 column family 里头。COLUMN_LOCK 放锁，COLUMN_WRITE 放写/删操作记录，COLUMN_FAMILY 放真正的数据。[这里](https://github.com/poorpool/TinyKV-of-poorpool/blob/course/doc/project4-Transaction.md)是实验文档。

### CS144 TCP

主要的框架都是课程搭好的。这里注重一下 seq、ack、syn、fin 的逻辑。

[为什么要三次握手而不是两次握手](https://blog.csdn.net/lengxiao1993/article/details/82771768)。简答：知道对方的 seq 且确定对方知道自己的 seq。

为什么第二次握手不顺带发个数据？面试官提了一下连接都没建立为啥要发数据，所以答案应该是连接未完成。不过我觉得我答的防洪泛攻击也有一点点道理。（其实 tls 1.3 有 early data 这种东西（））

### C Formatter

递归下降法是为每一个语法成分编写一个可递归调用的分析子程序进行自顶向下分析的语法分析方法。

