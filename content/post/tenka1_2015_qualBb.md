---
title: 天下一プログラマーコンテスト2015予選B - 天下一リテラル
# description: 

date: 2024-02-28
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
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

## 問題概要

問題

スクリプト言語hnwには整数型、辞書型、集合型が存在する。
整数型のリテラルは$0$以上$10^6$以下の整数を十進数で表記したものである。
辞書型、集合型のリテラルは以下の[EBNF](https://ja.wikipedia.org/wiki/EBNF)に従う。

```EBNF
DICT = "{" , EXPR , ":" , EXPR , { "," , EXPR , ":" , EXPR } , "}" | "{}" ;
SET  = "{" , EXPR , { "," , EXPR } , "}" ;
EXPR = DICT | SET | INTEGER ;
```

集合型か辞書型のリテラル$S$が与えられる。型を判定せよ。

制約

- $\lvert S \rvert \leq 50000$
- 入力に空白は含まれない

## 解法
このような構文解析は`EXPR`を受け取り、型を判定するオラクルが存在すると仮定して考えると良いです。
まず、エイヤと関数だけ作ってしまいましょう。

```d
enum HNW_TYPE {
    DICT,
    SET,
    INTEGER,
    UNDECIDED,
} 

enum HNW_TYPE analize_expr (string s, ref int i) {
}
```

まず、`INTEGER`に関しては定義に再帰的なものが含まれていないため、これを処理します。

```d
if ('0' <= s[i] && s[i] <= '9') {
    while ('0' <= s[i] && s[i] <= '9') i++;
    return HNW_TYPE.INTEGER;
}
```

別に数値をパースする必要はないので、読み飛ばしてしまいましょう。

`DICT`/`SET`のパースをしましょう。`DICT`/`SET`は必ず`{`から始まるので、ここを見つけるところからスタートです。
さらに、`DICT`のみ空なブラケットが許されるので、これは先に判定してしまいましょう。

```d
if (s[i] == '{') {
    i++;
    if (s[i] == '}') { // 空のDICTのリテラル
        i++;
        return HNW_TYPE.DICT;
    }
}
```

次に何らかの`EXPR`が来ますが、これは今作っている関数に丸投げします。
現時点でこの関数に`EXPR`を処理する能力はないですが、ばっちり処理してくれるということにします。
そのあとには`DICT`であれば`:`が来て、`SET`であれば`,`か`}`が来ます。

```d
auto res = HNW_TYPE.UNDECIDED;
bool end_of_expr = false;

while (true) {
    // any EXPR
    analize_expr(s, i);

    switch (s[i]) {
        case ':': // DICT
            i++;
            analize_expr(s, i);
            res = HNW_TYPE.DICT;
            break;

        case ',': // SET
            res = HNW_TYPE.SET;
            break;

        case '}': // SET
            res = HNW_TYPE.SET;
            break;

        default:
            assert(0);
    }

    // 後ろの余計なものを処理
    switch (s[i]) {
        case ',':
            i++;
            break;

        case '}':
            i++;
            end_of_expr = true;
            break;

        default:
            assert(0);
    }

    if (end_of_expr) break;
}
```

これでよさそうです。今までのものをつなげましょう。

## 実装

```d
enum HNW_TYPE {
    DICT,
    SET,
    INTEGER,
    UNDECIDED,
} 

enum HNW_TYPE analize_expr (string s, ref int i) {
    if ('0' <= s[i] && s[i] <= '9') {
        while ('0' <= s[i] && s[i] <= '9') i++;
        return HNW_TYPE.INTEGER;
    }

    if (s[i] == '{') {
        i++;
        if (s[i] == '}') { // 空のDICTのリテラル
            i++;
            return HNW_TYPE.DICT;
        }
    }

    auto res = HNW_TYPE.UNDECIDED;
    bool end_of_expr = false;

    while (true) {
        // any EXPR
        analize_expr(s, i);

        switch (s[i]) {
            case ':': // DICT
                i++;
                analize_expr(s, i);
                res = HNW_TYPE.DICT;
                break;

            case ',': // SET
                res = HNW_TYPE.SET;
                break;

            case '}': // SET
                res = HNW_TYPE.SET;
                break;

            default:
                assert(0);
        }

        // 後ろの余計なものを処理
        switch (s[i]) {
            case ',':
                i++;
                break;

            case '}':
                i++;
                end_of_expr = true;
                break;

            default:
                assert(0);
        }

        if (end_of_expr) break;
    }

    return res;
}
```

後はこの関数に渡した返り値を見てやればよいです。

[提出](https://atcoder.jp/contests/tenka1-2015-qualb/submissions/50711038)

## 感想
$\lvert S \rvert \leq 50000$だったので、特に考えずに再帰処理することができました。
この問題に関しては判定するだけであって、かつ変な入力は与えられないのでそこまで大変ではありませんでした。
しかし、ガチ解析をするにはもう少しBNF等に対する専門知識が必要になると思います。(私は完全に雰囲気で解いています。)

この問題の公式解説が見つからなかったのですが、どこにあるか知っている人いませんか...？
