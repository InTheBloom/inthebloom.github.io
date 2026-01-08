---
title: O(NM)時間多項式除算
# description: 

date: 2026-01-09
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 数学
  - アルゴリズム
  - 一問解説
archives:
  - 2026
  - 2026-01
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題
- $N$次多項式$A(x) = A _ N x ^ N + A _ {N - 1} x ^ {N - 1} + \dots + A _ 0$
- $M$次多項式$B(x) = B _ M x ^ M + B _ {M - 1} x ^ {M - 1} + \dots B _ 0$
- $N + M$次多項式$C(x) = A(x)B(x) = C _ {N + M} x ^ {N + M} + C _ {N + M - 1} x ^ {N + M - 1} + \dots + C _ 0$

がある。$A(x), C(x)$が与えられるので、$B(x)$を求めよ。

## 解法
$B _ i$を求めるときに$C _ {N + i}$を利用するとよいです。以下では$C _ {N + i}$から$B _ i$を求める具体的な手順を示します。

まず、多項式の積の定義から、
$$C _ {N + i} = \sum _ {p + q = N + i} A _ p B _ q$$です。
展開すると、
$$C _ {N + i} = A _ N B _ i + A _ {N - 1} B _ {i + 1} + \dots + A _ {N - M + i} B _ M$$とできることがわかります。（注: $N - M + i < 0$となる場合があるため、この立式では$A _ {i < 0} = 0$として扱っています。実装上では負の項にアクセスしないよう条件分岐等が必要です。）
右辺をよく見ると、依存している項は$B _ i, B _ {i + 1}, \dots, B _ M$となっています。
そこで、$B _ i$が関与する項以外を移項して、
$$C _ {N + i} - A _ {N - 1} B _ {i + 1} - \dots - A _ {N - M + i} B _ M = A _ N B _ i$$とできます。
$A _ N \neq 0$であったことから、$A _ N$で割ることができて、
$$B _ i = \frac{C _ {N + i} - A _ {N - 1} B _ {i + 1} - \dots - A _ {N - M + i} B _ M}{A _ N}$$
が成立します。
$A(x), C(x)$が与えられていること、$B _ i$より高次の項にしか依存しないことを踏まえると、$B(x)$の高次の項から求めていくことができます。
分子を計算するのに$O(N)$かかり、それを$M$回行えばよいため$O(NM)$時間です。

## 実装例
[ABC245D - Polynomial division](https://atcoder.jp/contests/abc245/tasks/abc245_d)を解きます。

```d
import std;

void main () {
    int N, M;
    readln.read(N, M);
    auto A = readln.split.to!(int[]);
    auto C = readln.split.to!(int[]);

    // 最高次の係数から順に求めていく。
    // より具体的には、B[i]を求めるとき
    // C[N + i] = A[N]B[i] + A[N - 1]B[i + 1] + ...
    // C[N + i] - A[N - 1]B[i + 1] - ... = A[N]B[i]
    // として、A[N] != 0を利用して計算する。

    auto B = new int[](M + 1);
    foreach_reverse (i; 0 .. M + 1) {
        // より高次のBの寄与を計算
        int val = C[N + i];
        foreach (j; i + 1 .. M + 1) {
            if (0 <= N + i - j) {
                val -= B[j] * A[N + i - j];
            }
        }
        B[i] = val / A[N];
    }

    writefln("%(%s %)", B);
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

## 補足
$S = \max(N, M)$として、$O(S \log S)$時間の解法が存在します。
[drken1215さんの解説](https://drken1215.hatenablog.com/entry/2022/03/29/190000)
