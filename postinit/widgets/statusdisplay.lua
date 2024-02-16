GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddClassPostConstruct("widgets/statusdisplays", function(self)
    if self.owner.CreateHealthBadge then
        self:RemoveChild(self.heart)
        self.heart:Kill()
        self.heart = self:AddChild(self.owner.CreateHealthBadge(self.owner))
        self.heart:SetPosition(40,20,0)
    end
end)