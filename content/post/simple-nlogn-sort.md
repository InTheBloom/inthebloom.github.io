---
title: 比較的シンプルなクイックソートとマージソートの実装
# description: 

date: 2024-07-02
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - アルゴリズム
archives:
  - 2024
  - 2024-07
# sample
# - yyyy
# - yyyy-mm

draft: true
math: true
# toc: false
# build: {list: never}
---

## ソートを書きませんか？
特に仮定のない比較によるソートが$\mathcal{O}(N \log N)$時間でできることは有名な事実でしょう。
しかし、実際に実装してみてと言われると困る人も多いのではないでしょうか。
本エントリでは、比較的バグらせにくく、楽に(当社比)クイックソート/マージソートを書く方法を紹介します。

「クイックソートは授業で一回実装したけどインデックス管理がヤバすぎて信頼性が無いなぁ」と思っている方におすすめです。

## お断り
- 実装例ではC++を使用し、`std::vector<int>`をソートします。
- 再帰を使用します。
- 定数倍最適ではないです。

## アイデアの発見元
最後に書いても読まれなさそうなので、前に書きます。
クイックソートはアルゴリズムイントロダクションのソートのところ、マージソートは電通大の授業資料で見ました。
前者はどの本だったか覚えておらず、後者は外部非公開資料なので引用が書けません。探したい人は頑張ってください。

## クイックソート
よくある実装は以下のようなものです。

1. ピボットを取る。
2. 左からピボットより大きなものを探す。
3. 右からピボットより小さなものを探す。
4. 両者の位置関係をみて、交換したり再帰に回したりする。

ネット上で発見した同様の実装:
- [クイックソート - Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%AF%E3%82%A4%E3%83%83%E3%82%AF%E3%82%BD%E3%83%BC%E3%83%88)
- [クイックソート quick sort](http://www3.u-toyama.ac.jp/math/algorithm/9.handout.pdf)

この実装では、手順2、3、4あたりでoff-by-oneが発生して壊れたり、普通に配列外参照したり、再帰の区間がおかしくて無限再帰したりしがちです。少なくともプログラミングコンテストで書けと言われて自信を持って書くのはしんどいです。
そこで、手順を次のように変更します。

1. ピボットを取る。
2. 左から走査して、ピボット未満のものを発見したら未確定ゾーンの左端と交換する。
3. 右から走査して、ピボット超過のものを発見したら未確定ゾーンの右端と交換する。
4. ピボット未満がある範囲とピボット超過がある範囲を再帰にかける。

定数倍悪化を許容して、要素を左右に寄せる部分をシンプルにしています。
もう少し具体的に書きます。配列$A$の$[L, R)$をソートするとして、最終的に$[L, l)$にピボット未満の値、$[r, R)$にピボット超過の値が入るようにします。最初は$l = L$、$r = R$です。

まず手順2を実行します。
$i$を$L$から$R - 1$まで動かしていき、$A\lbrack i \rbrack &lt; \mathrm{pivot}$であるとき$A\lbrack l \rbrack$と$A\lbrack i \rbrack$をスワップし、$l$を1増やします。
これで$A$の$[L, l)$には$\mathrm{pivot}$未満の値のみが入り、逆に$\mathrm{pivot}$未満の値は必ず$[L, l)$に入ります。

次に手順3を実行します。ほぼ同様です。
$i$を$R - 1$から$L$まで動かしていき、$\mathrm{pivot} &lt; A\lbrack i \rbrack$であるとき$r$を1減らし、$A\lbrack r \rbrack$と$A\lbrack i \rbrack$をスワップします。

最後に$[L, l)$と$[r, R)$を再帰にかければおしまいです。
以下に実装例を載せます。

```c++
#include <iostream>
#include <vector>
#include <random>

void quick_sort (std::vector<int>& A) {
    std::random_device rd;

    auto internal_quick_sort = [&](auto self, int L, int R) -> void {
        if (R - L <= 1) return;

        // 手順1. ピボットの選択
        int index = rd() % (R - L);
        if (index < 0) index += (R - L);
        index += L;

        int pivot = A[index];
        int l = L, r = R;

        // 手順2. 左から走査
        for (int i = L; i < R; i++) {
            if (A[i] < pivot) {
                std::swap(A[l], A[i]);
                l++;
            }
        }

        // 手順3. 右から走査
        for (int i = R - 1; L <= i; i--) {
            if (pivot < A[i]) {
                r--;
                std::swap(A[r], A[i]);
            }
        }

        // 手順4. 再帰
        self(self, L, l);
        self(self, r, R);
    };

    internal_quick_sort(internal_quick_sort, 0, static_cast<int> (A.size()));
}

int main () {
    std::random_device rd;
    std::vector<int> A(20);
    for (int i = 0; i < A.size(); i++) A[i] = rd() % 100;

    for (auto v : A) std::cout << v << " ";
    std::cout << "\n";

    quick_sort(A);

    for (auto v : A) std::cout << v << " ";
    std::cout << "\n";
}
```
