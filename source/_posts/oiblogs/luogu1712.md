---
title: luogu1712 [NOI2016]区间
date: 2018-06-21 20:11:24
categories:
  - OI
  - 数据结构
tags: 数据结构——线段树
---
先按照长度降序排序，然后一条条加入线段。当发现某个点被覆盖超过 $m$ 次后就开始不断统计答案并由长到短地删掉加了的线段（像是尺取法）直到没有超过 $m$ 次的。正确性显然。

<!--more-->

[ref](https://www.luogu.org/blog/user5680/solution-p1712)

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int n, m, num[1000005], tot;
struct Lines{
	int l, r;
	bool operator<(const Lines &u)const{
		return r-l>u.r-u.l;
	}
}l[500005];
struct SGT{
	int zdz[4000005], tag[4000005];
	void pushDown(int o, int lson, int rson){
		zdz[lson] += tag[o];
		zdz[rson] += tag[o];
		tag[lson] += tag[o];
		tag[rson] += tag[o];
		tag[o] = 0;
	}
	void update(int o, int l, int r, int x, int y, int v){
		if(l>=x && r<=y){
			zdz[o] += v;
			tag[o] += v;
		}
		else{
			int mid=(l+r)>>1;
			int lson=o<<1;
			int rson=lson|1;
			if(tag[o])	pushDown(o, lson, rson);
			if(x<=mid)	update(lson, l, mid, x, y, v);
			if(mid<y)	update(rson, mid+1, r, x, y, v);
			zdz[o] = max(zdz[lson], zdz[rson]);
		}
	}
}sgt;
int main(){
	cin>>n>>m;
	for(int i=1; i<=n; i++){
		scanf("%d %d", &l[i].l, &l[i].r);
		num[++tot] = l[i].l; num[++tot] = l[i].r;
	}
	sort(num+1, num+1+tot);
	tot = unique(num+1, num+1+tot) - num - 1;
	sort(l+1, l+1+n);
	int ll=1, re=0x3f3f3f3f;
	for(int i=1; i<=n; i++){
		l[i].l = lower_bound(num+1, num+1+tot, l[i].l)-num;
		l[i].r = lower_bound(num+1, num+1+tot, l[i].r)-num;
		sgt.update(1, 1, tot, l[i].l, l[i].r, 1);
		while(sgt.zdz[1]>=m && ll<=i){
			re = min(re, num[l[ll].r]-num[l[ll].l]-(num[l[i].r]-num[l[i].l]));
			sgt.update(1, 1, tot, l[ll].l, l[ll].r, -1);
			ll++;
		}
	}
	if(re!=0x3f3f3f3f)	cout<<re<<endl;
	else	cout<<"-1\n";
	return 0;
}
```