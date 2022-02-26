# frozen_string_literal: true

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample
  attr_accessor :attr_a, :attr_b

  def initialize
    @state = :ST0
    @attr_a = true
    @attr_b = true
  end

  def st0_proc(evt, param)
    case evt
    when :ev1
      if gd1? # guard
        puts "    gd1: #{gd1?}"
        act1(evt, param)
        @state = :ST1
      else
        puts "    <<< gd1: #{gd1?}, transition is ignored. >>>"
      end
    when :ev3
      act3(evt, param)
      @state = :ST2
    end
  end

  def st1_proc(evt, param)
    case evt
    when :ev2
      act2(evt, param)
      puts "    gd2: #{gd2?}"
      if gd2? # guard on choice.
        @state = :ST2
      else
        act3(evt, param)
        @state = :ST0
      end
    when :ev3
      act3(evt, param)
      @state = :ST0
    end
  end

  def play(evt, param)
    puts "#{@state} ->"
    puts "  event:#{evt}, param: #{param}"
    case @state
    when :ST0
      st0_proc(evt, param)
    when :ST1
      st1_proc(evt, param)
    when :ST2
      # none
    end
    puts "       -> #{@state}"
    puts 'finished.' if @state == :ST2
  end

  private

  def act1(evt, prm)
    puts "     act1: event:#{evt}, param: #{prm}"
  end

  def act2(evt, prm)
    puts "     act2: event:#{evt}, param: #{prm}"
  end

  def act3(evt, prm)
    puts "     act3: event:#{evt}, param: #{prm}"
  end

  def gd1?
    @attr_a && @attr_b
  end

  def gd2?
    !@attr_a || @attr_b
  end
end

# 検討用クラスのテストケースを提供するクラス
class SampleTest
  def test_base(events, data)
    samp01 = Sample.new
    samp01.attr_a = data[0]
    samp01.attr_b = data[1]
    events.each do |evt|
      samp01.play(evt, Time.now.usec)
    end
    puts '================'
  end

  def test01
    test_base(%i[ev1 ev2], [true, true])
  end

  def test02
    test_base(%i[ev1 ev3], [false, false]) # :ev1 will be ignored.
  end

  def test03
    test_base(%i[ev1 ev2 ev3], [true, false])
  end

  def run
    test01
    test02
    test03
  end
end

if $PROGRAM_NAME == __FILE__
  test = SampleTest.new
  test.run
end
