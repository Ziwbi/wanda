GLOBAL.setfenv(1, GLOBAL)
local Combat = require("components/combat")

local CalcDamage = Combat.CalcDamage
function Combat:CalcDamage(target, weapon, multiplier)
    local custom_multiplier = self.GetCustomModifier and self:GetCustomModifier(target, weapon, multiplier) or 1
    multiplier = multiplier and multiplier * custom_multiplier or custom_multiplier
    return CalcDamage(self, target, weapon, multiplier)
end

