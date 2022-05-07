---
title: 6.s081 学习笔记
date: 2022-01-12 13:52:42
tags:
- PDSL
- 笔记
- Raft
categories:
- 笔记
---

[DPUKV私仓地址](https://github.com/CheneyDing/dpukv)

## 阅读材料

[三篇文章了解 TiDB 技术内幕 - 说存储](https://pingcap.com/zh/blog/tidb-internal-1)

不能用一个 raft group 来存所有数据，要按照 key 分 range，用 StartKey 到 EndKey 这样一个左闭右开区间来描述,也就是一个 Region。一个 Region 里头的多个节点叫 Replica。

多版本控制 MVCC 的情况下，key 长这样，版本号较大的放在前面，版本号小的放在后面。

![qwq](/images/dpukv/1.png)

[三篇文章了解 TiDB 技术内幕 - 说计算](https://pingcap.com/zh/blog/tidb-internal-2)

这个文章主要讲了 TiDB 变 TiKV 上的操作，可以看着玩。

[三篇文章了解 TiDB 技术内幕 - 谈调度](https://pingcap.com/zh/blog/tidb-internal-3)

调度落地下来主要是三件事情：

- 增加一个 Replica
- 删除一个 Replica
- 将 Leader 角色在一个 Raft Group 的不同 Replica 之间 transfer

## Raft 论文精读

[Raft 中文论文](https://github.com/maemual/raft-zh_cn/blob/master/raft-zh_cn.md)

