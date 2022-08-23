---
title: Linux命令行与shell脚本编程大全 一些奇妙的写法
date: 2020-03-12 16:58:44
tags:
- shell
- Linux
categories: Linux
---
牙疼不是病，疼起来真要命。

<!--more-->

# 处理命令行参数
可以使用getopt，太菜了，不说了。

```bash
#!/bin/bash
while getopts :ab:cd opt
do
    case $opt in
    a) echo "Found -a option";;
    b) echo "Found -b option, with value $OPTARG";;
    c) echo "Found -c option";;
    d) echo "Found -d option";;
    *) echo "Unknown option: $opt";;
    esac
done

shift $[ $OPTIND - 1 ]

count=1
for param in "$@"
do
    echo "Param #$count: $param"
    count=$[ $count + 1 ]
done
```

```
$ ./qwq.sh -a -b test1 -d test2 test3 test4
Found -a option
Found -b option, with value test1
Found -d option
Param #1: test2
Param #2: test3
Param #3: test4
```

# 读入
```bash
read -p "input your name: " first last
```

# 重定向
`2>`是重定向stderr，`1>`是重定向stdout。`&>`是重定向stderr和stdout，但是err会有更高的优先级，也就是出现在更前面。

```bash
ls -al AFileThatDoesntExist 2> log.txt
```

有意地输出错误信息，例如`>&2`
```bash
echo "This is a wrong message" >&2
```
上面是临时重定向，下面是永久重定向。
```bash
exec 2>test
```
把本来发给stderr的通通重定向到test。顺带一提创建文件描述符也是这个语法。
```bash
exec 3>&1
exec 1>testout
exec 1>&3
```
这个体现了保存、恢复文件描述符的过程。关闭就用 `exec 3>&-`。

# sed、gawk与正则

`^$`分别是锁定在行首和锁定在行尾的锚字符。它们也可以组合起来用（他俩连用过滤掉空白行）。

```bash
$ echo "This is a test" | sed -n '/^This/s/test/big test/p'
This is a big test
$ echo "is This is a test" | sed -n '/^This/s/test/big test/p'
$ echo "is This is a test" | sed -n '/test$/s/test/big test/p'
is This is a big test
$ echo "is This is a test is" | sed -n '/test$/s/test/big test/p'
```

```bash
$ echo "QwQ at home" | sed -n "/[^ch]at/p"
QwQ at home
```
方括号里加个脱字符表示一个除了c和h之外的任意字符。但是要有一个字符（空格），不然就不行（例如at在行首）。

区间：`[a-ch-m]`是a到c，以及h到m的并。

`&`表示匹配的模式。
                                                                                                                                                                                                                                              
字符后面放星号表示该字符出现0到任意多次。放星号甚至可以用在点、区间后头。
```bash
$ echo "this fdferer fsdf siht" | sed -n "/this.*siht/p"
this fdferer fsdf siht
```
你看，多么奇妙。

下面是扩展正则表达式了。sed不支持，gawk支持。

后头放问号是出现0、1次，加号是至少出现一次。

后头加`{3}`这种的花括号是刚好出现3次，`{3,6}`是出现3到6次。注意gawk使用这个的时候应该加上 `--re-interval`。

管道符号`|`表示或。它和正则表达式之间不能有空格不然就被认为是正则的一部分了。

可以拿圆括号分组。`(urtay)?`表示urtay出现0或1次。

匹配美国电话号和电子邮件：
```bash
gawk --re-interval '/^\(?[2-9][0-9]{2}\)?(| |-|\.)[0-9]{3}( |-|\.)[0-9]{4}$/{print $0}'
gawk --re-interval '/^([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.\+]+)\.([a-zA-Z]{2,5})$/{print $0}'
```
给数字加逗号
```bash
sed '{
:start
s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/
t start
}'
```
波浪线将正则表达式限定在特定数据字段：
```bash
$ gawk -F: '$1 ~ /poorpool/{print $1,$NF}' /etc/passwd 
poorpool /usr/bin/fish
```