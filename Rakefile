$: << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require 'yaml'

namespace :maps do

  desc 'Validate existing maps in maps/ dir'
  task :validate do
    errors = []
    Dir['lib/maps/**.yml'].each do |map|
      begin
        map_yaml = YAML.load_file(map)
        map_name = File.basename(map)

        errors << "#{map_name} must have a 'name'" unless map_yaml['name']
        errors << "#{map_name} must have a 'width'" unless map_yaml['width']
        errors << "#{map_name} must have a 'height'" unless map_yaml['height']
      rescue
        throw StandardError, "Error loading map #{map}. Bad YAML?"
      end
    end
    STDERR.puts(errors.join("\n")) if errors.any?
  end

  desc 'Generate a map'
  task :generate, [:x, :y] do |t, args|
    require 'map'
    require 'character'

    char = BanditMayhem::Character.new
    puts BanditMayhem::Map.new(width: args[:x], height: args[:y]).build!(char)
  end

end
