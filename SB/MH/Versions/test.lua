local FetchedHumanoids = {}
local FetchedMannequins = {}
-- Slap ''Air''
for i,v in next, game:GetService("ReplicatedStorage").Assets:GetDescendants() do
if v and v:IsA("Model") and v:FindFirstChild("isInArena") and v.isInArena.Value==true and v:FindFirstChild("Head") then
if v.Parent.Name=="Mannequin" then
table.insert(FetchedMannequins,v.Head)
end
table.insert(FetchedHumanoids,v.Head)
end
end
local SlapHiddens = true
local SlapWhichHiddens = "Mannequins"

if (string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "xeno") or string.find(identifyexecutor(), "XENO")) or (string.find(identifyexecutor(), "Solara") or string.find(identifyexecutor(), "solara") or string.find(identifyexecutor(), "SOLARA")) then
function fcd(part)
assert(typeof(part) == "Instance", "invalid argument #1 to 'fireclickdetector' (Instance expected, got " .. type(part) .. ") ", 2)
local clickDetector = part:FindFirstChild("ClickDetector") or part
local previousParent = clickDetector.Parent
local newPart = Instance.new("Part", workspace)
newPart.Transparency = 1
newPart.Size = Vector3.new(30, 30, 30)
newPart.Anchored = true
newPart.CanCollide = false
delay(15, function()
if newPart:IsDescendantOf(game) then
newPart:Destroy()
end
end)
clickDetector.Parent = newPart
clickDetector.MaxActivationDistance = math.huge
local vUser = game:FindService("VirtualUser") or game:GetService("VirtualUser")
local connection = game:GetService("RunService").Heartbeat:Connect(function()
local camera = workspace.CurrentCamera or workspace.Camera
newPart.CFrame = camera.CFrame * CFrame.new(0, 0, -20) * CFrame.new(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Y, camera.CFrame.LookVector.Z)
vUser:ClickButton1(Vector2.new(20, 20), camera.CFrame)
end)
clickDetector.MouseClick:Once(function()
connection:Disconnect()
clickDetector.Parent = previousParent
newPart:Destroy()
end)
end
getgenv().fireclickdetector = fcd
end

repeat task.wait() until game:FindService("Players") and game:GetService("Players").LocalPlayer~=nil
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
function CreateMessage(a)
local instancename = (a=="Message" and a) or "Hint"
local msg = Instance.new(instancename,game:GetService("CoreGui"))
msg.Name = "BadgeHubNof"
msg.Text = ""
return msg
end
local msg = CreateMessage()
msg.Text = "Loading Modules... (0/1)"
local loadmoduleattempt = 0
local Module = nil
repeat task.wait()
local lodsuc, loderr = pcall(function()
Module = loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Modified%20Module.luau"))()
end)
if not lodsuc then
loadmoduleattempt += 1
msg.Text = "Failed loading Modules, re-trying... ( Attempt "..tostring(loadmoduleattempt).." )"
task.wait(1)
elseif lodsuc and Module.IsWorking ~= nil then
msg.Text = "Loading Modules... (1/1)"
task.wait(1)
else
loadmoduleattempt += 1
msg.Text = "Failed loading Modules, re-trying... ( Attempt "..tostring(loadmoduleattempt).." )"
task.wait(1)
end
until msg.Text == "Loading Modules... (1/1)"
pcall(function()
    local flags = require(game:GetService("ReplicatedStorage").BACKEND.Shared.Flags.FlagService)
    local orig = flags.IsEnabled
    flags.IsEnabled = function(flag, ...)
        if flag == "IgnoreSafety" then
            return true
        end
        return orig(flag, ...)
    end
end)
local network = false
function EquipGlove(glove)
    if network and game:GetService("ReplicatedStorage"):FindFirstChild("SelectGlove [STUDIO]",true) then
        repeat game:GetService("ReplicatedStorage"):FindFirstChild("SelectGlove [STUDIO]",true):FireServer(glove) task.wait(.1) until game:GetService("Players").LocalPlayer.leaderstats.Glove.Value == glove
    else
        repeat fireclickdetector(workspace.Lobby[glove]:FindFirstChildWhichIsA("ClickDetector",true)) task.wait(.1) until game:GetService("Players").LocalPlayer.leaderstats.Glove.Value == glove
    end
    task.wait(.1)
end
TeleportToArena = Module.TeleportToArena
TouchObject = Module.TouchObject
Slap = Module.Slap
task.wait(1)
msg.Text = "Launching Rayfield..."
--[[ Loading rayfield here ]] --
local Rayfield = Module:GetWorkingRayfield()
task.delay(2,function()
msg:Destroy()
end)

