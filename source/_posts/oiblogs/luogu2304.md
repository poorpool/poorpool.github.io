---
title: luogu2304 [NOI2015]小园丁与老司机
date: 2018-06-25 08:13:11
categories:
  - OI
  - 图论
tags: 图论——网络流
---
[ref](https://blog.csdn.net/litble/article/details/80463466)，神仙题，不会。

<!--more-->

还打破了我码长纪录……

```cpp
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cstdio>
#include <vector>
#include <queue>
using namespace std;
int n, f[50005];
vector<int> vec[50005];
struct Point{
	int x, y, b1, b2, id;
}pt[50005];
namespace work1{
	int liX[50005], liY[50005], liB1[50005], liB2[50005], cntLiX, cntLiY, cntLiB1, cntLiB2;
	int oriX[50005], oriY[50005], bucX[50005], bucB1[50005], bucB2[50005], movU[50005];
	int movL[50005], movR[50005], fUp[50005], gUp[50005], g[50005];
	bool cmp1(Point a, Point b){
		return a.y>b.y;
	}
	bool cmp2(Point a, Point b){
		return a.x<b.x;
	}
	void liSanHua(){
		for(int i=1; i<=n; i++){
			liX[++cntLiX] = pt[i].x;
			liY[++cntLiY] = pt[i].y;
			pt[i].b1 = liB1[++cntLiB1] = pt[i].y - pt[i].x;
			pt[i].b2 = liB2[++cntLiB2] = pt[i].x + pt[i].y;
			pt[i].id = i;
		}
		sort(liX+1, liX+1+cntLiX);
		sort(liY+1, liY+1+cntLiY);
		sort(liB1+1, liB1+1+cntLiB1);
		sort(liB2+1, liB2+1+cntLiB2);
		cntLiX = unique(liX+1, liX+1+cntLiX) - liX - 1;
		cntLiY = unique(liY+1, liY+1+cntLiY) - liY - 1;
		cntLiB1 = unique(liB1+1, liB1+1+cntLiB1) - liB1 - 1;
		cntLiB2 = unique(liB2+1, liB2+1+cntLiB2) - liB2 - 1;
		for(int i=1; i<=n; i++){
			pt[i].x = lower_bound(liX+1, liX+1+cntLiX, pt[i].x) - liX;
			pt[i].y = lower_bound(liY+1, liY+1+cntLiY, pt[i].y) - liY;
			oriX[i] = pt[i].x; oriY[i] = pt[i].y;
			pt[i].b1 = lower_bound(liB1+1, liB1+1+cntLiB1, pt[i].b1) - liB1;
			pt[i].b2 = lower_bound(liB2+1, liB2+1+cntLiB2, pt[i].b2) - liB2;
		}
	}
	void preWork(){
		sort(pt+1, pt+1+n, cmp1);
		for(int i=1; i<=n; i++){
			movU[pt[i].id] = bucX[pt[i].x];
			movR[pt[i].id] = bucB1[pt[i].b1];
			movL[pt[i].id] = bucB2[pt[i].b2];
			bucX[pt[i].x] = bucB1[pt[i].b1] = bucB2[pt[i].b2] = pt[i].id;
		}
		sort(pt+1, pt+1+n, cmp2);
		for(int i=1; i<=n; i++)
			vec[pt[i].y].push_back(pt[i].id);
	}
	void trueWork(){
		for(int y=cntLiY; y; y--){
			int tmpMx=0, tmpId=0, sz=vec[y].size();
			for(int i=0; i<sz; i++){
				int x=vec[y][i];
				if(movU[x] && f[movU[x]]>fUp[x])	fUp[x] = f[movU[x]], gUp[x] = movU[x];
				if(movL[x] && f[movL[x]]>fUp[x])	fUp[x] = f[movL[x]], gUp[x] = movL[x];
				if(movR[x] && f[movR[x]]>fUp[x])	fUp[x] = f[movR[x]], gUp[x] = movR[x];
				f[x] = tmpMx; g[x] = tmpId;
				if(tmpMx<sz-i+fUp[x])	tmpMx = sz - i + fUp[x], tmpId = x;
			}
			tmpMx = 0; tmpId = 0;
			for(int i=sz-1; i>=0; i--){
				int x=vec[y][i];
				if(f[x]<fUp[x]+1)	f[x] = fUp[x] + 1, g[x] = x;
				if(f[x]<tmpMx)	f[x] = tmpMx, g[x] = tmpId;
				if(i+1+fUp[x]>tmpMx)	tmpMx = i + 1 + fUp[x], tmpId = x;
			}
		}
	}
	void prt(int x){
		int y=oriY[x], sz=vec[y].size(), nxt=g[x];
		if(x!=n)	printf("%d ", x);
		if(oriX[nxt]<oriX[x]){
			for(int i=0; i<sz; i++)
				if(oriX[vec[y][i]]>oriX[x])
					printf("%d ", vec[y][i]);
			for(int i=sz-1; i>=0; i--)
				if(oriX[vec[y][i]]<oriX[x] && oriX[vec[y][i]]>=oriX[nxt])
					printf("%d ", vec[y][i]);
		}
		else if(oriX[nxt]>oriX[x]){
			for(int i=sz-1; i>=0; i--)
				if(oriX[vec[y][i]]<oriX[x])
					printf("%d ", vec[y][i]);
			for(int i=0; i<sz; i++)
				if(oriX[vec[y][i]]>oriX[x] && oriX[vec[y][i]]<=oriX[nxt])
					printf("%d ", vec[y][i]);
		}
		if(gUp[nxt])	prt(gUp[nxt]);
	}
	void main(){
		liSanHua();
		preWork();
		trueWork();
		printf("%d\n", f[n]-1);
		prt(n);
	}
}
namespace work2{
	int hea[50005], cnt, du[50005], ss, tt, ans, cur[50005], lev[50005];
	const int oo=0x3f3f3f3f;
	bool isOk[50005];
	queue<int> d;
	struct Edge{
		int too, nxt, val;
	}edge[5000005];
	void add_edge(int fro, int too, int val){
		edge[cnt].nxt = hea[fro];
		edge[cnt].too = too;
		edge[cnt].val = val;
		hea[fro] = cnt++;
	}
	void addEdge(int fro, int too, int val){
		add_edge(fro, too, val);
		add_edge(too, fro, 0);
	}
	void addEDGE(int fro, int too){
		for(int i=hea[fro]; i!=-1; i=edge[i].nxt)
			if(edge[i].too==too)
				return ;
		du[too]++; du[fro]--; isOk[too] = true;
		addEdge(fro, too, oo);
	}
	void calc(int a, int b){
		int sz=vec[a].size(), x=vec[a][b];
		for(int i=0; i<b; i++){
			int k=vec[a][i];
			if(work1::movU[k] && f[work1::movU[k]]+sz-i==f[x])	addEDGE(k, work1::movU[k]);
			if(work1::movL[k] && f[work1::movL[k]]+sz-i==f[x])	addEDGE(k, work1::movL[k]);
			if(work1::movR[k] && f[work1::movR[k]]+sz-i==f[x])	addEDGE(k, work1::movR[k]);
		}
		for(int i=b+1; i<sz; i++){
			int k=vec[a][i];
			if(work1::movU[k] && f[work1::movU[k]]+i+1==f[x])	addEDGE(k, work1::movU[k]);
			if(work1::movL[k] && f[work1::movL[k]]+i+1==f[x])	addEDGE(k, work1::movL[k]);
			if(work1::movR[k] && f[work1::movR[k]]+i+1==f[x])	addEDGE(k, work1::movR[k]);
		}
		if(work1::movU[x] && f[work1::movU[x]]+1==f[x])	addEDGE(x, work1::movU[x]);
		if(work1::movL[x] && f[work1::movL[x]]+1==f[x])	addEDGE(x, work1::movL[x]);
		if(work1::movR[x] && f[work1::movR[x]]+1==f[x])	addEDGE(x, work1::movR[x]);
	}
	void build(){
		memset(hea, -1, sizeof(hea));
		isOk[n] = true;
		for(int i=1; i<=work1::cntLiY; i++)
			for(int j=0; j<vec[i].size(); j++)
				if(isOk[vec[i][j]])
					calc(i, j);
		ss = n + 1; tt = n + 2;
		for(int i=1; i<=n; i++)
			if(du[i]>0)	addEdge(ss, i, du[i]), ans += du[i];
			else if(du[i]<0)	addEdge(i, tt, -du[i]);
	}
	bool bfs(){
		memset(lev, 0, sizeof(lev));
		d.push(ss);
		lev[ss] = 1;
		while(!d.empty()){
			int x=d.front();
			d.pop();
			for(int i=hea[x]; i!=-1; i=edge[i].nxt){
				int t=edge[i].too;
				if(!lev[t] && edge[i].val>0){
					d.push(t);
					lev[t] = lev[x] + 1;
				}
			}
		}
		return lev[tt]!=0;
	}
	int dfs(int x, int lim){
		if(x==tt)	return lim;
		int addFlow=0;
		for(int &i=cur[x]; i!=-1; i=edge[i].nxt){
			int t=edge[i].too;
			if(lev[t]==lev[x]+1 && edge[i].val>0){
				int tmp=dfs(t, min(lim-addFlow, edge[i].val));
				addFlow += tmp;
				edge[i].val -= tmp;
				edge[i^1].val += tmp;
				if(addFlow==lim)	break;
			}
		}
		return addFlow;
	}
	void main(){
		build();
		while(bfs()){
			for(int i=1; i<=tt; i++)	cur[i] = hea[i];
			ans -= dfs(ss, oo);
		}
		cout<<endl<<ans<<endl;
	}
}
int main(){
	cin>>n;
	for(int i=1; i<=n; i++)
		scanf("%d %d", &pt[i].x, &pt[i].y);
	n++;
	work1::main();
	work2::main();
	return 0;
}
```