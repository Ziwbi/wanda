GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ItemTile = require("widgets/itemtile")

local should_display_timer = GetModConfigData("timer", modname)

-----Cooldown Display-----
function ItemTile:UpdateTimer()
    if not self.recharge_timer then return end

    local time_left = math.ceil(self.rechargetime * (1 - self.rechargepct))
    if time_left <= 0 then
        self.recharge_timer:SetString("")
        return
    end

    local minutes_left = 0
    local seconds_left = 0
    if time_left < 60 then
        seconds_left = time_left
    else
        minutes_left = math.floor(time_left/60)
        seconds_left = math.floor(time_left - minutes_left * 60)
    end
    self.recharge_timer:SetString(string.format("%02d:%02d", minutes_left, seconds_left))
end

function ItemTile:SetChargePercent(percent)
    local prev_precent = self.rechargepct
    self.rechargepct = percent
    if self.recharge.shown then
        if percent < 1 then
            self.recharge:GetAnimState():SetPercent("recharge", percent)
            if not self.rechargeframe.shown then
                self.rechargeframe:Show()
            end
            if percent >= 0.9999 then
                self:StopUpdatingCharge()
            elseif self.rechargetime < math.huge then
                self:StartUpdatingCharge()
            end
        else
            if prev_precent < 1 and not self.recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
                self.recharge:GetAnimState():PlayAnimation("frame_pst")
            end
            if self.rechargeframe.shown then
                self.rechargeframe:Hide()
            end
            self:StopUpdatingCharge()
        end
    end
    self:UpdateTimer()
end

function ItemTile:SetChargeTime(t)
    self.rechargetime = t
    if self.rechargetime >= math.huge then
        self:StopUpdatingCharge()
    elseif self.rechargepct < .9999 then
        self:StartUpdatingCharge()
    end
    self:UpdateTimer()
end

local function _StartUpdating(_ItemTile, flag)
    if next(_ItemTile.updatingflags) == nil then
        _ItemTile:StartUpdating()
    end
    _ItemTile.updatingflags[flag] = true
end

local function _StopUpdating(_ItemTile, flag)
    _ItemTile.updatingflags[flag] = nil
    if next(_ItemTile.updatingflags) == nil then
        _ItemTile:StopUpdating()
    end
end

function ItemTile:StartUpdatingCharge()
    _StartUpdating(self, "charge")
end

function ItemTile:StopUpdatingCharge()
    _StopUpdating(self, "charge")
end

local _StartDrag = ItemTile.StartDrag
function ItemTile:StartDrag()
    if self.recharge then
        self.recharge:Hide()
        self.rechargeframe:Hide()
        self:StopUpdating()
    end
    _StartDrag(self)
end

local _OnUpdate = ItemTile.OnUpdate
function ItemTile:OnUpdate(dt)
    if self.updatingflags.charge and not GLOBAL.IsPaused() then
        self:SetChargePercent(self.rechargetime > 0 and self.rechargepct + dt / self.rechargetime or .9999)
    end
    if _OnUpdate ~= nil then
        _OnUpdate(self, dt)
    end
end

function ItemTile:Refresh()
    if self.rechargeframe ~= nil and self.item.components.rechargeable ~= nil then
        self:SetChargePercent(self.item.components.rechargeable:GetPercent())
        self:SetChargeTime(self.item.components.rechargeable:GetRechargeTime())
    end
end

ItemTile.updatingflags = {}

AddClassPostConstruct("widgets/itemtile", function(self)
    if self.item:HasTag("rechargeable") then
        self.rechargepct = 1
        self.rechargetime = math.huge
        self.rechargeframe = self:AddChild(UIAnim())
        self.rechargeframe:GetAnimState():SetBank("recharge_meter")
        self.rechargeframe:GetAnimState():SetBuild("recharge_meter")
        self.rechargeframe:GetAnimState():PlayAnimation("frame")

        if should_display_timer then
            self.recharge_timer = self:AddChild(Text(NUMBERFONT, 42))
            self.recharge_timer:SetPosition(5, -17, 0)
            self.recharge_timer:SetString("")
        end
    end

    if self.rechargeframe then
        self.recharge = self:AddChild(UIAnim())
        self.recharge:GetAnimState():SetBank("recharge_meter")
        self.recharge:GetAnimState():SetBuild("recharge_meter")
        self.recharge:GetAnimState():SetMultColour(0, 0, 0.4, 0.64)
        self.recharge:SetClickable(false)
    end

    if self.rechargeframe then
        self.inst:ListenForEvent("rechargechange",
            function(invitem, data)
                self:SetChargePercent(data.percent)
            end, self.item)

        self.inst:ListenForEvent("rechargetimechange",
            function(invitem, data)
                self:SetChargeTime(data.t)
            end, self.item)
    end

    -- Update UI
    self:Refresh()
end)
