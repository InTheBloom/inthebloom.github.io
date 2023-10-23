---
title: yukicoder contest407参加記録
# description: 

date: 2023-10-06
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - コンテスト参加記録
archives:
  - 2023
  - 2023-10
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## はじめに
本稿は2023-10-06に行われた[yukicoder contest 407](https://yukicoder.me/contests/460)の参加記録です。

## 戦績

## 雑振り返り

### A - napsack Problem?
[問題へのリンク](https://yukicoder.me/problems/no/2492)

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1696599879/pictures/yuki407/A_boi29r.png)

重さW以下のナップサックのうち、容量の最大値を見ていくだけです。O(N)
この人は単にデカいナップサックが欲しいだけみたいですね。

```d
import std;

void main () {
    int N, W; readln.read(N, W);
    int[] v = new int[](N);
    int[] w = new int[](N);
    foreach (i; 0..N) {
        readln.read(v[i], w[i]);
    }

    int ans = -1;

    foreach (i; 0..N) {
        if (w[i] <= W && ans < v[i]) {
            ans = v[i];
        }
    }

    writeln(ans);
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

### B - K-th in L2 with L1
[問題へのリンク](https://yukicoder.me/problems/no/2493)

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1696599879/pictures/yuki407/B_pxrwt3.png)

結構問題文の読解が難しいと感じました。
ユークリッド距離がDであるような点は高々4D個になるので、
1. 全部列挙
2. すべてに対するユークリッド距離を計算して配列に格納
3. 良い点一つ一つについて、条件を満たすかどうか二分探索

でO(Dlog(D))だと思います。

```d
import std;

void main () {
    int Q = readln.chomp.to!int;
    foreach (_; 0..Q) {
        int D, K; readln.read(D, K);
        solve(D, K);
    }
}

void solve (int D, int K) {
    // マンハッタン距離Dの点集合を列挙
    alias coord = Tuple!(int, "y", int, "x");
    bool[coord] DistanceDPoints;
    for (int i = 0; i <= D; i++) {
        int y = D-i;
        int x = i;
        DistanceDPoints[coord(y, x)] = true;
        DistanceDPoints[coord(y, -x)] = true;
        DistanceDPoints[coord(-y, x)] = true;
        DistanceDPoints[coord(-y, -x)] = true;
    }

    int[] dist;
    foreach (key, val; DistanceDPoints) {
        dist ~= key.y^^2 + key.x^^2;
    }

    dist.sort;

    // 二分探索
    int f (int idx) {
        if (idx < 0) return -int.max;
        if (dist.length <= idx) return int.max;
        return dist[idx];
    }

    foreach (key, val; DistanceDPoints) {
        int EuclidDist = key.y^^2 + key.x^^2;
        {
            int ok = 0, ng = cast(int) dist.length;
            while (1 < abs(ok-ng)) {
                int mid = (ok+ng) / 2;
                if (f(mid) <= EuclidDist) { 
                    ok = mid;
                } else {
                    ng = mid;
                }
            }
            if (ok+1 < K) continue;
        }
        {
            int ok = -1, ng = cast(int) dist.length;
            while (1 < abs(ok-ng)) {
                int mid = (ok+ng) / 2;
                if (f(mid) < EuclidDist) { 
                    ok = mid;
                } else {
                    ng = mid;
                }
            }
            if (K <= ok+1) continue;
        }

        writeln("Yes");
        writeln(key.x, " ", key.y);
        return;
    }

    writeln("No");
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

おそらくかなり無駄の多い実装になっています。
こういうの結構苦手より。

### C - Sum within Components
[問題へのリンク](https://yukicoder.me/problems/no/2494)

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1696599879/pictures/yuki407/C_vewxzv.png)

連結成分を列挙していくだけです。
`visited[i]`を`bool`にするのではなく、iを含む連結成分の総和が配列の何番目に入っているか？
という情報を入れておくことで、最後x=1, 2, ..., Nについての問題をO(1)で解けます。
割と明らかな問題な気がします。Bより簡単でした。

```d
import std;

void main () {
    int N, M; readln.read(N, M);
    int[] A = readln.split.to!(int[]);
    int[][] graph = new int[][](N, 0);
    foreach (_; 0..M) {
        int U, V; readln.read(U, V);
        U--, V--;
        graph[U] ~= V;
        graph[V] ~= U;
    }

    solve(N, M, A, graph);
}

void solve (int N, int M, int[] A, int[][] graph) {
    // 連結成分を列挙していけばよいですね～
    const long MOD = 998244353;

    int[] visited = new int[](N);
    DList!int Q;
    long[] SumOfComponent;

    int idx = 0;
    visited[] = -1;

    foreach (i; 0..N) {
        if (visited[i] != -1) continue;
        visited[i] = idx;
        Q.insertBack(i);
        SumOfComponent ~= A[i];
        SumOfComponent[idx] %= MOD;

        while (!Q.empty) {
            auto head = Q.front; Q.removeFront;
            foreach (to; graph[head]) {
                if (visited[to] != -1) continue;
                visited[to] = idx;
                (SumOfComponent[idx] += A[to]) %= MOD;
                Q.insertBack(to);
            }
        }
        idx++;
    }

    long ans = 1;
    foreach (x; 0..N) {
        ans *= SumOfComponent[ visited[x] ];
        ans %= MOD;
    }

    writeln(ans);
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

### D - Three Sets
[問題へのリンク](https://yukicoder.me/problems/no/2495)

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1696599879/pictures/yuki407/D_vgla3y.png)

式いかつ過ぎです。

|S|は必ず非負整数なので、ΣAとかはなるたけでかい方が良いです。
したがって、部分集合といいつつ、要素を削るなら小さいものから削るのが最適なことが分かります。

これで各列から何個整数を持ってくるかを全探索できます。
累積和を用いてO(N<sup>3</sup>)です。
全く間に合いませんが、これ以上はわかりませんでした。

```d
import std;

void main () {
    // なるたけどれもデカいほうが良い。部分集合といいつつ、削るなら最小要素から削るべき(要素数は負にならないので、できるだけでかい方がお得)
    // O(N^3)しかわからんけど...
    int[3] N;
    int[][3] X;
    readln.read(N[0], N[1], N[2]);
    X[0] = readln.split.to!(int[]);
    X[1] = readln.split.to!(int[]);
    X[2] = readln.split.to!(int[]);

    solve(N, X);
}

void solve (int[3] N, int[][3] X) {
    // O(N^3)
    foreach (ref x; X) x.sort!"a>b";

    int[][3] sum;
    foreach (i, ref s; sum) s = new int[](N[i]+1);
    foreach (idx, ref s; sum) foreach (i, ref ss; s) {
        if (i == 0) { ss = 0; continue; }
        ss = s[i-1] + X[idx][i-1];
    }

    long ans = -long.max;
    for (int i = 0; i <= N[0]; i++) for (int j = 0; j <= N[1]; j++) for (int k = 0; k <= N[2]; k++) {
        ans = max(ans, sum[0][i]*j + sum[1][j]*k + sum[2][k]*i);
    }

    writeln(ans);
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

### E以降
Dが解けていないのであまり見ていません。

## 終わりに
yukicoderいつも難しくて良くて3問か4問までしか解けません。
