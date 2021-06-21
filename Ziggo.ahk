#NoEnv
SetBatchLines, -1
;#Warn  ; Enable warnings to assist with detecting common errors.

#Include C:/Users/Max/Documents/Chrome.ahk

global PageInst := false
global selection := 0	;current channel selection
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

return

^PgUp::
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-kijken.html")			;Live TV Page
	Sleep 1000
	ChangeLiveChannelSelection(0)
return

^PgDn::
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-gids-replay.html")	;Replay Page
	InitializeReplaySelection()
return

!^+End::ClickLiveChannelSelection()
!^+Up::ChangeLiveChannelSelection(-5)
!^+Right::ChangeLiveChannelSelection(1)
!^+Down::ChangeLiveChannelSelection(5)
!^+Left::ChangeLiveChannelSelection(-1)
;!^+P::ChangeVolume(.05)
;!^+O::ChangeVolume(-.05)
!^+M::ToggleMute()
!^+R::JumpPlayerBackwards()
!^+F::JumpPlayerForwards()
!^+T::PlayPause()
!^+Y::StartShowOver()
!^+I::ChangeReplaySelectionUp()
!^+K::ChangeReplaySelectionDown()
!^+J::ChangeReplaySelectionLeft()
!^+L::ChangeReplaySelectionRight()
!^+N::SelectReplay()

; ============ Global ===============

ConnectZiggo() {
	if (Chromes := Chrome.FindInstances()) {
		ChromeInst := {"base": Chrome, "DebugPort": Chromes.MinIndex()}
	} else {
		ChromeInst := new Chrome("C:\Users\Max\AppData\Local\Google\Chrome\User Data\Profile 3", "https://www.ziggogo.tv/nl")
		pid := ChromeInst.PID
		WinWait, ahk_pid %pid%
		WinMove, ahk_pid %pid%,, 5000, 0
		WinMaximize, ahk_pid %pid%
	}

	if !(PageInst := ChromeInst.GetPage()) {
		MsgBox, Could not retrieve page!
		ChromeInst.Kill()
		return
	}

	;PageInst.WaitForLoad()
}

NavigateZiggo(url) {
	if (!PageConnectionExists())
		ConnectZiggo()

	PageInst.Call("Page.navigate", {"url": url})
	PageInst.WaitForLoad()

	Sleep 300
	if (IsLoggedOut()) {
		LogIn()
	}
}

PageConnectionExists() {
	if (!PageInst)
		return false

	if (!PageInst.Connected) {
		PageInst.Disconnect()	;make sure everything is cleaned up internally
		PageInst := false
		return false
	}

	return true
}

IsLoggedOut() {
	return RunJS("document.getElementsByClassName('clickable-block snippet-button utility-bar-button')[0].title;") == "login"
}

LogIn() {
	try {
		PageInst.Evaluate("document.getElementsByClassName('clickable-block snippet-button utility-bar-button')[0].click();")
		Sleep 500
		PageInst.Evaluate("document.getElementById('USERNAME').value = 'claudje1000@gmail.com'; document.getElementById('PASSWORD').value = 'VoDaFoNe1000'; document.getElementsByClassName('button button--primary login-form-button button--with-text')[0].click();")
	} catch e {
	}
}

RunJS(JS) {
	if (!PageConnectionExists())
		ConnectZiggo()

	try {
		return PageInst.Evaluate(JS).value
	} catch e {
		return false
	}	
}

; ============ Live TV ===============

ClickLiveChannelSelection() {
	RunJS("document.getElementsByClassName('button play-button positioner positioner-container')["
			. selection
			. "].click();")

	PageInst.WaitForLoad()
	SetAudioOutputDevice()
}

ChangeLiveChannelSelection(selection_diff){
	if (!PageConnectionExists())
		ConnectZiggo()

	try {
		PageInst.Evaluate("document.getElementsByClassName('live-channel-item')["
			. selection
			. "].style.removeProperty('border');")

		CalculateSelection(selection_diff)

		PageInst.Evaluate("")

		JS =
		(
			var elm = document.getElementsByClassName('live-channel-item')[%selection%];
			elm.style.setProperty('border', '4px solid #f48c00');
			elm.scrollIntoView({behavior: "smooth", block: 'center'})
		)
		PageInst.Evaluate(JS)
	} catch e {
	}
}

