---
title: unstableをstableにする小技
# description: 

date: 2023-07-03
lastmod: 2023-12-01
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
archives:
  - 2023
  - 2023-07
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## はじめに

先日(2023/7/1)の[ABC308](https://atcoder.jp/contests/abc308)のC問題にややこしいソート問題が出ました。
本稿はその問題を簡潔に解く実装のアイディアの紹介です。

## 無理やりstable化

標準ライブラリで一番簡単に使えるソートは安定ソートでないことが多いです。
このため、競技プログラミングでよくある2値以上を取る要素のソートのときなどに、
もとの順序が破壊されて困ることがあります。
これを解消するには、比較関数を自炊してソートに渡してあげればよいです。

例えば、以下のような構造体のソートを考えます。
```D
struct pair {
    int age;
    int id;
}
```

この構造体を次のルールに従って並べ替えます。

1.  `age`が若いほうが先頭
2.  `age`が同じなら、idが小さいほうが先頭

このとき、次のような実装で解決することができます。
```D
pair[] person = new pair[](N);

// ...
// 省略
// ...

bool Less (pair x, pair y) {
    if (x.age == y.age) {
        return x.id < y.id;
    }
    return x.age < y.age;
}

// 比較関数を渡す。
person.sort!(Less);
```

これ、賢いです。 多分3変数以上に拡張可能です。
さらに、stableにしたいという目的以外でも応用可能です。

例えば、[この問題](https://atcoder.jp/contests/abc291/tasks/abc291_c)で、
構造体に座標を突っ込んでいき、このソートをかければ
隣接要素が等しいものが一つでもあれば`Yes`というふうにできます。
(とは言ったものの、特に理由がなければ普通に`std::map`なりなんなりを使いましょう)

## おまけ: C言語での文字列ソート

C言語から始めた人は文字列のソートに
結構苦戦したことある人が多いんじゃないかと勝手に思っています。

せっかくソート小技のエントリなので、サンプルコードを貼り付けときます。

次の問題を解け

N個の長さが10以下の文字列が与えられます。これを辞書順に出力してください。

入力形式

<pre style="border: 1px black solid; background: whitesmoke;">
N
S_1
S_2
.
.
.
S_N-1
S_N
</pre>

-   解法1: 二次元配列で楽するアレ

```C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// T[i]へのポインタが引数なので、char **への変換からのデリファレンスが必要
int mystrcmp (const void *x, const void *y) {
    return strcmp(*(char **)x, *(char **)y);
}

int main (void) {
    int N; scanf("%d", &N);
    char S[N][11];
    char *T[N];

    for (int i = 0; i < N; i++) {
        scanf("%s", S[i]);
        T[i] = S[i];
    }

    // ソートする
    qsort(T, N, sizeof(char *), mystrcmp);

    // 出力
    for (int i = 0; i < N; i++) {
        printf("%s\n", T[i]);
    }

    return 0;
}
```

-   解法2: 一次元配列で文字列を受け取る

```C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// T[i]へのポインタが引数なので、char **への変換からのデリファレンスが必要
int mystrcmp (const void *x, const void *y) {
    return strcmp(*(char **)x, *(char **)y);
}

int main (void) {
    int N; scanf("%d", &N);
    char S[11*N];
    char *T[N];
    int idx = 0;

    for (int i = 0; i < N; i++) {
        T[i] = &S[idx];

        // 入力を受け取る
        char input[11];
        scanf("%s", input);

        for (int j = 0; input[j] != '\0'; j++) {
            S[idx] = input[j];
            idx++;
        }

        // 終端文字も忘れずに
        S[idx] = '\0';
        idx++;
    }

    // ソートする
    qsort(T, N, sizeof(char *), mystrcmp);

    // 出力
    for (int i = 0; i < N; i++) {
        printf("%s\n", T[i]);
    }

    return 0;
}
```

どちらも自動変数に文字列を積んでおいて、それらへのポインタを並べ替えることによってソートを実現しています。
解法1は楽ですが、一つの文字列あたりの長さが不定のときには取り回しが悪いです。
解法2は拡張性がありますが、シンプルに面倒くさいです。

結論: 動的配列が簡単に利用できる言語を使おう！(すみません)

## 余談

方法2は競プロフレンズさんの実装で知りました。
C言語はこういう謎テクが多くて困っちゃう。
