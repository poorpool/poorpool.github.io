---
title: luogu2178 [NOI2015]品酒大会
date: 2018-06-23 08:47:39
categories:
  - OI
  - 字符串
tags: 字符串——后缀数组
---
[ref](https://blog.csdn.net/alxpcun/article/details/50482493)

挺神仙的……

<!--more-->

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, a[300005], rnk[300005], cnt[300005], tmp[300005], p, m=128, hei[300005], mx[300005], mn[300005];
int fa[300005], siz[300005], saa[300005];
ll ans[300005], sum[300005];
char ss[300005];
struct Node{
	int h, x, y;
}nd[300005];
int myfind(int x){
	return fa[x]==x?x:fa[x]=myfind(fa[x]);
}
void sasort(){
	for(int i=0; i<m; i++)	cnt[i] = 0;
	for(int i=0; i<n; i++)	cnt[rnk[i]]++;
	for(int i=1; i<m; i++)	cnt[i] += cnt[i-1];
	for(int i=n-1; i>=0; i--)	saa[--cnt[rnk[tmp[i]]]] = tmp[i];
}
void buildSA(){
	ss[n++] = 0;
	for(int i=0; i<n; i++){
		rnk[i] = ss[i];
		tmp[i] = i;
	}
	sasort();
	for(int j=1; p<n; j<<=1){
		p = 0;
		for(int i=n-j; i<n; i++)	tmp[p++] = i;
		for(int i=0; i<n; i++)
			if(saa[i]>=j)
				tmp[p++] = saa[i] - j;
		sasort();
		swap(rnk, tmp);
		rnk[saa[0]] = 0;
		p = 1;
		for(int i=1; i<n; i++)
			if(tmp[saa[i]]==tmp[saa[i-1]] && tmp[saa[i]+j]==tmp[saa[i-1]+j])
				rnk[saa[i]] = p - 1;
			else
				rnk[saa[i]] = p++;
		m = p;
	}
	n--;
}
void getLcp(){
	for(int i=1; i<=n; i++)	rnk[saa[i]] = i;
	int h=0;
	for(int i=0; i<n; i++){
		if(h)	h--;
		int j=saa[rnk[i]-1];
		while(ss[i+h]==ss[j+h])	h++;
		hei[rnk[i]] = h;
	}
}
bool cmp(Node a, Node b){
	return a.h>b.h;
}
int main(){
	cin>>n;
	scanf("%s", ss);
	for(int i=1; i<=n; i++)	scanf("%d", &a[i]);
	buildSA();
	getLcp();
	for(int i=1; i<=n; i++){
		fa[i] = i;
		mx[rnk[i-1]] = mn[rnk[i-1]] = a[i];
		siz[i] = 1;
	}
	for(int i=2; i<=n; i++)
		nd[i-1] = (Node){hei[i], i, i-1};
	memset(sum, 128, sizeof(sum));
	int j=1;
	sort(nd+1, nd+n, cmp);
	for(int i=nd[1].h; i>=0; i--){
		ans[i] = ans[i+1]; sum[i] = sum[i+1];
		for(; j<n && nd[j].h==i; j++){
			int x=myfind(nd[j].x), y=myfind(nd[j].y);
			sum[i] = max(sum[i], (ll)mx[x]*mx[y]);
			sum[i] = max(sum[i], (ll)mn[x]*mn[y]);
			ans[i] += (ll)siz[x] * siz[y];
			fa[y] = x; siz[x] += siz[y];
			mx[x] = max(mx[x], mx[y]); mn[x] = min(mn[x], mn[y]);
		}
	}
	for(int i=0; i<n; i++)
		printf("%lld %lld\n", ans[i], ans[i]?sum[i]:0);
	return 0;
}
```