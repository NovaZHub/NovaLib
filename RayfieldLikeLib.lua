-- RayfieldLikeLib.lua
local RayfieldLike = {}

-- Serviços
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Dados de save
local SaveName = "RayfieldSave.json"
local SaveData = {}

-- Tema padrão
local Theme = {
    Accent = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(25, 25, 25),
    Side = Color3.fromRGB(30, 30, 30),
    Content = Color3.fromRGB(35, 35, 35),
    Button = Color3.fromRGB(45, 45, 45),
    Text = Color3.new(1, 1, 1)
}

-- Load Save
local function LoadSave()
    if isfile(SaveName) then
        local content = readfile(SaveName)
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success then
            SaveData = decoded
            if SaveData["Theme"] then
                for k, v in pairs(SaveData["Theme"]) do
                    Theme[k] = Color3.fromRGB(v.R, v.G, v.B)
                end
            end
        end
    end
end

-- Save
local function Save()
    local encoded = HttpService:JSONEncode(SaveData)
    writefile(SaveName, encoded)
    if RayfieldLike._SaveNotifier then
        RayfieldLike._SaveNotifier.Text = "💾 Salvo!"
        task.delay(1.5, function()
            if RayfieldLike._SaveNotifier then
                RayfieldLike._SaveNotifier.Text = ""
            end
        end)
    end
end

LoadSave()

-- Utilidade
function RayfieldLike:SetThemeColor(which, color)
    if Theme[which] then
        Theme[which] = color
        SaveData["Theme"] = SaveData["Theme"] or {}
        SaveData["Theme"][which] = {
            R = math.floor(color.R * 255),
            G = math.floor(color.G * 255),
            B = math.floor(color.B * 255)
        }
        Save()
    end
end

function RayfieldLike:EnableClickSound()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://9118823100"
    s.Volume = 1
    s.Name = "ClickSound"
    s.Parent = game:GetService("SoundService")
    self._ClickSound = s
end

function RayfieldLike:PlayClick()
    if self._ClickSound then self._ClickSound:Play() end
end

function RayfieldLike:MakeDraggable(frame)
    local dragging, input, start, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and self._Draggable ~= false then
            dragging = true
            start = i.Position
            startPos = frame.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then input = i end end)
    UIS.InputChanged:Connect(function(i)
        if i == input and dragging and self._Draggable ~= false then
            local delta = i.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function RayfieldLike:CreateWindow(config)
    local gui = Instance.new("ScreenGui", game.CoreGui)
    gui.Name = config.Name or "RayfieldLikeUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Active = true
    main.Name = "MainFrame"

    self:MakeDraggable(main)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "RayfieldLike"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Theme.Text

    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 140, 1, -40)
    side.Position = UDim2.new(0, 0, 0, 40)
    side.BackgroundColor3 = Theme.Side

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -140, 1, -40)
    content.Position = UDim2.new(0, 140, 0, 40)
    content.BackgroundColor3 = Theme.Content

    local notifier = Instance.new("TextLabel", main)
    notifier.Size = UDim2.new(0, 100, 0, 20)
    notifier.Position = UDim2.new(1, -110, 0, 10)
    notifier.Font = Enum.Font.Gotham
    notifier.TextSize = 14
    notifier.TextColor3 = Color3.fromRGB(0, 255, 0)
    notifier.BackgroundTransparency = 1
    notifier.TextXAlignment = Enum.TextXAlignment.Right
    notifier.Text = ""
    self._SaveNotifier = notifier

    local tabs = {}
    local function switch(tabFrame)
        for _, f in pairs(content:GetChildren()) do if f:IsA("ScrollingFrame") then f.Visible = false end end
        tabFrame.Visible = true
    end

    function self:CreateTab(data)
        local b = Instance.new("TextButton", side)
        b.Size = UDim2.new(1, 0, 0, 40)
        b.BackgroundTransparency = 1
        b.Text = data.Name or "Tab"
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.Gotham
        b.TextSize = 16

        local frame = Instance.new("ScrollingFrame", content)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.ScrollBarThickness = 5
        frame.CanvasSize = UDim2.new(0, 0, 10, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        frame.Name = "TabFrame"

        local layout = Instance.new("UIListLayout", frame)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        b.MouseButton1Click:Connect(function()
            switch(frame)
        end)

        if #tabs == 0 then switch(frame) end
        table.insert(tabs, frame)

        return frame
    end

    -- Componentes
    function self:CreateButton(tab, conf)
        local b = Instance.new("TextButton", tab)
        b.Size = UDim2.new(1, -20, 0, 40)
        b.Position = UDim2.new(0, 10, 0, 0)
        b.BackgroundColor3 = Theme.Button
        b.Text = conf.Name
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.Gotham
        b.TextSize = 16
        b.BorderSizePixel = 0
        b.MouseButton1Click:Connect(function()
            self:PlayClick()
            if conf.Callback then pcall(conf.Callback) end
        end)
    end

    function self:CreateToggle(tab, conf)
        local t = Instance.new("TextButton", tab)
        t.Size = UDim2.new(1, -20, 0, 40)
        t.BackgroundColor3 = Theme.Button
        t.TextColor3 = Theme.Text
        t.Font = Enum.Font.Gotham
        t.TextSize = 16
        t.BorderSizePixel = 0

        local key = "Toggle_" .. conf.Name
        local state = SaveData[key] or conf.Default or false
        t.Text = (state and "[ ON  ] " or "[ OFF ] ") .. conf.Name

        t.MouseButton1Click:Connect(function()
            state = not state
            t.Text = (state and "[ ON  ] " or "[ OFF ] ") .. conf.Name
            SaveData[key] = state
            Save()
            self:PlayClick()
            if conf.Callback then pcall(conf.Callback, state) end
        end)

        if conf.Callback then pcall(conf.Callback, state) end
    end

    function self:CreateClearSaveButton(tab)
        self:CreateButton(tab, {
            Name = "🧼 Limpar Dados Salvos",
            Callback = function()
                delfile(SaveName)
                warn("Save limpo. Reabra o script.")
            end
        })
    end

    -- Tema Editor
    function self:CreateThemeEditor(tab)
        for _, key in ipairs({"Accent", "Background", "Side", "Content", "Button", "Text"}) do
            for _, c in ipairs({"R", "G", "B"}) do
                self:CreateSlider(tab, {
                    Name = key .. " - " .. c,
                    Min = 0, Max = 255,
                    Default = math.floor((Theme[key][c:lower()] or 0) * 255),
                    Callback = function(val)
                        local old = Theme[key]
                        local r = (c == "R" and val or old.R * 255) / 255
                        local g = (c == "G" and val or old.G * 255) / 255
                        local b = (c == "B" and val or old.B * 255) / 255
                        self:SetThemeColor(key, Color3.new(r, g, b))
                    end
                })
            end
        end
    end

    -- Atalho para esconder GUI
    local visible = true
    UIS.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Enum.KeyCode.RightControl then
            visible = not visible
            gui.Enabled = visible
        end
    end)

    return self
end

return RayfieldLike
