local flags = require(game:GetService("ReplicatedStorage").BACKEND.Shared.Flags.FlagService)
local original = flags.IsEnabled

flags.IsEnabled = function(flag, ...)
    if flag == "IgnoreSafety" then
        return true
    end
    return original(flag, ...)
end

if NETWORK then return end

getgenv().NETWORK = {}
local receive_connection = nil

NETWORK.get_network = function()
    return (game:GetService("ReplicatedStorage"):FindFirstChild("_NETWORK") and game:GetService("ReplicatedStorage")._NETWORK) or game:GetService("ReplicatedStorage"):FindFirstChild("CMDRGetGloveIDs",true).Parent
end

NETWORK.get_remote = function(setting)
    local ins = NETWORK.get_network()
    return (ins:FindFirstChild(setting) and ins[setting]) or ins:FindFirstChild(setting.." [STUDIO]")
end

NETWORK.get_setting = function(setting, username)
    if game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(username) == nil then
        return nil
    end
    local decodedval = game:GetService("HttpService"):JSONDecode(game:GetService("ReplicatedStorage").PlayerData[username].Settings.Settings.Value)
    return decodedval[setting].Value
end

NETWORK.edit_setting = function(setting, value)
    local ins = NETWORK.get_remote("UpdatePlayerSetting")
    ins:InvokeServer(setting, value)
end

NETWORK.add_connection_queue = function()
    if receive_connection then
        receive_connection = false
    end
    local guid = game:GetService("HttpService"):GenerateGUID(false)
    local condata = {
        ['user'] = game:GetService("Players").LocalPlayer.Name,
        ['connected'] = false,
        ['connection'] = false,
        ['guid'] = guid,
        ['data'] = ''
    }
    NETWORK.edit_setting("_gloveRandomizer", condata)
    local plrname = false
    repeat task.wait(.05)
    for i, v in next, game:GetService("ReplicatedStorage").PlayerData:GetChildren() do
        if v and v.Name~=game:GetService("Players").LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
            local decodedval = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
            if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value and decodedval._gloveRandomizer.Value.guid == guid then
                local new_condata = table.clone(condata)
                new_condata.connected = true
                new_condata.guid = guid
                new_condata.connection = decodedval._gloveRandomizer.Value.user
                NETWORK.edit_setting("_gloveRandomizer", new_condata)
                plrname = decodedval._gloveRandomizer.Value.user
            end
        end
    end
    until plrname~=false
    return true
end

NETWORK.connect_to_available = function()
    if receive_connection then
        receive_connection = false
    end
    for i, v in next, game:GetService("ReplicatedStorage").PlayerData:GetChildren() do
        if v and v.Name~=game:GetService("Players").LocalPlayer.Name and v:FindFirstChild("Settings") and v.Settings:FindFirstChild("Settings") then
            local decodedval = game:GetService("HttpService"):JSONDecode(v.Settings.Settings.Value)
            if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value and decodedval._gloveRandomizer.Value.connected == false then
                local condata = {
                    ['user'] = game:GetService("Players").LocalPlayer.Name,
                    ['connected'] = true,
                    ['connection'] = decodedval._gloveRandomizer.Value.user,
                    ['guid'] = decodedval._gloveRandomizer.Value.guid,
                    ['data'] = ''
                }
                NETWORK.edit_setting("_gloveRandomizer", condata)
                return true
            end
        end
    end
    return false
end

NETWORK.send_data = function(data)
    local my_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(game:GetService("Players").LocalPlayer.Name)
    if my_data and my_data:FindFirstChild("Settings") and my_data.Settings:FindFirstChild("Settings") then
        local decodedval = game:GetService("HttpService"):JSONDecode(my_data.Settings.Settings.Value)
        if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value then
            local condata = decodedval._gloveRandomizer.Value
            condata.data = data
            NETWORK.edit_setting("_gloveRandomizer", condata)
        end
    end
end

NETWORK.on_data_receive = function(callback)
    receive_connection = true
    task.spawn(function()
        local last_data = ""
        local my_name = game:GetService("Players").LocalPlayer.Name
        while receive_connection do
            task.wait(0.1)
            local my_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(my_name)
            if my_data and my_data:FindFirstChild("Settings") and my_data.Settings:FindFirstChild("Settings") then
                local decodedval = game:GetService("HttpService"):JSONDecode(my_data.Settings.Settings.Value)
                if decodedval._gloveRandomizer and decodedval._gloveRandomizer.Value then
                    local partner = decodedval._gloveRandomizer.Value.connection
                    if partner then
                        local partner_data = game:GetService("ReplicatedStorage").PlayerData:FindFirstChild(partner)
                        if partner_data and partner_data:FindFirstChild("Settings") and partner_data.Settings:FindFirstChild("Settings") then
                            local partner_decoded = game:GetService("HttpService"):JSONDecode(partner_data.Settings.Settings.Value)
                            if partner_decoded._gloveRandomizer and partner_decoded._gloveRandomizer.Value then
                                local current_data = partner_decoded._gloveRandomizer.Value.data
                                if current_data ~= last_data and current_data ~= "" then
                                    last_data = current_data
                                    callback(current_data)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
