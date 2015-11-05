rfr = require 'rfr'
Tool = rfr 'app/js/tool'

module.exports =
class Item extends Tool
  properties:
    name:        'string'
    description: 'string'
    buy_value:   'int'
    sell_value:  'int'
