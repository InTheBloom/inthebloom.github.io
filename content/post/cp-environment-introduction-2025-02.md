---
title: 競技プログラミングの環境を晒す(2025年2月版)
# description: 

date: 2025-02-09
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 競技プログラミング
  - Linux
archives:
  - 2025
  - 2025-02
# sample
# - yyyy
# - yyyy-mm

draft: true
# math: true
# toc: false
# build: {list: never}
---

## はじめに
これまでコンピュータを使用する上でのベストプラクティスを習ったことがなく、インターネットを見ながら適当に使ってきました。
ほかの人がどう使っているのか気になるため、コンピュータ環境を晒す流れを作るべく、人柱になろうと思います。
みんな便乗して晒しあいませんか？(そして、知見を共有しましょう。)
意見、感想は広く募集します。
普段競技プログラミングをしていない人の環境も知りたいです。

## デバイス等
- モニタ: 23.5インチFHDモニタ2枚
- マウス: ロジクールG304
- キーボード: HHKB HYBRID日本語配列白
- CPU: Ryzen5 3600X
- GPU: asusの1050ti
- メモリ: 48GB(適当にスロット埋めたらこうなった)
- ストレージ: SSD 500GB1個(ブートドライブ)、256GB2個、1000GB1個

## OS等
- OS: windows11 Home

(ただし、プログラミング関係は可能な限りwsl2上で実行)

## ディレクトリ構成
以下特に断りがなければwsl2上の話をしています。

```text
$ pwd
/home/inthebloom
$ tree -L 2 -d
.
├── bin
├── cp
│   ├── contests
│   ├── lib
│   ├── practice
│   └── virtualcontests
├── dev
│   ├── how-to-fix-bug
│   └── inthebloom.github.io
├── dlang
│   └── dmd-2.109.1
└── experiment
    └── git

14 directories

```

### bin
適当に落としてきたバイナリとかはここに入れています。
パスが通っています。

### cp
cp = competitive programmingのつもりです。
競技プログラミング関連は大体ここに入っています。
```text
.
├── contests
│   ├── ABC390
│   ├── ABC391
│   ├── ABC392
│   └── AHC42
├── lib
│   ├── InTheBloom_Library
│   ├── ac-library
│   ├── library-checker-problems
│   └── multiway_trie
├── practice
│   ├── ABC164a.d
│   ├── ABC164b.d
│   ├── ABC164c.d
│   ├── ABC164d.d
│   ├── ABC165d.d
│   ├── ABC165f.d
│   ├── ABC173d.d
│   ├── ABC173e.d
│   ├── ABC215e.d
│   ├── ABC233d.d
│   ├── ABC233e.d
│   ├── ABC319d.d
│   ├── ABC389d.d
│   ├── ABC392f.d
│   ├── ARC28c.d
│   ├── a.d
│   ├── a.o
│   └── a.out
└── virtualcontests
    ├── iwai_anthology1
    ├── manabe012
    └── manabe013

16 directories, 18 files
```

`cp/practice`は本番外で提出するときとかに作ったファイルが置いてあります。
`cp/lib`はコードスニペット置き場です。作成中のやつも大体ここです。
この環境では導入していませんが、boostライブラリはここにあったりなかったりします。(競技プログラミング向けというわけではないので)

### dev
dev = developのつもりです。競技プログラミングにあまり関係ない制作物などがここに入ります。
このブログのローカルリポジトリもここにあります。

### experiment
とりあえず何かをお試ししたいときに適当にディレクトリを切ったり切らなかったりする場所です。ここはいきなり消滅しても文句を言わないというのがモットーです。

## ソフトウェア等
デフォルトのubuntuからこれは欲しいってやつです。

- git: 開発の役には立っていませんが、cloneとpush要員です。
- D言語コンパイラ: [公式インストールスクリプト](https://dlang.org/download.html)を使うと勝手にホーム以下にインストールされます。
- C/C++開発環境: よくわかってませんが、`sudo apt install build-essentials`でいろいろ入った。(適当)
- 標準入力をクリップボードにぶち込むやつ: 仕組みはよく知らないんですが、`sudo apt install xclip`をして、.bashrcに`alais clip="xclip -selection clipboard"`というエイリアスをはっておくと、`cat file | clip`みたいなことができます。競技プログラミングの提出やコマンド結果のコピペに利用しています。
- エディタ: neovimを使っています。

### .bashrc
コンパイルコマンドはエイリアスを噛ませています。
neovim矯正スクリプトというお笑い関数があります。
```bash
# clipboard
alias clip="xclip -selection clipboard"

alias g++="g++ -I /home/inthebloom/cp/lib/ac-library/"
alias dmd="dmd -of=\"a.out\""

# neovim強制エイリアス
alias vim=nvim_notify
function nvim_notify () {
    echo "wsl2ではnvimを使ってほしい"
}
```

### init.vim
大体[https://github.com/InTheBloom/vim-config](https://github.com/InTheBloom/vim-config)これと同じで、気になったところを若干変えています。
特徴的なのは、コードスニペットを新規tabで開く謎コマンドを定義しているのと、
```vim
" コード片のディレクトリオープン
" 参考 : https://thinca.hatenablog.com/entry/20090312/1236792602
let VIM_LIBRARY_PATH = '/home/inthebloom/cp/lib/InTheBloom_Library/dlang/src/' " path to directory

if VIM_LIBRARY_PATH == ''
    command Library echo 'このコマンドを利用するには、\".vimrc-excmd\"の変数\"VIM_LIBRARY_PATH\"を設定してください。'
else
    command Library tabnew | e `=VIM_LIBRARY_PATH`
endif
```

latexコンパイルをvim上から回せるコマンドを定義してあることだと思います。
```vim
" LaTeXのオートコンパイル
function s:_latex(...)
    let open_pdf = a:0 > 0 && a:1 != ''
    let cmd = '!platex % && platex % && platex % && dvipdfmx %<.dvi'
    if open_pdf
        if has('win32') || has('win64')
            let cmd .= ' && start %<.pdf'
        else
            let cmd .= ' && xdg-open %<.pdf'
        endif
    endif
    execute cmd
endfunction

command -nargs=? Latex call s:_latex(<f-args>)
```
