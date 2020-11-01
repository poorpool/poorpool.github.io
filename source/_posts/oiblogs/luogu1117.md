---
title: luogu1117 [NOI2016]优秀的拆分 
date: 2018-06-20 14:56:33
categories:
  - OI
  - 字符串
tags: 字符串——后缀数组
---
我们惊喜地发现傻叉哈希能拿 $95$ 分~~，那就不要想正解了，这就是 A 了~~。

<!--more-->

关于正解，其实就是加速“一个字符及其左（右）有多少个AA型字符串”的计算，一次算一个改成了一次算好几个。具体看 [yyb](https://blog.csdn.net/qq_30974369/article/details/79167123) 的博客。

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef long long ll;
int T, f[30005], g[30005], mlg[30005];
ll ans;
struct SuffixArray{
	int n, tmp[30005], rnk[30005], saa[30005], m, p, cnt[30005], st[30005][15], hei[30005];
	char ss[30005];
	void init(){
		m = 128;
		p = 0;
		memset(tmp, 0, sizeof(tmp));
		memset(rnk, 0, sizeof(rnk));
		memset(saa, 0, sizeof(saa));
		memset(hei, 0, sizeof(hei));
		memset(cnt, 0, sizeof(cnt));
		memset(st, 0, sizeof(st));
	}
	void sasort(){
		for(int i=0; i<m; i++)	cnt[i] = 0;
		for(int i=0; i<n; i++)	cnt[rnk[i]]++;
		for(int i=1; i<m; i++)	cnt[i] += cnt[i-1];
		for(int i=n-1; i>=0; i--)	saa[--cnt[rnk[tmp[i]]]] = tmp[i];
	}
	void getLcp(){
		int h=0;
		for(int i=1; i<=n; i++)	rnk[saa[i]] = i;
		for(int i=0; i<n; i++){
			if(h)	h--;
			int j=saa[rnk[i]-1];
			while(ss[i+h]==ss[j+h])	h++;
			hei[rnk[i]] = h;
		}
		for(int i=1; i<=n; i++)	st[i][0] = hei[i];
		for(int i=1; i<=14; i++)
			for(int j=1; j<=n && j+(1<<(i-1))<=n; j++)
				st[j][i] = min(st[j][i-1], st[j+(1<<(i-1))][i-1]);
	}
	void buildSA(){
		ss[n] = 0; n++;
		for(int i=0; i<n; i++){
			rnk[i] = ss[i];
			tmp[i] = i;
		}
		sasort();
		for(int j=1; p<n; j<<=1){
			p = 0;
			for(int i=n-j; i<n; i++)	tmp[p++] = i;
			for(int i=0; i<n; i++)
				if(saa[i]>=j)
					tmp[p++] = saa[i] - j;
			sasort();
			swap(rnk, tmp);
			p = 1;
			rnk[saa[0]] = 0;
			for(int i=1; i<n; i++)
				if(tmp[saa[i-1]]==tmp[saa[i]] && tmp[saa[i-1]+j]==tmp[saa[i]+j])
					rnk[saa[i]] = p - 1;
				else
					rnk[saa[i]] = p++;
			m = p;
		}
		n--;
		getLcp();
	}
	int lcp(int x, int y){
		int l=min(rnk[x], rnk[y])+1, r=max(rnk[x], rnk[y]);
		return min(st[l][mlg[r-l+1]], st[r-(1<<mlg[r-l+1])+1][mlg[r-l+1]]);
	}
}A, B;
int main(){
	cin>>T;
	for(int i=2; i<=30000; i++)
		mlg[i] = mlg[i>>1] + 1;
	while(T--){
		A.init(); B.init();
		scanf("%s", A.ss);
		A.n = B.n = strlen(A.ss);
		for(int i=0; i<A.n; i++)
			B.ss[A.n-1-i] = A.ss[i];
		A.buildSA(); B.buildSA();
		memset(f, 0, sizeof(f));
		memset(g, 0, sizeof(g));
		ans = 0;
		for(int len=1; 2*len<=A.n; len++){
			int j=len*2-1;
			for(int i=len-1; j<A.n; ){
				int x=min(A.lcp(i, j), len); 
				int y=min(B.lcp(A.n-i, A.n-j), len-1);
				int t=x+y-len+1;
				if(x+y>=len){
					g[i-y]++; g[i-y+t]--;
					f[j+x-t]++; f[j+x]--;
				}
				i += len;
				j += len;
			}
		}
		for(int i=1; i<A.n; i++){
			f[i] += f[i-1];
			g[i] += g[i-1];
		}
		for(int i=1; i<A.n-1; i++)
			ans += (ll)f[i] * g[i+1];
		printf("%lld\n", ans);
	}
	return 0;
}
```

-----

九十五分暴力：

```cpp
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
typedef unsigned long long ull;
int T, n, dp1[2005], dp2[2005];
char ss[2005];
ull mi1[2005], mi2[2005], hs1[2005], hs2[2005];
const ull bse=131, mo1=1e9+7, mo2=19260817;
bool ise(int a, int b, int c, int d){
    ull tmp1=0, tmp2=0;
    tmp1 = (hs1[b] - hs1[a-1] * mi1[b-a+1] %mo1 + mo1) % mo1;
    tmp2 = (hs1[d] - hs1[c-1] * mi1[d-c+1] %mo1 + mo1) % mo1;
    if(tmp1!=tmp2)	return false;
    tmp1 = tmp2 = 0;
    tmp1 = (hs2[b] - hs2[a-1] * mi2[b-a+1] %mo2 + mo2) % mo2;
    tmp2 = (hs2[d] - hs2[c-1] * mi2[d-c+1] %mo2 + mo2) % mo2;
    return tmp1==tmp2;
}
int main(){
    cin>>T;
    mi1[0] = mi2[0] = 1;
    for(int i=1; i<=2000; i++){
        mi1[i] = mi1[i-1] * bse % mo1;
        mi2[i] = mi2[i-1] * bse % mo2;
    }
    while(T--){
        scanf("%s", ss+1);
        n = strlen(ss+1);
        memset(dp1, 0, sizeof(dp1));
        memset(dp2, 0, sizeof(dp2));
        for(int i=1; i<=n; i++){
            hs1[i] = (hs1[i-1] * bse % mo1 + ss[i]) % mo1;
            hs2[i] = (hs2[i-1] * bse % mo2 + ss[i]) % mo2;
        }
        ull ans=0;
        for(int i=2; i<=n-2; i++){
            ull tmp=0, orz=0;
            for(int j=i; 2*(i-j+1)<=i && j>0; j--)
                if(ise(i-2*(i-j+1)+1, i-(i-j+1), j, i))
                    tmp++;
            for(int j=i+1; 2*(j-i)+i<=n && j<=n; j++)
                if(ise(i+1, j, j+1, 2*(j-i)+i))
                    orz++;
            ans += tmp * orz;
        }
        cout<<ans<<endl;
    }
    return 0;
}
```