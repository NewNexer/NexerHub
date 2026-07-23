local module = {}

--[[
Table Things
]]--
local SpecialCharacters = {['\a'] = '\\a', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t', ['\v'] = '\\v', ['\0'] = '\\0'}
local Keywords = { ['and'] = true, ['break'] = true, ['do'] = true, ['else'] = true, ['elseif'] = true, ['end'] = true, ['false'] = true, ['for'] = true, ['function'] = true, ['if'] = true, ['in'] = true, ['local'] = true, ['nil'] = true, ['not'] = true, ['or'] = true, ['repeat'] = true, ['return'] = true, ['then'] = true, ['true'] = true, ['until'] = true, ['while'] = true, ['continue'] = true}
local Functions = {
    [pairs] = "pairs",
    [ipairs] = "ipairs", 
    [next] = "next",
    [type] = "type",
    [tostring] = "tostring",
    [tonumber] = "tonumber",
    [print] = "print",
    [error] = "error",
    [assert] = "assert",
    [pcall] = "pcall",
    [xpcall] = "xpcall",
    [select] = "select",
    [rawget] = "rawget",
    [rawset] = "rawset",
    [rawequal] = "rawequal",
    [getmetatable] = "getmetatable",
    [setmetatable] = "setmetatable",
    [require] = "require",
}
if loadstring then Functions[loadstring] = "loadstring" end
if load then Functions[load] = "load" end
local function safeTypeof(value)
    if typeof then
        return typeof(value)
    else
        return type(value)
    end
end
function GetHierarchy(Object)
    if not Object or (type(Object) ~= "table" and safeTypeof(Object) ~= "Instance") then
        return tostring(Object)
    end
    local Hierarchy = {}
    local current = Object
    while current do
        local name = tostring(current.Name or current.name or "Unknown")
        name = string.gsub(name, '[%c%z]', SpecialCharacters)
        if current == game or current == _G.game then
            table.insert(Hierarchy, 1, "game")
        elseif Keywords[name] or not string.match(name, '^[_%a][_%w]*$') then
            table.insert(Hierarchy, 1, '["' .. name .. '"]')
        else
            table.insert(Hierarchy, 1, name)
        end
        current = current.Parent
    end
    
    return table.concat(Hierarchy, ".")
end
local function SerializeType(Value, Class)
    if Class == 'string' then
        return string.format('"%s"', string.gsub(Value, '[%c%z]', SpecialCharacters))
    elseif Class == 'Instance' then
        return GetHierarchy(Value)
    elseif Class == 'function' then
        return Functions[Value] or "'[Function: " .. tostring(Value) .. "]'"
    elseif Class == 'userdata' then
        return "'[userdata: " .. tostring(Value) .. "]'"
    elseif Class == 'thread' then
        if coroutine and coroutine.status then
            local status = pcall(function() return coroutine.status(Value) end)
            return "'[thread: " .. tostring(Value) .. (status and ", status: " .. coroutine.status(Value) or "") .. "]'"
        else
            return "'[thread: " .. tostring(Value) .. "]'"
        end
    else
        return tostring(Value)
    end
end
function TableToLuauString(Table, IgnoredTables, DepthData, Path)
    if type(Table) ~= "table" then
        return SerializeType(Table, safeTypeof(Table))
    end
    IgnoredTables = IgnoredTables or {}
    Path = Path or "ROOT"
    if not DepthData then
        DepthData = {0, Path}
    end
    local CyclicData = IgnoredTables[Table]
    if CyclicData then
        local currentDepth = DepthData[1] or 0
        local cyclicDepth = CyclicData[1] or 0
        return ((cyclicDepth == currentDepth - 1 and "'[Cyclic Parent " or "'[Cyclic ") .. tostring(Table) .. ', path: ' .. (CyclicData[2] or "unknown") .. "]'")
    end
    DepthData[1] = (DepthData[1] or 0) + 1
    DepthData[2] = Path
    IgnoredTables[Table] = {DepthData[1], DepthData[2]}
    local currentDepth = DepthData[1] or 1
    local Tab = string.rep('    ', currentDepth)
    local TrailingTab = string.rep('    ', currentDepth - 1)
    local Result = '{'
    local LineTab = '\n' .. Tab
    local HasOrder = true
    local Index = 1
    local IsEmpty = true
    for Key, Value in pairs(Table) do
        IsEmpty = false
        if Index ~= Key then
            HasOrder = false
        else
            Index = Index + 1
        end
        local KeyClass = safeTypeof(Key)
        local ValueClass = safeTypeof(Value)
        local HasBrackets = false
        local KeyStr
        if KeyClass == 'string' then
            local cleanKey = string.gsub(Key, '[%c%z]', SpecialCharacters)
            if Keywords[cleanKey] or not string.match(cleanKey, '^[_%a][_%w]*$') then
                HasBrackets = true
                KeyStr = string.format('["%s"]', cleanKey)
            else
                KeyStr = cleanKey
            end
        else
            HasBrackets = true
            if KeyClass == 'table' then
                KeyStr = '[' .. TableToLuauString(Key, IgnoredTables, {currentDepth + 1, Path}) .. ']'
            else
                KeyStr = '[' .. SerializeType(Key, KeyClass) .. ']'
            end
        end
        local ValueStr
        if ValueClass == 'table' then
            local newPath = Path .. (HasBrackets and '' or '.') .. KeyStr
            ValueStr = TableToLuauString(Value, IgnoredTables, {currentDepth + 1, Path}, newPath)
        else
            ValueStr = SerializeType(Value, ValueClass)
        end
        Result = Result .. LineTab .. (HasOrder and ValueStr or KeyStr .. ' = ' .. ValueStr) .. ','
    end
    local donetable = IsEmpty and Result .. '}' or string.sub(Result, 1, -2) .. '\n' .. TrailingTab .. '}'
    IgnoredTables[Table] = nil
    return donetable
end

local LocalPlayer, LP = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer
local Character, Char = nil, nil
local HumanoidRootPart, HRP = nil, nil
local Humanoid, Hum = nil, nil
pcall(function()
Character, Char = LocalPlayer.Character, LocalPlayer.Character
end)
pcall(function()
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
end)
pcall(function()
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)
LocalPlayer.CharacterAdded:Connect(function(char)
pcall(function()
Character, Char = nil, nil
HumanoidRootPart, HRP = nil, nil
Humanoid, Hum = nil, nil
task.wait()
Character, Char = char, char
repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
HumanoidRootPart, HRP = char.HumanoidRootPart, char.HumanoidRootPart
repeat task.wait() until Character:FindFirstChild("Humanoid")
Humanoid, Hum = char.Humanoid, char.Humanoid
end)
end)

function module.IsWorking()
return (module~=nil)
end

function module:ConvertToTable(a)
local b = TableToLuauString(a)
task.wait(0)
return "return "..b
end

function module:RequestModule(module)
if (string.find(identifyexecutor(), "Xeno") or string.find(identifyexecutor(), "xeno") or string.find(identifyexecutor(), "XENO")) or (string.find(identifyexecutor(), "Solara") or string.find(identifyexecutor(), "solara") or string.find(identifyexecutor(), "SOLARA")) then return nil end
local result = nil
local Success, Error = pcall(function()
result = require(module)
end)
if Success then
return result
elseif not Success then
return nil
end
end

function module:GetAssetPrice(assetid)
local Id = tonumber(assetid)
local MarketplaceService = game:GetService("MarketplaceService")
return (MarketplaceService:GetProductInfo(Id,Enum.InfoType.Asset).PriceInRobux)
end

function module:GetWorkingRayfield()
--[[

	Rayfield Interface Suite
	by Sirius

	shlex  | Designing + Programming
	iRay   | Programming
	Max    | Programming
	Damian | Programming

]]

if debugX then
	warn('Initialising Rayfield')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url) -- game:HttpGet(url)
		-- If the request fails the content can be empty, even if fetchSuccess is true
		if not fetchSuccess or #fetchResult == 0 then
			if #fetchResult == 0 then
				fetchResult = "Empty response" -- Set the error message
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult -- Fetched content
		local execSuccess, execResult = pcall(function()
			return loadstring(content)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn(`Request for {url} timed out after {timeout} seconds`)
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	-- Wait for completion or timeout
	while not requestCompleted do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn(`Failed to process {url}: {result}`)
	end
	return if success then result else nil
end

local requestsDisabled = true --getgenv and getgenv().DISABLE_RAYFIELD_REQUESTS
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		-- if needs be in order just make getSetting(name)
		rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
		-- buildwarnings
		-- rayfieldprompts

	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file, and are cleared if the user changes the setting in the UI
local overriddenSettings: { [string]: any } = {} -- For example, overriddenSettings["System.rayfieldOpen"] = "J"
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[`{category}.{name}`] ~= nil then
		return overriddenSettings[`{category}.{name}`]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')
local TextService = getService('TextService')

-- Environment Check
local useStudio = RunService:IsStudio() or false

local settingsCreated = false
local settingsInitialized = false -- Whether the UI elements in the settings page have been set to the proper values
local cachedSettings
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

-- Validate prompt loaded correctly
if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt = {
		create = function() end -- No-op fallback
	}
end



local function loadSettings()
	local file = nil

	local success, result =	pcall(function()
		task.spawn(function()
			if isfolder and isfolder(RayfieldFolder) then
				if isfile and isfile(RayfieldFolder..'/settings'..ConfigurationExtension) then
					file = readfile(RayfieldFolder..'/settings'..ConfigurationExtension)
				end
			end

			-- for debug in studio
			if useStudio then
				file = [[
		{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
	]]
			end


			if file then
				local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
				if success then
					file = decodedFile
				else
					file = {}
				end
			else
				file = {}
			end


			if not settingsCreated then 
				cachedSettings = file
				return
			end

			if file ~= {} then
				for categoryName, settingCategory in pairs(settingsTable) do
					if file[categoryName] then
						for settingName, setting in pairs(settingCategory) do
							if file[categoryName][settingName] then
								setting.Value = file[categoryName][settingName].Value
								setting.Element:Set(getSetting(categoryName, settingName))
							end
						end
					end
				end
			end
			settingsInitialized = true
		end)
	end)

	if not success then 
		if writefile then
			warn('Rayfield had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local analyticsLib
local sendReport = function(ev_n, sc_n) warn("Failed to load report function") end
if not requestsDisabled then
	if debugX then
		warn('Querying Settings for Reporter Information')
	end	
	analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
	if not analyticsLib then
		warn("Failed to load analytics reporter")
		analyticsLib = nil
	elseif analyticsLib and type(analyticsLib.load) == "function" then
		analyticsLib:load()
	else
		warn("Analytics library loaded but missing load function")
		analyticsLib = nil
	end
	sendReport = function(ev_n, sc_n)
		if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
			warn("Analytics library not loaded")
			return
		end
		if useStudio then
			print('Sending Analytics')
		else
			if debugX then warn('Reporting Analytics') end
			analyticsLib:report(
				{
					["name"] = ev_n,
					["script"] = {["name"] = sc_n, ["version"] = Release}
				},
				{
					["version"] = InterfaceBuild
				}
			)
			if debugX then warn('Finished Report') end
		end
	end
	if cachedSettings and (#cachedSettings == 0 or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
		sendReport("execution", "Rayfield")
	elseif not cachedSettings then
		sendReport("execution", "Rayfield")
	end
end

local promptUser = 2

if promptUser == 1 and prompt and type(prompt.create) == "function" then
	prompt.create(
		'Be cautious when running scripts',
	    [[Please be careful when running scripts from unknown developers. This script has already been ran.

<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
		'Okay',
		'',
		function()

		end
	)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local RayfieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},

		Ocean = {
			TextColor = Color3.fromRGB(230, 240, 240),

			Background = Color3.fromRGB(20, 30, 30),
			Topbar = Color3.fromRGB(25, 40, 40),
			Shadow = Color3.fromRGB(15, 20, 20),

			NotificationBackground = Color3.fromRGB(25, 35, 35),
			NotificationActionsBackground = Color3.fromRGB(230, 240, 240),

			TabBackground = Color3.fromRGB(40, 60, 60),
			TabStroke = Color3.fromRGB(50, 70, 70),
			TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
			TabTextColor = Color3.fromRGB(210, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(20, 50, 50),

			ElementBackground = Color3.fromRGB(30, 50, 50),
			ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
			ElementStroke = Color3.fromRGB(45, 70, 70),
			SecondaryElementStroke = Color3.fromRGB(40, 65, 65),

			SliderBackground = Color3.fromRGB(0, 110, 110),
			SliderProgress = Color3.fromRGB(0, 140, 140),
			SliderStroke = Color3.fromRGB(0, 160, 160),

			ToggleBackground = Color3.fromRGB(30, 50, 50),
			ToggleEnabled = Color3.fromRGB(0, 130, 130),
			ToggleDisabled = Color3.fromRGB(70, 90, 90),
			ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
			ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
			ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),

			DropdownSelected = Color3.fromRGB(30, 60, 60),
			DropdownUnselected = Color3.fromRGB(25, 40, 40),

			InputBackground = Color3.fromRGB(30, 50, 50),
			InputStroke = Color3.fromRGB(50, 70, 70),
			PlaceholderColor = Color3.fromRGB(140, 160, 160)
		},

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200), 
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235), 
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240), 
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45), 
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), 
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60), 
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
	}
}


-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Interface Management

local Rayfield = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false -- True when RayfieldLibrary:Destroy() is called

repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	toDestroy, Rayfield = Rayfield, useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
	if toDestroy and not useStudio then toDestroy:Destroy() end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
end


local minSize = Vector2.new(1024, 768)
local useMobileSizing

if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

if UserInputService.TouchEnabled then
	useMobilePrompt = true
end


-- Object Variables

local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- Thanks to Latte Softworks for the Lucide integration for Roblox
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')
-- Variables

local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications

