---
title: 個数制限ナップサックを01ナップサックに帰着するときのアレ
# description: 

date: 2026-03-12
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - トリビア
archives:
  - 2026
  - 2026-03
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 個数制限付きナップサック問題
$N$種類の物がある。$i$種類目の物は重さ$w _ i$、価値$v _ i$、個数$c _ i$個である。
ナップサックの容量を$V$とするとき、容量制限を守った上でナップサックに入れる物を選び、合計価値を最大化せよ。

## 01ナップサック問題への帰着
「$i$種類目の物を$c _ i$個まで取れる」ではなく、$c _ i = x _ 1 + x _ 2 + \dots + x _ k$を満たす$x _ i$を用いて、「重さ$x _ 1 w _ i$、価値$x _ 1 v _ i$の物、重さ$x _ 2 w _ i$、価値$x _ 2 v _ i$の物、... 重さ$x _ k w _ i$、価値$x _ k v _ i$の物からそれぞれ1つまで取れる」に変換します。
こうすることで、個数制限をより単純な01ナップサックに変換できます。

ただし、$0$個以上$c _ i$個以下なら自由に選んで取れるという条件を壊さないように、次のルールを守って$x _ i$を決める必要があります。

- 分解した物のとり方を組み合わせることで、個数$0$以上$c _ i$個以下のすべてを表現でき、これ以外は表現できない

このような条件を満たす分解は複数あり、自明な分解は重さ$w _ i$、価値$v _ i$の物$c _ i$個に分解することです。

01ナップサックに帰着するにあたって、$c _ i$個を少ないグループに分解できるかが重要になります。そして実は、$O(\log c _ i)$グループへの分解で条件を達成する方法が存在します。

それは、**2冪の小さいほうから貪欲に取る**ことです。
例えば$c _ i = 20$のとき、$c _ i = (2 ^ 0 + 2 ^ 1 + 2 ^ 2 + 2 ^ 3) + 5$というように分解します。

## 証明
個数$C$に対して2冪を$k$項取れたとし、あまりを$x$とします。
つまり$C = 2 ^ 0 + 2 ^ 1 + \dots + 2 ^ k + x$です。
このとき、$[1, 2 ^ {k + 1} - 1]$は2冪として分解した$k$項ですべて表すことができます。（$k$bitの2進数とみなせるので。）
また、貪欲に取るという仮定から、$x < 2 ^ {k + 1}$です。

さらに、$x$を取り、2冪の項をうまく組み合わせることで$[x, C]$もすべて表すことができます。（合計が$C$なので、$C - x$は$0$以上$2 ^ 0 + 2 ^ 1 + \dots + 2 ^ k$以下であるからです。）
また、すべての合計が$C$であることから$C$超過は表現できないことがわかります。

残った区間は$[2 ^ {k + 1}, x - 1]$ですが、$x < 2 ^ {k + 1}$を考えると、対象区間は空であることがわかります。
よって、どのグループも取らないことに対応する$0$を合わせると$[0, C]$の任意の量に対して、それを実現するような組み合わせが少なくとも1通り存在します。

