
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UpdateServerPos = ReplicatedStorage.Events.RemoteEvents.CustomReplication.UpdateServerPos
local GameAssets = workspace.GameAssets
local v1 = 0
local connector = nil

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

connector = RunService.RenderStepped:Connect(function(p1)
    v1 = v1 + p1

    local Character = LocalPlayer.Character

    if not Character then
        return
    end

    if not Character:IsDescendantOf(GameAssets.Teams) then
        return
    end

    if v1 >= 0.035 then
        v1 = 0

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if not HumanoidRootPart then
            return
        end

        if Character:FindFirstChild("PosValue") then
            HumanoidRootPart:PivotTo(Character.PosValue.Value.CFrame)
        end

        local v12 = HumanoidRootPart and HumanoidRootPart.CFrame or Character:GetPivot()
        local v3 = math.clamp(HumanoidRootPart:FindFirstChild("PingBool") and HumanoidRootPart.PingBool.Value * 0.8 or 0.2, 0.03, 0.13)
        local v5 = if Character:GetAttribute("Ragdolled") then Vector3.new(0, 0, 0) else (HumanoidRootPart and HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)) * v3

        if (Vector3.new(v12) - Vector3.new(v12 + v5)).Magnitude > 8 then
            v5 = v5 / 2
        end

        if ClientReplicator["Extend Hitbox"] and HumanoidRootPart then
            local lookVector = HumanoidRootPart.CFrame.LookVector
            local forwardVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            v12 = v12 + (forwardVector * ClientReplicator["Studs"])
        end

        if ClientReplicator["No Ping Affection"] and HumanoidRootPart then
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

        UpdateServerPos:FireServer(v12 + v5, workspace.CurrentCamera.CFrame.LookVector, staminaValue, tick())

        local v6 = GameAssets.Teams.Survivor:GetChildren()

        for k, v in pairs(GameAssets.Teams.Killer:GetChildren()) do
            table.insert(v6, v)
        end

        for k, v in pairs(GameAssets.Teams.Other:GetChildren()) do
            table.insert(v6, v)
        end

        for k, v in pairs(v6) do
            if not Players:GetPlayerFromCharacter(v) and v:FindFirstChild("PosValue") then
                v.PrimaryPart:PivotTo(v.PosValue.Value.CFrame)
            end
        end
    end

    for v7, v8 in Players:GetPlayers() do
        if v8 ~= LocalPlayer then
            local Character2 = v8.Character

            if Character2 then
                local HumanoidRootPart = Character2:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart then
                    local v9 = (Character2:FindFirstChild("Replicator_Good") or HumanoidRootPart).CFrame

                    if HumanoidRootPart then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(v9, 1.12)
                        continue
                    end

                    Character2:PivotTo(v9)
                end
            end
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

if game.Players.LocalPlayer.PlayerScripts:FindFirstChild("ClientReplicator") then
    game.Players.LocalPlayer.PlayerScripts.ClientReplicator:Destroy()
end
