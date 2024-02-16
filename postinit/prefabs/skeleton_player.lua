local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("skeleton_player", function(inst)
    if GetPlayer().prefab == "wanda" then
        inst:Hide()
        inst:AddTag("NOBLOCK")
        inst.persists = false
    end
end)
