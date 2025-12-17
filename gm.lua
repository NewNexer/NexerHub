local module = {}

--[[
Table Things
]]--
local SpecialCharacters = {['\a'] = '\\a', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\v'] = '\\v', ['\0'] = '\\0'}
local Keywords = { ['and'] = true, ['break'] = true, ['do'] = true, ['else'] = true, ['elseif'] = true, ['end'] = true, ['false'] = true, ['for'] = true, ['function'] = true, ['if'] = true, ['in'] = true, ['local'] = true, ['nil'] = true, ['not'] = true, ['or'] = true, ['repeat'] = true, ['return'] = true, ['then'] = true, ['true'] = true, ['until'] = true, ['while'] = true, ['continue'] = true}
local Functions = {
    [pairs] = "pairs",
    [ipairs] = "ipairs", 
    [next] = "next",
    [type] = "type",
    [tostring] = "tostring",
    [tonumber] = "tonumber",
    [print] = "print",
    [error] = "error",
    [assert] = "assert",
    [pcall] = "pcall",
    [xpcall] = "xpcall",
    [select] = "select",
    [rawget] = "rawget",
    [rawset] = "rawset",
    [rawequal] = "rawequal",
    [getmetatable] = "getmetatable",
    [setmetatable] = "setmetatable",
    [require] = "require",
}
if loadstring then Functions[loadstring] = "loadstring" end
if load then Functions[load] = "load" end
local function safeTypeof(value)
    if typeof then
        return typeof(value)
    else
        return type(value)
    end
end
function GetHierarchy(Object)
    if not Object or (type(Object) ~= "table" and safeTypeof(Object) ~= "Instance") then
        return tostring(Object)
    end
    local Hierarchy = {}
    local current = Object
    while current do
        local name = tostring(current.Name or current.name or "Unknown")
        name = string.gsub(name, '[%c%z]', SpecialCharacters)
        if current == game or current == _G.game then
            table.insert(Hierarchy, 1, "game")
        elseif Keywords[name] or not string.match(name, '^[_%a][_%w]*$') then
            table.insert(Hierarchy, 1, '["' .. name .. '"]')
        else
            table.insert(Hierarchy, 1, name)
        end
        current = current.Parent
    end
    
    return table.concat(Hierarchy, ".")
end
local function SerializeType(Value, Class)
    if Class == 'string' then
        return string.format('"%s"', string.gsub(Value, '[%c%z]', SpecialCharacters))
    elseif Class == 'Instance' then
        return GetHierarchy(Value)
    elseif Class == 'function' then
        return Functions[Value] or "'[Function: " .. tostring(Value) .. "]'"
    elseif Class == 'userdata' then
        return "'[userdata: " .. tostring(Value) .. "]'"
    elseif Class == 'thread' then
        if coroutine and coroutine.status then
            local status = pcall(function() return coroutine.status(Value) end)
            return "'[thread: " .. tostring(Value) .. (status and ", status: " .. coroutine.status(Value) or "") .. "]'"
        else
            return "'[thread: " .. tostring(Value) .. "]'"
        end
    else
        return tostring(Value)
    end
end
function TableToLuauString(Table, IgnoredTables, DepthData, Path)
    if type(Table) ~= "table" then
        return SerializeType(Table, safeTypeof(Table))
    end
    IgnoredTables = IgnoredTables or {}
    Path = Path or "ROOT"
    if not DepthData then
        DepthData = {0, Path}
    end
    local CyclicData = IgnoredTables[Table]
    if CyclicData then
        local currentDepth = DepthData[1] or 0
        local cyclicDepth = CyclicData[1] or 0
        return ((cyclicDepth == currentDepth - 1 and "'[Cyclic Parent " or "'[Cyclic ") .. tostring(Table) .. ', path: ' .. (CyclicData[2] or "unknown") .. "]'")
    end
    DepthData[1] = (DepthData[1] or 0) + 1
    DepthData[2] = Path
    IgnoredTables[Table] = {DepthData[1], DepthData[2]}
    local currentDepth = DepthData[1] or 1
    local Tab = string.rep('    ', currentDepth)
    local TrailingTab = string.rep('    ', currentDepth - 1)
    local Result = '{'
    local LineTab = '\n' .. Tab
    local HasOrder = true
    local Index = 1
    local IsEmpty = true
    for Key, Value in pairs(Table) do
        IsEmpty = false
        if Index ~= Key then
            HasOrder = false
        else
            Index = Index + 1
        end
        local KeyClass = safeTypeof(Key)
        local ValueClass = safeTypeof(Value)
        local HasBrackets = false
        local KeyStr
        if KeyClass == 'string' then
            local cleanKey = string.gsub(Key, '[%c%z]', SpecialCharacters)
            if Keywords[cleanKey] or not string.match(cleanKey, '^[_%a][_%w]*$') then
                HasBrackets = true
                KeyStr = string.format('["%s"]', cleanKey)
            else
                KeyStr = cleanKey
            end
        else
            HasBrackets = true
            if KeyClass == 'table' then
                KeyStr = '[' .. TableToLuauString(Key, IgnoredTables, {currentDepth + 1, Path}) .. ']'
            else
                KeyStr = '[' .. SerializeType(Key, KeyClass) .. ']'
            end
        end
        local ValueStr
        if ValueClass == 'table' then
            local newPath = Path .. (HasBrackets and '' or '.') .. KeyStr
            ValueStr = TableToLuauString(Value, IgnoredTables, {currentDepth + 1, Path}, newPath)
        else
            ValueStr = SerializeType(Value, ValueClass)
        end
        Result = Result .. LineTab .. (HasOrder and ValueStr or KeyStr .. ' = ' .. ValueStr) .. ','
    end
    local donetable = IsEmpty and Result .. '}' or string.sub(Result, 1, -2) .. '\n' .. TrailingTab .. '}'
    IgnoredTables[Table] = nil
    return donetable
end


if _G.GlobalStartupFunctions == nil or not _G.GlobalStartupFunctions then
_G.GlobalStartupFunctions = {}
warn("Re-creating functions")
task.wait()
end


function module.IsWorking()
return (module~=nil)
end

local AutoBlockEnabled = false
local AutoBlockRange = 0
local CheckIfFacesTowardsPlayer = false
local UnhookEverything = false
function module:AutoBlockSettings(a,b)
if a == "AutoBlockRange" then
AutoBlockRange = b
elseif a == "CheckIfFacesTowardsPlayer" then
CheckIfFacesTowardsPlayer = b
elseif a == "AutoBlockEnabled" then
AutoBlockEnabled = b
end
end

function module:InitiateAutoBlock()
local function HookOnto(chr)
local AB_UA = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")
local chrp = chr.Parent
local chrn = chr.Name
local function IsFacingTowards()
if CheckIfFacesTowardsPlayer~=true then return true end
local unit = ((HumanoidRootPart.Position - chr.HumanoidRootPart.Position) * Vector3.new(1,0,1)).Unit
local lookvector = chr.HumanoidRootPart.CFrame.LookVector * Vector3.new(1,0,1)
return (lookvector:Dot(unit) > 0.85)
end
local function GetMagnitudeDifference()
return (chr.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude or (1/0)
end
local function CheckRequirements()
local b = (GetMagnitudeDifference(chr) < tonumber(AutoBlockRange))
local c = IsFacingTowards(chr)
if b == true and c == true then return true end
return false
end
local AB_US = function() if CheckRequirements()==true and AutoBlockEnabled==true then AB_UA:InvokeServer("Block") end end
local a = chr.HumanoidRootPart.Swing.Played:Connect(AB_US)
repeat task.wait() until chrp:FindFirstChild(chrn) == nil or UnhookEverything == true
a:Disconnect()
end
for i,v in next, workspace.GameAssets.Teams.Killer:GetChildren() do
if v then
HookOnto(v)
end
end
workspace.GameAssets.Teams.Killer.ChildAdded:Connect(function(v)
HookOnto(v)
end)
end

function module:AutoBlockUnhookAll()
UnhookEverything = true
task.wait()
task.wait()
UnhookEverything = false
end

function module:SyncEmotes()
task.spawn(function()
local Songs = {
	["rbxassetid://95332984406426"] = "rbxassetid://73591689210949";
	["rbxassetid://91496313320059"] = "rbxassetid://117826199625726";
	["rbxassetid://72840218506214"] = "rbxassetid://87502844893473";
	["rbxassetid://76016409017292"] = "rbxassetid://125027188864914";
	["rbxassetid://33810432"] = "rbxassetid://81883187469620";
}
local function SyncEmoteWithClosestPlayer(e)
    local NewClosest = nil
    local ClosestDistance = math.huge
    local timeposem = 0
    local animtrackpos = nil
    local idklol = nil
    for i, v in pairs(game.Players:GetPlayers()) do
        if v and v.Name ~= game.Players.LocalPlayer.Name and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            local emote = (v.Character.Head:FindFirstChild("EmoteSong") or v.Character.HumanoidRootPart:FindFirstChild("EmoteSong"))
            if not emote or tostring(emote.SoundId) ~= e then
                continue
            end
            local Distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if Distance < ClosestDistance then
                ClosestDistance = Distance
                NewClosest = (v.Character.Humanoid:FindFirstChild("Animator") ~= nil and v.Character.Humanoid.Animator) or v.Character.Humanoid
                timeposem = emote.TimePosition
                local hah = NewClosest:GetPlayingAnimationTracks()
                for _, track in pairs(hah) do
                    if track.Animation and Songs[e] == tostring(track.Animation.AnimationId) then
                        idklol = tostring(track.Animation.AnimationId)
                        animtrackpos = track.TimePosition
                        break
                    end
                end
            end
        end
    end
    if NewClosest == nil or ClosestDistance > 20 then
        return nil, nil, nil
    end
    return idklol, animtrackpos, timeposem
end
game.Players.LocalPlayer.Character.Head.ChildAdded:Connect(function(c)
if c.Name=="EmoteSong" then
local a,b,v = SyncEmoteWithClosestPlayer(tostring(c.SoundId))
print(a,b,v)
c.TimePosition = v
local hoh = (game.Players.LocalPlayer.Character.Humanoid:FindFirstChild("Animator")~=nil and game.Players.LocalPlayer.Character.Humanoid.Animator) or game.Players.LocalPlayer.Character.Humanoid
local hah = hoh:GetPlayingAnimationTracks()
for _,track in pairs(hah) do
if tostring(track.Animation.AnimationId) == a then
track.TimePosition = b
end
end
end
end)
game.Players.LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(c)
if c.Name=="EmoteSong" then
local a,b,v = FindClosestPlayerWithEmote(tostring(c.SoundId))
print(a,b,v)
c.TimePosition = v
local hoh = (game.Players.LocalPlayer.Character.Humanoid:FindFirstChild("Animator")~=nil and game.Players.LocalPlayer.Character.Humanoid.Animator) or game.Players.LocalPlayer.Character.Humanoid
local hah = hoh:GetPlayingAnimationTracks()
for _,track in pairs(hah) do
if tostring(track.Animation.AnimationId) == a then
track.TimePosition = b
end
end
end
end)
end)
end

function module:RainbowWaves()
task.spawn(function()
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://75513960644342"
local planim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(anim)
planim:Play()
local song = Instance.new("Sound")
song.Volume = 1.5
song.Looped = true
song.SoundId = "rbxassetid://137048834753046"
song.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
song:Play()
local PE1 = Instance.new("ParticleEmitter")
PE1.Texture = "rbxassetid://13425686092"
PE1.Rate = 50
PE1.Lifetime = NumberRange.new(1, 1)
PE1.Speed = NumberRange.new(5, 15)
PE1.Size = NumberSequence.new(0.4)
PE1.LightEmission = 1
PE1.LightInfluence = 1

PE1.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 128, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(128, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})

PE1.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0, 0.613),
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0)
})

