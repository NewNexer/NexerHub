local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

game.Players.LocalPlayer.CharacterAdded:Once(function()
if game.Players.LocalPlayer.PlayerScripts.Character:FindFirstChild("ClientAnimations") then
    game.Players.LocalPlayer.PlayerScripts.Character.ClientAnimations:Destroy()
end
end)

if ClientAnimations~=nil then 
    ClientAnimations:Reload()
    return
end

getgenv().ClientAnimations = {}
task.wait()

ClientAnimations.ActiveConnections = {}
ClientAnimations.AnimationThreads = {}
ClientAnimations.IsEnabled = true
ClientAnimations.InitializedCharacters = {}

local ClientFunctions
local ClientModules = ReplicatedStorage:FindFirstChild("ClientModules")
if ClientModules then
    pcall(function()
        ClientFunctions = require(ClientModules.ClientFunctions)
    end)
end

local function CheckAir(character, direction)
    if ClientFunctions and ClientFunctions.CheckAir then
        return ClientFunctions.CheckAir(character, direction)
    end
    local root = character and character.PrimaryPart
    if not root then return nil end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    local result = workspace:Raycast(root.Position, direction, raycastParams)
    return result
end

local function AdjustAnimationSpeed(character, track)
    if not character or not track then return end
    if track.Name ~= "Walk" and track.Name ~= "HurtWalk" and track.Name ~= "Sprint" and track.Name ~= "HurtSprint" then
        return
    end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end
    local speed = humanoid.WalkSpeed
    local isSprint = track.Name == "Sprint" or track.Name == "HurtSprint"
    local baseSpeed = isSprint and (character:GetAttribute("SprintSpeed") or 26) or (character:GetAttribute("WalkSpeed") or 6)
    local adjustedSpeed = math.clamp(speed / baseSpeed, 0.1, 10)
    pcall(function()
        track:AdjustSpeed(adjustedSpeed)
    end)
end

local function PlayAnimation(character, animationName, stopExisting, fadeTime)
    if not ClientAnimations.IsEnabled then return end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local animationsFolder = character:FindFirstChild("Animations")
    
    if not humanoid or not animationsFolder then
        return
    end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Name == animationName then
            if stopExisting then
                pcall(function() track:Stop(fadeTime or 0.25) end)
                return
            end
            if not track.IsPlaying then
                pcall(function() track:Play() end)
            end
            AdjustAnimationSpeed(character, track)
            return
        end
    end
    
    if stopExisting then
        return
    end
    
    local animationObj = animationsFolder:FindFirstChild(animationName, true)
    if not animationObj then
        return
    end
    
    local track = humanoid:LoadAnimation(animationObj)
    track.Name = animationName
    pcall(function()
        track:Play(fadeTime or 0.25)
    end)

    if animationName == "Idle" or animationName == "HurtIdle" then
        track.Priority = Enum.AnimationPriority.Core
    elseif animationName == "Walk" or animationName == "HurtWalk" then
        track.Priority = Enum.AnimationPriority.Idle
    elseif animationName == "Sprint" or animationName == "HurtSprint" then
        track.Priority = Enum.AnimationPriority.Movement
    else
        track.Priority = Enum.AnimationPriority.Action
    end
    
    AdjustAnimationSpeed(character, track)
end

