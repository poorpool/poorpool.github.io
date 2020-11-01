---
title: skip-list
date: 2019-10-18 20:01:03
tags: 跳表
categoies: 数据结构
---
联创考试的时候让学跳表，学了以下。

跟 $k$ 有关的操作可以查indexed skip list之类的？

写了好久（摔！

<!--more-->

```cpp
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <climits>
#include <cstring>
#include <ctime>
#define MAXLEVEL 15
struct Random {//一个创造随机级别的结构体
    Random() {
        srand((int)time(NULL));
    }
    int makeRandomInt(int higher) {//产生一个在[1, higher]之间的级别
        int re=1;
        while(re<higher) {
            if(rand()%10<5) re++;
            else    break;
        }
        return re;
    }
}randomInt;
struct SkipList {
    struct Node {
        int key;
        struct Level { //每一个节点都有指向每一层的前向指针
            Node *forward;
            int width;//每条线多长
        }level[MAXLEVEL]; 
    };
    int level;//跳表的高度
    int length;//总共多少个
    Node *header;
    Node * createNode(int itsLevel, int key) {
        Node *node=(Node *)malloc(sizeof(*node));
        // printf("%d\n", sizeof(*node));
        node->key = key;
        return node;
    }
    SkipList() {
        level = 1;
        header = createNode(MAXLEVEL, 0);
        for(int i=0; i<MAXLEVEL; i++) {
            header->level[i].forward = NULL;
            header->level[i].width = 0;
        }
    }
    Node *findNode(int key) {//辅助函数，找到node
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward!=NULL && key>node->level[i].forward->key)
                node = node->level[i].forward;
        }
        if(node->level[0].forward!=NULL && node->level[0].forward->key==key) {
            return node->level[0].forward;
        }
        else    return NULL;
    }
    void insert(int key) {
        if(findNode(key)) {
            printf("错误！请不要重复插入相同的数字，您的这次插入无效。\n");
            return ;
        }
        int itsLevel=randomInt.makeRandomInt(MAXLEVEL);
        int stepsAtMove[MAXLEVEL];
        memset(stepsAtMove, 0, sizeof(stepsAtMove));
        Node *behinds[MAXLEVEL];//每一层刚好被node卡在后头的那个节点
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward!=NULL && key>node->level[i].forward->key) {
                
                stepsAtMove[i] += node->level[i].width;
                node = node->level[i].forward;
                
            }
            behinds[i] = node;
        }
        node = createNode(itsLevel, key);
        // printf("%p\n", node);
        if(itsLevel>level) {
            for(int i=level; i<itsLevel; i++)   behinds[i] = header;
            level = itsLevel;
        }
        int steps=0;
        for(int i=0; i<level; i++) {
            node->level[i].forward = behinds[i]->level[i].forward;
            behinds[i]->level[i].forward = node;
            node->level[i].width = behinds[i]->level[i].width-steps;//behinds到node那个点在上一层差下多少steps
            behinds[i]->level[i].width = steps + 1;
            steps += stepsAtMove[i];
        }
        for(int i=level; i<MAXLEVEL; i++)
            header->level[i].width++;
        length++;
        printf("插入成功。\n");
    }
    void dele(int key) {//还没更新width
        if(findNode(key)==NULL) {
            printf("错误！您不能删除一个不存在的数。\n");
            return ;
        }
        Node *behinds[MAXLEVEL];//每一层刚好被node卡在后头的那个节点
        Node *node=header;
        // printf("%d as level\n", level);
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward!=NULL && key>node->level[i].forward->key) {
                node = node->level[i].forward;
            }
            behinds[i] = node;
            // printf("behinds%d: %p\n", i, behinds[i]);
        }
        node = node->level[0].forward;
        for(int i=0; i<level; i++) {
            if(behinds[i]->level[i].forward==node) {
                behinds[i]->level[i].width =  behinds[i]->level[i].forward->level[i].width - 1;
                behinds[i]->level[i].forward = node->level[i].forward;
            }
        }
        for(int i=level; i<MAXLEVEL; i++)   header->level[i].width--;
        while(level>1 && header->level[level-1].forward==NULL)  level--;
        free(node);
        length--;
        printf("删除成功！\n");
    }
    int findkth(int key) {
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward && key>=node->level[i].width) {
                key -= node->level[i].width;
                node = node->level[i].forward;
            }
        }
        return node->key;
    }
    void whichRank(int key) {
        if(findNode(key)==NULL) {
            printf("这个数不存在！\n");
            return ;
        }
        int steps=0;
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward && key>node->level[i].forward->key) {
                steps += node->level[i].width;
                node = node->level[i].forward;
            }
        }
        printf("%d是第%d大。\n", key, steps+1);
    }
    void whichAfter(int key) {
        Node *re=findNode(key);
        if(re==NULL)    printf("您给的数字不存在！\n");
        else if(re->level[0].forward==NULL) printf("%d的后继不存在！\n", key);
        else    printf("%d的后继是%d。\n", key, re->level[0].forward->key);
    }
    void query(int l, int r) {
        printf("符合条件的有：[ ");
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward && l>node->level[i].forward->key) {
                node = node->level[i].forward;
            }
        }
        node = node->level[0].forward;
        while(node!=NULL && node->key>=l && node->key<=r) {
            printf("%d ", node->key);
            node = node->level[0].forward;
        }
        printf("]。\n");
    }
    void rangeDele(int l, int r) {
        Node *node=header;
        for(int i=level-1; i>=0; i--) {
            while(node->level[i].forward && l>node->level[i].forward->key) {
                node = node->level[i].forward;
            }
        }
        node = node->level[0].forward;
        while(node!=NULL && node->key>=l && node->key<=r) {
            Node *nxt=node->level[0].forward;
            dele(node->key);
            node = nxt;
        }
    }
}skipList;
int main() {
    printf("欢迎来到跳表测试！请按规定输入指令，否则会造成不可预料的错误！\n请输入数字代号并按下回车进行操作。\n");
    printf("1：插入一个数\n");
    printf("2：删除一个数\n");
    printf("3：查看第k大的数字\n");
    printf("4：查看一个数是第几大\n");
    printf("5：询问一个数的后继\n");
    printf("6：输出一个区间里存在的数字\n");
    printf("7：删除一个区间里存在的数字\n");
    printf("8：结束\n");
    while(true) {
        int opr, usr, rsu;
        printf("请输入数字代号：");
        std::cin>>opr;
        switch(opr) {
            case 1:
                printf("请输入你想要插入的数k：\n");
                std::cin>>usr;
                skipList.insert(usr);
                break;
            case 2:
                printf("请输入你想要删除的数k：\n");
                std::cin>>usr;
                skipList.dele(usr);
                break;
            case 3:
                printf("你想要查看第几大的数字？请输入：\n");
                std::cin>>usr;
                if(usr>skipList.length) printf("当前没有这么多数字，本次操作无效。\n");
                else    printf("第%d大的数字是%d。\n", usr, skipList.findkth(usr));
                break;
            case 4:
                printf("你想查看谁是第几大？请输入：\n");
                std::cin>>usr;
                skipList.whichRank(usr);
                break;
            case 5:
                printf("你想查看谁的后继？请输入：\n");
                std::cin>>usr;
                skipList.whichAfter(usr);
                break;
            case 6:
                printf("请输入区间左右端点（中间用空格分开）：\n");
                std::cin>>usr>>rsu;
                skipList.query(usr, rsu);
                break;
            case 7:
                printf("请输入区间左右端点（中间用空格分开）：\n");
                std::cin>>usr>>rsu;
                skipList.rangeDele(usr, rsu);
                break;
            case 8: return 0; break;
            default: break;
        }
    }
    return 0;
}
```