--[[

Your Variables and global variables

]]--



--[[ You can change this ]]--
AuthorKey = "Nexer"
GameKey = "Limbus Game"

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


--[[ Re-writing variables ]]--
AuthorKey = ""..((AuthorKey ~= nil and AuthorKey) or "Unknown")..""
GameKey = ""..((GameKey ~= nil and GameKey) or "Unknown")..""


--[[ Creating Window ]]--
local Window = Rayfield:CreateWindow({
   Name = ""..AuthorKey.." Hub : "..GameKey.."",
   Icon = 0,    
   LoadingTitle = ""..string.sub(AuthorKey,1,1).."H:"..GameKey:gsub("(%S)%S+","%1"):gsub("%s+","").."",
   LoadingSubtitle = "By "..AuthorKey.."",
   Theme = "AmberGlow",
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
local rscon = rs.Heartbeat:Connect(function()
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
Announcements:CreateParagraph({Title = "Hi there!", Content = "Script Version: 1.0 ( WORK IN PROGRESS, EXCEPT A LOT OF BUGS )\n\Thank you for using my script.\n\nAlso join our discord server for announcements, early updates, and just for funsies..."})
Announcements:CreateButton({Name = "Copy Discord Server Link"; Callback = function()
setclipboard(tostring("https://discord.gg/7u5GRNw3xn"))
Notification("Success!", "Copied Link!", 3, true)
end; })



local Tab1 = Window:CreateTab("Main",0)

local ClosestHRP = nil
local AutoTurn = false
local AutoTracer = false
local Range = 140

Heartbeat.AutoTracer = function()
if AutoTracer ~= true then return end
pcall(function()
while not (game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Parent and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent) do
task.wait(.5)
end
local mag = (ClosestHRP.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
local vel = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity
if mag > Range then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = vel
elseif mag < 32 then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = (((ClosestHRP.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Unit) * (mag * 10))
elseif mag < 140 then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = (((ClosestHRP.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Unit) * (mag * 13))
else
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = vel
end
game:GetService("RunService").RenderStepped:Wait()
if (game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Parent and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Parent) then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Velocity = vel
end
end)
end

function IsNormal(v)
if v and v:FindFirstChild("Head") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
return true
end
return false
end

Heartbeat.ClosestPlayer = function()
pcall(function()
local ClosestDistance = math.huge
local NewClosest = nil
if not IsNormal(game:GetService("Players").LocalPlayer.Character) then
ClosestHRP = nil
return
end
for i,v in pairs(game.Players:GetPlayers()) do
if v ~= game:GetService("Players").LocalPlayer and IsNormal(v.Character) then
local Distance = (HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
if Distance < ClosestDistance then
ClosestDistance = Distance
NewClosest = v.Character.HumanoidRootPart
end
end
end
if AutoTurn == true and ClosestDistance < Range then
HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, NewClosest.Position)
end
ClosestHRP = NewClosest
end)
end

Tab1:CreateSection("Hitbox")

Tab1:CreateParagraph({Title = "Hitbox", Content = "Hitbox manipulations and management."})

Tab1:CreateLabel("Hitbox Auto Tracer")

Tab1:CreateLabel("Warning!")
Tab1:CreateLabel("For hitbox to hit, your character must be turned to position where closest player is! (or you can enable auto turn if you don't wanna do it manually)")

Tab1:CreateSlider({Name = "Range"; Range = {1, 140}; Increment = 1; Suffix = " studs"; CurrentValue = 140; Callback = function(Value)
Range = tonumber(Value)
end; })

Tab1:CreateToggle({Name = "Hitbox Auto Tracer"; CurrentValue = false; Callback = function(Value)
AutoTracer = Value
end; })

Tab1:CreateToggle({Name = "Auto Turn"; CurrentValue = false; Callback = function(Value)
AutoTurn = Value
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

msg:Destroy()

local Tab3 = Window:CreateTab("Other",0)
Tab3:CreateButton({Name = "Close Hub"; Callback = function()
for i,v in next, Heartbeat do
if i then
Heartbeat[i] = nil
end
end
rscon:Disconnect()
Rayfield:Destroy()
end; })
