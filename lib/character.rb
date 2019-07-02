require 'item'
require 'map'
require 'market'
require 'utils'

require 'colorize'
require 'symbolized'

require 'items/traversing_ring'

module BanditMayhem
  class Character
    attr_accessor :weapon,
                  :location,
                  :items

    attr_reader :actor_values

    def initialize(add_stats)
      @location = {
          map: nil,
          last: nil,
          x: -1,
          y: -1
      }


      stats = {
        name: 'Character',
        health: 100,
        max_health: 100,
        str: 10,
        def: 0,
        level: 1,
      }.merge(add_stats)

      @items = []
      @actor_values = {}.to_symbolized_hash

      stats.map { |k, v| set_av(k, v) }
    end

    # gets an actor value
    def get_av(stat, default=nil)
      return @actor_values[stat] if @actor_values[stat]
      set_av(stat, default)
    end

    # sets an actor value
    def set_av(stat, value)
      @actor_values["base_#{stat}"] = value unless @actor_values["base_#{stat}"]
      @actor_values[stat] = value
    end

    def merge_avs(new_stats)
      @actor_values&.merge!(new_stats) if new_stats
    end

    # equip a Weapon object.
    def equip!(weapon)
      @weapon = weapon if weapon.is_a? Weapon
    end

    def loot(target)
      if target.is_a? BanditMayhem::Character

        everything_looted = {}.to_symbolized_hash

        if target.dead?
          gold = target.get_av('level') * 15 + (get_av('attacks', 0) * 3)

          everything_looted[:gold] = gold
          puts 'You got $' + "#{gold}!".yellow
        else
          puts 'cannot loot something thats not dead'.red
        end

        merge_avs(everything_looted)
        target.actor_values.delete_if { |k, v| everything_looted.key?(k) }

        everything_looted
      else
        case target['type']
          when 'coinpurse'
            set_av('gold',
              get_av('gold') + target['value']
            )
          when 'weapon'
            weapon = Object.const_get('BanditMayhem').const_get('Weapons').const_get(target['item']).new
            @items << weapon
          else
            itm = Object.const_get('BanditMayhem').const_get('Items').const_get(target['item']).new
            items << itm
        end
      end
    end

    def dead?
      get_av('health').to_i <= 0
    end

    # used for map detection. If the self collides with a market, for example.
    def interact_with(item)
      if is_a? BanditMayhem::Characters::Player
        if item[:map] # passing in the location object
          # interacting with a point on the map
          item = @location[:map].get_entity_at item
        end
        return if item.nil?
        case item['type']
          when 'market'
            market = BanditMayhem::Market.new item, self
            while market.shopping
              market.shop
            end

          when 'coinpurse'
            puts 'you found a ' + 'coinpurse'.upcase.blue + ' with ' + item['value'].to_s.yellow + ' inside!'
            loot(item)

          when 'door', 'cave'
            area = item['destination']['location']
            @location[:map] = BanditMayhem::Map.new(area)
            @location[:x] = item['destination']['x']
            @location[:y] = item['destination']['y']

          when 'item', 'weapon'
            puts 'you found a ' + item['item'].to_s.upcase.blue + '!'
            loot(item)

          when 'bandit'
            enemy_to_fight = nil
            if !item['name']
              require './lib/characters/bandit'
              enemy_to_fight = BanditMayhem::Characters::Bandit.new
            else
              # do later (this is for greater foes)
            end
            battle(enemy_to_fight)
        end
      end
      case item['type']
        when 'wall', 'tree'
          if has_item? BanditMayhem::Items::TraversingRing
            @location[:map].remove_entity(@location)
          else
            warp(@location[:last])
          end
      end

      if is_a? BanditMayhem::Characters::Player
        @location[:map].render_map(self)
      end
    end

    def warp(*args)
      if args[0].is_a? Array
        @location[:x], @location[:y] = args[0][0],args[0][1]
      else
        if args[0].is_a?(Integer) && args[1].is_a?(Integer)
          # warp to x and y
          @location[:x], @location[:y] = args[0].to_i, args[1].to_i
        end
      end
    end

    # move the self
    def move(direction)
      Game.cls
      @location[:last] = [@location[:x], @location[:y]]
      case direction
        when 'up', 'w'
          if @location[:y] == 1
            if @location[:map].north
              @location[:map] = BanditMayhem::Map.new(@location[:map].north)
              @location[:y] = @location[:map].height - 2
            else
              puts "can't go north!".red
            end
          else
            @location[:y] = @location[:y].to_i - 1
          end
        when 'down', 's'
          if @location[:y] == @location[:map].height - 2
            if @location[:map].south
              @location[:map] = BanditMayhem::Map.new(@location[:map].south)
              @location[:y] = 1
            else
              puts "can't go south!".red
            end
          else
            @location[:y] = @location[:y].to_i + 1
          end
        when 'left', 'a'
          if @location[:x] == 1
            if @location[:map].west
              @location[:map] = BanditMayhem::Map.new(@location[:map].west)
              @location[:x] = @location[:map].width - 2
            else
              puts "can't go west!".red
            end
          else
            @location[:x] = @location[:x].to_i - 1
          end
        when 'right', 'd'
          if @location[:x] == @location[:map].width - 2
            if @location[:map].east
              @location[:map] = BanditMayhem::Map.new(@location[:map].east)
              @location[:x] = @location[:map].width - 2
            else
              puts "can't go east!".red
            end
          else
            @location[:x] = @location[:x].to_i + 1
          end
      end
      interact_with @location
    end

    # ==== MAIN BATTLE FUNC === #
    def battle(enemy)
      if BanditMayhem::Settings.new.get('music', true)
        Game.media_player.play_song(File.expand_path('./lib/media/battle.mp3'))
      end

      set_av('attacks', 0)
      enemy.set_av('attacks', 0)

      @in_battle = true

      # self will always go first.
      players_turn = true

      Game.cls

      puts "\t\t\t\tBATTLING: #{enemy.get_av('name')}".green
      puts "\t\t" + enemy.get_av('avatar', '(no avatar)').to_s + "\n\n"

      while @in_battle
        puts 'Your health: ' + get_av('health').to_s.red
        puts enemy.get_av('name') + '\'s health: ' + enemy.get_av('health').to_s.red
        puts '------------------------'

        if players_turn
          puts 'Your turn...'.green
          fight_menu(enemy)

          loot(enemy) if enemy.dead?
          players_turn = false
          @location[:map].remove_entity(@location)
        else
          # for now, all the enemy will do, is attack.
          puts "#{enemy.get_av('name')}'s turn...".red

          attack(enemy)
          players_turn = true
        end
      end

      if BanditMayhem::Settings.new.get('music', true)
        Game.media_player.stop
      end
    end

    # return hash
    def attack(target)
      sleep(1)
      total_dmg = (calculate_attack_damage)
      target_health_after = target.get_av('health') - total_dmg

      battle_aftermath = {
        damage_dealt: total_dmg,
        target_health_before: target.get_av('health'),
        target_health_after: target_health_after
      }.to_symbolized_hash

      target.set_av('health',
        target.get_av('health') - total_dmg
      )

      puts "\n" + get_av('name').to_s.red + ' attacked ' + target.get_av('name').to_s.blue + ' for ' + total_dmg.to_s.green + " dmg.\n-----------------"

      set_av('attacks',
        get_av('attacks', 0).to_i + 1
      )

      if target.dead?
        puts src.get_av('name').to_s.red + ' has slain ' + target.get_av('name').to_s.blue
        battle_aftermath[:target_died] = true
        @in_battle = false
      end

      battle_aftermath
    end

    def fight_menu(enemy)
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
        attack(enemy)
      elsif cmd.eql? 2
        if BanditMayhem::Utils.shuffle_percent(get_av('luck'))
          # run away
          @in_battle = false
          puts 'You ran away'.green
          sleep(1)
          Game.cls
        else
          puts 'The bandit grabs you by your gear and pulls you back into the fight.'.red
          sleep(1)
          Game.cls
        end
      elsif cmd.eql? 3
        # show the inventory, then let them choose.
        show_inventory
        puts 'Enter an item to use:'
        STDOUT.flush
        item = gets.chomp
        use_item(item.to_i)
      end
    end

    private
    def calculate_attack_damage
      # dmg = str + weapon.str + (level*5) + (luck / 3)
      weapon_str = 0 || weapon.properties[:str].to_i
      (get_av('str').to_i + weapon_str + (get_av('level').to_i * 5) + (get_av('luck', 0).to_i / 3))
    end

    def calculate_defense(target)
      # def = player def + level + (luck / 5)
      (target.get_av('def').to_i + target.get_av('level').to_i + (target.get_av('luck', 0).to_i / 5))
    end
  end
end
