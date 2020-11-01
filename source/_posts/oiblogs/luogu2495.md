---
title: 虚树讲解和 luogu2495 [SDOI2011]消耗战
date: 2018-06-13 19:41:54
categories:
  - OI
  - 数据结构
tags: 
  - 数据结构——虚树
  - 动态规划——树形dp
---
虚树挺劲爆的，得学一学……

<!--more-->

-----

例题 luogu2495 [SDOI2011]消耗战。

如果只有一次询问就是个傻叉树形 dp：记 $dp_i$ 是斩断 $i$ 子树中所有关键点的最小费用（不能直接斩断 $i$ 和他父亲的道路），那么枚举当前结点 $u$ 的儿子 $v$，要是 $v$ 是关键点那 $dp_u$ 就要加上 $minval_v$（从 $u$ 到 $v$ 的道路的权值的最小值），否则就加上 $\min(minval_v, dp_v)$。

然而如果是多组呢？……观察到 $k$ 的和是十万级别，而且，那些非关键点好像不是太重要，似乎可以压缩一下？或者说，我们能不能找到一种单组复杂度跟 $k$ 有关，而不是 $n$ 有关的算法？

于是就有了虚树这种东西。

-----

现在，我们只想把关键点和他们的 lca（为了压缩路径）提取出来。可是这 $k$ 个关键点两两组成 lca 会有多少个呢？会不会很多啊？不会的。最多 $k-1$ 个。

而且，这些 lca 就是把关键点按 dfs 序排序后依次计算两个相邻的点的 lca。（证明？大致思想若三个点有三个 lca，那么就会存在一个点有两个父亲~~两姓家奴~~）

我们考虑按照 dfs 序依次加入结点和 lca。我们用一个栈表示“在虚树已经构造好的情况下，从根到最后加入的那个结点所构成的链”，栈顶是最后加入的结点，记为 $p$。另外，我们在构建虚树的时候只记录父亲。如果你有加边的需要构建完了再加。

好了。现在我们要加一个新结点 $x$ 了。他和 $p$ 的 lca 必定在那条链上（即使 lca 可能不在栈中）。我们先考虑一下要不要加 lca。对于 $p$ 和栈顶的上一个结点 $q$，如果 $q$ 比 lca 深或者就是 lca，那么 $p$ 的父亲就还是 $q$，并且把 $p$ 弹掉；否则说明 $p,q$ 中间卡了个 lca没加进去，$p$ 的父亲改为 $lca$，并且把 $p$ 弹掉。

然后如果栈顶不是 lca 的话就把 lca 入栈。然后把  $x$ 入栈。这样我们成功地加入了一个新结点，维护了虚树和栈。虚树便构造完毕了。

然后就是在虚树上跑 dp 了。注意清零的技巧哦。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, m, uu, vv, ww, hea[250005], cnt, dfn[250005], fa[250005][19];
int mn[250005][19], idx, vr, ki, wht[250005], nxg[250005], din;
int sta[250005], par[250005], dep[250005], qwq[250005];
ll dp[250005];
bool isw[250005];
const int oo=0x3f3f3f3f;
struct Edge{
	int too, nxt, val;
}edge[500005];
void add_edge(int fro, int too, int val){
	edge[++cnt].nxt = hea[fro];
	edge[cnt].too = too;
	edge[cnt].val = val;
	hea[fro] = cnt;
}
void dfs(int x, int f){
	dfn[x] = ++idx;
	fa[x][0] = f;
	dep[x] = dep[f] + 1;
	for(int i=1; i<=17; i++){
		fa[x][i] = fa[fa[x][i-1]][i-1];
		mn[x][i] = min(mn[x][i-1], mn[fa[x][i-1]][i-1]);
	}
	for(int i=hea[x]; i; i=edge[i].nxt){
		int t=edge[i].too;
		if(t!=f){
			mn[t][0] = edge[i].val;
			dfs(t, x);
		}
	}
}
bool cmp(int x, int y){
	return dfn[x]<dfn[y];
}
int getLca(int x, int y){
	if(dep[x]<dep[y])	swap(x, y);
	for(int i=17; i>=0; i--)
		if(dep[fa[x][i]]>=dep[y])
			x = fa[x][i];
	if(x==y)	return x;
	for(int i=17; i>=0; i--)
		if(fa[x][i]!=fa[y][i]){
			x = fa[x][i];
			y = fa[y][i];
		}
	return fa[x][0];
}
int getMin(int x, int y){
	int re=oo;
	for(int i=17; i>=0; i--)
		if(dep[fa[x][i]]>=dep[y]){
			re = min(re, mn[x][i]);
			x = fa[x][i];
		}
	return re;
}
void build(){
	din = 0;
	sort(wht+1, wht+1+vr, cmp);
	int tmp=vr;
	for(int i=1; i<=tmp; i++){
		int x=wht[i];
		if(!din){
			par[x] = 0;
			sta[++din] = x;
		}
		else{
			int lca=getLca(sta[din], x);
			while(dep[sta[din]]>dep[lca]){
				if(dep[sta[din-1]]<dep[lca])	par[sta[din]] = lca;
				din--;
			}
			if(lca!=sta[din]){
				wht[++vr] = lca;
				par[lca] = sta[din];
				sta[++din] = lca;
			}
			par[x] = lca; sta[++din] = x;
		}
	}
	sort(wht+1, wht+1+vr, cmp);
}
ll solve(){
	build();
	for(int i=2; i<=vr; i++)
		qwq[wht[i]] = getMin(wht[i], par[wht[i]]);
	for(int i=1; i<=vr; i++)
		dp[wht[i]] = 0;
	for(int i=vr; i>=2; i--){
		int x=wht[i];
		if(isw[x])	dp[par[x]] += qwq[x];
		else	dp[par[x]] += min((ll)qwq[x], dp[x]);
	}
	return dp[1];
}
int main(){
	cin>>n;
	for(int i=1; i<n; i++){
		scanf("%d %d %d", &uu, &vv, &ww);
		add_edge(uu, vv, ww);
		add_edge(vv, uu, ww);
	}
	dfs(1, 0);
	cin>>m;
	while(m--){
		vr = 0;
		scanf("%d", &ki);
		wht[++vr] = 1;
		for(int i=1; i<=ki; i++){
			scanf("%d", &nxg[i]);
			wht[++vr] = nxg[i];
			isw[nxg[i]] = true;
		}
		printf("%lld\n", solve());
		for(int i=1; i<=ki; i++)
			isw[nxg[i]] = false;
	}
	return 0;
}
```