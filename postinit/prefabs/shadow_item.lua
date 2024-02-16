local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local function wanda_dapperfn(inst, owner)
    -- dappermess component from base game
    local dapperness = inst.components.dapperness and inst.components.dapperness.dapperness or inst.components.equippable.dapperness or 0
    if owner.prefab == "wanda" then
        if inst:HasTag("shadow_item") then
            return owner.age_state == "old"    and dapperness * TUNING.WANDA_SHADOW_RESISTANCE_OLD
                or owner.age_state == "normal" and dapperness * TUNING.WANDA_SHADOW_RESISTANCE_NORMAL
                or dapperness * TUNING.WANDA_SHADOW_RESISTANCE_YOUNG
        end
    end
    return dapperness
end

local function shadow_item_postinit(inst)
    inst:AddTag("shadow_item")
    if inst.components.dapperness then
        inst.components.dapperness.dapperfn = wanda_dapperfn
    end
    if inst.components.equippable then
        inst.components.equippable.dapperfn = wanda_dapperfn
    end
end

AddPrefabPostInit("nightsword", shadow_item_postinit)
AddPrefabPostInit("armor_sanity", shadow_item_postinit)
