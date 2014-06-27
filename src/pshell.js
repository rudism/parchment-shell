$(document).ready(function(){
  $('.button').each(function(){
    switch($(this).attr('data-action')){
      case 'add':
        $(this).click(function(){
          $('#gameprompt').dialog({
            modal: true,
            title: 'Add Game',
            width: 550,
            buttons: [
              { text: 'OK', click: function(){
                var name = $("#gameprompt input[name='game-name']").val();
                var url = $("#gameprompt input[name='game-url']").val();
                addGame(name, url);
                $('#gameprompt input').each(function(){
                  $(this).val('');
                });
                $('#gameprompt').dialog('close');
              } },
              { text: 'Cancel', click: function(){
                $('#gameprompt input').each(function(){
                  $(this).val('');
                });
                $('#gameprompt').dialog('close');
              } }
            ]
          });
          return false;
        });
        break;
      case 'clear':
        $(this).click(function(){
          ifConfirm('Delete all games?', function(){
            saveGames(null);
          });
          return false;
        });
        break;
    }
  });
  updateList();
});
function addGame(name, url){
  if(!name || !url){
    alert('Both name and url are required.');
    return;
  }
  url = 'parchment/index.html?story=' + encodeURIComponent(url);
  var games = getGames();
  games.push({name: name, url: url});
  saveGames(games);
}
function getGames(){
  var gamesJson = localStorage.getItem('games');
  var games = [];
  if(gamesJson){
    games = JSON.parse(gamesJson);
    if(games == null){
      games = [];
    } else {
      games = _.sortBy(games, 'name');
    }
  }
  return games;
}
function saveGames(games){
  localStorage.setItem('games', JSON.stringify(games));
  updateList();
}
function removeGame(url){
  var games = getGames();
  _.remove(games, function(game) {return game.url === url;});
  saveGames(games);
  $('#playfield iframe').each(function(){
    if($(this).attr('data-url') === url){
      $(this).remove();
    }
  });
}
function loadGame(url){
  var loaded = false;
  $('#playfield iframe').each(function(){
    if($(this).attr('data-url') === url){
      $(this).show();
      loaded = true;
    } else {
      $(this).hide();
    }
  });
  if(!loaded){
    $('#playfield').append($('<iframe/>').attr('frameborder', '0').attr('data-url', url).attr('src', url));
  }
  setActiveIndicator();
}
function setActiveIndicator(){
  $('.game-item a .fa-dot-circle-o').removeClass('fa-dot-circle-o').addClass('fa-circle-o');
  var url = $('#playfield iframe:visible').attr('data-url');
  $(".game-item a[data-url='" + url + "'] .fa-circle-o").removeClass('fa-circle-o').addClass('fa-dot-circle-o');
}
function ifConfirm(text, onyes){
  $('#confirm').empty().html(text).dialog({
    modal: true,
    title: 'Confirm',
    width: 400,
    buttons: [
      { text: 'Yes', click: function(){ $('#confirm').dialog('close'); onyes(); } },
      { text: 'No', click: function(){ $('#confirm').dialog('close'); } }
    ]
  });
}
function updateList(){
  var games = getGames();
  var $list = $('#gamelist ul');
  $list.empty();
  $.each(games, function(index, game){
    var $link = $('<a class="game"/>').html('<i class="fa fa-circle-o"/> ' + game.name)
      .attr('data-url', game.url).attr('data-name', game.name).attr('href', '#').click(function(){
      loadGame($(this).attr('data-url'));
      return false;
    });
    var $tools = $('<a class="remove" href="#"><i class="fa fa-times-circle"/></a>')
      .attr('data-url', game.url).attr('data-name', game.name).click(function(){
      ifConfirm('Remove game "' + $(this).attr('data-name') + '"?', function(){
        removeGame(game.url);
      });
      return false;
    });
    var $item = $('<li class="game-item" />').append($tools).append($link);
    $list.append($item);
  });
  $('#playfield iframe').each(function(){
    if(!_.some(games, {url: $(this).attr('data-url')})){
      $(this).remove();
    }
  });
  setActiveIndicator();
}
