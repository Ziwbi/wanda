local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

-- AddPrefabPostInit("living_artifact", function(inst)
--     local turnonfn = inst.components.machine.turnonfn
--     inst.components.machine.turnonfn = function(inst)
--         turnonfn(inst)
--         GetPlayer().isironhulk = true
--     end

--     local BecomeIronLord_post = inst.BecomeIronLord_post
--     inst.BecomeIronLord_post = function(inst)
--         local oldager = GetPlayer().components.oldager 
--         if oldager then
--             print("StopUpdatingComponent")
--             oldager.inst:StopUpdatingComponent(oldager)
--         end
--         BecomeIronLord_post(inst)
--         GetPlayer().isironhulk = true
--     end

--     local _Revert = inst.Revert
--     inst.Revert = function(inst)
--         local oldager = GetPlayer().components.oldager 
--         if oldager then
--             oldager.inst:StartUpdatingComponent(oldager)
--         end
--         _Revert(inst)
--         GetPlayer().isironhulk = false
--     end
-- end)
