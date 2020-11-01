---
title: 《计算机程序的构造和解释》学习笔记 1
date: 2020-07-28 10:03:11
tags:
- lisp
categories:
- 笔记
---

[课程来源](https://www.bilibili.com/video/BV1Xx41117tr)

<!--more-->

# 基本

lambda

```lisp
(define square (lambda (x) (* x x)))
(define (square x) (* x x))
```

一样的。

牛顿法平方根：

```lisp
(define (sqrt x)
  (define (average x y) (/ (+ x y) 2.0))
  (define (improve guess) (average guess (/ x guess)))
  (define (good-enough? guess) (< (abs (- (* guess guess) x)) 0.0000000001))
  (define try (lambda (guess)
                (if (good-enough? guess)
                    guess
                    (try (improve guess)))))
  (try 1))
```

高阶函数：函数当成变量

```lisp
;通用sum，求a到b term(a) 的和，步长为next(a)
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a) (sum term (next a) next b))))

;从a加到b
(define (sum-int a b)
  (define (indentity a) a)
  (define (plus-one a) (+ 1 a))
  (sum indentity a plus-one b))

(sum-int 1 10)
```

牛顿法求解

```lisp
#lang sicp

(define tolerance 0.000001)
(define dx 0.000001)

;找出f(x)不动点
(define (fixed-point f first-guess)
  (define (close-enough? x y)
    (< (abs (- x y)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
          next
          (try next))))
  (try first-guess))

;求出g(x)导数
(define (deriv g)
  (lambda (x) (/ (- (g (+ x dx)) (g x)) dx)))

;g(x)=0的解是f(x)=x-g(x)/dg(x)的一个不动点，下面的就是f(x)
(define (newton-transform g)
  (lambda (x)
    (- x (/ (g x) ((deriv g) x)))))

;牛顿法求出g(x)=0的解
(define (newton-method g guess)
  (fixed-point (newton-transform g) guess))

(define (g x) (+ (* x x) (* 2 x) 1))

(newton-method g 1)
```

自己的 cons，car 和 cdr

```lisp
#lang sicp
(define (my-cons x y)
  (lambda (pick)
    (cond ((= pick 1) x)
          ((= pick 2) y))))

(define (my-car p) (p 1))

(define (my-cdr p) (p 2))

(my-cdr (my-cons 2 3))
```

自己的 map：

```lisp
#lang sicp
(define (my-map p l)
  (if (null? l)
      nil
      (cons (p (car l)) (my-map p (cdr l)))))

(my-map (lambda (x) (* x x)) (list 1 2 3 4))
```

## 符号数据

```lisp
(list 'a 'b)
=> (a b)

(cdr '(b c))
=> (c)


```

其实 `'(a b c)` 就相当于 `(quote (a b c))`。以后可以用 `'()` 来代替 `nil` 了。