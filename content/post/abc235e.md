---
title: ABC235E、あるいはクエリ並列処理
# description: 

date: 2023-10-31
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 典型テク
archives:
  - 2023
  - 2023-10-31
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題](https://atcoder.jp/contests/abc235/tasks/abc235_e)

辺の重みがすべて異なる無向連結グラフ$G$が与えられる。
さらに、クエリ$i$で$G$中のどの辺とも異なる重みをもつ辺$(u_i, v_i, w_i)$が与えられる。
クエリ$i$で与えられた辺を$G$に追加したグラフ$G'$を考える。
すべての$i$に対して、辺$(u_i, v_i, w_i)$は$G'$の最小全域木に含まれるか判定せよ。

制約
- $2 \leq N \leq 2 \times 10^5$ ($G$の頂点数)
- $N-1 \leq M \leq 2 \times 10^5$ ($G$の辺数)
- $1 \leq Q \leq 2 \times 10^5$

## 考察と解法
クラスカル法を考えると、辺を重みと連結性で貪欲にとればよい。
したがって、一つのクエリに対して$O(N \log N)$で答えることができる。
しかし、このままだと全体$O(QN \log N)$で間に合わない。

高速化を考える。
一つ一つのクエリは最小全域木に含まれるかどうかのみを判定して、元のグラフ$G$に取り込まれないことを利用しよう。
クラスカル法によると、辺の重みでソートして、辺が結ぶ頂点がまだ連結でない場合にのみ辺を採用すればよい。
そこで、次のアルゴリズムを考える。

1. すべてのクエリを先読みして、もとからあった$M$個の辺と$Q$個の辺を重みでソートする。
2. クラスカル法に基づいて、辺を採用するかどうかを判定していく。
ただし、**クエリで与えられた辺は採用できる場合でも採用しない。**

これでうまくいく。
なぜなら、一つのクエリから見れば、ほかのクエリによる$Q-1$個の辺は必ず採用されないため、
グラフ$G$の連結性に影響を与えていないからだ。

時間計算量は$O((N+Q) \log (N+Q))$となる。

## 実装例
```D
import std;

struct edge {
    int u, v;
    long w;
    int idx;
}

void main () {
    int N, M, Q; readln.read(N, M, Q);
    edge[] e = new edge[](M+Q);
    foreach (i; 0..M) {
        with (e[i]) {
            readln.read(u, v, w);
            u--, v--;
            idx = -1;
        }
    }
    foreach (i; 0..Q) {
        with (e[i+M]) {
            readln.read(u, v, w);
            u--, v--;
            idx = i;
        }
    }

    solve(N, M, Q, e);
}

void solve (int N, int M, int Q, edge[] e) {
    /* 解説AC クラスカル法を適用すればクエリ単品なら簡単に解ける。これをどうするか？
       -> クエリ先読みして、全部の辺をまとめてソートしたうえでその辺を採用できるかどうかを見ると行ける。 */
    e.sort!"a.w < b.w";
    string[] ans = new string[](Q);
    auto UF = UnionFind!int(N+Q);

    foreach (ee; e) with(ee) {
        if (UF.areInSameGroup(u, v)) {
            if (idx == -1) continue;
            ans[idx] = "No";
        } else {
            if (idx == -1) { UF.unite(u, v); continue; }
            ans[idx] = "Yes";
        }
    }

    foreach (i; 0..Q) {
        writeln(ans[i]);
    }
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```
UnionFindの実装は長いので省いている。

## 典型テク: クエリ並列処理
今回の問題のように、あるクエリがほかのクエリに影響を与えない場合、
すべてのクエリを一斉に処理することで高速に解くことができる場合がある。

クエリが飛んでくる問題が来た時に一度は検討したい方針である。

## 発展
今回の問題は、別の解法もある。
クエリ$i$で$(u_i, v_i, w_i)$が来た時、
この辺が最小全域木に採用されるかどうかは、
$(u_i, v_i)$を結ぶパス(木なので、ちょうど一つ存在)に含まれる辺の最大重みが
$w_i$より重いかどうかで判定することができる。
より具体的には、

- もし$w_i$より重い辺が存在するなら、その辺をカットして、
$(u_i, v_i, w_i)$を採用することで全域木であることを保ちつつ、より総和が小さくなる。
- そうでない場合は必ず総和が増える。

実は、この問題は解くことができる。(らしい)
詳しくは[kyopuro_friendsさんの解説](https://atcoder.jp/contests/abc235/editorial/3258)に載っているが、
私はまだ理解できていないため、紹介にとどめる。

## 終わりに
この発想は出なかった。次見たときには解けるようになりたい。
