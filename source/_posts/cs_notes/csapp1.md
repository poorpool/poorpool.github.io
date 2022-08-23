---
title: 《深入理解计算机系统》重修记 1
date: 2020-07-06 13:06:55
tags:
- 底层
- 笔记
categories:
- 底层
---

[课程来源](https://www.bilibili.com/video/BV1iW411d7hd)

<!-- more -->

# Machine Level Programming

risc 精简指令集，cisc 复杂指令集。以 arm 和 x86 为代表。

编译过程：预处理——编译——汇编——连接。

分别对应：

```bash
gcc -E -o qwq.i qwq.c
gcc -S -o qwq.s qwq.i
gcc -c -o qwq.o qwq.s
gcc -o qwq qwq.o
```

使用 `objdump -d qwq > qwq.d` 来反汇编。也可以 gdb 打开可执行文件以后 `disassemble functionName` 查看一个函数的反汇编。`x/14xb main` 检视从 main 开始的 14 个字节，十六进制形式。%rsp 是栈指针。%rip 指向当前在执行的指令。

`8(%rbp)` 就是 `Mem[Reg(%rbp)+8]`。`D(Rb, Ri, S)` 就是 `Mem[Reg[Rb]+S*Ri+D]`。有各种各样的精简版，套这个就行了。

如果用 `movq (%rdi, %rsi, 4) %rax` 取得的就是内存中这个地址的值。用 leaq 取得的是地址本身的值。

关于 swtich：值比较集中的时候会生成一个 jump table，直接根据被检查的值跳到响应的位置就可以了。但是如果是 0 和 1000000 这种数据就会变成 if-else。不过使用二分的思想，复杂度是 log。

%rsp 是从很高的值开始减。栈是倒过来的，高地址画在上头。

call 的时候会把栈指针减 8 然后写进去下一条指令的地址。ret 的时候 pop 出该地址然后返回。

![1.bmp](/images/csapp/1.bmp)

# 存储器层次结构

sram，静态 ram，稳定的，复杂的，昂贵的，快速的，应用于高速缓存存储器。

dram，动态 ram，便宜，慢，用于主存和帧缓冲区。

他们掉电就会白给。

闪存是一种 rom。

![image](/images/csapp/2.png)

顺带提一下南北桥。（干 南 桥！不过这一套好像过时了。

![image](/images/csapp/3.png)

计算机械硬盘容量的公式：

![image](/images/csapp/4.png)

（我怎么贴图这么多（（

对扇区的访问时间由寻道、旋转、传送时间构成。主要耗时是寻道和旋转，并且它们时间大致相等。

## 通用高速缓存存储器结构

存储器地址 $m$ 位，形成 $2^m$ 个不同的地址。存储器有 $S=2^s$ 个高速缓存组，每组有 $E$ 行，每行有一个 $B=2^b$ 字节的数据块，一个有效位，$t=m-s-b$ 个标记位。因此地址从高位到低位是 $t$ 位标记位，$s$ 位组索引，$b$ 位块偏移。

直接映射高速缓存，$E=1$。$E\not =1$ 是 $E$ 路组相联高速缓存。