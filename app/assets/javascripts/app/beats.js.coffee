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
      bam.clientId = @clientID;
      bam.authentication =
        access_token: @accessToken,
        user_id: @userID

      @eventHandler.onReady(@bam)
    )

    #@bam.on("durationchange", @eventHandler.onDuration);
    #@bam.on("loadedmetadata", @eventHandler.onMetadataLoaded);
    #@bam.on("canplay", @eventHandler.onStreamStarted);
    #@bam.on("playing", @eventHandler.onStreamPlaying);
    #@bam.on("pause", @eventHandler.onStreamPaused);
    #@bam.on("stopped", @eventHandler.onStreamStopped);
    #@bam.on("stalled", @eventHandler.onStreamStalled);
    #@bam.on("ended", @eventHandler.onStreamEnded);
    #@bam.on("timeupdate", @eventHandler.onTimeUpdate);
    #@bam.on("volumechange", @eventHandler.onVolumeChange);
    @bam.on("error", @eventHandler.onError);

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
