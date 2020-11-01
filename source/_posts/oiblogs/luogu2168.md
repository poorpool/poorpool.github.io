---
title: luogu2168 [NOI2015]荷马史诗
date: 2018-06-22 21:29:09
categories:
  - OI
  - 字符串
tags: 字符串——编码
---
对于我这种没学过哈夫曼树的人极不友好……

<!--more-->

[ref](https://blog.csdn.net/cqbzwja/article/details/46974241)

```cpp
#include <iostream>
#include <cstdio>
#include <queue>
using namespace std;
typedef long long ll;
int n, k;
ll ans;
struct Node{
	ll w;
	int d;
}nd[100015];
struct cmp{
	bool operator()(const Node &a, const Node &b)const{
		if(a.w!=b.w)	return a.w>b.w;
		else	return a.d>b.d;
	}
};
priority_queue<Node, vector<Node>, cmp> q;
int main(){
	cin>>n>>k;
	for(int i=1; i<=n; i++){
		scanf("%lld", &nd[i].w);
		nd[i].d = 1;
	}
	if((n-1)%(k-1)){
		int t=k-1-(n-1)%(k-1);
		while(t--)
			nd[++n] = (Node){0, 1};
	}
	for(int i=1; i<=n; i++)
		q.push(nd[i]);
	while(n!=1){
		Node tmp=(Node){0, 0};
		for(int i=1; i<=k; i++){
			Node u=q.top();
			q.pop();
			tmp.w += u.w; tmp.d = max(u.d, tmp.d);
			n--;
		}
		tmp.d++;
		ans += tmp.w;
		q.push(tmp);
		n++;
	}
	cout<<ans<<endl<<q.top().d-1;
	return 0;
}
```