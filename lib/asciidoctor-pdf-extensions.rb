# coding: utf-8
require 'asciidoctor-pdf' unless defined? ::Asciidoctor::Pdf

module AsciidoctorPdfExtensions

  # Override the built-in layout_toc to move colophon before front of table of contents
  # NOTE we assume that the colophon fits on a single page

  # def layout_toc doc, num_levels = 2, toc_page_number = 2, num_front_matter_pages = 0, start_at = nil
  #   go_to_page toc_page_number unless (page_number == toc_page_number) || scratch?
  #   if scratch?
  #     colophon = doc.find_by(context: :section) {|sect| sect.sectname == 'colophon' }
  #     if (colophon = colophon.first)
  #       doc.instance_variable_set :@colophon, colophon
  #       colophon.parent.blocks.delete colophon
  #     end
  #   else
  #     if (colophon = doc.instance_variable_get :@colophon)
  #       # if prepress book, consume blank page before table of contents
  #       go_to_page(page_number - 1) if @ppbook
  #       convert_section colophon
  #       go_to_page(page_number + 1)
  #     end
  #   end
  #   offset = colophon && !@ppbook ?  1 : 0
  #   toc_page_numbers = super doc, num_levels, (toc_page_number + offset), num_front_matter_pages
  #   scratch? ? ((toc_page_numbers.begin - offset)..toc_page_numbers.end) : toc_page_numbers

  # partintroのときもleadと同じに扱いたい
  # （下記ではなぜかうまくできていないのでconvert_paragraphのコピーを修正）
  # def convert_paragraph node
  #   node2 = node.clone
  #   if node.parent.style == 'partintro'
  #     node2.roles[0] = "lead"
  #   end
  #   p "#{node2.style}, #{node2.parent.style}, #{node2.content}"
  #   super node2
  # end

  def convert_paragraph node
    add_dest_for_block node if node.id
    prose_opts = { margin_bottom: 0 }
    lead = (roles = node.roles).include? 'lead'
    lead = lead || node.parent.style == 'partintro' # partintroでもleadの書式を使う
    if (align = resolve_alignment_from_role roles)
      prose_opts[:align] = align
    end

    # block indent for paragraph
    # [p_top, p_right, p_bottom, p_left]
#    pad_box [0,0,0,@theme.prose_offset_left] do

    if (text_indent = @theme.prose_text_indent)
      prose_opts[:indent_paragraphs] = text_indent
    end

    # TODO check if we're within one line of the bottom of the page
    # and advance to the next page if so (similar to logic for section titles)
    layout_caption node.title if node.title?

    if lead
      theme_font :lead do
        layout_prose node.content, prose_opts
      end
    else
      layout_prose node.content, prose_opts
    end

    if (margin_inner_val = @theme.prose_margin_inner) &&
        (next_block = (siblings = node.parent.blocks)[(siblings.index node) + 1]) && next_block.context == :paragraph
      margin_bottom_val = margin_inner_val
    else
      margin_bottom_val = @theme.prose_margin_bottom
    end
    margin_bottom margin_bottom_val
#    end  # pad_box
  end


  def layout_toc_level sections, num_levels, line_metrics, dot_leader, num_front_matter_pages = 0
    # sections.each { |key, val| p key }
    sect = sections.select { |sect| sect.sectname == 'colophon'}
    # p sect[0].sectname
    sections.delete(sect[0])
    super
  end

  def start_new_chapter chapter
    start_new_page unless at_page_top?
    if @ppbook && verso_page? && !(chapter.option? '%nonfacing')
      update_colors # prevents Ghostscript from reporting a warning when running content is written to blank page
      start_new_page unless chapter.sectname == 'colophon'
    end
  end

  def layout_part_title node, title, opts = {}
    start_new_page if verso_page?
    sectnum = node.sectnum

    if node.document.attr? 'media', 'prepress'
      move_down 160
    else
      move_down 220
    end

    if node.numbered
      title.gsub!(/#{sectnum}\s*/, "")
      if @ppbook
        layout_heading node.sectnum, align: :right, size: 60, style: :bold_italic
        move_up 20
        layout_heading title, align: :right, style: :bold_italic, size: 48
      else
        layout_heading node.sectnum, align: :right, size: 60, color: @font_color, style: :bold_italic
        move_up 20
        layout_heading title, align: :right, color: @font_color, style: :bold_italic, size: 48
      end
    else
      if @ppbook
        layout_heading title, align: :right, style: :bold_italic, size: 48
      else
        layout_heading title, align: :right, color: @font_color, style: :bold_italic, size: 48
      end
    end
    move_down 40
  end

  def layout_chapter_title node, title, opts = {}
    numbered = node.numbered
    sectnum = node.sectnum
    sectname = node.sectname
    if sectname == 'dedication' or sectname == 'acknowledgments'
      layout_heading_custom_1 node, title, align: :center
    elsif sectname == 'colophon' or sectname == 'discrete'
      layout_heading_custom_2 node, title, align: :left
    elsif sectname == 'chapter'
      start_new_page if verso_page?
      if numbered
        layout_heading_custom_3 node, title, align: :right
      else
        super
      end
    else
      super # delegate to default implementation
    end
  end

  def layout_heading_custom_1 node, string, opts = {}
    move_down 70
    typeset_text string, calc_line_metrics((opts.delete :line_height) || @theme[%(heading_h#{opts[:level]}_line_height)] || @theme.heading_line_height || @theme.base_line_height), {
      color: @font_color,
      inline_format: true,
      align: @base_align.to_sym
    }.merge(opts)
    move_down 40
  end

  def layout_heading_custom_2 node, title, opts = {}
    sep = ':'
    main, _, subtitle = title.rpartition sep

    if node.document.attr? 'media', 'prepress'
      move_down 500
    else
      move_down 500
    end
    layout_heading main, size: @theme.base_font_size * 1.6
    move_up 20
    layout_heading subtitle, size: @theme.base_font_size * 2.0
  end

  def layout_heading_custom_3 node, title, opts = {}
    sectnum = node.sectnum
    move_down 20 # 80

    if sectnum
      # title.gsub!(/#{sectnum}\s*/, "")
      if @ppbook
        # layout_heading node.sectnum, align: :right, size: 36, style: :bold_italic
        move_up 10 # 20
        # layout_heading title, align: :right, style: :bold_italic, size: 36
        layout_heading title, align: :left, style: :bold_italic, size: 28
      elsif node.document.attr? 'media', 'screen'  # for slide chapter title page
        # layout_heading node.sectnum, align: :center, size: 36, color: @font_color, style: :bold_italic
        move_up 10 # 20
        layout_heading title, align: :left, color: @font_color, style: :italic, size: 28
      else
        layout_heading node.sectnum, align: :right, size: 28, color: @font_color, style: :bold_italic
        move_up 10
        layout_heading title, align: :right, size: 28, color: @font_color, style: :bold_italic
      end
    else
      if @ppbook
        layout_heading title, align: :right, style: :bold_italic, size: 36
      else
        layout_heading title, align: :right, color: @font_color, style: :bold_italic, size: 36
      end
    end
    move_down 20 # 120
  end

end

Asciidoctor::Pdf::Converter.prepend AsciidoctorPdfExtensions
