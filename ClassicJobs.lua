-- Name:		ClassicJobs.lua
-- Created:		?
-- Prev. Modified?/Bulk of work:	January 16, 2022
-- Modified:	July 23, 2023

-- Author:		FreshFeeling (Kyle / RetroFreshTV)
-- Description:
--	Force the characters in Final Fantasy II into job roles.

-- RAM locations

-- This is the start of character data in EWRAM
characters_base_offset = 0x001F30

-- This is the increment between each of the four in-party characters
character_offsets = {0x0000,0x0080,0x0100,0x180}

-- These are the offsets of each of the attributes that we may modify.
character_identity = 0x00
status = 0x01
name_letter_1 = 0x0002
name_letter_2 = 0x0004
name_letter_3 = 0x0006
name_letter_4 = 0x0008
name_letter_5 = 0x000A
name_letter_6 = 0x000C
name_letter_7 = 0x000E
name_letter_8 = 0x0010
max_hp = 0x0014
current_mp = 0x0016
max_mp = 0x0018
strength_base = 0x001A
agility_base = 0x001B
stamina_base = 0x001C
intelligence_base = 0x001D
spirit_base = 0x001E
magic_base = 0x001F
spells = {0x003A, 0x003B, 0x003C, 0x003D, 0x003E, 0x003F, 0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047, 0x0048, 0x0049}
fist_experience = 0x004A
fist_level = 0x004B
knife_experience = 0x004C
knife_level = 0x004D
sword_experience = 0x004E
sword_level = 0x004F
staff_experience = 0x0050
staff_level = 0x0051
axe_experience = 0x0052
axe_level = 0x0053
spear_experience = 0x0054
spear_level = 0x0055
bow_experience = 0x0056
bow_level = 0x0057
shield_experience = 0x0058
shield_level = 0x0059
spell_experience = {0x005A, 0x005C, 0x005E, 0x0060, 0x0062, 0x0064, 0x0066, 0x0068, 0x006A, 0x006C, 0x006E, 0x0070, 0x0072, 0x0074, 0x0076, 0x0078}
spell_levels = {0x005B, 0x005D, 0x005F, 0x0061, 0x0063, 0x0065, 0x0067, 0x0069, 0x006B, 0x006D, 0x006F, 0x0071, 0x0073, 0x0075, 0x0077, 0x0079}

-- Store identity bytes for all characters. This allows us to "revert" to an existing state if a character is changed by the game's events.
character_1_previous_identity = memory.readbyte(characters_base_offset + character_offsets[1] + character_identity)
character_1_current_identity = memory.readbyte(characters_base_offset + character_offsets[1] + character_identity)
character_2_previous_identity = memory.readbyte(characters_base_offset + character_offsets[2] + character_identity)
character_2_current_identity = memory.readbyte(characters_base_offset + character_offsets[2] + character_identity)
character_3_previous_identity = memory.readbyte(characters_base_offset + character_offsets[3] + character_identity)
character_3_current_identity = memory.readbyte(characters_base_offset + character_offsets[3] + character_identity)
character_4_previous_identity = memory.readbyte(characters_base_offset + character_offsets[4] + character_identity)
character_4_current_identity = memory.readbyte(characters_base_offset + character_offsets[4] + character_identity)

-- Configure arrays for bytes for each of the core stats. These will make the functions that set these stats quite a bit more concise.
max_hp_bytes = {}
max_mp_bytes = {}
strength_bytes = {}
agility_bytes = {}
stamina_bytes = {}
intelligence_bytes = {}
spirit_bytes = {}
magic_bytes = {}
for character_index = 1, 4 do
	max_hp_bytes[character_index] = characters_base_offset + character_offsets[character_index] + max_hp
	max_mp_bytes[character_index] = characters_base_offset + character_offsets[character_index] + max_mp
	strength_bytes[character_index] = characters_base_offset + character_offsets[character_index] + strength_base
	agility_bytes[character_index] = characters_base_offset + character_offsets[character_index] + agility_base
	stamina_bytes[character_index] = characters_base_offset + character_offsets[character_index] + stamina_base
	intelligence_bytes[character_index] = characters_base_offset + character_offsets[character_index] + intelligence_base
	spirit_bytes[character_index] = characters_base_offset + character_offsets[character_index] + spirit_base
	magic_bytes[character_index] = characters_base_offset + character_offsets[character_index] + magic_base	
end

-- Arrays for each character's own stats, in case we're implementing some kind of force about their highest or lowest.
core_stats_bytes_1 = {characters_base_offset + character_offsets[1] + strength_base,
	characters_base_offset + character_offsets[1] + agility_base,
	characters_base_offset + character_offsets[1] + stamina_base,
	characters_base_offset + character_offsets[1] + intelligence_base,
	characters_base_offset + character_offsets[1] + spirit_base,
	characters_base_offset + character_offsets[1] + magic_base}
