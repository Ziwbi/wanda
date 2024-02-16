GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local function FinalOffset1(inst)
    inst.AnimState:SetFinalOffset(1)
end

local function FinalOffsetNegative1(inst)
    inst.AnimState:SetFinalOffset(-1)
end

local function GroundOrientation(inst)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local wanda_fx = 
{
    {
        name = "oldager_become_younger_front_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "younger_top",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "oldager_become_younger_back_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "younger_bottom",
        nofaced = true,
        fn = FinalOffsetNegative1,
    },
    {
        name = "oldager_become_older_fx",
        bank = "wanda_time_fx",
        build = "wanda_time_fx",
        anim = "older",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "oldager_become_younger_front_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "younger_top",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "oldager_become_younger_back_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "younger_bottom",
        nofaced = true,
        fn = FinalOffsetNegative1,
    },
    {
        name = "oldager_become_older_fx_mount",
        bank = "wanda_time_fx_mount",
        build = "wanda_time_fx_mount",
        anim = "older",
        nofaced = true,
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_pocketwatch_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = {"idle_big_1", "idle_big_2", "idle_big_3"},
        sound = "wanda2/characters/wanda/watch/weapon/shadow_hit_old",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_pocketwatch_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = {"idle_med_1", "idle_med_2", "idle_med_3"},
        sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_shadowweapon_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = {"idle_big_1", "idle_big_2", "idle_big_3"},
        sound = "wanda2/characters/wanda/watch/weapon/shadow_hit",
        fn = function(inst)
			inst.AnimState:Hide("white")
			inst.AnimState:SetFinalOffset(1)
		end,
    },
    {
        name = "wanda_attack_shadowweapon_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = {"idle_med_1", "idle_med_2", "idle_med_3"},
        sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    },
	{
        name = "pocketwatch_heal_fx",
        bank = "pocketwatch_cast_fx",
        build = "pocketwatch_casting_fx",
        anim = "pocketwatch_heal_fx", --NOTE: 16 blank frames at the start for audio syncing
        fn = FinalOffset1,
        bloom = true,
    },
	{
        name = "pocketwatch_heal_fx_mount",
        bank = "pocketwatch_casting_fx_mount",
        build = "pocketwatch_casting_fx_mount",
        anim = "pocketwatch_heal_fx", --NOTE: 16 blank frames at the start for audio syncing
        fn = FinalOffset1,
        bloom = true,
    },
	{
        name = "pocketwatch_ground_fx",
        bank = "pocketwatch_cast_fx",
        build = "pocketwatch_casting_fx",
        anim = "pocketwatch_ground", --NOTE: 16 blank frames at the start for audio syncing
        fn = GroundOrientation,
        bloom = true,
    },
    {
        name = "shadow_puff_solid",
        bank = "sand_puff",
        build = "sand_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
        end,
    },
}

local fx = require("fx")
for _,v in pairs(wanda_fx) do -- This could be optimised
    table.insert(fx, v)
end