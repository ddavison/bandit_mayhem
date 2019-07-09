require 'yaml'
require 'colorize'
require 'symbolized'

module BanditMayhem
  module Maps
    WALL_VERT          = '│'
    WALL_HORIZ         = '─'
    CORNER_UPPER_RIGHT = '┐'
    CORNER_UPPER_LEFT  = '┌'
    CORNER_LOWER_LEFT  = '└'
    CORNER_LOWER_RIGHT = '┘'

    INTERIOR_WALL_VERT          = '║'
    INTERIOR_WALL_HORIZ         = '═'
    INTERIOR_CORNER_UPPER_RIGHT = '╗'
    INTERIOR_CORNER_UPPER_LEFT  = '╔'
    INTERIOR_CORNER_LOWER_LEFT  = '╚'
    INTERIOR_CORNER_LOWER_RIGHT = '╝'

    DOOR               = '¤'.magenta
    CAVE               = 'O'.magenta
    SURFACE_DEFAULT    = ' '
    SURFACE_STONE      = '.'.light_black
    SURFACE_GRASS      = ','.green
    SHOP               = '$'.yellow
    PLAYER             = '@'.cyan
    COINPURSE          = '¢'.yellow
    ITEM               = '?'.yellow
    BANDIT             = '■'.red
    QUEST              = '!'.blue
    TREE               = '∆'.light_green
    NPC                = '∙'.cyan
    OTHER              = '?'
  end

  class Map

    def to_s
      @attributes[:name]
    end

    attr_reader :attributes,
                :poi

    attr_accessor :matrix

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

      @matrix = [[]]

      @poi = @attributes['poi'] || []
    end

    def build!(player)
      raise 'cannot generate an empty map' unless (@attributes[:width] && @attributes[:height])

      # the @render string
      map_surface = get_surface

      @boundary_height.times do |y|
        @matrix[y] = []
        @boundary_width.times do |x|
          non_surface = false
          case x
          when 0
            if y == 0
              @matrix[y][x] = Maps::CORNER_UPPER_LEFT

              next
            elsif y == @boundary_height - 1
              @matrix[y][x] = Maps::CORNER_LOWER_LEFT

              next
            else
              @matrix[y][x] = Maps::WALL_VERT

              next
            end
          when @boundary_width - 1
            if y == 0
              @matrix[y][x] = Maps::CORNER_UPPER_RIGHT
              next
            elsif y == @boundary_height - 1
              @matrix[y][x] = Maps::CORNER_LOWER_RIGHT
              next
            else
              @matrix[y][x] = Maps::WALL_VERT
              next
            end
          else
            if y == 0 || y == @boundary_height - 1
              @matrix[y][x] = Maps::WALL_HORIZ
              next
            end

            if x == player.location[:x] && y == player.location[:y]
              @matrix[y][x] = Maps::PLAYER
              next
            end

            @matrix[y][x] = map_surface

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
                    @matrix[y][x] = Maps::SHOP
                  when 'coinpurse'
                    @matrix[y][x] = Maps::COINPURSE
                  when 'item', 'weapon'
                    @matrix[y][x] = Maps::ITEM
                  when 'bandit'
                    @matrix[y][x] = Maps::BANDIT
                  when 'tree'
                    @matrix[y][x] = Maps::TREE
                  when 'cave'
                    @matrix[y][x] = Maps::CAVE
                  when 'door'
                    @matrix[y][x] = Maps::DOOR
                  when 'wall'
                    case poi['direction']
                    when 'vertical', 'vert'
                      @matrix[y][x] = Maps::WALL_VERT
                    when 'horizontal', 'horiz'
                      @matrix[y][x] = Maps::WALL_HORIZ
                    end
                  when 'npc'
                    @matrix[y][x] = Maps::NPC
                    next
                  else
                    @matrix[y][x] = Maps::OTHER
                  end
                  next
                end
              end
            end
          end
        end

      end

      draw_interiors!
    end

    def built?
      @matrix&.first&.any?
    end

    def render(player)
      map = String.new

      @matrix.each do |line|
        map += line.join('')
        map += "\n"
      end

      map
    end

    # draw the @render
    # @param player because we need the players position in relation to the map
    def draw_map(player)
      puts 'You are currently in ' + @attributes[:name].to_s.green

      # build the map
      build!(player)

      # render the map
      puts render(player)
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

      if @poi&.any?
        @poi.each do |poi|
          return poi if poi['x'] == location[:x] && poi['y'] == location[:y]
        end
      end
      nil
    end

    def get_char_at(location)
      raise 'need x and y coordinates' unless location[:x]&.is_a? Numeric and location[:y]&.is_a? Numeric
      raise 'map needs built first' unless built?

      @matrix[location[:y]][location[:x]]
    end

    private

    def draw_interiors!
      if built?
        if attributes[:interiors]&.any?
          attributes[:interiors].each do |interior|
            interior_width = interior[:width] + 2
            interior_height = interior[:height] + 2

            interior_height.times do |y|
                _y = interior[:y] + y
              interior_width.times do |x|
                _x = interior[:x] + x

                if interior[:door]
                  next if x == (interior[:door][:x] - 1) && y == (interior[:door][:y] - 1)
                end

                case _x
                when interior[:x]
                  if _y == interior[:y]
                    @matrix[_y][_x] = Maps::INTERIOR_CORNER_UPPER_LEFT

                    next
                  elsif _y == (interior[:y] + interior_height - 1)
                    @matrix[_y][_x] = Maps::INTERIOR_CORNER_LOWER_LEFT

                    next
                  else
                    @matrix[_y][_x] = Maps::INTERIOR_WALL_VERT

                    next
                  end
                when (interior[:x] + interior_width - 1)
                  if _y == interior[:y]
                    @matrix[_y][_x] = Maps::INTERIOR_CORNER_UPPER_RIGHT

                    next
                  elsif _y == (interior[:y] + interior_height - 1)
                    @matrix[_y][_x] = Maps::INTERIOR_CORNER_LOWER_RIGHT

                    next
                  else
                    @matrix[_y][_x] = Maps::INTERIOR_WALL_VERT
                  end
                else
                  # if y == interior[:y] || y == interior[:height] - 1
                  if _y == interior[:y] || _y == (interior[:y] + interior_height - 1)
                    @matrix[_y][_x] = Maps::INTERIOR_WALL_HORIZ

                    next
                  end

                end
              end
            end
          end
        end
      end
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
