repeat task.wait(.5) until game:GetService("Players").LocalPlayer and game:IsLoaded()

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character, HumanoidRootPart, Humanoid
pcall(function()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end)
pcall(function()
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3600)
end)
pcall(function()
	Humanoid = Character:WaitForChild("Humanoid",3600)
end)
LocalPlayer.CharacterAdded:Connect(function(AddedCharacter)
	pcall(function()
		Character = nil
		HumanoidRootPart = nil
		Humanoid = nil
		task.wait()
		Character = AddedCharacter
		repeat task.wait() until Character:FindFirstChild("HumanoidRootPart")
		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3600)
		repeat task.wait() until Character:FindFirstChild("Humanoid")
		Humanoid = Character:WaitForChild("Humanoid",3600)
	end)
end)

local EnterArena = function(ar) local oldcf = ar.CFrame ar.CanCollide = false ar.CanTouch = true repeat task.wait() pcall(function() ar:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) ar:PivotTo(oldcf) ar.CanCollide = true end
local TouchObject = function(object, seconds) local oldobjectcancollide = object.CanCollide local oldobjectcframe = object.CFrame local seconds = seconds or 1/20 if not HumanoidRootPart then return end object.CanCollide = false local start = tick() while tick() - start < seconds do pcall(function() object:PivotTo(HumanoidRootPart.CFrame) end) task.wait() end pcall(function() object:PivotTo(oldobjectcframe) end) pcall(function() object.CanCollide = oldobjectcancollide end) end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
local TeleportToPosition = function(cFrame,time,huh) local huh = huh or false local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() OverrideVelocity() if huh==true then for i,v in next, Character:GetChildren() do if v:IsA("BasePart") then v:PivotTo(cFrame) end end elseif huh==false then HumanoidRootPart:PivotTo(cFrame) end end) task.wait() end end

local EncodeConfiguration = function(a) return buffer.tostring(game:GetService("EncodingService"):Base64Encode(buffer.fromstring(game:GetService("HttpService"):JSONEncode(a)))) end
local DecodeConfiguration = function(a) return ((a~=nil and game:GetService("HttpService"):JSONDecode(buffer.tostring(game:GetService("EncodingService"):Base64Decode(buffer.fromstring(a))))) or nil) end

local Configuration = DecodeConfiguration(...) or {
    ["CandyCorns"] = false,
    ["Gifts"] = false,
    ["Jet"] = false,
    ["Phase"] = false,
    ["Glitch"] = false,
    ["MATERIALIZE"] = false,
    ["Siphon"] = false,
    ["Hammer"] = false,
    ["Slapples"] = false,
	["SortOrder"] = "Asc"
}

if not Configuration.SortOrder then
	Configuration.SortOrder = "Asc"
end

function Serverhop()
task.spawn(function()
while task.wait() do
local servers = {}
local req = game:HttpGet("https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder="..tostring(Configuration.SortOrder).."&limit=100&excludeFullGames=true")
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
task.delay(6,Serverhop)

if Configuration.Gifts==true or Configuration.Jet==true or Configuration.Phase==true or Configuration.Glitch==true or Configuration.MATERIALIZE==true or Configuration.Siphon==true or Configuration.Slapples==true then
    if workspace.Lobby:FindFirstChild("Teleport2") then
        EnterArena(workspace.Lobby["Teleport2"])
    else
        EnterArena(workspace.Lobby["Teleport1"])
    end
end
if Configuration.Hammer==true and workspace:FindFirstChild("Toolbox") then
    task.spawn(fireclickdetector, workspace.Toolbox:FindFirstChild("ClickDetector", true))
end
if Configuration.CandyCorns==true then
    for i,v in next, workspace.CandyCorns:GetChildren() do
        if v then
            task.spawn(TouchObject, v)
        end
    end
end
if Configuration.Gifts==true or Configuration.Jet==true or Configuration.Phase==true or Configuration.Glitch==true or Configuration.MATERIALIZE==true or Configuration.Siphon==true then
    for i,v in next, workspace:GetChildren() do
        if v.Name=="Gift" and Configuration.Gifts==true then
            task.spawn(TouchObject, v)
        elseif v.Name=="JetOrb" and Configuration.Jet==true then
            task.spawn(TouchObject, workspace.JetOrb)
        elseif v.Name=="PhaseOrb" and Configuration.Phase==true then
            task.spawn(TouchObject, workspace.PhaseOrb)
        elseif v.Name=="GlitchOrb" and Configuration.Glitch==true then
            task.spawn(TouchObject, workspace.GlitchOrb)
        elseif v.Name=="MATERIALIZEOrb" and Configuration.MATERIALIZE==true then
            task.spawn(TouchObject, workspace.MATERIALIZEOrb)
        elseif v.Name=="SiphonOrb" and Configuration.Siphon==true then
            task.spawn(TouchObject, workspace.SiphonOrb)
        end
    end
end
if Configuration.Slapples==true then
    for _,slapple in next, workspace.Arena.island5.Slapples:GetChildren() do
        if slapple and (slapple.Name == "Slapple" or slapple.Name == "GoldenSlapple") and slapple:FindFirstChild("Glove") then
            task.spawn(TouchObject, slapple.Glove)
        end
    end
end
task.wait(.5)
task.spawn(Serverhop)
