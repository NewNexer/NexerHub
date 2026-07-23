if game.Players.LocalPlayer.PlayerScripts:FindFirstChild("ClientReplicator") then
    game.Players.LocalPlayer.PlayerScripts.ClientReplicator:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CFUpdate = ReplicatedStorage.Events.RemoteEvents.CustomReplication.UpdateServerPos
local GameAssets = workspace.GameAssets
local v1 = 0

getgenv().ClientReplicator = {
	["Spoof Enabled"] = true,
	["No Ping Affection"] = false,
	["Extend Hitbox"] = false,
	["Studs"] = 5
}

local function GetPing()
	local pingString = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValueString()
	if pingString then
		local ping = tonumber(string.match(pingString, "^(%d+)"))
		return ping or 0
	end
	return 0
end

local function GetLegitMaxStamina(Character)
	local legitmaxstamina = 100
	if Character:GetAttribute("Killer") then
		if Character:GetAttribute("Killer") == "Pursuer" or Character:GetAttribute("Killer") == "Killdroid" or Character:GetAttribute("Killer") == "Badware" then
			legitmaxstamina = 110
		elseif Character:GetAttribute("Killer") == "Harken" then
			legitmaxstamina = 114
		end
	end
	return legitmaxstamina
end

local function GetNormalizedStamina(Character)
	if not Character then return 0 end
	local cs = Character:GetAttribute("Stamina") or 0
	local ms = Character:GetAttribute("MaxStamina") or GetLegitMaxStamina(Character)
	if not (type(cs) == "number" and type(ms) == "number") then return 0 end
	if ms <= 0 or not math.isfinite(ms) or not math.isfinite(cs) then return 0 end
	local normalized = (cs / ms) * GetLegitMaxStamina(Character)
	return math.clamp(normalized, 0, GetLegitMaxStamina(Character))
end

repeat
	task.wait(0.5)
until LocalPlayer:FindFirstChild("Stats") and LocalPlayer.Stats:FindFirstChild("LoadedIn")

local connector = RunService.RenderStepped:Connect(function(p1)
	if LocalPlayer==nil then LocalPlayer=Players.LocalPlayer end
	v1 = v1 + p1
	local Character = LocalPlayer.Character
	if not Character then return end
	if not Character:IsDescendantOf(GameAssets.Teams) then return end
	if not (v1 >= 0.035) then return end
	v1 = 0
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if Character:FindFirstChild("PosValue") then
		HumanoidRootPart:PivotTo(Character.PosValue.Value.CFrame)
	end
	local v12 = HumanoidRootPart and HumanoidRootPart.CFrame or Character:GetPivot()
	local v3 = if Character:GetAttribute("Ragdolled") then Vector3.new(0, 0, 0) else (HumanoidRootPart and HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)) / 17.5
	if (Vector3.new(v12) - Vector3.new(v12 + v3)).Magnitude > 7 then
		v3 = v3 / 2
	end
	if ClientReplicator["Extend Hitbox"] and HumanoidRootPart then
		local lookVector = HumanoidRootPart.CFrame.LookVector
		local forwardVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
		v12 = v12 + (forwardVector * ClientReplicator["Studs"])
	end
	if ClientReplicator["No Ping Affection"] and HumanoidRootPart and LocalPlayer==Players.LocalPlayer then
		local velocity = HumanoidRootPart.AssemblyLinearVelocity
		local speed = velocity.Magnitude
		local ping = GetPing()
		if speed > 10 and ping > 20 then
			local offset = math.min((speed * ping) / 1200, 7)
			local velocityDirection = velocity.Unit
			local forwardVector = Vector3.new(velocityDirection.X, 0, velocityDirection.Z).Unit
			v12 = v12 + (forwardVector * offset)
		end
	end
	local staminaValue
	if ClientReplicator["Spoof Enabled"] then
		staminaValue = GetNormalizedStamina(Character)
	else
		staminaValue = Character:GetAttribute("Stamina") or 0
	end
	CFUpdate:FireServer(v12 + v3, workspace.CurrentCamera.CFrame.LookVector, staminaValue)
	for v4, v5 in Players:GetPlayers() do
		if v5 ~= LocalPlayer then
			local Character2 = v5.Character
			if Character2 then
				local HumanoidRootPart2 = Character2:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart2 then
					local v6 = (Character2:FindFirstChild("Replicator_Good") or HumanoidRootPart2).CFrame
					if HumanoidRootPart2 then
						HumanoidRootPart2.CFrame:Lerp(v6, 0.035)
						continue
					end
					Character2:PivotTo(v6)
				end
			end
		end
	end
	local v7 = GameAssets.Teams.Survivor:GetChildren()
	for k, v in pairs(GameAssets.Teams.Killer:GetChildren()) do
		table.insert(v7, v)
	end
	for k, v in pairs(GameAssets.Teams.Other:GetChildren()) do
		table.insert(v7, v)
	end
	for k, v in pairs(v7) do
		if not Players:GetPlayerFromCharacter(v) and v:FindFirstChild("PosValue") then
			v.PrimaryPart:PivotTo(v.PosValue.Value.CFrame)
		end
	end
end)

function ClientReplicator.Disconnect()
if connector then
connector:Disconnect()
end
connector = nil
end
function ClientReplicator.HookOnto(plr)
LocalPlayer = plr
end
function ClientReplicator.Unhook()
LocalPlayer = Players.LocalPlayer
end