PE1.Shape = Enum.ParticleEmitterShape.Box
PE1.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
PE1.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
PE1.ShapePartial = 1

PE1.SpreadAngle = Vector2.new(360, 360)
PE1.EmissionDirection = Enum.NormalId.Top

PE1.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart

PE1.Orientation = Enum.ParticleOrientation.VelocityParallel
PE1.Acceleration = Vector3.new(-15, -15, -15)

PE1.Squash = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(1, 0)
})


local PE2 = Instance.new("ParticleEmitter")
PE2.Texture = "rbxassetid://1057939773"
PE2.Rate = 5
PE2.Lifetime = NumberRange.new(0.5, 0.5)
PE2.Speed = NumberRange.new(0.01, 0.01)
PE2.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.5),
	NumberSequenceKeypoint.new(1, 10),
	NumberSequenceKeypoint.new(1, 1)
})
PE2.LightEmission = 1
PE2.LightInfluence = 1
PE2.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 128, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(128, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
})
PE2.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0.613),
	NumberSequenceKeypoint.new(1, 1)
})
PE2.Shape = Enum.ParticleEmitterShape.Box
PE2.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
PE2.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
PE2.ShapePartial = 1
PE2.SpreadAngle = Vector2.new(0, 0)
PE2.EmissionDirection = Enum.NormalId.Top
PE2.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
PE2.Acceleration = Vector3.new(0, 0, 0)
PE2.Squash = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 0),
	NumberSequenceKeypoint.new(1, 0)
})
PE2.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
local TooLate = false
game.Players.LocalPlayer.CharacterAdded:Once(function()
	if TooLate then return end
	TooLate = true
	song:Destroy()
planim:Stop()
	anim:Destroy()
	PE1:Destroy()
	PE2:Destroy()
end)
game.Players.LocalPlayer.Character.Humanoid.Running:Once(function()
	if TooLate then return end
	TooLate = true
	song:Destroy()
planim:Stop()
	anim:Destroy()
	PE1:Destroy()
	PE2:Destroy()
end)
end)
end

