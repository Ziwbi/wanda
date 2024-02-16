local assets =
{
    Asset("ANIM", "anim/pocketwatch_dismantler.zip"),
}

local prefabs =
{
	"brokentool",
	"shadow_puff_solid",
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pocketwatch_dismantler")
    inst.AnimState:SetBuild("pocketwatch_dismantler")
    inst.AnimState:PlayAnimation("idle")

    if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
        inst:AddComponent("floatable")
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("pocketwatch_dismantler")

    inst:AddComponent("inspectable")

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("pocketwatch_dismantler", fn, assets, prefabs)