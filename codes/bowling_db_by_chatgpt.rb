# frozen_string_literal: true

require 'active_record'
require 'securerandom'
require 'sqlite3'

# SQLite3 データベースの接続設定
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'bowling_game.db'
)

# マイグレーション: テーブル定義
class CreateBowlingGameSchema < ActiveRecord::Migration[6.0]
  def change
    create_table :score_sheets do |t|
      t.string :uuid, null: false
      t.datetime :play_date, null: false
      t.timestamps
    end

    create_table :games do |t|
      t.string :uuid, null: false
      t.references :score_sheet, foreign_key: true
      t.integer :turn, default: 0, null: false
      t.timestamps
    end

    create_table :scores do |t|
      t.string :uuid, null: false
      t.references :game, foreign_key: true
      t.string :player, null: false
      t.integer :frame_number, default: 1, null: false
      t.string :state, default: 'WAIT_FOR_1ST', null: false
      t.timestamps
    end

    create_table :frames do |t|
      t.references :score, foreign_key: true
      t.integer :frame_no, null: false
      t.integer :first, default: 0, null: false
      t.integer :second, default: 0, null: false
      t.integer :spare_bonus, default: 0, null: false
      t.integer :strike_bonus, default: 0, null: false
      t.integer :total, default: 0, null: false
      t.string :state, default: 'RESERVED', null: false
      t.timestamps
    end
  end
end

# マイグレーションを実行
CreateBowlingGameSchema.migrate(:up)

# モデル定義
class ScoreSheet < ActiveRecord::Base
  has_many :games

  before_create :set_uuid

  private

  def set_uuid
    self.uuid = SecureRandom.urlsafe_base64(8)
  end
end

class Game < ActiveRecord::Base
  belongs_to :score_sheet
  has_many :scores

  before_create :set_uuid

  private

  def set_uuid
    self.uuid = SecureRandom.urlsafe_base64(8)
  end
end

class Score < ActiveRecord::Base
  belongs_to :game
  has_many :frames

  before_create :set_uuid

  private

  def set_uuid
    self.uuid = SecureRandom.urlsafe_base64(8)
  end
end

class Frame < ActiveRecord::Base
  belongs_to :score
end

# スコアシートの作成
def create_score_sheet(date)
  ScoreSheet.create!(play_date: date)
end

# サンプルコード
if $PROGRAM_NAME == __FILE__
  # スコアシート作成
  sheet = create_score_sheet(Time.now)

  # ゲーム作成
  game = sheet.games.create!

  # スコア追加
  score1 = game.scores.create!(player: 'くぼあき')
  score2 = game.scores.create!(player: 'うえはら')

  # フレーム追加
  (1..10).each do |frame_no|
    score1.frames.create!(frame_no: frame_no)
    score2.frames.create!(frame_no: frame_no)
  end

  puts "Score Sheet: #{sheet.uuid}"
end