local SelectedTheme = RayfieldLibrary.Theme.Default

	local SIDEBAR_MIN_WIDTH = 132
	local SIDEBAR_MAX_WIDTH = 150
	local TOPBAR_HEIGHT = 45
	local TAB_BUTTON_HEIGHT = 30
	local TAB_SECTION_HEIGHT = 18
	local TAB_SECTION_TEXT_SIZE = 11
	local TABLIST_HORIZONTAL_PADDING = 8
	local TABLIST_VERTICAL_PADDING = 8
	local TabListCanvasConnection
	local TabListOrderCounter = 0
	local CurrentTabSectionName = nil

	local function getSidebarWidth()
		local absoluteWidth = Main and Main.AbsoluteSize and Main.AbsoluteSize.X or 0
		if absoluteWidth <= 0 then
			return 140
		end

		return math.clamp(math.floor(absoluteWidth * 0.22), SIDEBAR_MIN_WIDTH, SIDEBAR_MAX_WIDTH)
	end

	local function updateTabListCanvas()
		pcall(function()
			if not TabList or not TabList:IsA('ScrollingFrame') then
				return
			end

			local tabLayout = TabList:FindFirstChildWhichIsA('UIListLayout')
			local contentHeight = 0
			if tabLayout then
				contentHeight = tabLayout.AbsoluteContentSize.Y
			end

			TabList.CanvasSize = UDim2.new(0, 0, 0, contentHeight + TABLIST_VERTICAL_PADDING)
		end)
	end

	local function styleTabSection(tabSection)
		if not tabSection or not tabSection:IsA('TextLabel') then
			return
		end

		tabSection.BackgroundTransparency = 1
		tabSection.BorderSizePixel = 0
		tabSection.TextXAlignment = Enum.TextXAlignment.Left
		tabSection.TextYAlignment = Enum.TextYAlignment.Bottom
		tabSection.Font = Enum.Font.GothamSemibold
		tabSection.TextSize = TAB_SECTION_TEXT_SIZE
		tabSection.TextTransparency = 0.38
		tabSection.TextColor3 = SelectedTheme.TextColor
		tabSection.RichText = false
		tabSection.ZIndex = 4
	end

	local function applySidebarLayout()
		pcall(function()
			local sidebarWidth = getSidebarWidth()
			Main.ClipsDescendants = true
			TabList.ClipsDescendants = true
			Elements.ClipsDescendants = true

			TabList.AnchorPoint = Vector2.new(0, 0)
			TabList.Position = UDim2.new(0, 8, 0, TOPBAR_HEIGHT + 8)
			TabList.Size = UDim2.new(0, sidebarWidth, 1, -(TOPBAR_HEIGHT + 16))
			TabList.BackgroundTransparency = 1

			if TabList:IsA('ScrollingFrame') then
				TabList.Active = true
				TabList.ScrollingDirection = Enum.ScrollingDirection.Y
				TabList.ScrollingEnabled = true
				TabList.AutomaticCanvasSize = Enum.AutomaticSize.None
				TabList.ScrollBarThickness = 4
				TabList.CanvasPosition = Vector2.new(TabList.CanvasPosition.X, TabList.CanvasPosition.Y)
			end

			local tabLayout = TabList:FindFirstChildWhichIsA('UIListLayout')
			if tabLayout then
				tabLayout.FillDirection = Enum.FillDirection.Vertical
				tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top
				tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
				tabLayout.Padding = UDim.new(0, 5)

				if not TabListCanvasConnection and TabList:IsA('ScrollingFrame') then
					TabListCanvasConnection = tabLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateTabListCanvas)
				end
			end

			Elements.AnchorPoint = Vector2.new(0, 0)
			Elements.Position = UDim2.new(0, sidebarWidth + 16, 0, TOPBAR_HEIGHT + 8)
			Elements.Size = UDim2.new(1, -(sidebarWidth + 24), 1, -(TOPBAR_HEIGHT + 16))
			Elements.ClipsDescendants = true

			for _, page in ipairs(Elements:GetChildren()) do
				if page:IsA('ScrollingFrame') or page:IsA('Frame') then
					page.Size = UDim2.new(1, 0, 1, 0)
					page.Position = UDim2.new(0, 0, 0, 0)
					page.ClipsDescendants = true
				end
			end

			for _, tabButton in ipairs(TabList:GetChildren()) do
				if tabButton:IsA('Frame') and tabButton.Name ~= 'Placeholder' then
					tabButton.Size = UDim2.new(1, -TABLIST_HORIZONTAL_PADDING, 0, TAB_BUTTON_HEIGHT)
				elseif tabButton:IsA('TextLabel') and tabButton:GetAttribute('RayfieldTabSection') then
					tabButton.Size = UDim2.new(1, -(TABLIST_HORIZONTAL_PADDING + 2), 0, TAB_SECTION_HEIGHT)
					styleTabSection(tabButton)
				end
			end

			if Main:FindFirstChild('Search') then
				Main.Search.Position = UDim2.new(0, sidebarWidth + 26, 0, TOPBAR_HEIGHT + 12)
				Main.Search.Size = UDim2.new(1, -(sidebarWidth + 42), 0, 32)
			end

			updateTabListCanvas()
		end)
	end

	Main:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
		applySidebarLayout()
	end)

local function ChangeTheme(Theme)
	if typeof(Theme) == 'string' then
		SelectedTheme = RayfieldLibrary.Theme[Theme]
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

	Rayfield.Main.BackgroundColor3 = SelectedTheme.Background
	Rayfield.Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow

	Rayfield.Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Rayfield.Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
		Rayfield.Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	end

	Main.Search.BackgroundColor3 = SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
	Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke

	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3 = SelectedTheme.Background
	end

	for _, text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent ~= Notifications then
			if text:IsA('TextLabel') or text:IsA('TextBox') then text.TextColor3 = SelectedTheme.TextColor end
		end
	end

	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element.ClassName == "Frame" and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and Element.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				Element.UIStroke.Color = SelectedTheme.ElementStroke
			end
		end
	end

	for _, tabGui in ipairs(TabList:GetChildren()) do
		if tabGui:IsA('TextLabel') and tabGui:GetAttribute('RayfieldTabSection') then
			styleTabSection(tabGui)
		end
	end
end

local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error(`Lucide Icons: Failed to find icon by the name of "{name}"`, 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end
-- Converts ID to asset URI. Returns rbxassetid://0 if ID is not a number
local function getAssetUri(id: any): string
	local assetUri = "rbxassetid://0" -- Default to empty image
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true

			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false

			connectFunctions()

			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
				TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end


local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed

	if not success then warn('Rayfield had an issue decoding the configuration file, please try delete the file and reopen Rayfield.') return end

	-- Iterate through current UI elements' flags
	for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
		local FlagValue = Data[FlagName]

		if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
			task.spawn(function()
				if Flag.Type == "ColorPicker" then
					changed = true
					Flag:Set(UnpackColor(FlagValue))
				else
					if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then 
						changed = true
						Flag:Set(FlagValue) 	
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '"..FlagName.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
			--RayfieldLibrary:Notify({Title = "Rayfield Flags", Content = "Rayfield was unable to find '"..FlagName.. "' in the save file. Check sirius.menu/discord for help.", Image = 3944688398})
		end
	end

	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	if debugX then
		print('Saving')
	end

	local Data = {}
	for i, v in pairs(RayfieldLibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			if typeof(v.CurrentValue) == 'boolean' then
				if v.CurrentValue == false then
					Data[i] = false
				else
					Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
				end
			else
				Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
			end
		end
	end

	if useStudio then
		if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = script.Parent
		ScreenGui.Name = 'configuration'

		local TextBox = Instance.new("TextBox")
		TextBox.Parent = ScreenGui
		TextBox.Size = UDim2.new(0, 800, 0, 50)
		TextBox.AnchorPoint = Vector2.new(0.5, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0, 30)
		TextBox.Text = HttpService:JSONEncode(Data)
		TextBox.ClearTextOnFocus = false
	end

	if debugX then
		warn(HttpService:JSONEncode(Data))
	end

	if writefile then
		writefile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
	end
end

function RayfieldLibrary:Notify(data) -- action e.g open messages
	task.spawn(function()

		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		-- Set Data
		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			if typeof(data.Image) == 'string' and Icons then
				local asset = getIcon(data.Image)

				newNotification.Icon.Image = 'rbxassetid://'..asset.id
				newNotification.Icon.ImageRectOffset = asset.imageRectOffset
				newNotification.Icon.ImageRectSize = asset.imageRectSize
			else
				newNotification.Icon.Image = getAssetUri(data.Image)
			end
		else
			newNotification.Icon.Image = "rbxassetid://" .. 0
		end

		-- Set initial transparency values

		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.Background
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Size = UDim2.new(1, 0, 0, 800)
		newNotification.Icon.ImageTransparency = 1
		newNotification.Icon.BackgroundTransparency = 1

		task.wait()

		newNotification.Visible = true

		if data.Actions then
			warn('Rayfield | Not seeing your actions in notifications?')
			print("Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
		end

		-- Calculate textbounds and set initial values
		local bounds = {newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y}
		newNotification.Size = UDim2.new(1, -60, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)

		newNotification.Icon.Size = UDim2.new(0, 32, 0, 32)
		newNotification.Icon.Position = UDim2.new(0, 20, 0.5, 0)

		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, math.max(bounds[1] + bounds[2] + 31, 60))}):Play()

		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

		task.wait(0.05)

		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()

		task.wait(0.05)
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()

		local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
		task.wait(data.Duration or waitDuration)

		newNotification.Icon.Visible = false
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()

		task.wait(1)

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)}):Play()

		newNotification.Visible = false
		newNotification:Destroy()
	end)
end

function RayfieldLibrary:Notification(title, content, time, mode)
local ttime = time or 4
local mmode = mode or warn
local iimg = 0
if mmode == true then
iimg = 136186846844342
elseif mmode == false then
iimg = 71508738660632
elseif mmode == warn then
iimg = 9441432403
end
RayfieldLibrary:Notify({
	Title = title,
	Content = content,
	Duration = ttime,
	Image = iimg,
	Actions = {},
})
end

local function openSearch()
	searchOpen = true

	Main.Search.BackgroundTransparency = 1
	Main.Search.Shadow.ImageTransparency = 1
	Main.Search.Input.TextTransparency = 1
	Main.Search.Search.ImageTransparency = 1
	Main.Search.UIStroke.Transparency = 1
	Main.Search.Size = UDim2.new(1, 0, 0, 80)
	Main.Search.Position = UDim2.new(0.5, 0, 0, 70)

	Main.Search.Input.Interactable = true

	Main.Search.Visible = true

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = false
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	Main.Search.Input:CaptureFocus()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 0.95}):Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9}):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -35, 0, 35)}):Play()
end

local function closeSearch()
	searchOpen = false

	TweenService:Create(Main.Search, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30)}):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = true
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end

	Main.Search.Input.Text = ''
	Main.Search.Input.Interactable = false
end

local function Hide(notify: boolean?)
	if MPrompt then
		MPrompt.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		MPrompt.Position = UDim2.new(0.5, 0, 0, -50)
		MPrompt.Size = UDim2.new(0, 40, 0, 10)
		MPrompt.BackgroundTransparency = 1
		MPrompt.Title.TextTransparency = 1
		MPrompt.Visible = true
	end

	task.spawn(closeSearch)

	Debounce = true
	if notify then
		if useMobilePrompt then 
			RayfieldLibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping 'Show'.", Duration = 7, Image = 4400697855})
		else
			RayfieldLibrary:Notify({Title = "Interface Hidden", Content = `The interface has been hidden, you can unhide the interface by tapping {getSetting("General", "rayfieldOpen")}.`, Duration = 7, Image = 4400697855})
		end
	end

	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 0)}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 45)}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

	if useMobilePrompt and MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3}):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
	end

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			TweenService:Create(TopbarButton, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		end
	end

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	dragInteract.Visible = false

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
						else
local stroke = element:FindFirstChild("UIStroke")
if stroke then
	TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
		Transparency = 1
	}):Play()
end

local title = element:FindFirstChild("Title")
if title then
	TweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
		TextTransparency = 1
	}):Play()
end

TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
	BackgroundTransparency = 1
}):Play()
						end
for _, child in ipairs(element:GetDescendants()) do
	if child:IsA("GuiObject") then
		child.Visible = false
	end
end
					end
				end
			end
		end
	end

	task.wait(0.5)
	Main.Visible = false
	Debounce = false
end

local function Maximise()
	Debounce = true
	Topbar.ChangeSize.Image = "rbxassetid://"..10137941941

	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 570, 0, 275) or UDim2.new(0, 570, 0, 475)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 570, 0, 45)}):Play()
	TabList.Visible = true
	task.wait(0.2)

	Elements.Visible = true

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
						else
							TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
							TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = false
							end
						end
					end
				end
			end
		end
	end

	task.wait(0.1)

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end

		end
	end

	task.wait(0.5)
	Debounce = false
end


local function Unhide()
	Debounce = true
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Visible = true
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 570, 0, 275) or UDim2.new(0, 570, 0, 475)}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 570, 0, 45)}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

	if MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.spawn(function()
			task.wait(0.5)
			MPrompt.Visible = false
		end)
	end

	if Minimised then
		task.spawn(Maximise)
	end

	dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset)

	dragInteract.Visible = true

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			if TopbarButton.Name == 'Icon' then
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			else
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
			end

		end
	end

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()
						else
TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
	BackgroundTransparency = 0
}):Play()

local stroke = element:FindFirstChild("UIStroke")
if stroke then
	TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
		Transparency = 0
	}):Play()
end

local title = element:FindFirstChild("Title")
if title then
	TweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
		TextTransparency = 0
	}):Play()
end
						end
for _, child in ipairs(element:GetDescendants()) do
	if child:IsA("GuiObject") then
		child.Visible = true
	end
end
					end
				end
			end
		end
	end

	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()

	task.wait(0.5)
	Minimised = false
	Debounce = false
end

local function Minimise()
	Debounce = true
	Topbar.ChangeSize.Image = "rbxassetid://"..11036884234

	Topbar.UIStroke.Color = SelectedTheme.ElementStroke

	task.spawn(closeSearch)

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
						else
							TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = false
							end
						end
					end
				end
			end
		end
	end

	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()

	task.wait(0.3)

	Elements.Visible = false
	TabList.Visible = false

	task.wait(0.2)
	Debounce = false
end

local function saveSettings() -- Save settings to config file
	local encoded
	local success, err = pcall(function()
		encoded = HttpService:JSONEncode(settingsTable)
	end)

	if success then
		if useStudio then
			if script.Parent['get.val'] then
				script.Parent['get.val'].Value = encoded
			end
		end
		if writefile then
			writefile(RayfieldFolder..'/settings'..ConfigurationExtension, encoded)
		end
	end
end

local function updateSetting(category: string, setting: string, value: any)
	if not settingsInitialized then
		return
	end
	settingsTable[category][setting].Value = value
	overriddenSettings[`{category}.{setting}`] = nil -- If user changes an overriden setting, remove the override
	saveSettings()
end