core_stats_bytes_2 = {characters_base_offset + character_offsets[2] + strength_base,
	characters_base_offset + character_offsets[2] + agility_base,
	characters_base_offset + character_offsets[2] + stamina_base,
	characters_base_offset + character_offsets[2] + intelligence_base,
	characters_base_offset + character_offsets[2] + spirit_base,
	characters_base_offset + character_offsets[2] + magic_base}
core_stats_bytes_3 = {characters_base_offset + character_offsets[3] + strength_base,
	characters_base_offset + character_offsets[3] + agility_base,
	characters_base_offset + character_offsets[3] + stamina_base,
	characters_base_offset + character_offsets[3] + intelligence_base,
	characters_base_offset + character_offsets[3] + spirit_base,
	characters_base_offset + character_offsets[3] + magic_base}
core_stats_bytes_4 = {characters_base_offset + character_offsets[4] + strength_base,
	characters_base_offset + character_offsets[4] + agility_base,
	characters_base_offset + character_offsets[4] + stamina_base,
	characters_base_offset + character_offsets[4] + intelligence_base,
	characters_base_offset + character_offsets[4] + spirit_base,
	characters_base_offset + character_offsets[4] + magic_base}


-- Force a character to be a knight named Scott. Or Firion.
function force_character_knight(position)
	-- Find character's identity byte.
	idbyte = characters_base_offset + character_offsets[position] + character_identity
	-- Force it to "0", representing Firion.
	-- or "A", representing Scott.
	memory.writebyte(idbyte, 0x0A)

	-- Get the character's letter bytes.
	letter1byte = characters_base_offset + character_offsets[position] + name_letter_1
	letter2byte = characters_base_offset + character_offsets[position] + name_letter_2
	letter3byte = characters_base_offset + character_offsets[position] + name_letter_3
	letter4byte = characters_base_offset + character_offsets[position] + name_letter_4
	letter5byte = characters_base_offset + character_offsets[position] + name_letter_5
	letter6byte = characters_base_offset + character_offsets[position] + name_letter_6
	letter7byte = characters_base_offset + character_offsets[position] + name_letter_7
	
	-- memory.write_u16_le(letter1byte, 0x6582) -- F
	-- memory.write_u16_le(letter2byte, 0x8982) -- i
	-- memory.write_u16_le(letter3byte, 0x9282) -- r
	-- memory.write_u16_le(letter4byte, 0x8982) -- i
	-- memory.write_u16_le(letter5byte, 0x8F82) -- o
	-- memory.write_u16_le(letter6byte, 0x8E82) -- n
	-- memory.write_u16_le(letter7byte, 0x0000) -- [end]

	memory.write_u16_le(letter1byte, 0x7282) -- S
	memory.write_u16_le(letter2byte, 0x8382) -- c
	memory.write_u16_le(letter3byte, 0x8F82) -- o
	memory.write_u16_le(letter4byte, 0x9482) -- t
	memory.write_u16_le(letter5byte, 0x9482) -- t
	memory.write_u16_le(letter6byte, 0x0000) -- [end]
end

-- Force a character to be a black mage named Maria.
function force_character_black_mage(position)
	-- Find character's identity byte.
	idbyte = characters_base_offset + character_offsets[position] + character_identity
	-- Force it to "1", representing Maria.
	memory.writebyte(idbyte, 1)

	-- Get the character's letter bytes.
	letter1byte = characters_base_offset + character_offsets[position] + name_letter_1
	letter2byte = characters_base_offset + character_offsets[position] + name_letter_2
	letter3byte = characters_base_offset + character_offsets[position] + name_letter_3
	letter4byte = characters_base_offset + character_offsets[position] + name_letter_4
	letter5byte = characters_base_offset + character_offsets[position] + name_letter_5
	letter6byte = characters_base_offset + character_offsets[position] + name_letter_6

	memory.write_u16_le(letter1byte, 0x6C82) -- M
	memory.write_u16_le(letter2byte, 0x8182) -- a
	memory.write_u16_le(letter3byte, 0x9282) -- r
	memory.write_u16_le(letter4byte, 0x8982) -- i
	memory.write_u16_le(letter5byte, 0x8182) -- a
	memory.write_u16_le(letter6byte, 0x0000) -- [end]

end

