fs = require 'fs'
yaml = require 'js-yaml'
rfr = require 'rfr'
vars = rfr 'app/js/gamevars'

module.exports =
class Tool
  properties: null
  content: null

  constructor: (file_path) ->
    @content = yaml.load(fs.readFileSync(vars.GAME_ROOT + '/' + file_path, 'utf-8'))

  getContent: ->
    @content