local function createSettings(window)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
		if Topbar['Settings'] then Topbar.Settings.Visible = false end
		Topbar['Search'].Position = UDim2.new(1, -75, 0.5, 0)
		warn('Can\'t create settings as no file-saving functionality is available.')
		return
	end

	local newTab = window:CreateTab('Rayfield Settings', 0, true)

	if TabList['Rayfield Settings'] then
		TabList['Rayfield Settings'].LayoutOrder = 1000
	end

	if Elements['Rayfield Settings'] then
		Elements['Rayfield Settings'].LayoutOrder = 1000
	end

	-- Create sections and elements
	for categoryName, settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)

		for settingName, setting in pairs(settingCategory) do
			if setting.Type == 'input' then
				setting.Element = newTab:CreateInput({
					Name = setting.Name,
					CurrentValue = setting.Value,
					PlaceholderText = setting.Placeholder,
					Ext = true,
					RemoveTextAfterFocusLost = setting.ClearOnFocus,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'toggle' then
				setting.Element = newTab:CreateToggle({
					Name = setting.Name,
					CurrentValue = setting.Value,
					Ext = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'bind' then
				setting.Element = newTab:CreateKeybind({
					Name = setting.Name,
					CurrentKeybind = setting.Value,
					HoldToInteract = false,
					Ext = true,
					CallOnChange = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			end
		end
	end

	settingsCreated = true
	loadSettings()
	saveSettings()
end



function RayfieldLibrary:CreateWindow(Settings)
	print('creating window')
	if Rayfield:FindFirstChild('Loading') then
		if getgenv and not getgenv().rayfieldCached then
			Rayfield.Enabled = true
			Rayfield.Loading.Visible = true

			task.wait(1.4)
			Rayfield.Loading.Visible = false
		end
	end

	if getgenv then getgenv().rayfieldCached = true end

	if not correctBuild and not Settings.DisableBuildWarnings then
		task.delay(3, 
			function() 
				RayfieldLibrary:Notify({Title = 'Build Mismatch', Content = 'Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.\n\nTry rejoining and then run the script twice.', Image = 4335487866, Duration = 15})		
			end)
	end

	if Settings.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind = Settings.ToggleUIKeybind
		if type(keybind) == "string" then
			keybind = string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end), "ToggleUIKeybind must be a valid KeyCode")
			overrideSetting("General", "rayfieldOpen", keybind)
		elseif typeof(keybind) == "EnumItem" then
			assert(keybind.EnumType == Enum.KeyCode, "ToggleUIKeybind must be a KeyCode enum")
			overrideSetting("General", "rayfieldOpen", keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end

	pcall(function()
	if isfolder and not isfolder(RayfieldFolder) then
		makefolder(RayfieldFolder)
	end
	end)

	-- Attempt to report an event to analytics
	if not requestsDisabled then
		sendReport("window_created", Settings.Name or "Unknown")
	end
	local Passthrough = false
	Topbar.Title.Text = Settings.Name

	Main.Size = UDim2.new(0, 480, 0, 100)
	Main.Visible = true
	Main.BackgroundTransparency = 1
	if Main:FindFirstChild('Notice') then Main.Notice.Visible = false end
	Main.Shadow.Image.ImageTransparency = 1

	LoadingFrame.Title.TextTransparency = 1
	LoadingFrame.Subtitle.TextTransparency = 1

	if Settings.ShowText then
		MPrompt.Title.Text = 'Show '..Settings.ShowText
	end

	LoadingFrame.Version.TextTransparency = 1
	LoadingFrame.Title.Text = Settings.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "Interface Suite"

	if Settings.LoadingTitle ~= "Rayfield Interface Suite" then
		LoadingFrame.Version.Text = "Rayfield UI"
	end

	if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
		Topbar.Icon.Visible = true
		Topbar.Title.Position = UDim2.new(0, 47, 0.5, 0)

		if Settings.Icon then
			if typeof(Settings.Icon) == 'string' and Icons then
				local asset = getIcon(Settings.Icon)

				Topbar.Icon.Image = 'rbxassetid://'..asset.id
				Topbar.Icon.ImageRectOffset = asset.imageRectOffset
				Topbar.Icon.ImageRectSize = asset.imageRectSize
			else
				Topbar.Icon.Image = getAssetUri(Settings.Icon)
			end
		else
			Topbar.Icon.Image = "rbxassetid://" .. 0
		end
	end

	if dragBar then
		dragBar.Visible = false
		dragBarCosmetic.BackgroundTransparency = 1
		dragBar.Visible = true
	end

	if Settings.Theme then
		local success, result = pcall(ChangeTheme, Settings.Theme)
		if not success then
			local success, result2 = pcall(ChangeTheme, 'Default')
			if not success then
				warn('CRITICAL ERROR - NO DEFAULT THEME')
				print(result2)
			end
			warn('issue rendering theme. no theme on file')
			print(result)
		end
	end

	Topbar.Visible = false
	Elements.Visible = false
	LoadingFrame.Visible = true

	if not Settings.DisableRayfieldPrompts then
		task.spawn(function()
			while true do
				task.wait(math.random(180, 600))
				RayfieldLibrary:Notify({
					Title = "Rayfield Interface",
					Content = "Enjoying this UI library? Find it at sirius.menu/discord",
					Duration = 7,
					Image = 4370033185,
				})
			end
		end)
	end

	pcall(function()
		if not Settings.ConfigurationSaving.FileName then
			Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
		end

		if Settings.ConfigurationSaving.Enabled == nil then
			Settings.ConfigurationSaving.Enabled = false
		end

		CFileName = Settings.ConfigurationSaving.FileName
		ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
		CEnabled = Settings.ConfigurationSaving.Enabled

		if Settings.ConfigurationSaving.Enabled then
			if not isfolder(ConfigurationFolder) then
				makefolder(ConfigurationFolder)
			end	
		end
	end)


	makeDraggable(Main, Topbar, false, {dragOffset, dragOffsetMobile})
	if dragBar then dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset) makeDraggable(Main, dragInteract, true, {dragOffset, dragOffsetMobile}) end

	for _, TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName == "Frame" and TabButton.Name ~= "Placeholder" then
			TabButton.BackgroundTransparency = 1
			TabButton.Title.TextTransparency = 1
			TabButton.Image.ImageTransparency = 1
			TabButton.UIStroke.Transparency = 1
		end
	end

	if Settings.Discord and Settings.Discord.Enabled and not useStudio then
		if isfolder and not isfolder(RayfieldFolder.."/Discord Invites") then
			makefolder(RayfieldFolder.."/Discord Invites")
		end

		if isfile and not isfile(RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension) then
			if requestFunc then
				pcall(function()
					requestFunc({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = HttpService:JSONEncode({
							cmd = 'INVITE_BROWSER',
							nonce = HttpService:GenerateGUID(false),
							args = {code = Settings.Discord.Invite}
						})
					})
				end)
			end

			if Settings.Discord.RememberJoins then -- We do logic this way so if the developer changes this setting, the user still won't be prompted, only new users
				writefile(RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension,"Rayfield RememberJoins is true for this invite, this invite will not ask you to join again")
			end
		end
	end

	if (Settings.KeySystem) then
		if not Settings.KeySettings then
			Passthrough = true
			return
		end

		if isfolder and not isfolder(RayfieldFolder.."/Key System") then
			makefolder(RayfieldFolder.."/Key System")
		end

		if typeof(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = {Settings.KeySettings.Key} end

		if Settings.KeySettings.GrabKeyFromSite then
			for i, Key in ipairs(Settings.KeySettings.Key) do
				local Success, Response = pcall(function()
					Settings.KeySettings.Key[i] = tostring(game:HttpGet(Key):gsub("[\n\r]", " "))
					Settings.KeySettings.Key[i] = string.gsub(Settings.KeySettings.Key[i], " ", "")
				end)
				if not Success then
					print("Rayfield | "..Key.." Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
				end
			end
		end

		if not Settings.KeySettings.FileName then
			Settings.KeySettings.FileName = "No file name specified"
		end

		if isfile and isfile(RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension) then
			for _, MKey in ipairs(Settings.KeySettings.Key) do
				if string.find(readfile(RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension), MKey) then
					Passthrough = true
				end
			end
		end

		if not Passthrough then
			local AttemptsRemaining = math.random(2, 5)
			Rayfield.Enabled = false
			local KeyUI = useStudio and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]

			KeyUI.Enabled = true

			if gethui then
				KeyUI.Parent = gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(KeyUI)
				KeyUI.Parent = CoreGui
			elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
				KeyUI.Parent = CoreGui:FindFirstChild("RobloxGui")
			elseif not useStudio then
				KeyUI.Parent = CoreGui
			end

			if gethui then
				for _, Interface in ipairs(gethui():GetChildren()) do
					if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
						Interface.Enabled = false
						Interface.Name = "KeyUI-Old"
					end
				end
			elseif not useStudio then
				for _, Interface in ipairs(CoreGui:GetChildren()) do
					if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
						Interface.Enabled = false
						Interface.Name = "KeyUI-Old"
					end
				end
			end

			local KeyMain = KeyUI.Main
			KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
			KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
			KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"

			KeyMain.Size = UDim2.new(0, 467, 0, 175)
			KeyMain.BackgroundTransparency = 1
			KeyMain.Shadow.Image.ImageTransparency = 1
			KeyMain.Title.TextTransparency = 1
			KeyMain.Subtitle.TextTransparency = 1
			KeyMain.KeyNote.TextTransparency = 1
			KeyMain.Input.BackgroundTransparency = 1
			KeyMain.Input.UIStroke.Transparency = 1
			KeyMain.Input.InputBox.TextTransparency = 1
			KeyMain.NoteTitle.TextTransparency = 1
			KeyMain.NoteMessage.TextTransparency = 1
			KeyMain.Hide.ImageTransparency = 1

			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
			TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.15)
			TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.3}):Play()


			KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
				if #KeyUI.Main.Input.InputBox.Text == 0 then return end
				local KeyFound = false
				local FoundKey = ''
				for _, MKey in ipairs(Settings.KeySettings.Key) do
					--if string.find(KeyMain.Input.InputBox.Text, MKey) then
					--	KeyFound = true
					--	FoundKey = MKey
					--end


					-- stricter key check
					if KeyMain.Input.InputBox.Text == MKey then
						KeyFound = true
						FoundKey = MKey
					end
				end
				if KeyFound then 
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
					TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					task.wait(0.51)
					Passthrough = true
					KeyMain.Visible = false
					if Settings.KeySettings.SaveKey then
						if writefile then
							writefile(RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension, FoundKey)
						end
						RayfieldLibrary:Notify({Title = "Key System", Content = "The key for this script has been saved successfully.", Image = 3605522284})
					end
				else
					if AttemptsRemaining == 0 then
						TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
						TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
						TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
						TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
						TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
						TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
						task.wait(0.45)
						Players.LocalPlayer:Kick("No Attempts Remaining")
						game:Shutdown()
					end
					KeyMain.Input.InputBox.Text = ""
					AttemptsRemaining = AttemptsRemaining - 1
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.495,0,0.5,0)}):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.505,0,0.5,0)}):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
				end
			end)

			KeyMain.Hide.MouseButton1Click:Connect(function()
				TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
				TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
				TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
				task.wait(0.51)
				RayfieldLibrary:Destroy()
				KeyUI:Destroy()
			end)
		else
			Passthrough = true
		end
	end
	if Settings.KeySystem then
		repeat task.wait() until Passthrough
	end

	Notifications.Template.Visible = false
	Notifications.Visible = true
	Rayfield.Enabled = true

	task.wait(0.5)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	task.wait(0.1)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()


	Elements.Template.LayoutOrder = 100000
	Elements.Template.Visible = false

	Elements.UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	TabList.Template.Visible = false

	-- Tab
	local FirstTab = false
	local Window = {}

	function Window:CreateTabSection(SectionName)
		TabListOrderCounter += 1
		CurrentTabSectionName = SectionName

		local SectionLabel = Instance.new('TextLabel')
		SectionLabel.Name = 'TabSection_' .. tostring(SectionName)
		SectionLabel.Text = '  ' .. string.upper(tostring(SectionName))
		SectionLabel.LayoutOrder = TabListOrderCounter
		SectionLabel.Parent = TabList
		SectionLabel:SetAttribute('RayfieldTabSection', true)
		styleTabSection(SectionLabel)
		applySidebarLayout()

		local SectionValue = {}
		function SectionValue:Set(NewSectionName)
			SectionName = NewSectionName
			CurrentTabSectionName = NewSectionName
			SectionLabel.Name = 'TabSection_' .. tostring(NewSectionName)
			SectionLabel.Text = '  ' .. string.upper(tostring(NewSectionName))
			updateTabListCanvas()
		end

		function SectionValue:Destroy()
			if CurrentTabSectionName == SectionName then
				CurrentTabSectionName = nil
			end
			SectionLabel:Destroy()
			updateTabListCanvas()
		end

		return SectionValue
	end

	function Window:CreateTab(Name, Image, Ext)
		local SDone = false
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabListOrderCounter += 1
		TabButton.LayoutOrder = TabListOrderCounter
		TabButton.Parent = TabList
		TabButton:SetAttribute('RayfieldTabButton', true)
		if CurrentTabSectionName then
			TabButton:SetAttribute('RayfieldTabSectionName', tostring(CurrentTabSectionName))
		end
		TabButton.Title.TextWrapped = false
		TabButton.Title.TextTruncate = Enum.TextTruncate.AtEnd
		TabButton.Title.TextSize = 13
		TabButton.Size = UDim2.new(1, -8, 0, TAB_BUTTON_HEIGHT)
		TabButton.AnchorPoint = Vector2.new(0, 0)
		TabButton.Position = UDim2.new(0, 4, 0, 0)
		TabButton.ClipsDescendants = true
		TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
		TabButton.Title.AnchorPoint = Vector2.new(0, 0.5)
		TabButton.Title.Position = UDim2.new(0, 12, 0.5, 0)
		TabButton.Title.Size = UDim2.new(1, -24, 0, 14)

		if Image and Image ~= 0 then
			if typeof(Image) == 'string' and Icons then
				local asset = getIcon(Image)

				TabButton.Image.Image = 'rbxassetid://'..asset.id
				TabButton.Image.ImageRectOffset = asset.imageRectOffset
				TabButton.Image.ImageRectSize = asset.imageRectSize
			else
				TabButton.Image.Image = getAssetUri(Image)
			end

			TabButton.Title.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Title.Position = UDim2.new(0, 36, 0.5, 0)
			TabButton.Title.Size = UDim2.new(1, -44, 0, 14)
			TabButton.Image.Visible = true
			TabButton.Image.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Image.Position = UDim2.new(0, 12, 0.5, 0)
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
			TabButton.Size = UDim2.new(1, -8, 0, TAB_BUTTON_HEIGHT)
		end



		TabButton.BackgroundTransparency = 1
		TabButton.Title.TextTransparency = 1
		TabButton.Image.ImageTransparency = 1
		TabButton.UIStroke.Transparency = 1

		TabButton.Visible = not Ext or false
		applySidebarLayout()

		-- Create Elements Page
		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true

		TabPage.LayoutOrder = #Elements:GetChildren() or Ext and 10000

		for _, TemplateElement in ipairs(TabPage:GetChildren()) do
			if TemplateElement.ClassName == "Frame" and TemplateElement.Name ~= "Placeholder" then
				TemplateElement:Destroy()
			end
		end

		TabPage.Parent = Elements
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.Position = UDim2.new(0, 0, 0, 0)
		TabPage.ClipsDescendants = true
		applySidebarLayout()
		if not FirstTab and not Ext then
			Elements.UIPageLayout.Animated = false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated = true
		end

		TabButton.UIStroke.Color = SelectedTheme.TabStroke

		if Elements.UIPageLayout.CurrentPage == TabPage then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
		else
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
		end


		-- Animate
		task.wait(0.1)
		if FirstTab or Ext then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
		elseif not Ext then
			FirstTab = Name
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		end


		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackgroundSelected}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.SelectedTabTextColor}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.SelectedTabTextColor}):Play()

			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end

			if Elements.UIPageLayout.CurrentPage ~= TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
			end
		end)

		local Tab = {}

		-- Button
		function Tab:CreateButton(ButtonSettings)
			local ButtonValue = {}

			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Name
			Button.Title.Text = ButtonSettings.Name
			Button.Visible = true
			Button.Parent = TabPage

			Button.BackgroundTransparency = 1
			Button.UIStroke.Transparency = 1
			Button.Title.TextTransparency = 1

			TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Button.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	


			Button.Interact.MouseButton1Click:Connect(function()
				local Success, Response = pcall(ButtonSettings.Callback)
				-- Prevents animation from trying to play if the button's callback called RayfieldLibrary:Destroy()
				if rayfieldDestroyed then
					return
				end
				if not Success then
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Button.Title.Text = "Callback Error"
					print("Rayfield | "..ButtonSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Button.Title.Text = ButtonSettings.Name
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				else
					if not ButtonSettings.Ext then
						SaveConfiguration(ButtonSettings.Name..'\n')
					end
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					task.wait(0.2)
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end
			end)

			Button.MouseEnter:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.7}):Play()
			end)

			Button.MouseLeave:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
			end)

			function ButtonValue:Set(NewButton)
				Button.Title.Text = NewButton
				Button.Name = NewButton
			end

			return ButtonValue
		end

		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerSettings) -- by Throit
			ColorPickerSettings.Type = "ColorPicker"
			local ColorPicker = Elements.Template.ColorPicker:Clone()
			local Background = ColorPicker.CPBackground
			local Display = Background.Display
			local Main = Background.MainCP
			local Slider = ColorPicker.ColorSlider
			ColorPicker.ClipsDescendants = true
			ColorPicker.Name = ColorPickerSettings.Name
			ColorPicker.Title.Text = ColorPickerSettings.Name
			ColorPicker.Visible = true
			ColorPicker.Parent = TabPage
			ColorPicker.Size = UDim2.new(1, -10, 0, 45)
			Background.Size = UDim2.new(0, 39, 0, 22)
			Display.BackgroundTransparency = 0
			Main.MainPoint.ImageTransparency = 1
			ColorPicker.Interact.Size = UDim2.new(1, 0, 1, 0)
			ColorPicker.Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
			ColorPicker.RGB.Position = UDim2.new(0, 17, 0, 70)
			ColorPicker.HexInput.Position = UDim2.new(0, 17, 0, 90)
			Main.ImageTransparency = 1
			Background.BackgroundTransparency = 1

			for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
				if rgbinput:IsA("Frame") then
					rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
					rgbinput.UIStroke.Color = SelectedTheme.InputStroke
				end
			end

			ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
			ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke

			local opened = false 
			local mouse = Players.LocalPlayer:GetMouse()
			Main.Image = "http://www.roblox.com/asset/?id=11415645739"
			local mainDragging = false 
			local sliderDragging = false 
			ColorPicker.Interact.MouseButton1Down:Connect(function()
				task.spawn(function()
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					task.wait(0.2)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end)

				if not opened then
					opened = true 
					TweenService:Create(Background, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 18, 0, 15)}):Play()
					task.wait(0.1)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 120)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 173, 0, 86)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.289, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 40)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 73)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0.574, 0, 1, 0)}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = SelectedTheme ~= RayfieldLibrary.Theme.Default and 0.25 or 0.1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				else
					opened = false
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 39, 0, 22)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 70)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 90)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				end

			end)

			UserInputService.InputEnded:Connect(function(input, gameProcessed) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
					mainDragging = false
					sliderDragging = false
				end end)
			Main.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Main.MainPoint.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Slider.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			Slider.SliderPoint.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			local h,s,v = ColorPickerSettings.Color:ToHSV()
			local color = Color3.fromHSV(h,s,v) 
			local hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
			ColorPicker.HexInput.InputBox.Text = hex
			local function setDisplay()
				--Main
				Main.MainPoint.Position = UDim2.new(s,-Main.MainPoint.AbsoluteSize.X/2,1-v,-Main.MainPoint.AbsoluteSize.Y/2)
				Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
				Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
				Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
				--Slider 
				local x = h * Slider.AbsoluteSize.X
				Slider.SliderPoint.Position = UDim2.new(0,x-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
				Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
				local color = Color3.fromHSV(h,s,v) 
				local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
				ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
				ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
				hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
				ColorPicker.HexInput.InputBox.Text = hex
			end
			setDisplay()
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				if not pcall(function()
						local r, g, b = string.match(ColorPicker.HexInput.InputBox.Text, "^#?(%w%w)(%w%w)(%w%w)$")
						local rgbColor = Color3.fromRGB(tonumber(r, 16),tonumber(g, 16), tonumber(b, 16))
						h,s,v = rgbColor:ToHSV()
						hex = ColorPicker.HexInput.InputBox.Text
						setDisplay()
						ColorPickerSettings.Color = rgbColor
					end) 
				then 
					ColorPicker.HexInput.InputBox.Text = hex 
				end
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration()
				end
			end)
			--RGB
			local function rgbBoxes(box,toChange)
				local value = tonumber(box.Text) 
				local color = Color3.fromHSV(h,s,v) 
				local oldR,oldG,oldB = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				local save 
				if toChange == "R" then save = oldR;oldR = value elseif toChange == "G" then save = oldG;oldG = value else save = oldB;oldB = value end
				if value then 
					value = math.clamp(value,0,255)
					h,s,v = Color3.fromRGB(oldR,oldG,oldB):ToHSV()

					setDisplay()
				else 
					box.Text = tostring(save)
				end
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration(ColorPickerSettings.Flag..'\n'..tostring(ColorPickerSettings.Color))
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox,"R")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox,"G")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox,"B")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)

			RunService.RenderStepped:connect(function()
				if mainDragging then 
					local localX = math.clamp(mouse.X-Main.AbsolutePosition.X,0,Main.AbsoluteSize.X)
					local localY = math.clamp(mouse.Y-Main.AbsolutePosition.Y,0,Main.AbsoluteSize.Y)
					Main.MainPoint.Position = UDim2.new(0,localX-Main.MainPoint.AbsoluteSize.X/2,0,localY-Main.MainPoint.AbsoluteSize.Y/2)
					s = localX / Main.AbsoluteSize.X
					v = 1 - (localY / Main.AbsoluteSize.Y)
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
				if sliderDragging then 
					local localX = math.clamp(mouse.X-Slider.AbsolutePosition.X,0,Slider.AbsoluteSize.X)
					h = localX / Slider.AbsoluteSize.X
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Slider.SliderPoint.Position = UDim2.new(0,localX-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
					Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and ColorPickerSettings.Flag then
					RayfieldLibrary.Flags[ColorPickerSettings.Flag] = ColorPickerSettings
				end
			end

			function ColorPickerSettings:Set(RGBColor)
				ColorPickerSettings.Color = RGBColor
				h,s,v = ColorPickerSettings.Color:ToHSV()
				color = Color3.fromHSV(h,s,v)
				setDisplay()
			end

			ColorPicker.MouseEnter:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			ColorPicker.MouseLeave:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
					if rgbinput:IsA("Frame") then
						rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
						rgbinput.UIStroke.Color = SelectedTheme.InputStroke
					end
				end

				ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
				ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return ColorPickerSettings
		end

		-- Section
		function Tab:CreateSection(SectionName)

			local SectionValue = {}

			if SDone then
				local SectionSpace = Elements.Template.SectionSpacing:Clone()
				SectionSpace.Visible = true
				SectionSpace.Parent = TabPage
			end

			local Section = Elements.Template.SectionTitle:Clone()
			Section.Title.Text = SectionName
			Section.Visible = true
			Section.Parent = TabPage

			Section.Title.TextTransparency = 1
			TweenService:Create(Section.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()

			function SectionValue:Set(NewSection)
				Section.Title.Text = NewSection
			end

			SDone = true

			return SectionValue
		end

		-- Divider
		function Tab:CreateDivider()
			local DividerValue = {}

			local Divider = Elements.Template.Divider:Clone()
			Divider.Visible = true
			Divider.Parent = TabPage

			Divider.Divider.BackgroundTransparency = 1
			TweenService:Create(Divider.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()

			function DividerValue:Set(Value)
				Divider.Visible = Value
			end

			return DividerValue
		end

		-- Label
		function Tab:CreateLabel(LabelText : string, Icon: number, Color : Color3, IgnoreTheme : boolean)
			local LabelValue = {}

			local Label = Elements.Template.Label:Clone()
			Label.Visible = true
			Label.Parent = TabPage
			Label.ClipsDescendants = true

			Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke

			Label.Title.TextWrapped = true
			Label.Title.TextTruncate = Enum.TextTruncate.None
			Label.Title.TextXAlignment = Enum.TextXAlignment.Left
			Label.Title.TextYAlignment = Enum.TextYAlignment.Top
			Label.Title.AnchorPoint = Vector2.new(0, 0)
			Label.Title.AutomaticSize = Enum.AutomaticSize.None

			local function resolveIcon(iconValue)
				if iconValue then
					if typeof(iconValue) == 'string' and Icons then
						local asset = getIcon(iconValue)
						Label.Icon.Image = 'rbxassetid://'..asset.id
						Label.Icon.ImageRectOffset = asset.imageRectOffset
						Label.Icon.ImageRectSize = asset.imageRectSize
					else
						Label.Icon.Image = getAssetUri(iconValue)
						Label.Icon.ImageRectOffset = Vector2.new(0, 0)
						Label.Icon.ImageRectSize = Vector2.new(0, 0)
					end
				else
					Label.Icon.Image = "rbxassetid://0"
					Label.Icon.ImageRectOffset = Vector2.new(0, 0)
					Label.Icon.ImageRectSize = Vector2.new(0, 0)
				end
			end

			local CurrentLabelText = tostring(LabelText or "")
			local CurrentIcon = Icon
			local CurrentColor = Color

			local function updateLabelSize()
				local iconVisible = CurrentIcon ~= nil and Label:FindFirstChild('Icon') ~= nil
				local leftPadding = iconVisible and 45 or 12
				local rightPadding = 12
				local contentWidth = math.max(80, Label.AbsoluteSize.X - leftPadding - rightPadding)
				if contentWidth <= 80 then
					local estimatedWidth = math.max(120, TabPage.AbsoluteSize.X - leftPadding - rightPadding - 8)
					contentWidth = estimatedWidth
				end

				Label.Title.Text = CurrentLabelText
				Label.Title.Position = UDim2.new(0, leftPadding, 0, 10)

				if iconVisible then
					resolveIcon(CurrentIcon)
					Label.Icon.Visible = true
				else
					resolveIcon(nil)
					Label.Icon.Visible = false
				end

				local measured = TextService:GetTextSize(CurrentLabelText, Label.Title.TextSize, Label.Title.Font, Vector2.new(contentWidth, 10000))
				local textHeight = math.max(14, measured.Y)
				Label.Title.Size = UDim2.new(1, -(leftPadding + rightPadding), 0, textHeight)
				local finalHeight = math.max(43, textHeight + 22)
				local buttonSize = Elements.Template.Button.Size

				Label.Size = UDim2.new(buttonSize.X.Scale, buttonSize.X.Offset, 0, finalHeight)
				Label.Title.Size = UDim2.new(1, -(leftPadding + rightPadding), 0, textHeight)
				Label.Name = CurrentLabelText ~= "" and CurrentLabelText or "Label"
			end

			updateLabelSize()
			Label.Icon.ImageTransparency = 1
			Label.BackgroundTransparency = 1
			Label.UIStroke.Transparency = 1
			Label.Title.TextTransparency = 1

			TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = CurrentColor and 0.8 or 0}):Play()
			TweenService:Create(Label.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = CurrentColor and 0.7 or 0}):Play()
			TweenService:Create(Label.Icon, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(Label.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = CurrentColor and 0.2 or 0}):Play()	

			task.defer(updateLabelSize)
			TabPage:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
				updateLabelSize()
			end)

			function LabelValue:Set(NewLabel, NewIcon, NewColor)
				CurrentLabelText = tostring(NewLabel or CurrentLabelText or "")
				if NewIcon ~= nil then
					CurrentIcon = NewIcon
				end

				if NewColor ~= nil then
					CurrentColor = NewColor
					Label.BackgroundColor3 = NewColor or SelectedTheme.SecondaryElementBackground
					Label.UIStroke.Color = NewColor or SelectedTheme.SecondaryElementStroke
				end

				updateLabelSize()
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Label.BackgroundColor3 = IgnoreTheme and (CurrentColor or Label.BackgroundColor3) or SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color = IgnoreTheme and (CurrentColor or Label.BackgroundColor3) or SelectedTheme.SecondaryElementStroke
			end)

			return LabelValue
		end

		-- Paragraph
		function Tab:CreateParagraph(ParagraphSettings)
			local ParagraphValue = {}
			ParagraphSettings = ParagraphSettings or {}

			local Paragraph = Elements.Template.Paragraph:Clone()
			Paragraph.Visible = true
			Paragraph.Parent = TabPage
			Paragraph.ClipsDescendants = true
			Paragraph.BackgroundTransparency = 1
			Paragraph.UIStroke.Transparency = 1
			Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
			Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke

			local TitleLabel = Paragraph:FindFirstChild('Title')
			if not TitleLabel or not TitleLabel:IsA('TextLabel') then
				if TitleLabel then
					TitleLabel:Destroy()
				end
				TitleLabel = Instance.new('TextLabel')
				TitleLabel.Name = 'Title'
				TitleLabel.Parent = Paragraph
			end

			local ContentLabel = Paragraph:FindFirstChild('Content')
			if not ContentLabel or not ContentLabel:IsA('TextLabel') then
				if ContentLabel then
					ContentLabel:Destroy()
				end
				ContentLabel = Instance.new('TextLabel')
				ContentLabel.Name = 'Content'
				ContentLabel.Parent = Paragraph
			end

			TitleLabel.BackgroundTransparency = 1
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
			TitleLabel.TextWrapped = false
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Size = UDim2.new(1, -24, 0, 18)
			TitleLabel.Position = UDim2.new(0, 12, 0, 10)
			TitleLabel.ZIndex = math.max(Paragraph.ZIndex + 1, TitleLabel.ZIndex)

			ContentLabel.BackgroundTransparency = 1
			ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
			ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
			ContentLabel.TextWrapped = true
			ContentLabel.TextTruncate = Enum.TextTruncate.None
			ContentLabel.Position = UDim2.new(0, 12, 0, 32)
			ContentLabel.Size = UDim2.new(1, -24, 0, 16)
			ContentLabel.ZIndex = math.max(Paragraph.ZIndex + 1, ContentLabel.ZIndex)

			local function updateParagraph(paragraphData)
				paragraphData = paragraphData or {}
				local titleText = tostring(paragraphData.Title or paragraphData.Name or '')
				local contentText = tostring(paragraphData.Content or paragraphData.Text or paragraphData.Description or '')
				local contentWidth = math.max(80, Paragraph.AbsoluteSize.X - 24)
				local titleVisible = titleText ~= ''
				local contentVisible = contentText ~= ''
				local contentTop = titleVisible and 32 or 12
				local contentHeight = 0

				TitleLabel.Text = titleText
				TitleLabel.Visible = titleVisible
				ContentLabel.Text = contentText
				ContentLabel.Visible = contentVisible

				if contentVisible then
					local measured = TextService:GetTextSize(contentText, ContentLabel.TextSize, ContentLabel.Font, Vector2.new(contentWidth, 10000))
					contentHeight = math.max(16, measured.Y)
				end

				TitleLabel.Position = UDim2.new(0, 12, 0, 10)
				TitleLabel.Size = UDim2.new(1, -24, 0, titleVisible and 18 or 0)
				ContentLabel.Position = UDim2.new(0, 12, 0, contentTop)
				ContentLabel.Size = UDim2.new(1, -24, 0, contentVisible and contentHeight or 0)
				local buttonSizee = Elements.Template.Button.Size
				Paragraph.Size = UDim2.new(buttonSizee.X.Scale, buttonSizee.X.Offset, 0, math.max(42, contentTop + contentHeight + 10))
				Paragraph.Name = titleText ~= '' and titleText or 'Paragraph'
			end

			updateParagraph(ParagraphSettings)
			TitleLabel.TextTransparency = 1
			ContentLabel.TextTransparency = 1
			TitleLabel.TextColor3 = SelectedTheme.TextColor
			ContentLabel.TextColor3 = SelectedTheme.TextColor

			TweenService:Create(Paragraph, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Paragraph.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(TitleLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	
			TweenService:Create(ContentLabel, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	
			task.defer(function()
				updateParagraph(ParagraphSettings)
			end)

			function ParagraphValue:Set(NewParagraphSettings)
				ParagraphSettings = NewParagraphSettings or ParagraphSettings
				updateParagraph(ParagraphSettings)
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
				Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke
				TitleLabel.TextColor3 = SelectedTheme.TextColor
				ContentLabel.TextColor3 = SelectedTheme.TextColor
			end)

			return ParagraphValue
		end

		-- Markdown
		function Tab:CreateMarkdown(MarkdownSettings)
			local MarkdownValue = {}
			if type(MarkdownSettings) == "string" then
				MarkdownSettings = {Content = MarkdownSettings}
			else
				MarkdownSettings = MarkdownSettings or {}
			end

			local Markdown = Elements.Template.Paragraph:Clone()
			Markdown.Visible = true
			Markdown.Parent = TabPage
			Markdown.ClipsDescendants = true
			Markdown.BackgroundTransparency = 1
			Markdown.UIStroke.Transparency = 1
			Markdown.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
			Markdown.UIStroke.Color = SelectedTheme.SecondaryElementStroke
			Markdown.Name = tostring(MarkdownSettings.Title or MarkdownSettings.Name or 'Markdown')

			for _, Child in ipairs(Markdown:GetChildren()) do
				if not Child:IsA('UIStroke') and not Child:IsA('UICorner') then
					Child:Destroy()
				end
			end

			local Holder = Instance.new('Frame')
			Holder.Name = 'MarkdownHolder'
			Holder.BackgroundTransparency = 1
			Holder.Parent = Markdown
			Holder.Position = UDim2.new(0, 12, 0, 10)
			Holder.Size = UDim2.new(1, -24, 0, 0)

			local HolderLayout = Instance.new('UIListLayout')
			HolderLayout.Padding = UDim.new(0, 6)
			HolderLayout.FillDirection = Enum.FillDirection.Vertical
			HolderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
			HolderLayout.Parent = Holder

			local function colorToHex(Color)
				return string.format('#%02X%02X%02X', math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
			end

			local function blendColor(ColorA, ColorB, Alpha)
				return Color3.new(
					ColorA.R + (ColorB.R - ColorA.R) * Alpha,
					ColorA.G + (ColorB.G - ColorA.G) * Alpha,
					ColorA.B + (ColorB.B - ColorA.B) * Alpha
				)
			end

			local function escapeRichText(Text)
				Text = tostring(Text or '')
				Text = Text:gsub('&', '&amp;')
				Text = Text:gsub('<', '&lt;')
				Text = Text:gsub('>', '&gt;')
				return Text
			end

			local function measureText(Text, TextSize, Font, Width)
				Width = math.max(40, Width or 40)
				return TextService:GetTextSize(tostring(Text or ''), TextSize, Font, Vector2.new(Width, 100000))
			end

			local function applyInlineMarkdown(Text)
				local AccentHex = colorToHex(SelectedTheme.TabTextColor or SelectedTheme.TextColor)
				local InlineCodeHex = colorToHex(blendColor(SelectedTheme.TextColor, Color3.fromRGB(140, 180, 255), 0.35))
				local Rich = escapeRichText(Text)
				Rich = Rich:gsub('%[([^%]]+)%]%(([^%)]+)%)', '<u><font color="' .. AccentHex .. '">%1</font></u>')
				Rich = Rich:gsub('%*%*([^%*][^%*]-)%*%*', '<b>%1</b>')
				Rich = Rich:gsub('__([^_][^_]-)__', '<b>%1</b>')
				Rich = Rich:gsub('~~([^~][^~]-)~~', '<s>%1</s>')
				Rich = Rich:gsub('`([^`\n]+)`', '<font color="' .. InlineCodeHex .. '"><b>%1</b></font>')
				Rich = Rich:gsub('%*([^%*\n]+)%*', '<i>%1</i>')
				Rich = Rich:gsub('_([^_\n]+)_', '<i>%1</i>')
				return Rich
			end

			local function clearBlocks()
				for _, Child in ipairs(Holder:GetChildren()) do
					if Child ~= HolderLayout then
						Child:Destroy()
					end
				end
			end

			local function updateMarkdownSize()
				local buttonSize = Elements.Template.Button.Size
				local contentHeight = HolderLayout.AbsoluteContentSize.Y
				Holder.Size = UDim2.new(1, -24, 0, contentHeight)
				Markdown.Size = UDim2.new(buttonSize.X.Scale, buttonSize.X.Offset, 0, math.max(42, contentHeight + 20))
			end

			HolderLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMarkdownSize)

			local lastKnownWidth = 0
			local renderMarkdown
			local function getContentWidth()
				local width = Markdown.AbsoluteSize.X
				if width <= 0 then
					local buttonSize = Elements.Template.Button.Size
					if buttonSize.X.Offset > 0 then
						width = buttonSize.X.Offset
					else
						width = 420
					end
				end
				return math.max(140, width - 24)
			end

			local function createTextBlock(Name, Text, TextSize, Font, Height, RichTextEnabled, TextColor, ExtraIndent)
				local Label = Instance.new('TextLabel')
				Label.Name = Name
				Label.BackgroundTransparency = 1
				Label.BorderSizePixel = 0
				Label.RichText = RichTextEnabled or false
				Label.TextWrapped = true
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.TextYAlignment = Enum.TextYAlignment.Top
				Label.Text = Text
				Label.TextSize = TextSize
				Label.Font = Font
				Label.TextColor3 = TextColor or SelectedTheme.TextColor
				Label.Size = UDim2.new(1, -(ExtraIndent or 0), 0, Height)
				Label.Parent = Holder
				return Label
			end

			renderMarkdown = function(CurrentSettings)
				CurrentSettings = CurrentSettings or MarkdownSettings or {}
				clearBlocks()
				Markdown.Name = tostring(CurrentSettings.Title or CurrentSettings.Name or 'Markdown')

				local markdownText = tostring(CurrentSettings.Content or CurrentSettings.Markdown or CurrentSettings.Text or '')
				local contentWidth = getContentWidth()
				lastKnownWidth = contentWidth

				local headingTitle = tostring(CurrentSettings.Title or '')
				if headingTitle ~= '' then
					local titleHeight = math.max(18, measureText(headingTitle, 16, Enum.Font.GothamBold, contentWidth).Y)
					createTextBlock('MarkdownTitle', escapeRichText(headingTitle), 16, Enum.Font.GothamBold, titleHeight, true, SelectedTheme.TextColor)
				end

				local lines = string.split(markdownText, '\n')
				local paragraphLines = {}
				local codeLines = {}
				local inCodeBlock = false
				local codeLanguage = ''

				local function flushParagraph()
					if #paragraphLines == 0 then
						return
					end
					local paragraphText = table.concat(paragraphLines, '\n')
					local richText = applyInlineMarkdown(paragraphText)
					local height = math.max(16, measureText(paragraphText, 13, Enum.Font.Gotham, contentWidth).Y)
					createTextBlock('ParagraphBlock', richText, 13, Enum.Font.Gotham, height, true, SelectedTheme.TextColor)
					table.clear(paragraphLines)
				end

				local function addSpacer(Height)
					local Spacer = Instance.new('Frame')
					Spacer.Name = 'Spacer'
					Spacer.BackgroundTransparency = 1
					Spacer.BorderSizePixel = 0
					Spacer.Size = UDim2.new(1, 0, 0, Height or 4)
					Spacer.Parent = Holder
				end

				local function flushCodeBlock()
					if #codeLines == 0 then
						codeLanguage = ''
						return
					end

					local rawCode = table.concat(codeLines, '\n')
					local CodeFrame = Instance.new('Frame')
					CodeFrame.Name = 'CodeBlock'
					CodeFrame.BackgroundColor3 = blendColor(SelectedTheme.SecondaryElementBackground, Color3.fromRGB(40, 40, 45), 0.35)
					CodeFrame.BorderSizePixel = 0
					CodeFrame.Size = UDim2.new(1, 0, 0, 0)
					CodeFrame.Parent = Holder

					local CodeCorner = Instance.new('UICorner')
					CodeCorner.CornerRadius = UDim.new(0, 8)
					CodeCorner.Parent = CodeFrame

					local CodeStroke = Instance.new('UIStroke')
					CodeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					CodeStroke.Color = blendColor(SelectedTheme.SecondaryElementStroke, SelectedTheme.TextColor, 0.15)
					CodeStroke.Transparency = 0.15
					CodeStroke.Parent = CodeFrame

					local padX = 10
					local headerHeight = 24
					local topInset = headerHeight + 10
					local codeWidth = math.max(80, contentWidth - padX * 2)
					local headerTextColor = blendColor(SelectedTheme.TextColor, Color3.fromRGB(160, 190, 255), 0.35)

					local HeaderFrame = Instance.new('Frame')
					HeaderFrame.Name = 'Header'
					HeaderFrame.BackgroundTransparency = 1
					HeaderFrame.BorderSizePixel = 0
					HeaderFrame.Size = UDim2.new(1, -(padX * 2), 0, headerHeight)
					HeaderFrame.Position = UDim2.new(0, padX, 0, 6)
					HeaderFrame.Parent = CodeFrame

					local languageText = codeLanguage ~= '' and string.upper(codeLanguage) or 'CODE'
					local LangLabel = Instance.new('TextLabel')
					LangLabel.Name = 'Language'
					LangLabel.BackgroundTransparency = 1
					LangLabel.BorderSizePixel = 0
					LangLabel.TextXAlignment = Enum.TextXAlignment.Left
					LangLabel.TextYAlignment = Enum.TextYAlignment.Center
					LangLabel.Font = Enum.Font.GothamBold
					LangLabel.TextSize = 11
					LangLabel.TextColor3 = headerTextColor
					LangLabel.Text = languageText
					LangLabel.Size = UDim2.new(1, -30, 1, 0)
					LangLabel.Parent = HeaderFrame

					local CopyButton = Instance.new('ImageButton')
					CopyButton.Name = 'CopyButton'
					CopyButton.AutoButtonColor = false
					CopyButton.BackgroundColor3 = blendColor(SelectedTheme.SecondaryElementBackground, SelectedTheme.SecondaryElementStroke, 0.18)
					CopyButton.BorderSizePixel = 0
					CopyButton.AnchorPoint = Vector2.new(1, 0)
					CopyButton.Position = UDim2.new(1, 0, 0, 1)
					CopyButton.Size = UDim2.new(0, 20, 0, 20)
					CopyButton.Image = 'rbxassetid://83983589022863'
					CopyButton.ImageColor3 = headerTextColor
					CopyButton.ImageTransparency = 0.08
					CopyButton.Parent = HeaderFrame

					local CopyCorner = Instance.new('UICorner')
					CopyCorner.CornerRadius = UDim.new(0, 6)
					CopyCorner.Parent = CopyButton

					local CopyStroke = Instance.new('UIStroke')
					CopyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					CopyStroke.Color = blendColor(SelectedTheme.SecondaryElementStroke, SelectedTheme.TextColor, 0.12)
					CopyStroke.Transparency = 0.25
					CopyStroke.Parent = CopyButton

					local function setCopyVisuals(isCopied)
						if isCopied then
							TweenService:Create(CopyButton, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {BackgroundColor3 = blendColor(SelectedTheme.TabTextColor or SelectedTheme.TextColor, SelectedTheme.SecondaryElementBackground, 0.55)}):Play()
							TweenService:Create(CopyButton, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
							TweenService:Create(CopyStroke, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {Transparency = 0.05}):Play()
						else
							TweenService:Create(CopyButton, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {BackgroundColor3 = blendColor(SelectedTheme.SecondaryElementBackground, SelectedTheme.SecondaryElementStroke, 0.18)}):Play()
							TweenService:Create(CopyButton, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {ImageColor3 = headerTextColor}):Play()
							TweenService:Create(CopyStroke, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {Transparency = 0.25}):Play()
						end
					end

					CopyButton.MouseEnter:Connect(function()
						TweenService:Create(CopyButton, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {BackgroundColor3 = blendColor(SelectedTheme.SecondaryElementBackground, SelectedTheme.SecondaryElementStroke, 0.3)}):Play()
						TweenService:Create(CopyStroke, TweenInfo.new(0.18, Enum.EasingStyle.Exponential), {Transparency = 0.12}):Play()
					end)

					CopyButton.MouseLeave:Connect(function()
						setCopyVisuals(false)
					end)

					CopyButton.MouseButton1Click:Connect(function()
						local clipboardFn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
						if clipboardFn then
							pcall(clipboardFn, rawCode)
							setCopyVisuals(true)
							task.delay(0.8, function()
								if CopyButton and CopyButton.Parent then
									setCopyVisuals(false)
								end
							end)
						end
					end)

					local CodeLabel = Instance.new('TextLabel')
					CodeLabel.Name = 'Code'
					CodeLabel.BackgroundTransparency = 1
					CodeLabel.BorderSizePixel = 0
					CodeLabel.RichText = false
					CodeLabel.TextWrapped = true
					CodeLabel.TextXAlignment = Enum.TextXAlignment.Left
					CodeLabel.TextYAlignment = Enum.TextYAlignment.Top
					CodeLabel.Font = Enum.Font.Code
					CodeLabel.TextSize = 13
					CodeLabel.TextColor3 = blendColor(SelectedTheme.TextColor, Color3.fromRGB(190, 210, 255), 0.18)
					CodeLabel.Text = rawCode
					local codeHeight = math.max(18, measureText(rawCode, 13, Enum.Font.Code, codeWidth).Y)
					CodeLabel.Size = UDim2.new(1, -(padX * 2), 0, codeHeight)
					CodeLabel.Position = UDim2.new(0, padX, 0, topInset)
					CodeLabel.Parent = CodeFrame

					CodeFrame.Size = UDim2.new(1, 0, 0, topInset + codeHeight + 10)
					table.clear(codeLines)
					codeLanguage = ''
				end

				for _, rawLine in ipairs(lines) do
					local line = rawLine or ''
					local fenceLanguage = line:match('^```%s*([%w_-]*)%s*$')
					if fenceLanguage ~= nil then
						if inCodeBlock then
							flushCodeBlock()
							inCodeBlock = false
						else
							flushParagraph()
							inCodeBlock = true
							codeLanguage = fenceLanguage or ''
						end
					elseif inCodeBlock then
						table.insert(codeLines, line)
					elseif line:match('^%s*$') then
						flushParagraph()
						addSpacer(2)
					else
						local headingHashes, headingText = line:match('^(%s*#+)%s+(.+)$')
						local quoteText = line:match('^%s*>%s+(.+)$')
						local bulletText = line:match('^%s*[-%*+]%s+(.+)$')
						local orderedIndex, orderedText = line:match('^%s*(%d+)%.%s+(.+)$')
						local divider = line:match('^%s*[-*_][-*_][-*_]+%s*$')

						if headingHashes and headingText then
							flushParagraph()
							local cleanHashes = headingHashes:gsub('%s', '')
							local level = math.clamp(#cleanHashes, 1, 6)
							local sizes = {24, 20, 17, 15, 14, 13}
							local headingSize = sizes[level] or 13
							local headingHeight = math.max(headingSize, measureText(headingText, headingSize, Enum.Font.GothamBold, contentWidth).Y)
							createTextBlock('Heading' .. tostring(level), applyInlineMarkdown(headingText), headingSize, Enum.Font.GothamBold, headingHeight, true, SelectedTheme.TextColor)
						elseif quoteText then
							flushParagraph()
							local QuoteFrame = Instance.new('Frame')
							QuoteFrame.Name = 'QuoteBlock'
							QuoteFrame.BackgroundTransparency = 1
							QuoteFrame.BorderSizePixel = 0
							QuoteFrame.Size = UDim2.new(1, 0, 0, 0)
							QuoteFrame.Parent = Holder

							local QuoteBar = Instance.new('Frame')
							QuoteBar.Name = 'Bar'
							QuoteBar.BorderSizePixel = 0
							QuoteBar.BackgroundColor3 = blendColor(SelectedTheme.TabTextColor or SelectedTheme.TextColor, SelectedTheme.SecondaryElementStroke, 0.35)
							QuoteBar.Size = UDim2.new(0, 3, 1, 0)
							QuoteBar.Parent = QuoteFrame

							local quoteWidth = math.max(80, contentWidth - 14)
							local QuoteLabel = Instance.new('TextLabel')
							QuoteLabel.Name = 'QuoteText'
							QuoteLabel.BackgroundTransparency = 1
							QuoteLabel.BorderSizePixel = 0
							QuoteLabel.RichText = true
							QuoteLabel.TextWrapped = true
							QuoteLabel.TextXAlignment = Enum.TextXAlignment.Left
							QuoteLabel.TextYAlignment = Enum.TextYAlignment.Top
							QuoteLabel.Font = Enum.Font.Gotham
							QuoteLabel.TextSize = 13
							QuoteLabel.TextColor3 = blendColor(SelectedTheme.TextColor, SelectedTheme.SecondaryElementStroke, 0.15)
							QuoteLabel.Text = applyInlineMarkdown(quoteText)
							local quoteHeight = math.max(16, measureText(quoteText, 13, Enum.Font.Gotham, quoteWidth).Y)
							QuoteLabel.Size = UDim2.new(1, -10, 0, quoteHeight)
							QuoteLabel.Position = UDim2.new(0, 10, 0, 0)
							QuoteLabel.Parent = QuoteFrame

							QuoteFrame.Size = UDim2.new(1, 0, 0, quoteHeight)
						elseif bulletText or orderedText then
							flushParagraph()
							local bulletBody = bulletText or orderedText or ''
							local markerText = bulletText and '•' or (tostring(orderedIndex) .. '.')
							local ItemFrame = Instance.new('Frame')
							ItemFrame.Name = 'ListItem'
							ItemFrame.BackgroundTransparency = 1
							ItemFrame.BorderSizePixel = 0
							ItemFrame.Size = UDim2.new(1, 0, 0, 0)
							ItemFrame.Parent = Holder

							local Marker = Instance.new('TextLabel')
							Marker.Name = 'Marker'
							Marker.BackgroundTransparency = 1
							Marker.BorderSizePixel = 0
							Marker.TextXAlignment = Enum.TextXAlignment.Left
							Marker.TextYAlignment = Enum.TextYAlignment.Top
							Marker.Font = Enum.Font.GothamBold
							Marker.TextSize = 13
							Marker.TextColor3 = SelectedTheme.TabTextColor or SelectedTheme.TextColor
							Marker.Text = markerText
							Marker.Size = UDim2.new(0, 16, 0, 16)
							Marker.Parent = ItemFrame

							local itemWidth = math.max(80, contentWidth - 18)
							local ItemLabel = Instance.new('TextLabel')
							ItemLabel.Name = 'ItemText'
							ItemLabel.BackgroundTransparency = 1
							ItemLabel.BorderSizePixel = 0
							ItemLabel.RichText = true
							ItemLabel.TextWrapped = true
							ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
							ItemLabel.TextYAlignment = Enum.TextYAlignment.Top
							ItemLabel.Font = Enum.Font.Gotham
							ItemLabel.TextSize = 13
							ItemLabel.TextColor3 = SelectedTheme.TextColor
							ItemLabel.Text = applyInlineMarkdown(bulletBody)
							local itemHeight = math.max(16, measureText(bulletBody, 13, Enum.Font.Gotham, itemWidth).Y)
							ItemLabel.Size = UDim2.new(1, -18, 0, itemHeight)
							ItemLabel.Position = UDim2.new(0, 18, 0, 0)
							ItemLabel.Parent = ItemFrame

							ItemFrame.Size = UDim2.new(1, 0, 0, itemHeight)
						elseif divider then
							flushParagraph()
							local Divider = Instance.new('Frame')
							Divider.Name = 'MarkdownDivider'
							Divider.BorderSizePixel = 0
							Divider.BackgroundColor3 = blendColor(SelectedTheme.SecondaryElementStroke, SelectedTheme.TextColor, 0.08)
							Divider.Size = UDim2.new(1, 0, 0, 1)
							Divider.Parent = Holder
						else
							table.insert(paragraphLines, line)
						end
					end
				end

				flushParagraph()
				if inCodeBlock then
					flushCodeBlock()
				end

				updateMarkdownSize()
			end

			updateMarkdownSize()
			renderMarkdown(MarkdownSettings)

			TweenService:Create(Markdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Markdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()

			task.defer(function()
				renderMarkdown(MarkdownSettings)
			end)

			Markdown:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
				local newWidth = getContentWidth()
				if math.abs(newWidth - lastKnownWidth) >= 4 then
					task.defer(function()
						renderMarkdown(MarkdownSettings)
					end)
				end
			end)

			function MarkdownValue:Set(NewMarkdownSettings)
				if type(NewMarkdownSettings) == 'string' then
					MarkdownSettings = {Content = NewMarkdownSettings}
				else
					MarkdownSettings = NewMarkdownSettings or MarkdownSettings
				end
				renderMarkdown(MarkdownSettings)
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Markdown.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
				Markdown.UIStroke.Color = SelectedTheme.SecondaryElementStroke
				renderMarkdown(MarkdownSettings)
			end)

			return MarkdownValue
		end

		-- Input
		function Tab:CreateInput(InputSettings)
			local Input = Elements.Template.Input:Clone()
			Input.Name = InputSettings.Name
			Input.Title.Text = InputSettings.Name
			Input.Visible = true
			Input.Parent = TabPage

			Input.BackgroundTransparency = 1
			Input.UIStroke.Transparency = 1
			Input.Title.TextTransparency = 1

			Input.InputFrame.InputBox.Text = InputSettings.CurrentValue or ''

			Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Input.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Input.InputFrame.InputBox.PlaceholderText = InputSettings.PlaceholderText or "nil"
			Input.InputFrame.Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

			Input.InputFrame.InputBox.FocusLost:Connect(function()
				local Success, Response = pcall(function()
					InputSettings.Callback(Input.InputFrame.InputBox.Text)
					InputSettings.CurrentValue = Input.InputFrame.InputBox.Text
				end)

				if not Success then
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Input.Title.Text = "Callback Error"
					print("Rayfield | "..InputSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Input.Title.Text = InputSettings.Name
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if InputSettings.RemoveTextAfterFocusLost then
					Input.InputFrame.InputBox.Text = ""
				end

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end)

			Input.MouseEnter:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Input.MouseLeave:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Input.InputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function InputSettings:Set(text)
				Input.InputFrame.InputBox.Text = text
				InputSettings.CurrentValue = text

				local Success, Response = pcall(function()
					InputSettings.Callback(text)
				end)

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and InputSettings.Flag then
					RayfieldLibrary.Flags[InputSettings.Flag] = InputSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return InputSettings
		end

		-- Dropdown
		function Tab:CreateDropdown(DropdownSettings)
			local Dropdown = Elements.Template.Dropdown:Clone()
			if string.find(DropdownSettings.Name,"closed") then
				Dropdown.Name = "Dropdown"
			else
				Dropdown.Name = DropdownSettings.Name
			end
			Dropdown.Title.Text = DropdownSettings.Name
			Dropdown.Visible = true
			Dropdown.Parent = TabPage

			Dropdown.List.Visible = false
			if DropdownSettings.CurrentOption then
				if type(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end
				if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end
			else
				DropdownSettings.CurrentOption = {}
			end

			if DropdownSettings.MultipleOptions then
				if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					DropdownSettings.CurrentOption = {}
					Dropdown.Selected.Text = "None"
				end
			else
				Dropdown.Selected.Text = DropdownSettings.CurrentOption[1] or "None"
			end

			Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
			TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()

			Dropdown.BackgroundTransparency = 1
			Dropdown.UIStroke.Transparency = 1
			Dropdown.Title.TextTransparency = 1

			Dropdown.Size = UDim2.new(1, -10, 0, 45)

			TweenService:Create(Dropdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Dropdown.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			for _, ununusedoption in ipairs(Dropdown.List:GetChildren()) do
				if ununusedoption.ClassName == "Frame" and ununusedoption.Name ~= "Placeholder" then
					ununusedoption:Destroy()
				end
			end

			Dropdown.Toggle.Rotation = 180

			Dropdown.Interact.MouseButton1Click:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				task.wait(0.1)
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				if Debounce then return end
				if Dropdown.List.Visible then
					Debounce = true
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						end
					end
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()	
					task.wait(0.35)
					Dropdown.List.Visible = false
					Debounce = false
				else
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 180)}):Play()
					Dropdown.List.Visible = true
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 0.7}):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 0}):Play()	
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							if DropdownOpt.Name ~= Dropdown.Selected.Text then
								TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
						end
					end
				end
			end)

			Dropdown.MouseEnter:Connect(function()
				if not Dropdown.List.Visible then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				end
			end)

			Dropdown.MouseLeave:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			local function SetDropdownOptions()
				for _, Option in ipairs(DropdownSettings.Options) do
					local DropdownOption = Elements.Template.Dropdown.List.Template:Clone()
					DropdownOption.Name = Option
					DropdownOption.Title.Text = Option
					DropdownOption.Parent = Dropdown.List
					DropdownOption.Visible = true

					DropdownOption.BackgroundTransparency = 1
					DropdownOption.UIStroke.Transparency = 1
					DropdownOption.Title.TextTransparency = 1

					--local Dropdown = Tab:CreateDropdown({
					--	Name = "Dropdown Example",
					--	Options = {"Option 1","Option 2"},
					--	CurrentOption = {"Option 1"},
					--  MultipleOptions = true,
					--	Flag = "Dropdown1",
					--	Callback = function(TableOfOptions)

					--	end,
					--})


					DropdownOption.Interact.ZIndex = 50
					DropdownOption.Interact.MouseButton1Click:Connect(function()
						if not DropdownSettings.MultipleOptions and table.find(DropdownSettings.CurrentOption, Option) then 
							return
						end

						if table.find(DropdownSettings.CurrentOption, Option) then
							table.remove(DropdownSettings.CurrentOption, table.find(DropdownSettings.CurrentOption, Option))
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
						else
							if not DropdownSettings.MultipleOptions then
								table.clear(DropdownSettings.CurrentOption)
							end
							table.insert(DropdownSettings.CurrentOption, Option)
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
							TweenService:Create(DropdownOption.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(DropdownOption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownSelected}):Play()
							Debounce = true
						end


						local Success, Response = pcall(function()
							DropdownSettings.Callback(DropdownSettings.CurrentOption)
						end)

						if not Success then
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Dropdown.Title.Text = "Callback Error"
							print("Rayfield | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Dropdown.Title.Text = DropdownSettings.Name
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
						end

						for _, droption in ipairs(Dropdown.List:GetChildren()) do
							if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" and not table.find(DropdownSettings.CurrentOption, droption.Name) then
								TweenService:Create(droption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownUnselected}):Play()
							end
						end
						if not DropdownSettings.MultipleOptions then
							task.wait(0.1)
							TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
							for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
								if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
									TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
									TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
								end
							end
							TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
							TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()	
							task.wait(0.35)
							Dropdown.List.Visible = false
						end
						Debounce = false
						if not DropdownSettings.Ext then
							SaveConfiguration()
						end
					end)

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						DropdownOption.UIStroke.Color = SelectedTheme.ElementStroke
					end)
				end
			end
			SetDropdownOptions()

			for _, droption in ipairs(Dropdown.List:GetChildren()) do
				if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
					if not table.find(DropdownSettings.CurrentOption, droption.Name) then
						droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
					else
						droption.BackgroundColor3 = SelectedTheme.DropdownSelected
					end

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end)
				end
			end

			function DropdownSettings:Set(NewOption)
				DropdownSettings.CurrentOption = NewOption

				if typeof(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end

				if not DropdownSettings.MultipleOptions then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end

				if DropdownSettings.MultipleOptions then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
				end


				local Success, Response = pcall(function()
					DropdownSettings.Callback(NewOption)
				end)
				if not Success then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Dropdown.Title.Text = "Callback Error"
					print("Rayfield | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Dropdown.Title.Text = DropdownSettings.Name
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				for _, droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end
				--SaveConfiguration()
			end

			function DropdownSettings:Refresh(optionsTable: table) -- updates a dropdown with new options from optionsTable
				DropdownSettings.Options = optionsTable
				for _, option in Dropdown.List:GetChildren() do
					if option.ClassName == "Frame" and option.Name ~= "Placeholder" then
						option:Destroy()
					end
				end
				SetDropdownOptions()
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and DropdownSettings.Flag then
					RayfieldLibrary.Flags[DropdownSettings.Flag] = DropdownSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			return DropdownSettings
		end

		-- Keybind
		function Tab:CreateKeybind(KeybindSettings)
			local CheckingForKey = false
			local Keybind = Elements.Template.Keybind:Clone()
			Keybind.Name = KeybindSettings.Name
			Keybind.Title.Text = KeybindSettings.Name
			Keybind.Visible = true
			Keybind.Parent = TabPage

			Keybind.BackgroundTransparency = 1
			Keybind.UIStroke.Transparency = 1
			Keybind.Title.TextTransparency = 1

			Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Keybind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Keybind.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
			Keybind.KeybindFrame.Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)

			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey = true
				Keybind.KeybindFrame.KeybindBox.Text = ""
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey = false
				if Keybind.KeybindFrame.KeybindBox.Text == nil or Keybind.KeybindFrame.KeybindBox.Text == "" then
					Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
					if not KeybindSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			Keybind.MouseEnter:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Keybind.MouseLeave:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if CheckingForKey then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local SplitMessage = string.split(tostring(input.KeyCode), ".")
						local NewKeyNoEnum = SplitMessage[3]
						Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeyNoEnum)
						KeybindSettings.CurrentKeybind = tostring(NewKeyNoEnum)
						Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
						if not KeybindSettings.Ext then
							SaveConfiguration()
						end

						if KeybindSettings.CallOnChange then
							KeybindSettings.Callback(tostring(NewKeyNoEnum))
						end
					end
				elseif not KeybindSettings.CallOnChange and KeybindSettings.CurrentKeybind ~= nil and (input.KeyCode == Enum.KeyCode[KeybindSettings.CurrentKeybind] and not processed) then -- Test
					local Held = true
					local Connection
					Connection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							Connection:Disconnect()
							Held = false
						end
					end)

					if not KeybindSettings.HoldToInteract then
						local Success, Response = pcall(KeybindSettings.Callback)
						if not Success then
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Keybind.Title.Text = "Callback Error"
							print("Rayfield | "..KeybindSettings.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Keybind.Title.Text = KeybindSettings.Name
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
						end
					else
						task.wait(0.25)
						if Held then
							local Loop; Loop = RunService.Stepped:Connect(function()
								if not Held then
									KeybindSettings.Callback(false) -- maybe pcall this
									Loop:Disconnect()
								else
									KeybindSettings.Callback(true) -- maybe pcall this
								end
							end)
						end
					end
				end
			end)

			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Keybind.KeybindFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function KeybindSettings:Set(NewKeybind)
				Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeybind)
				KeybindSettings.CurrentKeybind = tostring(NewKeybind)
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindSettings.Ext then
					SaveConfiguration()
				end

				if KeybindSettings.CallOnChange then
					KeybindSettings.Callback(tostring(NewKeybind))
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and KeybindSettings.Flag then
					RayfieldLibrary.Flags[KeybindSettings.Flag] = KeybindSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return KeybindSettings
		end

		-- Toggle
		function Tab:CreateToggle(ToggleSettings)
			local ToggleValue = {}

			local Toggle = Elements.Template.Toggle:Clone()
			Toggle.Name = ToggleSettings.Name
			Toggle.Title.Text = ToggleSettings.Name
			Toggle.Visible = true
			Toggle.Parent = TabPage

			Toggle.BackgroundTransparency = 1
			Toggle.UIStroke.Transparency = 1
			Toggle.Title.TextTransparency = 1
			Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Toggle.Switch.Shadow.Visible = false
			end

			TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Toggle.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			if ToggleSettings.CurrentValue == true then
				Toggle.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
			else
				Toggle.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
			end

			Toggle.MouseEnter:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Toggle.MouseLeave:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Toggle.Interact.MouseButton1Click:Connect(function()
				if ToggleSettings.CurrentValue == true then
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledOuterStroke}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				else
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledOuterStroke}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()		
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (Interact)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end)

			function ToggleSettings:Set(NewToggleValue)
				if NewToggleValue == true then
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()	
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				else
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (:Set)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end

			if not ToggleSettings.Ext then
				if Settings.ConfigurationSaving then
					if Settings.ConfigurationSaving.Enabled and ToggleSettings.Flag then
						RayfieldLibrary.Flags[ToggleSettings.Flag] = ToggleSettings
					end
				end
			end


			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Toggle.Switch.Shadow.Visible = false
				end

				task.wait()

				if not ToggleSettings.CurrentValue then
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
				else
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
				end
			end)

			return ToggleSettings
		end

		-- Slider
		function Tab:CreateSlider(SliderSettings)
			local SLDragging = false
			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Name
			Slider.Title.Text = SliderSettings.Name
			Slider.Visible = true
			Slider.Parent = TabPage

			Slider.BackgroundTransparency = 1
			Slider.UIStroke.Transparency = 1
			Slider.Title.TextTransparency = 1

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Slider.Main.Shadow.Visible = false
			end

			Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
			Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress

			TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Slider.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Slider.Main.Progress.Size =	UDim2.new(0, Slider.Main.AbsoluteSize.X * ((SliderSettings.CurrentValue + SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Main.AbsoluteSize.X * (SliderSettings.CurrentValue / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)

			if not SliderSettings.Suffix then
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue)
			else
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue) .. " " .. SliderSettings.Suffix
			end

			Slider.MouseEnter:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Slider.MouseLeave:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Slider.Main.Interact.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					SLDragging = true 
				end 
			end)

			Slider.Main.Interact.InputEnded:Connect(function(Input) 
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
					TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.3}):Play()
					SLDragging = false 
				end 
			end)

			Slider.Main.Interact.MouseButton1Down:Connect(function(X)
				local Current = Slider.Main.Progress.AbsolutePosition.X + Slider.Main.Progress.AbsoluteSize.X
				local Start = Current
				local Location = X
				local Loop; Loop = RunService.Stepped:Connect(function()
					if SLDragging then
						Location = UserInputService:GetMouseLocation().X
						Current = Current + 0.025 * (Location - Start)

						if Location < Slider.Main.AbsolutePosition.X then
							Location = Slider.Main.AbsolutePosition.X
						elseif Location > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Location = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current < Slider.Main.AbsolutePosition.X + 5 then
							Current = Slider.Main.AbsolutePosition.X + 5
						elseif Current > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Current = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current <= Location and (Location - Start) < 0 then
							Start = Location
						elseif Current >= Location and (Location - Start) > 0 then
							Start = Location
						end
						TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Current - Slider.Main.AbsolutePosition.X, 1, 0)}):Play()
						local NewValue = SliderSettings.Range[1] + (Location - Slider.Main.AbsolutePosition.X) / Slider.Main.AbsoluteSize.X * (SliderSettings.Range[2] - SliderSettings.Range[1])

						NewValue = math.floor(NewValue / SliderSettings.Increment + 0.5) * (SliderSettings.Increment * 10000000) / 10000000
						NewValue = math.clamp(NewValue, SliderSettings.Range[1], SliderSettings.Range[2])

						if not SliderSettings.Suffix then
							Slider.Main.Information.Text = tostring(NewValue)
						else
							Slider.Main.Information.Text = tostring(NewValue) .. " " .. SliderSettings.Suffix
						end

						if SliderSettings.CurrentValue ~= NewValue then
							local Success, Response = pcall(function()
								SliderSettings.Callback(NewValue)
							end)
							if not Success then
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								Slider.Title.Text = "Callback Error"
								print("Rayfield | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
								warn('Check docs.sirius.menu for help with Rayfield specific development.')
								task.wait(0.5)
								Slider.Title.Text = SliderSettings.Name
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end

							SliderSettings.CurrentValue = NewValue
							if not SliderSettings.Ext then
								SaveConfiguration()
							end
						end
					else
						TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Location - Slider.Main.AbsolutePosition.X > 5 and Location - Slider.Main.AbsolutePosition.X or 5, 1, 0)}):Play()
						Loop:Disconnect()
					end
				end)
			end)

			function SliderSettings:Set(NewVal)
				local NewVal = math.clamp(NewVal, SliderSettings.Range[1], SliderSettings.Range[2])

				TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Slider.Main.AbsoluteSize.X * ((NewVal + SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Main.AbsoluteSize.X * (NewVal / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)}):Play()
				Slider.Main.Information.Text = tostring(NewVal) .. " " .. (SliderSettings.Suffix or "")

				local Success, Response = pcall(function()
					SliderSettings.Callback(NewVal)
				end)

				if not Success then
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Slider.Title.Text = "Callback Error"
					print("Rayfield | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Slider.Title.Text = SliderSettings.Name
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				SliderSettings.CurrentValue = NewVal
				if not SliderSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and SliderSettings.Flag then
					RayfieldLibrary.Flags[SliderSettings.Flag] = SliderSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Slider.Main.Shadow.Visible = false
				end

				Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
				Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress
			end)

			return SliderSettings
		end

		Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			TabButton.UIStroke.Color = SelectedTheme.TabStroke

			if Elements.UIPageLayout.CurrentPage == TabPage then
				TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
				TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			else
				TabButton.BackgroundColor3 = SelectedTheme.TabBackground
				TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			end
		end)

		return Tab
	end

	Elements.Visible = true


	task.wait(1.1)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 390, 0, 90)}):Play()
	task.wait(0.3)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	task.wait(0.1)
	TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = useMobileSizing and UDim2.new(0, 570, 0, 275) or UDim2.new(0, 570, 0, 475)}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()

	Topbar.BackgroundTransparency = 1
	Topbar.Divider.Size = UDim2.new(0, 0, 0, 1)
	Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency = 1
	Topbar.Title.TextTransparency = 1
	Topbar.Search.ImageTransparency = 1
	if Topbar:FindFirstChild('Settings') then
		Topbar.Settings.ImageTransparency = 1
	end
	Topbar.ChangeSize.ImageTransparency = 1
	Topbar.Hide.ImageTransparency = 1


	task.wait(0.5)
	Topbar.Visible = true
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	task.wait(0.1)
	TweenService:Create(Topbar.Divider, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 1)}):Play()
	TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Search, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.05)
	if Topbar:FindFirstChild('Settings') then
		TweenService:Create(Topbar.Settings, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
		task.wait(0.05)
	end
	TweenService:Create(Topbar.ChangeSize, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Hide, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.3)

	if dragBar then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	end

	function Window.ModifyTheme(NewTheme)
		local success = pcall(ChangeTheme, NewTheme)
		if not success then
			RayfieldLibrary:Notify({Title = 'Unable to Change Theme', Content = 'We are unable find a theme on file.', Image = 4400704299})
		else
			RayfieldLibrary:Notify({Title = 'Theme Changed', Content = 'Successfully changed theme to '..(typeof(NewTheme) == 'string' and NewTheme or 'Custom Theme')..'.', Image = 4483362748})
		end
	end

	local success, result = pcall(function()
		createSettings(Window)
	end)

	if not success then warn('Rayfield had an issue creating settings.') end

	return Window
end

local function setVisibility(visibility: boolean, notify: boolean?)
	if Debounce then return end
	if visibility then
		Hidden = false
		Unhide()
	else
		Hidden = true
		Hide(notify)
	end
end

function RayfieldLibrary:SetVisibility(visibility: boolean)
	setVisibility(visibility, false)
end

function RayfieldLibrary:IsVisible(): boolean
	return not Hidden
end

local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function RayfieldLibrary:Destroy()
	rayfieldDestroyed = true
	hideHotkeyConnection:Disconnect()
	Rayfield:Destroy()
end

Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then
		Minimised = false
		Maximise()
	else
		Minimised = true
		Minimise()
	end
end)

Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
	if #Main.Search.Input.Text > 0 then
		if not Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks') then 
			local searchTitle = Elements.Template.SectionTitle:Clone()
			searchTitle.Parent = Elements.UIPageLayout.CurrentPage
			searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
			searchTitle.LayoutOrder = -100
			searchTitle.Title.Text = "Results from '"..Elements.UIPageLayout.CurrentPage.Name.."'"
			searchTitle.Visible = true
		end
	else
		local searchTitle = Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')

		if searchTitle then
			searchTitle:Destroy()
		end
	end

	for _, element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
		if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
			if element.Name == 'SectionTitle' then
				if #Main.Search.Input.Text == 0 then
					element.Visible = true
				else
					element.Visible = false
				end
			else
				if string.lower(element.Name):find(string.lower(Main.Search.Input.Text), 1, true) then
					element.Visible = true
				else
					element.Visible = false
				end
			end
		end
	end
