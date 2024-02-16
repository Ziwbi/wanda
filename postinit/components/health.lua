GLOBAL.setfenv(1, GLOBAL)
local Health = require("components/health")

-- TODO fix sound
function Health:DoDelta(amount, overtime, cause, ignore_invincible)
    if self.inst.isironlord then
        return
    end

    local old_percent = self:GetPercent()

    if self.redirect and self.redirect(self.inst, amount, overtime, cause, ignore_invincible) then
        return 0
    elseif not ignore_invincible and (self:IsInvincible() or self.inst.is_teleporting) then
        return 0
    elseif amount < 0 then
        amount = amount * math.clamp(1 - self.absorb, 0, 1)
    end

    self:SetVal(self.currenthealth + amount, cause)

    self.inst:PushEvent("healthdelta", { oldpercent = old_percent, newpercent = self:GetPercent(), overtime = overtime, cause = cause, amount = amount })

    if self.ondelta then
        self.ondelta(self.inst, old_percent, self:GetPercent(), overtime, cause, nil, amount)
    end
    return amount
end

local penalty_fn = Health.RecalculatePenalty
function Health:RecalculatePenalty()
    if not self.disable_penalty then
        penalty_fn(self)
    else
        self.penalty = 0
        self:DoDelta(0, nil, "resurrection_penalty")
    end
end

local function destroy(inst)
    local time_to_erode = 1
    local tick_time = TheSim:GetTickTime()

    if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

    inst:StartThread( function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
            ticks = ticks + 1
            Yield()
        end
        inst:Remove()
    end)
end
function Health:SetPercent(percent, cause, overtime)
    self:SetVal(self.maxhealth * percent, cause)
    self:DoDelta(0, overtime, cause, true, nil, true)
end

function Health:SetVal(val, cause)
    local old_health = self.currenthealth
    local max_health = self:GetMaxHealth()
    local min_health = math.min(self.minhealth or 0, max_health)

    if val > max_health then
        val = max_health
    end

    if val <= min_health then
        self.currenthealth = min_health
        self.inst:PushEvent("minhealth", {cause = cause})
    else
        self.currenthealth = val
    end

    if old_health > 0 and self.currenthealth <= 0 or self:GetMaxHealth() <= 0 then
        self.inst:PushEvent("death", {cause = cause})
        GetWorld():PushEvent("entity_death", {inst = self.inst, cause = cause,})


        if not self.nofadeout then
            self.inst:AddTag("NOCLICK")
            self.inst.persists = false
            self.inst:DoTaskInTime(self.destroytime or 2, destroy)
        end
    end
end

local respwan = Health.Respawn
function Health:Respawn(health)
    if self.inst.prefab ~= "wanda" then
        return respwan(self, health)
    end

    health = health and health * TUNING.OLDAGE_HEALTH_SCALE or 10
    self:SetPercent(health/self:GetMaxHealth())
    self.inst:PushEvent( "respawn", {} )
    self.inst:DoTaskInTime(0, function(inst)
        inst:PushEvent("healthdelta", {
            newpercent = health/self:GetMaxHealth(),
            oldpercent = 0,
            overtime = false,
        })
    end)
end
