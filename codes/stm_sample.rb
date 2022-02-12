# frozen_string_literal: true

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample
  attr_accessor :state, :gd1, :gd2

  def initialize
    @state = :ST0
    @gd1 = true
    @gd2 = true
  end

  def restart
    @state = :ST0
  end

  def act1(evt, p1)
    puts '   act1の処理'
  end

  def act2(evt, p1)
    puts '   act2の処理'
  end

  def act3(evt, p1)
    puts '   act3の処理'
  end

  def st0_proc(evt, p1)
    case evt
    when :ev1
      if gd1
        puts "   gd1(#{gd1})"
        act1(evt, p1)
        @state = :ST1
      else
        puts "   gd1(#{gd1}) is ignored."
      end
    when :ev3
      act3(evt, p1)
      @state = :ST2
    end
  end

  def st1_proc(evt, p1)
    case evt
    when :ev2
      act2(evt, p1)
      if gd2
        puts "   gd2(#{gd2})"
        @state = :ST2
      else
        puts "   gd2(#{gd2})"
        act3(evt, p1)
        @state = :ST0
      end
    when :ev3
      act3(evt, p1)
      @state = :ST0
    end
  end

  def play(evt, p1 = 0)
    puts "#{@state} ->"
    puts "   event:#{evt}"
    case @state
    when :ST0
      st0_proc(evt, p1)
    when :ST1
      st1_proc(evt, p1)
    when :ST2
      puts 'finished.'
    end
    puts "    -> #{@state}"
  end
end

if $PROGRAM_NAME == __FILE__
  events_list = [
    [ :ev1, :ev2, :ev3 ],
    [ :ev3 ],
    [ :ev1, :ev3 ]
  ]

  samp01 = Sample.new
  events_list. each do |events|
    puts "===="
    samp01.restart
    events.each do |evt|
      samp01.play(evt, 'param1')
    end
  end

  puts "========"
  samp01.gd1 = false
  samp01.gd2 = false

  events_list2 = [
    [ :ev1, :ev3 ], # :ev1 will be ignored.
    [ :ev3 ],
  ]
  events_list2. each do |events|
    puts "===="
    samp01.restart
    events.each do |evt|
      samp01.play(evt, 'param1')
    end
  end

  puts "========"
  samp01.gd1 = true
  samp01.gd2 = false

  events_list2 = [
    [ :ev1, :ev2, :ev3 ],
    [ :ev3 ],
  ]
  events_list2. each do |events|
    puts "===="
    samp01.restart
    events.each do |evt|
      samp01.play(evt, 'param1')
    end
  end
end
