app = require('app')
BrowserWindow = require('browser-window')

require('crash-reporter').start()

mainWindow = null

app.on('ready', ->
  mainWindow = new BrowserWindow({width: 1024, height: 768})

  mainWindow.loadUrl("file://#{__dirname}/index.html")

  mainWindow.webContents.openDevTools()

  mainWindow.on('closed', ->
    mainWindow = null
  )
)

app.on('window-all-closed', ->
  app.quit() if process.platform != 'darwin'
)
