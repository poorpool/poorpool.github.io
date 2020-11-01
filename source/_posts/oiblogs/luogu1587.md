---
title: luogu1587 [NOI2016]循环之美
date: 2018-06-21 16:44:51
categories: 数学
tags: 数学——反演和筛法
---

推公式推个爽。

<!--more-->

猜想一个既约分数 $i/j$ 是美的当 $(j,k)=1$。

假设竖式除法中余数出现循环的长度是 $l$，那么 $i \equiv ik^l \pmod j$。也即 $k^l \equiv 1 \pmod j$，那么想一想费马小定理成立的条件就能分析出 $(j,k)=1$。

-----

答案为
$$
\begin{aligned}
&\sum_{i=1}^n \sum_{j=1}^m [(i,j)=1][(j,k)=1] \\
= & \sum_{j=1}^m [(j,k)=1] \sum_{i=1}^n [(i,j)=1] \\
= & \sum_{j=1}^m [(j,k)=1] \sum_{i=1}^n \sum_{d \mid (i,j)} \mu(d) \\
= & \sum_d \mu(d) \sum_{i=1}^n [d \mid i] \sum_{j=1}^m [d \mid j][(j,k)=1] \\
 = & \sum_d \mu(d) \left \lfloor \frac{n}{i} \right \rfloor \sum_{jd=1}^m[(jd,k)=1] \\
 = & \sum_d \mu(d) \left \lfloor \frac{n}{i} \right \rfloor \sum_{j=1}^{\lfloor m/d \rfloor}[(jd,k)=1] \\
 = & \sum_d \mu(d) \left \lfloor \frac{n}{i} \right \rfloor \sum_{j=1}^{\lfloor m/d \rfloor}[(j,k)=1][(d,k)=1] \\
 = & \sum_{d=1}^n [(d,k)=1] \mu(d) \left \lfloor \frac{n}{i} \right \rfloor \sum_{j=1}^{\lfloor m/d \rfloor}[(j,k)=1] \\
\end{aligned}
$$


稍作休息，我们想要是能 $O(1)$ 求出后面的 sigma 该有多好啊，这样就能 $O(n)$ 地拿到 $84$ 分了。因为 $(i,j)=(i \bmod j,j)$。我们定义一个函数 $f(x)$ 表示 $\sum_{i=1}^x [(i,k)=1]$，依据刚才说的就是 $f(x)=\lfloor x/k \rfloor f(k) + f(x \bmod k)$。这样就拿到了 $84$ 分~~，就当做是 AC 了~~。

现在我们要快速求出
$$
\begin{aligned}
& \sum_{i=1}^n [(i,k)=1] \mu(i) \\
= & \sum_{i=1}^n \mu(i) \sum_{d \mid (i,k)} \mu(d) \\
= & \sum_{d|k} \mu(d) \sum_{i=1}^{\lfloor n/d \rfloor} \mu(id) \\
= & \sum_{d|k} \mu(d) \sum_{i=1}^{\lfloor n/d \rfloor} \mu(i)\mu(d)[(i,d)=1] \\
= & \sum_{d|k} \mu(d)^2 \sum_{i=1}^{\lfloor n/d \rfloor} \mu(i)[(i,d)=1] \\
\end{aligned}
$$


如果我们记这个式子为 $s(n,k)$，则 $s(n,k)=\sum_{d \mid k} \mu(d)^2 s(\lfloor n/d \rfloor,d)$。

然而我们发现 $k=1$ 时进入了循环递归，然而我们发现此时就是让求 $\mu$ 前缀和，杜教筛。做完了。

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
#include <map>
using namespace std;
typedef long long ll;
typedef pair<int,int> par;
int n, m, k, pri[1000005], cnt, mu[1000005], smu[1000005], qwq[2005];
bool isp[1000005];
const int mo=1000003;
map<par,int> mp;
struct HashTable{
	int hea[1000005], cnt;
	struct Edge{
		int x, y, nxt;
	}edge[1000005];
	void add(int x, int y){
		int p=x%mo;
		edge[++cnt].nxt = hea[p]; edge[cnt].x = x; edge[cnt].y = y;
		hea[p] = cnt;
	}
	int getV(int x){
		int p=x%mo;
		for(int i=hea[p]; i; i=edge[i].nxt)
			if(edge[i].x==x)
				return edge[i].y;
		return 0;
	}
}hst;
int gcd(int a, int b){
	return !b?a:gcd(b,a%b);
}
int getqwq(int x){
	return x/k*qwq[k]+qwq[x%k];
}
int dyh(int x){
	if(x<=1000000)	return smu[x];
	int t=hst.getV(x);
	if(t)	return t;
	int re=1, lst;
	for(int i=2; i<=x; i=lst+1){
		lst = x / (x / i);
		re -= (lst-i+1) * dyh(x/i);
	}
	hst.add(x, re);
	return re;
}
int S(int a, int b){
	int t=mp[par(a,b)];
	if(t)	return t;
	if(!a)	return 0;
	if(b==1)	return dyh(a);
	int re=0;
	for(int i=1; i*i<=b; i++)
		if(b%i==0){
			if(mu[i])	re += S(a/i, i);
			if(i*i!=b && mu[b/i])	re += S(a/(b/i), b/i);
		}
	mp[par(a,b)] = re;
	return re;
}
int main(){
	cin>>n>>m>>k;
	memset(isp, true, sizeof(isp));
	isp[0] = isp[1] = false; smu[1] = mu[1] = 1;
	for(int i=2; i<=1000000; i++){
		if(isp[i])	pri[++cnt] = i, mu[i] = -1;
		for(int j=1; j<=cnt && i*pri[j]<=1000000; j++){
			isp[i*pri[j]] = false;
			if(i%pri[j]==0){
				mu[i*pri[j]] = 0;
				break;
			}
			else	mu[i*pri[j]] = -mu[i];
		}
		smu[i] = smu[i-1] + mu[i];
	}
	for(int i=1; i<=k; i++)
		qwq[i] = qwq[i-1] + (gcd(i,k)==1);
	ll ans=0;
	int lst;
	for(int i=1; i<=n && i<=m; i=lst+1){
		lst = min(n/(n/i), m/(m/i));
		ans += (ll)n/i * (S(lst,k)-S(i-1,k)) * getqwq(m/i);
	}
	cout<<ans<<endl;
	return 0;
}
```

