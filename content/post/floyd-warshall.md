---
title: ワーシャル・フロイド法について調べて、納得したこと
# description: 

date: 2023-10-02
lastmod: 2023-10-05
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2023
  - 2023-10
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## はじめに
辺に任意の重みがある$N$頂点有向グラフ(ネットワーク)において、負の長さの閉路が存在しないとき、
全点対の最短経路を$O(N^3)$時間で求めるワーシャル・フロイド法と呼ばれるアルゴリズムが存在する。

本稿では、筆者がワーシャル・フロイド法について調べ、理解したことを記録する。

## ワーシャル・フロイド法でできるもの
負閉路が存在しないネットワークにおいて、任意の2頂点間の最短経路を求める。

頂点数を$N$としたとき、空間$O(N^2)$と時間$O(N^3)$を要する。

## アルゴリズムの詳細
以降、頂点のインデックスは0を基準とする。
また、頂点iから頂点jへの辺の重みを$w_{i,j}$とする。

$\mathrm{dist}[i][j]:=$「頂点iから頂点jへの最短経路」とする。
最初、$\mathrm{dist}[i][j]$を次のように初期化する。

$$
\mathrm{dist}[i][j] =
\begin{cases}
w_{i,j} & \text{if ~ $i$から$j$への辺が存在,}\\\\
\infty{} & \text{if ~ $i$から$j$への辺が存在しない,} \\\\
0 & \text{if ~ $i = j$.}
\end{cases}
$$

$k = 0, 1, \cdots{} N-1$に対して、順に次の手順を行う。

全ての$0 \leq{} i, ~ j \leq{} N-1$の組に対して、
$$
\mathrm{dist}[i][j] \leftarrow{} \min{}(\mathrm{dist}[i][j], ~ \mathrm{dist}[i][k] + \mathrm{dist}[k][j])
$$

以上を終えたとき、$\mathrm{dist}[i][j]$は頂点iから頂点jへの最短経路長が入っている。

## アルゴリズムの説明
下準備として、与えられたネットワークの辺が存在しない頂点対には距離無限大の辺が存在するとみなす。
こうすると、N頂点有向完全グラフになる。
そして、到達可能性を距離が有限であるかどうかで判定するとする。

このアルゴリズムは次の部分問題を用いた動的計画法とみなせる。

- 番号k以下の頂点のみを経由するとき、頂点iから頂点jへの最短経路はいくらか？

この問題が解けるとすると、k=N-1の問題に対する解が求めたい解そのものである。

このアルゴリズムを理解する鍵は、あるkとk+1における問題を考えることであると思う。

### 適当なkに対して問題を考える。

頂点iから頂点jへの最短経路は次のような構造になっている。

頂点i -> (頂点i, jを除いたk以下の頂点集合の部分集合の順列) -> 頂点j

### k+1に対して問題を考える。
kに対する問題が解けているという仮定のもとで議論を進める。

このとき、新しく最短経路となりうるのは、途中経路に頂点k+1を含むものに限られる。
(なぜなら、k以下に限った解は上の部分問題で解けているから)

つまり、最短経路は次のような構造になっている。

頂点i -> (頂点i, jを除いたk以下の頂点集合の部分集合の順列) -> 頂点k+1 -> (頂点i, jを除いたk以下の頂点集合の部分集合の順列) -> 頂点j

ここで、負閉路が存在しないことを仮定しているため、
上の経路が最短になるのは、i->k+1とk+1->jの経路が最短になるときである。
なぜなら、そうでない場合は経路を最短のものに変えることで距離を必ず改善できるからである。

さて、i->k+1とk+1->jの最短経路は、kに対しての部分問題を解いたときにすでに解けていることに気づくだろうか？
わからない人は、部分問題の設定を見直してみてほしい。

したがって、k+1における問題は
$$
\mathrm{dist}[i][j] = \min(\mathrm{dist}[i][j], ~ \mathrm{dist}[i][k+1] + \mathrm{dist}[k+1][j])
$$
という遷移で解けることがわかる。

### まとめ
ここまで分かったことをまとめる。

- 解きたい問題は、k=N-1のときの部分問題である。
- kに対して問題が解けるならば、k+1に対して問題が解ける。

あと必要なのは、一番最初のケースを解けるのか？ということである。

k=-1を考える。
これは、始点と終点以外の頂点を一切経由しないときの最短経路問題であり、この部分問題のベースケースである。

この問題は明らかに頂点iから頂点jへ辺が存在するかどうかを見るだけで解くことができる。

以上より、帰納的に問題が解けることが理解できる。

### 負閉路が存在するとき
負閉路が存在するとき、そこを通ることができる経路に対する最短経路はいくらでも縮めることができる。
しかし、このときワーシャル・フロイド法は$-\infty$を返さないことがあり得る。(というか、まず$-\infty$にはならない)

遷移を見ればわかるとおり、ワーシャル・フロイド法により求まるのは最短「パス」であるからである。
つまり、真の最短経路が閉路を含む(同じ頂点を2回以上通る)ものは正しく結果を求めることができない。

