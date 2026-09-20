-- Dice Gacha Hub V18
-- Xeno/LDPlayer robust GUI controls; all V16 features preserved.
-- Auto Roll Dice uses RollService > RF > RollDice
-- Auto Roll UI (SetAutoRoll) removed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- CLEANUP OLD HUB / OLD ANTI-AFK INDICATOR
--==================================================
-- Remove GUI instances from older executions so an old Anti-AFK
-- indicator cannot remain visible after loading this version.
pcall(function()
    local playerGui = player:WaitForChild("PlayerGui")

    local oldAFK = playerGui:FindFirstChild("DiceGachaAntiAFK")
    if oldAFK then
        oldAFK:Destroy()
    end

    local oldHub = playerGui:FindFirstChild("DiceGachaHub")
    if oldHub then
        oldHub:Destroy()
    end
end)

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
        error(remote:GetFullName() .. " is " .. remote.ClassName .. ", expected RemoteEvent")
    end

    return remote:FireServer(...)
end

local function invokeRF(serviceName, remoteName, ...)
    local network = getNetwork()
    local service = network:WaitForChild(serviceName, 9e9)
    local folder = service:WaitForChild("RF", 9e9)
    local remote = folder:WaitForChild(remoteName, 9e9)

    if not remote:IsA("RemoteFunction") then
        error(remote:GetFullName() .. " is " .. remote.ClassName .. ", expected RemoteFunction")
    end

    return remote:InvokeServer(...)
end

--==================================================
-- DICE DATA
--==================================================

local ALL_DICES = {
    {name = "Normal",       price = 1,                  luck = 2,        emoji = "馃幉", displayPrice = "1"},
    {name = "Fire",         price = 2500,               luck = 5,        emoji = "馃敟", displayPrice = "2.5K"},
    {name = "Water",        price = 10000,              luck = 10,       emoji = "馃挧", displayPrice = "10K"},
    {name = "Nature",       price = 75000,              luck = 20,       emoji = "馃尶", displayPrice = "75K"},
    {name = "Lightning",    price = 500000,             luck = 42.5,     emoji = "鈿�", displayPrice = "500K"},
    {name = "Ice",          price = 4000000,            luck = 100,      emoji = "鉂勶笍", displayPrice = "4M"},
    {name = "Magma",        price = 30000000,           luck = 200,      emoji = "馃寢", displayPrice = "30M"},
    {name = "Storm",        price = 200000000,          luck = 400,      emoji = "馃尓锔�", displayPrice = "200M"},
    {name = "Shadow",       price = 1500000000,         luck = 750,      emoji = "馃寫", displayPrice = "1.5B"},
    {name = "Light",        price = 12000000000,        luck = 1500,     emoji = "鉁�", displayPrice = "12B"},
    {name = "Blood Moon",   price = 100000000000,       luck = 3000,     emoji = "馃敶", displayPrice = "100B"},
    {name = "Void",         price = 750000000000,       luck = 6000,     emoji = "馃暢锔�", displayPrice = "750B"},
    {name = "Solar",        price = 5000000000000,      luck = 12500,    luckStr = "12.5k", emoji = "鈽€锔�", displayPrice = "5T"},
    {name = "Lunar",        price = 37500000000000,     luck = 25000,    emoji = "馃寵", displayPrice = "37.5T"},
    {name = "Galaxy",       price = 150000000000000,    luck = 50000,    emoji = "馃寣", displayPrice = "150T"},
    {name = "Black Hole",   price = 1000000000000000,   luck = 100000,   emoji = "鈿�", displayPrice = "1qd"},
    {name = "Dragon",       price = 8500000000000000,   luck = 200000,   emoji = "馃悏", displayPrice = "8.5qd"},
    {name = "Royal",        price = 1e17,               luck = 400000,   emoji = "馃憫", displayPrice = "100qd"},
    {name = "Prismatic",    price = 1e18,               luck = 1000000,  emoji = "馃寛", displayPrice = "1qi"},
    {name = "Arcane",       price = 1.25e19,            luck = 2000000,  emoji = "馃敭", displayPrice = "12qi"},
    {name = "Corrupted",    price = 1.5e20,             luck = 5000000,  emoji = "鈽ｏ笍", displayPrice = "150qi"},
    {name = "Titan",        price = 1e21,               luck = 10000000, emoji = "馃椏", displayPrice = "1sx"},
    {name = "Chrono",       price = 1.5e22,             luck = 25000000, emoji = "鈴�", displayPrice = "15sx"},
}

--==================================================
-- STATE
--==================================================

local autoRollOn = false
local autoFarmOn = false
local autoCollectOn = false
local autoEquipBestOn = false
local autoSellOn = false
local autoRebirthOn = false
local closed = false

--==================================================
-- SELL HELPERS
--==================================================

