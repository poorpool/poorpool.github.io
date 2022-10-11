---
title: Redis 学习笔记
date: 2022-09-02 22:31:17
tags:
- redis
- 笔记
categories:
- 笔记
---

基于内存的nosql数据库

<!--more-->

## NoSQL 认识

![image-20220905165346148](/home/poorpool/Documents/myblog/poorpool/source/_posts/programming/redis-notes.assets/image-20220905165346148.png)

水平扩展：不改动数据库表结构，通过对表中数据的拆分而达到分片的目的

垂直扩展：将表和表分离，或者改动表结构，依照訪问的差异将某些列拆分出去。

另一种解释：水平方向的添加更多的机器，在垂直的方向上添加更多的资源。

