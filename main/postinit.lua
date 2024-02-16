local component_postinits = {
    "builder",
    "edible",
    "eater",
    "combat",
    "driver",
    "health",
    "workable",
}


local prefab_postinits = {
    "amulet",
    "player",
    "resurrectionstatue",
    "shadow_item",
    "skeleton_player",
    "staff",
    "waterdrop",
}

local sim_postinits = {
    "saveindex",
}

local stategraph_postinits = {
    "wilson",
    "wilsonboating"
}

local widget_postinits = {
    "itemtile",
    "statusdisplay",
}

for _, component_postinit in pairs(component_postinits) do
    modimport("postinit/components/" .. component_postinit ..  ".lua")
end

for _, prefab_postinit in pairs(prefab_postinits) do
    modimport("postinit/prefabs/" .. prefab_postinit .. ".lua")
end

for _, sim_posinit in pairs(sim_postinits) do
    modimport("postinit/sim/" .. sim_posinit .. ".lua")
end

for _, stategraph_postinit in pairs(stategraph_postinits) do
    modimport("postinit/stategraphs/SG" .. stategraph_postinit .. ".lua")
end

for _, widget_postinit in pairs(widget_postinits) do
    modimport("postinit/widgets/" .. widget_postinit .. ".lua")
end
