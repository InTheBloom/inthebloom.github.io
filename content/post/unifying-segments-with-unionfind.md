---
title: UnionFindによる区間の統合
# description: 

date: 2024-11-19
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 典型テク
  - アルゴリズム
archives:
  - 2024
  - 2024-11
# sample
# - yyyy
# - yyyy-mm

math: true
toc: true
# build: {list: never}
---

## 概要
$N$個の区間を考えて、$i$個目の区間を$[i, i + 1)$とします。
$O(N)$くらいが許されるとき、隣り合う区間を統合するクエリをUnionFindで処理することができます。
より具体的には、次の操作をならし$O(\alpha (n))$時間で行うことができます。

- $u$が属する区間を$R$とする。$R$と、$R$に(左右どちらかに)**隣接する**区間を統合する。
- $u$が属する区間の最左と最右の点を答える。

## 方法
$N$頂点のUnionFindと、補助のデータとして2要素タプルの長さ$N$の配列$\mathrm{range}$を持ちます。ここで、$\mathrm{range[i]}$は$i$を根とする連結成分が表す区間です。
```D
auto uf = new UnionFind(N);
auto range = new Tuple!(int, int)[](N);
foreach (i; 0..N) range[i] = tuple(i, i);
```
初期状態では$\mathrm{range}[i]$は$(i, i)$を持ちます。$i$個目の区間は$[i, i + 1)$を表すので、閉区間で表現するなら$(i, i)$というわけです。

### 区間取得
まず、$u$が属する区間の取得を考えます。これは単にUnionFindの代表元を用いて操作すればよいです。
```D
int r = uf.root(u);
```
とします。$\mathrm{range}$の定義から、$\mathrm{range}[r]$が$u$の属する区間です。

騙されている気がしますが、初期状態では明らかに正しいです。じゃあ初期状態以外はどうなのかというと、区間マージの際にこれらの不変条件を壊さないように操作をすることで正しさを常に保つので大丈夫です。

### 区間統合
$u$の属する区間と、一つ右の区間を統合することを考えます。
二つの区間で代表元を取得して、それぞれ$\mathrm{cur}, \mathrm{right}$とします。$\mathrm{cur}$は$\mathrm{u}$から取得できます。$\mathrm{right}$は$\mathrm{range}[u]$を用いて取得できます。具体的には、
```D
int cur = uf.root(u);
int right = uf.root(range[cur][1] + 1);
```
です。

これらをUnionFindで統合します。新しく決まった根を$r$とします。
$\mathrm{range}[r]$を$\mathrm{range}$の定義が壊れないように修正します。
つまり、$\mathrm{range}[r] = (\mathrm{range}[\mathrm{cur}][0], \mathrm{range}[\mathrm{right}][1])$にします。
```D
int r = uf.unite(cur, right);
range[r] = tuple(range[cur][0], range[right][1]);
```
ここで、$\mathrm{range}[\mathrm{cur}]$や$\mathrm{range}[\mathrm{right}]$の修正を**行わない**ことに注意してください。この操作以降、区間を取りまとめて管理するのは$r$の仕事であり、もはや$\mathrm{cur}$や$\mathrm{right}$は根にはなりえません。なので、無視してもよいのです。

もう少しかみ砕くと、$\mathrm{range}[\mathrm{cur}][0] \leq x \leq \mathrm{range}[\mathrm{right}][1]$を満たすすべての数$x$に対して、その代表元は$r$になっています。

## 例題
[ABC380E - 1D Bucket Tool](https://atcoder.jp/contests/abc380/tasks/abc380_e)

### 問題文
$1$から$N$の番号がついた$N$個のマスが一列に並んでいます。
$1 \leq i < N$について、マス$i$とマス$i + 1$は隣接しています。

最初、マス$i$は色$i$で塗られています。

クエリが$Q$個与えられるので、順に処理してください。クエリは次の2種類のいずれかです。

- `1 x c`: マス$x$から始めて「いまいるマスと同じ色に塗られている隣接するマス」への移動を繰り返すことで到達可能なマスを全て色$c$に塗り替える
- `2 c`: 色$c$で塗られているマスの個数を答える

### 制約
- $1 \leq N \leq 5 \times 10 ^ 5$
- $1 \leq Q \leq 2 \times 10 ^ 5$

### 解法
さっくりと説明します。

まず、重要な考察として、一度くっついてしまったらそれ以降分離しません。つまり、区間のマージができればよさそうです。

上記で説明した情報のほかに、「連結成分の色」と、「色ごとのカウント」を用意します。
マージクエリが来たら、一旦今の連結成分の色をカウントの減らして、色を変え、変えた先の色のカウントを増やします。
最後に隣接領域と色が同じであればマージを行います。

細かい部分は自力で詰めるのがよいと思います。ぜひチャレンジしてみてください。

```D
import std;

void main () {
    int N, Q; readln.read(N, Q);
    auto uf = UnionFind(N);

    /* range[i] := 根をiとする連結成分が管理する区間 */
    auto range = iota(N).map!((i) => tuple(i, i)).array;

    /* color[i] := 根をiとする連結成分の色 */
    auto color = iota(N).array;

    /* count[i] := 色iの現在の数 */
    auto count = generate!(() => 1).take(N).array;

    auto ans = new int[](0);

    foreach (i; 0..Q) {
        auto query = readln.split.to!(int[]);
        int t = query[0];

        if (t == 1) {
            int x = query[1] - 1, c = query[2] - 1;
            int r = uf.root(x);

            /* xの属する連結成分のカウントを取り消し */
            count[color[r]] -= uf.GroupSize(r);

            /* 色の変更 + カウント */
            color[r] = c;
            count[color[r]] += uf.GroupSize(r);

            /* 同じ色で隣接している連結成分をマージする */
            if (0 <= range[r][0] - 1) {
                int left = uf.root(range[r][0] - 1);

                if (color[left] == color[r]) { // 左側マージ成功 + 新しい区間の範囲を正しくして、今見てる根を新しいほうにする
                    int nr = uf.unite(left, r);
                    range[nr][0] = range[left][0];
                    range[nr][1] = range[r][1];
                    r = nr;
                }
            }

            if (range[r][1] + 1 < N) {
                int right = uf.root(range[r][1] + 1);

                if (color[right] == color[r]) { // 右側マージ成功
                    int nr = uf.unite(r, right);
                    range[nr][0] = range[r][0];
                    range[nr][1] = range[right][1];
                    r = nr;
                }
            }
        }
        if (t == 2) {
            int c = query[1] - 1;
            ans ~= count[c];
        }
    }

    foreach (v; ans) {
        writeln(v);
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

// UnionFind省略
```

## 終わりに
一回実装しないとやり方がよくわからないシリーズかなと思います。ミソは、別に配列を持って、現在の根の場所に連結成分の情報を書き込むことです。
初めて見たときは少し混乱しましたが、UnionFindで扱える問題が広くなるよいアイデアだと思います。
