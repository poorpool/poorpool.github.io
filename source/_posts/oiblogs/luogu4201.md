---
title: luogu4201 [NOI2008]设计路线 
date: 2018-07-08 16:26:25
tags: 动态规划——树形dp
categories:
  - OI
  - 动态规划
---
挺神仙的树形 dp，做这题还要深刻理解树剖。

<!--more-->

显然题目中所给的图是一棵树。而且这个修铁路方式就跟树链剖分差不多。问题转化为将树剖成不相交的链，使得到根节点所经过的轻边条数最小。（这里的链可以带拐的，不用和树链剖分一样必须直上直下）

[ref1](https://blog.csdn.net/lych_cys/article/details/51094793) and [ref2](https://blog.csdn.net/clover_hxy/article/details/54670345)，懒得写了……

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, m, q, fa[100005], hea[100005], cnt, uu, vv, dp[100005][13][3];
struct Edge{
	int too, nxt;
}edge[200005];
void add_edge(int fro, int too){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	hea[fro] = cnt;
}
int mf(int x){
	return fa[x]==x?x:fa[x]=mf(fa[x]);
}
int g(ll x){
	if(!x)	return x;
	x %= q;
	if(!x)	x = q;
	return x;
}
void dfs(int x, int m, int f){
	dp[x][m][0] = 1;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(t!=f){
			dfs(t, m, x);
			int t1=m?g((ll)dp[t][m-1][0]+dp[t][m-1][1]+dp[t][m-1][2]):0;//light
			int t2=g((ll)dp[t][m][0]+dp[t][m][1]);//heavy
			dp[x][m][2] = g((ll)dp[x][m][2]*t1+(ll)dp[x][m][1]*t2);
			dp[x][m][1] = g((ll)dp[x][m][1]*t1+(ll)dp[x][m][0]*t2);
			dp[x][m][0] = g((ll)dp[x][m][0]*t1);
		}
	}
}
int main(){
	cin>>n>>m>>q;
	for(int i=1; i<=n; i++)	fa[i] = i;
	for(int i=1; i<=m; i++){
		scanf("%d %d", &uu, &vv);
		add_edge(uu, vv);
		add_edge(vv, uu);
		uu = mf(uu); vv = mf(vv);
		if(uu!=vv)	fa[vv] = uu;
	}
	for(int i=1; i<=n; i++)
		if(mf(i)!=mf(1)){
			printf("-1\n-1\n");
			return 0;
		}
	for(int i=0; ; i++){
		dfs(1, i, 0);
		if(dp[1][i][0] || dp[1][i][1] || dp[1][i][2]){
			printf("%d\n%d\n", i, (dp[1][i][0]+dp[1][i][1]+dp[1][i][2])%q);
			return 0;
		}
	}
	return 0;
}
```