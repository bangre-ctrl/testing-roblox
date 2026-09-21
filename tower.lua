--[[
    6 TOWER TEST GUI
    Based directly on the tower logic from the uploaded Dice Gacha Hub.

    Dragon / Cursed / Pirate / Infinity:
        EquipBestTowerTeam -> wait 0.2 -> TowerController.startTower(name)

    Hidden Leaf / Slayer:
        NO_PLAYTOWER:InvokeServer(name)

    This intentionally preserves the original difference so we can test
    all six towers side-by-side.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("TowerTestGUI")
if old then
    old:Destroy()
end

--==================================================
-- REMOTE HELPERS
--==================================================

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

--==================================================
-- TOWER CONTROLLER
--==================================================

local TowerController = nil

pcall(function()
    TowerController = require(
        ReplicatedStorage
            :WaitForChild("Framework", 9e9)
            :WaitForChild("Features", 9e9)
            :WaitForChild("Towers", 9e9)
            :WaitForChild("TowerController")
    )
end)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "TowerTestGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(380, 455)
main.Position = UDim2.new(0.5, -190, 0.5, -227)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(70, 70, 80)
outline.Thickness = 1
outline.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 46)
titleBar.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "🏰 6 Tower Test"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 32)
minimize.Position = UDim2.new(1, -72, 0, 7)
minimize.BackgroundColor3 = Color3.fromRGB(75, 75, 88)
minimize.Text = "□"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 17
minimize.Font = Enum.Font.GothamBold
minimize.BorderSizePixel = 0
minimize.Parent = titleBar
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -38, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 15
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 44)
statusLabel.Position = UDim2.fromOffset(12, 56)
statusLabel.BackgroundColor3 = Color3.fromRGB(31, 31, 39)
statusLabel.BorderSizePixel = 0
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = main
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0, 8)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -24, 1, -116)
list.Position = UDim2.fromOffset(12, 108)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 7
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Active = true
list.Parent = main

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 5)
pad.PaddingBottom = UDim.new(0, 10)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local function setStatus(text)
    statusLabel.Text = "Status: " .. text
end

--==================================================
-- TOWER ACTIONS
--==================================================

local function startDirectTower(name)
    if not TowerController then
        setStatus("TowerController unavailable")
        warn("[TOWER] TowerController unavailable:", name)
        return
    end

    setStatus("EquipBest: " .. name)

    local equipOk, equipResult = pcall(function()
        return fireRE("Towers", "EquipBestTowerTeam")
    end)

    print("========== DIRECT TOWER TEST ==========")
    print("[Tower]", name)
    print("[EquipBest]", equipOk, equipResult)

    if not equipOk then
        setStatus(name .. " → Equip ERROR")
        warn("[TOWER EQUIP]", equipResult)
        return
    end

    task.wait(0.2)

    setStatus("TowerController: " .. name)

    local startOk, started = pcall(function()
        return TowerController.startTower(name)
    end)

    print("[TowerController]", startOk, started)

    if startOk and started then
        setStatus(name .. " → STARTED")
    elseif startOk then
        setStatus(name .. " → returned " .. tostring(started))
        warn("[TOWER START]", name, "returned", started)
    else
        setStatus(name .. " → ERROR")
        warn("[TOWER START]", name, started)
    end

    print("========== END TEST ==========")
end

-- ALL SIX TOWERS USE ONLY THIS FLOW:
-- EquipBestTowerTeam -> wait 0.2 -> TowerController.startTower(name)
local function startTower(name)
    if not TowerController then
        setStatus("TowerController unavailable")
        warn("[TOWER] TowerController unavailable:", name)
        return
    end

    setStatus("EquipBest: " .. name)

    local equipOk, equipResult = pcall(function()
        return fireRE("Towers", "EquipBestTowerTeam")
    end)

    print("========== TOWER TEST ==========")
    print("[Tower]", name)
    print("[EquipBestTowerTeam]", equipOk, equipResult)

    if not equipOk then
        setStatus(name .. " → Equip ERROR")
        warn("[TOWER EQUIP]", name, equipResult)
        return
    end

    task.wait(0.2)

    setStatus("TowerController: " .. name)

    local startOk, started = pcall(function()
        return TowerController.startTower(name)
    end)

    print("[TowerController.startTower]", startOk, started)

    if startOk and started then
        setStatus(name .. " → STARTED")
    elseif startOk then
        setStatus(name .. " → returned " .. tostring(started))
        warn("[TOWER START]", name, "returned", started)
    else
        setStatus(name .. " → ERROR")
        warn("[TOWER START]", name, started)
    end

    print("========== END TOWER TEST ==========")
end

--==================================================
-- BUTTONS
--==================================================

local function makeButton(text, callback, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 48)
    b.LayoutOrder = order
    b.BackgroundColor3 = Color3.fromRGB(52, 52, 63)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Parent = list

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(68, 68, 80)
    s.Thickness = 1
    s.Parent = b

    b.Activated:Connect(callback)
end

-- All six buttons use the exact same startTower() flow.
makeButton("🐉  Dragon Tower  |  START", function()
    startTower("Dragon Tower")
end, 1)

makeButton("☠️  Cursed Tower  |  START", function()
    startTower("Cursed Tower")
end, 2)

makeButton("🏴‍☠️  Pirate Tower  |  START", function()
    startTower("Pirate Tower")
end, 3)

makeButton("🍃  Hidden Leaf Tower  |  START", function()
    startTower("Hidden Leaf Tower")
end, 4)

makeButton("⚔️  Slayer Tower  |  START", function()
    startTower("Slayer Tower")
end, 5)

makeButton("♾️  Infinity Tower  |  START", function()
    startTower("Infinity Tower")
end, 6)

--==================================================
-- CLOSE / MINIMIZE
--==================================================

close.Activated:Connect(function()
    gui:Destroy()
end)

local minimized = false

minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        main.Size = UDim2.fromOffset(180, 44)
        titleBar.Size = UDim2.new(1, 0, 1, 0)

        title.Size = UDim2.new(0, 92, 1, 0)
        title.Position = UDim2.fromOffset(8, 0)
        title.Text = "🏰 Tower"
        title.TextSize = 15

        minimize.Size = UDim2.fromOffset(32, 32)
        minimize.Position = UDim2.new(1, -72, 0, 6)

        close.Size = UDim2.fromOffset(32, 32)
        close.Position = UDim2.new(1, -38, 0, 6)

        statusLabel.Visible = false
        list.Visible = false
    else
        main.Size = UDim2.fromOffset(380, 455)
        titleBar.Size = UDim2.new(1, 0, 0, 46)

        title.Size = UDim2.new(1, -90, 1, 0)
        title.Position = UDim2.fromOffset(12, 0)
        title.Text = "🏰 6 Tower Test"
        title.TextSize = 17

        minimize.Size = UDim2.fromOffset(32, 32)
        minimize.Position = UDim2.new(1, -72, 0, 7)

        close.Size = UDim2.fromOffset(32, 32)
        close.Position = UDim2.new(1, -38, 0, 7)

        statusLabel.Visible = true
        list.Visible = true
    end
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

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
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("========================================")
print("[TowerTestGUI] 6 Tower Test Loaded")
print("[TowerTestGUI] Direct: Dragon/Cursed/Pirate/Infinity")
print("[TowerTestGUI] NO_PLAYTOWER: Hidden Leaf/Slayer")
print("========================================")
