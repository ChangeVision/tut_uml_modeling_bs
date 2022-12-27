# astah*を使ったUMLチュートリアル


この文書は、ソフトウェアの開発にモデリングツールを使う方法などについて独習するためのチュートリアルです。モデリングツールとして、astah* Professional を使っています。

文書は asciidoctor 型式で作成し、 asciidoctor コマンドでHTML型式に、 asciidoctor-pdf コマンドでPDF型式に変換します。

## 文書生成に関するメモ

* 文書は、Asciidoctor形式で記述して、`asciidoctor` コマンドでHTML形式に、 `asciidoctor-pdf`   コマンドでPDFに変換している。
* asciidoctor-pdfを 1.6.2にしたことで、生成されるPDFやオプションが変わった。
   - それに伴いカスタマイズのためのasciidoctor-pdf-extensions.rbを使うのをやめた、
   - 段落のインデントが使えるようになったので、本文全体で段落の左側にインデントをつけた。
* mediaをprepressにして、chapterにnonfacingオプションをつけて生成した（見開きレイアウトだが、空きページなし）。
* マルチページのHTMLを生成するようになった。
   - その代わり、adocと生成するHTMLが対応しないので、生成時にclobberが必要となる場合が生じている。
* includeしているコードの行番号についてのタグをつけても、取り除いて挿入してくれるので、挿入したファイルの実際の行番号とずれてしまう。これに対応するため、Rakefile中で挿入するファイルの行番号を調べ、生成時のパラメータに渡して調整している。
