module BanditMayhem
  module Items
    class Item
      def initialize(props)
        @properties = props
      end

      def get_property(prop)
        @properties[prop.to_sym]
      end

      # each item needs to implement "def use". there is no abstract in ruby.
    end
  end
end