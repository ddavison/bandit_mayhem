require './lib/item'

module BanditMayhem
  module Items
    class HealthPotion < Item
      def initialize
        props = {
          moniker: 'health_potion',
          name: 'Health Potion',
          description: 'Heals you for 25 HP',
          sell_value: 10,
          buy_value: 20
        }

        super(props)
      end

      def use(player)
        player.set_av('health',
          player.get_av('health') + 25
        )
      end
    end
  end
end