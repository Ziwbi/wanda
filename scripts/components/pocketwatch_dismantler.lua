local PocketWatch_Dismantler = Class(function(self, inst)
    self.inst = inst
end)

function PocketWatch_Dismantler:CanDismantle(target, doer)
	if target.components.rechargeable ~= nil and not target.components.rechargeable:IsCharged() then
        return false, "ONCOOLDOWN"
    end
	if not doer:HasTag("clockmaker") then
		return false
	end
    return true
end

local function GetFullRecipeLoot(recipe)
    local loot = {}

    for k,v in ipairs(recipe.ingredients) do
        local amt = v.amount
        for n = 1, amt do
            table.insert(loot, v.type)
        end
    end

    return loot
end

function PocketWatch_Dismantler:Dismantle(target, doer)
    local owner = target.components.inventoryitem:GetGrandOwner()
    local receiver = owner ~= nil and not owner:HasTag("pocketdimension_container") and (owner.components.inventory or owner.components.container) or nil
    local pt = receiver ~= nil and self.inst:GetPosition() or doer:GetPosition()

    local loot = GetFullRecipeLoot(GetAllRecipes()[target.prefab])
    target:Remove() -- We remove the target before giving the loot to make more space in the inventory

    for _, prefab in ipairs(loot) do
		if prefab ~= "nightmarefuel" then
			if receiver ~= nil then
		        receiver:GiveItem(SpawnPrefab(prefab), nil, pt)
			else
				target.components.lootdropper:SpawnLootPrefab(prefab, pt)
			end
		end
    end

    SpawnPrefab("brokentool").Transform:SetPosition(doer.Transform:GetWorldPosition())
end

function PocketWatch_Dismantler:CollectUseActions(doer, target, actions)
    if doer:HasTag("clockmaker") and target:HasTag("pocketwatch") then
        table.insert(actions, ACTIONS.DISMANTLE_POCKETWATCH)
    end
end

return PocketWatch_Dismantler
