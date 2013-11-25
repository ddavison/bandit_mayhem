require './lib/weapon'

module BanditMayhem
  module Weapons
    class Stick < Weapon
      def initialize
        props = {
          str: 25,
          name: 'Stick',
          moniker: 'stick',
          description: 'A simple wooden stick used to beat heads in'
        }

        super(props)
      end
    end
  end
end