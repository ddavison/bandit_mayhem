fs = require 'fs'

class Log
  log_file: 'editor.log'
  INFO: 0
  ERR:  1
  WARN: 2

  set$: ($) ->
    @$ = $
    @info(' >> Log Initialized << ')

  info: (message) ->
    @write(Log.INFO, message)

  warn: (message) ->
    @write(Log.WARN, message)

  err: (message) ->
    @write(Log.ERR, message)

  read: ->
    @$('#console-log').text()

  write: (level, o) ->
    date = new Date()
    prefix = "(#{date.getHours()}:#{date.getMinutes()}) "
    switch level
      when Log.INFO
        prefix += "[INFO] :"
      when Log.ERR
        prefix += "[ERRO] :"
      when Log.WARN
        prefix += "[WARN] :"
    line = "\n#{prefix} #{o}"
    @$('#console-log').text(@read() + line)

    # log to file
    fs.appendFile(@log_file, line)

    if(@$('#console-log').length) # scroll down to the bottom all the time
      @$('#console-log').scrollTop(@$('#console-log')[0].scrollHeight - @$('#console-log').height());


module.exports = new Log()
