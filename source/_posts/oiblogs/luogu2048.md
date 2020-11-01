---
title: luogu2048 [NOI2010]超级钢琴
date: 2018-07-05 16:05:36
tags: 数据结构——RMQ
categories:
  - OI
  - 数据结构
---
要是今年 NOI 也是这种水水的题就好了 qwq。

<!--more-->

考虑朴素的暴力，找出所有区间然后爆搞。

考虑优化一点的暴力，我们可以找出最优解，累加最优解，放弃最优解，找下一个不是当前最优解的最优解（解就是区间的数字和）……这样循环地做。最优解的左端点只有 $n$ 个，因此我们对于每个左端点，研究一下以这个点为左端点的合法区间的最优解是几。

记 $o,l,r,t,v$ 为左端点 $o$，合法区间的右端点在 $[l,r]$ 中的情况。这些所有合法区间的最优解是 $v$ 当右端点是 $t$ 的时候。加上这个区间以后，这个区间能扩展出两个不优于它的解 $o,l,t-1,t_l,v_l$ 和 $o,t+1,r,t_r,v_r$。

用堆来找当前一坨解中的最优解，RMQ 最大值，前缀和区间和。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int n, ll, rr, a[500005], b[500005][19], mlg[500005], k;
long long ans=0, m;
struct Node{
	int o, l, r, t, v;
}nd[2000005];
int query(int l, int r){
	int t=mlg[r-l+1];
	if(a[b[l][t]]>a[b[r-(1<<t)+1][t]])	return b[l][t];
	else	return b[r-(1<<t)+1][t];
}
bool cmp(Node a, Node b){
	return a.v<b.v;
}
int main(){
	cin>>n>>m;
	ll = 1; rr = n;
	for(int i=1; i<=n; i++){
		scanf("%d", &a[i]);
		a[i] += a[i-1];
		b[i][0] = i;
	}
	for(int i=2; i<=n; i++)	mlg[i] = mlg[i>>1] + 1;
	for(int i=1; i<=18; i++)
		for(int j=1; j+(1<<i)-1<=n; j++){
			if(a[b[j][i-1]]>a[b[j+(1<<(i-1))][i-1]])	b[j][i] = b[j][i-1];
			else	b[j][i] = b[j+(1<<(i-1))][i-1];
		}
	for(int i=1; i+ll-1<=n; i++){
		int l=i+ll-1, r=i+rr-1;
		if(r>n)	r = n;
		int t=query(l, r);
		nd[++k] = (Node){i, l, r, t, a[t]-a[i-1]};
		push_heap(nd+1, nd+1+k, cmp);
	}
	while(m--){
		Node x=nd[1];
		pop_heap(nd+1, nd+1+k, cmp);
		k--;
		ans = x.v;
		if(x.t!=x.l){
			int t=query(x.l, x.t-1);
			nd[++k] = (Node){x.o, x.l, x.t-1, t, a[t]-a[x.o-1]};
			push_heap(nd+1, nd+1+k, cmp);
		}
		if(x.t!=x.r){
			int t=query(x.t+1, x.r);
			nd[++k] = (Node){x.o, x.t+1, x.r, t, a[t]-a[x.o-1]};
			push_heap(nd+1, nd+1+k, cmp);
		}
	}
	cout<<ans<<endl;
	return 0;
}
```