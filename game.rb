require 'colorize'
require './lib/characters/player'
require './lib/commands'
require './lib/settings'
require './lib/media_player'
require 'yaml'

module BanditMayhem
  class Game
    class Commands < BanditMayhem::Commands
      def initialize(game_obj)
        @game = game_obj
        @descriptions = {
          '/quit' => 'Quit out of the game',
          '/history' => 'Show the history of commands youve used',
          # '/get_av (av)' => 'Get an attribute value',
          # '/set_av (av)' => 'Set an attribute value',
          '/use (item_id_or_name)' => 'Use an item',
          '/inv' => 'Shows your inventory',
          '/help' => 'Shows this menu',
          '/stats' => 'List the stats of your character'
        }

        @descriptions << {
          '/test_fight [bandit]' => 'Fight an enemy. Defaults to a Bandit',
          '/test_market' => 'Visit the market to buy supplies.'
        } if @game.devmode
      end

      # === COMMANDS ===
      # quit out of the game
      def quit(args)
        @game.quit = true
      end

      # quit out of the game
      def exit(args)
        quit(args)
      end

      # show the history of commands.
      def history(args)
        puts @game.cmds
      end

      # get an attribute value
      def get_av(args)
        args.each do |av|
          puts @game.player.get_av(av).to_s.blue
        end
      end

      # set an attribute value
      def set_av(args)
        begin
          @game.player.set_av(args[0].to_s, args[1].to_i) if Float(args[1])
        rescue
          @game.player.set_av(args[0].to_s, args[1])
        end
      end

      # use an item.
      def use(args)
        @game.player.use_item(args.first.to_i)
      end

      # show the player's current inventory.
      def inv(args)
        @game.player.inventory.slots.each do |item|
          puts @game.player.inventory.slots.index(item).to_s + '. ' + item.get_property('name').green + ' : ' + item.get_property('description').green
        end
      end

      # list the player's statistics.
      def stats(args)
        puts @game.player.to_yaml
      end
    end

    attr_accessor :player, :quit, :cmds, :devmode, :media_player

    @devmode = true

    # game initialization
    def initialize(name)
      @cmds = []
      media_player = BanditMayhem::MediaPlayer.new
      Game.media_player = media_player
      @settings = BanditMayhem::Settings.new
      @player = BanditMayhem::Characters::Player.new({name: name})
      @command_proc = Commands.new(self)

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

    def self.media_player=(media_player)
      @media_player = media_player
    end

    def self.media_player
      @media_player
    end

    def draw
    end

    def update
      # show health
      if @settings.get('music', true)
        unless Game.media_player.playing?
          unless Game.media_player.playing_level? @player.location[:map].map_info['name']
            # start playing the map track unless it's already playing
            Game.media_player.play_level_song(@player.location[:map].map_info['name'])
          end
        end
      end

      @player.location[:map].render_map(@player)
      puts '-----' + @player.get_av('name').blue + '-----'
      puts @player.get_av('health').to_s.red + 'hp'
      puts '$' + @player.get_av('gold').to_s.yellow
      puts 'Weapon: ' + @player.weapon.get_property('name').to_s.green
      puts ''
      puts "Enter a command (type #{'/help'.magenta} for commands) (#{'w'.magenta},#{'a'.magenta},#{'s'.magenta},#{'d'.magenta} to move)"
      STDOUT.flush
      cmd = gets.chomp

      if cmd[0] == '/'
        @command_proc.execute(cmd)
      else
        # move the character
        dirs = cmd.split ' '
        dirs.each do |direction|
          @player.move(direction)
        end
      end
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
