BrowserWindow = require('electron')
Editor = require('./js/editor')

require('crash-reporter').start()

mainWindow = null

app.on('ready', ->
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768,
    webPreferences: {
      nodeIntegration: true
    }
  })

  mainWindow.loadFile("index.html")

  mainWindow.webContents.openDevTools()

  mainWindow.on('closed', ->
    mainWindow = null
  )
)

app.on('window-all-closed', ->
  app.quit() if process.platform != 'darwin'
)
