require 'symbolized'

module BanditMayhem
  class Item
    attr_accessor :attributes

    def initialize(attributes={})
      @attributes = attributes.to_symbolized_hash
    end

    # each item needs to implement "def use_on!". there is no abstract in ruby.
    def use_on!(actor)
    end

    # return an object based on the moniker
    def self.by_name(name)
      Object.const_get('BanditMayhem').const_get('Items').const_get(name).new
    end
  end
end
