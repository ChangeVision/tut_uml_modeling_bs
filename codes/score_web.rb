# frozen_string_literal: true

require 'webrick'
require 'erb'
require 'open3'
require 'bcrypt'
require_relative 'score'

# Web Server for Bowling Scoring.
class BowlingWeb
  def initialize(bind_address = '127.0.0.1') # localhost
    @config = {
      DocumentRoot: './',
      BindAddress: bind_address,
      Port: 8099
    }
    @server = WEBrick::HTTPServer.new(@config)
    WEBrick::HTTPServlet::FileHandler.add_handler('erb', WEBrick::HTTPServlet::ERBHandler)
    @server.config[:MimeTypes]['erb'] = 'text/html'
    trap('INT') { @server.shutdown }
    add_handler_procs
  end

  def add_handler_procs
    register_player_proc
    start_game_proc
    update_score_proc
  end

  def validate_username(name)
    ret = name.empty? ||
          name.length < 4 || name.length > 16 ||
          name !~ /\A[a-z0-9]+\z/ || !name.start_with?(/[a-z]/)
    !ret
  end

  def validate_player_name(name)
    ret = name.empty? || name.length < 4 || name.length > 16
    !ret
  end

  def validate_password(pwd)
    ret = pwd.empty? ||
          pwd.length < 6 || pwd.length > 16 ||
          pwd !~ /\A[a-z0-9]+\z/
    !ret
  end

  def register_player_proc
    @server.mount_proc('/register_player') do |req, res|
      msg = {
        'username' => 'ユーザー名は半角で英小文字から始まり英小文字数字の組み合わせで4文字以上16文字までです。',
        'player_name' => 'プレーヤー名は4文字上16文字までです。',
        'password' => 'パスワードは半角6文字以上16文字以内です。'
      }
      p req.query
      username = req.query['username'].force_encoding('UTF-8')
      msg['username'] = 'OK.' if validate_username(username)
      player_name = req.query['player_name'].force_encoding('UTF-8')
      msg['player_name'] = 'OK.' if validate_player_name(player_name)
      password = req.query['password'].force_encoding('UTF-8')
      msg['password'] = 'OK.' if validate_password(password)
      admin = req.query['amdin']
      p msg
      if msg.count('OK.') < 3
        erb = 'register_player_error.erb'
      else
        erb = 'registered_player.erb'
        hashed_password = BCrypt::Password.create(password)
      end
      template = ERB.new(File.read(erb))
      res.body << template.result(binding)
    end
  end

  def start_game_proc
    @server.mount_proc('/start_game') do |req, res|
      p req.query
      player = req.query['name']
      player.force_encoding('UTF-8')
      @game = Bowling::Game.new(player)
      erb = 'start_game08.erb'
      template = ERB.new(File.read(erb))
      res.body << template.result(binding)
    end
  end

  def update_score_proc
    @server.mount_proc('/update_score') do |req, res|
      p req.query
      pins = req.query['pins'].to_i
      if @game.game_score.scoring(pins) == -1
        erb = 'input_error.erb'
      else
        erb = 'update_score08.erb'
      end
      template = ERB.new(File.read(erb))
      res.body << template.result(binding)
    end
  end

  def run
    @server.start
  end
end

if __FILE__ == $PROGRAM_NAME
  app = BowlingWeb.new
  app.run
end
