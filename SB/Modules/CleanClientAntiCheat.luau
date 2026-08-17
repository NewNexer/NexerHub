local place = ... or "Slap Battles"

repeat task.wait(.1) until game:GetService("Players").LocalPlayer

if place=="Slap Battles" then
    --[[local all_bad_remotes = {
        "PingPongEvent";
        "SetApiEnv";
        "ToggleApiMode";
        "Sparky";
        "Ban";
        "AdminGUI";
        "WalkSpeedChanged";
        "SpecialGloveAccess";
        "PlaySoundRemote";
        "GRAB";
    }]]
    local all_bad_remotes = {
        "SetApiEnv";
        "ToggleApiMode";
        "Ban";
        "AdminGUI";
        "WalkSpeedChanged";
        "SpecialGloveAccess";
        "PlaySoundRemote";
        "GRAB"
    }
    if require and not (string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "Solara")) then
        pcall(function()
            local module = require(game:GetService("ReplicatedStorage").Modules.NetworkOwnershipListener)
            module.ViolationDetected = function() end
        end)
    end
    for i,v in next, all_bad_remotes do
        if game:GetService("ReplicatedStorage"):FindFirstChild(v) then
            local real = game:GetService("ReplicatedStorage"):WaitForChild(v)
            local fake = Instance.new(real.ClassName)
            fake.Name = real.Name
            fake.Parent = real.Parent
            real:Destroy()
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("OperaGxRewardsRemotes") and game:GetService("ReplicatedStorage").OperaGxRewardsRemotes:FindFirstChild(v) then
            local real = game:GetService("ReplicatedStorage").OperaGxRewardsRemotes:WaitForChild(v)
            local fake = Instance.new(real.ClassName)
            fake.Name = real.Name
            fake.Parent = real.Parent
            real:Destroy()
        end
    end
    if game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true) and game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true).Enabled==true then
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true)
        remote.OnClientEvent:Connect(function(...)
            remote:FireServer({
                MessageError = {},
                MessageInfo = {"GrabLocal active"},
                MessageOutput = {},
                MessageWarning = {},
            })
        end)
    end
    if game:GetService("ReplicatedFirst"):FindFirstChild("Client") and game:GetService("ReplicatedFirst").Client:FindFirstChild("GrabLocal") then
        local real = game:GetService("ReplicatedFirst").Client.GrabLocal
        local fake = Instance.new("LocalScript")
        fake.Name = "GrabLocal"
        fake.Parent = game:GetService("ReplicatedFirst").Client
        real:Destroy()
    end
    if game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("ClientAnticheat") and game:GetService("Players").LocalPlayer.PlayerScripts.ClientAnticheat:FindFirstChild("AntiMobileExploits") then
        local real = game:GetService("Players").LocalPlayer.PlayerScripts.ClientAnticheat.AntiMobileExploits
        local fake = Instance.new("LocalScript")
        fake.Name = "AntiMobileExploits"
        fake.Parent = game:GetService("Players").LocalPlayer.PlayerScripts.ClientAnticheat
        real:Destroy()
    end
    if game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("LegacyClient") and game:GetService("Players").LocalPlayer.PlayerScripts.LegacyClient:FindFirstChild("MusicLoaderI") then
        local real = game:GetService("Players").LocalPlayer.PlayerScripts.LegacyClient.MusicLoaderI
        local fake = Instance.new("LocalScript")
        fake.Name = "MusicLoaderI"
        fake.Parent = game:GetService("Players").LocalPlayer.PlayerScripts.LegacyClient
        real:Destroy()
    end
    if game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("ClientAnticheat") and game:GetService("StarterPlayer").StarterPlayerScripts.ClientAnticheat:FindFirstChild("AntiMobileExploits") then
        local real = game:GetService("StarterPlayer").StarterPlayerScripts.ClientAnticheat.AntiMobileExploits
        local fake = Instance.new("LocalScript")
        fake.Name = "AntiMobileExploits"
        fake.Parent = game:GetService("StarterPlayer").StarterPlayerScripts.ClientAnticheat
        real:Destroy()
    end
elseif place=="Slap Royale" then
    local all_bad_remotes = {
        "LegacyBan";
        "Ban";
        "AdminGUI";
        "WalkSpeedChanged";
        "LegacyAntiCheatFunction";
        "KickedBind";
    }
    for i,v in next, all_bad_remotes do
        if game:GetService("ReplicatedStorage"):FindFirstChild(v) then
            local real = game:GetService("ReplicatedStorage"):WaitForChild(v)
            local fake = Instance.new(real.ClassName)
            fake.Name = real.Name
            fake.Parent = real.Parent
            real:Destroy()
        elseif game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild(v) then
            local real = game:GetService("ReplicatedStorage").Remotes:WaitForChild(v)
            local fake = Instance.new(real.ClassName)
            fake.Name = real.Name
            fake.Parent = real.Parent
            real:Destroy()
        end
    end
    if game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true) and game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true).Enabled==true then
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Grab", true)
        remote.OnClientEvent:Connect(function(...)
            remote:FireServer({
                MessageError = {},
                MessageInfo = {"GrabLocal active"},
                MessageOutput = {},
                MessageWarning = {},
            })
        end)
    end
    if game:GetService("ReplicatedFirst"):FindFirstChild("Client") and game:GetService("ReplicatedFirst").Client:FindFirstChild("GrabLocal") then
        local real = game:GetService("ReplicatedFirst").Client.GrabLocal
        local fake = Instance.new("LocalScript")
        fake.Name = "GrabLocal"
        fake.Parent = game:GetService("ReplicatedFirst").Client
        real:Destroy()
    end
end

if hookmetamethod and getnamecallmethod then
    pcall(function()
        local Namecall
        Namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = string.lower(getnamecallmethod())
            if method == "kick" then
                return
            end
            return Namecall(self, ...)
        end)
    end)
end
