games = []

# using GUIDs to identify games internally means we can add the same game twice
# might be useful for play testing multiple branches from a single save
generateUuid = ->
  d = new Date().getTime()
  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor (d / 16)
    v = if c == 'x' then r else (r & 0x7 | 0x8)
    v.toString 16

# generates the new internal rep of a game from the name, url, and type
# guesses type based on file extension if type is 'auto'
# this is useless for now since the TADS web terp can't load arbitrary .t3 files anyway
newGame = (name, url, type, ifdb, isNew, id) ->
  if !id?
    id = generateUuid()

  if type == 'auto'
    ext = url.toLowerCase().substring url.lastIndexOf('.') + 1, url.length
    gtype = if ext == 't3' then 'tads' else 'parchment'
  else
    gtype = type

  $elem = $('#gtemplate').clone().removeAttr('id').removeClass('template').addClass 'game-item'
  $elem.find('.name').html name

  if gtype == 'tads'
    $elem.find('.indicator').removeClass('indicator').removeClass('fa-circle-o').addClass('fa-external-link')

  $frame = $('<iframe/>').attr('frameborder', '0')

  newgame =
    id: id
    meta:
      element: $elem
      frame: $frame
      new: if isNew? then isNew else false
    game:
      id: id
      ifdb: ifdb
      name: name
      url: url
      type: gtype

  # we don't load the src yet because the frame needs to be visible first
  # otherwise Parchment doesn't lay things out correctly and generally breaks
  $frame.data('game', newgame).hide().appendTo $('#playfield')

  return newgame

# originally was doing this in newGame
# moved here because events were being lost after calls to updateGameList
wireGame = (game) ->
  game.meta.element.find('a.game').data('game', game).click ->
    mygame = $(this).data('game')
    loadGame mygame
    return false
  game.meta.element.find('a.remove').data('game', game).click ->
    mygame = $(this).data('game')
    onConfirm "Remove #{mygame.game.name}?", ->
      removeGame mygame
    return false

# brings the appropriate frame forward for parchment games
# TADS terp doesn't work in an iframe so we just pop those in a new window
loadGame = (game) ->
  game.meta.new = false
  game.meta.element.removeClass 'new'

  switch game.game.type
    when 'parchment'
      for g in games
        g.meta.frame.hide()
        g.meta.element.find('.indicator').removeClass('fa-dot-circle-o').addClass('fa-circle-o')
      game.meta.element.find('.indicator').removeClass('fa-circle-o').addClass('fa-dot-circle-o')
      game.meta.frame.show()
      if !game.meta.frame.attr('src')?
        frameUrl = if game.game.type == 'tads' then game.game.url else "parchment/index.html?story=#{encodeURIComponent game.game.url}"
        game.meta.frame.attr 'src', frameUrl
    when 'tads'
      onConfirm "#{game.game.name} can only be played in a new window. Open one now?", ->
        window.open game.game.url, '_blank'
  saveState()

removeGame = (game) ->
  game.meta.element.remove()
  game.meta.frame.remove()
  _.remove games, id: game.id
  updateGameList()

removeAllGames = ->
  removeGame game for game in _.clone games

loadGames = ->
  gamesJson = localStorage.getItem 'games-v2'
  if gamesJson?
    gameData = JSON.parse gamesJson
    if !gameData? or !(gameData instanceof Array)
      games = []
    else
      for game in gameData
        games.push newGame game.name, game.url, game.type, game.ifdb, false, game.id

# saves to localstorage here and updates the game list in the sidebar
updateGameList = ->
  if games.length == 0
    $('.no-games').show()
  else
    $('.no-games').hide()

  localStorage.setItem 'games-v2', JSON.stringify _.map games, 'game'
  $container = $('#gamelist ul')
  $('.game-item').remove()
  for game in (_.sortBy games, (g) -> g.game.name)
    if game.meta.new
      game.meta.element.addClass 'new'
    $container.append game.meta.element
    wireGame game
  saveState()
