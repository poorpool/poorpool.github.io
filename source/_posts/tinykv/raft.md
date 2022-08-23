---
title: Raft 学习笔记与资料摘编
date: 2022-07-03 14:31:00
tags:
- Raft
- TinyKV
- 分布式
categories:
- 笔记
---

重新做一遍 TinyKV，立志好好学 Raft

<!--more-->

## 链接

[Raft博士论文翻译](https://github.com/OneSizeFitsQuorum/raft-thesis-zh_cn/blob/master/raft-thesis-zh_cn.md)

[Raft博士论文原版](https://raw.githubusercontent.com/ongardie/dissertation/master/stanford.pdf)

[etcd中的raft实现](https://www.codedump.info/post/20210515-raft/)

[raft在etcd中的实现，更好](https://blog.betacat.io/post/raft-implementation-in-etcd/)

## Raft 基础

term 任期，index 索引，commit 提交，apply 应用

Raft 通过首先选举一个 leader ，然后让 leader 完全负责管理复制的日志来实现一致性。leader 从客户端接收日志条目，再把其复制到其他服务器上，并告诉服务器何时可以安全地将日志条目应用于其状态机。

拥有 leader 大大简化了复制日志的管理。例如， leader 可以决定新的日志条目需要放在日志中的什么位置而不需要和其他服务器商议，并且数据都以简单的方式从 leader 流向其他服务器。

leader 可能会失败或与其他服务器断开连接，在这种情况下，将选举出新的 leader。

通过 leader 机制，raft 被分为三个小问题：

- leader 选举：启动集群时以及现有 leader 失败时必须选出新的 leader
- 日志复制：leader 必须接受来自客户端的日志条目，并在整个集群中复制它们，迫使其他日志与其自己的日志一致
- 安全性：下文 Raft 的保证中的状态机安全：如果一个服务器在它的状态机上 apply 了一个给定 index 的日志条目，那么其他服务器不会为同一 index apply 不同的日志条目

### Raft 的保证

- 选举安全：一个给定 term 内最多有一个 leader
- leader 只 append：一个 leader 从不覆盖、删除它日志中的条目，它只是 append
- 日志匹配：如果两份日志在某个条目有相同的 index 和 term，那么从开头到这个 index 的日志都相同
- leader 完备：如果一个日志条目在某一特定 term 中被 commit，那么更高 term 的 leader 的日志中都会出现这个条目
- 状态机安全：如果一个服务器在它的状态机上 apply 了一个给定 index 的日志条目，那么其他服务器不会为同一 index apply 不同的日志条目。

### leader 选举

#### 状态的变迁

在任何时刻，每一个服务器节点都处于这三个状态之一：leader candidate follower。通常情况下，系统中一个是 leader，其他的是 follower。candidate 是选举的时候才有的。

follower 不发送请求，只是响应来自 leader candidate 的请求。leader 处理所有的请求。如果客户端把请求发给了 follower，follower 会把请求重定向给 leader 让他处理。

![节点状态变迁图](https://raw.githubusercontent.com/OneSizeFitsQuorum/raft-thesis-zh_cn/master/static/3_3.png)

领导者一直是领导者，直到它宕机。

#### 处理 rpc 时考虑 term 的基本原则

基本的 rpc有两种：请求投票 rpc，附加日志 rpc（包含心跳包）

每个节点存储当前 term，这一编号在整个时期内单调的增长。当服务器之间通信的时候会交换当前 term：

如果一个服务器的当前 term 比其他人小，那么他会更新自己的 term 到较大的 term 值。此外：

- 如果一个候选人或者领导者发现自己的 term 过期了，那么他会立即恢复成 follower 状态（但是只有在请求明确表明自己是 leader 的情况下才会设置自己的 leader）
- 如果一个节点接收到一个包含过期的 term 的请求，那么他会直接拒绝这个请求。

服务器程序启动的时候，大家都是 follower。只要一个 follower 不断从 leader candidate 处接收到有效的 rpc 就一直是 follower。

#### 超时选举

leader 一直向所有跟随者发送心跳包（博士论文中就是不含日志的附加日志 rpc，tinykv 中不是）来维持权威。因此如果一个 follower 一段时间没有收到有效 rpc，就出现了选举超时，随后发起选举。

选举的过程：

1. follower 转换为 candidate，自增 term，给自己投票，重置计时器
2. 并行向其他节点发送请求投票 rpc，直到发生三件事情中的任何一件：
   1. 赢得选举。这个 candidate 从大多数服务器节点获得了针对同一 term 的选票，他就赢了，立刻成为 leader，发送心跳（考虑到一个节点最多只会对一个 term 投出一张选票，先来先服务，保证了选举安全）
   2. 其他节点成为 leader。如果收到其他节点宣称他是 leader 的附加日志 rpc，那么如果这个 leader 的 term（包含在此次的 RPC中）不小于 candidate 当前的 term，那么 candidate 会承认 leader 合法并回到 follower 状态。 如果此次 RPC 中的 term 比自己小，那么 candidate 就会拒绝这次的 RPC 并且继续保持 candidate 状态。
   3. 随机的选举超时时间内没有任何人获胜。再自增 term。发起选举。

### 日志复制

客户端的请求成为 propose rpc，包含一条或多条被复制状态机执行的指令。leader  将条目附加到日志中并发起附加日志 rpc，让其他节点去复制这条日志。这条日志被安全复制的时候，leader 会 apply 这条日志并返回结果给客户端。

如果出现了网络丢包或者运行缓慢，leader 可能已经 apply 了日志并回复了客户端，但还是会不断重复尝试附加日志 rpc（比如心跳包返回的结果发现还有日志要附加）

当 leader 将日志条目复制到绝大部分节点的时候，日志条目就会被 commit（同时意味着之前的日志条目也 commit 了）。commitIndex 也会被包含到附加日志 rpc 和心跳包中。

如果 follower 知道一条日志条目 commit 了，就会 apply 这条日志条目。

回到前面的日志匹配：如果两份日志在某个条目有相同的 index 和 term，那么从开头到这个 index 的日志都相同。这个特性是因为在发送附加日志 RPC  的时候，leader 会把新的日志条目紧接着之前的条目的 index 和 term 包含在里面。如果 follower 在它的日志中找不到包含相同 index 和 term 的条目，那么他就会拒绝接收新的日志条目。

极端情况下，follower 可能会丢失一些在新的 leader 中有的日志条目，他也可能拥有一些 leader 没有的日志条目。因此，leader 要找到两者最后达成一致的地方。他会对每一个跟随者维护 nextIndex，表示下一个需要发送给 follower 的日志的 index。也会维护一个 matchIndex，表示两者达成一致的 index。

！！要检查：成为 leader 时所有 nextIndex 为自己最后一条 index + 1。如果有一个 follower 日志和 leader 有冲突，那么 follower 会拒绝附加日志 rpc，leader 会减小对它的 nextIndex 并重试。最终 nextIndex 会在某个位置使 leader 和 follower 的日志达成一致。当这种情况发生，附加日志 RPC 就会成功，这时就会把 follower 冲突的日志条目全部删除并且加上 leader 的日志。一旦附加日志 RPC 成功，那么 follower 的日志就会和 leader 保持一致，并且在接下来的 term 里一直继续保持。

实际上，leader 不会一上来就发送附加日志 rpc，而是通过心跳包协调 nextIndex。当协调到的 matchIndex 恰好比 nextIndex 小1，就立刻发送附加日志 rpc。

