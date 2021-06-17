local keyboard = libs.keyboard;
--local win = libs.win;
--local utf8 = libs.utf8;

--@help Home
actions.home = function()
    keyboard.stroke("ctrl", "home")
end

actions.tv_replay = function()
    keyboard.stroke("ctrl", "pgup")
end

actions.movies_series = function()
    keyboard.stroke("ctrl", "pgdown")
end

--@help Lower volume
actions.volume_down = function()
    keyboard.stroke("ctrl","shift","alt","O");
end

--@help Mute volume
actions.volume_mute = function()
    keyboard.stroke("ctrl","shift","alt","M");
end

--@help Raise volume
actions.volume_up = function()
    keyboard.stroke("ctrl","shift","alt","P");
end

--@help Pause playback
--actions.pause = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("next");
--end

--@help Toggle playback state
--actions.play_pause = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("space");
--end

--@help Navigate up
actions.up = function()
    keyboard.stroke("ctrl","shift","alt","up");
end

--@help Navigate right
actions.right = function()
    keyboard.stroke("ctrl","shift","alt","right");
end

--@help Navigate down
actions.down = function()
    keyboard.stroke("ctrl","shift","alt","down");
end

--@help Navigate left
actions.left = function()
    keyboard.stroke("ctrl","shift","alt","left");
end

--@help Select current item
actions.select = function()
    keyboard.stroke("ctrl","shift","alt","end");
end


--@help Seek forward
--actions.forward = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("right");
--end

--@help Seek backward
--actions.rewind = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("left");
--end

--@help Fullscreen view
--actions.fullscreen = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("F");
--end

--@help Windowed view
--actions.window = function()
--    local hwnd = FindWindow();
--    keyboard.stroke("escape");
--end

--actions.skip_intro = function()
--    keyboard.stroke("s");
--end