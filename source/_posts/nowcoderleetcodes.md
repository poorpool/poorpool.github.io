---
title: 牛客和 leetcode 及类似 OJ 的部分题目刷题记录
date: 2021-03-12 19:21:15
tags:
- 笔记
categories:
- 笔记
---
oi 题比这刺激多了。

<!--more-->

## 剑指 Offer

在牛客做的。

### JZ1 二维数组中的查找

每行可能出现 target 的位置是递减的，所以从右上角开始向左不断走到不比自己大的元素，然后下降一格，再往左……复杂度 $O(n+m)$。

### JZ2 替换空格

新长度是 $length+space\times 2$，直接扫就行了。

### JZ3 从尾到头打印链表

毫无难度。倒是可以用栈，遍历一遍反转，反转链表之类的东西。

### JZ4 重建二叉树

毫无难度。记得 x 序遍历都是说的根节点，前序便利就是根-左-右这样。

### JZ5 用两个栈实现队列

不一定每次都要把元素送回去，第二个栈空了再出。

```java
import java.util.Stack;
 
public class Solution {
    Stack<Integer> stack1 = new Stack<Integer>();
    Stack<Integer> stack2 = new Stack<Integer>();
 
    public void push(int node) {
        stack1.push(node);
    }
 
    public int pop() {
        if (stack2.empty()) {
            while (!stack1.empty()) {
                stack2.push(stack1.pop());
            }
        }
        return stack2.pop();
    }
}
```

### JZ6 旋转数组的最小元素

一个不降序列，把前面几个元素挪到后面，二分找最小值。注意时刻记录最小值，函数末返回。leetcode 好像做过。

### JZ7 斐波纳契数列

随便做。

### JZ8 跳台阶

随便做。

### JZ9 变态跳台阶

用前缀和随便做。想一想不对啊，直接求 $2^{number-1}$，，，，

### JZ10 矩形覆盖

随便做。

### JZ11 二进制中 1 的个数

随便做。

### JZ12 数值的整数次方

随便做。

### JZ13 调整数组顺序使奇数位于偶数前面

如果不要求相对顺序不变可以用快速排序那种双指针法，要求的话就只好 $n^2$ 暴力或者空间换时间了，，，

### JZ14 链表中倒数第 k 个节点

暴力，或者快慢指针：快指针先走 k 步左右，然后一块一步一步走。

### JZ15 反转链表

没有难度。还是用循环吧，常数小，，，

```cpp
class Solution {
private:
    ListNode* dfs(ListNode *node, ListNode *should) {
        if (node == NULL)    return NULL;
        ListNode* next = node->next;
        node->next = should;
        if (next != NULL) {
            return dfs(next, node);
        } else {
            return node;
        }
    }
public:
    ListNode* ReverseList(ListNode* pHead) {
        return dfs(pHead, NULL);
    }
};
```

### JZ16 合并两个排序的链表

没有难度。

### JZ17 树的子结构

注意不是同构！！！考虑好什么可以是 nullptr。

### JZ18 二叉树的镜像

没有难度。

### JZ19 顺时针打印矩阵

没有难度。

### JZ20 包含 min 函数的栈

考虑到 min 随栈元素增多而下降，栈的每一个位置保存原值和到目前的 min 就可以了。

### JZ21 栈的压入、弹出序列

压栈序列出栈顺序可否为给定出栈序列？元素不等的情况下，每次模拟入栈，尽可能按照弹出序列出栈，看最后栈空与否。

### JZ22 从上往下打印二叉树

bfs 就行了。没有难度。

### JZ23 二叉搜索树的后序遍历序列

一段小于末尾，一段大于末尾。只有这两种可能。递归下去。

### JZ24 二叉树中和为某一值的路径

没有难度。（没有考虑字典序，，，

### JZ25 复杂链表的复制

神必题，，，深拷贝一个复杂链表，链表除了有 next，还会随机指向节点。开个 map 就行了。注意要立刻保存自己到 map，以免出现指向自己而死循环的情况，，，

### JZ26 二叉搜索树与双向链表

把二叉搜索树转换为双向链表，可以保存子树范围内的最小最大节点到全局。最后返回最小节点。

### JZ27 字符串的排列

stl 拉满（）注意去重。

### JZ28 数组中出现次数超过一半的数字

摩尔投票法。可能不出现，最后再检验。

原理就是当前候选人和所有人轮番击剑，活到最后的人也不一定是众数，再检验一次。

```cpp
class Solution {
public:
    int MoreThanHalfNum_Solution(vector<int> numbers) {
        int now = 0, cnt = 0;
        for (auto &x : numbers) {
            if (!cnt) {
                cnt = 1;
                now = x;
            } else if (now == x) {
                cnt++;
            } else {
                cnt--;
            }
        }
        cnt = 0;
        for (auto &x : numbers)
            cnt += x == now;
        if (cnt > numbers.size() / 2)    return now;
        else    return 0;
    }
};
```

