getgenv().ClientAbilities = {["Civilian"]={};["Killer"]={};}
task.wait()
ClientAbilities.Civilian.Pie = [[local Variables = require(game:GetService("ReplicatedStorage").ClientModules.Gui.Variables)
local PieTrajectory = require(game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory)

PieTrajectory.UpdateMeter = function(p1, p2)
    p1.Bar:TweenSize(UDim2.new(p2 / PieTrajectory.MaxDistance, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05, true, nil)
    p1.Bar.Flash.Visible = true
    p1.Bar.Flash.Transparency = 0
    game:GetService("TweenService"):Create(p1.Bar.Flash, TweenInfo.new(0.05), {
        Transparency = 1
    }):Play()
end

function PieTrajectory.Init(p1)
    local Players = game:GetService("Players")
    local Character = Players.LocalPlayer.Character
    if not (Character and Character.Parent) then
        return
    end
    if PieTrajectory._initialised then
        warn("PieTrajectory already initialised")
        return
    end
    PieTrajectory._initialised = true
    local v3 = 10
    PieTrajectory.Update(v3, 50, p1)
    local LocalPlayer = Players.LocalPlayer
    local v4 = LocalPlayer.Stats.Settings.InteractKeybind:GetAttribute("Keybind")
    local function KeyCodeExists(p1)
        return pcall(function()
            return Enum.KeyCode[p1]
        end)
    end
    local v5 = v4
    local v6 = if pcall(function()
        return Enum.KeyCode[v5]
    end) and Enum.KeyCode[v4].Name ~= "Unknown" then Enum.KeyCode[v4] else Enum.UserInputType[v4]
    local MainGui = require(game:GetService("ReplicatedStorage").ClientModules.GuiCollect).MainGui
    local tbl = {}
    local holdingQ = false
    local holdingE = false
    local originalPlaybackSpeed = 1
    local function cleanupTrajectories()
        PieTrajectory.Bin:ClearAllChildren()
    end
    local function fullCleanup()
        holdingQ = false
        holdingE = false
        game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed = originalPlaybackSpeed
        for k, v in pairs(tbl) do
            v:Disconnect()
        end
        MainGui.Devices.Mobile.Action.Visible = false
        PieTrajectory._initialised = false
        cleanupTrajectories()
    end
    if Variables.PreferredInput == Enum.PreferredInput.Touch then
        MainGui.Devices.Mobile.Action.Visible = true
        MainGui.Devices.Mobile.Action.Icon.Image = "rbxassetid://40312175"
        MainGui.RoundUI.Civilian.Pie.Meter.Title.Text = "HOLD THE PIE BUTTON"
        table.insert(tbl, MainGui.Devices.Mobile.Action.MouseEnter:Connect(function()
            while PieTrajectory._initialised and Character and Character.Parent and Character:GetAttribute("HoldingPie") do
                v3 = v3 + 2
                v3 = math.clamp(v3, 0, PieTrajectory.MaxDistance)
                PieTrajectory.Update(v3, 50, p1)
                task.wait(0.02)
            end
        end))
        table.insert(tbl, MainGui.Devices.Mobile.Action.MouseLeave:Connect(function()
            if Character and Character.Parent and Character:GetAttribute("HoldingPie") then
                PieTrajectory.Shoot(Character)
                cleanupTrajectories()
            end
        end))
    else
        MainGui.RoundUI.Civilian.Pie.Meter.Title.Text = "HOLD Q/E: ADJUST DISTANCE | " .. string.upper(Variables.GetKeybindStringAbility(v6)) .. ": THROW"
        local UserInputService = game:GetService("UserInputService")
        local function playClickSoundLoop()
            while (holdingQ or holdingE) and PieTrajectory._initialised do
                game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click:Play()
                game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed = math.min(game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed + 0.05, 3)
                task.wait(0.1)
            end
            game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed = originalPlaybackSpeed
        end
        table.insert(tbl, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == Enum.KeyCode.Q and not holdingQ then
                holdingQ = true
                spawn(function()
                    while holdingQ and PieTrajectory._initialised and Character and Character.Parent and Character:GetAttribute("HoldingPie") do
                        v3 = math.max(v3 - 2, 0)
                        PieTrajectory.Update(v3, 50, p1)
                        task.wait(0.015)
                    end
                end)
                if not holdingE then
                    spawn(playClickSoundLoop)
                end
            end
            if input.KeyCode == Enum.KeyCode.E and not holdingE then
                holdingE = true
                spawn(function()
                    while holdingE and PieTrajectory._initialised and Character and Character.Parent and Character:GetAttribute("HoldingPie") do
                        v3 = math.min(v3 + 2, PieTrajectory.MaxDistance)
                        PieTrajectory.Update(v3, 50, p1)
                        task.wait(0.015)
                    end
                end)
                if not holdingQ then
                    spawn(playClickSoundLoop)
                end
            end
        end))
        table.insert(tbl, UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Q then
                holdingQ = false
                if not holdingE then
                    game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed = originalPlaybackSpeed
                end
            end
            if input.KeyCode == Enum.KeyCode.E then
                holdingE = false
                if not holdingQ then
                    game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.PieTrajectory.Click.PlaybackSpeed = originalPlaybackSpeed
                end
            end
        end))
        table.insert(tbl, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode ~= v6 and input.UserInputType ~= v6 then return end
            if Character and Character.Parent and Character:GetAttribute("HoldingPie") then
                PieTrajectory.Shoot(Character)
                cleanupTrajectories()
            end
        end))
    end
    repeat
        task.wait(0.01)
        if not Character:GetAttribute("HoldingPie") then
            fullCleanup()
            break
        end
        PieTrajectory.Render(Character)
    until not Character or (not Character.Parent or not PieTrajectory._initialised)
    if PieTrajectory._initialised then
        fullCleanup()
    end
