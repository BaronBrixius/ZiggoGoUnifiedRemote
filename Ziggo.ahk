#NoEnv
SetBatchLines, -1

;#Warn  ; Enable warnings to assist with detecting common errors.

#Include C:/Users/Max\Documents/Chrome.ahk

global PageInst := false
global state := false	;when numeric, current channel selection, otherwise used as label of current activity (e.g. "watching")

global HorizontalScrollJsString := "
(
	var bounding = newActive.getBoundingClientRect();
	//checks 1/3 into the element, not half as it's assumed users prefer to see the start rather than the end
	var horizontalTarget = bounding.left + (bounding.width / 3);
	if (!newActive.isSameNode(document.elementFromPoint(horizontalTarget,bounding.top))) {
		document.getElementsByClassName('epg-grid-arrows__button epg-grid-arrows__button--'.concat(horizontalTarget < 700 ? 'left' : 'right'))[0].click();
	}
)"

^Insert::	;testing method
	ChangeReplaySelectionLeft()
return

ChangeReplaySelectionLeft() {
	ChangeReplaySelectionHorizontal("previousElementSibling")
}
ChangeReplaySelectionRight() {
	ChangeReplaySelectionHorizontal("nextElementSibling")
}

ChangeReplaySelectionHorizontal(sibling) {
	if (!PageConnectionExists())
		ConnectZiggo()

	JS =
	(
	var newActive = document.getElementsByClassName('epg-grid-program-cell--active')[0].%sibling%;
	newActive.click();
	%HorizontalScrollJsString%
	)

	try {
		PageInst.Evaluate(JS)
	} catch ex {
	}
}


;	var newActive = document.getElementsByClassName('epg-grid-program-cell--active')[0].%sibling%;
;	newActive.click();
;
;	var viewBound = document.getElementsByClassName("epg-grid__programs")[0].getBoundingClientRect();
;
;	//checks 1/3 into the element, would be half but I feel there's a preference to see the start rather than the end
;	var bounding = newActive.getBoundingClientRect();
;	var horizontalTarget = bounding.left + Math.min(150, bounding.width / 3);
;
;	var numLeftClicks = (viewBound.left - horizontalTarget) / viewBound.width;
;
;	for (var i = 0; i < numLeftClicks; i++) {
;		document.getElementsByClassName('epg-grid-arrows__button epg-grid-arrows__button--%scrollDirection%')[0].click();
;	}
;	)

ChangeReplaySelectionUp() {
	ChangeReplaySelectionVertical("previousElementSibling")
}

ChangeReplaySelectionDown() {
	ChangeReplaySelectionVertical("nextElementSibling")
}

ChangeReplaySelectionVertical(sibling){
	if (!PageConnectionExists())
		ConnectZiggo()

	JS =
	(
		var oldActive = document.getElementsByClassName('epg-grid-program-cell--active')[0];
		var oldActiveBound = oldActive.getBoundingClientRect();
		var horizontalTarget = oldActiveBound.left + (oldActiveBound.width / 3);

		var parent = oldActive.parentElement.%sibling%;
		if (parent != null) {
			var newActive = parent.lastElementChild;
			while (newActive.getBoundingClientRect().left > horizontalTarget) {
				newActive = newActive.previousElementSibling;
			}
			newActive.click();
			%HorizontalScrollJsString%
		}
	)

	PageInst.Evaluate(JS)
}

^Home::
	NavigateZiggo("https://www.ziggogo.tv/nl")	;Home Page
	state := "home"
return

^PgUp::
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-kijken.html")			;TV & Replay Page
	state := 0
	ChangeLiveChannelSelection(0)
return

^PgDn::
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-gids-replay.html")	;Movies & Series Page
	state := "replay"
return

;^Del::EndConnection()
!^+End::ClickLiveChannelSelection()
!^+Up::ChangeLiveChannelSelection(-5)
!^+Right::ChangeLiveChannelSelection(1)
!^+Down::ChangeLiveChannelSelection(5)
!^+Left::ChangeLiveChannelSelection(-1)
!^+P::ChangeVolume(.05)
!^+O::ChangeVolume(-.05)
!^+M::ToggleMute()
!^+R::JumpPlayerBackwards()
!^+F::JumpPlayerForwards()
!^+T::PlayPause()
!^+I::ChangeReplaySelectionUp()
!^+K::ChangeReplaySelectionDown()
!^+J::ChangeReplaySelectionLeft()
!^+L::ChangeReplaySelectionRight()


ConnectZiggo() {
	if (Chromes := Chrome.FindInstances()) {
		ChromeInst := {"base": Chrome, "DebugPort": Chromes.MinIndex()}
		state := FindState(ChromeInst)
	} else {
		ChromeInst := new Chrome("C:\Users\Max\AppData\Local\Google\Chrome\User Data\Profile 3", "https://www.ziggogo.tv/nl")
		state := "home"
		;pid := ChromeInst.PID
		;WinWait, ahk_pid %pid%
		;WinMove, ahk_pid %pid%,, 5000, 0
		;WinMaximize, ahk_pid %pid%
	}

	if !(PageInst := ChromeInst.GetPage()) {
		MsgBox, Could not retrieve page!
		ChromeInst.Kill()
		return
	}

	;PageInst.WaitForLoad()
}

