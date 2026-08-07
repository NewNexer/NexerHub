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

connector = RunService.RenderStepped:Connect(function(arg1)
    v1 += arg1

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

        local Cframe = HumanoidRootPart and HumanoidRootPart.CFrame or Character:GetPivot()
        local v2 = HumanoidRootPart:FindFirstChild("PingBool") and HumanoidRootPart.PingBool.Value * 0.7 or 0.2
        local v3 = math.clamp(v2, 0.03, 0.13)
        local AssemblyLinearVelocity = HumanoidRootPart and HumanoidRootPart.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
        v2 = if Character:GetAttribute("Ragdolled") then Vector3.new(0, 0, 0) else AssemblyLinearVelocity * v3
        local v4 = Cframe + v2

        if (Vector3.new(Cframe) - Vector3.new(v4)).Magnitude > 8 then
            v2 /= 2
        end

        -- Added features kept but applied to the correct Cframe
        if ClientReplicator["Extend Hitbox"] and HumanoidRootPart then
            local lookVector = HumanoidRootPart.CFrame.LookVector
            local forwardVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            Cframe = Cframe + (forwardVector * ClientReplicator["Studs"])
        end

        if ClientReplicator["No Ping Affection"] and HumanoidRootPart then
            local velocity = HumanoidRootPart.AssemblyLinearVelocity
            local speed = velocity.Magnitude
            local ping = GetPing()
            if speed > 10 and ping > 20 then
                local offset = math.min((speed * ping) / 1200, 7)
                local velocityDirection = velocity.Unit
                local forwardVector = Vector3.new(velocityDirection.X, 0, velocityDirection.Z).Unit
                Cframe = Cframe + (forwardVector * offset)
            end
        end

        local staminaValue
        if ClientReplicator["Spoof Enabled"] then
            staminaValue = GetNormalizedStamina(Character)
        else
            staminaValue = Character:GetAttribute("Stamina") or 0
        end

        -- Fixed: Using correct parameters matching Script 1 (CFrame + velocity, stamina, tick())
        UpdateServerPos:FireServer(Cframe + v2, staminaValue, tick())

        local v7 = GameAssets.Teams.Survivor:GetChildren()
        local v8 = pairs
        local v9 = Character:GetAttribute("Stamina") or 0

        for v10, v11 in v8(GameAssets.Teams.Killer:GetChildren()) do
            table.insert(v7, v11)
        end

        for v13, v14 in pairs(GameAssets.Teams.Other:GetChildren()) do
            table.insert(v7, v14)
        end

        for v15, v16 in pairs(v7) do
            if not Players:GetPlayerFromCharacter(v16) and v16:FindFirstChild("PosValue") then
                v16.PrimaryPart:PivotTo(v16.PosValue.Value.CFrame)
            end
        end
    end

    for v17, v18 in Players:GetPlayers() do
        if v18 ~= LocalPlayer then
            local Character_1 = v18.Character

            if Character_1 then
                local HumanoidRootPart_1 = Character_1:FindFirstChild("HumanoidRootPart")

                if HumanoidRootPart_1 then
                    local Cframe_1 = (Character_1:FindFirstChild("Replicator_Good") or HumanoidRootPart_1).CFrame

                    if not Character_1:FindFirstChild("PosValue") then
                        if HumanoidRootPart_1 then
                            HumanoidRootPart_1.CFrame = HumanoidRootPart_1.CFrame:Lerp(Cframe_1, 0.14)
                        else
                            Character_1:PivotTo(Cframe_1)
                        end
                    end
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
