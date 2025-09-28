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

function Notify(title, content, time, mode)
time = time or 4
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
local GetRequestMethod = function()
local iqnd = request or http_request or HttpPost or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (game and game.HttpPost) or (KRNL and KRNL.request) or (Xeno and Xeno.request)
if iqnd then
return iqnd
else
return nil
end
end

local Window = Rayfield:CreateWindow({
   Name = "DOD:NH - Launcher",
   Icon = 0,    
   LoadingTitle = "DOD:NH - Launcher",
   LoadingSubtitle = "by nexer",
   Theme = "Amethyst",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = false,
      FolderName = "",
      FileName = ""
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
Notify("Success!", "Copied Link!", 4, true)
end

function OpenLink(link)
local url = tostring(link)
if WebHandler then
local suc, err = pcall(function() WebHandler:OpenRBX(url) end) if not suc then CopyLink(url) end
else
CopyLink(url)
end
end

Main:CreateParagraph({Title = "Follow Requirement", Content = "This script was very difficult to create, so please, support me by following me on roblox!"})

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
loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Main.luau"))()
else
Notify("Error!", "You aren't followed! ( But if you're 100% sure that you're followed, wait for about 5 minutes and try again )", 10)
end
end; })
