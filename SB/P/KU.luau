repeat task.wait(.5) until game:GetService("Players").LocalPlayer and game:IsLoaded()

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character, HumanoidRootPart, Humanoid
pcall(function()
	Character = LocalPlayer.Character
end)
pcall(function()
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3)
end)
pcall(function()
	Humanoid = Character:WaitForChild("Humanoid",3)
end)
LocalPlayer.CharacterAdded:Connect(function(AddedCharacter)
	pcall(function()
		Character = nil
		HumanoidRootPart = nil
		Humanoid = nil
		task.wait()
		Character = AddedCharacter
		repeat task.wait() until Character:FindFirstChild("HumanoidRootPart")
		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3)
		repeat task.wait() until Character:FindFirstChild("Humanoid")
		Humanoid = Character:WaitForChild("Humanoid",3)
	end)
end)

local NETWORK = (game:GetService("ReplicatedStorage"):FindFirstChild("_NETWORK") and game:GetService("ReplicatedStorage")._NETWORK) or game:GetService("ReplicatedStorage"):FindFirstChild("CMDRGetGloveIDs", true).Parent

if not NETWORK then return end

local EncodedRemotesFound = false
for i,v in next, NETWORK:GetChildren() do
	if v and v.Name:find("{") then
		EncodedRemotesFound = true
	end
end

local DisabledFlagService = false
if require and EncodedRemotesFound==true and (game:GetService("ReplicatedStorage"):FindFirstChild("BACKEND") and game:GetService("ReplicatedStorage").BACKEND:FindFirstChild("Shared") and game:GetService("ReplicatedStorage").BACKEND.Shared:FindFirstChild("Flags") and game:GetService("ReplicatedStorage").BACKEND.Shared.Flags:FindFirstChild("FlagService")) then
	local flags = require(game:GetService("ReplicatedStorage").BACKEND.Shared.Flags.FlagService)
	local original = flags.IsEnabled
	flags.IsEnabled = function(flag, ...)
		if flag == "IgnoreSafety" then
	        return true
	    end
	    return original(flag, ...)
	end
	DisabledFlagService = true
	local Processed = false
	task.spawn(function()
		while task.wait(.5) do
			for i,v in next, NETWORK:GetChildren() do
				if v and v.Name:find("[STUDIO]") then
					Processed = true
					break
				end
			end
		end
	end)
	repeat task.wait() until Processed == true
end


repeat task.wait() until NETWORK:FindFirstChild("SelectGlove") or NETWORK:FindFirstChild("SelectGlove [STUDIO]")
local SelectGloveRemote = nil
local SelectGlove = function(glove, verify) local verify = verify or true Instance.new("RemoteEvent"):FireServer(glove) if verify==true then local SelectGloveHold = tick() repeat task.wait() until LocalPlayer.leaderstats.Glove.Value==glove or tick() - SelectGloveHold >= 2 end task.wait(.1) end
if NETWORK:FindFirstChild("SelectGlove") then
	SelectGloveRemote = NETWORK:WaitForChild("SelectGlove")
elseif NETWORK:FindFirstChild("SelectGlove [STUDIO]") then
	SelectGloveRemote = NETWORK:WaitForChild("SelectGlove [STUDIO]")
end
if SelectGloveRemote~=nil then
    SelectGlove = function(glove, verify) local verify = verify or true SelectGloveRemote:FireServer(glove) if verify==true then local SelectGloveHold = tick() repeat task.wait() until LocalPlayer.leaderstats.Glove.Value==glove or tick() - SelectGloveHold >= 2 end task.wait(.1) end
end

repeat task.wait() until NETWORK:FindFirstChild("ActivateBadgeQuest") or NETWORK:FindFirstChild("ActivateBadgeQuest [STUDIO]")
local ActivateBadgeQuestRemote = nil
local ActivateBadgeQuest = function(quest) Instance.new("RemoteEvent"):FireServer(quest) end
if NETWORK:FindFirstChild("ActivateBadgeQuest") then
	ActivateBadgeQuestRemote = NETWORK:WaitForChild("ActivateBadgeQuest")
