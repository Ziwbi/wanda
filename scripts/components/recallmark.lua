local RecallMark = Class(function(self, inst)
    self.inst = inst

	inst:AddTag("recall_unmarked")
end)

function RecallMark:MarkPosition(recall_x, recall_y, recall_z, recall_level_mode, cavenum, cavelevel, slot, iteration)
	if recall_x ~= nil then
		self.recall_x = recall_x or 0
		self.recall_y = recall_y or 0
		self.recall_z = recall_z or 0
		self.inst:RemoveTag("recall_unmarked")

		self.save_slot = slot or SaveGameIndex.current_slot -- this will always be current_slot
		self.level_mode = recall_level_mode or SaveGameIndex:GetCurrentMode()
		self.level_iteration = iteration or SaveGameIndex:GetSlotWorld(self.save_slot) -- Increases after using teleportato
		if self.level_mode == "cave" then
			self.cavenum = cavenum or SaveGameIndex:GetCurrentCaveNum()
			self.cavelevel = cavelevel or SaveGameIndex:GetCurrentCaveLevel(self.save_slot, self.cavenum)
		end
	end

	if self.onMarkPosition ~= nil then
		self.onMarkPosition(self.inst, recall_x, recall_y, recall_z, recall_level_mode)
	end
end

function RecallMark:Copy(rhs)
	rhs = rhs ~= nil and rhs.components.recallmark
	if rhs then
		self:MarkPosition(rhs.recall_x, rhs.recall_y, rhs.recall_z, rhs.level_mode, rhs.cavenum, rhs.cavelevel)
	end
end

function RecallMark:IsMarked()
	return self.level_mode ~= nil
end

function RecallMark:IsTargetLevelRegenerated()
	local target_level_iteration = SaveGameIndex.data.slots[self.save_slot or SaveGameIndex.current_slot].modes[self.level_mode].world or 1
    return self.level_iteration ~= target_level_iteration
end

function RecallMark:IsMarkedForSameShard()
	local is_same = self.level_mode == SaveGameIndex:GetCurrentMode()
	if self.level_mode == "cave" then
		if is_same then
			return self.cavenum == SaveGameIndex:GetCurrentCaveNum() and self.cavelevel == SaveGameIndex:GetCurrentCaveLevel()
		end
	end
	return is_same
end

function RecallMark:GetMarkedPosition()
	if self:IsMarkedForSameShard() then
		return self.recall_x, self.recall_y, self.recall_z
	end

	return nil
end

function RecallMark:OnSave()
	return {
		recall_x = self.recall_x,
		recall_y = self.recall_y,
		recall_z = self.recall_z,
		recall_level_mode = self.level_mode,
		cavenum = self.cavenum,
		cavelevel = self.cavelevel,
		slot = self.save_slot,
		iteration = self.level_iteration
	}
end

function RecallMark:OnLoad(data)
	if data and data.recall_level_mode then
		self:MarkPosition(data.recall_x, data.recall_y, data.recall_z, data.recall_level_mode, data.cavenum, data.cavelevel, data.slot, data.iteration)
	end
end

return RecallMark