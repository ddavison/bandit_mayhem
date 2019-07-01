require 'item'

module BanditMayhem
  class Weapon < Item
    def initialize(add_props)
      # base stats
      props = { sell_value: 40,
        buy_value: 80,
        weapon: true
      }.merge(add_props)

      super(props)
    end

    # return an object based on the moniker
    def self.by_name(name)
      Object.const_get('BanditMayhem').const_get('Weapons').const_get(name).new
    end
  end
end