elseif NETWORK:FindFirstChild("ActivateBadgeQuest [STUDIO]") then
	ActivateBadgeQuestRemote = NETWORK:WaitForChild("ActivateBadgeQuest [STUDIO]")
end
if ActivateBadgeQuestRemote~=nil then
	ActivateBadgeQuest = function(quest) ActivateBadgeQuestRemote:FireServer(quest) end
end

repeat task.wait() until NETWORK:FindFirstChild("CollectBadgeQuestReward") or NETWORK:FindFirstChild("CollectBadgeQuestReward [STUDIO]")
local CollectBadgeQuestRewardRemote = nil
local CollectBadgeQuestReward = function(quest) Instance.new("RemoteEvent"):FireServer(quest) end
if NETWORK:FindFirstChild("CollectBadgeQuestReward") then
	CollectBadgeQuestRewardRemote = NETWORK:WaitForChild("CollectBadgeQuestReward")
elseif NETWORK:FindFirstChild("CollectBadgeQuestReward [STUDIO]") then
	CollectBadgeQuestRewardRemote = NETWORK:WaitForChild("CollectBadgeQuestReward [STUDIO]")
end
if CollectBadgeQuestRewardRemote~=nil then
	CollectBadgeQuestReward = function(quest) CollectBadgeQuestRewardRemote:FireServer(quest) end
end

local EnterArena = function(Arena) local oldcf = Arena.CFrame Arena.CanCollide = false Arena.CanTouch = true repeat task.wait() pcall(function() Arena:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) Arena:PivotTo(oldcf) Arena.CanCollide = true end
local TouchObject = function(object, seconds) local oldobjectcancollide = object.CanCollide local oldobjectcframe = object.CFrame local seconds = seconds or 1/20 if not HumanoidRootPart then return end object.CanCollide = false local start = tick() while tick() - start < seconds do pcall(function() object:PivotTo(HumanoidRootPart.CFrame) end) task.wait() end pcall(function() object:PivotTo(oldobjectcframe) end) pcall(function() object.CanCollide = oldobjectcancollide end) end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
local TeleportToPosition = function(cFrame,time,huh) local huh = huh or false local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() OverrideVelocity() if huh==true then for i,v in next, Character:GetChildren() do if v:IsA("BasePart") then v:PivotTo(cFrame) end end elseif huh==false then HumanoidRootPart:PivotTo(cFrame) end end) task.wait() end end

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

function CreateMessage(a)
local instancename = (a=="Message" and a) or "Hint"
local msg = Instance.new(instancename,game:GetService("CoreGui"))
msg.Text = ""
return msg
end
local startmessage = CreateMessage()
startmessage.Text = "Loading Assets... (0/3)"
if (makefolder and isfolder) and not isfolder("NexerStuff") then
makefolder("NexerStuff")
repeat task.wait() until isfolder("NexerStuff")
end
if (writefile and readfile and isfile) and not isfile("NexerStuff/README.txt") then
writefile("NexerStuff/README.txt", [[Script may break if you edit any insides of this folder. Edit with caution!]])
repeat task.wait() until isfile("NexerStuff/README.txt")
end
if (makefolder and isfolder) and not isfolder("NexerStuff/Pictures") then
makefolder("NexerStuff/Pictures")
repeat task.wait() until isfolder("NexerStuff/Pictures")
end
local Pictures = {
    ["Rouge Ishmael"] = "https://github.com/NewNexer/NexerHub/blob/main/Pictures/Rouge_Ishmael.png?raw=true";
}
for i,v in next, Pictures do
if (writefile and readfile and isfile) and not isfile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png") then
print("loading "..tostring("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png").."")
writefile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png", game:HttpGet(v))
print("loaded "..tostring("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png").."")
repeat task.wait() until isfile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png")
end
end
local ScreenCoverHandler = loadstring(game:HttpGet("https://gist.githubusercontent.com/NewNexer/dd8da43598f67527899a9b7458474fba/raw/27bc91300fe07bf994d8a7174aa0dbaca19c9373/coverhandler.luau"))()
local hidescreen = true
local RougeCover = ScreenCoverHandler
startmessage.Text = "Bypassing Anti-Cheat... (1/3)"
if game.PlaceId==101960002094215 or game.PlaceId==9431156611 then
loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/SB/Modules/CleanClientAntiCheat.luau"))("Slap Royale")
else
loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/SB/Modules/CleanClientAntiCheat.luau"))("Slap Battles")
end
startmessage.Text = "Loading WindUI... (2/3)"
local WindUISource = game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Libraries/windui-modified.luau")
local WindUI = loadstring(WindUISource)()
task.delay(1, function()
startmessage.Text = "All Done! (3/3)"
task.wait(2)
startmessage:Destroy()
end)
local ThemeData = {
    [1] = {["Background"]="NexerStuff/Pictures/Rouge_Ishmael.png";["Theme"]="Crimson"}
}
local RandomThemeData = ThemeData[1]
local Window = WindUI:CreateWindow({
    Title = "Kick Utility",
    Icon = "gravity:logo-github",
    Author = "by Nexer",
    Transparent = true,
    Theme = RandomThemeData.Theme,
    Resizable = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    BackgroundImageTransparency = 0.88,
    Background = getcustomasset(RandomThemeData.Background),
    
    OpenButton = {
        Title = "Kick Utility",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
    },

    User = {
        Enabled = false,
        Anonymous = true,
        Callback = function()
            print("clicked to the 'user icon'")
        end,
    },
})
local signals = {}
Window:OnDestroy(function()
    pcall(function()
        for i,v in pairs(signals) do
            v:Disconnect()
            v = nil
        end
    end)
    if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
        game:GetService("CoreGui").currentmusicforthescript:Destroy()
    end
end)


