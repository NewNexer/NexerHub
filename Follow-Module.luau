local module = {}

function IsFollowedTo(userid)

local function valid_url(which, cursor)
local qqz = which or 1
local zzx = (cursor and "&cursor="..cursor.."") or "&cursor="
if qqz == 1 then
return "https://friends.roblox.com/v1/users/"..game.Players.LocalPlayer.UserId.."/followings?sortOrder=Des&limit=100"..zzx
else
return "https://friends.roproxy.com/v1/users/"..game.Players.LocalPlayer.UserId.."/followings?sortOrder=Des&limit=100"..zzx
end
end

local Success, Fail = pcall(function()
ft = {}
Decode = nil
repeat
if Decode == nil then
Decode = game:GetService("HttpService"):JSONDecode(game:HttpGet(ReturnURL(1))) or game:GetService("HttpService"):JSONDecode(game:HttpGet(ReturnURL("backup")))
end
if not Decode["data"] or Decode["errors"] then return false end
for i,v in pairs(Decode["data"]) do
if v ~= nil and v["id"] then
table.insert(ft, v["id"])
end
end
if Decode["nextPageCursor"] ~= nil then
Decode = nil
Decode = game:GetService("HttpService"):JSONDecode(game:HttpGet(ReturnURL(1, Decode["nextPageCursor"]))) or game:GetService("HttpService"):JSONDecode(game:HttpGet(ReturnURL("backup", Decode["nextPageCursor"])))
end
until Decode["nextPageCursor"] == nil
if table.find(ft,tonumber(userid)) then
return true, "Success."
end
return false, "Fail."
end)

if not Success then
return true, "Unknown error occured."
end
end

function module:IsFollowedTo(userid)
return IsFollowedTo(userid)
end

return module
