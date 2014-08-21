require 'colorize'
require 'yaml'

# Enemies
require './lib/characters/bandit'

# Weapons
require './lib/weapons/stick'
require './lib/weapons/sword'
require './lib/weapons/axe'

module BanditMayhem
  class Commands
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

    # list the help menu.
    def help(args)
      @descriptions.each do |cmd, description|
        puts "\t#{cmd}".yellow + ': ' + "#{description}".yellow
      end
    end

    # list the player's statistics.
    def stats(args)
      puts @game.player.to_yaml
    end

    # === TEST FUNCS === #
    def test_fight(args)
      enemy = nil
      case args.first
        when 'bandit'
          enemy = BanditMayhem::Characters::Bandit.new
      end
      @game.battle(enemy)
    end

    # test the equiping feature
    def test_equip(args)
      weapon = args.first
      case weapon
        when 'sword'
          @game.player.equip!(BanditMayhem::Weapons::Sword.new)
        when 'stick'
          @game.player.equip!(BanditMayhem::Weapons::Stick.new)
        when 'axe'
          @game.player.equip!(BanditMayhem::Weapons::Axe.new)
      end
    end
  end
end
