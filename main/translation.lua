GLOBAL.setfenv(1, GLOBAL)
require("translator")

-- Join multiline strings in a po file, return array of joined strings
local function JoinPOFileMultilineStrings(fname)
    local lines = {}
    local workline = ""
    local started = false
    for i in io.lines(fname) do
        -- skip the header
        if i:sub(1,1) == "#" then
            started = true
        end
        -- if our buffer ands with '"' and current line starts with '"' 
        if started and workline:sub(-1) == '"' and i:sub(1,1)=='"' then
            -- append, stripping out end and start quotes
            workline = workline:sub(1,-2)..i:sub(2)
        else
            -- otherwise, flush it
            lines[#lines+1] = workline
            workline = i        
        end 
    end
    -- flush what we had left
    lines[#lines+1] = workline
    return lines
end

-- Join multiline strings in a po file, return iterator returning one (joined) line at a time
local function JoinPOFileMultiline(fname)
    local i = 0
    local lines = JoinPOFileMultilineStrings(fname)
    return function()
          i = i + 1
          if i > #lines then return nil
          else return lines[i] end
    end
end 

function Translator:JoinPoFile(fname, lang) -- appends translation, instead of overriding all translations
    local strings = self.languages[lang] or {}
    print("Translator:JoinPoFile - concatenating file: "..resolvefilepath(fname))
    local file = io.open(resolvefilepath(fname))
    if not file then print("Translator:JoinPoFile - Specified language file "..fname.." not found.") return end

    local newformat_flag = false
    local current_id = false
    local current_str = ""
    local msgstr_flag = false

    for line in JoinPOFileMultiline(resolvefilepath(fname)) do

        --Skip lines until find an id using new format
        if newformat_flag and not current_id then
            local sidx, eidx, c1, c2 = string.find(line, "^msgctxt(%s*)\"(%S*)\"")
            if c2 then
                current_id = c2
            end
        --Skip lines until find an id using old format (reference field)
        elseif not newformat_flag and not current_id then
            local sidx, eidx, c1, c2 = string.find(line, "^%#%:(%s*)(%S*)")
            if c2 then
                current_id = c2
             end
        --Gather up parts of translated text (since POedit breaks it up into 80 char strings)
        elseif msgstr_flag then
            local sidx, eidx, c1, c2 = string.find(line, "^(%s*)\"(.*)\"")
            --Found blank line or next entry (assumes blank line after each entry or at least a #. line)
            if not c2 then
                --Store translated text if provided
                if current_str ~= "" then
                    strings[current_id] = self:ConvertEscapeCharactersToRaw(current_str)
                end
                msgstr_flag = false
                current_str = ""
                current_id = false
            --Combine text with previously gathered text
            else
                current_str = current_str..c2
            end
        --Have id, so look for translated text
        elseif current_id then
            local sidx, eidx, c1, c2 = string.find(line, "^msgstr(%s*)\"(.*)\"")
            --Found multi-line entry so flag to gather it up
            if c2 and c2 == "" then
                msgstr_flag = true
            --Found translated text so store it
            elseif c2 then
                strings[current_id] = self:ConvertEscapeCharactersToRaw(c2)
                current_id = false
            end
        else
            --skip line
        end

        --Search for new format field if not already found
        if not newformat_flag then
            if string.find(line, "POT Version: 2.0", 0, true)
                or string.find(line, "X-Generator: Poedit", 0, true) then --Assume that Poedit is generating the new format files with msgctxt
                newformat_flag = true
            end
        end

    end

    file:close()
    self.languages[lang] = strings
end

LanguageTranslator:JoinPoFile("scripts/languages/wanda_s.po", "zh")
