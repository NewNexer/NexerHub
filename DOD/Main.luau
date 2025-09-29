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







--------------------------------







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



--------------------------------


local AbilityNames = {"Cloak","Punch","Taunt","BonusPad","Block","Caretaker","Dash","Hotdog","Revolver","Adrenaline","Banana"}

local AbilityDatas = {
    ["Adrenaline"] = {Name = "Adrenaline",InputShown = "",Tip = "Get a temporary speed boost for 6 seconds, highlighting you to your teamates and slowing you down after it\'s over.",Cooldown = 35,Icon = "rbxassetid://116399911657417",DisplayName = "Adrenaline"};
    ["Punch"] = {Name = "Punch",InputShown = "",Tip = "Swing foward stunning any killers hit for 3 seconds, if missed you\'ll get severe endlag.",Cooldown = 40,Icon = "rbxassetid://97428323453639",DisplayName = "Punch"};
    ["Caretaker"] = {Name = "Caretaker",InputShown = "",Tip = "Splash a potion infront of you, any survivors hit will heal 20 HP in total. Having this ability makes you lose 75 max health though!",Cooldown = 30,Icon = "rbxassetid://90712805517714",DisplayName = "Caretaker"};
    ["Cloak"] = {Name = "Cloak",InputShown = "",Tip = "Becoming heavily slowed but invisible for a short amount of time, Killers can still hit you though!",Cooldown = 50,Icon = "rbxassetid://90476367580326",DisplayName = "Cloak"};
    ["Block"] = {Name = "Block",InputShown = "",Tip = "Try blocking any form of damage, if successful heal 10 HP, get a speed boost and negate all the damage.",Cooldown = 40,Icon = "rbxassetid://120929805037270",DisplayName = "Block"};
    ["Dash"] = {Name = "Dash",InputShown = "",Tip = "Dash foward, after you will get fatigue for 2 seconds which slows stamina regeneration and makes it drain faster.",Cooldown = 20,Icon = "rbxassetid://73777691791017",DisplayName = "Dash"};
    ["BonusPad"] = {Name = "BonusPad",InputShown = "",Tip = "Build a temporary speed pad that speeds up any survivor who steps on it. Having this ability makes you lose 10 max health though!",Cooldown = 70,Icon = "rbxassetid://86775625332300",DisplayName = "BonusPad"};
    ["Hotdog"] = {Name = "Hotdog",InputShown = "",Tip = "Eat a hotdog, healing 15 HP at the cost of 10 stamina.",Cooldown = 15,Icon = "rbxassetid://134322360499381",DisplayName = "Hotdog"};
    ["Revolver"] = {Name = "Revolver",InputShown = "",Tip = "Shoot with your revolver stunning any killers hit for 2 seconds, you\'ll have to reload after. Having this ability makes you lose 20 max stamina though!",Cooldown = 15,Icon = "rbxassetid://107624957891469",DisplayName = "Revolver"};
    ["Taunt"] = {Name = "Taunt",InputShown = "",Tip = "Taunt the killer gaining a forcefield, highlighting the killer, and slowing them down for 5 seconds or until you\'re hit for the duration of the effect (1.25x damage).",Cooldown = 25,Icon = "rbxassetid://85436299122876",DisplayName = "Taunt"};
    ["Banana"] = {Name = "Banana",InputShown = "",Tip = "Toss a banana onto the floor, if the killer or the civilian who made it touch the banana, they will slip and be briefly stunned, the banana will naturally decay over time.",Cooldown = 20,Icon = "rbxassetid://96202444819611",DisplayName = "Banana Peel"};
}

local Tab_3 = Window:CreateTab("Abilities",0)
Tab_3:CreateParagraph({Title = "Abilities", Content = "You can give yourself abilities or cards with abilities."})
Tab_3:CreateSection("Get Ability")

Tab_3:CreateDropdown({Name = "Get Ability"; Options = AbilityNames; CurrentOption = ""; MultiSelection = false; Callback = function(Value)
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("AbilitySelection"):FireServer(unpack({{tostring(ConvertDropdownValue(Value));}}))
AbilityModule.CreateAbility(AbilityDatas[tostring(ConvertDropdownValue(Value))])
end; })

Tab_3:CreateButton({Name = "Get All Abilities"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("AbilitySelection"):FireServer(unpack({{tostring(AbilityNames[math.random(1, 11)]);tostring(AbilityNames[math.random(1, 11)]);}}))
for _,ability in pairs(AbilityNames) do
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("AbilitySelection"):FireServer(unpack({{tostring(ability);}}))
AbilityModule.CreateAbility(AbilityDatas[tostring(ability)])
end
end; })
