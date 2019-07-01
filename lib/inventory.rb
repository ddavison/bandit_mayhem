module BanditMayhem
  class Inventory
    def initialize(items=[])
      @slots = items
    end

    def add_item(item)
      @slots << item
    end

    def has_item?(item)
      @slots.include? item
    end

    def remove_item(item)
      @slots.delete(item) if @slots.include? item
    end
  end
end
