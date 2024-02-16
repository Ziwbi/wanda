GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
modimport("scripts/vecutil.lua") -- TODO

-- http://lua-users.org/wiki/CopyTable
local function shallowcopy(orig, dest)
    local copy
    if type(orig) == 'table' then
        copy = dest or {}
        for k, v in pairs(orig) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    if IsDLCEnabled(PORKLAND_DLC) then
        inst.Physics:CollidesWith(GetWorldCollision())
        inst.Physics:CollidesWith(GetWaterCollision())
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.WAVES)
        inst.Physics:CollidesWith(COLLISION.INTWALL)
    elseif IsDLCEnabled(CAPY_DLC) then
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.WAVES)
    else
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    end
end

local function TravelToLevel(inst, warpback_data, dest_worldid, recallmark, dropitems_tag)
    SetPause(false)

    -- drop irreplacables 
    if dropitems_tag ~= nil and type(dropitems_tag) == "string" then
        local itemlist = inst.components.inventory:FindItems(function(item) return item:HasTag(dropitems_tag) end)
        for i, item in pairs(itemlist) do
            local owner = item.components.inventoryitem:GetContainer()
            if owner then
                owner:DropItem(item)
            end
        end
    end

    local function onentered()
        SetPause(true)
        StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
        GetWorld():DoTaskInTime(0, function() GetPlayer().components.autosaver:DoSave() end)
    end

    local function onstartnextmode()
        SaveGameIndex:SaveCurrent(function()
            SaveGameIndex:EnterWorld(dest_worldid, onentered, recallmark.save_slot, recallmark.cavenum, recallmark.cavelevel, nil)
        end, nil, recallmark.cavenum)
    end

    -- An ugly solution to EnterWorld not having a player position option
    inst.recall = {x=warpback_data.dest_x, y=warpback_data.dest_y, z=warpback_data.dest_z}
    inst.HUD:Hide()
    inst:PushEvent("dropontravel")
    GetWorld():DoTaskInTime(0, function()
        TheFrontEnd:Fade(false, 3, function() onstartnextmode() end)
    end)
end


local actionhandlers =
{
    ActionHandler(ACTIONS.CAST_POCKETWATCH,
        function(inst, action)
            return action.invobject ~= nil
                and action.invobject:HasTag("recall_unmarked") and "dolongaction" or
                    action.invobject:HasTag("pocketwatch_warp_casting") and "pocketwatch_warpback_pre"
                or "pocketwatch_cast"
        end),

    ActionHandler(ACTIONS.DISMANTLE_POCKETWATCH, "dolongaction"),

    ActionHandler(ACTIONS.BUILD,
        function(inst, action)
            if action.recipe and action.recipe == "livinglog" and action.doer and action.doer.prefab == "wormwood" then
                return "form_log"
            elseif inst:HasTag("slowbuilder") then
                return "dolongestaction"
            else
                return "dolongaction"
            end
        end),
}

local events =
{
    EventHandler("becomeyounger_wanda",
        function(inst)
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("becomeyounger_wanda")
            end
        end),

    EventHandler("becomeolder_wanda",
        function(inst)
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("becomeolder_wanda")
            end
        end),

    EventHandler("doattack", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if weapon and weapon:HasTag("goggles") then
                inst.sg:GoToState("goggleattack")
            elseif weapon and weapon:HasTag("blowdart") then
                inst.sg:GoToState("blowdart")
            elseif weapon and weapon:HasTag("thrown") then
                inst.sg:GoToState("throw")
            elseif weapon and weapon:HasTag("pocketwatch") then
                inst.sg:GoToState("attack_whip")
            else
                inst.sg:GoToState("attack")
            end
        end
    end)
}

