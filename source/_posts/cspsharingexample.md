---
title: CSP 分享会中举到的代码例子
date: 2021-11-03 09:38:00
tags:
- 杂记
categories:
- 杂记
---

代码风格非常重要！

<!--more-->

## 反面例子

（ZJOI2019 麻将）

```cpp
#include<bits/stdc++.h>
#define Tp template<typename Ty>
#define Ts template<typename Ty,typename... Ar>
#define Reg register
#define RI Reg int
#define Con const
#define CI Con int&
#define I inline
#define W while
#define N 100
#define M 400
#define X 998244353
#define Gmax(x,y) (x<(y)&&(x=(y)))
#define Inc(x,y) ((x+=(y))>=X&&(x-=X))
#define Qinv(x) Qpow(x,X-2)
using namespace std;
int n,m,a[N+5],Fac[M+5],Inv[M+5];
I int Qpow(RI x,RI y) {RI t=1;W(y) y&1&&(t=1LL*t*x%X),x=1LL*x*x%X,y>>=1;return t;}
class HuAutomation//胡牌自动机
{
    private:
        #define SZ 2092//实测自动机大小
        #define C(x,y) (1LL*Fac[x]*Inv[y]%X*Inv[(x)-(y)]%X)//组合数
        #define Pos(x) (p.count(x)?p[x]:(O[p[x]=++tot]=x,tot))//求节点编号，若不存在则新建一个
        #define Expend(x) for(j=0;j^5;++j) O[x].S[j]=Pos(O[x]+j);//扩展
        class Mat//矩阵
        {
            private:
                #define CM Con Mat&
                #define Rp for(RI i=0,j;i^3;++i) for(j=0;j^3;++j)
                #define S (i+j+k)
                int f[3][3];
            public:
                I Mat() {Rp f[i][j]=-1;}I int* operator [] (CI x) {return f[x];}
                I bool operator != (Mat o) Con {Rp if(f[i][j]^o[i][j]) return 1;return 0;}//不等于
                I bool operator < (Mat o) Con {Rp if(f[i][j]^o[i][j]) return f[i][j]<o[i][j];}//比大小，用于map
                I bool Check() Con {Rp if(f[i][j]>3) return 1;return 0;}//判断是否能胡
                I void F5(Mat o,CI t)//更新
                {
                    Rp if(~o[i][j]) for(RI k=0;k^3&&S<=t;++k)//i,j,k分别枚举用于拼面子、用于保留(i-1,i)、用于保留i和直接拼面子的牌数 
                        Gmax(f[j][k],min(i+o[i][j]+(t-S)/3,4));//转移更新信息（要向4取模是因为大于4没有意义，同时提高效率）
                }
                #undef S
        };
        struct node//存储一个节点的信息
        {
            int t,S[5];Mat P[2];I node() {t=S[0]=S[1]=S[2]=S[3]=S[4]=0,P[0]=P[1]=Mat();}
            I bool operator < (Con node& o) Con//用于map
            {
                return t^o.t?t<o.t:(P[0]!=o.P[0]?P[0]<o.P[0]:(P[1]!=o.P[1]?P[1]<o.P[1]:0));
            }
            I node operator + (CI x) Con//加上x张新牌
            {
                if(IsHu()) return Hu();node res;//如果已经胡了直接返回
                res.P[0].F5(P[0],x),res.P[1].F5(P[1],x),x>1&&(res.P[1].F5(P[0],x-2),0),//进行转移
                res.t=t+(x>1),res.IsHu()&&(res=Hu(),0);return res;//统计对子数，然后判断是否胡
            }
            I bool IsHu() Con {return !~t||t>=7||P[1].Check();}//已经胡或者七对子或者存在4个面子和1个对子
            I node Hu() Con {node x;return x.t=-1,x;}//胡牌的特殊标记
        }O[SZ+5];map<node,int> p;
        I node Begin() {node x;return x.P[0][0][0]=0,x;}//初始状态
        I node Hu() {node x;return x.t=-1,x;}//胡牌的特殊标记
    public:
        int tot,f[N+5][M+5][SZ+5];
        I void Build()//建自动机
        {
            RI i,j;p[O[1]=Begin()]=1,p[O[2]=Hu()]=tot=2;//建立初始状态和胡牌状态
            Expend(1);for(i=3;i<=tot;++i) Expend(i);//对除第2个（胡牌）以外的其他状态进行扩展
        }
        I void DP()//DP求解答案
        {
            for(RI i=f[0][0][1]=1,j,k,t;i<=n;++i) for(j=m;~j;--j)//枚举当前是第i张牌，共摸了j张牌
                for(k=1;k<=tot;++k) if(f[i-1][j][k]) for(t=0;t<=4-a[i];++t)//枚举在胡牌自动机哪个节点上，以及现在摸的牌数
                    Inc(f[i][j+t][O[k].S[a[i]+t]],1LL*f[i-1][j][k]*C(4-a[i],t)%X);//转移，注意乘上组合数系数
        }
}H;
I void CInit(CI x)//初始化
{
    RI i;for(Fac[0]=i=1;i<=x;++i) Fac[i]=1LL*Fac[i-1]*i%X;//初始化阶乘
    for(Inv[x]=Qinv(Fac[x]),i=x-1;~i;--i) Inv[i]=1LL*Inv[i+1]*(i+1)%X;//初始化阶乘逆元
}
#define Calc(x,y) Inc(ans,1LL*H.f[n][x][y]*Fac[i]%X*Fac[m-i]%X)//统计答案
int main()
{
    RI i,j,x,y,ans=0;for(H.Build(),scanf("%d",&n),i=1;i<=13;++i) scanf("%d%d",&x,&y),++a[x];//读入数据+预处理
    for(m=(n<<2)-13,CInit(m),H.DP(),i=1;i<=m;++i) for(Calc(i,1),j=3;j<=H.tot;++j) Calc(i,j);//统计答案，注意跳过2号节点
    return printf("%lld",1LL*ans*Inv[m]%X+1),0;//输出答案，除以总状态数然后加1
}
```

