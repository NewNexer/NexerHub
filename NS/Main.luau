--[[

Hello either Nullscape Developers or some curious exploiters.

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
if NG_aura_enabled==false then break end
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
if GG_aura_enabled==false then break end
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
function GetAvailableGift(a)
local AvailableGift = workspace.Spawn
if a=="Any" then
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("NormalGifts", 9e9):GetChildren() do
if v and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and v.Transparency~=1 then
AvailableGift = v
end
end
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("GoldenGifts", 9e9):GetChildren() do
if v and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and v.Transparency~=1 then
AvailableGift = v
end
end
elseif a=="Closest" then
local ClosestDistance = math.huge
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("NormalGifts", 9e9):GetChildren() do
if HRP~=nil and v and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and (HRP.Position-v:GetAttribute("StartPosition")).magnitude<ClosestDistance and v.Transparency~=1 then
ClosestDistance = (HRP.Position-v:GetAttribute("StartPosition")).magnitude
AvailableGift = v
end
end
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("GoldenGifts", 9e9):GetChildren() do
if HRP~=nil and v and v:GetAttribute("StartPosition")~=nil and v:GetAttribute("Collected")==false and v:GetAttribute("ClientCollected")==false and (HRP.Position-v:GetAttribute("StartPosition")).magnitude<ClosestDistance and v.Transparency~=1 then
ClosestDistance = (HRP.Position-v:GetAttribute("StartPosition")).magnitude
AvailableGift = v
end
end
end
return AvailableGift
end
local G_Speed = 0.16
local G_AutoFarmEnabled = false
local G_CanEscape = true
local G_X, G_Y = 0, 0
function GiftAutoFarm(a)
G_AutoFarmEnabled = a
if a~=true then return end
task.spawn(function()
while task.wait(.1) do
if G_AutoFarmEnabled==false then workspace.Beacon.CanTouch = true task.wait(.1) break end
local AvailableGift = GetAvailableGift("Closest")
if AvailableGift.Name~="Spawn" then
workspace.Beacon.CanTouch = G_CanEscape
local GiftPosition = AvailableGift:GetAttribute("StartPosition")
local Speed = ((GiftPosition-HumanoidRootPart.Position).magnitude<51 and G_Speed) or (G_Speed+1) 
if Speed>1 then
HumanoidRootPart.Anchored = true
end
--((GiftPosition-HumanoidRootPart.Position).Magnitude/G_Speed) Studs per second
--0.15 Yea
local Tween = game:GetService("TweenService"):Create(HumanoidRootPart,TweenInfo.new(Speed,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Position=(GiftPosition + Vector3.new(G_X,G_Y,0))}):Play()
repeat task.wait() until AvailableGift:GetAttribute("ClientCollected")==true or (HumanoidRootPart.Position - GiftPosition).Magnitude < 4 or G_AutoFarmEnabled==false
if Tween~=nil then Tween:Cancel() Tween=nil end
HumanoidRootPart.Anchored = false
repeat task.wait() until AvailableGift:GetAttribute("Collected")==true or G_AutoFarmEnabled==false
else
workspace.Beacon.CanTouch = true
task.wait(.1)
end
end
end)
end
local Tab1 = Window:CreateTab("Gifts",0)
Tab1:CreateParagraph({Title = "Gifts", Content = "Gifts pick-up aura and more"})
Tab1:CreateSection("Auto Pick Up")
Tab1:CreateParagraph({Title = "Normal Gifts", Content = "Warning! Changing to a faster speed or further distance *may* result in a ban ( anti-cheat )"})
local NG_Distance, NG_Cooldown = 40, 0.12
Tab1:CreateSlider({Name = "Pick up speed"; Range = {0,0.5}; Increment = 0.02; Suffix = " seconds"; CurrentValue = 0.12; Callback = function(Value)
NG_Cooldown = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Pick up distance"; Range = {0,50}; Increment = 1; Suffix = " studs"; CurrentValue = 40; Callback = function(Value)
NG_Distance = tonumber(Value)
end; })
Tab1:CreateToggle({Name = "Enable pick-up aura"; CurrentValue = false; Callback = function(Value)
GiftAura("Normal",Value,NG_Distance,NG_Cooldown)
end; })
Tab1:CreateParagraph({Title = "Golden Gifts", Content = "Warning! Changing to a faster speed or further distance *may* result in a ban ( anti-cheat )"})
local GG_Distance, GG_Cooldown = 40, 0.12
Tab1:CreateSlider({Name = "Pick-Up Speed"; Range = {0,0.5}; Increment = 0.02; Suffix = " seconds"; CurrentValue = 0.12; Callback = function(Value)
GG_Cooldown = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Pick-Up Distance"; Range = {0,50}; Increment = 1; Suffix = " studs"; CurrentValue = 40; Callback = function(Value)
GG_Distance = tonumber(Value)
end; })
Tab1:CreateToggle({Name = "Enable Pick-Up Aura"; CurrentValue = false; Callback = function(Value)
GiftAura("Golden",Value,GG_Distance,GG_Cooldown)
end; })
Tab1:CreateSection("Beam")
local CanEscapeintobeam = true
Tab1:CreateKeybind({Name = "Escape into Beam"; CurrentKeybind = "U"; HoldToInteract = false; Callback = function(Value)
if CanEscapeintobeam~=true then return end
CanEscapeintobeam = false
local a = workspace.Beacon.CFrame
workspace.Beacon.CFrame = HumanoidRootPart.CFrame
task.wait(1)
workspace.Beacon.CFrame = a
task.wait(.1)
CanEscapeintobeam = true
end; })
Tab1:CreateKeybind({Name = "Teleport to Closest Gift"; CurrentKeybind = "Y"; HoldToInteract = false; Callback = function(Value)
local AvailableGift = GetAvailableGift("Closest")
local GiftPosition = AvailableGift:GetAttribute("StartPosition")
HumanoidRootPart.CFrame = CFrame.new(GiftPosition.X,(GiftPosition.Y+10),GiftPosition.Z)
end; })
Tab1:CreateSection("Auto Farm")
Tab1:CreateLabel("Warning! Changing to a faster speed result in a ban")
Tab1:CreateSlider({Name = "Auto-Farm Pick Up Speed"; Range = {0,1}; Increment = 0.02; Suffix = " seconds per gift"; CurrentValue = 0.24; Callback = function(Value)
G_Speed = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Tween Offset (X)"; Range = {0,10}; Increment = 1; Suffix = " studs"; CurrentValue = 0; Callback = function(Value)
G_X = tonumber(Value)
end; })
Tab1:CreateSlider({Name = "Tween Offset (Y)"; Range = {0,10}; Increment = 1; Suffix = " studs"; CurrentValue = 0; Callback = function(Value)
G_Y = tonumber(Value)
end; })
Tab1:CreateToggle({Name = "Can't Escape into Beam during Auto-Farm"; CurrentValue = false; Callback = function(Value)
G_CanEscape = not Value
end; })
Tab1:CreateToggle({Name = "Enable Auto-Farm"; CurrentValue = false; Callback = function(Value)
GiftAutoFarm(Value)
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
Tab3:CreateSection("Skinwalker")
Tab3:CreateButton({Name = "Destroy Skinwalker"; Callback = function()
pcall(function() GetEnemies("Skinwalker",function(a) a:Destroy() end) end)
pcall(function() workspace.Skinwalkers:ClearAllChildren() end)
end; })





local Immunity_2D = false
local SkilwalkerImmunity = false
workspace.Enemies.ChildAdded:Connect(function(c)
if Immunity_2D~=true then return end
if c:IsA("BasePart") then
c.CanTouch=false
pcall(function() c.TouchInterest:Destroy() end)
pcall(function() c:FindFirstChildOfClass("TouchTransmitter"):Destroy() end)
end
end)
workspace.Skinwalkers.DescendantAdded:Connect(function(c)
if SkilwalkerImmunity~=true then return end
if c:IsA("BasePart") then
c.CanTouch=false
pcall(function() c.TouchInterest:Destroy() end)
pcall(function() c:FindFirstChildOfClass("TouchTransmitter"):Destroy() end)
end
end)
local antivoidtpplace = "Center of the Map"
if workspace:FindFirstChild("AntiVoid")==nil then
local a = workspace.KillVoid:Clone()
a.Position = workspace.KillVoid.Position + Vector3.new(0,20,0)
a.CanTouch = false
pcall(function() a.TouchInterest:Destroy() end)
pcall(function() a:FindFirstChildOfClass("TouchTransmitter"):Destroy() end)
task.wait()
a.CanCollide = false
a.Transparency = 1
a.Name = "AntiVoid"
a.Parent = workspace
a.Touched:Connect(function(h)
if h:IsA("Part") and game.Players:GetPlayerFromCharacter(h.Parent) then
if antivoidtpplace == "Center of the Map" then
game.Players:GetPlayerFromCharacter(h.Parent).Character.HumanoidRootPart.CFrame = workspace.Spawn.CFrame * CFrame.new(0,22,0)
elseif antivoidtpplace == "Random Gift" then
local AvailableGift = GetAvailableGift("Any")
local GiftPosition = AvailableGift:GetAttribute("StartPosition")
game.Players:GetPlayerFromCharacter(h.Parent).Character.HumanoidRootPart.CFrame = CFrame.new(GiftPosition.X,(GiftPosition.Y+22),GiftPosition.Z)
end
end
end)
end
local AutoRemoveIceTiles = false
workspace.CurrentRooms.DescendantAdded:Connect(function(c)
if AutoRemoveIceTiles~=true then return end
if c:IsA("BasePart") and c.Material==Enum.Material.Ice then
c.Material=Enum.Material.Plastic
end
end)
local AutoRemoveGravityDebuff = false
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
if workspace.Gravity<110 then
workspace.Gravity = 110
end
end)
local AutoProtectTripminess = false
if workspace:FindFirstChild("ProtectedTripmines") == nil then
local a = Instance.new("Folder")
a.Name = "ProtectedTripmines"
a.Parent = workspace
end
workspace.CurrentRooms.ChildAdded:Once(function()
for i,v in next, workspace.ProtectedTripmines:GetChildren() do
if v then v:Destroy() end
end
end)
function AutoProtectTripmines()
task.spawn(function()
while task.wait(.1) do
if AutoProtectTripminess==false then break end
for i,v in next, workspace:WaitForChild("ItemPools", 9e9):WaitForChild("Tripmines", 9e9):GetChildren() do
if v and not v:GetAttribute("uuid") or v:GetAttribute("uuid")==nil then v:SetAttribute("uuid",tostring(game:GetService("HttpService"):GenerateGUID(false))) end
if HRP~=nil and v and v:GetAttribute("StartPosition")~=nil and workspace:FindFirstChild("ProtectedTripmines") and workspace.ProtectedTripmines:FindFirstChild(v:GetAttribute("uuid"))==nil then
local sizeoffset = tonumber(v.Size.X) + 2.5
local a = Instance.new("Part")
a.Name = v:GetAttribute("uuid")
a.Position = v:GetAttribute("StartPosition")
a.Size = Vector3.new(sizeoffset,sizeoffset,sizeoffset)
a.Anchored = true
a.Parent = workspace.ProtectedTripmines
v:GetPropertyChangedSignal("Transparency"):Once(function()
a:Destroy()
end)
task.wait(.01)
end
end
end
end)
end
local Tab4 = Window:CreateTab("Immunities",0)
Tab4:CreateParagraph({Title = "Immunities", Content = "Immunities management"})
Tab4:CreateSection("Enemies")
Tab4:CreateLabel("2D enemies: Bell, Mart, Baby, Flesh, Telefragger and others. ( except dozer and kookoo )")
Tab4:CreateToggle({Name = "Immunity to all 2D enemies"; CurrentValue = false; Callback = function(Value)
Immunity_2D = Value
for _,c in next, workspace.Enemies:GetChildren() do
if c:IsA("BasePart") then
c.CanTouch = not Value
if Value==true then
pcall(function() c.TouchInterest:Destroy() end)
pcall(function() c:FindFirstChildOfClass("TouchTransmitter"):Destroy() end)
end
end
end
end; })
Tab4:CreateToggle({Name = "Immunity to all skinwalker types"; CurrentValue = false; Callback = function(Value)
SkilwalkerImmunity = Value
for _,c in next, workspace.Skinwalkers:GetDescendants() do
if c:IsA("BasePart") then
c.CanTouch = not Value
if Value==true then
pcall(function() c.TouchInterest:Destroy() end)
pcall(function() c:FindFirstChildOfClass("TouchTransmitter"):Destroy() end)
end
end
end
end; })
Tab4:CreateLabel("Client enemies: Voidbreaker, Kookoo, Dozer, Void, Stalker and others.")
Tab4:CreateToggle({Name = "Immunity to all client enemies"; CurrentValue = false; Callback = function(Value)
if Value==true and game.ReplicatedStorage.Events:FindFirstChild("DiedFunction") then
RemoveInstance(game.ReplicatedStorage.Events:FindFirstChild("DiedFunction"))
end
if Value==false and game.ReplicatedStorage.Events:FindFirstChild("DiedFunction")==nil then
RestoreInstance("DiedFunction")
end
end; })
Tab4:CreateSection("Map")
Tab4:CreateDropdown({Name = "Anti Void Teleport Place"; Options = {"Center of the Map","Random Gift"}; CurrentOption = "Center of the Map"; MultiSelection = false; Callback = function(Value)
antivoidtpplace = Rayfield:GetDropdownValue(Value)
end; })
Tab4:CreateToggle({Name = "Immunity to Void"; CurrentValue = false; Callback = function(Value)
workspace.AntiVoid.CanTouch = Value
workspace.AntiVoid.CanCollide = Value
end; })
Tab4:CreateToggle({Name = "Auto-Create Protection from Tripmines"; CurrentValue = false; Callback = function(Value)
AutoProtectTripminess = Value
if Value==true then AutoProtectTripmines() end
if Value==false then
for i,v in next, workspace.ProtectedTripmines:GetChildren() do
if v then v:Destroy() end
end
end
end; })
Tab4:CreateToggle({Name = "Auto-Remove Ice Tiles"; CurrentValue = false; Callback = function(Value)
AutoRemoveIceTiles = Value
for _,c in next, workspace.CurrentRooms:GetDescendants() do
if c:IsA("BasePart") and c.Material==Enum.Material.Ice then
c.Material=Enum.Material.Plastic
end
end
end; })
Tab4:CreateToggle({Name = "Auto-Remove Gravity Debuffs"; CurrentValue = false; Callback = function(Value)
AutoRemoveGravityDebuff = Value
if workspace.Gravity<110 and Value==true then
workspace.Gravity = 110
end
end; })





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




local Other = Window:CreateTab("Other",0)
Other:CreateParagraph({Title = "Other", Content = "Other things"})
Other:CreateButton({Name = "Instant Respawn ( Void )"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Died"):FireServer("Void",false)
end; })
Other:CreateButton({Name = "Unlock Reset Button"; Callback = function()
game.StarterGui:SetCore("ResetButtonCallback", true)
end; })
Other:CreateButton({Name = "Create Solo Server"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Servers"):WaitForChild("CreateLobby"):InvokeServer(unpack({2,true,1,0,false,false,true}))
end; })
Other:CreateButton({Name = "Create Solo Server"; Callback = function()
game:GetService("ReplicatedStorage"):WaitForChild("Servers"):WaitForChild("CreateLobby"):InvokeServer(unpack({2,true,1,0,false,false,true}))
end; })
Other:CreateButton({Name = "Close Hub"; Callback = function()
for i,v in next, Heartbeat do
if i then
Heartbeat[i] = nil
end
end
rscon:Disconnect()
Rayfield:Destroy()
end; })
