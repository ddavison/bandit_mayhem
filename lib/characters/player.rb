require 'character'
require 'items/health_potion'
require 'items/luck_potion'
require 'weapons/stick'

module BanditMayhem
  module Characters
    class Player < Character
      def initialize(add_stats)
        stats = {
          name:   'Nigel',
          luck:   25,
          level:  1
        }

        stats.merge!(add_stats) if add_stats
        super(stats)

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
