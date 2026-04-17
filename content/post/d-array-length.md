---
title: "[D言語] 配列を縮めたり伸ばしたりするのはやめたほうがいい"
# description: 

date: 2026-04-17
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - D
  - トリビア
archives:
  - 2026
  - 2026-04
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 要約
`T[]`をstackのように縮めたり伸ばしたりを行うのはやめたほうがいい。

- 末尾要素にしか興味がない: 面倒くさがらずに`std.container.dlist`を使うべき。
- 末尾要素以外も触る: 長めの配列を用意して、どこまで使っているかをもう一つの変数で管理すべき。

## 前提: Dの配列
Dにおいて`T[]`は[派生データ型](https://dlang.org/spec/type.html#derived-data-types)であり、言語側により提供されます。
そしてこれは追加情報を持つC pointerのようなふるまいをします。

`T[]`の値`A`があったとして、

- `A.length`で現在の長さを取得でき、さらに`A.length`を経由して配列長を変更できます。
- `A.capacity`で再確保無しで末尾を伸ばせる限界のサイズを取得できます。
- `A ~= v`で型`T`の値`v`を末尾に追加できます。この際`A.length < A.capacity`であればメモリの再確保は発生しません。
- 末尾要素には`A[$ - 1]`で簡単にアクセスできます。（`$`は`A.length`の糖衣構文だと言っていい。）

## 問題
以上で説明した性質により、

1. 追加の変数を管理せずに
2. 標準ライブラリに依存せずに

簡単にstackを実現できます。
次のような感じです。

```d
void main () {
    int[] stack;
    stack ~= 1;
    stack ~= 2;

    writeln(stack[$ - 1]); // "2"

    stack.length--; // stack = stack[0 .. $ - 1]でもOK

    writeln(stack[$ - 1]); // "1"
}
```

このような書き方は非常に簡潔で、競技プログラミングで重宝します。（していました）
しかし、**このようなコードは書くべきではありません。**

これは`capacity`の変化を見ると明らかです。
次のプログラムを参照してください。[wandbox](https://wandbox.org/permlink/gzh13cpTfdT9rYkG)

```d
import std;

void main () {
    int[] A;

    info(A);
    // array: []
    // ptr: null
    // capacity: 0

    A ~= 1;
    info(A);
    // array: [1]
    // ptr: 7099580D0000
    // capacity: 3

    A ~= 2;
    A ~= 3;
    A ~= 4;
    info(A);
    // array: [1, 2, 3, 4]
    // ptr: 7099580D1000
    // capacity: 7

    A.length--;
    info(A);
    // array: [1, 2, 3]
    // ptr: 7099580D1000
    // capacity: 0
    // ↑ptrが変化していないのにかかわらず、capacityが0になっている！
    // 次回の末尾追加でメモリの再確保が走る。

    A ~= 4;
    info(A);
    // array: [1, 2, 3, 4]
    // ptr: 7099580D1020
    // capacity: 7
    // ↑メモリの再確保が行われて、ptrが変化した！
}

void info (int[] A) {
    writeln("array: ", A);
    writeln("ptr: ", A.ptr);
    writeln("capacity: ", A.capacity);
    writeln();
}
```

注目すべきは`A.length--`を行ったときの`capacity`の変化です。
一見、`length`を変える行為は`capacity`に変化を与えないように思えますが、D言語では`capacity`が0に変わってしまいます。

これにより、プログラマはstackとしての償却$O(1)$時間を期待している一方、実際には$\Theta (\text{length})$時間かかってしまいます。

## なぜこんなことになるのか？
（ここからは私の想像です。）

これはある`T[]`の値が指すメモリをそれ以外の`T[]`が参照している可能性を考慮してだと思います。
例えば、次のコードのような場合が該当します。

```d
import std;

void main () {
    int[] A = [1, 2, 3, 4];
    auto B = A[];

    // AとBは同じメモリを指す。
    assert(A.ptr == B.ptr);
    assert(A.length == B.length);

    A.length--;
    // AとBは以前同じメモリを指す。
    assert(A.ptr == B.ptr);

    A ~= 5;
    // このとき、Aが再確保されないとしたら、B[3]は上書きされることになる。
    // よって、この時Aが再確保され、別のメモリを指すようになる。
    assert(A.ptr != B.ptr);
    assert(A[3] == 5);
    assert(B[3] == 4);
}
```

`A`の長さを減らした後に追加した場合、別の変数に指されている可能性がある領域を書き換えることになり、「追加」であるはずの`~`のセマンティクスに反する挙動をすることになります。
よって、長さが減少する場合は`capacity`を0にする処置が行われるのだと思います。

## 調査結果
実験をして挙動を確かめようかなと思っていましたが、Dのドキュメントにしっかり明記されていました。
[https://dlang.org/spec/arrays.html#capacity-reserve](https://dlang.org/spec/arrays.html#capacity-reserve)

要約すると、

1. 動的配列のスライス`A[x .. y]`は、末尾位置が一致しない（`A[0 .. $ - 1]`など）場合、`capacity`が0になる。
2. 動的配列の長さが減少した場合、`capacity`が0になる。
3. 同じ未使用領域を`capacity`としてもつ動的配列が複数あった場合、（おそらくGCによって）最初にその未使用領域を使用した変数以外の`capacity`が0なる。正確には、未使用領域の最初の部分が自分の操作以外により未使用でなくなった場合0になる。

なるほど。
GCが相当すごいことをやっていて、重いと言われる理由がよくわかりました。

## 終わりに
[このsubmission](https://atcoder.jp/contests/awc0050/submissions/75015100)がTLEで落ちたことによりこの書き方が悪いと気が付きました。
ありがとうAWC

ところで、そもそも「今使っている量」みたいなのを追加で管理したくないからこういうことをやっていたのですが、代替案って何かありませんか？
こういう処理はよく出てきがちなのでいい方法を知りたいです。
