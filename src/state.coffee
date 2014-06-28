getQueryParam = (name) ->
  qstring = localStorage.getItem 'last-query'
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp "[\\?&]#{name}=([^&#]*)"
  results = regex.exec qstring
  return if results == null then "" else decodeURIComponent results[1].replace(/\+/g, ' ')

clearQueryString = ->
  localStorage.setItem 'last-query', location.search
  if location.search != ''
    cleanUri = location.protocol + "//" + location.host + location.pathname
    window.history.replaceState {}, document.title, cleanUri

saveState = ->
  # save the id of the currently active game
  activeGame = _.filter games, (game) ->
    game.meta.frame.is ':visible'
  if activeGame.length > 0
    localStorage.setItem 'active-game', activeGame[0].id
  else
    localStorage.setItem 'active-game', ''

  # save the size and state of the gamelist
  sbVisible = $('#gamelist').is ':visible'
  localStorage.setItem 'sidebar-visible', sbVisible
  localStorage.setItem 'sidebar-width', $('.splitbar').css 'left'

checkIfGameLoaded = (ifdb) ->
  loaded = _.first _.filter games, (g) -> g.game.ifdb == ifdb
  if loaded? and loaded != null
    loaded.meta.new = true
    return loaded
  return null

addGameFromIfdb = (ifdb) ->
  g = ifdbGames[ifdb]
  if g? and g != null
    game = newGame g.name, g.url, g.type, ifdb, true
    games.push game
    return game
  else
    return null

loadState = ->

  # restore the width of the sidebar first
  sbWidth = localStorage.getItem 'sidebar-width'
  if sbWidth?
    $('.splitbar').css 'left', sbWidth
    gameListResized parseInt sbWidth

  # check for supported query params
  bypassSaved = false
  ifdb = (getQueryParam 'ifdb').split ' '
  if ifdb? and ifdb.length == 1 and ifdb[0] != ''
    # if just one id is passed, hide the sidebar and load that game
    # load first existing instance if it's already in their game list
    game = checkIfGameLoaded ifdb[0]
    if game != null
      toggleGameList true
      loadGame game
      bypassSaved = true
    else
      game = addGameFromIfdb ifdb[0]
      if game != null
        if getQueryParam('list') != '1'
          toggleGameList true
        loadGame game
        bypassSaved = true
      else
        showAlert 'Error', 'The game specified by the link you followed could not be found.', 'D\'oh!'

  else if ifdb? and ifdb.length > 1
    # if multiple ids are passed, show the sidebar and add all games
    # don't load any games yet
    someGamesFailed = false
    someGamesPassed = false
    for gid in ifdb
      game = checkIfGameLoaded gid
      if game == null
        game = addGameFromIfdb gid
        if game == null
          someGamesFailed = true
        else
          someGamesPassed = true
      else
        someGamesPassed = true
    if someGamesFailed
      showAlert 'Error', "#{if someGamesPassed then "Some" else "All"} of the games specified by the link you followed could not be found.", 'D\'oh!'
    if someGamesPassed
      bypassSaved = true

  if !bypassSaved
    # restore the visibility of the sidebar
    sbVisible = localStorage.getItem 'sidebar-visible'
    if sbVisible? and sbVisible == 'false'
      # pass true to avoid saving state before the last active game is loaded
      toggleGameList true

    # restore the last active game
    activeGameId = localStorage.getItem 'active-game'
    if activeGameId? and activeGameId != ''
      activeGame = _.filter games, (game) ->
        game.id == activeGameId
      if activeGame.length > 0
        loadGame activeGame[0]

toggleGameList = (dontsave) ->
  $gl = $('#gamelist')
  $pf = $('#playfield')
  if $gl.is ':visible'
    $pf.data('old-left', $pf.css 'left').css 'left', 10
    $gl.hide()
    $('#expand').show()
  else
    $pf.css 'left', $pf.data 'old-left'
    $('#expand').hide()
    $gl.show()
  if !dontsave? or !dontsave
    saveState()

gameListResized = (newPos) ->
  $('#gamelist').css 'width', newPos
  $('#playfield').css 'left', (newPos + 6)
