---
title: 全方位木dpは何をやっているのか？のお気持ち
# description: 

date: 2024-10-25
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2024
  - 2024-10
# sample
# - yyyy
# - yyyy-mm

draft: true
math: true
# toc: false
# build: {list: never}
---

## はじめに
全方位木dpを学習していた時、インターネットでいろいろ文献を見ました、自分にとってクリティカルなお気持ちを説明しているものはありませんでした。
昔の私、あるいは私に似た感性の人にに向けて、全方位木dpが何を行うアルゴリズムなのか説明します。

- 全方位木dpをまだ理解していない方へ：この説明のどこがわからなかったのかフィードバックをいただけると嬉しいです。[Twitter](https://x.com/UU9782wsEdANDhp)なりなんなりにお願いします。
- 私より理解している人へ：不備や不足を指摘してもらえると大変助かります。もし見つけたらお気軽にお知らせください。

## 再考：「dfsで解ける問題」
次の問題を考えます。

### 問題1
無向木が与えられる。頂点$0$を根としたとき、頂点の深さの最大値を求めよ。

これは次のようなコードで解くことが出来ます。(動かしてないので間違ってるかも。)
```c++
// graph: vector<vector<int>>みたいなもので隣接リストを作ったと考えてください。

// dfs(pos, par) := 根がpos、親がparである部分木を考えた時、
//                  部分木の頂点で、posから最も離れた頂点のposからの深さ

int dfs (int pos, int par) {
    int res = 0;
    for (auto nex: graph[pos]) {
        // 親方向には戻らない
        if (nex == par) continue;

        res = max(res, dp(nex, pos));
    }
    return res + 1;
}

int ans = dfs(0, -1);
```

「頂点$r$を根としたとき、一番深い頂点の深さはいくらか」という部分問題を考えます。
