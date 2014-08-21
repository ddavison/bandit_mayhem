module BanditMayhem
  class Item
    def initialize(props)
      @properties = props
    end

    def get_property(prop)
      @properties[prop.to_sym]
    end

    # each item needs to implement "def use". there is no abstract in ruby.

    def is_weapon?
      return true if get_property('weapon')
      return false
    end

    # return an object based on the moniker
    def self.by_name(name)
      Object.const_get('BanditMayhem').const_get('Items').const_get(name).new
    end
  end
end
