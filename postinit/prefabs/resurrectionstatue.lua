GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local function onbuilt(inst)
    GetPlayer():PushEvent("effigy_activate")
end

local function OnRemoved(inst)
    GetPlayer():PushEvent("effigy_deactivate")
end

AddPrefabPostInit("resurrectionstatue", function(inst)
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", OnRemoved)
end)