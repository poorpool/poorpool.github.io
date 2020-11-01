---
title: luogu4202 [NOI2008]奥运物流 
date: 2018-07-09 09:15:35
tags: 动态规划——树形dp
categories:
  - OI
  - 动态规划
---
[论文](https://wenku.baidu.com/view/83d0a76925c52cc58bd6bea8.html) 和 [题解](https://blog.csdn.net/whjpji/article/details/7593329)

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
int n, m, nxt[65];
double K[65], c[65], f[65][65][65], g[65][65][65], F[65], ans;
void dp(int x, int d){
	for(int i=2; i<=n; i++)
		if(nxt[i]==x)
			dp(i, d+1);
	for(int D=min(2,d); D<=d; D++){
		for(int i=0; i<=m; i++)	F[i] = 0;
		for(int i=2; i<=n; i++)
			if(nxt[i]==x)
				for(int j=m; j>=0; j--)
					for(int k=j; k>=0; k--)
						F[j] = max(F[j], F[k]+g[i][j-k][D]);
		for(int i=0; i<=m; i++)
			f[x][i][D] = F[i] + c[x] * K[D];
	}
	if(d>1){
		for(int i=0; i<=m; i++)	F[i] = 0;
		for(int i=2; i<=n; i++)
			if(nxt[i]==x)
				for(int j=m; j>=0; j--)
					for(int k=j; k>=0; k--)
						F[j] = max(F[j], F[k]+g[i][j-k][1]);
		for(int i=1; i<=m; i++)
			f[x][i][1] = F[i-1] + c[x] * K[1];
	}
	for(int i=0; i<=m; i++)
		for(int D=0; D<=d; D++)
			g[x][i][D] = max(f[x][i][D+1], f[x][i][1]);
}
int main(){
	cin>>n>>m>>K[1];
	for(int i=1; i<=n; i++)	scanf("%d", &nxt[i]);
	for(int i=2; i<=n; i++)	K[i] = K[i-1] * K[1];
	for(int i=1; i<=n; i++)	scanf("%lf", &c[i]);
	int len=1;
	for(int x=nxt[1]; x!=1; x=nxt[x]){
		len++;
		for(int i=1; i<=n; i++)
			for(int j=0; j<=m; j++)
				for(int k=0; k<=n; k++)
					f[i][j][k] = g[i][j][k] = 0;
		int tmp=nxt[x]; nxt[x] = 1;
		for(int v=2; v<=n; v++)
			if(nxt[v]==1)
				dp(v, 1);
		for(int i=0; i<=m; i++)	F[i] = 0;
		for(int v=2; v<=n; v++)
			if(nxt[v]==1)
				for(int j=m; j>=0; j--)
					for(int k=j; k>=0; k--)
						F[j] = max(F[j], F[k]+f[v][j-k][1]);
		double now=0;
		for(int i=0; i<m; i++)	now = max(now, F[i]);
		if(tmp==1)	now = max(now, F[m]);
		ans = max(ans, (now+c[1])/(1-K[len]));
		nxt[x] = tmp;
	}
	printf("%.2f\n", ans);
	return 0;
}
```