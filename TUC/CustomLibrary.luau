local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local Library = {}
local Window = {}
local Tab = {}
local Section = {}
Window.__index = Window
Tab.__index = Tab
Section.__index = Section

local white = Color3.new(1, 1, 1)
local black = Color3.new(0, 0, 0)
local theme = table.freeze({
    White = white,
    Selected = Color3.fromRGB(8, 192, 9),
    Human = Color3.fromRGB(255, 203, 16),
    Zombie = Color3.fromRGB(81, 235, 78),
    Credit = Color3.fromRGB(255, 226, 56),
    Health = Color3.fromRGB(146, 221, 48),
    Danger = Color3.fromRGB(255, 33, 33),
    Stamina = Color3.fromRGB(85, 170, 255),
    StaminaTrack = Color3.fromRGB(85, 85, 255),
    BarText = Color3.fromRGB(0, 0, 255),
    TabHover = Color3.fromRGB(208, 208, 208),
    TrayTransparency = 0.9,
    TileTransparency = 0.8,
    EmoteTransparency = 0.7,
})
Library.Theme = theme

local font = Font.fromEnum(Enum.Font.Cartoon)
local bold = Font.new(font.Family, Enum.FontWeight.Bold)
local left = Enum.TextXAlignment.Left
local right = Enum.TextXAlignment.Right
local full = UDim2.fromScale(1, 1)

local function make(class, parent, properties)
    local object = Instance.new(class)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end

local function round(object, scale)
    make("UICorner", object, {CornerRadius = UDim.new(scale or 0.1, 0)})
end

local function outline(object, color, transparency, thickness)
    return make("UIStroke", object, {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency,
        Thickness = thickness,
    })
end

local function frame(parent, size, position, transparency, color)
    return make("Frame", parent, {
        Size = size, Position = position, BorderSizePixel = 0,
        BackgroundColor3 = color or white, BackgroundTransparency = transparency,
    })
end

