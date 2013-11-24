require './lib/characters/player'

module BanditMayhem
  class Game
    attr_accessor :player, :quit

    def initialize
      @cmds = []
      @player = BanditMayhem::Player.new({name: "Nigel"})

      # give the player 10 potions to start with.
      @player.give([
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new,
        BanditMayhem::Items::HealthPotion.new
      ])

      @quit = false
    end

    # This is the main game loop.
    def main
      update
      return quit = true if @player.get_av('health') <= 0
    end

    def update
      # system "clear" unless system "cls"
      puts "\n------ DISPLAY ------"
      # show health
      puts "__Health__"
      p @player.get_av('health')
      puts

      # show the inventory
      puts "__Inventory__"
      
      @player.inventory.slots.each do |item|
        puts @player.inventory.slots.index(item).to_s + ". " + item.get_property('name') + " : " + item.get_property('description')
      end
      
      puts "Enter a command (type /help for commands) : "
      STDOUT.flush
      cmd = gets.chomp
      execute(cmd)
    end

    # this subroutine will decide what to do with cmd
    def execute(cmd)
      @cmds << cmd

      if cmd.start_with?('/') # its a command.
        full_cmd = cmd.gsub(/\//, '')
        command_name = full_cmd.split(" ").first # the actual command name.
        params = full_cmd.split(" ") # the parameters passed to the command.
        params.shift

        if    command_name.eql? 'die' #quits the game
          @quit = true
        elsif command_name.eql? 'history' # outputs the history of commands.
          puts @cmds
        elsif command_name.eql? 'get_av'  # outputs an av
          params.each do |av|
            puts @player.get_av(av)
          end
        elsif command_name.eql? 'use' # use an item
          @player.use_item(params.first.to_i)
        end
      end
    end
  end
end

if __FILE__ == $0 
  game = BanditMayhem::Game.new

  while true
    break if game.quit
    game.main# loop
  end
  puts "thanks for playing bandit mayhem!"
end