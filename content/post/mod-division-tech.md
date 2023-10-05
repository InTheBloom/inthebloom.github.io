---
title: 割れるし割りたいのに割れない数を割る方法
# description: 

date: 2023-10-05
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
  - 数学
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

## 状況設定
- $x, ~ y, ~ z \in \mathbb N$
- $x\\%y = 0$
- $1 < \mathrm{gcd}(y, z)$
- $x$は陽に求められないほど大きく、$y$、$z$は常識的な大きさ

### 問題
$xy^{-1}$を$z$で割った非負最小剰余を求めよ。

## 何が厳しいのか
$\mathrm{gcd}(y, z) = 1$が満たされていれば話は終了です。
なぜなら、このような$y$は$\mathrm{mod} ~ z$上で逆元を持つからです。
普通に拡張ユークリッドの互除法などを用いれば答えられます。

問題はそうでない時です。
この時、$y$は逆元を持ちませんから、先に$\dfrac{x}{y}$を計算したくなります。
しかし、$x$はデカいので、陽に求めるのは無理です。
さてどうしましょう？

## 解答
結論から言います。$\mathrm{mod} ~ yz$上で考えるとうまくいきます。

もう少し具体的には、次の手順を踏むことで答えることができます。
1. $x ~ \mathrm{mod} ~ yz$を求める。
2. それを$y$で割る。

正当性を追っていきます。

除法定理より、次を満たす整数$q, ~ r$の組がただ一つ存在します。
- $x = q(yz) + r$
- $0 \leq r < yz$

ちなみに$r = x ~ \mathrm{mod} ~ yz$です。

ここで、$x\\%y = 0$を仮定しているので、必ず$r\\%y = 0$となっています。

両辺$y$で割ります。
$$
\begin{equation}
\frac{x}{y} = qz + \frac{r}{y}
\end{equation}
$$
です。

