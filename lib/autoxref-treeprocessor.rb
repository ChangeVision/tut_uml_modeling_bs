# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

Extensions.register do
  treeprocessor AutoXrefTreeprocessor
end

# Run using:
#
# asciidoctor -r ./lib/autoxref-treeprocessor.rb lib/autoxref-treeprocessor/sample.adoc

# You can hange caption string for autoxref like below:
# :autoxref-sectcaption: 節%d.%d
# :autoxref-imagecaption: 図%d.%d
# :autoxref-listingcaption: リスト%d.%d
# :autoxref-tablecaption: 表%d.%d

class AutoXrefTreeprocessor < Extensions::Treeprocessor
  def process document
    # Captions should we use.
    caption = {
      :section => (document.attr 'autoxref-sectcaption', "Section %d.%d"),
      :image => (document.attr 'autoxref-imagecaption', "Figure %d.%d"),
      :listing => (document.attr 'autoxref-listingcaption', "Listing %d.%d"),
      :table => (document.attr 'autoxref-tablecaption', "Table %d.%d")
    }

    # Reference number counter.  Reference numbers are reset by chapters.
    counter = {
      :chapter => 1,
      :section => 1,
      :image => 1,
      :listing => 1,
      :table => 1
    }

    document.find_by(context: :section).each do |blk|
      # pp {blk.title}, #{blk.numbered}, #{blk.level},  #{blk.sectname},  #{blk.sectnum}"
       if blk.sectname == 'chapter'
        reset_counter(blk, counter)
        [:image, :listing, :table].each do |type|
          blk.find_by(context: type).each do |elem|
            next unless elem.title
            replaced =  %(#{sprintf(caption[type], blk.sectnum_org.to_i, counter[type])}).lstrip
            replaced_caption = replaced + ' '
            elem.attributes['caption'] = replaced_caption
            elem.caption = replaced_caption
            document.references[:ids][elem.attributes['id']] = replaced
            update_counter(type, counter)
          end
        end
      end
    end
  end

  def reset_counter chapter, counter
    counter[:chapter] = chapter.sectnum.to_i
    counter[:section] = counter[:image] = counter[:listing] = counter[:table] = 1
  end

  def update_counter type, counter
    counter[type] = counter[type] + 1
  end
end
