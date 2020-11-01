---
title: luogu1398 [NOI2013]书法家
date: 2018-06-27 18:37:26
categories:
  - OI
  - 动态规划
tags: 动态规划——普通dp
---
分成 $11$ 个阶段 dp：

![pic](https://i.loli.net/2018/06/27/5b3369999069f.jpg)

<!--more-->

具体的转移看代码。你可能发现，有的转移有“自己到自己”，比如 $11$；有的就没有，比如 $7$。有“自己到自己”的区域，是因为他的宽度可以很宽。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
int n, m, a[505][155], f1[155][155], f2[155][155], f3[155][155], f4, f5[155][155], f6[155][155], f7[155][155], f8;
int f9[155][155], f10[155][155], f11[155][155], s1[155], s2[155][155], s3[155][155], oo, ans;
//a：原数组，s1：前缀和，s2[x][y]:\max_{i=y}^n f2[x][i]，s3也类似，只不过是f1，且固定尾部而不是头部
void c(int b[155][155]){
	memset(b, -63, sizeof(int)*155*155);
}
int main(){
	cin>>n>>m;
	for(int i=1; i<=n; i++)
		for(int j=1; j<=m; j++){
			int uu;
			scanf("%d", &uu);
			a[j][n-i+1] = uu;
		}
	c(f1); c(f2); c(f3); c(f5); c(f6); c(f7); c(f9); c(f10); c(f11); c(s2); c(s3);
	ans = oo = f4 = f8 = f1[1][1];
	for(int j=1; j<=m; j++){
		for(int i=1; i<=n; i++)	s1[i] = s1[i-1] + a[j][i];

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++){
				f11[l][r] = max(f11[l][r], f10[l][r]) + a[j][l] + a[j][r];
				ans = max(ans, f11[l][r]);
			}

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f10[l][r] = max(f9[l][r], f10[l][r]) + s1[r] - s1[l-1];

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f9[l][r] = max(f8, f9[l][r]) + a[j][l] + a[j][r];

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f8 = max(f8, f7[l][r]);

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f7[l][r] = f6[l][r] + s1[r] - s1[l-1];
	
		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f6[l][r] = max(f5[l][r], f6[l][r]) + a[j][l] + a[j][r];

		for(int l=1; l<=n; l++)
			for(int r=l+2; r<=n; r++)
				f5[l][r] = f4 + s1[r] - s1[l-1];

		for(int l=1; l<=n; l++)
			for(int r=l+1; r<=n; r++)
				f4 = max(f4, f3[l][r]);

		for(int l=1; l<=n; l++){
			int tmp=oo;
			for(int r=l+1; r<=n; r++){
				tmp = max(tmp, f2[l][r-1]);
				f3[l][r] = max(f3[l][r], tmp) + s1[r] - s1[l-1];
			}
		}

		for(int r=1; r<=n; r++){
			int tmp=s2[r+1][r+1];
			for(int l=r; l; l--){
				tmp = max(tmp, s2[l][r]);
				f2[l][r] = max(s3[l-1][r], tmp) + s1[r] - s1[l-1];
			}
		}

		for(int l=1; l<=n; l++)
			for(int r=l+1; r<=n; r++)
				f1[l][r] = max(0, f1[l][r]) + s1[r] - s1[l-1];

		for(int l=n; l; l--)
			for(int r=n; r>=l; r--)
				s2[l][r] = max(f2[l][r], s2[l][r+1]);

		for(int r=1; r<=n; r++)
			for(int l=1; l<=r; l++)
				s3[l][r] = max(f1[l][r], s3[l-1][r]);
    }  
	cout<<ans<<endl;
	return 0;
}
```