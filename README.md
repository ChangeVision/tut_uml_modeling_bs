# astah*を使ったUMLチュートリアル


この文書は、ソフトウェアの開発にモデリングツールを使う方法などについて独習するためのチュートリアルです。モデリングツールとして、astah* Professional を使っています。

文書は asciidoctor 型式で作成し、 asciidoctor コマンドでHTML型式に、 asciidoctor-pdf コマンドでPDF型式に変換します。

## 文書生成に関するメモ

* asciidoctor-pdfを 1.6.2にしたことで、生成されるPDFやオプションが変わった。
   -  それに伴いカスタマイズのためのasciidoctor-pdf-extensions.rbを使うのをやめた、
* mediaをprepressにして、chapterにnonfacingオプションをつけて生成した（見開きレイアウトだが、空きページなし）。
* マルチページのHTMLを生成するようになった。
   - その代わり、adocと生成するHTMLが対応しないので、生成時にclobberが必要となる場合が生じている。
* includeしているコードの行番号について、タグをつけると、それを取り除いて装入してくれるので、装入したファイルの実行番号とずれる。これに対応するため、Rakefile中で挿入するファイルの行番号を調べ、生成時のパラメータに渡して調整している。
