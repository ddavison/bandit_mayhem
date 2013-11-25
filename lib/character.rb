require './lib/inventory'
require './lib/item'
require 'colorize'

module BanditMayhem
  class Character
    attr_accessor :inventory
    attr_accessor :weapon

    def initialize(stats)
      @inventory = BanditMayhem::Inventory.new

      @stats = {}

      stats.each do |k,v|
        set_av("base_#{k}", v)
        set_av(k, v)
      end
    end

    # gets an attribute value
    def get_av(stat)
      puts "could not get unknown av ['#{stat}']".red if @stats[stat.to_sym].nil?
      @stats[stat.to_sym]
    end

    # sets an attribute value
    def set_av(stat, value)
      @stats[stat.to_sym] = value
    end

    def give(item)
      if item.respond_to?("each") 
        item.each do |i|
          @inventory.add_item(i)
        end
      else
        @inventory.add_item(item)
      end
    end

    def remove_all_items
      @inventory.slots.clear
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
      if has_item?(arg)
        if arg.is_a? Integer
          @inventory.slots.delete(arg.to_i) # TODO: figure out why it's not deleting an item correctly.
        elsif arg.is_a? String
          puts "destroy_item!(#{arg}): not implemented.".red
        end        
      end
    end

    def has_item?(arg)
      if arg.is_a? Integer
        return true if @inventory.slots[arg.to_i]
      elsif arg.is_a? String
        @inventory.slots.each do |item|
          return true if item.moniker.eql? arg
          return true if item.name.eql? arg
        end
      end
      return false
    end

    def merge_stats(new_stats)
      @stats.merge!(new_stats)
    end

    # equip a Weapon object.
    def equip!(weapon)
      if weapon.is_weapon?
        @weapon = weapon

        # modify the stats.
        new_str = @weapon.get_property('str').to_i + get_av('str')
        set_av('str', new_str.to_i)
      else
        puts "you tried to equip something that is not a weapon.".red
      end
    end

    def loot(target)
      if target.is_dead?
        # gold = target_health * ((attacked+target_attacks) / defense)
        gold = target.get_av('base_health') * get_av('attacks')

        set_av('gold',
          get_av('gold') + gold
        )
        
        puts "You got #{gold} Gold!".yellow
      else
        puts "cannot loot something thats not dead".red
      end
    end

    def show_inventory
      inventory.slots.each do |item|
        puts inventory.slots.index(item).to_s + ". " + item.get_property('name').green + " : " + item.get_property('description').green
      end
    end

    def is_dead?
      get_av('health').to_i <= 0
    end
  end
end