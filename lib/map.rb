require 'yaml'
require 'colorize'
require 'symbolized'

module BanditMayhem
  module Maps
    WALL_VERT          = '│'
    WALL_HORIZ         = '─'
    DOOR               = '¤'.magenta
    CAVE               = 'O'.magenta
    CORNER_UPPER_RIGHT = '┐'
    CORNER_UPPER_LEFT  = '┌'
    CORNER_LOWER_LEFT  = '└'
    CORNER_LOWER_RIGHT = '┘'
    SURFACE_DEFAULT    = ' '
    SURFACE_STONE      = '.'.light_black
    SURFACE_GRASS      = ','.green
    SHOP               = '$'.yellow
    PLAYER             = '@'.cyan
    COINPURSE          = '¢'.yellow
    ITEM               = '!'.blue
    BANDIT             = '■'.red
    OTHER              = '?'
    TREE               = '∆'.light_green
  end

  class Map

    def to_s
      @attributes[:name]
    end

    attr_reader :attributes,
                :poi,
                :render

    def initialize(args)
      @attributes = {}.to_symbolized_hash

      begin
        if args.is_a? String
          default_map_to_load = File.expand_path(File.join('lib', 'maps', "#{args}.yml"))
          @attributes.merge!(YAML.load_file(default_map_to_load)) if File.exists?(default_map_to_load)
          @attributes.merge!(YAML.load_file(File.expand_path("#{args}.yml"))) if File.exists?(File.expand_path("#{args}.yml"))
        elsif args.is_a? Hash
          if args[:file]
            @attributes.merge!(YAML.load_file(File.expand_path(args[:file])))
          else
            @attributes.merge!(args)
          end
        end
      rescue => e
        puts e
        raise "Cant load map #{args.inspect}"
      end

      @boundary_width = @attributes[:width].to_i + 2
      @boundary_height = @attributes[:height].to_i + 2

      # @area = @attributes[:width] * @attributes[:height]
      # @perimeter = 2 * @area

      @locations = []

      @poi = @attributes['poi']
    end

    def build!(player)
      # the @render string
      @render = String.new
      map_surface = get_surface

      @boundary_height.times do |y|  # columns
        @boundary_width.times do |x| # rows
          non_surface = false
          case x
            when 0
              if y == 0
                @render += Maps::CORNER_UPPER_LEFT
                next
              elsif y == @boundary_height - 1
                @render += Maps::CORNER_LOWER_LEFT
                next
              else
                @render += Maps::WALL_VERT
                next
              end
            when @boundary_width - 1
              if y == 0
                @render += Maps::CORNER_UPPER_RIGHT
                next
              elsif y == @boundary_height - 1
                @render += Maps::CORNER_LOWER_RIGHT
                next
              else
                @render += Maps::WALL_VERT
                next
              end
            else
              if y == 0 || y == @boundary_height - 1
                @render += Maps::WALL_HORIZ
                next
              end

              if x == player.location[:x] && y == player.location[:y]
                @render += Maps::PLAYER
                non_surface = true
                next
              end

              if @poi&.any?
                @poi.each do |poi|
                  @locations << [poi['x'], poi['y']] unless @locations.include? [poi['x'], poi['y']]
                  if player.location[:x] == poi['x'] && player.location[:y] == poi['y']
                    if poi['type'] == 'item' || poi['type'] == 'weapon' || poi['type'] == 'coinpurse'
                      @poi.delete(poi)
                    end
                    if poi['consumable']
                      if poi['consumable'].is_a? Hash
                        # there is a condition.
                        @poi.delete(poi) if player.get_av(poi['consumable']['unless'], false)
                      else
                        @poi.delete(poi) if @poi.include? poi
                      end
                    end

                    return player.interact_with poi
                  end
                  if x == poi['x'] && y == poi['y']
                    case poi['type']
                      when 'shop'
                        @render += Maps::SHOP
                        non_surface = true
                      when 'coinpurse'
                        @render += Maps::COINPURSE
                        non_surface = true
                      when 'item', 'weapon'
                        @render += Maps::ITEM
                        non_surface = true
                      when 'bandit'
                        @render += Maps::BANDIT
                        non_surface = true
                      when 'tree'
                        @render += Maps::TREE
                        non_surface = true
                      when 'cave'
                        @render += Maps::CAVE
                        non_surface = true
                      when 'door'
                        @render += Maps::DOOR
                        non_surface = true
                      when 'wall'
                        non_surface = true
                        case poi['direction']
                          when 'vertical', 'vert'
                            @render += Maps::WALL_VERT
                          when 'horizontal', 'horiz'
                            @render += Maps::WALL_HORIZ
                        end
                      else
                        @render += Maps::OTHER
                        non_surface = true
                    end
                    next
                  end
                end
              end
              @render += map_surface unless non_surface
          end
          non_surface = false
        end
        @render += "\n"
      end

      @render
    end
    # draw the @render
    # @param player because we need the players position in relation to the map
    def draw_map(player)
      puts 'You are currently in ' + @attributes[:name].to_s.green
      puts build!(player)
    end

    # exit a location
    def exit_location(player)
      # first we should favor the @render's `exits` attribute.  otherwise, calculate the nearest free space
      current_location = [player.location[:x], player.location[:y]]

      @poi.each do |poi|
        if [poi['x'], poi['y']] == current_location
          if poi['exits']
            player.location[:x] = poi['exits']['x'] || player.location[:x]
            player.location[:y] = poi['exits']['y'] || player.location[:y]
          else
            player.location[:y] += 1
          end
        end
      end
    end

    def get_entity_at(location)
      raise 'need x and y coordinates' unless location[:x]&.is_a? Numeric and location[:y]&.is_a? Numeric

      ret = nil
      if @poi&.any?
        @poi.each do |poi|
          ret = poi if poi['x'] == location[:x] && poi['y'] == location[:y]
        end
      end
      ret
    end

    def get_char_at(location)
      raise 'need x and y coordinates' unless location[:x]&.is_a? Numeric and location[:y]&.is_a? Numeric
      raise 'map needs built first' unless @render

      @render_lines ||= @render.split("\n")
      @render_lines[location[:y]][location[:x]]
    end

    def remove_entity(*args)
      if args[0].is_a? Hash
        @poi.each do |poi|
          if poi['x'] == args[0][:x] && poi['y'] == args[0][:y]
            @poi.delete(poi)
          end
        end
      end
    end

    def get_surface
      case @attributes['type']
        when 'town'
          Maps::SURFACE_STONE
        when 'plains'
          Maps::SURFACE_GRASS
        else
          Maps::SURFACE_DEFAULT
      end
    end
  end
end
