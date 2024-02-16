GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddClassPostConstruct("widgets/statusdisplays", function(widget)
    if widget.owner.CreateHealthBadge ~= nil then 
        widget:RemoveChild(widget.heart)
        widget.heart:Kill()
        widget.heart = widget:AddChild(widget.owner.CreateHealthBadge(widget.owner))
        widget.heart:SetPosition(40,20,0)
    end
end)