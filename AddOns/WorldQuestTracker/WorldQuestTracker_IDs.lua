
local addonId, wqtInternal = ...

--world quest tracker object
local WorldQuestTracker = WorldQuestTrackerAddon
if (not WorldQuestTracker) then
	return
end

--localization
local L = DetailsFramework.Language.GetLanguageTable(addonId)

--convert a filter type to a quest type
WorldQuestTracker.FilterToQuestType = {
	pet_battles =		WQT_QUESTTYPE_PETBATTLE,
	pvp =			WQT_QUESTTYPE_PVP,
	profession =		WQT_QUESTTYPE_PROFESSION,
	dungeon =			WQT_QUESTTYPE_DUNGEON,
	gold =			WQT_QUESTTYPE_GOLD,
	artifact_power =		WQT_QUESTTYPE_APOWER,
	garrison_resource =	WQT_QUESTTYPE_RESOURCE,
	equipment =		WQT_QUESTTYPE_EQUIPMENT,
	trade_skill =		WQT_QUESTTYPE_TRADE,
	reputation_token = 	WQT_QUESTTYPE_REPUTATION,
	racing =			WQT_QUESTTYPE_RACING,
}

--convert a quest type to a filter
WorldQuestTracker.QuestTypeToFilter = {
	[WQT_QUESTTYPE_GOLD] =			"gold",
	[WQT_QUESTTYPE_RESOURCE] =		"garrison_resource",
	[WQT_QUESTTYPE_APOWER] =		"artifact_power",
	[WQT_QUESTTYPE_EQUIPMENT] =		"equipment",
	[WQT_QUESTTYPE_TRADE] =			"trade_skill",
	[WQT_QUESTTYPE_DUNGEON] =		"dungeon",
	[WQT_QUESTTYPE_PROFESSION] =	"profession",
	[WQT_QUESTTYPE_PVP] =			"pvp",
	[WQT_QUESTTYPE_PETBATTLE] =		"pet_battles",
	[WQT_QUESTTYPE_REPUTATION] =	"reputation_token",
	[WQT_QUESTTYPE_RACING] =		"racing",
}

WorldQuestTracker.MapData = {}

--list of all zone ids
WorldQuestTracker.MapData.ZoneIDs = {
	--Main Hub
		AZEROTH =		947,

	--wow11
		KHAZALGAR = 	2274,
		RINGINGDEEPS =	2214,
		DORN = 			2248,
		AZJKAHET = 		2255,
		AZJKAHET_LOWER =	2256,
		HALLOWFALL = 	2215,
		CITYTHREADS = 	2213,
		CITYTHREADS_LOWER =	2216,
		UNDERMINE = 	2346,

	--Dragonflight
		DRAGONISLES = 	1978,
		AZURESSPAN = 	2024,
		THALDRASZUS = 	2025,
		OHNAHRANPLAINS = 	2023,
		WAKINGSHORES = 	2022,
		FORBIDDENREACH =	2151,
		ZARALEK = 		2133,
		EMERALDDREAM = 	2200,

	--Shadowlands
		MALDRAXXUS =	1536,
		BASTION = 		1533,
		ARDENWEALD =	1565,
		REVENDRETH =	1525,
		THEMAW =		1543,
		ORIBOS =		1570,
		THESHADOWLANDS = 1550,
		ZERETH = 		1970,

	--Legion
		ARGUS = 		905, --905
		BROKENISLES = 	619, --
		AZSUNA = 		630, --631 632 633
		VALSHARAH = 	641, --642 643 644
		HIGHMONTAIN = 	650, --
		DALARAN = 	625,
		SURAMAR =		680,
		STORMHEIM = 	634,
		BROKENSHORE = 	646,
		EYEAZSHARA = 	790,
		ANTORAN = 	885,
		KROKUUN = 	830,
		MCCAREE = 	882,

	--BFA
		DARKSHORE = 	62,
		ARATHI =		14,
		ZANDALAR = 	875,
		KULTIRAS = 	876,
		ZULDAZAAR = 	862,
		NAZMIR = 		863,
		VOLDUN = 		864,
		TIRAGARDE = 	895,
		STORMSONG = 	942,
		DRUSTVAR = 	896,
		TOLDAGOR =	1169,

		NAZJATAR = 	1355, --patch 8.2
		MECHAGON = 	1462, --patch 8.2
}

--cache
local zoneIDs = WorldQuestTracker.MapData.ZoneIDs

WorldQuestTracker.DotLineScale = {
	[zoneIDs.ZARALEK] = 2,
	[zoneIDs.OHNAHRANPLAINS] = 2,
	[zoneIDs.WAKINGSHORES] = 2,
	[zoneIDs.FORBIDDENREACH] = 2,
	[zoneIDs.AZURESSPAN] = 2,
	[zoneIDs.THALDRASZUS] = 2,
	[zoneIDs.DRAGONISLES] = 2,
	[2112] = 2, --valdrakken
	[zoneIDs.EMERALDDREAM] = 2,

	[zoneIDs.RINGINGDEEPS] = 3,
	[zoneIDs.DORN] = 3,
	[zoneIDs.AZJKAHET] = 3,
	[zoneIDs.AZJKAHET_LOWER] = 3,
	[zoneIDs.HALLOWFALL] = 3,
	[zoneIDs.CITYTHREADS] = 3,
	[zoneIDs.CITYTHREADS_LOWER] = 3,
	[zoneIDs.UNDERMINE] = 3,
}

WorldQuestTracker.MapData.ZoneToHub = {
	[zoneIDs.DORN] = zoneIDs.KHAZALGAR,
	[zoneIDs.HALLOWFALL] = zoneIDs.KHAZALGAR,
	[zoneIDs.RINGINGDEEPS] = zoneIDs.KHAZALGAR,
	[zoneIDs.AZJKAHET] = zoneIDs.KHAZALGAR,
	[zoneIDs.AZJKAHET_LOWER] = zoneIDs.KHAZALGAR,
	[zoneIDs.CITYTHREADS] = zoneIDs.KHAZALGAR,
	[zoneIDs.CITYTHREADS_LOWER] = zoneIDs.KHAZALGAR,
	[zoneIDs.UNDERMINE] = zoneIDs.KHAZALGAR,
}

