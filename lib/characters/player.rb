require './lib/character'
require './lib/items/health_potion'
require './lib/weapons/stick'

module BanditMayhem
  module Characters
    class Player < Character
      def initialize(add_stats)
        stats = {
          name: 'Player',
          health: 200,
          str: 10,
          def: 5,
          gold: 0
        }

        super(stats)

        merge_stats(add_stats)
        equip!(BanditMayhem::Weapons::Stick.new)
      end
    end
  end
end