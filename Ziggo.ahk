#NoEnv
SetBatchLines, -1
;#Warn  ; Enable warnings to assist with detecting common errors.

#Include C:/Users/Max/Documents/Chrome.ahk

global PageInst := false
global HorizontalScrollJsString := "
(
	var bounding = newActive.getBoundingClientRect();
	//checks 1/3 into the element rather than half as it's assumed users prefer to see the start rather than the end
	var horizontalTarget = bounding.left + (bounding.width / 3);
	if (!newActive.isSameNode(document.elementFromPoint(horizontalTarget,bounding.top))) {
		document.getElementsByClassName('epg-grid-arrows__button epg-grid-arrows__button--'.concat(horizontalTarget < 700 ? 'left' : 'right'))[0].click();
	}
)"

!^+PgUp::OpenLiveChannelsPage()
!^+PgDn::OpenReplayPage()
!^+Insert::CloseZiggo()
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

; ============ Global Functions ===============

EmptyMem(PID="AHK Rocks"){
    pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}

RunJS(JS, emptyMem := 1) {
	if (!PageConnectionExists())
		ConnectZiggo()

	value := ""
	try {
		value := PageInst.Evaluate("{" JS "}").value || true
	} catch e {
		value := false
	}
	
	if emptyMem
		EmptyMem()

	return value
}

; ============ Navigation ===============

ConnectZiggo() {
	for Item in Chrome.FindInstances() {
		if (Item = 9222)
			ChromeInst := {"base": Chrome, "DebugPort": Item}
	}

	if (!ChromeInst) {
		ChromeInst := new Chrome("C:\Users\Max\AppData\Local\Google\Chrome\User Data\Profile 3", "https://www.ziggogo.tv/nl")
		pid := ChromeInst.PID
		WinWait, ahk_pid %pid%,, 3
		Sleep 25
		if ErrorLevel
			Exit
		
		WinMove, ahk_pid %pid%,, 5000, 0
		WinMaximize, ahk_pid %pid%
		Winset, Alwaysontop, On, ahk_pid %pid%
	}

	if !(PageInst := ChromeInst.GetPage()) {
		ChromeInst.Kill()
		return
	}

	;PageInst.WaitForLoad()
}

NavigateZiggo(url) {
	if (!PageConnectionExists())
		ConnectZiggo()

	try PageInst.Call("Page.navigate", {"url": url})
	PageInst.WaitForLoad()

	Sleep 300
	TryClosePopUpsAndLogIn()
}

PageConnectionExists() {
	if (!PageInst)
		return false

	if (!PageInst.Connected) {
		PageInst.Disconnect()	;let Chrome.ahk clean everything up internally
		PageInst := false
		return false
	}

	return true
}

TryClosePopUpsAndLogIn() {
	JS =
	(
		let loginDelay = 10;
		
		let dialogCancelButton = document.getElementsByClassName('confirmation-buttons-cancel')[0];
		if (typeof(dialogCancelButton) != 'undefined' && dialogCancelButton != null) {
			dialogCancelButton.click();
			loginDelay = 350;
		}
		
		setTimeout(function() {
			let loginButton = document.getElementsByClassName('snippet-button utility-bar-button')[0];
			if (loginButton.title == 'login') {
				loginButton.click();
				setTimeout(function() {
					document.getElementById('USERNAME').value = 'claudje1000@gmail.com';
					document.getElementById('PASSWORD').value = 'VoDaFoNe1000';
					document.getElementsByClassName('button--primary login-form-button')[0].click();
				}, 700);
			}
		}, loginDelay);
	)
	
	RunJS(JS)
}

CloseZiggo() {
	if (!PageConnectionExists()) {
		for Item in Chrome.FindInstances() {
			if (Item = 9222) {
				ChromeInst := {"base": Chrome, "DebugPort": Item}
				PageInst := ChromeInst.GetPage()
				break
			}
		}
	}

	PageInst.Call("Browser.close") ; Fails when running headless
	PageInst.Disconnect()
	PageInst := false
	ChromeInst.Kill()
}

; ============ Live TV ===============

OpenLiveChannelsPage(){
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-kijken.html")			;Live TV Page
	Sleep 500
	ChangeLiveChannelSelection(0)
}

ClickLiveChannelSelection() {
	JS =
	(
		var channels = document.getElementsByClassName('live-channel-item');
		for (var i = 0; i < channels.length; i++) {
			if (channels[i].style['border'] == '4px solid rgb(244, 140, 0)') {
				channels[selection].click();
				break;
			}
		}
	)
	RunJS(JS)

	PageInst.WaitForLoad()
	Sleep 500
	SetAudioOutputDevice()
	SetVideoErrorObserver()
}

