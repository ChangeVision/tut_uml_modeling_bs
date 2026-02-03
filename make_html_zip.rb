# frozen_string_literal: true

require 'pathname'
require 'find'
require 'zip'

# HTMLファイルと関係するファイルをZipするためのクラス
class HtmlZipper
  attr_reader :images, :csses, :models, :videos, :javascripts, :codes, :htmls

  def initialize
    @lines = []
    @images = []
    @csses = []
    @models = []
    @videos = []
    @javascripts = []
    @htmls = []
    @base_dir = '.'
    @codes = %w[score.rb stm_sample.rb] # 要なコードファイルを特定するキーが見当たらないので手で追加
    @all_entries = []
  end

  def collect_html_contents(html_files)
    html_files.each do |html|
      puts "input from: #{html}"
      @base_dir = Pathname.new(html).dirname.to_s
      flines = IO.readlines(html)
      flines.each do |line|
        case line
        when %r{(images/.+\.(png|svg|jpg|jpeg))}
          @images.push($1)
        when %r{.*/(.+\.css)}
          @csses.push($1)
        when /([\d\w]+\.asta)/
          @models.push($1)
        when /([\d\w_-]+\.(mp4|mov))/
          @videos.push($1)
        when /([\d\w_-]+\.(js))/
          @javascripts.push($1)
        when /"([\d\w_-]+\.(html))"/
          @htmls.push($1)
          # when /???/
          # @codes.push($1)
        end
      end
    end
    @images.uniq!
    @csses.uniq!
    @models.uniq!
    @videos.uniq!
    @javascripts.uniq!
    @htmls.uniq!
    # @codes.uniq!
  end

  def find_contents_location(files)
    Dir.glob(files.map { |file| "#{@base_dir}/**/#{file}" })
  end

  def find_up_all_contents
    @all_entries = find_contents_location(@images) +
                   find_contents_location(@csses)  +
                   find_contents_location(@models) +
                   find_contents_location(@videos) +
                   find_contents_location(@javascripts) +
                   find_contents_location(@htmls) +
                   find_contents_location(@codes)
  end

  def create_zip_archive(zip_name = 'achive.zip')
    if File.exist?(zip_name)
      abort "#{zip_name} already exists."
    end
    basename = File.basename(zip_name, '.*')
    Zip::File.open(zip_name, create: true) do |zipfile|
      @all_entries.each do |file|
        zipfile.add("#{basename}/#{file.sub(%r{^\./}, '')}", file)
      end
    end
  end

  def list_zip_entries(zip_name = 'achive.zip')
    Zip::File.open(zip_name) do |zipfile|
      zipfile.each do |entry|
        puts "entry:#{entry.name}"
      end
    end
  end

  def make_zip_archive(zip_name, html_files)
    collect_html_contents(html_files)
    find_up_all_contents
    create_zip_archive(zip_name)
    list_zip_entries(zip_name)
  end
end

#
# ruby make_html_zip.rb tut_uml_modeling_bs_html.zip tut_uml_modeling_bs.html tut_uml_modeling_bs_full.html
#
if $PROGRAM_NAME == __FILE__
  zipper = HtmlZipper.new
  abort "usage: ruby #{$PROGRAM_NAME} zip_file_name html_file [html_file ...]" if ARGV.empty?
  zip_name = ARGV.shift
  html_files = ARGV
  zipper.make_zip_archive(zip_name, html_files)
end