end]]
ClientAbilities.Civilian.Bulge = [[local Variables = require(game:GetService("ReplicatedStorage").ClientModules.Gui.Variables)
local BugleEvent = require(game:GetService("ReplicatedStorage").ClientModules.Gui.Game.Ability.Require.BugleEvent)
local CreateEvent = function(p1, p2)
    if Variables.PreferredInput == Enum.PreferredInput.Touch then
        return BugleEvent.CreateMobileEvent(p1, p2)
    end
    local v1 = p1.Events.Template:Clone()
    v1.Visible = true
    v1.Parent = p1.Events
    game:GetService("Debris"):AddItem(v1, p2 + 0.05)
    local v2 = game:GetService("TweenService"):Create(v1, TweenInfo.new(p2 * 0.85, Enum.EasingStyle.Linear), {
        Size = p1.Center.Size
    })
    v2:Play()
    v1.ImageColor3 = Color3.fromRGB(255, 206, 60)
    p1.Keybind.TextColor3 = Color3.fromRGB(255, 206, 60)
    table.clear(BugleEvent.Keybinds)
    for i = 2, 5 do
        local v3 = game:GetService("Players").LocalPlayer.Stats.Settings[("Ability%*Keybind"):format(i)]:GetAttribute("Keybind")
        local function KeyCodeExists(p1)
            return pcall(function()
                return Enum.KeyCode[p1]
            end)
        end
        if pcall(function() 
            return Enum.KeyCode[v3]
        end) and Enum.KeyCode[v3].Name ~= "Unknown" then
            table.insert(BugleEvent.Keybinds, Enum.KeyCode[v3])
            continue
        end
        table.insert(BugleEvent.Keybinds, Enum.UserInputType[v3])
    end
    local v6 = Enum.KeyCode.E
    p1.Keybind.Text = v6.Name
    local v7 = nil
    v7 = game:GetService("UserInputService").InputBegan:Connect(function(p12, p2)
        if p2 then
            return
        end
        if p12.KeyCode ~= v6 and p12.UserInputType ~= v6 then
            return
        end
        v7:Disconnect()
        v7 = nil
        BugleEvent.EventSuccess(p1, v1)
    end)
    BugleEvent.KeybindToPress = v6
    v2.Completed:Connect(function()
        if v7 then
            v7:Disconnect()
            BugleEvent.EventFail(p1, v1)
        end
    end)
end
BugleEvent.CreateEvent = CreateEvent]]
