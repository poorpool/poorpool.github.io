---
title: luogu1232 [NOI2013]树的计数
date: 2018-06-27 15:25:11
categories:
  - OI
  - 图论
tags: 图论——树论
---
[ref](https://www.cnblogs.com/lcf-2000/p/6387918.html) 好神仙的思维题啊 QAQ

<!--more-->

```cpp
#include <iostream>
#include <cstdio>
using namespace std;
int n, a[200005], b[200005], c[200005], d[200005], e[200005], f[200005];
int main(){
	cin>>n;
	for(int i=1; i<=n; i++)	scanf("%d", &a[i]);
	for(int i=1; i<=n; i++)	scanf("%d", &b[i]);
	for(int i=1; i<=n; i++)	c[b[i]] = i;
	for(int i=1; i<=n; i++)	a[i] = c[a[i]];
	for(int i=1; i<=n; i++)	b[a[i]] = i;
	d[1] = 1; e[1]++; e[2]--;
	for(int i=1; i<n; i++)
		if(b[i]>b[i+1]){
			d[i] = 1;
			e[i]++;
			e[i+1]--;
		}
	for(int i=1; i<=n; i++)	f[i] = f[i-1] + d[i];
	for(int i=1; i<n; i++)
		if(a[i]<a[i+1] && f[a[i+1]-1]-f[a[i]-1]){
			e[a[i]]++;
			e[a[i+1]]--;
		}
	double ans=1.0;
	for(int i=1; i<n; i++){
		e[i] += e[i-1];
		if(e[i])	ans += d[i];
		else	ans += 0.5;
	}
	printf("%.3f\n", ans);
	return 0;
}
```