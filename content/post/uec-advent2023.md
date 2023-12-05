---
title: ミスりにくい二分探索 [UEC Advent Calendar 2023] 6日目
# description: 

date: 2023-12-05
lastmod: 2023-12-06
# hidedate: true

ogimage: https://res.cloudinary.com/dqoqdn2sk/image/upload/v1701781533/pictures/uecadvent2023/ogp_rxkpup.png

tags:
  - UEC Advent Calendar
  - アルゴリズム
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

<style>
details {
    padding: 1em;
    background: white;
}
</style>

## まえがき

この記事は、
[電通大生による電通大生のためのUEC Advent Calendar 2023](https://adventar.org/calendars/8698)
の6日目担当です。

<span style="font-size: 1.1em; color: red;">2時間ほど遅刻しました！すみません！</span>

<iframe src="https://adventar.org/calendars/8698/embed" width="620" height="362" frameborder="0" loading="lazy" style="overflow: scroll;"></iframe>

5日目はトナカイさんによる、[BASHであそぼ](https://reindeeruec.hatenablog.com/entry/2023/12/05/000937)でした。
私もⅠ類の友人がいますが、彼は毎回提出コマンドを手打ちしていた記憶があります。
自動化スクリプトをbashでササッと組めるのすごく憧れるんですが、いつもbashを勉強する面倒臭さが勝ってしまいます。
私もいつの日か[退屈なことはpythonにやらせ](https://www.amazon.co.jp/%E9%80%80%E5%B1%88%E3%81%AA%E3%81%93%E3%81%A8%E3%81%AFPython%E3%81%AB%E3%82%84%E3%82%89%E3%81%9B%E3%82%88%E3%81%86-%E2%80%95%E3%83%8E%E3%83%B3%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9E%E3%83%BC%E3%81%AB%E3%82%82%E3%81%A7%E3%81%8D%E3%82%8B%E8%87%AA%E5%8B%95%E5%8C%96%E5%87%A6%E7%90%86%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0-Al-Sweigart/dp/487311778X)られるようになりたいです。

実はAdvent Calendarは公開後すぐに枠が埋まってしまったので、2枠目も存在します(なんで？)。

<iframe src="https://adventar.org/calendars/8704/embed" width="620" height="362" frameborder="0" loading="lazy" style="overflow: scroll;"></iframe>

5日目の牛田ウシタさんの記事は<span style="text-decoration: line-through;">まだ公開されていないようですが、こちらもぜひ読んでみてはいかがでしょうか！</span>

本記事を書いている間に更新されていました。
アドカレを書くためにいきなり22万吹き飛んでいて笑いました。
長期間の出来事が詳細に語られていて、臨場感がありました。私が文章書くと臨場感が死ぬので、すごいなぁ。。

私は関西に住んでいた経験があるため、いくつか知っているポイントがあったのが面白かったです。(京都のデカい階段、奈良の穴とか)

それではそろそろ本題に行きましょう。

## はじめに
こんにちは、こんばんは、おはようございます。
6日目を担当する、[In](https://twitter.com/UU9782wsEdANDhp)と申します。
去年に引き続き、今年も参加させていただきました。

今年は[去年のやつ](https://inthebloom.github.io/post/uec-advent2022/)
よりも実りのある記事がかければ良いなと思っております。よろしくおねがいします。

## 二分探索とは
本記事では、競技プログラミングでよく使うかつ、割とバグらせやすいと思っているアルゴリズムである二分探索の
比較的バグらせにくい実装を紹介します。

なお、厳密性を欠いていたり、不正確な情報があるかもしれません。
もしまずい場所があれば指摘していただけると助かります。

まずは、本記事において「二分探索」が何を指すのかをはっきりさせておきましょう。

<div style="border: 1px black solid; padding: 1em;">
<span style="font-weight: bold; font-size: 1.2em;">二分探索で出来る事</span>

関数$f: \mathbb{Z} \rarr \\{0, 1 \\}$であって、次の性質を満たすものを考える。

1. $f(x)=0$を満たす$x \in \mathbb{Z}$が少なくとも一つ以上存在する。
2. $f(y)=1$を満たす$y \in \mathbb{Z}$が少なくとも一つ以上存在する。
3. 次のどちらか片方のみが成立している。
  - $x \leq y \Rightarrow f(x) \leq f(y)$
  - $x \geq y \Rightarrow f(x) \leq f(y)$

$f(a)=0$、$f(b)=1$を既知として、任意の$\mathbb{Z}$の元に対して$f$の値を時間計算量$\alpha$で求められるとする。
この時、$f(x) \neq f(x+1)$なる$x$を時間計算量$O(\alpha \log{|a-b|})$で求める。
</div>

状況はこんな感じです。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1701781532/pictures/uecadvent2023/graph_yhyxig.png)

二分探索の動作原理はいたってシンプルです。
最初、$a$と$b$の中点$c$をとります。
具体的には、$c = \lfloor \frac{a+b}{2} \rfloor$とします。

仮定より、関数$f$の値はある一点で$0$と$1$が切り替わり、それ以外の場所で変化しません。
ゆえに、もし$f(c)=0$であったとすると、必ず$a \leq c \leq x$であることがいえ、そうでない時は$x+1 \leq c \leq b$が言えます。

$f(c)$の値によって区間の端点$a$か$b$を$c$で置き換えます。これを繰り返します。

結果的に、$f(a)=0$と$f(b)=1$を保ったまま、$|b-a|=1$となるまで区間を縮めることができます。

時間計算量を考えましょう。
区間の端点を一度置き換えるごとに区間の長さはおよそ$\frac{1}{2}$になります。
したがって、アルゴリズムが停止するまでに繰り返される回数は、
$$
\begin{equation\*}
    \begin{split}
        \frac{|b-a|}{2^x} &= 1 \\\\
        |b-a| &= 2^x \\\\
    \end{split}
\end{equation\*}
$$
より、$x = \log_2{|b-a|}$となり、$O(\log{|b-a|})$回程度である事がわかります。

## 実装の詳細
競技プログラミング界隈で「めぐる式二分探索」と呼ばれる実装があります。

<blockquote class="twitter-tweet" data-media-max-width="560"><p lang="ja" dir="ltr">【めぐるのアルゴリズム講座】<br>二分探索（整数）の書き方<br>難しさ：４ <a href="https://t.co/LGLbkS0D7l">pic.twitter.com/LGLbkS0D7l</a></p>&mdash; 因幡めぐる@競技プログラミング (@meguru_comp) <a href="https://twitter.com/meguru_comp/status/697008509376835584?ref_src=twsrc%5Etfw">February 9, 2016</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

これをベースにやっていきます。

まず、めぐる式二分探索とは、次のような実装です。
```D
long ok = 0, ng = x;
while (1 < abs(ok-ng)) {
    long mid = (ok+ng) / 2;
    if (f(mid)) {
        ok = mid;
    }
    else {
        ng = mid;
    }
}
```

この実装では、`while`の条件式が`1 < abs(ok-ng)`になっています。
このおかげで、`ok`と`ng`の大小関係に気を配らなくてよくなります。

関数$f$の実装と二分探索のアルゴリズム部分を分けているのも特徴的です。
これによって、
- 初期値`ok`及び`ng`の設定
- 関数$f$の内部実装

さえきちんとできていれば、あとはボイラープレートとして扱えるという利点があります。
基本はこれ一本ですべてうまくいきます。

ということで、ここからは関数$f$の設計と初期値の設定に注力しましょう。

## 関数$f$の設計

関数の設計は、二分探索で最も重要な部分です。
ここをミスったらどうやってもバグります。

関数の設計で気を付けることは**ただ一つ**です。

<span style="font-size: 1.5em; color: red;">必ず$f(x)=0$及び$f(y)=1$なる$x$、$y$が存在するようにしてください。</span>

当たり前だろ。と思った方、意外にも見落とすことがあるので、本当に気を付けたほうがいいです。
配列の探索や、ちょっと変則的な関数から$f$を作る場合、定義域が知らぬ間に制限されることがあります。

このような場合、定義域の外まで定義域を拡張して回避するテクニックがあります。あとで触れます。

## 初期値の設定

初期値の設定は、$f$をうまく構成できたことを確認してから行いましょう。
初期値の設定に落とし穴は少ないです。
- `ok`が区間のどちら側か？
- $f$の中で計算するとき、`ok`、`ng`はオーバーフローしないか？
- 本当に$f(\mathrm{ok}) \neq f(\mathrm{ng})$が成立しているか？(もっと初期値を大きく/小さくとる必要があるか？)

あたりを調べれば、経験上大体うまくいきます。

## 練習問題
いくつか練習問題を用意しました。
要は習うより慣れろってことです。

解説も用意してみました。ぜひ見てみてください。

### Q1: 年齢あてゲーム
<span style="font-size: 1.1em; font-weight: bold;">問題</span>

あなたは相手に、「年齢は$x$歳以上ですか？」と何回でも質問できます。
なるべく少ない回数で年齢を当てましょう。

<span style="font-size: 1.1em; font-weight: bold;">制約</span>

- $0 \leq (相手の年齢) \leq 10^{18}$

<details>
<summary>解答</summary>

$$
\begin{equation\*}
f(x) =
\begin{cases}
1 & \text{if ($x$に対する質問の答えがYes),} \\\\
0 & \text{if ($x$に対する質問の答えがNo).}
\end{cases}
\end{equation\*}
$$

とすれば、$f$として満たすべき性質を満足します。
よって、次のような解答ができます。

```D
bool f (long x) {
    return ask(x); // ask: long -> bool を暗黙に仮定
}

long ok = 0, ng = 10L^^18+1;

while (1 < abs(ok-ng)) {
    long mid = (ok+ng) / 2;
    if (f(mid)) {
        ok = mid;
    }
    else {
        ng = mid;
    }
}

writeln("age = ", ok);
```
図にするとこうです。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1701786478/pictures/uecadvent2023/Q1_fs3byp.png)

- ポイント: $f$の構成は簡単ですが、`ok`を左端にすること、`ng`の初期値に注意が必要です。
</details>

### Q2: LowerBound

<span style="font-size: 1.1em; font-weight: bold;">問題</span>

$N$要素の配列$A$が与えられる。ここで、$i < j \Rightarrow A[i] < A[j]$が保証される。
$A$の要素であって、$x$以上のものの集合$B$を考える。すなわち、$B = \\{a \in A | x \leq a \\}$である。
$B$の最小要素を求めよ。$B = \emptyset$である場合はその旨を報告せよ。


<span style="font-size: 1.1em; font-weight: bold;">制約</span>

- $1 \leq N \leq 2 \times 10^5$
- $0 \leq i \leq N-1$に対して、$-10^9 \leq A[i] \leq 10^9$
- $-10^9 \leq x \leq 10^9$

<details>
<summary>解答</summary>

$$
\begin{equation\*}
f(i) =
\begin{cases}
0 & \text{if $i < 0$,} \\\\
0 & \text{if $A[i] < x$,} \\\\
1 & \text{if $x \leq A[i]$} \\\\
1 & \text{if $N \leq i$} \\\\
\end{cases}
\end{equation\*}
$$

と定めれば、二分探索に使える関数になります。
範囲外参照をしている場合は右側にはみ出していれば$1$とし、左側にはみ出している場合は$0$としています。

この関数を用いて二分探索することで、$x \leq A[i]$なる最小の$i$を見つけることができます。
$i = N$であれば$B = \emptyset$を判定できます。

なぜ範囲外に対しても値を定義しているかというと、$A$の要素がすべて$x$未満であったり、すべて$x$以上であることがあり得るからです。
この工夫をしないと、変な場合分けをする必要が出てきます。

```D
bool f (int i) {
    if (i < 0) return false;
    if (N <= i) return true;
    return x <= A[i];
}

int ok = N, ng = -1;
while (1 < abs(ok-ng)) {
    int mid = (ok+ng) / 2;
    if (f(mid)) {
        ok = mid;
    }
    else {
        ng = mid;
    }
}

if (ok == N) {
    writeln("B is empty");
}
else {
    writeln(A[ok]);
}
```

図にするとこんな感じです。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1701787921/pictures/uecadvent2023/Q2_vfypat.png)
</details>

### Q3 (Advanced Problem): ABC309C - Medicine

<span style="font-size: 1.1em; font-weight: bold;">問題</span>

高橋君は医者のすぬけ君から$N$種類の薬を処方されました。$i$種類目の薬は(処方された日を含めて)$a_i$日間、毎日$b_i$錠ずつ飲む必要があります。また、高橋君はこれ以外の薬を飲む必要がありません。

薬を処方された日を$1$日目とします。$1$日目以降で、初めて高橋君がその日に飲む必要がある薬が$K$錠以下になるのは何日目かを求めてください。

<span style="font-size: 1.1em; font-weight: bold;">制約</span>

- $1 \leq N \leq 3 \times 10^5$
- $0 \leq K \leq 10^9$
- $1 \leq a_i, b_i \leq 10^9$

出典: [AtCoder Beginner Contest 309 - C](https://atcoder.jp/contests/abc309/tasks/abc309_c)

この問題は二分探索に帰着するまでに考察が必要です。
頭の体操のつもりで考えてみましょう！
(解けなくても心配しないでください。問題を楽しみましょう！)

<details>
<summary>解答</summary>

$x$日目に処方される薬の数は、
$$
\sum_{\substack{1 \leq i \leq N \\\\ x \leq a_i}} b_i
$$
で求めることができます。
プログラム的には、
```D
long sum = 0;
for (int i = 0; i < N; i++) {
    if (x <= A[i]) sum += B[i];
}
```
という感じです。

制約から、この値は$x=1$の時最大値をとり、そこから広義単調減少することがわかります。
この性質から、この値が$K$以下になるか？を判定する関数$f$が二分探索の条件を満たしそうだと分かります。

また、$s(x)$を計算するのに$O(N)$しか必要としないため、これまた二分探索で解けそうな雰囲気があります。

結論から言うと、次の関数を用いることで二分探索可能になります。

$$
s(x) \coloneqq \sum_{\substack{1 \leq i \leq N \\\\ a_i \leq x}} b_i
$$
とするとき、
$$
\begin{equation\*}
f(x) =
\begin{cases}
0 & \text{if $K < s(x)$} \\\\
1 & \text{if $s(x) \leq K$,} \\\\
\end{cases}
\end{equation\*}
$$

解答は以下の通りです。

```D
import std;
import core.stdc.stdio;

void main () {
    /* 入力 */
    int N, K; scanf("%d%d", &N, &K);
    int[] a = new int[](N);
    int[] b = new int[](N);

    for (int i = 0; i < N; i++) scanf("%d%d", &a[i], &b[i]);

    /* sの定義 */
    long s (int x) {
        long ret = 0;
        for (int i = 0; i < N; i++) if (x <= a[i]) ret += b[i];
        return ret;
    }

    /* fの定義 */
    bool f (int x) {
        return s(x) <= K;
    }

    int ok = 10^^9+1, ng = 0;
    while (1 < abs(ok-ng)) {
        int mid = (ok+ng) / 2;
        if (f(mid)) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }

    writeln(ok);
}
```

時間計算量は$O(N \log{(\max{a_i})})$になります。
また、この問題は二分探索以外の解法もあります。
</details>

### Q4 (Advanced Problem): ABC312C - Invisible Hand

<span style="font-size: 1.1em; font-weight: bold;">問題</span>

りんご市場に$N$人の売り手と
$M$人の買い手がいます。

$i$番目の売り手は、
$A_i$円以上でならりんごを売ってもよいと考えています。

$i$番目の買い手は、
$B_i$円以下でならりんごを買ってもよいと考えています。

次の条件を満たすような最小の整数
$X$を求めてください。

条件：りんごを
$X$円で売ってもよいと考える売り手の人数が、りんごを $X$円で買ってもよいと考える買い手の人数以上である。

<span style="font-size: 1.1em; font-weight: bold;">制約</span>

- $1 \leq N, M \leq 2 \times 10^5$
- $1 \leq A_i, B_i \leq 10^9$

出典: [AtCoder Beginner Contest 312 - C](https://atcoder.jp/contests/abc312/tasks/abc312_c)

こちらもAtCoderから引っ張ってきました。
ちなみに私はこの問題の読解で詰まって本番で苦しみまくりました。

<details>
<summary>解答</summary>
りんごを$X$円で売ってよいと考える売り手の人数$P(X)$は、次のように求められます。
$$
P = \sum_{\substack{1 \leq i \leq N \\\\ A_i \leq X}} 1
$$
りんごを$X$円で買ってよいと考える買い手の人数$Q(X)$は、次のように求められます。
$$
Q = \sum_{\substack{1 \leq i \leq M \\\\ X \leq B_i}} 1
$$

問題は、$Q(X) \leq P(X)$を満たす最小の$X$を求めよというものです。
ここで、$P(X)$、$Q(X)$の性質を利用します。

$P(X)$は、$X$に対して広義単調増加し、$Q(X)$は広義単調減少することがわかります。
すなわち、不等式$Q(X) \leq P(X)$はある値を境目に「それ以上なら常に成立」、「それ未満なら常に不成立」となることがわかります。

これらの考察から、二分探索できそうな感じがします。

実際に$P(X)$及び$Q(X)$を1回求めるのに$O(N)$時間しか必要としないため、うまくいきそうです！

解答例を示します。
```D
import std;
import core.stdc.stdio;

void main () {
    /* 入力を受け取る */
    int N, M; scanf("%d%d", &N, &M);
    int[] A = new int[](N);
    int[] B = new int[](M);

    for (int i = 0; i < N; i++) scanf("%d", &A[i]);
    for (int i = 0; i < M; i++) scanf("%d", &B[i]);

    /* P(X) */
    int P (int X) {
        int ret = 0;
        for (int i = 0; i < N; i++) if (A[i] <= X) ret++;
        return ret;
    }

    /* Q(X) */
    int Q (int X) {
        int ret = 0;
        for (int i = 0; i < M; i++) if (X <= B[i]) ret++;
        return ret;
    }

    /* f(X) */
    bool f (int X) {
        return Q(X) <= P(X);
    }

    int ok = 10^^9+1, ng = 0;
    while (1 < abs(ok-ng)) {
        int mid = (ok+ng) / 2;
        if (f(mid)) {
            ok = mid;
        }
        else {
            ng = mid;
        }
    }

    writeln(ok);
}
```
時間計算量は$O(N \log{(\max{(\max{A}, \max{B})})})$となります。

解きなおしてるときにまたWA出してしまった...
この問題苦手です。
</details>

## 終わりに
これで記事はおしまいです。
ここまで読んでいただきありがとうございました。

二分探索は、(最近は比較的マシになってきましたが)私がずっっっっと苦手としているアルゴリズムで、いつか自分の理解をまとめたいと思っていました。
良い機会だと思って思い切って書いてみましたが、正直うまくまとめられなかった感を感じています。

もし本記事を読んで、「全然わからん！」と思った方がいれば、多分私の理解や説明が甘いせいです。すみません。
一方で、もし誰かの理解の助けになればうれしいです。

もし本記事に指摘、感想等いただけるなら、[Twitter](https://twitter.com/UU9782wsEdANDhp)の方までお願いします。

明日(12月7日)はみのさんによる、「2023年度財政状況報告」と、あかあくさんによる「アニメオタクのためのサイトを作った」です。
興味深いタイトルですね。
更新が楽しみです。

それではよい二分探索ライフを！
