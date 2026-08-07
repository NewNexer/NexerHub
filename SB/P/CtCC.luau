print("executed")

local flags = require(game:GetService("ReplicatedStorage").BACKEND.Shared.Flags.FlagService)
local original = flags.IsEnabled

flags.IsEnabled = function(flag, ...)
    if flag == "IgnoreSafety" then
        return true
    end
    return original(flag, ...)
end

local NETWORK = {}
local receive_connection = nil

NETWORK.get_network = function()
    return (game:GetService("ReplicatedStorage"):FindFirstChild("_NETWORK") and game:GetService("ReplicatedStorage")._NETWORK) or game:GetService("ReplicatedStorage"):FindFirstChild("CMDRGetGloveIDs",true).Parent
end

NETWORK.get_remote = function(setting)
    local ins = NETWORK.get_network()
    return (ins:FindFirstChild(setting) and ins[setting]) or ins:FindFirstChild(setting.." [STUDIO]")
end

NETWORK.get_setting = function(setting, username)
    if game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(username) == nil then
        return nil
    end
    local decodedval = game:GetService("HttpService"):JSONDecode(game:GetService("ReplicatedStorage").PlayerData[username].Settings.Settings.Value)
    return decodedval[setting].Value
end

NETWORK.edit_setting = function(setting, value)
    local ins = NETWORK.get_remote("UpdatePlayerSetting")
    ins:InvokeServer(setting, value)
end

NETWORK.add_connection_queue = function()
    if receive_connection then
        receive_connection = false
    end
    local guid = game:GetService("HttpService"):GenerateGUID(false)
    local condata = {
        ['user'] = game:GetService("Players").LocalPlayer.Name,
        ['connected'] = false,
        ['connection'] = false,
        ['guid'] = guid,
        ['data'] = ''
    }
    NETWORK.edit_setting("_gloveRandomizer", condata)
    local plrname = false
    repeat task.wait(.05)
    for i, v in next, game:GetService("ReplicatedStorage").PlayerData:GetChildren() do
        if v and v.Name~=game:GetService("Players").LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
            local decodedval = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
            if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value and decodedval._gloveRandomizer.Value.guid == guid then
                local new_condata = table.clone(condata)
                new_condata.connected = true
                new_condata.guid = guid
                new_condata.connection = decodedval._gloveRandomizer.Value.user
                NETWORK.edit_setting("_gloveRandomizer", new_condata)
                plrname = decodedval._gloveRandomizer.Value.user
            end
        end
    end
    until plrname~=false
    return true
end

NETWORK.connect_to_available = function()
    if receive_connection then
        receive_connection = false
    end
    for i, v in next, game:GetService("ReplicatedStorage").PlayerData:GetChildren() do
        if v and v.Name~=game:GetService("Players").LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
            local decodedval = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
            if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value and decodedval._gloveRandomizer.Value.connected == false then
                local condata = {
                    ['user'] = game:GetService("Players").LocalPlayer.Name,
                    ['connected'] = true,
                    ['connection'] = decodedval._gloveRandomizer.Value.user,
                    ['guid'] = decodedval._gloveRandomizer.Value.guid,
                    ['data'] = ''
                }
                NETWORK.edit_setting("_gloveRandomizer", condata)
                return true
            end
        end
    end
    return false
end

NETWORK.send_data = function(data)
    local my_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
    if my_data and my_data:FindFirstChild("Settings") and my_data.Settings:FindFirstChild("Settings") then
        local decodedval = game:GetService("HttpService"):JSONDecode(my_data.Settings.Settings.Value)
        if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value then
            local condata = decodedval._gloveRandomizer.Value
            condata.data = data .. "_" .. game:GetService("HttpService"):GenerateGUID(false)
            NETWORK.edit_setting("_gloveRandomizer", condata)
        end
    end
end

NETWORK.on_data_receive = function(callback)
    receive_connection = true
    task.spawn(function()
        local last_full_data = ""
        local my_name = game:GetService("Players").LocalPlayer.Name
        while receive_connection do
            task.wait(0.1)
            local my_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(my_name)
            if my_data and my_data:FindFirstChild("Settings") and my_data.Settings:FindFirstChild("Settings") then
                local decodedval = game:GetService("HttpService"):JSONDecode(my_data.Settings.Settings.Value)
                if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value then
                    local partner = decodedval._gloveRandomizer.Value.connection
                    if partner then
                        local partner_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(partner)
                        if partner_data and partner_data:FindFirstChild("Settings") and partner_data.Settings:FindFirstChild("Settings") then
                            local partner_decoded = game:GetService("HttpService"):JSONDecode(partner_data.Settings.Settings.Value)
                            if partner_decoded._gloveRandomizer and partner_decoded._gloveRandomizer.Value then
                                local current_full_data = partner_decoded._gloveRandomizer.Value.data
                                if current_full_data ~= "" and current_full_data ~= last_full_data then
                                    last_full_data = current_full_data
                                    local clean_data = string.match(current_full_data, "^(.*)_[%w%-]+$")
                                    if clean_data then
                                        callback(clean_data)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
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

local SelectGlove = function(g) repeat task.wait(.1) if Character:FindFirstChild("entered")==nil then NETWORK.get_remote("SelectGlove"):FireServer(g) end until LocalPlayer.leaderstats.Glove.Value==g task.wait(.1) end
local EnterArena = function(ar) local oldcf = ar.CFrame ar.CanCollide = false ar.CanTouch = true repeat task.wait() pcall(function() ar:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) ar:PivotTo(oldcf) ar.CanCollide = true end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
local TeleportToPosition = function(cFrame,time) local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() OverrideVelocity() HumanoidRootPart:PivotTo(cFrame) end) task.wait() end end

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
   Name = ""..GameKey.." | Client to Client Communicator",
   Icon = 0,    
   LoadingTitle = "SB:CtCC",
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

