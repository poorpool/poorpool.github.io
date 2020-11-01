---
title: luogu2081 [NOI2012]迷失游乐园
date: 2018-07-02 20:44:43
categories:
  - OI
  - 图论
tags:
  - 图论——基环树
  - 动态规划——树形dp
---
[ref](https://www.cnblogs.com/qt666/p/7252284.html)

<!--more-->

涨姿势……

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
int n, m, uu, vv, ww, son[100005], fa[100005], dis[100005], hea[100005], cnt, fat[100005], idx;
int dfn[100005], b[100005], len, cir[100005];
bool vis[100005];
double fd[100005], fu[100005], ans;
struct Edge{
	int too, nxt, val;
}edge[200005];
void add_edge(int fro, int too, int val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
void dfsDown(int x){
	vis[x] = true;
	int tot=0;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t]){
			dis[t] = edge[i].val;
			tot++;
			dfsDown(t);
			fd[x] += fd[t] + edge[i].val;
		}
	}
	if(tot)	fd[x] /= tot;
	son[x] = tot;
	vis[x] = false;
}
void dfsUp(int x, int f){
	vis[x] = true;
	if(f)	fa[x] = 1;
	if(f && (son[f]-1+fa[f]>0))
		fu[x] += (fu[f]*fa[f]+son[f]*fd[f]-fd[x]-dis[x]) / (son[f]-1+fa[f]);
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t]){
			fu[t] += edge[i].val;
			dfsUp(t, x);
		}
	}
}
void work(int u, int v){
	for(; v!=fat[u]; v=fat[v]){
		cir[++len] = v;
		b[len+1] = dis[v];
		vis[v] = 1;
		fa[v] = 2;
	}
}
void dfs3(int x, int f){
	fat[x] = f;
	dfn[x] = ++idx;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!dfn[t]){
			dis[t] = edge[i].val;
			dfs3(t, x);
		}
		else if(dfn[t]>dfn[x]){
			b[1] = edge[i].val;
			work(x, t);
		}
	}
}
void work4(int x, int j, int s){
	double g=0.5, d=0.0;
	for(int i=1; i<len; i++){
		if(s==-1)	d += b[j];
		j += s;
		if(!j)	j = len;
		if(j>len)	j = 1;
		if(s==1)	d += b[j];
		if(i==len-1)	fu[x] += g * (fd[cir[j]] + d);
		else	fu[x] += g * (fd[cir[j]] + d) * son[cir[j]] / (son[cir[j]] + 1);
		g /= son[cir[j]] + 1;
	}
}
void workCircle(){
	dfs3(1, 0);
	for(int i=1; i<=len; i++){
		dfsDown(cir[i]);
		vis[cir[i]] = true;
	}
	for(int i=1; i<=len; i++){
		work4(cir[i], i, 1);
		work4(cir[i], i, -1);
	}
	for(int i=1; i<=len; i++)
		dfsUp(cir[i], 0);
}
int main(){
	cin>>n>>m;
	for(int i=1; i<=m; i++){
		scanf("%d %d %d", &uu, &vv, &ww);
		add_edge(uu, vv, ww);
		add_edge(vv, uu, ww);
	}
	if(m<n){
		dfsDown(1);
		dfsUp(1, 0);
	}
	else	workCircle();
	for(int i=1; i<=n; i++)
		ans += (son[i]*fd[i]+fu[i]*fa[i]) / (son[i] + fa[i]);
	printf("%.5f\n", ans/n);
	return 0;
}
```