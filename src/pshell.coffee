games = []

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
        games.push new IfGame name, url
        updateGameList()
        $('#gameprompt').dialog 'close'
    ,
      text: 'Cancel'
      click: -> $('#gameprompt').dialog 'close'
    ]

updateGameList = ->
  localStorage.setItem 'games', JSON.stringify games
  createGameElements ifgame for ifgame in games

createGameElements = (ifgame) ->
  if $("#gamelist ul li[data-gameid='" + ifgame.id + "']").length == 0
    $temp = $('#gtemplate').clone().attr('data-gameid', ifgame.id)
    $temp.find('.name').html ifgame.name
    $temp.find('a.game').click ->
      return false
    $temp.find('a.remove').click ->
      return false
    $temp.appendTo $('#gamelist ul')
    $frame = $('<iframe/>').attr('frameborder', '0').attr('data-gameid', ifgame.id)
    $frame.appendTo $('#playfield')

$(document).ready ->
  gamesJson = localStorage.getItem 'games'
  if gamesJson?
    games = JSON.parse gamesJson
    if !games? or !(games instanceof Array)
      games = []

  $('.button').each ->
    switch $(this).attr 'data-action'
      when 'add'
        $(this).click -> showAddGameDialog()
      when 'clear'
        $(this).click -> onConfirm 'Delete all games?', ->
          games = []
          updateGameList()

  updateGameList()