GameKey = ""..((game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name ~= nil and game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name) or "Unknown")..""
--[[ Creating Window ]]--
local Window = Rayfield:CreateWindow({
   Name = ""..GameKey.." | Mastery Hub",
   Icon = 0,    
   LoadingTitle = "SB:UBH",
   LoadingSubtitle = "Developed by Nexer",
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

if workspace:FindFirstChild("platform1")==nil then
local platform1 = Instance.new("Part")
platform1.Position = Vector3.new(10000,-10000,10000)
platform1.Size = Vector3.new(2048,4,2048)
platform1.Anchored = true
platform1.Transparency = 0.5
platform1.CanCollide = true
platform1.Name = "platform1"
platform1.Parent = workspace
end

Window:CreateTabSection("Overview")

local Tab1 = Window:CreateTab("Overview",0)

Tab1:CreateSection("Overview")

Tab1:CreateParagraph({Title = "Overview", Content = "This script was developed by Nexer. By using this tool, you can easily earn many masteries. Enjoy!\n\n( PS: If you encountered an error, please DM me in discord! My current discord username is @new_nexer1234 )"})

Tab1:CreateSection("Other")

Tab1:CreateButton({Name = "Delete all stuck messages/hints/notifications"; Callback = function()
for i,v in next, game:GetService("CoreGui"):GetChildren() do
if v.Name=="BadgeHubNof" then
v:Destroy()
end
end
end; })

Tab1:CreateButton({Name = "Reset Portals"; Callback = function()
workspace.Lobby["Teleport1"].CFrame = CFrame.new(-1210.16235, 329.900879, 3.98652339, 1, 0, 0, 0, 1, 0, 0, 0, 1)
workspace.Lobby["Teleport1"].Size = Vector3.new(0.8665102124214172, 14.070901870727539, 8.572914123535156)
workspace.Lobby["Teleport2"].CFrame = CFrame.new(-1210.16235, 329.955811, -8.03007889, 1, 0, 0, 0, -1, 0, 0, 0, -1)
workspace.Lobby["Teleport2"].Size = Vector3.new(0.8665102124214172, 13.961214065551758, 9.13329792022705)
end; })

Tab1:CreateToggle({Name = "Anchor Yourself"; Default = false; Callback = function(Value)
HumanoidRootPart.Anchored = Value
end; })

Tab1:CreateToggle({Name = "Equip gloves thru network?"; Default = false; Callback = function(Value)
network = Value
end; })

Tab1:CreateToggle({Name = "Slap Hiddens?"; Default = true; Callback = function(Value)
SlapHiddens = Value
end; })

Tab1:CreateToggle({Name = "Slap Only Mannequins?"; Default = true; Callback = function(Value)
if Value==true then
SlapWhichHiddens = "Mannequins"
else
SlapWhichHiddens = "Humanoids"
end
end; })

Tab1:CreateButton({Name = "Close Gui"; Callback = function()
Rayfield:Destroy()
end; })

local Barriers = {
    workspace.DEATHBARRIER,
    workspace.DEATHBARRIER2,
    workspace.dedBarrier,
    workspace.ArenaBarrier,
    workspace.AntiDefaultArena
}

function ToggleBarriers(val)
for _,barrier in next, Barriers do
if barrier then
for _,part in next, barrier:GetChildren() do
if part and part:IsA("BasePart") then
part.CanTouch = val
end
end
barrier.CanTouch = val
end
end
end

function FindRandomPlayer()
local AllPlayers = game:GetService("Players"):GetChildren()
local RandomPlayer = AllPlayers[math.random(1, #AllPlayers)]
repeat task.wait()
RandomPlayer = AllPlayers[math.random(1, #AllPlayers)]
until RandomPlayer and RandomPlayer ~= LocalPlayer and RandomPlayer.Character and RandomPlayer.Character:FindFirstChild("entered") and RandomPlayer.Character:FindFirstChild("rock") == nil and RandomPlayer.Character:FindFirstChild("RobTransformed") == nil and RandomPlayer.Character:FindFirstChild("stevebody") == nil and RandomPlayer.Character:FindFirstChildWhichIsA("Humanoid") and RandomPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health ~= 0 and RandomPlayer.Character:FindFirstChild("Torso") and RandomPlayer.Character:FindFirstChild("Torso").Transparency~=1 and RandomPlayer.Character.Torso:FindFirstChild("BuddyBox") == nil and RandomPlayer.Character:FindFirstChild("Head") and RandomPlayer.Character.Head:FindFirstChild("ScreamParticles") == nil and RandomPlayer.Character:FindFirstChild("Reversed") == nil and RandomPlayer.Character.Head:FindFirstChild("UnoDraw4Card") == nil and RandomPlayer.Character.Head.BrickColor ~= "New Yeller" and RandomPlayer.Character:FindFirstChild("HumanoidRootPart") and RandomPlayer.Character.HumanoidRootPart:FindFirstChild("BlackheartREAL") == nil and RandomPlayer.Character.HumanoidRootPart:FindFirstChild("BlockedShield") == nil and Character and HumanoidRootPart and Humanoid
return RandomPlayer.Character
end

local processes = {}
function ShutdownProcess(processid)
processes[processid] = nil
end

function CreateProcess(gt,g,rem)
local processid = game:GetService("HttpService"):GenerateGUID(false)
processes[processid] = true
local gt = gt or {
   ["Replica"] = true;
   ["Cherry"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["UFO"] = false;
   ["Null"] = false;
   ["Swordfighter"] = false;
   ["Poltergeist"] = false;
   ["Conker"] = false;
   ["Elf"] = false;
   ["Command"] = false;
}
local g = g or "Glovel"
local trg = trg or GlovelSlappingProcess
local rem = rem or game.ReplicatedStorage.GeneralHit
local NullCooldown = "ended"
local CherryCooldown = "ended"
task.spawn(function()
repeat task.wait(.05)
for i,v in next, workspace:GetChildren() do
if LocalPlayer.leaderstats.Glove.Value~=g or gt.People==true then continue end
if v.Name==""..LocalPlayer.Name.."'s UFO" and v:FindFirstChild("UFOTarget") and v.UFOTarget:FindFirstChild("HumanoidRootPart") then
rem:FireServer(v.UFOTarget.HumanoidRootPart,true)
end
if v.Name=="Å"..LocalPlayer.Name.."" and v:FindFirstChild("HumanoidRootPart") then
rem:FireServer(v.HumanoidRootPart,true)
end
if v.Name=="ÅBaller"..LocalPlayer.Name.."" and v:FindFirstChild("HumanoidRootPart") then
rem:FireServer(v.HumanoidRootPart,true)
end
if v.Name=="Blink_"..LocalPlayer.Name.."" and v:FindFirstChild("HumanoidRootPart") then
rem:FireServer(v.HumanoidRootPart,true)
end
if v.Name=="cherry_storage" and v:FindFirstChild("Cherry "..LocalPlayer.Name) and v["Cherry "..LocalPlayer.Name]:FindFirstChild("HumanoidRootPart") then
rem:FireServer(v["Cherry "..LocalPlayer.Name].HumanoidRootPart,true)
end
if v.Name=="Imp" and v:FindFirstChild("Body") then
rem:FireServer(v.Body,true)
end
if v.Name==""..LocalPlayer.Name.."_More" then
if v:FindFirstChild("1") then
rem:FireServer(v["1"].HumanoidRootPart,true)
end
if v:FindFirstChild("2") then
rem:FireServer(v["2"].HumanoidRootPart,true)
end
if v:FindFirstChild("3") then
rem:FireServer(v["3"].HumanoidRootPart,true)
end
if v:FindFirstChild("4") then
rem:FireServer(v["4"].HumanoidRootPart,true)
end
if v:FindFirstChild("5") then
rem:FireServer(v["5"].HumanoidRootPart,true)
end
end
end
if SlapHiddens==true then
if SlapWhichHiddens=="Mannequins" then
for i,v in next, FetchedMannequins do
rem:FireServer(v,true)
end
else
for i,v in next, FetchedHumanoids do
rem:FireServer(v,true)
end
end
end
until processes[processid]~=true or Humanoid.Health==0
end)
task.spawn(function()
if gt.People==true then
local vector = Vector3.new(0,0,0)
ToggleBarriers(false)
repeat task.wait()
if LocalPlayer.leaderstats.Slaps.Value>665 and Character:FindFirstChild("Head") and Character.Head.Transparency~=1 then
EquipGlove("Ghost")
game.ReplicatedStorage.Ghostinvisibilityactivated:FireServer()
repeat task.wait() until Character:FindFirstChild("Head") and Character.Head.Transparency==1 or Humanoid.Health==0
end
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0 or processes[processid]~=true
end
if LocalPlayer.leaderstats.Glove.Value~=g then
EquipGlove(g)
end
local randomhuman = FindRandomPlayer()
for i=1,175 do
HumanoidRootPart:PivotTo(randomhuman:WaitForChild("HumanoidRootPart").CFrame)
for _,p in next, Character:GetDescendants() do
if p:IsA("BasePart") then
p.Velocity, p.RotVelocity = vector, vector
end
end
task.wait(.005)
end
rem:FireServer(randomhuman:WaitForChild("HumanoidRootPart"))
until processes[processid]~=true or Humanoid.Health==0
ToggleBarriers(true)
else
repeat task.wait(.1)
if gt.Baller==true and workspace:FindFirstChild("ÅBaller"..LocalPlayer.Name)==nil then
EquipGlove("Baller")
TeleportToArena(2)
game.ReplicatedStorage.GeneralAbility:FireServer()
task.wait(.2)
Humanoid.Health = 0
LocalPlayer.CharacterAdded:Wait()
task.wait(2)
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
end
if gt.Blink==true and workspace:FindFirstChild("Blink_"..LocalPlayer.Name)==nil then
EquipGlove("Blink")
game.ReplicatedStorage.Blink:FireServer("OutOfBody",{["dir"]=Vector3.new(0,0,0),["ismoving"]=false,["mousebehavior"]=Enum.MouseBehavior.Default})
repeat task.wait() until workspace:FindFirstChild("Blink_"..LocalPlayer.Name) or Humanoid.Health==0 or processes[processid]~=true
end
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0 or processes[processid]~=true
end
if gt["5 More"]==true and (workspace:FindFirstChild(LocalPlayer.Name.."_More")==nil or workspace[LocalPlayer.Name.."_More"]:FindFirstChild("5")==nil) then
EquipGlove("5 More")
repeat task.wait(.1)
game.ReplicatedStorage.GeneralAbility:FireServer()
until workspace:FindFirstChild(LocalPlayer.Name.."_More") and workspace[LocalPlayer.Name.."_More"]:FindFirstChild("5")
end
if gt.Cherry==true and CherryCooldown=="ended" then
EquipGlove("Cherry")
game.ReplicatedStorage.Events.Friction:FireServer("touched_fire")
repeat task.wait() until Character and Character:FindFirstChild("Ragdolled") and Character.Ragdolled.Value==true
game.ReplicatedStorage.GeneralAbility:FireServer()
repeat task.wait() until Character and Character:FindFirstChild("Ragdolled") and Character.Ragdolled.Value==false
CherryCooldown = "ongoing"
task.delay(6, function() CherryCooldown="ended" end)
end
if gt.Replica==true and workspace:FindFirstChild("Å"..LocalPlayer.Name)==nil then
EquipGlove("Replica")
game.ReplicatedStorage.Duplicate:FireServer()
repeat task.wait() until workspace:FindFirstChild("Å"..LocalPlayer.Name) or Humanoid.Health==0 or processes[processid]~=true
end
if gt.Null==true and NullCooldown=="ended" then
EquipGlove("Null")
game.ReplicatedStorage.NullAbility:FireServer()
NullCooldown = "ongoing"
task.delay(15, function() NullCooldown="ended" end)
end
if gt.UFO==true and workspace:FindFirstChild(LocalPlayer.Name.."'s UFO")==nil then
EquipGlove("UFO")
game.ReplicatedStorage.GeneralAbility:FireServer()
repeat task.wait() until workspace:FindFirstChild(LocalPlayer.Name.."'s UFO") or Humanoid.Health==0 or processes[processid]~=true
end
if LocalPlayer.leaderstats.Glove.Value~=g then
EquipGlove(g)
end
until processes[processid]~=true or Humanoid.Health==0
end
end)
return processid
end

Window:CreateTabSection("Glovel")

local GlovelYourself = Window:CreateTab("Glovel ( For Yourself )",0)

GlovelYourself:CreateSection("Safezones")

GlovelYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

GlovelYourself:CreateSection("Tasks 1, 2, 3")

local GlovelAllTasks = false
GlovelYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 2, 3 ( You need to enter arena )"; Default = false; Callback = function(Value)
GlovelAllTasks = Value
if GlovelAllTasks==true then
repeat task.wait(.05)
if Character and Character:FindFirstChild("Head") then
if Character.Head.Transparency~=1 then
game:GetService("ReplicatedStorage").GlovelFunc:InvokeServer()
else
game:GetService("ReplicatedStorage").GlovelCancel:FireServer()
end
end
if SlapHiddens==true then
if SlapWhichHiddens=="Mannequins" then
for i,v in next, FetchedMannequins do
game:GetService("ReplicatedStorage").GeneralHit:FireServer(v,true)
end
else
for i,v in next, FetchedHumanoids do
game:GetService("ReplicatedStorage").GeneralHit:FireServer(v,true)
end
end
end
until GlovelAllTasks==false
end
end; })


GlovelYourself:CreateSection("Task 1")

local DiggingGlovel = false
GlovelYourself:CreateToggle({Name = "Auto-Farm Task 1 ( You need to enter arena )"; Default = false; Callback = function(Value)
DiggingGlovel = Value
if DiggingGlovel==true then
repeat task.wait(.05)
if Character and Character:FindFirstChild("Head") then
if Character.Head.Transparency~=1 then
game:GetService("ReplicatedStorage").GlovelFunc:InvokeServer()
else
game:GetService("ReplicatedStorage").GlovelCancel:FireServer()
end
end
until DiggingGlovel==false
end
end; })


GlovelYourself:CreateSection("Tasks 2, 3")

local GlovelGlovesForSlapping = {
   ["People"] = false;
   ["Replica"] = false;
   ["Cherry"] = false;
   ["5 More"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["UFO"] = false;
   ["Null"] = false;
   ["Swordfighter"] = false;
   ["Poltergeist"] = false;
   ["Conker"] = false;
   ["Elf"] = false;
   ["Command"] = false;
}
GlovelYourself:CreateToggle({Name = "Slap People? ( If true: Only this will be used )"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["People"] = Value
end; })
GlovelYourself:CreateToggle({Name = "Slap Replica?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Replica"] = Value
end; })
GlovelYourself:CreateToggle({Name = "Slap Cherry?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Cherry"] = Value
end; })
GlovelYourself:CreateToggle({Name = "Slap 5 More?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["5 More"] = Value
end; })
GlovelYourself:CreateToggle({Name = "Slap Baller?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Baller"] = Value
end; })
GlovelYourself:CreateToggle({Name = "Slap Blink?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Blink"] = Value
end; })
--[[GlovelYourself:CreateToggle({Name = "Slap UFO?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["UFO"] = Value
end; })]]
GlovelYourself:CreateToggle({Name = "Slap Null?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Null"] = Value
end; })
--[[GlovelYourself:CreateToggle({Name = "Slap Swordfighter?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Swordfighter"] = Value
end; })]]
--[[GlovelYourself:CreateToggle({Name = "Slap Poltergeist?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Poltergeist"] = Value
end; })]]
--[[GlovelYourself:CreateToggle({Name = "Slap Conker?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Conker"] = Value
end; })]]
--[[GlovelYourself:CreateToggle({Name = "Slap Elf?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Elf"] = Value
end; })]]
--[[GlovelYourself:CreateToggle({Name = "Slap Command?"; Default = false; Callback = function(Value)
GlovelGlovesForSlapping["Command"] = Value
end; })]]

