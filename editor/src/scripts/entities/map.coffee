rfr = require 'rfr'
Tool = rfr 'app/js/tool'

module.exports =
class Map extends Tool
  WALL_VERT          : '│'
  WALL_HORIZ         : '─'
  door               : '¤'
  cave               : 'O'
  CORNER_UPPER_RIGHT : '┐'
  CORNER_UPPER_LEFT  : '┌'
  CORNER_LOWER_LEFT  : '└'
  CORNER_LOWER_RIGHT : '┘'
  town               : '.'
  plains             : ','
  market             : '$'
  coinpurse          : '¢'
  item               : '!'
  bandit             : '■'
  other              : '?'
  tree               : '∆'

  properties:
    name: 'string'
    width: 'int'
    height: 'int'
    type: ['town', 'plains', 'shop', 'cave']
    poi: [
      type: ['market', 'coinpurse', 'tree', 'weapon', 'bandit']
      x: 'int'
      y: 'int'
      value: 'int'
      consumable: 'bool' # unless
      destination:
        location: 'string'
        x: 'int'
        y: 'int'
    ]

  ###
    Prints out the actual map content as it would appear in game (minus the character)
  ###
  getContent: ->
    width  = @content.width
    height = @content.height
    map = [[]]

    for y in [0..height]
      map[y] = []
      for x in [0..width]
        switch x
          when 0
            if y == 0
              map[y][x] = @CORNER_UPPER_LEFT
              continue
            else if y == height
              map[y][x] = @CORNER_LOWER_LEFT
              continue
            else
              map[y][x] = @WALL_VERT
              continue
          when width
            if y == 0
              map[y][x] = @CORNER_UPPER_RIGHT
              continue
            else if y == height
              map[y][x] = @CORNER_LOWER_RIGHT
              continue
            else
              map[y][x] = @WALL_VERT
              continue
          else
            if y == 0 || y == height
              map[y][x] = @WALL_HORIZ
              continue
            else
              map[y][x] = @[@content.type]

            if @content.poi.length > 0
              for poi in @content.poi
                if x == poi.x && y == poi.y
                  console.log(map[y][x])
                  console.log(@[poi.type])
                  map[y][x] = @[poi.type]
                  map[y][x]['properties'] = poi

    map
