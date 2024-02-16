GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local actionhandlers = 
{
    ActionHandler(ACTIONS.CAST_POCKETWATCH, 
        function(inst, action)
            return action.invobject ~= nil and "pocketwatch_cast"
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
                inst.AnimState:OverrideSymbol("boat", inst.components.driver.vehicle.components.drivable.overridebuild,"rowboat")
                --inst.AnimState:AddOverrideBuild(inst.components.driver.vehicle.components.drivable.overridebuild)
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
            inst.components.driver:SplitFromVehicle() 
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

        onexit = function(inst)
            inst.components.driver:CombineWithVehicle()
        end
    }),

    State({
        name = "pocketwatch_cast",
        tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.driver:SplitFromVehicle()            
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
            inst.components.driver:CombineWithVehicle()

            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    }),

    State{
        name = "attack_whip",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            inst.components.driver:SplitFromVehicle()

            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period

            if equip ~= nil and equip:HasTag("pocketwatch") then
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
            end


            inst.sg:SetTimeout(cooldown)


            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
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
            TimeEvent(17*FRAMES, function(inst)
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
            inst.components.driver:CombineWithVehicle()
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat.laststartattacktime = nil 
            end
        end,
    },

    State({
        name = "funnyidle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()

            if inst.components.temperature:GetCurrent() < 5 then
                inst.AnimState:PlayAnimation("idle_shiver_pre")
                inst.AnimState:PushAnimation("idle_shiver_loop")
                inst.AnimState:PushAnimation("idle_shiver_pst", false)
            elseif inst.components.hunger:GetPercent() < _G.TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")    
            elseif inst.components.sanity:GetPercent() < .5 then
                inst.AnimState:PlayAnimation("idle_inaction_sanity")
            elseif inst.customidleanim ~= nil then
                inst.components.driver:SplitFromVehicle() 
                inst.AnimState:PlayAnimation(inst.customidleanim)
            else
                inst.AnimState:PlayAnimation("idle_inaction")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },

        onexit = function(inst)
            inst.components.driver:CombineWithVehicle()
        end,
    }),                       
}

for k,v in ipairs(states) do
    AddStategraphState("wilsonboating", v)
end
for k,v in ipairs(events) do
    AddStategraphEvent("wilsonboating", v)
end
for k,v in ipairs(actionhandlers) do
    AddStategraphActionHandler("wilsonboating", v)
end

AddStategraphPostInit("wilsonboating", function(sg)
    local row_start = sg.states.row_start
    if row_start ~= nil then
        local _onenter = row_start.onenter
        row_start.onenter = function(inst)
            inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")
            _onenter(inst)
        end
    end       
end)