local GlovelProcessID = nil
GlovelYourself:CreateToggle({Name = "Auto-Farm Tasks 2, 3"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
GlovelProcessID = CreateProcess(GlovelGlovesForSlapping, "Glovel", game.ReplicatedStorage.GeneralHit)
elseif GlovelProcessID~=nil then
ShutdownProcess(GlovelProcessID)
end
end; })

Window:CreateTabSection("Moon")

local MoonYourself = Window:CreateTab("Moon ( For Yourself )",0)

MoonYourself:CreateSection("Safezones")

MoonYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

MoonYourself:CreateSection("Task 1")

MoonYourself:CreateButton({Name = "Insta-Complete Task 1"; Callback = function()
for i=1,200 do
game:GetService("ReplicatedStorage").Events.celestial:FireServer("unequipped")
end
end; })

MoonYourself:CreateSection("Task 2")

local MoonGlovesForSlapping = {
   ["People"] = false;
   ["Replica"] = false;
   ["Cherry"] = false;
   ["5 More"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["Null"] = false;
}
MoonYourself:CreateToggle({Name = "Slap People? ( If true: Only this will be used )"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["People"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap Replica?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["Replica"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap Cherry?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["Cherry"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap 5 More?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["5 More"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap Baller?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["Baller"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap Blink?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["Blink"] = Value
end; })
MoonYourself:CreateToggle({Name = "Slap Null?"; Default = false; Callback = function(Value)
MoonGlovesForSlapping["Null"] = Value
end; })

local MoonProcessID = nil
MoonYourself:CreateToggle({Name = "Auto-Farm Task 2"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
MoonProcessID = CreateProcess(MoonGlovesForSlapping, "Moon", game.ReplicatedStorage.CelestialHit)
repeat
game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
game:GetService("ReplicatedStorage").Events.celestial:FireServer("landed",false)
task.wait()
game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
game:GetService("ReplicatedStorage").Events.celestial:FireServer("landed",true)
task.wait()
until processes[MoonProcessID]~=true
elseif MoonProcessID~=nil then
ShutdownProcess(MoonProcessID)
end
end; })

MoonYourself:CreateSection("Task 3")

local MoonSTProcessID = nil
MoonYourself:CreateToggle({Name = "Auto-Farm Task 3"; Default = false; Callback = function(Value)
if Value==true then
MoonSTProcessID = CreateProcess({["People"]=true;}, "Moon", game.ReplicatedStorage.CelestialHit)
elseif MoonSTProcessID~=nil then
ShutdownProcess(MoonSTProcessID)
end
end; })


Window:CreateTabSection("Wormhole")

local WormholeYourself = Window:CreateTab("Wormhole ( For Yourself )",0)

WormholeYourself:CreateSection("Safezones")

WormholeYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

WormholeYourself:CreateSection("Tasks 1, 2, 3")

local WormholeGlovesForSlapping = {
   ["People"] = false;
   ["Replica"] = false;
   ["Cherry"] = false;
   ["5 More"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["Null"] = false;
}
WormholeYourself:CreateToggle({Name = "Slap People? ( If true: Only this will be used )"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["People"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap Replica?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["Replica"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap Cherry?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["Cherry"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap 5 More?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["5 More"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap Baller?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["Baller"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap Blink?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["Blink"] = Value
end; })
WormholeYourself:CreateToggle({Name = "Slap Null?"; Default = false; Callback = function(Value)
WormholeGlovesForSlapping["Null"] = Value
end; })

local WormholeProcessID = nil
WormholeYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 2, 3"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
WormholeProcessID = CreateProcess(WormholeGlovesForSlapping, "Wormhole", game.ReplicatedStorage.WormHit)
repeat task.wait(.05)
game.ReplicatedStorage.WormholePlace:FireServer()
game.ReplicatedStorage.WormholeTP:FireServer(CFrame.new(0,0,0),"One")
game.ReplicatedStorage.WormholeTP:FireServer(CFrame.new(0,0,0),"Two")
until processes[WormholeProcessID]~=true
elseif WormholeProcessID~=nil then
ShutdownProcess(WormholeProcessID)
end
end; })

WormholeYourself:CreateSection("Task 2, 3")

local WormholeTPP = false
WormholeYourself:CreateToggle({Name = "Auto-Farm Tasks 2, 3"; Default = false; Callback = function(Value)
WormholeTPP = Value
if WormholeTPP==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
repeat task.wait(.05)
if LocalPlayer.leaderstats.Glove.Value~="Wormhole" then
EquipGlove("Wormhole")
end
game.ReplicatedStorage.WormholePlace:FireServer()
game.ReplicatedStorage.WormholeTP:FireServer(CFrame.new(10000,-10000,10000),"One")
game.ReplicatedStorage.WormholeTP:FireServer(CFrame.new(10000,-10000,10000),"Two")
until WormholeTPP==false
end
end; })

WormholeYourself:CreateSection("Task 3")

WormholeYourself:CreateButton({Name = "Insta-Complete Task 3"; Callback = function()
for i=1,1000 do
game.ReplicatedStorage.WormholePlace:FireServer()
end
end; })

Window:CreateTabSection("Flash")

local FlashYourself = Window:CreateTab("Flash ( For Yourself )",0)

FlashYourself:CreateSection("Safezones")

FlashYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

FlashYourself:CreateSection("Tasks 1, 2, 3")

local FlashGlovesForSlapping = {
   ["People"] = false;
   ["Replica"] = false;
   ["Cherry"] = false;
   ["5 More"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["Null"] = false;
}
FlashYourself:CreateToggle({Name = "Slap People? ( If true: Only this will be used )"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["People"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap Replica?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["Replica"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap Cherry?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["Cherry"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap 5 More?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["5 More"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap Baller?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["Baller"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap Blink?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["Blink"] = Value
end; })
FlashYourself:CreateToggle({Name = "Slap Null?"; Default = false; Callback = function(Value)
FlashGlovesForSlapping["Null"] = Value
end; })

local FlashProcessID = nil
FlashYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 2, 3"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
FlashProcessID = CreateProcess(FlashGlovesForSlapping, "Flash", game.ReplicatedStorage.FlashHit)
repeat task.wait(3)
game.ReplicatedStorage.FlashTeleport:FireServer()
until processes[FlashProcessID]~=true
elseif FlashProcessID~=nil then
ShutdownProcess(FlashProcessID)
end
end; })

FlashYourself:CreateSection("Tasks 1, 3")

FlashYourself:CreateButton({Name = "Insta-Complete Tasks 1, 3"; Callback = function()
for i=1,5000 do
game.ReplicatedStorage.FlashTeleport:FireServer()
end
end; })

Window:CreateTabSection("Bomb ( Broken )")

local BombYourself = Window:CreateTab("Bomb ( Broken, For Yourself )",0)

BombYourself:CreateSection("Safezones")

BombYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

BombYourself:CreateSection("Task 1")

BombYourself:CreateButton({Name = "Insta-Complete Task 1"; Callback = function()
for i=1,5000 do
game.ReplicatedStorage.BombThrow:FireServer("Ebutton")
end
end; })

BombYourself:CreateSection("Tasks 1, 2, 3")

local BombProcess = false
BombYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 2, 3"; Default = false; Callback = function(Value)
BombProcess = Value
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0
end
local vector = Vector3.new(0,0,0)
local newbombthrown = false
repeat task.wait()
if LocalPlayer.leaderstats.Glove.Value~="Bomb" then
EquipGlove("Bomb")
end
if not workspace:FindFirstChild(LocalPlayer.Name.."_bømb") then
game.ReplicatedStorage.BombThrow:FireServer("Ebutton")
repeat task.wait() until workspace:FindFirstChild(LocalPlayer.Name.."_bømb") or BombProcess==false
task.delay(8, function()
if workspace:FindFirstChild(LocalPlayer.Name.."_bømb")==nil then
game.ReplicatedStorage.BombThrow:FireServer("Ebutton")
repeat task.wait() until workspace:FindFirstChild(LocalPlayer.Name.."_bømb")
newbombthrown = true
task.wait(.1)
newbombthrown = false
else
game.ReplicatedStorage.BombThrow:FireServer("Ebutton")
end
end)
end
if workspace:FindFirstChild(LocalPlayer.Name.."_bømb") then
local checkforbugss = false
task.delay(10,function()
if workspace:FindFirstChild(LocalPlayer.Name.."_bømb")==nil then
checkforbugss = true
task.wait(.1)
checkforbugss = false
end
end)
repeat
if workspace:FindFirstChild(LocalPlayer.Name.."_bømb") then
HumanoidRootPart:PivotTo(CFrame.new(workspace[LocalPlayer.Name.."_bømb"].Position))
end
for _,p in next, Character:GetDescendants() do
if p:IsA("BasePart") then
p.Velocity, p.RotVelocity = vector, vector
end
end
task.wait()
until Character:FindFirstChild("Ragdolled") and Character.Ragdolled.Value==true or BombProcess==false or newbombthrown==true or Humanoid.Health==0 or checkforbugss==true
end
local checkforbugs = false
task.delay(5,function()
if workspace:FindFirstChild(LocalPlayer.Name.."_bømb")==nil then
checkforbugs = true
task.wait(.1)
checkforbugs = false
end
end)
repeat
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
for _,p in next, Character:GetDescendants() do
if p:IsA("BasePart") then
p.Velocity, p.RotVelocity = vector, vector
end
end
task.wait()
until Character:FindFirstChild("Ragdolled") and Character.Ragdolled.Value==false or BombProcess==false or Humanoid.Health==0 or checkforbugs==true
until BombProcess==false or Humanoid.Health==0
end
end; })

BombYourself:CreateSection("Tasks 1, 3")

local BombProcesss = false
BombYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 3"; Default = false; Callback = function(Value)
BombProcesss = Value
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0
end
repeat
if LocalPlayer.leaderstats.Glove.Value~="Bomb" then
EquipGlove("Bomb")
end
for i=1,2 do
game.ReplicatedStorage.BombThrow:FireServer("Ebutton")
end
task.wait(6)
until BombProcesss==false or Humanoid.Health==0
end
end; })


Window:CreateTabSection("Fort")

local FortYourself = Window:CreateTab("Fort ( For Yourself )",0)

FortYourself:CreateSection("Safezones")

FortYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

FortYourself:CreateSection("Task 1")

function PressKey(keycode)
local VirtualInputManager = game:GetService("VirtualInputManager")
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[keycode], false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[keycode], false, game)
end
FortYourself:CreateButton({Name = "Get Badge"; Callback = function()
EquipGlove("Fort")
TeleportToArena(1)
HumanoidRootPart:PivotTo(CFrame.new(-410,75,-41))
task.wait(2)
PressKey("E")
task.wait(2)
HumanoidRootPart:PivotTo(CFrame.new(-406,87,-51))
end; })

FortYourself:CreateSection("Tasks 2, 3")

local FortTasks = false
FortYourself:CreateToggle({Name = "Auto-Farm Tasks 2, 3"; Default = false; Callback = function(Value)
FortTasks = Value
if FortTasks==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1.5)
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0 or processes[processid]~=true
end
if LocalPlayer.leaderstats.Glove.Value~="ZZZZZZZ" then
EquipGlove("ZZZZZZZ")
end
game:GetService("ReplicatedStorage").ZZZZZZZSleep:FireServer()
task.wait(1)
if LocalPlayer.leaderstats.Glove.Value~="Fort" then
EquipGlove("Fort")
end
repeat
game:GetService("ReplicatedStorage").Fortlol:FireServer()
task.wait(4)
until FortTasks==false or Humanoid.Health==0
end
end; })
workspace.ChildAdded:Connect(function(fort)
task.wait(.333)
if fort.Name=="Part" and fort:FindFirstChild("brownsmoke") and fort.Color==Color3.fromRGB(172, 73, 73) and FortTasks==true then
fort.CanCollide = false
game:GetService("RunService").RenderStepped:Wait()
repeat task.wait(.01)
fort:PivotTo(HumanoidRootPart.CFrame)
until fort.Transparency==1
end
end)

Window:CreateTabSection("rob")

local robYourself = Window:CreateTab("rob ( For Yourself )",0)

robYourself:CreateSection("Safezones")

robYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

robYourself:CreateSection("Task 1")

robYourself:CreateButton({Name = "Spawn Portal"; Callback = function()
HumanoidRootPart:PivotTo(CFrame.new(248, -16, 0))
task.wait(1.5)
HumanoidRootPart.Anchored = true
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0
end
if LocalPlayer.leaderstats.Glove.Value~="rob" then
EquipGlove("rob")
end
game:GetService("ReplicatedStorage").rob:FireServer()
task.wait(4)
if LocalPlayer.leaderstats.Glove.Value~="bob" then
EquipGlove("bob")
end
game:GetService("ReplicatedStorage").bob:FireServer()
task.wait(2)
HumanoidRootPart.Anchored = false
end; })

robYourself:CreateSection("Task 2")

local RobTravel = false
robYourself:CreateToggle({Name = "Auto-Farm Task 2"; Default = false; Callback = function(Value)
RobTravel = Value
if RobTravel==true then
repeat
if LocalPlayer.leaderstats.Glove.Value~="rob" then
EquipGlove("rob")
end
HumanoidRootPart.CFrame = CFrame.new(math.random(10000,20000),math.random(10000,20000),math.random(10000,20000))
game:GetService("ReplicatedStorage").rob:FireServer()
task.wait(.05)
until RobTravel==false or Humanoid.Health==0
for i=1,50 do
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,30,0))
task.wait()
end
end
end; })

robYourself:CreateSection("Task 3")

local robAbsorb = false
robYourself:CreateToggle({Name = "Auto-Farm Task 3"; Default = false; Callback = function(Value)
robAbsorb = Value
if robAbsorb==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1.5)
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0 or processes[processid]~=true
end
HumanoidRootPart.Anchored = true
repeat
if LocalPlayer.leaderstats.Glove.Value~="Cherry" then
EquipGlove("Cherry")
end
game:GetService("ReplicatedStorage").GeneralAbility:FireServer()
task.wait(1)
if LocalPlayer.leaderstats.Glove.Value~="rob" then
EquipGlove("rob")
end
game:GetService("ReplicatedStorage").rob:FireServer()
task.wait(1)
for i,v in next, workspace.cherry_storage:GetChildren() do
if v and v.Name=="Cherry "..LocalPlayer.Name.."" and v:FindFirstChild("HumanoidRootPart") then
v.HumanoidRootPart:PivotTo(HumanoidRootPart.CFrame)
end
end
until robAbsorb==false or Humanoid.Health==0
HumanoidRootPart.Anchored = false
end
end; })


Window:CreateTabSection("[REDACTED]")

local REDACTEDYourself = Window:CreateTab("[REDACTED] ( For Yourself )",0)

REDACTEDYourself:CreateSection("Safezones")

REDACTEDYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

REDACTEDYourself:CreateSection("Task 1")

local REDACTEDWellC = false
REDACTEDYourself:CreateToggle({Name = "Auto-Capture People ( that are close enough to the well )"; Default = false; Callback = function(Value)
REDACTEDWellC = Value
if REDACTEDWellC==true then
repeat task.wait(.05)
if LocalPlayer.leaderstats.Glove.Value~="[REDACTED]" then
EquipGlove("[REDACTED]")
end
for i,v in next, game.Players:GetPlayers() do
game.ReplicatedStorage.WellCapture:FireServer(v)
end
until REDACTEDWellC==false
end
end; })

REDACTEDYourself:CreateSection("Tasks 2, 3")

local REDACTEDWellCC = false
REDACTEDYourself:CreateToggle({Name = "Auto-Farm Tasks 2, 3"; Default = false; Callback = function(Value)
REDACTEDWellCC = Value
if REDACTEDWellCC==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
repeat
if LocalPlayer.leaderstats.Glove.Value~="[REDACTED]" then
EquipGlove("[REDACTED]")
end
task.wait(1)
game:GetService("ReplicatedStorage"):WaitForChild("Well"):FireServer()
task.wait(1)
for i,v in next, game.Players:GetPlayers() do
game:GetService("ReplicatedStorage").WellCapture:FireServer(v)
end
task.wait(3)
until REDACTEDWellCC==false
end
end; })

REDACTEDYourself:CreateSection("Task 3")

local REDACTEDWell = false
REDACTEDYourself:CreateToggle({Name = "Auto-Farm Task 3"; Default = false; Callback = function(Value)
REDACTEDWell = Value
if REDACTEDWell==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
repeat
if LocalPlayer.leaderstats.Glove.Value~="[REDACTED]" then
EquipGlove("[REDACTED]")
end
game.ReplicatedStorage.Well:FireServer()
task.wait(5)
until REDACTEDWell==false
end
end; })


Window:CreateTabSection("Space")

local SpaceYourself = Window:CreateTab("Space ( For Yourself )",0)

SpaceYourself:CreateSection("Safezones")

SpaceYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

SpaceYourself:CreateSection("Task 1")

local ZeroGSpace = false
SpaceYourself:CreateToggle({Name = "Auto-Farm Task 1"; Default = false; Callback = function(Value)
ZeroGSpace = Value
if ZeroGSpace==true then
repeat task.wait(.05)
game.ReplicatedStorage.ZeroGSound:FireServer()
until ZeroGSpace==false
end
end; })

SpaceYourself:CreateSection("Tasks 1, 4")

local SpaceProcessID = nil
SpaceYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 4"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
SpaceProcessID = CreateProcess({["People"]=true;}, "Space", game.ReplicatedStorage.HtSpace)
repeat task.wait(.05)
game.ReplicatedStorage.ZeroGSound:FireServer()
until processes[SpaceProcessID]~=true
elseif SpaceProcessID~=nil then
ShutdownProcess(SpaceProcessID)
end
end; })

SpaceYourself:CreateSection("Task 3")

SpaceYourself:CreateButton({Name = "Auto-Complete Task 3"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
if LocalPlayer.leaderstats.Slaps.Value>665 and Character:FindFirstChild("Head") and Character.Head.Transparency~=1 then
EquipGlove("Ghost")
game.ReplicatedStorage.Ghostinvisibilityactivated:FireServer()
repeat task.wait() until Character:FindFirstChild("Head") and Character.Head.Transparency==1 or Humanoid.Health==0
end
if Character:FindFirstChild("isInArena") and Character.isInArena.Value==false and Character:FindFirstChild("entered")==nil then
EquipGlove("Eggler")
for i=1,2 do
game:GetService("ReplicatedStorage").Events.EgglerRAbility:FireServer()
task.wait(2)
end
repeat task.wait() until Character:FindFirstChild("isInArena") and Character.isInArena.Value==true or Humanoid.Health==0
end
if LocalPlayer.leaderstats.Glove.Value~="Space" then
EquipGlove("Space")
end
local vector = Vector3.new(0,0,0)
for i=1,175 do
HumanoidRootPart:PivotTo(workspace.Arena.CannonIsland.Cannon.MovingCannon.CannonPart["Meshes/cannon 1"].CFrame)
for _,p in next, Character:GetDescendants() do
if p:IsA("BasePart") then
p.Velocity, p.RotVelocity = vector, vector
end
end
task.wait(.005)
end
local ams = Instance.new("Message")
ams.Text = "Enter into cannon in 5 seconds"
ams.Parent = game:GetService("CoreGui")
task.wait(5)
ams:Destroy()
if Humanoid.Health==0 then return end
game.ReplicatedStorage.ZeroGSound:FireServer()
task.wait(.25)
for i=1,15 do
workspace:WaitForChild("Arena"):WaitForChild("CannonIsland"):WaitForChild("Cannon"):WaitForChild("_cannonRemote"):FireServer({y = 9e9,x = 9e9,force = 300},true)
task.wait(.05)
end
for i=1,200 do
HumanoidRootPart:PivotTo(CFrame.new(-420,63,-27))
for _,p in next, Character:GetDescendants() do
if p:IsA("BasePart") then
p.Velocity, p.RotVelocity = vector, vector
end
end
task.wait(.005)
end
end; })

Window:CreateTabSection("Spring")

local SpringYourself = Window:CreateTab("Spring ( For Yourself )",0)

SpringYourself:CreateSection("Safezones")

SpringYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

SpringYourself:CreateSection("Tasks 1, 2, 3")

local SpringProcessID = nil
SpringYourself:CreateToggle({Name = "Auto-Farm Tasks 1, 2, 3"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
SpringProcessID = CreateProcess({["People"]=true;}, "Spring", game.ReplicatedStorage.springhit)
repeat task.wait(.01)
game.ReplicatedStorage.SpringJump:FireServer()
until processes[SpringProcessID]~=true
elseif SpringProcessID~=nil then
ShutdownProcess(SpringProcessID)
end
end; })

Window:CreateTabSection("Stick")

local StickYourself = Window:CreateTab("Stick ( For Yourself )",0)

StickYourself:CreateSection("Safezones")

StickYourself:CreateButton({Name = "Teleport to baseplate"; Callback = function()
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
end; })

StickYourself:CreateSection("Task 1")

local StickGlovesForSlapping = {
   ["People"] = false;
   ["Replica"] = false;
   ["Cherry"] = false;
   ["5 More"] = false;
   ["Baller"] = false;
   ["Blink"] = false;
   ["Null"] = false;
}
StickYourself:CreateToggle({Name = "Slap People? ( If true: Only this will be used )"; Default = false; Callback = function(Value)
StickGlovesForSlapping["People"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap Replica?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["Replica"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap Cherry?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["Cherry"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap 5 More?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["5 More"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap Baller?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["Baller"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap Blink?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["Blink"] = Value
end; })
StickYourself:CreateToggle({Name = "Slap Null?"; Default = false; Callback = function(Value)
StickGlovesForSlapping["Null"] = Value
end; })

local StickProcessID = nil
StickYourself:CreateToggle({Name = "Start Farming"; Default = false; Callback = function(Value)
if Value==true then
HumanoidRootPart:PivotTo(workspace["platform1"].CFrame * CFrame.new(0,10,0))
task.wait(1)
StickProcessID = CreateProcess(StickGlovesForSlapping, "Stick", game.ReplicatedStorage.GeneralHit)
elseif StickProcessID~=nil then
ShutdownProcess(StickProcessID)
end
end; })

--[[local args = {
	true
}
game:GetService("ReplicatedStorage"):WaitForChild("MaceRaiseArm"):FireServer(unpack(args))
]]
