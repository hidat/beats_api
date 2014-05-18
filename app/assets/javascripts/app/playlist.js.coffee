class PlaylistItem
  constructor: (@trackID) ->
    this

class ItemToPlay
  constructor: (@index, @playlistItem) ->
    this

class Playlist
  constructor: (options) ->
    items = []
    currentIndex = -1

  addItem: (@trackID) ->
    itemToPlay = new ItemToPlay(@trackID)
    @items.append(itemToPlay)

  getNextItem: () ->
    itemToPlay = null
    if @currentIndex < @items.length - 1
      @currentIndex++
      itemToPlay = new ItemToPlay(@currentIndex, @item[@currentIndex])
    itemToPlay


Window.Playlist = Playlist
