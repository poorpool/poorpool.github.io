---
title: luogu1224 [NOI2013]向量内积
date: 2018-06-26 09:20:00
tags: 乱搞
categories:
  - OI
  - 乱搞
---
[ref](http://www.cnblogs.com/ljh2000-jump/p/6388599.html?utm_source=itdadao&utm_medium=referral)

什么玩意儿……随机化乱搞神题。

<!--more-->

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <ctime>
using namespace std;
int n, d, k, a[100005][105], b[105][100005], tot, c[100005], e[100005], f[100005], g[105][105];
int calc(int x){
	int tot=0;
	for(int i=1; i<=d; i++)
		for(int j=1; j<=d; j++){
			tot += g[i][j] * a[x][i] * a[x][j];
			g[i][j] += a[x][i] * a[x][j];
		}
	return tot%3;
}
int main(){
    srand(time(NULL));
    cin>>n>>d>>k;
    for(int i=1; i<=n; i++)
        for(int j=1; j<=d; j++){
            scanf("%d", &a[i][j]);
            a[i][j] %= k;
            b[j][i] = a[i][j];
        }
    if(k==2){
        int T=6;
        while(T--){
            tot = 0;
            for(int i=1; i<=n; i++){
                c[i] = rand() % 2;
                tot += c[i];
            }
			tot %= 2;
            memset(e, 0, sizeof(e));
            memset(f, 0, sizeof(f));
            for(int i=1; i<=d; i++){
                for(int j=1; j<=n; j++)
                    e[i] += b[i][j] * c[j];
                e[i] %= 2;
            }
            for(int i=1; i<=n; i++){
                for(int j=1; j<=d; j++)
                    f[i] += a[i][j] * e[j];
                f[i] %= 2;
            }
            int tag1=-1;
            for(int i=1; i<=n; i++)
                if(f[i]!=tot){
                    tag1 = i;
                    break;
                }
            if(tag1==-1)	continue;
            int tag2=-1;
            for(int i=1; i<=n; i++){
                if(i==tag1)	continue;
                int now=0;
                for(int j=1; j<=d; j++)
                    now += a[tag1][j] * a[i][j];
                now %= 2;
                if(!now){
                    tag2 = i;
                    break;
                }
            }
            if(tag2!=-1){
                if(tag1>tag2)	swap(tag1, tag2);
                printf("%d %d\n", tag1, tag2);
                return 0;
            }
        }
        printf("-1 -1\n");
    }
    else{
        for(int i=1; i<=n; i++)	c[i] = i;
		random_shuffle(c+1, c+1+n);
		for(int i=1; i<=n; i++){
			if(calc(c[i])!=(i-1)%3){
				for(int j=1; j<i; j++){
					int tot=0;
					for(int l=1; l<=d; l++)
						tot += a[c[i]][l] * a[c[j]][l];
					tot %= 3;
					if(!tot){
						if(c[i]>c[j])	swap(c[i], c[j]);
						printf("%d %d\n", c[i], c[j]);
						return 0;
					}
				}
			}
		}
		printf("-1 -1\n");
    }
	return 0;
}
```