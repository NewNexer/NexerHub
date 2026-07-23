

if DODHUBLOADED==true then
game.Players.LocalPlayer:Kick("Script was already executed before. A rejoin is required to execute it again! Rejoining...")
task.wait(3)
if #game.Players:GetPlayers() <= 1 then
game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
else
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end
end
getgenv().DODHUBLOADED = true

--[[

Your Variables and global variables

]]--



--[[ You can change this ]]--
AuthorKey = "Nexer"
GameKey = "Die Of Death"
local ScriptLink = "https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Launcher.luau"
local Version = "1.5.0"

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

-- Loading my modules
local msg = CreateMessage()
msg.Text = "Loading Modules... (0/4)"
local modules = {
	{"Main Module", "https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Modified%20Module.luau", true},
	{"Client Replicator", "https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Modules/ClientReplicator.luau", true},
	{"Client Animations", "https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Modules/ClientAnimations.luau", true},
	{"Client Abilities", "https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Modules/ClientAbilities.luau", true},
}
local loaded, attempts = {}, {}
for i = 1, #modules do attempts[i] = 0 end
local i = 1
repeat task.wait()
	local suc, res = pcall(function()
		return modules[i][3] and loadstring(game:HttpGet(modules[i][2]))() or game:HttpGet(modules[i][2])
	end)
	if not suc then
		attempts[i] += 1
		msg.Text = "Failed loading module '"..modules[i][1].."', retry: "..attempts[i]
		task.wait(1)
	else
		loaded[modules[i][1]] = res
		msg.Text = "Loading module '"..modules[i][1].."'... ("..tostring(i).."/4)"
		i += 1
		task.wait(1)
	end
until i > #modules
local Module, CReplicator, CAnimations, CAbilities = loaded["Main Module"], loaded["Client Replicator"], loaded["Client Animations"], loaded["Client Abilities"]
msg.Text = "Launching Rayfield..."
local Rayfield = Module:GetWorkingRayfield()
task.delay(2, function() msg:Destroy() end)


--[[ Re-writing variables ]]--
AuthorKey = ""..((AuthorKey ~= nil and AuthorKey) or "Unknown")..""
GameKey = ""..((GameKey ~= nil and GameKey) or "Unknown")..""


