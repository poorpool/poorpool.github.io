---
title: luogu1758 [NOI2009]管道取珠
date: 2018-07-06 10:06:16
tags: 动态规划——普通dp
categories:
  - OI
  - 动态规划
---
神仙 dp。[ref](https://blog.csdn.net/qpswwww/article/details/44065431)

<!--more-->

显然不能暴力求。考虑一下 $\sum a_i^2$ 是什么意义。

经过一番瞎搞，我们知道了这是“让两个人各玩一次，得到的序列相同的方案数”。

然后就水水的了。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int n, m, f[2][505][505];
char a[505], b[505];
const int mod=1024523;
int main(){
    cin>>n>>m;
    scanf("%s", a+1);
    scanf("%s", b+1);
    reverse(a+1, a+1+n);
    reverse(b+1, b+1+m);
    f[0][0][0] = 1;
    for(int i=0; i<=n; i++)
        for(int j=0; j<=m; j++)
            for(int k=0; k<=n; k++){
                int l=i+j-k;
                if(!f[i&1][j][k] || l<0 || l>m)	continue;
                if(a[i+1]==a[k+1])	f[(i+1)&1][j][k+1] = (f[(i+1)&1][j][k+1] + f[i&1][j][k]) % mod;
                if(a[i+1]==b[l+1])	f[(i+1)&1][j][k] = (f[(i+1)&1][j][k] + f[i&1][j][k]) % mod;
                if(b[j+1]==a[k+1])	f[i&1][j+1][k+1] = (f[i&1][j+1][k+1] + f[i&1][j][k]) % mod;
                if(b[j+1]==b[l+1])	f[i&1][j+1][k] = (f[i&1][j+1][k] + f[i&1][j][k]) % mod;
                if(i==n && j==m && k==n)	break;
                else    f[i&1][j][k] = 0;
            }
    cout<<f[n&1][m][n]<<endl;
    return 0;
}
```