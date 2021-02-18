---
title: Educational Codeforces Round 99 部分题记录
date: 2020-12-03 23:17:36
tags:
- 思维
categories:
- 算法竞赛
---

老年复健敷衍题解。

<!--more-->

## E

[ref](https://blog.csdn.net/qq_30361651/article/details/110424199)

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
int T;
ll x[4], y[4], xx[4], yy[4];
ll calc() {
    ll lxMax = max(xx[0], xx[2]), lxMin = min(xx[0], xx[2]), rxMin = min(xx[1], xx[3]), rxMax = max(xx[1], xx[3]);
    ll lx = max(rxMin - lxMax, 0LL), rx = max(rxMax - lxMin, 0LL);
    ll lyMax = max(yy[2], yy[3]), lyMin = min(yy[2], yy[3]), ryMin = min(yy[0], yy[1]), ryMax = max(yy[0], yy[1]);
    ll ly = max(ryMin - lyMax, 0LL), ry = max(ryMax - lyMin, 0LL);
    ll valX = rx != 0 ? lxMax - lxMin + rxMax - rxMin : lxMin - rxMin + lxMax - rxMax;
    ll valY = ry != 0 ? lyMax - lyMin + ryMax - ryMin : lyMin - ryMin + lyMax - ryMax;
    if (ry >= lx && ly <= rx)   return valX + valY;
    else if (ly > rx)   return valX + valY + 2 * (ly - rx);
    else    return valX + valY + 2 * (lx - ry);
}
int main() {
    scanf("%d", &T);
    while (T--) {
        for (int i = 0; i < 4; i++) {
            scanf("%lld %lld", &x[i], &y[i]);
        }
        int num[] = {0, 1, 2, 3};
        ll ans = 0x3f3f3f3f3f3f3f3fLL;
        do {
            for (int i = 0; i < 4; i++) {
                xx[i] = x[num[i]];
                yy[i] = y[num[i]];
            }
            ans = min(ans, calc());
        } while (next_permutation(num, num+4));
        printf("%lld\n", ans);
    }
    return 0;
}
```