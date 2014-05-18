##
# Wraps a simple API/Event Handler around the Beats BAM Player
##
class BeatsAPI
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

  apiCall: (pMethod, pParms) =>
    if pParms?
      pParms.client_id = @clientID
      pParms.access_token = @accessToken
    else
      pParms =
        client_id: @clientID
        access_token: @accessToken

    theURL = @apiURL + pMethod

    ajaxObj =
      url:  theURL
      data: pParms
      #dataType: 'jsonp'

    $.ajax(ajaxObj)

  setAuthToken: (token) ->
    @accessToken = token
    @bam.authentication =
      access_token: @accessToken,
      user_id: @userID




window.BeatsAPI = BeatsAPI