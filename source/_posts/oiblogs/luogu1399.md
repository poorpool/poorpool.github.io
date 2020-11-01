---
title: luogu1399 [NOI2013]快餐店
date: 2018-06-27 10:25:45
categories:
  - OI
  - 图论
tags: 图论——基环树
---
[ref](https://www.cnblogs.com/lcf-2000/p/6407519.html) 搞不懂啊……就学了个基环树找环

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, uu, vv, ww, hea[100005], cnt, fa[100005], dfn[100005], idx, cir[100005], tot;
ll ans, f[100005], dis[100005], d[100005], qi[100005][2], ho[100005][2], pr[100005], su[100005];
bool vis[100005];
struct Edge{
	int too, nxt, val;
}edge[200005];
void add_edge(int fro, int too, int val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
void work(int a, int b){
	while(b!=fa[a]){
		cir[++tot] = b; vis[b] = true; b = fa[b];
		d[tot+1] = dis[cir[tot]] - dis[b];
	}
	for(int i=1; i<=tot; i++)	d[i] += d[i-1];
}
void dfsCir(int x, int f){
	dfn[x] = ++idx;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(t!=f && !dfn[t]){
			dis[t] = dis[x] + edge[i].val;
			fa[t] = x;
			dfsCir(t, x);
		}
	}
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(fa[t]!=x && dfn[t]>dfn[x]){
			d[1] = edge[i].val;
			work(x, t);
		}
	}
}
void dp(int x){
	vis[x] = true;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t]){
			dp(t);
			ans = max(ans, f[x]+f[t]+edge[i].val);
			f[x] = max(f[t]+edge[i].val, f[x]);
		}
	}
}
void solve(){
	qi[0][0] = qi[0][1] = pr[0] = ho[tot+1][0] = ho[tot+1][1] = su[tot+1] = -1e18;
	for(int i=1; i<=tot; i++){
		int x=cir[i];
		qi[i][0] = max(qi[i-1][0], f[x]+d[i]-d[1]);
		qi[i][1] = max(qi[i-1][1], f[x]-d[i]+d[1]);
		pr[i] = max(pr[i-1], f[x]+d[i]-d[1]+qi[i-1][1]);
	}
	for(int i=tot; i; i--){
		int x=cir[i];
		ho[i][0] = max(ho[i+1][0], f[x]+d[tot]-d[i]);
		ho[i][1] = max(ho[i+1][1], f[x]-d[tot]+d[i]);
		su[i] = max(su[i+1], f[x]+d[tot]-d[i]+ho[i+1][1]);
	}
	ll qwq=pr[tot];
	for(int i=1; i<tot; i++){
		ll tmp=d[1]+qi[i][0]+ho[i+1][0];
		tmp = max(tmp, max(pr[i], su[i+1]));
		qwq = min(qwq, tmp);
	}
	ans = max(ans, qwq);
}
int main(){
	cin>>n;
	for(int i=1; i<=n; i++){
		scanf("%d %d %d", &uu, &vv, &ww);
		add_edge(uu, vv, ww);
		add_edge(vv, uu, ww);
	}
	dfsCir(1, 0);
	for(int i=1; i<=tot; i++)	dp(cir[i]);
	solve();
	printf("%.1f\n", ans/2.0);
	return 0;
}
```