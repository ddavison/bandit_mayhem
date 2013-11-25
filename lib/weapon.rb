require './lib/item'

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
  end
end