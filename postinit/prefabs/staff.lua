GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddPrefabPostInit("greenstaff", function(inst)
    local spelltest = inst.components.spellcaster.spelltest
    inst.components.spellcaster:SetSpellTestFn(function(staff, caster, target)
        if target and target:HasTag("pocketwatch") then
            return not target:HasTag("pocketwatch_inactive") 
        else
            return spelltest and spelltest(staff, caster, target) 
        end
    end)
end)