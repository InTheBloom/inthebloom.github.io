---
title: ABC74D - Restoring Road Network
# description: 

date: 2024-02-27
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
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

## 問題
[問題へのリンク](https://atcoder.jp/contests/abc074/tasks/arc083_b)

問題

行と列の大きさがそれぞれ$N$の非負整数数表$A$がある。
表の$i$行$j$列目の成分を$A _ {i, j}$と表記する。
ここで、$A$は次の条件を満たす。

- $A _ {i, i} = 0$
- $i \neq j$のとき、$1 \leq A _ {i, j} = A _ {j, i} \leq 10^9$

次の条件を満たすネットワークが存在するか判定し、存在するなら辺の重みの和としてありうる最小値を求めよ。
存在しない場合は`-1`を出力せよ。

- 辺の重みは正整数。
- $A _ {i, j}$は頂点$i$から$j$への最短経路長である。

制約

- $1 \leq N \leq 300$

## 考察
重要な性質として、次が成立します。

- 頂点$i$と頂点$j$を結ぶ辺は、存在するなら重み$A _ {i, j}$である。

これは次の理由によります。

- 重み$A _ {i, j}$より小さい辺が存在するとき、明らかに制約を満たさない。
- 重み$A _ {i, j}$より大きい辺が存在するとき、それを削除しても任意の最短経路に影響しない。

したがって、どの辺を採用するかを考えればよいです。

まず、重みが正整数であることから、辺の重みが$\min (A)$であるものは必ず存在する必要があります。
そうでない場合、$\min (A)$未満の経路が必ず生まれてしまうからです。

そのほかの辺に関しては、その時点で存在する辺だけを用いた時の全点対最短経路がわかれば、重み昇順に決めていくことができます。
例えば、$(u, v)$に辺が存在するかチェックしたいとき、その時点での最短経路長を返す関数を$\mathrm{dist}$と表記すると、

1. $\mathrm{dist}(u, v) = A _ {u, v}$であれば、辺は必要ない。
2. $\mathrm{dist}(u, v) &lt; A _ {u, v}$であれば、条件を満たすネットワークは存在しない。
3. $A _ {u, v} &lt; \mathrm{dist}(u, v)$であれば、辺は必要。

となります。
2番目の条件は少し非自明に感じますが、決定済みの辺割り当てが必要十分であることから従います。

さて、あとは各時点での全点対最短経路を求められればよいです。
新しく辺$(u, v)$を追加したとき、その辺を通る経路だけ考えればよいので、$0 \leq x, y &lt; N$に対して、
<div style="overflow:scroll;">
$$
\mathrm{dist}(x, y), \mathrm{dist}(y, x) \leftarrow \min (\mathrm{dist}(x, y), \mathrm{dist}(x, u) + \mathrm{dist}(u, v) + \mathrm{dist}(v, y))
$$
</div>
という更新をすればよいです。

以上より、辺の候補が$\Theta (N^2)$個で、更新に$\Theta (N^2)$回の手順が必要であるから、worst $\Theta (N^4)$で解くことができます。

さらに、もう少し考察することで$\Theta (N^3)$で解くこともできます。
上述の解法で、

> そのほかの辺に関しては、その時点で存在する辺だけを用いた時の全点対最短経路がわかれば、重み昇順に決めていくことができる。
> 例えば、$(u, v)$に辺が存在するかチェックしたいとき、その時点での最短経路長を返す関数を$\mathrm{dist}$と表記すると、

としていましたが、実は「その時点で存在する辺だけを用いたときの全点対最短経路」は逐次更新する必要はありません。

上記解法では「それまでの辺候補を全採用したときの、辺$(u, v)$を用いない$(u, v)$最短経路長」さえわかれば十分です。
以降の辺候補の重みがすべて$\mathrm{dist}(u, v)$以上であることを考えると、それらの辺は存在しても存在しなくても$(u, v)$をとるかどうかの判定に必要な部分に影響しません。

以上より、最初に「辺候補をすべて採用したネットワークにおける全点対最短経路長」を求めておいて、
$(u, v)$の判定には$\min _ {0 \leq x &lt; N} \mathrm{dist}(u, x) + \mathrm{dist}(x, v)$を用いればよいです。

こうすることで、前計算$\Theta (N^3)$、判定$\Theta (N)$になり、全体の計算量オーダー$\Theta (N^3)$になります。

## 実装例

### worst $\Theta (N^4)$
```d
import std;

void main () {
    int N = readln.chomp.to!int;
    auto A = new int[][](N, 0);
    foreach (i; 0..N) A[i] = readln.split.to!(int[]);

    solve(N, A);
}

void solve (int N, int[][] A) {
    // 非負の辺しかないので、Aの最小の値に関しては確定できる。
    // それ以外にも、重みの昇順に見ていくことを考えると、
    // 1. 重み分の辺をはる
    // 2. すでに制約が満たされている
    // のどちらかしかありえない。なぜなら、重みより小さい辺を新しくはると別の場所で制約違反が必ず起きるし、より大きな辺をはるとどうやっても達成できないから。
    // さらに、追加していく辺が重み昇順であることを考えると、タイプ1の時はチェックすらしなくてよい。

    Tuple!(int, int, int)[] edges;

    foreach (i; 0..N) {
        foreach (j; i+1..N) {
            edges ~= tuple(i, j, A[i][j]);
        }
    }

    edges.sort!"a[2] < b[2]";

    long ans = 0;
    auto dist = new long[][](N, N);
    foreach (d; dist) d[] = long.max;
    foreach (i; 0..N) dist[i][i] = 0;

    bool ok = true;

    foreach (e; edges) {
        if (dist[e[0]][e[1]] == e[2]) continue;
        if (dist[e[0]][e[1]] < e[2]) ok = false;

        if (e[2] < dist[e[0]][e[1]]) {
            ans += e[2];

            // floyd-warshallっぽく更新
            // 辺をセット
            dist[e[0]][e[1]] = dist[e[1]][e[0]] = e[2];

            foreach (i; 0..N) foreach (j; 0..N) {
                if (dist[i][e[0]] < long.max && dist[e[1]][j] < long.max) {
                    dist[i][j] = dist[j][i] = min(dist[i][j], dist[i][e[0]] + dist[e[0]][e[1]] + dist[e[1]][j]);
                }
            }
        }
    }

    if (ok) {
        writeln(ans);
    }
    else {
        writeln(-1);
    }
}
```
[提出](https://atcoder.jp/contests/abc074/submissions/50664969)

### $\Theta (N^3)$
```d
import std;

void main () {
    int N = readln.chomp.to!int;
    auto A = new int[][](N, 0);
    foreach (i; 0..N) A[i] = readln.split.to!(int[]);

    solve(N, A);
}

void solve (int N, int[][] A) {
    // Θ(N^3)解法

    Tuple!(int, int, int)[] edges;

    foreach (i; 0..N) {
        foreach (j; i+1..N) {
            edges ~= tuple(i, j, A[i][j]);
        }
    }

    edges.sort!"a[2] < b[2]";

    long ans = 0;

    auto dist = new long[][](N, N);
    foreach (d; dist) d[] = long.max;
    foreach (i; 0..N) dist[i][i] = 0;
    foreach (e; edges) dist[e[0]][e[1]] = dist[e[1]][e[0]] = e[2];

    foreach (k; 0..N) {
        foreach (i; 0..N) foreach (j; 0..N) {
            if (dist[i][k] == long.max || dist[k][j] == long.max) continue;
            dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
        }
    }

    bool ok = true;

    foreach (e; edges) {
        long d = long.max;
        foreach (i; 0..N) {
            if (i == e[0] || i == e[1]) continue;
            d = min(d, dist[e[0]][i] + dist[i][e[1]]);
        }

        if (d == e[2]) continue;
        if (d < e[2]) ok = false;

        if (e[2] < d) {
            ans += e[2];
        }
    }

    if (ok) {
        writeln(ans);
    }
    else {
        writeln(-1);
    }
}
```
[提出](https://atcoder.jp/contests/abc074/submissions/50670075)

## 終わりに
この問題は私にとって非常に難しかったです。
最小重みの辺を確定させることができるのは最初に気が付きましたが、そこからが本当に長かった。

辺候補を昇順に見ていくことがツボで、こうすることであとから追加する辺の影響を考えなくてよくなるのですが、これに気が付くまでかなり時間を要しました。
逆に、これに気が付いてからは割と道筋が見えてきて、あとは採用した辺を用いた最短経路問題をどうにかできればよいというところまで来ました。

結局この点は解決できず、$O(N^4)$で解きました。
あとから解説を見て$\Theta (N^3)$解法を理解しましたが、
「その時点での最短経路はそれまでの辺を全採用したことにしても変わらない」という点に気が付いていなかったなという感想です。

こういうad-hoc寄りな問題全般に言えることですが、
問題を考えるプロセスや、解決したときの喜びは大きいです。しかし、この問題がコンテストに出たらと思うとぞっとします。
