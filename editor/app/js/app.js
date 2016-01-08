(function() {
  var fs, log, rfr, vars,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  rfr = require('rfr');

  log = rfr('app/js/log');

  vars = rfr('app/js/gamevars');

  $(document).ready(function() {

    /*
      Main Editor class
     */
    var Editor;
    Editor = (function() {
      Editor.prototype.tool_belt = $('#tool-belt');

      Editor.prototype.tool_list = $('#tool-list');

      function Editor() {
        this.loadItems = bind(this.loadItems, this);
        this.populateToolBelt = bind(this.populateToolBelt, this);
        log.set$($);
        this.populateToolBelt();
        this.tool_belt.on('change', (function(_this) {
          return function() {
            return _this.loadItems(_this.tool_belt.val());
          };
        })(this));
      }


      /*
        Populate with all the directories in vars.GAME_ROOT
       */

      Editor.prototype.populateToolBelt = function() {
        var dir, dirs, i, len;
        log.info("populating tool belt...");
        dirs = fs.readdirSync(vars.GAME_ROOT);
        for (i = 0, len = dirs.length; i < len; i++) {
          dir = dirs[i];
          if (fs.statSync(vars.GAME_ROOT + "/" + dir).isDirectory()) {
            this.tool_belt.append($('<option></option>').attr('value', dir).text(dir.toUpperCase()));
            log.info("  > found: " + dir);
          }
        }
        return log.info('done.');
      };


      /*
        Load all types of items in
       */

      Editor.prototype.loadItems = function(entity_type) {
        var file, files, i, len, path, results;
        log.info("loading " + entity_type);
        this.tool_list.html('');
        path = vars.GAME_ROOT + "/" + entity_type;
        files = fs.readdirSync(path);
        switch (entity_type) {
          case 'maps':
            this.tool_list.append($("<a></a>").attr('class', 'list-group-item').text("New " + (entity_type.substr(0, entity_type.length - 1))).attr('href', "javascript:editor.newMap('" + entity_type + "')"));
            break;
          default:
            this.tool_list.append($("<a></a>").attr('class', 'list-group-item').text("New " + (entity_type.substr(0, entity_type.length - 1))).attr('href', "javascript:editor.newItem('" + entity_type + "')"));
        }
        results = [];
        for (i = 0, len = files.length; i < len; i++) {
          file = files[i];
          if (file.match(/.+\.(yaml|yml)/)) {
            switch (entity_type) {
              case 'maps':
                results.push(this.tool_list.append($("<a></a>").attr('class', 'list-group-item').text(file).attr('href', "javascript:editor.loadMap('" + file + "')")));
                break;
              default:
                results.push(this.tool_list.append($("<a></a>").attr('class', 'list-group-item').text(file).attr('href', "javascript:editor.loadItem('" + (this.tool_belt.val()) + "', '" + file + "')")));
            }
          } else {
            results.push(void 0);
          }
        }
        return results;
      };


      /*
        Load a particular item
       */

      Editor.prototype.loadItem = function(type, filename) {
        var Tool, html, property, property_type, ref, t, value;
        log.info("loading " + type + "/" + filename);
        Tool = rfr("app/js/entities/" + (type.substr(0, type.length - 1)));
        t = new Tool(type + "/" + filename);
        html = '';
        ref = t.properties;
        for (property in ref) {
          property_type = ref[property];
          value = t.content[property];
          switch (property_type) {
            case 'string':
              html += "<label>" + property + ":</label><input type='text' class='form-control game_value' value='" + value + "' /><br />";
              break;
            case 'int':
              html += "<label>" + property + ":</label><input type='number' class='form-control game_value' value='" + value + "' /><br />";
          }
        }
        return this.setContent(html);
      };


      /*
        Load a map in
       */

      Editor.prototype.loadMap = function(mapname) {
        var Map, content, height, html, i, j, map_file, ref, ref1, width, x, y;
        map_file = "maps/" + mapname;
        log.info("loading map " + map_file);
        Map = rfr("app/js/entities/map");
        Map = new Map(map_file);
        content = Map.getContent();
        html = '<div style="font-family: Consolas; font-size: 40px;">';
        height = Map.content.height - 1;
        width = Map.content.width - 1;
        for (y = i = 0, ref = height; 0 <= ref ? i <= ref : i >= ref; y = 0 <= ref ? ++i : --i) {
          for (x = j = 0, ref1 = width; 0 <= ref1 ? j <= ref1 : j >= ref1; x = 0 <= ref1 ? ++j : --j) {
            console.log(y);
            console.log(y[x]);
            console.log(y[x].properties);
            html += "<span class='map-marker' title='" + y[x]['properties'] + "'>" + content[y][x] + "</span>";
          }
          html += "<br />";
        }
        html += "</div>";
        return this.setContent(html);
      };

      Editor.prototype.setContent = function(content) {
        return $('#content-area').html(content);
      };

      return Editor;

    })();
    return window.editor = new Editor();
  });

}).call(this);
