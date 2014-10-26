require './lib/item'
require './lib/weapon'

module BanditMayhem
  class Weapon < Item
    def initialize(props)
      # base stats
      new_props = {
        sell_value: 40,
        buy_value: 80,
        weapon: true
      }

      props.merge!(new_props)

      super(props)
    end

    # return an object based on the moniker
    def self.by_name(name)
      Object.const_get('BanditMayhem').const_get('Weapons').const_get(name).new
    end
  end
end
