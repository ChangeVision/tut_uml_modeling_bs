# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

# 部、章、節のタイトル前のラベルの書式を与えて変更できるようにする
# sptintfに似たフォーマットを使えるようにする
#
# usage:
#    asciidoctor(-pdf) -r ./lib/heading-treeprocessor.rb  lib/heading-treeprocessor/sample.adoc
#
# example on adoc:
#
# :part-label: 第%s部
# :chapter-label: 第%s章
# 下記のような節以下の対応は未対応
# NG. :section-label: %s節   # 1.1節 Section Name
#
# QUESTION:
# :partnums: の設定が必要かどうか…
#

Extensions.register do
  treeprocessor HeadingTreeprocessor
end

class AbstractBlock
  alias_method :xreftext_org, :xreftext

  # asciidoctor-pdfでの参照リンク整形のため
  def xreftext xrefstyle = nil
    if (val = reftext) && !val.empty?
      val
    # NOTE xrefstyle only applies to blocks with a title and a caption or number
    elsif xrefstyle && @title && @caption
      caption = @caption.chomp '. '
      xreftext = document.references[:ids][@id]
      case xrefstyle
      when 'full'
        if xreftext
          %(#{xreftext}:#{title})
        elsif @numeral && (caption_attr_name = CAPTION_ATTRIBUTE_NAMES[@context]) && (prefix = @document.attributes[caption_attr_name])
          %(#{prefix}#{@numeral}:#{title})
        else
          %(#{caption}:#{title})
        end
      when 'short'
        if xreftext
          xreftext
        elsif @numeral && (caption_attr_name = CAPTION_ATTRIBUTE_NAMES[@context]) && (prefix = @document.attributes[caption_attr_name])
          %(#{prefix}#{@numeral})
        else
          caption
        end
      else # 'basic'
        title
      end
    else
      title
    end
  end
end

class Section
  alias_method :sectnum_org, :sectnum
  alias_method :xreftext_org, :xreftext

  # asciidoctor-pdf対応のため
  def numbered_title opts = {}
    slevel = @level == 0 && @special ? 1 : @level
    sectnumlevels = (@document.attr 'sectnumlevels', 3).to_i
    if @numbered && !@caption && slevel <= sectnumlevels
      # 番号付きヘッダ
      # "#{sectnum} #{title} --a"
      "#{sectnum} #{title}"
    else
      # 付録など
      if @numbered && slevel <= sectnumlevels
        caption = (@document.attr 'appendix-caption')
        if caption and @sectname == 'appendix'
          # %(#{caption}#{sectnum}: #{title} --b)
          %(#{caption}#{sectnum}: #{title})
        else
          # "#{sectnum} #{title} --c"
          "#{sectnum} #{title}"
        end
      else
        # 番号なしヘッダ
        # #{title} --d"
        title
      end
    end
  end

  # 部、章のタイトルの整形
  def sectnum(delimiter = '.', append = nil)
    sectnum_org_str = sectnum_org(delimiter, append)
    if sectname == 'part' or sectname == 'chapter'
      label_name = "#{sectname}-label"
      label_format = (document.attr label_name)
      if label_format != nil and label_format.include?("%s")
        %(#{sprintf( label_format, sectnum_org_str.to_i)}).lstrip
      else
        sectnum_org_str
      end
    elsif Section === @parent
      if @level > 2
        %(#{@parent.sectnum(delimiter, delimiter)}#{@numeral}#{append})
      elsif @level > 1
        %(#{@parent.sectnum_org(delimiter, delimiter)}#{@numeral}#{append})
      else
        # 節レベルappendixはここ
        @numeral
      end
    else
      # 章レベルappendixはここ
      %(#{@numeral}#{append})
    end
  end

  # asciidoctorでの参照リンク整形のため
  def xreftext xrefstyle = nil
    if (val = reftext) && !val.empty?
      val
    elsif xrefstyle
      if @numbered
        case xrefstyle
        when 'full'
          if (signifier = @document.attributes[%(#{@sectname}-refsig)]) and signifier != ""
            %(#{signifier}#{sectnum '.', ''}:#{title})
          else
            %(#{sectnum '.', ''}:#{title})
          end
        when 'short'
          if (signifier = @document.attributes[%(#{@sectname}-refsig)]) and signifier != ""
            %(#{signifier}#{sectnum '.', ''})
          else
            sectnum '.', ''
          end
        else # 'basic'
           title
        end
      else # apply basic styling
        title
      end
    else
      title
    end
  end

end


class HeadingTreeprocessor < Extensions::Treeprocessor
  def process document
    (document.find_by context: :section).each do |blk|
      if /part/ =~  blk.sectname
        blk.numbered = true
        blk.numeral = (document.counter 'part-number', 1)
      end
    end
  end
end
