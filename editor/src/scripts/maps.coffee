rfr = require 'rfr'
Tool = rfr 'js/tool'
module.exports =
class Maps extends Tool
  properties:
    name: 'string',
    width: 'int',
    height: 'int',
    type: ['town', 'plains', 'shop', 'cave']
    poi: [
      'type',
      'x',
      'y',
      'inventory': [
      ],
      'value',
      'destination': [
        'location',
        'x',
        'y'
      ]
    ]

  constructor: (file_path) ->
    super(file_path)