end)

Main.Search.Input.FocusLost:Connect(function(enterPressed)
	if #Main.Search.Input.Text == 0 and searchOpen then
		task.wait(0.12)
		closeSearch()
	end
end)

Topbar.Search.MouseButton1Click:Connect(function()
	task.spawn(function()
		if searchOpen then
			closeSearch()
		else
			openSearch()
		end
	end)
end)

if Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function()
		task.spawn(function()
			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end

			Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
		end)
	end)

end


Topbar.Hide.MouseButton1Click:Connect(function()
	setVisibility(Hidden, not useMobileSizing)
end)

hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if (input.KeyCode == Enum.KeyCode[getSetting("General", "rayfieldOpen")]) and not processed then
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		else
			Hidden = true
			Hide()
		end
	end
end)

if MPrompt then
	MPrompt.Interact.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		end
	end)
end

for _, TopbarButton in ipairs(Topbar:GetChildren()) do
	if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
		TopbarButton.MouseEnter:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		end)

		TopbarButton.MouseLeave:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
		end)
	end
end


function RayfieldLibrary:LoadConfiguration()
	local config

	if debugX then
		warn('Loading Configuration')
	end

	if useStudio then
		config = [[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
	end

	if CEnabled then
		local notified
		local loaded

		local success, result = pcall(function()
			if useStudio and config then
				loaded = LoadConfiguration(config)
				return
			end

			if isfile then 
				if isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
					loaded = LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
				end
			else
				notified = true
				RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We couldn't enable Configuration Saving as you are not using software with filesystem support.", Image = 4384402990})
			end
		end)

		if success and loaded and not notified then
			RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "The configuration file for this script has been loaded from a previous session.", Image = 4384403532})
		elseif not success and not notified then
			warn('Rayfield Configurations Error | '..tostring(result))
			RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.", Image = 4384402990})
		end
	end

	globalLoaded = true
