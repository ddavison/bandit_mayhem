require './lib/character'
require './lib/items/health_potion'
require './lib/items/luck_potion'
require './lib/weapons/stick'

module BanditMayhem
  module Characters
    class Player < Character
      def initialize(add_stats)
        stats = {
          name:   'Player',
          health: 200,
          str:    10,
          def:    5,
          gold:   0,
          luck:   25,
          level:  1
        }

        super(stats)

        merge_stats(add_stats)
        equip!(BanditMayhem::Weapons::Stick.new)
        # give([
        #   BanditMayhem::Items::HealthPotion.new,
        #   BanditMayhem::Items::HealthPotion.new,
        #   BanditMayhem::Items::HealthPotion.new,
        #   BanditMayhem::Items::LuckPotion.new
        # ])

        @location = {
            map: BanditMayhem::Map.new('lynwood'),
            x: 3,
            y: 3
        }
      end
    end
  end
end
