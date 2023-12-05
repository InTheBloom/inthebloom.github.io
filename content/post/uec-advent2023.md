---
title: はじめませんか？競技プログラミング + ミスりにくい二分探索 [UEC Advent Calendar 2023] 6日目
# description: 

date: 2023-12-05
draft: true
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - UEC Advent Calendar
archives:
  - 2023
  - 2023-12
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## まえがき

この記事は、
[電通大生による電通大生のためのUEC Advent Calendar 2023](https://adventar.org/calendars/8698)
の6日目担当です。

<iframe src="https://adventar.org/calendars/8698/embed" width="620" height="362" frameborder="0" loading="lazy" style="overflow: scroll;"></iframe>

5日目はトナカイさんによる、[BASHであそぼ](https://reindeeruec.hatenablog.com/entry/2023/12/05/000937)でした。
私もⅠ類の友人がいますが、彼は毎回提出コマンドを手打ちしていた記憶があります。
自動化スクリプトをbashでササッと組めるのすごく憧れるんですが、いつもbashを勉強する面倒臭さが勝ってしまいます。
私もいつの日か[退屈なことはpythonにやらせ](https://www.amazon.co.jp/%E9%80%80%E5%B1%88%E3%81%AA%E3%81%93%E3%81%A8%E3%81%AFPython%E3%81%AB%E3%82%84%E3%82%89%E3%81%9B%E3%82%88%E3%81%86-%E2%80%95%E3%83%8E%E3%83%B3%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9E%E3%83%BC%E3%81%AB%E3%82%82%E3%81%A7%E3%81%8D%E3%82%8B%E8%87%AA%E5%8B%95%E5%8C%96%E5%87%A6%E7%90%86%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0-Al-Sweigart/dp/487311778X)られるようになりたいです。

実はAdvent Calendarは公開後すぐに枠が埋まってしまったので、2枠目も存在します(なんで？)。

<iframe src="https://adventar.org/calendars/8704/embed" width="620" height="362" frameborder="0" loading="lazy" style="overflow: scroll;"></iframe>

5日目の牛田ウシタさんの記事はまだ公開されていないようですが、こちらもぜひ読んでみてはいかがでしょうか！

それではそろそろ本題に行きましょう。

## はじめに
こんにちは、こんばんは、おはようございます。
6日目を担当する、[In](https://twitter.com/UU9782wsEdANDhp)と申します。
去年に引き続き、今年も参加させていただきました。

今年は[去年のやつ](https://inthebloom.github.io/post/uec-advent2022/)
よりも実りのある記事がかければ良いなと思っております。よろしくおねがいします。

## 競技プログラミングとは何か？
<div style="border: 1px black solid; padding: 1em;">

> 競技プログラミング（きょうぎ - 、英: Competitive programming、略称: 競プロ）とは、プログラミングコンテストで行われる競技の一種である

> 競技プログラミングでは、参加者全員に同一の課題が出題され、より早く与えられた要求を満足するプログラムを正確に記述することを競う[1]。

(Wikipedia - [競技プログラミング](https://ja.wikipedia.org/wiki/%E7%AB%B6%E6%8A%80%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0) より)
</div>

簡単に言うと、競技プログラミングとは
「与えられる入力に対して条件を満たす出力をするプログラムを、できるだけはやく作る」
ことです。

名前のいかつさや近寄りがたさとは裏腹に、意外にシンプルなゲームになっています。
百聞は一見に如かずということで、例を挙げましょう。
次の問題は実際に競技プログラミングの問題として出題されたものです。

<div style="border: 1px black solid; padding: 1em">
<span style="font-size: 1.2em; font-weight: bold;">問題文</span>

$N$ 人の人 $1,2,\dots,N$ がある試験を受け、人 $i$ は $A_i$ 点を取りました。
この試験では、 $L$ 点以上を取った人のみが合格となります。
$N$ 人のうち何人が合格したか求めてください。

<span style="font-size: 1.2em; font-weight: bold;">制約</span>

- 入力はすべて整数
- $1 \leq N \leq 100$
- $1 \leq L \leq 1000$
- $0 \leq A_i \leq 1000$

<span style="font-size: 1.2em; font-weight: bold;">出力</span>

答えを整数として出力せよ。

<span style="font-size: 1.2em; font-weight: bold;">入力</span>

入力は以下の形式で標準入力から与えられる。

<script>
    document.addEventListener("DOMContentLoaded", function() {
        renderMathInElement(document.getElementById("problem"), {
          delimiters: [
              {left: '$$', right: '$$', display: true},
              {left: '$', right: '$', display: false},
              {left: '\\(', right: '\\)', display: false},
              {left: '\\[', right: '\\]', display: true}
          ],
          throwOnError : false
        });
    })
</script>

<pre id="problem" style="background: white; border: black 1px solid; font-size: 1.1em;">
$N$ $L$
$A_1$ $A_2$ $\dots$ $A_N$
</pre>

<span style="font-size: 1.2em; font-weight: bold;">入力例1</span>
<pre id="problem" style="background: white; border: black 1px solid; font-size: 1.1em;">
5 60
60 20 100 90 40
</pre>

(出典: [AtCoder Beginner Contest330 Problem A](https://atcoder.jp/contests/abc330/tasks/abc330_a))
</div>

この問題に対して、例えば次のようなコードが正解と判定されます。
```C
#include <stdio.h>

int main (void) {
    int N, L; scanf("%d%d", &N, &L);
    int A[N]; for (int i = 0; i < N; i++) scanf("%d", &A[i]);

    int ans = 0;
    for (int i = 0; i < N; i++) if (L <= A[i]) ans++;

    printf("%d\n", ans);
    return 0;
}
```
さて、正解であるというのはどのように判定されるのでしょうか？
ほとんどのプログラミングコンテストは、**オンラインジャッジ**を用いて判定を行います。

参加者は正しい出力をするであろうプログラムを作成したら、プログラミングコンテストの提供者側にソースコードを提出します。
提出されたコードはジャッジシステムによって(コンパイルと)実行され、
提供者が用意している**テストケース全てに対して**正しい出力をする時、正解であると判定されます。

上で紹介した解答プログラムを提出した結果が以下のリンクになります。

[提出](https://atcoder.jp/contests/abc330/submissions/48209615)

また、正解と判定される条件の中には
メモリの総使用量やプログラムの実行時間の制限もあります。
これらにより、間違った解法で解答するのは不可能あるいは非常に困難です。

### プログラミングコンテストについて
このような問題を1問以上集めて、大会が開かれることがあります。

参加者は同時に問題を公開されます。
他の人より多くの問題を解いたり、間違った解答が少なかったり、解答するまでの時間が早いとより上位になります。

これがプログラミングコンテスト及び競技プログラミングの中身です。
大体イメージをつかめていただけたでしょうか。

## 競技プログラミングをはじめるには
日本語で利用できる競技プログラミング(オンラインジャッジ)のサービスはいくつか存在します。

最大手なのが、[AtCoder](https://atcoder.jp/)社によるものです。

他にも次のようなものがあります。

- [yukicoder](https://yukicoder.me/)
- [AIZU ONLINE JUDGE](https://judge.u-aizu.ac.jp/onlinejudge/)
- [Library Checker](https://judge.yosupo.jp/)

日本語に限らなければ、他にもいくつもあります。

- [Codeforces](https://codeforces.com/)
- [TopCoder](https://www.topcoder.com/)
- [CodeChef](https://www.codechef.com/)
- [LeetCode](https://leetcode.com/)

他にもたくさんあると思います。

しかし、本当にはじめての方なら、

- 問題文が日本語で提供されている
- 低難易度の問題もたくさんある
- オンラインジャッジの対応言語が多い
- アクティブユーザーが非常に多い

などの理由から、AtCoderが最もハードルが低いと思います。
ちなみに、これだけ紹介しておいて私はAtCoderとyukicoderしか参加していません。

以下、AtCoderに限った話をします。

AtCoderに登録する方法や、画面の見方などは説明を省きます。
それらはそこまで複雑ではないし、検索するとすぐ出るからです。
ここからは、AtCoderがどのようなコンテンツを提供しているかを少しだけ紹介します。

### AtCoder Beginner Contest (通称: ABC)
土曜日21:00から100分間行われているコンテストです。
AtCoder社が提供するコンテストの中では、問題は比較的易しい傾向があり、最大で約10000人が参加します。

注意として、問題は易しいと書きましたが、"比較的"というだけで普通に難しい問題も出ます。

### AtCoder Regular Contest (通称: ARC)
現状定期開催ではありませんが、時々土曜または日曜日21:00から120分行われているコンテストです。
数学パズルのような問題が出題される傾向があります。
普通にゲキムズです。

### AtCoder Grand Contest (通称: AGC)
ARCより更に低頻度です。土曜または日曜日21:00から180分行われます。
天才以外お断りのパズルコンテストとか揶揄されることもあります。
私は全然歯が立ちません。

### 過去のコンテストで出題されたすべての問題
ABC、ARC、AGCで出題された問題はコンテスト終了後もオンラインジャッジを利用することができ、
24時間いつでも挑戦することができます。
基本的に私はいつもこれらの問題を解いています。

### レーティングシステム
上記3つのコンテストなどの成績によって、レートが変動します。

レートについてはAtCoderの社長による説明があります。
<iframe class="hatenablogcard" style="width:100%;height:155px;max-width:680px" src="https://hatenablog-parts.com/embed?url=https://chokudai.hatenablog.com/entry/2019/02/11/155904" width="300" height="150" frameborder="0" scrolling="no" ></iframe>


