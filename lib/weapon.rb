require './lib/item'

module BanditMayhem
  module Items
    class Weapon < Item
      def initialize(props)
        # base stats
        props = {
          sell_value: 40,
          buy_value: 80,
          weapon: true
        }

        super(props)
      end
    end
  end
end