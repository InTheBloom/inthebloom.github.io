---
title: 列をいくつかの連続部分列へ分解する小技
# description: 

date: 2023-12-13
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
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

## 問題
数列$A$の連続部分列を、$i, j \in [1, N]$かつ$i \leq j$なる$i, j$を選択し、
$A$の$i$項目から$j$項目までを順番を変えずに取り出したものとし、$B_{i, j}$と表記することとする。

長さ$N$の数列$A = (A_1, A_2, \dots, A_N)$が与えられる。
数列$A$から取り出した$1$個以上の連続部分列の列$C$であって、次の条件を満たすものをすべて列挙せよ。

- $C$の要素を前から順番を変えずに結合して得られる数列は、$A$に一致する。

但し、$2$つの連続部分列の列が異なるとは、ある要素が存在して、片方にのみ含まれることとする。

<span style="font-weight: bold; font-size: 1.2em;">制約</span>

- $1 \leq N \leq 15$

## 問題の説明
ややこしく書いたが、要は重ならない/余らないようにいくつかの連続部分列に分解しろという問題である。
まず、連続部分列への分割は$2^{N-1}$通り存在することを説明する。

まず、$A_i$と$A_{i+1}$の間に全部で$N-1$個の「切れ目」があると考える。

最終的に$k$個の連続部分列に分解する時、これらの切れ目を$k-1$個選択することで達成される。
この組み合わせ数は$\binom{N-1}{k-1}$通りである。

$1 \leq k \leq N$に対する総和を取ればよいため、全体の組み合わせ数は、
$$
\sum_{k=0}^{N-1}\binom{N-1}{k} = 2^{N-1}
$$
通りになる。
なお、この変形を含めた二項係数の公式は[高校数学の美しい物語](https://manabitimes.jp/math/588)を参照すると良い。

次の章で、これらすべてを実際に列挙する方法を説明する。

## 解法
本問題は、bit全探索を用いて時間計算量$O(N2^N)$で解くことができる。
まず、元の数列$A$を`int[]`で、1つの有効な分割を`int[][]`で管理することにする。
```d
int[] A = readln.split.to!(int[]); // 標準入力から入力
int[][] ans = new int[][](N, 0); // 二次元配列を宣言し、メモリ確保
```
また、$A_i$と$A_{i+1}$の「切れ目」を`int[]`で管理する。
```d
int[] cut = new int[](N-1);
```
ここで、`cut[i]`が表すのは$A_i$と$A_{i+1}$の間の「切れ目」であることに注意せよ。
bit全探索を用いて、どの「切れ目」を採用するかを探索する。
```d
for (int bit = 0; bit < (1<<(N-1)); bit++) {
    cut[] = 0; // cutのすべての要素に0を代入
    for (int i = 1; i < N; i++) if (0 < (bit&(1<<i))) cut[i] = -1; // -1の代入された切れ目を使う
}
```

例えば、$N=5$の時、`cut`を適切な場所で`print`すると次の出力を得る。
```text
[0, 0, 0, 0]
[-1, 0, 0, 0]
[0, -1, 0, 0]
[-1, -1, 0, 0]
[0, 0, -1, 0]
[-1, 0, -1, 0]
[0, -1, -1, 0]
[-1, -1, -1, 0]
[0, 0, 0, -1]
[-1, 0, 0, -1]
[0, -1, 0, -1]
[-1, -1, 0, -1]
[0, 0, -1, -1]
[-1, 0, -1, -1]
[0, -1, -1, -1]
[-1, -1, -1, -1]
```

あとは、`cut`の情報を利用しながら`ans`へ格納していけば良い。
具体的には、次のアルゴリズムで達成できる。

1. `cur = 0`、`idx = 0`とする。
2. `cur < N-1 && cut[cur] == -1`が真の時、手順3へ。そうでなければ手順4へ行く。
3. `ans[idx]`に`A[cur]`を追加し、`idx += 1`とする。手順5へ行く。
4. `ans[idx]`に`A[cur]`を追加する。手順5へ行く。
5. `cur += 1`とする。`cur == N`であれば終了。手順2へ行く。

## 実装例
```d
import std;

void main () {
    int[] A = [1, 2, 3, 4, 5];
    int[][] ans = new int[][](A.length, 0);
    int[] cut = new int[](A.length-1);

    /* bit全探索 */
    for (int bit = 0; bit < (1<<(A.length-1)); bit++) {
        cut[] = 0; // cutをリセット
        for (int i = 0; i < A.length-1; i++) if (0 < (bit&(1<<i))) cut[i] = -1;

        /* ansへ割り振る */
        foreach (ref a; ans) a.length = 0; // ans[i]をリセット

        int cur = 0, idx = 0;
        while (true) {
            if (cur == A.length) break;
            if (cur < A.length-1 && cut[cur] == -1) ans[idx++] ~= A[cur]; // ~=はpush_backのようなもの
            else ans[idx] ~= A[cur];
            cur++;
        }

        /* 出力 */
        write("answer ", bit, " ");
        for (int i = 0; i <= idx; i++) {
            write(ans[i], i == idx ? "\n" : " ");
        }
    }
}
```

```text
answer 0 [1, 2, 3, 4, 5]
answer 1 [1] [2, 3, 4, 5]
answer 2 [1, 2] [3, 4, 5]
answer 3 [1] [2] [3, 4, 5]
answer 4 [1, 2, 3] [4, 5]
answer 5 [1] [2, 3] [4, 5]
answer 6 [1, 2] [3] [4, 5]
answer 7 [1] [2] [3] [4, 5]
answer 8 [1, 2, 3, 4] [5]
answer 9 [1] [2, 3, 4] [5]
answer 10 [1, 2] [3, 4] [5]
answer 11 [1] [2] [3, 4] [5]
answer 12 [1, 2, 3] [4] [5]
answer 13 [1] [2, 3] [4] [5]
answer 14 [1, 2] [3] [4] [5]
answer 15 [1] [2] [3] [4] [5]
```

確かに分割が成功している。

## 使用例

ネタバレ注意であるが、AtCoderの[この問題](https://atcoder.jp/contests/abc159/tasks/abc159_e)で使うことができる。
[提出例](https://atcoder.jp/contests/abc159/submissions/48463494)

## 終わりに
これサッと実装しろと言われたら困る人も多いんじゃないかなと思ったので作りました。
役にたてば幸いです。
