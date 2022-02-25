# frozen_string_literal: true

require 'securerandom'

# Frameは1フレーム分のピン数やボーナスを記録する
class Frame
  attr_reader :frame_no
  attr_accessor :first, :second, :spare_bonus, :strike_bonus, :total, :state

  def initialize(frame_no)
    @frame_no = frame_no
    @first = 0
    @second = 0
    @spare_bonus = 0
    @strike_bonus = 0
    @total = 0
    @state = :RESERVED
  end

  def action(event, pins=0)
    case @state
    when :RESERVED
      case event
      when :SETUP
        @state = :BEFORE_1ST
      else
        puts "invalid event: #{event} is ignored."
      end
    when :BEFORE_1ST
      before_1st_porc(event, pins)
    when :BEFORE_2ND
      before_2nd_proc(event, pins)
    when :PENDING
      case event
      when :DETERMINE
        @state = :FIXED
      end
    when :FIXED
      puts 'fixed.'
    end
  end

  def frame_score
    @first + @second + @spare_bonus + @strike_bonus
  end

  def strike?
    @first == 10
  end

  def spare?
    @first < 10 && (@first + @second) == 10
  end

  def miss?
    @first < 10 && @second.zero && @state == :FIXED
  end

  def gutter?
    @first.zero
  end

  def fixed?
    @state == :FIXED
  end

  def to_s
    total = if @state == :FIXED
              @total
            else
              '   .'
            end
    format '|%2d|%3s|%3s|%5s|%11d|%11d|%12d|%13s|',
           @frame_no, @first, @second, total, frame_score,
           @spare_bonus, @strike_bonus, @state
  end

  private

  def before_1st_porc(evt, pins)
    case evt
    when :PINS
      puts "invalid pins: #{pins}" if pins.negative? || pins > 10
      @first = pins
      @state = if strike?
                 @second = 0
                 :PENDING
               else
                 :BEFORE_2ND
               end
    else
      puts "invalid event: #{evt} on #{@state}."
    end
  end

  def before_2nd_proc(evt, pins)
    case evt
    when :PINS
      puts "invalid pins: #{pins}" if pins.negative? || pins > (10 - @first)
      @second = pins
      @state = if spare?
                 :PENDING
               else
                 :FIXED
               end
    else
      puts "invalid event: #{evt} on #{@state}."
    end
  end
end

# スコアは各人の10フレーム分のスコアを記録する
class Score
  attr_accessor :id, :player, :fno, :frames, :state

  def initialize(name)
    @id = SecureRandom.urlsafe_base64(8)
    @player = name
    @fno = 1
    @frames = []
    (-1..13).each do |fno| # (-1, 0) are dummy frame
      @frames.append Frame.new(fno)
    end
    @state = :WAIT_FOR_1ST
    @frames[fno2idx(@fno)].action(:SETUP)
  end

  def fno2idx(fno)
    fno + 1 # frame number 1 => array index 3 (0 origin).
  end

  def frame(fno)
    @frames[fno2idx(fno)] # return index on @frams at frame number.
  end

  def go_next_frame
    @fno += 1
    @frames[fno2idx(fno)].action(:SETUP)
  end

  def current
    frame(@fno)
  end

  def prev
    frame(@fno - 1)
  end

  def pprev
    frame(@fno - 2)
  end

  def calc_spare_bonus_after_1st
    return unless prev.spare?

    prev.spare_bonus = current.first
    prev.action(:DETERMINE)
  end

  def calc_strike_bonus_after_1st
    return unless prev.strike? && pprev.strike?

    pprev.strike_bonus = prev.first + current.first
    pprev.action(:DETERMINE)
  end

  def calc_strike_bonus_after_2nd
    return unless prev.strike?

    prev.strike_bonus = current.first + current.second
    prev.action(:DETERMINE)
  end

  def update_total
    @frames.each_cons(2) do |prev, cur|
      cur.total = prev.total + cur.frame_score
    end
  end

  def finished?
    frame(10).fixed?
  end

  def wait_for_1st_proc(pins)
    current.action(:PINS, pins)
    calc_spare_bonus_after_1st
    calc_strike_bonus_after_1st
    update_total
    if finished?
      @state = :FINISHED
    elsif current.strike?
      @state = :WAIT_FOR_1ST
      go_next_frame
    else
      @state = :WAIT_FOR_2ND
    end
  end

  def wait_for_2nd_proc(pins)
    current.action(:PINS, pins)
    calc_strike_bonus_after_2nd
    update_total
    if finished?
      @state = :FINISHED
    else
      @state = :WAIT_FOR_1ST
      go_next_frame
    end
  end

  def scoring(pins)
    case @state
    when :WAIT_FOR_1ST
      wait_for_1st_proc(pins)
    when :WAIT_FOR_2ND
      wait_for_2nd_proc(pins)
    when :FINISHED
      puts 'finished'
    end
  end

  def to_s
    "Score(id: #{@id}),\nPlayer:#{@player}, Frame:#{@fno},\n#{@frames.join("\n")}"
  end
end

# Gameクラスは複数名の1ゲーム分のスコアのセットを構成する
class Game
  attr_reader :id, :turn, :scores

  def initialize
    @id = SecureRandom.urlsafe_base64(8)
    @turn = 0
    @scores = []
  end

  def entry(name = 'unknown')
    @scores.append(Score.new(name))
  end

  def turn_player_name
    @scores[@turn].player
  end

  def go_next_turn
    @turn = (@turn + 1) % @scores.size
  end

  def playing(score_index, pins)
    @scores[score_index].scoring(pins)
    if @scores[score_index].fno > 10
      go_next_turn if @scores[score_index].finished?
    elsif @scores[score_index].current.state == :BEFORE_1ST
      go_next_turn
    end
  end

  def finished?
    @scores.reject(&:finished?) == []
  end

  def to_s
    "Game(id:#{@id}),\n#{@scores.join("\n")}"
  end
end

# ScoreSheetは、複数名の複数回のGameを記録する
class ScoreSheet
  attr_accessor :id, :time, :games

  def initialize(date)
    @id = SecureRandom.urlsafe_base64(8)
    @play_date = date
    @games = []
  end

  def add_game(games = 1)
    games.times do
      @games.append(Game.new)
    end
  end

  def to_s
    "Score Sheet Date: #{@play_date}(id:#{@id})"
  end
end

if $PROGRAM_NAME == __FILE__
  sheet = ScoreSheet.new(Time.now)
  sheet.add_game
  game = sheet.games.last
  game.entry('くぼあき')
  game.entry('うえはら')
  puts sheet

  game_records = [
    # [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 10, 6, 4],
    # [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 5, 3],
    [7, 0, 5, 5, 10, 10, 5, 4, 10, 7, 3, 5, 4, 7, 3, 7, 3, 4],
    [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 6, 3]
  ]

  until game.finished?
    puts '----------------------------------------'
    puts "turn: #{game.turn_player_name}"
    score_index = game.turn
    pins = game_records[score_index].shift
    puts "input pins: #{pins}"
    game.playing(score_index, pins)
    puts game.to_s
    gets
  end

  puts "Game(id:#{game.id}) is finished."
end
