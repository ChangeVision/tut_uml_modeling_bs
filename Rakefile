# frozen_string_literal: true

require 'csv'
require 'rake/clean'

Encoding.default_external = 'utf-8'

SOURCE_DIR = 'codes'

# 現状、snap画像のディレクトリはadocごとに異なるので、imagesdirは、各adoc中で個別に変更しているので注意
IMAGES_DIR = 'images'
CSS_DIR = 'css'
CSS_FILE = 'mystyle.css'
CSS_FILE_PATH = "#{CSS_DIR}/#{CSS_FILE}"

# htmlやpdfを作成したいadocファイルのリスト（ALL_IMAGE_DIRS のように列挙したり、要素を追加してもよい）
ADOCS = FileList['**/*.adoc'].exclude(/^vendor/).exclude(/^lib/)
TARGET_ADOCS = ['uml_tutorial.adoc'].freeze

# マルチパートで生成される（そのためadocと対応しない）HTMLのリスト
MULTI_HTMLS = FileList['**/_*.html']
# adocから生成するファイルのリスト（ADOCSの拡張子を変換している）
HTMLS = ADOCS.ext('html') + MULTI_HTMLS
PDFS = ADOCS.ext('pdf')

THEME_DIR = 'theme/pdf'
THEME_FILE = 'mystyle-theme.yml'
FONTS_DIR = 'fonts'
CODE_STYLE = './rouge_custom_color.rb'
LIB_EXT = './lib/heading-treeprocessor.rb'
LIB_EXT2 = './lib/autoxref-treeprocessor.rb'
LIB_EXT3 = './lib/asciidoctor-pdf-extensions.rb'
LIB_EXT4 = './lib/asciidoctor-multipage.rb'

ALL_IMAGE_DIRS = [IMAGES_DIR, 'callouts']
ALL_IMAGES = []
ALL_IMAGE_DIRS.each do |dir|
  ALL_IMAGES.concat(FileList["#{dir}/*"].exclude(/\.pdf$/).exclude(/\.ppt*$/))
end

CLOBBER.concat HTMLS
CLOBBER.concat PDFS

desc 'Build multi/full HTML and PDF file'
# task :default => [:html, :pdf]
task :default => [:html_full, :html, :pdf]

desc 'Build full(one file) HTML files'
task :html_full => "uml_tutorial_full.html"

desc 'Build multi part HTML files'
task :html => "uml_tutorial.html"

desc 'Build main PDF files'
task :pdf => "uml_tutorial.pdf"

# rule ".html" => ".adoc" do |t|  # このルールでは対応するadocの更新しか認識できない
#   make_html( t.source, t.name )
# end

# rule ".pdf" => ".adoc" do |t|  # このルールでは対応するadocの更新しか認識できない
#   make_pdf( t.source, t.name )
# end

desc 'Show all target adoc files'
task :adocs => ADOCS do
  puts "target adocs ==> #{ADOCS}"
end

def update_revnumber(source, target)
  revfile = source.ext('rev')
  html_or_full_or_pdf = File.extname(target).sub('.', '')
  revno = 0
  vals = CSV.read(revfile)
  vals.each do |line|
    if line[0] =~/#{html_or_full_or_pdf}/
      revno = line[1].to_i
      revno += 1
      line[1] = revno
    end
  end
  CSV.open(revfile, 'wb') do |csv|
    vals.each do |line|
      csv << line
    end
  end
  ret = format ":revnumber: %s_%04d\n", html_or_full_or_pdf, revno
  File.open('revnumber.adoc', 'w+') do |f|
    f.printf ret
  end
  ret.chomp!
end

def make_html_full(source, target)
  revno = update_revnumber(source, target)
  revdate = `date "+%Y-%m-%d"`
  puts "Converting #{source} to #{target} (#{revno})."
  tag_lines = find_tag_lines('codes/score.rb',['main', 'test'])
  # -a linkcss -a stylesheet=#{CSS_FILE_PATH} はfront_matterに記載した
  `bundle exec asciidoctor -a score_main_start=#{tag_lines[0]} -a score_test_start=#{tag_lines[1]} -a revdate='#{revdate}' -r #{CODE_STYLE} -r #{LIB_EXT} -r #{LIB_EXT2}  #{source} -o #{target}`
