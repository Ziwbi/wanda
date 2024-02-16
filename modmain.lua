GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("main/assets.lua")
modimport("main/tuning.lua")
modimport("main/fx.lua")
modimport("main/actions.lua")
modimport("main/strings.lua")
modimport("main/translation.lua")
modimport("main/postinit.lua")

AddMinimapAtlas("images/map_icons/wanda.xml")
AddModCharacter("wanda")
