require 'colorize'
require 'gosu'
require './lib/characters/player'
require './lib/commands'
require './lib/campaign'

module BanditMayhem
  module ZOrder
    Cursor, Background, Player, UI = *0..3
  end

  class Game < Gosu::Window
    attr_accessor :player, :quit, :cmds

    def initialize
      # show the window.
      super 1024, 768, false
      self.caption = 'Bandit Mayhem'
      @background_image = Gosu::Image.new(self, './lib/media/bg.bmp', true)
      @cursor = Gosu::Image.new(self, './lib/media/cursor.png')

      @cmds = []
      @campaign = BanditMayhem::Campaign.new
      @player = BanditMayhem::Characters::Player.new({name: 'Nigel'})
      @command_proc = BanditMayhem::Commands.new(self)

      # give the player some potions to start with.
      @player.give([
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new
      ])

      @quit = false

      #Game.cls
      #puts "\t\tWelcome to BANDIT MAYHEM, #{@player.get_av('name')}\n\n".yellow
      @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    end

    # This is the main game loop.
    def main
      return quit = true if @player.get_av('health') <= 0
      update
    end

    def self.cls
      system 'clear' unless system 'cls'
    end

    def draw
      @cursor.draw(self.mouse_x, self.mouse_y, ZOrder::Cursor)
      @background_image.draw(0, 0, ZOrder::Background)

      @font.draw("Health: #{@player.get_av('health')}", 500, 10, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Gold: #{@player.get_av('gold')}", 500, 30, ZOrder::UI, 1.0, 1.0, 0xffffff00)

      @font.draw('Inventory:', 500, 55, ZOrder::UI)
      y = 70
      @player.inventory.slots.each do |item|
        @font.draw("#{item.get_property('name')}", 510, y, ZOrder::UI)
        y += 20
      end
    end

    def update

      # puts "\n------ DISPLAY ------"
      # show health
      #puts "\n__Health__"
      #puts @player.get_av('health').to_s.red
      #puts "\n__Gold__"
      #puts @player.get_av('gold').to_s.yellow
      #
      #if @player.weapon.nil?
      #  puts "You are currently unarmed with [#{@player.get_av('str')}] str.".green
      #else
      #  puts "You currently have a [#{@player.weapon.get_property('name')}] equipped.".green
      #end

      
      #puts 'Enter a command (type /help for commands) : '
      #STDOUT.flush
      #cmd = gets.chomp
      #execute(cmd)
    end

    # this subroutine will decide what to do with cmd
    def execute(cmd)
      @cmds << cmd

      full_cmd = cmd.gsub(/\//, '')
      command_name = full_cmd.split(" ").first # the actual command name.
      params = full_cmd.split(" ") # the parameters passed to the command.
      params.shift

      begin
        @command_proc.send("#{command_name}", params)
      rescue TypeError
        puts "unknown command [#{command_name}]".red
      end
    end

    # ==== MAIN BATTLE FUN`C === #
    def battle(enemy)
      player.set_av('attacks', 0)
      enemy.set_av('attacks', 0)

      @in_battle = true
      player = @player

      # player will always go first.
      players_turn = true

      Game.cls
      
      puts "\t\t\t\tBATTLING: #{enemy.get_av('name')}\n\n".yellow
      
      while @in_battle
        puts "Your health: " + player.get_av('health').to_s.red
        puts "Their health: " + enemy.get_av('health').to_s.red
        puts "------------------------"

        if players_turn
          puts "Your turn...".green
          fight_menu(enemy)

          player.loot(enemy) if enemy.is_dead?

          players_turn = false
        else
          # for now, all the enemy will do, is attack.
          puts "#{enemy.get_av('name')}'s turn...".red

          attack(enemy, player)
          players_turn = true
        end       
      end
    end
private
    def attack(src, dst)
      sleep(1)
      total_dmg = (src.get_av('str') - dst.get_av('def'))

      dst.set_av('health',
        dst.get_av('health') - total_dmg
      )

      puts "\n" + src.get_av('name').to_s.red + " attacked " + dst.get_av('name').to_s.blue + " for " + total_dmg.to_s.green + " dmg.\n-----------------"

      src.set_av('attacks',
        src.get_av('attacks').to_i + 1
      )

      if dst.is_dead?
        puts src.get_av('name').to_s.red + " has slain " + dst.get_av('name').to_s.blue
        @in_battle = false
      end
    end

    def fight_menu(enemy)
      puts "Fight options..."
      puts "----------------"
      puts "1. " + "Attack".red
      puts "2. " + "Run".yellow
      puts "3. " + "Use item".blue
      puts "Enter an option:"

      STDOUT.flush
      cmd = gets.chomp
      cmd = cmd.to_i

      if cmd.eql? 1
        # attack
        attack(@player, enemy)
      elsif cmd.eql? 2
        # run away
        @in_battle = false
        puts "You ran away".green
      elsif cmd.eql? 3
        # show the inventory, then let them choose.
        @player.show_inventory
        puts "Enter an item to use:"
        STDOUT.flush
        item = gets.chomp
        @player.use_item(item.to_i)
      end
    end
  end
end

if __FILE__ == $0 
  game = BanditMayhem::Game.new
  game.show

  while true
    break if game.quit
    #game.main # loop
  end

  puts "thanks for playing bandit mayhem!".yellow
end