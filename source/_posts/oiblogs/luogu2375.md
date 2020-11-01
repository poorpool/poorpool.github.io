---
title: luogu2375 [NOI2014]动物园
date: 2018-06-25 09:25:56
categories:
  - OI
  - 字符串
tags: 字符串——KMP
---
如果不管重叠就显然是在每个位置上不断迭代 next 数组，看迭代几次。

要是管重叠就迭代到不重叠就好了。预先处理一下“对于每个位置 $i$，有多少字符串满足 $1 \ldots l = i-l+1 \ldots i$”，这样不断迭代，时间复杂度 $n^2$。

<!--more-->

倍增优化迭代到不重叠的过程，时间复杂度 $n \log n$。可以过 $80$ 分，卡常可以 AC。

考虑记录一个变量，表示当前位置上最大的那个合法的 $l$，那么下一个位置就类似与 KMP 字符串匹配地研究一下 $l$ 的变化，复杂度 $n$，可以 AC。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int T, n, nxt[1000005], die[1000005], ans;
const int mod=1000000007;
char ss[1000005];
void getNxt(){
	int i=0, j;
	j = nxt[0] = -1;
	while(i<n){
		if(j==-1 || ss[i]==ss[j])	nxt[++i] = ++j;
		else	j = nxt[j];
	}
}
int main(){
	cin>>T;
	while(T--){
		ans = 1;
		memset(ss, 0, sizeof(ss));
		scanf("%s", ss);
		n = strlen(ss);
		getNxt();
		int j=0;
		for(int i=1; i<=n; i++){
			die[i] = die[nxt[i]] + 1;
			while(j && ss[i-1]!=ss[j])	j = nxt[j];
			if(ss[i-1]==ss[j])	j++;
			while(2*j>i)	j = nxt[j];
			ans = (ll)ans * (die[j] + 1) % mod;;
		}
		printf("%d\n", ans);
	}
	return 0;
}
```

倍增暴力：

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int T, n, nxt[1000005], die[1000005], f[1000005][21], ans;
const int mod=1000000007;
char ss[1000005];
void getNxt(){
    int i=0, j;
    j = nxt[0] = -1;
    while(i<n){
        if(j==-1 || ss[i]==ss[j])	nxt[++i] = ++j;
        else	j = nxt[j];
    }
}
int main(){
    cin>>T;
    while(T--){
        ans = 1;
        memset(ss, 0, sizeof(ss));
        // memset(f, 0, sizeof(f));
        scanf("%s", ss);
        n = strlen(ss);
        getNxt();
        for(int i=1; i<=n; i++){
            if(nxt[i]!=0)	die[i] = die[nxt[i]] + 1;
            else	die[i] = 1;
            f[i][0] = nxt[i];
            for(int j=1; j<=19; j++)
                f[i][j] = f[f[i][j-1]][j-1];
            int u=i;
            for(int j=19; j>=0; j--){
                if(2*f[u][j]>i)
                    u = f[u][j];
            }
            ans = (ll)ans * (die[nxt[u]] + 1) % mod;;
        }
        printf("%d\n", ans);
    }
    return 0;
}
```