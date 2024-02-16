--- TODO: use dir function

local components = {
    "builder",
    "edible",
    "eater",
    "combat",
    "driver",
    "health",
    "workable",
}

for _, component in pairs(components) do
    modimport(string.format("postinit/components/%s.lua", component))
end

local prefabs = {
    "amulet",
    "living_artifact",
    "player",
    "resurrectionstatue",
    "shadow_item",
    "skeleton_player",
    "staff",
    "waterdrop",
}

for _, prefab in pairs(prefabs) do
    modimport(string.format("postinit/prefabs/%s.lua", prefab))
end

local sim_postinits = {
    "saveindex",
}

for _, sim_posinit in pairs(sim_postinits) do
    modimport(string.format("postinit/sim/%s.lua", sim_posinit))
end

local stategraphs = {
    "wilson",
    "wilsonboating"
}

for _, stategraph in pairs(stategraphs) do
    modimport(string.format("postinit/stategraphs/SG%s.lua", stategraph))
end

local widgets = {
    "itemtile",
    "statusdisplay",
}

for _, widget in pairs(widgets) do
    modimport(string.format("postinit/widgets/%s.lua", widget))
end
