require 'yaml'

desc 'Validate existing maps in maps/ dir'
task :validate_maps do
  Dir['lib/maps/**.yml'].each do |map|
    begin
      map_yaml = YAML.load_file(map)
    rescue
      throw StandardError, "Error loading map #{map}. Bad YAML"
    end
  end
end
