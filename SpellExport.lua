
-- luacheck: globals SpellExportDB

local tinsert, tconcat, tsort = table.insert, table.concat, table.sort
local max = math.max
local GetSpellInfo, GetSpellDescription = GetSpellInfo, GetSpellDescription
local GetTime = GetTime
local NewTicker = C_Timer.NewTicker
local CTimerAfter = C_Timer.After

local spellData = {}
local tryAgainSpells = {}
local updateTicker, retryTimer = nil, nil
local eventFrame = CreateFrame("Frame")
local lastSpellUpdate = 0

local function p(...)
	print("|cffffaa00SpellExport|r:", ...)
end

local function formatValue(v)
  if not v then return "" end
  if type(v) == "number" then return v end
  return ("~~%s~~"):format(v)
end

local function clearSavedVariables()
	SpellExportDB = nil
	p("SavedVariables cleared.")
end

local function saveSpellData(id, isRetry)
	if not DoesSpellExist(id) then
		tryAgainSpells[id] = nil
		return true
	end
	local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(id)
	if not spellId then
		tryAgainSpells[id] = nil
		return true
	end
	local desc = GetSpellDescription(id)

	if name ~= "" and (desc ~= "" or isRetry) then
		tryAgainSpells[spellId] = nil
		spellData[spellId] = {
			formatValue(name),
			formatValue(rank),
			formatValue(icon),
			formatValue(castTime),
			formatValue(minRange),
			formatValue(maxRange),
			formatValue(desc),
		}
		return true
	else
		local count = (tryAgainSpells[spellId] or 0) + 1

		if count >= 3 and isRetry then
			print(("Giving up after %d"):format(count), " | name:", name,  " | desc:", desc, " | spellId:", spellId, " | isRetry:", isRetry)
			tryAgainSpells[spellId] = nil
		else
			tryAgainSpells[spellId] = count
		end
	end
end

local function retrySpellIds()
	if GetTime()-lastSpellUpdate < 0.5 then
		p("Still receiving spell name updates, please wait before retrying.")
		return
	end

	local count = 0
	for id,_ in pairs(tryAgainSpells) do
		count = count + 1
		if count < 1001 then
			saveSpellData(id, true)
		end
	end

	p(count >= 1000 and ("Retried 1000/%d spells"):format(count) or ("Retried %d spells"):format(count))
	
	if count > 0 then
		CTimerAfter(1, retrySpellIds)
	else
		PlaySound(73280, "MASTER") -- UI_ORDERHALL_TALENT_READY_TOAST
	end
end

local requestSpellIds

local function checkForLastSpellUpdate()
	if GetTime()-lastSpellUpdate > 1 then
		p("|cff00ff00Requesting new spells")
		requestSpellIds()
	end
end

local lastId = 1
function requestSpellIds()
	local failedCount = 0
	p(("|cffffaa00Starting with spell id %d"):format(lastId))
	for i=lastId,500000 do
		if not saveSpellData(i) then
			failedCount = failedCount + 1
			if failedCount > 1000 then
				if not updateTicker then
					updateTicker = NewTicker(0.5, checkForLastSpellUpdate)
				end
				lastId = i
				p(("|cffffff00Stopped requesting after %d fails at spell id %d"):format(1000, lastId))
				break
			end
		end
		if i == 500000 then
			if updateTicker then
				updateTicker:Cancel()
				updateTicker = nil
			end
			p("Done")
			PlaySound(73280, "MASTER") -- UI_ORDERHALL_TALENT_READY_TOAST
			retrySpellIds()
		end
	end
end

local function exportSpellDataTable()
	clearSavedVariables()
	local tbl, idTbl, count, lastSpellId = {}, {}, 0, 0
	for spellId, data in pairs(spellData) do
		tinsert(idTbl, spellId)
		count = count + 1
		lastSpellId = max(lastSpellId, spellId)
	end
	tsort(idTbl)
	for _, spellId in pairs(idTbl) do
		tinsert(tbl, spellId..","..tconcat(spellData[spellId], ","))
	end
	SpellExportDB = tbl
	local wowVersion, buildNr = GetBuildInfo()
	local isPtr = IsTestBuild() and "PTR" or "live"
	p(("Exported |cff00aaff%d|r spells, with |cff00aaff%d|r being the last spell id. Build info: |cff00aaff%s %d (%s)|r"):format(count, lastSpellId, wowVersion, buildNr, isPtr))
end

eventFrame:RegisterEvent("SPELL_TEXT_UPDATE")
local function eventHandler(self, event, eventId, eventName, ...)
	if event == "SPELL_TEXT_UPDATE" then
		lastSpellUpdate = GetTime()
		saveSpellData(eventId)
	end
end
eventFrame:SetScript("OnEvent", eventHandler)

local function slashCmdHandler(msg)
	if msg == "request" then
		requestSpellIds()
	elseif msg == "retry" then
		retrySpellIds()
	elseif msg == "export" then
		exportSpellDataTable()
	elseif msg == "clear" then
		clearSavedVariables()
	else
		p("Usage: /spellexport < request | retry | export | clear >")
	end
end

SlashCmdList['SPELLEXPORT_SLASHCMD'] = slashCmdHandler
SLASH_SPELLEXPORT_SLASHCMD1 = '/spellexport'
SLASH_SPELLEXPORT_SLASHCMD2 = '/se'

-- grep "\"" SpellExport.lua | sed -e 's/^\s\"//g' | sed -e "s/\", -- \[.*$//g" | sed -e 's/\\"/""/g' | sed -e 's/~~/\"/g'  > SpellData.csv
