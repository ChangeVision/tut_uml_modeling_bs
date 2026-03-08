# frozen_string_literal: true

# ステートマシン図の状態の値用クラス
class SampleState
  def initialize
    @states = %i[ST0 ST1 ST2]
    @state = :ST0
  end

  def transit_to(new)
    if @states.include?(new)
      @state = new
    else
      p "invlid state: #{new}."
    end
    @state
  end

  def current
    @state
  end
end

# ステートマシン図とコードの対応づけルールの検討用クラス
class Sample
  attr_accessor :guards

  def initialize
    @state = SampleState.new
    @guards = [true, true]
  end

  def gd1?
    @guards[0]
  end

  def gd2?
    @guards[1]
  end

  def st0_proc(evt, p01)
    case evt
    when :ev1
      if gd1? # guard
        puts "    gd1: #{gd1?}"
        act1(evt, p01)
        @state.transit_to(:ST1)
      else
        puts "    <<< gd1: #{gd1?}, transition is ignored. >>>"
      end
    when :ev3
      act3(evt, p01)
      @state.transit_to(:ST2)
    end
  end

  def st1_proc(evt, p01)
    case evt
    when :ev2
      act2(evt, p01)
      puts "    gd2: #{gd2?}"
      if gd2? # guard on choice.
        @state.transit_to(:ST2)
      else
        act3(evt, p01)
        @state.transit_to(:ST0)
      end
    when :ev3
      act3(evt, p01)
      @state.transit_to(:ST0)
    end
  end

  def play(evt, p01 = 0)
    puts "#{@state.current} ->"
    puts "  event:#{evt}, param: #{p01}"
    case @state.current
    when :ST0
      st0_proc(evt, p01)
    when :ST1
      st1_proc(evt, p01)
    when :ST2
      # none
    end
    puts "       -> #{@state.current}"
    puts 'finished.' if @state.current == :ST2
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
end

class SampleTest
  def test_base(events_list, guards)
    events_list.each do |events|
      @samp01 = Sample.new
      @samp01.guards = guards
      events.each do |evt|
        i = Time.now.usec
        @samp01.play(evt, i)
      end
      puts '----------------'
    end
  end

  def test01
    gurads = [true, true]

    events_list = [
      %i[ev1 ev2],
      %i[ev3],
      %i[ev1 ev3 ev3]
    ]

    test_base(events_list, gurads)
  end

  def test02
    gurads = [false, false]

    events_list = [
      %i[ev1 ev3], # :ev1 will be ignored.
      %i[ev1 ev2 ev3] # :ev1 and ev2 will be ignored.
    ]

    test_base(events_list, gurads)
  end

  def test03
    gurads = [true, false]

    events_list = [
      %i[ev1 ev2 ev3],
      %i[ev3]
    ]
    test_base(events_list, gurads)
  end

  def run
    puts '================'
    test01
    puts '================'
    test02
    puts '================'
    test03
  end
end

if $PROGRAM_NAME == __FILE__
  state = SampleState.new
  puts state.current

  puts state.transit_to(:ST2)

  puts state.transit_to(:ST4)
  puts state.transit_to(:ST1)
  puts'- - - -'

  test = SampleTest.new
  test.run

require 'golem'

class GolemSample
  include Golem

  attr_accessor :state

  def initialize(name)
    @name = name
  end

  def to_s
    @name
  end

  def gd1?
    true
  end

  def act1
    puts "triggered #{aasm.current_event}"
  end

  define_statamachine do
    inisital_state :ST0
    state :ST0 do
      on :ev1 do
        transition to: :ST1, if: :gd1? do
          action { act1 }
        end
      end
    end
    state :ST1 do
      on :ev2 do
        transition to: :ST0, unless: :gd2? do
        end
        transition to: :ST2, if: :gd2? do
        end
      end
    end
    state :ST2 do
    end
  end
end
as = GolemSample.new
p as.sleep?
p as.may_sence?
p as.sence { p 42}
p as.sleep?
p as.sence?
end
