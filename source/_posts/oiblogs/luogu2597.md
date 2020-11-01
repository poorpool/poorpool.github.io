---
title: luogu2597 [ZJOI2012]灾难
date: 2018-06-10 10:52:33
tags: 
  - 图论——拓扑排序
  - 图论——LCA
categories:
  - OI
  - 图论
---
先拓扑排序一下，然后按照拓扑序构建“灭绝树”，就是说一个结点，他的所有食物来源在灭绝树中的 lca 就是这个结点在灭绝树中的父亲。

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
#include <vector>
#include <queue>
using namespace std;
int n, uu, fa[65545][17], sta[65545], din, dep[65545], siz[65545];
int ru[65545];
queue<int> d;
struct Graph{
	vector<int> v[65545];
	void add_edge(int fro, int too){
		v[fro].push_back(too);
	}
}ga, gb;
int lca(int x, int y){
	if(dep[x]<dep[y])	swap(x, y);
	for(int i=15; i>=0; i--)
		if(dep[fa[x][i]]>=dep[y])
			x = fa[x][i];
	if(x==y)	return x;
	for(int i=15; i>=0; i--)
		if(fa[x][i]!=fa[y][i]){
			x = fa[x][i];
			y = fa[y][i];
		}
	return fa[x][0];
}
int main(){
	cin>>n;
	for(int i=1; i<=n; i++){
		while(scanf("%d", &uu)!=EOF){
			if(!uu)	break;
			ga.add_edge(i, uu);
			gb.add_edge(uu, i);
			ru[i]++;
		}
		if(!ru[i])	d.push(i);
	}
	while(!d.empty()){
		int x=d.front();
		d.pop();
		sta[++din] = x;
		for(int i=0; i<gb.v[x].size(); i++){
			int t=gb.v[x][i];
			ru[t]--;
			if(!ru[t])	d.push(t);
		}
	}
	for(int i=1; i<=n; i++){
		int x=sta[i], l;
		if(ga.v[x].size())	l = ga.v[x][0];
		else	l = 0;
		for(int j=1;  j<ga.v[x].size(); j++)
			l = lca(l, ga.v[x][j]);
		fa[x][0] = l;
		dep[x] = dep[l] + 1;
		for(int j=1; j<=15; j++)
			fa[x][j] = fa[fa[x][j-1]][j-1];
	}
	for(int i=n; i; i--){
		int x=sta[i];
		siz[x]++;
		siz[fa[x][0]] += siz[x];
	}
	for(int i=1; i<=n; i++)
		printf("%d\n", siz[i]-1);
	return 0;
}
```
