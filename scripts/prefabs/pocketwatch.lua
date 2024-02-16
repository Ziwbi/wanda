local PocketWatchCommon = require "prefabs/pocketwatch_common"

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/pocketwatch_common.lua"),

    Asset("ANIM", "anim/pocketwatch.zip"),
    Asset("ANIM", "anim/pocketwatch_marble.zip"),
    Asset("ANIM", "anim/pocketwatch_recall.zip"),
    Asset("ANIM", "anim/pocketwatch_warp.zip"),
    Asset("ANIM", "anim/pocketwatch_warp_marker.zip")
}
local prefabs = 
{
	"pocketwatch_cast_fx",
	"pocketwatch_cast_fx_mount",
	"pocketwatch_heal_fx",
	"pocketwatch_heal_fx_mount",
	"pocketwatch_ground_fx",
	"pocketwatch_warp_marker", 
	"pocketwatch_warpback_fx",
	"pocketwatch_warpbackout_fx",
}

-------------------------------------------------------------------------------

local function Heal_DoCastSpell(inst, doer)
	local health = doer.components.health
	if health and not health:IsDead() then
		doer.components.oldager:StopDamageOverTime()
		health:DoDelta(TUNING.POCKETWATCH_HEAL_HEALING, true, inst.prefab)

		local fx = SpawnPrefab((doer.components.rider and doer.components.rider:IsRiding()) and "pocketwatch_heal_fx_mount" or "pocketwatch_heal_fx")
		fx.entity:SetParent(doer.entity)

		inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_HEAL_COOLDOWN)
		return true
	end
end

local MOUNTED_CAST_TAGS = {"pocketwatch_mountedcast"}

local function healfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_marble", Heal_DoCastSpell, true, MOUNTED_CAST_TAGS)

	inst.castfxcolour = {255 / 255, 241 / 255, 236 / 255}

    return inst
end

-------------------------------------------------------------------------------


local function recallmarker_ShowMarker(inst, viewer) end

local function recallmarker_RemoveMarker(inst, viewer)
	if inst:IsAsleep() then
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("idle_pst")
		inst.AnimState:PushAnimation("off", false)
		inst:DoTaskInTime(0.5, inst.Remove) 
	end
end

local function recallmarkerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("pocketwatch_warp_marker")
    inst.AnimState:SetBuild("pocketwatch_warp_marker")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:PlayAnimation("idle_pre")
	inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1.0, 1.0, 1.0, 0.6)

	inst:AddTag("NOBLOCK")
    inst:AddTag("FX")

	inst.persists = false

	inst.ShowMarker = recallmarker_ShowMarker
	inst.RemoveMarker = recallmarker_RemoveMarker

    return inst
end

local function DelayedMarkTalker(player)
	-- if the player starts moving right away then we can skip this
	if player.sg == nil or player.sg:HasStateTag("idle") then 
		player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_POCKETWATCH_MARK"))
	end 
end

local function Recall_DoCastSpell(inst, doer, target, pos)
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
        if recallmark:IsTargetLevelRegenerated() then
           return false, "REVIVE_FAILED" -- A suitable quote
		elseif SaveGameIndex:HasWorld(recallmark.save_slot, recallmark.level_mode) then
			inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

			doer.sg.statemem.warpback = {
				dest_worldid = recallmark.level_mode, 
				dest_x = recallmark.recall_x, 
				dest_y = 0, 
				dest_z = recallmark.recall_z, 
				reset_warp = true,
				recallmark = inst.components.recallmark}
			return true
		else
			return false, "SHARD_UNAVAILABLE"
		end
	else
		local x, y, z = doer.Transform:GetWorldPosition()
		inst.components.recallmark:MarkPosition(x, y, z)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
end

local function Recall_GetActionVerb(inst, doer, target)
	return inst:HasTag("recall_unmarked") and "RECALL_MARK" or "RECALL"
end

local RECALL_WATCH_TAGS = {"pocketwatch_warp_casting", "nointerior"}

local function recallfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_recall", Recall_DoCastSpell, true, RECALL_WATCH_TAGS)

	inst.GetActionVerb_CAST_POCKETWATCH = Recall_GetActionVerb

	PocketWatchCommon.MakeRecallMarkable(inst)

    return inst
end

-------------------------------------------------------------------------------
local function warpmarker_SetMarkerViewer(inst, viewer)

end

local function warpmarker_HideMarker(inst)
	if inst.inuse then
		inst.inuse = false
		inst.AnimState:PlayAnimation("mark"..inst.anim_id.."_pst")
		inst.AnimState:PushAnimation("off", false)
	end
end

local function warpmarker_ShowMarker(inst)
	inst.anim_id = math.random(4)
	inst.AnimState:PlayAnimation("mark"..inst.anim_id.."_pre")
	inst.AnimState:PushAnimation("mark"..inst.anim_id.."_loop", true)
	inst.inuse = true
	inst.Transform:SetRotation(math.random(360))
	inst:Show()
end

local function warpmarkerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("pocketwatch_warp_marker")
    inst.AnimState:SetBuild("pocketwatch_warp_marker")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    -- inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:PlayAnimation("off")
    inst.AnimState:SetMultColour(1.0, 1.0, 1.0, 0.6)

	inst:Hide()

	inst:AddTag("NOBLOCK")
    inst:AddTag("FX")

	inst.persists = false

	inst.SetMarkerViewer = warpmarker_SetMarkerViewer
	inst.ShowMarker = warpmarker_ShowMarker
	inst.HideMarker = warpmarker_HideMarker

    return inst
end

local function Warp_DoCastSpell(inst, doer)
	local tx, ty, tz = doer.components.positionalwarp:GetHistoryPosition(false)
	if tx then
		inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_WARP_COOLDOWN)
		doer.sg.statemem.warpback = {dest_x = tx, dest_y = ty, dest_z = tz}
		return true
	end

	return false, "WARP_NO_POINTS_LEFT"
end

local WARP_WATCH_TAGS = {"pocketwatch_warp", "pocketwatch_warp_casting", "nointerior"}

local function warp_hidemarker(inst)
	if inst.marker_owner and inst.marker_owner:IsValid() then
		inst.marker_owner:PushEvent("hide_warp_marker")
	end
	inst.marker_owner = nil
end

local function warp_showmarker(inst)
	warp_hidemarker(inst)

	inst.marker_owner = inst.components.inventoryitem:GetGrandOwner()
	if inst.marker_owner then
		inst.marker_owner:PushEvent("show_warp_marker")
	end
end

local function warpfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_warp", Warp_DoCastSpell, true, WARP_WATCH_TAGS)

	inst.GetActionVerb_CAST_POCKETWATCH = "WARP"

	inst:ListenForEvent("onputininventory", warp_showmarker)
	inst:ListenForEvent("onownerputininventory", warp_showmarker)
	inst:ListenForEvent("ondropped", warp_hidemarker)
	inst:ListenForEvent("onownerdropped", warp_hidemarker)
	inst:ListenForEvent("onremove", warp_hidemarker)

    return inst
end

--------------------------------------------------------------------------------

return  Prefab("pocketwatch_heal", healfn, assets, prefabs),
		Prefab("pocketwatch_warp", warpfn, assets, prefabs),
		Prefab("pocketwatch_warp_marker", warpmarkerfn, {Asset("ANIM", "anim/pocketwatch_warp_marker.zip")}),
		Prefab("pocketwatch_recall", recallfn, assets, prefabs),
		Prefab("pocketwatch_recall_marker", recallmarkerfn, {Asset("ANIM", "anim/pocketwatch_warp_marker.zip")})
