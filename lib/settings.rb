require 'yaml'
require 'symbolized'

module BanditMayhem
  class Settings
    @settings = {}.to_symbolized_hash
    def initialize
      # load the initial settings.
      @settings = YAML.load_file('settings.yml')
    end

    # get a setting
    def get(str, default_value)
      return @settings[str] unless @settings[str].nil?

      set(str, default_value)
    end

    # set a setting
    def set(str, val)
      @settings[str] = val
      save_settings
      @settings[str]
    end

    private
    # save the settings to the settings.yml file
    def save_settings
      File.open('settings.yml', 'w') { |f| YAML.dump(@settings, f) }
    end
  end
end
