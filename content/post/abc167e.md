---
title: ABC167E - Colorful Blocks
# description: 

date: 2024-01-03
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
archives:
  - 2024
  - 2024-01
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要

[問題へのリンク](https://atcoder.jp/contests/abc167/tasks/abc167_e)

$N$個の横一列に並んだブロック列に色を塗る。
色は整数で表され、$1$から$M$までの$M$種類ある。
必ずしもすべての色を使う必要はない。
隣り合うブロックが同じ色である箇所が$K$以下の色の塗り方の総数を$998244353$で割ったあまりを求めよ。

制約

- $1 \leq N, M \leq 2 \times 10^5$
- $0 \leq K \leq N-1$

## 考察

dp解を考えてみよう。
<div style="overflow: scroll;">
$dp[i][j] = (iブロック目まで塗って、隣り合うブロックが同じ色である場所がj個であるような塗り方の総数)$
</div>
とすれば、初期値

- $dp[1][0] = M$

更新

- $dp[i+1][j] = (M-1) * dp[i][j]$
- $dp[i+1][j+1] = dp[i][j]$

とすることで、$O(NK)$で解くことができる。

```d
import std;

void main () {
    int N, M, K; readln.read(N, M, K);
    solve(N, M, K);
}

void solve (int N, int M, int K) {
    const long MOD = 998244353;
    long[][] dp = new long[][](N+1, K+1);
    foreach (d; dp) d[] = 0;

    dp[1][0] = M;

    foreach (i; 1..N) {
        for (int j = 0; j <= K; j++) {
            dp[i+1][j] += (M-1) * dp[i][j] % MOD;
            dp[i+1][j] %= MOD;

            if (j < K) {
                dp[i+1][j+1] += dp[i][j];
                dp[i+1][j+1] %= MOD;
            }
        }
    }

    long ans = 0;
    foreach (d; dp[N]) {
        ans += d;
        ans %= MOD;
    }

    writeln(ans);
}

void read (T...) (string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

しかし、これでは間に合わない。
どうにか他の方法を考えよう。

こういうときは、他にうまいdpがあることは(この難易度帯では)少なく、
うまく数学で解くことが多い。

まず、隣り合う数を固定して(以下、$x$で考える)考える。
前から順番に色を塗っていくと考えると、$i$番目のブロックを塗る時、

1. $i-1$番目のブロックと色が同じ時、隣り合う同じ色の場所の数は増える。(場合の数は$1$倍)
2. $i-1$番目のブロックと色が違う時、隣り合う同じ色の場所の数は変わらない。(場合の数は$M-1$倍)

が$2$以上の$i$に対して**常に成立**することがわかる。
すなわち、最後まで塗った結果隣り合う色が同じ場所が$x$となるような塗り方は、
パターン1を$x$回、パターン2を$N-1-x$回経たようなものに限定されることになる。
また、$i=1$のときは何色で塗っても「一つ前」がいないので変わらなく、$M$通りになる。

**どこで**パターン2を引くかの自由度を考えると、これは$\binom{N-1}{N-1-x}$通りであるから、最終的に場合の数は
上で議論したものにこれをかけた値、つまり

$$
M \times 1^{x} \times (M-1)^{N-1-x} \times \binom{N-1}{N-1-x} = M \times (M-1)^{N-1-x} \times \binom{N-1}{N-1-x}
$$

通りであり、解はこれを$0 \leq x \leq K$の範囲で合計したものになる。
適切な前計算の元、一つ固定した$x$に対して$O(\log N)$で求められるため、問題を$O(N \log N)$で解くことが出来た。

## 実装例
```d
import std;

void main () {
    int N, M, K; readln.read(N, M, K);
    solve(N, M, K);
}

void solve (int N, int M, int K) {
    /*
       前から順番に色を塗っていくことを考える。
       1通りの現状維持(同じ色+1) or M-1通りの色変え(同じ色維持)
       をN-1回迫られるという考え方で行く。
     */

    const long MOD = 998244353;

    long[] fact = new long[](N+1);
    long[] factInv = new long[](N+1);
    fact[0] = factInv[0] = 1;
    foreach (i; 1..N+1) {
        fact[i] = i*fact[i-1] % MOD;
        factInv[i] = modInv(fact[i], MOD);
    }

    long comb (int n, int k) {
        if (n < k) return 0;
        long res = fact[n] * factInv[k] % MOD;
        res *= factInv[n-k];
        return res % MOD;
    }

    long ans = 0;

    for (int i = 0; i <= K; i++) {
        /* i組の隣が同じ色のペアが存在する */
        long add = M*comb(N-1, N-1-i) % MOD;
        add *= modPow(M-1, N-1-i, MOD);
        add %= MOD;
        ans += add;
        ans %= MOD;
    }

    writeln(ans);
}
```

長いので、`ModPow`や`ModInv`など一部関数は省略している。

## 感想
久しぶりに問題を見返したら全く解けなくて驚愕した。
折角なので復習の意味も込めて解法を理解し直してみた。

この手の問題ではやはり

- 変数をできるだけ固定して考えてみる
- 単純化したバージョンの問題を考えてみる(2Dから1Dに落としてみるなど)

などの基本テクニックを忘れないことももちろん、

- 前から決めていくことにして考える(うまく行けば、今回のdp解のように部分問題の構造が見つかることも)
- 問題の操作を俯瞰的に見る
- 途中の「状態」を持たなくて良い方法を考える

など色々あると思う。
今回の解法はどこで一つ前と違う色を入れても変わらず場合の数が$M-1$倍になることが重要なポイントであった。

いや、やっぱりこんなの誰が解けるんだ？でも1ヶ月前の自分は解けてるんだよな。。。

結局思考を再現できそうにない気がする。助けてくれ。
