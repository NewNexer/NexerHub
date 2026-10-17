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

function CreateMessage(a)
local instancename = (a=="Message" and a) or "Hint"
local msg = Instance.new(instancename,game:GetService("CoreGui"))
msg.Text = ""
return msg
end
local startmessage = CreateMessage()
startmessage.Text = "Loading Assets... (0/2)"

local TouchObject = function(object, seconds) local oldobjectcancollide = object.CanCollide local oldobjectcframe = object.CFrame local seconds = seconds or 1/20 if not HumanoidRootPart then return end object.CanCollide = false local start = tick() while tick() - start < seconds do pcall(function() object:PivotTo(HumanoidRootPart.CFrame) end) task.wait() end pcall(function() object:PivotTo(oldobjectcframe) end) pcall(function() object.CanCollide = oldobjectcancollide end) end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
local TeleportToPosition = function(cFrame,time,huh) local huh = huh or false local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() OverrideVelocity() if huh==true then for i,v in next, Character:GetChildren() do if v:IsA("BasePart") then v:PivotTo(cFrame) end end elseif huh==false then HumanoidRootPart:PivotTo(cFrame) end end) task.wait() end end
local oldmakefolder = makefolder
getgenv().makefolder = function(...) pcall(oldmakefolder, ...) end

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
    --["Rouge Ishmael"] = "https://github.com/NewNexer/NexerHub/blob/main/Pictures/Rouge_Ishmael.png?raw=true";
    ["The Crimson God Sinclair"] = "https://github.com/NewNexer/NexerHub/blob/main/Pictures/Haute_Couture_The_Crimson_God_of_Le_Rouge_Sinclair_Full_Uptied.png?raw=true";
}
for i,v in next, Pictures do
if (writefile and readfile and isfile) and not isfile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png") then
task.spawn(function() pcall(function() writefile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png", game:HttpGet(v)) end) end)
Timeout = tick()
repeat task.wait(.1) until isfile("NexerStuff/Pictures/"..(i:gsub(" ", "_"))..".png") or (tick()-Timeout)>11
startmessage.Text = "Asset '"..tostring(i).."' failed to load. Skipping... (0/2)"
task.wait(2)
end
end
startmessage.Text = "Loading WindUI... (1/2)"
local WindUISource = game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/Libraries/windui-modified.luau")
local WindUI = loadstring(WindUISource)()
task.delay(1, function()
startmessage.Text = "All Done! (2/2)"
task.wait(2)
startmessage:Destroy()
end)
local ThemeData = {
    --[2] = {["Background"]="NexerStuff/Pictures/Rouge_Ishmael.png";["Theme"]="Crimson"};
    [1] = {["Background"]="NexerStuff/Pictures/The_Crimson_God_Sinclair.png";["Theme"]="Crimson"}
}
local RandomThemeData = ThemeData[1]
local Window = WindUI:CreateWindow({
    Title = "Le Rouge Hub | dogs",
    Icon = "gravity:logo-github",
    Author = "by Nexer",
    Transparent = true,
    Theme = RandomThemeData.Theme,
    Resizable = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    BackgroundImageTransparency = 0.88,
    Background = ((isfile(RandomThemeData.Background) and getcustomasset(RandomThemeData.Background)) or "rbxassetid://0"),
    
    OpenButton = {
        Title = "Le Rouge Hub",
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

local Stamina = Window:Tab({
    Title = "Stamina",
    Icon = "gravity:speedometer",
})  

local StaminaModule = {}
StaminaModule.required = false
StaminaModule.module = {}
StaminaModule.module._stamina = 100
StaminaModule.module.Config = {}
if require and not string.lower(identifyexecutor()):find("xeno") and not string.lower(identifyexecutor()):find("solara") then
    StaminaModule.required = true
    pcall(function()
        StaminaModule.module = require(game:GetService("ReplicatedStorage").Client.Sprint)
    end)
end

local SimpleMovement = Stamina:Section({
    Title = "Quick Features",
    Opened = true
})

local InfiniteStamina = false
signals[game:GetService("HttpService"):GenerateGUID(false)] = game:GetService("RunService").RenderStepped:Connect(function()
    if InfiniteStamina==true and StaminaModule.required==true then
        StaminaModule.module.Config.Max = math.huge
        StaminaModule.module._stamina = math.huge
    end
end)
SimpleMovement:Toggle({
    Title = "Infinite Stamina",
    Callback = function(state)
        InfiniteStamina = state
        if InfiniteStamina == false then
            game:GetService("RunService").RenderStepped:Wait()
            StaminaModule.module.Config.Max = 100
            StaminaModule.module._stamina = 100
        end
    end
})

local AdvancedMovement = Stamina:Section({
    Title = "Advanced Features",
    Opened = true
})

AdvancedMovement:Input({
    Title = "Max Stamina",
    Placeholder = "100",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.Max = tonumber(text)
        end
    end
})

local StaminaInput = AdvancedMovement:Input({
    Title = "Stamina",
    Placeholder = "100",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module._stamina = tonumber(text)
        end
    end
})
signals[game:GetService("HttpService"):GenerateGUID(false)] = LocalPlayer.CharacterAdded:Connect(function()
StaminaInput:Set("")
end)

AdvancedMovement:Input({
    Title = "Walk Speed",
    Placeholder = "16",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.WalkSpeed = tonumber(text)
        end
    end
})

AdvancedMovement:Input({
    Title = "Sprint Speed",
    Placeholder = "26",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.SprintSpeed = tonumber(text)
        end
    end
})

AdvancedMovement:Input({
    Title = "Stamina Regeneration",
    Placeholder = "16",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.Regen = tonumber(text)
        end
    end
})

AdvancedMovement:Input({
    Title = "Stamina Drain",
    Placeholder = "22",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.Drain = tonumber(text)
        end
    end
})

AdvancedMovement:Input({
    Title = "Stamina Regeneration Delay",
    Placeholder = "1",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.RegenDelay = tonumber(text)
        end
    end
})

AdvancedMovement:Input({
    Title = "Jump Cost in Stamina",
    Placeholder = "10",
    Value = "",
    Callback = function(text)
        if StaminaModule.required==true and tonumber(text)~=nil then
            StaminaModule.module.Config.JumpCost = tonumber(text)
        end
    end
})

local Emotes = Window:Tab({
    Title = "Emotes",
    Icon = "gravity:shapes-3",
})

local LocalPlayer = game:GetService("Players").LocalPlayer
local FetchedEmotes = {}
local FetchedSlots = {}
for i,v in pairs(LocalPlayer.Emotes:GetAttributes()) do
    if i:find("Slot") then
        FetchedSlots[i] = ((tostring(v):len()>1 and tostring(v)) or false)
    else
        FetchedEmotes[i] = ((tostring(v):len()>1 and true) or false)
    end
end

local SimpleEmotes = Emotes:Section({
    Title = "Quick Features",
    Opened = true
})

SimpleEmotes:Button({
    Title = "Get All Emotes",
    Icon = "mouse-pointer-click",
    Callback = function()
    for i,v in pairs(FetchedEmotes) do
        if v==false then
            for slot,emote in pairs(FetchedSlots) do
                if emote==false and FetchedEmotes[i]==false then
                    LocalPlayer.Emotes:SetAttribute(i, "Equipped")
                    LocalPlayer.Emotes:SetAttribute(slot, i)
                    FetchedSlots[slot] = i
                    FetchedEmotes[i] = true
                end
            end
        end
    end
    WindUI:Notify({
        Title = "Success",
        Content = "All Emotes were obtained.",
        Icon = "check",
        Duration = 3,
    })
    end
})

local AdvancedEmotes = Emotes:Section({
    Title = "Advanced Features",
    Opened = false
})

AdvancedEmotes:Paragraph({
    Title = "Nothing yet..."
})

for i,v in next, FetchedSlots do

end
 
local Weapons = Window:Tab({
    Title = "Weapons",
    Icon = "gravity:briefcase",
})

local AutoReload = false
Weapons:Toggle({
    Title = "Auto Reload",
    Callback = function(state)
        AutoReload = state
    end
})

local NoSpread = false
Weapons:Toggle({
    Title = "No Spread",
    Callback = function(state)
        NoSpread = state
    end
})

local InfiniteRange = false
Weapons:Toggle({
    Title = "Infinite Range",
    Callback = function(state)
        InfiniteRange = state
    end
})

local RemoteSpam = {["RifleReload"]={["previous"]=0;["current"]=0}}
function WeaponThingiesUpdate()
    if AutoReload==true or NoSpread==true or InfiniteRange==true then
        if Character:FindFirstChildWhichIsA("Tool") and (Character:FindFirstChildWhichIsA("Tool"):GetAttribute("Loaded")~=nil and tonumber(Character:FindFirstChildWhichIsA("Tool"):GetAttribute("Loaded"))==0) then
            if NoSpread==true then
                Character:FindFirstChildWhichIsA("Tool"):SetAttribute("Spread",0)
            end
            if InfiniteRange==true then
                Character:FindFirstChildWhichIsA("Tool"):SetAttribute("Range",math.huge)
            end
            if AutoReload==true then
                RemoteSpam.RifleReload.current = tick()
                if RemoteSpam.RifleReload.current-RemoteSpam.RifleReload.previous < 0.15 then
                    game:GetService("ReplicatedStorage").Remotes.RifleReload:FireServer()
                    RemoteSpam.RifleReload.previous = RemoteSpam.RifleReload.current
                end
            end
        end
    end
end
signals[game:GetService("HttpService"):GenerateGUID(false)] = game:GetService("RunService").RenderStepped:Connect(function() pcall(WeaponThingiesUpdate) end)

local Immunities = Window:Tab({
    Title = "Immunities",
    Icon = "gravity:shield",
})

local AutoSkillCheck = false
Immunities:Toggle({
    Title = "Auto Skill Checks",
    Callback = function(state)
        AutoSkillCheck = state
    end
})

signals[tostring(game:GetService("HttpService"):GenerateGUID(false))] = LocalPlayer.PlayerGui.SkillCheck:GetPropertyChangedSignal("Enabled"):Connect(function()
    if AutoSkillCheck==true and LocalPlayer.PlayerGui.SkillCheck.Enabled==true then
        repeat task.wait(.05) game:GetService("ReplicatedStorage").Remotes.SkillCheck:FireServer() until LocalPlayer.PlayerGui.SkillCheck.Enabled==false
    end
end)

local AutoFarm = Window:Tab({
    Title = "Auto Farm",
    Icon = "gravity:gear-play",
})

local FarmCandy = false
AutoFarm:Toggle({
    Title = "Auto Farm Bonbons (Candy)",
    Callback = function(state)
        FarmCandy = state
        if FarmCandy==true then
            for _,c in next, workspace.Bonbons:GetChildren() do
                if c and c:IsA("BasePart") then
                    c.Anchored = true
                    c.CanCollide = false
                    c.CanTouch = true
                    local tempcon = c:GetPropertyChangedSignal("CFrame"):Connect(function()
                        c:PivotTo(HumanoidRootPart.CFrame)
                    end)
                    task.delay(5, function() tempcon:Disconnect() tempcon=nil end)
                    c:PivotTo(HumanoidRootPart.CFrame)
                end
            end
        end
    end
})

signals[tostring(game:GetService("HttpService"):GenerateGUID(false))] = workspace.Bonbons.ChildAdded:Connect(function(c)
    if FarmCandy==true then
        task.wait(.1)
        pcall(function()
            c.Anchored = true
            c.CanCollide = false
            c.CanTouch = true
            local tempcon = c:GetPropertyChangedSignal("CFrame"):Connect(function()
                c:PivotTo(HumanoidRootPart.CFrame)
            end)
            task.delay(5, function() tempcon:Disconnect() tempcon=nil end)
            c:PivotTo(HumanoidRootPart.CFrame)
        end)
    end
end)

--[[
local gh = gethui or get_hui or gethiddengui or get_hidden_gui
signals[tostring(game:GetService("HttpService"):GenerateGUID(false))] = gh().ChildAdded:Connect(function(c)
    if HideScreeen==true and c.Name:find("TemplateCover_") then
        c.Enabled = false
    end
end)]]

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
            CreatedSound.Volume = 1
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
            CreatedSound.Volume = 1
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
            CreatedSound.Volume = 1
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
            CreatedSound.Volume = 1
            CreatedSound.Looped = true
            CreatedSound.Parent = game:GetService("CoreGui")
            game:GetService("RunService").RenderStepped:Wait()
            CreatedSound:Play()
        end
    end
})
ChosenMusicSlider:Set(math.random(1,4))
end)
