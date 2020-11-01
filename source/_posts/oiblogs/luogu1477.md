---
title: luogu1477 [NOI2008]假面舞会
date: 2018-07-09 16:54:53
tags: 思维
categories:
  - OI
  - 思维
---
[ref](https://blog.csdn.net/sunshinezff/article/details/48628401) and [ref](https://blog.csdn.net/wxh010910/article/details/53087571)

<!--more-->

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
int n, m, uu, vv, hea[100005], cnt, dis[100005], ans, mnn, mxx;
bool vis[100005], siv[2000005];
struct Edge{
	int too, nxt, val;
}edge[2000005];
void add_edge(int fro, int too, int val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
int gcd(int a, int b){
	return !b?a:gcd(b,a%b);
}
int q(int x){
	return x>=0?x:-x;
}
void dfs(int x){
	vis[x] = true;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t]){
			dis[t] = dis[x] + edge[i].val;
			dfs(t);
		}
		else	ans = gcd(ans, q(dis[x]+edge[i].val-dis[t]));
	}
}
void sfd(int x){
	vis[x] = true;
	mnn = min(mnn, dis[x]);
	mxx = max(mxx, dis[x]);
	for(int i=hea[x]; i; i=edge[i].nxt)
		if(!siv[i]){
			int t=edge[i].too;
			siv[((i-1)^1)+1] = siv[i] = true;
			dis[t] = dis[x] + edge[i].val;
			sfd(t);
		}
}
int main(){
	cin>>n>>m;
	for(int i=1; i<=m; i++){
		scanf("%d %d", &uu, &vv);
		add_edge(uu, vv, 1);
		add_edge(vv, uu, -1);
	}
	for(int i=1; i<=n; i++)
		if(!vis[i])
			dfs(i);
	if(ans){
		for(int i=3; i<=ans; i++)
			if(ans%i==0){
				printf("%d %d\n", ans, i);
				return 0;
			}
		printf("-1 -1\n");
		return 0;
	}
	memset(vis, 0, sizeof(vis));
	for(int i=1; i<=n; i++)
		if(!vis[i]){
			mnn = mxx = dis[i] = 0;
			sfd(i);
			ans += mxx - mnn + 1;
		}
	if(ans<3)	printf("-1 -1\n");
	else	printf("%d 3\n", ans);
	return 0;
}
```