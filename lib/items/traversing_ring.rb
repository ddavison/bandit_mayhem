require './lib/item'

module BanditMayhem
  module Items
    class TraversingRing < Item
      def initialize
        super({
          name: 'Traversing Ring',
          description: 'Allows you to traverse through walls.',
          sell_value: 20_000
        })
      end

      def use(player)
        puts 'this is a passive item that allows you to walk through walls.'
      end
    end
  end
end
