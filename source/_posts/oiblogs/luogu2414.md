---
title: luogu2414 [NOI2011]阿狸的打字机
date: 2018-07-04 20:50:12
tags: 字符串——AC自动机
categories:
  - OI
  - 字符串
---
[orz](https://blog.csdn.net/huzecong/article/details/7769988)

<!--more-->

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
#include <queue>
using namespace std;
int n, uu, vv, preq[100005], fstq[100005], sonq[100005], pos[100005], id, m, ans[100005];
char ss[100005];
queue<int> d;
struct AC{
	int tot, ch[100005][26], fa[100005], fai[100005], hea[100005], cnt, dfn[100005], nfd[100005];
	int idx, c[100005];
	struct Edge{
		int too, nxt;
	}edge[200005];
	int lb(int x){
		return x & -x;
	}
	void add(int x, int v){
		for(; x<=idx; x+=lb(x))
			c[x] += v;
	}
	int query(int x){
		int re=0;
		for(; x; x-=lb(x))
			re += c[x];
		return re;
	}
	void add_edge(int fro, int too){
		edge[++cnt].nxt = hea[fro];
		edge[cnt].too = too;
		hea[fro] = cnt;
	}
	void build(){
		int u=0;
		for(int i=1; i<=n; i++){
			if(ss[i]=='B')
				u = fa[u];
			else if(ss[i]=='P')
				pos[++id] = u;
			else{
				int c=ss[i]-'a';
				if(!ch[u][c]){
					ch[u][c] = ++tot;
					fa[ch[u][c]] = u;
				}
				u = ch[u][c];
			}
		}
	}
	void getFail(){
		for(int i=0; i<26; i++)
			if(ch[0][i])
				d.push(ch[0][i]);
		while(!d.empty()){
			int x=d.front();
			d.pop();
			for(int i=0; i<26; i++){
				if(ch[x][i]){
					fai[ch[x][i]] = ch[fai[x]][i];
					d.push(ch[x][i]);
				}
				else	ch[x][i] = ch[fai[x]][i];
			}
		}
	}
	void buildTree(){
		for(int i=1; i<=tot; i++)
			add_edge(fai[i], i);
	}
	void dfs(int x){
		dfn[x] = ++idx;
		for(int i=hea[x]; i; i=edge[i].nxt)
			dfs(edge[i].too);
		nfd[x] = idx;
	}
	void work(){
		int u=0;
		id = 0;
		for(int i=1; i<=n; i++){
			if(ss[i]=='B'){
				add(dfn[u], -1);
				u = fa[u];
			}
			else if(ss[i]=='P'){
				id++;
				for(int y=fstq[id]; y; y=preq[y]){
					int t=pos[sonq[y]];
					ans[y] = query(nfd[t]) - query(dfn[t]-1);
				}
			}
			else{
				u = ch[u][ss[i]-'a'];
				add(dfn[u], 1);
			}
		}
	}
}ac;
int main(){
	scanf("%s", ss+1);
	n = strlen(ss+1);
	cin>>m;
	for(int i=1; i<=m; i++){
		scanf("%d %d", &uu, &vv);
		preq[i] = fstq[vv];
		fstq[vv] = i;
		sonq[i] = uu;
	}
	ac.build();
	ac.getFail();
	ac.buildTree();
	ac.dfs(0);
	ac.work();
	for(int i=1; i<=m; i++)
		printf("%d\n", ans[i]);
	return 0;
}
```