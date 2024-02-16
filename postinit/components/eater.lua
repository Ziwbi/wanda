GLOBAL.setfenv(1, GLOBAL)
local Eater = require("components/eater")

function Eater:DoFoodEffects(food)
    return not ((food:HasTag("monstermeat")
            and (self.inst:HasTag("player") and self.monsterimmune or self.strongstomach))
            or self.inst.components.foodaffinity and self.inst.components.foodaffinity:HasPrefabAffinity(food))
end

function Eater:Eat( food )
    if not self:CanEat(food) then return end

    local stack_mult = self.eatwholestack and food.components.stackable and food.components.stackable:StackSize() or 1

    local health_delta = 0
    local hunger_delta = 0
    local sanity_delta = 0

    if self.inst.components.health and not self.inst:HasTag("donthealfromfood") then
        if (food.components.edible.healthvalue >= 0 or self:DoFoodEffects(food)) then
            health_delta = food.components.edible:GetHealth(self.inst) * self.healthabsorption
        end
    end

    if self.inst.components.health and not self.inst:HasTag("donthealfromfood") then
        if (food.components.edible.healthvalue < 0 and self:DoFoodEffects(food) or food.components.edible.healthvalue > 0) and self.inst.components.health then
            local delta = food.components.edible:GetHealth(self.inst) * self.healthabsorption
            self.inst.components.health:DoDelta(delta* stack_mult, nil, food.prefab)
        end
    end

    if self.inst.components.hunger then
        hunger_delta = food.components.edible:GetHunger(self.inst) * self.hungerabsorption
    end

    if self.inst.components.sanity and (food.components.edible.sanityvalue >= 0 or self:DoFoodEffects(food)) then
        sanity_delta = food.components.edible:GetSanity(self.inst) * self.sanityabsorption
    end

    if self.custom_stats_mod_fn ~= nil then
        health_delta, hunger_delta, sanity_delta = self.custom_stats_mod_fn(self.inst, health_delta, hunger_delta, sanity_delta, food, feeder)
    end

    if health_delta ~= 0 then
        self.inst.components.health:DoDelta(health_delta * stack_mult, nil, food.prefab)
    end
    if hunger_delta ~= 0 then
        self.inst.components.hunger:DoDelta(hunger_delta * stack_mult)
    end
    if sanity_delta ~= 0 then
        self.inst.components.sanity:DoDelta(sanity_delta * stack_mult)
    end

    if self.inst.components.poisonable and self.inst.components.poisonable:IsPoisoned() and food.components.poisonhealer then
        food.components.poisonhealer:Cure(self.inst)
    end

    local naughtyvalue = food.components.edible.GetNaughtiness and food.components.edible:GetNaughtiness(self.inst) or 0
    if naughtyvalue > 0 and self.inst.components.kramped then
        self.inst.components.kramped:OnNaughtyAction(naughtyvalue)
    end

    self.inst:PushEvent("oneat", {food = food})
    if self.oneatfn then
        self.oneatfn(self.inst, food)
    end

    if food.components.edible then
        food.components.edible:OnEaten(self.inst)
    end

    if food.components.stackable and food.components.stackable.stacksize > 1 and not self.eatwholestack then
        food.components.stackable:Get():Remove()
    else
        food:Remove()
    end

    self.lasteattime = GetTime()

    self.inst:PushEvent("oneatsomething", {food = food})

    return true
end
