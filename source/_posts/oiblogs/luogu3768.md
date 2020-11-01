---
title: luogu3768 简单的数学题
date: 2018-06-21 15:32:31
categories:
  - OI
  - 数学
tags: 数学——反演和筛法
---
推公式推个爽。

<!--more-->



具体看 [yyb](https://www.luogu.org/blog/cjyyb/solution-p3768) 的博客吧 orz，但是也要自己推一遍哦。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int mod, pri[4641595], cnt, in6, mo=6662333;
ll phi[4641595], n;
bool isp[4641595];
struct HashTable{
	int hea[6662335], cnt;
	struct Edge{
		ll x, y;
		int nxt;
	}edge[6662335];
	void add(ll x, ll y){
		int p=x%mo;
		edge[++cnt].nxt = hea[p]; edge[cnt].x = x; edge[cnt].y = y;
		hea[p] = cnt;
	}
	ll getV(ll x){
		int p=x%mo;
		for(int i=hea[p]; i; i=edge[i].nxt)
			if(edge[i].x==x)
				return edge[i].y;
		return 0;
	}
}hst;
ll sum1(ll x){
	x %= mod;
	return x*(x+1)/2%mod;
}
ll sum2(ll x){
	x %= mod;
	return x*(x+1)%mod*(2*x%mod+1)%mod*in6%mod;
}
int ksm(int a, int b){
	int re=1;
	while(b){
		if(b&1)	re = (ll)re * a % mod;
		a = (ll)a * a % mod;
		b >>= 1;
	}
	return re;
}
ll F(ll x){
	if(x<=4641588)	return phi[x];
	ll t=hst.getV(x);
	if(t)	return t;
	ll re=sum1(x)*sum1(x)%mod, lst;
	for(ll i=2; i<=x; i=lst+1){
		lst = x / (x / i);
		re = (re - F(x/i) * (sum2(lst) - sum2(i-1) + mod) % mod + mod) % mod;
	}
	hst.add(x, re);
	return re;
}
int main(){
	cin>>mod>>n;
	in6 = ksm(6, mod-2);
	memset(isp, true, sizeof(isp));
	isp[0] = isp[1] = false; phi[1] = 1;
	for(int i=2; i<=4641588; i++){
		if(isp[i])	pri[++cnt] = i, phi[i] = i - 1;
		for(int j=1; j<=cnt && pri[j]*i<=4641588; j++){
			isp[i*pri[j]] = false;
			if(i%pri[j]==0){
				phi[i*pri[j]] = phi[i] * pri[j];
				break;
			}
			else	phi[i*pri[j]] = phi[i] * (pri[j] - 1);
		}
	}
	for(int i=2; i<=4641588; i++)
		phi[i] = (phi[i-1] + (ll)i*i%mod*phi[i]%mod) % mod;
	ll ans=0, lst;
	for(ll i=1; i<=n; i=lst+1){
		lst = n / (n / i);
		ans = (ans + sum1(n/i)*sum1(n/i)%mod*(F(lst)-F(i-1)+mod)%mod) % mod;
	}
	cout<<ans<<endl;
	return 0;
}
```

