# frozen_string_literal: true

require 'webrick'
require 'erb'
require 'open3'
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
    entry_proc
    start_game_proc
    update_score_proc
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
