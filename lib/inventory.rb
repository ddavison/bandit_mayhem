module BanditMayhem
  class Inventory
    def initialize
      @slots = []
    end

    def add_item(item)
      @slots << item if item.is_a? Item
    end

    def all_items
      @slots
    end

    def has_item?(item)
      @slots.include? item
    end

    def remove_item(item)
      @slots.delete(item) if @slots.include? item
    end
  end
end
