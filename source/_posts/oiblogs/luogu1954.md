---
title: luogu1954 [NOI2010]航空管制
date: 2018-07-05 10:39:51
tags: 图论——拓扑排序
categories:
  - OI
  - 图论
---
拓扑排序。

<!--more-->

正着做挺难的，反着来。

第一问很好做，就是普通的拓扑排序。

第二问。想一想，我们反着来，就是构建反图拓扑排序，填充发射序列的时候也是反着来的。那么我们在不使用当前点的情况下拓扑排序，要是实在拓扑不下去了就说明必须是这个点了，这也就是这个点出现的最早位置。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
typedef pair<int,int> par;
int n, m, uu, vv, a[2005], b[2005], inn[2005], c[2005], hea[2005], cnt, k, e[2005];
par d[2005];
struct Edge{
	int too, nxt;
}edge[10005];
bool cmp(par a, par b){
	return a.second<b.second;
}
void add_edge(int fro, int too){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	hea[fro] = cnt;
}
int f(int o){
	k = 0;
	for(int i=1; i<=n; i++){
		c[i] = inn[i];
		if(!inn[i] && i!=o){
			d[++k] = par(i, a[i]);
			push_heap(d+1, d+1+k, cmp);
		}
	}
	for(int i=n; i; i--){
		if(!k)	return i;
		par x=d[1];
		pop_heap(d+1, d+1+k, cmp);
		k--;
		if(x.second<i)	return i;
		for(int i=hea[x.first]; i; i=edge[i].nxt){
			int t=edge[i].too;
			c[t]--;
			if(!c[t] && t!=o){
				d[++k] = par(t, a[t]);
				push_heap(d+1, d+1+k, cmp);
			}
		}
	}
}
int main(){
	cin>>n>>m;
	for(int i=1; i<=n; i++)	scanf("%d", &a[i]);
	for(int i=1; i<=m; i++){
		scanf("%d %d", &uu, &vv);
		add_edge(vv, uu);
		inn[uu]++;
	}
	for(int i=1; i<=n; i++){
		c[i] = inn[i];
		if(!inn[i]){
			d[++k] = par(i, a[i]);
			push_heap(d+1, d+1+k, cmp);
		}
	}
	for(int i=n; i; i--){
		par x=d[1];
		pop_heap(d+1, d+1+k, cmp);
		k--;
		e[i] = x.first;
		for(int i=hea[x.first]; i; i=edge[i].nxt){
			int t=edge[i].too;
			c[t]--;
			if(!c[t]){
				d[++k] = par(t, a[t]);
				push_heap(d+1, d+1+k, cmp);
			}
		}
	}
	for(int i=1; i<=n; i++)	printf("%d ", e[i]);
	printf("\n");
	for(int i=1; i<=n; i++)	printf("%d ", f(i));
	printf("\n");
	return 0;
}
```