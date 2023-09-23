---
title: InTheDayDreamをhugoに移行するためにやったことたち
date: 2023-09-15
lastmod: 2023-09-23
# ogimage: https://path/to/ogimage.img
tags:
  - hugo
archives:
  - 2023
  - 2023-09
# math: true
# toc: false
---

## 手動ブログ運営はしんどい！
さて、皆様はhatenablogなどのサービスを全く介さずに、単にインターネット上の置き場所にWebページを展開したことがありますでしょうか？
私がしばらく運営している当ブログは、github pagesを利用した完全な手動運用のサイトです。

まあこれが辛いんです結構

具体的に何がしんどいのかと言うと、ページ公開に伴う面倒な作業がとにかく多いんですね。
例えば一つ公開したいページがあるとき、色んな所にリンクを貼り付ける必要があります。

また、すべてのCSSや、各ページのヘッダ(htmlの`<head>`タグの中身)とかも全部用意しなければいけません。
これがやりたいという人はいいですけど、結構面倒くさくて記事更新のモチベーションがゴリゴリ減らされるわけです。

私は現在競技プログラミングに取り組んでいて、新しい知見を得ることが結構ありますが、わざわざ一つの問題に対して記事を建てるなんて面倒くさくてやりたくないわけです。
これはかなりのデメリットです。

私はフロントエンドエンジニアでもなんでもなく、gitの使い方すらガバガバな初心者ですから、大抵の実装はその場しのぎで後からいじるとかはやりたくないわけです。

現在私のブログはもう触りたくないけどなーみたいなゴミがたくさん転がっているひどい現状です。
しかも、折角書いた記事も全然再利用性がないなーと感じています。
私の理想を言うなら、できるだけmarkdownなどでプレーンテキストデータに近い形で記事をおいておきたいわけです。これにスタイルシートとかを当てたり、他のフォーマットに変換するのは割と容易ですし。

というわけで、このあたりの面倒くさい作業をhugoに丸投げしちゃおうと言う感じです。

## hugoとは？
> The world’s fastest framework for building websites
> 
> Hugo is one of the most popular open-source static site generators. With its amazing speed and flexibility, Hugo makes building websites fun again.

