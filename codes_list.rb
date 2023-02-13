# frozen_string_literal: true

require 'date'
require 'fileutils'

list_targets = {
  'app_develop_loadmap.adoc' => 'chap01',
  'app_tech_research.adoc' => 'chap02',
  'dev_cmd_line_app.adoc' => 'chap03',
  'web_app_tech_research_sub.adoc' => 'chap04',
  'dev_web_app.adoc' => 'chap05',
  'dev_excel_app.adoc' => 'chap06',
  'setup_ruby_env.adoc' => 'appendix-c',
  'ruby_basics.adoc' => 'appendix-d',
  'column08.adoc' => 'column08',
}

date =  Date.today.strftime("%Y%m%d")
dir_name = "rubybook3-samples-#{date}"
Dir.mkdir(dir_name)
zip_name = dir_name + '.zip'

list_targets.each do |adoc, chap|
  File.open(adoc, 'r') do |f|
    source_files = []
    puts "#{adoc}, #{chap} ----------"
    sub_dir_name = "#{dir_name}/#{chap}"
    Dir.mkdir(sub_dir_name)
    f.each do |line|
      # if line =~ /include::(.+adoc)/
      #   puts line
      # end
      if line =~ %r{include::\{sourcesdir\}/(.+)\[.*\]}
        source_files << $1
      end
    end
    if chap == 'chap05'
      source_files.concat(['webapp/collect.erb', 'webapp/delete.erb', 'webapp/index.html',
                          'webapp/list.erb', 'webapp/nodeleted.erb', 'webapp/report.erb'])
    end
    files = source_files.uniq.sort
    files.each do |f3|
      from = 'codes/' + f3
      f3_2 = f3.split('/')
      if f3_2.size > 1
        sub_sub_dir_name = sub_dir_name + '/' + f3_2.first
        Dir.mkdir(sub_sub_dir_name) unless Dir.exist?(sub_sub_dir_name)
      end
      to = sub_dir_name + '/' + f3
      puts "from: #{from},  to: #{to}"
      # File.open(from, 'r') do |f4|
      #   File.open(to, 'w') do |f5|
      FileUtils.copy(from, to)
      # end
      # end
    end
  end
end

system "zip -r #{zip_name} #{dir_name}"
