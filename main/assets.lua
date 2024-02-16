GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

PrefabFiles = 
{
    "wanda",
    "pocketwatch",
    "pocketwatch_dismantler",
    "pocketwatch_parts",
    "pocketwatch_weapon",
    "staff_castinglight_wanda",
    "staffcastfx_wanda",
}

Assets = 
{
    Asset("IMAGE", "bigportraits/wanda.tex"),
    Asset("ATLAS", "bigportraits/wanda.xml"),
    Asset("IMAGE", "images/saveslot_portraits/wanda.tex"),
    Asset("ATLAS", "images/saveslot_portraits/wanda.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/wanda.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/wanda.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/wanda_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/wanda_silho.xml"),
    Asset("IMAGE", "images/inventoryimages_3.tex"), 
    Asset("ATLAS", "images/inventoryimages_3.xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages_3.xml", 256),  
    Asset("IMAGE", "images/map_icons/wanda.tex"),
    Asset("ATLAS", "images/map_icons/wanda.xml"),
    Asset("ATLAS", "images/hud/clocksmithy.xml"),
    Asset("IMAGE", "images/hud/clocksmithy.tex"),

    Asset("ANIM", "anim/player_actions_useitem.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
    Asset("ANIM", "anim/player_mount_actions_useitem.zip"),
    Asset("ANIM", "anim/pocketwatch.zip"),
    Asset("ANIM", "anim/pocketwatch_marble.zip"),
    Asset("ANIM", "anim/pocketwatch_recall.zip"),
    Asset("ANIM", "anim/pocketwatch_warp_marker.zip"),
    Asset("ANIM", "anim/pocketwatch_warp.zip"),
    Asset("ANIM", "anim/pocketwatch_weapon.zip"),
    Asset("ANIM", "anim/pocketwatch_parts.zip"),
    Asset("ANIM", "anim/pocketwatch_dismantler.zip"),
    Asset("ANIM", "anim/pocketwatch_warp_casting_fx.zip"),
    Asset("ANIM", "anim/recharge_meter.zip"),
    Asset("ANIM", "anim/status_health.zip"),
    Asset("ANIM", "anim/status_oldage.zip"),
    Asset("ANIM", "anim/swap_paddle.zip"),
    Asset("ANIM", "anim/wanda.zip"),
    Asset("ANIM", "anim/wanda_young.zip"),
    Asset("ANIM", "anim/wanda_old.zip"),
    Asset("ANIM", "anim/wanda_basics.zip"),
    Asset("ANIM", "anim/wanda_mount_basics.zip"),
    Asset("ANIM", "anim/wanda_attack.zip"),
    Asset("ANIM", "anim/wanda_casting.zip"),
    Asset("ANIM", "anim/wanda_casting2.zip"),
    Asset("ANIM", "anim/wanda_mount_casting2.zip"),

    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SCRIPT", "scripts/prefabs/pocketwatch_common.lua"),

    Asset("SOUNDPACKAGE", "sound/wanda2.fev" ),
    Asset("SOUND", "sound/wanda2.fsb" ), 
}

RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_heal.tex")
RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_warp.tex")
RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_recall.tex")
RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_weapon.tex")
RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_parts.tex")
RegisterInventoryItemAtlas("images/inventoryimages_3.xml", "pocketwatch_dismantler.tex")