local function words(parent, content, size, position, textSize, align, color, weight)
    return make("TextLabel", parent, {
        BackgroundTransparency = 1, Size = size, Position = position,
        FontFace = weight or font, Text = tostring(content), TextSize = textSize,
        TextColor3 = color or white, TextStrokeColor3 = black, TextStrokeTransparency = 0.6,
        TextXAlignment = align or Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function bindClickSound(control)
    local screen = control:FindFirstAncestorWhichIsA("ScreenGui")
    local sound = screen and screen:FindFirstChild("ClickSound")
    if not sound then return end

    local function play() SoundService:PlayLocalSound(sound) end
    if control:IsA("GuiButton") then
        control.Activated:Connect(play)
    elseif control:IsA("TextBox") then
        control.Focused:Connect(play)
    end
end

local function tile(parent, content, size, position, alpha)
    local button = make("TextButton", parent, {
        Size = size, Position = position, BackgroundColor3 = white,
        BackgroundTransparency = alpha or theme.EmoteTransparency, BorderSizePixel = 0,
        AutoButtonColor = false, FontFace = font, TextSize = 16, Text = tostring(content),
        TextColor3 = white, TextStrokeColor3 = black, TextStrokeTransparency = 0.5,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    bindClickSound(button)
    round(button)
    return button, outline(button, black, 0.8, 1)
end

local function selection(stroke, enabled)
    stroke.Color = enabled and theme.Selected or black
    stroke.Thickness = enabled and 3 or 1
    stroke.Transparency = enabled and 0 or 0.8
end

local function stack(parent, gap, direction)
    return make("UIListLayout", parent, {
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap),
    })
end

local function callback(fn, ...)
    if not fn then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SurvivorUI] " .. tostring(err)) end
end

local function valueControl(initial, render, changed)
    local value = initial
    local control = {}
    function control:Get() return value end
    function control:Set(nextValue, silent)
        local normalized = render(nextValue)
        if normalized == value then return end
        value = normalized
        if not silent then callback(changed, value) end
    end
    value = render(initial)
    return control
end

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function xy(input)
    return Vector2.new(input.Position.X, input.Position.Y)
end

function Library:CreateWindow(options)
    options = options or {}
    local parent = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local hotkey = options.ToggleKey or Enum.KeyCode.RightShift
    local cursorKey = options.CursorKey
    local forceCursor = options.ForceCursor == true
    local width = math.clamp(options.Width or 560, 440, 760)
    local height = math.clamp(options.Height or 452, 320, 650)
    local screen = make("ScreenGui", nil, {
        Name = options.Id or "SurvivorUI", ResetOnSpawn = false,
        DisplayOrder = options.DisplayOrder or 30, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    make("Sound", screen, {Name = "ClickSound", SoundId = "rbxassetid://12221976", Volume = 0.5})
    local hoverSound = make("Sound", screen, {Name = "TabHoverSound", SoundId = "rbxassetid://12222170", Volume = 0.4})
    local canvas = frame(screen, full, UDim2.new(), 1)
    local modal
    if options.CaptureMouse == true then
        modal = make("TextButton", canvas, {
            Name = "Modal", Size = full, BackgroundTransparency = 1, Text = "",
            Modal = true, Selectable = false, Visible = false,
        })
    end

    local shell = frame(canvas, UDim2.fromOffset(width, height), UDim2.fromScale(0.5, 0.5), theme.TrayTransparency)
    shell.Name = "Window"
    shell.AnchorPoint = Vector2.new(0.5, 0.5)
    shell.Active = true
    round(shell)
    local scale = make("UIScale", shell, {Scale = 1})
    local header = frame(shell, UDim2.new(1, -104, 0, 42), UDim2.fromOffset(12, 4), 1)
    header.Active = true
    words(header, options.Title or "SURVIVOR", full, UDim2.new(), 31, left)
    local close = tile(shell, "[ Hide ]", UDim2.fromOffset(76, 31), UDim2.new(1, -88, 0, 10), theme.TileTransparency)

    local tabs = make("ScrollingFrame", shell, {
        Name = "Tabs", Size = UDim2.new(1, -24, 0, 49), Position = UDim2.fromOffset(12, 51),
        BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = 2, ScrollBarImageColor3 = white, Selectable = false,
    })
    stack(tabs, 6, Enum.FillDirection.Horizontal)
    make("UIPadding", tabs, {PaddingLeft = UDim.new(0, 4), PaddingTop = UDim.new(0, 4)})
    local body = frame(shell, UDim2.new(1, -24, 1, -128), UDim2.fromOffset(12, 108), 1)
    local hint = "[" .. hotkey.Name .. "]"
    local footer = hint .. "  Hide menu"
    if cursorKey and Input.KeyboardEnabled then
        footer = "[Hold " .. cursorKey.Name .. "]  Cursor     " .. footer
    end
    words(shell, footer, UDim2.new(1, -24, 0, 19), UDim2.new(0, 12, 1, -19), 13, right)
    local reopen = tile(canvas, hint .. "  Menu", UDim2.fromOffset(130, 28), UDim2.new(1, -142, 0, 34), theme.TileTransparency)
    reopen.Name = "Reopen"
    local feed = frame(canvas, UDim2.fromOffset(300, 132), UDim2.new(1, -312, 0.5, 4), 1)
    feed.Name = "Notifications"
    stack(feed, 3)

    local window = setmetatable({
        Gui = screen, _shell = shell, _modal = modal, _reopen = reopen, _showReopen = options.ShowReopen ~= false,
        _hoverSound = hoverSound,
        _tabs = tabs, _body = body, _feed = feed, _pages = {}, _notifications = {}, _connections = {}, _binds = {},
        _nextNotice = 0, _offset = options.Offset or Vector2.zero, _visible = true,
        _forceCursor = forceCursor,
        _cursorBinding = (forceCursor or cursorKey) and ("SurvivorUI_" .. HttpService:GenerateGUID(false)) or nil,
    }, Window)

    local function position(offset)
        local max = (canvas.AbsoluteSize - Vector2.new(width, height) * scale.Scale) / 2
        local x, y = math.max(0, max.X - 4), math.max(0, max.Y - 4)
        window._offset = Vector2.new(math.clamp(offset.X, -x, x), math.clamp(offset.Y, -y, y))
        shell.Position = UDim2.new(0.5, window._offset.X, 0.5, window._offset.Y)
    end

    local function resize()
        local size = canvas.AbsoluteSize
        scale.Scale = math.clamp(math.min((size.X - 24) / width, (size.Y - 24) / height), 0.1, 1)
        position(window._offset)
    end

    header.InputBegan:Connect(function(input)
        if isPointer(input) then
            window._pointer = {Input = input, Start = xy(input), Offset = window._offset, Move = position}
        end
    end)
    close.Activated:Connect(function() window:SetVisible(false) end)
    reopen.Activated:Connect(function() window:SetVisible(true) end)
    canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
    table.insert(window._connections, Input.InputChanged:Connect(function(input)
        local pointer = window._pointer
        if not pointer then return end
        local mouseDrag = pointer.Input.UserInputType == Enum.UserInputType.MouseButton1
        if input == pointer.Input or (mouseDrag and input.UserInputType == Enum.UserInputType.MouseMovement) then
            pointer.Move(pointer.Offset + xy(input) - pointer.Start)
        end
    end))
    table.insert(window._connections, Input.InputEnded:Connect(function(input)
        local pointer = window._pointer
        if pointer and input == pointer.Input then window._pointer = nil end
        if input.KeyCode == cursorKey and window._cursorHeld then
            window._cursorHeld = false
            window:_updateCursor()
        end
    end))
    if cursorKey then
        table.insert(window._connections, Input.WindowFocusReleased:Connect(function()
            window._cursorHeld = false
            window:_updateCursor()
        end))
    end
    table.insert(window._connections, Input.InputBegan:Connect(function(input, processed)
        if Input:GetFocusedTextBox() or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if window._capture then
            local capture = window._capture
            window._capture = nil
            capture(input.KeyCode)
            return
        end
        if processed then return end
        if input.KeyCode == hotkey then
            window:SetVisible(not window._visible)
            return
        end
        if input.KeyCode == cursorKey and window._visible then
            window._cursorHeld = true
            window:_updateCursor()
            return
        end
        for _, binding in ipairs(window._binds) do
            if binding.Control:Get() == input.KeyCode then callback(binding.Activated, input.KeyCode) end
        end
    end))
    screen.Destroying:Connect(function()
        window:_releaseCursor()
        window._destroyed = true
        window._pointer, window._capture = nil, nil
        for _, connection in ipairs(window._connections) do connection:Disconnect() end
        table.clear(window._connections)
    end)
    screen.Parent = parent
    resize()
    window:SetVisible(options.Visible ~= false)
    return window
end

function Window:_releaseCursor()
    local previous = self._cursorBefore
    if not previous then return end
    RunService:UnbindFromRenderStep(self._cursorBinding)
    Input.MouseBehavior = previous.Behavior
    Input.MouseIconEnabled = previous.Icon
    self._cursorBefore = nil
end

function Window:_updateCursor()
    if not (self._visible and (self._forceCursor or self._cursorHeld)) then
        self:_releaseCursor()
        return
    end
    if self._cursorBefore then return end
    self._cursorBefore = {Behavior = Input.MouseBehavior, Icon = Input.MouseIconEnabled}
    RunService:BindToRenderStep(self._cursorBinding, Enum.RenderPriority.Last.Value + 1, function()
        Input.MouseBehavior = Enum.MouseBehavior.Default
        Input.MouseIconEnabled = true
    end)
end

function Window:SetVisible(visible)
    if self._destroyed then return end
    self._visible = visible == true
    self._shell.Visible = self._visible
    if self._modal then self._modal.Visible = self._visible end
    self._reopen.Visible = not self._visible and self._showReopen
    if not self._visible then
        self._cursorHeld = false
        self._pointer = nil
        local capture = self._capture
        self._capture = nil
        if capture then capture(Enum.KeyCode.Escape) end
    end
    self:_updateCursor()
end

function Window:Destroy()
    if self._destroyed then return end
    self:_releaseCursor()
    self.Gui:Destroy()
end

function Window:Notify(options)
    if self._destroyed then return end
    if type(options) == "string" then options = {Text = options} end
    self._nextNotice += 1
    local notice = words(self._feed, options.Text or "", UDim2.fromOffset(300, 22), UDim2.new(), 18, right, options.Color or theme.Credit)
    notice.LayoutOrder = self._nextNotice
    table.insert(self._notifications, notice)
    if #self._notifications > 5 then
        local oldest = table.remove(self._notifications, 1)
        if oldest then oldest:Destroy() end
    end
    task.delay(math.max(0, options.Duration or 3), function()
        local index = table.find(self._notifications, notice)
        if index then
            table.remove(self._notifications, index)
            if notice.Parent then notice:Destroy() end
        end
    end)
end

function Window:CreateTab(options)
    if type(options) == "string" then options = {Name = options} end
    local name = options.Name or "Tab"
    local button, stroke = tile(self._tabs, name, UDim2.fromOffset(options.Width or 124, 39), UDim2.new())
    button.Name = name
    button.LayoutOrder = #self._pages + 1
    local page = make("ScrollingFrame", self._body, {
        Name = name, Size = full, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = white, Visible = false, Selectable = false,
    })
    stack(page, 10)
    local tab = setmetatable({_window = self, _page = page, _stroke = stroke, _sections = 0}, Tab)
    table.insert(self._pages, tab)
    button.MouseEnter:Connect(function()
        if not Input.MouseEnabled then return end
        button.BackgroundColor3 = theme.TabHover
        SoundService:PlayLocalSound(self._hoverSound)
    end)
    button.MouseLeave:Connect(function() button.BackgroundColor3 = white end)
    button.Activated:Connect(function() tab:Select() end)
    if #self._pages == 1 then tab:Select() end
    return tab
end

function Tab:Select()
    for _, tab in ipairs(self._window._pages) do
        tab._page.Visible = tab == self
        selection(tab._stroke, tab == self)
    end
end

function Tab:CreateSection(options)
    if type(options) == "string" then options = {Name = options} end
    local group = frame(self._page, UDim2.new(1, -9, 0, 0), UDim2.new(), 1)
    self._sections += 1
    group.LayoutOrder = self._sections
    group.AutomaticSize = Enum.AutomaticSize.Y
    stack(group, 5)
    local heading = frame(group, UDim2.new(1, 0, 0, 25), UDim2.new(), 1)
    local color = options.Color or theme.Human
    words(heading, options.Name or "Controls", UDim2.new(1, -8, 1, -2), UDim2.fromOffset(4, 0), 20, left, color)
    frame(heading, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), 0, color)
    return setmetatable({_window = self._window, _group = group, _rows = 0}, Section)
end

function Section:_row(name, height, textWidth)
    local row = frame(self._group, UDim2.new(1, 0, 0, height or 42), UDim2.new(), theme.TileTransparency)
    row.Name = tostring(name)
    self._rows += 1
    row.LayoutOrder = self._rows
    round(row)
    local label = words(row, name, textWidth or UDim2.new(0.47, -10, 0, height or 42), UDim2.fromOffset(10, 0), 17, left)
    return row, label
end

function Section:AddLabel(options)
    if type(options) == "string" then options = {Text = options} end
    local _, label = self:_row(options.Text or "", 36, UDim2.new(1, -20, 0, 36))
    if options.Color then label.TextColor3 = options.Color end
    return valueControl(label.Text, function(value)
        label.Text = tostring(value)
        return label.Text
    end)
end

function Section:AddButton(options)
    local row = self:_row(options.Name or "Button")
    local button = tile(row, options.Text or "[ Use ]", UDim2.new(0.49, -8, 0, 28), UDim2.new(0.51, 0, 0, 7))
    local function activate() callback(options.Callback) end
    button.Activated:Connect(activate)
    return {Press = activate}
end

function Section:AddToggle(options)
    local row = self:_row(options.Name or "Toggle")
    local button, stroke = tile(row, "", UDim2.new(0.49, -8, 0, 28), UDim2.new(0.51, 0, 0, 7))
    local control = valueControl(options.Default == true, function(value)
        local enabled = value == true
        button.Text = enabled and "[ On ]" or "[ Off ]"
        selection(stroke, enabled)
        return enabled
    end, options.Callback)
    button.Activated:Connect(function() control:Set(not control:Get()) end)
    return control
end

function Section:AddSlider(options)
    local min, max, step = options.Min or 0, options.Max or 100, options.Step or 1
    assert(max > min and step > 0, "Slider needs Max > Min and Step > 0")
    local row = self:_row(options.Name or "Slider")
    local track = make("TextButton", row, {
        Size = UDim2.new(0.49, -8, 0, 22), Position = UDim2.new(0.51, 0, 0, 10), Text = "",
        BackgroundColor3 = options.HealthStyle and theme.Danger or theme.StaminaTrack,
        BorderSizePixel = 0, AutoButtonColor = false,
    })
    bindClickSound(track)
    round(track, 0.4)
    local fill = frame(track, full, UDim2.new(), 0, options.HealthStyle and theme.Health or theme.Stamina)
    round(fill, 0.4)
    local number = words(track, "", full, UDim2.new(), 16, nil, theme.BarText, bold)
    number.TextStrokeTransparency = 1
    local control = valueControl(options.Default or min, function(value)
        value = math.clamp(tonumber(value) or min, min, max)
        if value ~= max then value = math.clamp(min + math.round((value - min) / step) * step, min, max) end
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
        number.Text = string.format("%.7g", value) .. (options.Suffix or "")
        return value
    end, options.Callback)
    local function update(pos)
        local fraction = math.clamp((pos.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        control:Set(min + fraction * (max - min))
    end
    local window = self._window
    track.InputBegan:Connect(function(input)
        if not isPointer(input) then return end
        window._pointer = {Input = input, Start = xy(input), Offset = xy(input), Move = update}
        update(xy(input))
    end)
    track.Activated:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            control:Set(control:Get() >= max and min or control:Get() + step)
        end
    end)
    return control
end

function Section:AddDropdown(options)
    local values = table.clone(options.Values or {})
    local row = self:_row(options.Name or "Dropdown")
    local button, stroke = tile(row, "", UDim2.new(0.49, -8, 0, 28), UDim2.new(0.51, 0, 0, 7))
    local list = frame(row, UDim2.new(1, -16, 0, #values * 29), UDim2.fromOffset(8, 42), 1)
    stack(list, 3)
    local open = false
    local control = valueControl(options.Default, function(value)
        if not table.find(values, value) then value = nil end
        button.Text = value == nil and "[ Select ]" or "[ " .. tostring(value) .. " ]"
        return value
    end, options.Callback)
    local function expand(visible)
        open = visible and #values > 0
        list.Visible = open
        row.Size = UDim2.new(1, 0, 0, open and 46 + #values * 29 or 42)
        selection(stroke, open)
    end
    expand(false)
    for index, value in ipairs(values) do
        local option = tile(list, value, UDim2.new(1, 0, 0, 26), UDim2.new())
        option.LayoutOrder = index
        option.Activated:Connect(function()
            expand(false)
            control:Set(value)
        end)
    end
    button.Activated:Connect(function() expand(not open) end)
    return control
end

function Section:AddInput(options)
    local row = self:_row(options.Name or "Input")
    local box = make("TextBox", row, {
        Size = UDim2.new(0.49, -8, 0, 28), Position = UDim2.new(0.51, 0, 0, 7),
        BackgroundColor3 = white, BackgroundTransparency = theme.EmoteTransparency, BorderSizePixel = 0,
        ClearTextOnFocus = false, Text = "", PlaceholderText = options.Placeholder or "Type here",
        PlaceholderColor3 = white, FontFace = font, TextColor3 = white, TextSize = 16,
        TextStrokeColor3 = black, TextStrokeTransparency = 0.5,
    })
    bindClickSound(box)
    round(box)
    local stroke = outline(box, black, 0.8, 1)
    local control = valueControl(options.Default or "", function(value)
        box.Text = tostring(value or "")
        return box.Text
    end, options.Callback)
    box.Focused:Connect(function() selection(stroke, true) end)
    box.FocusLost:Connect(function()
        selection(stroke, false)
        control:Set(box.Text)
    end)
    return control
end

function Section:AddKeybind(options)
    local row = self:_row(options.Name or "Keybind")
    local button, stroke = tile(row, "", UDim2.new(0.49, -8, 0, 28), UDim2.new(0.51, 0, 0, 7))
    local control = valueControl(options.Default or Enum.KeyCode.Unknown, function(value)
        assert(typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode, "Expected an Enum.KeyCode")
        button.Text = value == Enum.KeyCode.Unknown and "[ Unbound ]" or "[ " .. value.Name .. " ]"
        return value
    end, options.Changed)
    local window = self._window
    table.insert(window._binds, {Control = control, Activated = options.Callback})
    button.Activated:Connect(function()
        if window._capture then window._capture(Enum.KeyCode.Escape) end
        button.Text = "[ Press a key ]"
        selection(stroke, true)
        window._capture = function(key)
            selection(stroke, false)
            if key == Enum.KeyCode.Escape then key = control:Get() end
            if key == Enum.KeyCode.Backspace then key = Enum.KeyCode.Unknown end
            control:Set(key)
        end
    end)
    return control
end

return Library
