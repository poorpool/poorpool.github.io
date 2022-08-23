---
title: 《编译原理》第二版（龙书）学习笔记
date: 2021-01-27 15:53:36
tags:
- 编译原理
- 笔记
categories:
- 笔记
---
因为做课设要用，先随便学一学

<!--more-->

# 引论

语言处理系统：预处理器，编译器，汇编器，链接器。

编译期把源程序映射为在语义上等价的目标程序，由分析部分和综合部分组成，也就是前端和后端。

## 词法分析

编译器的第一个步骤是词法分析。每个词素产生词法单元（token），形如`<token-name, attribute-value>`。

```
position = initial + rate * 60
```

position 映射成 `<**id**, 1>`，**id** 为标识符，1 指向符号表中 position 对应的条目。

```
<id, 1> <=> <id, 2> <+> <id,3> <*> <60>
```

后面是语法分析，语义分析……先不看了（）

# 一个简单的语法制导翻译器

## 语法定义

上下文无关文法。

```
if (expression) then statement else statement
```

用 expr 表示表达式，stmt 表示语句，则可以表示为

```
stmt -> if (expr) stmt else stmt
```

`->` 为具有以下形式，这样的规则是产生式。if、括号这样的词法元素为终结符号，expr、stmt 这样的变量表示终结符号的序列，为非终结符号。

![qwq](/images/compileprinciple/1.png)

最终要都是终结符号。