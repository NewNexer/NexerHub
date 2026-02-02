--[[

Your Variables and global variables

]]--



--[[ You can change this ]]--
AuthorKey = "Nexer"
GameKey = "Null Scape"

--[[ Don't change this ]]--
local LocalPlayer, LP = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer
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
LocalPlayer.CharacterAdded:Connect(function(char)
pcall(function()
Character, Char = nil, nil
HumanoidRootPart, HRP = nil, nil
Humanoid, Hum = nil, nil
task.wait()
Character, Char = char, char
repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
HumanoidRootPart, HRP = char.HumanoidRootPart, char.HumanoidRootPart
repeat task.wait() until Character:FindFirstChild("Humanoid")
Humanoid, Hum = char.Humanoid, char.Humanoid
end)
end)





--[[

Loading Part ( mainmodule and rayfield )

]]--



function CreateMessage(a)
local instancename = (a=="Message" and a) or "Hint"
local msg = Instance.new(instancename,game:GetService("CoreGui"))
msg.Text = ""
return msg
end

--[[ Loading my module ]]--
local msg = CreateMessage()
msg.Text = "Loading API Module... (0/1)"
local loadmoduleattempt = 0
local Module = nil
repeat task.wait()
local lodsuc, loderr = pcall(function()
Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Global-Module.luau"))()
end)
if not lodsuc then
loadmoduleattempt += 1
msg.Text = "Failed loading API Module, re-trying... ( Attempt "..tostring(loadmoduleattempt).." )"
task.wait(1)
elseif lodsuc and Module.IsWorking ~= nil then
msg.Text = "Loading API Module... (1/1)"
task.wait(1)
else
loadmoduleattempt += 1
msg.Text = "Failed loading API Module, re-trying... ( Attempt "..tostring(loadmoduleattempt).." )"
task.wait(1)
end
until msg.Text == "Loading API Module... (1/1)"
task.wait(1)
msg.Text = "Launching Rayfield..."
--[[ Loading rayfield here ]] --
local Rayfield = Module:GetWorkingRayfield()
task.delay(2,function()
msg:Destroy()
end)


--[[ Re-writing variables ]]--
AuthorKey = ""..((AuthorKey ~= nil and AuthorKey) or "Unknown")..""
GameKey = ""..((GameKey ~= nil and GameKey) or "Unknown")..""


--[[ Creating Window ]]--
local Window = Rayfield:CreateWindow({
   Name = ""..AuthorKey.." Hub : Nullscape",
   Icon = 0,    
   LoadingTitle = ""..string.sub(AuthorKey,1,1).."H:"..GameKey:gsub("(%S)%S+","%1"):gsub("%s+","").."",
   LoadingSubtitle = "By "..AuthorKey.."",
   Theme = "Amethyst",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
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


--[[ Additional Connections Handler ]]--
local rs = game:GetService("RunService")
local Heartbeat = {}
rs.Heartbeat:Connect(function()
for i,v in next, Heartbeat do
if v~=nil then
task.spawn(v)
end
end
end)
--[[local TaskTick = {}
task.spawn(function()
while task.wait() do
for i,v in next, TaskTick do
if v~=nil then
task.spawn(v)
end
end
end
end)]]--
--upconnections: stepped, renderstepped, postsimulation



--[[

Tabs And Main Functions

]]--

local Tab1 = Window:CreateTab("Gifts",0)
Tab1:CreateParagraph({Title = "Gifts", Content = "Gifts pick-up aura and more"})
Tab1:CreateSection("Normal Gifts")
local NG_Distance, NG_Cooldown = 40, 0.12
Tab1:CreateLabel("Warning! Changing to a faster speed or further distance *may* result in a ban ( anti-cheat )")
Tab1:CreateSlider({Name = "Pick up speed"; Range = {0,0.5}; Increment = 0.02; Suffix = " seconds"; CurrentValue = 0.12; Callback = function(Value)
NG_Cooldown = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Pick up distance"; Range = {0,50}; Increment = 1; Suffix = " studs"; CurrentValue = 40; Callback = function(Value)
NG_Distance = tonumber(Value)
end; })
Tab1:CreateToggle({Name = "Enable pick-up aura"; CurrentValue = false; Callback = function(Value)

end; })
Tab1:CreateSection("Golden Gifts")
local GG_Distance, GG_Cooldown = 40, 0.12
Tab1:CreateLabel("Warning! Changing to a faster speed or further distance *may* result in a ban ( anti-cheat )")
Tab1:CreateSlider({Name = "Pick up speed"; Range = {0,0.5}; Increment = 0.02; Suffix = " seconds"; CurrentValue = 0.12; Callback = function(Value)
GG_Cooldown = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Pick up distance"; Range = {0,50}; Increment = 1; Suffix = " studs"; CurrentValue = 40; Callback = function(Value)
GG_Distance = tonumber(Value)
end; })
Tab1:CreateToggle({Name = "Enable pick-up aura"; CurrentValue = false; Callback = function(Value)

end; })






--[[
Tab1:CreateDropdown({Name = "Dropdown"; Options = {"1","2"}; CurrentOption = "1"; MultiSelection = false; Callback = function(Value)
local Value = Rayfield:GetDropdownValue(Value) -- returns string
print(Value)
end; })
]]--
local Tab2 = Window:CreateTab("Local Player",0)
Tab2:CreateParagraph({Title = "Local Player", Content = "Local Player Management"})
local WalkSpeed = 0
local JumpPower = 0
Tab2:CreateSection("WalkSpeed")
local CurrentWalkSpeedLabel = Tab2:CreateLabel("Your current WalkSpeed is ???")
Heartbeat.CurrentWalkSpeed = function()
pcall(function()
if Humanoid then
CurrentWalkSpeedLabel:Set("Your current WalkSpeed is "..tostring(Humanoid.WalkSpeed).."")
end
end)
end
Tab2:CreateInput({Name = "WalkSpeed"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
WalkSpeed = tonumber(Value)
end; })
Tab2:CreateButton({Name = "Set WalkSpeed"; Callback = function()
Humanoid.WalkSpeed = WalkSpeed
end; })
Tab2:CreateToggle({Name = "Loop Set WalkSpeed"; CurrentValue = false; Callback = function(Value)
if Value == true then
Heartbeat.LoopWalkSpeed = function() Humanoid.WalkSpeed = WalkSpeed end
elseif Value == false then
if Heartbeat.LoopWalkSpeed~=nil then
Heartbeat.LoopWalkSpeed = nil
end
end
end; })
Tab2:CreateSection("JumpPower")
local CurrentJumpPowerLabel = Tab2:CreateLabel("Your current JumpPower is ???")
Heartbeat.CurrentJumpPower = function()
pcall(function()
if Humanoid then
CurrentJumpPowerLabel:Set("Your current JumpPower is "..tostring(Humanoid.JumpPower).."")
end
end)
end
Tab2:CreateInput({Name = "JumpPower"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
JumpPower = tonumber(Value)
end; })
Tab2:CreateButton({Name = "Set JumpPower"; Callback = function()
Humanoid.JumpPower = JumpPower
end; })
Tab2:CreateToggle({Name = "Loop Set JumpPower"; CurrentValue = false; Callback = function(Value)
if Value == true then
Heartbeat.LoopJumpPower = function() Humanoid.JumpPower = JumpPower end
elseif Value == false then
if Heartbeat.LoopJumpPower~=nil then
Heartbeat.LoopJumpPower = nil
end
end
end; })
Tab2:CreateSection("Camera")
Tab2:CreateSlider({Name = "FOV"; Range = {0,360}; Increment = 1; Suffix = ""; CurrentValue = workspace.CurrentCamera.FieldOfView; Callback = function(Value)
workspace.CurrentCamera.FieldOfView = Value
end; })
