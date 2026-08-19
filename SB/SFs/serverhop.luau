local settings = ... or {["snow"]=true;["slapples"]=true;["autoserverhop"]=6}

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

game:GetService("RunService").RenderStepped:Connect(function()
game:GetService("GuiService"):ClearError()
pcall(function()
game:GetService("CoreGui").RobloxLoadingGUI:Destroy()
end)
end)

function Serverhop()
task.spawn(function()
while task.wait() do
local servers = {}
local req = game:HttpGet("https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
local body = game:GetService("HttpService"):JSONDecode(req)
if body and body.data then
for i, v in next, body.data do
if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
table.insert(servers, 1, v.id)
end
end
end
if #servers > 0 then
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game:GetService("Players").LocalPlayer)
else
game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end
end
end)
end
task.delay(settings.autoserverhop,Serverhop)

if string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "Solara") then
local FixedFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/SCRIPT/Fix.lua"))()
getgenv().fireclickdetector = FixedFunctions.fireclickdetector
getgenv().fireproximityprompt = FixedFunctions.fireproximityprompt
end

local SelectGlove = function(g) repeat task.wait(.1) fireclickdetector(workspace.Lobby[g]:FindFirstChildWhichIsA("ClickDetector", true)) until LocalPlayer.leaderstats.Glove.Value==g task.wait(.1) end
local EnterArena = function(ar) local oldcf = ar.CFrame ar.CanCollide = false ar.CanTouch = true repeat task.wait() pcall(function() ar:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) ar:PivotTo(oldcf) ar.CanCollide = true end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end

function FindRandomEnemy()
local AllPlayers = game:GetService("Players"):GetChildren()
local RandomPlayer = AllPlayers[math.random(1, #AllPlayers)]
repeat task.wait()
RandomPlayer = AllPlayers[math.random(1, #AllPlayers)]
until RandomPlayer and RandomPlayer ~= LocalPlayer and RandomPlayer.Character and RandomPlayer.Character:FindFirstChild("entered") and RandomPlayer.Character:FindFirstChild("rock") == nil and RandomPlayer.Character:FindFirstChild("RobTransformed") == nil and RandomPlayer.Character:FindFirstChild("stevebody") == nil and RandomPlayer.Character:FindFirstChildWhichIsA("Humanoid") and RandomPlayer.Character:FindFirstChildWhichIsA("Humanoid").Health ~= 0 and RandomPlayer.Character:FindFirstChild("Torso") and RandomPlayer.Character:FindFirstChild("Torso").Transparency~=1 and RandomPlayer.Character.Torso:FindFirstChild("BuddyBox") == nil and RandomPlayer.Character:FindFirstChild("Head") and RandomPlayer.Character.Head:FindFirstChild("ScreamParticles") == nil and RandomPlayer.Character.Head:FindFirstChild("UnoReverseCard") == nil and RandomPlayer.Character.Head:FindFirstChild("UnoDraw4Card") == nil and RandomPlayer.Character.Head.BrickColor ~= "New Yeller" and RandomPlayer.Character:FindFirstChild("HumanoidRootPart") and RandomPlayer.Character.HumanoidRootPart:FindFirstChild("BlackheartREAL") == nil and RandomPlayer.Character.HumanoidRootPart:FindFirstChild("BlockedShield") == nil and Character and HumanoidRootPart and Humanoid
return RandomPlayer
end

if LocalPlayer.leaderstats.Slaps.Value>665 and settings.snow==true then
SelectGlove("Ghost")
game:GetService("ReplicatedStorage").Ghostinvisibilityactivated:FireServer()
repeat task.wait() until Character.Torso.Transparency==1
end
if settings.snow==true and LocalPlayer.leaderstats.Slaps.Value>84 then
SelectGlove("Snow")
end
if settings.slapples==true then
EnterArena((settings.snow==true and workspace.Lobby["Teleport1"]) or workspace.Lobby["Teleport2"])
task.spawn(function()
while task.wait(.05) do
for i,v in pairs(workspace.Arena["island5"].Slapples:GetChildren()) do
if (v.Name == "Slapple" or v.Name == "GoldenSlapple") and v:FindFirstChild("Glove") and v.Glove:FindFirstChildWhichIsA("TouchTransmitter") then
v.Glove:PivotTo(HumanoidRootPart.CFrame)
end
end
end
end)
if settings.snow~=true then
task.delay(2,Serverhop)
end
end
if settings.snow==true and LocalPlayer.leaderstats.Slaps.Value>84 then
game:GetService("ReplicatedStorage").GeneralAbility:FireServer("setcollisiongroup","NoCollideCharacterCollisionGroup")
local enemy = FindRandomEnemy()
task.spawn(function()
while task.wait() do
HumanoidRootPart:PivotTo(enemy.Character.HumanoidRootPart.CFrame)
end
end)
task.spawn(function()
while task.wait() do
pcall(OverrideVelocity)
end
end)
task.spawn(function()
while task.wait() do
if Character:FindFirstChildWhichIsA("Tool") then
pcall(function()
Character:FindFirstChildWhichIsA("Tool").Parent = LocalPlayer.Backpack
end)
end
end
end)
task.wait(2)
for i=1,2000 do
game:GetService("ReplicatedStorage").SnowHit:FireServer(enemy.Character.HumanoidRootPart)
end
end
