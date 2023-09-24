---
title: ABC202D - aab aba baa
# description: 

date: 2023-09-24
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
  - 典型テク
  - 辞書順
archives:
  - 2023
  - 2023-09
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc202/tasks/abc202_d)

A個の`a`とB個の`b`からなる文字列であって、辞書順でK番目のものを求めよ。

制約
- 1 <= A, B <= 30
- 辞書順でK番目の文字列が存在する。

## 解法
まず、問題文の条件を満たす文字列は$\displaystyle\frac{(A+B)!}{A!B!}$通り存在する。
これは、単にA+B個を並べたものからAの重複とBの重複を除いたものである。
また、これは二項係数$\displaystyle\binom{A+B}{A} = \binom{A+B}{B}$でもあり、
A+B個の枠のうち、AかBを入れる場所を決めれば文字列が一つ定まると解釈することもできる。

制約下で最も種類数が多くなるのはA=B=30のときで、これは$\displaystyle\frac{60!}{30!30!} = \binom{60}{30} = 118264581564861424$通りである。
したがって、文字列をすべて列挙して解くことはできない。

そこで、先頭からどの文字を使うかを決めていくことを考える。
ちなみにこれは辞書順を考えるときの典型テクニックらしいので、ある程度パターンマッチングとして選択肢に入れておくようにすると良いかもしれない。

先頭にaを入れた時を考える。
このとき、残るA-1個の`a`とB個の`b`で作ることができる文字列の種類は$\displaystyle\binom{A+B-1}{A-1}$通りになる。
もしKがこの値よりも大きければ、先頭にaを入れた時点でK番目に到達できないことが確定する。

つまり、先頭の1文字目は次の条件分岐で決定できる。
- $K \leq{} \displaystyle\binom{A+B-1}{A-1}$であるとき、`a`
- そうでないとき、`b`

続けて次の文字を決定したいが、その前にやることがある。
上記の条件分岐で`b`を先頭に入れた場合、`a`が先頭であったときにあり得た$\displaystyle\binom{A+B-1}{A-1}$通りは
必ず自分よりも辞書順で若いはずである。
つまり、現時点で少なくとも$\displaystyle\binom{A+B-1}{A-1}$通り分のパディングを持っていることになる。
これを記録しておく必要がある。

さて、2文字目を決定しよう。
実は2文字目もほとんど同様に決めることができる。
1文字目との変化は
- 1文字目にとった文字の分減らして考えないといけない
- パディングを忘れないようにする

という点だけである。
つまり、2文字目は次の条件分岐で決定できる。

$$
now =
\begin{cases}
\displaystyle\binom{A+B-1}{A-1} & \text{if 先頭がbである。} \\\\
0 & \text{if 先頭がaである。}
\end{cases}
$$

として、先頭の文字に合わせて$A \leftarrow{} A-1$または$B \leftarrow{} B-1$とする。
- $K \leq{} now + \displaystyle\binom{A+B-1}{A-1}$であるとき、`a`
- そうでないとき、`b`

とできる。

これを繰り返すことで文字列を決定できる。
注意として、`a`か`b`どちらかを使い切ってしまえば文字列が確定するので、最後まで手順を繰り返す必要はない。

時間計算量は、二項係数1回求める時間を$O(x)$と置くと、$O(x\cdot{}\mathrm{max}(A, B))$である。(多分)

## 提出
```D
import std;

void main () {
    int A, B;
    long K;
    readln.read(A, B, K);

    solve(A, B, K);
}

void solve (int A, int B, long K) {
    // 先頭からaとbどっちにするか決めていく。
    // n_i個のアルファベットA_i(1<=i<=n)で構成される文字列の種類は多項係数の数だけ存在するので、頭の一つを決めれば後ろに何個存在するかがわかる。

    long now = 0;
    char[] ans; ans.reserve(A+B);
    while (0 < A && 0 < B) {
        if (now + nCk(A+B-1, A-1) < K) {
            now += nCk(A+B-1, A-1);
            ans ~= 'b';
            B--;
        } else {
            ans ~= 'a';
            A--;
        }
    }

    foreach (_; 0..A) ans ~= 'a';
    foreach (_; 0..B) ans ~= 'b';

    writeln(ans);
}

long nCk (int n, int k) {
    assert(0 <= n && 0 <= k);
    if (n < k) return 0L;

    long res = 1;
    for (int i = 1; i <= k; i++) {
        res *= n-i+1;
        res /= i;
    }

    return res;
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

## 発展
3種類以上の文字を含む場合にも同様の手順で辞書順K番目の文字列を求めることができる。
$m$種類の文字に対して、文字$c_i$が$N_i$個含まれる文字列の種類数は多項係数
$$
\binom{\sum{}N_i}{N_1, N_2, \dots{}, N_m} = \frac{(\sum{}N_i)!}{\prod{}N_i!}
$$
により求めることができるから、これを用いて上のアルゴリズムを適用すれば良い。

しかし、現実的には多項係数が非常に大きくなるので問題には出にくいと思う。
