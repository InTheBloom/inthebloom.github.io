---
title: 失われしappleスタイルのemojiを召喚 on mintty
# description: 

date: 2024-11-09
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - trivia
archives:
  - 2024
  - 2024-11
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---

## はじめに

[mintty](https://mintty.github.io/)という端末エミュレータがあります。
msysやcygwinやgitbashにくっついてインストールされるようで、私のwindows環境にもいつの間にかありました。
私は基本的にターミナル暮らしをしており、最近はgitbashにくっついてきたminttyを常用しています。

さて、そんなminttyですが、デフォルトでemojiを描画出来ません。具体的には次のようになります。

![](/images/apple-emoji-on-mintty/coldface_nostyle.png)

これはCold Face🥶(U+1F976)です。なんの趣もありません。ちゃんとemojiを表示したいですね？？？

今回、minttyで**appleスタイルの**emojiを描画することに成功したので、その方法を書きます。

## emoji導入を試みる
当然先人は居るわけで、「mintty emoji」でググると二番目に出てくるこのページが非常に参考になりました。

[mr/minttyやwslttyでカラー絵文字 ](https://kemasoft.net/index.php?mr/mintty%E3%82%84wsltty%E3%81%A7%E3%82%AB%E3%83%A9%E3%83%BC%E7%B5%B5%E6%96%87%E5%AD%97)

結論としては、スクリプト一発で出来るようです。以下に上記ページのスクリプトを少し改造したものを掲載します。実際に私の環境で動いたやつです。(改造はwgetをcurlに置き換えた部分だけです。)
```bash
# MSYS2(mintty)の場合
emojis_dir="$(echo "$APPDATA/mintty" | sed -re 's;^(.).;/\L\1;' -e 's;\\;/;g')/emojis"

getemojis_url='https://raw.githubusercontent.com/mintty/mintty/master/tools/getemojis'
getemojis_script="${getemojis_url##*/}"

# 絵文字png用ディレクトリ作成
mkdir -p "$emojis_dir" || true
cd "$emojis_dir"       || exit 1

echo "created $emojis_dir"

# 絵文字pngダウンロードスクリプトの準備
[ -e "$getemojis_script" ] && rm -rf "$getemojis_script"
curl -o "$getemojis_script" "$getemojis_url"
sed -i '/postproc=sh/s;sh;bash;' "${getemojis_script}"  # sh -> bash に修正

# 絵文字pngダウンロード（そこそこ時間が掛かります）
bash "${getemojis_script}" -d
```

これでminttyの設定画面からgoogleスタイルのemojiを選択できるようになるはずです。
でも上記ページにはいろんなスタイルを選択できると書いてありましたが、googleしかありません。**私はappleスタイルが使いたいんですが！**

## 調査
上記スクリプトはhttps://raw.githubusercontent.com/mintty/mintty/master/tools/getemojisをダウンロードしてきて実行するといった内容のようです。(普通に何も見ずに実行しました。セキュリティさん...)

そこで、ダウンロード + 実行されたスクリプトを見に行きましょう。
私の場合は、`~/AppData/Roaming/mintty/emojis`にgetemojisというスクリプトが生成されていました。
ソースコードを見ていると、不穏な一文を発見...

```bash
echo "  $emojisurl1" >&2
echo "for the selected emoji style sets, or (if none selected) all of them:" >&2
echo "  google" >&2
echo "and always extracts common emoji graphics." >&2
echo "Other styles are no longer provided at unicode.org:" >&2
echo "  [apple facebook windows twitter emojione samsung]" >&2
echo >&2
```
**Other styles are no longer provided at unicode.org:**

つまり、unicode.orgがgoogle以外のemojiスタイルの画像を提供するのをやめてしまったのが原因のようでした。
ということは、画像さえ用意できれば別スタイルのemojiを表示できる...？

実際、`~/AppData/Roaming/mintty/emojis/google/`以下はこんな感じでした。

![](/images/apple-emoji-on-mintty/google_emoji.png)

名前をそのemojiの16進数表現にした透過pngを用意できれば良いっぽいですね。

## appleスタイルのインストール
というわけで、appleスタイルのemoji画像が集まっているwebページからpngを取得して、`~/AppData/Roaming/mintty/emojis/apple/`に入れるスクリプトを書きました。

ソースコードが酷いのは見逃してください。
`requests`モジュールを要求しますが、複雑なことは何一つしていないので標準の範囲でも書き直せそうです。

注意:
- `saved_image_path`を書き換えてください。(他にも直すとこあるかも)
- パス区切り文字を無理やり`/`にしてます。
- **実行時間40分くらい**です。

[gistにもあがっています。](https://gist.github.com/InTheBloom/a145117e2a56c4aeee257a952d11ab49)

```python3
from html.parser import HTMLParser
import urllib
import requests
import re
import sys
import os

class EmojigraphReader(HTMLParser):
    def __init__ (self):
        super().__init__()
        self.is_in_emoji_element = False
        self.urls = []

    def retrive_urls (self):
        return self.urls.copy()

    def handle_starttag (self, tag, attrs):
        def handle ():
            if tag == "a":
                for attr in attrs:
                    if attr[0] == "class" and attr[1] == "pim":
                        self.is_in_emoji_element = True
                return

            if tag == "img":
                if not self.is_in_emoji_element:
                    return
                for attr in attrs:
                    if attr[0] != "src": continue
                    self.urls.append(attr[1])

        handle()

    def handle_endtag (self, tag):
        if tag == "a" and self.is_in_emoji_element:
            self.is_in_emoji_element = False

def main ():
    emojigraph_apple_emojis_url = "https://emojigraph.org/apple/"
    current_path = "https://emojigraph.org"
    saved_image_path = "/Users/namah/AppData/Roaming/mintty/emojis/apple"

    # 対象ディレクトリ作成
    if not os.path.isdir(saved_image_path):
        os.mkdir(saved_image_path)

    # emojigraph.orgへGETを飛ばす。
    print(f"Trying GET {emojigraph_apple_emojis_url}")
    emojigraph_response = requests.get(emojigraph_apple_emojis_url)
    if not 200 <= emojigraph_response.status_code <= 299:
        print(f"Status code of GET {emojigraph_apple_emojis}: {emojigraph_response.status_code}", file=sys.stderr)
        print("Maybe failed.", file=sys.stderr)
        exit(1)
    print("Successed!")
    sys.stdout.flush()

    # HTML解析(ガバガバ)
    reader = EmojigraphReader()
    reader.feed(emojigraph_response.text)
    image_urls = reader.retrive_urls()

    # ダウンロードをする。
    # 正規表現書きたかったけど技術力が足りんので普通に末尾を見る実装で
    for url in image_urls:
        codepoint_plus_png = url[url.find("_") + 1:]
        res = requests.get(urllib.parse.urljoin(current_path, url))
        print(f"Trying GET {urllib.parse.urljoin(current_path, url)}")

        if not 200 <= res.status_code <= 299:
            print(f"Status code of GET {url}: {res.status_code}", file=sys.stderr)
            print("Maybe failed. (continue downloading)", file=sys.stderr)
            sys.stdout.flush()
            continue

        img_path = os.path.join(saved_image_path, codepoint_plus_png).replace("\\", "/")

        with open(img_path, "wb") as img:
            img.write(res.content)
        print(f"Saved image to {img_path}")
        sys.stdout.flush()

if __name__ == "__main__":
    main()
```

これを実行すると、メニューにappleのスタイルが増えました！

![](/images/apple-emoji-on-mintty/config.png)

無事にappleスタイルを表示することが出来ました。やったー！

![](/images/apple-emoji-on-mintty/coldface_apple.png)

## 終わりに
競技プログラミング以外でコード書くことほぼないので、たまに活用できてうれしいね。みたいな話。
mainを肥大化させる癖マジで直したいです。

今回スクレイピングしたhtmlは滅茶苦茶シンプルだったからよかったけど、pythonの標準パーサだと複雑なことは出来なさそうだと思いました。
DOM操作ができる標準ライブラリの普及が待たれる。(需要ないのかな？)
