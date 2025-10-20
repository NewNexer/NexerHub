local module = {}

function OpenRBX(url)
--a:LoadWebbrowser("https://google.com")
game:GetService("GuiService"):BroadcastNotification(game:GetService("HttpService"):JSONEncode({["title"] = "Roblox", ["presentationStyle"] = 2, ["visible"] = true, ["url"] = tostring(url)}), 20)
end

function module:OpenRBX(url)
OpenRBX(url)
end

return module
