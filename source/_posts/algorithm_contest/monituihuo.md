---
title: 模拟退火
date: 2021-02-10 13:59:27
tags:
- 模拟退火
categories:
- OI
- 乱搞
---
其实这玩意很好理解，首先看：[讲解](https://www.cnblogs.com/flashhu/p/8884132.html)

<!--more-->

做题，luogu 1337，[讲解](https://www.cnblogs.com/flashhu/p/8900466.html)

```cpp
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <cmath>
using namespace std;
const double eps = 1e-14;
const double bei = 0.99;
int n, x[1005], y[1005], w[1005];
double best, bx, by; // 全局最优结果
double calc(double xx, double yy) {
    double ret = 0.0;
    for (int i = 1; i <= n; i++) {
        ret += sqrt((xx-x[i])*(xx-x[i])+(yy-y[i])*(yy-y[i])) * w[i];
    }
    return ret;
}
int main() {
    srand(time(NULL));
    cin>>n;
    for (int i = 1; i <= n; i++) {
        scanf("%d %d %d", &x[i], &y[i], &w[i]);
        bx += x[i];
        by += y[i];
    }
    bx /= n;
    by /= n;
    best = calc(bx, by);
    int Times = 5; // 退火五次，每次从全局最优开始退火
    while (Times--) {
        double ans = best, xx = bx, yy = by;
        for (double T = 100000.0; T > eps; T *= bei) {
            double dx = xx + (double)T * (2.0 * rand() - RAND_MAX); // 要有正负，但是这个改变量就是玄学
            double dy = yy + (double)T * (2.0 * rand() - RAND_MAX);
            double ret = calc(dx, dy);
            if (best > ret) {
                best = ret;
                bx = dx;
                by = dy;
            }
            if (ans > ret || (1.0 * rand() / RAND_MAX <= exp((ans-ret)/T))) {
                ans = ret;
                xx = dx;
                yy = dy;
            }
        }
    }
    printf("%.3f %.3f\n", bx, by);
    return 0;
}
```

LOJ [BalticOI 2012 Day2]俄罗斯方块 

（luogu 的不好使）

模拟退火能调出来五十分的

solver:

```cpp
#include "solver.h"
#include <iostream>
#include <cstring>
#include <cstdio>
using namespace std;
int n, uu;
bool block[15][5][5];
bool board[15][15], tmpb[15][15]; // col 1-9, row 1-9
/*
row
4 0 0 0
3 1 1 0
2 1 0 0
1 0 0 0
  1 2 3 col first
col 1, row 2 is always the note block
*/
char fileName[1005];
double zxxd[15]={0, 0.5, 1.0, 0.5, 1.5, 0.5, 1.0, 1.0, 1.0, 0.0}; // 重心相对 note 块 底边的高度
int height[15]={0, 1, 2, 1, 3, 1, 2, 2, 2, 1};// 最高边相对note块底边的高度
// tmp
int canSet(bool tmp[15][15], int col, int bt) { // 可以的话就返回 row
    int ret = 0;
    for (int row = 10-height[bt]; row >= 1 ; row--) {
        // note 希望在 col 列 row 行
        bool flag = true;
        for (int i = 1; i <= 3; i++)
            for (int j = 1; j <= 4; j++) 
                if (block[bt][i][j]) {
                    int ri = col + i - 1;
                    int rj = row + j - 2;
                    if (!(ri >= 1 && ri <= 9 && rj >= 1 && rj <= 9 && !tmp[ri][rj])) {
                        flag = false;
                    }
                }
        if (flag)   ret = row;
        else    break;
    }
    return ret;
}

// tmp
void setNotClear(bool tmp[15][15], int col, int row, int bt) {
    for (int i = 1; i <= 3; i++)
        for (int j = 1; j <= 4; j++) 
            if (block[bt][i][j])
                tmp[col+i-1][row+j-2] = true;
}

// tmp
bool canClear(bool tmp[15][15], int row) {
    for (int i = 1; i <= 9; i++)
        if (!tmp[i][row])
            return false;
    return true;
}

// tmp
void clearRow(bool tmp[15][15], int row) {
    for (int i = row; i <= 9; i++)
        for (int j = 1; j <= 9; j++)
            tmp[j][i] = tmp[j][i+1];
}

int colDiffInRow(int row) {
    int ret = 0;
    for (int i = 2; i <= 9; i++)
        if (tmpb[i-1][row] != tmpb[i][row])
            ret++;
    return ret;
}

int rowDiffInCol(int col) {
    int ret = 0;
    for (int i = 2; i <= 9; i++)
        if (tmpb[col][i-1] != tmpb[col][i])
            ret++;
    return ret;
}

int getJiao(int bt, int row) {
    int ret = 0;
    if (row <= 4 && row >= 1)
        for (int i = 1; i <= 3; i++)
            ret += block[bt][i][row];
    return ret;
}

// tmpb
int getHoles() {
    int ret = 0;
    for (int i = 1; i <= 9; i++) {
        bool flag = false;
        for (int j = 9; j >= 1; j--) {
            flag |= tmpb[i][j];
            if (!tmpb[i][j] && flag)    ret++;
        }
    }
    return ret;
}

//tmpb
int getWells() {
    int ret = 0;
    for (int i = 1; i <= 9; i++) {
        int jing = 0;
        for (int j = 1; j <= 9; j++)
            if (tmpb[i][j])
                jing = 0;
            else {
                if ((i==1 && tmpb[2][j]) || (i==9 && tmpb[8][j]) || (i >= 2 && i <= 8 && tmpb[i-1][j] && tmpb[i+1][j])) {
                    jing++;
                    ret += jing;
                } else {
                    jing = 0;
                }
            }
    }
    //printf("jing %d\n", ret);
    return ret;
}

//double chang[6] = {-4.500158825082766,3.4181268101392694, -3.2178882868487753,-9.348695305445199,-7.899265427351652,-3.3855972247263626};
double chang[6]={
-108.1552516822,
93.4515835788,
-33.8268913751,
-36.4696344915,
-165.6161517320,
-34.6613258266
};

double getScore(int col, int row, int bt) { // note 在 col 列 row 行
    double landingHeight = row + zxxd[bt];
    double rowsEliminated = 0.0;
    double rowTransitions = 0.0;
    double colTransitions = 0.0;
    setNotClear(tmpb, col, row, bt);
    int jiao = 0;
    for (int i = 1, trueI=1; i <= 9; i++, trueI++)
        if (canClear(tmpb, i)) {
            rowsEliminated += 1.0;
            clearRow(tmpb, i);
            i--;
            jiao += getJiao(bt, trueI-row+2);
        }
    if (jiao == 0 && rowsEliminated > 0.1) {
        printf("impossible!\n");
    }
    rowsEliminated *= jiao;
    for (int i = 1; i <= 9; i++) {
        rowTransitions += colDiffInRow(i);
        colTransitions += rowDiffInCol(i);
    }
    double holeNums = getHoles();
    double wells = getWells();
    //printf("col %d:\n%.3f\n%.3f\n%.3f\n%.3f\n%.3f\n%.3f\n\n", col, landingHeight, rowsEliminated, rowTransitions, colTransitions, holeNums, wells);
    return chang[0] * landingHeight
            + chang[1] * rowsEliminated
            + chang[2] * rowTransitions
            + chang[3] * colTransitions // fixme: 这个行列变化错了！
            + chang[4] * holeNums
            + chang[5] * wells;
}

int setter(int bt) {
    int idx = -1, row;
    double sco = 0.0, score = 0.0;

    for (int i = 1; i <= 9; i++) {
        memcpy(tmpb, board, sizeof(board));
        row = canSet(tmpb, i, bt);
        //printf("col %d, row %d\n", i, row);
        if (row) {
            score = getScore(i, row, bt);
            if (idx == -1 || score > sco) {
                sco = score;
                idx = i;
            }
        }
    }
    return idx;
}

void setBlock(int col, int bt) {
    int row = canSet(board, col, bt);
    //printf("block %d to %d col, %d row\n", bt, col, row);
    setNotClear(board, col, row, bt);
    for (int i = 1, trueI=1; i <= 9; i++, trueI++)
        if (canClear(board, i)) {
            clearRow(board, i);
            i--;
        }
}

double solve(int number) {
    sprintf(fileName, "tiny%d.in", number);
    FILE *inFp = fopen(fileName, "r");
    sprintf(fileName, "tiny.o%d", number);
    FILE *outFp = fopen(fileName, "w");
    memset(board, false, sizeof(board));

    int solved = 0, ret;
    fscanf(inFp, "%d", &n);
    //printf("#%d has %d blocks\n", number, n);

    for (int i = 1; i <= n; i++) {
        fscanf(inFp, "%d", &uu);
        ret = setter(uu);

        /*printf("\n");
        for (int row = 4; row >= 1; row--) {
            for (int col = 1; col <= 3; col++) {
                putchar(block[uu][col][row] ? '#' : ' ');
            }
            printf("\n");
        }
        printf("\n");
        for (int row = 9; row >= 1; row--) {
            for (int col = 1; col <= 9; col++) {
                putchar(board[col][row] ? '#' : '_');
                putchar(' ');
            }
            printf("\n");
        }
        getchar();*/
        if (ret == -1) {
            break;
        } else {
            setBlock(ret, uu);
            solved++;
            fprintf(outFp, "%d\n", ret);
        }
    }

    //printf("#%d: solved %d out of %d, rate %.2f\n", number, solved, n, 1.0 * solved / n);
    fclose(inFp);
    fclose(outFp);
    return 1.0*solved/n;
}
double mnthjk(double cchang[]) {
    for (int i = 0; i < 6; i++)
        chang[i] = cchang[i];
    FILE *blockFp = fopen("blocks.txt", "r");
    for (int i = 1; i <= 9; i++)
        for (int row = 4; row >= 1; row--)
            for (int col = 1; col <= 3; col++) {
                fscanf(blockFp, "%d", &uu);
                block[i][col][row] = uu > 0;
            }
    double ret = 0.0;
    for (int i = 1; i <= 5; i++)    ret +=solve(i);
    fclose(blockFp);
    return ret;
}

int main() {
    FILE *blockFp = fopen("blocks.txt", "r");
    for (int i = 1; i <= 9; i++)
        for (int row = 4; row >= 1; row--)
            for (int col = 1; col <= 3; col++) {
                fscanf(blockFp, "%d", &uu);
                block[i][col][row] = uu > 0;
            }
    for (int i = 1; i <= 5; i++)    solve(i);
    fclose(blockFp);
    return 0;
}
```

mnth

```cpp
#include "solver.h"
const double eps = 1e-5;
const double bei = 0.97;
extern double mnthjk(double ccss[]);
double css[6] = {
-108.1552516822,
93.4515835788,
-33.8268913751,
-36.4696344915,
-165.6161517320,
-34.6613258266
};

double bcss[6], ecss[6], fcss[6];

int main() {
    srand(time(NULL));
    
    for (int i = 0; i < 6; i++)
        bcss[i] = css[i];
    double best = mnthjk(bcss);
    FILE *fp = fopen("best_para.txt", "w");
    fprintf(fp, "bret %.3f\n", best);
    for (int i = 0; i < 6; i++)
            fprintf(fp, "%.10f\n", bcss[i]);
    fclose(fp);
    int Times = 5; // 退火五次，每次从全局最优开始退火
    while (Times--) {
        double ans = best;
        for (int i = 0; i < 6; i++) {
            ecss[i] = bcss[i];
        }
        int cnt = 0;
        for (double T = 100000.0; T > eps; T *= bei) {
            for (int i = 0; i < 6; i++) {
                fcss[i] = ecss[i] + (double)T * (2.0 * rand() - RAND_MAX)/RAND_MAX/  5000.0;
            }
            double ret = mnthjk(fcss);
            cnt++;
            printf("cnt %d, T %.3f\n ret %.3f, best %.3f\n\n", cnt, T ,ret,best);
            if (best < ret) {
                best = ret;
                for (int i = 0; i < 6; i++)
                    bcss[i] = fcss[i];
                FILE *fp = fopen("best_para.txt", "w");
                fprintf(fp, "bret %.3f\n", best);
                for (int i = 0; i < 6; i++)
                    fprintf(fp, "%.10f\n", bcss[i]);
                fclose(fp);
            }
            if (ans < ret || (1.0 * rand() / RAND_MAX <= exp((ret-ans)/T))) {
                ans = ret;
                for (int i = 0; i < 6; i++)
                    ecss[i] = fcss[i];
            }
        }
        printf("bret %.3f\n", best);
        for (int i = 0; i < 6; i++)
            printf("%.10f\n", bcss[i]);
    }
    
    return 0;
}
```
