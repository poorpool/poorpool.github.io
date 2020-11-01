---
title: luogu2354 [NOI2014]随机数生成器
date: 2018-06-25 11:12:52
tags: 贪心
categories: 贪心
---
只要不看错题就好办……模拟生成矩阵，然后贪心考虑 $1 \ldots nm$ 是否能填，这个维护一下每一行的能放数的位置就好了。

<!--more-->

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, m, nm, x[25000005], t[25000005], a, b, c, d, q, uu, vv, upp[5005], loo[5005], tot, e[10005];
void add(int a, int b){
	for(int i=1; i<=n; i++)
		if(i<a)	upp[i] = min(upp[i], b);
		else if(i>a)	loo[i] = max(loo[i], b);
}
int main(){
	cin>>x[0]>>a>>b>>c>>d;
	cin>>n>>m>>q;
	nm = n * m;
	for(int i=1; i<=nm; i++){
		x[i] = ((ll)a * x[i-1] % d * x[i-1] % d + (ll)b * x[i-1] % d + c) % d;
		t[i] = i;
	}
	for(int i=1; i<=nm; i++)
		swap(t[i], t[(x[i]%i)+1]);
	for(int i=1; i<=q; i++){
		scanf("%d %d", &uu, &vv);
		swap(t[uu], t[vv]);
	}
	for(int i=1; i<=nm; i++)
		x[t[i]] = i;
	memset(upp, 0x3f, sizeof(upp));
	for(int i=1; i<=nm; i++){
		int o=x[i], a=(o-1)/m+1, b=(o-1)%m+1;
		if(b<=upp[a] && b>=loo[a]){
			add(a, b);
			e[++tot] = i;
			if(tot==nm-1)	break;
		}
	}
	for(int i=1; i<=tot; i++)
		printf("%d ", e[i]);
	return 0;
}
```