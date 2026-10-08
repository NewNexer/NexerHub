repeat task.wait(.5) until game:GetService("Players").LocalPlayer and game:IsLoaded()

getgenv().LocalPlayer = game:GetService("Players").LocalPlayer
pcall(function()
	getgenv().Character = LocalPlayer.Character
end)
pcall(function()
	getgenv().HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3)
end)
pcall(function()
	getgenv().Humanoid = Character:WaitForChild("Humanoid",3)
end)
LocalPlayer.CharacterAdded:Connect(function(AddedCharacter)
	pcall(function()
		getgenv().Character = nil
		getgenv().HumanoidRootPart = nil
		getgenv().Humanoid = nil
		task.wait()
		getgenv().Character = AddedCharacter
		repeat task.wait() until Character:FindFirstChild("HumanoidRootPart")
		getgenv().HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",3)
		repeat task.wait() until Character:FindFirstChild("Humanoid")
		getgenv().Humanoid = Character:WaitForChild("Humanoid",3)
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

if DisabledFlagService == true then
	local SelectGloveRemote = nil
	getgenv().SelectGlove = function(glove, verify) local verify = verify or true Instance.new("RemoteEvent"):FireServer(glove) if verify==true then local SelectGloveHold = tick() repeat task.wait() until LocalPlayer.leaderstats.Glove.Value==g or tick() - sgtt >= 2 end task.wait(.1) end
	if NETWORK:FindFirstChild("SelectGlove") then
		SelectGloveRemote = NETWORK:WaitForChild("SelectGlove")
	elseif NETWORK:FindFirstChild("SelectGlove [STUDIO]") then
		SelectGloveRemote = NETWORK:WaitForChild("SelectGlove [STUDIO]")
	end
	if SelectGloveRemote~=nil then
	getgenv().SelectGlove = function(glove, verify) local verify = verify or true SelectGloveRemote:FireServer(glove) if verify==true then local SelectGloveHold = tick() repeat task.wait() until LocalPlayer.leaderstats.Glove.Value==g or tick() - sgtt >= 2 end task.wait(.1) end
	end

	local ActivateBadgeQuestRemote = nil
	getgenv().ActivateBadgeQuest = function(quest) Instance.new("RemoteEvent"):FireServer(quest) end
	if NETWORK:FindFirstChild("ActivateBadgeQuest") then
		ActivateBadgeQuestRemote = NETWORK:WaitForChild("ActivateBadgeQuest")
	elseif NETWORK:FindFirstChild("ActivateBadgeQuest [STUDIO]") then
		ActivateBadgeQuestRemote = NETWORK:WaitForChild("ActivateBadgeQuest [STUDIO]")
	end
	if ActivateBadgeQuestRemote~=nil then
		getgenv().ActivateBadgeQuest = function(quest) ActivateBadgeQuestRemote:FireServer(quest) end
	end
	
	local CollectBadgeQuestRewardRemote = nil
	getgenv().CollectBadgeQuestReward = function(quest) Instance.new("RemoteEvent"):FireServer(quest) end
	if NETWORK:FindFirstChild("CollectBadgeQuestReward") then
		CollectBadgeQuestRewardRemote = NETWORK:WaitForChild("CollectBadgeQuestReward")
	elseif NETWORK:FindFirstChild("CollectBadgeQuestReward [STUDIO]") then
		CollectBadgeQuestRewardRemote = NETWORK:WaitForChild("CollectBadgeQuestReward [STUDIO]")
	end
	if CollectBadgeQuestRewardRemote~=nil then
		getgenv().CollectBadgeQuestReward = function(quest) CollectBadgeQuestRewardRemote:FireServer(quest) end
	end
end

getgenv().EnterArena = function(Arena) local oldcf = Arena.CFrame Arena.CanCollide = false Arena.CanTouch = true repeat task.wait() pcall(function() Arena:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) Arena:PivotTo(oldcf) Arena.CanCollide = true end
getgenv().TouchObject = function(object, seconds) local oldobjectcancollide = object.CanCollide local oldobjectcframe = object.CFrame local seconds = seconds or 1/20 if not HumanoidRootPart then return end object.CanCollide = false local start = tick() while tick() - start < seconds do pcall(function() object:PivotTo(HumanoidRootPart.CFrame) end) task.wait() end pcall(function() object:PivotTo(oldobjectcframe) end) pcall(function() object.CanCollide = oldobjectcancollide end) end
getgenv().OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
getgenv().TeleportToPosition = function(cFrame,time,huh) local huh = huh or false local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() OverrideVelocity() if huh==true then for i,v in next, Character:GetChildren() do if v:IsA("BasePart") then v:PivotTo(cFrame) end end elseif huh==false then HumanoidRootPart:PivotTo(cFrame) end end) task.wait() end end

return true
