require 'character'
require 'weapons/stick'

module BanditMayhem
  module Characters
    class Player < Character
      def initialize(add_stats={})
        stats = {
          name:   'Nigel',
        }.merge(add_stats)

        super(stats)

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
        }.to_symbolized_hash
      end
    end
  end
end
