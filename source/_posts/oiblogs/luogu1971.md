---
title: luogu1971 [NOI2011]兔兔与蛋蛋游戏
date: 2018-07-04 18:09:25
tags:
  - 图论——二分图
  - 数学——博弈论
categories:
  - OI
  - 图论
---
[ref1](https://blog.csdn.net/xym_csdn/article/details/52597140) and [ref2](https://blog.csdn.net/outer_form/article/details/51893048)

<!--more-->

判定一个点是不是在增广路上的姿势……

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
#include <queue>
using namespace std;
int n, m, k, num[45][45], sx, sy, hea[1605], cnt, mat[1605], qwq[1605], qaq;
const int dx[]={0, 1, 0, -1, 0};
const int dy[]={0, 0, 1, 0, -1};
char ss[45];
bool vis[1605], ban[1605];
queue<int> d;
struct Edge{
	int too, nxt, val;
}edge[10005];
void add_edge(int fro, int too){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	hea[fro] = cnt;
}
int f(int a, int b){
	return (a-1)*m+b;
}
int dfs(int x){
	if(ban[x])	return false;
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(!vis[t] && !ban[t]){
			vis[t] = true;
			if(!mat[t] || dfs(mat[t])){
				mat[t] = x;
				mat[x] = t;
				return 1;
			}
		}
	}
	return 0;
}
int main(){
	cin>>n>>m;
	for(int i=1; i<=n; i++){
		scanf("%s", ss+1);
		for(int j=1; j<=m; j++){
			if(ss[j]=='O')	num[i][j] = 1;
			else	num[i][j] = 2;
			if(ss[j]=='.'){
				sx = i;
				sy = j;
			}
		}
	}
	d.push(f(sx,sy));
	while(!d.empty()){
		int x=d.front();
		d.pop();
		int tx=(x-1)/m+1;
		int ty=(x-1)%m+1;
		for(int i=1; i<=4; i++){
			int kx=tx+dx[i];
			int ky=ty+dy[i];
			if(kx<1 || kx>n || ky<1 || ky>m)	continue;
			if(num[tx][ty]+num[kx][ky]!=3)	continue;
			int t=f(kx,ky);
			add_edge(x, t);
			if(!vis[t]){
				vis[t] = true;
				d.push(t);
			}
		}
	}
	for(int i=1; i<=n*m; i++)
		if(!mat[i]){
			memset(vis, 0, sizeof(vis));
			dfs(i);
		}
	cin>>k;
	for(int i=1; i<=k; i++){
		bool f1=false, f2=false;
		int x=f(sx, sy);
		ban[x] = true;
		if(mat[x]){
			int t=mat[x];
			mat[x] = mat[t] = 0;
			memset(vis, 0, sizeof(vis));
			f1 = !dfs(t);
		}
		else	f1 = false;
		scanf("%d %d", &sx, &sy);
		x = f(sx, sy);
		ban[x] = true;
		if(mat[x]){
			int t=mat[x];
			mat[x] = mat[t] = 0;
			memset(vis, 0, sizeof(vis));
			f2 = !dfs(t);
		}
		else	f2 = false;
		scanf("%d %d", &sx, &sy);
		if(f1 && f2)	qwq[++qaq] = i;
	}
	printf("%d\n", qaq);
	for(int i=1; i<=qaq; i++)
		printf("%d\n", qwq[i]);
	return 0;
}
```