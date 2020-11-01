---
title: luogu2179 [NOI2012]骑行川藏
date: 2018-07-02 16:46:30
categories:
  - OI
  - 数学
tags: 数学——微积分
---
参考 [rabbithu](http://www.cnblogs.com/RabbitHu/p/9019762.html) 的博客。

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
int n;
double eu, s[10005], k[10005], u[10005], ans;
double getV(int x, double lim){
	double l=max(u[x],0.0), r=0x3f3f3f3f, mid;
	for(int ii=1; ii<=100; ii++){
		mid = (l + r) / 2.0;
		if(-1/(2*k[x]*mid*mid*(mid-u[x]))<=lim)	l = mid;
		else	r = mid;
	}
	return (l+r)/2.0;
}
bool chk1(double lim){
	double re=0;
	for(int i=1; i<=n; i++){
		double v=getV(i, lim);
		re += k[i] * s[i] * (v - u[i]) * (v - u[i]);
	}
	return re<=eu;
}
int main(){
	cin>>n>>eu;
	for(int i=1; i<=n; i++)
		scanf("%lf %lf %lf", &s[i], &k[i], &u[i]);
	double l=-0x3f3f3f3f, r=0.0, mid, re;
	for(int ii=1; ii<=100; ii++){
		mid = (l + r) / 2.0;
		if(chk1(mid))	l = mid;
		else	r = mid;
	}
	re = (l + r) / 2.0;
	for(int i=1; i<=n; i++)
		ans += s[i] / getV(i, re);
	printf("%.12f\n", ans);
	return 0;
}
```