以下google翻訳
> ウェブサイトを構築するための世界最速のフレームワーク
> 
> Hugo は、最も人気のあるオープンソースの静的サイト ジェネレーターの 1 つです。 Hugo の驚くべきスピードと柔軟性により、Web サイトの構築が再び楽しくなります。
>
> [hugo公式サイト](https://gohugo.io/)より

だそうです。すごく簡単に言うと、WordPressなどのようなCMSと違い、設計図のようなものから静的Webサイトを構築するソフトウェアです。
似たようなソフトウェアに[jekyll](http://jekyllrb-ja.github.io/)とかがあります。

実は、以前jekyllをワチャワチャしてみようと思ったのですが、その時はよくわからずに諦めてしまったことがあります。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Jekyllなんか知らんけど動かない</p>&mdash; In (@UU9782wsEdANDhp) <a href="https://twitter.com/UU9782wsEdANDhp/status/1639909860077871106?ref_src=twsrc%5Etfw">March 26, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

これはjekyllがプログラミング言語rubyとかなり密接につながっていることが原因の一つです。
jekyllはちょっと動かしてみたいなーってだけでなんだか色々インストールだの何だのを要求されます。

私はプログラミングのことなんか全然わかりませんから、普通にキレてやめました。

一方、hugoはあまりややこしいことをしなければgo言語の処理系を用意する必要すらないということで、割と良さそうだなと思って試しています。
もちろんソースからビルドとかしたいなら処理系が必要ですが、各プラットフォーム向けにバイナリが配布されているようなので、それでなんとかします。

## let's try!
とりあえずバイナリを[ここ](https://github.com/gohugoio/hugo/releases)からひったくってきます。
Windowsの方などは`hugo_extended_0.118.2_windows-amd64.zip`っていうやつをパクってきたらいいと思います。(2023/09/15)
Linuxなどの方は、ディストリビューションのパッケージとして公開してくれてるやつを引っ張ってきても良いと思います。

私はUbuntu 22.04.3 LTS (64bit)ですので、aptからパクってくることもできます。
```bash
sudo apt update
sudo apt install hugo
```
ただ、なんか微妙に古かったので、さっきのリンクからパッケージをパクってきて、それをaptに渡しました。

`hugo_extended_0.118.2_linux-arm64.deb`をダウンロード
```bash
sudo apt install path/to/hugo_extended_0.118.2_linux-arm64.deb
```
インストールできない？<span style="text-decoration: line-through">俺もわからん</span>
```bash
hugo version
# -> hugo v0.118.2-da7983ac4b94d97d776d7c2405040de97e95c03d+extended linux/amd64 BuildDate=2023-08-31T11:23:51Z VendorInfo=gohugoio
```
だそうです。

使い方は次のリンクをさっと見ていきましょう。ちなみに私は細かい使い方とか難しいことは何も分かっていません。
- [公式サイト(英語)](https://gohugo.io/documentation/)
- [さくらのナレッジ](https://knowledge.sakura.ad.jp/22908/)
- [私は読んでないけど、なんかドンピシャなやつあった(qiita)](https://qiita.com/peaceiris/items/ef38cc2a4b5565d0dd7c)
- [こっちは読んだやつ(Zenn)](https://zenn.dev/harachan/articles/a043e9a756cae4)
- [読んだやつパート2(Zenn)](https://zenn.dev/harachan/articles/21d8f3a9f2ca4e)

もっとちゃんと知りたい人はちゃんと公式サイトを浚いましょうね。

さて、サイトテーマを決めましょう。hugoは公式サイトで有志が作ったテーマをいっぱい公開してくれています。
[ここ](https://themes.gohugo.io/)で物色しましょう。

テーマってなんやねんと思う方もいると思います。
私の浅いイメージ的には、
- hugo : ユーザーが特定のディレクトリに配置したファイルからいろんなデータなどを抜き出し、それを操作する統一的なインターフェースとかを提供する。(例えば、配置したmdファイルからテキストを抜き出して、{{content}}みたいな記法で他のファイルに挿入できるようにするとか)
- hugoテーマ : hugoが提供してくれる機能をいい感じにデコったりしてくれる。

みたいな感じなのかな？

なので、hugo側でデフォルトで提供されているものの、テーマがそれに対応していないこともあります。readmeとかを見てちゃんと決めましょう。リポジトリを見に行けば大抵デモページが用意されています。

## 私がやったこと
さて、本題です。
ここからは、私がこのサイトを構築するためにやったことを色々書きます。
どちらかと言うと自分が忘れたときのためのものなので、大して参考にならんかもしれません。
正直に言うと、このセクションのためにこの記事を書き始めました。

### テーマ選択
テーマは[simplog](https://themes.gohugo.io/themes/simplog/)を選択します。
主な選定理由はタグやカテゴリなどの便利機能をサポートしつつ、シンプルで使いやすそうだからです。

さて、今まで構築していたリポジトリをローカルにコピーしておいて、破壊しましょう。
```bash
cp -r ./ path/to/archive/
rm *
hugo new site . --force

# 以下実際のログ
Congratulations! Your new Hugo site was created in /home/in/dev/git/myblog.

Just a few more steps...

1. Change the current directory to /home/in/dev/git/myblog.
2. Create or install a theme:
   - Create a new theme with the command "hugo new theme <THEMENAME>"
   - Install a theme from https://themes.gohugo.io/
3. Edit hugo.toml, setting the "theme" property to the theme name.
4. Create new content with the command "hugo new content <SECTIONNAME>/<FILENAME>.<FORMAT>".
5. Start the embedded web server with the command "hugo server --buildDrafts".

See documentation at https://gohugo.io/.
```
次に、テーマをインストールします。よく分かってないですが、とりあえず書いてあるとおりに進めます。(なんだよsubmoduleって)
```bash
git submodule add https://github.com/michimani/simplog.git ./themes/simplog

# 以下実際のログ
Cloning into '/home/in/dev/git/myblog/themes/simplog'...
remote: Enumerating objects: 2538, done.
remote: Counting objects: 100% (664/664), done.
remote: Compressing objects: 100% (262/262), done.
remote: Total 2538 (delta 288), reused 625 (delta 280), pack-reused 1874
Receiving objects: 100% (2538/2538), 3.09 MiB | 6.19 MiB/s, done.
Resolving deltas: 100% (1201/1201), done.
```

### 全体の設定(hugo.toml)
さて、驚くべきことに、これで大半の作業は終了です。
後は設定やテーマをいじりましょう。

まず、ルート直下にある`hugo.toml`を設定します。(hugoのバージョンによっては`config.toml`がデフォだったりする)
私の設定を貼り付けておきますが、このあたりはテーマに依存する項目も多いですから、いろんな情報を見てみると良さそうです。

あと、一応注意喚起ですが、私は雰囲気で設定したので多分いくつかおかしいです。
```toml
baseURL = 'http://inthebloom.github.io/'
languageCode = 'ja'
DefaultContentLanguage = "ja"
title = "InTheDayDream"
description = "InTheBloom's Website"
author = "InTheBloom"

theme = "simplog"
paginate = 10
summarylength = 20
enableInlineShortcodes = true
ignoreErrors = ["error-remote-getjson"]
googleAnalytics = ""
disqusShortname = ""

[markup]
  [markup.goldmark]
    [markup.goldmark.renderer]
      unsafe = true

[menu]
  [[menu.main]]
    identifier = "home"
    name = "Home"
    url = "/"
    weight = 1

  [[menu.main]]
    identifier = "tags"
    name = "Tags"
    url = "/tags/"
    weight = 2

  [[menu.main]]
    identifier = "categories"
    name = "Categories"
    url = "/categories/"
    weight = 3

  [[menu.main]]
    identifier = "archives"
    name = "Archives"
    url = "/archives/"
    weight = 4

  [[menu.main]]
    identifier = "about"
    name = "About"
    url = "/about/"
    weight = 5

[taxonomies]
  category = "categories"
  tag = "tags"
  archive = "archives"

[services]

  [services.instagram]
    disableInlineCSS = true

  [services.twitter]
    disableInlineCSS = true

[params]
  subtitle = ""
  colorTheme = "default"
  description = ""
  twitter = "UU9782wsEdANDhp"
  customCSS = "/css/custom.css"
  adobeFontsKitId = ""
  headerImagePath = ""

  [params.enabled]
    comment = true
    summary = true
    toc = true
```
ポイントとしては、mdファイル中の生のhtmlを反映するようにunsafe機能を有効にしてあります。また、カスタムcssを有効にしてあります。カスタムcssは`/static/`以下が検索されてるっぽい？

### カスタムcss(static/css/custom.css)

cssは気に入らないものをオーバーライドしましょう。
ブラウザの調査機能などを使うと比較的簡単にどれを変えればよいかわかります。
```css
img {
    width: auto;
    max-width: 100%;
    height: auto;
    border: 1px solid black;
}

#content h2 {
    padding-bottom: 0.5em;
    border-bottom: 1px solid gray;
    margin-top: 3em;
}

#main-menu-nav-items {
    grid-template-columns: repeat(5, 20%);
}

.block-separater {
    margin-top: 50px;
}

#content-footer {
    margin-top: 70px;
}
```

### テンプレートのオーバーライド(layouts/)

テーマに用意されているテンプレートもいじりましょう。
`themes/`以下の`layouts`ではなく、ルート以下の`layouts`に同様のファイルを用意してあげることで、差異があったら優先的に使ってくれます。
```bash
cp -r themes/simplog/layouts/* ./layouts/
```

#### KaTeXの設定
[これ](https://katex.org/docs/autorender.html)を利用する。
要はCDNからKaTeXを読み込んで、JSでロード時に変換しているっぽい？
詳しいことはたくさん記事が存在するから各自でやりましょう。

まず諸々の設定を入れ込んだpartialを作成しよう。
```bash
touch layouts/partials/math.html
```
中身はこれ
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.css" integrity="sha384-GvrOXuhMATgEsSwCs4smul74iXGOixntILdUW9XmUC6+HX0sLNAK3q71HotJqlAn" crossorigin="anonymous">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.js" integrity="sha384-cpW21h6RZv/phavutF+AuVYrr+dA8xD9zs6FwLpaCct6O9ctzYFfFr4dgmgccOTx" crossorigin="anonymous"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/contrib/auto-render.min.js" integrity="sha384-+VBxd3r6XgURycqtZ117nYw44OOcIax56Z4dCRWbxyPt0Koah1uHoK0o4+/RRE05" crossorigin="anonymous"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        renderMathInElement(document.body, {
          // customised options
          // • auto-render specific keys, e.g.:
          delimiters: [
              {left: '$$', right: '$$', display: true},
              {left: '$', right: '$', display: false},
              // {left: '\\(', right: '\\)', display: false},
              // {left: '\\[', right: '\\]', display: true}
          ],
          // • rendering keys, e.g.:
          throwOnError : false
        });
    });
</script>
```
各ページで読み込むための設定をしよう。
フロントマター(各記事先頭の設定)や、`hugo.toml`で記述したパラメータを参照してオンオフを切り替えるようにした。
`layouts/partials/header.html`あたりにでも埋め込もう。
```html
<!-- KaTeX Settings -->
{{ if or .Params.math .Site.Params.math }}
{{ partial "math.html"}}
{{ end }}
```
これでページ先頭に`math: true`などと書けばKaTeXを使ってくれる。

余談ではあるが、markdownとKaTeXを同時に運用するのは相性的にあまり良くない。というのも、markdownパーサーがKaTeX記法と衝突することがあり、この場合htmlのロード後に発動するKaTeXが必ず負ける。
いろんなケースがあるので、問題が発生したらその都度解決策を考える必要があり、かなり面倒くさい。
マジで誰かなんとかしてくれ

#### Table Of Contentsを強調する
記事の先頭にTOC(Table Of Contents)を設置してくれる機能がある。しかし、simplogのデフォルトはあまりにもわかりにくいと感じるので、改造する。
TOCは`layouts/_default/single.html`をいじれば良さそう。
これが元
```html
<!--TOC-->
{{ if eq .Site.Params.Enabled.Toc true }}                                                                                
{{.TableOfContents}}
{{ end }}
```
改造後
```html
<!--TOC-->
{{ if and .Site.Params.Enabled.Toc (not (eq .Params.Toc false)) }}
<div style="padding: 0em 1em; margin-bottom: 5em; margin-top: 0.7em;">
    <p style="font-size: 1.3em;">Table Of Contents</p>
{{.TableOfContents}}
</div>
{{ end }}
```
ついでに各記事内でTOCを制御できるようにした。先頭メタデータで`toc: true/false`で制御できる。

#### 記事タイトルをh1にする
何故か最大の見出しがh2にされていて、自作cssが適用されちゃうのが嫌なのでh1に差し替える。
いじるファイルは同様に`layouts/_default/single.html`
あと、ついでに公開日のところをいじる。

before
```html
<!--Title-->
<h2>{{.Title}}</h2>
{{ if or (not .Params.hideDate) (eq .Params.hideDate false) }}
<span class="sub">{{.Date.Format "2006-01-02"}}</span><br>
{{ end }}
```
after
```html
<!--Title-->
<h1>{{.Title}}</h1>
{{ if or (not .Params.hideDate) (eq .Params.hideDate false) }}
<span class="sub">Published on {{.Date.Format "2006-01-02"}}</span><br>
<span class="sub">Last Modified {{.Lastmod.Format "2006-01-02"}}</span>
{{ end }}
```
何気にパラメータ`lastmod`が追加された。
先頭メタデータ内で、`lastmod: 2006-01-01`みたいな感じで指定してあげると良さそう
なお、`lastmod`が設定されていないときはデフォルトで`date`に合わせてくれた。気が利くなぁ

#### ogpの画像の参照先をいじる
ogpというのは、SNSなどにリンクを貼ったときにいい感じにプレビュー画像みたいなのを表示してくれるやつです。
デフォルトでは相対パスで検索しているようなので、ここを絶対パスを使うようにしてみます。
`layouts/partials/head.html`をいじります。

before
```html
<meta property="og:image" content="{{ $site.BaseURL }}{{ . }}">

<meta property="og:image" content="{{ $site.BaseURL }}{{ . }}">                                                          
```
after
```html
<meta property="og:image" content="{{ . }}">

<meta property="og:image" content="{{ . }}">
```
これで、メタデータで`ogimage: path/to/image`で指定できます。ただし絶対パスが必要になるので、外部のURLを指定すべきです。
ついでにデフォルトのogpimageを設定しておきましょう。`{{ $site.BaseURL }}/images/featured_image.jpg`という設定になっているようなので、この場所、名前で適当に作って配置します。

...と思ったが、メタモンが発生してやる気がなくなったのでやめた。

### faviconを用意する
ブラウザなどでサイト名の横に表示されるちっちゃい画像のことをファビコンと呼ぶ。
これを用意する。
```html
<link rel="apple-touch-icon" sizes="180x180" href="{{ relURL "images/apple-touch-icon.png" }}?c={{$cacheHashBase}}">
<link rel="icon" type="image/png" sizes="32x32" href="{{ relURL "images/favicon.png" }}?c={{$cacheHashBase}}">
<link rel="icon" type="image/png" sizes="16x16" href="{{ relURL "images/favicon-16x16.png" }}?c={{$cacheHashBase}}">
```
`layouts/partials/head.html`にこのような記述があった。この名前とサイズで用意しよう。
なんかよくわからないが`/static/images/*.png`に用意したら反映された。

### aboutページを用意する
`contents/about.md`を用意すると動きました。
細かいことには触れません。

## 大体完成！
後はルートディレクトリで`hugo server`を実行すると`http://localhost:1313`にアクセスすると見れます。
ビルドするときは`hugo`を実行すれば`public/`に静的サイトが作成されます。

適当にpushしときましょう。

メタデータのテンプレートはこんなかんじかな？
```yaml
---
title: title
date: yyyy-mm-dd
# lastmod: yyyy-mm-dd
# ogimage: https://path/to/ogimage.img
tags:
  -
categories:
  -
archives:
  -
# math: true
# toc: false
---
```

## 追記
**注意**このセクションに書いてあることとそれまでのセクションで書いてあることが重複していたり、矛盾している場合、こちらがより正しい。

実用的にはほとんど何もしなくてもいい感じにしてくれるほうが良いなと思った。
記事作成でメタ情報の追加が面倒くさそうだなと思ったので、分類をタグのみに絞ることにした。

まず、`hugo.toml`の内容を修正する。
具体的には、次の内容を消す
```toml
# [taxonomies]にある
  category = "categories"

# [menu]にある
  [[menu.main]]
    identifier = "categories"
    name = "Categories"
    url = "/Categories/"
    weight = 4
```
すると、上のメニューバーが一枠開くので、CSSを修正する。
`/static/css/custom.css`を次のように修正する。
```css
/* #main-menu-nav-itemsにある */
/* 次を消す */
grid-template-columns: repeat(5, 20%);

/* 次を追加 */
grid-template-columns: repeat(4, 25%);
```
これでタクソノミーを減らすことができた。hugo的にはカテゴリとタグを特別使い分けてなさそう(知らんけど)ので、許されるんじゃないかな

### 全文検索をパクる
[まくまくhugoノート](https://maku77.github.io/p/p4n5m3i/)を見ていたら、全文検索を実装できるらしい。
この機能があれば過去記事とかから情報を検索できてすごく便利だなと思ったので、導入することにした。

ほとんど上のコードをパクり、`/layouts/shortcodes/search.html`としてファイルを作成し、`search.md`というファイルでショートコードを取り込むことにした。
内容は省略するとして、`search.md`の内容を載せておく。
```markdown
---
title: サイト内全文検索
hidedate: true
toc: false
_build: {list: never}
---
サイト内の文章からインクリメント検索が可能です。
下の入力欄に入力することで検索ができます。

本ページは検索の対象外になっています。

<!-- searchのショートコードを入れる(ここに入れるとここでも無限再帰になってしまう。) -->
```
`_build: {list: never}`というのをすると、一覧系のページに表示されなくなるらしい。これをしないとビルドのときに無限再帰になってしまう。

さて、これで上のメニューバーに検索を入れたくなった。
CSSを再度修正し、先程消したカテゴリの分を作る。
```css
grid-template-columns: repeat(5, 20%);
```
```toml
  [[menu.main]]
    identifier = "search"
    name = "Search"
    url = "/search/"
    weight = 4
```
出来上がりは[検索ページ](/search/)で確認できる。
また、詳細なファイルの内容はgithubのリポジトリにおいてある。

それはそれとして、さっき直したものをまた直すとは計画性のないアホである。

### 関連タグの表示を調整する
便利な機能として、関連タグの記事を下の自動リンクしてくれる機能があるが、その見た目があまり良くなかった。
ので、改造する。
`/layouts/partials/related-tag-posts.html`を次のように修正する。
```html
<!-- 次を削除 -->
<h4>Other posts tagged by "{{ $t }}"</h3>

<!-- 次を追加 -->
<h4 style="font-size: 1.3em;">Other posts tagged by "{{ $t }}"</h4>
```
これ修正して気づいたが、オリジナルのコード閉じタグ間違ってない？

それと同時にCSSに次のものを追加する。
```css
.related-tag-category-list {
    margin-top: 5em;
}
```
これで幅と可読性がいい感じになった。

### 過去記事の移植
今日(9月23日)、まだ完了していませんが、pandocでhtmlをmarkdownに変換して手作業で移植しています。つらたん。

### (デプロイ後に発覚)faviconの謎の不具合
なんか`layouts/partials/head.html`のfaviconのhrefの後ろに`c=?<謎の文字列>`みたいな謎の処理が入っているが、何故かgithub pages上でうまく動かなかった。
よって、これを削除した。
どういう影響があるのか知らない。

2023-09-23追記: 多分キャッシュ関連の何かだと思うんだけど、調べてもよくわからなかった。まあ動かなかったのは事実なのでfaviconくらい別にいいでしょの顔

ただ不思議なのは、cssとかもこれをやる設定になっているように見えること。なぜかfaviconだけうまく動かない。

### win機でpullしたときに発覚したこと
(これはhugoの記事として適切ではないかもしれません。)

最初にsimplogを`git submodule`してとってきましたが、他のPCでこのリポジトリをクローンした場合、自動的にsubmoduleまでとってきてくれるわけではないようです。
[これ](https://maku77.github.io/p/dsctaq7/)を参考にして、次のコマンドを打ったらうまくいきました。

```bash
git submodule init
git submodule update
```

### フロントマターのテンプレート
最後に改訂版フロントマターのテンプレートを載せておく。
```yaml
---
title: hogehoge
# description: hogehoge

date: yyyy-mm-dd
# hidedate: true
# lastmod: yyyy-mm-dd

# ogimage: https://hoge/fuga/piyo.img

tags:
  - hoge
archives:
  - yyyy
  - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---
```

## 終わりに
なんだかんだ1週間以上色々やってた。
疲れました。

これでいろんな記事を作りやすくなった。嬉しい。
