generateUuid = ->
  d = new Date().getTime()
  uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
    r = (d + Math.random() * 16) % 16 | 0
    d = Math.floor (d / 16)
    v = if c == x then r else (r & 0x7 | 0x8)
    v.toString 16

getGameForElement = ($elem) -> $elem.parents('li').attr 'data-gameid'
