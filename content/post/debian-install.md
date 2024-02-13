---
title: Ubuntuが死んだのでDebianをインストールする

date: 2024-02-13

tags:
  - mementos
  - linux
archives:
  - 2024
  - 2024-02

---
## はじめに
2023年の2月あたりからおよそ1年間にわたりUbuntu22.04.3LTSを使用してきた。

ここ一週間ほど、急にネットワーク接続がおかしくなったり、システムの電源を切ることすらままならなくなる事態が発生してしまった。
いくつか解決策を調べてみたり、応急手当として手元にあったUSBのwifiアダプターをさして(何故かこちらを経由するとうまく接続できる場合があったのである。しかし、特定のネットワークにはつながらないので意味不明であった。)みたりした。

しかし、私の知識と熱意では到底解決できそうにないし、そもそも私がコストをかけるべきはこんなところではないだろうと思い始めてきたところで、OSの入れ替えを決行することにした。

## Debianを使ってみる
2023年6月10日にリリースされたという[Debian12 bookworm](https://www.debian.or.jp/)を試してみることにした。
主な理由は、

1. Ubuntuに近い操作感であるだろうと思ったから。
2. 違うディストリビューションを使ってみたかったから。

といったところだろうか。

## インストール備忘録
また何かしらでトラブって、インストール作業が発生するかもしれないので、備忘録を残しておく。

### インストールメディア作成 + インストール
まずは適当にインストールメディアを作成する。イメージファイルを[このリンク](https://www.debian.org/distrib/netinst.en.html)から落としてきて、手元のwin機にて[Rufus](https://rufus.ie/ja/)で焼いた。

落としてくるイメージは各自PCのCPUアーキテクチャに依存する。
私はamdのcpuを使用しているので、amd64を落としてきた。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/debian_u8fcz3.png)

さて、インストールはUSBをさしてBIOSなりUEFIなりで起動順序変更をしてやればよい。細かいことはググってほしい。
Debianは比較的親切にインストール案内を出してくれる。guiインストールを選べばあとはポチポチしていたらインストールが終わる。
公式も[インストールガイド](https://www.debian.org/releases/stable/i386/index.ja.html)を出しているので、困ったら見るとよいだろう。

### sudoをなんかいい感じにする
デフォルト状態だとなんかエラーが出て`sudo`させてくれない。
[これ](https://qiita.com/unkomorasi01/items/219b56f2c9ddc8df4fe7)が参考になる。
一回super userとしてsudoの設定をしてやれば良いらしい。

### タスクバー的なものをセット
GNOMEデフォルトだと「アクティビティ」からしかタスクバー的なものを使えない。windowsに飼い慣らされた我々は、画面の左か下にタスクバーがないと死んでしまうのだ。
解決は[このページ](https://forums.debian.net/viewtopic.php?t=155401)が参考になった。
```bash
sudo apt install gnome-shell-extension-dashtodock
```
で拡張機能をインストールして、一回ログアウトする。
再びログインしたら「拡張機能」アプリにdashtodockが追加されているから、有効化する。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786003/pictures/debian-install/extension_oa0akc.png)

設定はこんな感じ。

<img src="https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/dashtodock1_ukossn.png" style="max-height: 500px;">

<img src="https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/dashtodock2_qj0yq3.png" style="max-height: 500px;">

これで画面左側にタスクバーが出現する。ありがてえ。

### 各種ソフトウェアのインストール+設定
`apt install hoge`で普通に入るやつをインストールしていく

#### いつものやつ
```bash
sudo apt install gcc
sudo apt install g++
sudo apt install git
sudo apt install curl
sudo apt install vim
sudo apt install texlive-full
```
余談だが、Debianにプリインストールされているvimはなぜかnetrwが使えなかったし、vimのはずなのに「vim」へのシンボリックリンクすらなくて、「vi」でしか起動できなかった。あれはもしかしてviだったのだろうか。

`texlive-full`は全部で7GBほどの容量を食う。そんなことしたくないという人は[このあたり](https://uwabami.github.io/cc-env/DebianTeX.html)が参考になるかもしれない。

まずはgitの設定からしよう。
gitの設定は難しくてよくわからないので、[このページ](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E8%A8%AD%E5%AE%9A)や[このページ](https://qiita.com/ucan-lab/items/aadbedcacbc2ac86a2b3)を見ながらできそうなやつをポチポチしていく。

```bash
git config --global user.name "InTheBloom"
git config --global user.email "hoge.fuga@example.com"
git config --global core.quotePath false
```

あとはgithubに接続する設定(?)みたいなのをやっていく。このあたり本当に勉強したほうがいい気がするが、わけわからない単語を並べられてもしんどいというのが本音である。

[これ](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh)に沿ってやっていく。

```bash
inthebloom@debian:~$ ssh-keygen -t ed25519 -C "hoge.fuga@example.com"
inthebloom@debian:~$ cat ~/.ssh/id_ed25519.pub | clip

# githubの方でssh鍵の登録設定をする

inthebloom@debian:~$ ssh -T git@github.com
Hi InTheBloom! You've successfully authenticated, but GitHub does not provide shell access.
inthebloom@debian:~$
```

なんか動いた(最悪)

次にvimの設定をする。
自分のvimの設定が[ここ](https://github.com/InTheBloom/vim-config)にあるので、これをセットアップする。
詳細は`README.md`に書いてある。

次にAtCoder Libraryとboost Libraryをローカルで動かせるようにする。
まずAtCoder Libraryをcloneする。
```bash
git clone git@github.com:atcoder/ac-library.git
```
ACLは事前ビルドが不要(ヘッダオンリー)のため、単にコンパイラの参照パスに追加すればよい。

私の場合、競技プログラミング以外でg++を使用することはほぼないため、常時参照しても問題にならない。そのため、aliasとして登録しておくと楽になる。
```~/.bashrc
alias g++='g++ -I/home/inthebloom/cp/lib/ac-library'
```

あとはboostを導入していく。
[このページ](https://boostjp.github.io/howtobuild.html)に従ってやっていく。
まずは現在の最新バージョンを落としてくる。最新バージョンへのリンクは上のリンクにある。

boostディレクトリを解凍し、
```bash
./bootstrap.sh
./b2 install -j8 --prefix=/home/inthebloom/libboost/
```
を実行し、boostをビルドする。
実は私が利用するような機能群は事前ビルドが必要ないものが多い(`boost/multiprecision/cpp_int`など)が、全部使えると嬉しいのでビルドする。
もしヘッダオンリーだけでいい場合、
```bash
./b2 headers
```
でいいらしい。
あとはACLと同じように参照パスを追加しておく。
```~/.bashrc
alias g++='g++ -I/home/inthebloom/cp/lib/ac-library/ -I/home/inthebloom/libboost/include/'
```

#### DMD(D言語処理系)

私が普段使ってるD言語処理系は、`apt`ならldcをインストールできる。
ただし、公式実装のDegital Mars Dがいいという人(私)は、公式の.debファイルかインストールスクリプトを利用すると楽だと思う。
[ダウンロードページ](https://dlang.org/download.html)
```bash
curl -fsS https://dlang.org/install.sh | bash -s dmd
```
activateが必要なので、`~/.bashrc`に次を追記して、常時activatedにしておく。
行儀悪い方法かもしれないが、別にマナー講師になりたいわけではないので気にしないことにする。
```~/.bashrc
# dmd activation

_OLD_D_PATH="${PATH:-}"
_OLD_D_LIBRARY_PATH="${LIBRARY_PATH:-}"
_OLD_D_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="/home/inthebloom/dlang/dmd-2.107.0/linux/lib64${LIBRARY_PATH:+:}${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="/home/inthebloom/dlang/dmd-2.107.0/linux/lib64${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH:-}"
_OLD_D_PATH="${PATH:-}"
_OLD_D_PS1="${PS1:-}"
export PATH="/home/inthebloom/dlang/dmd-2.107.0/linux/bin64${PATH:+:}${PATH:-}"
export DMD=dmd
export DC=dmd
```
これは`~/dlang/dmd-[version]/activate`の下の方にある内容をコピってきたものなので、これをそのまま使っても動かない。(だってユーザー名とかガッツリ含まれてるし..)

私は競技プログラミングにおいて、c++と似た動作にするためにコンパイル結果をわざと`a.out`にするようにしている。
これはaliasを設定してやれば良い。

```~/.bashrc
alias dmd='dmd -of="a.out"'
```

#### その他のソフト

- vscode
- hugo
- zoom
- slack

このあたりはdebian向けパッケージファイル`hoge.deb`を公開してくれているので、それをパクってきて
```bash
sudo apt install hoge.deb
```
としておけばインストールできる。

私はいくつかの事情でvscodeをターミナルエミュレーターとして使用しているので、そのあたりの設定をしていく。

まず、ターミナルエミュレータにショートカットキーはいらないので、全部消す。ちょうどいい拡張機能があるので、これをインストールする。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/disable-shortcut_pwj62u.png)

ただし、この拡張機能はあまりに強力で、なんと`backspace`すら無効化されてしまう。
そのため、別途有効にしたいキーバインディングは`~/.config/Code/User/keybindings.json`に追記することにした。
デフォルト設定は[ここ](https://github.com/codebling/vs-code-default-keybindings/blob/master/linux.keybindings.json)にあるため、これを改良して使う。

フォントは[Inconsolata](https://os0x.hatenablog.com/entry/20100822/1282495059)を使う。
[Google Fonts](https://fonts.google.com/specimen/Inconsolata)からダウンロードしてきて、`~/.fonts/`にttfを配置すると、現在のユーザーで読み込まれる。([参考](https://turtlechan.hatenablog.com/entry/2019/06/11/211543))

あとは、設定を開いて、

- `Terminal > Integrated: Default Location`を`editor`
- `Terminal > Integrated: Font Family`を`'Inconsolata'`
- `Terminal > Integrated: Font Size`を`17`

に変更した。
ついでに背景透明化も行う。GlassIt-VSCをインストールすると、普通に透ける。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/glassit_bppiko.png)

#### 地味な設定

地味にないと困る設定をしていく。
まず、firefoxの二本指スワイプで進む/戻るを実現する設定をする。
[このページ](https://pankona.github.io/blog/2014/09/15/histryback-by-swipe-on-firefox/)を参考にした。
アドレスバーに`about:config`を入力し、

- `mousewheel.default.override_x`を2
- `mousewheel.default.delta_multiplier_x`を-5

に設定する。これでスワイプ操作で進む/戻るを実現できる。

次に、コマンドラインコピーペーストを実現する。
[このページ](https://osima.jp/posts/ubuntu-howto-copy-and-paste-on-terminal/)を参考にした。
まず、xselというツールをインストールする。
```bash
sudo apt install xsel
```
`~/.bashrc`に以下を追記
```~/.bashrc
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias clip=$pbcopy
```
これで`cat file | clip`や、`pbpaste > file`ができる。

### OSレベルのキーバインディング関連
このあたりは自分も何やってるのかよくわかっていないことは許してほしい。とりあえず動く方法だけ紹介する。
私の普段のキーバインディングはCapsLockをctrlにし、hankaku/zenkakuをEscにした上でmuhenkanをIMEオン、henkanをIMEオフに割り当てるというものである。これを実現する。

とりあえずTweaksという神アプリがプリインストールされているので、これを起動する。Ubuntuにも入ってるはず。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786002/pictures/debian-install/tweaks_h9ebnc.png)

追加のレイアウトオプションを選択

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786003/pictures/debian-install/layoutoption_ddlcoh.png)

`Caps Lock behavior`と`日本語キーボードオプション`をいじる。
前者は`Make Caps Lock an additional Ctrl`に、後者は`Make Zenkaku Hankaku an additional Esc`にする。
これで割当変更ができる。仕組みはわからない。**開発者ℒ𝒪𝒱ℰ...**

次にIMEの設定をしよう。DebianではIMEとしてMozcというソフトウェアが使われているらしい。
Mozc以外の話はわからないし、Mozcが何なのかもわかってないことは許してほしい。
まず、「アクティビティ」から`Mozcの設定`という謎アプリを開く。

![](https://res.cloudinary.com/dqoqdn2sk/image/upload/v1707786003/pictures/debian-install/mozc-property_yjydjj.png)

そしたら、「キー設定」の「キー設定の選択」を選んで、ここをいじっていく。

<details>
<summary>私の設定をエクスポートしたやつ</summary>
```
status	key	command
Precomposition	Backspace	Revert
Composition	Backspace	Backspace
Conversion	Backspace	Cancel
Conversion	Ctrl a	SegmentFocusFirst
Composition	Ctrl a	MoveCursorToBeginning
Composition	Ctrl Backspace	Backspace
Precomposition	Ctrl Backspace	Undo
Conversion	Ctrl Backspace	Cancel
Conversion	Ctrl d	SegmentFocusRight
Composition	Ctrl d	MoveCursorRight
Prediction	Ctrl Delete	DeleteSelectedCandidate
Conversion	Ctrl Down	CommitOnlyFirstSegment
Composition	Ctrl Down	MoveCursorToEnd
Conversion	Ctrl e	ConvertPrev
Composition	Ctrl e	MoveCursorToBeginning
Composition	Ctrl Enter	Commit
Conversion	Ctrl Enter	Commit
Conversion	Ctrl f	SegmentFocusLast
Composition	Ctrl f	MoveCursorToEnd
Composition	Ctrl g	Delete
Conversion	Ctrl g	Cancel
Composition	Ctrl h	Backspace
Conversion	Ctrl h	Cancel
Composition	Ctrl i	ConvertToFullKatakana
Conversion	Ctrl i	ConvertToFullKatakana
Conversion	Ctrl k	SegmentWidthShrink
Composition	Ctrl k	MoveCursorLeft
Conversion	Ctrl l	SegmentWidthExpand
Composition	Ctrl l	MoveCursorRight
Conversion	Ctrl Left	SegmentFocusFirst
Composition	Ctrl Left	MoveCursorToBeginning
Composition	Ctrl m	Commit
Conversion	Ctrl m	Commit
Conversion	Ctrl n	CommitOnlyFirstSegment
Composition	Ctrl n	MoveCursorToEnd
Composition	Ctrl o	ConvertToHalfWidth
Conversion	Ctrl o	ConvertToHalfWidth
Composition	Ctrl p	ConvertToFullAlphanumeric
Conversion	Ctrl p	ConvertToFullAlphanumeric
Conversion	Ctrl Right	SegmentFocusLast
Composition	Ctrl Right	MoveCursorToEnd
Conversion	Ctrl s	SegmentFocusLeft
Composition	Ctrl s	MoveCursorLeft
Composition	Ctrl Shift Space	InsertFullSpace
Conversion	Ctrl Shift Space	InsertFullSpace
Precomposition	Ctrl Shift Space	InsertFullSpace
Composition	Ctrl Space	InsertHalfSpace
Conversion	Ctrl Space	InsertHalfSpace
Composition	Ctrl t	ConvertToHalfAlphanumeric
Conversion	Ctrl t	ConvertToHalfAlphanumeric
Composition	Ctrl u	ConvertToHiragana
Conversion	Ctrl u	ConvertToHiragana
Conversion	Ctrl Up	ConvertPrev
Composition	Ctrl Up	MoveCursorToBeginning
Conversion	Ctrl x	ConvertNext
Composition	Ctrl x	MoveCursorToEnd
Composition	Ctrl z	Cancel
Conversion	Ctrl z	Cancel
Composition	Delete	Delete
Conversion	Delete	Cancel
Suggestion	Down	PredictAndConvert
Conversion	Down	ConvertNext
Composition	Down	MoveCursorToEnd
Composition	Eisu	ToggleAlphanumericMode
Conversion	Eisu	ToggleAlphanumericMode
Precomposition	Eisu	ToggleAlphanumericMode
DirectInput	Eisu	IMEOn
Conversion	End	SegmentFocusLast
Composition	End	MoveCursorToEnd
Composition	Enter	Commit
Conversion	Enter	Commit
Composition	ESC	Cancel
Conversion	ESC	Cancel
Composition	F10	ConvertToHalfAlphanumeric
Conversion	F10	ConvertToHalfAlphanumeric
DirectInput	F13	IMEOn
Composition	F2	ConvertWithoutHistory
Composition	F6	ConvertToHiragana
Conversion	F6	ConvertToHiragana
Composition	F7	ConvertToFullKatakana
Conversion	F7	ConvertToFullKatakana
Composition	F8	ConvertToHalfWidth
Conversion	F8	ConvertToHalfWidth
Composition	F9	ConvertToFullAlphanumeric
Conversion	F9	ConvertToFullAlphanumeric
Composition	Henkan	IMEOff
Conversion	Henkan	IMEOff
Precomposition	Henkan	IMEOff
Conversion	Home	SegmentFocusFirst
Composition	Home	MoveCursorToBeginning
Conversion	Left	SegmentFocusLeft
Composition	Left	MoveCursorLeft
Precomposition	Muhenkan	InputModeSwitchKanaType
Composition	Muhenkan	SwitchKanaType
Conversion	Muhenkan	SwitchKanaType
DirectInput	Muhenkan	IMEOn
Precomposition	Muhenkan	IMEOn
Conversion	PageDown	ConvertNextPage
Conversion	PageUp	ConvertPrevPage
Conversion	Right	SegmentFocusRight
Composition	Right	MoveCursorRight
Composition	Shift Backspace	Backspace
Conversion	Shift Backspace	Cancel
Conversion	Shift Down	ConvertNextPage
Suggestion	Shift Enter	CommitFirstSuggestion
Composition	Shift ESC	Cancel
Conversion	Shift ESC	Cancel
Conversion	Shift Henkan	ConvertPrev
Conversion	Shift Left	SegmentWidthShrink
Composition	Shift Left	MoveCursorLeft
Composition	Shift Muhenkan	ConvertToFullAlphanumeric
Conversion	Shift Muhenkan	ConvertToFullAlphanumeric
Precomposition	Shift Muhenkan	ToggleAlphanumericMode
Conversion	Shift Right	SegmentWidthExpand
Composition	Shift Right	MoveCursorRight
Composition	Shift Space	Convert
Precomposition	Shift Space	InsertAlternateSpace
Conversion	Shift Space	ConvertPrev
Conversion	Shift Tab	ConvertPrev
Conversion	Shift Up	ConvertPrevPage
Composition	Space	Convert
Conversion	Space	ConvertNext
Precomposition	Space	InsertSpace
Composition	Tab	PredictAndConvert
Conversion	Tab	PredictAndConvert
Conversion	Up	ConvertPrev
Conversion	VirtualEnter	CommitOnlyFirstSegment
Composition	VirtualEnter	Commit
Conversion	VirtualLeft	SegmentWidthShrink
Composition	VirtualLeft	MoveCursorLeft
Conversion	VirtualRight	SegmentWidthExpand
Composition	VirtualRight	MoveCursorRight
Composition	ASCII	InsertCharacter
Composition	Kanji	IMEOff
Composition	OFF	IMEOff
Composition	ON	IMEOn
Conversion	Kanji	IMEOff
Conversion	OFF	IMEOff
Conversion	ON	IMEOn
DirectInput	Kanji	IMEOn
DirectInput	ON	IMEOn
Precomposition	ASCII	InsertCharacter
Precomposition	Kanji	IMEOff
Precomposition	OFF	IMEOff
Precomposition	ON	IMEOn
```
</details>
多分これをコピーしてインポートすることができるので、よかったら使ってね。



### wifiアダプタ有効化
手元にusbのwifiアダプタがあるので、一応動かせるようにしておく。
`lsusb`コマンドによると、アダプタはTP-Link AC600 wireless Realtek RTL8811AU [Archer T2U Nano]らしい。
単にさしただけだと反応しないので、何らかの処置が必要らしい。
いくつかググると、[このページ](https://tech.nosuz.jp/post/2021-09/ubuntu_wifi/)がヒットした。

まず、必要なツールをインストールする。
```bash
sudo apt install dkms
sudo apt install build-essential
sudo apt install linux-headers-6.1.0-17-amd64
```

ドライバのリポジトリを引っ張ってきて、`make`する。
```bash
git clone git@github.com:aircrack-ng/rt18812au.git
cd rt18812au
sudo make dkms_install
```
何故か「すでにインストールされています」的なことを言われる。
でもまだアダプタが認識しないので、一回アンインストールを試みる。
```bash
sudo make dkms_remove
sudo make dkms_install
```
これで急に認識されるようになった。
`NetWorkManager`のclクライアント`nmcli`で簡単に確認できる。
```bash
nmcli device show
```

## 終わりに
これで必要なセットアップは大体できた。
もっと細かいこともあるが、あとはケースバイケースなものが多いと思う。
このエントリが初心者linuxユーザーの役に立つことを願う。
