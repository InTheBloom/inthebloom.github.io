---
title: ABC221E - LEQ
# description: 

date: 2023-12-16
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - 一問解説
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

## 問題概要
[問題へのリンク](https://atcoder.jp/contests/abc221/tasks/abc221_e)

長さ$N$の整数列$A = (A_1, A_2, \dots , A_N)$が与えらえる。
$A$の長さ$2$以上の部分列であって、次の条件を満たすものをの総数を$998244353$で割ったあまりを求めよ。

- 部分列の最初と最後の項を$A^\prime{}\_1, A^\prime{}\_k$とするとき、$A^\prime{}\_1 \leq A^\prime{}\_k$が成立する。

制約

- $2 \leq N \leq 3 \times 10^5$
- $1 \leq A_i \leq 10^9$

## 考察
まず感じるのが、ちょっと変わった条件だなということ。
この条件下では、部分列を要求しておきながら、最初と最後しか条件に影響しない。

現段階で私は、部分列を扱うという時点である程度はdpの線を疑ったほうが良いと考えている。
なので、とりあえず典型的なdpに落とし込めないか(簡単な部分問題を見つけられるか)を試す。

こういう問題でdpを考えるときは、大抵の場合前から逐次的に項を部分列に追加するかどうかを見ていくdpになる。
なので、ある段階でそれまでの部分列を特徴づける値(高々2次元くらいが好ましい)がないかを探してみる。
が、いい感じのdpはなさそうである。

そういう時はもっと大枠の数学で数え上げられることがある。
例えば、「実はこの問題の解は重複順列と同じようなアイディアで解ける」というようなケースがこれに当たる。
そう思っていろいろ考えてみるが、やはり「最初の項」の情報を持っておかなければどうにもならないので、そんな都合のいいことはなさそうである。

だが、例えば始点を完全に一つに定めたとする。これなら解ける。
始点を$A_x$、終点を$A_y$とする。
この間の$y-x-1$項は、どのように採用しても部分列は条件を満たす。
すなわち、$2^{y-x-1}$通りになる。これを$x < y$なるすべての$y$について足し合わせれば$O(N)$くらいで解ける。
しかし、この問題においてはどの項も初項になる可能性があり、結局$O(N^2)$となるため間に合わない。

ここで自力考察は力尽きてしまった。

## 解法(解説AC)
実は、最後の始点固定が当たりの方針で、これをうまく利用すると解くことができる。

(どちらでもよいが)簡単のため、終点を固定して考える。終点を$A_j$とするとき、条件を満たす部分列の個数はいくつになるだろうか？
答えは、$i < j$かつ$A_i \leq A_j$なるすべての$i$に対して、$2^{j-i-1}$の和、つまり、数式で表わすと、

$$
\sum_{\substack{i < j \\\\ A_i \leq A_j}} 2^{j-i-1}
$$

である。これを次のように変形する。

$$
\begin{split}
\sum_{\substack{i < j \\\\ A_i \leq A_j}} 2^{j-i-1} &= \sum_{\substack{i < j \\\\ A_i \leq A_j}} \frac{2^{j}}{2^{i+1}} \\\\
        &= 2^{j} \sum_{\substack{i < j \\\\ A_i \leq A_j}} \frac{1}{2^{i+1}}
\end{split}
$$

なんと、数式の裏に隠れて気づきにくいが、$2^{j}$を外に出すことができる。
この形に持ってきたら、なんとなく方針が見えてくる。
要は、$i < j$なる$i$で、条件を満たすものの総和を高速に求められたら良いということになる。
そしてこれは、座標圧縮とセグメントツリー(やBITなど)で達成できる。

具体的な方法の説明をしよう。
座標圧縮によって、元の数列$A$を$[0, N-1]$の元へ写す。
こうすることで、セグメントツリーの$x$個目の要素が元の数列の$x$番目に大きな要素と対応する。
ここに、$A$の前の項から順番に適切な場所へ$1/2^{i+1}$の値を足しこんでいく。

終点が$A_x$であるときの解を求めるには、$A_x$の圧縮先を$x$とするとき、セグメントツリーの$[0, x]$の合計値に$2^{x}$をかけることで得られる。

以上より、全体$O(N \log N)$で解を求めることができる。

## 実装例
```d
import std;

void main () {
    int N = readln.chomp.to!int;
    int[] A = readln.split.to!(int[]);

    solve(N, A);
}

void solve (int N, int[] A) {
    /*
       解説AC: 先に部分列の頭と尻尾を決め打ちする。
       この時、i < j かつ A_i <= A_jである。
       このような部分列は2^{j-i-1}個存在し、すべて条件を満たす。
       2^{j-i-1} = 2^{j} / 2^{i+1}であるから、

       jを一つ固定して考える。尻尾がA_jであって、条件を満たす部分列は2^{j} / sum(1 <= i < j かつ A_i <= A_j) 2^{i+1}通り。
       これは座圧 + 動的区間和取得ができればO(log N)
       具体的には、Aを座圧して列Bを作り、前からj-1までで1/2^{i+1}の計算結果を列のしかるべきところに入れる。

       すべてのjに対して同じことを行うと、O(N log N)に落ちる
     */
    const long MOD = 998244353;

    /* 座圧 */
    auto B = A.dup;
    B = B.sort.uniq.array;
    int[int] comp;

    int f (int x) {
        /* A -> B */
        return comp[x];
    }
    int fInv (int x) {
        /* B -> A */
        return B[x];
    }

    foreach (i, b; B) comp[b] = cast(int) i;

    auto RSQ = new SegmentTree!(long, (long a, long b) => ((a+b)%MOD), () => 0L)(B.length);

    long ans = 0;
    long po = 2;
    long deno = modInv(2, MOD);
    long inv = deno*deno % MOD;
    foreach (i, a; A) {
        ans += po * RSQ.prod(0, f(a)+1) % MOD;
        ans %= MOD;

        long NewVal = RSQ.get(f(a)) + inv;
        NewVal %= MOD;
        RSQ.set(f(a), NewVal);

        po *= 2;
        po %= MOD;
        inv *= deno;
        inv %= MOD;
    }

    writeln(ans);
}
```

セグメントツリーの実装は長いので省略した。

## 感想
いいところまでたどり着けていたので、自力でACとりたかった気持ちもあるが、それ以上に解法に感動した。
この解法は$O(N \log N)$で転倒数を求めるアルゴリズムとほぼ同じだと思った。
しかし、そこに帰着するまでの考察もそこそこ非自明だと感じる。
やはり水色diffはかなり苦しい。

得られる教訓としては、やはり変数固定は大事であるということと、式におこすことに成功したら変数分離を試みるべきという事だろうか。
$j$(尻尾のインデックス)を分離できるというのは負の指数を分数形に直すまで全然気が付かなかった。

また、考察の最初にdpの線を考えていたが、今になって考えてみると、
この問題で問われる部分列は、明らかに最後にとった項やこれまで取った項から計算できる何かで特徴づけされているのではない。
先頭の項のみによって特徴づけられているということからdpの線を外すべきだったなと思う。
なぜなら、ある項で終了できる部分列かどうかというのは最初の項を見ないと判断できないため、どうしても$O(N)$個くらいの情報を持っておかないといけないはずだからである。