local function StepSmoke(character)
    if character:GetAttribute("Undetectable") or not character.PrimaryPart then
        return
    end
    
    local smoke = ReplicatedStorage.Assets.VFX.StepSmoke:Clone()
    smoke.Parent = workspace.GameAssets.Debris.Cleanable
    smoke.Transparency = 0.5
    Debris:AddItem(smoke, 0.75)
    
    local offset = Vector3.new(math.random(-10, 10) / 10, character.PrimaryPart.Size.Y, math.random(-10, 10) / 10)
    local pos = character.PrimaryPart.CFrame - offset
    smoke:PivotTo(pos * CFrame.Angles(math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90)), math.rad(math.random(-90, 90))))
    TweenService:Create(smoke, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
end

local function LandSmoke(character)
    if character:GetAttribute("Undetectable") or not character.PrimaryPart then
        return
    end
    
    local smoke = ReplicatedStorage.Assets.VFX.StepSmoke:Clone()
    smoke.Parent = workspace.GameAssets.Debris.Cleanable
    smoke.Transparency = 0.65
    smoke.Mesh.Scale = Vector3.new(1, 0.7, 1)
    Debris:AddItem(smoke, 0.75)
    
    local pos = character.PrimaryPart.CFrame - Vector3.new(0, 2, 0)
    local hit = CheckAir(character, Vector3.new(0, -100, 0))
    if hit then
        pos = CFrame.new(hit.Position)
    end
    
    smoke:PivotTo(pos * CFrame.Angles(0, math.rad(math.random(-90, 90)), 0))
    TweenService:Create(smoke.Mesh, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Scale = Vector3.new(2.1, 0.4, 2.1)}):Play()
    TweenService:Create(smoke, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
end

local function Trail(character, color, duration, transparency)
    local model = Instance.new("Model")
    model.Parent = workspace.GameAssets.Debris.Cleanable
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Shadow" then
            local clone = part:Clone()
            clone:ClearAllChildren()
            clone.Parent = model
            clone.Anchored = true
            clone.CanCollide = false
            clone.CanQuery = false
            clone.CanTouch = false
            clone.Transparency = (transparency or 0.6) * 1.3
            clone.Color = color or Color3.fromRGB(255, 255, 255)
            TweenService:Create(clone, TweenInfo.new(duration or 1), {Transparency = 1}):Play()
        end
    end
    
    Debris:AddItem(model, duration or 1)
end

local function PlayMovementAnims(character, hurtAnimations)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or not character:FindFirstChild("Animations") then return end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Name == "Idle" or track.Name == "HurtIdle" then
            pcall(function() track:Stop(0.25) end)
            break
        end
    end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local isHurt = health <= maxHealth / 2 and hurtAnimations
    
    if character:GetAttribute("Sprinting") then
        if not isHurt then
            PlayAnimation(character, "Sprint")
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Name == "HurtSprint" then pcall(function() track:Stop(0.25) end) end
            end
        else
            PlayAnimation(character, "HurtSprint")
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Name == "Sprint" then pcall(function() track:Stop(0.25) end) end
            end
        end

        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Name == "Walk" then pcall(function() track:Stop(0.25) end) end
            if track.Name == "HurtWalk" then pcall(function() track:Stop(0.25) end) end
        end
        return
    end

    if not isHurt then
        PlayAnimation(character, "Walk")
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Name == "HurtWalk" then pcall(function() track:Stop(0.25) end) end
        end
    else
        PlayAnimation(character, "HurtWalk")
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Name == "Walk" then pcall(function() track:Stop(0.25) end) end
        end
    end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Name == "Sprint" then pcall(function() track:Stop(0.25) end) end
        if track.Name == "HurtSprint" then pcall(function() track:Stop(0.25) end) end
    end
end

local function PlayIdleAnims(character, hurtAnimations)
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid or not character:FindFirstChild("Animations") then return end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Name == "Walk" or track.Name == "Sprint" or track.Name == "HurtWalk" or track.Name == "HurtSprint" then
            pcall(function() track:Stop(0.25) end)
        end
    end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local isHurt = health <= maxHealth / 2 and hurtAnimations
    
    if not isHurt then
        PlayAnimation(character, "Idle")
    else
        PlayAnimation(character, "HurtIdle")
    end
end

function ClientAnimations:Init(character)
    if not self.IsEnabled then return end

    if self.InitializedCharacters[character] then return end
    self.InitializedCharacters[character] = true

    local timeout = 0
    repeat
        task.wait(0.25)
        timeout = timeout + 1
    until not character or not character.Parent or (character:FindFirstChildWhichIsA("Humanoid") and character.PrimaryPart and character:FindFirstChild("Animations")) or timeout > 40
    
    if not character or not character.Parent then 
        self.InitializedCharacters[character] = nil
        return 
    end

    local player = Players:GetPlayerFromCharacter(character)
    if player and player ~= Players.LocalPlayer then 
        self.InitializedCharacters[character] = nil
        return 
    end
    
    if character:GetAttribute("Animated") then 
        self.InitializedCharacters[character] = nil
        return 
    end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local animationsFolder = character:FindFirstChild("Animations")
    
    if not humanoid or not animationsFolder then 
        self.InitializedCharacters[character] = nil
        return 
    end
    
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    character:SetAttribute("Animated", true)
    
    if not animationsFolder:FindFirstChild("Idle") then 
        self.InitializedCharacters[character] = nil
        return 
    end
    
    PlayAnimation(character, "Idle")
    
    if animationsFolder:FindFirstChild("PassiveAnimation") then
        PlayAnimation(character, "PassiveAnimation")
    end
    
    if not animationsFolder:FindFirstChild("Walk") then 
        self.InitializedCharacters[character] = nil
        return 
    end
    
    local GameAssets = workspace:WaitForChild("GameAssets")
    local Teams = GameAssets:WaitForChild("Teams")
    local connections = {}
    local isMoving = false
    local lastStepTime = tick()
    local trailTime = tick()
    local hurtAnimations = animationsFolder:FindFirstChild("HurtAnimations")
    
    local runningConnection = humanoid.Running:Connect(function(speed)
        isMoving = speed > 0.5
    end)
    table.insert(connections, runningConnection)

    if animationsFolder:FindFirstChild("Jump") then
        local stateConnection = humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
                if newState == Enum.HumanoidStateType.Jumping and character.PrimaryPart:FindFirstChild("Jump") then
                    pcall(function()
                        character.PrimaryPart.Jump:Play()
                        character.PrimaryPart.Jump.PlaybackSpeed = 1 + math.random(-100, 100) / 1000
                    end)
                end
                PlayAnimation(character, "Jump", false, 0.1)
            else
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    if track.Name == "Jump" then
                        pcall(function() track:Stop(0.05) end)
                        break
                    end
                end
                if not character:IsDescendantOf(Teams) then
                    PlayAnimation(character, "Land", false, 0)
                end
                LandSmoke(character)
            end
        end)
        table.insert(connections, stateConnection)
    end

    self.ActiveConnections[character] = connections

    local animThread = task.spawn(function()
        while character and character.Parent and character.PrimaryPart and self.IsEnabled do
            task.wait(0.04)
            
            if not character or not character.Parent or not character.PrimaryPart then break end
            if not self.IsEnabled then break end

            if character:GetAttribute("Trail") and tick() - trailTime >= 0.1 then
                local duration = character:IsDescendantOf(Teams.Other) and 0.75 or 2
                local transparency = character:IsDescendantOf(Teams.Other) and 0.85 or 0.6
                local color = character.PrimaryPart.Color
                if character:GetAttribute("KillerName") == "Badware" then
                    color = Color3.fromRGB(146, 212, 70)
                    transparency = 0.8
                end
                trailTime = tick()
                Trail(character, color, duration, transparency)
            end

            if isMoving and not character.PrimaryPart.Anchored then
                if tick() - lastStepTime >= 0.15 then
                    if character:GetAttribute("Sprinting") then
                        StepSmoke(character)
                    end
                    lastStepTime = tick()
                end
                PlayMovementAnims(character, hurtAnimations)
            else
                PlayIdleAnims(character, hurtAnimations)
            end
        end

        if self.ActiveConnections[character] then
            for _, connection in pairs(self.ActiveConnections[character]) do
                pcall(function() connection:Disconnect() end)
            end
            self.ActiveConnections[character] = nil
        end
        
        self.InitializedCharacters[character] = nil
    end)

    self.AnimationThreads[character] = animThread
