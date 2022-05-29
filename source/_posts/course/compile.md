---
title: 编译原理笔记（20220529上传）
date: 2022-05-29 22:37:22
tags:
- 笔记
- 编译原理
categories:
- 笔记
---
过！过！过！

<!--more-->

## 引论

编译过程：词法分析、语法分析、语义分析、中间代码生成、代码优化、目标代码生成

## 文法和语言

### 符号和符号串-文法的基本要素

字母表∑是非空有穷集合，其元素称为符号。由字母表∑中的符号组成的有穷序列称为 (字母表∑上的)符号串. 不含任何符号的有穷序列称为空串,记为ε。符号串α的长度是指符号串α中含有符号的个数，记为︱α︱。如果集合A的元素都是字母表∑上的符号串，则称集合A为∑上的符号串集合，简称串集。 

设字母表∑＝｛a，b，c｝，A＝｛ε，a，ba，cab｝，B＝｛a1，ba，cab｝，则 A是∑上的符号串集合，B不是∑上的符号串集合。 

**符号串的运算**：和计算理论中的类似。连接、或、幂、正闭包、星闭包。

**符号串集合的运算**：（笛卡尔）乘积、和、幂、正闭包、星闭包。

![image-20220330223124328](/images/compileprinciple/image-20220330223124328.png)

显然，若A为任意一个字母表，$A^*$就是字母表上所有符号串（包括空串）的集合。

### 文法和语言的形式化定义

![image-20220330223532698](/images/compileprinciple/image-20220330223532698.png)$\alpha ::= \beta$简写为$\alpha \rightarrow \beta$。若P中包含它，则任意的串γαδ 可以推导出γβδ，这是**直接推导/一步推导**，记为γαδ $\Rightarrow$ γβδ。也可以说γβδ归约到γαδ ，这种归约称为**直接归约/一步归约**。

![image-20220331082033770](/images/compileprinciple/image-20220331082033770.png)

若$\alpha \stackrel{+}{\Rightarrow} \beta$或者$\alpha \rightarrow \beta$，则记$\alpha \stackrel{*}{\Rightarrow} \beta$。

**句型和句子**：G[S]  有$S \stackrel{*}{\Rightarrow} \beta$，则称β是文法G[S]的**句型**。若β∈$V_T^*$，则称β是文法G的**句子**。当然，句子也是句型。

文法G产生语言即为其句子的集合，记为L(G)。如果两个文法的产生语言一样，文法就等价。

### 文法的类型

- 0型文法/短语文法/图灵机：一个文法的所有规则，**左侧至少含有一个非终结符**。

- 1型文法/上下文有关文法/线性界限自动机：左侧符号串的**长度不大于**右侧符号串的长度（空规则除外），且**左侧至少含有一个非终结符**。（ γAδ $\Rightarrow$ γβθδ，A被替换成βθ，跟A的上下文相关，因为要match整个 γAδ）

- 2型文法/上下文无关文法：任一产生式左部均为恰**好一个非终结符**

- 3型文法/正规文法/有限自动机：跟教材上不一样！

  ![image-20220331085250128](/images/compileprinciple/image-20220331085250128.png)

  L3真含于L2真含于L1真含于L0。

### 上下文无关文法及其语法树

  最右推导，也叫规范推导。由规范推导所得的句型，叫做规范句型(右句型)。规范推导的逆过程，叫做规范归约。 

  ![image-20220331091635117](/images/compileprinciple/image-20220331091635117.png)

  语法的二义性不等于语言的二义性。二义性文法可能存在等价的非二义性文法。不过语法的二义性问题是不可判定的。

### 句型的分析

  假设文法G[S]是语言L之文法，即L(G)＝L，则“符号串α是否符合语言L的语法问题” 被等价地转化成“推导或归约问题”，即是否$S \stackrel{*}{\Rightarrow} \alpha \and \alpha \in V_T^*$。

  **自顶向下分析法**：从文法开始符号出发，反复使用规则，寻找匹配符号串（推导）的句型，直到推导出句子或穷尽规则也不能推导出。

  要解决的问题：选择句型中哪一个非终结符进行推导、选择非终结符的哪一个规则进行推导。

  容易出现回溯，可以考虑提公因子。

  **自下而上分析法**：从输入符号串α开始，逐步进行“归约”，直至归约出文法的开始符号 S，则输入串α是文法G定义的语言的句子，否则不是

  要解决的问题：如何选择句型α的子串β进行归约。

  按句柄归约-规范归约(移进-归约)

  ![image-20220407081506001](/images/compileprinciple/image-20220407081506001.png)

  总的来说,一个非终结符的树叶组成短语，一个下面就一层的非终结符的树叶组成直接短语。在做推导的时候，ε直接不写。但是在分析短语的时候，ε要写出来。一个句型**最左边的那一个直接短语**，叫做句柄

  ![image-20220407081736004](/images/compileprinciple/image-20220407081736004.png)

