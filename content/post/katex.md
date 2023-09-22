---
title: KaTeX導入してみる
# description: hogehoge

date: 2023-06-23
# hidedate: true
lastmod: 2023-09-20

ogimage: https://res.cloudinary.com/dqoqdn2sk/image/upload/v1687509951/pictures/katex/ogp_y9qwcb.png

tags:
  - katex
archives:
  - 2023
  - 2023-09

math: true
# toc: false
# build: {list: never}
---
## KaTeXを使ってみる

$\LaTeX{}$風の数式を表示できるJavaScriptライブラリ(らしい)である$\KaTeX{}$を導入してみました。
本稿では、$\KaTeX$の紹介と、自分がどうやって導入したかを説明します。

**注意！** 筆者は$\KaTeX{}$及び$\LaTeX{}$に全く詳しくありません。
内容がガバガバかもしれないです。

## 使い方

[ここ](https://tex2e.github.io/blog/latex/mathjax-to-katex)に丁寧に書いてあるので、こっちを参考にしてください。

私は手元で動かしたい人向けにリポジトリから窃盗する手順だけ紹介します。
リポジトリは[こちら](https://github.com/KaTeX/KaTeX)です。

アクセスするとこんな画面になるはずです。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1687500518/pictures/katex/repo_wdawhk.png)

右下の方のReleasesの中のlatestがついてるやつをクリックしましょう。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1687500518/pictures/katex/latest_jwytzg.png)

こんな画面になるはずです。(私が作成してるときはv0.16.7でした。)
tarballかzipをダウンロードして解凍しましょう。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1687500806/pictures/katex/directory_qpbpmf.png)

こんなファイル群が出てくるはずです。
これらをhtmlファイル内で読み込めば使用できます。

下は実際にこのページで使用されている設定です。
(上で貼ったページのものをちょっぴり差し替えただけです。ファイルパスは自分の環境に合わせて変える必要があります。)

```html
<link rel="stylesheet" href="../katex/katex.css">
<script defer src="../katex/katex.js"></script>
<script defer src="../katex/contrib/auto-render.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
  renderMathInElement(document.body, {
    delimiters: [
      {left: "$$", right: "$$", display: true},
      {left: "$", right: "$", display: false},
    ]
  });
});
</script>
```

数式のフォントサイズが気に入らなかったら、head内に次を足してください。(数字はお好みで)

```html
<style>
    .katex {
        font-size: 1em !important;
    }
</style>
```

もしくはdivとかの中だけフォントサイズをいじるっていう方法もあります。

## KaTeXテンプレート

$\KaTeX{}$を使うときは、インライン数式なら`$`で囲みます。
行単位なら`$$`で囲みます。 そうしないとうまく動かないです。
基本の使い方は$\LaTeX{}$と同じなので、$\LaTeX{}$記法はググると良いです。

よく使いそうな数式を紹介します。

1.  行番号あり数式

```html
$$
\begin{equation}
    \int_0^{2\pi{}} \sin{}x dx = 0
\end{equation}
$$
```

\$\$ \\begin{equation} \\int_0\^{2\\pi{}} \\sin{}x dx = 0
\\end{equation} \$\$

2.  複数行に渡る数式(行番号一つ)
```html
$$
\begin{equation}
    \begin{split}
        \sum_{k=0}^{n} {}_n \mathrm{C}_k &= {}_n \mathrm{C}_0 + {}_n \mathrm{C}_1 + \dots \\
        &= 2^n
    \end{split}
\end{equation}
$$
```

\$\$ \\begin{equation} \\begin{split} \\sum\_{k=0}\^{n} {}\_n
\\mathrm{C}\_k &= {}\_n \\mathrm{C}\_0 + {}\_n \\mathrm{C}\_1 +
\\dots \\\\ &= 2\^n \\end{split} \\end{equation} \$\$

3.  デカ括弧
```html
$$
T = 2\pi{} \sqrt{ \frac{h}{g} \left( 1+\frac{2r^2}{5h^2} \right) } \left( 1+\frac{\theta{}^2}{16} \right)
$$
```

\$\$ T = 2\\pi{} \\sqrt{ \\frac{h}{g} \\left( 1+\\frac{2r\^2}{5h\^2}
\\right) } \\left( 1+\\frac{\\theta{}\^2}{16} \\right) \$\$
なお、絶対値やその他の括弧も基本上の例に従う。


4.  インラインデカ数式
```html
通常

$\frac{a}{b}$
$\sum_a^b$
$\int_a^b$

デカ

$\dfrac{a}{b}$
$\displaystyle\sum_a^b$
$\sum\limits_a^b$
$\displaystyle\int_a^b$
$\int\limits_a^b$
```

通常

\$\\frac{a}{b}\$ \$\\sum_a\^b\$ \$\\int_a\^b\$

デカ

\$\\dfrac{a}{b}\$ \$\\displaystyle\\sum_a\^b\$
\$\\sum\\limits_a\^b\$ \$\\displaystyle\\int_a\^b\$
\$\\int\\limits_a\^b\$

これはinline表示をdisplayモードに矯正するコマンドです。一番適したものを使いましょう。

5.  単位をつけるために微妙に間あけるやつ
```html
$1.0\,\mathrm{m}$
```

\$1.0\\,\\mathrm{m}\$

数式環境下での立体は基本的に\\mathrm{}を使っておけば良い。
\$\\KaTeX{}\$が対応してるかなどは知らないが、
物理単位などによっては組み込みやパッケージ等でより良いものが用意されていることがあるので、
それらを調べてから使うとなお良い。


## 終わりに

あくまでテキストベースなの良いですよね。($\TeX{}$記法が再利用性が高いかは置いておくとして)

ただ、思ったより色々と大変でした。
特に、markdownのパースのせいで$\KaTeX{}$が崩されたりするのはかなり罠だと思います。

個人的な使い方としては、htmlに変換した後厳重にチェックした後放流するって感じになりそうです。
