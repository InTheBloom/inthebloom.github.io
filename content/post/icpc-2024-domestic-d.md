---
title: ICPC模擬国内予選D 過去問の共有
# description: 

date: 2024-10-29
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
archives:
  - 2024
  - 2024-10
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題へのリンク](https://icpc2024.jag-icpc.org/icpcdomestic/contest/all_ja.html)

### 問題文
JAG大学ICPC学科には$N$人の学生が在籍しており、それぞれの学生には$1$から$N$までの番号がついている。また、学生の交友関係が$M$個存在する。$i$番目の交友関係は、学生$a _ i$と$b _ i$が友達であり、互いに連絡できることを表す。

学科の期末試験では、$N$教科の試験が行われる予定である。はじめ、学生$i$は教科$i$の過去問を持っている。
あなたは学生$1$である。友達同士で過去問を共有することを繰り返したとき、あなたが過去問の情報を何教科得られるかが気になった。そこで、友達同士で行われる過去問の共有が$K$回行われたときの期待値を調べることにした。

次のイベントが順に$K$回独立に発生することを考える。

> $M$個の交友関係のうち一つがランダムに選ばれ、その学生二人が連絡を取りあう。このとき、それぞれが持つ過去問情報をすべて共有しあう。
> 言い換えると、片方が持つ過去問の教科の集合を$X$、もう片方を$Y$とすると、そのイベントの後、持っている過去問の教科の集合は双方とも$X \cup Y$になる。

$K$回のイベントの終了後、学生$1$であるあなたが持っている過去問の教科数の期待値を$\mod 998244353$で求めよ。

なお、この問題において、求める期待値は必ず有理数になることが証明できる。また、この問題の制約のもとでは、その値を既約分数$P/Q$で表したとき、$Q \neq 0 \pmod {998244353}$となることも証明できる。よって、$R \times Q \equiv P \pmod {998244353}, \quad 0 \leq R < 998244353$を満たす整数$R$が一意に定まる。この$R$が、期待値$\mod 998244353$である。ここで、$998244353 = 223 \times 7 \times 17 + 1$は素数である。

### 制約
- $2 \leq N \leq 10$
- $1 \leq M \leq \frac{N(N - 1)}{2}$
- $1 \leq K \leq 50$

## 解法
全てのイベント列をシミュレーションすることが出来れば、期待値を直接求めることが出来る。
しかし、全てのイベント列は$M ^ K$回個あるため、現実的でない。

そこで、次の動的計画法を検討する。
$\mathrm{dp}\lbrack i \rbrack \lbrack S _ 1 \rbrack \lbrack S _ 2 \rbrack \lbrack \dots \rbrack \lbrack S _ N \rbrack = (\text{先頭$i$個のイベントが終わった時点で、学生$j$の持っている過去問の集合が$S _ j$である場合の数})$
状態数は$K 2 ^ {N ^ 2}$で、依然として現実的でない。
また、次のイベントが発生したとき各学生の持っている教科を求めるためには、現時点で持っている教科を知る必要があるため、これ以上状態を削減する事すら難しい。

期待値を考える時の典型的な手法として、確率変数の分離を行ない、期待値の線形性を利用するというものがある。今回はこの方針がうまくいく。

確率変数を考えるので、必要な情報を考えよう。今回の問題では、
標本空間はイベントを$K$個並べた列、つまり$\Omega = \lbrace (e _ 1, e _ 2, \dots, e _ K) \mid e _ i \in \lbrack 1, M \rbrack \rbrace$、確率関数$P$は、任意の根源事象$\omega \in \Omega$に対して、$P(\lbrace \omega \rbrace) = \frac{1}{\lvert \Omega \rvert}$となる。

今考えている確率変数を$X$とする。
この$X$は$K$回のイベントの列から、「最終的に学生$1$が持つ過去問の教科数」への写像である。

各教科に着目して確率変数を分離してみよう。確率変数$X _ i$を「最終的に学生$1$が過去問$i$を持っていれば$1$、そうでなければ$0$」となる写像であるとする。
この時、任意の$\omega \in \Omega$に対して、$X(\omega) = \sum _ {i = 1} ^ N X _ i(\omega)$が成立する。
ここで、期待値の線形性を適用すると、$E\lbrack X \rbrack = \sum _ {i = 1} ^ N E\lbrack X _ i \rbrack$が成立する。
よって、各$i$に対して$E\lbrack X _ i \rbrack$を求められれば良いことがわかった。

$E\lbrack X _ i \rbrack$について検討しよう。
定義より、$E\lbrack X _ i \rbrack = \sum _ {\omega \in \Omega} P(\lbrace \omega \rbrace) X _ i(\omega)$である。
イベントを独立に選択するという仮定から、任意の$\omega \in \Omega$に対して$P(\lbrace \omega \rbrace) = \frac{1}{\lvert \Omega \rvert}$である。
つまりこれを外に出すことが出来て、$E\lbrack X _ i \rbrack = \frac{1}{\lvert \Omega \rvert} \sum _ {\omega \in \Omega} X _ i(\omega)$が成立する。

ここで、$X _ i$の定義は「最終的に学生$1$が過去問$i$を持っていれば$1$、そうでなければ$0$となる写像」であった。
つまり、$\sum _ {\omega \in \Omega} X _ i(\omega)$は「最終的に学生$1$が過去問$i$を持っているようなイベント列の数」である。

以上より、$E\lbrack X _ i \rbrack = \frac{(\text{学生$1$が過去問$i$を持っているようなイベント列の数})}{(\text{イベント列の総数})}$である。
これはランダムに一つイベント列をとったとき、それが学生$1$に過去問$i$が回ってくるようなイベント列である確率ととらえることが出来る。

さて、問題に戻ろう。最初検討した動的計画法は、**過去問全種類について**一挙に考えようとしていたため、$N$人がそれぞれ$N$ビットの情報を持つ必要があった。しかし、確率変数の分離と期待値の線形性により、**過去問の種類ごとに分けて考えてよい**ことがわかった。
ここで改めて動的計画法を組みなおそう。
欲しい値は、「ある科目について、学生$1$が最終的に過去問を得られるようなイベント列の総数(あるいはそのイベントの全体からの割合)」である。
過去問の伝播は、過去問を既に持っている人からしか発生しないため、$i$回のイベントが終わった時点でその過去問を持っている人の集合がわかれば遷移が出来そうだ。そこで、$\mathrm{P}\lbrack i \rbrack \lbrack S \rbrack = (\text{$i$回のイベントが終わった時点で、ある教科の過去問を持っている人の集合が$S$であるようなイベント列の割合})$
とする。
$i$から$i + 1$の遷移は、$M$個すべての関係を見たとき、
1. 人$a _ j$または$b _ j$が過去問を持っているとき、$\mathrm{dp}\lbrack i + 1 \rbrack \lbrack S \cup a _ j \cup b _ j \rbrack$に$\frac{1}{M} \mathrm{dp}\lbrack i \rbrack \lbrack S \rbrack$を足しこむ。
2. そうでない時、$\mathrm{dp}\lbrack i + 1 \rbrack \lbrack S \rbrack$に$\frac{1}{M} \mathrm{dp}\lbrack i \rbrack \lbrack S \rbrack$を足しこむ。

という形になる。初期状態は、教科$x$について考えるとき、
$\mathrm{dp}\lbrack 0 \rbrack \lbrack \lbrace x \rbrace \rbrack = 1$、それ以外は$0$となる。
最終的に、解に$\mathrm{dp}\lbrack K \rbrack \lbrack S \rbrack$であって、$S$に$1$が含まれるものを足しこむことになる。

最後にこの解法の計算量を確認しておこう。
$i$を固定した際の状態数が$2 ^ N$で、これら一つあたり$M$個の$O(1)$時間で行なえる遷移を試すことになるので、教科一つについて$O(K 2 ^ N M)$時間である。
$N$教科についてこれを行うと、全体で$O(NK 2 ^ N M)$時間となる。
$NK 2^ N M$は制約下で$NK 2 ^ N M \leq 23040000 \approx 2.3 \times 10 ^ 7$となる。

## 実装例

c++による解答例を示す。
[jagページ](https://jag-icpc.org/?2024%2FPractice%2F%E6%A8%A1%E6%93%AC%E5%9B%BD%E5%86%85%E4%BA%88%E9%81%B8%2F%E5%95%8F%E9%A1%8C%E6%96%87%E3%81%A8%E3%83%87%E3%83%BC%E3%82%BF%E3%82%BB%E3%83%83%E3%83%88)にあるすべてのテストケースに対して、10秒以内程度で正しい解を出力することを確認している。

```c++
#include <iostream>
#include <vector>
#include <cassert>
#include <utility>

using namespace std;
using ll = long long;

ll mod_pow (ll a, ll x, const ll MOD) {
    assert(0 <= x);
    assert(1 <= MOD);

    a %= MOD;
    if (a < 0) a += MOD;

    ll base = a;
    ll res = 1;
    while (0 < x) {
        if (0 < (x & 1)) {
            res *= base;
            res %= MOD;
        }
        base *= base;
        base %= MOD;
        x >>= 1;
    }

    return res % MOD;
}

ll mod_inv (ll a, const ll MOD) {
    // MOD: 素数を仮定
    return mod_pow(a, MOD - 2, MOD);
}

int main () {
    // 確率変数Xを試行終了後に1が持っている過去問の種類数とする。
    // N個の確率変数Xiを、試行終了後に1が過去問iを持っていれば1、持っていなければ0として定める。
    // X = sum(Xi)である。期待値の線形性から、
    // E[X] = sum(E[Xi])としてよい。
    // 定義から、E[Xi] = (1が過去問iを持っている試行の数) / M^K = (1が過去問iを持っている試行が生起する確率)
    // が成立。

    const ll MOD = 998244353;
    vector<ll> ans;

    while (true) {
        int N, M, K; cin >> N >> M >> K;
        if (N == 0 && M == 0 && K == 0) break;

        vector<int> a(M), b(M);
        for (int i = 0; i < M; i++) {
            cin >> a[i] >> b[i];
            a[i]--, b[i]--;
        }

        vector<ll> P(1 << N);
        vector<ll> NP(1 << N);
        // P[i][S] := i回の操作が終わったとき、ある過去問を持っている人の集合がSである確率

        ll inv_M = mod_inv(M, MOD);
        ll res = 0;

        for (int pid = 0; pid < N; pid++) {
            // Pのリセット
            for (int S = 0; S < (1 << N); S++) {
                P[S] = 0;
            }

            // P初期値
            P[1 << pid] = 1;

            for (int i = 0; i < K; i++) {
                // NPのリセット
                for (int S = 0; S < (1 << N); S++) {
                    NP[S] = 0;
                }

                for (int S = 0; S < (1 << N); S++) {
                    for (int j = 0; j < M; j++) {
                        int v = 0;
                        if (0 < (S & (1 << a[j])) || 0 < (S & (1 << b[j]))) v = 1;

                        NP[S | (v << a[j]) | (v << b[j])] += P[S] * inv_M % MOD;
                        NP[S | (v << a[j]) | (v << b[j])] %= MOD;
                    }
                }

                swap(P, NP);
            }

            // 集計
            for (int S = 0; S < (1 << N); S++) {
                if (0 < (S & 1)) {
                    res += P[S];
                    res %= MOD;
                }
            }
        }

        ans.push_back(res);
    }

    for (auto& v : ans) {
        cout << v << "\n";
    }
}
```

## 感想
ようやく解法を理解できた。
問題文を誤読していて、期待値の線形性に持ち込んだ後にちょっと悩むパートがあった。
確率変数を分離して、期待値の線形性に持ち込む解法は他にも出題例があるので、この手の議論に慣れていきたい。
