---
title: luogu4203 [NOI2008]糖果雨 
date: 2018-07-07 19:27:00
tags: 数学——计算几何
categories:
  - OI
  - 数学
---
[ref](http://blog.sina.com.cn/s/blog_86942b1401015yln.html) and [ref](https://blog.csdn.net/BraketBN/article/details/51039318)

<!--more-->

神仙数形结合……

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
int n, len, len2, len4, cc[2][2005][4005], x[1000005], y[1000005], opt, t;
int lb(int x){
	return x & -x;
}
int sum(int o, int a, int b){
	if(a<0 || b<0)	return 0;
	a++; b++;
	int re=0;
	a = min(a, len2+1);
	b = min(b, len4+1);
	for(; a; a-=lb(a))
		for(int i=b; i; i-=lb(i))
			re += cc[o][a][i];
	return re;
}
int query(int o, int xu, int yu, int xv, int yv){
	return sum(o, xv, yv)-sum(o, xu-1, yv)-sum(o, xv, yu-1)+sum(o, xu-1, yu-1);
}
void add(int o, int a, int b, int v){
	a++; b++;
	for(; a<=len2; a+=lb(a))
		for(int i=b; i<=len4; i+=lb(i))
			cc[o][a][i] += v;
}
int main(){
	cin>>n>>len;
	len2 = len << 1;
	len4 = len << 2;
	while(n--){
		scanf("%d %d", &opt, &t);
		if(opt==1){
			int c, l, r, d;
			scanf("%d %d %d %d", &c, &l, &r, &d);
			x[c] = (t - d * l + len2 )% len2;
			y[c] = r - l;
			add(0, x[c], y[c]+x[c], 1);
			add(1, x[c], y[c]-x[c]+len2, 1);
		}
		else if(opt==2){
			int l, r;
			scanf("%d %d", &l, &r);
			t %= len2;
			int k=(r==len);
			int ans=query(0, t, l+t, r+t, len4)+query(0, 0, t+l-len2, t+r-len2-k, len4)+query(1, t-r+len2+k, l-t, len2, len4)+query(1, t-r, l-t+len2, t-1, len4);
			printf("%d\n", ans);
		}
		else{
			int c;
			scanf("%d", &c);
			add(0, x[c], y[c]+x[c], -1);
			add(1, x[c], y[c]-x[c]+len2, -1);
		}
	}
	return 0;
}
```