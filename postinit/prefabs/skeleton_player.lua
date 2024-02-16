GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddPrefabPostInit("skeleton_player", function(inst)
    if GetPlayer().prefab == "wanda" then 
        inst:Hide()
        inst:AddTag("NOBLOCK")
        inst.persists = false
    end
end)
