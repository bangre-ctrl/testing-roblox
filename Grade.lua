-- Grade Hub Standalone
-- GUI prototype: grade toggles + Start/Stop
-- Auto-roll result detection will be connected next.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local grades = {
    {name = "D",  color = Color3.fromRGB(175, 175, 175)},
    {name = "C",  color = Color3.fromRGB(60, 255, 20)},
    {name = "B",  color = Color3.fromRGB(45, 145, 255)},
    {name = "A",  color = Color3.fromRGB(145, 20, 255)},
    {name = "A+", color = Color3.fromRGB(255, 190, 20)},
    {name = "S",  color = Color3.fromRGB(255, 45, 45)},
    {name = "S+", color = Color3.fromRGB(40, 60, 255)},
    {name = "Z",  color = Color3.fromRGB(40, 255, 190)},
    {name = "Z+", color = Color3.fromRGB(255, 50, 180)},
    {name = "神", color = Color3.fromRGB(255, 45, 35)},
    {name = "∞",  color = Color3.fromRGB(150, 255, 110)},
    {name = "Ω",  color = Color3.fromRGB(205, 145, 255)},
}

local enabled = {}
for _, grade in ipairs(grades) do
    enabled[grade.name] = false
end

local old = playerGui:FindFirstChild("GradeHubStandalone")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GradeHubStandalone"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(430, 390)
main.Position = UDim2.new(0.5, -215, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(85, 90, 100)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 38)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "GRADE HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -36, 0, 7)
close.Text = "X"
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(160, 45, 45)
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local grid = Instance.new("Frame")
grid.Position = UDim2.fromOffset(12, 47)
grid.Size = UDim2.new(1, -24, 0, 220)
grid.BackgroundTransparency = 1
grid.Parent = main

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(1/3, -6, 0, 49)
layout.CellPadding = UDim2.fromOffset(6, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 273)
status.Size = UDim2.new(1, -24, 0, 24)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(205, 205, 215)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = main

local running = false

local function refreshButton(button, grade)
    if enabled[grade.name] then
        button.BackgroundColor3 = Color3.fromRGB(45, 105, 45)
        button.TextColor3 = grade.color
    else
        button.BackgroundColor3 = Color3.fromRGB(35, 36, 41)
        button.TextColor3 = grade.color
    end
end

for index, grade in ipairs(grades) do
    local button = Instance.new("TextButton")
    button.Name = "Grade_" .. grade.name
    button.LayoutOrder = index
    button.Text = grade.name
    button.TextSize = 29
    button.Font = Enum.Font.GothamBlack
    button.AutoButtonColor = true
    button.BackgroundColor3 = Color3.fromRGB(35, 36, 41)
    button.TextColor3 = grade.color
    button.Parent = grid

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

    local outline = Instance.new("UIStroke")
    outline.Color = grade.color
    outline.Thickness = 2
    outline.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled[grade.name] = not enabled[grade.name]
        refreshButton(button, grade)
    end)
end

local start = Instance.new("TextButton")
start.Position = UDim2.fromOffset(12, 308)
start.Size = UDim2.new(0.5, -15, 0, 38)
start.Text = "AUTO ROLL"
start.Font = Enum.Font.GothamBold
start.TextSize = 14
start.TextColor3 = Color3.new(1, 1, 1)
start.BackgroundColor3 = Color3.fromRGB(35, 145, 70)
start.Parent = main
Instance.new("UICorner", start).CornerRadius = UDim.new(0, 8)

local stop = Instance.new("TextButton")
stop.Position = UDim2.new(0.5, 3, 0, 308)
stop.Size = UDim2.new(0.5, -15, 0, 38)
stop.Text = "STOP"
stop.Font = Enum.Font.GothamBold
stop.TextSize = 14
stop.TextColor3 = Color3.new(1, 1, 1)
stop.BackgroundColor3 = Color3.fromRGB(165, 45, 45)
stop.Parent = main
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 8)

start.MouseButton1Click:Connect(function()
    if running then return end

    local selected = 0
    for _, grade in ipairs(grades) do
        if enabled[grade.name] then
            selected += 1
        end
    end

    if selected == 0 then
        status.Text = "Status: Aktifkan minimal 1 grade!"
        return
    end

    running = true
    status.Text = "Status: Auto Roll ON — detector belum dipasang"
    -- Next step: connect Roll remote + result detection + Keep/Skip.
end)

stop.MouseButton1Click:Connect(function()
    running = false
    status.Text = "Status: Stopped"
end)
