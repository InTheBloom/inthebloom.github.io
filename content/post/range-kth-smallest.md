---
title: Range Kth Smallestに対する4つの解法と2つの実装例
# description: 

date: 2024-09-07
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - アルゴリズム
archives:
  - 2024
  - 2024-09
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## 問題
$N$要素の数列$A$が与えられる。$Q$個のクエリに解答せよ。

- $A$の$[l _ i, r _ i)$内にある要素の中で$k _ i + 1$番目に小さい値を答える。

$1 \leq N \leq 2 \times 10 ^ 5, \quad 1 \leq Q \leq 2 \times 10 ^ 5, \quad 1 \leq A _ i \leq 10 ^ 9$

[ジャッジ(library checker)](https://judge.yosupo.jp/problem/range_kth_smallest)

## 解法1
rectangle sumに帰着させる。
横軸に数列のインデックス、縦軸に値の大きさをとる二次元平面を考え、各$A _ i$に対応する場所に+1を積んでおく。

各クエリでは、x座標$[l _ i, r _ i)$に対してy軸方向$[-\infty, v]$の総和をとる。この値は$v$に対して広義単調増加であるから、ちょうど$k _ i + 1$以上になる最小の$v$は二分探索で求まる。

クエリ$O(\log N \log N \log (\max A _ i))$程度(使うデータ構造によって多少揺れると思われる。なんかいい感じにやるとlog一つくらい落ちるかも)

やりようによってはonlineクエリかつ列の変更クエリありでも動く。
rectangle sumの良い感じのやつをまだ持っていないので実装例なし。

## 解法2
wavelet matrixを用いる。wavelet matrixはこのクエリをサポートしているので、やるだけになる。
クエリ$O(\log (\max A _ i))$

onlineクエリでできるが、列の変更クエリなしのみ対応。dynamic wavelet matrixを用いればlogが付く代わりに変更クエリをさばける。(多分)
当然持っていないので実装例なし。

[dynamic wavelet matrixってこんなやつ](https://miti-7.hatenablog.com/entry/2019/02/01/143655)

ちなみに現在のlibrary checker最速実行時間はこの方針に改造を加えたものだと思われる。

## 解法3
並列二分探索を用いる。

並列二分探索のことはいったん忘れて、クエリ$[l _ i, r _ i)$を考えることにする。

配列$B = (0, 0, \dots, 0)$を用意して、$A _ i$が小さい$i$から順番に$B _ i = 1$としていくことにする。

上記操作を進めていく中で、配列$B$の$[l _ i, r _ i)$におけるRange Sum Queryの値がはじめて$k _ i + 1$以上になったときの$A _ i$がRange Kth Smallestの解である。
そして、クエリ結果が$k _ i + 1$以上になるかどうかは操作の進度に対して単調であるから、二分探索ができる。

各クエリの二分探索は並列化することで計算量を均す。
具体的には、$B _ i = 1$にしていく$N$回の操作1セットを行う途中に、すべてのクエリの二分探索を一段階進めることにする。

セグメント木を用いると、Range Sum Queryの更新1セット分が$O(N \log N)$で、二分探索更新1セット分が$O(Q \log N)$になる。
$O(\log N)$セット行えばすべての二分探索が終わるので、全体$O((N + Q) \log ^ 2 N)$

offlineかつ変更クエリなしのみ対応。

[AC(879ms)](https://judge.yosupo.jp/submission/233545)

[参考元](https://jupiro.hatenablog.com/entry/2022/02/20/110013)

```d
/// Range Kth Smallest (offlineかつstatic)
/// 並列二分探索による解法
/// aの昇順に配列を構築していくと考える。aをどこまで使えば区間[li, ri]にki以上の要素が入るかを考えると、これは単調である。
/// よって、どこまで使うかを二分探索で求めることが出来る。その境界にある要素がまさにRange Kth Smallestの解である。

import std;

void main () {
    int N, Q; readln.read(N, Q);
    auto a = readln.split.to!(int[]);

    auto l = new int[](Q);
    auto r = new int[](Q);
    auto k = new int[](Q);
    foreach (i; 0..Q) readln.read(l[i], r[i], k[i]);

    auto rsq = new SegmentTree!(int, (int a, int b) => a + b, () => 0)(N);
    auto ok = new int[](Q);
    auto ng = new int[](Q);
    auto mid = new int[](Q);
    ok[] = N - 1;
    ng[] = -1;

    auto value_ord = iota(N).array.sort!((i, j) => a[i] < a[j]).array;
    auto query_ord = iota(Q).array;

    while (true) {
        bool end = () {
            foreach (i; 0..Q) if (1 < abs(ok[i] - ng[i])) return false;
            return true;
        }();
        if (end) break;

        // セグメント木のリセット
        foreach (i; 0..N) rsq.set(i, 0);

        // midの計算 + midの昇順にソート
        foreach (i; 0..Q) mid[i] = (ok[i] + ng[i]) / 2;
        query_ord.sort!((i, j) => mid[i] < mid[j]);

        int L = 0, R = 0;
        foreach (count, i; value_ord) {
            // 点追加
            rsq.set(i, rsq.get(i) + 1);

            if (L < Q && count == mid[query_ord[L]]) {
                while (R < Q) {
                    if (mid[query_ord[R]] != count) break;
                    R++;
                }

                // 二分探索を一段階進める
                foreach (U; L..R) {
                    int qidx = query_ord[U];
                    bool f () {
                        return k[qidx] + 1 <= rsq.prod(l[qidx], r[qidx]);
                    }

                    if (f()) {
                        ok[qidx] = mid[qidx];
                    }
                    else {
                        ng[qidx] = mid[qidx];
                    }
                }

                L = R;
            }
        }
    }

    foreach (i; 0..Q) {
        writeln(a[value_ord[ok[i]]]);
    }
}

void read (T...) (string S, ref T args) {
    import std.conv : to;
    import std.array : split;
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}

// セグメント木は省略
```

## 解法4
Mo's algorithmと平方分割によるRange Sum Queryを用いる。

$A$を座標圧縮した後の値を横軸に、その値の出現回数を縦軸にとるRange Sum Queryを考える。
ある区間$[l _ i, r _ i)$のなかにある$A$の要素だけで上記Range Sum Queryを構築することにすると、$[0, x]$のRange Sum Queryがはじめて$k _ i + 1$以上になる$x$がRange Kth Smallestの解になる。

クエリ区間の巡回はMo's algorithmにより$O(N \sqrt{Q})$でできる。Range Sum Queryに平方分割を採用すると、Moの更新が$O(1)$、解の取得が$O(\sqrt{N})$で出来る。(実はRange Sum Queryにセグメント木を用いるより高速になる。)

全体$O(Q \sqrt{N} + N \sqrt{Q})$

offlineかつ変更クエリなしのみ対応。

[AC(372ms)](https://judge.yosupo.jp/submission/233551)

参考
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">1点更新range sumを平方分割でやると、更新がO(1)でクエリがO(√N)になって、Moと相性が良くなるの、おもしろ〜〜〜</p>&mdash; けむにく＠競プロ (@kemuniku) <a href="https://twitter.com/kemuniku/status/1787782215193231849?ref_src=twsrc%5Etfw">May 7, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

```d
/// Range Kth Smallest (offlineかつstatic)
/// Mo's algorithm + 平方分割rsqによる解法
/// aに含まれる要素で座標圧縮をし、横軸が座標圧縮後のindexとなるrsqを考える。
/// Moによって区間を巡回し、区間内の要素で上のrsqに積んでいくことにすると、[0, x)がはじめてkiを超える場所がRange Kth Smallestの解になる。
/// ここで、rsqに平方分割を採用すると、更新O(1)、ki以上の場所の取得がO(√N)であるから、全体O(Q√N + N√Q)で解ける。

/// 補足1: ki以上の場所がO(√N)になるからくり
/// 先頭から足していくことにして、足して初めてki以上になるブロックを見つける。ここまでO(√N)
/// ブロック内で厳密にkiになる場所を探す。ここでO(√N)
/// 合計O(√N)

/// 補足2: 座圧後のrsqで平方分割を使っているのは、セグメント木を用いるより全体の計算量が良くなるから。Mo's algorithmでは移動が支配的なので、取得を多少遅くしたとしても更新を早くする方が有利になる。

import std;

void main () {
    int N, Q; readln.read(N, Q);
    auto a = readln.split.to!(int[]);

    auto l = new int[](Q);
    auto r = new int[](Q);
    auto k = new int[](Q);
    auto ans = new int[](Q);
    foreach (i; 0..Q) readln.read(l[i], r[i], k[i]);

    // mo's algorithmの準備
    const int mo_width = max(1, sqrt(Q.to!double).to!int);
    auto priority = new int[](Q);
    foreach (i; 0..Q) priority[i] = l[i] / mo_width;

    bool less (int i, int j) {
        if (priority[i] == priority[j]) {
            if (priority[i] % 2 == 0) return r[i] < r[j];
            return r[j] < r[i];
        }
        return priority[i] < priority[j];
    }

    auto query_ord = iota(Q).array.sort!(less).array;

    // 平方分割の準備
    auto f = new int[](N);
    int max_f = 0;
    auto index = iota(N).array.sort!((i, j) => a[i] < a[j]).array;
    auto b = a.dup.sort.uniq.array;
    {
        int L = 0, R = 0;
        while (L < N) {
            while (R < N) {
                if (a[index[L]] != a[index[R]]) break;
                R++;
            }

            foreach (U; L..R) {
                f[index[U]] = max_f;
            }
            max_f++;

            L = R;
        }
    }
    const int width = max(1, sqrt(max_f.to!double).to!int);
    auto block_count = new int[](max_f / width + 1);
    auto count = new int[](max_f + 1);

    int L = 0, R = 0;
    foreach (i; query_ord) {
        // 区間合わせ
        while (L < l[i]) { block_count[f[L] / width]--; count[f[L]]--; L++; }
        while (l[i] < L) { L--; block_count[f[L] / width]++; count[f[L]]++; }
        while (R < r[i]) { block_count[f[R] / width]++; count[f[R]]++; R++; }
        while (r[i] < R) { R--; block_count[f[R] / width]--; count[f[R]]--; }

        // 取得
        int acc = 0;
        int cur_block = 0;
        while (acc + block_count[cur_block] < k[i] + 1) {
            acc += block_count[cur_block];
            cur_block++;
        }

        // ブロック内走査
        int cur = cur_block * width;
        while (acc + count[cur] < k[i] + 1) {
            acc += count[cur];
            cur++;
        }

        ans[i] = b[cur];
    }

    foreach (i; 0..Q) {
        writeln(ans[i]);
    }
}

void read (T...) (string S, ref T args) {
    import std.conv : to;
    import std.array : split;
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}
```

## おわりに
並列二分探索も平方分割も慣れない実装で辛かったです。ライブラリ化するかいい感じの実装方針を見つけないと実践で使える気がしません。

rectangle sumは実用性と汎用性のバランスが難しいなと悩む日々です。とりあえず定数倍とか無視して動くものを作ってみようかなと思っているんですが、なんだかんだ作るの面倒くさいですね。一方、簡潔でもコンパクトでもないビットベクトルなら実装できそうな気がするので、カスのwavelet matrix作ろうかなと検討中です。みなさんはどうしていますか？

MMA ContestとMaximum Cupの参加記録を書かなきゃいけないんですが、なかなか重い腰が上がりません。助けてほしい。

それでは。
