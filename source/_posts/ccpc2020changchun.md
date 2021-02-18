---
title: CCPC 2020 长春站补题
date: 2020-12-06 19:15:42
tags:
- 算法竞赛
categories:
- 算法竞赛
---

没去，自己做着玩。[2020 China Collegiate Programming Contest Changchun Onsite](https://codeforces.com/gym/102832)

<!--more-->

# A. Krypton

枚举氪金的顺序，非首充通通充一块的

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int n, ans, ret, nn;
int a[7] = {1, 6, 28, 88, 198, 328, 648};
int r[7] = {8, 18, 28, 58, 128, 198, 388};
int main() {
    cin>>n;
    do {
        ret = 0;
        nn = n;
        for (int i = 0; i < 7; i++) {
            if (nn >= a[i]) {
                nn -= a[i];
                ret += r[i] + a[i] * 10;
            }
        }
        ans = max(ans, ret + nn * 10);
    } while (next_permutation(a, a+7) && next_permutation(r, r+7));
    cout<<ans<<endl;
    return 0;
}
```

# D. Meaningless Sequence

观察到 $a_i=c^{d}$，$d$ 为 $a_i$ 二进制表示中 1 的个数，直接组合数来一套。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
const int mod = 1e9 + 7;
char s[3009];
int c, cpows[3005], zhs[3005][3005], len, passed1, cnt[3005], ans=1;
int main() {
    scanf("%s %d", s, &c);
    cpows[0] = 1;
    for (int i = 1; i <= 3003; i++) {
        cpows[i] = ((ll)cpows[i-1] * c) % mod;
        for (int j = 0; j <= i; j++) {
            if (j==0 || j==i)   zhs[i][j] = 1;
            else    zhs[i][j] = (zhs[i-1][j-1] + zhs[i-1][j]) % mod;
        }
    }
    len = strlen(s);
    for (int i = 0; i < len; i++) {
        if (s[i] == '1') {
            int k = len - 1 - i;
            int tmp = 0;
            for (int j = 1; j <= k; j++) {
                tmp = (tmp + (ll)zhs[k][j] * cpows[j] % mod) % mod;
            }
            tmp = (tmp + c) % mod;
            ans = (ans + (ll)tmp * cpows[passed1] % mod) % mod;
            passed1++;
        }
    }
    printf("%d\n", ans);
    return 0;
}
```