---
title: No.2616 中央番目の中央値
# description: 

date: 2024-01-27
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 典型テク
  - 二項係数
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

[問題へのリンク](https://yukicoder.me/problems/no/2616)

長さ$N$の順列$P = (P\_1, \cdots , P\_N)$が与えられる。$P$の部分列$p$であって、以下の条件をすべて満たすものの総数を$998244353$で割ったあまりを求めよ。

- 長さが奇数
- $p$の中央値が、$p$のちょうど中央に位置する

制約

- $1 \leq N \leq 3 \times 10^5$
- $(P\_1, \cdots , P\_N)$は$(1, 2, \cdots , N)$を並べ替えた順列

## 考察
まず中央値としてどこをとるかを固定して問題を考察する。
中央値として$P\_i$をとるとしたとき、

- 自分より左と自分より右から同量の項を採用する。
- 採用した項は半分が自分未満で、半分が自分超過である。

ということが題意を満たす$p$の必要条件十分になる。
例えば、自分の左右から自分超過と自分未満の項を$\mathrm{more}\_{左}, \mathrm{less}\_{左}, \mathrm{more}\_{右}, \mathrm{less}\_{右}$
個とったとすると、前述の条件から次の連立方程式が立つ。

$$
\begin{equation}
\left \\{
\begin{split}
\mathrm{less}\_{左} + \mathrm{more}\_{左} &= \mathrm{less}\_{右} + \mathrm{more}\_{右} \\\\
\mathrm{less}\_{左} + \mathrm{less}\_{右} &= \mathrm{more}\_{左} + \mathrm{more}\_{右} \\\\
\end{split}
\right .
\end{equation}
$$

これを解くと、$\mathrm{more}\_{左} = \mathrm{less}\_{右}, \mathrm{less}\_{左} = \mathrm{more}\_{右}$を得る。
結果としては当たり前のことを言っていて、「左側から大きい項をとってきたなら、右側で小さい項をとってきて帳尻を合わせなさいよ」ということである。

さて、よく見ると$\mathrm{less}\_{左}$と$\mathrm{more}\_{左}$は反対側で取る項により帳尻を合わせている。
すなわち、$\mathrm{less}\_{左}$と$\mathrm{more}\_{左}$自体は関係性がないため、独立に考えてよいことがわかる。
まず$\mathrm{less}\_{左}, \mathrm{more}\_{右}$の取り方によってできる部分列について考えよう。

まず、
<div style="overflow: scroll;">
$$
0 \leq \mathrm{less}_{左}, \mathrm{more}_{右} \leq \min((自分より左にあるP_i未満の数の数), (自分より右にあるP_i超過の数の数))
$$
</div>
であることがわかる。そうでないなら、帳尻を合わせられないからだ。

$\mathrm{less}\_{左} = \mathrm{more}\_{右} = i$であるとき、
どこから取るかの自由度があるため、作れる部分列の個数は$X = (自分より左にあるP\_i未満の数の数)$、$Y = (自分より右にあるP\_i超過の数の数)$と定めると、
$\binom{X}{i} \binom{Y}{i}$通りになる。この総和を考えればよいため、
$$
\sum\_{i=0}^{\min(X, Y)} \binom{X}{i} \binom{Y}{i}
$$
通りになる。
二項係数の性質$\binom{N}{K} = \binom{N}{N-K}$を用いると、
$$
\sum\_{i=0}^{\min(X, Y)} \binom{X}{X-i} \binom{Y}{i}
$$
$\min(X, Y) = X$であるとき、[ヴァンデルモンドの畳み込み](https://manabitimes.jp/math/622)という恒等式が成立し、
$$
\sum\_{i=0}^{X} \binom{X}{X-i} \binom{Y}{i} = \binom{X+Y}{X}
$$
となる。$\min(X, Y) = Y$であるときも全く同様にして
$$
\sum\_{i=0}^{Y} \binom{X}{i} \binom{Y}{Y-i} = \binom{X+Y}{Y}
$$
が成立する。ただし、$\binom{X+Y}{X} = \binom{X+Y}{Y}$に注意せよ。

$\mathrm{more}\_{左}, \mathrm{less}\_{右}$にも全く同様の議論ができる。
これらの議論がそれぞれ独立であることを考えると、中央値$P\_i$であるときのあり得る部分列の個数はこれらの積になる。

これらの二項係数は適切に前計算することでクエリ$O(1)$となり、$(自分より左にあるP\_i未満の数の数)$といった数はSegmentTreeなどのデータ構造によりクエリ$O(\log N)$で求まる。

具体的には、要素数$N$の一点更新/区間和取得のセグメントツリーを2本持っておいて、セグメントツリーの最下段の配列と$P$の各項を対応付けて管理する。
すなわち、「区間$[0, x)$に入っている$P\_i$は1、そうでないなら0」という情報と、「区間$[x+1, N)$に入っている$P\_i$は1、そうでないなら0」という情報を持っておいて、それぞれ適切に
`prod(0, P[i])`や`prod(P[i]+1, N)`というクエリを飛ばすことで達成できる。

以上より、$O(N \log N)$で解が求まる。

## 実装例
ICPCもあるので、練習にc++を使ってみた。
コンパイルが通るように全部貼り付けたが、`solve`関数の中だけ見ればよい。
```c++
#include <iostream>
#include <atcoder/segtree>
#include <vector>
#include <cassert>

using namespace std;
using namespace atcoder;
using ll = long long;

ll ModPow (ll a, ll x, const ll MOD) {
    assert(0 <= x);
    assert(1 <= MOD);

    a %= MOD;
    if (a < 0) a += MOD;

    ll res = 1;
    while (x != 0) {
        if (0 < (x & 1)) {
            res *= a;
            res %= MOD;
        }
        a *= a;
        a %= MOD;
        x >>= 1;
    }

    return res % MOD;
}

ll ModInv (ll x, const ll MOD) {
    assert(1 <= x);
    assert(2 <= MOD);
    return ModPow(x, MOD-2, MOD);
}

int ope (int a, int b) { return a + b; }
int e () { return 0; }

void solve (int N, vector<int> &P) {
    // ある要素を中央値に採用すると考える。
    // 「前から見て(長さ-1)/2個からなる部分列でmaxがそれ未満」と「後ろから見て(長さ-1)/2個からなる部分列でminがそれ超過」の場合の数がわかればよい？
    // -> 明らかにΘ(N^2)以上が見込まれるのでダメ

    // 右側から超過をk個、未満をl個とったと考える。この時、左側からとるべきものも確定して、未満をk個、超過をl個とる必要がある。
    // 左側でとった超過/未満は右側でつじつまを合わせるため、独立に考えてよい。
    // 例えば左側未満は[0, min((左側未満), (右側超過))]個自由にとれる。->どこからとるかはnCkになり、これの積を足していけばいい
    // wolfram alpha先生にbinomial(N, i) * binomial(M, i)の和[0, N]を投げたら(M+N)!/(N!M!)って言われた
    // セグ木かなんかでこれを持っておけばよくないか？

    const ll MOD = 998244353;

    vector<ll> fact(2*N+1), factinv(2*N+1);
    fact[0] = 1;
    for (int i = 1; i <= 2*N; i++) fact[i] = i*fact[i-1] % MOD;
    factinv[2*N] = ModInv(fact[2*N], MOD);
    for (int i = 2*N-1; 0 <= i; i--) factinv[i] = (i+1) * factinv[i+1] % MOD;

    segtree<int, ope, e> L(N), R(N);
    for (int i = 0; i < N; i++) R.set(i, 1);

    ll ans = 0;
    for (int i = 0; i < N; i++) {
        // 計算
        int Llarge = L.prod(P[i]+1, N);
        int Lless = L.prod(0, P[i]);
        int Rlarge = R.prod(P[i]+1, N);
        int Rless = R.prod(0, P[i]);

        ll add = fact[Llarge + Rless] * factinv[Llarge] % MOD;
        add *= factinv[Rless];
        add %= MOD;

        add *= fact[Rlarge + Lless];
        add %= MOD;
        add *= factinv[Rlarge];
        add %= MOD;
        add *= factinv[Lless];
        add %= MOD;

        ans += add;
        ans %= MOD;

        // 更新
        L.set(P[i], 1);
        R.set(P[i], 0);
    }

    cout << ans << "\n";
}

int main () {
    int N; cin >> N;
    vector<int> P(N);
    for (int i = 0; i < N; i++) {
        cin >> P[i];
        P[i]--; // 0-indexed
    }

    solve(N, P);
}
```

## 感想
久しぶりにyukicoderで難しめの問題が解けた気がする。
本番はwolfram alphaに投げたら式変形してくれたが、本稿を書くにあたって二項係数が入った恒等式の証明が全然わからなくて苦労した。
ヴァンデルモンドの畳み込み恒等式は競技プログラミングにおいて様々な応用がありそうな気がするが、筆者のレベルだとあまり見たことがない。

不明点があれば[公式解説](https://yukicoder.me/problems/no/2616/editorial)が詳しい。
