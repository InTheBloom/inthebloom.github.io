---
title: ABC100D - Patisserie ABC
# description: 

date: 2023-11-06
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 数学
archives:
  - 2023
  - 2023-11
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc100/tasks/abc100_d)

$N$種類のケーキがある。$i$種類目のケーキは「綺麗さ」$x_i$、「おいしさ」$y_i$、「人気度」$z_i$を持っている。
このうち$M$種類のケーキを選んで食べる。ただし、同じ種類のケーキを2つとることはできない。

選んだ$M$種類のケーキに対して、スコアを
$\left| \displaystyle\sum_{i=1}^M x_i \right| + 
\left| \displaystyle\sum_{i=1}^M y_i \right| +
\left| \displaystyle\sum_{i=1}^M z_i \right|$
と定める。
スコアの最大値を求めよ。

制約
- $1 \leq N \leq 1000$
- $0 \leq M \leq N$
- $1 \leq i \leq N$に対して、$-10^{10} \leq x_i, y_i, z_i \leq 10^{10}$

## 考察
ナイーブに全探索を考えると、とりうるケーキの組み合わせの数は
$\displaystyle\binom{N}{M}$通りになるが、$N = 1000, M = 500$において非常に大きくなるため現実的でない。

また、各$x_i, y_i, z_i$の値が大きいため部分和問題のようなdpはできない。
どうしようか？

## 解法1
典型テクニック: 「絶対値関数はmax関数で外す」を用いる。

頑張って変形していく。
<div style="overflow: auto">
$$
\begin{equation*}
\begin{split}
\left| \displaystyle\sum x_i \right| + 
\left| \displaystyle\sum y_i \right| +
\left| \displaystyle\sum z_i \right|
&= \max \left( \displaystyle\sum x_i, ~ -\displaystyle\sum x_i \right) +
\max \left( \displaystyle\sum y_i, ~ -\displaystyle\sum y_i \right) +
\max \left( \displaystyle\sum z_i, ~ -\displaystyle\sum z_i \right) \\
&= \max \left(
        \displaystyle\sum x_i + \displaystyle\sum y_i + \displaystyle\sum z_i, ~
        \displaystyle\sum x_i + \displaystyle\sum y_i - \displaystyle\sum z_i, ~
        \displaystyle\sum x_i - \displaystyle\sum y_i + \displaystyle\sum z_i, ~
        \displaystyle\sum x_i - \displaystyle\sum y_i - \displaystyle\sum z_i, ~
        -\displaystyle\sum x_i + \displaystyle\sum y_i + \displaystyle\sum z_i, ~
        -\displaystyle\sum x_i + \displaystyle\sum y_i - \displaystyle\sum z_i, ~
        -\displaystyle\sum x_i - \displaystyle\sum y_i + \displaystyle\sum z_i, ~
        -\displaystyle\sum x_i - \displaystyle\sum y_i - \displaystyle\sum z_i
        \right) \\
&= \max \left(
        \displaystyle\sum (x_i + y_i + z_i), ~
        \displaystyle\sum (x_i + y_i - z_i), ~
        \displaystyle\sum (x_i - y_i + z_i), ~
        \displaystyle\sum (x_i - y_i - z_i), ~
        \displaystyle\sum (-x_i + y_i + z_i), ~
        \displaystyle\sum (-x_i + y_i - z_i), ~
        \displaystyle\sum (-x_i - y_i + z_i), ~
        \displaystyle\sum (-x_i - y_i - z_i)
        \right)
\end{split}
\end{equation*}
$$
</div>
とてもすっきりした式になった。
よく見ると、最後のmax関数の中にある各項は$O(N\log N)$で計算できることが分かる。
よって全体$O(N\log N)$で解くことができる。

```D
import std;

alias trio = Tuple!(long, "x", long, "y", long, "z");

void main () {
    int N, M; readln.read(N, M);
    trio[] cake = new trio[](N);
    foreach (i; 0..N) {
        with (cake[i]) readln.read(x, y, z);
    }

    solve(N, M, cake);
}

void solve (int N, int M, trio[] cake) {
    /* 典型テク: 絶対値記号を外すやつ によって符号を変えた8通りの和で貪欲にとればよい。O(N log(N)) */
    long[] val = new long[](N);
    int[] sign = new int[](3);
    long ans = -long.max;

    void calc () {
        foreach (i; 0..N) {
            val[i] = 0;
            foreach (j, c; cake[i]) {
                if (sign[j] == 0) val[i] += c;
                if (sign[j] == 1) val[i] -= c;
            }
        }
        val.sort!"a>b";
        ans = max(ans, val[0..M].sum);
    }

    void dfs (int level) {
        if (level == 3) {
            /* 処理 */
            calc();
            return;
        }

        foreach (i; 0..2) {
            sign[level] = i;
            dfs(level+1);
        }
    }

    dfs(0);
    writeln(ans);
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

## 解法2
[はまやんさんの解説](https://blog.hamayanhamayan.com/entry/2018/06/17/113721)で紹介されているdpをすることもできる。
結論から言うと、最初検討した部分和問題ではなく
<div style="overflow: auto">
$$
\begin{equation*}
dp[i][j] = (i項目までのうちj項をとったとき、あり得る最大値)
\end{equation*}
$$
</div>
を考える。
このdpを考えるに至る考察は大体次のような感じになる。

1. $x_i, y_i, z_i$別々だとだるいので、まず$x_i$についてだけ考える。
2. 絶対値をとるので、最適解は$\sum x_i$が最大または最小になるときだと分かる。
&rarr;最大の値が採用されるときは普通にdpで解ける。
3. 最小になるときが最適解になるときは総和が負になるはずなので、符号を反転させた状態でのdpも考える。
4. 3軸に戻す。3軸すべてが最大をとるタイミングを採用できるように、8通りの符号でdpする。

詳しいアルゴリズムは実装例を参考にしてください。

```D
import std;

