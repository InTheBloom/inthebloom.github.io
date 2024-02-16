---
title: ABC155E - Payment
# description: 

draft: true

date: 2024-02-15
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 桁dp
archives:
  - 2024
  - 2024-02
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc155/tasks/abc155_e)

$10^{100} + 1$種類の紙幣があり、価値はそれぞれ$1, 10, 10^2, \dots, 10^{(10^{100})}$である。
価値$N$の商品を一つ買うとき、払う紙幣の枚数とお釣りで返される紙幣の枚数の和の最小値を求めよ。

ただし、どの紙幣も十分多く持っているとする。

制約
- $1 \leq N \leq 10^{10^6}$

## 考察
微妙につかみどころがない問題なので、まずは単純なケースについて考えよう。

- $1 \leq N \leq 9$

    この場合、最適な支払いは$N$円か$10$円に限られる。
    - $N < x < 10$円を支払うとき

        余分な支払いとお釣りを1円ずつ減らすことで、やり取りする紙幣を減らしながら$N$円まで持っていける。

    - $10 < x$円を支払うとき

        