### 补充说明-文法中的多余规则和epsilon (ε) 规则

  文法的化简：

  1. 删除A->A这样的有害规则
  2. 删除不终结产生式（永远到不了终结符）
  3. 删除不可用产生式（压根到不了规则左边的非终结符）
  
  4. 删除ε产生式：

  ![image-20220407084113774](/images/compileprinciple/image-20220407084113774.png)

## 词法分析

### 词法分析程序设计

  输出每个词形式 (单词种别，单词自身的值)，单词种别常用enum

### 单词的形式化描述工具

  用正规文法、正规式、有穷自动机三种描述方法。（计算理论人狂喜）

  正规文法：设文法G＝（$V_N$，$V_T$，P，S），如果任意A→β∈ P，A∈ $V_N$ ，且β只能是aB或a或Ɛ, 则称文法G属于右线性3型文法。

  正规式：算符优先级由高到低 ：\*，·，|

### 有穷自动机

  DFA的f: 状态转换(移)函数，为$K\times \Sigma \rightarrow K$的单值部分映射

  DFA的扩展状态转移函数 f' $K\times \Sigma^* \rightarrow K$，编译的DFA好像允许不是每个字母都有状态去转移

  NFA的状态转移函数 $K\times(\Sigma\cup\{ε\})\rightarrow P(K)$，其中P(K)为K的幂集

  NFA 弧上的标记可以是ε，同一个字母可能出现在同一状态射出的多条弧上

  NFA

  ![image-20220414084718054](/images/compileprinciple/image-20220414084718054.png)

  每次都做集合到集合的变换

  ![image-20220414090551991](/images/compileprinciple/image-20220414090551991.png)

  显然$\epsilon-Closure(I)$就是I通过空转移能到达的所有状态的集合

### 各类转换

#### 正规式转正规文法

  ![image-20220414083551890](/images/compileprinciple/image-20220414083551890.png)

  我的评价是计算理论重现江湖

#### 正规文法转正规式

  ![image-20220419081117532](/images/compileprinciple/image-20220419081117532.png) 

#### NFA转DFA

  ![image-20220414090745492](/images/compileprinciple/image-20220414090745492.png)

  画这么一个表：

  |                 | 重命名 | a               | b             |
  | --------------- | ------ | --------------- | ------------- |
  | {0,1,7,2,4}     | 0      | {3,8,6,1,7,2,4} | {5,6,1,7,2,4} |
  | {3,8,6,1,7,2,4} | ...    | ...             | ...           |

  就是首先放进去ε-Closure(S)，然后不断变换。注意每一个变换的结果都是ε-Closure。最后按这个表格重命名画图。

#### DFA的化简

  1. 消除无用状态：不可达，没有通路到达终态；
  2. 合并等价状态（都是终结态/非终结态，任意转换都到等价的状态）

  起初的两个集合先按终结 非终结分类，每次查看有没有一个集合的两个元素的转移结果不在同一个集合里头，那么这两个元素就要拆开。

  ![image-20220414105256495](/images/compileprinciple/image-20220414105256495.png)

#### 正规式和有穷自动机的转换

  NFA转正规式：

  ![image-20220419082022955](/images/compileprinciple/image-20220419082022955.png)

  正规式转NFA：

  ![image-20220419082119908](/images/compileprinciple/image-20220419082119908.png)

  NFA转DFA就是了。

#### 正规文法和有穷自动机的转换

  ![image-20220414092719407](/images/compileprinciple/image-20220414092719407.png)

  ![image-20220414092810437](/images/compileprinciple/image-20220414092810437.png)

## 自顶向下语法分析方法

自顶向下是推导，ANTLR4，LL(1)