end

function ClientAnimations:StopAllAnimations()
    local character = Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0.1) end)
            end
        end
    end
end

function ClientAnimations:CleanupCharacter(character)
    if self.AnimationThreads[character] then
        self.AnimationThreads[character] = nil
    end

    if self.ActiveConnections[character] then
        for _, connection in pairs(self.ActiveConnections[character]) do
            pcall(function() connection:Disconnect() end)
        end
        self.ActiveConnections[character] = nil
    end
    
    if character and character.Parent then
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
        character:SetAttribute("Animated", false)
    end
    
    self.InitializedCharacters[character] = nil
end

function ClientAnimations:Reload()
    self.IsEnabled = false
    
    self:StopAllAnimations()
    
    for character, _ in pairs(self.ActiveConnections) do
        self:CleanupCharacter(character)
    end
    
    self.InitializedCharacters = {}
    
    task.wait(0.1)
    
    self.IsEnabled = true

    if Players.LocalPlayer.Character then
        task.spawn(function()
            self:Init(Players.LocalPlayer.Character)
        end)
    end
    
    local Teams = workspace:WaitForChild("GameAssets"):WaitForChild("Teams")
    if Teams then
        for _, team in pairs(Teams:GetChildren()) do
            if team:IsA("Folder") or team:IsA("Model") then
                for _, character in pairs(team:GetChildren()) do
                    if character:FindFirstChild("Humanoid") then
                        task.spawn(function()
                            self:Init(character)
                        end)
                    end
                end
            end
        end
    end
