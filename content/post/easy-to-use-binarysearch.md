---
title: めぐる式二分探索亜種を使ってみませんか？
# description: 

date: 2025-03-16
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2025
  - 2025-03
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## はじめに
私の中で今のところ一番しっくり来ている二分探索の抽象化を紹介します。

## 対象読者

* 二分探索を毎回べた書きしている。
* 以下のような二分探索関数を使用していて、不満がある。よくわからないoff-by-oneで苦しんだことがある。添字バトルで敗北したことがある。

```c++
using ll = long long;

template<typename T>
ll bsearch (T cond, ll ok, ll ng) {
    while (1 < abs(ok - ng)) {
        ll mid = (ok + ng) / 2;
        if (cond(mid)) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }
    return ok;
}
```

## めぐる式二分探索の好きじゃないところ

1. `true`区間の存在を仮定している。

めぐる式二分探索においては`cond(ok)`が`true`となることを仮定してしまっています。
しかし、実際の二分探索において自然な判定問題を考えると`cond(ok)`がすでに`false`になる場合があります。

例えば、昇順に並んだ長さ$N$の配列$A$において$b$以下である最大の要素がどこにあるか探すとします。
$A = (2, 5, 10, 15, 47), b = 20$のとき、$A _ 3 = 15$かつ$A _ 4 = 47$なので、答えは$3$です。


この問題を解くために以下のようなc++コードを書いたとします。

```c++
int solve (std::vector<int>& A, int b) {
    int ok = 0, ng = static_cast<int>(A.size());
    while (1 < abs(ok - ng)) {
        int mid = (ok + ng) / 2;
        if (A[mid] <= b) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }
    return ok;
}
```

さっそく使ってみます。

```c++
int main () {
    std::vector<int> A{2, 5, 10, 15, 47};
    int b = 20;

    std::cout << solve(A, b) << "\n"; // 出力: 3
}
```

うまく動いていそうです。では次のケースではどうでしょうか？

```c++
int main () {
    std::vector<int> A{2, 5, 10, 15, 47};
    int b = 1;

    std::cout << solve(A, b) << "\n"; // 出力: 0
}
```

$A _ 0 = 2, b = 1$なのでこれは誤りで、解なしが正しいです。
めぐる式二分探索では、指定範囲に`true`区間が存在しない場合に`ok`が動かないまま反復終了してしまい、`cond(ok)`のみが`true`であるケースと区別することができません。これが`cond(ok)`が`true`を仮定していることの弊害です。

この問題を解決するために、判定問題を拡張して無理やり`true`区間を生み出すことがよく行われています。
例えば、次のような感じです。

```c++
int solve_correct (std::vector<int>& A, int b) {
    int ok = -1, ng = static_cast<int>(A.size());
    while (1 < abs(ok - ng)) {
        int mid = (ok + ng) / 2;
        if (A[mid] <= b) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }
    return ok;
}
```

`ok = -1`に変更しました。イメージとしては$A$を勝手に拡張して$A _ {-1} = -\infty$としている感じです。
修正した二分探索において`-1`が帰ってきたときは解なしがわかります。アルゴリズムの動作を考えると、実際に$A _ {-1}$にアクセスすることはないことに注意してください。

```c++
int main () {
    std::vector<int> A{2, 5, 10, 15, 47};
    int b = 1;

    std::cout << solve_correct(A, b) << "\n"; // 出力: -1
}
```

このように、めぐる式二分探索を利用するときは「`true`となる区間が存在するか」や「返却値の意味が何か」に注意が必要です。

2. 区間を開区間指定している。

これは個人的意見が大きいのですが、二分探索のような各点での評価値を考えるときには閉区間指定の方がわかりやすいと考えています。
個人的に、二分探索で区間を指定するときは、「解があるとするならこの点以上この点以下」といった風に端点を意識することが多いです。閉区間指定は私の思考様式とマッチしているわけです。

逆向きに区間を指定するときに、`(N - 1, -1)`と`(N - 1, 0)`なら後者の方が自然に感じるというのもあります。
また、単調増加な数列の一定区間を探索するときなどにも$i$項目以降$j$項目以前といった風に閉区間指定が自然に見える気がします。

私の体感ですが、半開区間は表現したい区間が空になりうるときに力を発揮するものであり、表現したい区間が非空であることが保証できるのであればほとんどの用途で閉区間の方が利用しやすいです。（植木算に注意する必要がありますが、経験を積んだ競技プログラマは間違えないと思います。）

## 解決案

上記問題1、2を解決した実装を考えましょう。

問題1に対しては、返却値を構造体などにして「値が存在しない」を表現できるようにするとよいです。
問題2に対しては、めぐる式の更新をベースにして、`ok`と`ng`の幅が十分小さくなったあとに注意して処理することで実現できます。

私が今使用している、D言語による実装例を紹介します。

まずは二分探索結果を表す構造体です。
メンバ関数`empty()`と`value()`を持っていて、`true`区間が存在しない場合に`value`にアクセスしようとすると例外がスローされます。

```d
struct BsearchResult (T) {
    import std.format: format;

    private bool has_value = true;
    private T l, r;
    private T _value;

    this (T _l, T _r) {
        this.l = _l;
        this.r = _r;
        this.has_value = false;
    }
    this (T _l, T _r, T _value) {
        this.l = _l;
        this.r = _r;
        this._value = _value;
    }

    bool empty () {
        return !this.has_value;
    }

    T value () {
        if (this.empty()) {
            throw new NoTrueRangeException(
                    format("No true condition found in the range [%s, %s].", l, r));
        }

        return _value;
    };
}
```

本命の二分探索（の抜粋）です。

```d
BsearchResult!T bsearch (alias func, T) (T l, T r) {
    T L = l, R = r;

    if (l == r) {
        if (func(l)) return BsearchResult!(T)(L, R, l);
        return BsearchResult!(T)(L, R);
    }

    while (min(l, r) + 1 < max(l, r)) {
        T m = midpoint(l, r);

        if (func(m)) {
            l = m;
        }
        else {
            r = m;
        }
    }

    bool lb = func(l);
    if (!lb) return BsearchResult!(T)(L, R);

    bool rb = func(r);
    if (rb) return BsearchResult!(T)(L, R, r);
    if (!rb) return BsearchResult!(T)(L, R, l);

    throw new BsearchException(format("This code path should never be reached. l: %s, r: %s.", L, R));
}
```

基本はほとんどめぐる式と同じですが、多少違いがあります。
半開区間指定と異なり、`l == r`のときにも非空区間が指定されているので処理が必要です。
また、二つの位置が十分近くなったあとに通常のめぐる式とは違いがあります。

説明のため一部抜粋されています。
完全なソースコードは[https://github.com/InTheBloom/InTheBloom\_Library/blob/main/dlang/src/bsearch.d](https://github.com/InTheBloom/InTheBloom_Library/blob/main/dlang/src/bsearch.d)を参照してください。

意見、感想、改善案、より良いアイデアがあれば是非[私のtwitter](https://x.com/UU9782wsEdANDhp)に教えてください。
