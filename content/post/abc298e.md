---
title: ABC298E - Unfair Sugoroku
# description: 

date: 2024-06-12
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 確率/期待値
archives:
  - 2024
  - 2024-06
# sample
# - yyyy
# - yyyy-mm

math: true
draft: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc298/tasks/abc298_e)

$1$から$N$までの$N$個の地点があるすごろくがある。はじめ高橋くんは地点$A$、青木くんは地点$B$にいる。
高橋くんのサイコロは$1$から$P$までの整数が一様ランダムに出る。青木くんのサイコロは$1$から$Q$までの整数が一様ランダムに出る。

地点$x$にいるときにサイコロの出目が$i$であるとき、地点$\min(x + i, N)$に進む。地点$N$に先についた人を勝者とする。
高橋くんが先にサイコロを振るとき、高橋くんが勝つ確率はいくらか？

### 制約
- $2 \leq N \leq 100$
- $1 \leq A, B &lt; N$
- $1 \leq P, Q \leq N$

## 解法
ゲーム終了まで高々$N$ターンになるため、有限の標本空間を考えれば良い。無限の標本空間をもつ確率空間に比べて、定義通りに書き下すだけで色々楽になることが多いため、まずそうしてみよう。

標本空間$\Omega$をお互いが$N$回サイコロを振った結果の列と定める。すなわち、$\Omega = \lbrace (i, j)^N \mid 1 \leq i \leq P, 1 \leq j \leq Q \rbrace$とする。
また、高橋の現在位置が青木より先に$N$になる根元事象の集合を$E$と定める。すなわち、$E = \lbrace (i, j)^N \in \Omega \mid \exists x, \sum _ {k = 1}^x j _ k &lt; N \land N \leq \sum _ {k = 1}^{x + 1} i _ k \rbrace$とする。

このとき、求める確率は$P(E)$である。
さて、$\lvert 2^\Omega \rvert = (PQ)^N$であるため、この時点で$O(N(PQ)^N)$の解法を手に入れたことになる。しかし、流石にこのままだと間に合わないため、高速化を考える必要がある。

### 高速化1
上記のアプローチはいわば、根元事象一つ一つを区別して考えるというアプローチである。こうしてしまうと、どうしても$O(\lvert E \rvert)$かかってしまう。そこで、複数の根元事象を**何らかの値**を用いて同一視することを考える。

今回においては高橋、青木の現在マスの情報を用いることで上手く解くことができる。
例えば、$\mathrm{dp}\lbrack i \rbrack \lbrack j \rbrack \lbrack k \rbrack = (\text{お互いサイコロを$i$回投げて、高橋が$j$、青木が$k$にいる確率})$とすると、$1 \leq p \leq P, 1 \leq q \leq Q$なるすべての$(p, q)$を用いて、
$$\mathrm{dp}\lbrack 0 \rbrack \lbrack A \rbrack \lbrack B \rbrack = 1$$
$$\mathrm{dp}\lbrack i + 1 \rbrack \lbrack j + p \rbrack \lbrack k + q \rbrack = \frac{1}{PQ} \mathrm{dp}\lbrack i \rbrack \lbrack j  \rbrack \lbrack k \rbrack + \mathrm{dp}\lbrack i + 1 \rbrack \lbrack j + p \rbrack \lbrack k + q \rbrack$$
と更新することで、$\mathrm{dp}\lbrack i \rbrack$はサイコロをお互い$i$回投げたときのすべての事象をトレスした最終結果の確率分布となる。特に、$\mathrm{dp}\lbrack N \rbrack$は$\Omega$の要素をすべてトレスした最終結果の確率分布になる。

さて、指数時間からはかなり改善されたが、今計算しているものは求める値とは少し異なるものであるから、必要な値を計算途中で上手く抽出する必要がある。