end

def make_html_multi(source, target)
  revno = update_revnumber(source, target)
  revdate = `date "+%Y-%m-%d"`
  # -a linkcss -a stylesheet=#{CSS_FILE_PATH} はfront_matterに記載した
  puts "Converting #{source} to multi-part html (#{revno})."
  tag_lines = find_tag_lines('codes/score.rb',['main', 'test'])
  `bundle exec asciidoctor -a score_main_start=#{tag_lines[0]} -a score_test_start=#{tag_lines[1]} -a revdate='#{revdate}' -r #{LIB_EXT4} -b multipage_html5 -r #{CODE_STYLE} -r #{LIB_EXT} -r #{LIB_EXT2}  #{source} -o #{target}`
end

def make_pdf(source, target)
  revno = update_revnumber(source, target)
  revdate = `date "+%Y-%m-%d"`
  puts "Converting #{source} to #{target} (#{revno}). (this one takes a while)"
  tag_lines = find_tag_lines('codes/score.rb',['main', 'test'])
  # `bundle exec asciidoctor-pdf -r asciidoctor-pdf-cjk  -a revdate='#{revdate}'  -r #{CODE_STYLE} -r #{LIB_EXT} -r #{LIB_EXT2} -r  #{LIB_EXT3} -a pdf-stylesdir=#{THEME_DIR} -a pdf-style=#{THEME_FILE} -a pdf-fontsdir=#{FONTS_DIR} #{source} --out=#{target}` #  2>/dev/null`
  # `bundle exec asciidoctor-pdf -a scripts=cjk -a score_main_start=#{tag_lines[0]} -a score_test_start=#{tag_lines[1]} -a revdate='#{revdate}'  -r #{CODE_STYLE} -r #{LIB_EXT} -r #{LIB_EXT2} -r  #{LIB_EXT3} -a pdf-stylesdir=#{THEME_DIR} -a pdf-style=#{THEME_FILE} -a pdf-fontsdir=#{FONTS_DIR} #{source} --out=#{target}` #  2>/dev/null`
  `bundle exec asciidoctor-pdf -a scripts=cjk -a score_main_start=#{tag_lines[0]} -a score_test_start=#{tag_lines[1]} -a revdate='#{revdate}'  -r #{CODE_STYLE} -r #{LIB_EXT} -r #{LIB_EXT2} -a pdf-stylesdir=#{THEME_DIR} -a pdf-style=#{THEME_FILE} -a pdf-fontsdir=#{FONTS_DIR} #{source} --out=#{target}` #  2>/dev/null`
end

# コードのtagの（次の）行番号を返す
def find_tag_lines(filename, tagnames)
  tag_lines = []
  File.open(filename) do |f|
    f.each do |line|
      tag_lines.push(f.lineno + 1) if line =~ /tag::(.+)/ && $1.start_with?(*tagnames)
    end
  end
  tag_lines
end