![image-20220419083609234](/images/compileprinciple/image-20220419083609234.png)

### 确定的自顶向下语法分析思想

约定好每次选择最左边的非终结符，选择出来一个唯一的产生式

FIRST(α)-串首(终结)符号集

![image-20220419084319905](/images/compileprinciple/image-20220419084319905.png)

FOLLOW(A)-非终结符的后继(终结)符号集。FOLLOW(A)是由任意句型中紧邻非终结符号A之后出现的终结符号a组成的集合。

![image-20220419084959351](/images/compileprinciple/image-20220419084959351.png)

![image-20220419085416649](/images/compileprinciple/image-20220419085416649.png)

SELECT(A→α) - 产生式的可选集

![image-20220419085604298](/images/compileprinciple/image-20220419085604298.png)

文法G是LL(1)的，当且仅当对每个VN，A的两个不同产生式A→α，A→β，满足SELECT(A→α) ∩ SELECT(A→β) = Φ 其中，α、β不能同时推导出ε。确定的无二义性的。

L – Left to right parsing 从左至右分析token
L – Left-most derivation 最左推导
1 –只需向右看1个符号便可以决定选择哪个产生式进行推导

![image-20220419090316698](/images/compileprinciple/image-20220419090316698.png)

### LL(1)文法的判别

文法G是LL(1)的,当且仅当任意两个左部相同的产生式其select集的交集为空。

- 判别$S \stackrel{*}{\Rightarrow} \alpha$ ？仅当α中所有非终结符全部可推导出空，且α无非空的终结符
- 求产生式右部FIRST集, 如产式右部可推导出ε,则还需：
- 计算产生式左部FOLLOW集

**判别能否产生空串**：

![image-20220419101007194](/images/compileprinciple/image-20220419101007194.png)

**求产生式右部FIRST集**：

![image-20220419101319842](/images/compileprinciple/image-20220419101319842.png)

**求follow集合**：

![image-20220419101431945](/images/compileprinciple/image-20220419101431945.png)

### 某些非LL(1)文法到LL(1)文法的等价变换

若文法含有左公共因子，或者含有直接或间接左递归，一定不是LL(1)文法。

先消除左递归，再提取左公因子。

**提取左公因子**：

![image-20220421082139849](/images/compileprinciple/image-20220421082139849.png)

这么不断提取。注意没有左公因子只是一个必要条件。

**消除左递归**：

![image-20220421082420386](/images/compileprinciple/image-20220421082420386.png)

![image-20220421082504587](/images/compileprinciple/image-20220421082504587.png)

**消除一切左递归**：

![image-20220421082740405](/images/compileprinciple/image-20220421082740405.png)

### LL(1)分析的实现-递归下降分析法

将每个非终结符编写成一个递归子程序，选择规则的实现步骤是将输入串“下一个符号”逐个与A规则的选择集进行判定。

### LL(1)分析的实现-表驱动分析法

![image-20220421083325643](/images/compileprinciple/image-20220421083325643.png)

![image-20220421083340220](/images/compileprinciple/image-20220421083340220.png)

## 自底向上优先分析

###  简单优先分析法

![image-20220428081111495](/images/compileprinciple/image-20220428081111495.png)

文法G的符号集V中,任意两个符号之间至多$\lessdot$lessdot、$\gtrdot$gtrdot、$\eqcirc$eqcirc（实在打不出来了）三种简单优先关系之一,且没有相同右部的规则,则文法G称为简单优先文法。

![image-20220428082511008](/images/compileprinciple/image-20220428082511008.png)

###  算符优先分析法

![image-20220428083145749](/images/compileprinciple/image-20220428083145749.png)

![image-20220428083245056](/images/compileprinciple/image-20220428083245056.png)

设不含空规则的文法G为OG文法,如果任意两个终结符之间至多存在$\eqcirc,\lessdot,\gtrdot$三种算符优先关系之一,则称文法G为算符优先文法(Operator Precedence Grammar),简称OPG文法。

![image-20220428083420727](/images/compileprinciple/image-20220428083420727-16511060612761.png)

后面太复杂了，做了作业再截图

![image-20220428084438149](/images/compileprinciple/image-20220428084438149.png)

![image-20220428084500970](/images/compileprinciple/image-20220428084500970.png)

