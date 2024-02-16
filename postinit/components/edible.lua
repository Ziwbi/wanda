GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
local Edible = require("components/edible")

function Edible:GetHunger(eater)
    local multiplier = 1
    local ignore_spoilage = not self.degrades_with_spoilage or self.hungervalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.stale_hunger or self.stale_hunger
        elseif self.inst.components.perishable:IsSpoiled() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.spoiled_hunger or self.spoiled_hunger
        end
    end

    if eater and eater.components.foodaffinity then
        local affinity_bonus = eater.components.foodaffinity:GetAffinity(self.inst)
        if affinity_bonus ~= nil then
            multiplier = multiplier * affinity_bonus
        end
    end

    if eater and eater.components.eater and eater.components.eater.gethungermultfn then
        multiplier = multiplier * eater.components.eater:gethungermultfn(self.inst, self.hungervalue)
    end

    return multiplier * self.hungervalue
end
