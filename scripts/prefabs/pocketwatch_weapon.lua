
local assets =
{
    Asset("ANIM", "anim/pocketwatch_weapon.zip"),
}

local prefabs =
{
}

local function TryStartFx(inst, owner)

end

local function StopFx(inst)

end

-------------------------------------------------------------------------------
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "pocketwatch_weapon", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

	TryStartFx(inst, owner)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	StopFx(inst)
end

local function onattack(inst, attacker, target)
	if not inst.components.fueled:IsEmpty() then
		inst.components.fueled:DoDelta(-TUNING.TINY_FUEL)

		if attacker == nil or attacker.age_state == nil or attacker.age_state == "young" then
			inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/shadow_attack")
		else
			-- fx will handle sounds
		end
	else
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/attack")
	end
end

local function GetStatus(inst, viewer)
	return (viewer:HasTag("pocketwatchcaster") and inst.components.fueled:IsEmpty()) and "DEPLETED"
			or nil
end

local function OnFuelChanged(inst, data)
    if data and data.percent then
        if data.percent > 0 then
            if not inst:HasTag("shadow_item") then
                inst:AddTag("shadow_item")
			    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
				TryStartFx(inst)
            end
        else
            inst:RemoveTag("shadow_item")
		    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_DEPLETED_DAMAGE)
			StopFx(inst)
        end
    end
end

local function OnTakeFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

	inst:AddTag("pocketwatch")

    inst.AnimState:SetBank("pocketwatch_weapon")
    inst.AnimState:SetBuild("pocketwatch_weapon")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("characterspecific")
    inst.components.characterspecific.owner = "wanda"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
        inst:AddComponent("floatable")
    end

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
    inst.components.fueled.accepting = true
    inst.components.fueled.ontakefuelfn = OnTakeFuel

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.POCKETWATCH_SHADOW_DAMAGE)
    inst.components.weapon:SetRange(TUNING.WHIP_RANGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:ListenForEvent("percentusedchange", OnFuelChanged)

    inst:DoTaskInTime(0, function()
        OnFuelChanged(inst, {percent = inst.components.fueled:GetPercent()})
    end)

    return inst
end

--------------------------------------------------------------------------------

return Prefab("pocketwatch_weapon", fn, assets, prefabs)
