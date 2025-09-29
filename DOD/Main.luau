function ConvertDropdownValue(tbl)
if type(tbl) == "table" then
for _,element in ipairs(tbl) do
return tostring(element)
end
else
return tostring(tbl)
end
end

local WebHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Web-Module.luau"))()
local GetRequestMethod = function()
local iqnd = request or http_request or HttpPost or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (game and game.HttpPost) or (KRNL and KRNL.request) or (Xeno and Xeno.request)
if iqnd then
return iqnd
else
return nil
end
end
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

local Window = Rayfield:CreateWindow({
   Name = "Die of Death : Nexer Hub",
   Icon = 0,    
   LoadingTitle = "DOD:NH",
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

local LocalPlayer, LP = game.Players.LocalPlayer, game.Players.LocalPlayer
local Character, Char
local HumanoidRootPart, HRP
local Humanoid, Hum
pcall(function()
Character, Char = LocalPlayer.Character, LocalPlayer.Character
end)
pcall(function()
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
end)
pcall(function()
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)

LocalPlayer.CharacterAdded:Connect(function()
Character, Char = nil, nil
HumanoidRootPart, HRP = nil, nil
Humanoid, Hum = nil, nil
task.wait()
repeat task.wait() until LocalPlayer.Character
Character, Char = LocalPlayer.Character, LocalPlayer.Character
task.wait()
repeat task.wait() until Character:FindFirstChild("HumanoidRootPart")
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
task.wait()
repeat task.wait() until Character:FindFirstChild("Humanoid")
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)

pcall(function()
StaminaModule = require(LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Movement"))
end)

function SetStaminaProperty(property, value)
if property == "MaxStamina" then
Char:SetAttribute("MaxStamina", value)
elseif property == "Stamina" then
if StaminaModule then
StaminaModule["Stamina"] = value
end
elseif property == "Fatigue" then
Char:SetAttribute("Fatigue", value)
elseif property == "WalkSpeed" then
Hum.WalkSpeed = value
elseif property == "SprintSpeed" then
Char:SetAttribute("SprintSpeed", value)
elseif property == "CanJump" then
if value == true then Hum.JumpPower = 50 else Hum.JumpPower = 0 end
end
end

local Tab_1 = Window:CreateTab("Stamina",0)

Tab_1:CreateParagraph({Title = "Stamina", Content = "You can change your stamina properties here."})

Tab_1:CreateSection("Fast Functions")

Tab_1:CreateButton({Name = "Infinite Stamina"; Callback = function()
SetStaminaProperty("MaxStamina", (1/0))
SetStaminaProperty("Stamina", (1/0))
end; })

Tab_1:CreateButton({Name = "Become Fast"; Callback = function()
SetStaminaProperty("WalkSpeed", 50)
SetStaminaProperty("SprintSpeed", 70)
end; })

Tab_1:CreateButton({Name = "Enable/Disable Jump"; Callback = function()
if Hum.JumpPower == 0 then
SetStaminaProperty("CanJump", true)
else
SetStaminaProperty("CanJump", false)
end
end; })

Tab_1:CreateSection("Advanced Editing")

Tab_1:CreateInput({Name = "Max Stamina"; PlaceholderText = "Type Here!"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
SetStaminaProperty("MaxStamina", tonumber(Value))
end; })

Tab_1:CreateInput({Name = "Stamina"; PlaceholderText = "Type Here!"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
SetStaminaProperty("Stamina", tonumber(Value))
end; })

Tab_1:CreateInput({Name = "Walk Speed"; PlaceholderText = "Type Here!"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
SetStaminaProperty("WalkSpeed", tonumber(Value))
end; })

Tab_1:CreateInput({Name = "Sprint Speed"; PlaceholderText = "Type Here!"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
SetStaminaProperty("SprintSpeed", tonumber(Value))
end; })

Tab_1:CreateButton({Name = "Enable/Disable Fatigue"; Callback = function()
if Char:GetAttribute("Fatigue") and Char:GetAttribute("Fatigue") == true then
SetStaminaProperty("Fatigue", false)
else
SetStaminaProperty("Fatigue", true)
end
end; })

local Tab_2 = Window:CreateTab("Emotes",0)

Tab_2:CreateParagraph({Title = "Emotes", Content = "Functions that are related to emotes."})

Tab_2:CreateSection("ITZZZZ PARTY TIME!!!!")

Tab_2:CreateButton({Name = "Open Emote Selection"; Callback = function()
LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("EmoteSelection").Visible = true
LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("EmoteSelection").Active = true
end; })

Tab_2:CreateButton({Name = "Use Dance"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote"):FireServer("Dance")
end; })

Tab_2:CreateButton({Name = "Use Squingle"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote"):FireServer("Squingle")
end; })

Tab_2:CreateButton({Name = "Use Gangnam Style"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote"):FireServer("Gangnam Style")
end; })

Tab_2:CreateButton({Name = "Use PBJ"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote"):FireServer("PBJ")
end; })

Tab_2:CreateButton({Name = "Use Tornado"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote"):FireServer("Tornado")
end; })