### JZ29 最小的 k 个数

top k。看这个实现吧。

```cpp
class Solution {
public:
    int partition(vector<int> &input, int l, int r) {
        int pivot = input[(l + r) >> 1];
        int i = l, j = r;
        while (i <= j) {
            while (input[i] < pivot)    i++;
            while (input[j] > pivot)    j--;
            if (i <= j) {
                swap(input[i], input[j]);
                i++;
                j--;
            }
        }
        return i-1;
    }
    vector<int> GetLeastNumbers_Solution(vector<int> input, int k) {
        int len = input.size();
        if (len < k || k == 0)    return vector<int>{};
        int l = 0, r = len - 1, p;
        while (l <= r) {
            p = partition(input, l, r);
            if (p + 1 == k)    return vector<int>(input.begin(), input.begin() + k);
            else if (p + 1 < k)    l = p + 1;
            else    r = p;
        }
        return input;
    }
};
```

### JZ30 连续子数组的最大和

没有难度。

### JZ31 整数中 1 出现的次数（从 1 到 n 整数中 1 出现的次数）

简单的 dp，想清楚递推和递归。
```cpp
class Solution {
public:
    vector<int> dp0, dp1;
    int dfs(int x, int wei, int mi10) {
        if (x == 0)    return 0;
        if (x <= 9)    return 1;
        int zgw = x / mi10;
        int ret = zgw * dp1[wei - 1];
        if (zgw == 1) {
            ret += x - mi10 * zgw + 1;
        } else {
            ret += mi10;
        }
        ret += dfs(x - zgw * mi10, wei - 1, mi10 / 10);
        return ret;
    }
    int NumberOf1Between1AndN_Solution(int n)
    {
        int nn = n, wei = 0;
        while (nn) {
            nn /= 10;
            wei++;
        }
        dp0.push_back(0);
        dp1.push_back(0);
        int mi10;
        for (int i = 1; i <= wei; i++) {
            if (i == 1)    mi10 = 1;
            else    mi10 *= 10;
            dp0.push_back(mi10 + 9 * dp1.back());
            dp1.push_back(dp0.back() + dp1.back());
        }
        return dfs(n, wei, mi10);
    }
};
```

### JZ32 把数组排成最小的数

首先肯定不能用字典序。然后要排序，那就字符串 a + b < b + a 作为排序的依据吧。

### JZ33 丑数

丑数必定由丑数乘 2,3,5 得到，维护三个指针指向准备被乘的丑数，每次比较三个。

### JZ34 第一个只出现一次的字符

没有难度。

### JZ35 数组中的逆序对

没有难度。归并排序过程中求就可以了。

### JZ36 两个链表的第一个公共结点

双指针。两个链表为 Y 形，a 接 b b 接 a 就等长可用双指针了。（玄学错误）

### JZ37 数字在升序数组中出现的次数

没有难度。

### JZ38 二叉树的深度

没有难度。

### JZ39 平衡二叉树

没有难度。

### JZ40 数组中只出现一次的数字

经典题。

### JZ41 和为 S 的连续正数序列

随便推一推。

### JZ42 和为 S 的两个数字

没有难度。

### JZ43 左旋转字符串

string，没有难度。

### JZ44 翻转单词顺序列

拿 python 做，go 神秘编译错误（）

### JZ45 扑克牌顺子

出题人不会说人话吗？没有价值。

### JZ46 孩子们的游戏（圆圈中最后剩下的数）

研究一下约瑟夫环怎么推。$n$ 人报数 $m$，记 $f(n,m)$ 为从第一个人开始报数最后剩下的人的编号。

如果人从 0 开始编号，首先会干掉 $m\bmod n$，从而 $f(n,m)=(f(n-1,m)+m\bmod n)\bmod n=(f(n-1,m)+m)\bmod n$。$f(1,m)=0$。

### JZ47 求1+2+3+...+n

神经病啊这题。

### JZ48 不用加减乘除做加法

想一下，加用 xor，进位用 and：

```cpp
int Add(int num1, int num2)
{
    if (!num2)    return num1;
    return Add(num1^num2, (num1&num2)<<1);
}
```

### JZ49 把字符串转换成整数

写就完事了。

### JZ50 数组中重复的数字

标答不好，随便做吧。

### JZ51 构建乘积数组

就前缀和后缀和吧。没有难度。

### JZ52 正则表达式匹配

暴力。

### JZ53 表示数值的字符串

来写正则（x

```java
import java.util.regex.Pattern;
public class Solution {
    public boolean isNumeric(char[] str) {
        String pattern = "^[+-]?\\d*(?:\\.\\d*)?(?:[eE][+-]?\\d+)?$";
        return Pattern.matches(pattern, new String(str));
    }
}
```

