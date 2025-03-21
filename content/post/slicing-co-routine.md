---
title: co-routineをスライスする
# description: 

date: 2025-03-21
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - プログラミング
  - トリビア
  - javascript
  - python
archives:
  - 2025
  - 2025-03
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## はじめに
このエントリの内容は誤りを含む可能性が高いです。ご注意ください。
指摘等は歓迎しますので、[twitter](https://x.com/UU9782wsEdANDhp)までお願いします。

## co-routineの意義
あなたがゲームを作っているとします。
もし30fpsで動作しているとすると、プログラムは1/30秒ごとに入力の監視や画面更新などをしないといけません。
つまり、次のような感じになると思います。（pygame風疑似コード）

```python
running = True
while running:
    for event in engine.get_event():
        # 入力などの処理
        if event.type == QUIT:
            running = False

    # 画面更新
    engine.update_screen()
```

ここで処理に数秒かかる重たい処理をしなければいけないとします。
普通に処理を行うと、その重たい処理が終わるまで入力監視や画面更新が出来なくなってしまいます。

一つの解決策は、仕事を行う人をもう一人追加することです。これは別プロセスや別スレッドを生成してそちらで処理を行うということです。

もう一つの解決策は、処理を細切れにして、ほかの処理を行いながら少しずつ実行し、「合計して」数秒処理するというものです。
処理を細切れにするという通常の関数などとは異なった処理をします。この特別な処理単位は特にコルーチン（co-routine）と呼ばれます。

仕事をする人を増やす解決策を「並列（pararell）」といい、仕事を細切れにして少しずつ進める解決策を「平行（concurrent）」といいます。

## async/await
平行処理を行うためには、今やるべき仕事を決定したり、別の仕事に切り替えたりする「マネージャー」的なものが必要です。
マネージャーは平行処理ライブラリなどに隠蔽されて直接触れることはほぼありませんが、多くの場合「この仕事も管理下に置いて」という指令を出すことにより間接的に触れることができます。

言語によって細かい仕様は異なりますが、`async`や`await`キーワードはこの仕事の依頼や終わった仕事の結果を回収するために用いられます。
大抵、`async`は仕事を追加する動作に対応し、`await`は結果が帰ってくるまで待つ動作に対応することが多いです。

```js
async function f () {
    return 0;
}
```
javascriptを例にしてみます。`async`を用いて定義されたco-routineの`f`は、呼び出された時点で平行処理仕事リストに追加され、`Promise`という型の値が返ります。
この値は仕事がどうなったかを表現します。仕事がすべて完了した時点で、いつの間にか返り値の「結果」の欄が書き換わります。
この例では即座に「結果」に0がセットされるでしょう。

返り値が帰ってきた時点で仕事が完了しているかどうかはわからず、仕事が終わった時に値を書き換えるという形で通知されるというわけです。

```js
async function g () {
    const ret = await f();
    return ret + 1;
}
```

`await`キーワードはco-routine間に依存関係があるときに便利です。`g`は`f`の値に依存するため、`f`よりも先に動作が終わることはありえません。
そこで、`await`によって`f`の`Promise`が完了状態になるまで処理を進めないようにできます。

注意点として、`g`もまたco-routineである必要があります。
`g`がマネージャーの管理下で動かない関数であったとしたら、`g`を動かすためにマネージャーを動かすことができず、`f`が解決されることがないといった状態になってしまうからです。（このあたりの事情、jsとかだともっと複雑な気がしています。普通に嘘かも。）

1. 順次実行と平行実行は同時に共存できない。
2. 平行実行をしている間、あるのは非同期的処理の依存関係だけ。

といった感じになります。

## syncなasync
二つ前の章で「処理を細切れにして」という表現を用いました。
処理の「切れ目」とはどこのことでしょうか？

これは言語仕様に依存しますが、多くは`await`を呼んだタイミングです。
次のサンプルを見てみましょう。

```js
async function f () {
    for (let i = 0; i < 10; i++) {
        console.log(`from f: ${i}`);
    }
}

async function g () {
    for (let i = 0; i < 10; i++) {
        console.log(`from g: ${i}`);
    }
}

f();
g();
```

内部に`for`ループを持つ`async`関数二つを用意して、両方ほぼ同時に起動しました。
結果は以下の通りです。

```text
from f: 0
from f: 1
from f: 2
from f: 3
from f: 4
from f: 5
from f: 6
from f: 7
from f: 8
from f: 9
from g: 0
from g: 1
from g: 2
from g: 3
from g: 4
from g: 5
from g: 6
from g: 7
from g: 8
from g: 9
```

せっかく細切れにして少しずつ処理してやろうとしたのに、順次実行されているように見えます。
`async`のうまみが死んでますね。

では次のコードはどうなるでしょうか？

```js
async function do_nothing () {
}

async function f () {
    for (let i = 0; i < 10; i++) {
        console.log(`from f: ${i}`);
        await do_nothing();
    }
}

async function g () {
    for (let i = 0; i < 10; i++) {
        console.log(`from g: ${i}`);
        await do_nothing();
    }
}

f();
g();
```

`undefined`が返るだけの何もしない`async`関数`do_nothing`を`await`するコードが挿入されました。
結果は以下の通りです。

```text
from f: 0
from g: 0
from f: 1
from g: 1
from f: 2
from g: 2
from f: 3
from g: 3
from f: 4
from g: 4
from f: 5
from g: 5
from f: 6
from g: 6
from f: 7
from g: 7
from f: 8
from g: 8
from f: 9
from g: 9
```

`f`と`g`が切り替わっていることが確認できます。
マネージャーは`await`が呼ばれたタイミングを処理の「切れ目」として扱っているようです。

## 総括
`async`/`await`等平行処理を利用する際には、適切に管理者に渡す処理に「切れ目」を入れてあげる必要がありそうです。
こうしないと、別の処理にスイッチする処理がブロックされてしまい、平行処理で実現したかったことが壊れてしまうでしょう。

また、`python`の`asyncio`ではコルーチンの`await`では実行コンテキストが切り替わりません。
実行コンテキストが`Future`を`await`する必要があるそうです。
最も簡単な方法は、内部で`Future`を利用している`asyncio.sleep()`を利用することです。適宜`asyncio.sleep(0)`を挿入することでそのコルーチンを刻むことができます。

## 参考資料
- [python3 の async/awaitを理解する](https://qiita.com/maueki/items/8f1e190681682ea11c98) | qiita
- [asyncio --- 非同期 I/O](https://docs.python.org/ja/3/library/asyncio.html) | python公式doc
- [AsyncIO for the working PyGame programmer (part I)](https://blubberquark.tumblr.com/post/177559279405/asyncio-for-the-working-pygame-programmer-part-i) | Blubberquark Software
- [イメージで伝われ！図解JavaScriptの非同期処理](https://memowomome.hatenablog.com/entry/js_async_viz) | メモを揉め
- 私の曖昧な知識とそこから出てくる怪しい予想
