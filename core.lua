-- $Id: core.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local addons = {
	--[[ Adding a set:
				Use the format:
						["setname"] = { "Addon Name", "Another_Addon" }, --]]
	--[[---------------------------------------------------------------------------
								   -=( Base Addons )=-
		---------------------------------------------------------------------------
		These addons will load for every user, always.								--]]
	["base"] = { "!recBug", "oGlow", "oUF", "oUF_Caellian", "oUF_SpellRange", "oUF_WeaponEnchant",
				"recActionBars", "recAddonManager", "recAltInfo", "recBags", "recChat",
				"recChatFilter", "recCombatText", "recConfig", "recCooldowns", "recDamageMeter",
				"recDataFeeds", "recDressUp", "recFoodAndWater", "recMedia", "recMinimap",
				"recMirrorBar", "recNameplates", "recPanels", "recThreatmeter", "recTimers",
				"recTooltip", "recWhispers", "recWorldMap", "RedRange"
	},
	--[[---------------------------------------------------------------------------
							  -=( Class-Specific Addons )=-
		---------------------------------------------------------------------------
		Addons under subtable ["base"] will load for the class always.
		Addons under other subtables will load for the class only when the role is also selected. --]]
	["PRIEST"]		= {
		["base"]	= {  },
		["party"]	= {  },
		["raid"]	= {  },
	},
	["MAGE"]		= {
		["base"]	= {  },
		["party"]	= {  },
		["raid"]	= {  },
	},
	["SHAMAN"]		= {
		["base"]	= { "aTotemBar" },
		["party"]	= {  },
		["raid"]	= {  },
	},
	["PALADIN"]		= {
		["base"]	= { "PallyPower" },
		["party"]	= {  },
		["raid"]	= {  },
	},
	["WARLOCK"] 	= {
		["base"]	= {  },
	},
	["DEATHKNIGHT"]	= {
		["base"]	= { "recRunes" },
	},
	["HUNTER"] 		= {
		["base"]	= {  },
	},
	["ROGUE"] 		= {
		["base"]	= {  },
	},
	["WARRIOR"] 	= {
		["base"]	= {  },
	},
	["DRUID"] 		= {
		["base"]	= {  },
	},
	
	--[[---------------------------------------------------------------------------
							  -=( Level-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load for the specified levels/level range, always.						--]]
	["level"] = {
		["80"] = {  },
		["1-79"] = {  },
	},

	--[[---------------------------------------------------------------------------
								-=( Task-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load if you use their set name after the slash command.
		'/addonset raid' to load raid addons, for example.  You can enable multiple sets
		by separating them with spaces.  '/addonset quest gather party'  Indented sets are
		that way to indicate that they are a sub-set.  If you want the sub-set loaded, you
		should use the parent set as well.  '/addonset raid naxx'			--]]
	-- Raiding addons
	["raid"]	= { "oUF_ReadyCheck", "recBossTimers" },
		["os"]		= {  },
		["toc"]		= {  },
		["eoe"]		= {  },
		["naxx"]	= {  },
		["ony"]		= {  },
		["uld"]		= {  },
		["icc"] 	= {  },
	["party"]	= { "oUF_ReadyCheck", "recBossTimers" },
	-- Questing addons
	["quest"]	= { "recQuestProgress", "TourGuide" },
	-- Development addons
	["dev"]		= {  },
	-- PvP addons
	["pvp"]		= {  },
	-- Role-playing addons
	["rp"]		= {  },
	-- Bank alt addons
	["bank"]	= {  },

	["games"]	= { "LostCavern" },

	["gather"] = { "recGatherInfo" },

	["grind"] = { "LootWatch" },
	
	["profile"] = { "CharacterProfiler" },

	--[[---------------------------------------------------------------------------
								-=( Character-Specific Addons )=-
		---------------------------------------------------------------------------
		These addons will load for the specified character, always.  These characters
		are server-specific for flexibility.										--]]
	["Moon Guard"] = {
		["Suzi"]	= {  },
		["Neural"]	= {  },
	},
	["Wyrmrest Accord"] = {
		["Katy"]	= {  },
	},
	["Sisters of Elune"] = {
		["Suzie"] = {  }
	},
}

local function EnableSet(set)
	if set == "character" then
		local realm, character = GetRealmName(), UnitName("player")
		if not realm or not character or not addons[realm] or not addons[realm][character] then
			return
		else
			for _,v in pairs(addons[realm][character]) do EnableAddOn(v) end		-- Load all addons in set
		end
	elseif set == "level" then
		local level = UnitLevel("player")
		for k,_ in pairs(addons["level"]) do -- Check/handle level ranges
			local found, _, low, high = strfind(k, "(%d+)-(%d+)")
			if found then
				if level >= tonumber(low) and level <= tonumber(high) then
					for _,v in pairs(addons["level"][k]) do EnableAddOn(v) end
				end
			elseif tostring(level) == k then
				for _,v in pairs(addons["level"][k]) do EnableAddOn(v) end
			end
		end
	elseif set == "class" then
		for _,v in pairs(addons[select(2, UnitClass("player"))]["base"]) do EnableAddOn(v) end -- Class Base addons
	elseif not addons[set] then
		return 		-- If the set does not exist, then bail.
	else
		for _,v in pairs(addons[set]) do EnableAddOn(v) end		-- Load all addons in set
		if addons[select(2, UnitClass("player"))][set] then
			for _,v in pairs(addons[select(2, UnitClass("player"))][set]) do EnableAddOn(v) end -- Class Set addons
		end
	end
end

local function HandleSlash(set)
	for i = 1, GetNumAddOns() do
		DisableAddOn(i)		-- Disable all addons (to ensure only what we want gets loaded)
	end

	EnableSet("base")		-- Enable base addons

	if set then				-- Enable all addons passed in as arguments.
		local parse_position,sets = 0, {}
		for set_start, set_end in function() return string.find(set, " ", parse_position, true) end do
			table.insert(sets, string.sub(set, parse_position, set_start-1))
			parse_position = set_end+1
		end
		table.insert(sets, string.sub(set, parse_position))
		for _,set in pairs(sets) do
			EnableSet(set)
		end
	end

	EnableSet("class")	-- Enable all class-related addons
	EnableSet("character")	-- Enable all character specific addons
	EnableSet("level")	-- Enable all level-specific addons.

	ReloadUI()			-- Reload the UI for changes to take effect
end

SLASH_RECADDONMANAGER1 = '/addonset'
SlashCmdList.RECADDONMANAGER = HandleSlash