-- send-to-pleco
-- Requires adb
-- Sends the current subtitle to be viewed in Pleco on Android via ADB.

local mp = require("mp")
local utils = require("mp.utils")

local last_subtitle = ""

local function is_empty(s)
	return s == nil or s == ""
end

-- https://stackoverflow.com/a/43419070
local function is_utf32_char_chinese(c)
	return c ~= nil
		and ((c >= 0x3400 and c <= 0x4DBF) or (c >= 0x4E00 and c <= 0x9FFF) or (c >= 0xF900 and c <= 0xFAFF))
end

-- https://lua-users.org/wiki/LuaUnicode
local function is_chinese(s)
	if is_empty(s) then
		return false
	end

	local seq, val = 0, nil
	for i = 1, #s do
		local c = s:byte(i)
		if seq == 0 then
			if is_utf32_char_chinese(val) then
				return true
			end
			seq = c < 0x80 and 1
				or c < 0xE0 and 2
				or c < 0xF0 and 3
				or c < 0xF8 and 4 --c < 0xFC and 5 or c < 0xFE and 6 or
				or error("invalid UTF-8 character sequence")
			val = bit32.band(c, 2 ^ (8 - seq) - 1)
		else
			val = bit32.bor(bit32.lshift(val, 6), bit32.band(c, 0x3F))
		end
		seq = seq - 1
	end
	return is_utf32_char_chinese(val)
end

-- https://rosettacode.org/wiki/URL_encoding#Lua
local function urlencode(str)
	local output, t = str:gsub("[^%w]", function(char)
		return string.format("%%%X", string.byte(char))
	end)
	return output
end

local function send_to_pleco(text)
	-- Strip newlines and clean up whitespace.
	-- https://lua-users.org/wiki/StringTrim
	local new_text, t = text:gsub("\n", " ")
	new_text, t = new_text:gsub("^%s*(.-)%s*$", "%1")
	new_text, t = new_text:gsub("%s+", " ")
	mp.commandv(
		"run",
		"adb",
		"shell",
		"am",
		"start",
		"-a",
		"android.intent.action.VIEW",
		"-d",
		"plecoapi://x-callback-url/s?q=" .. urlencode(new_text)
	)
end

mp.observe_property("sub-text", "string", function(prop, subtitle)
	if subtitle ~= last_subtitle and is_chinese(subtitle) then
		last_subtitle = subtitle
		send_to_pleco(subtitle)
	end
end)
