---
title: gVimのススメ + 私のVim操作
# description: 

date: 2025-12-07
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - vim
  - UECPG Advent Calendar
archives:
  - 2025
  - 2025-12
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## はじめに
本エントリは[電通大プログラミング教室 Advent Calendar 2025](https://adventar.org/calendars/12393)の8日目です。
少々用事がありまして公開がクソ遅くなりました。JSTで8日中なのでセーフという説にかけます。

<div style="overflow: scroll;">
    <iframe src="https://adventar.org/calendars/12393/embed" width="620" height="362" frameborder="0" loading="lazy"></iframe>
</div>

昨日はYamakyuさんの「[バスナムのご案内[成果物紹介]](https://zenn.dev/yamakyu/articles/a79379227bae77)」でした。
バスの管理番号から詳細情報を見れるということをはじめて知りました。
調布周辺を活動拠点にしている人ならとても便利なアプリケーションですね。あいにく私は電車移動しかしないのですが...

さて、話題を私のエントリの方に変えます。
今日は私がメインで使っているテキストエディタ「vim」の小話をしていきます。
ブログのアーカイブを見ればわかるのですが、競技プログラミング以外の話題を書くのが9カ月ぶりくらいで、かつこのブログをしばらく更新していませんでした。
ということであまりクオリティに自信がありませんが、ぼちぼちやっていこうと思います。

## Vimとは
Vim（ヴィム）とは、コマンドラインなどで動作するテキストエディタです。windowsのメモ帳やvscodeなどの仲間です。Microsoft Wordの仲間ではありません。

[Vimのwikipedia](https://ja.wikipedia.org/wiki/Vim)によると、Vim出生は1987年7月で、ブラム・ムールナーがviという既存のテキストエディタを別の環境で使うために作成したクローン（Vi IMitation）であったそうです。
そこから2025年現在に至るまで実に38年間数えきれないほど多くの人に愛されてきた歴史あるソフトウェアです。

Vimは主にコマンドラインで動作するため、グラフィカル環境のありなしに関わらず、非常に様々な環境にプリインストールされています。
普段GUIテキストエディタを使用している人には「Gitを操作したついでに使わされるやつ」「大学で教えられたけど意味不明で投げ捨てたやつ」「信者が怖いやつ」など様々な見られ方をしているでしょう。

私のお気に入りのVim動画を2つ紹介します。興味があれば見てみてください。

<iframe width="500" height="300" src="https://www.youtube.com/embed/P7LNU9HYr7M" title="プログラミルクボーイ「Vim」" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
<iframe width="500" height="300" src="https://www.youtube.com/embed/KpDTFSijA6U" title="「テキストエディタ戦争」とは何か？#168" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Vim入門の現状
Vimに入門してみよう！という記事はネット上を探すと本当に無限に出てきます。
その要因として、
* Vimを使っている強い人に憧れている人が多い
* Vimはめちゃくちゃ軽い
* Vimは他のテキストエディタと比べて圧倒的に効率よく操作できる（という説がある）

などがあるでしょう。こんな本もあります。

![実践Vim](/images/uecpg-advent2025/jissenvim.png)
写真: [https://www.amazon.co.jp/dp/4048916599](https://www.amazon.co.jp/dp/4048916599)

しかし布教活動もむなしく、Vimは「扱いが難しいテキストエディタ」「古臭いもの」「ガチ勢しか触っていないもの」みたいな印象を持たれているフシがあります。（これは定量的なデータではなく、肌感です。）
今見ているその端末で「Vim 入門」とググってみてください。この入門記事の多さがVimのハードルの高さをそのまま表しています。

Vimは他のテキストエディタとは全く異なる操作感を持っており、いきなり移行、入門をしようとしてもギャップに苦しむことはほぼ確定です。

その要因の一つに「モード」というものがあります。Vimは非GUI環境でも動くソフトウェアですから、全ての操作をキーボードで行える必要があります。
全ての操作というのはカーソルの移動、検索、コマンド実行などを含んでいます。
そのため、「今はカーソル移動だけできるモード」や「今は文字入力だけできるモード」などを適宜切り替えながら使わないといけません。
何も知らない人がVimを使おうとすると、多くの場合一文字も入力することができません。なんならVimを終了することすらできません。

## gVim
さて、なぜVimが難しいのかというのをざっくり理解してもらったところで、私が思うVim入門のベターな方法をご紹介します。
それはズバリ**gVim**です。
私はWindowsなのでそれ以外の環境でうまく動くかはよくわかりませんが、Vimの公式webサイトでgVimというGUI版Vimがあります。[ダウンロードページ](https://www.vim.org/download.php)

現在最新バージョンが9.1.1825のようです。ダウンロードして適当にインストールすると、デスクトップに「gVim 9.1」「gVim Easy 9.1」「gVim Read only 9.1」という3つのショートカットが生成されます。

![gvim](/images/uecpg-advent2025/gvim.png)

これをダブルクリックすることで開くことができます。
全然関係ないんですが、グラセフとスゲー似てます。

![gta5](/images/uecpg-advent2025/gta5.png)

### gVim Easy
gVim EasyとはVimから「モード」の概念を取り払った機能制限版です。Windowsのメモ帳とほとんど同じで、クリックや矢印キーでカーソル移動するだけです。
デフォルトでコードハイライトとかをしてくれる（たしかそう）ので、まずはVimと触れ合ってみたい方はここからどうぞ。
アプリケーションの見た目は以下の感じです。

![gvimeasy](/images/uecpg-advent2025/gvimeasy.png)

### gVim
つぎにgVimの紹介をします。これはコマンドライン版Vimとほぼ同じ動作をするものです。
ただしコマンドライン版との一番の違いは、上のツールバーから操作を行うことができることと、デフォルトでクリック操作がサポートされていることです。

Vimの基本操作をおぼえて、いざ実践投入してみるというときはこれを使うと良いと思います。
コマンドライン版のVimの場合、よく使う操作のコマンドチートシートを用意していないと、思うように操作できなくてイライラするかと思います。
ですがgVimなら最悪上のメニューからやりたいことを探せば大体できるためストレスフリーだったりします。
全部をいっぺんにではなく、段階的におぼえることが可能ということです。
最初はカーソル移動系を練習することになるかと思いますが、それに慣れるまではファイル保存や編集ファイルの切り替えなどはツールバーから行うといった感じです。
アプリの見た目はgVim Easyと同じです。

### gVim Read only
これはgVimを読み込み専用のオプションをつけて開くショートカットです。このショートカットから直接開いたファイルは書き込み時に警告が出ます。
正直無理やり書き込めるし、いらないです。

ということで、Vimに入門してみたい人はgVimおすすめです。いかがでしたか？


## Vim経験者向け部分
ここまでで前半は終わりで、以下はVim経験者に向けて自分の知見を共有していこうと思います。

私は大学入学したころにVimに入門して、そこから3年ほどVim一筋でやっています。
しかし他人とVimについての話をあまりしたことがなく、Vim操作がかなりガラパゴス化している可能性があります。

なので自分の認識を正してくれる人を募集するとともに、3年のVim経験を生かして少しでも役立つ情報を発信できればと思う次第です。
前提条件として、vimrcはこんな感じです。（ところどころ壊れていたりするので参考程度にしてほしい）

<style>
.gh-card-container{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;border:1px solid #e1e4e8;border-radius:6px;padding:16px;margin:1.5em 0;line-height:1.4;background:#fff;max-width:600px}
.gh-card-container a{text-decoration:none;color:inherit}
.gh-card-header{display:flex;align-items:center;gap:8px;margin-bottom:8px}
.gh-card-repo-name{font-weight:600;font-size:1.1em;color:#0366d6}
.gh-card-repo-name:hover{text-decoration:underline}
.gh-card-description{color:#586069;font-size:.9em;margin-bottom:16px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;min-height:2.5em}
.gh-card-footer{display:flex;align-items:center;gap:16px;font-size:.8em;color:#586069}
.gh-card-language-color{width:12px;height:12px;border-radius:50%;border:1px solid #d1d5da;margin-right:4px;display:inline-block;vertical-align:middle}
.gh-card-owner{margin-left:auto;display:flex;align-items:center;gap:6px}
.gh-card-owner img{width:24px;height:24px;border-radius:50%}
</style>
<div class="gh-card-container">
  <a href="https://github.com/InTheBloom/vim-config" target="_blank" rel="noopener noreferrer">
    <div class="gh-card-header">
      <svg aria-hidden="true" height="16" viewBox="0 0 16 16" width="16"><path d="M2 2.5A2.5 2.5 0 0 1 4.5 0h8.75a.75.75 0 0 1 .75.75v12.5a.75.75 0 0 1-.75.75h-2.5a.75.75 0 0 1 0-1.5h1.75v-2h-8a1 1 0 0 0-.714 1.7.75.75 0 0 1-1.072 1.05A2.495 2.495 0 0 1 2 11.5Z M4.5 1h8V.75H4.5a1.75 1.75 0 0 0 0 3.5h8V3h-8a1.75 1.75 0 0 0 0-3.5Zm-2.25 8a.75.75 0 0 0 .75.75h4.5a.75.75 0 0 0 0-1.5h-4.5a.75.75 0 0 0-.75.75Z"></path></svg>
      <span class="gh-card-repo-name">InTheBloom/vim-config</span>
    </div>
    <div class="gh-card-description">My vim setting files.</div>
    <div class="gh-card-footer">
      <span><span class="gh-card-language-color" style="background:#ededed"></span>Vim Script</span>
      <span title="Stars">⭐ 0</span>
      <span title="Forks">⑂ 0</span>
      <span class="gh-card-owner"><img src="https://avatars.githubusercontent.com/u/112522354?v=4" alt="InTheBloom">InTheBloom</span>
    </div>
  </a>
</div>

(generated with [https://insane.nao-kun.com/github-card](https://insane.nao-kun.com/github-card))

タイピング動画作りました。いつもこんな感じでVimを使っています。
<iframe width="500" height="300" src="https://www.youtube.com/embed/7Rd1QFlO39o" title="タイピング動画" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

よく使う便利なコマンドを適当に列挙してみてみます。

### カーソル大雑把移動系
* `gg`（一番上に移動）
* `shift + g`（一番下に移動）
* `ctrl + d`（半ページ下に移動）
* `ctrl + u`（半ページ上に移動）
* `zz`（現在のカーソル位置を画面中央へ）

### カーソル精密移動系
* `f の後 (文字)`（行内で右側の最も近い指定文字へジャンプ）
* `shift + f の後 (文字)`（行内で左側の最も近い指定文字へジャンプ）
* `t の後 (文字)`（行内で右側の最も近い指定文字の前にジャンプ）
* `shift + t の後 (文字)`（行内で左側の最も近い指定文字の前にジャンプ）
* `0`（行先頭移動）
* `shift + 4`（行末移動）
* `shift + i`（行先頭へ移動しINSERTに移る）
* `shift + a`（行末へ移動しINSERTに移る）
* `shift + (`（対応する括弧へジャンプ）
* `gj`（表示上の1行下に移動）
* `gk`（表示上の1行上に移動）
* `:(数字) の後 enter`（指定行番号へジャンプ）

### 入力系
* `shift + . shift + .`（カーソルの行を1インデント上げる）
* `shift + , shift + ,`（カーソルの行を1インデント下げる）
* （INSERT時）`ctrl + t`（カーソルの行を1インデント上げる）
* （INSERT時）`ctrl + d`（カーソルの行を1インデント下げる）
* `u`（一手戻る）
* `ctrl + r`（一手進む）
* `o`（次の行を作成）
* `shift + o`（前の行を作成）
* `dd`（現在の行をヤンクして削除）
* `yy`（現在の行をヤンク）

### ヴィジュアルモード系
* `v`（ヴィジュアルモードにする）
* `shift + v`（行単位のヴィジュアルモードにする）
* `ctrl + v`（矩形ヴィジュアルモードにする）
* （矩形ヴィジュアルモードで選択後）`shift + i`（矩形の先頭に一斉挿入できるINSERT）
* （矩形ヴィジュアルモードで選択後）`shift + c`（矩形領域を削除 + 矩形の先頭に一斉挿入できるINSERT）

### ウィンドウ系
* `:sp`（ウィンドウの水平分割）
* `:vsp`（ウィンドウの垂直分割）
* `ctrl + w の後 jklhいずれか`（その方向のウィンドウへ移動）
* `ctrl + w の後 shift + -`（ウィンドウサイズを均等にする）

### バッファ系
* `:bn`（次のバッファを表示）
* `:bp`（前のバッファを表示）

### タブ系
* `:tabnew`（新規タブ）
* `gt`（次のタブへ移動）

思ったより思い出せなくて驚きました。もう少しある気がしますが、ある程度無意識で使ってみるらしいです。
逆に3年使っている人が覚えているコマンド数がこの程度ということはなかなか意外なのではないでしょうか。
新米Vimmerの役に立てば幸いです。

逆にVim上級者の人は「これ便利なんじゃない」「この入力こうするとサボれる」というのがあれば是非教えてください。

## おわりに
Vim使ってみてね。
明日はYamakyuさんの記事で、コメントに「css wakarnai」とあります。お楽しみに。
