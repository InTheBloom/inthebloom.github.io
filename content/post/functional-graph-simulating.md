---
title: "[メモ] Functional Graph上のシミュレーション"
# description: 

date: 2024-04-15
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
  - アルゴリズム
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

## 概要
本稿において、$N$頂点$N$辺からなる有向グラフであって、すべての頂点の出次数が1であるグラフを**functional graph**と呼ぶ。

本稿の目的は、次の問題を時間計算量$O(N \log k)$で解く方法を簡潔にまとめることである。

<div style="padding : 1em; border : black 1px solid;">
始点$u$が与えられる。
頂点$p$を始点とする辺の終点を$f(p)$と表記するとき、
$\underbrace{f(f( \dots f(u) \dots ))} _ {k \text{times}}$を求めよ。
</div>

## 方法1 - ダブリング
- 時間計算量(前計算) : $\Theta (N \log k)$
- 空間計算量(前計算) : $\Theta (N \log k)$
- クエリ : $O(\log k)$

次の動的計画法を行う。
$$\mathrm{dp} _ {i, j} \coloneqq \text{頂点$i$から$2^j$回移動したときに到達する頂点}$$

初期値

$$\mathrm{dp} _ {i, 0} = f(i)$$

更新

$$\mathrm{dp} _ {i, j + 1} = \mathrm{dp} _ {\mathrm{dp} _ {i, j}, j}$$

これは$j$の昇順に行うことができる。$j$は$\log(k)$程度までで十分である。
$k \leq 10^9$であれば30程度、$k \leq 10^{18}$であれば60程度になる。

上記のテーブルを構築した上で、$f(f( \dots f(u) \dots))$は次のように求める。

非負整数$x$の二進数表示において、$n ~ \text{bit}$目の値を返す関数を$\mathrm{bit}(x, n)$とする。
$j = 1, 2, \dots$に対して、順に次を行う。

$\mathrm{bit}(k, j) = 1$ならば$u \leftarrow \mathrm{dp} _ {u, j}$とする。

アルゴリズムが終了した時点での$u$の値は$f(f( \dots f(u) \dots ))$に等しい。

### 利点
- 前計算が完了していれば、任意の始点に対して1回あたり$O(\log k)$で計算できる。

### 欠点
- グラフのサイズによってはTime LimitやMemory Limitがギリギリになる場合がある。

### 補足
$\mathrm{dp} _ {i, j}$の値は必ずしも頂点である必要はなく、ある関数$g$を用いて$g(\mathrm{dp} _ {i, j}) = \text{頂点$i$から$2^j$回移動したときに到達する頂点}$とできる値ならばどのように決めても良い。

## 方法2 - 両端キューを用いる方法
- 時間計算量 : $O(N)$
- 空間計算量 : $O(N)$

次のアルゴリズムにより計算する。

到達済み頂点の集合を$\mathrm{seen}$とする。最初$\mathrm{seen} = \emptyset$である。
また、現在の頂点を$\mathrm{cur}$とする。最初$\mathrm{cur} = u$である。
空の両端キューを$\mathrm{deque}$とする。

1. $\mathrm{cur} \in \mathrm{seen}$であれば手順4を行う。
2. $\mathrm{seen} \leftarrow \mathrm{seen} \cup \mathrm{cur}$とし、$\mathrm{deque}$の末尾に$\mathrm{cur}$を追加する。その後$\mathrm{cur} \leftarrow f(\mathrm{cur})$と更新する。
3. 手順1を行う。
4. $\mathrm{deque}$の先頭要素が$\mathrm{cur}$と等しい、または$k = 0$であれば手順7を行う。
5. $\mathrm{deque}$の先頭要素を取り除き、$k \leftarrow k - 1$と更新する。
6. 手順4を行う。
7. $k \leftarrow k \mod \vert \mathrm{deque} \vert$と更新する。ただし$\vert \mathrm{deque} \vert$は$\mathrm{deque}$の要素数である。
8. $k = 0$であれば$\mathrm{deque}$の先頭要素を出力し、手順を終了する。
9. $\mathrm{deque}$の先頭要素を取り除き、$k \leftarrow k - 1$と更新する。
10. 手順8を行う。

<details>
<summary>アルゴリズムの説明</summary>
手順1, 2, 3で閉路を含む頂点集合を列挙している。なお、$\mathrm{deque}$内の要素は常に実際の訪問順と等しい。

手順4, 5, 6で閉路を構成する頂点集合を抽出している。$k$が十分に小さい場合、閉路の頂点を抽出し終わる前にこの部分を抜ける。その時は$\mathrm{deque}$の先頭要素が求める値になっている。

手順7で閉路のループを一括処理している。$k = 0$には影響しないことに注意。

