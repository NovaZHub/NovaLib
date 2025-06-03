local NovaLib = {}
NovaLib.Settings = {
    LibName = "NovaLib",
    Version = "1.0",
    ExecutorWhitelist = {
        ["Delta"] = true,
        ["KRNL"] = true,
        ["Cryptic"] = true
    }
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

function NovaLib.CheckExecutor()
    local exec = identifyexecutor and identifyexecutor() or "Desconhecido"
    if NovaLib.Settings.ExecutorWhitelist[exec] then
        return true, exec
    else
        return false, exec
    end
end

function NovaLib.Notify(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title or "NovaLib",
        Text = text or "Sem mensagem.",
        Duration = duration or 5
    })
end

function NovaLib:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = title or "NovaLibGui"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Name = "MainFrame"
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Sidebar.Name = "Sidebar"

    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.Text = title or "NovaLib"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 20

    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Size = UDim2.new(1, -120, 1, 0)
    TabHolder.Position = UDim2.new(0, 120, 0, 0)
    TabHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabHolder.Name = "TabHolder"

    local UIPageLayout = Instance.new("UIPageLayout", TabHolder)
    UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIPageLayout.EasingDirection = Enum.EasingDirection.InOut
    UIPageLayout.EasingStyle = Enum.EasingStyle.Quad
    UIPageLayout.TweenTime = 0.4
    UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
    UIPageLayout.Padding = UDim.new(0, 10)

    local Tabs = {}

    function Tabs:CreateTab(name)
        local Button = Instance.new("TextButton", Sidebar)
        Button.Size = UDim2.new(1, 0, 0, 40)
        Button.Text = name
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.SourceSans
        Button.TextSize = 18

        local Tab = Instance.new("ScrollingFrame", TabHolder)
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.ScrollBarThickness = 6
        Tab.BackgroundTransparency = 1

        local Layout = Instance.new("UIListLayout", Tab)
        Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder

        Button.MouseButton1Click:Connect(function()
            UIPageLayout:JumpTo(Tab)
        end)

        local Elements = {}

        function Elements:AddButton(text, callback)
            local btn = Instance.new("TextButton", Tab)
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.Text = text
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 18
            btn.MouseButton1Click:Connect(callback)
        end

        return Elements
    end

    return Tabs
end

function NovaLib:Start()
    local status, exec = NovaLib.CheckExecutor()
    if not status then
        NovaLib.Notify("Executor inseguro!", "Você será expulso.", 5)
        wait(5)
        Player:Kick("Eu te avisei >:(")
    else
        NovaLib.Notify("Executor aprovado", "Executor: " .. exec, 5)
    end
end

return NovaLib
