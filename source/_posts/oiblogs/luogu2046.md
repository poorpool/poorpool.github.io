---
title: luogu2046 [NOI2010]海拔
date: 2018-07-05 08:57:15
tags: 
  - 图论——网络流
  - 图论——最短次短K短路
categories:
  - OI
  - 图论
---
平面图转最短路。

<!--more-->

大力猜性质：

每个点是 $0$ 或 $1$。

$0$ 连片，$1$ 连片。

发现这两个性质后脑补一下，答案就是最小割。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
#include <queue>
using namespace std;
typedef long long ll;
int n, hea[250005], cnt, uu, ss, tt, k;
ll dis[250005];
bool vis[250005];
struct Edge{
	int too, nxt, val;
}edge[1002005];
struct Node{
	int idx;
	ll dis;
}nd[1252005];
bool cmp(Node a, Node b){
	return a.dis>b.dis;
}
void add_edge(int fro, int too, int val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
int main(){
	cin>>n;
	ss = n * n + 1; tt = ss + 1;
	for(int i=0; i<=n; i++)
		for(int j=1; j<=n; j++){
			scanf("%d", &uu);
			if(i==0)	add_edge(j, tt, uu);
			else if(i==n)	add_edge(ss, (i-1)*n+j, uu);
			else	add_edge(i*n+j, (i-1)*n+j, uu);
		}
	for(int i=1; i<=n; i++)
		for(int j=0; j<=n; j++){
			scanf("%d", &uu);
			if(j==0)	add_edge(ss, (i-1)*n+j+1, uu);
			else if(j==n)	add_edge((i-1)*n+j, tt, uu);
			else	add_edge((i-1)*n+j, (i-1)*n+j+1, uu);
		}
	for(int i=0; i<=n; i++)
		for(int j=1; j<=n; j++){
			scanf("%d", &uu);
			if(i==0)	add_edge(tt, j, uu);
			else if(i==n)	add_edge((i-1)*n+j, ss, uu);
			else	add_edge((i-1)*n+j, i*n+j, uu);
		}
	for(int i=1; i<=n; i++)
		for(int j=0; j<=n; j++){
			scanf("%d", &uu);
			if(j==0)	add_edge((i-1)*n+j+1, ss, uu);
			else if(j==n)	add_edge(tt, (i-1)*n+j, uu);
			else	add_edge((i-1)*n+j+1, (i-1)*n+j, uu);
		}
	memset(dis, 0x3f, sizeof(dis));
	dis[ss] = 0;
	nd[++k] = (Node){ss, 0};
	while(k){
		Node x=nd[1];
		pop_heap(nd+1, nd+1+k, cmp);
		k--;
		if(vis[x.idx])	continue;
		vis[x.idx] = true;
		for(int i=hea[x.idx]; i; i=edge[i].nxt){
			int t=edge[i].too;
			if(!vis[t] && dis[t]>dis[x.idx]+edge[i].val){
				dis[t] = dis[x.idx] + edge[i].val;
				nd[++k] = (Node){t, dis[t]};
				push_heap(nd+1, nd+1+k, cmp);
			}
		}
	}
	cout<<dis[tt]<<endl;
	return 0;
}
```