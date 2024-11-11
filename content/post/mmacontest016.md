---
title: MMA Contest 016 (upsolved)
# description: 

date: 2024-03-06
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - upsolve
archives:
  - 2024
  - 2024-03
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## はじめに
来るMMA Contest 018に備えて[MMA Contest 016](https://yukicoder.me/contests/450)のupsolveを行いました。
問題の振り返りをします。

## 問題たち

### A - 2KA 3 KA

[問題へのリンク](https://yukicoder.me/problems/no/2414)

$X = 2(AB + AC + BC)$と$Y = ABC$が成立します。

```c++
#include <iostream>

using namespace std;

int main () {
    int A, B, C; cin >> A >> B >> C;

    int X = 2*A*B + 2*A*C + 2*B*C;
    int Y = A*B*C;

    if (Y < X) {
        cout << 2 << "\n";
    }
    else {
        cout << 3 << "\n";
    }
}
```

### B - 偶数判定！Nafmoくん

[問題へのリンク](https://yukicoder.me/problems/no/2415)

2進数の偶奇は末尾の桁のみを見ればよいです。

```c++
#include <iostream>
#include <string>

using namespace std;

int main () {
    string A, B;
    cin >> A >> B;

    if (A.back() == '0' || B.back() == '0') {
        cout << "Even\n";
    }
    else {
        cout << "Odd\n";
    }
}
```

### C - vs Slime

[問題へリンク](https://yukicoder.me/problems/no/2416)

よくある漸化式が立つやつです。
$f(h) \coloneqq (体力hのスライムに対する問題の解)$としたとき、

- $f(h) = 1 + 2 f( \lfloor \frac{h}{A} \rfloor )$
- $f(0) = 0$

が成立します。さらに、「割った値を床関数にかける」を繰り返して得られる値は十分少ないです。
特に、$A = 2$の時$\lfloor \frac{h}{2^x} \rfloor$か$\lceil \frac{h}{2^x} \rceil$に限られるそうです。
証明は理解していませんが、[これ](https://atcoder.jp/contests/abc340/editorial/9308)などが参考になりそうです。

よって、メモ化で通ります。

```c++
#include <iostream>
#include <map>

using namespace std;
using ll = long long;

ll rec (ll H, ll A, map<ll, ll>& memo) {
    if (H == 0) return 0;
    if (memo.find(H) != memo.end()) return memo[H];

    ll res = 1 + 2 * rec(H/A, A, memo);
    memo[H] = res;
    return memo[H];
}

int main () {
    // 再帰メモ化していいやつ。atcoderに似た問題あった気がする
    ll H, A; cin >> H >> A;
    map<ll, ll> memo;

    cout << rec(H, A, memo) << "\n";
}
```

### D - Div Count

[問題へのリンク](https://yukicoder.me/problems/no/2417)

ある$0 < A$を一つ固定します。この$A$が条件を満たすとは、次のことです。

- ある整数$0 \leq p$が存在して、$N = pA + K$かつ$K &lt; A$が成立する。

この時、$p = \frac{N-K}{A}$となるため、ある$A$が条件を満たすとき、$p$は一意であることがわかります。

すなわち、条件を満たす$A$の必要十分条件は$A \vert (N-K)$かつ$K &lt; A$です。
以上より、$N-K$の約数を列挙できれば良いことがわかります。

```c++
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;
using ll = long long;

vector<ll> enum_divs (ll x) {
    vector<ll> res;
    for (int i = 1; i <= x; i++) {
        if (x < 1LL * i * i) break;
        if (x % i == 0) {
            res.push_back(i);
            if (x / i != i) res.push_back(x/i);
        }
    }
    sort(res.begin(), res.end());

    return res;
}

int main () {
    ll N, K; cin >> N >> K;

    auto divs = enum_divs(N-K);
    int ans = 0;
    for (auto& v : divs) if (K < v) ans++;

    cout << ans << "\n";
}
```

### E - 情報通だよ！Nafmoくん

[問題へのリンク](https://yukicoder.me/problems/no/2418)

連結成分内で出来るだけペアを組むのが最適です。
したがって、$(余る人の総和)/2$が解になります。

```c++
#include <iostream>
#include <vector>

using namespace std;

class UnionFind {
    private:
        vector<int> par, size;

    public:
        UnionFind (int N) {
            par.resize(N);
            size.resize(N);

            for (int i = 0; i < N; i++) {
                par[i] = i;
                size[i] = 1;
            }
        }

        int root (int u) {
            if (par[u] == u) return u;
            return par[u] = root(par[u]);
        }

        void unite (int u, int v) {
            int l = root(u);
            int s = root(v);
            if (l == s) return;

            if (size[l] < size[s]) swap(l, s);
            size[l] += size[s];
            par[s] = l;
        }

        bool same (int u, int v) {
            return root(u) == root(v);
        }

        int groupsize (int u) {
            return size[u];
        }
};

int main () {
    // 余るのは常に連結成分数の端数だけ -> UF
    int N, M; cin >> N >> M;
    UnionFind UF(2*N);

    for (int i = 0; i < M; i++) {
        int A, B; cin >> A >> B;
        A--, B--;

        UF.unite(A, B);
    }

    int ans = 0;
    for (int i = 0; i < 2*N; i++) {
        if (UF.root(i) == i) ans += UF.groupsize(i) % 2;
    }

    ans /= 2;
    cout << ans << "\n";
}
```

### F - MMA文字列2

[問題へのリンク](https://yukicoder.me/problems/no/2419)

「先頭$i$文字から作れる部分列で、大文字2文字を0, 1, 2文字連続したものは何通りとれるか」を計算していけば良いです。

$\mathrm{dp}[i][j][k] \coloneqq (先頭i文字から、文字'A' + jがk個連続する部分列を何通りとれるか)$とします。
初期値は

- $\mathrm{dp}[0][j][0] = 1$

で、新しく追加する文字$c$に対して、

- $\mathrm{dp}[i+1][c][k] += \mathrm{dp}[i][c][k-1]$

と更新すればよいです。更新されるところ以外は$c$は3文字目として使えるので、$\mathrm{dp}[i][j][2]$を答えに足しこんでいきます。
実装上は最新の配列のみを持てばよいです。

```c++
#include <iostream>
#include <string>
#include <vector>

using namespace std;
using ll = long long;

int main () {
    string S; cin >> S;
    // (文字)と
    // (文字)(文字)が何通りあるかをカウントしながら進んでいけばwordsize分で行ける

    ll ans = 0;
    vector<vector<ll>> dp(26, vector<ll>(3, 0));
    for (int i = 0; i < 26; i++) dp[i][0] = 1;

    for (int i = 0; i < S.size(); i++) {
        // 更新
        for (int k = 2; 1 <= k; k--) dp[S[i] - 'A'][k] += dp[S[i] - 'A'][k-1];

        // それ以外の文字はMMAを完成させる
        for (int j = 0; j < 26; j++) {
            if (j == S[i] - 'A') continue;
            ans += dp[j][2];
        }
    }

    cout << ans << "\n";
}
```

### G - Simple Problem

[問題へのリンク](https://yukicoder.me/problems/no/2420)

$$
\begin{equation}
\begin{split}
&\sqrt{A} + \sqrt{B} &lt; X \newline
\Rightarrow ~ & A + 2\sqrt{AB} + B &lt; X^2 \newline
\Leftrightarrow ~ & 2\sqrt{AB} &lt; X^2 - (A+B) \newline
\Rightarrow ~ & 4AB &lt; (X^2 - (A+B))^2
\end{split}
\end{equation}
$$

となり、根号を排除できます。
ただし、最初と最後は同値ではないことに注意してください。
同値にするには、$0 &lt; X$と$(A+B) &lt; X^2$を追加すればよいです。

以上より、二分探索で解けます。

```c++
#include <iostream>
#include <boost/multiprecision/cpp_int.hpp>

using namespace std;
using ll = long long;
using namespace boost::multiprecision;

ll solve (int A, int B) {
    auto f = [&](ll X) -> bool {
        cpp_int a = A, b = B, x = X;

        return 0 < x*x - a - b && 4 * a * b < (x*x - (a+b)) * (x*x - (a+b));
    };

    ll ok = 65000, ng = 0;
    while (1 < abs(ok-ng)) {
        ll mid = (ok + ng) / 2;
        if (f(mid)) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }

    return ok;
}

int main () {
    int N; cin >> N;
    // 二回2乗してやれば二分探索できそうな形になる(った)
    // -> アッ、二乗したときに符号関連の情報が死んでるっぽい

    while (N--) {
        int A, B; cin >> A >> B;

        auto ans = solve(A, B);
        cout << ans << "\n";
    }
}
```

同値性が失われていることを忘れており、精度死しているのかと思って`cpp_int`を持ち出してしまいました。

### H - entrsys?

[問題へのリンク](https://yukicoder.me/problems/no/2421)

クエリ2は人ごとに入退室の時間を`std::map`に入れていけば良いです。
クエリ1はrange\_add、point\_getができればよいです。
出現しうる座標を先読み + 座標圧縮をし、Dynamic range sum queryができるデータ構造の上でimos法をすることで達成できます。

注意として、mapに退室情報を入れるときに、入力情報を上書きしてはいけません。(これでめちゃくちゃ不正解を出しました。)

```c++
#include <iostream>
#include <string>
#include <map>
#include <algorithm>

#include <atcoder/segtree>

using namespace std;
using namespace atcoder;

int op (int x, int y) { return x + y; }
int e () { return 0; }

int main () {
    // クエリ2 -> 座圧 + 区間加算、1点取得のセグ木。
    // クエリ1と3 -> 人ごとにmapを持っておいて、lower_boundしましょう。
    int N; cin >> N;
    map<string, int> X_inv;
    vector<string> X(N);
    vector<int> L(N), R(N);

    for (int i = 0; i < N; i++) {
        cin >> X[i] >> L[i] >> R[i];

        int len = (int) X_inv.size();
        if (X_inv.find(X[i]) == X_inv.end()) X_inv[X[i]] = len;
    }

    int Q; cin >> Q;
    vector<int> type(Q), l(Q), r(Q), t(Q);
    vector<string> x(Q);

    for (int i = 0; i < Q; i++) {
        cin >> type[i];
        if (type[i] == 1) {
            cin >> x[i] >> t[i];

            int len = (int) X_inv.size();
            if (X_inv.find(x[i]) == X_inv.end()) X_inv[x[i]] = len;
        }

        if (type[i] == 2) {
            cin >> t[i];
        }

        if (type[i] == 3) {
            cin >> x[i] >> l[i] >> r[i];

            int len = (int) X_inv.size();
            if (X_inv.find(x[i]) == X_inv.end()) X_inv[x[i]] = len;
        }
    }

    // 座圧
    vector<int> f_inv;
    for (int i = 0; i < N; i++) {
        f_inv.push_back(L[i]);
        f_inv.push_back(R[i]);
    }
    for (int i = 0; i < Q; i++) {
        if (0 < l[i]) f_inv.push_back(l[i]);
        if (0 < r[i]) f_inv.push_back(r[i]);
        if (0 < t[i]) f_inv.push_back(t[i]);
    }

    sort(f_inv.begin(), f_inv.end());
    f_inv.erase(unique(f_inv.begin(), f_inv.end()), f_inv.end());

    map<int, int> f;
    for (int i = 0; i < f_inv.size(); i++) f[f_inv[i]] = i;

    // セグ木
    segtree<int, op, e> seg(f.size() + 10);

    auto range_add = [&](int l, int r, int v) -> void {
        seg.set(l, seg.get(l) + v);
        seg.set(r, seg.get(r) - v);
    };

    auto point_get = [&](int x) -> int {
        return seg.prod(0, x+1);
    };

    for (int i = 0; i < N; i++) {
        range_add(f[L[i]], f[R[i]] + 1, 1);
    }

    // map
    enum STATE {
        IN,
        OUT,
    };

    vector<map<int, STATE, greater<int>>> mp(X_inv.size());

    for (int i = 0; i < N; i++) {
        int idx = X_inv[X[i]];
        mp[idx][L[i]] = IN;
        mp[idx].try_emplace(R[i] + 1, OUT);
    }

    // クエリ処理
    for (int i = 0; i < Q; i++) {
        if (type[i] == 1) {
            int idx = X_inv[x[i]];
            auto it = mp[idx].lower_bound(t[i]);

            if (it == mp[idx].end() || it->second == OUT) {
                cout << "No\n";
            }
            else {
                cout << "Yes\n";
            }
        }

        if (type[i] == 2) {
            cout << point_get(f[t[i]]) << "\n";
        }

        if (type[i] == 3) {
            int idx = X_inv[x[i]];
            mp[idx][l[i]] = IN;
            mp[idx].try_emplace(r[i] + 1, OUT);

            range_add(f[l[i]], f[r[i]] + 1, 1);
        }
    }
}
```

解法は10分以内に見えた一方、慣れない言語でこれをやるのは本当にしんどかったです。

### I - regisys?

[問題へのリンク](https://yukicoder.me/problems/no/2422)

おそらく貪欲だろうなという点以外全くわかりませんでした。
とりあえず解説ACしましたが、正当性がわからないので提出は載せません。

SSRS氏のユーザー解説がありますが、こちらは私のレベルを大きく超えているため現時点では理解をあきらめました。(Hallの結婚定理の事実だけ覚えておきました。)

### J - Merge Stones

[問題へのリンク](https://yukicoder.me/problems/no/2423)

$i$から右回りに$j$個とった連続区間を考え、これを色$c$の一つの石にまとめられるか？という状態を考えます。
$\Theta (3^N)$のbit DPのように、完成状態から一つむしり取るような遷移で$O(N^3 50K)$の区間DPができます。

[提出](https://yukicoder.me/submissions/957832)

上の提出のように、これは間に合いません。
ここで、詰まってしまい、解説を見ました。

「$i$から右回りに$j$個とった連続区間を色$c$にまとめられるか？」が1bitにまとめられることを利用して、64bit整数型に押し込むことでword sizeの高速化をします。

遷移に関しては、

- 切れ目の右側を$k$bits右シフト、左側はそのままとのbitwise AND
- 切れ目の右側を$k$bits左シフト、左側はそのままとのbitwise AND
- 切れ目の左側を$k$bits右シフト、右側はそのままとのbitwise AND
- 切れ目の左側を$k$bits左シフト、右側はそのままとのbitwise AND

の4通りを考え、これらと分割元とのbitwise ORをとることで達成できます。

```c++
#include <iostream>
#include <vector>

using namespace std;
using ll = long long;
using ull = unsigned long long;

int main () {
    // 色と場所を持って区間dpできそう -> 間に合わないが、真偽値によるdpであることを考えるとワードサイズ分の高速化が効く

    int N, K; cin >> N >> K;
    vector<int> A(N), C(N);

    for (int i = 0; i < N; i++) cin >> A[i];
    for (int i = 0; i < N; i++) cin >> C[i];
    for (int i = 0; i < N; i++) C[i]--;

    vector<vector<ull>> dp(N, vector<ull>(N+1, 0));
    // dp[i][j] := iから右回りにj個の区間を全統合したとき、作成可能な色のセット

    for (int i = 0; i < N; i++) dp[i][1] = 1ull<<C[i];

    ull mask = (1ull<<50) - 1;

    for (int j = 2; j <= N; j++) {
        for (int i = 0; i < N; i++) {
            for (int mid = 1; mid < j; mid++) {

                // 右シフト or 左シフト
                for (int k = 0; k <= K; k++) {
                    dp[i][j] |= dp[i][mid] & (dp[(i+mid) % N][j-mid] >> k);
                    dp[i][j] |= (dp[i][mid] >> k) & dp[(i+mid) % N][j-mid];

                    dp[i][j] |= dp[i][mid] & (dp[(i+mid) % N][j-mid] << k);
                    dp[i][j] |= (dp[i][mid] << k) & dp[(i+mid) % N][j-mid];
                }
            }

            dp[i][j] &= mask;
        }
    }

    ll ans = 0;
    for (int i = 0; i < N; i++) for (int j = 1; j <= N; j++) for (int c = 0; c < 50; c++) if (0 < dp[i][j]) {
        ll sum = 0;
        for (int k = 0; k < j; k++) sum += A[(i + k) % N];
        ans = max(ans, sum);
    }

    cout << ans << "\n";
}
```

## 終わりに

体感難易度は次のような感じです。

A &lt; B &lt; C &lt; E &lt; D &lt; F &lt; G &lt; H &lt; J &lt; I

後ろ3問はほんとに疲れました。