--all zones with world quests
WorldQuestTracker.MapData.WorldQuestZones = {
	--wow 11
		[zoneIDs.DORN] = true,
		[zoneIDs.HALLOWFALL] = true,
		[zoneIDs.RINGINGDEEPS] = true,
		[zoneIDs.AZJKAHET] = true,
		[zoneIDs.AZJKAHET_LOWER] = true,
		[zoneIDs.CITYTHREADS] = true,
		[zoneIDs.CITYTHREADS_LOWER] = true,
		[zoneIDs.UNDERMINE] = true,

	--Dragonflight
		[zoneIDs.AZURESSPAN] = 		true,
		[zoneIDs.THALDRASZUS] = 	true,
		[zoneIDs.OHNAHRANPLAINS] = 	true,
		[zoneIDs.WAKINGSHORES] = 	true,
		[zoneIDs.FORBIDDENREACH] = 	true,
		[zoneIDs.ZARALEK] = 		true,
		[zoneIDs.EMERALDDREAM] = 	true,

	--Shadowlands
		[zoneIDs.MALDRAXXUS] =	true,
		[zoneIDs.BASTION] = 	true,
		[zoneIDs.ARDENWEALD] =	true,
		[zoneIDs.REVENDRETH] =	true,
		[zoneIDs.THEMAW] =		true,
		[zoneIDs.ZERETH] = 		true,
		--[zoneQuests.ORIBOS] =		true,

	--BFA
		--zandalar
		[zoneIDs.ZULDAZAAR] = 	true,
		[zoneIDs.NAZMIR] = 		true,
		[zoneIDs.VOLDUN] = 		true,
		[1165] = 		true, --dazar'alor
		[1161] = 		true, --boralus
		[zoneIDs.TOLDAGOR] = 		true,

		--kul'tiras
		[zoneIDs.TIRAGARDE] = 	true,
		[zoneIDs.STORMSONG] = 	true,
		[zoneIDs.DRUSTVAR] = 		true,

		--PRE PATCH
		[zoneIDs.DARKSHORE] = 	true,
		[zoneIDs.ARATHI] 	= 	true,

		--8.2
		[zoneIDs.NAZJATAR] = 		true,
		[zoneIDs.MECHAGON] = 	true,

	--Legion
		--broken isles
		[zoneIDs.AZSUNA] = 		true,
		[zoneIDs.HIGHMONTAIN] = 	true,
		[zoneIDs.STORMHEIM] = 	true,
		[zoneIDs.SURAMAR] = 		true,
		[zoneIDs.VALSHARAH] = 	true,
		[zoneIDs.EYEAZSHARA] = 	true,
		[zoneIDs.DALARAN] = 		true,
		[zoneIDs.BROKENSHORE] = 	true,
		--argus
		[zoneIDs.ANTORAN] = 		true,
		[zoneIDs.KROKUUN] = 		true,
		[zoneIDs.MCCAREE] = 		true,
}

WorldQuestTracker.MapData.DragonflightZones = {
	[zoneIDs.AZURESSPAN] = 	true,
	[zoneIDs.THALDRASZUS] = 	true,
	[zoneIDs.OHNAHRANPLAINS] = 	true,
	[zoneIDs.WAKINGSHORES] = 	true,
	[zoneIDs.FORBIDDENREACH] = 	true,
	[zoneIDs.ZARALEK] = 	true,
	[zoneIDs.DRAGONISLES] = 	true,
	[zoneIDs.EMERALDDREAM] = 	true,
	[2112] = true, --valdrakken
}

--quest hub by expansion
WorldQuestTracker.MapData.ExpMaps = {
	[zoneIDs.KHAZALGAR] = 11,
	[zoneIDs.DRAGONISLES] = 10,
	[zoneIDs.THESHADOWLANDS] = 9,
	[zoneIDs.ZANDALAR] = 8,
	[zoneIDs.KULTIRAS] = 8,
	[zoneIDs.AZEROTH] = 8,
	[zoneIDs.BROKENISLES] = 7,
}

WorldQuestTracker.MapData.HubMapIconsScale = {
	[zoneIDs.DRAGONISLES] = 0.85,
	[zoneIDs.THESHADOWLANDS] = 1,
	[zoneIDs.ZANDALAR] = 0.9,
	[zoneIDs.KULTIRAS] = 0.9,
	[zoneIDs.AZEROTH] = 1,
	[zoneIDs.BROKENISLES] = 0.30,
	[zoneIDs.KHAZALGAR] = 0.95,
}

--list of map ids for world quest hubs
WorldQuestTracker.MapData.QuestHubs = {
	[zoneIDs.KHAZALGAR] = true, --wow11 hub
	[zoneIDs.DRAGONISLES] = true, --dragon isles hub
	[zoneIDs.THESHADOWLANDS] = true, --shadowlands hub
	[zoneIDs.BROKENISLES] = true, --dalaran (~rev)
	[zoneIDs.ARGUS] = true, --argus (~rev)
	[zoneIDs.ZANDALAR] = true, --bfa horde
	[zoneIDs.KULTIRAS] = true, --bfa alliance
	[zoneIDs.AZEROTH] = true, --main hub
}

--world map anchors
WorldQuestTracker.mapTables = {
	--dlc 10 (tww)
	[zoneIDs.RINGINGDEEPS] = 		{
		widgets = {},
		Anchor_X = 0.995,
		Anchor_Y = 0.50,
		GrowRight = false,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	[zoneIDs.HALLOWFALL] = 		{
		widgets = {},
		Anchor_X = 0.002,
		Anchor_Y = 0.28,
		GrowRight = true,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	[zoneIDs.UNDERMINE] = 		{
		widgets = {},
		Anchor_X = 0.995,
		Anchor_Y = 0.70,
		GrowRight = false,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	[zoneIDs.DORN] = 		{
		widgets = {},
		Anchor_X = 0.3,
		Anchor_Y = 0.12,
		GrowRight = true,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	[zoneIDs.AZJKAHET] = 		{
		widgets = {},
		Anchor_X = 0.002,
		Anchor_Y = 0.78,
		GrowRight = true,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	[zoneIDs.AZJKAHET_LOWER] = 		{
		widgets = {},
		Anchor_X = 0.002,
		Anchor_Y = 0.88,
		GrowRight = true,
		show_on_map = {
			[zoneIDs.KHAZALGAR] = true,
		},
	},

	--Dragon Isles (Dragonflight)

		[zoneIDs.AZURESSPAN] = 		{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.48,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.THALDRASZUS] = 		{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.35,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.ZARALEK] = 		{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.7,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.OHNAHRANPLAINS] = 		{
			widgets = {},
			Anchor_X = 0.002,
			Anchor_Y = 0.48,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.WAKINGSHORES] = 		{
			widgets = {},
			Anchor_X = 0.002,
			Anchor_Y = 0.28,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.FORBIDDENREACH] = 		{
			widgets = {},
			Anchor_X = 0.6,
			Anchor_Y = 0.05,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},

		[zoneIDs.EMERALDDREAM] = 		{
			widgets = {},
			Anchor_X = 0.002,
			Anchor_Y = 0.67,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.DRAGONISLES] = true,
			},
		},


	--Shadowlands

		[zoneIDs.ZERETH] = 		{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.68,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

		[zoneIDs.MALDRAXXUS] =	{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.28,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

		[zoneIDs.BASTION] = 		{
			widgets = {},
			Anchor_X = 0.995,
			Anchor_Y = 0.46,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

		[zoneIDs.ARDENWEALD] =	{
			widgets = {},
			Anchor_X = 0.002,
			Anchor_Y = 0.70,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

		[zoneIDs.REVENDRETH] =	{
			widgets = {},
			Anchor_X = 0.002,
			Anchor_Y = 0.34,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

		[zoneIDs.THEMAW] = {
			widgets = {},
			--Anchor_X = 0.31,
			Anchor_X = 0.002,
			Anchor_Y = 0.17,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.THESHADOWLANDS] = true,
			},
		},

	--Main Hub
		[zoneIDs.ZANDALAR] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.55,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.AZEROTH] = true,
			},
		},

		[zoneIDs.KULTIRAS] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.15,
			GrowRight = false,
			show_on_map = {
				[zoneIDs.AZEROTH] = true,
			},
		},

		[zoneIDs.DARKSHORE] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.32,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.AZEROTH] = true,
			},
		},

		[zoneIDs.ARATHI] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.20,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.AZEROTH] = true,
			},
		},

		[zoneIDs.NAZJATAR] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.08,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.AZEROTH] = true,
			},
		},

	--BFA
		[1161] = { --boralus
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.48,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.KULTIRAS] = true,
				},
		},

		[1165] = { --dazar'alor
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.48,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.ZANDALAR] = true,
				}
		},

		--alliance
		[zoneIDs.TIRAGARDE] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.62,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.KULTIRAS] = true,
				},
		},
		[zoneIDs.STORMSONG] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.18,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.KULTIRAS] = true,
				},
		},
		[zoneIDs.DRUSTVAR] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.36,
			GrowRight = true,
			show_on_map = {
					[zoneIDs.KULTIRAS] = true,
				},
		},
		[zoneIDs.TOLDAGOR] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.56,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.KULTIRAS] = true,
				},
		},

		--horde
		[zoneIDs.ZULDAZAAR] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.62,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.ZANDALAR] = true,
				}
		},
		[zoneIDs.NAZMIR] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.18,
			GrowRight = false,
			show_on_map = {
					[zoneIDs.ZANDALAR] = true,
				}
		},
		[zoneIDs.VOLDUN] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.36,
			GrowRight = true,
			show_on_map = {
					[zoneIDs.ZANDALAR] = true,
				}
		},

	--Legion
		[zoneIDs.AZSUNA] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.53,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.VALSHARAH] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.33,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.HIGHMONTAIN] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.10,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.STORMHEIM] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.30,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.SURAMAR] = {
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.50,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.BROKENSHORE] = { --broken shore
			widgets = {},
			Anchor_X = 0.99,
			Anchor_Y = 0.69,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.EYEAZSHARA] = {
			widgets = {},
			Anchor_X = 0.5,
			Anchor_Y = 0.8,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},
		[zoneIDs.DALARAN] = {
			widgets = {},
			Anchor_X = 0.47,
			Anchor_Y = 0.62,
			GrowRight = true,
			show_on_map = {
				[zoneIDs.BROKENISLES] = true,
			}
		},

		[zoneIDs.MCCAREE] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.20,
			show_on_map = {
					[zoneIDs.ARGUS] = true,
				},
			GrowRight = true,
		},
		[zoneIDs.ANTORAN] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.37,
			show_on_map = {
					[zoneIDs.ARGUS] = true,
				},
			GrowRight = true,
		},
		[zoneIDs.KROKUUN] = {
			widgets = {},
			Anchor_X = 0.01,
			Anchor_Y = 0.52,
			show_on_map = {
					[zoneIDs.ARGUS] = true,
				},
			GrowRight = true,
		},
}

