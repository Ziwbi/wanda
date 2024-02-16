local Badge = require "widgets/dstbadge"
local UIAnim = require "widgets/uianim"

local function OnEffigyDeactivated(inst)
    if inst.AnimState:IsCurrentAnimation("effigy_deactivate") then
        inst.widget:Hide()
    end
end

local OldAgeBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "status_oldage", owner, { .8, .8, .8, 1 }, nil, nil, nil, true)

    self.rate_time = 0
    self.warning_precent = 0.1

    self.health_precent = 1

    self.year_hand = self.underNumber:AddChild(UIAnim())
    self.year_hand:GetAnimState():SetBank("status_oldage")
    self.year_hand:GetAnimState():SetBuild("status_oldage")
    self.year_hand:GetAnimState():PlayAnimation("year")
    --self.year_hand:GetAnimState():AnimateWhilePaused(false)

    self.days_hand = self.underNumber:AddChild(UIAnim())
    self.days_hand:GetAnimState():SetBank("status_oldage")
    self.days_hand:GetAnimState():SetBuild("status_oldage")
    self.days_hand:GetAnimState():PlayAnimation("day")
    --self.days_hand:GetAnimState():AnimateWhilePaused(false)

    self.effigyanim = self.underNumber:AddChild(UIAnim())
    self.effigyanim:GetAnimState():SetBank("status_health")
    self.effigyanim:GetAnimState():SetBuild("status_health")
    self.effigyanim:GetAnimState():PlayAnimation("effigy_deactivate")
    self.effigyanim:Hide()
    self.effigyanim:SetClickable(false)
    --self.effigyanim:GetAnimState():AnimateWhilePaused(false)
    self.effigyanim.inst:ListenForEvent("animover", OnEffigyDeactivated)
    self.effigy = false
    self.effigybreaksound = nil

    for _, mod_actual_name in pairs(KnownModIndex:GetModsToLoad()) do
        if KnownModIndex:GetModFancyName(mod_actual_name) == "Combined Status" then
            self.effigyanim:SetPosition(45, 50)
            break
        end
    end

    self:StartUpdating()
    self.healthpenalty = 0

    GetPlayer():ListenForEvent("effigy_activate", function()
        if not next(SaveGameIndex.resurrection_statues) then return end
        self:ShowEffigy()
    end)
    GetPlayer():ListenForEvent("effigy_deactivate", function()
        if next(SaveGameIndex.resurrection_statues) then return end
        self:HideEffigy()
    end)

    self.inst:DoTaskInTime(1, function()
        self:ShowEffigy()
    end)
end)


function OldAgeBadge:ShowEffigy()
    if not self.effigy then
        self.effigy = true
        self.effigyanim:GetAnimState():PlayAnimation("effigy_activate")
        self.effigyanim:GetAnimState():PushAnimation("effigy_idle", false)
        self.effigyanim:Show()
    end
end

function OldAgeBadge:HideEffigy()
    if self.effigy then
        self.effigy = false
        self.effigyanim:GetAnimState():PlayAnimation("effigy_deactivate")
        if self.effigyanim.inst.task ~= nil then
            self.effigyanim.inst.task:Cancel()
        end
    end
end

function OldAgeBadge:SetPercent(val, max, penaltypercent)
    local age_precent = 1 - val
    local age = TUNING.WANDA_MIN_YEARS_OLD + age_precent * (TUNING.WANDA_MAX_YEARS_OLD - TUNING.WANDA_MIN_YEARS_OLD)
    
    self.health_precent = val

    self.num:SetString(tostring(math.floor(age + 0.5)))

    local badge_max = TUNING.WANDA_MAX_YEARS_OLD - TUNING.WANDA_MIN_YEARS_OLD

    self.year_hand:SetRotation( Lerp(0, 360, age_precent) )
end

function OldAgeBadge:OnUpdate(dt)
    if IsPaused() then return end

    self.days_hand:SetRotation(Lerp(0, 360, self.owner.components.oldager.year_timer))
end

function OldAgeBadge:PulseColor(r, g, b, a)
    self.pulse:GetAnimState():SetMultColour(r, g, b, a)
    self.pulse:GetAnimState():PlayAnimation("on")
    self.pulse:GetAnimState():PushAnimation("on_loop", true)
end

function OldAgeBadge:PulseGreen()
    self:PulseColor(0, 1, 0, 1)
end

function OldAgeBadge:PulseRed()
    self:PulseColor(1, 0, 0, 1)
end

function OldAgeBadge:PulseOff()
    self.pulse:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("off")
    self.pulse:GetAnimState():PushAnimation("idle")
    TheFrontEnd:GetSound():KillSound("pulse_loop")
    self.playing_pulse_loop = nil
    self.pulsing = nil
end

function OldAgeBadge:Pulse(color)
    local frontend_sound = TheFrontEnd:GetSound()
    
    if color == "green" then
        self:PulseGreen()
        frontend_sound:KillSound("pulse_loop")
        frontend_sound:PlaySound("wanda2/characters/wanda/up_health_LP", "pulse_loop")
        self.playing_pulse_loop = "up"
        frontend_sound:PlaySound("dontstarve/HUD/health_up") -- this?
    else
        self:PulseRed()
        frontend_sound:KillSound("pulse_loop")
        self.playing_pulse_loop = "down"
        frontend_sound:PlaySound("wanda2/characters/wanda/down_health_LP", "pulse_loop")

        local volume = self.owner.player_classified:GetOldagerRate() > 0 and 1
                    or self.health_precent <= TUNING.WANDA_AGE_THRESHOLD_OLD and 1 
                    or self.health_precent < TUNING.WANDA_AGE_THRESHOLD_YOUNG and 0.65
                    or 0.4
        frontend_sound:PlaySound("dontstarve/HUD/health_down", nil, volume)
    end

    self.pulsing = color
end

function OldAgeBadge:HealthDelta(data)
    
    local oldpenalty = self.healthpenalty
    local health = self.owner.components.health
    self.healthpenalty = health:GetPenaltyPercent()

    self:SetPercent(data.newpercent, health:Max(), self.healthpenalty)

    local should_pulse = nil

    if oldpenalty > self.healthpenalty or data.newpercent > data.oldpercent then
        should_pulse = "green"
    elseif oldpenalty < self.healthpenalty or data.newpercent < data.oldpercent then
        should_pulse = "red"
    end

    if should_pulse then
        if self.pulsing ~= nil then
            if should_pulse == self.pulsing then
                if self.turnofftask ~= nil then
                    self.turnofftask:Cancel()
                    self.turnofftask = nil
                end
            else
                if self.turnofftask ~= nil then
                    self.turnofftask:Cancel()
                    self.turnofftask = nil
                end
                self:Pulse(should_pulse)
            end
        else
            self:Pulse(should_pulse)
        end

        self.turnofftask = self.inst:DoTaskInTime(0.25, function() self:PulseOff() end)
    else
        if self.turnofftask ~= nil then
            self.turnofftask:Cancel()
            self.turnofftask = nil
        end
        self:PulseOff()
    end
end

return OldAgeBadge
