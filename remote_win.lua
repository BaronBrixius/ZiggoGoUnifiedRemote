local keyboard = libs.keyboard;
--local win = libs.win;
--local utf8 = libs.utf8;

--@help Live TV
actions.live_tv = function()
    keyboard.stroke("ctrl", "pgup")
end

--@help Replays
actions.replays = function()
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

--@help Select current item
actions.jumpbackwards = function()
    keyboard.stroke("ctrl","shift","alt","R");
end

--@help Select current item
actions.playpause = function()
    keyboard.stroke("ctrl","shift","alt","T");
end

--@help Select current item
actions.jumpforwards = function()
    keyboard.stroke("ctrl","shift","alt","F");
end