-- Force a character to be a white mage named Minwu.
function force_character_white_mage(position)
	-- Find character's identity byte.
	idbyte = characters_base_offset + character_offsets[position] + character_identity
	-- Force it to "3", representing Minwu.
	memory.writebyte(idbyte, 3)

	-- Get the character's letter bytes.
	letter1byte = characters_base_offset + character_offsets[position] + name_letter_1
	letter2byte = characters_base_offset + character_offsets[position] + name_letter_2
	letter3byte = characters_base_offset + character_offsets[position] + name_letter_3
	letter4byte = characters_base_offset + character_offsets[position] + name_letter_4
	letter5byte = characters_base_offset + character_offsets[position] + name_letter_5
	letter6byte = characters_base_offset + character_offsets[position] + name_letter_6

	memory.write_u16_le(letter1byte, 0x6C82) -- M
	memory.write_u16_le(letter2byte, 0x8982) -- i
	memory.write_u16_le(letter3byte, 0x8E82) -- n
	memory.write_u16_le(letter4byte, 0x9782) -- w
	memory.write_u16_le(letter5byte, 0x9582) -- u
	memory.write_u16_le(letter6byte, 0x0000) -- [end]

end

-- Force a character to be a thief named Leila.
function force_character_thief(position)
	-- Find character's identity byte.
	idbyte = characters_base_offset + character_offsets[position] + character_identity
	-- Force it to "6", representing Leila.
	memory.writebyte(idbyte, 06)

	-- Get the character's letter bytes.
	letter1byte = characters_base_offset + character_offsets[position] + name_letter_1
	letter2byte = characters_base_offset + character_offsets[position] + name_letter_2
	letter3byte = characters_base_offset + character_offsets[position] + name_letter_3
	letter4byte = characters_base_offset + character_offsets[position] + name_letter_4
	letter5byte = characters_base_offset + character_offsets[position] + name_letter_5
	letter6byte = characters_base_offset + character_offsets[position] + name_letter_6

	memory.write_u16_le(letter1byte, 0x6B82) -- L
	memory.write_u16_le(letter2byte, 0x8582) -- e
	memory.write_u16_le(letter3byte, 0x8982) -- i
	memory.write_u16_le(letter4byte, 0x8C82) -- l
	memory.write_u16_le(letter5byte, 0x8182) -- a
	memory.write_u16_le(letter6byte, 0x0000) -- [end]

end

function initialize_all_characters()
	-- Force character identities by slot.
	force_character_knight(1)
	force_character_thief(2)
	force_character_white_mage(3)
	force_character_black_mage(4)

	-- This loop sets all stats to a minimum value, all weapon skills to 1, and all spell slots to 0 for all characters.
	for i = 1, 4 do
		-- This part sets base values for stats, based on lowest normal game values.
		memory.write_u16_le(characters_base_offset + character_offsets[i] + max_hp, 0x0014)
		memory.write_u16_le(characters_base_offset + character_offsets[i] + max_hp - 0x0002, 0x0014)
		memory.write_u16_le(characters_base_offset + character_offsets[i] + current_mp, 0x0001)
		memory.write_u16_le(characters_base_offset + character_offsets[i] + max_mp, 0x0003)
		memory.writebyte(characters_base_offset + character_offsets[i] + strength_base, 0x03)
		memory.writebyte(characters_base_offset + character_offsets[i] + agility_base, 0x03)
		memory.writebyte(characters_base_offset + character_offsets[i] + stamina_base, 0x03)
		memory.writebyte(characters_base_offset + character_offsets[i] + intelligence_base, 0x03)
		memory.writebyte(characters_base_offset + character_offsets[i] + spirit_base, 0x03)
		memory.writebyte(characters_base_offset + character_offsets[i] + magic_base, 0x03)

		-- This part nullifies weapon experience and sets weapon levels to 1.
		memory.writebyte(characters_base_offset + character_offsets[i] + fist_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + fist_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + knife_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + knife_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + sword_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + sword_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + staff_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + staff_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + axe_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + axe_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + spear_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + spear_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + bow_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + bow_experience, 0x00)
		memory.writebyte(characters_base_offset + character_offsets[i] + shield_level, 0x01)
		memory.writebyte(characters_base_offset + character_offsets[i] + shield_experience, 0x00)
		
		-- This part nullifies the spells known, spell levels, and spell experience.
		for spell = 1, 16 do
			memory.writebyte(characters_base_offset + character_offsets[i] + spells[spell], 0x00)
			memory.writebyte(characters_base_offset + character_offsets[i] + spell_experience[spell], 0x00)
			memory.writebyte(characters_base_offset + character_offsets[i] + spell_levels[spell], 0x01)
		end
		
	end

	-- Set slot 1's initial equipment as a knight.
	memory.writebyte(0x001F53, 0x53) -- Right hand broadsword
	memory.writebyte(0x001F54, 0x31) -- Left hand buckler
	memory.writebyte(0x001F55, 0x70) -- Head leather helmet
	memory.writebyte(0x001F56, 0x7B) -- Body leather armor
	memory.writebyte(0x001F57, 0x8E) -- Hands leather glove
	
	-- Set slot 2's initial equipment as a thief.
	memory.writebyte(0x001F53 + character_offsets[2], 0x3B) -- Right hand dagger
	memory.writebyte(0x001F54 + character_offsets[2], 0x00) -- Left hand empty
	memory.writebyte(0x001F55 + character_offsets[2], 0x00) -- Head empty
	memory.writebyte(0x001F56 + character_offsets[2], 0x7B) -- Body leather armor
	memory.writebyte(0x001F57 + character_offsets[2], 0x8E) -- Hands leather glove
	
	-- Set slot 4's initial equipment as a black mage.
	memory.writebyte(0x001F53 + character_offsets[4], 0x41) -- Right hand cane
	memory.writebyte(0x001F54 + character_offsets[4], 0x00) -- Left hand empty
	memory.writebyte(0x001F55 + character_offsets[4], 0x00) -- Head empty
	memory.writebyte(0x001F56 + character_offsets[4], 0x7A) -- Body clothes
	memory.writebyte(0x001F57 + character_offsets[4], 0x00) -- Hands empty
	memory.writebyte(characters_base_offset + character_offsets[4] + spells[1], 0x01) -- Fire spell
	memory.writebyte(characters_base_offset + character_offsets[4] + spells[2], 0x02) -- Thunder spell
	memory.writebyte(characters_base_offset + character_offsets[4] + spells[3], 0x03) -- Blizzard spell

	-- Set slot 3's initial equipment as a white mage.
	memory.writebyte(0x001F53 + character_offsets[3], 0x41) -- Right hand cane
	memory.writebyte(0x001F54 + character_offsets[3], 0x00) -- Left hand empty
	memory.writebyte(0x001F55 + character_offsets[3], 0x00) -- Head empty
	memory.writebyte(0x001F56 + character_offsets[3], 0x7A) -- Body clothes
	memory.writebyte(0x001F57 + character_offsets[3], 0x00) -- Hands empty
	memory.writebyte(characters_base_offset + character_offsets[3] + spells[1], 0x15) -- Cure spell
	memory.writebyte(characters_base_offset + character_offsets[3] + spell_levels[1], 0x02) -- Cure spell level	