## 写出大模拟的代码

CSP 202104-3 DHCP 服务器 我的考场代码。

你应当能分辨出，这段代码比上面的代码好，但是仍有很多值得改进的地方。

```cpp
#include <iostream>
#include <cstdio>
#include <string>
#include <cstring>
#include <set>
#include <map>
#include <unordered_map>
using namespace std;
int N, n, t, Tmin, Tdef, Tmax, ipaddr, exprt, num;
char tpe[1005];
string H, sendHost, recHost;
struct IP {
    int stat; // 0 weifenpei, 1 daifenpei, 2 zhanyong, 3 guoqi
    int zyz; // zhan yong zhe, 0 null
    int gqsk; // guo qi shi ke
    /*IP(int _stat, int _zyz, int _gqsk) {
        stat = _stat;
        zyz = _zyz;
        gqsk = _gqsk;
    }*/
}ip[10005];
unordered_map<string, int> mp;
unordered_map<int, string> pm;
set<int> ipset[4]; // dui ying 4 zhong zhuang tai
void tick(int ti) {
    set<int>::iterator it = ipset[1].begin();
    while (it != ipset[1].end()) {
        int qwq = *it;
        it++;
        if (ip[qwq].gqsk <= ti) {
            ipset[1].erase(qwq);
            ip[qwq].stat = 0;
            ip[qwq].zyz = 0;
            ip[qwq].gqsk = 0;
            ipset[0].insert(qwq);
        }
    }
    it = ipset[2].begin();
    while (it != ipset[2].end()) {
        int qwq = *it;
        it++;
        if (ip[qwq].gqsk <= ti) {
            ipset[2].erase(qwq);
            ip[qwq].stat = 3;
            ip[qwq].gqsk = 0;
            ipset[3].insert(qwq);
        }
    }
}
int main() {
    cin>>N>>Tdef>>Tmax>>Tmin>>H;
    mp[H] = ++num;
    pm[num] = H;
    for (int i = 1; i <= N; i++) {
        ip[i].stat = 0;
        ip[i].zyz = 0;
        ip[i].gqsk = 0;
        ipset[0].insert(i);
    }
    int ti;
    cin>>n;
    while (n--) {
        scanf("%d", &ti);
        cin>>sendHost>>recHost;
        if (!mp.count(sendHost)) {
            mp[sendHost] = ++num;
            pm[num] = sendHost;
        }
        if (!mp.count(recHost)) {
            mp[recHost] = ++num;
            pm[num] = recHost;
        }
        scanf("%s", tpe);
        scanf("%d %d", &ipaddr, &exprt);
        tick(ti);
        if (recHost != H && recHost != "*" && strcmp(tpe, "REQ")) {
            continue;
        }
        if (strcmp(tpe, "REQ") && strcmp(tpe, "DIS")) {
            continue;
        }
        if (recHost == "*" && strcmp(tpe, "DIS")) {
            continue;
        }
        if (recHost == H && strcmp(tpe, "DIS") == 0) {
            continue;
        }
        if (strcmp(tpe, "DIS") == 0) {
            int foundIp = 0;
            for (int i = 1; i < 4; i++) {
                set<int>::iterator it = ipset[i].begin();
                while (it != ipset[i].end()) {
                    int qwq = *it;
                    if (ip[qwq].zyz == mp[sendHost]) {
                        foundIp = qwq;
                        break;
                    }
                    it++;
                }
            }
            if (!foundIp) {
                if (ipset[0].begin() != ipset[0].end()) {
                    foundIp = *(ipset[0].begin());
                }
            }
            if (!foundIp) {
                if (ipset[3].begin() != ipset[3].end()) {
                    foundIp = *(ipset[3].begin());
                }
            }
            if (!foundIp) {
                continue;
            }
            ipset[ip[foundIp].stat].erase(foundIp);
            ip[foundIp].stat = 1;
            ip[foundIp].zyz = mp[sendHost];
            ipset[1].insert(foundIp);
            if (exprt == 0) {
                ip[foundIp].gqsk = ti + Tdef;
            } else {
                int will_expired = exprt - ti;
                if (will_expired < Tmin) {
                    ip[foundIp].gqsk = Tmin + ti;
                } else if (will_expired > Tmax) {
                    ip[foundIp].gqsk = Tmax + ti;
                } else {
                    ip[foundIp].gqsk = exprt;
                }
            }
            cout<<H<<" "<<sendHost;
            printf(" OFR %d %d\n", foundIp, ip[foundIp].gqsk);
        } else {
            if (recHost != H) {
                set<int>::iterator it = ipset[1].begin();
                while (it != ipset[1].end()) {
                    int qwq = *it;
                    it++;
                    if (ip[qwq].zyz == mp[sendHost]) {
                        ip[qwq].zyz = ip[qwq].gqsk = 0;
                        ip[qwq].stat = 0;
                        ipset[1].erase(qwq);
                        ipset[0].insert(qwq);
                    }
                }
                continue;
            }
            if (ipaddr < 0 || ipaddr > N || ip[ipaddr].zyz != mp[sendHost]) {
                cout<<H<<" "<<sendHost;
                printf(" NAK %d %d\n", ipaddr, 0);
                continue;
            }
            ipset[ip[ipaddr].stat].erase(ipaddr);
            ip[ipaddr].stat = 2;
            ip[ipaddr].zyz = mp[sendHost];
            ipset[2].insert(ipaddr);
            if (exprt == 0) {
                ip[ipaddr].gqsk = ti + Tdef;
            } else {
                int will_expired = exprt - ti;
                if (will_expired < Tmin) {
                    ip[ipaddr].gqsk = Tmin + ti;
                } else if (will_expired > Tmax) {
                    ip[ipaddr].gqsk = Tmax + ti;
                } else {
                    ip[ipaddr].gqsk = exprt;
                }
            }
            cout<<H<<" "<<sendHost;
            printf(" ACK %d %d\n", ipaddr, ip[ipaddr].gqsk);
        }
    }
    return 0;
}
```