require './lib/character'
require './lib/weapons/stick'

module BanditMayhem
  module Characters
    class Bandit < Character
      def initialize
        stats = {
          name: 'Bandit',
          health: 100,
          str: 10,
          def: 0
        }

        super(stats)

        equip!(BanditMayhem::Weapons::Stick.new)
      end
    end
  end
end