end

-- Record an entire character's stats to an array.
function record_character(position)
	address = characters_base_offset + character_offsets[position]
	
	return memory.read_bytes_as_array(address, 0x80, "EWRAM")

end

-- Overwrite an entire character's stats using an array.
function overwrite_character(position, character_stats)
    address = characters_base_offset + character_offsets[position]
	
	memory.write_bytes_as_array(address, character_stats, "EWRAM")
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_highest_byte(address_to_change, stat_address_array)
	highest = 0
	
	-- Identify the highest value among all characters.
	for i = 1, 4 do
		if memory.readbyte(stat_address_array[i]) > highest then
			highest = memory.readbyte(stat_address_array[i])
		end
	end

	-- Max value = 99 / 0x63.
	if highest >= 0x63 then
		highest = 0x63
	end

	-- If less than highest, set it to tie highest.
	if memory.readbyte(address_to_change) < highest then
		memory.writebyte(address_to_change, highest)
	end
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_highest_word(address_to_change, stat_address_array)
	highest = 0
	
	-- Identify the highest value among all characters.
	for i = 1, 4 do
		if memory.read_u16_le(stat_address_array[i]) > highest then		
			highest = memory.read_u16_le(stat_address_array[i])
		end
	end

	-- Max value = 9999.
	if highest >= 9999 then
		highest = 9999
	end

	-- If less than highest, set it to tie highest.
	if memory.read_u16_le(address_to_change) < highest then
		memory.write_u16_le(address_to_change, highest)
	end
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_not_highest_byte(address_to_change, stat_address_array)
	highest = 0
	
	-- Identify the highest value among all characters.
	for i = 1, 4 do
		if memory.readbyte(stat_address_array[i]) > highest then
			highest = memory.readbyte(stat_address_array[i])
		end
	end
	
	-- If this character is highest, set the value to highest - 1.
	if memory.readbyte(address_to_change) >= highest then
		memory.writebyte(address_to_change, highest - 1)
	end
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_not_highest_word(address_to_change, stat_address_array)
	highest = 0
	
	-- Identify the highest value among all characters.
	for i = 1, 4 do
		if memory.read_u16_le(stat_address_array[i]) > highest then
			highest = memory.read_u16_le(stat_address_array[i])
		end
	end

	-- Max value = 9999.
	if highest > 9999 then
		highest = 9999
	end
	
	-- If this character is highest, set the value to highest - 1.
	if memory.read_u16_le(address_to_change) >= highest then
			memory.write_u16_le(address_to_change, highest - 1)
	end
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_not_lowest_byte(address_to_change, stat_address_array)
	lowest = 0x63
	
	-- Identify the lowest value among all characters.
	for i = 1, 4 do
		if memory.readbyte(stat_address_array[i]) < lowest then
			lowest = memory.readbyte(stat_address_array[i])
		end
	end

	-- Minimum value is 1.
	if lowest < 0x01 then
		lowest = 0x01
	end

	-- If lowest, set value to lowest + 1.
	if memory.readbyte(address_to_change) <= lowest then
			memory.writebyte(address_to_change, lowest + 1)
	end
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_not_lowest_word(address_to_change, stat_address_array)
	lowest = 0x270F
	
	-- Identify the lowest value among all characters.
	for i = 1, 4 do
		if memory.read_u16_le(stat_address_array[i]) < lowest then
			lowest = memory.read_u16_le(stat_address_array[i])
		end
	end

	-- Minimum value is 1.
	if lowest < 1 then
		lowest = 1
	end

	-- If lowest, set value to lowest + 1.
	if memory.read_u16_le(address_to_change) <= lowest then
			memory.write_u16_le(address_to_change, lowest + 1)
	end
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_lowest_byte(address_to_change, stat_address_array)
	lowest = 0x63
	
	-- Identify the lowest value among all characters.
	for i = 1, 4 do
		if memory.readbyte(stat_address_array[i]) < lowest then
			lowest = memory.readbyte(stat_address_array[i])
		end
	end

	-- Minimum value is 1.
	if lowest < 0x01 then
		lowest = 0x01
	end

	-- If not lowest, set value to lowest.
	if memory.readbyte(address_to_change) < lowest then
			memory.writebyte(address_to_change, lowest)
	end
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to the highest value.
function set_lowest_word(address_to_change, stat_address_array)
	lowest = 0x270F
	
	-- Identify the lowest value among all characters.
	for i = 1, 4 do
		if memory.read_u16_le(stat_address_array[i]) < lowest then
			lowest = memory.read_u16_le(stat_address_array[i])
		end
	end

	-- Minimum value is 1.
	if lowest < 1 then
		lowest = 1
	end
	
	-- If not lowest, set value to lowest.
	if memory.read_u16_le(address_to_change) <= lowest then
		memory.write_u16_le(address_to_change, lowest)
	end
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to at least the average value.
function set_above_average_byte(address_to_change, stat_address_array)
	average = 0
	highest = 0
	total = 0
	current_value = memory.readbyte(address_to_change)
	
	-- Calculate the total among other characters and identify the highest value.
	for i = 1, 4 do
		-- We do not consider this character's own value since that may cause this calculation to roll up like crazy.
		if address_to_change ~= stat_address_array[i] then
			total = total + memory.readbyte(stat_address_array[i])
			if memory.readbyte(stat_address_array[i]) > highest then
				highest = memory.readbyte(stat_address_array[i])
			end
		end
	end

	-- Calculate the average value.
	average = total / 3

	-- If less than average, set it to average +1. If higher than highest, set it to highest - 1.
	if current_value <= average then
		current_value = average + 1
	elseif current_value >= highest then
		current_value = highest - 1
	end

	memory.writebyte(address_to_change, current_value)
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to at least the average value.
function set_above_average_word(address_to_change, stat_address_array)
	average = 0
	highest = 0
	total = 0
	current_value = memory.read_u16_le(address_to_change)

	-- Calculate the total among other characters and identify the highest value.
	for i = 1, 4 do
		-- We do not consider this character's own value since that may cause this calculation to roll up like crazy.
		if address_to_change ~= stat_address_array[i] then
			total = total + memory.read_u16_le(stat_address_array[i])
			if memory.read_u16_le(stat_address_array[i]) > highest then
				highest = memory.read_u16_le(stat_address_array[i])
			end
		end
	end

	-- Calculate the average value.
	average = total / 3

	-- If less than average, set it to average +1. If higher than highest, set it to highest - 1.
	if current_value <= average then
		current_value = average + 1
	elseif current_value >= highest then
		current_value = highest - 1
	end

	memory.write_u16_le(address_to_change, current_value)
