local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("waterdrop", function(inst) -- Do it in oldager?
    inst.components.edible:SetOnEatenFn(function(food, eater)
        if eater.prefab == "wanda" then
            eater.components.health:DoDelta(TUNING.HEALING_SUPERHUGE * 3, false, inst.prefab)
        end
    end)
end)