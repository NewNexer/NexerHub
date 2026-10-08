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

if workspace:FindFirstChild("platform4")==nil then
local platform4 = Instance.new("Part")
platform4.Position = Vector3.new(0,30000,0)
platform4.Size = Vector3.new(2048,4,2048)
platform4.Anchored = true
platform4.Transparency = 0.5
platform4.CanCollide = true
platform4.Name = "platform4"
platform4.Parent = workspace
end

TeleportToPosition(CFrame.new(-89, -28140, 5), .5)
Humanoid.HealthChanged:Wait()
SelectGlove("el gato")
TeleportToPosition(workspace["platform4"].CFrame * CFrame.new(0,10,0), 2)
repeat task.wait() until Character.isInArena.Value==true
repeat game:GetService("ReplicatedStorage").Events.Cat:FireServer() task.wait() until workspace:FindFirstChild(LocalPlayer.Name.."'s cat")
game:GetService("ReplicatedStorage").GeneralAbility:FireServer()
repeat task.wait() until Character:FindFirstChild("Reversed") or Humanoid.Health==0
if Humanoid.Health==0 then return end
SelectGlove("Replica")
game:GetService("ReplicatedStorage").Duplicate:FireServer(true)
repeat task.wait() until workspace:FindFirstChild("Å"..LocalPlayer.Name)
LocalPlayer.Reset:FireServer()
SelectGlove("Divert")
LocalPlayer.CharacterAdded:Wait()
task.wait(1)
task.delay(.777,function() game:GetService("ReplicatedStorage").GeneralHit:FireServer(workspace["Å"..LocalPlayer.Name].Head) end)
TeleportToPosition(workspace["platform4"].CFrame * CFrame.new(0,10,0), 3)
game:GetService("ReplicatedStorage").Events.Friction:FireServer("touched_fire")
game:GetService("ReplicatedStorage").SelfKnockback:FireServer({Force = 10, Direction = Vector3.new(0,-10,0)})
repeat task.wait() until Character.Ragdolled.Value==true
repeat task.wait() until Character.Ragdolled.Value==false
for i,v in next, HumanoidRootPart:GetChildren() do
if v.Name=="BodyVelocity" or v.Name=="BodyAngularVelocity" then
v:Destroy()
end
end
task.wait(1)
TeleportToPosition(CFrame.new(-1198.31946, 327.912567, -1.62665927, 0.0157224797, -9.95097764e-08, -0.99987638, 1.43943977e-08, 1, -9.92957325e-08, 0.99987638, -1.28314435e-08, 0.0157224797), 2)