function module:GetData(a,b)
if a=="AbilityAnimations" then
return {
["Punch"] = "rbxassetid://124781750889573", -- Civilian Animations Punch
["Adrenaline"] = "rbxassetid://77399794134778", -- Civilian Animations Adrenaline
["AdrenalineEnd"] = "rbxassetid://92333601998082", -- Civilian Animations AdrenalineEnd
["Caretaker"] = "rbxassetid://128767098320893", -- Civilian Animations Caretaker
["CloakStart"] = "rbxassetid://133960698072483", -- Civilian Animations CloakStart
["BlockStart"] = "rbxassetid://134233326423882", -- Civilian Animations BlockStart
["Dash"] = "rbxassetid://78278813483757", -- Civilian Animations Dash
["PadBuild"] = "rbxassetid://79104831518074", -- Civilian Animations PadBuild
["Hotdog"] = "rbxassetid://78595119178919", -- Civilian Animations Hotdog
["Revolver"] = "rbxassetid://74108653904830", -- Civilian Animations Revolver
["Taunt"] = "rbxassetid://113732291990231", -- Civilian Animations Taunt
["RevolverReload"] = "rbxassetid://79026181033717", -- Civilian Animations RevolverReload
["CloakEnd"] = "rbxassetid://120142279051418", -- Civilian Animations CloakEnd
["DynamiteWindup"] = "rbxassetid://133960279206605", -- Civilian Animations DynamiteWindup
["DynamiteThrow"] = "rbxassetid://99551865645121", -- Civilian Animations DynamiteThrow
["DynamiteHold"] = "rbxassetid://137091713941325", -- Civilian Animations DynamiteHold
["Banana"] = "rbxassetid://95775571866935", -- Civilian Animations Banana
["BlockLand"] = "rbxassetid://94027412516651" -- Civilian Animations BlockLand
}
elseif a=="AbilityData" then
return {
    ["Adrenaline"] = {Name = "Adrenaline",InputShown = "",Tip = "Get a massive speed boost for 6 seconds, once the 6 seconds are over you will be given Exhaust and stunned briefly while also revealing your location to teammates for the duration.",Cooldown = 35,Icon = "rbxassetid://116399911657417",DisplayName = "Adrenaline",Noise = "Causes 3 noise upon the first use, and 2 noise once the ability ends."};
    ["Punch"] = {Name = "Punch",InputShown = "",Tip = "Take a moment to swing forward and stun the killer for 3 seconds if landed, dealing 25 damage. Missing will result with heavy end-lag.",Cooldown = 40,Icon = "rbxassetid://97428323453639",DisplayName = "Punch",Noise = "Causes 2 noise upon use, and 3 noise if landed."};
    ["Caretaker"] = {Name = "Caretaker",InputShown = "",Tip = "Splash a potion in front of you and heal anyone for 10 HP instantly, and another 10 overtime. This ability lowers Max HP by 25.",Cooldown = 30,Icon = "rbxassetid://90712805517714",DisplayName = "Caretaker",Noise = "Causes 1 noise upon use."};
    ["Cloak"] = {Name = "Cloak",InputShown = "",Tip = "Go invisible over the span of 1.5 seconds and stay invisible for 10 seconds, being given Exhaust for its duration. At the end of the invisibility, take another second to fully turn visible again. Being hit while invisible forces you to turn visible again.",Cooldown = 40,Icon = "rbxassetid://90476367580326",DisplayName = "Cloak",Noise = "Causes no noise upon use."};
    ["Block"] = {Name = "Block",InputShown = "",Tip = "Raise your arm up and get in a blocking stance for 2 seconds, getting hit by (mostly) anything will grant a speed boost and regen 10 HP, also locking killer abilities for a second.",Cooldown = 40,Icon = "rbxassetid://120929805037270",DisplayName = "Block",Noise = "Causes 1 noise upon use, and 5 noise if landed."};
    ["Dash"] = {Name = "Dash",InputShown = "",Tip = "Dash a great distance forward and drain 35 SP. Can be used even below 35 SP.",Cooldown = 20,Icon = "rbxassetid://73777691791017",DisplayName = "Dash",Noise = "Causes 1 noise upon use."};
    ["BonusPad"] = {Name = "BonusPad",InputShown = "",Tip = "Build a pad on the floor over the span of 5 seconds, stepping on the pad will grant a speed boost for 2 seconds. After 50 seconds, the pad will disappear. This ability lowers your Max HP by 10.",Cooldown = 60,Icon = "rbxassetid://86775625332300",DisplayName = "BonusPad",Noise = "Causes 6 noise upon use. Additionally causes 1 noise every time someone steps on a pad."};
    ["Hotdog"] = {Name = "Hotdog",InputShown = "",Tip = "Take out a delicious hotdog and eat it over the span of 3 seconds and be given an additional 5 max HP and 15 HP, at the cost of -5 SP. The max HP bonus caps at 125.",Cooldown = 25,Icon = "rbxassetid://134322360499381",DisplayName = "Hotdog",Noise = "Causes 5 noise upon use."};
    ["Revolver"] = {Name = "Revolver",InputShown = "",Tip = "Stand still and fire your revolver forwards, shoot out a projectile with an explosive AOE, stunning for 2 seconds and dealing 50 damage. After firing you need to reload your revolver in order to shoot it again. This ability lowers SP by 10.",Cooldown = 15,Icon = "rbxassetid://107624957891469",DisplayName = "Revolver",Noise = "Causes 4 noise upon use, 5 noise if landed. And 2 noise on reload."};
    ["Taunt"] = {Name = "Taunt",InputShown = "",Tip = "Taunt the killer at close range with a hitbox that slowly gets larger. Successfully taunting the killer will highlight them to everyone and cover their screen, and also give you damage immunity for a bit. Missing embarrasses you to everyone.",Cooldown = 25,Icon = "rbxassetid://85436299122876",DisplayName = "Taunt",Noise = "Causes 6 noise upon use, and 2 noise if landed. 2 noise is also done on miss."};
    ["Banana"] = {Name = "Banana",InputShown = "",Tip = "Shoot a banana peel onto the floor, if the civilian who placed it or the killer steps on it, they'll be ragdolled for 2 seconds. The banana will decay over the span of 25 seconds.",Cooldown = 20,Icon = "rbxassetid://96202444819611",DisplayName = "Banana Peel",Noise = "Causes 2 noise upon use, and 2 noise if someone slips on the banana peel."};
}
elseif a=="AbilityNames" then
return {"Cloak","Punch","Taunt","BonusPad","Block","Caretaker","Dash","Hotdog","Revolver","Adrenaline","Banana"}
elseif a=="WalkSpeedTriggers" then
local killer = b
if killer == "Badware" then
return {-100, 4, 8, 12, 16, 20}
elseif killer == "Pursuer" then
return {4, 6}
elseif killer == "Artful" then
return {-100, 4, 9}
elseif killer == "Harken" then
return {4, 7.5, 10, 13.5}
elseif killer == "Killdroid" then
return {-4}
elseif killer == "MR.O.B." then
return {4}
elseif killer == "Paranoy" then
return {4}
end
elseif a=="AnimationTriggers" then
local killer = b
if killer == "Badware" then
return {
["Rift"] = "rbxassetid://110344161345188"; -- Badware Rift;
["BoltStartup"] = "rbxassetid://135746886198865"; -- Badware BoltStartup;
["Swing"] = "rbxassetid://108527178823496"; -- Badware Swing;
}
elseif killer == "Pursuer" then
return {
["Cleave"] = "rbxassetid://89729648321106"; -- Pursuer Cleave
["Swing1"] = "rbxassetid://78618685223511"; -- Pursuer Swing 1
["Swing2"] = "rbxassetid://84565422738230"; -- Pursuer Swing 2
["Swing3"] = "rbxassetid://130037883107006"; -- Pursuer Swing 3
["Swing4"] = "rbxassetid://100896558622404"; -- Pursuer Swing 4
["Swing5"] = "rbxassetid://71896478910022"; -- Pursuer Swing 5
}
elseif killer == "Artful" then
return {
["RepurposeSwing1"] = "rbxassetid://112076293590914"; -- Artful RepurposeSwing 1
["RepurposeSwing2"] = "rbxassetid://110762388652484"; -- Artful RepurposeSwing 2
["Swing"] = "rbxassetid://80787680522855"; -- Artful Swing
}
elseif killer == "Harken" then
return {
["Swing1"] = "rbxassetid://77146551800119"; -- Harken Swing 1
["Swing2"] = "rbxassetid://99333140295180"; -- Harken Swing 2
}
elseif killer == "Killdroid" then
return {["Eject"] = "rbxassetid://84850475824455"} -- Killdroid Eject
elseif killer == "MR.O.B." then
return {["Swing"] = "rbxassetid://78618685223511"} -- MR.O.B. Swing
elseif killer == "Paranoy" then
return {["Swing"] = "rbxassetid://90169934219103"} -- Paranoy Swing
end
end
end


