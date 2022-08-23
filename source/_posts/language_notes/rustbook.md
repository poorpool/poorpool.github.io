---
title: Rust 随便学学
date: 2022-02-01 11:21:21
tags:
- Rust
categories:
- 编程语言
---
Rust book，rustlings

<!--more-->

## 基础

表达式没有分号，可以有：

```rust
fn main() {
    let x = 5;

    let y = {
        let x = 3;
        x + 1
    };

    let number = if condition {
        5
    } else {
        6
    };

    println!("The value of y is: {}", y);
}
```

loop 循环中可以break到标签，也可以break返回一个值。

```rust
fn main() {
    let mut count = 0;
    'counting_up: loop {
        println!("count = {}", count);
        let mut remaining = 10;

        loop {
            println!("remaining = {}", remaining);
            if remaining == 9 {
                break;
            }
            if count == 2 {
                break 'counting_up;
            }
            remaining -= 1;
        }

        count += 1;
    }
    println!("End count = {}", count);
    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };
}
```

let定义的变量可以推断出类型，const定义的变量必须有类型。

函数参数和返回值：

```rust
fn sale_price(price: i32) -> i32 {
    if is_even(price) {
        price - 10
    } else {
        price - 3
    }
}
```

rust 的char是4个字节。

元组、数组：

```rust
fn main() {
    let tup = (500, 6.4, 1); // 类型可以是 (i32, f64, u8)

    let (x, y, z) = tup;

    println!("The value of y is: {}", y);
    //可以tup.1来访问y

    let a: [i32; 5] = [1, 2, 3, 4, 5];
    let a = [3; 5];  // [item; length]
}
```

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}

let user2 = User {
    email: String::from("another@example.com"),
    ..user1
};

// 元组结构体
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

let black = Color(0, 0, 0);
let origin = Point(0, 0, 0);
```

字段初始化简写语法可以省略结构体中字段名和变量名相同的情况的重复。结构体更新语法可以指定剩余未显式设置值的字段应有与给定实例对应字段相同的值。



## 所有权

1. Rust 中的每一个值都有一个被称为其所有者的变量。
2. 值在任一时刻有且只有一个所有者。
3. 当所有者（变量）离开作用域，这个值将被丢弃。

Rust 永远也不会自动创建数据的 “深拷贝”。其他语言常见的浅拷贝可能是Rust中的移动。

整型这样的在编译时已知大小的类型被整个存储在栈上，所以不会失效。要分清楚copy的和drop的。

在同一时间只能有一个对某一特定数据的可变引用。也不能在拥有不可变引用的同时拥有可变引用。注意一个引用的作用域从声明的地方开始一直持续到最后一次使用为止。

- 在任意给定时间，要么 只能有一个可变引用，要么 只能有多个不可变引用。
- 引用必须总是有效的。

slice：&str。编译器会确保指向 String 的引用持续有效。字面值就是字符串slice。

```rust
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);  // 这里也要加&符号

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
    s.len()
}


fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

## 结构体和枚举

结构体在impl块里头写方法或者是关联函数。

枚举可以存不同的数据

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);

let loopback = IpAddr::V6(String::from("::1"));

#[derive(Debug)] // 这样可以立刻看到州的名称
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        },
    }
}
let mut count = 0;
if let Coin::Quarter(state) = coin {
    println!("State quarter from {:?}!", state);
} else {
    count += 1;
}
```

match和枚举很搭配。匹配是穷尽的。可以用下划线或者other取得不想要的值。

如果只想要枚举中的一种情况，可以用if-let语句。

## 模块

可以一次use多个

```rust
use std::time::{SystemTime, UNIX_EPOCH};
```

## 集合

vector：

```rust
let v: Vec<i32> = Vec::new();
let v = vec![1, 2, 3];
v.push(5);
```

可以用索引或者get方法，返回Option<&T>。

map：
```rust
use std::collections::HashMap;

let teams = vec![String::from("Blue"), String::from("Yellow")];
let initial_scores = vec![10, 50];

let mut scores: HashMap<_, _> =
    teams.into_iter().zip(initial_scores.into_iter()).collect(); // 高级用法

let mut scores = HashMap::new();


scores.entry(String::from("Yellow")).or_insert(50);//只在没有时插入

let text = "hello world wonderful world";

let mut map = HashMap::new();

for word in text.split_whitespace() {
    let count = map.entry(word).or_insert(0);  // 返回可变引用
    *count += 1;
}
```

## 错误处理

如果 Result 值是成员 Ok，unwrap 会返回 Ok 中的值。如果 Result 是成员 Err，unwrap 会为我们调用 panic!。except类似，可以写文字。问号可以传递错误。

## 泛型

函数名后头加尖括号T，和java的一样。结构体名后面也可以加。impl关键字后面也可以加。

```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {  // 为泛型实现方法
    fn x(&self) -> &T {
        &self.x
    }
}

impl Point<f32> {  // 只为f32实例提供实现
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

泛型和cpp的模板比较类似。

trait类似接口。

```rust
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(Read more from {}...)", self.summarize_author())
    }
}


pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}

pub fn notify(item: &impl Summary) { // trait作为参数。适合短小的例子，但是不能限制俩参数类型一样
    println!("Breaking news! {}", item.summarize());
}

pub fn notify<T: Summary>(item1: &T, item2: &T) //这个是trait bound
pub fn notify<T: Summary + Display>(item: &T) //可以用加号搞多个trait

// 更复杂的可以使用where从句，，，
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: Display + Clone,
          U: Clone + Debug
{
```

生命周期注解挺复杂的，，，

## 函数式

闭包：

```rust
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

所有的闭包都实现了 trait Fn、FnMut 或 FnOnce 中的一个。

迭代器加闭包

```rust
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}
```