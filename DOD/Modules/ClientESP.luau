if DODESP~=nil then return end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FOLDER_NAME = "DOD_ESP_HANDLER"
local TEAM_PATHS = {
    Lobby = Workspace:WaitForChild("GameAssets"):WaitForChild("Other"):WaitForChild("LobbyPlayers", 5),
    Ghost = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Ghost", 5),
    Killer = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer", 5),
    Survivor = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor", 5)
}

local TEAM_COLORS = {
    Lobby = Color3.fromRGB(255, 255, 255),
    Ghost = Color3.fromRGB(255, 255, 255),
    Killer = Color3.fromRGB(255, 0, 0),
    Survivor = Color3.fromRGB(0, 255, 0),
    Unknown = Color3.fromRGB(128, 128, 128)
}

getgenv().DODESP = {
  ["functions"] = {};
  ["settings"] = {["Enabled"]=false;["Transparency"]=0.5;["ShowName"]=true;["ShowHealth"]=true;["ShowStamina"]=true;["BillboardSize"]=1};
}

local function safeWaitForChild(parent, name, timeout)
    timeout = timeout or 3
    local startTime = tick()
    local child = parent:FindFirstChild(name)
    while not child and tick() - startTime < timeout do
        task.wait(0.1)
        child = parent:FindFirstChild(name)
    end
    return child
end

