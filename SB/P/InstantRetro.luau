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

local TouchObject = function(object, seconds) local oldobjectcancollide = object.CanCollide local oldobjectcframe = object.CFrame local seconds = seconds or 1/20 if not HumanoidRootPart then return end object.CanCollide = false local start = tick() while tick() - start < seconds do pcall(function() object:PivotTo(HumanoidRootPart.CFrame) end) task.wait() end pcall(function() object:PivotTo(oldobjectcframe) end) pcall(function() object.CanCollide = oldobjectcancollide end) end
local OverrideVelocity = function() pcall(function() for i,v in next, Character:GetDescendants() do if v and v:IsA("BasePart") then v.Velocity,v.RotVelocity = Vector3.new(0,0,0),Vector3.new(0,0,0) end end end) end
local TeleportToPosition = function(cFrame,time,huh) local huh = huh or false local time = time or 1 local starttimee = tick() while tick() - starttimee < time do pcall(function() task.spawn(OverrideVelocity) if huh==true then for i,v in next, Character:GetChildren() do if v:IsA("BasePart") then v:PivotTo(cFrame) end end elseif huh==false then HumanoidRootPart:PivotTo(cFrame) end end) task.wait() end end

if game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems:FindFirstChild("VFXReplication") and game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication:FindFirstChild("RepressedMemory") then
    game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication.RepressedMemory.Name = "RM"
end
repeat task.wait(.005) game:GetService("ReplicatedStorage").RecallReset:FireServer(nil, true) task.spawn(function() rsanswrr = game:GetService("ReplicatedStorage").RecallLastInteractionSteps:InvokeServer(false) end) until rsanswrr=="Simon says walk through the portal to collect your reward"
TouchObject(workspace.RepressedMemories.Portal)
repeat task.wait() until LocalPlayer.leaderstats.Glove.Value=="Recall"
task.spawn(TeleportToPosition, workspace.FinishDoor_Retro:FindFirstChild("TouchInterest",true).Parent.CFrame, 3)
game:GetService("ReplicatedStorage").ClaimRetroFastTravel:FireServer(true,true)
if game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems:FindFirstChild("VFXReplication") and game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication:FindFirstChild("RM") then
    game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication.RepressedMemory.Name = "RepressedMemory"
end