end



if useStudio then
	-- run w/ studio
	-- Feel free to place your own script here to see how it'd work in Roblox Studio before running it on your execution software.


	--local Window = RayfieldLibrary:CreateWindow({
	--	Name = "Rayfield Example Window",
	--	LoadingTitle = "Rayfield Interface Suite",
	--	Theme = 'Default',
	--	Icon = 0,
	--	LoadingSubtitle = "by Sirius",
	--	ConfigurationSaving = {
	--		Enabled = true,
	--		FolderName = nil, -- Create a custom folder for your hub/game
	--		FileName = "Big Hub52"
	--	},
	--	Discord = {
	--		Enabled = false,
	--		Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
	--		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	--	},
	--	KeySystem = false, -- Set this to true to use our key system
	--	KeySettings = {
	--		Title = "Untitled",
	--		Subtitle = "Key System",
	--		Note = "No method of obtaining the key is provided",
	--		FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
	--		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
	--		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
	--		Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	--	}
	--})

	--local CombatTabs = Window:CreateTabSection("Combat")
	--local Tab = Window:CreateTab("Tab Example", 'key-round') -- Title, Image
	--local Tab2 = Window:CreateTab("Tab Example 2", 4483362458) -- Title, Image

	--local Section = Tab2:CreateSection("Section")


	--local ColorPicker = Tab2:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicfsefker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab2:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slidefefsr1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab2:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = '',
	--	PlaceholderText = "Input Placeholder",
	--	Flag = 'dawdawd',
	--	RemoveTextAfterFocusLost = false,
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})


	----RayfieldLibrary:Notify({Title = "Rayfield Interface", Content = "Welcome to Rayfield. These - are the brand new notification design for Rayfield, with custom sizing and Rayfield calculated wait times.", Image = 4483362458})

	--local Section = Tab:CreateSection("Section Example")

	--local Button = Tab:CreateButton({
	--	Name = "Change Theme",
	--	Callback = function()
	--		-- The function that takes place when the button is pressed
	--		Window.ModifyTheme('DarkBlue')
	--	end,
	--})

	--local Toggle = Tab:CreateToggle({
	--	Name = "Toggle Example",
	--	CurrentValue = false,
	--	Flag = "Toggle1adwawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the toggle is pressed
	--		-- The variable (Value) is a boolean on whether the toggle is true or false
	--	end,
	--})

	--local ColorPicker = Tab:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicker1awd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slider1dawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = "Helo",
	--	PlaceholderText = "Adaptive Input",
	--	RemoveTextAfterFocusLost = false,
	--	Flag = 'Input1',
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})

	--local thoptions = {}
	--for themename, theme in pairs(RayfieldLibrary.Theme) do
	--	table.insert(thoptions, themename)
	--end

	--local Dropdown = Tab:CreateDropdown({
	--	Name = "Theme",
	--	Options = thoptions,
	--	CurrentOption = {"Default"},
	--	MultipleOptions = false,
	--	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Options)
	--		--Window.ModifyTheme(Options[1])
	--		-- The function that takes place when the selected option is changed
	--		-- The variable (Options) is a table of strings for the current selected options
	--	end,
	--})


	--Window.ModifyTheme({
	--	TextColor = Color3.fromRGB(50, 55, 60),
	--	Background = Color3.fromRGB(240, 245, 250),
	--	Topbar = Color3.fromRGB(215, 225, 235),
	--	Shadow = Color3.fromRGB(200, 210, 220),

	--	NotificationBackground = Color3.fromRGB(210, 220, 230),
	--	NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

	--	TabBackground = Color3.fromRGB(200, 210, 220),
	--	TabStroke = Color3.fromRGB(180, 190, 200),
	--	TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
	--	TabTextColor = Color3.fromRGB(50, 55, 60),
	--	SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

	--	ElementBackground = Color3.fromRGB(210, 220, 230),
	--	ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
	--	SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
	--	ElementStroke = Color3.fromRGB(190, 200, 210),
	--	SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

	--	SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
	--	SliderProgress = Color3.fromRGB(70, 130, 180),
	--	SliderStroke = Color3.fromRGB(150, 180, 220),

	--	ToggleBackground = Color3.fromRGB(210, 220, 230),
	--	ToggleEnabled = Color3.fromRGB(70, 160, 210),
	--	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	--	ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
	--	ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
	--	ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
	--	ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

	--	DropdownSelected = Color3.fromRGB(220, 230, 240),
	--	DropdownUnselected = Color3.fromRGB(200, 210, 220),

	--	InputBackground = Color3.fromRGB(220, 230, 240),
	--	InputStroke = Color3.fromRGB(180, 190, 200),
	--	PlaceholderColor = Color3.fromRGB(150, 150, 150)
	--})

	--local Keybind = Tab:CreateKeybind({
	--	Name = "Keybind Example",
	--	CurrentKeybind = "Q",
	--	HoldToInteract = false,
	--	Flag = "Keybind1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Keybind)
	--		-- The function that takes place when the keybind is pressed
	--		-- The variable (Keybind) is a boolean for whether the keybind is being held or not (HoldToInteract needs to be true)
	--	end,
	--})

	--local Label = Tab:CreateLabel("Label Example")

	--local Label2 = Tab:CreateLabel("Warning", 4483362458, Color3.fromRGB(255, 159, 49),  true)

	--local Paragraph = Tab:CreateParagraph({Title = "Paragraph Example", Content = "Paragraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph Example"})
