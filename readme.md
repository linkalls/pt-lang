# PTLang

PTLangは、独自のプログラミング言語を解釈するRuby製のインタープリタです。

## 特徴

- 変数の定義と使用
- 四則演算
- 文字列と変数の連結
- コードの行ごとの実行

## 使用方法

1. PTLangのコードを含むテキストファイルを作成します。
2. コマンドラインからPTLangのインタープリタを実行します。以下のようにファイル名をコマンドライン引数として指定します。

```bash
ruby ptlang_interpreter.rb your_file.pt

例
以下は、PTLangで"hello world"を表示する例です。
name = "world"
h "hello " + name
このコードを実行すると、"hello world"と表示されます。