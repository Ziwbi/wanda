GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
if not IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(PORKLAND_DLC) then
    return
end

local Driver = require("components/driver")

local _OnUpdate = Driver.OnUpdate
function Driver:OnUpdate(dt)
    _OnUpdate(self, dt)
    if not self.inst.prefab == "wanda" then return end
    if self.vehicle and self.vehicle:IsValid() then
        local CameraRight = TheCamera:GetRightVec()
        local CameraDown = TheCamera:GetDownVec()

        local myPos = self.inst:GetPosition()
        local displacement = CameraRight:Cross(CameraDown) * 0.035

        local pos = myPos - displacement

        self.vehicle.Transform:SetPosition(pos:Get())
    end
end