end

-- Function to compare a single byte to an array of the current party's values in the stat. Sets the value at the given address equal to less than the average value.
function set_below_average_byte(address_to_change, stat_address_array)
	lowest = 0x270F
	average = 0
	total = 0
	current_value = memory.readbyte(address_to_change)

	-- Calculate the total among other characters and identify the lowest value.
	for i = 1, 4 do
		-- We do not consider this character's own value since that may cause this calculation to roll up like crazy.
		if address_to_change ~= stat_address_array[i] then
			total = total + memory.readbyte(stat_address_array[i])
			if memory.readbyte(stat_address_array[i]) < lowest then
				lowest = memory.readbyte(stat_address_array[i])
			end
		end
	end

	-- Calculate the average value.
	average = total / 3

	-- If above average, set it to average - 1. If lower than lowest, set it to lowest + 1.
	if current_value >= average then
		current_value = average - 1
	elseif current_value <= lowest then
		current_value = lowest + 1
	end

	memory.writebyte(address_to_change, current_value)
end

-- Function to compare two bytes to an array of the current party's values in the stat. Sets the value at the given address equal to less than the average value.
function set_below_average_word(address_to_change, stat_address_array)
	lowest = 0x270F
	average = 0
	total = 0
	current_value = memory.read_u16_le(address_to_change)

	-- Calculate the total among other characters and identify the lowest value.
	for i = 1, 4 do
		-- We do not consider this character's own value since that may cause this calculation to roll up like crazy.
		if address_to_change ~= stat_address_array[i] then
			total = total + memory.read_u16_le(stat_address_array[i])
			if memory.read_u16_le(stat_address_array[i]) < lowest then
				lowest = memory.read_u16_le(stat_address_array[i])
			end
		end
	end

	-- Calculate the average value.
	average = total / 3

	-- If above average, set it to average - 1. If lower than lowest, set it to lowest + 1.
	if current_value >= average then
		current_value = average - 1
	elseif current_value <= lowest then
		current_value = lowest + 1
	end

	memory.write_u16_le(address_to_change, current_value)
