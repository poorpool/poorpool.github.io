---
title: Linux奇妙命令
date: 2019-10-24 13:54:00
tags:
- shell
- Linux
categories: Linux
---
世界真是奇妙

<!--more-->
# find

find: `find [-path] expression`
find里头有 -mtime, -mmin之类的，形式上就是

```shell
find . -mtime +10 # 找到10*24小时之前的
find . -mtime -10 # 找到从现在往前推10*24小时以内的
find . -mmin +10 -exec rm {} \; # 找到10分钟以前的并删了
find . -path "./poorpool/node_modules" -prune -o -name "[A-Z]*" -print # 这个意思是要是在那个目录底下就跳过（prune），否则（o），就找首字母为大写英文字母的输出（name）那个
```