local function GetESPFolder()
    local folder = CoreGui:FindFirstChild(FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = FOLDER_NAME
        folder.Parent = CoreGui
    end
    return folder
end

local function GetPlayerTeamColor(character)
    if not character or not character.Parent then 
        return TEAM_COLORS.Unknown 
    end
    local success, result = pcall(function()
        for teamName, teamPath in pairs(TEAM_PATHS) do
            if teamPath and character:IsDescendantOf(teamPath) then
                return TEAM_COLORS[teamName]
            end
        end
        return TEAM_COLORS.Unknown
    end)
    return success and result or TEAM_COLORS.Unknown
end

local function GetBillboardSize()
    local scale = DODESP.settings.BillboardSize or 1
    local baseSize = 100
    local size = math.max(20, baseSize * scale)
    return UDim2.new(0, size, 0, size * 0.6)
end

local function CreateESP(player)
    if not player or not player:IsA("Player") then return end
    local success, err = pcall(function()
        local espFolder = GetESPFolder()
        local folderName = "ESP_" .. player.UserId
        local existing = espFolder:FindFirstChild(folderName)
        if existing then
            local oldConnections = existing:GetAttribute("Connections")
            if oldConnections then
                for _, conn in ipairs(oldConnections) do
                    if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                        conn:Disconnect()
                    end
                end
            end
            existing:Destroy()
        end
        
        local playerFolder = Instance.new("Folder")
        playerFolder.Name = folderName
        playerFolder.Parent = espFolder
        
        local connections = {}
        local isDestroyed = false
        
        local function disconnectAll()
            for _, conn in ipairs(connections) do
                if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                    conn:Disconnect()
                end
            end
            connections = {}
        end
        
        local function cleanup()
            if isDestroyed then return end
            isDestroyed = true
            disconnectAll()
            if playerFolder and playerFolder.Parent then
                playerFolder:Destroy()
            end
        end
        local folderRemoving = playerFolder.AncestryChanged:Connect(function(_, parent)
            if not parent then
                isDestroyed = true
                disconnectAll()
            end
        end)
        table.insert(connections, folderRemoving)
        
        local function setupESPOnCharacter(character)
            if isDestroyed or not playerFolder.Parent then return end
            pcall(function()
                if playerFolder then
                    for _, child in ipairs(playerFolder:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end)
            if not character or not character.Parent then return end
            local humanoid = safeWaitForChild(character, "Humanoid", 5)
            local rootPart = safeWaitForChild(character, "HumanoidRootPart", 5)
            if not humanoid or not rootPart then 
                task.wait(0.5)
                humanoid = character:FindFirstChildOfClass("Humanoid")
                rootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoid or not rootPart then
                    warn("Failed to find Humanoid/RootPart for " .. player.Name)
                    return
                end
            end

            local highlightParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
            local highlights = {}
            
            local function getPartHighlight(partName)
                local part = character:FindFirstChild(partName)
                if not part or not part:IsA("BasePart") then return nil end
                if isDestroyed or not playerFolder.Parent then return nil end
                local highlight = Instance.new("BoxHandleAdornment")
                highlight.Name = partName
                highlight.Adornee = part
                highlight.AlwaysOnTop = true
                highlight.ZIndex = 1
                highlight.Size = part.Size
                highlight.Transparency = DODESP.settings.Transparency
                highlight.Color3 = GetPlayerTeamColor(character)
                highlight.Parent = playerFolder
                local partAncestry
                partAncestry = part.AncestryChanged:Connect(function(_, parent)
                    if not parent and highlight and highlight.Parent then
                        highlight:Destroy()
                    end
                    if partAncestry and partAncestry.Connected then
                        partAncestry:Disconnect()
                    end
                end)
                table.insert(connections, partAncestry)
                
                return highlight
            end
            for _, partName in ipairs(highlightParts) do
                local highlight = getPartHighlight(partName)
                if highlight then
                    table.insert(highlights, highlight)
                end
            end
            local head = character:FindFirstChild("Head")
            if head and not isDestroyed and playerFolder.Parent then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "NameTag"
                billboard.Adornee = head
                billboard.Size = GetBillboardSize()
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = playerFolder
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.SourceSansSemibold
                textLabel.TextSize = 14
                textLabel.Parent = billboard
                local headAncestry
                headAncestry = head.AncestryChanged:Connect(function(_, parent)
                    if not parent and billboard and billboard.Parent then
                        billboard:Destroy()
                    end
                    if headAncestry and headAncestry.Connected then
                        headAncestry:Disconnect()
                    end
                end)
                table.insert(connections, headAncestry)
                local updateConnection
                updateConnection = RunService.Heartbeat:Connect(function()
                    if isDestroyed then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    if not playerFolder.Parent then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    if not DODESP.settings.Enabled then
                        if updateConnection and updateConnection.Connected then
                            updateConnection:Disconnect()
                        end
                        return
                    end
                    pcall(function()
                        local info = {}
                        if DODESP.settings.ShowName then
                            table.insert(info, player.Name)
                        end
                        if DODESP.settings.ShowHealth and humanoid and humanoid.Parent then
                            table.insert(info, "HP: " .. math.floor(humanoid.Health))
                        elseif not humanoid or not humanoid.Parent then
                            local newHumanoid = character and character:FindFirstChildOfClass("Humanoid")
                            if newHumanoid then
                                humanoid = newHumanoid
                            end
                        end
                        if DODESP.settings.ShowStamina and character and character.Parent then
                            local stamina = character:GetAttribute("StaminaServer")
                            if stamina ~= nil then
                                table.insert(info, "SP: " .. tostring(math.floor(stamina)))
                            end
                        end
                        if textLabel and textLabel.Parent then
                            textLabel.Text = table.concat(info, "\n")
                            if billboard and billboard.Parent then
                                billboard.Size = GetBillboardSize()
                            end
                        end
                        if character and character.Parent then
                            local currentColor = GetPlayerTeamColor(character)
                            for _, highlight in ipairs(highlights) do
                                if highlight and highlight.Parent then
                                    highlight.Color3 = currentColor
                                end
                            end
                        end
                    end)
                end)
                table.insert(connections, updateConnection)
            end
        end
        if player.Character then
            setupESPOnCharacter(player.Character)
        end
        local characterAdded = player.CharacterAdded:Connect(function(character)
            if isDestroyed then return end
            task.wait(0.2)
            local attempts = 0
            local maxAttempts = 3
            while attempts < maxAttempts and not isDestroyed do
                if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
                    setupESPOnCharacter(character)
                    break
                end
                attempts = attempts + 1
                task.wait(0.5)
            end
        end)
        table.insert(connections, characterAdded)
        local characterRemoving = player.CharacterRemoving:Connect(function()
            if isDestroyed then return end
            pcall(function()
                if playerFolder then
                    for _, child in ipairs(playerFolder:GetChildren()) do
                        if child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end)
        end)
        table.insert(connections, characterRemoving)
        local playerLeaving
        playerLeaving = player.AncestryChanged:Connect(function(_, parent)
            if not parent then
                cleanup()
                if playerLeaving and playerLeaving.Connected then
                    playerLeaving:Disconnect()
                end
            end
        end)
        table.insert(connections, playerLeaving)
        playerFolder:SetAttribute("Connections", connections)
    end)
    if not success then end
end

local function RemoveESP(player)
    pcall(function()
        local espFolder = GetESPFolder()
        local playerFolder = espFolder:FindFirstChild("ESP_" .. player.UserId)
        if playerFolder then
            local connections = playerFolder:GetAttribute("Connections")
            if connections then
                for _, conn in ipairs(connections) do
                    if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                        conn:Disconnect()
                    end
                end
            end
            playerFolder:Destroy()
        end
    end)
end

local function ClearAllESP()
    pcall(function()
        local espFolder = GetESPFolder()
        for _, folder in ipairs(espFolder:GetChildren()) do
            if folder:IsA("Folder") then
                local connections = folder:GetAttribute("Connections")
                if connections then
                    for _, conn in ipairs(connections) do
                        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
                            conn:Disconnect()
                        end
                    end
                end
                folder:Destroy()
            end
        end
    end)
end

local mainConnections = {}

local function EnableESP()
    DODESP.settings.Enabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            task.spawn(function()
                CreateESP(player)
            end)
        end
    end
    mainConnections.playerAdded = Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            task.spawn(function()
                task.wait(0.5)
                CreateESP(player)
            end)
        end
    end)
    mainConnections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        RemoveESP(player)
    end)
    mainConnections.folderMonitor = GetESPFolder().AncestryChanged:Connect(function(_, parent)
        if not parent and DODESP.settings.Enabled then
            task.wait(0.1)
            local newFolder = Instance.new("Folder")
            newFolder.Name = FOLDER_NAME
            newFolder.Parent = CoreGui
            mainConnections.folderMonitor = newFolder.AncestryChanged:Connect(function(_, p)
                if not p and DODESP.settings.Enabled then
                    EnableESP()
                end
            end)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    task.spawn(function()
                        CreateESP(player)
                    end)
                end
            end
        end
    end)
end

local function DisableESP()
    DODESP.settings.Enabled = false
    for _, conn in pairs(mainConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    mainConnections = {}
    ClearAllESP()
end

local path = DODESP.functions

function path.Toggle(enabled)
    if enabled then
        EnableESP()
    else
        DisableESP()
    end
end

function path.SetTransparency(value)
    DODESP.settings.Transparency = math.clamp(value, 0, 1)
    pcall(function()
        local espFolder = GetESPFolder()
        for _, folder in ipairs(espFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, adornment in ipairs(folder:GetChildren()) do
                    if adornment:IsA("BoxHandleAdornment") then
                        adornment.Transparency = DODESP.settings.Transparency
                    end
                end
            end
        end
    end)
end

function path.SetBillboardSize(scale)
    scale = math.max(0.2, scale or 1)
    DODESP.settings.BillboardSize = scale
end