end

-- Function to force a byte to at least a minimum value.
function set_minimum_byte(address_to_change, minimum_value)
	if memory.readbyte(address_to_change) < minimum_value then
		memory.writebyte(address_to_change, minimum_value)
	end
end

-- Function to force a two-byte value to at least a minimum value.
function set_minimum_word(address_to_change, minimum_value)
	if memory.read_u16_le(address_to_change) < minimum_value then
		memory.write_u16_le(address_to_change, minimum_value)
	end
end

-- Function to force a byte to at cap at a maximum value.
function set_maximum_byte(address_to_change, maximum_value)
	if memory.readbyte(address_to_change) > maximum_value then
		memory.writebyte(address_to_change, maximum_value)
	end
end

-- Function to force a two-byte value to at cap at a maximum value.
function set_maximum_word(address_to_change, maximum_value)
	if memory.read_u16_le(address_to_change) > maximum_value then
		memory.write_u16_le(address_to_change, maximum_value)
	end
end

-- Main loop!
while true do

	memory.usememorydomain("EWRAM")

	-- Uncomment this line for the first run of the script to force initial identities, equips and base stats.
	-- If I were really smart, this would be a separate one-time script. But I'm not.
    -- initialize_all_characters()

	-- An arbitrary pause in how often identity checks are done to ease processing.
	-- Really, even if this only happened every 5 seconds (300 frames) it would probably be fine and almost unnoticeable.
	-- Try to ensure it doesn't share a low GCD with the next segment. Maybe make it a prime between 50 and 250 or something.
	if emu.framecount() % 173 == 0 then

		-- Get all characters' current identities.
		-- We're doing this to detect changes, and if a character's identity changes we have to replace them with their assigned class/character.
		character_1_current_identity = memory.readbyte(characters_base_offset + character_offsets[1] + character_identity)
		character_2_current_identity = memory.readbyte(characters_base_offset + character_offsets[2] + character_identity)
		character_3_current_identity = memory.readbyte(characters_base_offset + character_offsets[3] + character_identity)
		character_4_current_identity = memory.readbyte(characters_base_offset + character_offsets[4] + character_identity)

    	-- Check if character 1 changed.
		if character_1_current_identity ~= character_1_previous_identity then
			-- If character 1 changed, make them a knight and overwrite their stats.
			force_character_knight(1)
			overwrite_character(1, character_1_stats)
			character_1_previous_identity = character_1_current_identity
		else
			-- If character 1 has not changed, make a copy of them to be used if they change later.
			character_1_stats = record_character(1)
		end

		-- Check if character 2 changed.
		if character_2_current_identity ~= character_2_previous_identity then
			-- If character 2 changed, make them a knight and overwrite their stats.
			force_character_black_mage(2)
			overwrite_character(2, character_2_stats)
			character_2_previous_identity = character_2_current_identity
		else
			-- If character 2 has not changed, make a copy of them to be used if they change later.
			character_2_stats = record_character(2)
		end

		-- Check if character 3 changed.
		if character_3_current_identity ~= character_3_previous_identity then
			-- If character 3 changed, make them a knight and overwrite their stats.
			force_character_white_mage(3)
			overwrite_character(3, character_3_stats)
			character_3_previous_identity = character_3_current_identity
		else
			-- If character 3 has not changed, make a copy of them to be used if they change later.
			character_3_stats = record_character(3)
		end

		-- Check if character 4 changed.
		if character_4_current_identity ~= character_4_previous_identity then
			-- If character 4 changed, make them a knight and overwrite their stats.
			force_character_thief(4)
			overwrite_character(4, character_4_stats)
			character_4_previous_identity = character_4_current_identity
		else
			-- If character 4 has not changed, make a copy of them to be used if they change later.
			character_4_stats = record_character(4)
		end
	end

	-- An arbitrary pause in how often stats forces are done to ease processing.
	-- This should probably be under 2 seconds (120 frames) to ensure stats are balanced between two fights on neighbouring tiles.
	if emu.framecount() % 60 == 0 then

		-- Force Knight stats!
		-- Max HP highest, min 100.
		set_highest_word(characters_base_offset + character_offsets[1] + character_identity + max_hp, max_hp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[1] + character_identity + max_hp, 0x0064)
		-- Max MP below average, min 1.
		set_below_average_word(characters_base_offset + character_offsets[1] + character_identity + max_mp, max_mp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[1] + character_identity + max_mp, 0x0001)
		-- Strength highest, min 15, max 99.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + strength_base, 0x63)
		set_highest_byte(characters_base_offset + character_offsets[1] + character_identity + strength_base, strength_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + strength_base, 0x0F)
		-- Spirit middle, min 9, max 80.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + spirit_base, 0x50)
		set_not_highest_byte(characters_base_offset + character_offsets[1] + character_identity + spirit_base, spirit_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[1] + character_identity + spirit_base, spirit_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + spirit_base, 0x09)
		-- Intelligence lowest, min 3, max 60.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + intelligence_base, 0x3C)
		set_lowest_byte(characters_base_offset + character_offsets[1] + character_identity + intelligence_base, intelligence_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + intelligence_base, 0x03)
		-- Stamina highest, min 12, max 90.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + stamina_base, 0x5A)
		set_highest_byte(characters_base_offset + character_offsets[1] + character_identity + stamina_base, stamina_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + stamina_base, 0x0C)
		-- Agility lowest, min 6, max 70.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + agility_base, 0x46)
		set_lowest_byte(characters_base_offset + character_offsets[1] + character_identity + agility_base, agility_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + agility_base, 0x06)
		-- Magic middle, min 3, max 60.
		set_maximum_byte(characters_base_offset + character_offsets[1] + character_identity + magic_base, 0x3C)
		set_not_highest_byte(characters_base_offset + character_offsets[1] + character_identity + magic_base, magic_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[1] + character_identity + magic_base, magic_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + magic_base, 0x03)
		-- Sword level min 3.
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + sword_level, 0x03)
		-- Shield level min 2.
		set_minimum_byte(characters_base_offset + character_offsets[1] + character_identity + shield_level, 0x02)

		-- Force Black Mage stats!
		-- Max HP lowest, min 20.
		set_lowest_word(characters_base_offset + character_offsets[4] + character_identity + max_hp, max_hp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[4] + character_identity + max_hp, 0x0014)
		-- Max MP highest, min 40.
		set_maximum_word(characters_base_offset + character_offsets[4] + character_identity + max_mp, 0x03E7)
		set_highest_word(characters_base_offset + character_offsets[4] + character_identity + max_mp, max_mp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[4] + character_identity + max_mp, 0x0028)
		-- Strength lowest, min 3, max 60.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + strength_base, 0x3C)
		set_lowest_byte(characters_base_offset + character_offsets[4] + character_identity + strength_base, strength_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + strength_base, 0x03)
		-- Spirit middle, min 6, max 70.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + spirit_base, 0x46)
		set_not_highest_byte(characters_base_offset + character_offsets[4] + character_identity + spirit_base, spirit_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[4] + character_identity + spirit_base, spirit_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + spirit_base, 0x06)
		-- Intelligence highest, min 15, max 99.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + intelligence_base, 0x63)
		set_highest_byte(characters_base_offset + character_offsets[4] + character_identity + intelligence_base, intelligence_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + intelligence_base, 0x0F)
		-- Stamina lowest, min 3, max 60.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + stamina_base, 0x3C)
		set_lowest_byte(characters_base_offset + character_offsets[4] + character_identity + stamina_base, stamina_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + stamina_base, 0x03)
		-- Agility middle, min 9, max 80.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + agility_base, 0x50)
		set_not_highest_byte(characters_base_offset + character_offsets[4] + character_identity + agility_base, agility_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[4] + character_identity + agility_base, agility_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + agility_base, 0x09)
		-- Magic highest, min 15, max 99.
		set_maximum_byte(characters_base_offset + character_offsets[4] + character_identity + magic_base, 0x63)
		set_highest_byte(characters_base_offset + character_offsets[4] + character_identity + magic_base, magic_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[4] + character_identity + magic_base, 0x0F)
		
		-- Force White Mage stats!
		-- Max HP middle, min 25.
		set_not_highest_word(characters_base_offset + character_offsets[3] + character_identity + max_hp, max_hp_bytes)
		set_not_lowest_word(characters_base_offset + character_offsets[3] + character_identity + max_hp, max_hp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[3] + character_identity + max_hp, 0x0019)
		-- Max MP above average, min 40.
		set_above_average_word(characters_base_offset + character_offsets[3] + character_identity + max_mp, max_mp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[3] + character_identity + max_mp, 0x0028)
		-- Strength below average, min 6, max 70.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + strength_base, 0x46)
		set_below_average_byte(characters_base_offset + character_offsets[3] + character_identity + strength_base, strength_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + strength_base, 0x06)
		-- Spirit highest, min 15, max 99.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + spirit_base, 0x63)
		set_highest_byte(characters_base_offset + character_offsets[3] + character_identity + spirit_base, spirit_bytes)	
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + spirit_base, 0x0F)
		-- Intelligence middle, min 12, max 90.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + intelligence_base, 0x5A)
		set_not_highest_byte(characters_base_offset + character_offsets[3] + character_identity + intelligence_base, intelligence_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[3] + character_identity + intelligence_base, intelligence_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + intelligence_base, 0x0C)
		-- Stamina middle, min 9, max 80.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + stamina_base, 0x50)
		set_not_highest_byte(characters_base_offset + character_offsets[3] + character_identity + stamina_base, stamina_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[3] + character_identity + stamina_base, stamina_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + stamina_base, 0x09)
		-- Agility middle, min 9, max 80.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + agility_base, 0x50)
		set_not_highest_byte(characters_base_offset + character_offsets[3] + character_identity + agility_base, agility_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[3] + character_identity + agility_base, agility_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + agility_base, 0x09)
		-- Magic above average, min 12, max 90.
		set_maximum_byte(characters_base_offset + character_offsets[3] + character_identity + magic_base, 0x5A)
		set_above_average_byte(characters_base_offset + character_offsets[3] + character_identity + magic_base, magic_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[3] + character_identity + magic_base, 0x0C)
		
		-- Force Thief stats!
		-- Max HP middle, min 35.
		set_not_highest_word(characters_base_offset + character_offsets[2] + character_identity + max_hp, max_hp_bytes)
		set_not_lowest_word(characters_base_offset + character_offsets[2] + character_identity + max_hp, max_hp_bytes)
		set_minimum_word(characters_base_offset + character_offsets[2] + character_identity + max_hp, 0x0023)
		-- Max MP 0.
		memory.write_u16_le(characters_base_offset + character_offsets[2] + character_identity + current_mp, 0x0000)
		memory.write_u16_le(characters_base_offset + character_offsets[2] + character_identity + max_mp, 0x0000)
		-- Strength middle, min 9, max 80.
		set_maximum_byte(characters_base_offset + character_offsets[2] + character_identity + strength_base, 0x50)
		set_not_highest_byte(characters_base_offset + character_offsets[2] + character_identity + strength_base, strength_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[2] + character_identity + strength_base, strength_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + strength_base, 0x09)
		-- Spirit lowest, min 3, max 60.
		set_maximum_byte(characters_base_offset + character_offsets[2] + character_identity + spirit_base, 0x3C)
		set_lowest_byte(characters_base_offset + character_offsets[2] + character_identity + spirit_base, spirit_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + spirit_base, 0x03)
		-- Intelligence middle, min 6, max 70.
		set_maximum_byte(characters_base_offset + character_offsets[2] + character_identity + intelligence_base, 0x46)
		set_not_highest_byte(characters_base_offset + character_offsets[2] + character_identity + intelligence_base, intelligence_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[2] + character_identity + intelligence_base, intelligence_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + intelligence_base, 0x6)
		-- Stamina middle, min 6, max 70.
		set_maximum_byte(characters_base_offset + character_offsets[2] + character_identity + stamina_base, 0x46)
		set_not_highest_byte(characters_base_offset + character_offsets[2] + character_identity + stamina_base, stamina_bytes)
		set_not_lowest_byte(characters_base_offset + character_offsets[2] + character_identity + stamina_base, stamina_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + stamina_base, 0x06)
		-- Agility highest, min 15, max 99.
		set_maximum_byte(characters_base_offset + character_offsets[2] + character_identity + agility_base, 0x63)
		set_highest_byte(characters_base_offset + character_offsets[2] + character_identity + agility_base, agility_bytes)
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + agility_base, 0x0F)
		-- Magic 1.
		memory.writebyte(characters_base_offset + character_offsets[2] + character_identity + magic_base, 0x01)
		-- Knife level min 2.
		set_minimum_byte(characters_base_offset + character_offsets[2] + character_identity + knife_level, 0x02)

	end

	emu.frameadvance();
end