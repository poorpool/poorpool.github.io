---
title: luogu2305 [NOI2014]购票 
date: 2018-06-25 20:51:54
categories:
  - OI
  - 动态规划
tags:
  - 动态规划——斜率优化
  - 图论——点分治
---
[ref](https://blog.csdn.net/litble/article/details/80632055)

<!--more-->

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, fa[200005], hea[200005], cnt, siz[200005], rnd[200005], rot, qwq, qaq[200005];
int din, sta[200005];
ll uu, p[200005], q[200005], l[200005], dis[200005], f[200005];
double sl[200005];
bool vis[200005];
struct Edge{
	int too, nxt;
	ll val;
}edge[200005];
void add_edge(int fro, int too, ll val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
void getDis(int x){
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		dis[t] = dis[x] + edge[i].val;
		getDis(t);
	}
}
void dfs(int x){
	qaq[++qwq] = x;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t])	dfs(t);
	}
}
bool cmp(int x, int y){
	return dis[x]-l[x]>dis[y]-l[y];
}
void getRoot(int x, int sz){
	rnd[x] = 0;
	siz[x] = 1;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t]){
			getRoot(t, sz);
			siz[x] += siz[t];
			rnd[x] = max(rnd[x], siz[t]);
		}
	}
	rnd[x] = max(rnd[x], sz-siz[x]);
	if(rnd[x]<=rnd[rot])	rot = x;
}
double getK(int a, int b){
	return (f[a]-f[b])/(double)(dis[a]-dis[b]);
}
void ins(int x){
	while(din>=2 && sl[din-1]<=getK(sta[din], x))	din--;
	sta[++din] = x; sl[din-1] = getK(sta[din-1], sta[din]); sl[din] = -1e18;
}
int query(int x){
	int l=1, r=din, mid, re;
	while(l<=r){
		mid = (l + r) >> 1;
		if(sl[mid]<=x)	re = mid, r = mid - 1;
		else	l = mid + 1;
	}
	return sta[re];
}
void work(int o, int sze){
	if(sze==1)	return ;
	rot = 0; rnd[0] = 0x3f3f3f3f;
	getRoot(o, sze);
	int x=rot;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		vis[t] = true;
		sze -= siz[t];
	}
	work(o, sze);
	qwq = 0;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		dfs(t);
	}
	sort(qaq+1, qaq+1+qwq, cmp);
	din = 0;
	int j=x;
	for(int i=1; i<=qwq; i++){
		while(j!=fa[o] && dis[j]>=dis[qaq[i]]-l[qaq[i]]){
			ins(j);
			j = fa[j];
		}
		if(din){
			int k=query(p[qaq[i]]);
			f[qaq[i]] = min(f[qaq[i]], f[k]+(dis[qaq[i]]-dis[k])*p[qaq[i]]+q[qaq[i]]);
		}
	}
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		work(t, siz[t]);
	}
}
int main(){
	cin>>n>>uu;
	for(int i=2; i<=n; i++){
		scanf("%d %lld %lld %lld %lld", &fa[i], &uu, &p[i], &q[i], &l[i]);
		add_edge(fa[i], i, uu);
	}
	getDis(1);
	rnd[0] = 0x3f3f3f3f;
	memset(f, 0x3f, sizeof(f));
	f[1] = 0;
	work(1, n);
	for(int i=2; i<=n; i++)
		printf("%lld\n", f[i]);
	return 0;
}
```