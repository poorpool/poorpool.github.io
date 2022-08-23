---
title: 在线记俄语一到一千的数字
date: 2020-11-16 18:42:29
tags: 
- 杂记
categories:
- 杂记
---

用 js 写的

<!--more-->
{% raw %}
<script>
var num_ge = new Array("", "оди́н", "два", "три", "четы́ре", "пять", "шесть", "семь", "во́семь", "де́вять", "де́сять")
var num_shi0 = new Array("", "оди́ннадцать", "двена́дцать","трина́дцать","четы́рнадцать", "пятна́дцать", "шестна́дцать", "семна́дцать", "восемна́дцать", "девятна́дцать")
var num_shi1 = new Array("", "", "два́дцать", "три́дцать", "со́рок", "пятьдеся́т", "шестьдеся́т", "се́мьдесят", "во́семьдесят", "девяно́сто")
var num_bai = new Array("", "сто", "две́сти", "три́ста", "четы́реста", "пятьсо́т", "шестьсо́т", "семьсо́т", "восемьсо́т", "девятьсо́т", "ты́сяча")

function get_num(x) {
    if (x < 1 || x > 1000) {
        return "Error!"
    }
    var ret = num_bai[Math.floor(x/100)] + " "
    x %= 100
    if (x === 0) {

    }
    else if (x <= 10) {
        ret += num_ge[x]
    } else if (x <= 19) {
        ret += num_shi0[x-10]
    } else {
        ret += num_shi1[Math.floor(x/10)] + " " + num_ge[x%10]
    }
    return ret.replace(/(^\s*)|(\s*$)/g, ""); 
}

var num = 0

//生成从minNum到maxNum的随机数
function randomNum(minNum,maxNum){ 
    switch(arguments.length){ 
        case 1: 
            return parseInt(Math.random()*minNum+1,10); 
        break; 
        case 2: 
            return parseInt(Math.random()*(maxNum-minNum+1)+minNum,10); 
        break; 
            default: 
                return 0; 
            break; 
    } 
} 

function my_gen() {
    num = randomNum(1, 1000)
    document.getElementById("num").innerHTML = num
    document.getElementById("russian").innerHTML = ""
}

function my_show() {
    document.getElementById("russian").innerHTML = get_num(num)
}
</script>
{% endraw %}

{% raw %}
<p style="font-size: 3.0rem;">
数字：
<span id="num"></span>
</p>
{% endraw %}

{% raw %}
<p style="font-size: 3.0rem;">
俄语：
<span id="russian" style="font-family: 'Noto Sans'"></span>
</p>
{% endraw %}

{% raw %}
<p>
<button onclick="my_gen()">生成</button>
<button onclick="my_show()">显示答案</button>
</p>
{% endraw %}