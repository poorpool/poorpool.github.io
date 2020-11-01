---
title: vue 学习笔记 2
date: 2020-07-13 20:29:31
tags:
- 前端
- vue
categories:
- 笔记
---

[课程来源](https://www.bilibili.com/video/BV15741177Eh)

<!-- more -->

# 基础部分

## slot

这东西好像被废弃了，以后使用 v-slot（（

比如淘宝手机版顶上，可能是搜索框，可能是没有搜索的导航条。这个地方就写个插槽然后插上对应的组件。

```html
<body>
    <div id="app">
        <cpn><button>button</button></cpn><!-- 这就插到插槽里头了。写多个的话会一起替换掉 slot -->
        <cpn><h2>qwq</h2></cpn>
    </div>
    <template id="cpn">
        <div>
            <h2>slot 在下头</h2>
            <slot></slot><!-- 里头可以写个默认的 -->
        </div>
    </template>
    <script>
        const app = new Vue({
            el: "#app",
            components: {
                cpn: {
                    template: "#cpn"
                }
            }
        });
    </script>
</body>
```

```html
<div id="app">
    <cpn><button>button</button></cpn>
    <cpn><button slot="right">toRight</button></cpn>
</div>
<template id="cpn">
    <div>
        <slot name="left"><span>left</span></slot>
        <slot><span>middle</span></slot>
        <slot name="right"><span>right</span></slot>
    </div>
</template>
```

父组件模板的所有东西都会在父级作用域内编译，子组件的在子级作用域里编译。如果子组件有数据，父组件想把数据改一改放到子组件的插槽中去，因为编译作用域的存在，不能直接在父组件里头用 mustache 语法写子组件的数据。新版本作用域插槽要用 v-slot。

```html
<body>
    <div id="app">
        <cpn>
            <template v-slot="qwq"><!-- 获得子组件的数据 -->
                <div v-for="item in qwq.data">
                    {{ item }}
                </div>
                <h1>{{ qwq.data2 }}</h1>
            </template>
        </cpn>
    </div>
    <template id="cpn">
        <div>
            <slot :data="lan" :data2="nal"></slot><!-- 把子组件的数据绑到喜欢的名字上 -->
        </div>
    </template>
    <script>
        const app = new Vue({
            el: "#app",
            components: {
                cpn: {
                    template: "#cpn",
                    data() {
                        return {
                            lan: ['a', 'b', 'c'],
                            nal: 19
                        }
                    }
                }
            }
        });
    </script>
</body>
```

## 模块化

```html
<script src="aaa.js" type="module"></script>
<script src="bbb.js" type="module"></script>
```

```javascript
var a = 10;
export {a}//1
export function sum(a, b) {//2定义时导出
    return a + b;
}
export default function (str) {//3匿名导出
    console.log(str);
}
```

```javascript
import {a, sum} from "./aaa.js"//导入普通的
console.log(a);
console.log(sum(1, 3));

import addr from "./aaa.js"//导入 default 的
addr("nihao")
```

webpack.config.js

```javascript
const path = require("path");
module.exports = {
    entry: "./src/main.js",
    output: {
        path: path.resolve(__dirname, "dist"),
        filename: "bundle.js"
    },
    module: {
        rules: [
            { test: /\.css$/, use: ['style-loader', 'css-loader'] }
        ]
    }
}
```

main.js

```javascript
import {sum, mul} from "./js/mathUtils.js";

console.log(sum(1, 3));
console.log(mul(2, 3));

require("./css/style.css");//css也要引用。用先 css-loader 再 style-loader，和上面写的顺序相反。
```

顺带一提，箭头函数的 this 是向外层作用域一层一层查找 this，直到查找到。

# Vue Cli

## router

单页面富应用 SPA，就是在前后端分离的基础加上了前端路由。