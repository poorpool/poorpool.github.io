---
title: luogu1973 [NOI2011]Noi嘉年华
date: 2018-07-04 08:25:45
categories:
  - OI
  - 动态规划
tags: 动态规划——普通dp
---
[ref1](https://blog.csdn.net/whjpji/article/details/7547159) [ref2](https://blog.csdn.net/qpswwww/article/details/45251877)

<!--more-->

我不会告诉你我第一眼看错题了的……

```cpp
#include <algorithm>
#include <iostream>
#include <cstdio>
using namespace std;
int n, tot, lsh[405], num[405][405], pre[405][205], suf[405][205], g[405][405];
const int oo=0x3f3f3f3f;
struct Lines{
	int a, b;
}l[205];
int main(){
	cin>>n;
	for(int i=1; i<=n; i++){
		scanf("%d %d", &l[i].a, &l[i].b);
		l[i].b += l[i].a;
		lsh[++tot] = l[i].a;
		lsh[++tot] = l[i].b;
	}
	sort(lsh+1, lsh+1+tot);
	tot = unique(lsh+1, lsh+1+tot) - lsh - 1;
	for(int i=1; i<=n; i++){
		l[i].a = lower_bound(lsh+1, lsh+1+tot, l[i].a) - lsh;
		l[i].b = lower_bound(lsh+1, lsh+1+tot, l[i].b) - lsh;
	}
	for(int i=1; i<=tot; i++){
		for(int j=1; j<=n; j++)
			if(l[j].a>=i)
				num[i][l[j].b]++;
		for(int j=i+1; j<=tot; j++)
			num[i][j] += num[i][j-1];
	}
	for(int i=0; i<=404; i++)
		for(int j=0; j<=204; j++)
			pre[i][j] = suf[i][j] = -oo;
	pre[0][0] = suf[tot+1][0] = 0;
	for(int i=1; i<=tot; i++){
		for(int j=0; j<=n; j++){
			for(int k=0; k<i; k++){
				pre[i][j] = max(pre[i][j], pre[k][j]+num[k][i]);
				if(j>=num[k][i])	pre[i][j] = max(pre[i][j], pre[k][j-num[k][i]]);
			}
		}
		for(int j=0; j<=n; j++)
			if(pre[i][j]>=0)
				pre[i][pre[i][j]] = max(pre[i][pre[i][j]], j);
		for(int j=n-1; j>=0; j--)
			pre[i][j] = max(pre[i][j], pre[i][j+1]);
	}
	for(int i=tot; i; i--){
		for(int j=0; j<=n; j++){
			for(int k=i+1; k<=tot+1; k++){
				suf[i][j] = max(suf[i][j], suf[k][j]+num[i][k]);
				if(j>=num[i][k])	suf[i][j] = max(suf[i][j], suf[k][j-num[i][k]]);
			}
		}
		for(int j=0; j<=n; j++)
			if(suf[i][j]>=0)
				suf[i][suf[i][j]] = max(suf[i][suf[i][j]], j);
		for(int j=n-1; j>=0; j--)
			suf[i][j] = max(suf[i][j], suf[i][j+1]);
	}
	int ans=0;
	for(int i=0; i<=n; i++)
		ans = max(ans, min(i,pre[tot][i]));
	cout<<ans<<endl;
	for(int i=1; i<=tot; i++)
		for(int j=i; j<=tot; j++){
			g[i][j] = -oo;
			int y=n;
			for(int x=0; x<=n; x++){
				while(y>=0 && x+y>num[i][j]+pre[i][x]+suf[j][y])	y--;
				if(y>=0)	g[i][j] = max(g[i][j], x+y);
			}
		}
	for(int i=1; i<=n; i++){
		int tmp=-oo;
		for(int j=1; j<=l[i].a; j++)
			for(int k=l[i].b; k<=tot; k++)
				tmp = max(tmp, g[j][k]);
		printf("%d\n", tmp);
	}
	return 0;
}
```