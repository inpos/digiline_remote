--[[
    .___.__       .__.__  .__                                                 __
  __| _/|__| ____ |__|  | |__| ____   ____     _______   ____   _____   _____/  |_  ____
 / __ | |  |/ ___\|  |  | |  |/    \_/ __ \    \_  __ \_/ __ \ /     \ /  _ \   __\/ __ \
/ /_/ | |  / /_/  >  |  |_|  |   |  \  ___/     |  | \/\  ___/|  Y Y  (  <_> )  | \  ___/
\____ | |__\___  /|__|____/__|___|  /\___  >____|__|    \___  >__|_|  /\____/|__|  \___  >
     \/   /_____/                 \/     \/_____/           \/      \/                 \/
--]]

digiline_remote = {}

local MODNAME = "digiline_remote"
local MODPATH = minetest.get_modpath(MODNAME)
dofile(MODPATH.."/api.lua")
dofile(MODPATH.."/antenna.lua")
dofile(MODPATH.."/rc.lua")
dofile(MODPATH.."/test.lua")
