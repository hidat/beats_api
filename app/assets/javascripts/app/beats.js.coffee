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
      @eventHandler.onStreamStarted(@bam)
      true
    );
    @bam.on("playing", ()=>
      @eventHandler.onStreamPlaying(@bam)
      true
    );
    @bam.on("pause", ()=>
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
    @bam.play()

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
      dataType: 'jsonp'

    $.ajax(ajaxObj)





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
    bam.apiCall('tracks/' + metadata.id).done((data)=>
      artist = data.artist
    )
    true

  onStreamStarted: (bam) =>
    console.log('onStreamStarted')
    true

  onStreamPlaying: (bam) =>
    console.log('onStreamPlaying')
    true

  onStreamPaused: (bam) =>
    console.log('onStreamPaused')
    true

  onStreamStopped: (bam) =>
    console.log('onStreamStopped')
    true

  onStreamStalled: (bam) =>
    console.log('onStreamStalled')
    true

  onStreamEnded: (bam) =>
    console.log('onStreamEnded')
    true

  onTimeUpdate: (bam) =>
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
      @player.loadTrack(trackID)
    )


    $('#play').click(() =>
      console.log('Toggling Track')
      @player.togglePlayback()
    )


window.BeatsPlayer = BeatsPlayer
window.PlayerEventHandler = PlayerEventHandler
window.PlayerController = PlayerController