end

if CEnabled and Main:FindFirstChild('Notice') then
	Main.Notice.BackgroundTransparency = 1
	Main.Notice.Title.TextTransparency = 1
	Main.Notice.Size = UDim2.new(0, 0, 0, 0)
	Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
	Main.Notice.Visible = true


	TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5}):Play()
	TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.1}):Play()
end
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA why :(
--if not useStudio then
--	task.spawn(loadWithTimeout, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua")
--end

task.delay(4, function()
	RayfieldLibrary.LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)

function RayfieldLibrary:GetDropdownValue(tbl)
if type(tbl) == "table" then
for _,element in ipairs(tbl) do
return tostring(element)
end
else
return tostring(tbl)
end
end

return RayfieldLibrary
end

if game.PlaceId==71895508397153 then
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
end

loadstring([[local RequireService = cloneref or function(clone) return clone end
local BlockInstance = function(e) e.Name = "BlockedInstance_"..math.random(0,500000).."" e.Parent = RequireService(game:GetService("LogService")) e:Destroy() end

local game = game or Ugc
local Players = RequireService(game:GetService("Players"))
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local StarterPlayer = RequireService(game:GetService("StarterPlayer"))
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ReplicatedStorage = RequireService(game:GetService("ReplicatedStorage"))
local ReplicatedFirst = RequireService(game:GetService("ReplicatedFirst"))

local function DestroyGrabLocalScript()
if ReplicatedFirst and ReplicatedFirst:FindFirstChild("Client") and ReplicatedFirst.Client:FindFirstChild("GrabLocal") then
BlockInstance(game.ReplicatedFirst.Client.GrabLocal)
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Bypassed Grab Client!",
	Text = "",
	Duration = 10,
	Button1 = "Alright!"
})
end
end

local function BypassMobileClientAntiCheat()
if StarterPlayerScripts and StarterPlayerScripts:FindFirstChild("ClientAnticheat") and StarterPlayerScripts.ClientAnticheat:FindFirstChild("AntiMobileExploits") then
BlockInstance(StarterPlayerScripts.ClientAnticheat.AntiMobileExploits)
BlockInstance(StarterPlayerScripts.ClientAnticheat)
game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Bypassed Mobile Client Anti-Cheat!",
	Text = "",
	Duration = 10,
	Button1 = "Alright!"
})
end
end

if game.PlaceId == 9431156611 then -- Slap Royale
if hookmetamethod and getnamecallmethod then
local Namecall
Namecall = hookmetamethod(game, "__namecall", function(self, ...)
   if getnamecallmethod() == "FireServer" and tostring(self) == "Ban" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "WalkSpeedChanged" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "WS" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "WS2" then
       return
   end
   return Namecall(self, ...)
end)
else
local AmountOfBlockedRemotes = 0
if game:GetService("ReplicatedStorage").Events:FindFirstChild("Ban") then
BlockInstance(game:GetService("ReplicatedStorage").Events.Ban)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage").Events:FindFirstChild("WS") then
BlockInstance(game:GetService("ReplicatedStorage").Events.WS)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage").Events:FindFirstChild("AdminGUI") then
BlockInstance(game:GetService("ReplicatedStorage").Events.AdminGUI)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage").Events:FindFirstChild("WS2") then
BlockInstance(game:GetService("ReplicatedStorage").Events["WS2"])
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
end
DestroyGrabLocalScript()
BypassMobileClientAntiCheat()


elseif game.PlaceId == 11520107397 or game.PlaceId == 9015014224 or game.PlaceId == 6403373529 or game.PlaceId == 124596094333302 then
if hookmetamethod and getnamecallmethod then
local Namecall
Namecall = hookmetamethod(game, "__namecall", function(self, ...)
   if getnamecallmethod() == "FireServer" and tostring(self) == "Ban" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "WalkSpeedChanged" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "AdminGUI" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "GRAB" then
       return
   elseif getnamecallmethod() == "FireServer" and tostring(self) == "SpecialGloveAccess" then
       return
   end
   return Namecall(self, ...)
end)
else
local AmountOfBlockedRemotes = 0
if game:GetService("ReplicatedStorage"):FindFirstChild("Ban") then
BlockInstance(game:GetService("ReplicatedStorage").Ban)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("WalkSpeedChanged") then
BlockInstance(game:GetService("ReplicatedStorage").WalkSpeedChanged)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("AdminGUI") then
BlockInstance(game:GetService("ReplicatedStorage").AdminGUI)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("GRAB") then
BlockInstance(game:GetService("ReplicatedStorage").GRAB)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
if game:GetService("ReplicatedStorage"):FindFirstChild("SpecialGloveAccess") then
BlockInstance(game:GetService("ReplicatedStorage").SpecialGloveAccess)
AmountOfBlockedRemotes = AmountOfBlockedRemotes + 1
end
end
DestroyGrabLocalScript()
BypassMobileClientAntiCheat()
end]])()