struct trio
{
    long x, y, z;
}

void main ()
{
    int N, M; readln.read(N, M);
    trio[] cake = new trio[](N);
    foreach (i; 0..N)
    {
        with (cake[i]) readln.read(x, y, z);
    }

    solve(N, M, cake);
}

void solve (int N, int M, trio[] cake)
{
    long[][] dp = new long[][](N+1, M+1);
    // dp[i][j] := (i項目までからj項選んだ時の最大値)
    long ans = 0;

    /* 符号8通りでdp */
    for (int a = -1; a <= 1; a++) for (int b = -1; b <= 1; b++) for (int c = -1; c <= 1; c++) if (a*b*c != 0)
    {
        foreach (d; dp) d[] = -long.max;
        dp[0][0] = 0;

        foreach (i; 0..N) foreach (j; 0..M+1)
        {
            if (dp[i][j] == -long.max) continue;
            long diff = a*cake[i].x + b*cake[i].y + c*cake[i].z;
            // 採用
            if (j+1 <= M) dp[i+1][j+1] = max(dp[i+1][j+1], dp[i][j] + diff);

            // 採用しない
            dp[i+1][j] = max(dp[i+1][j], dp[i][j]);
        }
        ans = max(ans, dp[N][M]);
    }

    writeln(ans);
}

void read(T...)(string S, ref T args)
{
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

## 発展
解法1は45度回転と呼ばれるテクニックとも関連がある。
45度回転とは2次元座標平面上においてマンハッタン距離を考えるときに有用になるテクニックである。
1問紹介しておこう。

[ABC178E - Dist Max](https://atcoder.jp/contests/abc178/tasks/abc178_e)

問題文

2点$(a, b), ~ (c, d)$に対して2点間のマンハッタン距離を$|a - c|+|b - d|$と定める。
$N$点$(x_i, y_i)$が与えられる。2点間のマンハッタン距離としてあり得る最大の値を求めよ。

制約

- $2 \leq N \leq 2\times 10^5$
- $1 \leq x_i, y_i \leq 10^9$

これを同様に処理してみる。
適当な二点についてマンハッタン距離を考えると、次のようになる。
<div style="overflow: auto">
$$
\begin{equation*}
\begin{split}
|x_i - x_j| + |y_i - y_j| &= \max (x_i - x_j, ~ x_j - x_i) + \max (y_i - y_j, ~ y_j - y_i) \\\\
&= \max ((x_i - x_j)+(y_i - y_j), ~ (x_i - x_j)+(y_j - y_i), ~ (x_j - x_i)+(y_i - y_j), ~ (x_j - x_i)+(y_j - y_i)) \\\\
&= \max ((x_i + y_i)-(x_j + y_j), ~ (x_i - y_i)-(x_j - y_j), ~ -(x_i - y_i)+(x_j - y_j), ~ -(x_i + y_i)+(x_j + y_j)) \\\\
&= \max (|(x_i + y_i) - (x_j + y_j)|, ~ |(x_i - y_i) - (x_j - y_j)|)
\end{split}
\end{equation*}
$$
</div>
を得る。
最後の式から、すべての点に対して$x_i + y_i$と$x_i - y_i$を計算して、
それぞれの差分の絶対値の最大値を見つければよい。
これは単にそれぞれの最大値と最小値を与える点を見つければよいため、全体$O(N)$で処理できる。

以上より、マンハッタン距離を代表とする絶対値記号は、max関数を用いて外すとうまく計算できる場合がある。

筆者は解法を理解していないが、[yukicoder No.2520 L1 Explosion](https://yukicoder.me/problems/no/2520)も45度回転を用いるらしい。
この問題は今後の課題としたい。

## 終わりに
いつか取り上げたいと思っていたトピックに触れることができてよかった。
ただし、現状私はこの変換がなぜうまくいくのかという数学的背景を知らないため、
さらに勉強ないし応用の余地があると思う。
が、疲れたのでこのあたりにしておく。
