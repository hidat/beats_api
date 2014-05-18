##
# Wraps a simple API/Event Handler around the Beats BAM Player
##
class BeatsPlayer
  constructor: (@eventHandler, options) ->
    @apiURL = "https://partner.api.beatsmusic.com/v1/api/"
    @clientID = options.clientID
    @userID = options.userID
    @accessToken = options.accessToken
    @bamReady = false
    @showConsole = options.showConsole
    @bam = new BeatsAudioManager()
    @loaded = false
    @playing = false
    @paused=false

    @bam.on("ready", ()=>
      @bamReady = true
      if @showConsole
        bam_engine.style.width = "500px";
        bam_engine.style.height = "300px";

      # set credentials
      @bam.clientId = @clientID;
      @bam.authentication =
        access_token: @accessToken,
        user_id: @userID

      @eventHandler.onReady(@bam)
      true
    )

    @bam.on("durationchange", (duration)=>
      @eventHandler.onDuration(@bam, duration)
      true
    );
    @bam.on("loadedmetadata", (metadata)=>
      @eventHandler.onMetadataLoaded(@, metadata)
      true
    );
    @bam.on("canplay", ()=>
      @loaded = true
      @playing = true
      @paused = false
      @eventHandler.onStreamStarted(@bam)
      true
    );
    @bam.on("playing", ()=>
      @playing = true
      @paused = false
      @eventHandler.onStreamPlaying(@bam)
      true
    );
    @bam.on("pause", ()=>
      @paused = true
      @eventHandler.onStreamPaused(@bam)
      true
    );
    @bam.on("stopped", ()=>
      @eventHandler.onStreamStopped(@bam)
      true
    );
    @bam.on("stalled", ()=>
      @eventHandler.onStreamStalled(@bam)
      true
    );
    @bam.on("ended", ()=>
      @playing = false
      @loaded = false
      @eventHandler.onStreamEnded(@bam)
      true
    );
    @bam.on("timeupdate", ()=>
      @eventHandler.onTimeUpdate(@bam)
      true
    );
    @bam.on("volumechange", ()=>
      @eventHandler.onVolumeChange(@bam)
      true
    );
    @bam.on("error", (error)=>
      @eventHandler.onError(@bam, error)
      true
    );

  loadTrack: (trackID) ->
    @bam.identifier = trackID;
    @bam.load();

  togglePlayback: () ->
    if @paused
      @bam.play()
    else
      @bam.pause()

  apiCall: (pMethod, pParms) ->
    if pParms?
      pParms.client_id = @clientID
    else
      pParms =
        client_id: @clientID
    theURL = @apiURL + pMethod

    ajaxObj =
      url:  theURL
      data: pParms
      #dataType: 'jsonp'

    $.ajax(ajaxObj)

  popAuth: () ->
    authWindow = window.open("https://partner.api.beatsmusic.com/oauth2/authorize?"+
        "client_id=" + @clientID +
        "&response_type=token&state=page&"+
        "redirect_uri=http://localhost:3000/auth/beats_callback",
      "authpop",'height=600,width=600'
    )
    if (window.focus)
      authWindow.focus()

  setAuthToken: (token) ->
    @accessToken = token
    @bam.authentication =
      access_token: @accessToken,
      user_id: @userID


