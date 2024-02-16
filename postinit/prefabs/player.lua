GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddPlayerPostInit(function(inst)
    inst:AddComponent("foodaffinity")
end)