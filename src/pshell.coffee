$(document).ready ->
  # handle the query string if one was passed
  clearQueryString()

  # read saved games list if it exists
  loadGames()

  # set up the add/clear buttons
  $('.button').each ->
    switch $(this).attr 'data-action'

      # hook up the add button
      when 'add'
        $(this).click ->
          showFindGameDialog()
          return false

      # hook up the clear games button
      when 'clear'
        $(this).click ->
          onConfirm 'Remove all games?', ->
            removeAllGames()
          return false

      # hook up the about button
      when 'about'
        $(this).click ->
          showAboutDialog()
          return false

  # make the sidebar collapsable
  $('#collapse,#expand').click ->
    toggleGameList()
    return false

  # make the sidebar resizable
  $('.splitbar').draggable
    axis: 'x'
    containment: [200, 0, 500, 0]
    iframeFix: true
    drag: (event, ui) -> gameListResized ui.position.left
    stop: (event, ui) -> saveState()

  # set up the IFDB search field
  $("#ifdbprompt input[name='game-search']").on 'input', ->
    searchIfdb $(this).val()

  # load saved state and handle querystring
  loadState()

  # build the game list
  updateGameList()