--[[ Creating Window ]]--
local Window = Rayfield:CreateWindow({
   Name = ""..AuthorKey.." Hub : "..GameKey.."",
   Icon = 0,    
   LoadingTitle = ""..string.sub(AuthorKey,1,1).."H:"..GameKey:gsub("(%S)%S+","%1"):gsub("%s+","").."",
   LoadingSubtitle = "By "..AuthorKey.."",
   Theme = "Default",
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





local Announcements = Window:CreateTab("Announce",0)
Announcements:CreateParagraph({Title = "W.I.P.", Content = "A lot of stuff haven't been added yet. Work is in progress."})
Announcements:CreateLabel("Version: "..Version)
Announcements:CreateButton({Name = "Copy discord server link"; Callback = function()
setclipboard(tostring("https://discord.gg/7u5GRNw3xn"))
Rayfield:Notification("Success!", "Copied Link!", 3, true)
end; })

Window:CreateTabSection("Movement")

local Movement = Window:CreateTab("Movement",0)

local function GetLegitMaxStamina()
local legitmaxstamina = 100
if Character:GetAttribute("Killer") then
if Character:GetAttribute("Killer")=="Pursuer" or Character:GetAttribute("Killer")=="Killdroid" or Character:GetAttribute("Killer")=="Badware" then
legitmaxstamina = 110
elseif Character:GetAttribute("Killer")=="Harken" then
legitmaxstamina = 114
end
end
return legitmaxstamina
end
local InfiniteStamina = false
Movement:CreateToggle({Name = "Infinite Stamina"; CurrentValue = false; Callback = function(Value)
InfiniteStamina = Value
Character:SetAttribute("MaxStamina",(Value==true and math.huge or GetLegitMaxStamina()))
if Character:IsDescendantOf(workspace.GameAssets.Teams) then
Rayfield:Notification("Success!", "Infinite stamina will automatically inject once the new round starts!", 3, true)
end
end; })
local CanJump = false
Movement:CreateToggle({Name = "Can Jump?"; CurrentValue = false; Callback = function(Value)
CanJump = Value
if Value==true then Humanoid.UseJumpPower=false else Humanoid.UseJumpPower=true end
end; })
local NoFatigue = false
Movement:CreateToggle({Name = "No Fatigue"; CurrentValue = NoFatigue; Callback = function(Value)
NoFatigue = Value
if Value == true then
task.spawn(function()
Heartbeat.LoopNoFatigue = function() if Character~=nil and Character:GetAttribute("Fatigue")~=nil and Character:GetAttribute("Fatigue") == 1 then Character:SetAttribute("Fatigue", 0) end end
repeat task.wait(0.1) until NoFatigue == false
if Heartbeat.LoopNoFatigue~=nil then
Heartbeat.LoopNoFatigue = nil
end
end)
end
end; })
local NoSpeedDebuffs = false
Movement:CreateToggle({Name = "No Speed Debuffs"; CurrentValue = NoFatigue; Callback = function(Value)
NoSpeedDebuffs = Value
if Value == true then
task.spawn(function()
Heartbeat.LoopNoSpeedDebuffs = function() if Character~=nil and Character:GetAttribute("WalkSpeedModifier")~=nil and Character:GetAttribute("WalkSpeedModifier")<0 then Character:SetAttribute("WalkSpeedModifier", 0) end end
repeat task.wait(0.1) until NoSpeedDebuffs == false
if Heartbeat.LoopNoSpeedDebuffs~=nil then
Heartbeat.LoopNoSpeedDebuffs = nil
end
end)
end
end; })
Movement:CreateSection("Advanced")
Movement:CreateInput({Name = "Max Stamina"; PlaceholderText = "100"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
Char:SetAttribute("MaxStamina", tonumber(Value))
end; })
Movement:CreateInput({Name = "Walk Speed"; PlaceholderText = "11"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
Char:SetAttribute("WalkSpeed", tonumber(Value))
end; })
Movement:CreateInput({Name = "Sprint Speed"; PlaceholderText = "26"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
Char:SetAttribute("SprintSpeed", tonumber(Value))
end; })
Movement:CreateInput({Name = "Walk Speed Modifier"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = true; Callback = function(Value)
Char:SetAttribute("WalkSpeedModifier", tonumber(Value))
end; })
Movement:CreateToggle({Name = "Fatigue"; CurrentValue = false; Callback = function(Value)
Char:SetAttribute("Fatigue", ((Value==true and 1) or 0))
end; })
Movement:CreateToggle({Name = "Stamina Regen Paused"; CurrentValue = false; Callback = function(Value)
Char:SetAttribute("PauseRegen", ((Value==true and 1) or 0))
end; })
Movement:CreateToggle({Name = "Sprint Disabled"; CurrentValue = false; Callback = function(Value)
Char:SetAttribute("DisableSprint", Value)
end; })

local Teleport = Window:CreateTab("Teleport",0)
Teleport:CreateParagraph({Title = "Teleports", Content = "Teleport to killer / survivors and others."})
function SafeTeleport(model)
pcall(function()
local time = tick()
while tick() - time < 1 do
for i,v in pairs(Character:GetDescendants()) do
if v and v:IsA("BasePart") then
v.Velocity = Vector3.new(0,0,0)
v.RotVelocity = Vector3.new(0,0,0)
end
end
HumanoidRootPart.CFrame = model.CFrame
task.wait()
end
end)
end
function GetChildNames(model)
local coolbalt = {}
for i,v in pairs(model:GetChildren()) do
if v then
table.insert(coolbalt, tostring(v.Name))
end
end
return coolbalt
end
Teleport:CreateSection("Team Teleport")
ChoosenKillerTarget = nil
ChoosenSurvivorTarget = nil
ChoosenGhostTarget = nil
local TeleportToKillerDropdown = Teleport:CreateDropdown({Name = "Target Killer"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenKillerTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Killer"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no killers!", 3, warn)
return nil
end
if ChoosenKillerTarget == nil or ChoosenKillerTarget == "" or not ChoosenKillerTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, false)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer"):FindFirstChild(ChoosenKillerTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer").ChildAdded:Connect(function(child)
pcall(function()
TeleportToKillerDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToKillerDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")))
end)
end)
local TeleportToSurvivorDropdown = Teleport:CreateDropdown({Name = "Target Survivor"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenSurvivorTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Survivor"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no survivors!", 3, false)
return nil
end
if ChoosenSurvivorTarget == nil or ChoosenSurvivorTarget == "" or not ChoosenSurvivorTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, warn)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor"):FindFirstChild(ChoosenSurvivorTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor").ChildAdded:Connect(function(child)
pcall(function()
TeleportToSurvivorDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToSurvivorDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")))
end)
end)
local TeleportToGhostDropdown = Teleport:CreateDropdown({Name = "Target Ghost"; Options = GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")); CurrentOption = ""; MultiSelection = false; Callback = function(Value)
ChoosenGhostTarget = Rayfield:GetDropdownValue(Value)
end; })
Teleport:CreateButton({Name = "Teleport to Ghost"; Callback = function()
if not game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost"):FindFirstChildOfClass("Model") then
Rayfield:Notification("Error!", "There are no ghosts!", 3, warn)
return nil
end
if ChoosenGhostTarget == nil or ChoosenGhostTarget == "" or not ChoosenGhostTarget then
Rayfield:Notification("Error!", "Choose your target!", 3, false)
return nil
end
SafeTeleport(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost"):FindFirstChild(ChoosenGhostTarget):WaitForChild("HumanoidRootPart"))
end; })
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost").ChildAdded:Connect(function(child)
pcall(function()
TeleportToGhostDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")))
end)
end)
game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost").ChildRemoved:Connect(function(child)
pcall(function()
TeleportToGhostDropdown:Refresh(GetChildNames(game:GetService("Workspace"):WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost")))
end)
end)

Window:CreateTabSection("Survivor")

local AbilityGiver = Window:CreateTab("Ability Giver",0)

AbilityGiver:CreateLabel("No it's patched")

local AbilityBugle = Window:CreateTab("Bugle",0)

local BugleDelay = 0
AbilityBugle:CreateSlider({Name = "Delay Between using Bugle"; Range = {0, 2}; Increment = .1; Suffix = " seconds"; CurrentValue = 0; Callback = function(Value)
BugleDelay = tonumber(Value)
end; })

local AutoBugle = false
AbilityBugle:CreateToggle({Name = "Auto Bugle"; CurrentValue = false; Callback = function(Value)
AutoBugle = Value
end; })
LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle:GetPropertyChangedSignal("Visible"):Connect(function()
if LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle.Visible and AutoBugle then
for i=1,100 do
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Abilities"):WaitForChild("Bugle"):FireServer(true)
if BugleDelay~=0 then
task.wait(BugleDelay)
end
if not LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Bugle.Visible then
break
end
end
end
end)

local AbilityPie = Window:CreateTab("Pie",0)

AbilityPie:CreateMarkdown({Title = "Coordinates Guide", Content = [[
By using coordinates you can decide where will the pie be thrown. The pie is being launched from HumanoidRootPart's front.
The default is Vector3.new(0,0,-150). This will shoot the pie just like the bullet from the revolver and will explode after flying -150 studs on Z coordinate.

Examples:
Vector3.new(X,Y,Z) - The coordinates you can set below
Vector3.new(0,0,0) - On Yourself
Vector3.new(-100,0,0) - Left (relative to where HumanoidRootPart is facing)
Vector3.new(100,0,0) - Right (relative to where HumanoidRootPart is facing)
Vector3.new(0,-100,0) - Down (relative to where HumanoidRootPart is facing)
Vector3.new(0,100,0) - Up (relative to where HumanoidRootPart is facing)
Vector3.new(0,0,-100) - Forward (relative to where HumanoidRootPart is facing)
Vector3.new(0,0,100) - Backward (relative to where HumanoidRootPart is facing)]]})

local Pie_X = 0
AbilityPie:CreateInput({Name = "X Coordinate"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_X = tonumber(Value)
end; })

local Pie_Y = 0
AbilityPie:CreateInput({Name = "Y Coordinate"; PlaceholderText = "0"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_Y = tonumber(Value)
end; })

local Pie_Z = -150
AbilityPie:CreateInput({Name = "Z Coordinate"; PlaceholderText = "-150"; NumbersOnly = true; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
Pie_Z = tonumber(Value)
end; })

local PieDelay = 0
AbilityPie:CreateSlider({Name = "Delay Before using Pie"; Range = {0, 3}; Increment = .1; Suffix = " seconds"; CurrentValue = 0; Callback = function(Value)
PieDelay = tonumber(Value)
end; })

local AutoPie = false
AbilityPie:CreateToggle({Name = "Auto Pie"; CurrentValue = false; Callback = function(Value)
AutoPie = Value
end; })
LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Pie:GetPropertyChangedSignal("Visible"):Connect(function()
if LocalPlayer.PlayerGui.MainGui.RoundUI.Civilian.Pie.Visible and AutoPie then
if PieDelay~=0 then
task.wait(PieDelay)
end
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Abilities"):WaitForChild("Pie"):FireServer(Vector3.new(Pie_X,Pie_Y,Pie_Z))
end
end)

Window:CreateTabSection("Killer")

local AbilitySwing = Window:CreateTab("M1",0)

local NoCDSwing = false
AbilitySwing:CreateToggle({Name = "No Cooldown M1"; CurrentValue = false; Callback = function(Value)
NoCDSwing = Value
if NoCDSwing~=true then return end
Character:SetAttribute("SwingCooldown","")
Character:GetAttributeChangedSignal("SwingCooldown"):Connect(function()
if NoCDSwing~=true then return end
Character:SetAttribute("SwingCooldown","")
end)
Character:SetAttribute("EjectCooldown","")
Character:GetAttributeChangedSignal("EjectCooldown"):Connect(function()
if NoCDSwing~=true then return end
Character:SetAttribute("EjectCooldown","")
end)
end; })
LocalPlayer.CharacterAdded:Connect(function(cac)
task.spawn(function()
if InfiniteStamina~=true then return end
cac:SetAttribute("MaxStamina",math.huge)
cac:GetAttributeChangedSignal("MaxStamina"):Connect(function()
if InfiniteStamina~=true then return end
cac:SetAttribute("MaxStamina",math.huge)
end)
end)
task.spawn(function()
if CanJump~=true then return end
cac:WaitForChild("Humanoid",9e9).UseJumpPower=true
end)
task.spawn(function()
if NoCDSwing~=true then return end
cac:SetAttribute("SwingCooldown","")
cac:GetAttributeChangedSignal("SwingCooldown"):Connect(function()
if NoCDSwing~=true then return end
cac:SetAttribute("SwingCooldown","")
end)
end)
task.spawn(function()
if NoCDSwing~=true then return end
cac:SetAttribute("EjectCooldown","")
cac:GetAttributeChangedSignal("EjectCooldown"):Connect(function()
if NoCDSwing~=true then return end
cac:SetAttribute("EjectCooldown","")
end)
end)
end)

function ReloadClientReplicator()
pcall(function()
ClientReplicator.Disconnect()
end)
pcall(function()
ClientReplicator = nil
end)
loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/DOD/Modules/ClientReplicator.luau"))()
end

Window:CreateTabSection("Hitboxes")

local HitboxExtender = Window:CreateTab("Hitbox Extender",0)

HitboxExtender:CreateParagraph({Title = "Hitbox Extender", Content = "Your hitbox server position will be spoofed and extended depending on the settings below."})
HitboxExtender:CreateToggle({Name = "Extend Hitbox?"; CurrentValue = false; Callback = function(Value)
ClientReplicator["Extend Hitbox"] = Value
end; })
HitboxExtender:CreateSlider({Name = "Hitbox Extend Range"; Range = {0, 50}; Increment = 0.5; Suffix = " studs"; CurrentValue = 5; Callback = function(Value)
ClientReplicator["Studs"] = Value
end; })

local HitboxReacher = Window:CreateTab("Hitbox Reacher",0)

local HitboxReacherEnabled = false
local HitboxReacherRange = 20
local WhoToTargetHitboxReach = "Auto"
local ClosestCivilian = nil
Heartbeat.ClosestCivilian = function()
    local closestplayer = nil
    local closestdistance = HitboxReacherRange + 1
    for i,v in next, workspace.GameAssets.Teams.Survivor:GetChildren() do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildWhichIsA("Humanoid") and HumanoidRootPart and Humanoid and Humanoid.Health>0 then
            local humanoid = v:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < closestdistance then
                    closestdistance = distance
                    closestPlayer = game.Players:GetPlayerFromCharacter(v)
                end
            end
        end
    end
    ClosestCivilian = closestPlayer
end
local ClosestKiller = nil
Heartbeat.ClosestKiller = function()
    local closestplayer = nil
    local closestdistance = HitboxReacherRange + 1
    for i,v in next, workspace.GameAssets.Teams.Killer:GetChildren() do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildWhichIsA("Humanoid") and HumanoidRootPart and Humanoid and Humanoid.Health>0 then
            local humanoid = v:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < closestdistance then
                    closestdistance = distance
                    closestPlayer = game.Players:GetPlayerFromCharacter(v)
                end
            end
        end
    end
    ClosestKiller = closestPlayer
end
local ClosestAuto = nil
Heartbeat.ClosestAuto = function()
    local choosrnplayer = nil
    local closestdistance = HitboxReacherRange + 1
	if workspace:FindFirstChild(LocalPlayer.Name,true).Parent.Name=="Survivor" and Character:FindFirstChild("Vanities") and Character.Vanities:FindFirstChild("CaretakerItem") and Character.Vanities.CaretakerItem.Transparency~=1 then
    for i,v in next, workspace.GameAssets.Teams.Survivor:GetChildren() do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildWhichIsA("Humanoid") and HumanoidRootPart and Humanoid and Humanoid.Health>0 then
            local humanoid = v:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < (HitboxReacherRange + 1) then
                    if humanoid.Health < lowestHp then
                        lowestHp = humanoid.Health
                        choosrnplayer = game.Players:GetPlayerFromCharacter(v)
                    end
                end
            end
        end
    end
	elseif workspace:FindFirstChild(LocalPlayer.Name,true).Parent.Name=="Survivor" then
	for i,v in next, workspace.GameAssets.Teams.Killer:GetChildren() do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildWhichIsA("Humanoid") and HumanoidRootPart and Humanoid and Humanoid.Health>0 then
            local humanoid = v:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < closestdistance then
                    closestdistance = distance
                    choosrnplayer = game.Players:GetPlayerFromCharacter(v)
                end
            end
        end
    end
	elseif workspace:FindFirstChild(LocalPlayer.Name,true).Parent.Name=="Killer" then
    for i,v in next, workspace.GameAssets.Teams.Survivor:GetChildren() do
        if v and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildWhichIsA("Humanoid") and HumanoidRootPart and Humanoid and Humanoid.Health>0 then
            local humanoid = v:FindFirstChildWhichIsA("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if distance < closestdistance then
                    closestdistance = distance
                    choosrnplayer = game.Players:GetPlayerFromCharacter(v)
                end
            end
        end
    end
	end
    ClosestAuto = choosrnplayer
end
Heartbeat.HitboxReacherHandler = function()
if HitboxReacherEnabled==true then
if WhoToTargetHitboxReach=="Auto" then
if ClosestAuto and ClosestAuto.Character and ClosestAuto.Character:FindFirstChild("HumanoidRootPart") and (ClosestAuto.Character.HumanoidRootPart.Position-HumanoidRootPart.Position).Magnitude<(HitboxReacherRange+1) then
ClientReplicator.HookOnto(ClosestAuto)
else
ClientReplicator.Unhook()
end
elseif WhoToTargetHitboxReach=="Killers Only" then
if ClosestKiller and ClosestKiller.Character and ClosestKiller.Character:FindFirstChild("HumanoidRootPart") and (ClosestKiller.Character.HumanoidRootPart.Position-HumanoidRootPart.Position).Magnitude<(HitboxReacherRange+1) then
ClientReplicator.HookOnto(ClosestKiller)
else
ClientReplicator.Unhook()
end
elseif WhoToTargetHitboxReach=="Civilians Only" then
if ClosestCivilian and ClosestCivilian.Character and ClosestCivilian.Character:FindFirstChild("HumanoidRootPart") and (ClosestCivilian.Character.HumanoidRootPart.Position-HumanoidRootPart.Position).Magnitude<(HitboxReacherRange+1) then
ClientReplicator.HookOnto(ClosestCivilian)
else
ClientReplicator.Unhook()
end
end
else
ClientReplicator.Unhook()
end
end
HitboxReacher:CreateParagraph({Title = "Hitbox Reacher", Content = "Your hitbox server position will be spoofed and teleported to players depending on the settings below.\nTarget Options:\n1. Auto - Automatically decides who to target. If you are the killer, the hitboxes will target closest civilian. If you are civilian and tried landing a punch, the hitboxes will target the closest killer. If you are civilian and used caretaker, the hitboxes will target the closest civilian with least hp.\n2. Killers Only - The hitboxes will target only killers.\n2. Civilians Only - The hitboxes will target only civilians."})
HitboxReacher:CreateToggle({Name = "Hitbox Reacher"; CurrentValue = false; Callback = function(Value)
HitboxReacherEnabled = Value
end; })
HitboxReacher:CreateDropdown({Name = "Target"; Options = {"Auto";"Killers Only";"Civilians Only"}; CurrentOption = "Auto"; MultiSelection = false; Callback = function(Value)
WhoToTargetHitboxReach = Rayfield:GetDropdownValue(Value)
end; })
HitboxReacher:CreateSlider({Name = "Hitbox Reach Range"; Range = {0, 80}; Increment = 0.5; Suffix = " studs"; CurrentValue = 20; Callback = function(Value)
HitboxReacherRange = Value
end; })


Window:CreateTabSection("Visual")

local guiT = Window:CreateTab("UI",0)

guiT:CreateButton({Name = "Make all hidden skins visible"; Callback = function()
if not require then
Rayfield:Notification("Error!", "Missing function 'require'! Your executor seems to not support it!", 3, false)
end
for i,v in next,game:GetService("ReplicatedStorage").ClientModules:GetDescendants() do if v and v:IsA("ModuleScript") then
pcall(function()
local a = require(v)
if a.Hidden~=nil and a.Hidden==true then
a.Hidden = nil
end
if a.DevOnly~=nil and a.DevOnly==true then
a.DevOnly = nil
end
end)
end; end
end; })

local ESP = Window:CreateTab("ESP",0)

ESP:CreateToggle({Name = "ESP Enabled?"; CurrentValue = false; Callback = function(Value)
DODESP.functions.Toggle(Value)
end; })
ESP:CreateSlider({Name = "ESP Transparency"; Range = {0, 100}; Increment = 1; Suffix = "%"; CurrentValue = 50; Callback = function(Value)
DODESP.functions.SetTransparency(Value / 100)
end; })
ESP:CreateSlider({Name = "Billboard Size"; Range = {1, 5}; Increment = 1; Suffix = ""; CurrentValue = 1; Callback = function(Value)
DODESP.functions.SetBillboardSize(Value)
end; })
ESP:CreateToggle({Name = "Show Username"; CurrentValue = true; Callback = function(Value)
DODESP.settings.ShowName = Value
end; })
ESP:CreateToggle({Name = "Show Health"; CurrentValue = true; Callback = function(Value)
DODESP.settings.ShowHealth = Value
end; })
ESP:CreateToggle({Name = "Show Stamina"; CurrentValue = true; Callback = function(Value)
DODESP.settings.ShowStamina = Value
end; })


Window:CreateTabSection("Animations")
local Animations = Window:CreateTab("Animations",0)
local agaas = Animations:CreateLabel("Animations will work after your character will be reset. This label will change if the character has already been reseted.")
LocalPlayer.CharacterAdded:Once(function()
agaas:Set("Animations of civilians, killers and others.")
end)
function ReturnAnimFolder()
if Character:FindFirstChild("Animations") then
return Character:WaitForChild("Animations")
end
return nil
end
function SetRunAnim(run)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("HurtSprint") then
AnimationFolder:FindFirstChild("HurtSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("NormalSprint") then
AnimationFolder:FindFirstChild("NormalSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldSprint") then
AnimationFolder:FindFirstChild("OldSprint").AnimationId = run
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("Sprint") then
AnimationFolder:FindFirstChild("Sprint").AnimationId = run
end
end)
end
function SetWalkAnim(walk)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("Walk") then
AnimationFolder:FindFirstChild("Walk").AnimationId = walk
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldWalk") then
AnimationFolder:FindFirstChild("OldWalk").AnimationId = walk
end
end)
end
function SetIdleAnim(idle)
pcall(function()
local stopper = Humanoid or Character:FindFirstChildOfClass("AnimationController")
for i,v in next, stopper:GetPlayingAnimationTracks() do
v:Stop()
end
end)
local AnimationFolder = ReturnAnimFolder()
pcall(function()
if AnimationFolder:FindFirstChild("Idle") then
AnimationFolder:FindFirstChild("Idle").AnimationId = idle
end
end)
pcall(function()
if AnimationFolder:FindFirstChild("OldIdle") then
AnimationFolder:FindFirstChild("OldIdle").AnimationId = idle
end
end)
end
function ApplyNewAnimations()
pcall(function()
ClientAnimations:Reload()
end)
end
task.wait()
Animations:CreateSection("Pre-loaded animations")
Animations:CreateLabel("Civilian animations")
Animations:CreateButton({Name = "Apply New Civilian Animations"; Callback = function()
local RunAnim = "rbxassetid://137375023685630"
local WalkAnim = "rbxassetid://84388941697203"
local IdleAnim = "rbxassetid://100930402371608"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateButton({Name = "Apply Old Civilian animations"; Callback = function()
local RunAnim = "rbxassetid://79488319304371"
local WalkAnim = "rbxassetid://138161225743614"
local IdleAnim = "rbxassetid://74309548749074"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateLabel("Ghost Animations")
Animations:CreateButton({Name = "Apply Ghost animations"; Callback = function()
local RunAnim = "rbxassetid://124260679864309"
local WalkAnim = "rbxassetid://124260679864309"
local IdleAnim = "rbxassetid://110395159339100"
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
Animations:CreateSection("Auto-loaded animations")
pcall(function()
for i,v in pairs(game:GetService("ReplicatedStorage").ClientModules.Characters:GetChildren()) do if v.Name=="Civilian" or v.Name=="Ghost" then continue elseif v then
Animations:CreateLabel(v.Name.." Animations")
local temp_table = {}
for _,e in pairs(v.Skins:GetChildren()) do if e and e:FindFirstChildWhichIsA("Model") and e:FindFirstChildWhichIsA("Model"):FindFirstChild("Animations") then
table.insert(temp_table, e:FindFirstChildWhichIsA("Model").Name)
end; end
local Hi = v:WaitForChild("Default")
Animations:CreateDropdown({Name = "Choose "..v.Name.." animations"; Options = temp_table; CurrentOption = "Default"; MultiSelection = false; Callback = function(Value)
Hi = v.Skins:WaitForChild(Rayfield:GetDropdownValue(Value)):WaitForChild(Rayfield:GetDropdownValue(Value))
end; })
Animations:CreateButton({Name = "Apply "..v.Name.." animations"; Callback = function()
local RunAnim = Hi:WaitForChild("Animations"):WaitForChild("Sprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldSprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("NormalSprint").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("HurtSprint").AnimationId
local WalkAnim = Hi:WaitForChild("Animations"):WaitForChild("Walk").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldWalk").AnimationId
local IdleAnim = Hi:WaitForChild("Animations"):WaitForChild("Idle").AnimationId or Hi:WaitForChild("Animations"):WaitForChild("OldIdle").AnimationId
task.spawn(function()
SetRunAnim(RunAnim)
SetWalkAnim(WalkAnim)
SetIdleAnim(IdleAnim)
task.wait()
ApplyNewAnimations()
end)
Rayfield:Notification("Success!", "Applying animations, it may take up to 5 seconds.", 3, true)
end; })
end; end
end)

Window:CreateTabSection("Premium")

local noclip_connection = nil
local camera_connection = nil
function ApplyInvisibility(bool)
if bool == false then
task.spawn(function()
for i,v in next, Humanoid:GetPlayingAnimationTracks() do
v.Priority = Enum.AnimationPriority.Core
v:AdjustSpeed(tonumber(0))
v:Stop(tonumber(0))
end
end)
if noclip_connection then
noclip_connection:Disconnect()
noclip_connection = nil
end
if camera_connection then
camera_connection:Disconnect()
camera_connection = nil
pcall(function()
workspace.CurrentCamera.CameraSubject = Humanoid
end)
end
elseif bool == true then
local function nocollision()
for i,v in pairs(LP.Character:GetDescendants()) do
if v and v:IsA("BasePart") and v.CanCollide == true and v.Name ~= "HumanoidRootPart" then
v.CanCollide = false
end
end
if LP.Character:FindFirstChild("HumanoidRootPart") then
LP.Character:FindFirstChild("HumanoidRootPart").CanCollide = true
end
end
noclip_connection = game:GetService("RunService").Stepped:Connect(nocollision)
workspace.CurrentCamera.CameraSubject = HumanoidRootPart
camera_connection = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
workspace.CurrentCamera.CameraSubject = HumanoidRootPart
end)
local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://90444351114401" -- If you will use my invis, please credit me.
local loadedanim = Humanoid:LoadAnimation(Anim)
loadedanim.Priority = Enum.AnimationPriority.Action4
repeat task.wait() until loadedanim.Length > 0	
loadedanim:Play()
repeat task.wait() until loadedanim.IsPlaying
loadedanim:AdjustSpeed(tonumber(0))
loadedanim.TimePosition = 2.2
end
end
local InvisibilityTab = Window:CreateTab("Invisibility",0)
InvisibilityTab:CreateToggle({Name = "Invisibility"; CurrentValue = false; Callback = function(Value)
ApplyInvisibility(Value)
end; })

local ServerLagTab = Window:CreateTab("Lag Server",0)
ServerLagTab:CreateButton({Name = "Cause a Lag Spike to everyone in the server ( Breakdance emote required )"; Callback = function()
local con = workspace.DescendantAdded:Connect(function(d)
if d.Name=="EmoteObject" and d:FindFirstChild("Mesh") and d.Mesh.TextureId=="http://www.roblox.com/asset/?id=212303049  " then
d:Destroy()
end
if d.Name=="EmoteMusic" and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and d.Parent~=nil and d.Parent.Parent~=nil and game.Players:GetPlayerFromCharacter(d.Parent.Parent)==game.Players.LocalPlayer then
d:Destroy()
end
end)
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("Emote")
local name = "Breakdance"
task.spawn(function() 
    for i=1,5000 do 
        remote:FireServer(name) 
    end 
end)
task.wait(5)
con:Disconnect()
end; })

Window:CreateTabSection("Modules")

local ClientReplicatorTab = Window:CreateTab("Client Replicator",0)

ClientReplicatorTab:CreateButton({Name = "Reload Module"; Callback = function()
ReloadClientReplicator()
Rayfield:Notification("Success!", "Reloaded the module!", 3, true)
end; })

ClientReplicatorTab:CreateParagraph({Title = "Spoofer", Content = "The spoofer below targets the stamina data that is being sent to the server on every render frame.\nRegardless of your actual stamina—whether it’s 200, 1 million, or infinite — the value will be altered to match your character's range (0–114 max).\nThe spoofed stamina will not be static and will change based on your stamina percentage as well."})
ClientReplicatorTab:CreateToggle({Name = "Spoofing Enabled?"; CurrentValue = true; Callback = function(Value)
ClientReplicator["Spoof Enabled"] = Value
end; })

ClientReplicatorTab:CreateParagraph({Title = "No Ping Affection", Content = "Your hitboxes will be perfectly intact and synced with your character no matter the ping. Very useful!"})
ClientReplicatorTab:CreateToggle({Name = "No Ping Affection"; CurrentValue = false; Callback = function(Value)
ClientReplicator["No Ping Affection"] = Value
end; })

local ClientAnimationsTab = Window:CreateTab("Client Animations",0)

ClientAnimationsTab:CreateButton({Name = "Reload Module"; Callback = function()
ClientAnimations:Reload()
Rayfield:Notification("Success!", "Reloaded the module!", 3, true)
end; })

Window:CreateTabSection("Other")

local Other = Window:CreateTab("Other",0)

Other:CreateButton({Name = "Get All Client Achievements ( FE )"; Callback = function()
local Achievements = {"I'm Very Hungry!";"Violent Golf";"Laundry List";"I'm Your Biggest Fan";"Lifesaver";"Studious Scholar";"Best of Both Worlds";"Karma Called";"Sight Slaying";"Measuring Minutes";"I'm Just Saiyan'";"Here Lies: You";"Stealing The Spotlight";"Bloodshed";"Double Or Nothing";"Counting Seconds";"Golf Enthusiast";"Survivor's Guilt";"Fear And Hunger";"High Noon";"Big Spender";"Hot Stuff";"Born Again";"Biggest Threat In The Room";"Humble Beginnings";"Never-Ending Shift";"The First Of Many";"Little Spender";"Still Standing";"Sizable Wallet";"Live And Let Die.";"Another Mark On The Tally";"Vivid Recollection";"[MISSION SUCCESS]";"Les Misérables";"[SYSTEM_PURGE]";"Thrill Of the Hunt";"Participation Trophy";"The Best Defense...";"Meet The Sniper";"Give Em' Hell!";"Teetering On The Edge Of Life";"Every DoD Youtuber Be Like:";"Deep Dive";"Die Of Death Any% WR";"Tis But A Scratch";"Mulligan";"Albatross";"Combat Medic";"Spec-Tater";"Lucid Nightmare";"Slaughterhouse";"3-POINTER";"Born, Again?";"For Those We Lost Along The Way";"I'm Not Afraid Of You Anymore!";"Two Birds, One Stone!";"Help Wanted";"Luck of the Draw";"Mann Vs Machine";"Don't Call It A Comeback!";"Water Baby";"My spine hurts every night";"KABOOOM!"}
for i,v in pairs(Achievements) do
game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("RemoteEvents", 9e9):WaitForChild("Achievement", 9e9):FireServer(v)
game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("RemoteEvents", 9e9):WaitForChild("Achievement", 9e9):FireServer(v.."_Fixed")
end
end; })
Other:CreateButton({Name = "Close Hub"; Callback = function()
Rayfield:Destroy()
end; })
