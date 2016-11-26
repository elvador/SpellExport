local tinsert = table.insert
local GetSpellInfo, GetSpellDescription = GetSpellInfo, GetSpellDescription
local GetTime = GetTime

local function clearSavedVariables()
  SpellExportDB = nil
  print("SpellExport: SavedVariables cleared.")
end

local function exportSpellIds()
  clearSavedVariables()
  local tbl, count, lastSpellId = {}, 0, 0
  for i=1,400000 do
    if GetSpellInfo(i) then
      local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(i)
      local desc = GetSpellDescription(i)
      tinsert(tbl, spellId..","..name..","..rank..","..icon..","..castTime..","..minRange..","..maxRange..","..desc)
      count = count + 1
      lastSpellId = spellId
    end
  end
  SpellExportDB = tbl
  print(("SpellExport: Exported %d spells, with %d being the last spell id."):format(count, lastSpellId))
end

local function slashCmdHandler(msg)
  if msg == "export" then
    exportSpellIds()
  elseif msg == "clear" then
    clearSavedVariables()
  else
    print("Usage: /spellexport export|clear")
  end
end

SlashCmdList['SPELLEXPORT_SLASHCMD'] = slashCmdHandler
SLASH_SPELLEXPORT_SLASHCMD1 = '/spellexport'
SLASH_SPELLEXPORT_SLASHCMD2 = '/se'

-- grep "\"" SpellExport.lua | cut -d'"' -f2 > SpellData.csv