# 各章のadocと依存物を調べて、更新時に生成するルールを動的に生成する
def make_rule_for_each_adoc
  TARGET_ADOCS.each do |adoc|
    base = adoc.pathmap('%X')
    html = adoc.pathmap('%X.html')
    html_full = adoc.pathmap('%X_full.html')
    pdf = adoc.pathmap('%X.pdf')
    deps = [adoc]

    # 依存ファイルのリストを作成
    make_depends(adoc, IMAGES_DIR, SOURCE_DIR, '.', deps, {})
    depends_for_html = deps.dup.push("#{CSS_DIR}/#{CSS_FILE}", LIB_EXT, LIB_EXT2)
    depends_for_pdf  = deps.push("#{THEME_DIR}/#{THEME_FILE}", LIB_EXT, LIB_EXT2, LIB_EXT3)

    desc "Build #{html_full}"
    file html_full => depends_for_html do
      make_html_full(adoc, html_full)
    end

    desc "Build #{html}"
    file html => depends_for_html do
      make_html_multi(adoc, html)
    end

    # desc "Build #{pdf}"
    file pdf => depends_for_pdf do
      make_pdf(adoc, pdf)
    end

    # desc "Build #{base} (HTML/PDF)"
    task base => [html, pdf]

    # desc "Show depends of #{html}"
    file "#{html}.deps" => depends_for_html do
      puts "#{html} ==> #{depends_for_html}."
    end

    # desc "Show depends of #{pdf}"
    file "#{pdf}.deps" => depends_for_pdf do
      puts "#{pdf} ==> #{depends_for_pdf}."
    end
  end
end

# adoc内のinclude, imageを調べて、依存ファイルリストを作る
def make_depends(adoc, images_dir, source_dir, include_dir, depends, variables)
  path = adoc.pathmap('%d')
  # p path
  include_file = ''
  image_file = ''
  cur_images_dir = images_dir
  cur_source_dir = source_dir
  cur_include_dir = include_dir
  deps = depends
  vals = variables

  # ひとまず、全行読み込んで配列に入れる
  flines = IO.readlines(adoc)

  # 1行（読み込んだ配列の1要素）ずつ処理
  flines.each do |line|
    # p line

    if line =~ /^:imagesdir:\s*([\w\-\/.]+)/
      cur_images_dir =  $1
      # puts "cur_images_dir ==> #{cur_images_dir}"
      next
    end

    # imagedir を一時的に置き換えているときの対処（保存時）
    if line =~ /^:(.+):\s*{imagesdir}/
      vals[$1] = cur_images_dir
      # p vals
      next
    end

    # imagedir を一時的に置き換えているときの対処（書き戻し時）
    if line =~ /^:imagesdir:\s*{(.+)}/
      cur_images_dir =  vals[$1]
      # puts "cur_images_dir ==> #{cur_images_dir}"
      next
    end

    if line =~ /^:sourcesdir:\s*([\w\-\/.]+)/
      cur_source_dir = $1
      # puts "cur_source_dir ==> #{path}/#{cur_source_dir}"
      next
    end

    # sourcesdir も一時的に置き換えているときの対処が必要かもしれない…
    # if line =~ /^:(.+):\s*{sourcesdir}/
    # ....
    # end

    if line =~ /^:includedir:\s*([\w\-\/.]+)/
      cur_include_dir = $1
      # puts "cur_include_dir ==> #{cur_include_dir}"
      next
    end

    if line =~ /^include::\s*([\w\-\/.{}]+)\[.*\]/
      include_file = $1
      # puts "include_file: #{include_file}"
      if include_file =~ /({sourcesdir})/
        # include_file.sub!( $1, "#{path}/#{cur_source_dir}")   # codeのとき
        include_file.sub!( $1, cur_source_dir)   # codeのとき
        # puts "source_file: #{include_file}"
      elsif include_file =~ /({includedir})/
        include_file.sub( $1, cur_include_dir)  # adocのとき
      end
      # puts "include_file ==> #{include_file}"
      # deps << include_file
      deps << "#{path}/#{include_file}"
      # その中にもincludeがあるかもしれないので
      make_depends( "#{path}/#{include_file}", images_dir, source_dir, include_dir, deps, vals )
      # puts "deps ==> #{deps}"
      # puts "vals ==> #{vals}"
      next
    end

    if line =~ /^image::\s*([\w\-\/.]+)\[.*\]/
      image_file = $1
      image_file = %(#{cur_images_dir}/#{image_file})
      # puts "image_file ==> #{image_file}"
      deps << image_file
      next
    end
  end

  # puts "== #{adoc}  #{deps} =="
  deps.uniq!
end

# ルールを生成する
make_rule_for_each_adoc