ここから少し定義に戻って確認します。
$\dfrac{x}{y} ~ \mathrm{mod} ~ z$を求めるとは
$$
\begin{equation}
\dfrac{x}{y} = q'z + r' ~ \left(  0 \leq r' < z  \right)
\end{equation}
$$
なる$r'$を求めることです。
ここで、除法定理よりこのような整数の組$(q', r')$はただ一つに定まります。
さて、式(1)を見てみましょう。
$0 \leq r < yz$でありますから、$0 \leq \dfrac{r}{y} < z$であることが分かります。

式(2)と見比べてみましょう。$r' = \dfrac{r}{y}$となっていることが確認できます。

なんということでしょう。求めることができてしまいました。除法定理が強力すぎますね。

## 応用例
実際にこのテクニックを使える問題を2問紹介します。

1. [ARC111A - Simple Math 2](https://atcoder.jp/contests/arc111/tasks/arc111_a)

<details>
<summary>解法</summary>
$10^N = qM + r ~ (0 \leq r < M)$と表すと、
$\left\lfloor \dfrac{10^N}{M} \right\rfloor = \left\lfloor \dfrac{qM + r}{M} \right\rfloor = q$
であるから、解は$q\%M$です。
これをもとに変形していきます。

$$
qM = 10^N - r
$$
$$
q = \frac{10^N-r}{M}
$$

ここまで変形すると今回のテクニックに帰着します。
求めたいのは$q ~ \mathrm{mod} ~ M$ですが、$M$は$\mathrm{mod} ~ M$上で逆元を持ちません。
また、$10^N-r$も大きすぎて陽に求めるのは無理です。
そこで、$(10^N - r) ~ \mathrm{mod} ~ M^2$を計算してから最後に$M$で割ってやるとうまくいきます。

実装例(一部抜粋)
```d
void solve (long N, int M) {
    // 10^N = qM + r (0<=r<M) を得たとき、解はq%M
    // 両辺Mで剰余をとってみると、 (10^N)%M = r%M
    // 条件より、(10^N)%M = r

    // 典型テク: mod MK (Mは最後に求めたい剰余、Kは割りたいけど法と互いに素でない数) で考える。
    long ans = modPow(10, N, M^^2);
    ans -= modPow(10, N, M);
    if (ans < 0) {
        ans += M^^2;
    }

    ans /= M;
    writeln(ans);
}
```
</details>

2. [ABC293E - Geometric Progression](https://atcoder.jp/contests/abc293/tasks/abc293_e)

<details>
<summary>解法</summary>
解法がたくさんありますが、<a href="https://atcoder.jp/contests/abc293/editorial/5966">kyopro_friendsさんのユーザー解説</a>と同じ方法です。

丁寧に式変形を追っていきます。

$S(x) \coloneqq \displaystyle\sum_{i=0}^{x}A^i$と定めます。

$0 \leq N$を用いて、

$$
\begin{alignat\*}{3}
A \times S(N) &= &&A^1 + A^2 + \cdots + A^N-1 + A^N + A^{N+1} \\\\
S(N) &= A^0 + &&A^1 + A^2 + \cdots + A^N-1 + A^N \\\\
\end{alignat\*}
$$

が成立します。そこで、

$$
A \times S(N) - S(N) = A^{N+1} - A^0
$$
となります。$S(N)$でくくると、
$$
(A-1) \times S(N) = A^{N+1} - 1
$$
です。$A-1 \neq 0$ならば、両辺を割れて、
$$
S(N) = \frac{A^{N+1}-1}{A-1}
$$
を得ます。

さて、今回求める値は$S(X-1) ~ \mathrm{mod} ~ M$にほかなりません。$A-1 \neq 0$のとき、$0 \leq X-1$なので、上式を適用できます。
$$
S(X-1) = \frac{A^X-1}{A-1}
$$
ここで、$A-1$は$\mathrm{mod} ~ M$上で逆元を持つとは限りません。今回のテクを使いましょう。
つまり、$\mathrm{mod} ~ M(A-1)$で考えるとうまくいきます。

注意点として、この値は法としてはかなり大きくなる(それでも十分常識の範囲ですが)ので、
計算途中で64bit整数型を超える可能性が高いです。128bit整数や、多倍長整数を使いましょう。
多倍長整数とはいえ、そこまで桁数は大きくならないので十分高速です。
よくわからない人はpythonを使うとよいです。

また、$A-1 = 0$の時はすべての項が1になるため、簡単に計算できます。

実装例(一部抜粋)
```d
void solve (int A, long X, int M) {
    // 解は (A^x - 1) / (A - 1)

    // 場合分けが必要なケース
    if (A == 1) {
        writeln(X%M);
        return;
    }

    BigInt a = A, x = X, m = M;
    BigInt ans = std.bigint.powmod(a, x, m*(a-1)) - 1;
    if (ans < 0) ans += m*(a-1);
    ans /= A-1;
    writeln(ans);
}
```
</details>

### 補足
問題2の解法説明で、
「逆元を持つとは限りません」と書きましたが、逆元を持っていてもよいことに注意してください。
正当性の証明のパートを見ればわかるように、法と除数の関係性は正当性を示すのに用いていないためです。

もちろん$\mathrm{gcd}(M, A-1)$を計算して、逆元を持つ場合はそちらを経由するという方法でも解けます。

また、問題2に関しては、行列累乗による$O(\log(X))$解法や、平方分割による解法など勉強になる解法がたくさん紹介されています。
余裕のある人はぜひ学んでみてください。(ちなみに私は学べてないです。コーナーで差をつけろ！)

## 終わりに
いつかまとめようと思っていたネタです。
ほんの思い付きで書き始めたつもりが約2時間たっていて現在深夜1時です。
助けてくれ。

このアイディア自体はまさに上で紹介したABC293Eのユーザー解説から得たものです。
かなり行間が広いと感じたので、そこを埋める目的で作りました。
なので、この主張がどこまで一般化できるのかなどは私はわかっていません。

誤りがありましたら指摘していただければありがたいです。
