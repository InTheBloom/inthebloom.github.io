---
title: ABC290E - Make it Palindrome
# description: 

date: 2023-12-31
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
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

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc290/tasks/abc290_e)

文字列$X$に対して、$f(X) = $($X$を回分にするために変更する必要のある要素の個数の最小値)と定める。
長さ$N$の数列$A$が与えられるので、$A$のすべての**連続部分列**の集合$X$として、
$\sum_{x \in X} f(x)$を求めよ。

### 制約
- $1 \leq N \leq 2 \times 10^5$
- $1 \leq A_i \leq N$

## 解法
すべての連続部分列は$O(N^2)$個ある。
なぜなら、連続部分列を1つ決めることは端点を2つ決めることと等価であるからであり、
端点を2つ決める組み合わせの数は$\binom{N}{2}$通りであるからである。

一つの連続部分列は長さ$O(N)$であるため、全探索は$O(N^3)$となり、当然間に合わない。

そこで、主客転倒してみよう。(言葉の使い方があってるか不安)
ある$(A_i, A_j)$ペアに着目した時、これらが一致する必要のあるような連続部分列は**何通り取れるのか**を考える。

次に、具体例を挙げる。
2つのOが$A_i$と$A_j$だと考えれば良い。
<pre>
____O____O___
</pre>
まず、これらが端点の連続部分列を取れば良い。連続部分列の端点をXで示す。
<pre>
____X____X___
</pre>
他にもこういうとり方もできる。
<pre>
___XO____OX__
</pre>
これでも良い。
<pre>
__X_O____O_X_
</pre>

というわけで、問題の答えは「$\min{} (i, N-j+1)$通り取れる」となる。(1-indexed)

O(N)は通るので、左側の項を列挙することにする。
すなわち、任意の$(A_i, A_j)$に対して考えたいが、
とりあえず$A_i$は固定して、$i$より大きな$j$に対する$A_j$の寄与を考えるというわけだ。
1つ左端$A_i$をとった時、「各項が何回一致する必要があるか」は、次のようになる。

<pre>
___O______
    4444321
</pre>

というわけで、とりあえず$O(N^2)$解を得ることが出来た。
$A_i$と$A_j$が一致するならスキップ、そうでないなら$\min{} (i+1, N-j)$(0-indexed)を足し込んでいく感じで解ける。
実装例は次のような感じ。
```d
long ans = 0;
foreach (i; 0..N) {
    foreach (j; i+1..N) {
        if (A[i] != A[j]) {
            ans += min(i+1, N-j);
        }
    }
}
```

当然まだ通らないので、これを高速化しよう。
問題を解くには、「ある区間に何個分$x$があるのか？」みたいなのを管理できれば良さそうである。
これをセグメントツリーで管理する。
ただし、右端の「4321」みたいになってるところがキモいので、これと「4444」みたいに一定値になってる部分を分けてセグメントツリー2本で管理することにする。

わかりにくいと思うので、もう少し言語化する。
セグメントツリーの最下段を$N$要素確保して、最下段の$i$番目の値を「今見てる区間に$i$は何個あるか？」を管理することにする。
こうすれば、(総和)-(区間の左端の値が何個あるか)を計算することで
「固定した左端の要素を変更する必要のあるような連続部分列のとり方」を数え上げられるという仕組みになっている。

まだイメージがわかない人は実装例を見てほしい...と言いたかったのだが、実装が厳しすぎておよそ人の読めるようなものではなくなってしまった。
どうしてもインデックスが合わなくて、偶奇で分けて、プリントと$O(N^2)$と合わせながら頑張って実装した。

もっとスマートなやり方はいくらでも紹介されてるので、そちらを参照したほうが良いだろう。(自分もそうする。)

## 提出
努力の証拠ということで一応貼り付けておく。
解法自体はすぐわかったものの、問題とは3日以上向き合った気がする。
多分$O(N \log N)$

```d
import std;

void main () {
    /*
       主客転倒して、A[i]がどこと何回一致判定されるかを考える。
       すると、min(右側の幅, 左側の幅)を考えれば良いことがわかり、セグ木2本持っておくとよい。
     */

    int N = readln.chomp.to!int;
    int[] A = readln.split.to!(int[]);
    A[] -= 1;

    long ans;
    if (N % 2 == 0) {
        ans = solveEVEN(N, A);
    }
    else {
        ans = solveODD(N, A);
    }

    writeln(ans);
}

long solveEVEN (int N, int[] A) {
    auto M = new SegmentTree!(long, (long a, long b) => a+b, () => 0L)(N);
    auto R = new SegmentTree!(long, (long a, long b) => a+b, () => 0L)(N);
    long ans = 0;

    for (int i = N-1; N/2 <= i; i--) {
        R.set(A[i], R.get(A[i]) + N-i);
    }

    /* 右に進む */
    for (int i = N/2-1, j = 0; i < N-1; i++, j++) {
        ans += R.prod(0, N) - R.get(A[i]);
        R.set(A[i+1], R.get(A[i+1]) - (N/2-j));
    }

    /* セット */
    foreach (i; 0..N) R.set(i, 0);
    for (int i = N-1; N/2+1 <= i; i--) {
        R.set(A[i], R.get(A[i]) + N-i);
    }

    M.set(A[N/2], M.get(A[N/2]) + 1);
    M.set(A[N/2-1], M.get(A[N/2-1]) + 1);

    for (int i = N/2-2, j = 0; 0 <= i; i--, j++) {
        ans += (i+1) * (M.prod(0, N) - M.get(A[i]));
        ans += R.prod(0, N) - R.get(A[i]);

        R.set(A[N/2+1+j], R.get(A[N/2+1+j]) - (i+1));
        M.set(A[N/2+1+j], M.get(A[N/2+1+j]) + 1);
        M.set(A[i], M.get(A[i]) + 1);

    }

    return ans;
}

long solveODD (int N, int[] A) {
    auto M = new SegmentTree!(long, (long a, long b) => a+b, () => 0L)(N);
    auto R = new SegmentTree!(long, (long a, long b) => a+b, () => 0L)(N);
    long ans = 0;

    for (int i = N-1; N/2 < i; i--) {
        R.set(A[i], R.get(A[i]) + N-i);
    }

    /* 右に進む */
    for (int i = N/2, j = 0; i < N-1; i++, j++) {
        ans += R.prod(0, N) - R.get(A[i]);
        R.set(A[i+1], R.get(A[i+1]) - (N/2-j));
    }

    /* セット */
    foreach (i; 0..N) R.set(i, 0);
    for (int i = N-1; N/2 < i; i--) {
        R.set(A[i], R.get(A[i]) + N-i);
    }
    M.set(A[N/2], M.get(A[N/2]) + 1);

    for (int i = N/2-1, j = 0; 0 <= i; i--, j++) {
        ans += (i+1) * (M.prod(0, N) - M.get(A[i]));
        ans += R.prod(0, N) - R.get(A[i]);

        R.set(A[N/2+1+j], R.get(A[N/2+1+j]) - (i+1));
        M.set(A[N/2+1+j], M.get(A[N/2+1+j]) + 1);
        M.set(A[i], M.get(A[i]) + 1);
    }

    return ans;
}
```
流石に長いのでセグメントツリーの実装は省略した。

## 感想
死ぬほど苦戦して、かなり自信を失った気がする。
次解くときはもっとスマートな解法でやりたいと思う。
