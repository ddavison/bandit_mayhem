require 'item'
require 'consumable'

module BanditMayhem
  module Items
    class HealthPotion < Consumable
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

      def use(actor)
        actor.set_av('health',
          actor.get_av('health') + 25
        )
      end
    end
  end
end
