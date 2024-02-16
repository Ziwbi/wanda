GLOBAL.setfenv(1, GLOBAL)
local Workable = require("components/workable")

local _WorkedBy = Workable.WorkedBy
function Workable:WorkedBy(worker, numworks)
    if worker.prefab == "wanda" and self:GetWorkAction() == ACTIONS.HAMMER then
        numworks = (numworks or 1) * (worker.components.worker and worker.components.worker:GetEffectiveness(ACTIONS.HAMMER) or 1)
    end
    return _WorkedBy(self, worker, numworks)
end
