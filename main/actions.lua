GLOBAL.setfenv(1, GLOBAL)

local function FunctionOrValue(func_or_val, ...)
    if type(func_or_val) == "function" then
        return func_or_val(...)
    end
    return func_or_val
end

CAST_POCKETWATCH = Action({mount_enabled = true}, -1, false, true)
CAST_POCKETWATCH.id = "CAST_POCKETWATCH"
CAST_POCKETWATCH.str = "Cast"
CAST_POCKETWATCH.fn = function(act)
    local caster = act.doer
    if act.invobject and caster and caster:HasTag("pocketwatchcaster") then
        return act.invobject.components.pocketwatch:CastSpell(caster, act.target, act.pos and act.pos:GetPosition() or nil)
    end
end
CAST_POCKETWATCH.strfn = function(act)
    if act.invobject then
        return FunctionOrValue(act.invobject.GetActionVerb_CAST_POCKETWATCH, act.invobject, act.doer, act.target)
    end
end

DISMANTLE_POCKETWATCH = Action({mount_enabled = true}, 0, false, true)
DISMANTLE_POCKETWATCH.id = "DISMANTLE_POCKETWATCH"
DISMANTLE_POCKETWATCH.str = "Dismantle"
DISMANTLE_POCKETWATCH.fn = function(act)
    local can_dismantle, reason = act.invobject.components.pocketwatch_dismantler:CanDismantle(act.target, act.doer)
    if can_dismantle then
        act.invobject.components.pocketwatch_dismantler:Dismantle(act.target, act.doer)
    end
    return can_dismantle, reason
end

AddAction(CAST_POCKETWATCH)
AddAction(DISMANTLE_POCKETWATCH)
