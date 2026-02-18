---
title: 非可換モノイドの逆順積の計算
# description: 

date: 2026-02-18
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
  - 典型テク
archives:
  - 2026
  - 2026-02
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## はじめに
小ネタです。全人類知っているかもしれませんが、私は比較的最近知ったので共有します。
以下、モノイドは$(M, e, \times)$を考えます。

モノイドはものによっては可換性を持ちません。すなわち、$a, b \in M$に対して、$a \times b \neq b \times a$になりえます。
また、競技プログラミングにおいて、「モノイドの列$A = (A _ 0, A _ 1, \dots, A _ {N - 1})$が与えられるので、$l, r$に対して$A _ l \times A _ {l + 1} \times \dots \times A _ {r - 1}$と$A _ {r - 1} \times A _ {r - 2} \times \dots \times A _ l$を両方計算する」といったタスクに出会うことがあります。
前者（$A _ l \times A _ {l + 1} \times \dots \times A _ {r - 1}$）はセグメント木なりsparse tableなりで簡単に計算できますが、後者は苦労することが多いです。（同じようにセグメント木を用いるとすると、逆順にのせた上でindexの変換が必要です。）

本エントリでは、前者を計算するのと全く同じように後者を計算する方法を紹介します。
なお、説明の都合上、前者の計算結果を「正順の値」、後者を「逆順の値」と呼びます。

## やりかた
簡単のため計算にACLのセグメント木を利用することを考えます。（インターフェースが広く知られているからACLをたとえ話に出すだけで、別のデータ構造でも動くはずです。）
ACLにおいてはモノイドの演算を関数ポインタや関数オブジェクトとして渡しますが、そのシグネチャはモノイドの型`M`としたとき、`M op (M a, M b)`という形になり、`op(a, b)`として呼ぶことで$a \times b$を計算します。
この`op`をテンプレートに渡したうえで`prod(l, r)`を呼ぶことで正順の値を計算できます。

実は、以下のように定義される`op2`をテンプレートに渡したうえで`prod(l, r)`を呼ぶことで逆順の値を計算することができます。（初期化の際に列をreverseしたり、indexを変換する必要は全くなく、ここだけ変えます。）
```c++
M op2(M a, M b) {
    return op(b, a);
}
```
これが正しく動くことを確認しておきましょう。
$[l, r)$に対して逆順の値を計算するとき、セグメント木ではいくつかのブロックを拾っていき、$\mathrm{op2}$で結合していきます。
最後の1回の結合が$[l, m)$と$[m, r)$の結合であったとし、$[l, m)$と$[m, r)$に対応するブロックにはその区間の逆順の値が保存されているとします。
このとき、
$$\mathrm{op2}(A _ {m - 1} \times A _ {m - 2} \times \dots \times A _ l, A _ {r - 1} \times A _ {r - 2} \times \dots \times A _ m)$$
を計算することになります。定義から、
$$
\mathrm{op2}(A _ {m - 1} \times A _ {m - 2} \times \dots \times A _ l, A _ {r - 1} \times A _ {r - 2} \times \dots \times A _ m) \\\\
= \mathrm{op}(A _ {r - 1} \times A _ {r - 2} \times \dots \times A _ m, A _ {m - 1} \times A _ {m - 2} \times \dots \times A _ l) \\\\
= A _ {r - 1} \times A _ {r - 2} \times \dots \times A _ l
$$
となり、$[l, m)$と$[m, r)$の逆順の値が計算できていれば、$m$をどのようにとっても$[l, r)$の逆順の値も計算できることがわかりました。
$[l, l + 1)$に対応する逆順の値は$A _ l$なので、同様の議論により要素数が1になるまで分割を続けることで正当性がわかります。

さらに、この方法はセグメント木特有のものではなく、sparse tableや累積和等の区間モノイド積を扱うデータ構造（私が知る限りは全て）に適用可能です。

## 応用例1
連続部分文字列$S = (s _ l, s _ {l + 1}, \dots, s _ {r - 1})$を、基数$b$、法$M$として
$$
\sum _ {i = l} ^ {r - 1} s _ i b ^ {r - i - 1} \bmod M
$$
によりハッシュ化する手法は競技プログラミング界隈でRolling Hashと呼ばれています。
ここで、各連続部分文字列に対して定まる$(ハッシュ値, b ^ {文字列長})$という値の組を考えます。
実は、この値は単位元$(0, b ^ 0)$と結合演算
$$
(h _ 1, b ^ {l _ 1}) \times (h _ 2, b ^ {l _ 2}) = (h _ 1 b ^ {l _ 2} + h _ 2, b ^ {l _ 1 + l _ 2})
$$
によって非可換モノイドを成し、セグメント木などを利用することで1点への文字変更、任意の連続部分文字列に対するハッシュ値取得を$O(\log N)$時間で行うことができます。

[ABC331F - Palindrome Query](https://atcoder.jp/contests/abc331/tasks/abc331_f)はこのモノイドを利用することが想定解の問題です。
回文の判定を「正順のハッシュ値と逆順のハッシュ値が等しい」で判定することができますが、ここで逆順の値が欲しくなります。

本テクニックにより簡潔に解くことができます。
結合を逆にしたセグメント木を用意して、あとはそのまま使うだけです。
```D
alias RH = RollingHash!();
auto seg = new SegmentTree!(RH.Hash, (RH.Hash a, RH.Hash b) => RH.concat(a, b), () => RH.Hash())(N);
auto segR = new SegmentTree!(RH.Hash, (RH.Hash a, RH.Hash b) => RH.concat(b, a), () => RH.Hash())(N);
```
```D
ans ~= seg.prod(L, R).value == segR.prod(L, R).value;
```

[解答例（DMD 2.111.0）](https://atcoder.jp/contests/abc331/submissions/71784182)

## 応用例2
Heavy Light Decompositionで非可換モノイドを扱う際、index変換無しで集計できます。
$u \rightarrow v$パスを扱うとき、必ず$u$側が逆順の値、$v$側が正順の値を扱うことになるので、そのように集計すればよいです。

Library Checkerの[Vertex Set Path Composite](https://judge.yosupo.jp/submission/338095)が良い練習になります。（ライブラリさえ整備してしまえばやるだけです。）
$t = 1$クエリには次のように答えます。
```D
int u = input[1];
int v = input[2];
int x = input[3];

T uProd = e();
T vProd = e();
while (top[u] != top[v]) {
    if (depth[top[u]] < depth[top[v]]) {
        vProd = op(seg.prod(place[top[v]], place[v] + 1), vProd);
        v = parent[top[v]];
    }
    else {
        uProd = op(uProd, segR.prod(place[top[u]], place[u] + 1));
        u = parent[top[u]];
    }
}

if (depth[u] < depth[v]) {
    vProd = op(seg.prod(place[u], place[v] + 1), vProd);
}
else {
    uProd = op(uProd, segR.prod(place[v], place[u] + 1));
}

T pathProd = op(uProd, vProd);
```
[解答例](https://judge.yosupo.jp/submission/338095)

## 補足
- 機械的に変換できる
- index変換を考えなくてよい

という利点はありますが、定数倍を詰めに行くならセグメント木2本よりもモノイドを太らせた方が良いかもしれません。

私が最初にこれを知ったきっかけはLCに提出されている誰かのHLDだったはずですが、誰のHLDだったか忘れました。
