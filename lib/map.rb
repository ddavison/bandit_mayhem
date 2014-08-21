require 'yaml'

module BanditMayhem
  module Maps
    WALL_VERT          = '│'
    WALL_HORIZ         = '─'
    DOOR               = '¤'
    CORNER_UPPER_RIGHT = '┐'
    CORNER_UPPER_LEFT  = '┌'
    CORNER_LOWER_LEFT  = '└'
    CORNER_LOWER_RIGHT = '┘'
    SURFACE_STONE      = '.'
    SURFACE_PLAIN      = '~'
    MARKET             = '$'
    PLAYER             = '@'
    COINPURSE          = '¢'
    ITEM               = '!'
    BANDIT             = '■'
    OTHER              = '?'
  end

  class Map
    attr_reader :map_info,
                :width,
                :height,
                :type,
                :north,
                :east,
                :south,
                :west

    def initialize(name)
      @map_info = YAML.load_file("./lib/maps/#{name}.yml")

      @width  = @map_info['width']
      @height = @map_info['height']

      @north = @map_info['north']
      @south = @map_info['south']
      @east  = @map_info['east']
      @west  = @map_info['west']

      @poi = @map_info['poi']
    end

    # returns a string of the map layout
    # @param player - because we need the players position.
    def render_map(player)
      # fix the character location if it's out of bounds
      player.location[:x] = @width - 2 if player.location[:x] > @width - 2
      player.location[:y] = @height- 2 if player.location[:y] > @height- 2

      puts 'You are currently in ' + @map_info['name'].to_s.green
      # the map string
      map = ''

      actual_height = @height - 1
      actual_width = @width - 1

      @height.times do |y|
        @width.times do |x|
          case x
            when 0
              if y == 0
                map += Maps::CORNER_UPPER_LEFT
                next
              elsif y == actual_height
                map += Maps::CORNER_LOWER_LEFT
                next
              else
                map += Maps::WALL_VERT
                next
              end
            when actual_width
              if y == 0
                map += Maps::CORNER_UPPER_RIGHT
                next
              elsif y == actual_height
                map += Maps::CORNER_LOWER_RIGHT
                next
              else
                map += Maps::WALL_VERT
                next
              end
            else
              if y == 0 || y == actual_height
                map += Maps::WALL_HORIZ
                next
              end

              @poi.each do |poi|
                if player.location[:x] == poi['x'] && player.location[:y] == poi['y']
                  if poi['consumable']
                    p poi['consumable']
                    if poi['consumable'].is_a? Hash
                      # there is a condition.
                      @poi.delete(poi) if player.get_av(poi['consumable']['unless'], false)
                    else
                      @poi.delete(poi)
                    end
                  end
                  return player.interact_with poi
                end
                if x == poi['x'] && y == poi['y']
                  case poi['type']
                    when 'market'
                      map += Maps::MARKET

                    when 'coinpurse'
                      map += Maps::COINPURSE
                    when 'item', 'weapon'
                      map += Maps::ITEM
                    when 'bandit'
                      map += Maps::BANDIT
                    else
                      map += Maps::OTHER
                  end
                  next
                end
              end

              if x == player.location[:x] && y == player.location[:y]
                map += Maps::PLAYER
                next
              end

              map += get_surface
          end
        end
        map += "\n"
      end

      map
    end

    def get_surface
      case @map_info['type']
        when 'town'
          Maps::SURFACE_STONE
        when 'plains'
          Maps::SURFACE_PLAIN
      end
    end
  end
end
