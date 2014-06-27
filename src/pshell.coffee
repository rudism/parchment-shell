games = []

$(document).ready ->
  $('.button').each ->
    switch $(this).attr 'data-action'
      when 'add'
        $(this).click -> showAddGameDialog()
      when 'clear'
        $(this).click ->

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
        $('#gameprompt').dialog 'close'
    ,
      text: 'Cancel'
      click: -> $('#gameprompt').dialog 'close'
    ]
