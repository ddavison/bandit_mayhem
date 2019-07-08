require 'character'

module BanditMayhem
  module Characters
    class Npc < Character
      def initialize(add_stats={})
        stats = {
          name: 'Townsperson',
          health: 100,
          gold: 10
        }.merge(add_stats)

        super(stats)
      end
    end
  end
end
