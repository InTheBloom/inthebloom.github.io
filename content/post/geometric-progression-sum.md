---
title: 等比数列の和を計算する2つの対数時間アルゴリズム
# description: 

date: 2024-02-15
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 数学
  - アルゴリズム
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

## 概要
隣り合う2つの項の比が一定である数列を、**等比数列**という。
より厳密には、初項$a$、公比$r$によって定まる次の数列のことを指す。

- $a\_1 = a$
- $a\_i = ra\_{i-1} ~ (2 \leq i)$

本稿では、等比数列の最初の$n$項の和$S\_n = a + ar + ar^2 + \dots ar^{n-1}$を任意の法$M$で割った非負最小剰余を$O(\log n)$時間で求めるアルゴリズムを紹介する。

以下のアルゴリズムでは、$a, r$を64bit整数型で、$M$を32bit整数型で表現できる事を仮定する。
この仮定を満たさない入力値に対して、計算量が悪化する可能性がある。

また、文章中において「$S\_n$」と「$S\_n$を$M$で割った非負最小剰余」を区別せず記述する場所がある。

## アルゴリズム1(閉じた式による表示)
有名なテクニックを用いて、$S\_n$を閉じた式で表す。
$S\_n$と$r S\_n$の差を考えると、

$$
\begin{equation}
\begin{aligned}
rS\_n        &=&     &ar + ar^2 + \dots + ar^{n-1} + ar^n \\\\
S\_n         &=& a + &ar + ar^2 + \dots + ar^{n-1} \\\\
\end{aligned}
\end{equation}
$$
であるから、$S\_n (r-1) = a(r^n - 1)$が成立する。
1. $r \neq 1$

    両辺を$r-1$で割ることができて、
    $$
    \begin{equation}
    S\_n = \frac{a(r^n - 1)}{r-1}
    \end{equation}
    $$
    が成立する。法を$M$としたとき、$\gcd(M, r-1) = 1$であれば法$M$における$r-1$の逆元が存在し、
    $S\_n = a(r^n - 1) (r-1)^{-1}$となる。

    $\gcd(M, r-1) \neq 1$であるときも[このエントリ](https://inthebloom.github.io/post/mod-division-tech/)で触れた通り、
    法$M(r-1)$において$r^n - 1$計算し、それを$r-1$で割ることで法$M$における$\frac{r^n-1}{r-1}$の値を得ることができる。
    最後に$a$を乗算することで$S\_n$が求まる。

    以上より、$S\_n$を$O(\log n)$時間で計算可能である。

2. $r = 1$

    $\forall i \in \mathbb{N}$に対して、$a\_i = a\_1$が成立する。
    したがって、$S\_n = na\_1$であり、これは$O(1)$で計算可能である。

上記の方法により、$S\_n$を$O(\log n)$で計算することができる。。

## アルゴリズム2(繰り返し2倍法)
「繰り返し2倍法」という名前は[ここ](https://atcoder.jp/contests/abc293/editorial/5966?lang=ja)で言及されているものであり、一般的でない可能性に留意してほしい。

[このエントリ](https://inthebloom.github.io/post/modpow/)で触れたように、任意の自然数$n$は$\\{0, 1\\}$のみからなる数列($c$と書くことにする)による表示を一意に持つ。
つまり、次が成立するような数列$c$が存在して、かつそれは一意である。
$$
\begin{equation}
n = \sum_{i=0} 2^i c\_i
\end{equation}
$$
これは2進数そのものである。例えば、$1$は$(1, 0, 0, \dots)$で表現され、$2$は$(0, 1, 0, \dots)$、$10$は$(0, 1, 0, 1, 0, \dots)$である。
平素な言葉で言い換えるなら、「任意の自然数は$2$の冪の和によって一意に表すことができる。」となる。これを利用する。

$n$を2進表示した列$c$を用いて、$S\_n$を次のように表すことができる。

<div style="font-size : 1.5em;">
$$
\begin{equation}
S_n = \sum_{i=0} c_i r^{\sum\limits_{j=0}^{i-1} c_j 2^j} S_{2^i}
\end{equation}
$$
</div>

(式が非常に複雑なので、フォントサイズを1.5倍にしている。)
式4は一見複雑に見えるが、$S\_{2^i}$のいくつかの和によって長さの帳尻を合わせ、かつ適切な位置まで$r^{\sum_{j=0}^{i-1} c\_j 2^j}$を乗算することでずらしていると考えれば理解しやすいかもしれない。
例えば、$n = 10$において次のようになる。

$$
\begin{equation}
\begin{split}
S\_{10} &= r^{0 \times 2^0} S\_{2^1} + r^{0 \times 2^0 + 1 \times 2^1 + 0 \times 2^2} S\_{2^3} \\\\
        &= r^0 S\_2 + r^2 S\_8 \\\\
        &= (a + ar) + r^2 (a + ar + ar^2 + \dots + ar^7) \\\\
        &= a + ar + ar^2 + ar^3 + \dots + ar^9
\end{split}
\end{equation}
$$

さて、$S\_{2x} = S\_x + r^x S\_x$と$r^{2x} = r^x  r^x$が成立することを利用すると、
$(r^1, S\_1), (r^2, S\_2), (r^4, S\_4), \dots , (r^{2^x}, S\_{2^x})$
を時間$O(x)$、空間$O(1)$で順番に列挙することができる。

式4の計算には$(r^{2^{\lfloor \log n \rfloor}}, S\_{2^{\lfloor \log n \rfloor}})$まで分かれば十分であるため、$S\_n$を$O(\log n)$時間で計算可能である。

## 実装
D言語による実装を以下に示す。
なお、$a$と$r$を最初に正規化しているが、これは次の理由により正しい値を返す。

正規化後の値を$a^\prime$と$r^\prime$とするとき、
「初項$a$、公比$r$の等比数列の先頭$n$項の和を$M$で割った非負最小剰余」と「初項$a^\prime$、公比$r^\prime$の等比数列の先頭$n$項の和を$M$で割った非負最小剰余」が一致する。

ナイーブな実装とのランダムテストを含めた完全なソースは[gist](https://gist.github.com/InTheBloom/e6e838c01d001076065e6853bf36568f)を参照せよ。

### アルゴリズム1
```D
long geometric_progression_sum_algorithm1  (long a, long r, long n, const long MOD)
in {
    assert(0 <= n);
    assert(1 <= MOD);
}
do {
    import std.BigInt;
    // 正規化
    a %= MOD;
    r %= MOD;
    if (a < 0) a += MOD;
    if (r < 0) r += MOD;

    // 場合分け
    if (r == 1) return a * (n % MOD) % MOD;

    // 計算
    const BigInt M = BigInt(r-1) * BigInt(MOD);
    const BigInt N = BigInt(n);
    const BigInt R = BigInt(r);

    BigInt S = powmod(R, N, M) - 1;
    if (S < 0) S += M;
    S /= r-1;

    S *= a;
    return S % MOD;
}
```

### アルゴリズム2
```D
long geometric_progression_sum_algorithm2  (long a, long r, long n, const long MOD)
in {
    assert(0 <= n);
    assert(1 <= MOD && MOD <= int.max);
}
do {
    // 正規化
    a %= MOD;
    r %= MOD;
    if (a < 0) a += MOD;
    if (r < 0) r += MOD;

    // 計算
    long S = a;
    long R = r;
    long R_prod = 1;
    long res = 0;

    foreach (i; 0..64) {
        if (n < (1L<<i)) break;
        if ( 0 < (n & (1L<<i)) ) {
            res += R_prod * S % MOD;
            res %= MOD;

            R_prod *= R;
            R_prod %= MOD;
        }

        S += R * S % MOD;
        S %= MOD;
        R *= R;
        R %= MOD;
    }

    return res;
}
```

## 終わりに
等差数列の和が非常に簡単な形で表されるのに対して、等比数列の和は工夫が必要なのが面白いと思った。
具体的に値を求めようとしたとき、閉じた式による計算が必ずしも最速ではないということが非自明に感じる。

また、実装していて、割ったあまりを人力で管理するのはなかなか厳しいものがあると感じた。
今まで必要性を感じていなかったが、`ModPow`構造体を用意するモチベーションになった気がする。
