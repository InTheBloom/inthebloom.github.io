---
title: 比較的シンプルなクイックソートとマージソートの実装
# description: 

date: 2024-10-10
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - アルゴリズム
archives:
  - 2024
  - 2024-10
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## はじめに
比較的頭を壊しにくいクイックソートとマージソートの実装方針を共有します。
オーダーも悪化しません。定数倍はわかりませんが、最適実装に比べて高々2倍とかだと思います。(適当)
実装例はすべてC++です。

## クイックソート
列を与えられたときに適切にswapしながら境界線を探すパートが最難関です。
この部分を2回に分けて行います。

1回目は前から走査していき、ピボット未満の値が出てきたらその時点での先頭とswapします。
2回目は後ろから走査していき、ピボット超過の値が出てきたらその時点で末尾とswapします。

こうすることで列全体は(ピボット未満)(ピボットと等しい)(ピボット超過)と分けることが出来て、さらにこれら境界線も手に入ります。

```c++
#include <iostream>
#include <vector>
#include <random>
#include <utility>
#include <cassert>

template<class T>
void quick_sort (std::vector<T>& A, size_t L, size_t R) {
    assert(0 <= L);
    assert(R <= A.size());
    assert(L <= R);
    if (R - L <= 1) return;

    int l = static_cast<int> (L), r = static_cast<int> (R);

    std::random_device rd;
    T piv = A[l + rd() % (r - l)];

    int lb = l, rb = r;
    // [l, lb)はpiv未満の値が入る。[rb, r)はpiv超過の値が入る。

    for (int i = l; i < r; i++) {
        if (A[i] < piv) std::swap(A[i], A[lb++]);
    }

    for (int i = r - 1; l <= i; i--) {
        if (piv < A[i]) std::swap(A[i], A[--rb]);
    }

    quick_sort(A, l, lb);
    quick_sort(A, rb, r);
}

int main () {
    const int N = 10;
    std::vector<int> A(N);

    std::random_device rd;
    for (auto& v : A) v = rd() % 10000;

    for (int i = 0; i < A.size(); i++) {
        std::cout << A[i] << (i == A.size() - 1 ? '\n' : ' ');
    }

    quick_sort(A, 0, A.size());

    for (int i = 0; i < A.size() - 1; i++) {
        assert(A[i] <= A[i + 1]);
    }

    for (int i = 0; i < A.size(); i++) {
        std::cout << A[i] << (i == A.size() - 1 ? '\n' : ' ');
    }
}
```

実行例:
```text
6469 715 7203 2864 4958 3626 9044 2876 7437 248
248 715 2864 2876 3626 4958 6469 7203 7437 9044
```

これ実装しているときに普通にバグらせていたのは内緒です。
注意点としては
1. 再帰の打ち切り
2. ピボット値の選択

あたりです。

## マージソート
再帰にかけた後に列をマージする部分が面倒です。この部分を工夫します。

列をマージするときに一時的に作業配列を使う部分で、左半分を昇順、右半分を降順に詰めます。
つまり、作業配列に詰めた後に大小関係が(小 大 小)となるようにします。
こうすると、常に右端と左端の大小だけを気にすればよくなり、片方を使い切ったので...みたいな場合分けが消えます。

```c++
#include <iostream>
#include <vector>
#include <random>
#include <utility>
#include <cassert>
#include <algorithm>

template<class T>
void merge_sort (std::vector<T>& A, size_t L, size_t R) {
    assert(0 <= L);
    assert(R <= A.size());
    assert(L <= R);
    if (R - L <= 1) return;

    static std::vector<T> tmp;
    tmp.resize(std::max(R - L, tmp.size()));

    int l = static_cast<int> (L), r = static_cast<int> (R);

    int m = (l + r) / 2;

    merge_sort(A, l, m);
    merge_sort(A, m, r);

    for (int i = 0; i < m - l; i++) tmp[l + i] = A[l + i];
    for (int i = 0; i < r - m; i++) tmp[r - i - 1] = A[m + i];

    // マージ
    int tl = l, tr = r - 1;
    for (int i = 0; i < r - l; i++) {
        if (tmp[tl] < tmp[tr]) {
            A[l + i] = tmp[tl];
            tl++;
        }
        else {
            A[l + i] = tmp[tr];
            tr--;
        }
    }
}

int main () {
    const int N = 10;
    std::vector<int> A(N);

    std::random_device rd;
    for (auto& v : A) v = rd() % 10000;

    for (int i = 0; i < A.size(); i++) {
        std::cout << A[i] << (i == A.size() - 1 ? '\n' : ' ');
    }

    merge_sort(A, 0, A.size());

    for (int i = 0; i < A.size() - 1; i++) {
        assert(A[i] <= A[i + 1]);
    }

    for (int i = 0; i < A.size(); i++) {
        std::cout << A[i] << (i == A.size() - 1 ? '\n' : ' ');
    }
}
```

実行例:
```text
9033 6639 7992 2387 8486 7967 3180 6807 3361 9980
2387 3180 3361 6639 6807 7967 7992 8486 9033 9980
```

一時配列に詰める部分でバグりやすいので気を付けてください。そこ以外は変数名が衝突しなければ難しくないはずです。

## 参考
- クイックソート: アルゴリズムイントロダクション(版などは忘れました...)
- マージソート: UECの授業資料（一般公開されていないやつ）

## 終わりに
g++でコンパイルオプションとして`-D_GLIBCXX_DEBUG`をつけると範囲外参照を検出してくれるのですが、何行目で落ちてるとか言ってくれなくてかなりデバッグしにくかったです。
これどうにかなりませんか？

このエントリ7月に100行くらい書いた状態でずっと放置していたのが最近発見されたので完成させました。

みなさんはこの実装方針どう思いますか？意見がある方は[Twitter/X](https://x.com/UU9782wsEdANDhp)までどうぞ。
