require './lib/inventory'

module BanditMayhem
  class Character
    attr_accessor :inventory
    attr_accessor :weapon

    def initialize(stats)
      @inventory = BanditMayhem::Inventory.new
      @stats = stats

      stats.each do |stats|
        
      end
    end

    # gets an attribute value
    def get_av(stat)
      puts "could not get unknown av ['#{stat}']" if @stats[stat.to_sym].nil?
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
        puts "You do not have an item currently with the id/name [#{arg}]"
      end
    end

    def destroy_item!(arg)
      if has_item?(arg)
        if arg.is_a? Integer
          @inventory.slots.delete(arg.to_i) # TODO: figure out why it's not deleting an item correctly.
        elsif arg.is_a? String
          puts "destroy_item!(#{arg}): not implemented."
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

    def equip!(weapon)
      
    end
  end
end