CalculateSelection(selection_diff) {
	try {
		num_channels := PageInst.Evaluate("document.getElementsByClassName('live-channel-item').length;").value
	} catch e {
		num_channels := 50
	}
	selection := selection + selection_diff
	if (selection < 0)
		selection := selection + num_channels
	else if (selection >= num_channels)
		selection := selection - num_channels
}

; ============ Replays ===============

InitializeReplaySelection() {
	if (!PageConnectionExists())
		ConnectZiggo()

	PageInst.WaitForLoad()
	Sleep 1000

	JS =
	(
		var newActive = document.getElementsByClassName('epg-grid-programs__line')[0].firstElementChild;
		while (newActive.getBoundingClientRect().right < 650) {
			newActive = newActive.nextElementSibling;
		}
		newActive.click();
	)

	try {
		PageInst.Evaluate(JS)
	} catch ex {
	}
}

ChangeReplaySelectionLeft() {
	ChangeReplaySelectionHorizontal("previousElementSibling")
}
ChangeReplaySelectionRight() {
	ChangeReplaySelectionHorizontal("nextElementSibling")
}

ChangeReplaySelectionHorizontal(sibling) {
	JS =
	(
		var newActive = document.getElementsByClassName('epg-grid-program-cell--active')[0].%sibling%;
		newActive.click();
		%HorizontalScrollJsString%
	)

	RunJS(JS)
}

ChangeReplaySelectionUp() {
	ChangeReplaySelectionVertical("previousElementSibling")
}

ChangeReplaySelectionDown() {
	ChangeReplaySelectionVertical("nextElementSibling")
}

ChangeReplaySelectionVertical(sibling){
	JS =
	(
		var oldActive = document.getElementsByClassName('epg-grid-program-cell--active')[0];
		var oldActiveBound = oldActive.getBoundingClientRect();
		var horizontalTarget = oldActiveBound.left + Math.min(200,oldActiveBound.width / 3);

		var parent = oldActive.parentElement.%sibling%;
		if (parent != null) {
			var newActive = parent.lastElementChild;
			while (newActive.getBoundingClientRect().left > horizontalTarget) {
				newActive = newActive.previousElementSibling;
			}
			newActive.click();
			%HorizontalScrollJsString%
			newActive.scrollIntoView({block: 'center'})
		}
	)

	RunJS(JS)
}

SelectReplay() {
	RunJS("document.getElementsByClassName('button button--primary button-with-options')[0].click()")
}

; ============ Player ===============

PlayPause() {
	RunJS("document.getElementsByClassName('clickable-block ui-cd-playback-control__play')[0].click();")
}

JumpPlayerBackwards() {
	RunJS("document.getElementsByClassName('clickable-block ui-cd-playback-control__backward player-ui-control-button')[0].click();")
}

JumpPlayerForwards() {
	RunJS("document.getElementsByClassName('clickable-block ui-cd-playback-control__forward player-ui-control-button')[0].click();")
}

StartShowOver() {
	RunJS("document.getElementsByClassName('button button--tertiary player-ui-linear-tile__primary-action--startover')[0].click();")
}
; ============ Sound ===============

;ChangeVolume(volume_diff) {
;	if (!PageConnectionExists())
;		ConnectZiggo()
;
;	try {
;		volume := PageInst.Evaluate("document.getElementsByClassName('player-linear-video')[0].children[0].volume;").value
;
;		volume := volume + volume_diff
;		if (volume > 1)
;			volume := 1
;		if (volume < 0)
;			volume := 0
;
;		;PageInst.Call("DOM.setAttributeValue", {"nodeId": DescNode.NodeId, "name": "value", "value": volume})
;		PageInst.Evaluate("document.getElementsByClassName('player-linear-video')[0].children[0].volume = "
;			. volume
;			. ";")
;	} catch e {
;	}
;}

ToggleMute() {
	RunJS("document.getElementsByClassName('clickable-block player-ui-volume__snippet player-ui-control-button')[0].click();")
	SetAudioOutputDevice()	; just in case -- if user is messing with Mute then sound output device might have messed up
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

	RunJS(JS)
}