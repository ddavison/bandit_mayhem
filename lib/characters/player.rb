require './lib/character'
require './lib/items/health_potion'

module BanditMayhem
  class Player < Character
    def initialize(add_stats)
      stats = {
        name: 'Player',
        health: 200,
        str: 10,
      }

      super(stats)

      merge_stats(add_stats)
    end
  end
end