# frozen_string_literal: true

# def find_depends(f)
#   incl_docs = IO.readlines(f).grep(/include::(.*\.(asciidoc|adoc|inc))\[.*\]\n/){"#{$1}"}
#   ret = incl_docs
#   incl_docs.each do |ff|
#     ret.concat(find_depends(ff))
#   end
#   return ret.uniq
# end

def find_depends_html(f)
  incl_docs = IO.readlines(f).grep(/include::(.*\.(asciidoc|adoc|inc))\[.*\]\n/){"#{$1}"}
  ret = incl_docs
  incl_docs.each do |ff|
    ret.concat(find_depends(ff))
  end
  return ret.uniq
end

def find_depends_image(deps)
  ret = []
  deps.each do |f|
    images = IO.readlines(f).grep(/image::(.*)\[.*\]\n/){"#{$1}"}
    ret.concat(images)
  end
  return ret.uniq
end

def find_depends_source(deps)
  ret = []
  deps.each do |f|
    sources = IO.readlines(f).grep(/include::({sourcedir}\/.*)\[.*\]\n/){"#{$1}"}
    ret.concat(sources)
  end
  return ret.uniq
end

if __FILE__ == $0
  CODES_DIR = 'codes'
  IMAGES_DIR = 'images'
  input = ARGV.shift
  deps = find_depends(input)
  p deps
  deps << input
  ret = find_depends_image(deps)
  ret.map! {|n| IMAGES_DIR + '/' + n }
  p ret
  ret = find_depends_source(deps)
  ret.map! {|n| n.sub(/{sourcedir}/, CODES_DIR) }
  p ret
end