### JZ54 字符流中第一个不重复的字符

有点技巧的暴力，队列和 map 结合起来。

### JZ55 链表中环的入口结点

双指针好题。设起点到环入口 $x$ 步，快慢指针相遇在环入口后 $y$ 步，环长 $y+z$ 步。慢指针在环上走了 $m$ 圈，快指针走了 $n$ 圈。

慢指针走了 $x+m(z+y)+y$ 步，快指针两倍快，走了 $2x+2m(z+y)+2y=x+n(z+y)+y$，$x+(2m-n)(z+y)+y=0$ 即 $x=kz+(k-1)y$，$x$ 刚好是 $k$ 圈 $y+z$ 减去已有的 $y$。也就是说，相遇以后把慢指针放回起点，两个指针每次均走一步，再次相遇的地方就是环的入口。

### JZ56 删除链表中重复的结点

没有难度。

### JZ57 二叉树的下一个结点

没有难度。

### JZ58 对称的二叉树

没有难度。

### JZ59 按之字形顺序打印二叉树

没有难度。

### JZ60 把二叉树打印成多行

没有难度。

### JZ61 序列化二叉树

没有难度。

### JZ62 二叉搜索树的第 k 个结点

没有难度。

### JZ63 数据流中的中位数

经典双堆法。时刻保持双堆 top 元素的大小关系。

### JZ64 滑动窗口的最大值

经典单调队列。

### JZ65 矩阵中的路径

没有难度。

### JZ66 机器人的运动范围

没有难度。

### JZ67 剪绳子

没有难度。

## 牛客

### NC50 链表中的节点每k个一组翻转

想好怎么接链表。

## LeetCode Microsoft

### 8 字符串转换整数 (atoi)

注意截断。如果新数超过了就要截断：

```cpp
if (flag != -1) {
    while (pos < len && isdigit(ss[pos])) {
        int todi = ss[pos] - '0';
        if (ret > qwq || (ret == qwq && todi > 7))
            return INT32_MAX;
        ret = ret * 10 + todi;
        pos++;
    }
    return ret;
} else {
    while (pos < len && isdigit(ss[pos])) {
        int todi = ss[pos] - '0';
        if (ret > qwq || (ret == qwq && todi > 7))
            return INT32_MIN;
        ret = ret * 10 + todi;
        pos++;
    }
    return -ret;
}
```

### 13 罗马数字转整数

想好就行了。没有难度。

### 20 有效的括号

没有难度。

### 21 合并两个有序链表

没有难度。

### 23 合并 k 个有序链表

用堆就行，扔进去 listnode，按 val 排序。

### 24 两两交换链表中的节点

没有难度。

### 25 K 个一组翻转链表

没有难度。

### 28 实现 strStr()

kmp。

### 46 全排列

没有难度。

### 47 全排列 II

数字可以重复。导致排列重复的原因就是相同的数字出现的顺序不一样。因此先排个序，在 dfs 的时候额外加一个条件，就是前面的相同数字都选了。

### 71 简化路径

拿 go 写（跑

### 91 解码方法

没有难度。

### 94 二叉树的中序遍历

迭代法怎么说？用 [morris 遍历](https://leetcode-cn.com/problems/binary-tree-inorder-traversal/solution/er-cha-shu-de-zhong-xu-bian-li-by-leetcode-solutio/)。

迭代法搞中序遍历的难点是一个叶节点怎么知道后序节点是啥，，，所以每次到有左子树的节点就先查询左子树的最右节点。把这个节点的右子树接到当前节点，然后去当前节点的左子节点。

这样一路向左，接完了叶节点的后序节点。到了最左的节点，因为它前面被接了右子树，会回到比它大的第一个节点。此时再查询左子树的最右节点会发现这个居然还有一个右节点（自己），便知道自己该进去了，然后取消掉左子树的最右节点的右子节点并把自己丢到 ans 里，去自己的右子树。

太精妙了。

时间复杂度，每一条边只会经过两次。所以是 $O(n)$。

### 98 验证二叉搜索树

记录子树最小最大值就行了。

### 101 对称二叉树

迭代法怎么做？设置两个待检队列，每次检查头部元素。放元素的时候一个左右一个右左。

### 114 二叉树展开为链表

注意复杂度分析，2n 也是 n。

### 116 填充每个节点的下一个右侧节点指针

利用好已经存在的节点。

### 117 填充每个节点的下一个右侧节点指针 II

注意先右后左！！！

### 124 二叉树中的最大路径和

简单题目。

### 125 验证回文串

没有难度。

### 146 LRU 缓存机制

看前面。

### 151 翻转字符串里的单词

可以先翻转单词，再翻转句子。

### 160 相交链表

做过了。

### 165 比较版本号

没有难度。