---
title: CS144 Lab 记录
date: 2021-02-12 15:26:44
tags:
- 计算机网络
- 笔记
categories:
- 笔记
---
计算机网络课

<!--more-->

# Lab 0

## 手工 telnet 发邮件

来个 163 邮箱[的](https://blog.csdn.net/csdnliwenqi/article/details/108558969)

## netcat

`nc -v -l -p 9090` 监听 9090 端口，用 telnet/nc 连接成功以后可以互发信息。

## webget

使用文档中提供的包裹类即可

## 简单 stream

先学个大括号初始化，这玩意又叫 initializer_list。C++ 11 的。

然后就拿一个 string 当作内部存储就好了。

# Lab 1

实现一个分组重排器：

![image](/images/cs144/1.png)

一旦能够排好，立刻输入到 ByteStream 里头，这样应用层就可以读字节了。

# Lab 2

first_unassembled 即为 tcp 中 ackno，first_unassembled 和 first_unacceptable 的差即为 window size。

ack，ackno 都是 acknowledgement，代表已经全部收到小于 ackno 的字节。

ByteStream 的下标是 64 位，但是 tcp seqno 是 32 位的，需要转换。

一个字节一个下标，SYN 和 FIN 单独占一个下标。开头是随机的，也即 SYN 的下标为 ISN（initial sequence number）

![image](/images/cs144/2.png)

# Lab 3

lab 3 实现一个发送方，仔细看材料吧。

# Lab 4

把东西接起来，实现 TCPConnection。

**文档摘编**：

收到 segment 时：如果 rst 设置了，立刻结束连接；给 receiver 提供 segment；给 sender 提供 ackno（如果有）；研究是否要返回 ackno。

发送 segment 时：看 pdf。

tick 时：告诉 sender 时间流逝。可能提早结束连接，或者干净地结束连接。

主要还是看文档，，，然后写出来的东西肯定炸得一塌糊涂，不要慌，先 make check_lab3 确定都过了，然后一个一个慢慢修改。**注意不要随便 debug printf 输出！**不然后面的自动测试过不了。最终我的 benchmark 为 4.6 和 3.3 Gbit/s，很神奇。

# Lab 5

实现 arp 协议，通过 ip 找到 mac。很简单，照着做就可以了。没有特意降低复杂度。

# Lab 6

最长前缀匹配路由转发，好写。

# Lab 7

这个不用写。

![image](/images/cs144/3.png)

结束啦，撒花～