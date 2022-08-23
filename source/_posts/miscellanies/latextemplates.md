---
title: LaTeX 模板
date: 2021-08-27 11:00:00
tags:
- latex
- 笔记
categories:
- 笔记
---
记录一下经常用到的模板

<!--more-->

```
\documentclass[UTF8,12pt]{ctexart}

\usepackage[T1]{fontenc}
\usepackage{newpxtext,newpxmath} % palatino风格字体
\usepackage{geometry} % 调整页边距
\usepackage{algorithm} % 算法伪代码包
\usepackage{algorithmic}
\usepackage[usenames, dvipsnames]{xcolor}
\usepackage{listings} % 代码高亮包

\geometry{a4paper,scale=0.8} % 调整页边距

\ctexset{section={format={\large\bfseries\raggedright}}}  % section居左

\setCJKmainfont[BoldFont=SimHei, ItalicFont=KaiTi]{SimSun} % 字体设置

\newcommand{\BigO}[1]{\ensuremath{\operatorname{O}\bigl(#1\bigr)}}
\newcommand{\BigOmega}[1]{\ensuremath{\operatorname{\Omega}\bigl(#1\bigr)}}

\lstset{
	basicstyle=\ttfamily,% 基本风格
	numberstyle=\ttfamily,
	numbers=left,    % 行号
	numbersep=10pt,  % 行号间隔 
	tabsize=4,       % 缩进
	extendedchars=true, % 扩展符号？
	breaklines=true, % 自动换行
	language=C++,
	showspaces=false,% 空格字符加下划线
	showstringspaces=false,% 字符串中的空格加下划线
	showtabs=false,  % 字符串中的tab加下划线
	breaklines=true,
	frame=shadowbox,
	rulesepcolor=\color{red!20!green!20!blue!20},
	keywordstyle=\color{Fuchsia},       % keyword style
	stringstyle=\color{teal},
	commentstyle=\color{gray},
}

\title{\bfseries 文章的标题}
\author{poorpool}
\date{\today}

\begin{document}

\maketitle

\section{Hello 标题}

How are you? 我很好。

The quick brown fox jumps over a lazy dog.

\emph{The quick brown fox jumps over a lazy dog.}

\end{document}
```