local function getSellableUUIDs()
    local dataCtrl = ReplicatedStorage
        :WaitForChild("Framework", 9e9)
        :WaitForChild("Features", 9e9)
        :WaitForChild("Data", 9e9)
        :WaitForChild("DataController", 9e9)

    local sellUtil = ReplicatedStorage
        :WaitForChild("Framework", 9e9)
        :WaitForChild("Features", 9e9)
        :WaitForChild("Selling", 9e9)
        :WaitForChild("SellUtil", 9e9)

    local data = require(dataCtrl)
    local util = require(sellUtil)

    local summary = util.CreateSummary(data.Inventory(), data.Slots())
    local uuids = {}

    if summary and summary.sales then
        for _, sale in pairs(summary.sales) do
            if sale and sale.key then
                table.insert(uuids, sale.key)
            end
        end
    end

    return uuids
end

local function sellInventory()
    local uuids = getSellableUUIDs()

    if #uuids == 0 then
        return false, "No sellable items"
    end

    local ok, result = pcall(function()
        return invokeRF("SellService", "SellInventory", uuids)
    end)

    if ok then
        return true, result
    end

    return false, result
end

local function sellEquipped()
    return pcall(function()
        return invokeRF("SellService", "SellEquipped")
    end)
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DiceGachaHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 640, 0, 550)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = gui

--==================================================
-- RESPONSIVE UI SCALE
--==================================================
-- Base design is 680x540.
-- On smaller screens (especially phones), the whole hub
-- scales down proportionally so nothing gets cut off.
local mainScale = Instance.new("UIScale")
mainScale.Name = "ResponsiveScale"
mainScale.Scale = 1
mainScale.Parent = main

local camera = workspace.CurrentCamera

local function updateMainScale()
    camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local minAxis = math.min(viewport.X, viewport.Y)

    -- Normal desktop: 1.0
    -- Small/emulator screens: progressively smaller.
    local scale

    if minAxis <= 600 then
        scale = 0.55
    elseif minAxis <= 720 then
        scale = 0.65
    elseif minAxis <= 800 then
        scale = 0.72
    elseif minAxis <= 900 then
        scale = 0.80
    elseif minAxis <= 1000 then
        scale = 0.88
    else
        scale = 1
    end

    -- Also make sure the complete hub fits inside the viewport.
    local fitX = (viewport.X - 20) / 640
    local fitY = (viewport.Y - 20) / 550
    scale = math.min(scale, fitX, fitY)

    mainScale.Scale = math.clamp(scale, 0.50, 1)
end

updateMainScale()

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMainScale)
end

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

--==================================================
-- TITLE BAR
--==================================================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -130, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "馃幉 Dice Gacha Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 36, 0, 34)
minimize.Position = UDim2.new(1, -78, 0, 7)
minimize.BackgroundColor3 = Color3.fromRGB(75, 75, 88)
minimize.Text = "鈻�"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.BorderSizePixel = 0
minimize.Active = true
minimize.Selectable = false
minimize.ZIndex = 10
minimize.Parent = titleBar

Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 36, 0, 34)
close.Position = UDim2.new(1, -38, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 55)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Active = true
close.Selectable = false
close.ZIndex = 10
close.Parent = titleBar

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

--==================================================
-- STATS
--==================================================

local stats = Instance.new("Frame")
stats.Size = UDim2.new(1, -24, 0, 38)
stats.Position = UDim2.new(0, 12, 0, 56)
stats.BackgroundColor3 = Color3.fromRGB(31, 31, 39)
stats.BorderSizePixel = 0
stats.Parent = main

Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 8)

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0.5, -8, 1, 0)
moneyLabel.Position = UDim2.new(0, 12, 0, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "馃挵 Money: --"
moneyLabel.TextColor3 = Color3.new(1, 1, 1)
moneyLabel.TextSize = 14
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = stats

local rollsLabel = Instance.new("TextLabel")
rollsLabel.Size = UDim2.new(0.5, -8, 1, 0)
rollsLabel.Position = UDim2.new(0.5, 0, 0, 0)
rollsLabel.BackgroundTransparency = 1
rollsLabel.Text = "馃幉 Rolls: --"
rollsLabel.TextColor3 = Color3.new(1, 1, 1)
rollsLabel.TextSize = 14
rollsLabel.Font = Enum.Font.GothamBold
rollsLabel.TextXAlignment = Enum.TextXAlignment.Right
rollsLabel.Parent = stats

--==================================================
-- STATUS
--==================================================

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 25)
statusLabel.Position = UDim2.new(0, 12, 0, 98)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = main

local function status(text)
    if not closed and statusLabel.Parent then
        statusLabel.Text = text
    end
end

--==================================================
-- COLUMNS
--==================================================

local left = Instance.new("ScrollingFrame")
left.Name = "Left"
left.Size = UDim2.new(0, 305, 0, 410)
left.Position = UDim2.new(0, 10, 0, 125)
left.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
left.BorderSizePixel = 0
left.ScrollBarThickness = 7
left.ScrollBarImageTransparency = 0
left.ScrollingEnabled = true
left.ScrollingDirection = Enum.ScrollingDirection.Y
left.AutomaticCanvasSize = Enum.AutomaticSize.Y
left.CanvasSize = UDim2.new(0, 0, 0, 0)
left.Parent = main

