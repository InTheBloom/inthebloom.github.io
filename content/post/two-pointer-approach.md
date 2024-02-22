---
title: 尺取り法備忘録
# description: 

date: 2024-02-22
draft: true
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
  - 尺取り法
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

## 尺取り法、してますか？
条件を満たす列に対して

- 条件を満たす連続部分列の最大/最小長さ
- 条件を満たす連続部分列の数え上げ

などを求めるアルゴリズムとして、**尺取り法**が知られています。
要求される条件は、大まかには以下のどちらかです。

- ある区間$I$が条件を満たすならば、$\forall i \in I$もまた条件を満たす。
- ある区間$I$が条件を満たすならば、$\forall i \supseteq I$もまた条件を満たす。

[けんちょんさんの記事](https://qiita.com/drken/items/ecd1a472d3a0e7db8dce#1-3-%E3%81%97%E3%82%83%E3%81%8F%E3%81%A8%E3%82%8A%E6%B3%95%E3%81%8C%E4%BD%BF%E3%81%88%E3%82%8B%E6%9D%A1%E4%BB%B6)によると、これらの条件は次のようにも言い換えられます。

- 区間の最左のインデックスを$l$、条件を満たす区間の右のインデックス最大値を$f(l)$としたとき、$f(l)$は広義単調増加。
- 区間の最左のインデックスを$l$，条件を満たす区間の右のインデックス最小値を$f(l)$としたとき、$f(l)$は広義単調増加。

いきなり抽象的なことを言ってもしょうがないので、具体例を見ていきましょう。

## 例題 : AOJ DSL\_3\_C (The Number of Windows)

問題

長さ$N$の数列$a\_1, a\_2, a\_3, \dots , a\_N$が与えられる。次の$Q$個の質問に答えよ。

整数$x\_i$が与えられる。$1 \leq l \leq r \leq N$かつ$\sum_{i=l}^{r} \leq x\_i$を満たす$(l, r)$の組の個数を求めよ。

制約

- $1 \leq N \leq 10^5$
- $1 \leq Q \leq 500$
- $1 \leq a\_i \leq 10^9$
- $1 \leq x\_i \leq 10^{14}$

$1 \leq a\_i$であるため、$\sum_{i=l}^{r} a\_i \leq x\_i$が成立するなら、これよりも狭い区間の和もまた$x\_i$以下になります。
すなわち、尺取り法の条件を満たしています。
