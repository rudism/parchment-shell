# generic dialog for confirmation... because confirm() is ugly
onConfirm = (prompt, callback) ->
  $('#confirm').empty().html(prompt).dialog
    modal: true
    draggable: false
    resizable: false
    title: 'Confirm'
    width: 400
    buttons: [
      text: 'Yes'
      click: ->
        $('#confirm').dialog 'close'
        callback()
    ,
      text: 'No'
      click: ->
        $('#confirm').dialog 'close'
    ]

# generic dialog for alerts
showAlert = (title, message, button) ->
  $('#confirm').empty().html(message).dialog
    modal: true
    draggable: false
    resizable: false
    title: title
    width: 400
    buttons: [
      text: button
      click: ->
        $('#confirm').dialog 'close'
    ]

# shows the about dialog
showAboutDialog = ->
  $('#aboutprompt').dialog
    modal: true
    resizable: false
    draggable: false
    title: 'ifShell r2014-06-28'
    width: 400
    buttons: [
      text: 'OK'
      click: ->
        $('#aboutprompt').dialog 'close'
    ]

# shows the dialog for searching the IFDB index
showFindGameDialog = ->
  $("#ifdbprompt input[name='game-search']").val ''
  searchIfdb ''
  $('#ifdbprompt').dialog
    modal: true
    resizable: false
    draggable: false
    title: 'Search IFDB'
    width: 550
    buttons: [
      text: 'Manual Add...'
      click: ->
        $('#ifdbprompt').dialog 'close'
        showAddGameDialog()
    ,
      text: 'Cancel'
      click: ->
        $('#ifdbprompt').dialog 'close'
    ]

# shows the dialog for manual Parchment game entry
showAddGameDialog = ->
  $("#gameprompt input[type='text']").val ''
  $('#gameprompt').dialog
    modal: true
    draggable: false
    resizable: false
    title: 'Add Game'
    width: 550
    buttons: [
      text: 'OK'
      click: ->
        name = $("#gameprompt input[name='game-name']").val()
        url = $("#gameprompt input[name='game-url']").val()
        games.push newGame name, url, 'parchment'
        $('#gameprompt').dialog 'close'
        updateGameList()
    ,
      text: 'Cancel'
      click: -> $('#gameprompt').dialog 'close'
    ]
