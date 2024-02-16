GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

-- This one is actually not a post init function
-- Because it have to be called pre init

SaveIndex.resurrection_statues = {}
local RegisterResurrector = SaveIndex.RegisterResurrector
function SaveIndex:RegisterResurrector(res, penalty)
    if res.prefab == "resurrectionstatue" then
        self.resurrection_statues[res.GUID] = true
    end
    return RegisterResurrector(self, res, penalty)
end

local DeregisterResurrector = SaveIndex.DeregisterResurrector
function SaveIndex:DeregisterResurrector(res)
    self.resurrection_statues[res.GUID] = nil
    return DeregisterResurrector(self, res)
end
