---
title: PG BATTLE 2023参加記録
# description: 

date: 2023-10-23
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - コンテスト参加記録
  - 競技プログラミング
archives:
  - 2023
  - 2023-10
# sample
# - yyyy
# - yyyy-mm

math: true
# toc: false
# build: {list: never}
---

<style> /* 動画埋め込み */
    #wrap::before {
        content: "";
        display: block;
        padding-top: 56.25%;
    }
</style>

## 始まりは突然に
10月9日に、やきとりさん(@yktr_drm06)から[PG BATTLE](https://products.sint.co.jp/pg_battle)に誘われて、
私、やきとりさん、ryotaさん(@95s7k84695a)のチームで参加することになりました。

このコンテストの存在は知っていたものの、学内に競技プログラミングをしている知り合いが存在しないため、どうしようか迷っていました。(最悪電通大競プロサークルのDiscordで募集かけようかと思っていた。)

そんな時にお誘いいただいたので、ぜひ！ということで参加させていただきました。
<span style="text-decoration: line-through;">メンバーが私よりも強い方なので、ラッキーだなとか思っていました</span>(すいません。)

## PG BATTLEについて
普段はAtCoderのコンテスト及び類似のコンテストしか出ていないので、PG BATTLEのルールはちょっと新鮮でした。
要点は以下の通りです。

- 3人1チーム
- **ひとりひとり解く問題が違う**(配点は1/3ずつ)
- **チーム内相談禁止**
- **提出は一回のみ**
- 総得点及び解答提出時間で勝負

ICPCですら提出は何回かできるので、プログラミングコンテストとしてはかなり珍しい方だなと思います。
問題は、ましゅまろ/せんべい/かつおぶしの三種類あり、誰がどの問題を解くかは事前に決めることができます。
私は二番目に簡単なせんべいを担当しました。

## せんべい雑振り返り
すべての問題は[ここ](https://products.sint.co.jp/q_list_2023)で公開されています。

### 難易度2 積の符号
![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1698063034/pictures/pgbattle2023/A_a2euey.png)

ちょっと前にTwitterで話題になっていた、注意力を要求するB問題みたいな雰囲気のする問題です。
符号を当てればよいので、全部掛け算する必要はなく、0があるかどうかで場合分けをすればよいです。

0がなければ、-の要素が偶数個か奇数個かでACできます。

```D
import std;

void main () {
    int N = readln.chomp.to!int;
    int[] A = readln.split.to!(int[]);

    int minus = false;

    A.sort;
    foreach (i; 0..N) {
        if (A[i] == 0) { writeln(0); return; }
        if (A[i] < 0) minus++;
    }

    if (minus % 2 == 0) {
        writeln("+");
    } else {
        writeln("-");
    }
}
```

### 難易度3 ABCの個数
![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1698063034/pictures/pgbattle2023/B_rwm02t.png)

期待値を求める系の問題は大体よくわかってないので、
苦手問題来たーって思って身構えました。

ググって何とかならないかなーと思って、
「期待値の線形性」というキーワードで出てきた[このサイト](https://manabitimes.jp/math/698)を見ていたら、
応用例2がまさにこの問題でした。ラッキー！

どうやら各部分で"ABC"が作れる確率を足し合わせればよいようです。

期待値の線形性ってこうやって使うんだなぁと勉強になったような気がします。
ただ、数学的理解が怪しいのでうーんという感じです。

```D
import std;

void main () {
    string S = readln.chomp;

    solve(S);
}

void solve (string S) {
    /* 期待値の線形性を使う */
    /* 場所iをスタートにしてABCができる確率X_iとすると、解はE[Σ(X_i)] */
    double ans = 0;
    foreach (i; 0..S.length) {
        if (S.length <= i+2) continue;
        if ((S[i] != '?' && S[i] != 'A') || (S[i+1] != '?' && S[i+1] != 'B') || (S[i+2] != '?' && S[i+2] != 'C')) continue; /* 確率0 */
        int UnComfirmed = 0;
        for (int j = 0; j < 3; j++) if (S[i+j] == '?') UnComfirmed++;
        ans += 1./(3^^UnComfirmed);
    }

    writefln("%.10f", ans);
}
```

### 難易度4 距離K
![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1698063034/pictures/pgbattle2023/C_alut3f.png)

これは割とすぐ解法が見えました。
まずは数列を次のようにK個のグループに分けます。
$$\mathrm{group}[i] \coloneqq \\{ A[x] \mid \forall j, ~ x = i+jK \\}$$
実は、操作によって入れ替わることができるのは同一グループに属する要素だけです。

簡単のため、ある一つのグループ以外を固定して考えます。
この時、数列Aは操作できるグループの「[同じものを含む順列](https://hiraocafe.com/note/onajimono-jyunretsu.html)」通り数になります。
同様の議論をすべてのグループに適用することで、数列Aの変化先の総数は、
すべてのグループについての「同じものを含む順列」の総積であることが分かります。

式におこしましょう。$\mathrm{group}[i]$が要素$x[j]$を$y[j]$個持つとすると、求める値は
$$
\prod_{i} \frac{\left( \sum_{j} y[j] \right)!}{\prod_j (y[j]!)}
$$
となります。$\sum_{j}y[j] \leq N$なので、
Nまでの階乗及びその逆元をを空間/時間$O(N)$で先に求めておけば、上の式を高速に求めることができます。

```D
import std;

void main () {
    int N, K; readln.read(N, K);
    int[] A = readln.split.to!(int[]);

    solve(N, K, A);
}

void solve (int N, int K, int[] A) {
    const long MOD = 998244353;

    /* 階乗前計算 */
    long[] fact = new long[](N+1);
    long[] factInv = new long[](N+1);
    fact[0] = factInv[0] = 1;

    for (int i = 1; i <= N; i++) {
        fact[i] = i*fact[i-1] % MOD;
        factInv[i] = modInv(fact[i], MOD);
    }

    int[][] ModuloKGroups = new int[][](K, 0);

    foreach (i; 0..K) {
        if (N <= i) continue;
        int pos = i;
        while (pos < N) {
            ModuloKGroups[i] ~= A[pos];
            pos += K;
        }
    }

    /* 最後にprodの総積をとる */
    long[] prod = new long[](K);

    int[int] count;
    foreach (i; 0..K) {
        int ElemSize = cast(int) ModuloKGroups[i].length;
        foreach (m; ModuloKGroups[i]) count[m]++;

        prod[i] = fact[ElemSize];
        foreach (key, val; count) {
            prod[i] *= factInv[val];
            prod[i] %= MOD;
        }
        count.clear;
    }

    long ans = 1;
    foreach (i; 0..K) {
        ans *= prod[i];
        ans %= MOD;
    }

    writeln(ans);
}

void read(T...)(string S, ref T args) {
    auto buf = S.split;
    foreach (i, ref arg; args) {
        arg = buf[i].to!(typeof(arg));
    }
}

long modPow (long a, long x, const int MOD) {
    // assertion
    assert(0 <= x);
    assert(1 <= MOD);

    // normalize
    a %= MOD; a += MOD; a %= MOD;

    // simple case
    if (MOD == 1) {
        return 0L;
    }

    if (x == 0) {
        return 1L;
    }

    if (x == 1) {
        return a;
    }

    // calculate
    long res = 1L;
    long base = a % MOD;
    while (x != 0) {
        if ((x&1) != 0) {
            res *= base;
            res %= MOD;
        }
        base = base*base; base %= MOD;
        x >>= 1;
    }

    return res;
}

long modInv (long x, const int MOD) {
    import std.exception;
    enforce(1 <= MOD, format("Line : %s, MOD must be greater than 1. Your input = %s", __LINE__, MOD));
    return modPow(x, MOD-2, MOD);
}
```

### 難易度6 トリオ
![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1698063034/pictures/pgbattle2023/D_zzyfw2.png)

なんもわからん！こんなの無理だろ！と文句を言っていたらコンテストが終わりました。。。

<div id="wrap" style="width: 100%; position: relative;">
<iframe style="position: absolute; top: 0; left: 0; width: 100%; max-width: 1000px; height: 100%; border: none;" src="https://www.youtube.com/embed/BNYhmCt0Gn0?list=PLnNY0P_Gy1dd0OiBvt8f70V7n-pldMSB1" title="PG BATTLE 2023 『せんべい 難易度6解説動画』トリオ(Trio)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

chokudaiさんが解説を上げていたので見ましたが、これは本番解けるわけないな...となりました。
しかし、一応状態$O(3^N)$までは見えていたので、悪くはないかな？

## 終わりに
チーム戦も面白いですね。
またこういうコンテストに出たいなぁと思いました。
チーム合計240点で割とよさげなので、なんか商品もらえるといいなぁ

やきとりさん、ryotaさん、お誘いいただきありがとうございました。