### 追記(2023-10-05)
以下、[アルゴリズムロジック](https://algo-logic.info/warshall-floyd/)からの情報を追加します。
疲れているときに書いたので、普段以上に内容が怪しいかもしれません。ご注意ください。

#### 負閉路の検出
負閉路が含まれているとき、閉路中の任意の一つの頂点をiとする。すると、iからiへの最短パスは総和が最小となる負閉路をぐるっと一周回ったものが採用される。
負閉路がない時、$\mathrm{dist}[i][i] = 0$となるはずなので、これを用いて$O(N)$で検出できる。
```d
bool hasNegativeCycle () {
    for (int i = 0; i < N; i++) {
        if (dist[i][i] < 0) return true;
    }
    return false;
}
```

#### 最短距離の一つを復元
$\mathrm{prev}[i][j] \coloneqq$ ($i$から$j$への最短経路で、$j$の一つ前にいた頂点) とすると、空間$O(N^2)$を用いて復元できる。
$\mathrm{prev}$は$\mathrm{dist}$と一緒に更新するとよい。

$\mathrm{prev}$の初期値は次のようになる。

$$
\mathrm{prev}[i][j] \coloneqq
\begin{cases}
i & \text{if $(i = j) \lor (iからjへ辺が存在する)$,} \\\\
-1 & \text{otherwise.}
\end{cases}
$$
-1は異常値として採用しています。

更新は、$\mathrm{dist}$と一緒に行います。
```d
for (int k = 0; k < N; k++) {
    for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
        if (dist[i][k] < int.max && dist[k][j] < int.max && dist[i][k] + dist[k][j] < dist[i][j]) {
            dist[i][j] = dist[i][k] + dist[k][j];
            prev[i][j] = prev[k][j];
        }
    }
}
```
復元は次のようになります。
```d
int[] restorePath (int start, int end) {
    if (prev[start][end] == -1) return [];

    int[] res;

    int cur = end;
    while (cur != start) {
        res ~= cur;
        cur = prev[start][cur];
    }
    res ~= start;
    res.reverse;

    return res;
}
```

## 実装例
次の問題に回答するD言語によるコードを示す。(本問題はワーシャル・フロイド法を用いなくても解けるが、簡単のため採用した。)

問題

頂点$U$から頂点$V$への最短経路を出力せよ。到達不能である場合、`-1`を出力せよ。

入力形式

<pre style="background: #e1e1e1; padding: 1em; border: #c3c3c3 1px solid;">
N  M
U  V
u_1 v_1 w_1
u_2 v_2 w_2
.
.
.
u_M v_M w_M
</pre>

```d
import std;

void main () {
    /* input N, M */
    int N, M; readln.read(N, M);
    int U, V; readln.read(U, V);
    U--, V--; // 0-indexed

    /* difine dist[][] */
    int[][] dist = new int[][](N, N);
    foreach (i; 0..N) foreach (j; 0..N) dist[i][j] = int.max;
    foreach (i; 0..N) dist[i][i] = 0;

    /* input all edge */
    foreach (_; 0..M) {
        int u, v, w; readln.read(u, v, w);
        u--, v--;
        dist[u][v] = w;
    }

    solve(N, M, U, V, dist);
}

void solve (int N, int M, int U, int V, int[][] dist) {
    /* Floyd-Warshall Algorithm */
    for (int k = 0; k < N; k++) {
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
            if (dist[i][k] < int.max && dist[k][j] < int.max) {
                dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
            }
        }
    }

    /* output */
    if (dist[U][V] < int.max) {
        writeln(dist[U][V]);
    } else {
        writeln(-1);
    }
}
```
ジャッジはないし、veryfyもないです。何ならコンパイルすらしてないので間違っているかもしれないですが、参考程度でお願いします。

## 練習問題
本記事を読んだ方は、ぜひ挑戦してみてほしい。
大抵の場合、全点対最短距離に帰着するまでのパートはかなり明らかなことが多いので、ネタバレはそこまで問題ではないと思う。
- [ABC208D](https://atcoder.jp/contests/abc208/tasks/abc208_d)
- [ABC79D](https://atcoder.jp/contests/abc079/tasks/abc079_d)

## 参考文献
- 浅野 孝夫. グラフ・ネットワークアルゴリズムの基礎 数理とCプログラム(初版). 近代科学社, 2017.

様々なグラフアルゴリズムを簡潔に紹介しています。グラフ理論による厳密な証明などは比重が小さく、数学系でない人も気軽に内容を浚える本だと思います。

- rp523. "ワーシャルフロイド法がなぜうまくいくのか、改めて考えてみる". qiita. 2022. [https://qiita.com/rp523/items/8fba3882c4a6ea203757](https://qiita.com/rp523/items/8fba3882c4a6ea203757), (2023-10-02閲覧).

この動的計画法がどのようにして状態を圧縮しているのかを丁寧に説明しています。

- 吉田 雄真. "参考文献の書き方". 新潟大学付属図書館. 2021. [https://www.lib.niigata-u.ac.jp/learning_support/doc/20210709-3.pdf](https://www.lib.niigata-u.ac.jp/learning_support/doc/20210709-3.pdf), (2023-10-02閲覧).

参考文献リストはこの文献を参考に書きました。
