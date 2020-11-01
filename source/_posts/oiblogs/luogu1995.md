---
title: luogu1995 [NOI2011]智能车比赛
date: 2018-07-04 11:34:41
tags: 动态规划——普通dp
categories:
  - OI
  - 动态规划
---
水水的 dp，水水的 poorpool。

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
#include <cmath>
using namespace std;
int n, cnt;
double vv, lu;
const double eps=1e-8;
struct Point{
	double x, y, dp;
	Point(){
		x = y = 0;
		dp = 1e18;
	}
	void rn(){
		double a, b;
		scanf("%lf %lf", &a, &b);
		x = a; y = b;
	}
}ss, tt, a[4005];
struct Squares{
	Point zx, ys;
}squ[2005];
struct Tongdao{
	Point xia, sha;
}td[2005];
double getDis(Point a, Point b){
	return sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y));
}
double getK(Point a, Point b){
	return (b.y-a.y)/(b.x-a.x);
}
int main(){
	cin>>n;
	for(int i=1; i<=n; i++){
		squ[i].zx.rn();
		squ[i].ys.rn();
	}
	ss.rn(); tt.rn();
	if(ss.x>tt.x)	swap(ss, tt);
	scanf("%lf", &vv);
	for(int i=1; i<n; i++){
		td[i].xia.x = td[i].sha.x = squ[i].ys.x;
		td[i].xia.y = max(squ[i].zx.y, squ[i+1].zx.y);
		td[i].sha.y = min(squ[i].ys.y, squ[i+1].ys.y);
	}
	ss.dp = 0;
	a[++cnt] = ss;
	for(int i=1; i<n; i++){
		if(td[i].xia.x<ss.x)	continue;
		if(td[i].xia.x>tt.x)	break;
		a[++cnt] = td[i].xia;
		a[++cnt] = td[i].sha;
	}
	a[++cnt] = tt;
	a[1].dp = 0;
	for(int i=1; i<cnt; i++){
		double kmax=1e18, kmin=-1e18;
		for(int j=i+1; j<=cnt; j++){
			if(fabs(a[j].x-a[i].x)<eps)
				a[j].dp = min(a[j].dp, a[i].dp+getDis(a[i], a[j]));
			else{
				double k=getK(a[j], a[i]);
				if(k<=kmax && k>=kmin)
					a[j].dp = min(a[j].dp, a[i].dp+getDis(a[i], a[j]));
				if(j&1)
					kmax = min(kmax, k);
				else
					kmin = max(kmin, k);
			}
		}
	}
	printf("%.12f\n", a[cnt].dp/vv);
	return 0;
}
```