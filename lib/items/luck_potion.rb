require './lib/item'

module BanditMayhem
  module Items
    class LuckPotion < Item
      def initialize
        props = {
            moniker: 'luck_potion',
            name: 'Luck Potion',
            description: 'Ups your luck',
            sell_value: 30,
            buy_value: 60
        }
        super(props)
      end

      def use(player)
        return if player.get_av('luck') == 100
        player.set_av('luck',
          player.get_av('luck') + 15
        )
      end
    end
  end
end