![image-20220428084514951](/images/compileprinciple/image-20220428084514951.png)

![image-20220428084615079](/images/compileprinciple/image-20220428084615079.png)

![image-20220428084626767](/images/compileprinciple/image-20220428084626767.png)

#### 实例

注意：任何句型前后都有一个井号！自己加的。

竖着的是a，横着的是b，内容是a和b的关系

N代表任意非终结符，感觉是根据前一个非终结符的关系来判定，小于和等于就移进。大于规约。

![image-20220502152007125](/images/compileprinciple/image-20220502152007125.png)

![image-20220502152019257](/images/compileprinciple/image-20220502152019257.png)



## LR 分析

语法分析。**本章要对着ppt仔仔细细研究**。

### LR分析概述

LR(k)：L(Left to right parsing), R(right-most derivation in reverse), K(look ahead k token(s))

总控程序、分析栈和分析表三个组成部分，移进-规约法。

![image-20220503084504065](/images/compileprinciple/image-20220503084504065.png)

![image-20220503084519357](/images/compileprinciple/image-20220503084519357.png)

![image-20220503084839204](/images/compileprinciple/image-20220503084839204.png)

总之，状态栈和符号栈要同进同出。

### LR(0)分析

#### 活前缀和可归前缀

简单地说，先找到句柄（最左直接短语），然后**活前缀**是从符号串最左端到句柄最右端，这一条串的所有前缀。**可归前缀**是从符号串最左端到句柄最右端这一条串。

![image-20220503085505514](/images/compileprinciple/image-20220503085505514.png)

#### 识别活前缀DFA

技术线路是根据文法G，构造识别活前缀NFA  M。之后通过子集法，将NFA M确定化，得到识别活前缀DFA  M′。

1. 添加一条$S'\rightarrow S$规则，S'作为起始符，用来给最后转移到接收态。
2. S→aAcBe这样的，画状态，最后一个节点标上规则的序号并为可接收态，每个非终结符边前面的状态要通过$\epsilon$转移到相应的规则上面
3. 确定化nfa，得到dfa，按照标注的规则转移

![image-20220503091034551](/images/compileprinciple/image-20220503091034551.png)

![image-20220503091043963](/images/compileprinciple/image-20220503091043963.png)

#### 构造LR(0)项目集规范族

首先是给状态取一个规范的名称

![image-20220503091359102](/images/compileprinciple/image-20220503091359102.png)

这样的话，可以通过上面的方法构造识别活前缀的dfa，也可以使用LR(0)项目集(规范族)**直接构造**识别活前缀的DFA。

![image-20220503092728081](/images/compileprinciple/image-20220503092728081.png)

设I是文法G的LR(0)项目子集，则MOVE(I，X)定义如下：MOVE(I，X) ＝ {A→αX·β︱A→α·Xβ∈I}。move就相当于把点往后挪了一格。

I的闭包就是它和第一个非终结符的规则的集合：

![image-20220503093200172](/images/compileprinciple/image-20220503093200172.png)

**最终构造DFA方法（仔细研读）**：

![image-20220503094230676](/images/compileprinciple/image-20220503094230676.png)

文法G的识别活前缀DFA  M的状态集称为文法G的LR(0)项目集规范族。 

![image-20220503095023503](/images/compileprinciple/image-20220503095023503.png)

#### LR(0)分析表的构造

![image-20220503094939549](/images/compileprinciple/image-20220503094939549.png)

表见上。**总之**，有一个状态$i$（对应项目集规范族$I_i$）

- 非终结符转移到$j$，填action为j
- $I_i$是不含规约项目的，那么通过终结符转移到j，填action为$S_j$
- $I_i$是含规约项目的，那么全行都是对应的的$r_x$
- 状态1通常是$S'\rightarrow S$，那么action[1,S]为accept。

移进-归约冲突: 项目集中同时出现移进和归约项目：A→α•aβ，B→γ•
归约-归约冲突：项目集中同时出现多个归约项目：A→α•，B→β•

如果文法G的LR(0)项目集规范族**不存在移进-归约冲突或归约-归约冲突的项目集，则文法G称为LR(0)文法**。可采用LR(0)分析法、无二义性的。分析表ACTION表中每格仅会是移进、归约和报错3种动作之一。

### SLR(1)分析

