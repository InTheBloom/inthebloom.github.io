---
title: ABC239EとABC372Eをより強い条件で解いてみる
# description: 

date: 2025-08-21
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - データ構造
archives:
  - 2025
  - 2025-08
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

## ABC372E - K-th Largest Connected Components

[問題](https://atcoder.jp/contests/abc372/tasks/abc372_e)

### 問題文（概略）
$N$頂点のグラフがあり、頂点$i$には数$i$が書かれている。
以下の２つのクエリを処理。

- 頂点$u, v$を結ぶ無向辺の追加
- $u$の連結成分における$k$番目に大きな数を出力。存在しなければ$-1$とする。

$N \leq 2 \times 10 ^ 5, Q \leq 2 \times 10 ^ 5, k \leq 10$

これを$k$の上限なしで解きます。
方法自体は解説にのっており、新規性0です。
ですが、せっかく平衡木を組めるので全部自力でやります。

### 方法
平衡木は実装次第で$k$番目の値を取得するクエリに対応できます。要素数$N$の時$O(\log N)$です。（`std::set`や`std::map`、pythonの`Set`などは非対応。）

それとマージテクを組み合わせるとできます。
マージテクとは競技プログラミングでしばしば登場する典型テクです。
全体で$N$個のモノを、「２つのモノを結合する」という操作を全体が一つになるまで繰り返す過程において、「要素数の小さい方にある要素を大きい方へと移す」というルールを守ることで移動の回数を$O(N\log N)$回にすることができるというものです。

今回の問題はまさにマージテクが適用可能で、サイズの小さい平衡木から大きい平衡木へと要素を動かすことで移動回数を償却$O(\log N)$回にできます。
移動の時間計算量は$O(\log N)$なので、全体で$O(N\log^2 N)$時間で適切に集合を管理できます。

各クエリは$O(\log N)$時間で答えられるので、全体$O(N\log^2 N + Q\log N)$になります。

### 実装
kyopro\_friendsさんの実装ではUnionFindにg++拡張の平衡木を埋め込んで実装していました。が、UnionFindと平衡木を別々に管理してもできます。

まず$N$頂点でUnionFindを作ります。同時に各代表元に対応する平衡木たちを作ります。初期状態では1要素の平衡木$N$本です。
注意として、平衡木の配列は代表元が持つデータを表すためのものであって、常に$N$個すべてを使うわけではありません。
例えばマージ済みの頂点$u, v$の代表元が$u$である時、$v$番目にある平衡木は使いません。

$u, v$のマージをするときは、まず$u, v$をそれらの代表元を取得しておきます。（変数の節約のため以後$u, v$が代表元であるとします。）
$u, v$をマージし、新しく根になった頂点を$n$とします。

まともなUnionFindなら$n$は$u, v$のどちらかになっているので、根になれなかった方の頂点がわかります。
根になれなかった方に対応する平衡木から新しい根に対応する平衡木へ要素を移動すればよいです。

少々雑ですが、D言語による実装を示します。
マージの時一応サイズの確認を行い、必ず大きい方へとマージするように木をswapしてあります。Union By SizeかUnion By Rankをやってれば心配不要だと思います。

[AC（753ms/56364KiB）](https://atcoder.jp/contests/abc372/submissions/68661781)

```d
void main () {
    int N, Q;
    readln.read(N, Q);

    auto uf = UnionFind(N);
    auto tree = new NodePtr[](N);
    foreach (i; 0 .. N) {
        tree[i] = insert(tree[i], i);
    }
    auto ans = new int[](0);

    foreach (i; 0 .. Q) {
        auto query = readln.split.to!(int[]);
        int t = query[0];

        if (t == 1) {
            int u = query[1] - 1;
            int v = query[2] - 1;
            u = uf.root(u);
            v = uf.root(v);
            if (u == v) {
                continue;
            }

            uf.unite(u, v);
            int n = uf.root(u);

            if (u == n) {
                swap(u, v);
            }
            if (tree[v].length < tree[u].length) {
                swap(tree[u], tree[v]);
            }

            foreach (j; 0 .. tree[u].length) {
                tree[v] = insert(tree[v], kthValue(tree[u], j).value);
            }
            tree[u] = null;
        }
        if (t == 2) {
            int v = query[1] - 1;
            int k = query[2];

            v = uf.root(v);
            if (k <= tree[v].length) {
                ans ~= kthValue(tree[v], tree[v].length - k).value + 1;
            }
            else {
                ans ~= -1;
            }
        }
    }

    writefln("%(%s\n%)", ans);
}
```

## ABC239E - Subtree K-th Max

[問題](https://atcoder.jp/contests/abc239/tasks/abc239_e)

### 問題文（概略）
$N$頂点、$1$を根とする根付き木がある。頂点$i$には数$X _ i$が書かれている。
以下のクエリを処理。

- $u$の部分木の頂点に書かれた$k$番目に大きな数を出力。

$N \leq 2 \times 10 ^ 5, Q \leq 10 ^ 5, k \leq 20$

同じく$k$の上限なしで解きます。

### 方法
手法は同じで、$k$番目を取得可能な平衡木を適切に管理します。

一度マージしてしまうと切り離せないので、クエリを先読みして根から遠いものから優先的に答えます。

木上のマージでも計算量解析は同じで、$O(N\log ^ 2 N + Q\log N)$時間です。

### 実装
初期状態は各頂点に対応する$N$本の平衡木を作成しておきます。要素数は0です。
$u$の部分木のクエリに答えるときは再帰的にマージしていき、$u$を部分木とする頂点の$X _ i$がすべて$u$番目の平衡木に集約されるようにします。

このマージの過程で小さい方から大きい方へ移動させてあげればよいです。

注意点があります。
例えば$u$の部分木のクエリを処理するために、$u$の子$v$とのマージをしたいとします。この時$v$に対応する平衡木の要素数の方が大きくなることがあります。
こういうときは$u, v$に対応する平衡木を最初に交換し、$u$側が大きくなるように調整してあげないといけません。
どちらからどちらへマージしても結局同じことなので、最初に交換してもOKです。

D言語による実装例を示します。
キモは葉方向からクエリに答えることと、再帰的なマージをどう実装するか（実装例における関数`f`）なので、それらを意識すると難しくないと思います。

[AC（418ms/31796KiB）](https://atcoder.jp/contests/abc239/submissions/68626574)

```d
void main () {
    int N, Q;
    readln.read(N, Q);
    auto X = readln.split.to!(int[]);
    auto A = new int[](N - 1);
    auto B = new int[](N - 1);
    foreach (i; 0 .. N - 1) {
        readln.read(A[i], B[i]);
        A[i]--, B[i]--;
    }
    auto V = new int[](Q);
    auto K = new int[](Q);
    foreach (i; 0 .. Q) {
        readln.read(V[i], K[i]);
        V[i]--;
    }

    auto graph = new int[][](N);
    foreach (i; 0 .. N - 1) {
        graph[A[i]] ~= B[i];
        graph[B[i]] ~= A[i];
    }

    auto depth = new int[](N);
    void dfs (int pos, int par) {
        foreach (to; graph[pos]) {
            if (to == par) {
                continue;
            }
            depth[to] = depth[pos] + 1;
            dfs(to, pos);
        }
    }
    dfs(0, -1);

    auto ord = iota(Q).array;
    ord.sort!((a, b) => depth[V[b]] < depth[V[a]]);

    auto vis = new bool[](N);
    auto tree = new NodePtr[](N);

    // 再帰的にuまでマージ
    void f (int u) {
        if (vis[u]) {
            return;
        }
        vis[u] = true;
        // 自分
        tree[u] = insert(tree[u], X[u]);

        foreach (to; graph[u]) {
            if (depth[to] < depth[u]) {
                continue;
            }
            f(to);
            if (tree[u].length < tree[to].length) {
                swap(tree[u], tree[to]);
            }

            foreach (i; 0 .. tree[to].length) {
                tree[u] = insert(tree[u], kthValue(tree[to], i).value);
            }

            // メモリ開放
            tree[to] = null;
        }
    }

    auto ans = new int[](Q);
    foreach (i; ord) {
        f(V[i]);
        ans[i] = kthValue(tree[V[i]], tree[V[i]].length - K[i]).value;
    }

    writefln("%(%s\n%)", ans);
}
```

## おまけ

### Q1. k番目の取得ってどうやってるの？
各ノードに部分木サイズをもたせたうえで次のような感じで再帰的に求められます。
通ったノードは記憶しなくて良いので非再帰でも楽です。
```d
int kthValue (tree t, int k) {
    assert(0 <= k);

    int lSize = t.lch.length;
    if (lSize == k) {
        return t.value;
    }
    if (k < lSize) {
        return kthValue(r.lch, k);
    }
    return kthValue(r.rch, k - lSize - 1);
}
```

（わかる人むけ）または要素数を基準とした`split`を作って最小or最大を探す実装でもOKです。定数倍は3倍くらいつきます。

計算量を悪化させずにノードに部分木サイズをのせられるのかという問題が残りますが、都合の良いことに多くの平衡木で可能です。

一般に、更新の際に部分木の構造が変化してしまうような場所が$O(\log N)$個程度になる平衡戦略を取る木なら同様のことができます。何ならモノイド積とかものります。

### Q2. マージテクの解析
$N$個のモノに対する任意のマージの操作列を考えます。ただし、すでにマージ済みのものをマージする操作は使わないことにします。
例えば$N = 4$として
- (1, 3)
- (2, 3)
- (1, 4)

という操作列を処理すると、
- {1, 2, 3, 4}
- {{1, 3}, 2, 4}
- {{1, 2, 3}, 4}
- {{1, 2, 3, 4}}

という順で結合していき、全体が一つになります。

あるモノの移動回数を「自分が所属している塊の要素数はいくつか？」ということに着目して解析します。

マージテクは小さい方の塊を移動させてマージするため、「自分が移動する必要のあるマージ」をすると、自分が所属する塊の要素数は少なくとも2倍になります。

よって、このようなマージを$x$回行ったとすると、要素数は$2 ^ x$以上になります。
モノは全部で$N$個のため、この値が$N$を超えることはありません。
つまり、$2 ^ x \leq N$となり、ここから$x \leq \log _ 2 N$が従います。

以上の議論がどのモノについても成立するため、全体の移動回数は$N \log _ 2 N$回以下になります。
