local MakePlayerCharacter = require("prefabs/player_common")
local WandaAgeBadge = require("widgets/wandaagebadge")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

    Asset("ANIM", "anim/wanda.zip"),
    Asset("ANIM", "anim/wanda_young.zip"),
    Asset("ANIM", "anim/wanda_old.zip"),

    Asset("ANIM", "anim/status_oldage.zip"),
    Asset("ANIM", "anim/wanda_basics.zip"),
    Asset("ANIM", "anim/wanda_mount_basics.zip"),
    Asset("ANIM", "anim/wanda_attack.zip"),
    Asset("ANIM", "anim/wanda_casting.zip"),
    Asset("ANIM", "anim/wanda_casting2.zip"),
    Asset("ANIM", "anim/wanda_mount_casting2.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
}

local prefabs =
{
	"oldager_become_younger_front_fx",
	"oldager_become_younger_back_fx",
	"oldager_become_older_fx",
	"oldager_become_younger_front_fx_mount",
	"oldager_become_younger_back_fx_mount",
	"oldager_become_older_fx_mount",

	"wanda_attack_pocketwatch_old_fx",
	"wanda_attack_pocketwatch_normal_fx",
	"wanda_attack_shadowweapon_old_fx",
	"wanda_attack_shadowweapon_normal_fx",
}

local starting_inventory = {"pocketwatch_heal", "pocketwatch_parts", "pocketwatch_parts", "pocketwatch_parts"}

----------Animation----------

local function PlayAgingFx(inst, fx_name)
	if inst.components.rider and inst.components.rider:IsRiding() then
		fx_name = fx_name .. "_mount"
	end

	local fx = SpawnPrefab(fx_name)
	fx.entity:SetParent(inst.entity)
end

local function UpdateBuild(inst, build, delay)
    -- This chunk is actually never reached
    -- if inst.queued_skinmode_task ~= nil then
    --     inst.updateskinmodetask:Cancel()
    --     inst.updateskinmodetask = nil
    -- end

    if delay then
        if inst.queued_build then
            inst.AnimState:SetBuild(inst.queued_build)
        end
        inst.queued_build = build
        inst.update_build_task = inst:DoTaskInTime(FRAMES * 15, inst.UpdateBuild, build)
    else
        inst.AnimState:SetBuild(build)
        inst.queued_build = nil
    end
end

---I can't believe there's no "Animstate:GetBuild" function
local function GetBuild(inst) 
    local health = inst.components.health.currenthealth
    local maxhealth = inst.components.health:GetMaxHealth()
    if health > 0.75 * maxhealth then
        return "wanda_young"
    elseif health > 0.25 * maxhealth then
        return "wanda"
    else 
        return "wanda_old"
    end
end

local function become_old(inst, silent)
    if inst.age_state == "old" then
        return
    end

	inst:UpdateBuild("wanda_old", not silent)

    if not silent then
        inst.sg:PushEvent("becomeolder_wanda")
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_WANDA_NORMALTOOLD"))
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
		PlayAgingFx(inst, "oldager_become_older_fx")
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_OLD)

    inst.talksoundoverride = "wanda2/characters/wanda/talk_old_LP"
    inst.age_state = "old"

    inst:AddTag("slowbuilder") 
    inst.components.worker:SetAction(ACTIONS.HAMMER, TUNING.WANDA_OLD_HAMMER_EFFECTIVENESS)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_OLD)
end

local function become_normal(inst, silent)
    if inst.age_state == "normal" then
        return
    end

    inst:UpdateBuild("wanda", not silent)

    if not silent then
        if inst.age_state == "young" then
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_WANDA_YOUNGTONORMAL"))
            inst.sg:PushEvent("becomeolder_wanda")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
			PlayAgingFx(inst, "oldager_become_older_fx")
        elseif inst.age_state == "old" then
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_WANDA_OLDTONORMAL"))
            inst.sg:PushEvent("becomeyounger_wanda")
            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
			PlayAgingFx(inst, "oldager_become_younger_front_fx")
			PlayAgingFx(inst, "oldager_become_younger_back_fx")
        end
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_NORMAL)

    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil
    inst.age_state = "normal"

    inst:RemoveTag("slowbuilder")
    inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_NORMAL)