LL(1)的痛苦是解决不了移进-规约冲突和规约-规约冲突问题。

不是LR(0)文法时，可以采用简单地**向后看1个输入符号**的方法，解决移进-归约冲突或归约-归约冲突。

![image-20220510083743748](/images/compileprinciple/image-20220510083743748.png)

它的构造法和LR(1)的很类似，除了$I_i$是含规约项目的时候，**不再是简单地把全行都搞成对应的$r_x$**，而是$\forall a\in FOLLOW(A), action[i,a]=r_i$。也就是说得在follow集合里头。

![image-20220510083854799](/images/compileprinciple/image-20220510083854799.png)

SLR(1)文法，是无二义性的；LR(0)文法，一定也是SLR(1)文法 

![image-20220510083956629](/images/compileprinciple/image-20220510083956629.png)

![image-20220510084009733](/images/compileprinciple/image-20220510084009733.png)

![image-20220510084020483](/images/compileprinciple/image-20220510084020483.png)

![image-20220510084032839](/images/compileprinciple/image-20220510084032839.png)

### LR(1)分析

b∈FOLLOW(A)只是归约α的一个必要条件，而非充分条件

把First(β)作为产生式作为B→γ归约时向前查看的符号集合,代替SLR(1)分析法中的Follow(B)

并将向前搜索符号集也放在LR(0)项目的后面:[A→α•β, a]， a称为向前搜索符(展望符) - LR(1)项目

LR(1)项目中LR(0)项目部分称为LR(1)项目的心。

同心的LR(1)项目简记为 [LR(0)项目，搜索符1︱搜索符2︱···︱搜索符m]。

“搜索符1︱搜索符2︱···︱搜索符m”称为搜索集。

形如[A→α•, a]的项表示仅在下一个输入符号等于a时才可以按照A→α 进行归约； 

这样的a的集合总是FOLLOW(A)的子集，通常是真子集

![image-20220510164659045](/images/compileprinciple/image-20220510164659045.png)

![image-20220510165822712](/images/compileprinciple/image-20220510165822712.png)

就是非终结符的后头和后继符都那啥

![image-20220510191348959](/images/compileprinciple/image-20220510191348959.png)

![image-20220510191429332](/images/compileprinciple/image-20220510191429332.png)

![image-20220510191852844](/images/compileprinciple/image-20220510191852844.png)

### LALR(1)分析

如果采用同心项目集合并方法，进行合并后的文法G的LR(1)项目集规范族，没有LR(1)项目冲突，则称文法G为LALR(1)文法。

合并同心集时产生移进-规约、归约-归约冲突, 就不是LALR(1)文法。

![image-20220510192044831](/images/compileprinciple/image-20220510192044831.png)

任何一个二义性文法都不是LR的

## 语法制导的语义计算

### 基于属性文法的语义计算

#### 属性文法

**综合属性**：

- 自下而上传递信息
- 语法规则：产生式左部符号的综合属性由产生式右部符号的属性计算得出
- 语法树：父节点的综合属性由子结点的属性和父结点自身的属性计算得出

终结符的综合属性值是由词法分析器提供的词法值，因此在属性文法中没有计算终结符属性值的语义规则

**继承属性**：

- 自上而下传递信息

- 语法规则：根据右部候选式中的符号的属性和左部符号的属性计算右部候选式中的符号的继承属性

- 语法树：根据父结点和兄长节点的属性计算子结点的继承属性

  ![image-20220523090729753](/images/compileprinciple/image-20220523090729753.png)

产生式右部符号的继承属性和产生式左部符号的综合属性由本产生式提供计算规则。且规则中只能使用本产生式中文法符号的属性。
产生式左部符号的继承属性和产生式右部符号的综合属性的计算规则不由本产生式提供，而是根据其它产生式的语义规则来计算。

带注释的语法树(仅含综合属性)：仅使用综合属性的属性文法称S－属性文法

![image-20220523091450231](/images/compileprinciple/image-20220523091450231.png)

