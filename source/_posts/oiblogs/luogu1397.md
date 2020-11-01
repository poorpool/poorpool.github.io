---
title: luogu1397 [NOI2013]矩阵游戏
date: 2018-06-26 11:40:40
categories:
  - OI
  - 数学
tags: 数学——数论
---
这群人怎么都用的矩阵快速幂呀 QAQ，来讲个数学方法吧。

<!--more-->

前置技能：高中数学必修“数列”，扩展欧拉定理降幂。

考虑从 $F_{i,1}$ 推到 $F_{i,m}$。考虑到有人没学过数列我还是推一下吧 qwq。

我们设 $F_{i,j} + k = a(F_{i,j-1}+k)$，易得到 $(a-1)k=b$。我们需要对 $a$ 分类讨论。

### 当 $a=1$ 时

将 $a$ 放到题目给的第二个式子，得到 $F_{i,j}=F_{i,1}+(j-1)b$。

再考虑 $F_{i+1, 1}$ 的转移。

$F_{i+1,1}=cF_{i,m}+d=c(F_{i,1}+(m-1)b)+d=cF_{i,1}+cb(m-1)+d$。

用同样的套路得到 $F_{n+1,1}$ 的式子。我们发现 $c$ 也是要分类讨论的。我们记 $D=cb(m-1)+d$。

$c=1$ 时，$F_{n+1,1}=F_{1,1}+nD$。

否则 $F_{n+1,1}=c^nF_{1,1}+D \cdot \dfrac{c^n-1}{c-1}$。

这样我们便可以轻松得到 $F_{n+1,1}$ 了。

### 当 $a \neq 1$ 时

于是 $k=b/(a-1)$。同样地我们得出 $F_{i,j}=a^{j-1}F_{i,1}+(a^{j-1}-1) \dfrac{b}{a-1}$。

再考虑 $F_{i+1, 1}$ 的转移。

$F_{i+1,1}=cF_{i,m}+d=c(a^{m-1}F_{i,1}+(a^{m-1}-1) \dfrac{b}{a-1})+d$。

化简得到 $a^{m-1}cF_{i,1}+c(a^{m-1}-1) \dfrac{b}{a-1}+d$

记 $A=a^{m-1}c$，$B=c(a^{m-1}-1) \dfrac{b}{a-1}+d$，则 $F_{i+1,1}=AF_{i,1}+B$。

我们再讨论一下是否 $A=1$。不过，我们发现这里和上面的式子（$F_{i+1,1}=cF_{i,1}+D$）的形式是一样的（只有常数不同），那么我们不必重复讨论，只要将求解 $F_{n+1,1}$ 写成一个函数调用就可以了。这个函数的讨论就按照上面对 $c$ 的讨论做就行了。

-----

现在我们得到了 $F_{n+1,1}$ ，只需要按照题目中给的第三个式子逆推就行了。于是我们 AC 了这道题。

最后解释一下为什么要用扩展欧拉定理降幂。观察到 $n,m$ 太大了，肯定要取模。当 $n,m$ 作系数的时候是对 $10^9+7$ 取模的，但是我们发现 $n,m$ 还要作指数，作指数应当对 $\varphi(10^9+7)$ 取模。所以要用扩展欧拉定理降幂，因此我们要记录一下 $n,m$ 对于这两个不同的模数取模后的值。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int a, b, c, d, nu, nv, mu, mv;
const int mod=1e9+7, phi=mod-1;
char ss[1000005];
void rn(int &x, int &y){
	scanf("%s", ss);
	int len=strlen(ss);
	for(int i=0; i<len; i++){
		x = ((ll)x * 10 % mod + ss[i] - '0') % mod;
		y = ((ll)y * 10 % phi + ss[i] - '0') % phi;
	}
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
int qwq(int x, int y){
	int re;
	if(x==1)
		re = (1 + (ll)nu * y % mod) % mod;
	else{
		re = ksm(x, nv);
		re = (re + (ll)y*(ksm(x, nv)-1+mod)%mod*ksm(x-1, mod-2)%mod) % mod;
	}
	return re;
}
int main(){
	rn(nu, nv);
	rn(mu, mv);
	cin>>a>>b>>c>>d;
	int re;
	if(a==1){
		int D=(ll)c*b%mod*(mu-1+mod)%mod;
		D = (D + d) % mod;
		re = qwq(c, D);
	}
	else{
		int A=(ll)c*ksm(a, (mv-1+phi)%phi+phi)%mod;
		int B=((ll)c*b%mod*(ksm(a, (mv-1+phi)%phi+phi)-1+mod)%mod*ksm(a-1, mod-2)%mod+d)%mod;
		re = qwq(A, B);
	}
	re = (re - d + mod) % mod;
	re = (ll)re * ksm(c, mod-2) % mod;
	cout<<re<<endl;
	return 0;
}
```
