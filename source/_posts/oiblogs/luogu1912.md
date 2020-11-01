---
title: luogu1912 [NOI2009]诗人小G
date: 2018-07-06 16:07:21
tags: 动态规划——决策单调性
categories:
  - OI
  - 动态规划
---
怎样证明决策单调性？打表、瞪眼（误）

<!--more-->

[ref](https://www.luogu.org/blog/larryzhong/solution-p1912) 这个是详细的题解

```cpp
#include <iostream>
#include <cstring>
#include <string>
#include <cstdio>
using namespace std;
typedef long double ld;
int n, l, p, s[100005], d[100005], ll[100005], rr[100005], idx[100005], nxt[100005];
ld f[100005];
char ss[100005][35];
ld ksm(ld a, int b){
	ld re=1;
	while(b){
		if(b&1)	re = re * a;
		a = a * a;
		b >>= 1;
	}
	return re;
}
ld o(ld x){
	return x>0?x:-x;
}
ld calc(int j, int i){
	return f[j]+ksm(o(s[i]-s[j]-1-l), p);
}
int main(){
	int T;
	cin>>T;
	while(T--){
		scanf("%d %d %d", &n, &l, &p);
		for(int i=1; i<=n; i++){
			scanf("%s", ss[i]);
			s[i] = s[i-1] + strlen(ss[i]);
		}
		for(int i=1; i<=n; i++)	s[i] += i;
		int lll=1, rrr=0;
		d[++rrr] = 0; ll[0] = 1; rr[0] = n;
		for(int i=1; i<=n; i++){
			while(rr[d[lll]]<i)	lll++;
			f[i] = calc(d[lll], i);
			idx[i] = d[lll];
			if(calc(i, n)>calc(d[rrr], n))	continue;
			while(calc(i, ll[d[rrr]])<calc(d[rrr], ll[d[rrr]]))	rrr--;
			/*int lb=ll[d[rrr]], rb=n, mid, re;
			while(lb<=rb){
				mid = (lb + rb) >> 1;
				if(calc(i, mid)<calc(d[rrr], mid))	re = mid, rb = mid - 1;
				else	lb = mid + 1;
			}
			rr[d[rrr]] = re - 1;
			d[++rrr] = i; ll[d[rrr]] = re; rr[d[rrr]] = n;*/
			int lb = ll[d[rrr]], rb = n;
			while (lb < rb) {
				int mid = (lb + rb) >> 1;
				if (calc(i, mid) < calc(d[rrr], mid)) {
					rb = mid;
				} else {
					lb = mid + 1;
				}
			}
			rr[d[rrr]] = lb - 1;
			d[++rrr] = i, ll[i] = lb, rr[i] = n;
		}
		if(f[n]>1e18)	printf("Too hard to arrange\n");
		else{
			printf("%lld\n", (long long)(f[n]+0.5));
			for(int i=n; i; i=idx[i])	nxt[idx[i]] = i;
			int cur=0;
			for(int i=1; i<=n; i=cur+1){
				cur = nxt[cur];
				for(int j=i; j<cur; j++)	printf("%s ", ss[j]);
				printf("%s\n", ss[cur]);
			}
		}
		printf("--------------------\n");
	}
	return 0;
}
```