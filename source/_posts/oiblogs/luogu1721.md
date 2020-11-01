---
title: luogu1721 [NOI2016]国王饮水记
date: 2018-06-22 16:12:11
categories:
  - OI
  - 动态规划
tags: 动态规划——斜率优化
---
鬼畜题……看[picks大爷的课件](https://gitee.com/mulab/NOI2016)吧。

<!--more-->

以下略去高精小数库，要想过编译应当复制高精库并修改高精库精度。

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int nn, n=1, k, p, h[8005], q[8005], r[8005][15];
double s[8005], f[8005][15];
Decimal ans;
struct Point{
	double x, y;
}pt[8005], t;
double getK(Point u, Point v){
	return (u.y-v.y)/(u.x-v.x);
}
Decimal d(int a, int b){
	if(!b)	return h[1];
	else	return (d(r[a][b], b-1)+s[a]-s[r[a][b]])/(a-r[a][b]+1);
}
int main(){
	cin>>nn>>k>>p;
	scanf("%d", &h[1]);
	for(int i=1; i<nn; i++){
		int a;
		scanf("%d", &a);
		if(a<=h[1])	continue;
		h[++n] = a;
	}
	sort(h+1, h+1+n);
	for(int i=1; i<=n; i++)
		s[i] = s[i-1] + h[i];
	k = min(k, n);
	for(int i=1; i<=n; i++)
		f[i][0] = h[1];
	int lim=min(k, 14);
	for(int j=1; j<=lim; j++){
		pt[1] = (Point){0, s[1]-f[1][j-1]};
		int ll=0, rr=0;
		q[0] = 1;
		for(int i=2; i<=n; i++){
			t = (Point){(double)i, s[i]};
			while(ll<rr && getK(pt[q[ll]], t)<getK(pt[q[ll+1]], t))	ll++;
			pt[i] = (Point){(double)i-1, s[i]-f[i][j-1]};
			r[i][j] = q[ll];
			f[i][j] = (s[i] - (s[q[ll]]-f[q[ll]][j-1])) / (double)(i - (q[ll]-1));
			while(ll<rr && getK(pt[q[rr]], pt[q[rr-1]])>getK(pt[q[rr]], pt[i]))	rr--;
			q[++rr] = i;
		}
	}
	int u=n-(k-lim);
	double w=0;
	int o;
	for(int i=0; i<=lim; i++)
		if(w<f[u][i]){
			w = f[u][i];
			o = i;
		}
	ans = d(u, o);
	for(int i=u+1; i<=n; i++)
		ans = (ans + h[i]) / 2;
	cout<<ans.to_string(p*2)<<endl;
	return 0;
}
```