FindState(ChromeInst) {
	url := ChromeInst.GetPageList()[1]["url"]

	if (!InStr(url, "ziggogo.tv"))
		return false

	if (InStr(url, "#action=watch"))
		return "watching"

	if (InStr(url, "tv/tv-kijken.html"))
		return 0

	if (InStr(url, "movies-series-xl/ontdek.html"))
		return "replay"

	return false
}

NavigateZiggo(url) {
	if (!PageConnectionExists())
		ConnectZiggo()

	PageInst.Call("Page.navigate", {"url": url})
	PageInst.WaitForLoad()

	if IsLoggedOut()
		LogIn()
}

IsLoggedOut() {
	try {
		LoginText := PageInst.Evaluate("document.getElementsByClassName('clickable-block snippet-button utility-bar-button')[0].title;").value
		return LoginText == "login"
	} catch e {
		return false
	}
}

LogIn() {
	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block snippet-button utility-bar-button')[0].click();")
		Sleep 500
		PageInst.Evaluate("document.getElementById('USERNAME').value = 'claudje1000@gmail.com';")
		PageInst.Evaluate("document.getElementById('PASSWORD').value = 'VoDaFoNe1000';")
		PageInst.Evaluate("document.getElementsByClassName('button button--primary login-form-button button--with-text')[0].click();")
	} catch e {
	}
}

PageConnectionExists() {
	if (!PageInst)
		return false

	if (!PageInst.Connected) {
		PageInst.Disconnect()	;just to be sure everything is cleaned up
		PageInst := false
		return false
	}

	return true
}

SetAudioOutputDevice(outputDevice := "50UHD_LCD_TV") {
		;get permission to access audio devices
		;(async () => {
		;	await navigator.mediaDevices.getUserMedia({audio: true});
		;	let devices = await navigator.mediaDevices.enumerateDevices();
		;	console.log(devices);
		;	})();

	JS =
	(
		navigator.mediaDevices.enumerateDevices()
			.then(function(deviceInfos) {
				for (var i = 0; i != deviceInfos.length; i++) {
					var deviceInfo = deviceInfos[i];
					if (deviceInfo.kind == 'audiooutput' && deviceInfo.label.startsWith("50UHD_LCD_TV")) {
						document.getElementsByClassName('player-linear-video')[0].children[0].setSinkId(deviceInfo.deviceId);
						return true;
					}
				}
				return false;
		});
	)

	try {
		PageInst.Evaluate(JS)
		return true
	} catch e {
		return false
	}
}

ClickLiveChannelSelection() {
	if (!PageConnectionExists())
		ConnectZiggo()

	if state is not integer
		return

	try {
		PageInst.Evaluate("document.getElementsByClassName('button play-button positioner positioner-container')["
			. state
			. "].click();")

		state := "watching"
	} catch e {
	}

	PageInst.WaitForLoad()
	SetAudioOutputDevice()
}

ChangeLiveChannelSelection(state_diff){
	if (!PageConnectionExists())
		ConnectZiggo()

	if state is not integer
		return

	try {
		PageInst.Evaluate("document.getElementsByClassName('live-channel-item')["
			. state
			. "].style.removeProperty('border');")

		CalculateSelection(state_diff)

		PageInst.Evaluate("document.getElementsByClassName('live-channel-item')["
			. state
			. "].style.setProperty('border', '4px solid #f48c00');")
		PageInst.Evaluate("document.getElementsByClassName('live-channel-item')["
			. state
			. "].focus();") ;.scrollIntoView();
	} catch e {
	}
}

CalculateSelection(state_diff) {
	try {
		num_channels := PageInst.Evaluate("document.getElementsByClassName('live-channel-item').length;").value
	} catch e {
		num_channels := 50
	}
	state := state + state_diff
	if (state < 0)
		state := state + num_channels
	else if (state >= num_channels)
		state := state - num_channels
}

ChangeVolume(volume_diff) {
	if (!PageConnectionExists())
		ConnectZiggo()

	if (state != "watching")
		return
	try {
		volume := PageInst.Evaluate("document.getElementsByClassName('player-linear-video')[0].children[0].volume;").value

		volume := volume + volume_diff
		if (volume > 1)
			volume := 1
		if (volume < 0)
			volume := 0

		;PageInst.Call("DOM.setAttributeValue", {"nodeId": DescNode.NodeId, "name": "value", "value": volume})
		PageInst.Evaluate("document.getElementsByClassName('player-linear-video')[0].children[0].volume = "
			. volume
			. ";")
	} catch e {
	}
}

ToggleMute() {
	if (!PageConnectionExists())
		ConnectZiggo()

	if (state != "watching")
		return

	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block player-ui-volume__snippet player-ui-control-button')[0].click();")
		SetAudioOutputDevice()	; just in case -- if user is messing with Mute then output device might have messed up
	} catch e {
	}
}

PlayPause() {
	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block ui-cd-playback-control__play')[0].click();")
	} catch e {
	}
}

JumpPlayerBackwards() {
	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block ui-cd-playback-control__backward player-ui-control-button')[0].click();")
	} catch e {
	}
}

JumpPlayerForwards() {
	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block ui-cd-playback-control__forward player-ui-control-button')[0].click();")
	} catch e {
	}
}