
name = ChooseTranslationTable({"[DST]Wanda", zh= "[DST]旺达"})
description = ChooseTranslationTable({[[Wanda from Don't Starve Together]], zh= [[饥荒联机版的旺达]]}) 
author = "ziwbi"


api_version = 6
version = "2.1.0"
priority = 10

configuration_options = {
    {
        name = "timer",
        label = ChooseTranslationTable({"Show CD", zh = "显示冷却"}),
        hover = ChooseTranslationTable({"Show pocket watches' cool down", zh = "显示怀表的冷却时间"}),
        options = 
        {
            {description = ChooseTranslationTable({"Yes", zh = "是"}), data = true},
            {description = ChooseTranslationTable({"No", zh = "否"}), data = false},
        },
        default = false,
    },
    -- {
    --     name = "name",
    --     label = ChooseTranslationTable({"Named watches", zh = "溯源表命名"}),
    --     hover = ChooseTranslationTable({"Use feather pencil to name backtrek watch", zh = "用羽毛笔给溯源表命名"}),
    --     options = 
    --     {
    --         {description = ChooseTranslationTable({"Yes", zh = "是"}), data = true},
    --         {description = ChooseTranslationTable({"No", zh = "否"}), data = false},
    --     },
    --     default = false,
    -- },
}

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

forumthread = ""