
local function oninactive(self, inactive)
    if inactive then
        self.inst:AddTag("pocketwatch_inactive")
    else
        self.inst:RemoveTag("pocketwatch_inactive")
    end
end

local PocketWatch = Class(function(self, inst)
    self.inst = inst

	self.inactive = true
end,
nil,
{
    inactive = oninactive,
})

function PocketWatch:OnRemoveFromEntity()
    self.inst:RemoveTag("pocketwatch_inactive")
end

function PocketWatch:CanCast(doer, target, pos)
	return self.inactive and (self.CanCastFn == nil or self.CanCastFn(self.inst, doer, target, pos))
end

function PocketWatch:CastSpell(doer, target, pos)
	if self.DoCastSpell ~= nil and self.inactive then
		local success, reason = self.DoCastSpell(self.inst, doer, target, pos)
		return success, reason
	end
	return false
end

function PocketWatch:CollectInventoryActions(doer, actions)
    local target = self.inst
    if target:HasTag("pocketwatch_inactive") and doer:HasTag("pocketwatchcaster") then
        if     ((doer.components.rider ~= nil  and doer.components.rider:IsRiding())      and not target:HasTag("pocketwatch_mountedcast"))
            or ((doer.components.driver ~= nil and doer.components.driver:GetIsDriving()) and not target:HasTag("pocketwatch_mountedcast"))
            or (GetWorld().components.interiorspawner ~= nil and GetWorld().components.interiorspawner:IsInInterior() and target:HasTag("nointerior")) then
            return 
        end

        
        table.insert(actions, ACTIONS.CAST_POCKETWATCH)
    end
end

return PocketWatch
