module BanditMayhem
  class Battle
    def initialize(player, victim)
      @player = player
      @victim = victim
      @in_battle = true
    end

    def fight!
      if BanditMayhem::Settings.new.get('music', true)
        Game.media_player.play_song(File.expand_path('./lib/media/battle.mp3'))
      end

      @player.set_av('attacks', 0)
      @victim.set_av('attacks', 0)

      # player will always go first. (for now)
      players_turn = true

      Utils.cls

      puts "\t\t\t\tBATTLING: #{@victim.get_av('name')}".green
      puts "\t\t" + @victim.get_av('avatar', '(no avatar)').to_s + "\n\n"

      while @in_battle
        puts 'Your health: ' + get_av('health').to_s.red
        puts @victim.get_av('name') + '\'s health: ' + @victim.get_av('health').to_s.red
        puts '------------------------'

        if players_turn
          puts 'Your turn...'.green
          fight_menu

          @player.loot(@victim) if @victim.dead?
          players_turn = false
          @location[:map].remove_entity(@location)
        else
          # for now, all the enemy will do, is attack.
          puts "#{@victim.get_av('name')}'s turn...".red

          @victim.attack(@player)
          players_turn = true
        end
      end

      # if BanditMayhem::Settings.new.get('music', true)
      #   Game.media_player.stop
      # end
    end

    def fight_menu
      puts 'Fight options...'
      puts '----------------'
      puts '1. ' + 'Attack'.red
      puts '2. ' + 'Run'.green
      puts '3. ' + 'Use item'.blue
      puts 'Enter an option:'

      STDOUT.flush
      cmd = gets.chomp
      cmd = cmd.to_i

      if cmd.eql? 1
        # attack
        @player.attack(@victim)

        if @victim.dead?
          puts @player.get_av('name').to_s.red + ' has slain ' + @victim.get_av('name').to_s.blue
          @in_battle = false
        end

      elsif cmd.eql? 2
        if BanditMayhem::Utils.shuffle_percent(get_av('luck'))
          # run away
          @in_battle = false
          puts 'You ran away'.green
          # sleep(1)
          Utils.cls
        else
          puts 'The bandit grabs you by your gear and pulls you back into the fight.'.red
          # sleep(1)
          Utils.cls
        end
      elsif cmd.eql? 3
        # TODO: implement
        puts 'not yet implemented'.red
      end
    end
  end
end
