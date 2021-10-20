-- send-to-pleco
-- Requires adb
-- Sends the current subtitle to be viewed in Pleco on Android via ADB.

require("mp")

-- https://rosettacode.org/wiki/URL_encoding#Lua
local function urlencode(str)
	local output, t = str:gsub("[^%w]", function(char)
		return string.format("%%%X", string.byte(char))
	end)
	return output
end

function send_to_pleco()
	local subtitle = mp.get_property("sub-text")
	mp.commandv(
		"run",
		"adb",
		"shell",
		"am",
		"start",
		"-a",
		"android.intent.action.VIEW",
		"-d",
		"plecoapi://x-callback-url/s?q=" .. urlencode(subtitle)
	)
	mp.osd_message("Sent to Pleco.")
end

mp.add_key_binding("a", "send-to-pleco", send_to_pleco)