带注释的语法树(含继承属性）：先构造语法树，再计算属性。

#### 语义计算

属性依赖：

![image-20220523091924170](/images/compileprinciple/image-20220523091924170.png)

如果属性X.a的值依赖于属性Y.b的值，则依赖图中有一条从Y.b的结点指向X.a的结点的有向边

![image-20220523092221539](/images/compileprinciple/image-20220523092221539.png)

树遍历算法：

```
While  还有未被计算的属性  do
	VisitNode(S) 	  /*S是开始符号*/

procedure VisitNode (N:Node) ;
begin
     if N是一个非终结符 then  /*假设其产生式为N→X1…Xm*/
	     for i :=1 to  m  do
              if XiVN  then /*即Xi是非终结符*/
		         begin
		              计算Xi的所有能够计算的继承属性；
		              VisitNode (Xi)
              end;
     计算N的所有能够计算的综合属性；
end
```

一遍扫描法：
在语法分析的同时计算属性值 

语义规则被计算的时机

- 自上而下分析，一个产生式匹配输入串成功时
- 自下而上分析，一个产生式被用于进行归约时

#### S-属性文法和L-属性文法

仅含综合属性的属性文法称为S-属性文法

![image-20220523093848685](/images/compileprinciple/image-20220523093848685-16532699290421.png)

#### 基于S-属性文法的语义计算

给LR分析栈里头加上一个语义栈

![image-20220523094232788](/images/compileprinciple/image-20220523094232788.png)

#### 基于L-属性文法的语义计算

上面的树遍历法

### 基于翻译模式的语义计算

#### 翻译模式

属性文法的语义规则：总是放在产生式的尾部
翻译模式：把语义规则（也称语义动作），用花括号{ }括起来，插入到产生式右部的合适位置上。进一步细化了语义计算的时机。

#### 基于S-翻译模式的语义计算

S-翻译模式：仅涉及到综合属性，通常语义动作集置于产生式右端的末尾。常采用LR的自底向上的分析法，和S属性文法类似。

与S-属性文法类似

- 基础文法是LL(1)：自顶向下计算
- 基础文法是LR系：自底向上计算

#### 基于L-翻译模式的自顶向下计算

![image-20220523094834861](/images/compileprinciple/image-20220523094834861.png)

- 分析程序由一组递归子程序(函数)组成，每个非终结符对应一个子程序
- 如果非终结符有多个产生式，根据当前符号和SELECT集决定用哪个产生式
- 从左到右分析符号串，遇到终结符就匹配，遇到非终结符就调用相应的分析子程序
- 要求基础文法是LL(1)的

#### 基于L-翻译模式的自底向上计算

从翻译模式中删除嵌入在产生式中间的语义动作
继承属性的求值结果以综合属性值存放在语义栈中，对继承属性的访问变成对语义栈中某个综合属性的访问
模拟继承属性的计算

![image-20220523102243905](/images/compileprinciple/image-20220523102243905.png)

## 静态语义分析和中间代码生成

### 静态语义分析

类型表达式：

基本类型是类型表达式

若T是类型表达式，I是整数域 (0..5; 1..10), 则Array(I,T) 也是类型表达式

若T是类型表达式，则pointer(T)是类型表达式

……

### 中间代码生成

![image-20220523110955171](/images/compileprinciple/image-20220523110955171.png)

#### 赋值语句和算术表达式的翻译

S -> id := E

   语义属性
     id.place : id 对应的存储位置     
     E.place : 用来存放 E 的值的存储单元的地址
     E.code :  对E 求值的 TAC 语句序列
     S.code :  对应于 S 的 TAC 语句序列 

   语义函数/过程
     gen() : 生成一条 TAC 语句
     newtemp() : 在符号表中新建一个从未使用过的名字，
                 并返回该名字的存储位置
     || 是TAC 语句序列之间的链接运算 

![image-20220523111750937](/images/compileprinciple/image-20220523111750937.png)

#### 说明语句的翻译

![image-20220523112337336](/images/compileprinciple/image-20220523112337336.png)

![image-20220523112514088](/images/compileprinciple/image-20220523112514088.png)

bool表达式的翻译

![image-20220523112608775](/images/compileprinciple/image-20220523112608775.png)

#### 拉链与代码回填（backpatching）

![image-20220523112720484](/images/compileprinciple/image-20220523112720484.png)

![image-20220523112729649](/images/compileprinciple/image-20220523112729649.png)

![image-20220523113011411](/images/compileprinciple/image-20220523113011411.png)

![image-20220523113025922](/images/compileprinciple/image-20220523113025922.png)