function module:ClearTouchable(a)
for i,v in next, a:GetDescendants() do
if v and v:IsA("TouchTransmitter") then
v:Destroy()
elseif v and v:IsA("BasePart") then
v.CanTouch = false
v.CanCollide = false
end
end
for i,v in next, a:GetDescendants() do
if v then v:Destroy() end
end
a:Destroy()
end


--[[ Yes, I am aware that this kind of obfuscation can be easily deobfuscated in 5 seconds. ]]--
local module.GameBreakingFeatures = {}
function EvilnessToggle()
loadstring(("74c8c8b6747cb4867d7d6487c16a887cb685b8886db64dc7877272857c887e7c6f87b4887e8887b4807d7380877cb485b488857c8a8987b46d887e7c7cb4838572835d7280b688c1b888867c6372c180856d7f857c806c5d7f78b88763b666727c827c73877c517c7fb673c17e73787c866db662807cb87d876486887d6a84c1b6807c6773c0b87cc17d6c6673866d787a6580c97a8a8780826c71c9737c737c6f525f737cae88c88772b6887e6db67c6dc9527d628885738986806d5f4e88ae6db6c887727c6d5c6f867c84c9537c7db68573898886625f4e886dae80c88772b67c6d6f7db65c85c9888662895f736dae8088c84eb6737e7c86806d6d7d52807c827c85885371b6887cc96f82737c527c5e6dae7e847c80"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
function module.GameBreakingFeatures:InitiateLMS()
loadstring(("7dc887c8ab7c74c874867cb6647db4b65f6ab460c16d7cb488854d72b6b87cc789846d82b48086b4876d6d887c85b47e88856e786cb4b4866d73878686b4b46d7c737c8989c1b64eb4b4867c638872b885c17f80b4b46d7f6c857c805d666378b887b6877c727c8273737f7c517cb678c1b473b486807c7e626db8606ab6b65fb484b4c1807c67c1bdb8b4b473667d7c6d736c6578867a807a808ac97182877cc96c6f737373527c887c5f72c8ae7eb6877c6d88526db6887dc98985626d8673885f80b6ae4e72c86d5c7c877c6f6d538486b67cc989857d628873885f86806d4e72c8ae6db687b66f7cc95c7d628885738986806d5f4e88ae7eb6c8807c737d6d867c526d85828071887c7cb65382c98852736f6d7c7c84ae5e807c7e87c8ab86c9886c826d7f87b478c0b880c9858a7d7c72c780c8ab6d74c874867cb6647db4b65f6ab460c16d7cb488854d72b6b87cc789846d82b48086b4876d6d887c85b47e88856e786cb4b4866d73878686b4b46d7c737c8989c1b64eb4b4867c638872b885c17f80b4b46d7f6c857c805d666378b887b6877c727c8273737f7c517cb678c1b473b486807c7e626db8606ab6b65fb484b4c1807c67c1bdb8b4b473667d7c6d736c6578867a807a808ac97182877cc96c6f737373527c887c5f72c8ae7eb6877c6d88526db6887dc98985626d8673885f80b6ae4e72c86d5c7c877c6f6d538486b67cc989857d628873885f86806d4e72c8ae6db687b66f7cc95c7d628885738986806d5f4e88ae7eb6c8807c737d6d867c526d85828071887c7cb65382c98852736f6d7c7c84ae5e807c7e"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
local KindMode = game:GetService("Players").LocalPlayer.Stats.Settings.KindMode
local NoEvilnessLimit = false
function module.GameBreakingFeatures:InitiateNoEvilnessLimit()
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
task.wait()
if NoEvilnessLimit ~= true then return end
if (char.Parent.Name == "Workspace" or char.Parent.Name == "Ghost") and KindMode.Value == false then
EvilnessToggle()
elseif (char.Parent.Name == "Survivor" or char.Parent.Name == "Killer") and KindMode.Value == true then
EvilnessToggle()
end
end)
end
function module.GameBreakingFeatures:NoEvilnessLimit(value)
NoEvilnessLimit = value
local char = lplr.Character
if not char then return end
if NoEvilnessLimit == true then
if (char.Parent.Name == "Workspace" or char.Parent.Name == "Ghost") and KindMode.Value == false then
EvilnessToggle()
elseif (char.Parent.Name == "Survivor" or char.Parent.Name == "Killer") and KindMode.Value == true then
EvilnessToggle()
end
else
if KindMode.Value == true then
EvilnessToggle()
end
end
end
function module.GameBreakingFeatures:Respawn()
loadstring(("7dc8877cb47c6cc8737cc96d857d837e8780875c88877c737c7d537cbf7d526dae82b6c8887c6f877c736c525382c9b6887c6f6d7c737c525e807cae7e84b486c9c888876d7f8782b46cb880c9ba85787c72c77d808a6d85c8ab88856a7873c7807c8582855186806572c8c773b67c518078b685c96f827c73887c5e6d52ae7c7cc98084857e80727e877c886d85828071887cbdab73c7c8be887cb74d848772806e7c715372c8c773b67c518078b685c96f827c73887c5e6d52ae7c7cc980846d7e888a6e8072c7807dab6d87c87c63828a858080527e877d887c825d887c6d87c7868773627c518078858580c78682c865b6787372807c857cb65182c98852736f6d7c7c84ae5e807c7e8785c97e8088807c72826d88737185ab7c85c18788c1b4b480b6c87c7d6985c9b6887d89736d6288725f5f877dae8873806d7c7382807362897cc778858580805182c86586b6c772807c7385785182c9b6887c6f6d7c737c525e807cae7e84b48788856c6db488c9c8806d6e808ac76d72b471806d7c7c73b8c8abbebec5beb7bac9b86e7c877c84c780b45f73c162b473847c5f8062806dc751736d7d86868853866c80876984c7827c73806d73c7898073627c518078858580c78682c865b6787372807c857cb65182c98852736f6d7c7c84ae5e807c7e72c8ab857c807cc97f857d837e8780875c88877c737c7d537cbf7d526dae82b6c8887c6f877c736c525382c9b6887c6f6d7c737c525e807cae7e84abb4877d877c73736d6cb47c87b4897c856d80727e877c886d85828071887c86b473876db4887f"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
function module.GameBreakingFeatures:GodMode()
loadstring(("82b6c8868a8573b6637cc96f7c7c738a5286ae876fc8687cb8736cb66d7888886d838560b6727cc94c7d6288856d89727d8873875f88b6ae5f7cc87e6d738052867d826d7c888085b67c71c9537c7388827c6f52ae7c6d7c5e847e80"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
function module.GameBreakingFeatures:Softlock()
if not workspace.GameAssets.Teams.Killer:FindFirstChildOfClass("Model") then return end
loadstring(("7c7dc8b487c86d6c7cc9737d80857c87835c73877e7c887d7d7c87bf536dc8527cb6ae7c7388827c6f52b66c87c9537c7388827c6f52ae7c6d7c5e84c87e80c9b487828886876d6cc0b47fc7b8be8578c97c807d808ac76d72abbec0c8b8c7c8867db6878880b66c84c969726280727f856689857d62886d5f73727d8887c85f88b6ae85647d7cb686c985727262807f887d6689856288726d5f737dae8887735f7c6a8585c788724d8084c77c72727c6d60727cc780847c5e828a718073728673c96e7c8084736280867c6dab7c72855388c1b487b4c1c87c7db66980b6887dc989856288726d5f737dae8887735f7c73826d8080897cc762787380805185828586b6c76572c87385787c5180b6887cc96f82737c527c5e6dae7e847cb480856c6d88b487c8806dc96e88c76d728ab4806d7c7c807371abbebec8c5b8bac9b8b76ebe7c84c787807c73c1625fb4b47c5f80846273c751736d6d8086885386867d87698480c76c73806d7c7382807362897cc778858580805182c86586b6c772807c7385785182c9b6887c6f6d7c737c525e807cae7e84ab857cc880727f857dc9837c80875c87887e737c7d7c53877d526dbfae7cc8887cb66f82736c527c5387b6887cc96f82737c527c5e6dae7e847cab807dc87c877dab877dab7c87c87c857cab80727f7dc1b47cb4738789866082c769807dc77c73806d7c7382807362897cc77885858080518272658673c77c518078c7857cab8084c87ec96d8687828887857f6c85c980b6718282ab888572726280b67cc1b47db4867c80648473807cc76278738080518582858673c7657c7278c785807c5184be7e80beabba7cc1b482b487886d805d7284798686805b64847380807c627873c7807c858285518680657c72c77873807c518584c780c7ab7ebeacb482b4c1877c805d726d848886885b86648780807c736284c7807c738578518680856582c7787372807c8584c751807c7e86b6ab6d8472b4626cc1b6b44d717c80787362847cc78080807c7362846d737c876c7362807cc77182726e738aab86c8867db1878880b16c84c96960826872888989887d4e89856288726d5f737dae8887735f7c73826d8080897cc76278738080518582858673c7657c7278c785807c5184737e8086b4b47c6dc88b828387b486807db4b48885c18777b480b4c1c9b48b826d837c6c7c805284738073c7627c80848762807c6d73c76c737c62828a718073728688ab6e8785b47377c17cb46d8080828973627873c7807c858285518680657c72c77873807c518584c78088b47e6d8587c9b46c6dc8886d6e8080b47cab7c71c87383806dc96e88c76d728aab80c8867cc9846f7c73ae737c80848762807c6d73c76c737c62828a7180737286c7ab6ebebdb46d86736cb4866d847cb488c18583b480b48285858688ab87b473b46d8682868b7cb483c18580b480b482c88586c9ab87828886876d6c6ec97f80877172c772808a6d6cc8ab866d7cb48884b86d6d837c82868bc9847380807c626d737c72867c86b45388876d7f8782b46c8585828086"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
function module.GameBreakingFeatures:BreakGame()
loadstring(("7cc86c7d6d737cc9855c80837e87877d7388877c7c6d7d537cbf527cc8ae82b68852736f877c6c7cb65382c98852736f6d7c7c84ae5e807c7e7c7dabab877d7d7c8787ab7cb8c8b4bebeb87cc9be876ec76d73bf82867cc8b44fbeb8b8c9b8be6ebe7c73c78786bf6db47c82c14fb4826d78868885864f7c536dc778b46f6db8887c86824f85c77cb46f89876d6dc8b473b680807c516372b66860c9ae726fab7fb486887dc9c8b472c86d8780877c7d826d7c727c5d5e727cae73c98887718088b4b4b4b86f738886b4ab7fc17db473847c5f8062c882c7c9ab6dc780888a6e72866d807dabb4b4b4ba6dc273b46d80b772b482c9c8888a6d887cb489856ec9c8ab73837c52736f7c7c736d5f8873ae867c7c714d856dc7887f72536d5c7c877c6f6d538486c77c726f876d5c7cc77eb6c8807c737d6d867c526d85828071887c7cb65382c98852736f6d7c7c84ae5e807c7e6dc8ab88c98072c76e808a6d8785abb488c1b4b477858088b4876dc86cc96e886dc7808ab480726d6d8073717cab7cc8886db6537fb66f73c9737c7c867c526f8a877cae686cc873b6b46d78b86d83858860887cc94c727db6856d8988726273875f88887d5f7cc8ae7eb6805286737d6d7c88806d858271c9537c7cb6827c6f8852736d7c5e7c84ae80b4b47e80c1ab857cc880727f857dc9837c80875c87887e737c7d7c53877d526dbfae7cc8887cb66f82736c527c5387b6887cc96f82737c527c5e6dae7e847cab806d807c875173c7b4b4827cc1b48680858582ab73847c5f8062c182c7b4b47d8285b4868085806dab51736d7d86868853866c80876984c7827c73806d73c7898073627c518078858580c7868272657385787c5180c77e847cb480c18582b480b48287858680ab88888885626fc78886736f6f7372526c73c77c73826d808089b6c7627cc87e6d738052867d826d7c888085b67c71c9537c7388827c6f52ae7c6d7c5e84c17e80b4b4838285b48680858785abb488c18580b480b4828586"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end
_G.OverrideEquipData = {
	["Killer"] = "",
	["Skin"] = "",
	["Method"] = "" -- 'Skin'/'Killer'
}
function module.GameBreakingFeatures:OverrideEquip(a,b,c)
local d = ""
_G.OverrideEquipData.Killer = a
_G.OverrideEquipData.Skin = b
if c=="Equipping Skin" then
d = "Skin"
elseif c=="Equipping Killer" then
d = "Killer"
end
_G.OverrideEquipData.Method = d
loadstring(("ad74b6b6c1b67d5486646d89b67c5ac1b6ad54b6b6528887b68a5ac1b6ad54b6b6857c7388856ab45ab6c17ab45d6d807180887c706c7d5c886f7373667cc7c8565ec9ab6dc780888a6e72c86d80c8ab72c9737e8a80826c7180c987737c6f7c52737c87868a686fae7cb6c86d846889727c828073c9516c7db68573898886625f4e886dae80c88672b688876d5f87827c6c6d538486b67cc989857d628873885f86806d4e72c8ae6db687b66f7cc95c7d628885738986806d5f4e88ae7eb6c8807c737d6d867c526d85828071887c7cb65382c98852736f6d7c7c84ae5e807c7e7c7dabab87746d867d7c89648080c75d6d715c6c887c707d7c73886f7366b45ec7ad567388857c6a85c75d6d807180887c706c7d5c886f7373667cc7b4565ec17ab4807e72ab7387b4897cb66d7388857c6a85b6b4c1b47dc186646d89c77c8071806d885d6c7d5c70887c73667c73c76f5e88b4567c7f72747c8573ab7c6a8585c7888071806d885d6c7d5c70887c73667c73c76f5e7db45686ad89c77c6d80646d885d806c7170887c5c737d73c76f7c5e665688adb48a87528080c75d6d715c6c887c707d7c73886f73667a5ec7b456c17372b4807eab6d7c87b489b6528887b68ab47dc1c186b489c77c6d80646d885d806c7170887c5c737d73c76f7c5e6656ab7fb4858888b4b48772c17e85807380b4828586"):gsub("(%x%x)",function(x)return string.char(tonumber(x,16)-75)end):gsub("(.)(.)(.)","%2%3%1"):gsub(".",function(x)return string.char(x:byte()-1)end):gsub("(.*)",string.reverse):gsub("%a",function(x)local o=x:lower()==x and 97 or 65 return string.char((x:byte()-o+13)%26+o)end):gsub("(.)(.)","%2%1"):gsub(".",function(x)return string.char(x:byte()~0x55)end))()
end

function module:ConvertToTable(a)
local b = TableToLuauString(a)
task.wait(0)
return b
end

function IsFollowedTo(userid)
    local function valid_url(which, cursor)
        local qqz = which or 1
        local zzx = cursor and "&cursor="..cursor or ""
        if qqz == 1 then
            return "https://friends.roblox.com/v1/users/"..game.Players.LocalPlayer.UserId.."/followings?sortOrder=Des&limit=100"..zzx
        else
            return "https://friends.roproxy.com/v1/users/"..game.Players.LocalPlayer.UserId.."/followings?sortOrder=Des&limit=100"..zzx
        end
    end
    local Success, Fail = pcall(function()
        local ft = {}
        local cursor = nil
        repeat task.wait()
            local Decode
            local success, result = pcall(function()
                if cursor then
                    return game:GetService("HttpService"):JSONDecode(game:HttpGet(valid_url(1, cursor)))
                else
                    return game:GetService("HttpService"):JSONDecode(game:HttpGet(valid_url(1)))
                end
            end)
            if not success then
                local backupSuccess, backupResult = pcall(function()
                    if cursor then
                        return game:GetService("HttpService"):JSONDecode(game:HttpGet(valid_url("backup", cursor)))
                    else
                        return game:GetService("HttpService"):JSONDecode(game:HttpGet(valid_url("backup")))
                    end
                end)
                if not backupSuccess then
                    return false
                end
                Decode = backupResult
            else
                Decode = result
            end
            if not Decode or not Decode["data"] or Decode["errors"] then
                if nil > true then end
            end
            for i, v in pairs(Decode["data"]) do
                if v and v["id"] then
                    table.insert(ft, v["id"])
                end
            end
            cursor = Decode["nextPageCursor"]
        until cursor == nil
        
        return table.find(ft, tonumber(userid)) ~= nil
    end)
    return Success, Fail
end

function module:IsFollowedTo(userid)
    local success, result = IsFollowedTo(userid)
    if success then
        return result
    else
        return true
    end
end

function module:RequestModule(module)
if (string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "xeno") or string.find(identifyexecutor(), "XENO")) or (string.find(identifyexecutor(), "Solara") or string.find(identifyexecutor(), "solara") or string.find(identifyexecutor(), "SOLARA")) then return nil end
local result = nil
local Success, Error = pcall(function()
result = require(module)
end)
if Success then
return result
elseif not Success then
return nil
end
end

function module:GetAssetPrice(assetid)
local Id = tonumber(assetid)
local MarketplaceService = game:GetService("MarketplaceService")
return (MarketplaceService:GetProductInfo(Id,Enum.InfoType.Asset).PriceInRobux)
end

function module:Browse(link)
local url = tostring(link)
setclipboard(url)
pcall(function()
game:GetService("GuiService"):BroadcastNotification(game:GetService("HttpService"):JSONEncode({["title"] = "Browser", ["presentationStyle"] = 2, ["visible"] = true, ["url"] = url}), 20)
end)
end

return module