手順8, 9, 10で最後の1周をシミュレーションにより求めている。これまでと同様に$k = 0$であれば最初に手順8を行う時点で終了することに注意。
</details>

### 利点
- ダブリングと比較して、Time LimitやMemory Limitの点で有利である。

### 欠点
- 始点一つに対して$O(N)$時間かかるため、クエリ処理に向かない。
- ダブリングと比較して、アルゴリズムがやや複雑である。

## 実装例
適用できる問題と、その解答コードを掲載する。(ネタバレ注意)
これを見ながらコーディングすることを想定しているため、問題の解法に関する言及はない。

### ABC167D - Telepoter (ダブリング/両端キュー)
[問題へのリンク](https://atcoder.jp/contests/abc167/tasks/abc167_d)

```d
void solve (int N, long K, int[] A) {
    DList!int Q;
    bool[] vis = new bool[](N);

    int cur = 0;
    while (vis[cur] == 0) {
        Q.insertBack(cur);
        vis[cur] = true;
        cur = A[cur];
    }

    // ループ入るまでpop
    while (0 < K && Q.front != cur) {
        Q.removeFront;
        K--;
    }
    K %= Q.dup.array.length;

    // 残りシミュレーション
    while (0 < K) {
        Q.removeFront;
        K--;
    }

    writeln(Q.front + 1);
}
```

```d
void solve (int N, long K, int[] A) {
    const int max_bit = 60;
    int[][] dp = new int[][](N, max_bit + 1);

    // 初期化
    foreach (i; 0..N) {
        dp[i][0] = A[i];
    }

    foreach (j; 0..max_bit) {
        foreach (i; 0..N) {
            dp[i][j + 1] = dp[dp[i][j]][j];
        }
    }

    // 繰り返し二乗法の要領でK手を「ほぐす」
    int ans = 0;
    foreach (i; 0..max_bit + 1) {
        if (0 < ((1L << max_bit) & K)) {
            ans = dp[ans][i];
        }
    }

    writeln(ans + 1);
}
```

### ARC113C - A^B^C (両端キュー)
[問題へのリンク](https://atcoder.jp/contests/arc113/tasks/arc113_b)

```d
void solve (int A, int B, int C) {
    // A^{B^C} % 10を考える。
    // Aの冪はmod10で考えるとfunctional graphとみなせる

    bool[] vis = new bool[](10);
    DList!int Q;
    A %= 10;
    int cur = A;
    int MOD = 0;

    while (!vis[cur]) {
        MOD++;
        vis[cur] = true;
        Q.insertBack(cur);

        // 更新
        cur *= A;
        cur %= 10;
    }

    long power = ModPow(B, C, MOD);
    foreach (_; 0..(MOD + power - 1) % MOD) {
        Q.removeFront;
    }

    writeln(Q.front);
}
```

### ABC258E - Packing Potatoes (ダブリング)
[問題へのリンク](https://atcoder.jp/contests/abc258/tasks/abc258_e)

```d
void solve (int N, int Q, int X, int[] W) {
    // 始点を決めれば終点が決まる。これはfunctional graphとみなせて、ダブリングでK番目に蓋をする箱の始点が見つかる。
    int x = X;
    long sum = 0;
    foreach (w; W) sum += w;
    x %= sum;

    auto dp = new int[][](N, 64);
    auto ans = new long[](N);

    // 尺取りで最初の1回を見つける。
    auto w = W ~ W;
    int l = 0, r = 0;
    long s = 0;
    while (l < N) {
        while (s < x) {
            s += w[r];
            r++;
        }
        dp[l][0] = r % N;
        ans[l] = (r-l) + N * (X / sum);

        s -= W[l];
        l++;
    }

    // doubling
    foreach (k; 1..64) {
        foreach (i; 0..N) dp[i][k] = dp[ dp[i][k-1] ][k-1];
    }

    foreach (_; 0..Q) {
        long K = readln.chomp.to!long;
        K--;
        int cur = 0;
        foreach (i; 0..64) {
            if (0 < (K & (1L << i))) cur = dp[cur][i];
        }

        writeln(ans[cur]);
    }
}
```

### ABC30d - へんてこ辞書 (両端キュー)
[問題へのリンク](https://atcoder.jp/contests/abc030/tasks/abc030_d)

```d
void solve (int N, int a, BigInt k, int[] b) {
    // functional graphのシミュレーション 単一始点はキューでやると楽
    bool[int] seen;

    int cur = a;
    DList!int Q;
    int size = 0;

    while (true) {
        if (cur in seen) break;
        seen[cur] = true;
        Q.insertBack(cur);
        size++;
        cur = b[cur];
    }

    // ループだけが残る or kが0になるまでremove
    while (true) {
        if (k == 0) break;
        if (Q.front() == cur) break;
        Q.removeFront();
        size--;
        k--;
    }

    k %= size;
    while (0 < k) {
        Q.removeFront();
        k--;
    }

    writeln(Q.front() + 1);
}
```

### ABC136D - Gathering Children (ダブリング)
[問題へのリンク](https://atcoder.jp/contests/abc136/tasks/abc136_d)

```d
void solve (string S) {
    int[][] dp = new int[][](S.length, 18);
    // dp[i][j] := 頂点iから2^j回移動した先

    foreach (i; 0..S.length) dp[i][0] = (S[i]=='R' ? cast(int) (i+1) : cast(int) (i-1));

    foreach (j; 0..17) {
        foreach (i; 0..S.length) {
            dp[i][j+1] = dp[dp[i][j]][j];
        }
    }

    // 10^{100}は過剰なので、10^5回移動したとする
    int move = 10^^5;
    int[] ans = new int[](S.length);

    foreach (i; 0..S.length) {
        int bit = 0;
        int cur = cast(int) i;
        while ((1<<bit) <= move) {
            if (0 < (move & (1<<bit))) cur = dp[cur][bit];
            bit++;
        }
        ans[cur]++;
    }

    foreach (i, a; ans) {
        write(a, i == ans.length-1 ? '\n' : ' ');
    }
}
```

### yukicoder No.2716 Falcon Method (ダブリング)
[問題へのリンク](https://yukicoder.me/problems/no/2716)

```cpp
int main () {
    int N, Q; cin >> N >> Q;
    string s; cin >> s;

    int D = 0, R = 0;
    for (auto c : s) {
        if (c == 'D') D++;
        if (c == 'R') R++;
    }

    if (D == 0) {
        for (int i = 0; i < Q; i++) {
            int H, W, P; cin >> H >> W >> P;
            cout << (P + W) % N << "\n";
        }
        return 0;
    }

    if (R == 0) {
        for (int i = 0; i < Q; i++) {
            int H, W, P; cin >> H >> W >> P;
            cout << (P + H) % N << "\n";
        }
        return 0;
    }

    // 両方向でダブリング -> 短い方を採用

    const int MAX = 32;
    vector<vector<ll>> dp_R(N + 1, vector<ll>(MAX)), dp_D(N + 1, vector<ll>(MAX));
    // dp_R[i][j] := カウンタiからスタートして、(カウンタiは踏む)右に2^jマス進むために踏むマス数

    {
        int l = 0, r = 0;
        while (l < N) {
            if (r < l) r = l;

            while (true) {
                if (s[r % N] == 'R') break;
                r++;
            }

            dp_R[l][0] = r - l + 1;
            l++;
        }
    }

    {
        int l = 0, r = 0;
        while (l < N) {
            if (r < l) r = l;

            while (true) {
                if (s[r % N] == 'D') break;
                r++;
            }

            dp_D[l][0] = r - l + 1;
            l++;
        }
    }

    for (int j = 0; j < MAX - 1; j++) {
        for (int i = 0; i < N; i++) {
            dp_R[i][j + 1] = dp_R[(i + dp_R[i][j]) % N][j] + dp_R[i][j];
            dp_D[i][j + 1] = dp_D[(i + dp_D[i][j]) % N][j] + dp_D[i][j];
        }
    }

    for (int i = 0; i < Q; i++) {
        int H, W, P; cin >> H >> W >> P;

        ll h = P;
        ll w = P;

        for (int j = 0; j < MAX; j++) {
            if (0 < (H & (1LL << j))) {
                h += dp_D[h % N][j];
            }
        }

        for (int j = 0; j < MAX; j++) {
            if (0 < (W & (1LL << j))) {
                w += dp_R[w % N][j];
            }
        }

        cout << min(h, w) % N << "\n";
    }
}
```

### 水以下コンテストB - f(f(f(f(f(x))))) (ダブリング)
[問題へのリンク](https://mofecoder.com/contests/cyan_or_less_01/tasks/cyan_or_less_01_b)

```cpp
// 構文解析部分は省略
int main () {
    ll K; cin >> K;
    string S; cin >> S;

    // ダブリング
    vector<vector<int>> dp(MOD, vector<int>(64));
    // dp[i][j] := iから2^j回適用した値

    for (int i = 0; i < MOD; i++) {
        dp[i][0] = analize(S, i);
    }

    for (int j = 0; j < 64; j++) {
        for (int i = 0; i < MOD; i++) {
            dp[i][j + 1] = dp[dp[i][j]][j];
        }
    }

    int ans = 1;
    for (int j = 0; j < 64; j++) {
        if (0 < (K & (1LL << j))) {
            ans = dp[ans][j];
        }
    }

    cout << ans << "\n";
}
```

## 終わりに
いっつもバグらせて混乱するのでまとめました。
追加情報及び不備の指摘は随時募集中です。
