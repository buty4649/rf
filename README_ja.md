# rf

rfはRubyのコードでテキスト/JSON/YAMLをフィルタできるCLIのツールです。
これらのファイルは[awk](https://www.gnu.org/software/gawk/manual/gawk.html)や[jq](https://jqlang.github.io/jq/)、[yq](https://github.com/mikefarah/yq)といったツールを使い処理しますが、それぞれの使い方や記法を覚える必要があります。
rfでは同等の処理をRubyのコードで記述できるため、Rubyistにとって手になじむツールとなっています。

rfは[mruby](https://github.com/mruby/mruby)を使って作られていて、単独のバイナリファイルで構成されています。
rfを使うために追加でRubyをインストール必要はありません。
バイナリファイルをダウンロードすればすぐに使い始められるのも特徴です。

## クイック使用ガイド

テキストの一部を置き換える

```sh
rf 'gsub(/hello/, "world")' example.txt
```

標準入力から読み込む

```sh
rf 'gsub(/hello/, "world")' < example.txt
```

特定のパターンが含まれる行だけ表示する

```sh
rf '/hello/' example.txt
```

指定するパターンはUTF-8も使える

```sh
rf '/🍣/' example.txt
```

カンマで区切られたファイルの2カラム目を足し合わせる

```sh
rf -F, 's||=0;s+=_2; at_exit{putts s}' example.csv
```

JSONファイルの特定のキーを出力する

```sh
rf -j '.a.b' example.json
```

YAMLファイルの特定のキーを出力する

```sh
rf -y '.a.b' example.json
```

## インストール方法

[Releaseページ](https://github.com/buty4649/rf/releases)からダウンロードできます。
各プラットフォームとアーキテクチャ向けにバイナリファイルを提供しています。
それぞれの対応状況は以下のテーブルを参照してください。

|     | amd64 | arm64|
|-----|-------|------|
|Linux|✅    |✅    |
|MacOS|✅    |✅    |
|Windows|✅  |-     |

別の方法として各パッケージマネージャを使ってインストールすることもできます。

### [asdf](https://asdf-vm.com/)

```sh
asdf plugin install rf https://github.com/buty4649/asdf-rf/
asdf install rf latest
asdf global rf latest
```

### [rtx](https://github.com/jdxcode/rtx)

```sh
rtx plugin install rf https://github.com/buty4649/asdf-rf/
rtx install rf@latest
rtx global rf@latest
```

### [Homebrew](https://brew.sh/)

```sh
brew tap buty4649/tap
brew install buty4649/tap/rf
```

### [GitHub CLI](https://cli.github.com/) and [k1LoW/gh-setup](https://github.com/k1LoW/gh-setup/)

```sh
# if not installed k1LoW/gh-setup
gh extension install k1LoW/gh-setup
gh setup --repo buty4649/rf --bin-dir ~/.local/bin
```

## オプション

```sh
Usage: rf [options] 'command' file ...
  -t, --type={text|json|yaml}      set the type of input (default:text)
  -j, --json                       equivalent to -tjson
  -y, --yaml                       equivalent to -tyaml
      --debug                      enable debug mode
  -n, --quiet                      suppress automatic priting
  -h, --help                       show this message
  -v, --version                    show version

text options:
  -F, --filed-separator VAL        set the field separator(regexp)
```

*file*を指定しなかった場合は標準入力から読み込みます。

## コマンド

*command*にはRubyのコードを記述します。
このRubyのコードのことをrfでは**コマンド**と呼びます。
rfにおいてはRuby処理系に[mruby](https://github.com/mruby/mruby)を利用しています。
mrubyは組み込みシステム向けに軽量につくられたRuby処理系です。
CRubyとの互換性がありほとんどすべての機能が使えますが、一部機能制限があります。
詳しくは[mrubyのドキュメント](https://github.com/mruby/mruby/blob/master/doc/limitations.md)を参照してください。

## フィルタ

rfでは以下のような流れで処理を行います。

1. *file*や標準入力からデータを読み込む
2. 読み込んだデータをRubyで扱いやすいように変換する
3. 変換したデータを分割する
4. *command*を実行し結果を評価する
5. 評価結果を加工して出力する
6. データがなくなるまで3から5を繰り返す

2と3と5を行う機能をrfでは**フィルタ**と呼びます。
この処理の流れをRubyの疑似コードで表すと以下の通りになります。

```ruby
Filter.read(input).each do |chunk|
  puts eval(command)
end
```

### チャンク

フィルタは入力されたデータを一定のルールに従って分割します。
この分割された単位をrfでは**チャンク**と呼びます。
分割するルールはフィルタによって異なります。

テキストフィルタでは改行コード(`\n`)で分割されます。
JSONフィルタ/YAMLフィルタではオブジェクト単位で分割されます。例えば、入力されたデータが配列なら配列の要素ごとに分割します。
Rubyのコードで表すと以下のような処理になります。

```ruby
# YAMLフィルタの場合はYAML.loadになります
[JSON.load(input)].flatten(1).each do |chunk|
  puts eval(command)
end
```

### フィールド

チャンクをさらに分割したものをrfでは**フィールド**と呼びます。
`_1`, `_2`, `_3`...という特殊変数を使うと1番目のフィールド、2番目のフィールド、3番目のフィールド…へアクセスすることができます。
フィールドへの分割は自動で行われますが、`_`変数を使うとフィールドに分割されていないチャンクにアクセスできます。

フィールドの分割ルールはフィルタによって異なります。
テキストフィルタの場合は空白文字で区切られます。`String#split`を引数なしで呼び出した時と同じ挙動です。
`-F`オプションを指定すると区切り文字を変更できます。区切り文字は正規表現を使うことも可能です。
JSONフィルタ/YAMLフィルタは、チャンクが配列だった場合にのみフィールドに分割します。
それ以外のデータ型だった場合は`_1`にのみ格納され、`_2`以降はnilになります。

## 特殊変数

rfではRubyで定義されている[特殊変数](https://docs.ruby-lang.org/ja/latest/class/Kernel.html)を使用できます。
しかしながら、いくつかの変数はrfの独自の定義に変更されています。

| 変数名 | 説明 |
|-------|------|
| \_  | 入力されたチャンクです |
| $\_ | \_ のエイリアスです |
| $F | \_ のエイリアスです |
| \_1, \_2, \_3, ... | 1番目、2番目、3番目のフィールドです |

## 組み込みメソッド

利便性のためにいくつかのメソッドが組み込みメソッドとなっています。

| メソッド名 | 説明 |
|-----------|------|
| gsub | `_.gusb`と同等です |
| gsub! | `_.gusb!`と同等です |
| match | `_.match`と同等です |
| match? | `_.match?`と同等です |
| sub | `_.sub`と同等です |
| sub! | `_.sub!`と同等です |
| tr | `_.tr`と同等です |
| tr! | `_.tr!`と同等です |

## 拡張機能

rfではRubyの言語機能に独自の拡張を行っています。

### 自動的にto_i/to_fを行う

標準のRubyではStringとInteger/Floatを直接計算することはできません。
String#to_iやString#to_fを呼び出す必要があります。
rfではこれらの呼び出しを自動で行うようになっています。

```ruby
1 + "1"
#=> 2
```

### Hashのkeyをメソッドとして指定できる

Hashに含まれるkeyをメソッドとして呼び出すことができます。

```ruby
h = {"a": 1}
h.a
#=> 1
```

存在しないkeyをメソッドとして呼び出すとundefined methodになります。

```ruby
h.b
#=> Error: undefined method 'b'
```

空白文字や記号、マルチバイト文字を含んだkeyをこの方法で呼び出すことはできないため、`Hash#[]`を使います。

## License

See [LICENSE](LICENSE) © [buty4649](https://github.com/buty4649/)
