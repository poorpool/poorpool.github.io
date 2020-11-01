---
title: luogu1864 [NOI2009]二叉查找树
date: 2018-07-06 08:28:07
tags: 动态规划——区间dp
categories:
  - OI
  - 动态规划
---
[ref](https://blog.csdn.net/FZHvampire/article/details/51823917)

不是太懂 orz。

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int n, k, num[75];
ll f[75][75][75];
struct Node{
	int x, y, z;
}a[75];
bool cmp(Node u, Node v){
	return u.x<v.x;
}
int main(){
	cin>>n>>k;
	for(int i=1; i<=n; i++)	scanf("%d", &a[i].x);
	for(int i=1; i<=n; i++)	{
		scanf("%d", &a[i].y);
		num[i] = a[i].y;
	}
	for(int i=1; i<=n; i++)	scanf("%d", &a[i].z);
	sort(a+1, a+1+n, cmp);
	sort(num+1, num+1+n);
	for(int i=1; i<=n; i++){
		a[i].y = lower_bound(num+1, num+1+n, a[i].y) - num;
		a[i].z += a[i-1].z;
	}
	memset(f, 0x3f, sizeof(f));
	for(int i=1; i<=n+1; i++)
		for(int j=0; j<=n; j++)
			f[i][i-1][j] = 0;
	for(int i=1; i<=n; i++)
		for(int j=0; j<=n; j++)
			if(a[i].y>=j)	f[i][i][j] = a[i].z - a[i-1].z;
			else	f[i][i][j] = a[i].z - a[i-1].z + k;
	for(int l=2; l<=n; l++)
		for(int i=1; i+l-1<=n; i++){
			int j=i+l-1;
			for(int w=0; w<=n; w++){
				for(int m=i; m<=j; m++){
					if(a[m].y>=w)
						f[i][j][w] = min(f[i][j][w], f[i][m-1][a[m].y]+f[m+1][j][a[m].y]+a[j].z-a[i-1].z);
					f[i][j][w] = min(f[i][j][w], f[i][m-1][w]+f[m+1][j][w]+a[j].z-a[i-1].z+k);
				}
			}
		}
	cout<<f[1][n][0]<<endl;
	return 0;
}
```