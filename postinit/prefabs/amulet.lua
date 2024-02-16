local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

AddPrefabPostInit("amulet", function(inst)
    local onequip = inst.components.equippable.onequipfn
    inst.components.equippable:SetOnEquip(function(inst, owner)
        if onequip then
            onequip(inst, owner)
        end

        if owner.prefab == "wanda" and inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end)
end)
