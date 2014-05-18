PlayController = (() ->
  beatsAPI = null
  userID = null
  tracksToPlay = []
  currentTrack = 0
  playingAll = false
  fastPlayMode = false

  eventHandlers =
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
      playerController.gotoNext()
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


  playerController =
    hookupEvents: () ->
      $('.play-container a').click( () =>
        trackID = $('#trackId').val()
        console.log('Loading Track ' + trackID)
        if (beatsAPI.loaded)
          beatsAPI.togglePlayback()
        else
          beatsAPI.loadTrack(trackID)
        true
      )

      $('.back-container a').click( () =>
        ct = beatsAPI.bam.currentTime
        seekable = beatsAPI.bam.seekable
        if ct > 5
          ct = ct - 5
        else
          ct = 0

        console.log('Moving play point back to ' + ct)
        #beatsAPI.bam.pause()
        beatsAPI.bam.currentTime = ct
        #beatsAPI.bam.play()
        true
      )

      $('.forward-container a').click( () =>
        ct = beatsAPI.bam.currentTime
        seekable = beatsAPI.bam.seekable
        if (ct + 5 > seekable.end)
          ct = seekable.end - 2
        else
          ct = ct + 5
        console.log('Moving play point forward to ' + ct)
        beatsAPI.bam.currentTime = ct
        true
      )

      $('.fast-play-container a').click( () =>
        trackID = $('#trackId').val()
        segments = $('#segments').val()
        seconds = $('#length').val()
        console.log('Loading Track ' + trackID)
        beatsAPI.loadTrack(trackID)
        @playSegment(1, segments, seconds)
        true
      )
      $('#play-all').click( ()=>
        playerController.playAll()
      )
      $('#play-all-fast').click( ()=>
        playerController.playAllFast()
      )


    playSegment: (segment, total, length) ->
      totalDuration = beatsAPI.bam.duration
      timerLength = length
      if (segment == 1)
        timerLength = length * 1.5
      else
        if (segment < total)
          ct = (totalDuration/(total-1)) * (segment - 1)
        else
          ct = totalDuration - (length * 1.5)
        beatsAPI.bam.currentTime = ct

      if (segment < total)
        setTimeout(() =>
          @playSegment(segment + 1, total, length)
          true
        , timerLength * 1000)
      true

    loadShit: () ->
      #c = beatsAPI.apiCall('users/' + userID + '/recs/just_for_you')
      c = beatsAPI.apiCall('users/' + userID + '/mymusic/tracks')
      c.done((res) =>
        if (res.code = 'OK')
          for track in res.data
            tracksToPlay.push(track.id)
        true
      )
      alert(tracksToPlay.length + ' tracks loaded!')
      true

    playAll: () ->
      currentTrack = 0
      playingAll = true
      playerController.gotoNext()
      true

    playAllFast: () ->
      currentTrack = 0
      fastPlayMode = true
      playingAll = true
      playerController.gotoNext()
      true


    gotoNext: () ->
      if (playingAll)
        if (currentTrack < tracksToPlay.length)
          beatsAPI.loadTrack((tracksToPlay[currentTrack]))
          if (fastPlayMode)
            segments = $('#segments').val()
            seconds = $('#length').val()
            @playSegment(1, segments, seconds)

          currentTrack++


  publicAPI =
  ##
  # Initializes the NGN1 SDK
  ##
    initialize: (pOptions) ->

      # Validate configuration
      unless pOptions?
        console.error('No options passed to Ngn1, aborting!')
        return false

      beatsAPI = new BeatsAPI(eventHandlers, pOptions)
      userID = pOptions.userID
      playerController.hookupEvents()
      true

    setAuthToken: (token) ->
      beatsAPI.setAuthToken((token))
      playerController.loadShit()
      true


  publicAPI
)()

window.PlayManager = PlayController