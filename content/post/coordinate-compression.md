---
title: 2way 座標圧縮
# description: 

date: 2025-06-24
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2025
  - 2025-06
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 座標圧縮
次のことを実現するアルゴリズムを指して、**座標圧縮**と呼ぶことがあります。

> 長さ$N$の数列$A = (A[1], A[2], \dots, A[N])$が与えられる。
> $1 \leq i \leq N$なる$i$に対して、$A[i]$が$A$の中で昇順何番目かを調べる。

$A$における値の重複をどうするかなどは状況によりますが、一般的には重複は一回だけカウントすることが多いです。
具体例としては、$A = (3, 1, 5, 1, 2, 6, 10)$のとき、

- $A[1] = 3$は3番目
- $A[2] = A[4] = 1$はどちらも2番目
- $A[7] = 10$は6番目

となります。

数列の値の大小関係が大事で、具体的な値にはあまり興味のないときなどに使うことがあります。
座標圧縮で値域をしぼめてデータ構造に乗せるといったことをやりがちです。

本エントリでは、座標圧縮の方法を2通り紹介します。

## 方法1
$A$をコピーした数列$B$を作り、$B$をソートしてから重複を取り除きます。
先程のように$A = (3, 1, 5, 1, 2, 6, 10)$とするなら、$B = (1, 2, 3, 5, 6, 10)$となります。

あとはmapなどで$\mathrm{mp}[B[i]] = i$のようにします。
このように構築したmapに$A$の要素を入れると座標圧縮ができます。

mapを使うのが嫌な場合は、$B$上で$A[i]$を超えないindexを二分探索で探すと同様のことができます。

mapを使う例: [https://atcoder.jp/contests/abc036/submissions/67035552](https://atcoder.jp/contests/abc036/submissions/67035552)

```c++
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

int main () {
    int N;
    std::cin >> N;
    std::vector<int> a(N);
    for (int i = 0; i < N; i++) {
        std::cin >> a[i];
    }

    auto b = a;
    std::sort(b.begin(), b.end());
    b.erase(std::unique(b.begin(), b.end()), b.end());

    std::map<int, int> mp;
    for (int i = 0; i < b.size(); i++) {
        mp[b[i]] = i;
    }

    for (int i = 0; i < N; i++) {
        std::cout << mp[a[i]] << "\n";
    }

    return 0;
}
```

二分探索を使う例: [https://atcoder.jp/contests/abc036/submissions/67035612](https://atcoder.jp/contests/abc036/submissions/67035612)

```c++
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>
#include <cmath>

int main () {
    int N;
    std::cin >> N;
    std::vector<int> a(N);
    for (int i = 0; i < N; i++) {
        std::cin >> a[i];
    }

    auto b = a;
    std::sort(b.begin(), b.end());
    b.erase(std::unique(b.begin(), b.end()), b.end());

    for (int i = 0; i < N; i++) {
        int ok = 0, ng = static_cast<int>(b.size());
        while (1 < std::abs(ok - ng)) {
            int mid = (ok + ng) / 2;
            if (b[mid] <= a[i]) {
                ok = mid;
            }
            else {
                ng = mid;
            }
        }

        std::cout << ok << "\n";
    }

    return 0;
}
```

## 方法2
まず、「インデックスソート」を行います。
これは、次の条件を満たす長さ$N$の数列$\mathrm{ord}$を作成することです。

- $1 \leq i \leq N$に対して、$\mathrm{ord}[i]$は「$A$において昇順で$i$番目の要素があるindex」を表す。

わかりにくい定義なので、具体例を提示します。
$A = (7, 3, 9, 1, 5)$とします。

このとき、
- 昇順1番目の要素「1」は、$A$のindex 4にある
- 昇順2番目の要素「3」は、$A$のindex 2にある
- 昇順3番目の要素「5」は、$A$のindex 5にある
- 昇順4番目の要素「7」は、$A$のindex 1にある
- 昇順5番目の要素「9」は、$A$のindex 3にある

となります。

したがって、$\mathrm{ord} = (4, 2, 5, 1, 3)$です。
$A$に重複した要素があるとき、タイブレークの順番は適当で大丈夫です。

作り方としては、まず最初$\mathrm{ord} = (1, 2, 3, \dots, N)$とします。
次に比較関数
$\mathrm{ord}[i] < \mathrm{ord}[j] \Leftrightarrow A[\mathrm{ord}[i]] < A[\mathrm{ord}[j]]$
を用いて$\mathrm{ord}$をソートをすると良いです。
（$\mathrm{ord}$の要素自体の大小ではなく、その値で$A$にアクセスしたときに大小がどうなるかでソートしている。）

この$\mathrm{ord}$を使って新しく長さ$N$の数列$B$を作ります。
$B$は$B[\mathrm{ord}[i]] = i$を満たすようにします。

これでokです。
$A[i]$の座標圧縮結果は$B[i]$になっています。

ただしこの方法は注意点があります。
$A$が重複した要素を持つ場合、つまり$A[i] = A[j]$なる$i \neq j$がある場合、
上記アルゴリズムのままだと$B[i] \neq B[j]$になります。

これを$B[i] = B[j]$にしたい場合は単に$B[\mathrm{ord}[i]] = i$とするのではなく、
$A[\mathrm{ord}[l]] = A[\mathrm{ord}[r]]$であるような範囲を尺取りで求めて、
その区間の$B[\mathrm{ord}[i]]$には同じ数を代入する必要があります。
（詳しくは実装例を参照してください。）

方法2: [https://atcoder.jp/contests/abc036/submissions/67036368](https://atcoder.jp/contests/abc036/submissions/67036368)

```c++
#include <iostream>
#include <vector>
#include <algorithm>
#include <numeric>

int main () {
    int N;
    std::cin >> N;
    std::vector<int> a(N);
    for (int i = 0; i < N; i++) {
        std::cin >> a[i];
    }

    std::vector<int> ord(N);
    std::iota(ord.begin(), ord.end(), 0);

    std::sort(ord.begin(), ord.end(), [&](int i, int j) -> bool { return a[i] < a[j]; });

    std::vector<int> B(N);
    int current = 0;
    int l = 0, r = 0;
    while (l < N) {
        while (r < N) {
            if (a[ord[l]] != a[ord[r]]) {
                break;
            }
            r++;
        }

        for (int k = l; k < r; k++) {
            B[ord[k]] = current;
        }
        current++;
        l = r;
    }

    for (int i = 0; i < N; i++) {
        std::cout << B[i] << "\n";
    }

    return 0;
}
```

## おわりに
両者得意不得意があります。場面に応じて使い分けるなりライブラリ化するなりしておくと便利だと思います。

本エントリでは触れませんでしたが、部分木の要素数を持つ二分探索木を使って座標圧縮することもできそうです。額面上の計算量は同じですが、ソートを用いる方法などに比べて定数倍は悪いかもしれません。
