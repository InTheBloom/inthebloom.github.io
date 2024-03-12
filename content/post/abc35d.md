---
title: ABC35D - トレジャーハント
# description: 

date: 2024-03-12
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 典型テク
archives:
  - 2024
  - 2024-03
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要

[問題へのリンク](https://atcoder.jp/contests/abc035/tasks/abc035_d)

### 問題文

$1$から$N$の番号が割り振られた$N$個の町があり、$M$本の道がこれらの町を結んでいる。
$i$番目の道を用いることで$a _ i$番目の町から$b _ i$番目の町へと移動できるが、逆はできない。

高橋君は、$i$番目の町に1分間滞在することで、$A _ i$円得ることができる。
また、高橋君の開始$0$分時点での所持金は$0$円で、開始$0$分時点と$T$分時点で$1$番目の町にいたことがわかっている。

高橋君の所持金は、最大でいくらまで増やせるだろうか。

### 制約

- $2 \leq N \leq 10^5$
- $1 \leq M \leq \min (N(N-1), 10^5)$
- $1 \leq T \leq 10^9$
- $1 \leq A _ i \leq 10^5$

## 解法

この問題において、高橋君がお金を得る町は1つに絞るのが最適になります。

条件を満たす動きであって、2つ以上の町でお金を得るようなものを考えます。
この時、得られる金額がより大きな町のみでお金を稼ぐようにすると、必ず元の解以上の金額を得ることができるからです。

以上より、本問題は次の値を求められれば良いです。

$$
\max _ {1 \leq k \leq N} ( A _ k \times \max(0, T - (\text{町$1$から町$k$に行く最短時間}) - (\text{町$k$から町$1$に行く最短時間})) )
$$

$(\text{町$1$から町$k$に行く最短時間})$はダイクストラ法などで十分高速に計算することができます。
厄介なのは、$(\text{町$k$から町$1$に行く最短時間})$を求めるところです。

厄介な点は次の2つです。
1. 有向グラフにおいて、町$1$から町$k$の最短経路は町$k$から$1$の最短経路と異なる可能性があるので、町$1$からの最短経路が使いまわせない。
2. 各頂点からダイクストラ法をすると間に合わない。

実は、すべての$(\text{町$k$から町$1$に行く最短時間})$を1回のダイクストラ法で計算するうまい方法があります。
それは、通行方向を逆にしたグラフ上で町$1$からの最短経路問題を解くことです。

なぜこれが動作するのかの説明をします。
まず、元のグラフ上で、ある町$k$から町$1$への最短経路を成す頂点列$(v _ 0, v _ 1, \dots , v _ x)$を考えます。
ここで、$v _ 0 = k$と$v _ x = 1$が成立することに注意してください。

辺の通行方向を逆にしたグラフを考えると、明らかに頂点列$(v _ x, v _ {x-1}, \dots , v _ 0)$を経由するパスが存在し、そのコストも等しいです。
そして、逆グラフにおいてもこれ以上コストを小さくするパスは存在しません。なぜなら、そのようなパスが存在するとき、元のグラフ上にも存在するはずだからです。

元のグラフ上で町$k$から町$1$に到達不能であるときも、同様の議論により逆グラフにおいて到達不能であることが言えます。
よって、逆グラフ上での町$1$からの探索は正しい値を返します。

以上より、本問題を解くことができます。

## 実装例

```d
import std;

void main () {
    int N, M, T; readln.read(N, M, T);
    auto A = readln.split.to!(int[]);
    auto edges = new Tuple!(int, int, int)[](M);

    foreach (i; 0..M) {
        int a, b, c; readln.read(a, b, c);
        a--, b--;
        edges[i] = tuple(a, b, c);
    }

    solve(N, M, T, A, edges);
}

void solve (int N, int M, int T, int[] A, Tuple!(int, int, int)[] edges) {
    // どの場所で金稼ぎをするか？を全探索できる
    // 逆辺をはることで帰りの時間を求められる。

    auto one_to_k = new long[](N);
    auto k_to_one = new long[](N);

    one_to_k[] = long.max;
    k_to_one[] = long.max;

    BinaryHeap!(Tuple!(int, long)[], "b[1] < a[1]") PQ = [];

    {
        auto graph = new Tuple!(int, int)[][](N, 0);
        foreach (e; edges) {
            graph[e[0]] ~= tuple(e[1], e[2]);
        }

        // 1 -> k
        PQ.insert(tuple(0, 0L));

        while (!PQ.empty) {
            auto h = PQ.front; PQ.removeFront;
            int u = h[0];
            long cost = h[1];

            if (one_to_k[u] < cost) continue;
            one_to_k[u] = cost;

            foreach (to; graph[u]) {
                int v = to[0];
                long new_cost = cost + to[1];
                if (one_to_k[v] <= new_cost) continue;

                one_to_k[v] = new_cost;
                PQ.insert(tuple(v, new_cost));
            }
        }
    }

    {
        auto graph = new Tuple!(int, int)[][](N, 0);
        foreach (e; edges) {
            graph[e[1]] ~= tuple(e[0], e[2]);
        }

        // k -> 1
        PQ.insert(tuple(0, 0L));

        while (!PQ.empty) {
            auto h = PQ.front; PQ.removeFront;
            int u = h[0];
            long cost = h[1];

            if (k_to_one[u] < cost) continue;
            k_to_one[u] = cost;

            foreach (to; graph[u]) {
                int v = to[0];
                long new_cost = cost + to[1];
                if (k_to_one[v] <= new_cost) continue;

                k_to_one[v] = new_cost;
                PQ.insert(tuple(v, new_cost));
            }
        }
    }

    long ans = 0;
    foreach (i; 0..N) {
        if (one_to_k[i] == long.max || k_to_one[i] == long.max) continue;
        if (T <= one_to_k[i] + k_to_one[i]) continue;
        ans = max(ans, A[i] * (T - (one_to_k[i] + k_to_one[i])));
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

## 感想

「元のグラフの$k \rightarrow 1$最短経路は逆グラフの$1 \rightarrow k$最短経路と同じ」という事実を非自明に感じたので、解法を残しておくことにした。
いつか別の問題に役立ちそうな気がする。
