GLOBAL.setfenv(1, GLOBAL)
local Builder = require("components/builder")
-- For Time Pieces

function Builder:CanBuild(recipe)
    if self.freebuildmode then
        return true
    end

    if type(recipe) == "string" then
        recipe = GetRecipe(recipe)
    end

    if recipe then
        if recipe.ingredients then
            for ik, iv in pairs(recipe.ingredients) do
                local amt = math.max(1, RoundUp(iv.amount * self.ingredientmod))
                if iv.type == "oinc" then
                    if self.inst.components.shopper:GetMoney(self.inst.components.inventory) < amt then
                        return false
                    end
                else
                    if not self.inst.components.inventory:Has(iv.type, amt, true) then
                        return false
                    end
                end
            end
        end

        if recipe.character_ingredients then
            for i, v in ipairs(recipe.character_ingredients) do
                if not self:HasCharacterIngredient(v) then
                    return false
                end
            end
        end

        return true
    end

    return false
end

function Builder:GetIngredients(recname)
    local recipe = GetRecipe(recname)
    if not recipe then
        return
    end

    local ingredients = {}
    for k, v in pairs(recipe.ingredients) do
        if v.amount > 0 then
            if v.type == "oinc" then
                local amount = math.max(1, RoundUp(v.amount * self.ingredientmod))
                ingredients[v.type] = amount
            else
                local amount = math.max(1, RoundUp(v.amount * self.ingredientmod))
                local items = self.inst.components.inventory:GetCraftingIngredient(v.type, amount)
                ingredients[v.type] = items
            end
        end
    end

    return ingredients
end

function Builder:RemoveIngredients(ingredients, recname)
    if self.freebuildmode then
        return
    end

    for item, ents in pairs(ingredients) do
        if item == "oinc" then
            self.inst.components.shopper:PayMoney(self.inst.components.inventory, ents)
        else
            for k,v in pairs(ents) do
                for i = 1, v do
                    self.inst.components.inventory:RemoveItem(k, false, true):Remove()
                end
            end
        end
    end

    local recipe = GetAllRecipes()[recname]
    if recipe then
        for k,v in pairs(recipe.character_ingredients) do
            if v.type == CHARACTER_INGREDIENT.HEALTH then
                local delta = math.min(math.max(0, self.inst.components.health.currenthealth - 1), v.amount)
                self.inst:PushEvent("consumehealthcost")
                self.inst.components.health:DoDelta(-delta, false, "builder", true, nil, true)
            elseif v.type == CHARACTER_INGREDIENT.MAX_HEALTH then
                self.inst:PushEvent("consumehealthcost")
                self.inst.components.health:DeltaPenalty(v.amount)
            elseif v.type == CHARACTER_INGREDIENT.SANITY then
                self.inst.components.sanity:DoDelta(-v.amount)
            elseif v.type == CHARACTER_INGREDIENT.MAX_SANITY then
                --[[
                    Because we don't have any maxsanity restoring items we want to be more careful
                    with how we remove max sanity. Because of that, this is not handled here.
                    Removal of sanity is actually managed by the entity that is created.
                    See maxwell's pet leash on spawn and pet on death functions for examples.
                --]]
            end
        end
    end
    self.inst:PushEvent("consumeingredients")
end