local KickTab = Window:Tab({
    Title = "Kick",
    Icon = "gravity:arrow-right-from-square",
})  

function TryPattern(pattern)
    if not pattern or pattern == "" then
        return nil
    end
    local matches = {}
    for i,v in ipairs(game:GetService("Players"):GetPlayers()) do
        if string.sub(string.lower(v.Name), 1, #string.lower(pattern)) == string.lower(pattern) then
            table.insert(matches, v.Name)
        end
    end
    if #matches >= 1 then
        return matches[1]
    end
    return "not found"
end

local Ignoring = false
local UsernameOfTarget = ""
local KickInput
KickTab:Button({
    Title = "Choose random eligible target",
	Icon = "gravity:sparkles-fill",
    Callback = function()
        local temp_table = {}
		for i,v in next, game:GetService("Players"):GetPlayers() do
            if v~=LocalPlayer and not table.find(temp_table, v.Name) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health~=0 and v.Character.Humanoid.Sit~=true and v.Character:FindFirstChild("isInArena") and v.Character.isInArena.Value==true then
                table.insert(temp_table, v.Name)
            end
        end
        if #temp_table >= 1 then
            KickInput:Set(temp_table[math.random(1,#temp_table)])
            return
        end
        WindUI:Notify({
            Title = "No eligible targets found",
            Content = "",
            Icon = "gravity:triangle-exclamation",
            Duration = 3,
        })
	end
})

KickInput = KickTab:Input({
    Title = "Target",
    Desc = "Put the username of the player you want to kick.",
    Placeholder = "...",
    Value = "",
    Callback = function(text)
        if Ignoring==true then return end
        local result = TryPattern(tostring(text))
        if result=="not found" then
            WindUI:Notify({
                Title = "Target not found",
                Content = "",
                Icon = "gravity:triangle-exclamation",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Found target",
                Content = "Hooked onto "..result,
                Icon = "check",
                Duration = 3,
            })
            Ignoring = true
            KickInput:Set(result)
            Ignoring = false
            UsernameOfTarget = result
        end
    end
})

local originalvolumes = {}
local connection

function muteall()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	for _, descendant in game:GetDescendants() do
		if descendant:IsA("Sound") then
			local incoregui = false
			local current = descendant
			while current do
				if current == game:GetService("CoreGui") then
					incoregui = true
					break
				end
				current = current.Parent
			end
			if not incoregui then
				if originalvolumes[descendant] == nil then
					originalvolumes[descendant] = descendant.Volume
				end
				descendant.Volume = 0
			end
		end
	end
	connection = game.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Sound") then
			local incoregui = false
			local current = descendant
			while current do
				if current == game:GetService("CoreGui") then
					incoregui = true
					break
				end
				current = current.Parent
			end
			if not incoregui then
				if originalvolumes[descendant] == nil then
					originalvolumes[descendant] = descendant.Volume
				end
				descendant.Volume = 0
			end
		end
	end)
end

function unmuteall()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	for sound, volume in originalvolumes do
		if sound and sound.Parent then
			sound.Volume = volume
		end
	end
	local result = table.clone(originalvolumes)
	table.clear(originalvolumes)
	return result
end

function KickPlayer(username, a, b)
    local username = username or ""
    local done = false
    local step = 0
    local lastpt = tick()
    local function updater(text)
        b.Text = text
        step = step + 1
        lastpt = tick()
    end
    local function abort(failt, faild)
        done = true
        if onemoreconn then onemoreconn:Disconnect() onemoreconn = nil end
        a.Text = failt
        b.Text = faild
    end
    local onemoreconn
    onemoreconn = game:GetService("RunService").Heartbeat:Connect(function()
        if done then
            if onemoreconn then onemoreconn:Disconnect() onemoreconn = nil end
            return
        end
        if tick() - lastpt > 10 then
            abort("Failed to kick "..username..".", "Timeout: Stuck on step "..step.." for more than 10 seconds.")
        end
    end)
    task.spawn(function()
        local dots = 0
        while not done do
            dots = dots % 3 + 1
            a.Text = "Kicking "..username..string.rep(".", dots)
            task.wait(0.3)
        end
    end)
    local dunno = {}
    local total = 0
    for i = 1,8 do
        dunno[i] = math.random(5, 20)
        total = total + dunno[i]
    end
    local scale = 100 / total
    local steps = {}
    local running = 0
    for i = 1, 8 do
        running = running + dunno[i] * scale
        steps[i] = math.floor(running * 10 + 0.5) / 10
    end
    steps[8] = 100
    local step = 1
    updater("Processing... | 0% completed.")
    game:GetService("RunService").RenderStepped:Wait()
    if done then return end
    if not game:GetService("Players"):FindFirstChild(username) then 
        return abort("Failed to kick "..username..".", "No players with such username were found.")
    end
    if not game:GetService("Players")[username].Character then 
        return abort("Failed to kick "..username..".", "Target is missing Character.")
    end
    if not game:GetService("Players")[username].Character:FindFirstChild("HumanoidRootPart") then 
        return abort("Failed to kick "..username..".", "Target is missing HumanoidRootPart.")
    end
    if game:GetService("Players")[username].Character:FindFirstChild("Humanoid").Health==0 then 
        return abort("Failed to kick "..username..".", "Target is dead.")
    end
    if game:GetService("Players")[username].Character:FindFirstChild("Humanoid").Sit==true then 
        return abort("Failed to kick "..username..".", "Target is sitting somewhere.")
    end
    if not game:GetService("Players")[username].Character:FindFirstChild("isInArena") then 
        return abort("Failed to kick "..username..".", "Target is missing isInArena value.")
    end
    if game:GetService("Players")[username].Character.isInArena.Value==false then 
        if game:GetService("Players")[username].Character:FindFirstChild("entered") then
            return abort("Failed to kick "..username..".", "Target is currently in an Immortal state.")
        else
            return abort("Failed to kick "..username..".", "Target is not in the Arena.")
        end
    end
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    game:GetService("RunService").RenderStepped:Wait()
    if done then return end
    if LocalPlayer.leaderstats.Slaps.Value>665 and Character.Torso.Transparency~=1 then
        SelectGlove("Ghost")
        game:GetService("ReplicatedStorage").Ghostinvisibilityactivated:FireServer()
    end
    local function SpawnFirework()
        if workspace:FindFirstChild("Firework_"..LocalPlayer.Name) then return end
        repeat 
            game:GetService("ReplicatedStorage").GeneralAbility:FireServer("setcollisiongroup","NoCollideCharacterCollisionGroup") 
            task.wait(.1) 
        until done or (workspace:FindFirstChild("Firework_"..LocalPlayer.Name) and workspace["Firework_"..LocalPlayer.Name]:FindFirstChild("VehicleSeat"))
    end
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    game:GetService("RunService").RenderStepped:Wait()
    if done then return end
    SelectGlove("Firework")
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    game:GetService("RunService").RenderStepped:Wait()
    if done then return end
    TeleportToPosition((CFrame.new(workspace.Lobby.brazil.platform.Position)*CFrame.new(0,5,0)), 1, false)
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    if done then return end
    if game:GetService("ReplicatedStorage"):FindFirstChild("firework") then
        game:GetService("ReplicatedStorage").firework:Destroy()
    end
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    if done then return end
    SpawnFirework()
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    if done then return end
    repeat task.wait() 
        SpawnFirework() 
        if not done then
            game:GetService("Players")[username].Character.HumanoidRootPart:PivotTo(workspace["Firework_"..LocalPlayer.Name].VehicleSeat.CFrame)
        end
    until (game:GetService("Players")[username].Character.Humanoid.Sit==true) or done
    if done then return end
    task.wait(.5)
    updater("Processing... | "..steps[step].."% completed.")
    step = step + 1
    done = true
    if onemoreconn then onemoreconn:Disconnect() onemoreconn = nil end
    a.Text = "Kicked "..username.."."
    b.Text = "Target was kicked. | 100% completed."
    return
end

local HideScreeen = false
KickTab:Toggle({
    Title = "Hide Screen",
    Value = false,
    Callback = function(state)
        HideScreeen = state
    end
})

local gh = gethui or get_hui or gethiddengui or get_hidden_gui
signals[tostring(game:GetService("HttpService"):GenerateGUID(false))] = gh().ChildAdded:Connect(function(c)
    if HideScreeen==true and c.Name:find("TemplateCover_") then
        c.Enabled = false
    end
end)


KickTab:Button({
    Title = "Kick",
    Desc = "You must have Firework.",
	Icon = "gravity:sparkles-fill",
    Callback = function()
        if Character:FindFirstChild("entered") then
            WindUI:Notify({
                Title = "Use in the lobby!",
                Content = "",
                Icon = "gravity:triangle-exclamation",
                Duration = 3,
            })
            return
        end
        local savedpossss = HumanoidRootPart.CFrame
        local a,b,c = RougeCover()
        muteall()
        KickPlayer(UsernameOfTarget, a, b)
        TeleportToPosition(savedpossss, 1, false)
        game:GetService("ReplicatedStorage").Ghostinvisibilitydeactivated:FireServer()
        SelectGlove("spin")
        game:GetService("ReplicatedStorage").GeneralAbility:FireServer("setcollisiongroup","DefaultCharacterCollisionGroup")
        unmuteall()
        c()
	end
})



local MusicTab = Window:Tab({
    Title = "Music",
    Icon = "gravity:music-note",
})
local LoadingMusic = MusicTab:Paragraph({
    Title = "Loading Assets... Come back a bit later!"
})
task.spawn(function()
if (makefolder and isfolder) and not isfolder("NexerStuff/Music") then
makefolder("NexerStuff/Music")
repeat task.wait() until isfolder("NexerStuff/Music")
end
local Music = {
    ["Canto X Battle Theme C"] = "https://github.com/NewNexer/NexerHub/blob/main/Music/Limbus%20Company%20OST%20-%20Canto%20X%20Battle%20Theme%20C.mp3?raw=true";
    ["Canto X Boss 5 Battle Theme 1"] = "https://github.com/NewNexer/NexerHub/blob/main/Music/Limbus%20Company%20OST%20-%20Canto%20X%20Boss%205%20Battle%20Theme%201.mp3?raw=true";
    ["Canto X Boss 5 Battle Theme 2"] = "https://github.com/NewNexer/NexerHub/blob/main/Music/Limbus%20Company%20OST%20-%20Canto%20X%20Boss%205%20Battle%20Theme%202.mp3?raw=true";
    ["Canto X Boss 5 Battle Theme 3"] = "https://github.com/NewNexer/NexerHub/blob/main/Music/Limbus%20Company%20OST%20-%20Canto%20X%20Boss%205%20Battle%20Theme%203.mp3?raw=true";
}
for i,v in next, Music do
if (writefile and readfile and isfile) and not isfile("NexerStuff/Music/"..(i:gsub(" ", "_"))..".mp3") then
print("loading "..tostring("NexerStuff/Music/"..(i:gsub(" ", "_"))..".mp3").."")
writefile("NexerStuff/Music/"..(i:gsub(" ", "_"))..".mp3", game:HttpGet(v))
print("loading "..tostring("NexerStuff/Music/"..(i:gsub(" ", "_"))..".mp3").."")
repeat task.wait() until isfile("NexerStuff/Music/"..(i:gsub(" ", "_"))..".mp3")
end
end
LoadingMusic:Destroy()
local CreatedSound
local MusicInfo = MusicTab:Paragraph({
    Title = "..."
})
local ChosenMusicSlider = MusicTab:Slider({
    Title = "Music",
    Value = {
        Min = 0,
        Max = 4,
        Default = 0
    },
    Step = 1,
    Locked = false,
    Callback = function(value)
        if value==0 then
            MusicInfo:SetTitle("...")
            if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
                game:GetService("CoreGui").currentmusicforthescript:Destroy()
                CreatedSound = nil
            end
        elseif value==1 then
            MusicInfo:SetTitle("Canto X Battle Theme C")
            if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
                game:GetService("CoreGui").currentmusicforthescript:Destroy()
                CreatedSound = nil
            end
            CreatedSound = Instance.new("Sound")
            CreatedSound.Name = "currentmusicforthescript"
            CreatedSound.SoundId = getcustomasset("NexerStuff/Music/Canto_X_Battle_Theme_C.mp3")
            CreatedSound.Volume = 2
            CreatedSound.Looped = true
            CreatedSound.Parent = game:GetService("CoreGui")
            game:GetService("RunService").RenderStepped:Wait()
            CreatedSound:Play()
        elseif value==2 then
            MusicInfo:SetTitle("Canto X Boss 5 Battle Theme 1")
            if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
                game:GetService("CoreGui").currentmusicforthescript:Destroy()
                CreatedSound = nil
            end
            CreatedSound = Instance.new("Sound")
            CreatedSound.Name = "currentmusicforthescript"
            CreatedSound.SoundId = getcustomasset("NexerStuff/Music/Canto_X_Boss_5_Battle_Theme_1.mp3")
            CreatedSound.Volume = 2
            CreatedSound.Looped = true
            CreatedSound.Parent = game:GetService("CoreGui")
            game:GetService("RunService").RenderStepped:Wait()
            CreatedSound:Play()
        elseif value==3 then
            MusicInfo:SetTitle("Canto X Boss 5 Battle Theme 2")
            if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
                game:GetService("CoreGui").currentmusicforthescript:Destroy()
                CreatedSound = nil
            end
            CreatedSound = Instance.new("Sound")
            CreatedSound.Name = "currentmusicforthescript"
            CreatedSound.SoundId = getcustomasset("NexerStuff/Music/Canto_X_Boss_5_Battle_Theme_2.mp3")
            CreatedSound.Volume = 2
            CreatedSound.Looped = true
            CreatedSound.Parent = game:GetService("CoreGui")
            game:GetService("RunService").RenderStepped:Wait()
            CreatedSound:Play()
        elseif value==4 then
            MusicInfo:SetTitle("Canto X Boss 5 Battle Theme 3")
            if game:GetService("CoreGui"):FindFirstChild("currentmusicforthescript") then
                game:GetService("CoreGui").currentmusicforthescript:Destroy()
                CreatedSound = nil
            end
            CreatedSound = Instance.new("Sound")
            CreatedSound.Name = "currentmusicforthescript"
            CreatedSound.SoundId = getcustomasset("NexerStuff/Music/Canto_X_Boss_5_Battle_Theme_3.mp3")
            CreatedSound.Volume = 2
            CreatedSound.Looped = true
            CreatedSound.Parent = game:GetService("CoreGui")
            game:GetService("RunService").RenderStepped:Wait()
            CreatedSound:Play()
        end
    end
})
ChosenMusicSlider:Set(math.random(1,4))
end)