Instance.new("UICorner", left).CornerRadius = UDim.new(0, 9)

local right = Instance.new("ScrollingFrame")
right.Name = "Right"
right.Size = UDim2.new(0, 305, 0, 410)
right.Position = UDim2.new(0, 325, 0, 125)
right.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
right.BorderSizePixel = 0
right.ScrollBarThickness = 7
right.ScrollBarImageTransparency = 0
right.ScrollingEnabled = true
right.ScrollingDirection = Enum.ScrollingDirection.Y
right.AutomaticCanvasSize = Enum.AutomaticSize.Y
right.CanvasSize = UDim2.new(0, 0, 0, 0)
right.Parent = main

Instance.new("UICorner", right).CornerRadius = UDim.new(0, 9)

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 8)
leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = left

local leftPad = Instance.new("UIPadding")
leftPad.PaddingTop = UDim.new(0, 10)
leftPad.PaddingBottom = UDim.new(0, 10)
leftPad.PaddingLeft = UDim.new(0, 4)
leftPad.PaddingRight = UDim.new(0, 4)
leftPad.Parent = left

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 8)
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Parent = right

local rightPad = Instance.new("UIPadding")
rightPad.PaddingTop = UDim.new(0, 10)
rightPad.PaddingBottom = UDim.new(0, 10)
rightPad.PaddingLeft = UDim.new(0, 4)
rightPad.PaddingRight = UDim.new(0, 4)
rightPad.Parent = right

leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    -- AutomaticCanvasSize handles the actual scrolling canvas.
    -- Keep a small extra bottom buffer.
    left.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 20)
end)

rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 20)
end)

--==================================================
-- MOBILE / TOUCH SCROLL FIX
--==================================================
-- Some Android emulators do not pass normal touch-wheel scrolling
-- correctly to a ScrollingFrame. Add manual swipe scrolling as a
-- fallback so the lower buttons (Collect/Rebirth/Automation) are
-- always reachable.
left.Active = true
right.Active = true

local function setupTouchScroll(frame, layout)
    local draggingScroll = false
    local dragStartY = 0
    local startCanvasY = 0

    local function insideFrame(position)
        local pos = frame.AbsolutePosition
        local size = frame.AbsoluteSize

        return position.X >= pos.X
            and position.X <= pos.X + size.X
            and position.Y >= pos.Y
            and position.Y <= pos.Y + size.Y
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if not insideFrame(input.Position) then
            return
        end

        draggingScroll = true
        dragStartY = input.Position.Y
        startCanvasY = frame.CanvasPosition.Y
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not draggingScroll then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local deltaY = input.Position.Y - dragStartY
        local contentHeight = math.max(
            layout.AbsoluteContentSize.Y + 24,
            frame.AbsoluteSize.Y
        )
        local maxY = math.max(0, contentHeight - frame.AbsoluteSize.Y)

        local newY = math.clamp(startCanvasY - deltaY, 0, maxY)
        frame.CanvasPosition = Vector2.new(0, newY)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingScroll = false
        end
    end)
end

setupTouchScroll(left, leftLayout)
setupTouchScroll(right, rightLayout)

local function nextLeft()
    return #left:GetChildren()
end

local function nextRight()
    return #right:GetChildren()
end

--==================================================
-- UI HELPERS
--==================================================

local function section(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 210, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #parent:GetChildren()
    label.Parent = parent
    return label
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(52, 52, 63)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Active = true
    b.Selectable = false
    b.LayoutOrder = #parent:GetChildren()
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.Activated:Connect(function()
        pcall(callback)
    end)

    return b
end

local function toggle(parent, text, _, onCallback, offCallback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    b.Text = text .. " : OFF"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Active = true
    b.Selectable = false
    b.LayoutOrder = #parent:GetChildren()
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local enabled = false

    b.Activated:Connect(function()
        enabled = not enabled

        if enabled then
            b.Text = text .. " : ON"
            b.BackgroundColor3 = Color3.fromRGB(45, 155, 75)
            pcall(onCallback)
        else
            b.Text = text .. " : OFF"
            b.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            pcall(offCallback)
        end
    end)

    return b
end

--==================================================
-- LEFT MENU
--==================================================

section(left, "馃幉 GACHA")

button(left, "馃幉 Roll Dice", function()
    local ok, result = pcall(function()
        return invokeRF("RollService", "RollDice")
    end)

    if ok then
        status("Roll berhasil")
    else
        status("Roll error")
        warn("[Roll]", result)
    end
end)

toggle(
    left,
    "馃幉 Auto Roll Dice",
    nextLeft(),
    function()
        autoRollOn = true
        status("Auto Roll Dice: ON")

        task.spawn(function()
            while autoRollOn and not closed do
                pcall(function()
                    invokeRF("RollService", "RollDice")
                end)

                task.wait(0.3)
            end
        end)
    end,
    function()
        autoRollOn = false
        status("Auto Roll Dice: OFF")
    end
)

section(left, "鈿旓笍 EQUIP")

button(left, "馃帓 Buka 