証明は[nyaanさんによるもの](https://atcoder.jp/contests/abc269/editorial/4841)を元にしています。

## 実装例
AOJに[ジャッジ](https://onlinejudge.u-aizu.ac.jp/courses/library/7/DPL/all/DPL_1_G)があるのでやっておきました。
色々適当なのでそのまま使うのはおすすめしません。

[提出リンク](https://onlinejudge.u-aizu.ac.jp/solutions/problem/DPL_1_G/review/11368097/InTheBloom/D)

```D
import std;

void main () {
    int N, W;
    readln.read(N, W);
    auto v = new int[](N);
    auto w = new int[](N);
    auto m = new int[](N);
    foreach (i; 0 .. N) {
        readln.read(v[i], w[i], m[i]);
    }

    auto ans = knapsackWithLimitation(N, W, v, w, m);
    writeln(ans);
}

int knapsackWithLimitation (int N, int W, int[] v, int[] w, int[] m) {
    auto items = new int[2][](0);
    foreach (i; 0 .. N) {
        int acc = 0;
        foreach (b; 0 .. 20) {
            int sz = 1 << b;
            if (acc + sz <= m[i]) {
                items ~= [sz * v[i], sz * w[i]].staticArray;
            }
            else {
                if (0 < m[i] - acc) {
                    items ~= [(m[i] - acc) * v[i], (m[i] - acc) * w[i]].staticArray;
                }
                break;
            }
            acc += sz;
        }
    }

    auto dp = new int[](W + 1);
    auto ndp = new int[](W + 1);
    dp[] = -int.max;
    dp[0] = 0;

    foreach (i; 0 .. items.length) {
        ndp[] = -int.max;
        foreach (j; 0 .. W + 1) {
            if (dp[j] == -int.max) {
                continue;
            }

            // 取らない
            ndp[j] = max(ndp[j], dp[j]);

            // 取る
            if (j + items[i][1] <= W) {
                ndp[j + items[i][1]] = max(ndp[j + items[i][1]], dp[j] + items[i][0]);
            }
        }
        swap(dp, ndp);
    }

    int ret = -int.max;
    foreach (val; dp) {
        ret = max(ret, val);
    }

    return ret;
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

## おまけ
上記の分解を用いた場合、計算量は$O(NV \log (\max c _ i))$などになりますが、うまくやるとlogを消せます。

ナップサック容量を$V$、$i$種類目が重さ$w _ i$、価値$v _ i$、数$c _ i$個であるとします。
$\mathrm{dp}[i][j]$を「先頭$i$種類を処理して、使用容量$j$のときの最大価値」とするとき、$\mathrm{dp}[i][j]$からは$\mathrm{dp}[i][j + k w _ i]$の形で表される場所しか更新しません。
よって、$\mathrm{dp}[i]$の$V$個の場所は、$w _ i$で割ったあまりが等しい場所同士しか干渉しないことがわかります。
以下ではある1つのグループについて考えます。

dpの定義から、
$$\mathrm{dp}[i + 1][j] = \max _ {0 \leq k \leq c _ i} (\mathrm{dp}[i][j - k w _ i] + k v _ i)$$
であることがわかります。
この定義式のまま計算すると毎回$c _ i + 1$項見ることになってしまうため、max計算から$k$をうまく分離できると良さそうです。
ここで、競技プログラミングの中難易度以上で時々見るテクニックが使えます。
上記dpは「$j$から$k$個離れた値に$k v _ i$足したもののmax」を計算していますが、maxの中身が$j$ごとに変わってしまうため、高速化が難しいです。

そこで発想を変えて、$\mathrm{dp}[i]$の値から事前に$v _ i$の何倍かを引いておいて、「その値たちでmaxしたものに帳尻合わせの$v _ i$の何倍かを足す」とすることでmax計算から動的な部分を消します。

$r$をこのグループのあまりとします。グループは$r, r + w _ i, r + 2 w _ i \dots$と続きます。
実は、予め$\mathrm{dp}[i][r + p W _ i]$から$p v _ i$引いておくことでうまくいきます。

更新したい場所$\mathrm{dp}[i + 1][j]$とし、さらに$j = r + p w _ i$（グループ昇順$p$番目）とします。
このとき定義式を改めて書き直すと、
$$
\mathrm{dp}[i + 1][r + p w _ i] = \max _ {0 \leq k \leq c _ i} (\mathrm{dp}[i][r + (p - k) w _ i] + k v _ i)
$$
となります。
$\mathrm{dp}[i]$から予め$p v _ i$を引いておいた配列を$X$とします。
つまり、$X[r + p w _ i] = \mathrm{dp}[i][r + p w _ i] - p v _ i$です。
$X$を用いてさらに書き直すと、
$$
\begin{aligned}
    \mathrm{dp}[i + 1][r + p w _ i] &= \max _ {0 \leq k \leq c _ i} (\mathrm{dp}[i][r + (p - k) w _ i] + k v _ i) \\\\
    &= \max _ {0 \leq k \leq c _ i} ((X[r + (p - k) w _ i] + (p - k) v _ i) + k v _ i) \\\\
    &= \max _ {0 \leq k \leq c _ i} (X[r + (p - k) w _ i] + p v _ i) \\\\
    &= \max _ {0 \leq k \leq c _ i} (X[r + (p - k) w _ i]) + p v _ i
\end{aligned}
$$
となり、maxの中で$k v _ i$を足すという要素を排除できています。
よって、不変な配列$X$の連続$c _ i + 1$項のmaxを取る問題に帰着できました。
これはスライド最小値等で線形時間で処理できるため、グループごとに$O(V / w _ i)$時間で処理できます。
これを各グループに行うのを$N$種類の物全てに行うので、合計$O(NV)$時間です。

## おまけの実装例
解いておきました。
だいぶごちゃごちゃしてしまったのでうしライブラリを参考にしたほうがよいです。
index周りでだいぶ苦戦した。。。

スライド最大値 is 何という方は[こちら](/post/uecpg-advent2025-2/)に私の解説があります。
線形なんて非本質！という場合は別にセグ木使ってもいーのよ？

[提出リンク](https://onlinejudge.u-aizu.ac.jp/solutions/problem/DPL_1_G/review/11368068/InTheBloom/D)

```D
import std;

void main () {
    int N, W;
    readln.read(N, W);
    auto v = new int[](N);
    auto w = new int[](N);
    auto m = new int[](N);
    foreach (i; 0 .. N) {
        readln.read(v[i], w[i], m[i]);
    }

    auto ans = knapsackWithLimitation(N, W, v, w, m);
    writeln(ans);
}

int knapsackWithLimitation (int N, int W, int[] v, int[] w, int[] m) {
    auto dp = new int[](W + 1);
    auto ndp = new int[](W + 1);
    dp[] = -int.max;
    dp[0] = 0;
    auto st = DList!(int)();

    foreach (i; 0 .. N) {
        ndp[] = -int.max;

        foreach (j; 0 .. w[i]) { // あまりjのグループ
            // 前処理
            int k = 0;
            while (j + k * w[i] <= W) {
                if (dp[j + k * w[i]] != -int.max) {
                    dp[j + k * w[i]] -= k * v[i];
                }
                k++;
            }
            k--;

            // スライド最大値に最大m[i] + 1個詰める
            int count = 0;
            while (count < m[i] + 1 && 0 <= k - count) {
                int nj = j + (k - count) * w[i];
                while (!st.empty() && dp[st.front()] <= dp[nj]) {
                    st.removeFront();
                }
                st.insertFront(nj);

                count++;
            }

            while (true) {
                if (dp[st.back()] != -int.max) {
                    ndp[j + k * w[i]] = dp[st.back()] + k * v[i];
                }

                if (st.back() == j + k * w[i]) {
                    st.removeBack();
                }
                if (k == 0) {
                    break;
                }

                // 追加
                if (0 <= k - m[i] - 1) {
                    int nj = j + (k - m[i] - 1) * w[i];
                    while (!st.empty() && dp[st.front()] <= dp[nj]) {
                        st.removeFront();
                    }
                    st.insertFront(nj);
                }
                k--;
            }
        }
        swap(dp, ndp);
    }

    int ret = 0;
    foreach (val; dp) {
        ret = max(ret, val);
    }
    return ret;
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