end

getgenv().ReloadAnimations = function()
    ClientAnimations:Reload()
end

Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if ClientAnimations.IsEnabled then
        task.wait(0.5)
        ClientAnimations:Init(character)
    end
end)

Players.LocalPlayer.CharacterRemoving:Connect(function(character)
    ClientAnimations:CleanupCharacter(character)
end)

local Teams = workspace:WaitForChild("GameAssets"):WaitForChild("Teams")
if Teams then
    for _, team in pairs(Teams:GetChildren()) do
        if team:IsA("Folder") or team:IsA("Model") then
            team.ChildAdded:Connect(function(character)
                if ClientAnimations.IsEnabled then
                    task.wait(0.25)
                    ClientAnimations:Init(character)
                end
            end)
            
            team.ChildRemoved:Connect(function(character)
                ClientAnimations:CleanupCharacter(character)
            end)
            
            for _, character in pairs(team:GetChildren()) do
                if character:FindFirstChild("Humanoid") then
                    task.spawn(function()
                        ClientAnimations:Init(character)
                    end)
                end
            end
        end
    end
end

if Players.LocalPlayer.Character then
    local character = Players.LocalPlayer.Character
    
    if not character:FindFirstChild("Animations") then
        local civilian = ReplicatedStorage:FindFirstChild("Characters") and ReplicatedStorage.Characters:FindFirstChild("Survivor") and ReplicatedStorage.Characters.Survivor:FindFirstChild("Civilian")
        local defaultAnimations = civilian and civilian:FindFirstChild("Animations")
        
        if defaultAnimations then
            local existingAnimations = character:FindFirstChild("Animations")
            if existingAnimations then
                existingAnimations:Destroy()
            end
            
            local newAnimations = defaultAnimations:Clone()
            newAnimations.Parent = character
            
            if character:FindFirstChild("HumanoidRootPart") then
                character.PrimaryPart = character.HumanoidRootPart
            end
            
            character:SetAttribute("WalkSpeed", 10)
            character:SetAttribute("SprintSpeed", 26)
        end
    end

    task.spawn(function()
        local attempts = 0
        while attempts < 10 do
            if character:FindFirstChild("Animations") then
                ClientAnimations:Init(character)
                break
            end
            task.wait(0.5)
            attempts = attempts + 1
        end
    end)
end
