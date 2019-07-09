require 'yaml'

module BanditMayhem
  class Dialogue
    # Dialogue with another NPC.
    def initialize(player, npc)
      @player = player
      @npc = npc

      @is_talking = true

      @dialogue = YAML.load_file(File.join("dialogue", npc.get_av('name')))
    end

    def talk!

      Utils.cls

      puts @npc.get_av('name').green
      puts @npc.get_av('avatar')

      while @is_talking
        dialogue_menu
      end
    end

    def dialogue_menu
      puts '----------------'
      puts '1. ' + 'Ok'.green
      puts '0. ' + 'Leave'.red
      puts 'Enter an option:'

      STDOUT.flush
      cmd = gets.chomp
      cmd = cmd.to_i

      if cmd.eql? 0
        @is_talking = false
      end
    end
  end
end
