-- Hello I decided to leave it open sourced

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
EquipGlove = Module.EquipGlove
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
   Name = "[Private] Kick Utility",
   Icon = 0,
   LoadingTitle = "Kick Utility",
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
function FireworkKick(plrn)
local username = plrn
if not game:GetService("Players"):FindFirstChild(username) then
for i,v in next, game:GetService("Players"):GetPlayers() do
if v.DisplayName==plrn then
username = v.Name
end
end
end
task.wait()
if not game:GetService("Players"):FindFirstChild(username) then return end
if LocalPlayer.leaderstats.Slaps.Value>665 and Character:FindFirstChild("Head") and Character.Head.Transparency~=1 then
EquipGlove("Ghost")
game.ReplicatedStorage.Ghostinvisibilityactivated:FireServer()
repeat task.wait() until Character:FindFirstChild("Head") and Character.Head.Transparency==1 or Humanoid.Health==0
end
if LocalPlayer.leaderstats.Glove.Value~="Firework" then
EquipGlove("Firework")
end
for i,v in next, workspace.Lobby.brazil:GetDescendants() do
if v:IsA("TouchTransmitter") then
v:Destroy()
end
if v:IsA("BasePart") and v.Name~="platform" then
v.CanTouch = false
v.CanCollide = false
end
if v:IsA("TouchTransmitter") then
v:Destroy()
end
end
task.wait(.5)
if workspace.Lobby.brazil:FindFirstChild("platform")==nil then
local a = workspace.Lobby.brazil.portal:Clone()
a.Transparency = 0.8
a.CanCollide = true
a.Size = Vector3.new(40,40,4)
a.CFrame = workspace.Lobby.brazil.portal.CFrame * CFrame.new(0,0,-7)
for i,v in a:GetDescendants() do
if v then
v:Destroy()
end
end
a.Name = "platform"
a.Parent = workspace.Lobby.brazil
repeat task.wait() until workspace.Lobby.brazil:FindFirstChild("platform")
end
for i=1,50 do
HumanoidRootPart:PivotTo(CFrame.new(-1116.51514,306.96167,-1.4176054,0.00858737156,1.87259624e-10,0.999963105,-1.18700427e-07,1,8.32095726e-10,-0.999963105,-1.18703198e-07,0.00858737156))
end
task.wait(1)
repeat task.wait() until game:GetService("Players")[username].Character and game:GetService("Players")[username].Character:FindFirstChild("HumanoidRootPart") and game:GetService("Players")[username].Character:FindFirstChild("Ragdolled") and game:GetService("Players")[username].Character.Ragdolled.Value~=true and game:GetService("Players")[username].Character:FindFirstChild("Humanoid")
game.ReplicatedStorage.GeneralAbility:FireServer()
repeat task.wait() until workspace:FindFirstChild("Firework_"..LocalPlayer.Name) and workspace["Firework_"..LocalPlayer.Name]:FindFirstChild("VehicleSeat")
repeat task.wait() until game:GetService("Players")[username].Character and game:GetService("Players")[username].Character:FindFirstChild("HumanoidRootPart") and game:GetService("Players")[username].Character:FindFirstChild("Ragdolled") and game:GetService("Players")[username].Character.Ragdolled.Value~=true and game:GetService("Players")[username].Character:FindFirstChild("Humanoid")
repeat task.wait() game:GetService("Players")[username].Character.HumanoidRootPart:PivotTo(workspace["Firework_"..LocalPlayer.Name].VehicleSeat.CFrame) until game:GetService("Players")[username].Character.Humanoid.Sit==true
repeat task.wait() until workspace:FindFirstChild("Firework_"..LocalPlayer.Name)==nil
end
Window:CreateTabSection("Firework")
local Firework = Window:CreateTab("Firework Kick",0)
Firework:CreateSection("Obtainment")
Firework:CreateButton({Name = "Get Cake Mix"; Callback = function()
game:GetService("ReplicatedStorage").Firework:InvokeServer()
game:GetService("ReplicatedStorage").AlchemistEvent:FireServer("AddItem","Cake Mix")
task.wait()
game:GetService("ReplicatedStorage").AlchemistEvent:FireServer("EquipItem","Cake Mix")
end; })
Firework:CreateSection("Certain Kicking")
local CertainUsername = "Nexer"
Firework:CreateInput({Name="Name / Display Name"; PlaceholderText="Nexer"; NumbersOnly=false; OnEnter=true; RemoveTextAfterFocusLost=false; Callback=function(Value)
CertainUsername = tostring(Value)
end; })
Firework:CreateButton({Name = "Kick Player"; Callback = function()
FireworkKick(CertainUsername)
end; })
Firework:CreateSection("Mass Kicking")
Firework:CreateButton({Name = "Kick Everyone"; Callback = function()
for i,v in next, game:GetService("Players"):GetPlayers() do
if v and v~=LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health~=0 then
FireworkKick(v.Name)
end
end
end; })
Firework:CreateButton({Name = "Kick Everyone except Friends"; Callback = function()
for i,v in next, game:GetService("Players"):GetPlayers() do
if v and v~=LocalPlayer and not v:IsFriendsWith(LocalPlayer.UserId) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health~=0 then
FireworkKick(v.Name)
end
end
end; })
Window:CreateTabSection("Other")
local Other = Window:CreateTab("Other",0)
Other:CreateButton({Name = "Close UI"; Callback = function()
Rayfield:Destroy()
end; })
