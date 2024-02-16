GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local actual_name = LOC.GetLocaleCode() == "zh" and "[DST]旺达" or "[DST]Wanda"
local allow_watch_name = GetModConfigData("name", KnownModIndex:GetModActualName(actual_name))

if not allow_watch_name then
    return
end

AddComponentPostInit("drawingtool", function(DrawingTool)
    local CollectUseActions = DrawingTool.CollectUseActions
    function DrawingTool:CollectUseActions(doer, target, actions)
        if target:HasTag("drawable") then
            table.insert(actions, ACTIONS.DRAW)
        end
    end
end)