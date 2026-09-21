--[[
    Tower Test GUI
    Standalone test GUI for tower start behavior.
    Xeno / Roblox compatible.

    Tests:
      - Dragon Tower
      - Cursed Tower
      - Pirate Tower
      - Hidden Leaf Tower
      - Slayer Tower
      - Infinity Tower

    Each button:
      1) EquipBestTowerTeam
      2) waits 0.2s
      3) PlayTower(towerName)

    No other Dice/Auto Farm features are included.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy
local old = PlayerGui:FindFirstChild("TowerTestGUI")
if old then
    old:Destroy()
end

local function getNetwork()
    return ReplicatedStorage:WaitForChild("Network", 9e9)
end

local function fireRE(serviceName, remoteName, ...)
    local network = getNetwork()
    local service = network:WaitForChild(serviceName, 9e9)
    local folder = service:WaitForChild("RE", 9e9)
    local remote = folder:WaitForChild(remoteName, 9e9)

    if not remote:IsA("RemoteEvent") then
        error(remote:GetFullName() .. " is " .. remote.ClassName)
    end

    return remote:FireServer(...)
end

local function invokeRF(serviceName, remoteName, ...)
    local network = getNetwork()
    local service = network:WaitForChild(serviceName, 9e9)
    local folder = service:WaitForChild("RF", 9e9)
    local remote = folder:WaitForChild(remoteName, 9e9)

    if not remote:IsA("RemoteFunction") then
        error(remote:GetFullName() .. " is " .. remote.ClassName)
    end

    return remote:InvokeServer(...)
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TowerTestGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(360, 430)
main.Position = UDim2.new(0.5, -180, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 80)
stroke.Thickness = 1
stroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "🏰 Tower Test"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 32)
minimize.Position = UDim2.new(1, -72, 0, 6)
minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minimize.Text = "□"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 17
minimize.Font = Enum.Font.GothamBold
minimize.AutoButtonColor = true
minimize.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 7)
minCorner.Parent = minimize

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -38, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(130, 45, 45)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 15
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = true
close.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -24, 0, 42)
statusLabel.Position = UDim2.fromOffset(12, 52)
statusLabel.BackgroundColor3 = Color3.fromRGB(31, 31, 38)
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(190, 255, 190)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 7)
statusCorner.Parent = statusLabel

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "TowerList"
scroll.Size = UDim2.new(1, -24, 1, -112)
scroll.Position = UDim2.fromOffset(12, 100)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Active = true
scroll.Parent = main

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 2)
padding.PaddingRight = UDim.new(0, 2)
padding.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function status(text)
    statusLabel.Text = "Status: " .. text
end

local function makeButton(text, order, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 48)
    button.LayoutOrder = order
    button.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = true
    button.Parent = scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(65, 65, 78)
    btnStroke.Thickness = 1
    btnStroke.Parent = button

    button.Activated:Connect(callback)
    return button
end

local running = false

local function startTower(towerName)
    if running then
        status("Please wait for the current test...")
        return
    end

    running = true
    status("Equipping team: " .. towerName)

    task.spawn(function()
        local okEquip, equipResult = pcall(function()
            return fireRE("Towers", "EquipBestTowerTeam")
        end)

        print("[Tower Test]", towerName, "EquipBestTowerTeam:", okEquip, equipResult)

        if not okEquip then
            status("Equip failed: " .. towerName)
            warn("[TOWER EQUIP]", towerName, equipResult)
            running = false
            return
        end

        task.wait(0.2)

        status("Calling PlayTower: " .. towerName)

        local okPlay, playResult = pcall(function()
            return invokeRF("Towers", "PlayTower", towerName)
        end)

        print("[Tower Test]", towerName, "PlayTower:", okPlay, playResult)

        if okPlay then
            status(towerName .. " → returned " .. tostring(playResult))
        else
            status(towerName .. " → ERROR")
            warn("[TOWER START]", towerName, playResult)
        end

        running = false
    end)
end

local towers = {
    {"🐉  Dragon Tower", "Dragon Tower"},
    {"☠️  Cursed Tower", "Cursed Tower"},
    {"🏴‍☠️  Pirate Tower", "Pirate Tower"},
    {"🍃  Hidden Leaf Tower", "Hidden Leaf Tower"},
    {"⚔️  Slayer Tower", "Slayer Tower"},
    {"♾️  Infinity Tower", "Infinity Tower"},
}

for i, data in ipairs(towers) do
    makeButton(data[1] .. "  |  START", i, function()
        startTower(data[2])
    end)
end

-- Close
close.Activated:Connect(function()
    gui:Destroy()
end)

-- Minimize / restore
local minimized = false
local normalSize = UDim2.fromOffset(360, 430)
local minimizedSize = UDim2.fromOffset(180, 44)

minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        main.Size = minimizedSize
        title.Text = "🏰 Tower"
        title.TextSize = 15
        title.Size = UDim2.new(1, -90, 1, 0)
        statusLabel.Visible = false
        scroll.Visible = false
        minimize.Text = "□"
    else
        main.Size = normalSize
        title.Text = "🏰 Tower Test"
        title.TextSize = 17
        statusLabel.Visible = true
        scroll.Visible = true
        minimize.Text = "□"
    end
end)

-- Drag
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end
end)

-- Ctrl hide/show
local hidden = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.LeftControl
        or input.KeyCode == Enum.KeyCode.RightControl then

        hidden = not hidden
        main.Visible = not hidden
    end
end)

print("[Tower Test GUI] Loaded")