end

local function become_young(inst, silent)
    if inst.age_state == "young" then
        return
    end

	inst:UpdateBuild("wanda_young", not silent)


    if not silent then
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_WANDA_NORMALTOYOUNG"))
        inst.sg:PushEvent("becomeyounger_wanda")
        inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
		PlayAgingFx(inst, "oldager_become_younger_front_fx")
		PlayAgingFx(inst, "oldager_become_younger_back_fx")
    end

	inst.components.positionalwarp:SetWarpBackDist(TUNING.WANDA_WARP_DIST_YOUNG)

    inst.talksoundoverride = "wanda2/characters/wanda/talk_young_LP"
    inst.age_state = "young"
    
    inst:RemoveTag("slowbuilder")
    inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
    inst.components.staffsanity:SetMultiplier(TUNING.WANDA_STAFFSANITY_YOUNG)
end

---@param inst EntityScript
---@param amount number
---@param overtime boolean
---@param cause string
---@param ignore_invincible boolean
---@param afflicter EntityScript
---@param ignore_absorb boolean
---@return nil|boolean
local function redirect_to_oldager(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return inst.components.oldager and inst.components.oldager:OnTakeDamage(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
end

---------Combat Component----------

local function GetCustomModifier(self, target, weapon)
    local inst = self.inst
    weapon = weapon or inst.components.combat:GetWeapon()
    local mount = inst.components.rider and inst.components.rider:GetMount() or nil

    if mount == nil then
        if weapon ~= nil and weapon:HasTag("shadow_item") then
            return inst.age_state == "old" and TUNING.WANDA_SHADOW_DAMAGE_OLD
                    or inst.age_state == "normal" and TUNING.WANDA_SHADOW_DAMAGE_NORMAL
                    or TUNING.WANDA_SHADOW_DAMAGE_YOUNG
        else
            return inst.age_state == "old" and TUNING.WANDA_REGULAR_DAMAGE_OLD
                    or inst.age_state == "normal" and TUNING.WANDA_REGULAR_DAMAGE_NORMAL
                    or TUNING.WANDA_REGULAR_DAMAGE_YOUNG
        end
    end

    return 1
end

local function ShadowWeaponFx(inst, target)
    local weapon = inst.components.combat:GetWeapon()
    if weapon ~= nil and target ~= nil and target:IsValid() and weapon:IsValid() and weapon:HasTag("shadow_item") then
        local fx_prefab = inst.age_state == "old" and (weapon:HasTag("pocketwatch") and "wanda_attack_pocketwatch_old_fx" or "wanda_attack_shadowweapon_old_fx")
                or inst.age_state == "normal" and (weapon:HasTag("pocketwatch") and "wanda_attack_pocketwatch_normal_fx" or "wanda_attack_shadowweapon_normal_fx")
                or nil

        if fx_prefab ~= nil then
            local fx = SpawnPrefab(fx_prefab)

            local x, y, z = target.Transform:GetWorldPosition()
            local radius = target:GetPhysicsRadius(.5)
            local angle = (inst.Transform:GetRotation() - 90) * DEGREES
            fx.Transform:SetPosition(x + math.sin(angle) * radius, 0, z + math.cos(angle) * radius)
        end
    end
end

-- Event Callbacks

local function OnHealthDelta(inst, data, forcesilent)
    if inst.sg:HasStateTag("nomorph") or
        inst.components.health:IsDead() then
        return
    end

    local silent = inst.sg:HasStateTag("silentmorph") or not inst.entity:IsVisible() or forcesilent
    local health = inst.components.health and inst.components.health:GetPercent() or 0

    if inst.age_state == "old" then
        if health > TUNING.WANDA_AGE_THRESHOLD_OLD then
            if silent and health >= TUNING.WANDA_AGE_THRESHOLD_YOUNG then
                become_young(inst, true)
            else
                become_normal(inst, silent)
            end
        end
    elseif inst.age_state == "young" then
        if health < TUNING.WANDA_AGE_THRESHOLD_YOUNG then
            if silent and health <= TUNING.WANDA_AGE_THRESHOLD_OLD then
                become_old(inst, true)
            else
                become_normal(inst, silent)
            end
        end
    elseif health <= TUNING.WANDA_AGE_THRESHOLD_OLD then
        become_old(inst, silent)
    elseif health >= TUNING.WANDA_AGE_THRESHOLD_YOUNG then
        become_young(inst, silent)
    else
        become_normal(inst, silent)
    end
end

local function OnNewStategraphState(inst)
    if inst._wasnomorph ~= inst.sg:HasStateTag("nomorph") then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            OnHealthDelta(inst) -- Update state
        end
    end
end

local function OnBecomeHuman(inst, data, isloading)
    inst.age_state = nil
    OnHealthDelta(inst, nil, true)

    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("newstate", OnNewStategraphState)

    inst.components.health.redirect = redirect_to_oldager
    inst.components.health.canheal = false

    if inst.components.positionalwarp then
        if not isloading then
            inst.components.positionalwarp:Reset()
        end
        if inst.components.inventory:FindItem(function(item) return item.prefab == "pocketwatch_warp" end) then
            inst.components.positionalwarp:EnableMarker(true)
        end
    end

    -- Update animation and UI
    inst:DoTaskInTime(0, inst.UpdateBuild, GetBuild(inst), false)
    inst:DoTaskInTime(0, function(inst)
        inst:PushEvent("healthdelta", {
            newpercent = inst.components.health:GetPercent(),
            oldpercent = inst.components.health:GetPercent(),
            overtime = true,
        }) 
    end)
end

local function OnDeath(inst, data)
    inst._wasnomorph = nil
    inst.talksoundoverride = nil
    inst.hurtsoundoverride = nil

    inst.age_state = "old"

    inst:RemoveEventCallback("healthdelta", OnHealthDelta)
    inst:RemoveEventCallback("newstate", OnNewStategraphState)

    if inst.components.positionalwarp then
        inst.components.positionalwarp:EnableMarker(false)
    end
end

local function OnGetItem(inst, data)
    local item = data ~= nil and data.item or nil

    if item ~= nil and item:HasTag("pocketwatch") then
        item:AddTag("nosteal") 
    end
end

local function OnLoseItem(inst, data)
    local item = data ~= nil and (data.prev_item or data.item)
    if item and item:IsValid() and item:HasTag("pocketwatch") then
        item.components.inventoryitem.keepondeath = false
        item:RemoveTag("nosteal")
    end
end

local function OnShowWarpMarker(inst)
    inst.components.positionalwarp:EnableMarker(true)
end

local function OnHideWarpMarker(inst)
    inst.components.positionalwarp:EnableMarker(false)
end

local function DelayedWarpBackTalker(inst)
    -- if the player starts moving right away then we can skip this
    if inst.sg == nil or inst.sg:HasStateTag("idle") then 
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_POCKETWATCH_RECALL"))
    end 
end

local function OnWarpBack(inst, data)
    if inst.components.positionalwarp then
        if data and data.reset_warp then
            inst.components.positionalwarp:Reset()
            inst:DoTaskInTime(15 * FRAMES, DelayedWarpBackTalker) 
        else
            inst.components.positionalwarp:GetHistoryPosition(true)
        end
    end
end

local function OnLivingArtifactOn(inst, data)
    OnDeath(inst, data)
    inst:StopUpdatingComponent(inst.components.oldager)
    inst.isironlord = true
end

local function OnLivingArtifactOff(inst, data)
    inst:AddComponent("worker")
    inst:StartUpdatingComponent(inst.components.oldager)
    inst.isironlord = false
    OnBecomeHuman(inst, nil, false)
end

local function OnSave(inst, data)
    if inst.recall then
        data.recall = {}
        data.recall.x = inst.recall.x
        data.recall.y = inst.recall.y
        data.recall.z = inst.recall.z
    end
    data.isironlord = inst.isironlord
end

local function OnLoad(inst, data, isloading)
    if data.recall then
        inst:DoTaskInTime(0, inst.Transform:SetPosition(data.recall.x, data.recall.y, data.recall.z))
    end

    if not data.isironlord then
        OnBecomeHuman(inst, nil, true)
    end
end

-- prefab function

local function fn(inst)
	inst:AddTag("clockmaker")
	inst:AddTag("pocketwatchcaster")
	inst:AddTag("health_as_oldage")

    local override_builds =
    {
        "player_idles_wanda",
        "wanda_attack,",
        "wanda_basics",
        "wanda_casting",
        "wanda_casting2",
        "wanda_mount_basics",
        "wanda_mount_casting2"
    }
    for _,v in pairs(override_builds) do inst.AnimState:AddOverrideBuild(v) end

    inst.MiniMapEntity:SetIcon("wanda.tex")

	inst.CreateHealthBadge = WandaAgeBadge

    inst.UpdateBuild = UpdateBuild -- mods

	inst.customidleanim = "idle_wanda"
    inst.talker_path_override = "wanda2/characters/" 
    inst.deathanimoverride = "death_wanda"

	inst:AddComponent("oldager")
	inst.components.oldager:AddValidHealingCause("pocketwatch_heal")
	inst.components.oldager:AddValidHealingCause("oldager_component")
    inst.components.oldager:AddValidHealingCause("debug_key")

	inst:AddComponent("positionalwarp") 
	inst:DoTaskInTime(0, function() inst.components.positionalwarp:SetMarker("pocketwatch_warp_marker") end)

    inst:AddComponent("staffsanity")
    inst:AddComponent("worker")

    inst.components.health:SetMaxHealth(TUNING.WANDA_OLDAGER)
    inst.components.health.canheal = false
    inst.components.health.disable_penalty = true
    inst.components.health.redirect = redirect_to_oldager
    inst.components.health.currenthealth = TUNING.WANDA_OLDAGER * 0.7 -- Starting health
    inst.components.hunger:SetMax(TUNING.WANDA_HUNGER)
    inst.components.sanity:SetMax(TUNING.WANDA_SANITY)

    inst:DoTaskInTime(0, function(inst)
        inst.components.foodaffinity:SetPrefabAffinity("taffy", TUNING.AFFINITY_15_CALORIES_MED)
    end)

    inst.components.combat.onhitotherfn = ShadowWeaponFx
    inst.components.combat.GetCustomModifier = GetCustomModifier

    local clocksmithytab = {str = "CLOCKMAKER", sort = 999, icon = "clocksmithy.tex", icon_atlas = "images/hud/clocksmithy.xml"}
    inst.components.builder:AddRecipeTab(clocksmithytab)

    Recipe("pocketwatch_dismantler", {Ingredient("goldnugget", 1), Ingredient("flint", 1), Ingredient("twigs", 3)},
        clocksmithytab, TECH.NONE) 
    if SaveGameIndex:IsModePorkland() then
        Recipe("pocketwatch_parts",      {Ingredient("pocketwatch_dismantler", 0), Ingredient("alloy", 2), Ingredient("nightmarefuel", 2)},
            clocksmithytab, TECH.SCIENCE_TWO)
        Recipe("pocketwatch_heal",       {Ingredient("pocketwatch_parts", 1), Ingredient("iron", 4), Ingredient("redgem", 1)},
            clocksmithytab, TECH.NONE) -- HAM has no marble   
        Recipe("pocketwatch_warp",       {Ingredient("pocketwatch_parts", 1), Ingredient("goldnugget", 2)},
            clocksmithytab, TECH.NONE)
        Recipe("pocketwatch_recall",     {Ingredient("pocketwatch_parts", 2), Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1)}, 
            clocksmithytab, TECH.MAGIC_TWO)
        Recipe("pocketwatch_weapon",     {Ingredient("pocketwatch_parts", 3), Ingredient("iron", 6), Ingredient("nightmarefuel", 8)},   
            clocksmithytab, TECH.MAGIC_THREE) -- HAM has no marble
    elseif SaveGameIndex:IsModeShipwrecked() then
        Recipe("pocketwatch_parts",      {Ingredient("pocketwatch_dismantler", 0), Ingredient("obsidian", 2), Ingredient("nightmarefuel", 2)},
            clocksmithytab, TECH.NONE,     RECIPE_GAME_TYPE.SHIPWREKCED)
        Recipe("pocketwatch_heal",       {Ingredient("pocketwatch_parts", 1), Ingredient("limestone", 2), Ingredient("redgem", 1)},
            clocksmithytab, TECH.NONE, RECIPE_GAME_TYPE.SHIPWREKCED) -- SW has no marble
        Recipe("pocketwatch_warp",       {Ingredient("pocketwatch_parts", 1), Ingredient("goldnugget", 2)},
            clocksmithytab, TECH.NONE)
        Recipe("pocketwatch_recall",     {Ingredient("pocketwatch_parts", 2), Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1)}, 
            clocksmithytab, TECH.MAGIC_TWO)
        Recipe("pocketwatch_weapon",     {Ingredient("pocketwatch_parts", 3), Ingredient("limestone", 4), Ingredient("nightmarefuel", 8)},   
            clocksmithytab, TECH.MAGIC_THREE, RECIPE_GAME_TYPE.SHIPWREKCED) -- SW has no marble
    else
        Recipe("pocketwatch_parts",      {Ingredient("pocketwatch_dismantler", 0), Ingredient("thulecite_pieces", 8), Ingredient("nightmarefuel", 2)},
        clocksmithytab, TECH.NONE)
        Recipe("pocketwatch_heal",       {Ingredient("pocketwatch_parts", 1), Ingredient("marble", 2), Ingredient("redgem", 1)},
            clocksmithytab, TECH.NONE)
        Recipe("pocketwatch_warp",       {Ingredient("pocketwatch_parts", 1), Ingredient("goldnugget", 2)},
            clocksmithytab, TECH.NONE)
        Recipe("pocketwatch_recall",     {Ingredient("pocketwatch_parts", 2), Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1)}, 
            clocksmithytab, TECH.MAGIC_TWO)
        Recipe("pocketwatch_weapon",     {Ingredient("pocketwatch_parts", 3), Ingredient("marble", 4), Ingredient("nightmarefuel", 8)},   
            clocksmithytab, TECH.MAGIC_THREE)
    end

    -- event listeners
	inst:ListenForEvent("show_warp_marker", OnShowWarpMarker)
	inst:ListenForEvent("hide_warp_marker", OnHideWarpMarker)
    inst:ListenForEvent("onwarpback", OnWarpBack)

	inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("equip", OnGetItem)
    inst:ListenForEvent("itemlose", OnLoseItem)
    inst:ListenForEvent("unequip", OnLoseItem)

    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("respawn", OnBecomeHuman)

    inst:ListenForEvent("livingartifactoveron", OnLivingArtifactOn)
    inst:ListenForEvent("livingartifactoveroff", OnLivingArtifactOff)

    local onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if onsave then
            onsave(inst, data)
        end
        return OnSave(inst, data)
    end

    local onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if onload then
            onload(inst, data)
        end
        OnLoad(inst, data)
    end
end

return  MakePlayerCharacter("wanda", prefabs, assets, fn, starting_inventory)
