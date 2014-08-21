require 'colorize'
require './lib/characters/player'
require './lib/commands'
require './lib/helpers'

module BanditMayhem
  class Game
    attr_accessor :player, :quit, :cmds, :devmode

    @devmode = true

    def initialize(name)
      @cmds = []
      @player = BanditMayhem::Characters::Player.new({name: name})
      @command_proc = BanditMayhem::Commands.new(self)

      @quit = false

      Game.cls
      puts "\t\tWelcome to BANDIT MAYHEM, #{@player.get_av('name')}\n\n".yellow
    end

    # This is the main game loop.
    def main
      return quit = true if @player.is_dead?
      update
    end

    def self.cls
      system 'clear' unless system 'cls'
    end

    def draw
    end

    def update
      # show health
      show_map
      puts '-----' + @player.get_av('name').blue + '-----'
      puts @player.get_av('health').to_s.red + 'hp'
      puts '$' + @player.get_av('gold').to_s.yellow
      puts 'Weapon: ' + @player.weapon.get_property('name').to_s.green
      puts ''
      puts 'Enter a command (type /help for commands) : '
      STDOUT.flush
      cmd = gets.chomp
      execute(cmd)
    end

    # this subroutine will decide what to do with cmd
    def execute(cmd)
      if cmd.include? '/'
        @cmds << cmd

        cmd.downcase!

        full_cmd = cmd.gsub(/\//, '')
        command_name = full_cmd.split(' ').first # the actual command name.
        params = full_cmd.split(' ') # the parameters passed to the command.
        params.shift

        begin
          @command_proc.send("#{command_name}", params)
        rescue NoMethodError
          puts "unknown command [#{command_name}]".red
        rescue TypeError
          puts "you have an issue in your code for [#{command_name}]".red
        end
      else
        # any other command is a direction.
        dirs = cmd.split(' ')
        dirs.each do |direction|
          @player.move(direction)
        end
      end
    end

private
    def show_map
      puts @player.location[:map].render_map(@player)
    end
  end
end

if __FILE__ == $0
  if $2
    game = BanditMayhem::Game.new $2
  else
    game = BanditMayhem::Game.new 'Nigel'
  end

  while true
    break if game.quit
    game.main # loop
  end

  puts 'thanks for playing bandit mayhem!'.green
end