ChangeLiveChannelSelection(selection_diff){
	JS =
	(
		var channels = document.getElementsByClassName('live-channel-item');

		for (var selection = 0; selection < channels.length; selection++) {
			if (channels[selection].style['border'] == '4px solid rgb(244, 140, 0)') {
				channels[selection].style.removeProperty('border');
				break;
			}
		}
		if (selection == channels.length) {
			selection = 0;
		}

		selection = (selection + %selection_diff% + channels.length) `% channels.length;	//js doesn't modulo negative numbers correctly

		channels[selection].style.setProperty('border', '4px solid #f48c00');
		channels[selection].scrollIntoView({behavior: 'smooth', block: 'center'});
	)

	RunJS(JS, 0)
}

; ============ Replays ===============

OpenReplayPage() {
	NavigateZiggo("https://www.ziggogo.tv/nl/tv/tv-gids-replay.html")	;Replay Page
	Sleep 1000
	InitializeReplaySelection()
}

InitializeReplaySelection() {
	JS =
	(
		var newActive = document.getElementsByClassName('epg-grid-programs__line')[0].firstElementChild;
		while (newActive.getBoundingClientRect().right < 750 && newActive.nextElementSibling) {
			newActive = newActive.nextElementSibling;
		}
		newActive.click();
	)

	RunJS(JS)
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
		var oldActive = document.getElementsByClassName('epg-grid-program-cell--active')[0];
		if (!oldActive) {
			let newActive = document.getElementsByClassName('epg-grid-programs__line')[0].firstElementChild;
			while (newActive.getBoundingClientRect().right < 750 && newActive.nextElementSibling) {
				newActive = newActive.nextElementSibling;
			}
			newActive.click();
			exit
		}
		oldActive.%sibling%.click();
		%HorizontalScrollJsString%
	)

	RunJS(JS, 0)
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
		if (!oldActive) {
			let newActive = document.getElementsByClassName('epg-grid-programs__line')[0].firstElementChild;
			while (newActive.getBoundingClientRect().right < 750 && newActive.nextElementSibling) {
				newActive = newActive.nextElementSibling;
			}
			newActive.click();
			exit
		}
		var oldActiveBound = oldActive.getBoundingClientRect();
		var horizontalTarget = oldActiveBound.left + Math.min(200,oldActiveBound.width / 3);

		var parent = oldActive.parentElement.%sibling%;
		if (parent) {
			let newActive = parent.lastElementChild;
			while (newActive.getBoundingClientRect().left > horizontalTarget) {
				newActive = newActive.previousElementSibling;
			}
			newActive.click();
			%HorizontalScrollJsString%
			newActive.scrollIntoView({block: 'center'})
		}
	)

	RunJS(JS, 0)
}

SelectReplay() {
	RunJS("document.getElementsByClassName('button-with-options')[0].click()")
	;not setting audio/observer like live-channel selection because both methods are called and the other covers this -- not good practice but eh
	;Sleep 500
	;SetAudioOutputDevice()
	;SetVideoErrorObserver()
}

; ============ Player ===============

PlayPause() {
	RunJS("document.querySelector('.ui-cd-playback-control__play').click();")
}

JumpPlayerBackwards() {
	RunJS("document.getElementsByClassName('ui-cd-playback-control__backward player-ui-control-button')[0].click();")
}

JumpPlayerForwards() {
	RunJS("document.getElementsByClassName('ui-cd-playback-control__forward player-ui-control-button')[0].click();")
}

StartShowOver() {
	JS =
	(
		let backToLiveButton = document.querySelector('.player-vod-bottom-bar__primary-action--back-to-live')
		if (backToLiveButton) {
			backToLiveButton.click()
			exit
		}
		document.querySelector('.action-buttons-dropdown').click();
		document.querySelector('.clickable-block.start-over-snippet').click();
	)

	RunJS(JS)
	
	PageInst.WaitForLoad()
	Sleep 500
	SetAudioOutputDevice()
	SetVideoErrorObserver()
}

SetVideoErrorObserver() {
	JS =
	(
		var errorUI = document.getElementsByClassName('player-ui__error-screen')[0];
		var errorObserver = new MutationObserver( () => {
			setTimeout(function() {
				let button = errorUI.getElementsByClassName('button button--primary button--with-text')[0];
				if (button.innerText == 'HERSTART VIDEO') {
					button.click();
				}
			}, 2750);
		});
		
		errorObserver.observe(errorUI, {childList: true});
	)
	
	RunJS(JS)
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
	RunJS("document.getElementsByClassName('player-ui-volume__snippet player-ui-control-button')[0].click();")
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
					let deviceInfo = deviceInfos[i];
					if (deviceInfo.kind == 'audiooutput' && deviceInfo.label.startsWith("50UHD_LCD_TV")) {
						document.getElementsByTagName('video')[0].setSinkId(deviceInfo.deviceId);
						return true;
					}
				}
				return false;
		});
	)

	RunJS(JS)
}