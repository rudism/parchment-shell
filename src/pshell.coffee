$(document).ready ->
  # read saved games list if it exists
  gamesJson = localStorage.getItem 'games'
  if gamesJson?
    gameData = JSON.parse gamesJson
    if !gameData? or !(gameData instanceof Array)
      games = []
    else
      games.push newGame game.name, game.url, game.type for game in gameData

  # set up the add/clear buttons
  $('.button').each ->
    switch $(this).attr 'data-action'
      when 'add'
        $(this).click ->
          showFindGameDialog()
          return false
      when 'clear'
        $(this).click ->
          onConfirm 'Remove all games?', ->
            removeAllGames()
          return false

  # set up the IFDB search field
  $("#ifdbprompt input[name='game-search']").on 'input', ->
    searchIfdb $(this).val()

  # build the game list
  updateGameList()
