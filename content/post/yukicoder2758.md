---
title: No.2758 RDQ
# description: 

date: 2024-05-18
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
archives:
  - 2024
  - 2024-05
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要

[問題へのリンク](https://yukicoder.me/problems/no/2758)

### 問題文
長さ$N$の数列$A = (A _ 1, A _ 2, \dots, A _ N)$が与えられる。次の$Q$個の質問に答えよ。
- 区間$\lbrack L, R \rbrack$の要素$A _ L, A _ {L + 1}, \dots, A _ R$のうち、$K$の倍数はいくつ存在するか。

### 制約
- $2 \leq N \leq 5 \times 10^4$
- $1 \leq Q \leq 5 \times 10^4$
- $1 \leq A _ i \leq 10^5$
- $1 \leq L _ j &lt; R _ j \leq N \\, (1 \leq j \leq Q)$
- $1 \leq K _ j \leq 10^5$

## 解法
素直な方針として、次のものが思いつく。
「$10^5$以下のすべての法について、$A _ i$が法で割り切れるなら$1$、割り切れないなら$0$とした数列を作成し、累積和をとっておく。
クエリに答えるパートでは、$K _ j$を法とした累積和配列を$\mathrm{acc} _ {K _ j}$としたとき、$\mathrm{acc} _ {K _ j} \lbrack R _ j \rbrack - \mathrm{acc} _ {K _ j} \lbrack L _ j - 1 \rbrack$を答える。」
しかし、これは空間/時間ともに$\mathcal{O}(10^5 N)$が必要であり、間に合わない。
そこで、クエリで要求される区間だけを見ることでうまく解けないかを考えてみる。

Mo's algorithmを適用する。
これにより全体の移動回数$\mathcal{O} (N \sqrt{Q})$で次の配列$B$をクエリごとに得ることができる。
$$B \lbrack i \rbrack \coloneqq (\text{$\lbrack L _ j, R _ j \rbrack$に含まれる$i$の数})$$
この配列$B$を用いて$K$の倍数をカウントすることを考える。
この時クエリあたり$\mathcal{O}((\text{配列$B$の長さ}) / K)$回の計算が必要で、十分大きな$K$に対してなら間に合う。
$K$の値が小さなときがボトルネックになっているので、その時は別の解法に切り替えるようにしよう。

十分小さな$K$に対しては集計がネックになる代わりに、空間をあまり使わずに前計算ができることが多い。
以降、$M = (\text{配列$B$の長さ})$とする。本問題においては$1$以上$\sqrt{M}$以下の数に対して「素直な方針」を適用すると、数学的にある程度最善になる事が見込める。
この前計算に必要なメモリは$\mathcal{O}(N \sqrt{M})$で、制約の上で十分実現できる。

これで全体$\mathcal{O}(N \sqrt{Q} + (N + Q) \sqrt{M})$で解ける。

公式解説の方法も理解しておこう。実はこの問題は、最初説明した「素直な方針」を拡張することでもっと楽に解ける。
「$A _ i$が法で割り切れるなら$1$、割り切れないなら$0$とした数列」というものを考えたが、実は$A _ i$を割り切る法は制約において十分に少ない。
そこで、$1$になる要素だけをメモリに記録しておくことで、大幅に高速化することができる。

「$A _ i$を割り切る法」というのはすなわち$A _ i$の約数であるから、「素直な方針」で$1$になる要素の数は高度合成数を用いて上から評価できる。
[高度合成数の一覧](https://algo-method.com/descriptions/92)を見ると、$114N$で抑えることができ、これは制約下で可能である。
具体的なやり方としては、例えばvectorを要素に持つmapを用いる方法がある。空でない配列に対して「本来$1$になるインデックス」を昇順に保持するという感じになる。実装例を参照されたい。
座標圧縮を用いてmapを使用しないこともできると思う。
この方針では約数関数を$\mathrm{d}(x)$として、$\mathcal{O}(N \mathrm{d}(\max A) + Q \log N)$となる。

## 実装例

### Mo + 平方分割
```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <tuple>
#include <cmath>

using namespace std;
using ll = long long;

int main () {
    int N, Q; cin >> N >> Q;
    vector<int> A(N);
    for (int i = 0; i < N; i++) cin >> A[i];

    // 賢いやり方不明。
    // ある程度大きなKに対してはMoを適用し、小さなKに対しては空間N√Nで計算しながらやる。
    vector<int> L(Q), R(Q), K(Q);
    for (int i = 0; i < Q; i++) {
        cin >> L[i] >> R[i] >> K[i];
        L[i]--;
        // 0-indexedで開区間
    }

    vector<int> index(Q), priority(Q);
    const int width = (int) sqrt((double) Q) + 10;

    for (int i = 0; i < Q; i++) {
        index[i] = i;
        priority[i] = L[i] / width;
    }

    sort(index.begin(), index.end(), [&](int x, int y) {
                if (priority[x] == priority[y]) {
                    if ((priority[x]) % 2 == 0) return R[x] < R[y];
                    return R[y] < R[x];
                }
                return priority[x] < priority[y];
            });

    const int max_mod = 100000;
    const int sqrt_N = (int) sqrt((double) N);
    vector<int> count_all(max_mod + 1);
    vector<vector<int>> acc(sqrt_N, vector<int>(N + 1, 0));

    // 前計算
    for (int i = 1; i < sqrt_N; i++) {
        for (int j = 0; j < N; j++) {
            int add = 0;
            if (A[j] % i == 0) add = 1;
            acc[i][j + 1] = acc[i][j] + add;
        }
    }

    vector<int> ans(Q);

    int l = 0, r = 0;
    // [l, r)
    for (int i = 0; i < Q; i++) {
        int idx = index[i];

        while (l < L[idx]) {
            count_all[A[l]]--;
            l++;
        }
        while (L[idx] < l) {
            l--;
            count_all[A[l]]++;
        }

        while (r < R[idx]) {
            count_all[A[r]]++;
            r++;
        }
        while (R[idx] < r) {
            r--;
            count_all[A[r]]--;
        }

        if (K[idx] < sqrt_N) {
            ans[idx] = acc[K[idx]][R[idx]] - acc[K[idx]][L[idx]];
        }
        else {
            int cur = K[idx];
            while (cur <= max_mod) {
                ans[idx] += count_all[cur];
                cur += K[idx];
            }
        }
    }

    for (auto v : ans) cout << v << "\n";
}
```

### 実装例(約数列挙)
```cpp
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

using namespace std;

vector<int> divisors (int N) {
    vector<int> res;
    for (int i = 1; 1LL * i * i <= N; i++) {
        if (0 < (N % i)) continue;
        res.push_back(i);
        if (1LL * i * i == N) continue;
        res.push_back(N / i);
    }
    sort(res.begin(), res.end());
    return res;
}

int main () {
    int N, Q; cin >> N >> Q;
    vector<int> A(N);
    for (int i = 0; i < N; i++) cin >> A[i];

    map<int, vector<int>> acc;

    for (int i = 0; i < N; i++) {
        for (auto d : divisors(A[i])) {
            acc[d].push_back(i);
        }
    }

    for (int i = 0; i < Q; i++) {
        int L, R, K; cin >> L >> R >> K;
        L--, R--;
        auto lit = lower_bound(acc[K].begin(), acc[K].end(), L);
        auto rit = upper_bound(acc[K].begin(), acc[K].end(), R);

        cout << (rit - lit) << "\n";
    }
}
```

## 終わりに
つくづくMo's algorithmは便利だなと思った。
後から考えてみると、私の解法はかなり行き当たりばったりでゴリ押し解法であるように感じる。

C++のイテレータあたりの仕様やテクニックが全然わからないため、公式解説の方法を実装するときにどうしたらよいか困った。
ランダムアクセスイテレータのインクリメントやデクリメントは変なバグやUBを踏みそうで怖い。
