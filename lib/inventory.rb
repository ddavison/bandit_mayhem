module BanditMayhem
  class Inventory
    attr_accessor :slots
    
    def initialize
      @slots = []
    end

    def add_item(item)
      @slots << item
    end

    def remove_item(item)
      @slots.delete(item) if @slots.include? item
    end
  end
end
