require 'symbolized'

module BanditMayhem
  class Item

    def initialize(props={})
      @properties = props.to_symbolized_hash
    end

    # each item needs to implement "def use". there is no abstract in ruby.
    def is_weapon?
      !!@properties[:weapon]
    end

    def use
      yield
    end

    # return an object based on the moniker
    def self.by_name(name)
      Object.const_get('BanditMayhem').const_get('Items').const_get(name).new
    end
  end
end
