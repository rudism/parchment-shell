# add a game to the list after the user finds what they're looking for
ifdbAddResult = (id) ->
  result = ifdbGames[id]
  $temp = $('#ifdbtemplate').clone().removeAttr('id').removeClass('template').addClass 'result'
  $temp.find('a.name').html(result.name).click ->
    games.push newGame result.name, result.url, result.type
    $('#ifdbprompt').dialog 'close'
    updateGameList()
    return false
  $temp.find('a.ifdb').attr 'href', "http://ifdb.tads.org/viewgame?id=#{id}"
  $temp.find('.author').html "by #{result.author}"
  $temp.appendTo $('#ifdbprompt .results')

# the ifdbGames and ifdbSearch arrays were build by shamelessly scraping the IFDB
# the scripts to generate those are not included with this project
# see ifdb-games.coffee and ifdb-search.coffee for timestamps when they were last built
searchIfdb = (query) ->
  $container = $('#ifdbprompt .results')
  $container.find('.result').remove()
  if query? and query.length >= 1
    query = query.toLowerCase()
    filtered = _.filter ifdbSearch, (g) -> g.searchName.indexOf(query) >= 0
    ifdbAddResult r.id for r in _.first (_.sortBy filtered, (g) => g.searchName.indexOf query), 5
