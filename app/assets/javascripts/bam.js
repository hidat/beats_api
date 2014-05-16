var bam = new BeatsAudioManager();
bam.on("ready", handleReady);
bam.on("durationchange", handleDuration);
bam.on("loadedmetadata", handleMetadataLoaded);
bam.on("canplay", handleStreamStarted);
bam.on("playing", handleStreamPlaying);
bam.on("pause", handleStreamPaused);
bam.on("stopped", handleStreamStopped);
bam.on("stalled", handleStreamStalled);
bam.on("ended", handleStreamEnded);
bam.on("timeupdate", handleTimeUpdate);
bam.on("volumechange", handleVolumeChange);
bam.on("error", handleError);

function handleReady(value) {
    //show console
    bam_engine.style.width = "500px";
    bam_engine.style.height = "300px";
    // set credentials
    bam.clientId = clientID;
    bam.authentication = {
        access_token: accessToken,
        user_id: "121738377149"
    };
    bam.identifier = trackID;
    trackId.value = bam.identifier; // show trackId
    accessToken.value = bam.authentication.access_token; // show auth token

    muted.hidden = true;
    pauseStream.hidden = true;

    loadStream.onclick = function () {
        bam.authentication = {
            access_token: accessToken.value,
            user_id: "121738377149"
        };
        // bam.authentication = accessToken.value;
        bam.identifier = trackId.value;
        bam.load();
    };

    playStream.onclick = function () {
        bam.play();
    };

    pauseStream.onclick = function () {
        bam.pause();
    };

    stopStream.onclick = function () {
        bam.stop();
        showPause(false);
    };

    doVolume.onclick = function () {
        bam.volume = volume.value;
    };

    volumeUp.onclick = function () {
        bam.volume += 0.1;
    };

    volumeDown.onclick = function () {
        bam.volume -= 0.1;
    };

    muted.onclick = function () {
        bam.muted = false;
        toggleMute();
    };

    unmuted.onclick = function () {
        bam.muted = true;
        toggleMute();
    };

    autoplay.onclick = function () {
        bam.autoplay = autoplay.checked;
    };

    loopStream.onclick = function () {
        bam.loop = loopStream.checked;
    };

    doSeek.onclick = function () {
        bam.currentTime = seek.value;
        togglePause(false);
    };
}

function handleError(value) {
    console.log("Error: " + value);
    switch (value) {
        case "auth":
            // Beats Music API auth error (401)
            break;
        case "connectionfailure":
            // audio stream connection failure
            break;
        case "apisecurity":
            // Beats Music API crossdomain error
            break;
        case "streamsecurity":
            // audio stream crossdomain error
            break;
        case "streamio":
            // audio stream io error
            break;
        case "apiio":
            // Beats Music API io error getting track data
            break;
        case "flashversion":
            // flash version too low or not installed (10.2)
            break;
    }
}

function handleDuration(value) {
    timeDuration.innerHTML = "Duration: " + value;
    debug("bam:handleDuration: " + value);
}

function handleStreamStarted() {
    debug("bam:handleStreamStarted");
    showPause(true);
}

function handleStreamStalled() {
    debug("bam:handleStreamStalled");
    showPause(false);
}

function handleStreamStopped() {
    debug("bam:handleStreamStopped");
    showPause(false);
}

function handleStreamPaused() {
    debug("bam:handleStreamPaused");
    showPause(false);
}

function handleStreamPlaying() {
    debug("bam:handleStreamPlaying");
    showPause(true);
}

function handleStreamEnded() {
    debug("bam:handleStreamEnded");
    showPause(false);
}

function handleMetadataLoaded(data) {
    trackName.innerHTML = "Title:" + data.display;
    debug("bam:handleMetadataLoaded");
}

function handleVolumeChange(data) {
    volume.value = data.volume;
    debug("bam:handleVolumeChange");
}

function handleTimeUpdate() {
    var elapsed = bam.currentTime;
    var buffered = bam.buffered;
    var seekable = bam.seekable;
    var remaining = bam.duration - elapsed;
    timeElapsed.innerHTML = "Elapsed: " + elapsed;
    timeRemaining.innerHTML = "Remaining: " + remaining;
    timeBufferedStart.innerHTML = "Start: " + buffered.start;
    timeBufferedEnd.innerHTML = "End: " + buffered.end;
    timeBufferedLength.innerHTML = "Length: " + buffered.length;
    timeSeekableStart.innerHTML = "Start: " + seekable.start;
    timeSeekableEnd.innerHTML = "End: " + seekable.end;
    timeSeekableLength.innerHTML = "Length: " + seekable.length;

}

function showPause(value) {
    if (value == true) {
        playStream.hidden = true;
        pauseStream.hidden = false;
        return;
    }
    playStream.hidden = false;
    pauseStream.hidden = true;
}

function toggleMute() {
    muted.hidden = !muted.hidden;
    unmuted.hidden = !unmuted.hidden;
}

function debug(value) {
    if (console.log && window.console) {
        console.log(value);
    }
}