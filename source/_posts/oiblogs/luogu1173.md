---
title: luogu1173 [NOI2016]网格
date: 2018-06-20 20:38:30
categories:
  - OI
  - 图论
tags:
  - 思维
  - 图论——割点与桥
---
真鬼畜啊这蛐蛐题……

<!--more-->

容易观察到答案就是 $[-1,2]$ 之间。

$-1$：跳蚤数 $<1$ 或**两个**跳蚤四联通。

$0$：跳蚤不连通。

$1$：把四联通跳蚤连边，存在割点。

$2$：其余情况。

-----

然而跳蚤太多了，想办法忽略一些。我们选择将每个蛐蛐为中心的 $5 \times 5$ 的方格拉出来连边。

这样图也许不连通，但是跳蚤是联通的。如果跳蚤不连通，那么这些跳蚤必定是围在一团蛐蛐身边的。dfs 蛐蛐团然后判跳蚤是否分属不同的联通块。这样是 $0$ 的判定。

然后存在割点就成了在联通块内是否存在割点。

建议不要看代码自己脑补。

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
#include <vector>
using namespace std;
typedef long long ll;
int n, m, c, T, uu[100005], vv[100005], tot, sta[2500005], din;
ll num[2500005];
const int dx[]={0, 1, 0, -1, 0};
const int dy[]={0, 0, -1, 0, 1};
ll f(int x, int y){
	return (ll)(x-1)*m+y;
}
struct HashTable{
	int cnt, mod, hea[1635955];
	struct Edge{
		ll x;
		int y, nxt;
	}edge[2500005];
	void init(){
		mod = 1635947;
		memset(hea, 0, sizeof(hea));
		cnt = 0;
	}
	void add(ll x, int y){
		int p=x%mod;
		for(int i=hea[p]; i; i=edge[i].nxt)
			if(edge[i].x==x){
				edge[i].y = y;
				return ;
			}
		edge[++cnt].x = x; edge[cnt].y = y; edge[cnt].nxt = hea[p];
		hea[p] = cnt;
	}
	int getV(ll x){
		int p=x%mod;
		for(int i=hea[p]; i; i=edge[i].nxt)
			if(edge[i].x==x)
				return edge[i].y;
		return 0;
	}
}hst;
struct Graph{
	int hea[2500005], cnt, dfn[2500005], loo[2500005], idx, scc, bel[2500005];
	vector<int> gee;
	struct Edge{
		int too, nxt;
	}edge[10000005];
	void init(){
		cnt = idx = scc = 0;
		gee.clear();
		for(int i=1; i<=25*c; i++)
			hea[i] = dfn[i] = 0;
	}
	void add_edge(int fro, int too){
		edge[++cnt].nxt = hea[fro];
		edge[cnt].too = too;
		hea[fro] = cnt;
	}
	void tarjan(int x, int f){
		bel[x] = scc;
		dfn[x] = loo[x] = ++idx;
		int cd=0;
		for(int i=hea[x]; i; i=edge[i].nxt){
			int t=edge[i].too;
			if(!dfn[t]){
				cd++;
				tarjan(t, x);
				loo[x] = min(loo[x], loo[t]);
				if(f && loo[t]>=dfn[x])	gee.push_back(x);
			}
			else	loo[x] = min(loo[x], dfn[t]);
		}
		if(!f && cd>=2)	gee.push_back(x);
	}
	void dfs(int a, int b){
		hst.add(f(a,b), 2);
		for(int i=1; i<=4; i++){
			int e=a+dx[i], g=b+dy[i];
			if(e<1 || e>n || g<1 || g>m)	continue;
			int t=hst.getV(f(e,g));
			if(t==3){
				sta[++din] = lower_bound(num+1, num+1+tot, f(e,g))-num;
				hst.add(f(e,g), 4);
			}
			else if(t==1)	dfs(e, g);
		}
	}
}G;
bool chkFuYi(){
	if((ll)n*m-c<=1)	return true;
	if((ll)n*m-c>2)	return false;
	for(int i=1; i<=n; i++)
		for(int j=1; j<=m; j++){
			if(hst.getV(f(i,j))!=1){
				for(int k=1; k<=4; k++){
					int a=i+dx[k], b=j+dy[k];
					if(a<1 || a>n || b<1 || b>m)	continue;
					if(hst.getV(f(a,b))!=1)	return true;
				}
			}
		}
		return false;
}
int main(){
	cin>>T;
	while(T--){
		scanf("%d %d %d", &n, &m, &c);
		tot = 0;
		hst.init();
		G.init();
		for(int i=1; i<=c; i++){
			scanf("%d %d", &uu[i], &vv[i]);
			hst.add(f(uu[i],vv[i]), 1);
		}
		if(chkFuYi()){
			printf("-1\n");
			continue;
		}
		for(int i=1; i<=c; i++)
			for(int j=-2; j<=2; j++)
				for(int k=-2; k<=2; k++){
					int a=uu[i]+j, b=vv[i]+k;
					if(a<1 || a>n || b<1 || b>m)	continue;
					if(hst.getV(f(a, b))>=1)	continue;
					hst.add(f(a,b), 3);
					num[++tot] = f(a,b);
				}
		sort(num+1, num+1+tot);
		tot = unique(num+1, num+1+tot) - num - 1;
		for(int i=1; i<=tot; i++){
			int a=(num[i]-1)/m+1, b=(num[i]-1)%m+1;
			for(int j=1; j<=4; j++){
				int e=a+dx[j], g=b+dy[j];
				if(e<1 || e>n || g<1 || g>m)	continue;
				if(hst.getV(f(e,g))!=3)	continue;
				G.add_edge(i, lower_bound(num+1, num+1+tot, f(e,g))-num);
			}
		}
		for(int i=1; i<=tot; i++)
			if(!G.dfn[i]){
				G.scc++;
				G.tarjan(i, 0);
			}
		bool flag=false;
		for(int i=1; i<=c; i++){
			din = 0;
			if(hst.getV(f(uu[i],vv[i]))!=2)
				G.dfs(uu[i], vv[i]);
			for(int j=1; j<=din; j++)
				if(G.bel[sta[1]]!=G.bel[sta[j]])
					flag = true;
			for(int j=1; j<=din; j++){
				ll x=num[sta[j]];
				hst.add(x, 3);
			}
			if(flag)	break;
		}
		for(int i=1; i<=c; i++)
			hst.add(f(uu[i],vv[i]),1);
		if(flag){
			printf("0\n");
			continue;
		}
		if(n==1 || m==1){
			printf("1\n");
			continue;
		}
		for(int i=0; i<G.gee.size(); i++){
			ll x=num[G.gee[i]];
			int a=(x-1)/m+1, b=(x-1)%m+1;
			for(int j=-1; j<=1; j++){
				for(int k=-1; k<=1; k++){
					int e=a+j, g=b+k;
					if(e<1 || e>n || g<1 || g>m)	continue;
					if(hst.getV(f(e,g))==1){
						flag = true;
						break;
					}
				}
			}
		}
		if(flag)	printf("1\n");
		else	printf("2\n");
	}
	return 0;
}
```