pcall(function()
loadstring([[local RequireService = function(clone) return clone end
local BlockInstance = function(e) e.Name = "BlockedInstance_"..math.random(0,500000).."" e.Parent = RequireService(game:GetService("LogService")) e:Destroy() end

local game = game or Ugc
local Players = RequireService(game:GetService("Players"))
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local StarterPlayer = RequireService(game:GetService("StarterPlayer"))
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ReplicatedStorage = RequireService(game:GetService("ReplicatedStorage"))
local ReplicatedFirst = RequireService(game:GetService("ReplicatedFirst"))

local function DestroyGrabLocalScript()
if ReplicatedFirst and ReplicatedFirst:FindFirstChild("Client") and ReplicatedFirst.Client:FindFirstChild("GrabLocal") then
BlockInstance(game.ReplicatedFirst.Client.GrabLocal)
end
end

local function BypassMobileClientAntiCheat()
if StarterPlayerScripts and StarterPlayerScripts:FindFirstChild("ClientAnticheat") and StarterPlayerScripts.ClientAnticheat:FindFirstChild("AntiMobileExploits") then
BlockInstance(StarterPlayerScripts.ClientAnticheat.AntiMobileExploits)
BlockInstance(StarterPlayerScripts.ClientAnticheat)
end
end

local AmountOfBlockedRemotes = 0
if game:GetService("ReplicatedStorage"):FindFirstChild("Ban") then
BlockInstance(game:GetService("ReplicatedStorage").Ban)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("WalkSpeedChanged") then
BlockInstance(game:GetService("ReplicatedStorage").WalkSpeedChanged)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("AdminGUI") then
BlockInstance(game:GetService("ReplicatedStorage").AdminGUI)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("GRAB") then
BlockInstance(game:GetService("ReplicatedStorage").GRAB)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("SpecialGloveAccess") then
BlockInstance(game:GetService("ReplicatedStorage").SpecialGloveAccess)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
DestroyGrabLocalScript()
BypassMobileClientAntiCheat()]])()
end)

function PressKey(keycode)
local VirtualInputManager = game:GetService("VirtualInputManager")
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[keycode], false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[keycode], false, game)
end

function ReceiveData()
NETWORK.on_data_receive(function(datastring)
if datastring=="jump" then
game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
if datastring=="reset" then
game:GetService("Players").LocalPlayer.Reset:FireServer()
end
if datastring=="ability_E" then
PressKey("E")
end
if datastring=="ability_R" then
PressKey("R")
end
if datastring=="EnterArena" then
EnterArena(workspace.Lobby:FindFirstChild("Teleport1",true))
end
if LocalPlayer:WaitForChild("_unlockedGloves"):FindFirstChild(datastring) and LocalPlayer:WaitForChild("_unlockedGloves"):WaitForChild(datastring).Value==true then
task.spawn(SelectGlove, datastring)
end
end)
end

Window:CreateTabSection("Connect")

local FirstPlayer = Window:CreateTab("Player 1",0)

FirstPlayer:CreateButton({Name = "Connect"; Callback = function()
Rayfield:Notification("Connecting...","Waiting for someone to connect...",3,true)
NETWORK.add_connection_queue()
ReceiveData()
Rayfield:Notification("Connected!","Found connection and connected successfully!",3,true)
end; })

local SecondPlayer = Window:CreateTab("Player 2",0)

SecondPlayer:CreateButton({Name = "Connect"; Callback = function()
NETWORK.connect_to_available()
ReceiveData()
Rayfield:Notification("Sent connection request.","Sent connection request. If someone was waiting for a connection, you are connected now.",6,true)
end; })

Window:CreateTabSection("Control")

local Buttons = Window:CreateTab("Buttons",0)

Buttons:CreateButton({Name = "Enter Arena"; Callback = function()
NETWORK.send_data("EnterArena")
end; })

Buttons:CreateInput({Name = "Equip Glove"; CurrentValue = "Default"; PlaceholderText = "..."; RemoveTextAfterFocusLost = false; Callback = function(Text)
NETWORK.send_data(Text)
end; })

Buttons:CreateButton({Name = "Jump Teammate"; Callback = function()
NETWORK.send_data("jump")
end; })

Buttons:CreateButton({Name = "Reset Teammate"; Callback = function()
NETWORK.send_data("reset")
end; })
