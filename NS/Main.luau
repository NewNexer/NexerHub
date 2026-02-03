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
--GiftAura("Normal",true,40,0.12)
local NG_aura_enabled = false
local GG_aura_enabled = false
function GiftAura(...)
local a,b,c,d = ...
if a=="Normal" then
NG_aura_enabled = b
if b~=true then return end
task.spawn(function()
while task.wait(.1) do
if NG_aura_enabled==true then wait(999999999) break end
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("NormalGifts", 9e9):GetChildren() do
if HRP~=nil and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and (HRP.Position-v:GetAttribute("StartPosition")).magnitude<c then
game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("GiftCollected", 9e9):FireServer(v)
v:SetAttribute("ClientCollected",true)
task.wait(d)
end
end
end
end)
elseif a=="Golden" then
GG_aura_enabled = b
if b~=true then return end
task.spawn(function()
while task.wait(.1) do
if GG_aura_enabled==true then wait(999999999) break end
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("GoldenGifts", 9e9):GetChildren() do
if HRP~=nil and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and (HRP.Position-v:GetAttribute("StartPosition")).magnitude<c then
game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("GiftCollected", 9e9):FireServer(v)
v:SetAttribute("ClientCollected",true)
task.wait(d)
end
end
end
end)
end
end
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
GiftAura("Normal",Value,NG_Distance,NG_Cooldown)
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
GiftAura("Golden",Value,GG_Distance,GG_Cooldown)
end; })


function GetEnemies(a,b)
for i,v in next, workspace.Enemies:GetChildren() do
if v and v.Name==a then
b(v)
end
end
end
local deleted_instances = {}
function RemoveInstance(a)
deleted_instances[a.Name] = {["Instance"]=a;["Parent"]=a.Parent;}
a.Parent = nil
end
function RestoreInstance(a)
if deleted_instances[a]~=nil then
deleted_instances[a]["Instance"].Parent = deleted_instances[a]["Parent"]
end
end
local Tab3 = Window:CreateTab("Enemies",0)
Tab3:CreateParagraph({Title = "Enemies", Content = "Enemies configurations"})
Tab3:CreateSection("Bell")
Tab3:CreateButton({Name = "Destroy Bell"; Callback = function()
pcall(function() GetEnemies("Bell",function(a) a:Destroy() end) end)
end; })
Tab3:CreateSection("Mart")
Tab3:CreateButton({Name = "Destroy Mart"; Callback = function()
pcall(function() GetEnemies("Mart",function(a) a:Destroy() end) end)
end; })
Tab3:CreateButton({Name = "Remove Mart Sounds"; Callback = function()
pcall(function() GetEnemies("Mart",function(a) a.Mart:Destroy() end) end)
end; })
Tab3:CreateSection("Baby")
Tab3:CreateButton({Name = "Destroy Baby"; Callback = function()
pcall(function() GetEnemies("Baby",function(a) a:Destroy() end) end)
end; })
Tab3:CreateButton({Name = "Remove Baby Screams"; Callback = function()
pcall(function() GetEnemies("Baby",function(a) a.Scream:Destroy() end) end)
end; })
Tab3:CreateSection("Flesh")
Tab3:CreateButton({Name = "Destroy Flesh"; Callback = function()
pcall(function() GetEnemies("Flesh",function(a) a:Destroy() end) end)
end; })
Tab3:CreateSection("Dozer/Kookoo")
Tab3:CreateButton({Name = "Make Dozer/Kookoo Friendly"; Callback = function()
pcall(function()
if game.ReplicatedStorage.Events:FindFirstChild("ResetBindable") then
RemoveInstance(game.ReplicatedStorage.Events:FindFirstChild("ResetBindable"))
end
if game.ReplicatedStorage.Events:FindFirstChild("DiedBindable") then
RemoveInstance(game.ReplicatedStorage.Events:FindFirstChild("DiedBindable"))
end
game.Players.LocalPlayer.CharacterAdded:Once(function()
RestoreInstance("ResetBindable")
RestoreInstance("DiedBindable")
end)
end)
end; })
Tab3:CreateSection("Skinwalker")
Tab3:CreateButton({Name = "Destroy Skinwalker"; Callback = function()
pcall(function() GetEnemies("Skinwalker",function(a) a:Destroy() end) end)
pcall(function() workspace.Skinwalkers:ClearAllChildren() end)
end; })



--[[
Tab1:CreateDropdown({Name = "Dropdown"; Options = {"1","2"}; CurrentOption = "1"; MultiSelection = false; Callback = function(Value)
local Value = Rayfield:GetDropdownValue(Value) -- returns string
print(Value)
end; })
]]--
local Tab2 = Window:CreateTab("Movement",0)
Tab2:CreateParagraph({Title = "Movement", Content = "Movement Management"})
local Gravity = 0
local JumpPower = 0
Tab2:CreateSection("Gravity")
local CurrentGravityLabel = Tab2:CreateLabel("Your current Gravity is ???")
Heartbeat.CurrentGravity = function()
pcall(function()
CurrentGravityLabel:Set("Your current Gravity is "..tostring(workspace.Gravity).."")
end)
end
Tab2:CreateInput({Name = "Gravity"; PlaceholderText = "110"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Gravity = tonumber(Value)
end; })
Tab2:CreateButton({Name = "Set Gravity"; Callback = function()
workspace.Gravity = Gravity
end; })
Tab2:CreateToggle({Name = "Loop Set Gravity"; CurrentValue = false; Callback = function(Value)
if Value == true then
Heartbeat.LoopGravity = function() workspace.Gravity = Gravity end
elseif Value == false then
if Heartbeat.LoopGravity~=nil then
Heartbeat.LoopGravity = nil
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