WorldQuestTracker.extraIcons = {

}

WorldQuestTracker.MapData.EquipmentIcons = {
	["INVTYPE_HEAD"] = "Interface\\ICONS\\" .. "INV_Helmet_29",
	["INVTYPE_NECK" ] = "Interface\\ICONS\\" .. "INV_Jewelry_Necklace_07",
	["INVTYPE_SHOULDER"] = "Interface\\ICONS\\" .. "INV_Shoulder_25",
	["INVTYPE_ROBE"] = "Interface\\ICONS\\" .. "INV_Chest_Cloth_08", --INVTYPE_CHEST
	["INVTYPE_WAIST"] = "Interface\\ICONS\\" .. "INV_Belt_15",
	["INVTYPE_LEGS"] = "Interface\\ICONS\\" .. "INV_Pants_08",
	["INVTYPE_FEET"] = "Interface\\ICONS\\" .. "INV_Boots_Cloth_03",
	["INVTYPE_WRIST"] = "Interface\\ICONS\\" .. "INV_Bracer_07",
	["INVTYPE_HAND"] = "Interface\\ICONS\\" .. "INV_Gauntlets_17",
	["INVTYPE_FINGER"] = "Interface\\ICONS\\" .. "INV_Jewelry_Ring_22",
	["INVTYPE_TRINKET"] = "Interface\\ICONS\\" .. "INV_Jewelry_Talisman_07", --"INV_Trinket_HonorHold",
	["INVTYPE_CLOAK"] = "Interface\\ICONS\\" .. "INV_Misc_Cape_19", --INVTYPE_BACK
	["Relic"] = "Interface\\ICONS\\" .. "inv_misc_enchantedpearlE",

	["INVTYPE_WEAPON"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_SHIELD"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_2HWEAPON"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_WEAPONMAINHAND"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_WEAPONOFFHAND"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_HOLDABLE"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_RANGED"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_THROWN"] = "Interface\\ICONS\\" .. "INV_Sword_39",
	["INVTYPE_RANGEDRIGHT"] = "Interface\\ICONS\\" .. "INV_Sword_39",
}

WorldQuestTracker.MapData.ItemIcons = {
	["DRAGONFLIGHT_ARTIFACT"] = "",
	["LEGION_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_artifactpower_redT]],
	["BFA_RESOURCE"] = [[Interface\AddOns\WorldQuestTracker\media\icon_resource]],
	["BFA_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_artifact_power]],
	["SHADOWLANDS_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_mana]],
}

WorldQuestTracker.MapData.ArtifactPowerSummaryIcons = {
	["DRAGONFLIGHT_ARTIFACT"] = "",
	["LEGION_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_artifact_power_legion]],
	["BFA_RESOURCE"] = [[Interface\AddOns\WorldQuestTracker\media\icon_resource]],
	["BFA_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_artifact_power_bfa]],
	["SHADOWLANDS_ARTIFACT"] = [[Interface\AddOns\WorldQuestTracker\media\icon_artifact_power_shadowlands]],
}

WorldQuestTracker.MapData.ResourceIcons = {
	--dragonflight tbd
	[2032600] = true, --war resources BFA
	[WorldQuestTracker.MapData.ItemIcons ["BFA_RESOURCE"]] = true, --custom icon for the BFA war resource
	[1397630] = true, --order resources LEGION
}

--start of ~factions

-- texture ID of the reward when the world quest reward is a faction rep token
WorldQuestTracker.MapData.ReputationIcons = {
	--DLC 10 (tww)
	[5891369] = true, --Council of Dornogal
	[5891367] = true, --The Assembly of the Deeps
	[5891368] = true, --Hallowfall Arathi
	[5891370] = true, --The Severed Threads

	--Dragonflight
	[4687627] = true, --Maruuk Centaur
	[4687628] = true, --Dragonscale Expedition
	[4687630] = true, --Valdrakken Accord
	[4687629] = true, --Iskaara Tuskarr
	["Interface\\ICONS\\UI_MajorFaction_Niffen"] = true, --Loamm Niffen
	[5244643] = true, --Dream Wardens

	--Shadowlands
	[3257748] = true, --Ascended
	[3575389] = true, --Wild Hunt
	[3492310] = true, --Undying Army
	[3514227] = true, --Court of Harvesters
	[4226232] = true, --The Enlightened

	--BFA
	[2032597] = true, --Talanji's Expedition
	[2032601] = true, --Zandalari Empire
	[2032599] = true, --Voldunai
	[2032593] = true, --Honorbound

	[2032598] = true, --Tortollan Seekers
	[2032592] = true, --Champions of Azreroth

	[2032596] = true, --Storm's Wake
	[2032594] = true, --Order of Embers
	[2032595] = true, --Proudmoore
	[2032591] = true, --7th Legion

	--[0] = true, --Rustbolt Resistance | 8.2
	--[0] = true, --The Unshackled | 8.2
	--[0] = true, --Rajani | 8.3
	--[0] = true, --Uldum Accord | 8.3
}

---list of relevant factions
---@type table<factionid, boolean>
WorldQuestTracker.MapData.AllFactionIds = {
	--DLC 10 (tww)
	[2590] = true, --Council of Dornogal
	[2594] = true, --The Assembly of the Deeps
	[2570] = true, --Hallowfall Arathi
	[2600] = true, --The Severed Threads

	--Dragonflight Factions
	[2503] = true, --Maruuk Centaur
	--[2506] = true, --Dragonflight
	[2507] = true, --Dragonscale Expedition
	[2510] = true, --Valdrakken Accord
	[2511] = true, --Iskaara Tuskarr
	[2564] = true, --Loamm Niffen
	[2574] = true, --Dream Wardens

	--Shadowlands Factions
	[2410] = true, --The Undying Army
	[2407] = true, --The Ascended
	[2465] = true, --The Wild Hunt
	[2413] = true, --Court of Harvesters
	[2470] = true, --Death's Advance
	[2472] = true, --The Archivists' Codex
	[2432] = true, --Ve'nari
	[2478] = true, --The Enlightened

	--BFA Factions
	[2159] = true, --7th Legion
	[2160] = true, --Proudmoore Admiralty
	[2161] = true, --Order of Embers
	[2162] = true, --Storm's Wake
	[2103] = true, --Zandalari Empire
	[2156] = true, --Talanji's Expedition
	[2157] = true, --The Honorbound
	[2158] = true, --Voldunai
	[2163] = true, --Tortollan Seekers
	[2164] = true, --Champions of Azeroth
	[2391] = true, --Rustbolt Resistance | 8.2
	[2373] = true, --The Unshackled | 8.2
	[2415] = true, --Rajani | 8.3
	[2417] = true, --Uldum Accord | 8.3

	--Legion Factions
	[2170] = true, --Argussian Reach
	[2045] = true, --Armies of Legionfall
	[2165] = true, --Army of the Light
	[1900] = true, --Court of Farondis
	[1883] = true, --Dreamwavers
	[1828] = true, --Highmountain Tribe
	[1859] = true, --The Nightfallen
	[1894] = true, --The Wardens
	[1948] = true, --Valarjar
}

---@type table<factionid, mapid>
WorldQuestTracker.MapData.FactionMapId = {
	--DLC 10 (tww)
	[2590] = zoneIDs.DORN, --Council of Dornogal
	[2594] = zoneIDs.RINGINGDEEPS, --The Assembly of the Deeps
	[2570] = zoneIDs.HALLOWFALL, --Hallowfall Arathi
	[2600] = zoneIDs.AZJKAHET, --The Severed Threads

	--Dragonflight
	[2503] = zoneIDs.OHNAHRANPLAINS, --Maruuk Centaur
	[2507] = zoneIDs.WAKINGSHORES, --Dragonscale Expedition
	[2510] = zoneIDs.THALDRASZUS, --Valdrakken Accord
	[2511] = zoneIDs.AZURESSPAN, --Iskaara Tuskarr
	[2564] = zoneIDs.ZARALEK, --Loamm Niffen
	[2574] = zoneIDs.EMERALDDREAM, --Dream Wardens

	--Shadowlands
	[2410] = 1536, --The Undying Army | MALDRAXXUS
	[2407] = 1533, --The Ascended | BASTION
	[2465] = 1565, --The Wild Hunt | ARDENWEALD
	[2413] = 1525, --Court of Harvesters | REVENDRETH
	[2470] = 1961, --Death's Advance
	[2472] = 1961, --The Archivists' Codex
	[2432] = 1543, --Ve'nari
}

---@type table<factionid, string|number>
WorldQuestTracker.MapData.FactionIcons = {
	--DLC 10 (tww)
	[2590] = 5891369, --Council of Dornogal
	[2594] = 5891367, --The Assembly of the Deeps
	[2570] = 5891368, --Hallowfall Arathi
	[2600] = 5891370, --The Severed Threads

	--Dragonflight
	[2503] = 4687627, --Maruuk Centaur
	[2507] = 4687628, --Dragonscale Expedition
	[2510] = 4687630, --Valdrakken Accord
	[2511] = 4687629, --Iskaara Tuskarr
	[2564] = [[Interface\ICONS\UI_MajorFaction_Niffen]], --Loamm Niffen
	[2574] = 5244643, --Dream Wardens

	--Shadowlands
	[2410] = 3492310, --The Undying Army
	[2407] = 3257748, --The Ascended
	[2465] = 3575389, --The Wild Hunt
	[2413] = 3514227, --Court of Harvesters
	[2470] = [[Interface\ICONS\INV_Tabard_DeathsAdvance_B_01]], --Death's Advance
	[2472] = [[Interface\ICONS\INV_Inscription_80_Scroll]], --The Archivists' Codex
	[2432] = [[Interface\AddOns\WorldQuestTracker\media\venari]], --Ve'nari
	[2478] = 4226232, --The Enlightened

	--BFA
	[2159] = "Interface\\ICONS\\inv__faction_alliancewareffort", --7th Legion
	[2160] = "Interface\\ICONS\\inv__faction_proudmooreadmiralty", --Proudmoore Admiralty
	[2161] = "Interface\\ICONS\\inv__faction_orderofembers", --Order of Embers
	[2162] = "Interface\\ICONS\\inv__faction_stormswake", --Storm's Wake
	[2103] = "Interface\\ICONS\\inv__faction_zandalariempire", --Zandalari Empire
	[2156] = "Interface\\ICONS\\inv__faction_talanjisexpedition", --Talanji's Expedition
	[2157] = "Interface\\ICONS\\inv__faction_hordewareffort", --The Honorbound
	[2158] = "Interface\\ICONS\\inv__faction_voldunai", --Voldunai
	[2163] = "Interface\\ICONS\\inv__faction_tortollanseekers", --Tortollan Seekers
	[2164] = "Interface\\ICONS\\inv__faction_championsofazeroth", --Champions of Azeroth
	[2391] = "Interface\\ICONS\\INV_Faction_Rustbolt", --Rustbolt Resistance | 8.2
	[2373] = "Interface\\ICONS\\INV_Faction_Unshackled", --The Unshackled | 8.2
	[2415] = "Interface\\ICONS\\INV_FACTION_83_RAJANI", --Rajani | 8.3
	[2417] = "Interface\\ICONS\\INV_FACTION_83_ULDUMACCORD", --Uldum Accord | 8.3

	--Legion
	[2170] = "Interface\\ICONS\\INV_Legion_Faction_ArgussianReach", --Argussian Reach
	[2045] = "Interface\\ICONS\\INV_Legion_Faction_Legionfall", --Armies of Legionfall
	[2165] = "Interface\\ICONS\\INV_Legion_Faction_ArmyoftheLight", --Army of the Light
	[1900] = "Interface\\ICONS\\INV_Legion_Faction_CourtofFarnodis", --Court of Farondis
	[1883] = "Interface\\ICONS\\INV_Legion_Faction_DreamWeavers", --Dreamwavers
	[1828] = "Interface\\ICONS\\INV_Legion_Faction_HightmountainTribes", --Highmountain Tribe
	[1859] = "Interface\\ICONS\\INV_Legion_Faction_NightFallen", --The Nightfallen
	[1894] = "Interface\\ICONS\\INV_Legion_Faction_Warden", --The Wardens
	[1948] = "Interface\\ICONS\\INV_Legion_Faction_Valarjar", --Valarjar
--	/run for i =1, 3000 do local N={WorldQuestTracker.GetFactionDataByID(i)}if(N[1])then print(N[1].." "..N[14])end end
}

local WOW11Factions = { --DLC10 (tww)
	[2590] = true, --Council of Dornogal
	[2594] = true, --The Assembly of the Deeps
	[2570] = true, --Hallowfall Arathi
	[2600] = true, --The Severed Threads
}

WorldQuestTracker.MapData.FactionHasWarbandReputation = {}
for factionId in pairs (WOW11Factions) do
	WorldQuestTracker.MapData.FactionHasWarbandReputation[factionId] = true
end

local DragonflightFactions = {
	[2503] = true, --Maruuk Centaur
	[2507] = true, --Dragonscale Expedition
	[2510] = true, --Valdrakken Accord
	[2511] = true, --Iskaara Tuskarr
	[2564] = true, --Loamm Niffen
	[2574] = true, --Dream Wardens
}

local ShadowlandsFactions = {
	[2410] = true, --The Undying Army
	[2407] = true, --The Ascended
	[2465] = true, --The Wild Hunt
	[2413] = true, --Court of Harvesters
	[2470] = true, --Death's Advance
	[2472] = true, --The Archivists' Codex
	[2432] = true, --Ve'nari
	[2478] = true, --The Enlightened
}

local BFAFactions = {
	["Alliance"] = {
		[2159] = true, --7th Legion
		[2160] = true, --Proudmoore Admiralty
		[2161] = true, --Order of Embers
		[2162] = true, --Storm's Wake
		[2400] = true, --Waveblade Ankoan

		[2163] = true, --Tortollan Seekers
		[2164] = true, --Champions of Azeroth
		[2417] = true, --Uldum Accord
		[2415] = true, --Rajani
		[2391] = true, --Rustbolt Resistance
	},

	["Horde"] = {
		--BFA
		[2103] = true, --Zandalari Empire
		[2156] = true, --Talanji's Expedition
		[2157] = true, --The Honorbound
		[2158] = true, --Voldunai
		[2373] = true, --The Unshackled
		[2163] = true, --Tortollan Seekers
		[2164] = true, --Champions of Azeroth
		[2417] = true, --Uldum Accord
		[2415] = true, --Rajani
		[2391] = true, --Rustbolt Resistance
	}
}

local LegionFactions = {
	[2170] = true, --Argussian Reach
	[2045] = true, --Armies of Legionfall
	[2165] = true, --Army of the Light
	[1900] = true, --Court of Farondis
	[1883] = true, --Dreamwavers
	[1828] = true, --Highmountain Tribe
	[1859] = true, --The Nightfallen
	[1894] = true, --The Wardens
	[1948] = true, --Valarjar
}

WorldQuestTracker.MapData.OverrideMapId = {
	--wow11
	[zoneIDs.AZJKAHET_LOWER] =	zoneIDs.AZJKAHET,
	[zoneIDs.CITYTHREADS] =		zoneIDs.AZJKAHET,
	[zoneIDs.CITYTHREADS_LOWER] =	zoneIDs.AZJKAHET,
}

--what are the factionIds belong to the map
WorldQuestTracker.MapData.ReputationByMap = {
	--world maps
		[zoneIDs.KHAZALGAR] = WOW11Factions,
		[zoneIDs.DRAGONISLES] = DragonflightFactions,
		[zoneIDs.THESHADOWLANDS] = ShadowlandsFactions,
		[zoneIDs.KULTIRAS] = BFAFactions,
		[zoneIDs.ZANDALAR] = BFAFactions,
		[zoneIDs.AZEROTH] = BFAFactions,
		[zoneIDs.BROKENISLES] = LegionFactions,
		[zoneIDs.ARGUS] = LegionFactions,

	--zones
		--wow11
		[zoneIDs.DORN] = WOW11Factions,
		[zoneIDs.RINGINGDEEPS] = WOW11Factions,
		[zoneIDs.HALLOWFALL] = WOW11Factions,
		[zoneIDs.AZJKAHET] = WOW11Factions,
		[zoneIDs.AZJKAHET_LOWER] = WOW11Factions,
		[zoneIDs.CITYTHREADS] = WOW11Factions,
		[zoneIDs.CITYTHREADS_LOWER] = WOW11Factions,

		--Dragonflight
		[zoneIDs.OHNAHRANPLAINS] = DragonflightFactions,
		[zoneIDs.WAKINGSHORES] = DragonflightFactions,
		[zoneIDs.THALDRASZUS] = DragonflightFactions,
		[zoneIDs.AZURESSPAN] = DragonflightFactions,
		[zoneIDs.ZARALEK] = DragonflightFactions,
		[zoneIDs.EMERALDDREAM] = DragonflightFactions,

		--Shadowlands
		[zoneIDs.BASTION] = 		ShadowlandsFactions,
		[zoneIDs.MALDRAXXUS] = 	ShadowlandsFactions,
		[zoneIDs.ARDENWEALD] = 	ShadowlandsFactions,
		[zoneIDs.REVENDRETH] = 	ShadowlandsFactions,
		[zoneIDs.ZERETH] = 		ShadowlandsFactions,

		--BFA
		[zoneIDs.ZULDAZAAR] = 	BFAFactions,
		[zoneIDs.NAZMIR] = 		BFAFactions,
		[zoneIDs.VOLDUN] = 		BFAFactions,
		[zoneIDs.TIRAGARDE] = 	BFAFactions,
		[zoneIDs.STORMSONG] = 	BFAFactions,
		[zoneIDs.DRUSTVAR] = 		BFAFactions,
}

function WorldQuestTracker.GetFactionsAllowedOnMap(mapId)
	local factionIdList = WorldQuestTracker.MapData.ReputationByMap[mapId]
	if (not factionIdList) then
		return
	end

	if (factionIdList.Horde and factionIdList.Alliance) then
		local playerFactionGroup = UnitFactionGroup("player")
		local list = factionIdList[playerFactionGroup]
		return list

	else
		return factionIdList
	end
end

WorldQuestTracker.MapData.TradeSkillIcons = {
	[1064188] = true, --veiled argunite LEGION
	[399041] = true, --argus waystone LEGION
}

WorldQuestTracker.MapData.ReplaceIcon = {
	[2032600] = WorldQuestTracker.MapData.ItemIcons ["BFA_RESOURCE"], --war resource BFA
}

--when a quest rewards more than 1 reward, sometimes the first reward is a fixed currency
WorldQuestTracker.MapData.IgnoredRewardTexures = {
	[2565244] = true, --BFA honorbound service medal
	[2565243] = true, --BFA 7th legion service medal
}

WorldQuestTracker.MapData.QuestTypeIcons = {
	--[WQT_QUESTTYPE_APOWER] = {name = L["S_QUESTTYPE_ARTIFACTPOWER"], icon = [[Interface\AddOns\WorldQuestTracker\media\icon_artifactpower_red_roundT]], coords = {0, 1, 0, 1}},
	[WQT_QUESTTYPE_APOWER] = {name = L["S_QUESTTYPE_ARTIFACTPOWER"], icon = 2967113, coords = {0, 1, 0, 1}},
	[WQT_QUESTTYPE_GOLD] = {name = L["S_QUESTTYPE_GOLD"], icon = [[Interface\GossipFrame\auctioneerGossipIcon]], coords = {0, 1, 0, 1}},
	[WQT_QUESTTYPE_RESOURCE] = {name = L["S_QUESTTYPE_RESOURCE"], icon = [[Interface\AddOns\WorldQuestTracker\media\resource_iconT]], coords = {0, 1, 0, 1}},
	[WQT_QUESTTYPE_EQUIPMENT] = {name = L["S_QUESTTYPE_EQUIPMENT"], icon = [[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]], coords = {0, 1, 0, 1}},
	[WQT_QUESTTYPE_DUNGEON] = {name = L["S_QUESTTYPE_DUNGEON"], icon = [[Interface\TARGETINGFRAME\Nameplates]], coords = {41/256, 0/256, 29/128, 63/128}},
	[WQT_QUESTTYPE_PROFESSION] = {name = L["S_QUESTTYPE_PROFESSION"], icon = [[Interface\MINIMAP\TRACKING\Profession]], coords = {2/32, 30/32, 2/32, 30/32}},
	[WQT_QUESTTYPE_PVP] = {name = L["S_QUESTTYPE_PVP"], icon = [[Interface\QUESTFRAME\QuestTypeIcons]], coords = {37/128, 53/128, 19/64, 36/64}},
	[WQT_QUESTTYPE_PETBATTLE] = {name = L["S_QUESTTYPE_PETBATTLE"], icon = [[Interface\AddOns\WorldQuestTracker\media\icon_pet]], coords = {0.05, 0.95, 0.05, 0.95}},
	[WQT_QUESTTYPE_TRADE] = {name = L["S_QUESTTYPE_TRADESKILL"], icon = [[Interface\ICONS\INV_Blood of Sargeras]], coords = {5/64, 59/64, 5/64, 59/64}},
	[WQT_QUESTTYPE_REPUTATION] = {name = L["Reputation"], icon = [[Interface\ICONS\Achievement_Reputation_01]], coords = {5/64, 59/64, 5/64, 59/64}},
	[WQT_QUESTTYPE_RACING] = {name = L["Racing"], icon = [[Interface\AddOns\WorldQuestTracker\media\icon_racing_nobackground]], coords = {0, 1, 0, 1}},
}

WorldQuestTracker.MapData.GeneralIcons = {
	["CRITERIA"] = {name = "criteria", icon = [[Interface\AdventureMap\AdventureMap]], coords = {833/1024, 856/1024, 270/1024, 307/1024}}
}

WorldQuestTracker.MapData.GroupFinderIgnoreQuestList = {
	--Legion
		[43325] = true,--race
		[43753] = true,--race
		[43764] = true,--race
		[43769] = true,--race
		[43774] = true,--race
		[45047] = true,--wind
		[45046] = true,--wind
		[45048] = true,--wind
		[45047] = true,--wind
		[45049] = true,--wind
		[45071] = true,--barrel
		[45068] = true,--barrel
		[45069] = true,--barrel
		[45070] = true,--barrel
		[45072] = true,--barrel
		[43327] = true,--fly
		[43777] = true,--fly
		[43771] = true,--fly
		[43766] = true,--fly
		[43755] = true,--fly
		[43756] = true, --enigmatic
		[43772] = true, --enigmatic
		[43767] = true, --enigmatic
		[43778] = true, --enigmatic
		[43328] = true, --enigmatic
		[41327] = true, --supplies-needed-stormscales
		[41224] = true, --supplies-needed-foxflower
		[41293] = true, --supplies-needed-dreamleaf
		[41288] = true, --supplies-needed-aethril
		[41339] = true, --supplies-needed-stonehide-leather
		[41318] = true, --supplies-needed-felslate
		[41351] = true, --supplies-needed-stonehide-leather
		[41345] = true, --supplies-needed-stormscales
		[41207] = true, --supplies-needed-leystone
		[41303] = true, --supplies-needed-starlight-roses
		[41237] = true, --supplies-needed-stonehide-leather
		[41298] = true, --supplies-needed-fjarnskaggl
		[41317] = true, --supplies-needed-leystone
		[41315] = true, --supplies-needed-leystone
		[41316] = true, --supplies-needed-leystone

		[48338] = true, --supplies-needed-astral-glory
		[48337] = true, --supplies-needed-astral-glory
		[48360] = true, --supplies-needed-fiendish leather
		[48358] = true, --supplies-needed-empyrium
		[48349] = true, --supplies-needed-empyrium
		[48374] = true, --supplies-needed-lightweave-cloth
		[48373] = true, --supplies-needed-lightweave-cloth

		--other quests
		[45988] = true, --ancient bones broken shore
		[45379] = true, --tresure master rope broken shore
		[43943] = true, --army training suramar
		[45791] = true, --war materiel broken shore
		[48097] = true, --gatekeeper's cunning macaree
		[48386] = true, --jed'hin tournament
}

WorldQuestTracker.MapData.RaresToScan = {
	--BFA
		[124185] = true, -- Golrakahn
		[122004] = true, -- Umbra'jin

		--arathi highlands
		[141668] = true, --echo of myzrael
		[141618] = true, --cresting goliath
		[141615] = true, --burniong goliath
		[142436] = true, --ragebeak
		[142440] = true, --yogursa
		[141620] = true, --rumbling goliath
		[142435] = true, --plaguefeather
		[141942] = true, --molok the crusher
		[142438] = true, --venomarus
		[141616] = true, --thundering goliath
		[142508] = true, --branchlord akdrus
		[142437] = true, --skullripper
		[142423] = true, --overseer krix

	--Legion
		[126338] = true, --wrathlord yarez
		[126852] = true, --wrangler kravos
		[122958] = true, --blistermaw
		[127288] = true, --houndmaster kerrax
		[126912] = true, --skreeg the devourer
		[126867] = true, --venomtail skyfin
		[126862] = true, --baruut the bloodthirsty
		[127703] = true, --doomcaster suprax
		[126900] = true, --instructor tarahna
		[126860] = true, --kaara the pale
		[126419] = true, --naroua
		[126898] = true, --sabuul
		[126208] = true, --varga
		[127705] = true, --mother rosula
		[127706] = true, --rezira the seer
		[123464] = true, --sister subversia
		[127700] = true, --squadron commander vishax
		[127581] = true, --the many faced devourer
		[126887] = true, --ataxon
		[126338] = true, --wrath lord yarez
		[127090] = true, --admiral relvar
		[120393] = true, --siegemaster voraan
		[127096] = true, --all seer xanarian
		[126199] = true, --vrax-thul
		[127376] = true, --chief alchemist munculus
		[127300] = true, --void warden valsuran
		[125820] = true, --imp mother laglath
		[125388] = true, --vagath the betrayed
		[123689] = true, --talestra the vile
		[127118] = true, --worldsplitter skuul
		[124804] = true, --tereck the selector
		[125479] = true, --tar spitter
		[122911] = true, --commander vecaya
		[125824] = true, --khazaduum
		[122912] = true, --commander sathrenael
		[124775] = true, --commander endaxis
		[127704] = true, --soultender videx
		[126040] = true, --puscilla
		[127291] = true, --watcher aival
		[127090] = true, --admiral relvar
		[122999] = true, --garzoth
		[122947] = true, --mistress ilthendra
		[127581] = true, --the many faced devourer
		[126115] = true, --venorn
		[126254] = true, --lieutenant xakaar
		[127084] = true, --commander texlaz
		[126946] = true, --inquisitor vethroz
		[126865] = true, --vigilant thanos
		[126869] = true, --captain faruq
		[126896] = true, --herald of chaos
		[126899] = true, --jedhin champion vorusk
		[125497] = true, --overseer ysorna
		[126910] = true, --commander xethgar
		[126913] = true, --slithon the last
		[122838] = true, --shadowcaster voruun
		[126815] = true, --soultwisted monstrosity
		[126864] = true, --feasel the muffin thief
		[126866] = true, --vigilant kuro
		[126868] = true, --turek the lucid
		[126885] = true, --umbraliss
		[126889] = true, --sorolis the ill fated
		[124440] = true, --overseer ybeda
		[125498] = true, --overseer ymorna
		[126908] = true, --zultan the numerous
}

--> greater invasion point
WorldQuestTracker.MapData.InvasionBosses = {
	--Legion
		[124625] = true, --mistress alluradel
		[124514] = true, --matron folnuna
		[124555] = true, --sotanathor
		[124492] = true, --occularus
		[124592] = true, --inquisitor meto
		[124719] = true, --pit lord vilemus
}

WorldQuestTracker.MapData.RaresLocations = {
	--Legion
		[126852] = {x = 55.7, y = 59.9}, --wrangler kravos
		[122958] = {x = 61.7, y = 37.2}, --blistermaw
		[127288] = {x = 63.1, y = 25.2}, --houndmaster kerrax
		[126912] = {x = 49.7, y = 9.9}, --skreeg the devourer
		[126867] = {x = 33.7, y = 47.5}, --venomtail skyfin
		[126862] = {x = 43.8, y = 60.2}, --baruut the bloodthirsty
		[127703] = {x = 58.50, y = 11.75}, --doomcaster suprax
		[126900] = {x = 61.4, y = 50.2}, --instructor tarahna
		[126860] = {x = 38.7, y = 55.8}, --kaara the pale
		[126419] = {x = 70.5, y = 33.7}, --naroua
		[126898] = {x = 44.2, y = 49.8}, --sabuul
		[126208] = {x = 64.3, y = 48.2}, --varga
		[127705] = {x = 65.5, y = 26.6}, --mother rosula
		[127706] = {x = 0, y = 0}, --rezira the seer (no coords?)
		[123464] = {x = 53.4, y = 30.9}, --sister subversia
		[127700] = {x = 77.4, y = 74.9}, --squadron commander vishax
		[126887] = {x = 30.3, y = 40.4}, --ataxon
		[126338] = {x = 61.9, y = 64.3}, --wrath lord yarez
		[120393] = {x = 58.0, y = 74.8}, --siegemaster voraan
		[127096] = {x = 75.6, y = 56.5}, --all seer xanarian
		[126199] = {x = 53.1, y = 35.8}, --vrax-thul
		[127376] = {x = 60.9, y = 22.9}, --chief alchemist munculus
		[127300] = {x = 55.7, y = 21.9}, --void warden valsuran
		[125820] = {x = 41.7, y = 70.2}, --imp mother laglath
		[125388] = {x = 60.8, y = 20.8}, --vagath the betrayed
		[123689] = {x = 55.5, y = 80.2}, --talestra the vile
		[127118] = {x = 50.9, y = 55.3}, --worldsplitter skuul
		[124804] = {x = 69.6, y = 57.5}, --tereck the selector
		[125479] = {x = 69.7, y = 80.5}, --tar spitter
		[122911] = {x = 	42.0, y = 57.1}, --commander vecaya
		[125824] = {x = 50.3, y = 17.3}, --khazaduum
		[122912] = {x = 33.0, y = 76.0}, --commander sathrenael
		[124775] = {x = 44.5, y = 58.7}, --commander endaxis
		[127704] = {x = 0, y = 0}, --soultender videx (no coords?)
		[126040] = {x = 65.6, y = 26.6}, --puscilla
		[127291] = {x = 52.7, y = 29.5}, --watcher aival
		[127090] = {x = 73.2, y = 70.8}, --admiral relvar
		[122999] = {x = 56.2, y = 45.5}, --garzoth
		[122947] = {x = 57.4, y = 32.9}, --mistress ilthendra
		[127581] = {x = 54.7, y = 39.1}, --the many faced devourer
		[126115] = {x = 62.9, y = 57.2}, --venorn
		[126254] = {x = 62.4, y = 53.8}, --lieutenant xakaar
		[127084] = {x = 80.5, y = 62.8}, --commander texlaz
		[126946] = {x = 61.1, y = 45.7}, --inquisitor vethroz
		[126865] = {x = 36.3, y = 23.6}, --vigilant thanos
		[126869] = {x = 27.2, y = 29.8}, --captain faruq
		[126896] = {x = 35.5, y = 58.7}, --herald of chaos
		[126899] = {x = 48.5, y = 40.9}, --jedhin champion vorusk
		[125497] = {x = 58.0, y = 30.9}, --overseer ysorna
		[126910] = {x = 56.8, y = 14.5}, --commander xethgar
		[126913] = {x = 49.5, y = 52.8}, --slithon the last
		[122838] = {x = 44.6, y = 71.6}, --shadowcaster voruun
		[126815] = {x = 53.0, y = 67.5}, --soultwisted monstrosity
		[126864] = {x = 41.3, y = 11.6}, --feasel the muffin thief
		[126866] = {x = 63.8, y = 64.6}, --vigilant kuro
		[126868] = {x = 39.2, y = 66.6}, --turek the lucid
		[126885] = {x = 35.2, y = 37.2}, --umbraliss
		[126889] = {x = 70.4, y = 46.7}, --sorolis the ill fated
		[124440] = {x = 59.2, y = 37.7}, --overseer ybeda
		[125498] = {x = 60.4, y = 29.7}, --overseer ymorna
		[126908] = {x = 64.0, y = 29.5}, --zultan the numerous
}

WorldQuestTracker.MapData.RaresQuestIDs = {
	--Legion
		[126338] = 48814, --wrathlord yarez
		[126852] = 48695, --wrangler kravos
		[122958] = 49183, --blistermaw
		[127288] = 48821, --houndmaster kerrax
		[126912] = 48721, --skreeg the devourer
		[126867] = 48705, --venomtail skyfin
		[126862] = 48700, --baruut the bloodthirsty
		[127703] = 48968, --doomcaster suprax
		[126900] = 48718, --instructor tarahna
		[126860] = 48697, --kaara the pale
		[126419] = 48667, --naroua
		[126898] = 48712, --sabuul
		[126208] = 48812, --varga
		[127705] = 48970, --mother rosula
		[127706] = 48971, --rezira the seer
		[123464] = 48565, --sister subversia
		[127700] = 48967, --squadron commander vishax
		[127581] = 48966, --the many faced devourer
		[126887] = 48709, --ataxon
		[126338] = 48814, --wrath-lord yarez
		[127090] = 48817, --admiral relvar
		[120393] = 48627, --siegemaster voraan
		[127096] = 48818, --all seer xanarian
		[126199] = 48810, --vrax-thul
		[127376] = 48865, --chief alchemist munculus
		[127300] = 48824, --void warden valsuran
		[125820] = 48666, --imp mother laglath
		[125388] = 48629, --vagath the betrayed
		[123689] = 48628, --talestra the vile
		[127118] = 48820, --worldsplitter skuul
		[124804] = 48664, --tereck the selector
		[125479] = 48665, --tar spitter
		[122911] = 48563, --commander vecaya
		[125824] = 48561, --khazaduum
		[122912] = 48562, --commander sathrenael
		[124775] = 48564, --commander endaxis
		[127704] = 48969, --soultender videx
		[126040] = 48809, --puscilla
		[127291] = 48822, --watcher aival
		[122999] = 49241, --garzoth
		[122947] = 49240, --mistress ilthendra
		[126115] = 48811, --venorn
		[126254] = 48813, --lieutenant xakaar
		[127084] = 48816, --commander texlaz
		[126946] = 48815, --inquisitor vethroz
		[126865] = 48703, --vigilant thanos
		[126869] = 48707, --captain faruq
		[126896] = 48711, --herald of chaos
		[126899] = 48713, --jedhin champion vorusk
		[125497] = 48716, --overseer ysorna
		[126910] = 48720, --commander xethgar
		[126913] = 48936, --slithon the last
		[122838] = 48692, --shadowcaster voruun
		[126815] = 48693, --soultwisted monstrosity
		[126864] = 48702, --feasel the muffin thief
		[126866] = 48704, --vigilant kuro
		[126868] = 48706, --turek the lucid
		[126885] = 48708, --umbraliss
		[126889] = 48710, --sorolis the ill fated
		[124440] = 48714, --overseer ybeda
		[125498] = 48717, --overseer ymorna
		[126908] = 48719, --zultan the numerous
}

WorldQuestTracker.MapData.RaresENNames = {
	--Legion
		[126338] = "wrath-lord yarez",
		[126852] = "wrangler kravos",
		[122958] = "blistermaw",
		[127288] = "houndmaster kerrax",
		[126912] = "skreeg the devourer",
		[126867] = "venomtail skyfin",
		[126862] = "baruut the bloodthirsty",
		[127703] = "doomcaster suprax",
		[126900] = "instructor tarahna",
		[126860] = "kaara the pale",
		[126419] = "naroua",
		[126898] = "sabuul",
		[126208] = "varga",
		[127705] = "mother rosula",
		[127706] = "rezira the seer",
		[123464] = "sister subversia",
		[127700] = "squadron commander vishax",
		[127581] = "the many faced devourer",
		[126887] = "ataxon",
		[127090] = "admiral rel'var",
		[120393] = "siegemaster voraan",
		[127096] = "all-seer xanarian",
		[126199] = "vrax'thul",
		[127376] = "chief alchemist munculus",
		[127300] = "void warden valsuran",
		[125820] = "imp mother laglath",
		[125388] = "vagath the betrayed",
		[123689] = "talestra the vile",
		[127118] = "worldsplitter skuul",
		[124804] = "tereck the selector",
		[125479] = "tar spitter",
		[122911] = "commander vecaya",
		[125824] = "khazaduum",
		[122912] = "commander sathrenael",
		[124775] = "commander endaxis",
		[127704] = "soultender videx",
		[126040] = "puscilla",
		[127291] = "watcher aival",
		[127090] = "admiral relvar",
		[122999] = "gar'zoth",
		[122947] = "mistress il'thendra",
		[127581] = "the many faced devourer",
		[126115] = "ven'orn",
		[126254] = "lieutenant xakaar",
		[127084] = "commander texlaz",
		[126946] = "inquisitor vethroz",
		[126865] = "vigilant thanos",
		[126869] = "captain faruq",
		[126896] = "herald of chaos",
		[126899] = "jed'hin champion vorusk",
		[125497] = "overseer y'sorna",
		[126910] = "commander xethgar",
		[126913] = "slithon the last",
		[122838] = "shadowcaster voruun",
		[126815] = "soultwisted monstrosity",
		[126864] = "feasel the muffin thief",
		[126866] = "vigilant kuro",
		[126868] = "turek the lucid",
		[126885] = "umbraliss",
		[126889] = "sorolis the ill-fated",
		[124440] = "overseer y'beda",
		[125498] = "overseer y'morna",
		[126908] = "zul'tan the numerous",

	--world bosses
	--Legion
		[124625] = "mistress alluradel",
		[124514] = "matron folnuna",
		[124555] = "sotanathor",
		[124492] = "occularus",
		[124592] = "inquisitor meto",
		[124719] = "pit lord vilemus",
}

WorldQuestTracker.MapData.RaresIgnored = {
	--Legion
		[127581] = true, --the many faced devourer
		[127703] = true, --doomcaster suprax
		[127706] = true, --rezira the seer
}

WorldQuestTracker.MapData.ENRareNameToZoneID = {
	--Legion
		["sister subversia"] = 1135,
		["admiral rel'var"] = 1171,
		["chief alchemist munculus"] = 1171,
		["wrangler kravos"] = 1170,
		["commander texlaz"] = 1171,
		["commander endaxis"] = 1135,
		["turek the lucid"] = 1170,
		["commander sathrenael"] = 1135,
		["baruut the bloodthirsty"] = 1170,
		["watcher aival"] = 1171,
		["captain faruq"] = 1170,
		["mistress il'thendra"] = 1171,
		["houndmaster kerrax"] = 1171,
		["mother rosula"] = 1171,
		["slithon the last"] = 1170,
		["puscilla"] = 1171,
		["imp mother laglath"] = 1135,
		["rezira the seer"] = 1171,
		["squadron commander vishax"] = 1171,
		["skreeg the devourer"] = 1170,
		["the many-faced devourer"] = 1171,
		["umbraliss"] = 1170,
		["varga"] = 1171,
		["ven'orn"] = 1171,
		["all-seer xanarian"] = 1171,
		["vigilant kuro"] = 1170,
		["vrax'thul"] = 1171,
		["gar'zoth"] = 1171,
		["blistermaw"] = 1171,
		["inquisitor vethroz"] = 1171,
		["lieutenant xakaar"] = 1171,
		["soultwisted monstrosity"] = 1170,
		["wrath-lord yarez"] = 1171,
		["zul'tan the numerous"] = 1170,
		["khazaduum"] = 1135,
		["vigilant thanos"] = 1170,
		["naroua"] = 1135,
		["siegemaster voraan"] = 1135,
		["talestra the vile"] = 1135,
		["tar spitter"] = 1135,
		["tereck the selector"] = 1135,
		["doomcaster suprax"] = 1171,
		["vagath the betrayed"] = 1135,
		["feasel the muffin thief"] = 1170,
		["herald of chaos"] = 1170,
		["instructor tarahna"] = 1170,
		["jed'hin champion vorusk"] = 1170,
		["kaara the pale"] = 1170,
		["void warden valsuran"] = 1171,
		["overseer y'beda"] = 1170,
		["overseer y'morna"] = 1170,
		["ataxon"] = 1170,
		["commander vecaya"] = 1135,
		["overseer y'sorna"] = 1170,
		["sabuul"] = 1170,
		["shadowcaster voruun"] = 1170,
		["worldsplitter skuul"] = 1171,
		["sorolis the ill-fated"] = 1170,
		["commander xethgar"] = 1170,
		["venomtail skyfin"] = 1170,
}
