local keyboard = libs.keyboard;

--@help Live TV
actions.live_tv = function()
	keyboard.stroke("ctrl","shift","alt", "pgup")
end

--@help Replays
actions.replays = function()
	keyboard.stroke("ctrl","shift","alt", "pgdown")
end

-- --@help Lower volume
--actions.volume_down = function()
--    keyboard.stroke("ctrl","shift","alt","O");
--end

-- --@help Raise volume
--actions.volume_up = function()
--    keyboard.stroke("ctrl","shift","alt","P");
--end

--@help Mute volume
actions.volume_mute = function()
	keyboard.stroke("ctrl","shift","alt","M");
end

--@help Navigate up
actions.up = function()
	keyboard.stroke("ctrl","shift","alt","up");
	keyboard.stroke("ctrl","shift","alt","I");
end

--@help Navigate right
actions.right = function()
	keyboard.stroke("ctrl","shift","alt","right");
	keyboard.stroke("ctrl","shift","alt","L");
end

--@help Navigate down
actions.down = function()
	keyboard.stroke("ctrl","shift","alt","down");
	keyboard.stroke("ctrl","shift","alt","K");
end

--@help Navigate left
actions.left = function()
	keyboard.stroke("ctrl","shift","alt","left");
	keyboard.stroke("ctrl","shift","alt","J");
end

--@help Select current item
actions.select = function()
	keyboard.stroke("ctrl","shift","alt","end");
	keyboard.stroke("ctrl","shift","alt","N");
end

--@help Jump player backwards
actions.jump_backwards = function()
	keyboard.stroke("ctrl","shift","alt","R");
end

--@help Playpause
actions.playpause = function()
	keyboard.stroke("ctrl","shift","alt","T");
end

--@help Jump player forwards
actions.jump_forwards = function()
	keyboard.stroke("ctrl","shift","alt","F");
end

--@help Start show over
actions.start_show_over = function()
	keyboard.stroke("ctrl","shift","alt","Y");
end

--@help Close Ziggo
actions.close_ziggo = function()
	keyboard.stroke("ctrl","shift","alt","Y");
end