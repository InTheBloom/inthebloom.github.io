---
title: UECCPバーチャルコンテストを発起し、完走した
# description: 

date: 2024-08-08
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - UECCP
archives:
  - 2024
  - 2024-08
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## UECCPバーチャルコンテストについて
私が電通大競プログラミングサークルに呼びかけて、4月から8月までAtCoder Problemsを利用したバーチャルコンテストを週1回開催しました。
某H先生のご厚意により、競プロサークルで利用できる教室があったため、そこをオンサイト会場(笑)として利用しました。
4月22日から8月5日まで合計13回開催しました。

- [第一回](https://kenkoooo.com/atcoder/#/contest/show/30ab495f-efd8-4df2-8d53-09f4f11b06ef)
- [第二回](https://kenkoooo.com/atcoder/#/contest/show/bfed3120-7020-4f28-974a-187a9a085203)
- [第三回](https://kenkoooo.com/atcoder/#/contest/show/5d46636a-1982-4f9f-8a64-2a7ab1c1eb6b)
- [第四回](https://kenkoooo.com/atcoder/#/contest/show/ed11c3d5-23fa-4891-908d-685cf51c31d5)
- [第五回](https://kenkoooo.com/atcoder/#/contest/show/bbe612d2-00fc-4cc9-8757-4d3017fdb5c4)
- [第六回](https://kenkoooo.com/atcoder/#/contest/show/d9949f2e-1713-4c7b-a5fa-74d7ec73056a)
- [第七回](https://kenkoooo.com/atcoder/#/contest/show/10f4601b-623a-4761-9b67-65ff6d2003c6)
- [第八回](https://kenkoooo.com/atcoder/#/contest/show/590a5683-675a-4639-83e7-6c1bdc235ac5)
- [第九回](https://kenkoooo.com/atcoder/#/contest/show/47b86b38-9035-4fca-9f69-c4564bdc36e8)
- [第十回](https://kenkoooo.com/atcoder/#/contest/show/94dfd432-d91e-46f3-a5ad-223513926de5)
- [第十一回](https://kenkoooo.com/atcoder/#/contest/show/395b2257-abc2-4a1b-8d19-aadb9d3d2b14)
- [第十二回](https://kenkoooo.com/atcoder/#/contest/show/92450648-ec22-4f68-b09c-1b59618789ff)
- [第十三回](https://kenkoooo.com/atcoder/#/contest/show/24fefab0-d4c1-4640-ae6e-5476424fede2)

## まえがき
本エントリでは、しばらくのあいだUECCPバーチャルコンテストを定期開催して感じたことなど適当に書こうと思います。

## きっかけ
せっかくUECCPという形で有志が集まっているのだから、なにか競技プログラミングの定期イベント的なものがあれば嬉しいなとずっと思っていました。
2023年前期はsepa\_38さんが声掛けをして、ABC振り返り回的なものを行っていました。
しかし、その集まりも前期終盤になってなあなあで消滅してしまったりと、アクティブに活動する方は多くないという印象がありました。
こういった事情で、私がやりたいことは私が始めるしか無いなと思い、一念発起してみました。

私は競技プログラミングの話をするだけでも十分に楽しいので、あまりやることを固めていませんでした。
今になって思えばそんな集まり誰が来たいんだよという感じがあるので、バーチャルコンテストをやることにして正解でした。バーチャルコンテストを提案してくれたdyktr\_06さんに感謝です。

## 実際に行ってみて
初回は物珍しさ + 学期はじめでスケジュールが楽な人が多かった(?)ため、沢山の人が参加してくれました。そのため椅子が足りなくなり、私は膝立ちでプログラムを書いていました。膝、めちゃくちゃ痛かったです。
所属「The University of Electro-Communications」で順位表によくいる人に実際に合ってお話する機会にもなりました。

第二回以降は人数も落ち着いて、だいたい同じ人が参加するようになりました。幸運なことに、私とレート帯の近い方がよく参加してくれたため、特にお話していて楽しかったです。

途中からdyktr\_06さんにより[UECCP Viewer](https://dyktr06.work/ueccp/)という各回の結果を見れるツールが開発されました。(スゴイ)

## 終わっての感想
全体的にやってよかったなと思います。他の競技プログラミング勢とお話することは、私にとってとても新鮮で、毎週の楽しみでした。
しばらくは同じ部屋を利用させていただけそうな感じがするので、できるだけずっと開催したいと思います。
参加していただいた皆さん、ありがとうございました。またお願いします。

## 各回で一番好きな問題
- 第一回

    [ABC281E - Least Elements](https://atcoder.jp/contests/abc281/tasks/abc281_e)

    Priority sumという興味深いアルゴリズムを適用できる問題です。全順序と加法のような二項演算の定まった要素の集合において、順序の(高い/低い)順に先頭$K$個の和を求めることができます。いい感じの平衡二分木を使えば都度$K$を変更することもできます。整数しか扱わないといった制約をいくつか入れると、より簡単に$K$を変更できるようになります。

- 第二回

    [ABC281D - Max Multiple](https://atcoder.jp/contests/abc281/tasks/abc281_d)

    迷いましたがこれにしました。私が競技プログラミングをはじめた頃に出題されて、わから無さすぎて困った思い出の問題です。典型的な取る/取らないdpとして解釈できます。この問題から多くを学びました。

- 第三回

    [ABC277E - Crystal Switches](https://atcoder.jp/contests/abc277/tasks/abc277_e)

    グラフ多重化典型で解くことができます。この手の問題は自力で解法にたどり着くのが非常に難しいと考えています。私がグラフ探索の可能性を感じ始めた思い出の一問です。

- 第四回

    [ABC188E - Peddler](https://atcoder.jp/contests/abc188/tasks/abc188_e)

    dpについて考えるきっかけをくれた問題です。[陽なDAG上のdpを楽に処理する](/post/dp-in-explicit-dag/)はこの問題の解法に感動したのがきっかけで書きました。

- 第五回

    [ABC132D - Blue and Red Balls](https://atcoder.jp/contests/abc132/tasks/abc132_d)

    組み合わせや場合の数に関する知識が問われる問題です。高校時代に非常に苦手だったジャンルですが、このような問題を解くうちに少しずつお気持ちがわかってきています。

- 第六回

    [ABC298E - Unfair Sugoroku](https://atcoder.jp/contests/abc298/tasks/abc298_e)

    確率/期待値の知識が問われる問題です。この手の問題は未だに苦手ですが、多分競技プログラミングで最も「数学」な部分なのでつい頑張って考えてしまいます。
    好きではないですが、一番思い出深いということでここにあげました。

- 第七回

    [キーエンスプログラミングコンテスト2021C - Robot on Grid](https://atcoder.jp/contests/keyence2021/tasks/keyence2021_c)

    バーチャルコンテストではじめて出会ったタイプの問題でした。解釈は2通りあります。ロボットの移動経路が何通りあるかの期待値を考える方法と、一つの経路からの主客転倒により数え上げる方法です。このタイプの問題についての解法はまだ自分の中に確立した理論がありませんが、この2通りの解釈はほぼ等価なのではないかという予想をしています。

- 第八回

    [ABC257C - Robot Takahashi](https://atcoder.jp/contests/abc257/tasks/abc257_c)

    difficultyの割に難しいと思っています。問題分の正確な理解とシンプルな実装方針を取れるかによって体感難易度が大きく変化します。間違いなく良問です。

- 第九回

    [ABC317E - Avoid Eye Contact](https://atcoder.jp/contests/abc317/tasks/abc317_e)

    解法自体はすっと見える人が多そうですが、きちんとACを得るには正確かつ高速な実装が要求されます。
    下手な実装だと実行時間制限がかなり厳しくなりそうです。
    グリッドの下処理は4方向でやってしまうのが良いという謎の典型でもあります。

- 第十回

    [ARC127A - Leading 1s](https://atcoder.jp/contests/arc127/tasks/arc127_a)

    桁dpとして解くことができます。この問題を考察しているうちに、桁dpへの理解が非常に深まりました。これまで私は桁dpを蛇蝎のごとく嫌っていましたが、この問題を通して好きになりかけています。

- 第十一回

    [ARC114A - Not coprime](https://atcoder.jp/contests/arc114/tasks/arc114_a)

    ARCらしい発想の転換が必要な問題です。$X$側から$Y$を構築するのは難しそうなので、$X _ i \leq 50$の制約をうまく利用して解きます。

- 第十二回

    [ABC240F - Sum Sum Max](https://atcoder.jp/contests/abc240/tasks/abc240_f)

    累積和の累積和という非常にややこしいものについて考える必要があります。累積和が最大値を取るときとはどのような時であるかを丁寧に考察する必要があります。
    実装も方針によっては簡単に破滅してしまう問題なので、十分な経験と自力が必要です。
    ちなみに、累積累積和に$x _ i$がどのように関与するかの絵を書くと解きやすいです。

- 第十三回

    [ABC266F - Well-defined Path Queries on a Namori](https://atcoder.jp/contests/abc266/tasks/abc266_f)

    なもりグラフの閉路を成す頂点集合を列挙するという典型問題が解ければ比較的簡単です。
    functional graphと異なり、強連結成分分解を振り回せないので少し面倒です。
    こちらも実装方針をちゃんと選ばないと実装が爆発しがちです。

以上です。ぜひ解いてみてください。
このリスト書くのに1時間くらいかかりました。疲れた...