pcall(function()
local gloveremotes = {
    ["Default"] = game:GetService("ReplicatedStorage"):FindFirstChild("b", true),
    ["Diamond"] = game:GetService("ReplicatedStorage"):FindFirstChild("DiamondHit", true),
    ["ZZZZZZZ"] = game:GetService("ReplicatedStorage"):FindFirstChild("ZZZZZZZHit", true),
    ["Extended"] = game:GetService("ReplicatedStorage"):FindFirstChild("b", true),
    ["Dual"] = game:GetService("ReplicatedStorage"):FindFirstChild("DualHit", true),
    ["Brick"] = game:GetService("ReplicatedStorage"):FindFirstChild("BrickHit", true),
    ["Snow"] = game:GetService("ReplicatedStorage"):FindFirstChild("SnowHit", true),
    ["Pull"] = game:GetService("ReplicatedStorage"):FindFirstChild("PullHit", true),
    ["Flash"] = game:GetService("ReplicatedStorage"):FindFirstChild("FlashHit", true),
    ["Spring"] = game:GetService("ReplicatedStorage"):FindFirstChild("springhit", true),
    ["Pinwheel"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Swapper"] = game:GetService("ReplicatedStorage"):FindFirstChild("HitSwapper", true),
    ["Screwdriver"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Bull"] = game:GetService("ReplicatedStorage"):FindFirstChild("BullHit", true),
    ["Dice"] = game:GetService("ReplicatedStorage"):FindFirstChild("DiceHit", true),
    ["Ghost"] = game:GetService("ReplicatedStorage"):FindFirstChild("GhostHit", true),
    ["Thanos"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Stun"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["L.O.L.B.O.M.B"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Za Hando"] = game:GetService("ReplicatedStorage"):FindFirstChild("zhramt", true),
    ["Fort"] = game:GetService("ReplicatedStorage"):FindFirstChild("Fort", true),
    ["Magnet"] = game:GetService("ReplicatedStorage"):FindFirstChild("MagnetHIT", true),
    ["Pusher"] = game:GetService("ReplicatedStorage"):FindFirstChild("PusherHit", true),
    ["Anchor"] = game:GetService("ReplicatedStorage"):FindFirstChild("hitAnchor", true),
    ["Space"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtSpace", true),
    ["Boomerang"] = game:GetService("ReplicatedStorage"):FindFirstChild("BoomerangH", true),
    ["Speedrun"] = game:GetService("ReplicatedStorage"):FindFirstChild("Speedrunhit", true),
    ["Mail"] = game:GetService("ReplicatedStorage"):FindFirstChild("MailHit", true),
    ["T H I C K"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Golden"] = game:GetService("ReplicatedStorage"):FindFirstChild("GoldenHit", true),
    ["Squid"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["MR"] = game:GetService("ReplicatedStorage"):FindFirstChild("MisterHit", true),
    ["Hive"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Reaper"] = game:GetService("ReplicatedStorage"):FindFirstChild("ReaperHit", true),
    ["Baby"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Replica"] = game:GetService("ReplicatedStorage"):FindFirstChild("ReplicaHit", true),
    ["Mace"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Defense"] = game:GetService("ReplicatedStorage"):FindFirstChild("DefenseHit", true),
    ["Offense"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Killstreak"] = game:GetService("ReplicatedStorage"):FindFirstChild("KSHit", true),
    ["Pineslapple"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Reverse"] = game:GetService("ReplicatedStorage"):FindFirstChild("ReverseHit", true),
    ["Shukuchi"] = game:GetService("ReplicatedStorage"):FindFirstChild("ShukuchiHit", true),
    ["Duelist"] = game:GetService("ReplicatedStorage"):FindFirstChild("DuelistHit", true),
    ["woah"] = game:GetService("ReplicatedStorage"):FindFirstChild("woahHit", true),
    ["Ice"] = game:GetService("ReplicatedStorage"):FindFirstChild("IceHit", true),
    ["Gummy"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Adios"] = game:GetService("ReplicatedStorage"):FindFirstChild("hitAdios", true),
    ["Blocked"] = game:GetService("ReplicatedStorage"):FindFirstChild("BlockedHit", true),
    ["Divert"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Engineer"] = game:GetService("ReplicatedStorage"):FindFirstChild("engiehit", true),
    ["Rocky"] = game:GetService("ReplicatedStorage"):FindFirstChild("RockyHit", true),
    ["Coil"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Conveyor"] = game:GetService("ReplicatedStorage"):FindFirstChild("ConvHit", true),
    ["Balloony"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Phantom"] = game:GetService("ReplicatedStorage"):FindFirstChild("PhantomHit", true),
    ["Leafblower"] = game:GetService("ReplicatedStorage"):FindFirstChild("LeafblowerHit", true),
    ["el gato"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Wormhole"] = game:GetService("ReplicatedStorage"):FindFirstChild("WormHit", true),
    ["Shackle"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Flick"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["STOP"] = game:GetService("ReplicatedStorage"):FindFirstChild("STOP", true),
    ["Daredevil"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Equalizer"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Track"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Stalker"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Prop"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Cherry"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Shield"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Clover"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["5 More"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Booster"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Chainsaw"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Ping Pong"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Thumbtack"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Trifecta"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Baller"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Architect"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Home Run"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Friction"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Whirlwind"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Disc"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["BONK"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Grenadier"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Excavator"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Retribution"] = game:GetService("ReplicatedStorage"):FindFirstChild("RetributionHit", true),
    ["Nightmare"] = game:GetService("ReplicatedStorage"):FindFirstChild("nightmarehit", true),
    ["Pylon"] = game:GetService("ReplicatedStorage"):FindFirstChild("PylonHit", true),
    ["Thor"] = game:GetService("ReplicatedStorage"):FindFirstChild("ThorHit", true),
    ["Slime"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Pocket"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Grapple"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Command"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Cloud"] = game:GetService("ReplicatedStorage"):FindFirstChild("CloudHit", true),
    ["Stalagmite"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Gravity"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Helix"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Parry"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Jebaited"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Meteor"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Oven"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Guardian Angel"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Sun"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Ferryman"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Blackhole"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Walrus"] = game:GetService("ReplicatedStorage"):FindFirstChild("WalrusHit", true),
    ["Blink"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Tableflip"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Slapstick"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Beatdown"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Jockey"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Chicken"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Slicer"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Sbeve"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Golem"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Doomsday"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Grab"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["UFO"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Demolition"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Beachball"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Shotgun"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["64"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Roguelike"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Barrel"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Lawnmower"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Virus"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Smiler"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Butcher"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Infinity"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Aggro"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Medusa"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Seal"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Soul"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["R/C"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Mushroom"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Scuba"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Pyromania"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Automaton"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Roaring"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["God's Hand"] = game:GetService("ReplicatedStorage"):FindFirstChild("Godshand", true),
    ["The Flex"] = game:GetService("ReplicatedStorage"):FindFirstChild("FlexHit", true),
    ["MEGAROCK"] = game:GetService("ReplicatedStorage"):FindFirstChild("DiamondHit", true),
    ["Plague"] = game:GetService("ReplicatedStorage"):FindFirstChild("PlagueHit", true),
    ["Hallow Jack"] = game:GetService("ReplicatedStorage"):FindFirstChild("HallowHIT", true),
    ["[REDACTED]"] = game:GetService("ReplicatedStorage"):FindFirstChild("ReHit", true),
    ["bus"] = game:GetService("ReplicatedStorage"):FindFirstChild("hitbus", true),
    ["Mitten"] = game:GetService("ReplicatedStorage"):FindFirstChild("MittenHit", true),
    ["Phase"] = game:GetService("ReplicatedStorage"):FindFirstChild("PhaseH", true),
    ["Warp"] = game:GetService("ReplicatedStorage"):FindFirstChild("WarpHt", true),
    ["Bomb"] = game:GetService("ReplicatedStorage"):FindFirstChild("BombHit", true),
    ["Bubble"] = game:GetService("ReplicatedStorage"):FindFirstChild("BubbleHit", true),
    ["Jet"] = game:GetService("ReplicatedStorage"):FindFirstChild("JetHit", true),
    ["Shard"] = game:GetService("ReplicatedStorage"):FindFirstChild("ShardHIT", true),
    ["CULT"] = game:GetService("ReplicatedStorage"):FindFirstChild("CULTHit", true),
    ["bob"] = game:GetService("ReplicatedStorage"):FindFirstChild("bobhit", true),
    ["buddies"] = game:GetService("ReplicatedStorage"):FindFirstChild("buddiesHIT", true),
    ["Moon"] = game:GetService("ReplicatedStorage"):FindFirstChild("CelestialHit", true),
    ["Jupiter"] = game:GetService("ReplicatedStorage"):FindFirstChild("CelestialHit", true),
    ["Spy"] = game:GetService("ReplicatedStorage"):FindFirstChild("SpyHit", true),
    ["Detonator"] = game:GetService("ReplicatedStorage"):FindFirstChild("DetonatorHit", true),
    ["Rage"] = game:GetService("ReplicatedStorage"):FindFirstChild("GRRRR", true),
    ["Trap"] = game:GetService("ReplicatedStorage"):FindFirstChild("traphi", true),
    ["Orbit"] = game:GetService("ReplicatedStorage"):FindFirstChild("Orbihit", true),
    ["Hybrid"] = game:GetService("ReplicatedStorage"):FindFirstChild("HybridCLAP", true),
    ["Slapple"] = game:GetService("ReplicatedStorage"):FindFirstChild("SlappleHit", true),
    ["Disarm"] = game:GetService("ReplicatedStorage"):FindFirstChild("DisarmH", true),
    ["Dominance"] = game:GetService("ReplicatedStorage"):FindFirstChild("DominanceHit", true),
    ["Link"] = game:GetService("ReplicatedStorage"):FindFirstChild("LinkHit", true),
    ["Chain"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Rattlebones"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Charge"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Tycoon"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Confusion"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Glitch"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Snowball"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Elude"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["RNG"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["fish"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["🗿"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Obby"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Voodoo"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Goofy"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Leash"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Flamarang"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Kinetic"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Berserk"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Sparky"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Boogie"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Recall"] = game:GetService("ReplicatedStorage"):FindFirstChild("HtStun", true),
    ["Quake"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Psycho"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Kraken"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Counter"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Hammer"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["rob"] = game:GetService("ReplicatedStorage"):FindFirstChild("robhit", true),
    ["Rhythm"] = game:GetService("ReplicatedStorage"):FindFirstChild("rhythmhit", true),
    ["Rojo"] = game:GetService("ReplicatedStorage"):FindFirstChild("RojoHit", true),
    ["Hitman"] = game:GetService("ReplicatedStorage"):FindFirstChild("HitmanHit", true),
    ["Retro"] = game:GetService("ReplicatedStorage"):FindFirstChild("RetroHit", true),
    ["Null"] = game:GetService("ReplicatedStorage"):FindFirstChild("NullHit", true),
    ["Lure"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Tinkerer"] = game:GetService("ReplicatedStorage"):FindFirstChild("TinkererHit", true),
    ["Necromancer"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Alchemist"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Druid"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Jester"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Scythe"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Santa"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Iceskate"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Blasphemy"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Pan"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Admin"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Joust"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Firework"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Run"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Glovel"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Divebomb"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Lamp"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Knockoff"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Frostbite"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Plank"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Spoonful"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["the schlob"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Siphon"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Wrench"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Hunter"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Relude"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Avatar"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Water"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Fan"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Boxer"] = game:GetService("ReplicatedStorage"):FindFirstChild("Boxing", true),
    ["MATERIALIZE"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Bind"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Poltergeist"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Clock"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Untitled Tag Glove"] = game:GetService("ReplicatedStorage"):FindFirstChild("UTGHit", true),
    ["Pillow"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Angler"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Jerry"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Snowroller"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Draw4"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Mouse"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Swordfighter"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Tank"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Eggler"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Slender"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Swashbuckler"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Silly"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Slasher"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Car Keys"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Suction"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Reflect"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Dave"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["mortis"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Bounty"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Debug"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Paint"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Plate"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Lag"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Harvester"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Riftshot"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Conker"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Wheelchair"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Shopkeeper"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Collector"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Glaxe"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Piñata"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Penguin"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Undead"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Groundbreaker"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Shellbert"] = game:GetService("ReplicatedStorage"):FindFirstChild("FabergeSwing", true),
    ["Lasso"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Lotus"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Elastic"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["G-X"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Doorkeeper"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Camera"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["OVERKILL"] = game:GetService("ReplicatedStorage"):FindFirstChild("Overkillhit", true),
    ["CUSTOM"] = game:GetService("ReplicatedStorage"):FindFirstChild("CustomHit", true),
    ["Ultra Instinct"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["spin"] = game:GetService("ReplicatedStorage"):FindFirstChild("spinhit", true),
    ["Default but bad"] = game:GetService("ReplicatedStorage"):FindFirstChild("dbb", true),
    ["Stick"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["potato"] = game:GetService("ReplicatedStorage"):FindFirstChild("potatohit", true),
    ["Error"] = game:GetService("ReplicatedStorage"):FindFirstChild("Errorhit", true),
    ["killerfish"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Titan"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true),
    ["Acrobat"] = game:GetService("ReplicatedStorage"):FindFirstChild("AcHit", true),
    ["EverythingElse"] = game:GetService("ReplicatedStorage"):FindFirstChild("GeneralHit", true)
}
function module.EquipGlove(glove)
    repeat fireclickdetector(workspace.Lobby[glove]:FindFirstChildWhichIsA("ClickDetector",true)) task.wait(.1) until LocalPlayer.leaderstats.Glove.Value == glove
    task.wait(.1)
end
function module.TeleportToArena(arena)
local old = workspace.Lobby["Teleport"..tostring(arena)].CFrame
workspace.Lobby["Teleport"..tostring(arena)].CanCollide = false
task.wait()
repeat task.wait() pcall(function() workspace.Lobby["Teleport"..tostring(arena)]:PivotTo(HumanoidRootPart.CFrame) end) until (Character and Character:FindFirstChild("entered")) or (Humanoid and Humanoid.Health==0)
workspace.Lobby["Teleport"..tostring(arena)]:PivotTo(old)
workspace.Lobby["Teleport"..tostring(arena)].CanCollide = true
task.wait(1)
end
function module.TouchObject(object, seconds)
local oldobjectcancollide = object.CanCollide
local oldobjectcframe = object.CFrame
local seconds = seconds or 1/20
if not HumanoidRootPart then return end
object.CanCollide = false
local start = tick()
while tick() - start < seconds do
pcall(function()
object:PivotTo(HumanoidRootPart.CFrame)
end)
task.wait()
end
pcall(function()
object:PivotTo(oldobjectcframe)
end)
pcall(function()
object.CanCollide = oldobjectcancollide
end)
end
function module.Slap(args)
local ChosenRemote = (gloveremotes[LocalPlayer.leaderstats.Glove.Value]~=nil and gloveremotes[LocalPlayer.leaderstats.Glove.Value]) or gloveremotes["EverythingElse"]
pcall(function() ChosenRemote:FireServer(unpack(args)) end)
end
end)

return module
