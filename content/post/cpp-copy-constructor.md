---
title: 暗黙のコピーコンストラクタにご注意を
# description: 

date: 2024-08-17
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - C++
archives:
  - 2024
  - 2024-08
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## Hackで落とされた...
[Educational Codeforces Round 169 (Rated for Div. 2)](https://codeforces.com/contest/2004)のD問題がHackされ、TLEで落ちました。

![](/images/cpp-copy-constructor/submission.png)

アルゴリズムは正しい自信があったので、定数倍で落ちていると思っていましたが、原因は意外なところにありました。

## コピーコンストラクタの罠
落ちたコードを掲載します。
目的の街にいくために必要な中継のポータルは高々1つになるので、ポータルの色を決め打ちして`upper_bound`で探しています。
これで8通りの色それぞれに2回`upper_bound`をすればよく、十分間に合うという感じです。

```c++
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <map>

using namespace std;
using ll = long long;

constexpr int iINF = 1'000'000'000;

void solve () {
    int n, q; cin >> n >> q;
    // 中継は高々1回
    // 中継のポータルを決め打ちして探索することで8 * 2 * logくらいでみつかる。

    vector<string> portal(n);
    for (int i = 0; i < n; i++) cin >> portal[i];
    vector<int> ord(128);
    ord['B'] = 0;
    ord['G'] = 1;
    ord['R'] = 2;
    ord['Y'] = 3;

    map<string, vector<int>> mp;
    for (int i = 0; i < n; i++) {
        mp[portal[i]].push_back(i);
    }

    for (int i = 0; i < q; i++) {
        int x, y; cin >> x >> y;
        x--, y--;
        if (y < x) swap(x, y);

        int ans = iINF;

        // 中継ポータルを決め打ちする
        for (auto c1 : portal[x]) {
            for (auto c2 : portal[y]) {
                string key = "";
                key += c1;
                key += c2;
                if (ord[key[1]] < ord[key[0]]) swap(key[0], key[1]);
                auto vec = mp[key];

                { // xの左
                    auto it = upper_bound(vec.begin(), vec.end(), x);
                    if (it != vec.end()) {
                        ans = min(ans, abs(x - *it) + abs(*it - y));
                    }

                    if (it != vec.begin()) {
                        it--;
                        ans = min(ans, abs(x - *it) + abs(*it - y));
                    }
                }

                { // yより右
                    auto it = upper_bound(vec.begin(), vec.end(), y);
                    if (it != vec.end()) {
                        ans = min(ans, abs(x - *it) + abs(*it - y));
                    }
                }
            }
        }

        if (ans == iINF) {
            cout << -1 << "\n";
        }
        else {
            cout << ans << "\n";
        }
    }
}

int main () {
    int t; cin >> t;
    for (int i = 0; i < t; i++) {
        solve();
    }
}
```

TLEを引き起こしている場所は次の部分でした。(抜粋)
```c++
// 中継ポータルを決め打ちする
for (auto c1 : portal[x]) {
    for (auto c2 : portal[y]) {
        string key = "";
        key += c1;
        key += c2;
        if (ord[key[1]] < ord[key[0]]) swap(key[0], key[1]);

        /* ↓これがダメ */
        auto vec = mp[key];

        { // xの左
```

ここで、のちのコードを記述しやすくするために、ポータルの色が`key`であるような街番号を昇順に格納した`std::vector<int>`(すなわち、`mp[key]`のことです)を`vec`に代入しています。
このとき、実は`mp[key]`の長さ分の`std::vector<int>`がいちいち作られていたようです。

正直C++の仕様には全然詳しくないので細かいことへの言及は避けますが、[CPP事始め: コピーコンストラクタ，代入演算子](https://qiita.com/hiro4669/items/44144f0f9739a8aa1285)によると、`auto vec = mp[key];`はコピーコンストラクタが呼ばれてしまうようです。
これを回避するためには、参照を利用するとよいです。すなわち、`std::vector<int>&`で受けます。

```c++
vector<int>& vec = mp[key];
auto& vec = mp[key]; // こうしても良い
```

## まとめ
色々見ている限り、C++では構造体やクラスなどは何も指定しなければコピーが走る傾向にあるようです。
皆様もC++で別の変数に参照を持つみたいなことをやろうとするときはお気をつけください。

最後に文句だけ言わせてください。

**D言語なら動的配列の代入演算子は参照が渡されるからC++とかいうの許せね〜 これHackされなかったら830位くらいだったっていうのもマジで許せね〜(Hackされて3000位くらいまで落ちた) マジでレート返してくれ！！！**

## 参考
- [std::vector::operator= cpprefjp - C++日本語リファレンス](https://cpprefjp.github.io/reference/vector/vector/op_assign.html)
- [CPP事始め: コピーコンストラクタ，代入演算子](https://qiita.com/hiro4669/items/44144f0f9739a8aa1285)
