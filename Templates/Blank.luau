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
task.delay(2,function()
msg:Destroy()
end)


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





local Tab1 = Window:CreateTab("Main",0)

Tab1:CreateParagraph({Title = "Main", Content = "Text."})

Tab1:CreateLabel("Text")

Tab1:CreateSection("Text")

Tab1:CreateButton({Name = "Button"; Callback = function()
print("Text")
end; })

Tab1:CreateInput({Name = "Input"; PlaceholderText = "Text"; NumbersOnly = false; OnEnter = true; RemoveTextAfterFocusLost = false; Callback = function(Value)
print(Value)
end; })

Tab1:CreateDropdown({Name = "Dropdown"; Options = {"1","2"}; CurrentOption = "1"; MultiSelection = false; Callback = function(Value)
local Value = Rayfield:GetDropdownValue(Value) -- returns string
print(Value)
end; })

Tab1:CreateToggle({Name = "Toggle"; CurrentValue = false; Callback = function(Value)
print(Value)
end; })

Tab1:CreateSlider({Name = "Slider"; Range = {0, 100}; Increment = 5; Suffix = "%"; CurrentValue = 50; Callback = function(Value)
print(Value)
end; })
