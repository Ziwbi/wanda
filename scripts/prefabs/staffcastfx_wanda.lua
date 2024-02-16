local assets_pocketwatch =
{
    Asset("ANIM", "anim/pocketwatch_casting_fx.zip"),
    Asset("ANIM", "anim/pocketwatch_casting_fx_mount.zip"),
}

local assets_pocketwatch_warp =
{
    Asset("ANIM", "anim/pocketwatch_warp_casting_fx.zip"),
}

local function SetUp(inst, colour)
    inst.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
end

local function MakeStaffFX(anim, build, bank)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst:AddTag("FX")

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank(bank or "staff_fx")
        inst.AnimState:SetBuild(build or "staff")
        inst.AnimState:PlayAnimation(anim)
	    inst.AnimState:SetFinalOffset(1)

        inst.SetUp = SetUp

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return 
	Prefab("pocketwatch_cast_fx", MakeStaffFX("pocketwatch_cast", "pocketwatch_casting_fx", "pocketwatch_cast_fx"), assets_pocketwatch),
	Prefab("pocketwatch_cast_fx_mount", MakeStaffFX("pocketwatch_cast", "pocketwatch_casting_fx_mount", "pocketwatch_casting_fx_mount"), assets_pocketwatch),
	Prefab("pocketwatch_warpback_fx", MakeStaffFX("warpfx", "pocketwatch_warp_casting_fx", "pocketwatch_warp_casting_fx"), assets_pocketwatch_warp),
	Prefab("pocketwatch_warpbackout_fx", MakeStaffFX("warpfx_pst", "pocketwatch_warp_casting_fx", "pocketwatch_warp_casting_fx"), assets_pocketwatch_warp)
