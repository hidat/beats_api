##
# Wraps a simple API/Event Handler around the Beats BAM Player
##
class BeatsPlayer
  constructor: (@eventHandler, options) ->
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
    );
    @bam.on("loadedmetadata", (metadata)=>
      @eventHandler.onMetadataLoaded(@bam, metadata)
    );
    @bam.on("canplay", ()=>
      @eventHandler.onStreamStarted(@bam)
    );
    @bam.on("playing", ()=>
      @eventHandler.onStreamPlaying(@bam)
    );
    @bam.on("pause", ()=>
      @eventHandler.onStreamPaused(@bam)
    );
    @bam.on("stopped", ()=>
      @eventHandler.onStreamStopped(@bam)
    );
    @bam.on("stalled", ()=>
      @eventHandler.onStreamStalled(@bam)
    );
    @bam.on("ended", ()=>
      @eventHandler.onStreamEnded(@bam)
    );
    @bam.on("timeupdate", ()=>
      @eventHandler.onTimeUpdate(@bam)
    );
    @bam.on("volumechange", ()=>
      @eventHandler.onVolumeChange(@bam)
    );
    @bam.on("error", (error)=>
      @eventHandler.onError(@bam, error)
    );

  loadTrack: (trackID) ->
    @bam.identifier = trackID;
    @bam.load();

  togglePlayback: () ->
    @bam.play()


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

    onDuration: (duration) =>
      console.log('onDuration')
      true

    onMetadataLoaded: (metadata) =>
      console.log('onMetadataLoaded')
      true

    onStreamStarted: () =>
      console.log('onStreamStarted')
      true

    onStreamPlaying: () =>
      console.log('onStreamPlaying')
      true

    onStreamPaused: () =>
      console.log('onStreamPaused')
      true

    onStreamStopped: () =>
      console.log('onStreamStopped')
      true

    onStreamStalled: () =>
      console.log('onStreamStalled')
      true

    onStreamEnded: () =>
      console.log('onStreamEnded')
      true

    onTimeUpdate: () =>
      console.log('onTimeUpdate')
      true

    onVolumeChange: (onVolumeChange) =>
      console.log('')
      true


class PlayerController
  constructor: (@player, options) ->
    @baseEl = $(options.baseSelector || 'beats-player')
    @hookupEvents()

  hookupEvents: () ->
    $('#loadStream').click( () =>
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
