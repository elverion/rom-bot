include("addresses.lua");
include("functions.lua");

-- Note: We get 'char' and 'macro' data from functions.lua
-- because it is used in other scripts.


--[[
	Required:
	pattern		The pattern, obviously.
	mask		...The mask?
	offset		Offset from the start of the pattern that the requested data exists.
	startloc	Where to start the search, in bytes

	Optional:
	searchlen	The length, in bytes, to continue searching (default: 0xA0000)
	adjustment	How many bytes to adjust the returned value forward or backward (default: 0)
	size		The length, in bytes, of the data (default: 4)
	comment		A string of text that will be appended in the output
]]

local updatePatterns =
{
	staticbase_char = {
		pattern = getCharUpdatePattern(),
		mask = getCharUpdateMask(),
		offset = getCharUpdateOffset(),
		startloc = 0x5A0000,
	},

	staticbase_macro = {
		pattern = getMacroUpdatePattern(),
		mask = getMacroUpdateMask(),
		offset = getMacroUpdateOffset(),
		startloc = 0x700000,
	},

	charPtr_offset = {
		pattern = string.char(0x8B, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC0, 0x74, 0xFF, 0x8B, 0x80),
		mask = "xx????xxx?xx",
		offset = 2,
		startloc = 0x5A0000,
	},

	mousePtr_offset = {
		pattern = string.char(0x80, 0xBD, 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0x8B, 0x95, 0xFF, 0xFF, 0xFF, 0xFF),
		mask = "xx????xxx????",
		offset = 9,
		startloc = 0x5F0000,
	},

	camPtr_offset = {
		pattern = string.char(0xFF, 0xD2, 0x8B, 0x8E, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0xD8),
		mask = "xxxx????xx",
		offset = 4,
		startloc = 0x5E0000,
	},

	camXUVec_offset = {
		pattern = string.char(0xD9, 0x5C, 0x24, 0x08, 0xD9, 0x82, 0xFF, 0xFF, 0xFF, 0xFF, 0xD9, 0x5C, 0x24),
		mask = "xxxxxx????xxx",
		offset = 6,
		startloc = 0x440000,
	},

	camX_offset = {
		pattern = string.char(0xD9, 0x82, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x57, 0xC9, 0xD8, 0xA2, 0xFF, 0xFF, 0xFF, 0xFF),
		mask = "xx????xxxxx????",
		offset = 11,
		startloc = 0x440000,
	},

	pawnCasting_offset = {
		pattern = string.char(0xC2, 0x04, 0x00, 0xD9, 0x44, 0x24, 0x04, 0xD9, 0x81, 0xFF, 0xFF, 0xFF, 0xFF),
		mask = "xxxxxxxxx????",
		offset = 9,
		startloc = 0x820000,
	},

	charAlive_offset = {
		pattern = string.char(0x88, 0x44, 0x24, 0xFF, 0x8A, 0x87, 0xFF, 0xFF, 0xFF, 0xFF),
		mask = "xxx?xx????",
		offset = 6,
		startloc = 0x5E0000,
	},

	charBattle_offset = {
		pattern = string.char(0x89, 0x44, 0x24, 0x20, 0x8A, 0x86, 0xFF, 0xFF, 0xFF, 0xFF, 0xF6, 0xD8),
		mask = "xxxxxx????xx",
		offset = 6,
		startloc = 0x5E0000,
	},

	pawnHarvesting_offset = {
		pattern = string.char(0x5F, 0x89, 0xAE, 0xFF, 0xFF, 0xFF, 0xFF, 0x89, 0xAE, 0xFF, 0xFF, 0xFF, 0xFF, 0x89, 0xAE),
		mask = "xxx????xx????xx",
		offset = 9,
		startloc = 0x820000,
		adjustment = 0x3C,
	},

	-- Note: We add 10 bytes to the value gained from this
	macroBody_offset = {
		pattern = string.char(0x0F, 0x84, 0xFF, 0xFF, 0xFF, 0xFF, 0x38, 0x98, 0xFF, 0xFF, 0xFF, 0xFF, 0x8D, 0xB8),
		mask = "xx????xx????xx",
		offset = 8,
		startloc = 0x7A0000,
		adjustment = 0x10,
	},

	staticTablePtr = {
		pattern = string.char(0x7E, 0xFF, 0x53, 0x56, 0x57, 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x3C, 0xA8, 0x8B, 0x1D),
		mask = "x?xxxx????xxxxx",
		offset = 6,
		startloc = 0x820000,
	},

	staticTableSize = {
		pattern = string.char(0x85, 0xFF, 0x74, 0x09, 0x57, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF,
			0x83, 0xC4, 0x04, 0x8B, 0x15, 0xFF, 0xFF, 0xFF, 0xFF, 0x52),
		mask = "xxxxxx????xxxxx????x",
		offset = 15,
		startloc = 0x620000,
	},

	ping_offset = {
		pattern = string.char(0xFF, 0xD2, 0xEB, 0x17, 0x8B, 0x85, 0xFF, 0xFF, 0xFF, 0xFF, 0x03, 0x85),
		mask = "xxxxxx????xx",
		offset = 6,
		startloc = 0x5FA000,
	},

	staticEquipBase = {
		pattern = string.char(0x0F, 0x8D, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0xC8, 0xE9, 0xFF, 0xFF, 0xFF, 0xFF, 0xB8, 0xFF, 0xFF, 0xFF, 0xFF, 0x8D, 0x64, 0x24),
		mask = "xx????xxx????x????xxx",
		offset = 14,
		startloc = 0x5E0000,
	},

	boundStatusOffset = {
		pattern = string.char(0x51, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x43, 0xFF, 0x8B, 0x13),
		mask = "xx????xx?xx",
		offset = 8,
		startloc = 0x820000,
		size = 1,
	},

	durabilityOffset = {
		pattern = string.char(0x03, 0xC2, 0x8B, 0x4B, 0xFF, 0x3B, 0xC8, 0x75),
		mask = "xxxx?xxx",
		offset = 4,
		startloc = 0x690000,
		size = 1,
	},

	idCardNPCOffset = {
		pattern = string.char(0x75, 0xFF, 0x8B, 0x91, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x35),
		mask = "x?xx????xx",
		offset = 4,
		startloc = 0x680000,
	},

	nameOffset = {
		pattern = string.char(0x50, 0xE9, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x41, 0xFF, 0x5E),
		mask = "xx????xx?x",
		offset = 8,
		startloc = 0x680000,
		size = 1,
	},

	requiredLevelOffset = {
		pattern = string.char(0x83, 0xEC, 0xFF, 0x8B, 0xF4, 0x8D, 0x4C, 0x24, 0xFF, 0x89, 0x64, 0x24, 0xFF, 0x51),
		mask = "xx?xxxxx?xxx?x",
		offset = 8,
		startloc = 0x780000,
		size = 1,
	},

	itemCountOffset = {
		pattern = string.char(0xEB, 0xFF, 0x8B, 0x4E, 0xFF, 0x89, 0x4C, 0x24),
		mask =  "x?xx?xxx",
		offset = 4,
		startloc = 0x760000,
		size = 1,
	},

	inUseOffset = {
		pattern = string.char(0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x6E, 0xFF, 0x56),
		mask = "xx????xx?x",
		offset = 8,
		startloc = 0x760000,
		size = 1,
	},

	maxDurabilityOffset = {
		pattern = string.char(0x0F, 0xB6, 0x4D, 0xFF, 0x0F, 0xAF, 0x8E),
		mask = "xxx?xxx",
		offset = 3,
		startloc = 0x6A0000,
		size = 1,
	},

	charMaxExpTable_address = {
		pattern = string.char(
			0x56, 0xFF, 0x15, 0xFF, 0xFF, 0xFF, 0xFF,
			0x83, 0xC4, 0xFF, 0x89, 0x1D, 0xFF, 0xFF,
			0xFF, 0xFF, 0xA1, 0xFF, 0xFF, 0xFF, 0xFF,
			0x8B, 0x35, 0xFF, 0xFF, 0xFF, 0xFF, 0x3B,
			0xF0, 0x8B, 0xF8, 0x76, 0x18, 0xFF, 0xD5,
			0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x35,
			0xFF, 0xFF, 0xFF, 0xFF, 0x3B, 0xF0, 0x76,
			0x07, 0xFF, 0xD5, 0xA1, 0xFF, 0xFF, 0xFF,
			0xFF, 0x3B, 0xF7, 0x74, 0x26, 0x2B, 0xC7,
			0xC1, 0xF8, 0xFF, 0x85, 0xC0, 0x8D, 0x0C,
			0x85, 0x00, 0x00, 0x00, 0x00, 0x8D, 0x1C,
			0x0E, 0x7E, 0x0D, 0x51, 0x57, 0x51, 0x56,
			0xFF, 0x15, 0xFF, 0xFF, 0xFF, 0xFF, 0x83,
			0xC4, 0xFF, 0x89, 0x1D, 0xFF, 0xFF, 0xFF,
			0xFF, 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B,
			0x35, 0xFF, 0xFF, 0xFF, 0xFF, 0x3B, 0xF0
			),
		mask = "xxx????xx?xx????x????xx????xxxxxxxxx????xx????xxxxxxx????xxxxxxxx?xxxxxxxxxxxxxxxxxxxx????xx?xx????x????xx????xx",
		offset = 106,
		startloc = 0x615000,
	},

	pawnLootable_offset = {
		pattern = string.char(0x8B, 0xC8,
0xE8, 0xFF, 0xFF, 0xFF, 0xFF,
0xD9, 0x5C, 0x24, 0xFF,
0xF6, 0x86, 0xFF, 0xFF, 0xFF, 0xFF, 0x04,
0x0F, 0x84),
		mask = "xxx????xxx?xx????xxx",
		offset = 13,
		startloc = 0x5E0000,
	},

	charPtrMounted_offset = {
		pattern = string.char(0x83, 0x79, 0xFF, 0x00, 0x74, 0x0C, 0xF6, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x74, 0x03, 0xB0, 0x01),
		mask = "xx?xxxxx?????xxxx",
		offset = 2,
		startloc = 0x840000,
		size = 1,
	},

	realItemIdOffset = {
		pattern = string.char(0x8B, 0xF0, 0xEB, 0xA5, 0x8B, 0x89, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC9),
		mask = "xxxxxx????xx",
		offset = 6,
		startloc = 0x6A0000,
	},

	coolDownOffset = {
		pattern = string.char(0x75, 0x4F, 0xF3, 0x0F, 0x2A, 0x88, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x2F, 0xC1),
		mask = "xxxxxx????xxx",
		offset = 6,
		startloc = 0x6A0000,
	},

	idOffset = {
		pattern = string.char(0x8B, 0x46, 0xFF, 0x8B, 0xFA, 0x99),
		mask = "xx?xxx",
		offset = 2,
		startloc = 0x820000,
		size = 1,
	},

	pawnClass1_offset = {
		pattern = string.char(0xC7, 0x40, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x91, 0xFF, 0xFF, 0xFF, 0xFF, 0x83, 0xFA),
		mask = "xx?????xx????xx",
		offset = 9,
		startloc = 0x5E0000,
	},

	pawnClass2_offset = {
		pattern = string.char(0x89, 0x10, 0x8B, 0x89, 0xFF, 0xFF, 0xFF, 0xFF, 0x83, 0xF9, 0xFF, 0x77),
		mask = "xxxx????xx?x",
		offset = 4,
		startloc = 0x5E0000,
	},

	pawnDirXUVec_offset = {
		pattern = string.char(0xCC, 0x8B, 0x44, 0x24, 0xFF, 0xD9, 0x41, 0xFF, 0xD9, 0x18, 0xD9, 0x41, 0xFF, 0xD9, 0x58, 0xFF, 0xD9,
			0x41, 0xFF, 0xD9, 0x58, 0xFF, 0xC2, 0x04, 0x00, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xF3);
		mask = "xxxx?xx?xxxx?xx?xx?xx?xxxxxxxxxxxx",
		offset = 7,
		startloc = 0x840000,
		size = 1,
	},

	pawnDirZUVec_offset = {
		pattern = string.char(0xD9, 0x58, 0xFF, 0xD9, 0x41, 0xFF, 0xD9, 0x58, 0xFF, 0xC2, 0x04, 0x00, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xF3),
		mask = "xx?xx?xx?xxxxxxxxxxxx",
		offset = 5,
		startloc = 0x840000,
		size = 1,
	},

	pawnHP_offset = {
		pattern = string.char(0x74, 0xFF, 0x8B, 0x88, 0xFF, 0xFF, 0xFF, 0xFF, 0x2B, 0x88),
		mask = "x?xx????xx",
		offset = 4,
		startloc = 0x7E0000,
	},

	pawnId_offset = {
		pattern = string.char(0x55, 0x8B, 0x6C, 0x24, 0x08, 0x56, 0x8B, 0xF1, 0x39, 0x6E, 0xFF, 0x75, 0x07, 0x5E),
		mask = "xxxxxxxxxx?xxx",
		offset = 10,
		startloc = 0x820000,
		size = 1,
	},

	pawnLevel_offset = {
		pattern = string.char(0x56, 0x89, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0x89, 0x91, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x35),
		mask = "xxx????xx????xx",
		offset = 3,
		startloc = 0x840000,
	},

	pawnLevel2_offset = {
		pattern = string.char(0x56, 0x89, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0x89, 0x91, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x35),
		mask = "xxx????xx????xx",
		offset = 9,
		startloc = 0x840000,
	},

	pawnMP_offset = {
		pattern = string.char(0x74, 0xFF, 0x8B, 0x8E, 0xFF, 0xFF, 0xFF, 0xFF, 0x33, 0xD2, 0x85, 0xC9),
		mask = "x?xx????xxxx",
		offset = 4,
		startloc = 0x840000,
	},

	pawnMaxHP_offset = {
		pattern = string.char(0x52, 0x8B, 0xCE, 0x89, 0x86, 0xFF, 0xFF, 0xFF, 0xFF, 0xE8),
		mask = "xxxxx????x",
		offset = 5,
		startloc = 0x840000,
	},

	pawnMaxMP_offset = {
		pattern = string.char(0x33, 0xD2, 0x85, 0xC9, 0x0F, 0x9C, 0xC2, 0x89, 0x86, 0xFF, 0xFF, 0xFF, 0xFF, 0x83, 0xEA, 0x01),
		mask = "xxxxxxxxx????xxx",
		offset = 9,
		startloc = 0x840000,
	},

	pawnMount_offset = {
		pattern = string.char(0xCC, 0x8A, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0xA8, 0x01, 0x74, 0xFF, 0xA8, 0x02),
		mask = "xxx????xxx?xx",
		offset = 3,
		startloc = 0x840000,
	},

	pawnName_offset = {
		pattern = string.char(0xC3, 0x8D, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0xC3, 0x8B, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC0, 0x75),
		mask = "xxx????xxx????xxx",
		offset = 10,
		startloc = 0x840000,
	},


	pawnPetPtr_offset = {
		pattern = string.char(0x81, 0xEC, 0x80, 0x00, 0x00, 0x00,
0x53,
0x55,
0x8B, 0xAC, 0x24, 0x8C, 0x00, 0x00, 0x00,
0x8B, 0x8D, 0x84, 0x02, 0x00, 0x00,
0x56,
0x33, 0xDB,
0x85, 0xC9,
0x57,
0x7E, 0x17,
0x8B, 0x85, 0x80, 0x02, 0x00, 0x00,
0x83, 0xC0, 0x08),
		mask = "xxxxxxxxxxx????xx????xxxxxxxxxx????xxx",
		offset = 31,
		startloc = 0x4A0000,
	},

	pawnRace_offset = {
		pattern = string.char(0xC3,
		0x83, 0xEC, 0x28,
		0x56,
		0x8B, 0xF1,
		0x83, 0xBE, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
		0x57),
		mask = "xxxxxxxxx????xx",
		offset = 9,
		startloc = 0x75F000,
	},

	pawnTargetPtr_offset = {
		pattern = string.char(0x85, 0xC0, 0x75, 0x3F, 0x85, 0xED, 0x74, 0x08, 0x8B, 0x85, 0xFF, 0xFF, 0xFF, 0xFF, 0xEB, 0x0C),
		mask = "xxxxxxxxxx????xx",
		offset = 10,
		startloc = 0x5F0000,
	},

	pawnType_offset = {
		pattern = string.char(0xFF, 0xD0, 0x8B, 0x46, 0xFF, 0x83, 0xE8, 0x02, 0x74, 0x09, 0x83, 0xE8, 0x02),
		mask = "xxxx?xxxxxxxx",
		offset = 4,
		startloc = 0x850000,
		size = 1,
	},

	pawnX_offset = {
		pattern = string.char(0x8B, 0x44, 0x24, 0x04, 0xD9, 0x41, 0xFF, 0xD9, 0x18, 0xD9, 0x41, 0xFF, 0xD9, 0x58, 0x04, 0xD9, 0x41, 0xFF, 0xD9, 0x58, 0xFF, 0xC2, 0x04, 0x00),
		mask = "xxxxxx?xxxx?xxxxx?xx?xxx",
		offset = 6,
		startloc = 0x840000,
		size = 1,
	},

	qualityBaseOffset = {
		pattern = string.char(0x74, 0x15, 0x85, 0xF6, 0x8B, 0x40, 0xFF, 0x74, 0x10, 0x0F, 0xB6, 0x4E),
		mask = "xxxxxx?xxxxx",
		offset = 6,
		startloc = 0x600000,
		size = 1,
	},

	qualityTierOffset = {
		pattern = string.char(0x77, 0x19, 0x83, 0x7B, 0xFF, 0x01, 0x7F, 0x13, 0x8A, 0x4F, 0xFF, 0x80, 0xE1),
		mask = "xxxx?xxxxx?xx",
		offset = 10,
		startloc = 0x790000,
		size = 1,
	},

	valueOffset = {
		pattern = string.char(0x50, 0xFF, 0xD2, 0x8B, 0x4F, 0xFF, 0x83, 0xC1, 0xFF, 0xB8),
		mask = "xxxxx?xx?x",
		offset = 5,
		startloc = 0x790000,
		size = 1,
	},

	loadingScreen_offset = {
		pattern = string.char(0xFF, 0xD2, 0xDD, 0x05, 0xFF, 0xFF, 0xFF, 0xFF, 0xC6, 0x46, 0x0FF, 0xFF, 0xD9, 0x44, 0x24, 0xFF, 0xDF, 0xF1),
		mask = "xxxx????xx??xxx?xx",
		offset = 10,
		startloc = 0x7B0000,
		size = 1,
	},

	loadingScreenPtr = {
		pattern = string.char(0xFF, 0xD0, 0x80, 0x7E, 0xFF, 0xFF, 0x0F, 0x85, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x85, 0xC9, 0x0F, 0x84),
		mask = "xxxx??xx????xx????xxxx",
		offset = 14,
		startloc = 0x5E0000,
	},

	hotkeysKey_offset = {
		pattern = string.char(0x50, 0x57, 0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0XFF, 0x8B, 0x01, 0x8B, 0x56, 0xFF, 0x8B, 0x80),
		mask = "xxx????xx????xxxx?xx",
		offset = 17,
		startloc = 0x7B0000,
		size = 1,
	},

	hotkeys_offset = {
		pattern = string.char(0xE9, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x6B, 0xFF, 0x39, 0x6B, 0xFF, 0x76, 0x06, 0xFF, 0x15, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x7B, 0xFF, 0x3B),
		mask = "x????xx?xx?xxxx????xx?x",
		offset = 21,
		startloc = 0x7B0000,
		size = 1,
	},

	hotkeysPtr = {
		pattern = string.char(0x66, 0x85, 0xC0, 0x7D, 0x06, 0x81, 0xCE, 0x00, 0x00, 0x04, 0x00, 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x01, 0x8B, 0x90),
		mask = "xxxxxxxxxxxxx????xxxx",
		offset = 13,
		startloc = 0x740000,
	},

	actionBarPtr = {
		pattern = string.char(0xBF, 0xFF, 0xFF, 0xFF, 0xFF, 0xB9, 0x07, 0x00, 0x00, 0x00, 0x33, 0xC0, 0xF3, 0xA6, 0x75, 0x68, 0x8B, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF,
			0xE8, 0xFF, 0xFF, 0xFF, 0xFF, 0x5E, 0x5F, 0x5B, 0xC2, 0x14, 0x00),
		mask = "x????xxxxxxxxxxxxx????x????xxxxxx",
		offset = 18,
		startloc = 0x5E0000,
	},

	eggPetMaxExpTablePtr = {
		pattern = string.char(0x83, 0xC4, 0x10, 0x8B, 0xCB, 0x89, 0x0D, 0xFF, 0xFF, 0xFF, 0xFF, 0xA1, 0xFF, 0xFF, 0xFF, 0xFF, 0x8B, 0x35, 0xFF, 0xFF, 0xFF, 0xFF, 0x3B, 0xF0),
		mask = "xxxxxxx????x????xx????xx",
		offset = 18,
		startloc = 0x610000
	},
}


