---
title: luogu4103 [HEOI2014]大工程 
date: 2018-06-13 21:26:21
categories:
  - OI
  - 数据结构
tags:
  - 数据结构——虚树
  - 动态规划——树形dp
---
先建虚树，然后树形 dp 一下就好了。转移看代码吧。

<!--more-->

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, uu, vv, dfn[1000005], idx, dep[1000005], fa[1000005][21], q;
int par[1000005], sta[1000005], din, k, wht[1000005], ansn, ansx;
int mnn[1000005], mxx[1000005], siz[1000005], vr;
const int oo=0x3f3f3f3f;
ll dp[1000005];
bool isv[1000005];
void rn(int &x){
	x = 0;
	char ch=getchar();
	while(ch<'0' || ch>'9')	ch = getchar();
	while(ch>='0' && ch<='9'){
		x = x * 10 + ch - '0';
		ch = getchar();
	}
}
struct Graph{
	int hea[1000005], cnt;
	struct Edge{
		int too, nxt;
	}edge[2000005];
	void add_edge(int fro, int too){
		edge[++cnt].nxt = hea[fro];
		edge[cnt].too = too;
		hea[fro] = cnt;
	}
	void dfs1(int x, int f){
		dep[x] = dep[f] + 1;
		dfn[x] = ++idx;
		fa[x][0] = f;
		for(int i=1; i<=19; i++)
			fa[x][i] = fa[fa[x][i-1]][i-1];
		for(int i=hea[x]; i; i=edge[i].nxt){
			int t=edge[i].too;
			if(t!=f)	dfs1(t, x);
		}
	}
	void dfs2(int x, int f){
		siz[x] = isv[x]; mnn[x] = oo; mxx[x] = dp[x] = 0;
		for(int i=hea[x]; i; i=edge[i].nxt){
			int t=edge[i].too, d=dep[t]-dep[x];
			if(t!=f){
				dfs2(t, x);
				siz[x] += siz[t];
				ansn = min(ansn, mnn[x]+mnn[t]+d);
				mnn[x] = min(mnn[x], mnn[t]+d);
				ansx = max(ansx, mxx[x]+mxx[t]+d);
				mxx[x] = max(mxx[x], mxx[t]+d);
				dp[x] += dp[t] + (ll)d * (k - siz[t]) * siz[t];
			}
		}
		if(isv[x]){
			ansn = min(ansn, mnn[x]);
			ansx = max(ansx, mxx[x]);
			mnn[x] = 0;
		}
		hea[x] = 0;
	}
}ga, gb;
bool cmp(int x, int y){
	return dfn[x]<dfn[y];
}
int getLca(int x, int y){
	if(dep[x]<dep[y])	swap(x, y);
	for(int i=19; i>=0; i--)
		if(dep[fa[x][i]]>=dep[y])
			x = fa[x][i];
	if(x==y)	return x;
	for(int i=19; i>=0; i--)
		if(fa[x][i]!=fa[y][i]){
			x = fa[x][i];
			y = fa[y][i];
		}
	return fa[x][0];
}
void build(){
    din = 0; vr = k;
    sort(wht+1, wht+1+k, cmp);
    for(int i=1; i<=k; i++){
        int x=wht[i];
        if(!din){
            par[x] = 0;
            sta[++din] = x;
        }
        else{
            int lca=getLca(sta[din], x);
            while(dep[sta[din]]>dep[lca]){
                if(dep[sta[din-1]]<dep[lca])    par[sta[din]] = lca;
                din--;
            }
            if(lca!=sta[din]){
                par[lca] = sta[din];
                sta[++din] = lca;
				wht[++vr] = lca;
            }
            par[x] = lca; sta[++din] = x;
        }
    }
	for(int i=1; i<=vr; i++)
		gb.add_edge(par[wht[i]], wht[i]);
}
void solve(){
	build();
	ansx = 0; ansn = oo;
	gb.dfs2(sta[1], 0);
	printf("%lld %d %d\n", dp[sta[1]], ansn, ansx);
}
int main(){
	cin>>n;
	for(int i=1; i<n; i++){
		rn(uu); rn(vv);
		ga.add_edge(uu, vv);
		ga.add_edge(vv, uu);
	}
	ga.dfs1(1, 0);
	cin>>q;
	while(q--){
		rn(k);
		for(int i=1; i<=k; i++){
			rn(wht[i]);
			isv[wht[i]] = true;
		}
		solve();
		for(int i=1; i<=k; i++)
			isv[wht[i]] = false;
		gb.cnt = 0;
	}
	return 0;
}
```
