---
title: luogu2150 [NOI2015]寿司晚宴
date: 2018-06-22 19:38:27
categories:
  - OI
  - 动态规划
tags: 动态规划——状压dp
---
[ref](https://blog.csdn.net/u012288458/article/details/51360737)

<!--more-->

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
struct Num{
	int a, b;
}s[505];
int n, p, f[265][265], g[2][265][265];
const int pri[]={2, 3, 5, 7, 11, 13, 17, 19};
bool cmp(Num u, Num v){
	return u.b<v.b;
}
int main(){
	cin>>n>>p;
	for(int i=2; i<=n; i++){
		int x=i;
		for(int j=0; j<8; j++)
			if(x%pri[j]==0){
				s[i].a |= 1<<j;
				while(x%pri[j]==0)	x /= pri[j];
			}
		s[i].b = x;
	}
	sort(s+2, s+1+n, cmp);
	f[0][0] = 1;
	for(int i=2; i<=n; i++){
		if(i==2 || s[i].b==1 || s[i].b!=s[i-1].b){
			memcpy(g[0], f, sizeof(f));
			memcpy(g[1], f, sizeof(f));
		}
		for(int j=(1<<8)-1; j>=0; j--)
			for(int k=(1<<8)-1; k>=0; k--){
				if(j&k)	continue;
				g[0][j|s[i].a][k] = (g[0][j|s[i].a][k] + g[0][j][k]) % p;
				g[1][j][k|s[i].a] = (g[1][j][k|s[i].a] + g[1][j][k]) % p;
			}
		if(i==n || s[i].b==1 || s[i].b!=s[i+1].b)
			for(int j=(1<<8)-1; j>=0; j--)
				for(int k=(1<<8)-1; k>=0; k--){
					if(j&k)	continue;
					f[j][k] = ((g[0][j][k] + g[1][j][k]) % p - f[j][k] + p) % p;
				}
	}
	int ans=0;
	for(int j=(1<<8)-1; j>=0; j--)
		for(int k=(1<<8)-1; k>=0; k--){
			if(j&k)	continue;
			ans = (ans + f[j][k]) % p;
		}
	cout<<ans<<endl;
	return 0;
}
```