games = []

generateUuid = ->
  d = new Date().getTime()
  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor (d / 16)
    v = if c == 'x' then r else (r & 0x7 | 0x8)
    v.toString 16

newGame = (name, url, type) ->
  if type == 'auto'
    ext = url.toLowerCase().substring url.lastIndexOf('.') + 1, url.length
    gtype = if ext == 't3' then 'tads' else 'parchment'
  else
    gtype = type

  $elem = $('#gtemplate').clone().removeAttr('id').addClass('game-item')
  $elem.find('.name').html name
  $elem.find('a.game').click ->
    return false
  $elem.find('a.remove').click ->
    return false

  $frame = $('<iframe/>').attr('frameborder', '0')

  newgame =
    id: generateUuid()
    meta:
      element: $elem
      frame: $frame
    game:
      name: name
      url: url
      type: gtype

  $elem.data 'game', newgame
  $frame.data 'game', newgame
  $frame.appendTo $('#playfield')

  return newgame

updateGameList = ->
  localStorage.setItem 'games', JSON.stringify _.map games, 'game'
  $('.game-item').remove()
  $('#gamelist ul').append game.meta.element for game in _.sortBy games, 'game.name'

onConfirm = (prompt, callback) ->
  $('#confirm').empty().html(prompt).dialog
    modal: true
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

showAddGameDialog = ->
  $('#gameprompt').dialog
    modal: true
    title: 'Add Game'
    width: 550
    buttons: [
      text: 'OK'
      click: ->
        name = $("#gameprompt input[name='game-name']").val()
        url = $("#gameprompt input[name='game-url']").val()
        type = $("#gameprompt select[name='game-type'] option:selected").val()
        games.push newGame name, url, type
        $('#gameprompt').dialog 'close'
        updateGameList()
    ,
      text: 'Cancel'
      click: -> $('#gameprompt').dialog 'close'
    ]

$(document).ready ->
  gamesJson = localStorage.getItem 'games'
  if gamesJson?
    gameData = JSON.parse gamesJson
    if !gameData? or !(gameData instanceof Array)
      games = []
    else
      games.push newGame game.name, game.url, game.type for game in gameData

  $('.button').each ->
    switch $(this).attr 'data-action'
      when 'add'
        $(this).click ->
          showAddGameDialog()
          return false
      when 'clear'
        $(this).click ->
          onConfirm 'Delete all games?', ->
            games = []
            updateGameList()
          return false

  updateGameList()