class PlayerEventHandler
  constructor: (options) ->
    @baseEl = $(options.baseSelector || 'beats-player')

  onReady: (bam) =>
    console.log('BAM Ready')

  onError: (value) =>
    console.log("Error: " + value);
    switch value
      when "auth"
        # Beats Music API auth error (401)
        console.log('Auth Error!')

      when "connectionfailure"
        # audio stream connection failure
        console.log(' Error!')

      when "apisecurity"
        # Beats Music API crossdomain error
        console.log(' Error!')

      when "streamsecurity"
        # audio stream crossdomain error
        console.log(' Error!')

      when "streamio"
        # audio stream io error
        console.log(' Error!')

      when "apiio"
        # Beats Music API io error getting track data
        console.log(' Error!')

      when "flashversion"
        # flash version too low or not installed (10.2)
        console.log(' Error!')

      else
        console.log("Don't know that error!")
    true

  onDuration: (bam, duration) =>
    console.log('onDuration')
    true

  onMetadataLoaded: (bam, metadata) =>
    console.log('onMetadataLoaded')
    title = $("#beats-player .title")
    title.text(metadata.display)
    api = bam.apiCall('tracks/' + metadata.id)
    api.done((data)=>
      artist = data.data.artist_display_name
      $("#beats-player .performer").text(artist)
      true
    )
    api.fail(()->
      console.log('API Failure!')
    )
    true

  onStreamStarted: (bam) =>
    $('#beats-player').removeClass('paused')
    $('#beats-player').addClass('now-playing')
    console.log('onStreamStarted')
    true

  onStreamPlaying: (bam) =>
    $('#beats-player').removeClass('paused')
    $('#beats-player').addClass('now-playing')
    console.log('onStreamPlaying')
    true

  onStreamPaused: (bam) =>
    console.log('onStreamPaused')
    $('#beats-player').addClass('paused')
    true

  onStreamStopped: (bam) =>
    console.log('onStreamStopped')
    $('#beats-player').removeClass('now-playing')
    true

  onStreamStalled: (bam) =>
    console.log('onStreamStalled')
    true

  onStreamEnded: (bam) =>
    console.log('onStreamEnded')
    $('#beats-player').removeClass('now-playing')
    true

  onTimeUpdate: (bam) =>
    $('#beats-player .counts .time').text(bam.currentTime)
    #$('#beats-player .counts .buffer').text(bam.buffered.end)
    $('#beats-player .counts .seekable').text(bam.seekable.end)
    #console.log('onTimeUpdate')
    true

  onVolumeChange: (bam, onVolumeChange) =>
    console.log('')
    true


class PlayerController
  constructor: (@player, options) ->
    @baseEl = $(options.baseSelector || 'beats-player')
    @hookupEvents()

  hookupEvents: () ->
    $('.play-container a').click( () =>
      trackID = $('#trackId').val()
      console.log('Loading Track ' + trackID)
      if (@player.loaded)
        @player.togglePlayback()
      else
        @player.loadTrack(trackID)
      true
    )

    $('.back-container a').click( () =>
      ct = @player.bam.currentTime
      seekable = @player.bam.seekable
      if ct > 5
        ct = ct - 5
      else
        ct = 0

      console.log('Moving play point back to ' + ct)
      #@player.bam.pause()
      @player.bam.currentTime = ct
      #@player.bam.play()
      true
    )

    $('.forward-container a').click( () =>
      ct = @player.bam.currentTime
      seekable = @player.bam.seekable
      if (ct + 5 > seekable.end)
        ct = seekable.end - 2
      else
        ct = ct + 5
      console.log('Moving play point forward to ' + ct)
      @player.bam.currentTime = ct
      true
    )

    $('.fast-play-container a').click( () =>
      trackID = $('#trackId').val()
      segments = $('#segments').val()
      seconds = $('#length').val()
      console.log('Loading Track ' + trackID)
      @player.loadTrack(trackID)
      @playSegment(1, segments, seconds)
      true
    )
    $('#auth').click(()=>
      @player.popAuth()
    )

  playSegment: (segment, total, length) ->
    totalDuration = @player.bam.duration
    timerLength = length
    if (segment == 1)
      timerLength = length * 1.5
    else
      if (segment < total)
        ct = (totalDuration/(total-1)) * (segment - 1)
      else
        ct = totalDuration - (length * 1.5)
      @player.bam.currentTime = ct

    if (segment < total)
      setTimeout(() =>
        @playSegment(segment + 1, total, length)
        true
      , timerLength * 1000)
    true


window.BeatsPlayer = BeatsPlayer
window.PlayerEventHandler = PlayerEventHandler
window.PlayerController = PlayerController
