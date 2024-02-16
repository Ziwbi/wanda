GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ItemTile = require("widgets/itemtile")

local actual_name = LOC.GetLocaleCode() == "zh" and "[DST]旺达" or "[DST]Wanda"
local should_display_timer = GetModConfigData("timer", modname) -- KnownModIndex:GetModActualName(actual_name))

-----Cooldown Display-----
function ItemTile:UpdateTimer()
    if not ItemTile.recharge_timer then return end

    local time_left = math.ceil(ItemTile.rechargetime * (1 - ItemTile.rechargepct))
    if time_left <= 0 then
        ItemTile.recharge_timer:SetString("")
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
    ItemTile.recharge_timer:SetString(string.format("%02d:%02d", minutes_left, seconds_left))
end

function ItemTile:SetChargePercent(percent)
    local prev_precent = ItemTile.rechargepct
    ItemTile.rechargepct = percent
    if ItemTile.recharge.shown then
        if percent < 1 then
            ItemTile.recharge:GetAnimState():SetPercent("recharge", percent)
            if not ItemTile.rechargeframe.shown then
                ItemTile.rechargeframe:Show()
            end
            if percent >= 0.9999 then
                ItemTile:StopUpdatingCharge()
            elseif ItemTile.rechargetime < math.huge then
                ItemTile:StartUpdatingCharge()
            end
        else
            if prev_precent < 1 and not ItemTile.recharge:GetAnimState():IsCurrentAnimation("frame_pst") then
                ItemTile.recharge:GetAnimState():PlayAnimation("frame_pst")
            end
            if ItemTile.rechargeframe.shown then
                ItemTile.rechargeframe:Hide()
            end
            ItemTile:StopUpdatingCharge()
        end
    end
    ItemTile:UpdateTimer()
end

function ItemTile:SetChargeTime(t)
    ItemTile.rechargetime = t
    if ItemTile.rechargetime >= math.huge then
        ItemTile:StopUpdatingCharge()
    elseif ItemTile.rechargepct < .9999 then
        ItemTile:StartUpdatingCharge()
    end
    ItemTile:UpdateTimer()
end

local function _StartUpdating(ItemTile, flag)
    if next(ItemTile.updatingflags) == nil then
        ItemTile:StartUpdating()
    end
    ItemTile.updatingflags[flag] = true
end

local function _StopUpdating(ItemTile, flag)
    ItemTile.updatingflags[flag] = nil
    if next(ItemTile.updatingflags) == nil then
        ItemTile:StopUpdating()
    end
end

function ItemTile:StartUpdatingCharge()
    _StartUpdating(ItemTile, "charge")
end

function ItemTile:StopUpdatingCharge()
    _StopUpdating(ItemTile, "charge")
end

local _StartDrag = ItemTile.StartDrag
function ItemTile:StartDrag()
    if ItemTile.recharge then
        ItemTile.recharge:Hide()
        ItemTile.rechargeframe:Hide()
        ItemTile:StopUpdating()
    end
    _StartDrag(ItemTile)
end

local _OnUpdate = ItemTile.OnUpdate
function ItemTile:OnUpdate(dt)
    if self.updatingflags.charge and not GLOBAL.IsPaused() then
        self:SetChargePercent(self.rechargetime > 0 and self.rechargepct + dt / self.rechargetime or .9999)
    end
    if _OnUpdate ~= nil then
        _OnUpdate(ItemTile, dt)
    end
end

function ItemTile:Refresh()
    if ItemTile.rechargeframe ~= nil and ItemTile.item.components.rechargeable ~= nil then
        ItemTile:SetChargePercent(ItemTile.item.components.rechargeable:GetPercent())
        ItemTile:SetChargeTime(ItemTile.item.components.rechargeable:GetRechargeTime())
    end
end

ItemTile.updatingflags = {}

if ItemTile.item:HasTag("rechargeable") then
    ItemTile.rechargepct = 1
    ItemTile.rechargetime = math.huge
    ItemTile.rechargeframe = ItemTile:AddChild(UIAnim())
    ItemTile.rechargeframe:GetAnimState():SetBank("recharge_meter")
    ItemTile.rechargeframe:GetAnimState():SetBuild("recharge_meter")
    ItemTile.rechargeframe:GetAnimState():PlayAnimation("frame")

    if should_display_timer then
        ItemTile.recharge_timer = ItemTile:AddChild(Text(NUMBERFONT, 42))
        ItemTile.recharge_timer:SetPosition(5, -17, 0)
        ItemTile.recharge_timer:SetString("")
    end
end

if ItemTile.rechargeframe then
    ItemTile.recharge = ItemTile:AddChild(UIAnim())
    ItemTile.recharge:GetAnimState():SetBank("recharge_meter")
    ItemTile.recharge:GetAnimState():SetBuild("recharge_meter")
    ItemTile.recharge:GetAnimState():SetMultColour(0, 0, 0.4, 0.64)
    ItemTile.recharge:SetClickable(false)
end

if ItemTile.rechargeframe then
    ItemTile.inst:ListenForEvent("rechargechange",
        function(invitem, data)
            ItemTile:SetChargePercent(data.percent)
        end, ItemTile.item)

    ItemTile.inst:ListenForEvent("rechargetimechange",
        function(invitem, data)
            ItemTile:SetChargeTime(data.t)
        end, ItemTile.item)
end

-- Update UI
ItemTile:Refresh()
