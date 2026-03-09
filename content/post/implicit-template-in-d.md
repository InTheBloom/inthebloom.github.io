---
title: "[D言語] (a, b) => b < aについて"
# description: 

date: 2026-03-09
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - D
  - トリビア
archives:
  - 2026
  - 2026-03
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## 前提
API Documentationはversion 2.112.0を参照しています。
なお、私の手元環境はDebian GNU/Linux 12 (bookworm) 64bit + dmd v2.108.1です。

## 問題
`std.algorithm.sorting.sort`を利用するとき、例えば降順ソートだと
```d
A.sort!((a, b) => b < a);
```
と書くことがあると思います。
ところで、`(a, b) => b < a`って一体何なのでしょうか？

## 正解
[Expressions](https://dlang.org/spec/expression.html)に答えが書いていました。

11.19.8.3 Function Literal Templatesによると、

> A function literal will be a template when it has either:（関数リテラルは、いずれかの場合にテンプレートになります。）
> - An unspecified parameter type and no context to infer it from.（指定されていないパラメータ型で、それを推測するためのコンテキストがありません。）
> - An auto ref parameter.（ 自動参照パラメータ。)

だそうです。
つまり、正解は「`(a, b) => b < a`は関数テンプレート」でした。
なので、脱糖すると
```d
void main () {
    int[] A = [3, 1, 4, 1, 5];

    A.sort!(comp);
}

template comp (T) {
    bool comp (T a, T b) {
        return b < a;
    }
}
```
に近いことが起こっているのだと推測できます。
なるほど〜

## 余談1
`sort`のシグネチャは[ドキュメント](https://dlang.org/library/std/algorithm/sorting/sort.html)によると
```d
SortedRange!(Range,less) sort(alias less, SwapStrategy ss = SwapStrategy.unstable, Range)(
  Range r
);
```
となっています。
今まで使ったことなかったのですが、`SortedRange!(Range,less)`がめちゃくちゃ便利かもしれないことに気が付きました。
細かい仕様は[ここ](https://dlang.org/library/std/range/sorted_range.html)に記載されていますが、競技プログラミング的には

- `contains`
- `trisect`

が使えると嬉しい場面が多そうです。
ただ、indexを触りたいときにひと工夫必要そうなので肝心なときに役に立たない気もしています。

## 余談2
競技プログラミングでハードラックとダンスっちまったときにD言語のドキュメントに目を通していますが、基本的によ〜く読まないとよくわからない機能が多くて困っています。
他の言語に比べて、どこまでがライブラリ実装されていて、どこからランタイム機能になるのか難しい機能が多い印象です。

結局`alias`がどこまでできて何ができないのかとかはよくわかっていません。
あとはメタプログラミングの文脈での`tuple`（`AliasSeq`？）もよくわかりません。
とりあえず`std.typecons: Tuple`とは全く異なるのはわかりますが、`AliasSeq`を用いたメタプログラミングは自力で組み立てられません。
（というのを書いているときに`std.typecons`のドキュメントを見に行ったのですが、そんなことできたんかい！みたいな機能が提供されていて、D言語練度の低さを思い知りました。）

なんというか、Dを使いこなすためにはプログラミングの作法や機能を知っていないといけないように感じて、[最初のプログラミング言語としては、PythonやJavaScriptの方が適している。](https://dlang-ja-dokutoku-b1ce36c99e10c96adf0310979a9f2e5f51a136791c046.gitlab.io/overview.html)という記述はもっともだなと思いました。
（ただ、Pythonは型の意識が身につきにくいし、JavaScriptは至るところで非同期が絡んでくるから最初の言語として適しているか？とも思いますが...）

![引用のスクリーンショット](/images/implicit-template-in-d/quote.png)

競技プログラミングばっかりやっていたら全然プログラミングうまくならないのでなんか別のことにも手を出したいですね。
技術書とかいうの読んでみたいです。
