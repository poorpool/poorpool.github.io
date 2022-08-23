---
title: HUST ACM 2020 新生赛补题
date: 2020-12-06 19:32:01
tags:
- 算法竞赛
categories:
- 算法竞赛
---

虽然是老油条，但还是来玩了玩。题目在 [hls 的 OJ](http://jjikkollp.icu)。做出来了 A、B、C、E 四个题。补的题都有题意。

<!--more-->

# A. Chipmunk and Cakes

二分跳石头，NOIP 题。注意最后一个不能删，要特判。

# B. Chipmunk and Brackets

暴力括号匹配。注意可以在栈里保存每一个左括号位置，这样就可以直接 $i-stack.top+1$。

# C. Chipmunk and Ele.me

感觉是个混合背包。用 0/1 背包解决用 $i$ 魔法值能得到多少能量，用完全背包解决用 $i$ 魔法值经恢复能到达多少魔法值。max 比值就是答案。

# D. Chipmunk and Array

**题意**：$[1,2n]$ 这些数划分成 B 和 C 两个等长单增序列，且要求 $B_i < C_i$，问方案数（取模）。

看到取模数，应该想一想递推什么的。推不出来，就应当换一种思路（））发现条件就等价于依次填数，填完 $|B|\geq |C|$。***这不就是 Catalan 数吗！***

$C_n=\binom{2n}{n}-\binom{2n}{n-1}=\frac{1}{n+1}\binom{2n}{n}$。这和出栈序列个数、合法括号匹配数是一种题。

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
const int mod = 998244353;
int n, ans, b[2000005];
int main() {
    cin>>n;
    b[1] = 1;
    for (int i = 2; i <= n + 1; i++) {
        b[i] = (mod-(ll)(mod/i)*b[mod%i]%mod)%mod;
    }
    int ans = b[n+1];
    for (int i = 1; i <= n; i++) {
        ans = (ll)ans * (n + i) % mod;
        ans = (ll)ans * b[i] % mod;
    }
    cout<<ans<<endl;
    return 0;
}
```

# E. Chipmunk and Wormholes

可以按二进制位来构造。第 $i$ 次依据每个元素二进制表示 $i$ 位置上为 0/1 来划分，可以保证每两个不同的元素都会被分到两个集合一次。我是递归地划分集合，每次划分所给集合为两半，把这两半放到两个集合。总的来说就是划分第 $i$ 层有 $2^i$ 个小集合，把这些小集合轮流放到要产生边的两个大集合里。

# J. Chipmunk and Hunters

**题意：** 有 $n$ 个猎人和价值 $V$ 的钱币，每个猎人有权值 $a_i$ 和期望 $b_i$。可以选一些猎人去取钱币，每个猎人的钱币加权均分，也即 $a_iV/\sum_{\mathrm{selected}\ j}a_j$。如果超过 $b_i$ 这个猎人就是满意的。最大化满意猎人的数量。

首先最优方案显然是选择的每一个猎人都是满意的。$a_iV/\sum a_j\geq b_i$ 即 $\sum a_j \leq a_iV/b_i=s_i$。选择的所有猎人，权加起来应该小于最小的 $s_i$，因此将猎人按 $s_i$ 降序排序并枚举 $i$，大于等于 $s_i$ 的都可以选，可以选择的猎人是连续的。用堆维护猎人集合，使得权和小于等于 $s_i$，非法时候踢权最大的猎人。维护这个过程中堆最大 size。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
#include <queue>
using namespace std;
typedef long long ll;
struct Node {
    int a, b;
    double s;
}nd[200005];
int n, V, size, ans;
ll sum;
bool cmp(const Node &a, const Node &b) {
    return a.s > b.s;
}
priority_queue<int, vector<int>, less<int> > pq;
int main() {
    cin>>n>>V;
    for (int i = 1; i <= n; i++) {
        scanf("%d %d", &nd[i].a, &nd[i].b);
        nd[i].s = 1.0 * nd[i].a * V / nd[i].b;
    }
    sort(nd+1, nd+1+n, cmp);
    for (int i = 1; i <= n; i++) {
        pq.push(nd[i].a);
        sum += nd[i].a;
        size++;
        while (sum > nd[i].s + 1e-9) {
            int x = pq.top();
            pq.pop();
            sum -= x;
            size--;
        };
        ans = max(ans, size);
    }
    cout<<ans<<endl;
    return 0;
}
```
