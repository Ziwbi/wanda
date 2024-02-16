-- Gives characters a hugner bonus from eating a specific item or footype
-- Note: Those bonuses are percentage bonus that multiplies
local FoodAffinity = Class(function(self, inst)
    self.inst = inst
    self.tag_affinities = {}
    self.prefab_affinities = {}
    self.foodtype_affinities = {}
end)

function FoodAffinity:SortAffinitiesByBonus(affinities)
    table.sort(affinities, function(a,b) return a.hunger_bonus > b.hunger_bonus end)
end

function FoodAffinity:SetTagAffinity(tag, bonus)
    self.tag_affinities[tag] = bonus
end

function FoodAffinity:SetPrefabAffinity(prefab, bonus)
    self.prefab_affinities[prefab] = bonus
end

function FoodAffinity:SetFoodtypeAffinity(foodtype, bonus)
    self.foodtype_affinities[foodtype] = bonus
end

function FoodAffinity:RemoveTagAffinity(tag)
    self.tag_affinities[tag] = nil
end

function FoodAffinity:RemovePrefabAffinity(prefab)
    self.prefab_affinities[prefab] = nil
end

function FoodAffinity:RemoveFoodtypeAffinity(foodtype)
    self.foodtype_affinities[foodtype] = nil
end

function FoodAffinity:HasAffinity(food)
    if self:HasPrefabAffinity(food) then
        return true
    end

    if food.components.edible and self.foodtype_affinities[food.components.edible.foodtype] then
        return true
    end

    for tag, bonus in pairs(self.tag_affinities) do
        if food:HasTag(tag) then
            return true
        end
    end
end

function FoodAffinity:HasPrefabAffinity(food)
    return self.prefab_affinities[food.prefab] ~= nil
end

function FoodAffinity:GetAffinity(food)
    local found_affinities = {}

    if self.prefab_affinities[food.prefab] then
        table.insert(found_affinities, self.prefab_affinities[food.prefab])
    end

    local prefabaffinity = self.prefab_affinities[food.prefab]
    if prefabaffinity then
        table.insert(found_affinities, prefabaffinity)
    end

    if food.components.edible and self.foodtype_affinities[food.components.edible.foodtype] then
        table.insert(found_affinities, self.foodtype_affinities[food.components.edible.foodtype])
    end

    for tag, bonus in pairs(self.tag_affinities) do
        if food:HasTag(tag) then
            table.insert(found_affinities, bonus)
        end
    end

    if #found_affinities > 0 then
        if #found_affinities > 1 then
            -- Sort the found_affinities so we return the biggest bonus
            table.sort(found_affinities, function(a, b) return a > b end)
        end
        return found_affinities[1]
    end
end

return FoodAffinity