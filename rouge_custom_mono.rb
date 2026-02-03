# -*- coding: utf-8 -*- #

require 'rouge' unless defined? ::Rouge.version

module Rouge
  module Themes
    class MyTheme < CSSTheme
      name 'custom'  #
      'mytheme'

      style Comment::Multiline,               :fg => '#606060', :italic => true
      style Comment::Preproc,                 :fg => '#383838'
      style Comment::Single,                  :fg => '#606060', :italic => true
      style Comment::Special,                 :fg => '#606060', :italic => true, :bold => true
      style Comment,                          :fg => '#606060', :italic => true
      style Error,                            :fg => '#000000', :bg => '#cccccc'
      style Generic::Deleted,                 :fg => '#000000', :bg => '#cccccc'
      style Generic::Emph,                    :fg => '#000000', :italic => true
      style Generic::Error,                   :fg => '#000000'
      style Generic::Heading,                 :fg => '#000000' # '#7f7f7f'
      style Generic::Inserted,                :fg => '#000000', :bg => '#cccccc'
      style Generic::Output,                  :fg => '#383838'
      style Generic::Prompt,                  :fg => '#000000' #, :bg => '#cccccc'
      style Generic::Strong,                  :bold => true
      style Generic::Subheading,              :fg => '#cccccc'
      style Generic::Traceback,               :fg => '#606060'
      style Generic::Lineno,                  :fg => '#606060'
      style Keyword::Constant,                :fg => '#000000', :bold => true
      style Keyword::Declaration,             :fg => '#000000', :bold => true
      style Keyword::Namespace,               :fg => '#000000', :bold => true
      style Keyword::Pseudo,                  :fg => '#000000', :bold => true
      style Keyword::Reserved,                :fg => '#000000', :bold => true
      style Keyword::Type,                    :fg => '#555555', :bold => true
      style Keyword,                          :fg => '#555555', :bold => true
      style Literal::Number::Float,           :fg => '#000000'
      style Literal::Number::Hex,             :fg => '#000000'
      style Literal::Number::Integer::Long,   :fg => '#000000'
      style Literal::Number::Integer,         :fg => '#000000'
      style Literal::Number::Oct,             :fg => '#000000'
      style Literal::Number,                  :fg => '#000000'
      style Literal::String::Backtick,        :fg => '#000000'
      style Literal::String::Char,            :fg => '#000000'
      style Literal::String::Doc,             :fg => '#000000'
      style Literal::String::Double,          :fg => '#000000'
      style Literal::String::Escape,          :fg => '#000000'
      style Literal::String::Heredoc,         :fg => '#000000'
      style Literal::String::Interpol,        :fg => '#000000'
      style Literal::String::Other,           :fg => '#000000'
      style Literal::String::Regex,           :fg => '#555555'
      style Literal::String::Single,          :fg => '#000000'
      style Literal::String::Symbol,          :fg => '#000000'
      style Literal::String,                  :fg => '#000000'
      style Name::Attribute,                  :fg => '#606060'
      style Name::Builtin::Pseudo,            :fg => '#606060'
      style Name::Builtin,                    :fg => '#000000'
      style Name::Class,                      :fg => '#000000', :bold => true
      style Name::Constant,                   :fg => '#000000'  # '#606060'
      style Name::Decorator,                  :fg => '#555555', :bold => true
      style Name::Entity,                     :fg => '#555555'
      style Name::Exception,                  :fg => '#555555', :bold => true
      style Name::Function,                   :fg => '#555555', :bold => true
      style Name::Label,                      :fg => '#555555', :bold => true
      style Name::Namespace,                  :fg => '#555555'
      style Name::Tag,                        :fg => '#000000'
      style Name::Variable::Class,            :fg => '#000000'
      style Name::Variable::Global,           :fg => '#000000'
      style Name::Variable::Instance,         :fg => '#000000'
      style Name::Variable,                   :fg => '#555555'
      style Operator::Word,                   :fg => '#000000', :bold => true
      style Operator,                         :fg => '#000000', :bold => true
      style Text::Whitespace,                 :fg => '#7f7f7f'
      style Text,                             :bg => '#ffffff'
    end
  end
end