-- This function will attempt to automatically find the true addresses
-- from RoM, even if they have moved.
-- Only works on MicroMacro v1.0 or newer.
function findOffsets()
	for name,values in pairs(updatePatterns) do
		local found = 0;
		local readFunc = nil;
		local pattern = values["pattern"];
		local mask = values["mask"];
		local offset = values["offset"];
		local startloc = values["startloc"];
		local searchlen = values["searchlen"] or 0xA0000;
		local adjustment = values["adjustment"] or 0;
		local size = values["size"] or 4;
		local comment = values["comment"] or "";

		found = findPatternInProcess(getProc(), pattern, mask, startloc, searchlen);
		if( found == 0 ) then
			error("Unable to find \'" .. name .. "\' in module.", 0);
		end

		if( size == 1 ) then
			readFunc = memoryReadUByte;
		elseif( size == 2 ) then
			readFunc = memoryReadUShort;
		elseif( size == 4 ) then
			readFunc = memoryReadUInt
		else -- default, assume 4 bytes
			readFunc = memoryReadUInt;
		end

		addresses[name] = readFunc(getProc(), found + offset) + adjustment;
		local msg = sprintf("Patched addresses.%s\t (value: 0x%X, at: 0x%X)", name, addresses[name], found + offset);
		printf(msg .. "\n");
		logMessage(msg);

		-- Special cases; record found locations
		if( name == "staticbase_char" ) then
			addresses.staticpattern_char = found;
		elseif( name == "staticbase_macro" ) then
			addresses.staticpattern_macro = found;
		end
	end

	-- Assumption-based updating.
	-- Not very accurate, but is quick-and-easy for those
	-- hard to track values.
	printf("\n\n");
	local function assumptionUpdate(name, newValue)
		local assumptionUpdateMsg = "Assuming information for \'addresses.%s\'; now 0x%X, was 0x%X\n";
		printf(assumptionUpdateMsg, name, newValue, addresses[name]);
		addresses[name] = newValue;
	end

	assumptionUpdate("pawnMP2_offset", addresses.pawnMP_offset + 8);
	assumptionUpdate("pawnMaxMP2_offset", addresses.pawnMaxMP_offset + 8);
	assumptionUpdate("pawnY_offset", addresses.pawnX_offset + 4);
	assumptionUpdate("pawnZ_offset", addresses.pawnX_offset + 8);
	assumptionUpdate("camYUVec_offset", addresses.camXUVec_offset + 4);
	assumptionUpdate("camZUVec_offset", addresses.camXUVec_offset + 8);
	assumptionUpdate("camY_offset", addresses.camX_offset + 4);
	assumptionUpdate("camZ_offset", addresses.camX_offset + 8);
	assumptionUpdate("moneyPtr", addresses.staticInventory + 0x2FD4);
	assumptionUpdate("charExp_address", addresses.staticbase_char + 0x6C);
end

function rewriteAddresses()
	local filename = getExecutionPath() .. "/addresses.lua";
	getProc(); -- Just to make sure we open the process first

	printf("Scanning for updated addresses...\n");
	findOffsets();
	printf("Finished.\n");

	local addresses_new = {};
	for i,v in pairs(addresses) do
		table.insert(addresses_new, {index = i, value = v});
	end

	-- Sort alphabetically by index
	local function addressSort(tab1, tab2)
		if( tab1.index < tab2.index ) then
			return true;
		end

		return false;
	end
	table.sort(addresses_new, addressSort);

	local file = io.open(filename, "w");

	file:write(
		sprintf("-- Auto-generated by update.lua\n") ..
		"addresses = {\n"
	);

	for i,v in pairs(addresses_new) do
		local comment = "";
		if( updatePatterns[v.index] ) then
			local tmp = updatePatterns[v.index].comment;
			if( tmp ) then
				comment = "\t--[[ " .. tmp .. " ]]";
			end
		end
		file:write( sprintf("\t%s = 0x%X,%s\n", v.index, v.value, comment) );
	end

	file:write("}\n");

	file:close();

end
rewriteAddresses();
