if NETWORK then return end

getgenv().NETWORK = {}

local FixedFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/SCRIPT/Fix.lua"))()
getgenv().fireclickdetector = FixedFunctions.fireclickdetector
getgenv().fireproximityprompt = FixedFunctions.fireproximityprompt

NETWORK.get_network = function()
    return (game:GetService("ReplicatedStorage"):FindFirstChild("_NETWORK") and game:GetService("ReplicatedStorage")._NETWORK) 
        or game:GetService("ReplicatedStorage"):FindFirstChild("CMDRGetGloveIDs", true).Parent
end

if not NETWORK.get_network():FindFirstChild("UpdatePlayerSetting") then
    game:GetService("Players").LocalPlayer:Kick("Xeno | UpdatePlayerSetting not found | Rejoin and execute this script again")
end

local UpdatePlayerSetting = false
NETWORK.get_remote = function(setting)
    local ins = NETWORK.get_network()
    local rem = (ins:FindFirstChild(setting) and ins[setting]) or ins:FindFirstChild(setting.." [STUDIO]")
    if setting == "UpdatePlayerSetting" then
        UpdatePlayerSetting = rem
    end
    return (setting == "UpdatePlayerSetting" and UpdatePlayerSetting) or rem
end

NETWORK.get_setting = function(setting, username)
    local playerData = game:GetService("ReplicatedStorage").PlayerData
    local userData = playerData:FindFirstChild(username)
    if not userData then return nil end
    local decoded = game:GetService("HttpService"):JSONDecode(userData.Settings.Settings.Value)
    return decoded[setting].Value
end

NETWORK.edit_setting = function(setting, value)
    NETWORK.get_remote("UpdatePlayerSetting"):InvokeServer(setting, value)

local function get_my_condata()
    local my_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(game.Players.LocalPlayer.Name)
    if not my_data or not my_data:FindFirstChild("Settings") or not my_data.Settings:FindFirstChild("Settings") then
        return nil
    end
    local decoded = game:GetService("HttpService"):JSONDecode(my_data.Settings.Settings.Value)
    return decoded and decoded._gloveRandomizer and decoded._gloveRandomizer.Value
end

local function set_my_condata(condata)
    NETWORK.edit_setting("_gloveRandomizer", condata)
end

function NETWORK.add_connection_queue()
    local guid = game:GetService("HttpService"):GenerateGUID(false)
    local condata = {
        user = game.Players.LocalPlayer.Name,
        connected = false,
        connection = false,
        guid = guid,
        data = ""
    }
    set_my_condata(condata)
    local partner_name = false
    local timeout = 10
    local start = tick()
    repeat
        task.wait(0.2)
        for _, v in pairs(game:GetService("ReplicatedStorage").PlayerData:GetChildren()) do
            if v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
                local decoded = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
                if decoded and decoded._gloveRandomizer and decoded._gloveRandomizer.Value 
                    and decoded._gloveRandomizer.Value.guid == guid then
                    partner_name = decoded._gloveRandomizer.Value.user
                    break
                end
            end
        end
    until partner_name or (tick() - start > timeout)
    if partner_name then
        local my_condata = get_my_condata()
        if my_condata then
            my_condata.connected = true
            my_condata.connection = partner_name
            set_my_condata(my_condata)
        end
        return true
    end
    return false
end

function NETWORK.connect_to_available()
    for _, v in pairs(game:GetService("ReplicatedStorage").PlayerData:GetChildren()) do
        if v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
            local decoded = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
            if decoded and decoded._gloveRandomizer and decoded._gloveRandomizer.Value then
                local condata = decoded._gloveRandomizer.Value
                if condata.connected == false and condata.guid then
                    local my_condata = {
                        user = game.Players.LocalPlayer.Name,
                        connected = true,
                        connection = condata.user,
                        guid = condata.guid,
                        data = ""
                    }
                    set_my_condata(my_condata)
                    return true
                end
            end
        end
    end
    return false
end

function NETWORK.send_data(data)
    local my_condata = get_my_condata()
    if my_condata then
        my_condata.data = data
        set_my_condata(my_condata)
    end
end

function NETWORK.on_data_receive(callback)
    local last_data = ""
    local my_name = game.Players.LocalPlayer.Name
    local partner_name_cache = nil
    task.spawn(function()
        while true do
            task.wait(0.2)
            if not partner_name_cache then
                local my_condata = get_my_condata()
                if my_condata and my_condata.connection then
                    partner_name_cache = my_condata.connection
                else
                    continue
                end
            end
            local partner_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(partner_name_cache)
            if not partner_data or not partner_data:FindFirstChild("Settings") or not partner_data.Settings:FindFirstChild("Settings") then
                partner_name_cache = nil
                continue
            end
            local decoded = game:GetService("HttpService"):JSONDecode(partner_data.Settings.Settings.Value)
            if not decoded or not decoded._gloveRandomizer or not decoded._gloveRandomizer.Value then
                continue
            end
            local current_data = decoded._gloveRandomizer.Value.data
            if current_data ~= last_data and current_data ~= "" then
                last_data = current_data
                callback(current_data)
            end
        end
    end)
end
