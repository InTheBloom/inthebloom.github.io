---
title: めぐる式二分探索亜種の提案
# description: 

date: 2025-01-26
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2025
  - 2025-01
# sample
# - yyyy
# - yyyy-mm

math: true
draft: true
# toc: false
# build: {list: never}
---

## はじめに
競技プログラミングにおける二分探索の代表的な実装方法の一つに、**めぐる式二分探索**があります。
本エントリでは、めぐる式二分探索に改変を加え、より使いやすくしたバージョンを提案します。

## めぐる式二分探索の問題点
めぐる式二分探索と呼ばれるようになった由来のツイートを掲載します。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">【めぐるのアルゴリズム講座】<br>二分探索（整数）の書き方<br>難しさ：４ <a href="https://t.co/LGLbkS0D7l">pic.twitter.com/LGLbkS0D7l</a></p>&mdash; 因幡めぐる@競技プログラミング (@meguru\_comp) <a href="https://twitter.com/meguru_comp/status/697008509376835584?ref_src=twsrc%5Etfw">February 9, 2016</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

どのような実装であるかを確認しましょう。
めぐる式二分探索では、区間$\lbrack \mathrm{ok}, \mathrm{ng})$あるいは$(\mathrm{ng}, \mathrm{ok} \rbrack$を考えて、$\mathrm{mid} = \lfloor \frac{\mathrm{ok} + \mathrm{ng}}{2} \rfloor$における判定関数$\mathrm{solve}$の返り値に応じて$\mathrm{ok}$または$\mathrm{ng}$を更新するというものです。

めぐる式二分探索の問題は2点あります。
ひとつは、判定関数の定義域を片側開区間で指定していること。
もう一つは、$f(\mathrm{ok}) = \mathrm{true}$を必要条件にしていることです。

### 片側開区間で指定することの欠点
関数$\mathrm{solve}$の定義域が有限なときに欠点が顕著になります。
例として、配列上の二分探索を考えます。

問題: $N$要素の昇順に並んだ配列$A$が与えられる。ある値$K$

