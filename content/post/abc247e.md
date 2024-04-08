---
title: ABC247E - Max Min
# description: 

date: 2024-04-08
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
archives:
  - 2024
  - 2024-04
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要

[問題へのリンク](https://atcoder.jp/contests/abc247/tasks/abc247_e)

### 問題文

長さ$N$の数列$A = (A _ 1, A _ 2, \dots, A _ N)$及び整数$X, Y$が与えられる。次の条件をすべて満たす整数の組$(L, R)$の個数を求めよ。

- $1 \leq L \leq R \leq N$
- $A _ L, A _ {L + 1}, \dots, A _ R$の最大値が$X$で、最小値が$Y$である。

### 制約

- $1 \leq N \leq 2 \times 10^5$
- $1 \leq A _ i \leq 2 \times 10^5$
- $1 \leq Y \leq X \leq 2 \times 10^5$

## 解法

条件を満たす連続部分列$A _ L, A _ {L + 1}, \dots, A _ R$の各要素は、明らかに$Y$以上$X$以下である。
したがって、この範囲外にであるような要素$A _ i$に対して、$A _ i$をまたぐような区間は条件を満たすことはない。
これにより、$A _ i < Y$または$X < A _ i$を満たす要素で数列$A$を分割して考えて良いことがわかる。

分割してできた列のうち一つを$B = (B _ 1, B _ 2, \dots, B _ M)$として、$B$に対して問題を解くことを考える。

数え上げの問題に対する一般的なアプローチとして、何かしらの値を固定して考えるというものがある。
今回は区間の右端を固定したときに、左端をどのように取れるかを考えることにする。

まず、$L \leq R$であることから、右端$R$に次の必要条件が課されることがわかる。

- $B _ 1, B _ 2, \dots, B _ R$の最小値が$Y$で、最大値が$X$である。

すべての要素が$Y \leq B _ i \leq X$であるという仮定から、これは次の条件に言い換えることができる。

- $R$は数列$B$の中で最初に現れる$X$と$Y$より後ろにいなければいけない。

数式で表現するなら、$X _ {\mathrm{idx}} \coloneqq \lbrace i \mid B _ i = X \rbrace, Y _ {\mathrm{idx}} \coloneqq \lbrace i \mid B _ i = Y \rbrace$に対して、$\max (\min X _ {\mathrm{idx}}, \min Y _ {\mathrm{idx}}) \leq R$
(ただし、$\min \emptyset = \infty$とする。)
という感じになる。

この条件が満たされるとき、少なくとも$(1, R)$は条件を満たすため、少なくとも1通りの有効な組が存在することがわかる。

では、この条件下で左端$L$はどこまで大きく取れるだろうか？この答えは、次の通りである。

- $R$より前の一番近い$X$と$Y$より左ならよい。

より形式的には、$x \coloneqq \max \lbrace i \mid i \in X _ \mathrm{idx} \land i \leq R \rbrace, y \coloneqq \max \lbrace i \mid i \in Y _ \mathrm{idx} \land i \leq R \rbrace$として、$L \leq \min(x, y)$であるような$L$ならすべて条件を満たす。

さて、これで問題を解くことができた。残る問題は、これらの操作を高速に行うことができるかになる。
まず、数列$A$を分割するのは尺取り法などにより全体$\Theta(N)$時間で行うことができる。

分割された数列$B$に対して考える。
事前に$\Theta(\vert B \vert)$時間をかけて$X, Y$それぞれと等しい要素のインデックスを昇順に保持しておくと、
現在の$R$右端として用いることができるかを$O(1)$時間、$R$を順に(昇順/降順どちらでもできる)見ていくことで、その時点での$x, y$を$O(1)$時間で更新できる。
$R$の候補は$\vert B \vert$個であるから、全体$\Theta(\vert B \vert)$時間で解ける。

以上より、問題を$\Theta(N)$時間で解くことができる。

## 実装例

```d
import std;

void main () {
    int N, X, Y; readln.read(N, X, Y);
    auto A = readln.split.to!(int[]);

    solve(N, X, Y, A);
}

void solve (int N, int X, int Y, int[] A) {
    // Y <= a <= Xが成立する区間に分割 -> 区間に置いてa == Yとa == Xが成立するインデックスを全部持っておき、区間の右側を全探索 -> 線形時間

    long ans = 0;
    int[] X_idx, Y_idx;

    // 尺取りで頑張る
    int l = 0, r = 0;

    void f () {
        X_idx.length = Y_idx.length = 0;
        foreach (i; l..r) {
            if (A[i] == X) X_idx ~= i;
            if (A[i] == Y) Y_idx ~= i;
        }

        if (X_idx.length == 0 || Y_idx.length == 0) return;

        // 右側を探索
        int x = 0, y = 0;
        foreach (i; l..r) {
            if (x + 1 < X_idx.length && X_idx[x + 1] == i) x++;
            if (y + 1 < Y_idx.length && Y_idx[y + 1] == i) y++;
            if (i < X_idx[0] || i < Y_idx[0]) continue;

            ans += min(X_idx[x], Y_idx[y]) - l + 1;
        }
    }

    while (l < N) {
        if (r < l) r = l;
        if (A[l] < Y || X < A[l]) {
            l++;
            continue;
        }

        while (r < N) {
            if (Y <= A[r] && A[r] <= X) {
                r++;
                continue;
            }
            break;
        }

        // 区間に対して操作
        f();

        l = r;
    }

    writeln(ans);
}

void read (T...) (string S, ref T args) {
    import std.conv : to;
    import std.array : split;
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

尺取り法で区間を分割している。
それぞれの連続部分列に対して問題を解くことは関数`f()`を呼ぶことと対応している。
$x, y$の計算等が面倒な場合、平衡二分木を用いると$O(N \log N)$時間になる代わりに実装が楽になる。

## 終わりに

久しぶりに見返したら、思いの外苦戦したので解法をまとめておくことにした。
尺取り法を使うのが少しずつうまくなっているのを感じる。
