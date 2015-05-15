fs = require 'fs'
rfr = require 'rfr'
log = rfr 'app/js/log'
vars = rfr 'app/js/gamevars'

$(document).ready ->
  ###
    Main Editor class
  ###
  class Editor
    tool_belt: $('#tool-belt')  # the element where we'll put the tool belt
    tool_list: $('#tool-list')  # the element where we'll put the tool list

    constructor: ->
      log.set$($)
      @populateToolBelt()

      # Bindings
      @tool_belt.on('change', =>
        @loadItems(@tool_belt.val()))

    ###
      Populate with all the directories in vars.GAME_ROOT
    ###
    populateToolBelt: =>
      log.info "populating tool belt..."
      dirs = fs.readdirSync vars.GAME_ROOT
      for dir in dirs
        if fs.statSync("#{vars.GAME_ROOT}/#{dir}").isDirectory()
          @tool_belt.append(
            $('<option></option>')
              .attr('value', dir)
              .text(dir.toUpperCase())
          )
          log.info "  > found: #{dir}"
      log.info 'done.'


    ###
      Load all types of items in
    ###
    loadItems: (entity_type) =>
      log.info "loading #{entity_type}"
      @tool_list.html('')

      # `entity_type` will be the directory name
      path = "#{vars.GAME_ROOT}/#{entity_type}"
      files = fs.readdirSync path

      switch entity_type
        when 'maps'
          @tool_list.append(
            $("<a></a>")
            .attr('class', 'list-group-item')
            .text("New #{entity_type.substr(0, (entity_type.length - 1))}")
            .attr('href', "javascript:editor.newMap('#{entity_type}')")
          )
        else
          @tool_list.append(
            $("<a></a>")
              .attr('class', 'list-group-item')
              .text("New #{entity_type.substr(0, (entity_type.length - 1))}")
              .attr('href', "javascript:editor.newItem('#{entity_type}')")
          )

      for file in files
        if file.match /.+\.(yaml|yml)/
          switch entity_type
            when 'maps'
              @tool_list.append(
                $("<a></a>")
                .attr('class', 'list-group-item')
                .text(file)
                .attr('href', "javascript:editor.loadMap('#{file}')")
              )
            else
              @tool_list.append(
                $("<a></a>")
                  .attr('class', 'list-group-item')
                  .text(file)
                  .attr('href', "javascript:editor.loadItem('#{@tool_belt.val()}', '#{file}')")
              )

    ###
      Load a particular item
    ###
    loadItem: (type, filename) ->
      log.info "loading #{type}/#{filename}"

      Tool = rfr "app/js/entities/#{type.substr(0, (type.length - 1))}"
      t = new Tool("#{type}/#{filename}")

      html = ''
      for property,property_type of t.properties
        value = t.content[property]
        switch property_type
          when 'string'
            html += "<label>#{property}:</label><input type='text' class='form-control game_value' value='#{value}' /><br />"
          when 'int'
            html += "<label>#{property}:</label><input type='number' class='form-control game_value' value='#{value}' /><br />"

      @setContent(html)

    ###
      Load a map in
    ###
    loadMap: (mapname) ->
      map_file = "maps/#{mapname}"
      log.info "loading map #{map_file}"
      Map = rfr "app/js/entities/map"
      Map = new Map(map_file)

      content = Map.getContent()

      html = '<div style="font-family: Consolas; font-size: 40px;">'

      height = Map.content.height - 1
      width = Map.content.width - 1
      
      for y in [0..height]
        for x in [0..width]
          html += "<span class='map-marker' title='#{[y][x]['properties']}'>#{content[y][x]}</span>"
        html += "<br />"
      html += "</div>"
      @setContent(html)

    setContent: (content) ->
      $('#content-area').html(content)


  window.editor = new Editor()