local states =
{
    State({
        name = "dolongestaction",
        onenter = function(inst)
            inst.sg:GoToState("dolongaction", TUNING.LONGEST_ACTION_TIMEOUT)
        end,
    }),

    State({
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.last_death_position = inst:GetPosition()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
        end,
    }),

    State({
        name = "becomeyounger_wanda",
        tags = { "nomorph" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("wanda_young")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }),

    State({
        name = "becomeolder_wanda",
        tags = { "nomorph", "nodangle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("wanda_old")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }),

    State({
        name = "pocketwatch_cast",
        tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_cast", false)
            inst.AnimState:PushAnimation("useitem_pst", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst.AnimState:OverrideSymbol("watchprop", buffaction.invobject.build, "watchprop")
                inst.sg.statemem.castfxcolour = buffaction.invobject.castfxcolour
                inst.sg.statemem.pocketwatch = buffaction.invobject
                inst.sg.statemem.target = buffaction.target
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                local pocketwatch = inst.sg.statemem.pocketwatch
                if pocketwatch ~= nil and pocketwatch:IsValid() and pocketwatch.components.pocketwatch:CanCast(inst, inst.sg.statemem.target) then
                    inst.sg.statemem.stafffx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding()) and "pocketwatch_cast_fx_mount" or "pocketwatch_cast_fx")
                    inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                    inst.sg.statemem.stafffx:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 })
                    -- TODO: Adjust Facing
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/heal")
                end
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.stafffx ~= nil then
                    inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight_small")
                    inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.sg.statemem.stafflight:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 }, 0.75, 0)
                end
            end),
            TimeEvent(25 * FRAMES, function(inst)
                if not inst:PerformBufferedAction() then
                    inst.sg.statemem.action_failed = true
                end
            end),

            --success timeline
            TimeEvent(40 * FRAMES, function(inst)
                if not inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),

            --failed timeline
            TimeEvent(28 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.AnimState:SetPercent("pocketwatch_cast", 34/inst.AnimState:GetCurrentAnimationLength())
                    -- inst.AnimState:SetFrame(34)
                    if inst.sg.statemem.stafffx ~= nil then
                        inst.sg.statemem.stafffx:Remove()
                        inst.sg.statemem.stafffx = nil
                    end
                    if inst.sg.statemem.stafflight ~= nil then
                        inst.sg.statemem.stafflight:Remove()
                        inst.sg.statemem.stafflight = nil
                    end
                end
            end),
            TimeEvent(41 * FRAMES, function(inst)
                if inst.sg.statemem.action_failed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("watchprop")
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    }),

    State({
        name = "pocketwatch_warpback_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp_pre")

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst.AnimState:OverrideSymbol("watchprop", buffaction.invobject.build, "watchprop")

                inst.sg.statemem.castfxcolour = buffaction.invobject.castfxcolour
            end
        end,

        timeline=
        {
            TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/warp") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:PerformBufferedAction() then
                        local data = shallowcopy(inst.sg.statemem)
                        inst.sg.statemem.portaljumping = true
                        inst.sg:GoToState("pocketwatch_warpback", data)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.portaljumping then
                inst.AnimState:ClearOverrideSymbol("watchprop")
            end
        end,
    }),

    State({
        name = "pocketwatch_warpback",
        tags = {"busy", "nodangle", "nomorph", "jumping"},

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp")

            inst.sg.statemem.warpback_data = data.warpback
            inst.sg.statemem.castfxcolour = data.castfxcolour

            inst.sg.statemem.stafffx = SpawnPrefab("pocketwatch_warpback_fx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(data.castfxcolour or { 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),

            TimeEvent(4 * FRAMES, function(inst)
                local warpback_data = inst.sg.statemem.warpback_data
                local x, y, z = inst.Transform:GetWorldPosition()
                if (warpback_data.dest_worldid == nil or warpback_data.dest_worldid == _G.SaveGameIndex:GetCurrentMode()) and VecUtil_DistSq(x, z, warpback_data.dest_x, warpback_data.dest_z) > 30*30 then
                    inst.sg.statemem.snap_camera = true
                    _G.TheFrontEnd:Fade(false, .5)

                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.AnimState:AnimDone() then return end

                if inst.sg.statemem.stafffx ~= nil then
                    inst.sg.statemem.stafffx.entity:SetParent(nil)
                    inst.sg.statemem.stafffx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    inst.sg.statemem.stafffx = nil
                end

                if inst.sg.statemem.snap_camera then
                    inst.sg.statemem.snap_camera = nil
                    inst.sg.statemem.queued_snap_camera = true
                end

                local data = shallowcopy(inst.sg.statemem)
                local warpback_data = data.warpback_data
                local dest_worldid = warpback_data.dest_worldid
                local recallmark = warpback_data.recallmark
                inst.sg.statemem.portaljumping = true
                if dest_worldid ~= nil and not recallmark:IsMarkedForSameShard() then
                    if _G.SaveGameIndex:HasWorld(recallmark.save_slot, recallmark.level_mode) then
                        inst:StartThread(function()
                            inst.components.autosaver:DoSave()
                            TravelToLevel(inst, warpback_data, dest_worldid, recallmark, "irreplaceable")
                        end)

                    else
                        warpback_data.dest_x, warpback_data.dest_y, warpback_data.dest_z = inst.Transform:GetWorldPosition()
                        inst.sg:GoToState("pocketwatch_warpback_pst", data)
                    end
                else
                    inst.sg:GoToState("pocketwatch_warpback_pst", data)
                end

            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.snap_camera then
                inst:StartThread(function()
                    _G.TheCamera:SetCustomLocation(_G.Point(warpback_data.dest_x, warpback_data.dest_y, warpback_data.dest_z))
                    _G.Sleep(.5)
                    _G.TheFrontEnd:Fade(true, .5)
                end)

            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if not inst.sg.statemem.portaljumping then
                inst.AnimState:ClearOverrideSymbol("watchprop")
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
            end
        end,
    }),

    State({
        name = "pocketwatch_warpback_pst",
        tags = {"busy", "nomorph", "noattack", "nointerrupt", "jumping"},

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("pocketwatch_warp_pst")

            if data.queued_snap_camera then
                inst:StartThread(function()
                    _G.TheCamera:SetDefault()
                    _G.Sleep(.5)
                    _G.TheFrontEnd:Fade(true, .5)
                end)
            end

            if data.warpback_data ~= nil then
                inst.Physics:Teleport(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
            end
            inst:PushEvent("onwarpback", data.warpback_data)

            local fx = SpawnPrefab("pocketwatch_warpbackout_fx")
            fx.Transform:SetPosition(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
            fx:SetUp(data.castfxcolour or { 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/recall")
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("jumping")
                inst.sg:RemoveStateTag("nomorph")
                inst.sg:RemoveStateTag("nointerrupt")
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:AddStateTag("idle")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("watchprop")
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    }),

    State({
        name = "attack_whip",
        tags = {"attack", "notalking", "abouttoattack"},

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
            end

            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period

            if equip and equip:HasTag("pocketwatch") then
                inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
                inst.AnimState:PushAnimation("pocketwatch_atk", false)
                inst.sg.statemem.ispocketwatch = true
                cooldown = math.max(cooldown, 15 * FRAMES)
                if equip:HasTag("shadow_item") then
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
                    inst.AnimState:Show("pocketwatch_weapon_fx")
                    inst.sg.statemem.ispocketwatch_fueled = true
                else
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
                    inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 24 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.ispocketwatch then
                    local target = inst.components.combat.target
                    inst.components.combat:DoAttack(target)
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.ispocketwatch then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat.laststartattacktime = nil
            end
        end,
    }),

    State({
        name = "funnyidle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            if inst.components.temperature:GetCurrent() < 5 then
                inst.AnimState:PlayAnimation("idle_shiver_pre")
                inst.AnimState:PushAnimation("idle_shiver_loop")
                inst.AnimState:PushAnimation("idle_shiver_pst", false)
            elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst.components.sanity:GetPercent() < .5 then
                inst.AnimState:PlayAnimation("idle_inaction_sanity")
            else
                inst.AnimState:PlayAnimation(inst.customidleanim or "idle_inaction")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        }
    }),
}

for k, v in ipairs(states) do
    AddStategraphState("wilson", v)
end
for k, v in ipairs(events) do
    AddStategraphEvent("wilson", v)
end
for k, v in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilson", v)
end
