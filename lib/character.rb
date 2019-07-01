require 'inventory'
require 'item'
require 'map'
require 'market'
require 'helpers'

require 'colorize'
require 'symbolized'

require 'items/traversing_ring'

module BanditMayhem
  class Character
    attr_accessor :inventory,
                  :weapon,
                  :location

    attr_reader :actor_values

    def initialize(stats)
      @location = {
          map: nil,
          last: nil,
          x: -1,
          y: -1
      }

      stats.merge!({
        name: 'Character',
        health: 100,
        max_health: 100,
        str: 10,
        def: 0,
        level: 1,
      })

      @inventory = BanditMayhem::Inventory.new
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

    def give(item)
      if item.respond_to? :each
        item.each do |i|
          @inventory.add_item(i)
        end
      else
        @inventory.add_item(item)
      end
    end

    def use_item(arg)
      if has_item?(arg)
        if arg.is_a? Integer # use the id of the item.
          @inventory.slots[arg.to_i].use(self)
          destroy_item!(arg)
        elsif arg.is_a? String # use the moniker / name of the item.
          @inventory.slots.each do |item|
            if item.name.eql? arg or item.moniker.eql? arg
              @inventory.slots[item].use(self)
              destroy_item!(item)
            end
          end
        end
      else
        puts "you do not have an item currently with the id/name [#{arg}]".red
      end
    end

    def destroy_item!(arg)
      @inventory.remove_item(arg) if has_item?(arg)
    end

    def has_item?(arg)
      if arg.is_a? Class
        if @inventory.slots.respond_to? :each
          @inventory.slots.each do |slot|
            return true if slot.is_a? arg
          end
        else
          false
        end
      elsif arg.is_a? Integer
        return true if @inventory.slots[arg.to_i]
      elsif arg.is_a? String
        @inventory.slots.each do |item|
          return true if item.moniker.eql? arg
          return true if item.name.eql? arg
        end
      end
      false
    end

    def merge_avs(new_stats)
      @actor_values&.merge!(new_stats) if new_stats
    end

    # equip a Weapon object.
    def equip!(weapon)
      if weapon.is_weapon?
        @weapon = weapon
      else
        puts 'you tried to equip something that is not a weapon.'.red
      end
    end

    def loot(target)
      Dir['./lib/items/*'].each { |file| require file }
      Dir['./lib/weapons/*'].each { |file| require file }

      if target.is_a? BanditMayhem::Character
        if target.dead?
          # gold = target_health * ((attacked+target_attacks) / defense)
          gold = target.get_av('base_health') * get_av('attacks')

          set_av('gold',
            get_av('gold') + gold
          )

          puts 'You got $' + "#{gold}!".yellow
        else
          puts 'cannot loot something thats not dead'.red
        end
      else
        case target['type']
          when 'coinpurse'
            set_av('gold',
              get_av('gold') + target['value']
            )
          when 'weapon'
            weapon = Object.const_get('BanditMayhem').const_get('Weapons').const_get(target['item']).new
            give weapon
          else
            itm = Object.const_get('BanditMayhem').const_get('Items').const_get(target['item']).new
            give itm
        end
      end
    end

    def show_inventory
      inventory.slots.each do |item|
        puts inventory.slots.index(item).to_s + '. ' + item.get_property('name').green + ' : ' + item.get_property('description').green
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

          attack(enemy, self)
          players_turn = true
        end
      end

      if BanditMayhem::Settings.new.get('music', true)
        Game.media_player.stop
      end
    end

    def attack(src, dst)
      sleep(1)
      total_dmg = (BanditMayhem::Helpers.calculate_attack_damage(src) - BanditMayhem::Helpers.calculate_defense(dst))

      dst.set_av('health',
        dst.get_av('health') - total_dmg
      )

      puts "\n" + src.get_av('name').to_s.red + ' attacked ' + dst.get_av('name').to_s.blue + ' for ' + total_dmg.to_s.green + " dmg.\n-----------------"

      src.set_av('attacks',
        src.get_av('attacks', 0).to_i + 1
      )

      if dst.dead?
        puts src.get_av('name').to_s.red + ' has slain ' + dst.get_av('name').to_s.blue
        @in_battle = false
      end
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
        attack(self, enemy)
      elsif cmd.eql? 2
        if BanditMayhem::Helpers.shuffle_percent(get_av('luck'))
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
  end
end
