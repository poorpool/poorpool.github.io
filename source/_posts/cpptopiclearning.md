---
title: C++ 专题学习
date: 2022-02-01 11:21:21
tags:
- C++
categories:
- 编程语言
---

a tour of c++ 之类的书

<!--more-->

## 列表初始化

https://zh.cppreference.com/w/cpp/language/list_initialization

https://greedysky.github.io/2020/09/16/C++%20%E5%88%97%E8%A1%A8%E5%88%9D%E5%A7%8B%E5%8C%96%E8%AF%A6%E8%A7%A3/

## 构造与拷贝控制

可以参考 C++ Primer 第十三章拷贝控制。

五大成员函数：拷贝构造函数、移动构造函数，拷贝赋值运算符、移动赋值运算符，析构函数。

构造函数可以声明为explict的来抑制只有一个参数的构造函数的隐式转换。

如果自己定义了构造函数，可以用=default依然生成默认的构造函数。可以用=delete来拒绝生成默认的拷贝赋值运算符等。

如果一个类需要析构函数，它往往需要把拷贝构造函数和拷贝赋值运算符也写上（里头可能有指针）。

注意处理自赋值问题：先new再delete。

## 右值引用、移动语义、引用折叠、万能引用、完美转发

移动构造函数是偷资源的，形式都是`Node(Node &&nd)`。如果现在写一个swap：

```cpp
struct Node {
  int x;
  Node(int xx) {
    printf("普通构造函数\n");
  }
  Node(const Node &nd) {
    printf("拷贝构造函数\n");
  }
  Node& operator=(const Node&nd) {
    printf("拷贝赋值运算符\n");
    return *this;
  }
};

template<typename T>
void myswap(T &a, T &b) {
  T tmp(a);
  a = b;
  b = tmp;
}

int main() {
  Node a{5};
  Node b{5};
  myswap(a, b);
  return 0;
}
/*
普通构造函数
普通构造函数
拷贝构造函数
拷贝赋值运算符
拷贝赋值运算符
*/
```

发生一次拷贝构造、两次拷贝赋值，很野蛮。如果Node里头存一个指针，那岂不是要多内存分配一次。

```cpp
struct Node {
  int x;
  Node(int xx) {
    printf("普通构造函数\n");
  }
  Node(const Node &nd) {
    printf("拷贝构造函数\n");
  }
  Node& operator=(const Node&nd) {
    printf("拷贝赋值运算符\n");
    return *this;
  }
  Node(Node &&nd) {
    printf("移动构造函数\n");
  }
  Node& operator=(Node &&nd) {
    printf("移动赋值运算符\n");
    return *this;
  }
};

template<typename T>
void myswap(T &a, T &b) {
  T tmp(std::move(a));
  a = std::move(b);
  b = std::move(tmp);
}
/*
普通构造函数
普通构造函数
移动构造函数
移动赋值运算符
移动赋值运算符
*/
```
这样就很好。由此可见，std::move把左值引用转换为右值引用。这就是**移动语义**。它的源代码：

```cpp
// remove_reference起到一个删除引用符号的作用
  template<typename _Tp>
    struct remove_reference
    { typedef _Tp   type; };

  template<typename _Tp>
    struct remove_reference<_Tp&>
    { typedef _Tp   type; };

  template<typename _Tp>
    struct remove_reference<_Tp&&>
    { typedef _Tp   type; };

  template<typename _Tp>
    _GLIBCXX_NODISCARD
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```

总而言之，就是强转。

在继承和组合的时候要显式调用std::move，因为一个接受右值引用的变量可能是左值：

```cpp
struct Node {
  Node() {
    printf("Node 普通构造函数\n");
  }
  Node(const Node &nd) {
    printf("Node 拷贝构造函数\n");
  }
  Node(Node &&nd) {
    printf("Node 移动构造函数\n");
  }
};

struct NChild : Node{
  NChild() {
    printf("NChild 普通构造函数\n");
  }
  NChild(const NChild &nd): Node(nd) {
    printf("NChild 拷贝构造函数\n");
  }
  NChild(NChild &&nd): Node(nd) { // 解决方法是改成Node(std::move(nd))
    printf("NChild 移动构造函数\n");
  }
};

int main() {
  NChild obj;
  printf("\n");
  NChild obj2(std::move(obj));
  return 0;
}
/*
Node 普通构造函数
NChild 普通构造函数

Node 拷贝构造函数
NChild 移动构造函数
*/
```

返回局部变量时不要使用移动语义。

**引用折叠**是实现**万能引用**的技术。看 https://zhuanlan.zhihu.com/p/50816420

使用万能引用写一个wrapper，如

```cpp
void print(int &x) {
  printf("左值\n");
}

void print(int &&x) {
  printf("右值\n");
}

template<typename T>
void myforward(T &&x) {
  print(x); // 如果改成 std::forward<T>(x) 就是左值右值
  // 如果改成std::move(x)就是右值右值
}

int main() {
  int x = 2;
  myforward(x);
  printf("\n");
  myforward(1);
  return 0;
}
```

虽然myforward可以接收左值和右值了，但是调用的结果是输出左值左值！这是因为形参x具名。如果充分利用T里面的信息，交给std::forward

上面代码都使用的是下面第一个函数的例子。T为int &时，int& &&为int &。T为int时，int &&。

```cpp
  template<typename _Tp>
    _GLIBCXX_NODISCARD
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type& __t) noexcept
    { return static_cast<_Tp&&>(__t); }

  template<typename _Tp>
    _GLIBCXX_NODISCARD
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type&& __t) noexcept
    {
      static_assert(!std::is_lvalue_reference<_Tp>::value, "template argument"
		    " substituting _Tp must not be an lvalue reference type");
      return static_cast<_Tp&&>(__t);
    }
```

这就实现了**完美转发**。

总而言之，**移动语义**是通通转为右值。**完美转发**是靠类型推导来取得真正的引用类型。

也参考 https://blog.csdn.net/xiangbaohui/article/details/103673177

## 智能指针

