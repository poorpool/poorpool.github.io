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
\geometry{a4paper,scale=0.8} % 调整页边距
\ctexset{section={format={\large\bfseries\raggedright}}}  % section居左

\setCJKmainfont[BoldFont=FandolHei, ItalicFont=FandolKai]{FandolSong} % 字体设置overleaf

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
