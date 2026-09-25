-- Dice Gacha Hub V9
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
    {name = "Normal",       price = 1,                  luck = 2,        emoji = "🎲", displayPrice = "1"},
    {name = "Fire",         price = 2500,               luck = 5,        emoji = "🔥", displayPrice = "2.5K"},
    {name = "Water",        price = 10000,              luck = 10,       emoji = "💧", displayPrice = "10K"},
    {name = "Nature",       price = 75000,              luck = 20,       emoji = "🌿", displayPrice = "75K"},
    {name = "Lightning",    price = 500000,             luck = 42.5,     emoji = "⚡", displayPrice = "500K"},
    {name = "Ice",          price = 4000000,            luck = 100,      emoji = "❄️", displayPrice = "4M"},
    {name = "Magma",        price = 30000000,           luck = 200,      emoji = "🌋", displayPrice = "30M"},
    {name = "Storm",        price = 200000000,          luck = 400,      emoji = "🌪️", displayPrice = "200M"},
    {name = "Shadow",       price = 1500000000,         luck = 750,      emoji = "🌑", displayPrice = "1.5B"},
    {name = "Light",        price = 12000000000,        luck = 1500,     emoji = "✨", displayPrice = "12B"},
    {name = "Blood Moon",   price = 100000000000,       luck = 3000,     emoji = "🔴", displayPrice = "100B"},
    {name = "Void",         price = 750000000000,       luck = 6000,     emoji = "🕳️", displayPrice = "750B"},
    {name = "Solar",        price = 5000000000000,      luck = 12500,    luckStr = "12.5k", emoji = "☀️", displayPrice = "5T"},
    {name = "Lunar",        price = 37500000000000,     luck = 25000,    emoji = "🌙", displayPrice = "37.5T"},
    {name = "Galaxy",       price = 150000000000000,    luck = 50000,    emoji = "🌌", displayPrice = "150T"},
    {name = "Black Hole",   price = 1000000000000000,   luck = 100000,   emoji = "⚫", displayPrice = "1qd"},
    {name = "Dragon",       price = 8500000000000000,   luck = 200000,   emoji = "🐉", displayPrice = "8.5qd"},
    {name = "Royal",        price = 1e17,               luck = 400000,   emoji = "👑", displayPrice = "100qd"},
    {name = "Prismatic",    price = 1e18,               luck = 1000000,  emoji = "🌈", displayPrice = "1qi"},
    {name = "Arcane",       price = 1.25e19,            luck = 2000000,  emoji = "🔮", displayPrice = "12qi"},
    {name = "Corrupted",    price = 1.5e20,             luck = 5000000,  emoji = "☣️", displayPrice = "150qi"},
    {name = "Titan",        price = 1e21,               luck = 10000000, emoji = "🗿", displayPrice = "1sx"},
    {name = "Chrono",       price = 1.5e22,             luck = 25000000, emoji = "⏳", displayPrice = "15sx"},
}

--==================================================
-- STATE
--==================================================

local autoRollOn = false
local autoCollectOn = false
local autoDailyQuestOn = false
local autoWeeklyQuestOn = false
local autoQuestShopOn = false
local closed = false

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
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -130, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎲 Dice Gacha Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 36, 0, 34)
minimize.Position = UDim2.new(1, -78, 0, 7)
minimize.BackgroundColor3 = Color3.fromRGB(75, 75, 88)
minimize.Text = "□"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.BorderSizePixel = 0
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
moneyLabel.Text = "💰 Money: --"
moneyLabel.TextColor3 = Color3.new(1, 1, 1)
moneyLabel.TextSize = 14
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Parent = stats

local rollsLabel = Instance.new("TextLabel")
rollsLabel.Size = UDim2.new(0.5, -8, 1, 0)
rollsLabel.Position = UDim2.new(0.5, 0, 0, 0)
rollsLabel.BackgroundTransparency = 1
rollsLabel.Text = "🎲 Rolls: --"
rollsLabel.TextColor3 = Color3.new(1, 1, 1)
rollsLabel.TextSize = 14
rollsLabel.Font = Enum.Font.GothamBold
rollsLabel.TextXAlignment = Enum.TextXAlignment.Right
rollsLabel.Parent = stats

--==================================================
-- MINI STATS (shown while minimized)
--==================================================

local miniFrame = Instance.new("Frame")
miniFrame.Name = "MiniStats"
miniFrame.Size = UDim2.new(0, 220, 0, 104)
miniFrame.Position = UDim2.new(0.5, -110, 0, 10)
miniFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
miniFrame.BorderSizePixel = 0
miniFrame.Visible = false
miniFrame.Active = true
miniFrame.Parent = gui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniFrame

local miniTitle = Instance.new("TextLabel")
miniTitle.Size = UDim2.new(1, -48, 0, 26)
miniTitle.Position = UDim2.new(0, 8, 0, 4)
miniTitle.BackgroundTransparency = 1
miniTitle.Text = "🎲 Dice"
miniTitle.TextColor3 = Color3.new(1, 1, 1)
miniTitle.TextSize = 14
miniTitle.Font = Enum.Font.GothamBold
miniTitle.TextXAlignment = Enum.TextXAlignment.Left
miniTitle.Parent = miniFrame

local miniRestore = Instance.new("TextButton")
miniRestore.Size = UDim2.new(0, 32, 0, 28)
miniRestore.Position = UDim2.new(1, -70, 0, 3)
miniRestore.BackgroundColor3 = Color3.fromRGB(75, 75, 88)
miniRestore.Text = "□"
miniRestore.TextColor3 = Color3.new(1, 1, 1)
miniRestore.TextSize = 17
miniRestore.Font = Enum.Font.GothamBold
miniRestore.BorderSizePixel = 0
miniRestore.Parent = miniFrame
Instance.new("UICorner", miniRestore).CornerRadius = UDim.new(0, 7)

local miniClose = Instance.new("TextButton")
miniClose.Size = UDim2.new(0, 32, 0, 28)
miniClose.Position = UDim2.new(1, -35, 0, 3)
miniClose.BackgroundColor3 = Color3.fromRGB(180, 50, 55)
miniClose.Text = "X"
miniClose.TextColor3 = Color3.new(1, 1, 1)
miniClose.TextSize = 15
miniClose.Font = Enum.Font.GothamBold
miniClose.BorderSizePixel = 0
miniClose.Parent = miniFrame
Instance.new("UICorner", miniClose).CornerRadius = UDim.new(0, 7)

local miniMoney = Instance.new("TextLabel")
miniMoney.Size = UDim2.new(1, -16, 0, 20)
miniMoney.Position = UDim2.new(0, 8, 0, 31)
miniMoney.BackgroundTransparency = 1
miniMoney.Text = "💰 Money: --"
miniMoney.TextColor3 = Color3.new(1, 1, 1)
miniMoney.TextSize = 13
miniMoney.Font = Enum.Font.GothamBold
miniMoney.TextXAlignment = Enum.TextXAlignment.Left
miniMoney.Parent = miniFrame

local miniRolls = Instance.new("TextLabel")
miniRolls.Size = UDim2.new(1, -16, 0, 20)
miniRolls.Position = UDim2.new(0, 8, 0, 52)
miniRolls.BackgroundTransparency = 1
miniRolls.Text = "🎲 Rolls: --"
miniRolls.TextColor3 = Color3.new(1, 1, 1)
miniRolls.TextSize = 13
miniRolls.Font = Enum.Font.GothamBold
miniRolls.TextXAlignment = Enum.TextXAlignment.Left
miniRolls.Parent = miniFrame

local miniTickets = Instance.new("TextLabel")
miniTickets.Size = UDim2.new(1, -16, 0, 20)
miniTickets.Position = UDim2.new(0, 8, 0, 73)
miniTickets.BackgroundTransparency = 1
miniTickets.Text = "🎟️ Tickets: --"
miniTickets.TextColor3 = Color3.new(1, 1, 1)
miniTickets.TextSize = 13
miniTickets.Font = Enum.Font.GothamBold
miniTickets.TextXAlignment = Enum.TextXAlignment.Left
miniTickets.Parent = miniFrame

local function getTickets()
    local ok, text = pcall(function()
        return player.PlayerGui.Root.Menus.Quests.Shop.ScrollingFrame
            ["Jackpot Spin"].Buy.Frame.Info.TextLabel.Text
    end)

    if not ok then
        return 0
    end

    return tonumber(string.match(text, "^(%d+)")) or 0
end

local miniDragging = false
local miniDragStart
local miniStartPos

miniTitle.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    miniDragging = true
    miniDragStart = input.Position
    miniStartPos = miniFrame.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            miniDragging = false
        end
    end)
end)

UserInputService.InputChanged:Connect(function(input)
    if not miniDragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - miniDragStart
    miniFrame.Position = UDim2.new(
        miniStartPos.X.Scale,
        miniStartPos.X.Offset + delta.X,
        miniStartPos.Y.Scale,
        miniStartPos.Y.Offset + delta.Y
    )
end)

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
left.Position = UDim2.new(0, 10, 0, 168)
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
right.Position = UDim2.new(0, 325, 0, 168)
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
    task.defer(function()
        right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 24)
    end)
end)

--==================================================
-- MOBILE / TOUCH SCROLL FIX
--==================================================
-- Some Android emulators do not pass normal touch-wheel scrolling
-- correctly to a ScrollingFrame. Add manual swipe scrolling as a
-- fallback so the lower buttons (Collect/Quest/Shop) are
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
    b.LayoutOrder = #parent:GetChildren()
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
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
    b.LayoutOrder = #parent:GetChildren()
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local enabled = false

    b.MouseButton1Click:Connect(function()
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

section(left, "🎁 DAILY")

local dailyRewardButton = button(left, "🎁 Claim Daily Reward", function()
    local ok, result = pcall(function()
        fireRE("DailyRewardService", "Claim")
    end)

    if ok then
        status("Daily Reward: Claim sent")
    else
        status("Daily Reward: Failed")
        warn("[DAILY REWARD]", result)
    end
end)

section(left, "🎲 GACHA")

toggle(
    left,
    "🎲 Auto Roll Dice",
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

section(left, "💎 COLLECT")

button(left, "💎 Collect All Slots", function()
    for i = 1, 8 do
        pcall(function()
            fireRE("PlotService", "CollectBalance", i)
        end)
        task.wait(0.05)
    end

    status("Collected slots 1-8")
end)

toggle(
    left,
    "💎 Auto Collect Balance",
    nextLeft(),
    function()
        autoCollectOn = true
        status("Auto Collect: ON")

        task.spawn(function()
            while autoCollectOn and not closed do
                for i = 1, 8 do
                    if not autoCollectOn or closed then
                        break
                    end

                    pcall(function()
                        fireRE("PlotService", "CollectBalance", i)
                    end)

                    task.wait(0.05)
                end

                task.wait(10)
            end
        end)
    end,
    function()
        autoCollectOn = false
        status("Auto Collect: OFF")
    end
)

--==================================================
-- RIGHT: TOWER
--==================================================

section(right, "🏰 TOWER")

local towerOpen = false

local towerButton = Instance.new("TextButton")
towerButton.Size = UDim2.new(1, -16, 0, 42)
towerButton.BackgroundColor3 = Color3.fromRGB(52, 52, 63)
towerButton.Text = "🏰 Tower  ▸"
towerButton.TextColor3 = Color3.new(1, 1, 1)
towerButton.TextSize = 14
towerButton.Font = Enum.Font.GothamBold
towerButton.BorderSizePixel = 0
towerButton.LayoutOrder = #right:GetChildren()
towerButton.Parent = right
Instance.new("UICorner", towerButton).CornerRadius = UDim.new(0, 8)

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

local function startTowerDirect(name)
    if not TowerController then
        status("TowerController unavailable")
        warn("[TOWER] TowerController unavailable:", name)
        return
    end

    local equipOk, equipResult = pcall(function()
        return fireRE("Towers", "EquipBestTowerTeam")
    end)

    if not equipOk then
        status("Equip Tower Failed")
        warn("[TOWER EQUIP]", equipResult)
        return
    end

    task.wait(0.2)

    local startOk, started = pcall(function()
        return TowerController.startTower(name)
    end)

    if startOk and started then
        status(name .. " started")
    elseif startOk then
        status(name .. " could not start (battle active?)")
        warn("[TOWER START]", name, "returned", started)
    else
        status(name .. " start error")
        warn("[TOWER START]", name, started)
    end
end

local towerItems = {}

local function addTower(text, callback)
    local b = button(right, text, callback)
    b.Visible = false
    table.insert(towerItems, b)
    return b
end

addTower("🐉 Dragon Tower  |  START", function()
    startTowerDirect("Dragon Tower")
end)

addTower("☠️ Cursed Tower  |  START", function()
    startTowerDirect("Cursed Tower")
end)

addTower("🏴‍☠️ Pirate Tower  |  START", function()
    startTowerDirect("Pirate Tower")
end)

addTower("🍃 Hidden Leaf Tower  |  START", function()
    startTowerDirect("Hidden Leaf Tower")
end)

addTower("⚔️ Slayer Tower  |  START", function()
    startTowerDirect("Slayer Tower")
end)

addTower("♾️ Infinity Tower  |  START", function()
    startTowerDirect("Infinity Tower")
end)

towerButton.Activated:Connect(function()
    towerOpen = not towerOpen
    towerButton.Text = towerOpen and "🏰 Tower  ▾" or "🏰 Tower  ▸"

    for _, item in ipairs(towerItems) do
        item.Visible = towerOpen
    end

    task.defer(function()
        right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 24)
    end)
end)

--==================================================
-- QUEST HELPERS
--==================================================

local QUEST_TARGETS = {
    Daily = {Playtime=1800, Rolls=1000, Towers=2, UnitsSold=500},
    Weekly = {Playtime=18000, Rolls=7500, Towers=15, UnitsSold=5000},
}

local QUEST_NAMES = {
    Playtime={Daily='30m Login', Weekly='5h Login'},
    Rolls={Daily='1K Rolls', Weekly='7.5K Rolls'},
    Towers={Daily='2 Tower Attacks', Weekly='15 Tower Attacks'},
    UnitsSold={Daily='500 Units Sold', Weekly='5K Units Sold'},
}

local function findQuestTokens()
    -- Recursive quest-state scanner.
    -- Some sessions keep the actual Daily/Weekly state nested inside
    -- another client table, so only checking obj.progress misses it.
    local now = os.time()
    local states = {}
    local seen = {}
    local MAX_DEPTH = 6

    local function num(v)
        return type(v) == 'number' and v or tonumber(v)
    end

    local function readProgress(p, key)
        if type(p) ~= 'table' then return nil end
        local v = rawget(p, key)
        if v == nil then v = rawget(p, string.lower(key)) end
        return num(v)
    end

    local function saveCandidate(obj, progressTable, expiresAt, claimedTable)
        local e = num(expiresAt)
        if not e or e <= (now - 3600) then return end

        local progress = {
            Playtime  = readProgress(progressTable, 'Playtime'),
            Rolls     = readProgress(progressTable, 'Rolls'),
            Towers    = readProgress(progressTable, 'Towers'),
            UnitsSold = readProgress(progressTable, 'UnitsSold'),
        }

        local foundProgress = 0
        for _, q in ipairs({'Playtime','Rolls','Towers','UnitsSold'}) do
            if progress[q] ~= nil then foundProgress += 1 end
        end
        if foundProgress == 0 then return end

        local claimed = type(claimedTable) == 'table' and claimedTable or {}
        local old = states[e]
        local oldCount = old and old.progressCount or 0

        if not old or foundProgress > oldCount then
            states[e] = {
                expiresAt = e,
                progress = progress,
                claimed = claimed,
                progressCount = foundProgress,
                source = obj,
            }
        end
    end

    local function scanTable(t, depth)
        if type(t) ~= 'table' or depth > MAX_DEPTH or seen[t] then return end
        seen[t] = true

        -- Normal layout: {progress = {...}, claimed = {...}, expiresAt = ...}
        local p = rawget(t, 'progress')
        local e = rawget(t, 'expiresAt')
        local c = rawget(t, 'claimed')
        if type(p) == 'table' and e ~= nil then
            saveCandidate(t, p, e, c)
        end

        -- Some versions use a differently named expiry field.
        if type(p) == 'table' then
            local altE = rawget(t, 'expires') or rawget(t, 'expiry') or rawget(t, 'expireAt')
            if altE ~= nil then saveCandidate(t, p, altE, c) end
        end

        -- Search nested tables, but avoid walking huge unrelated structures.
        for k, v in pairs(t) do
            if type(v) == 'table' then
                local key = type(k) == 'string' and string.lower(k) or ''
                if depth < MAX_DEPTH and (
                    key == 'quest' or key == 'quests' or key == 'daily' or key == 'weekly'
                    or key == 'state' or key == 'data' or key == 'progress'
                    or key == 'claimed' or key == 'dailyquests' or key == 'weeklyquests'
                    or key == ''
                ) then
                    scanTable(v, depth + 1)
                end
            end
        end
    end

    for _, obj in ipairs(getgc(true)) do
        if type(obj) == 'table' then
            scanTable(obj, 0)
        end
    end

    local list = {}
    for _, state in pairs(states) do table.insert(list, state) end
    table.sort(list, function(a,b) return a.expiresAt < b.expiresAt end)

    local daily, weekly
    for _, state in ipairs(list) do
        local remaining = state.expiresAt - now
        if remaining > 0 then
            if remaining <= 2 * 86400 and not daily then
                daily = state
            elseif remaining > 2 * 86400 and not weekly then
                weekly = state
            end
        end
    end

    if not daily and #list >= 1 then daily = list[1] end
    if not weekly and #list >= 2 then weekly = list[#list] end
    if weekly == daily then weekly = nil end

    print('[QUEST SCAN] candidates:', #list,
        'daily:', daily and daily.expiresAt or 'nil',
        'weekly:', weekly and weekly.expiresAt or 'nil')

    if daily then
        print('[QUEST DAILY STATE]',
            'Playtime=', tostring(daily.progress.Playtime),
            'Rolls=', tostring(daily.progress.Rolls),
            'Towers=', tostring(daily.progress.Towers),
            'UnitsSold=', tostring(daily.progress.UnitsSold),
            'claimedType=', type(daily.claimed))
    end

    return daily, weekly
end

local function getQuestState(period)
    local d, w = findQuestTokens()
    return period == 'Daily' and d or w
end

local function claimAvailableQuest(period)
    local s = getQuestState(period)
    if not s then
        warn('[QUEST] No '..period..' quest state detected')
        return false
    end

    local p = s.progress or {}
    local c = s.claimed or {}

    local allClaimed = true
    for _, q in ipairs({'Playtime','Rolls','Towers','UnitsSold'}) do
        local current = tonumber(p[q]) or 0
        local target = QUEST_TARGETS[period][q]
        local isClaimed = c[q] == true or c[q] == 1 or c[q] == 'true'
        if current < target or not isClaimed then
            allClaimed = false
            break
        end
    end

    for _, q in ipairs({'Playtime','Rolls','Towers','UnitsSold'}) do
        local current = tonumber(p[q]) or 0
        local target = QUEST_TARGETS[period][q]
        local isClaimed = c[q] == true or c[q] == 1 or c[q] == 'true'

        print('[QUEST CHECK]', period, q,
            'progress=', current,
            'target=', target,
            'claimed=', tostring(isClaimed),
            'expiresAt=', s.expiresAt)

        if current >= target and not isClaimed then
            local ok, err = pcall(function()
                fireRE('QuestService','Claim',period,q,s.expiresAt)
            end)

            if ok then
                -- Prevent the same client-side state from being selected again
                -- before the game refreshes its quest data.
                c[q] = true
                status(period..': '..QUEST_NAMES[q][period]..' claim sent')
                print('[QUEST]',period,QUEST_NAMES[q][period],'token:',s.expiresAt)
                return true
            end

            warn('[QUEST CLAIM]',period,q,err)
            return false
        end
    end

    if allClaimed then
        status(period..': all quests claimed')
        print('[QUEST]', period, 'all quests claimed')
    end

    return false
end

--==================================================

-- RIGHT: TELEPORT
--==================================================

section(right, "📍 TELEPORT")

local teleportOpen = false

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, -16, 0, 42)
teleportButton.BackgroundColor3 = Color3.fromRGB(52, 52, 63)
teleportButton.Text = "📍 Teleport  ▸"
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.TextSize = 14
teleportButton.Font = Enum.Font.GothamBold
teleportButton.BorderSizePixel = 0
teleportButton.LayoutOrder = #right:GetChildren()
teleportButton.Parent = right
Instance.new("UICorner", teleportButton).CornerRadius = UDim.new(0, 8)

local TELEPORT_LOCATIONS = {
    {name = "Quest",  cframe = CFrame.new(324.563, 12.285, 4.673)},
    {name = "Grades", cframe = CFrame.new(245.927, 12.285, 84.685)},
    {name = "Traits", cframe = CFrame.new(325.477, 12.285, 82.21)},
    {name = "Trade",  cframe = CFrame.new(247.183, 12.285, 6.185)},
}

local function teleportTo(name, targetCFrame)
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        status("Teleport failed: character not found")
        return
    end

    local ok, err = pcall(function()
        hrp.CFrame = targetCFrame
    end)

    if ok then
        status("Teleported to " .. name)
    else
        status("Teleport failed: " .. name)
        warn("[TELEPORT]", name, err)
    end
end

local teleportItems = {}

local function addTeleport(text, name, targetCFrame)
    local b = button(right, text, function()
        teleportTo(name, targetCFrame)
    end)
    b.Visible = false
    table.insert(teleportItems, b)
    return b
end

addTeleport("📍 Quest", "Quest", TELEPORT_LOCATIONS[1].cframe)
addTeleport("📍 Grades", "Grades", TELEPORT_LOCATIONS[2].cframe)
addTeleport("📍 Traits", "Traits", TELEPORT_LOCATIONS[3].cframe)
addTeleport("📍 Trade", "Trade", TELEPORT_LOCATIONS[4].cframe)

teleportButton.Activated:Connect(function()
    teleportOpen = not teleportOpen
    teleportButton.Text = teleportOpen and "📍 Teleport  ▾" or "📍 Teleport  ▸"

    for _, item in ipairs(teleportItems) do
        item.Visible = teleportOpen
    end

    task.defer(function()
        right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 24)
    end)
end)

--==================================================
-- QUEST / JP SPIN QUEUE
--==================================================

local QUEST_REQUEST_INTERVAL=30
local questQueueRunning=false

local function runQuestQueue()
    if questQueueRunning then return end
    questQueueRunning=true
    task.spawn(function()
        local categoryIndex=1
        local shopIndex=1
        while not closed and (autoDailyQuestOn or autoWeeklyQuestOn or autoQuestShopOn) do
            local categories={}
            if autoDailyQuestOn then table.insert(categories,'Daily') end
            if autoWeeklyQuestOn then table.insert(categories,'Weekly') end
            if autoQuestShopOn then table.insert(categories,'Shop') end
            if #categories==0 then break end
            if categoryIndex>#categories then categoryIndex=1 end
            local category=categories[categoryIndex]
            if category=='Daily' then
                claimAvailableQuest('Daily')
            elseif category=='Weekly' then
                claimAvailableQuest('Weekly')
            else
                pcall(function() fireRE('QuestService','Buy','Jackpot Spin') end)
                status('JP Spin: request '..shopIndex..'/4')
                shopIndex=(shopIndex%4)+1
            end
            categoryIndex+=1
            task.wait(QUEST_REQUEST_INTERVAL)
        end
        questQueueRunning=false
    end)
end

--==================================================
-- RIGHT: QUEST / JP SPIN
--==================================================

section(right, '📜 QUEST')

toggle(right,'📅 DAILY',nextRight(),function()
    autoDailyQuestOn=true
    status('Daily Quest Auto Claim: ON')
    runQuestQueue()
end,function()
    autoDailyQuestOn=false
    status('Daily Quest Auto Claim: OFF')
end)

toggle(right,'🗓️ WEEKLY',nextRight(),function()
    autoWeeklyQuestOn=true
    status('Weekly Quest Auto Claim: ON')
    runQuestQueue()
end,function()
    autoWeeklyQuestOn=false
    status('Weekly Quest Auto Claim: OFF')
end)

section(right,'🛒 SHOP')

toggle(right,'🎰 AUTO BUY JP SPIN',nextRight(),function()
    autoQuestShopOn=true
    status('Auto Buy JP Spin: ON')
    runQuestQueue()
end,function()
    autoQuestShopOn=false
    status('Auto Buy JP Spin: OFF')
end)

--==================================================
-- MINI STATS HELPERS
--==================================================

local function formatMoney(value)
    value = tonumber(value) or 0

    local suffixes = {
        {1e21, "sx"},
        {1e18, "qi"},
        {1e15, "qd"},
        {1e12, "T"},
        {1e9, "B"},
        {1e6, "M"},
        {1e3, "K"},
    }

    for _, data in ipairs(suffixes) do
        local threshold, suffix = data[1], data[2]
        if value >= threshold then
            local n = value / threshold
            local text
            if n >= 100 then
                text = string.format("%.0f", n)
            elseif n >= 10 then
                text = string.format("%.1f", n):gsub("%.0$", "")
            else
                text = string.format("%.2f", n):gsub("0+$", ""):gsub("%.$", "")
            end
            return text .. suffix
        end
    end

    return tostring(math.floor(value))
end

--==================================================
-- STATS UPDATE
--==================================================

task.spawn(function()
    while not closed and gui.Parent do
        pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")

            if leaderstats then
                local money = leaderstats:FindFirstChild("Money")
                local rolls = leaderstats:FindFirstChild("Rolls")

                if money then
                    local moneyValue = tonumber(money.Value) or 0
                    moneyLabel.Text = "💰 Money: " .. tostring(money.Value)
                    miniMoney.Text = "💰 Money: " .. formatMoney(moneyValue)
                end

                if rolls then
                    local rollsValue = tonumber(rolls.Value) or 0
                    rollsLabel.Text = "🎲 Rolls: " .. tostring(rolls.Value)
                    miniRolls.Text = "🎲 Rolls: " .. string.format("%d", rollsValue):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                end

            end

            -- Tickets are independent of leaderstats.
            miniTickets.Text = "🎟️ Tickets: " .. tostring(getTickets())
        end)

        task.wait(1)
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

--==================================================
-- CTRL: HIDE / SHOW GUI
--==================================================
-- LDPlayer/Roblox reports the Ctrl key as LeftControl.
-- Do not check gameProcessed here so the hotkey still works
-- when Roblox/emulator marks the input as processed.

local guiHidden = false
local ctrlDebounce = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode ~= Enum.KeyCode.LeftControl then
        return
    end

    if ctrlDebounce then
        return
    end

    ctrlDebounce = true

    guiHidden = not guiHidden
    gui.Enabled = not guiHidden

    task.delay(0.2, function()
        ctrlDebounce = false
    end)
end)

--==================================================
-- MINIMIZE
--==================================================

local minimized = false
local normalSize = main.Size
local normalTitleSize = titleBar.Size

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        -- Refresh immediately so the mini window never opens with stale "--" values.
        pcall(function()
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money")
                local rolls = leaderstats:FindFirstChild("Rolls")
                if money then
                    miniMoney.Text = "💰 Money: " .. formatMoney(money.Value)
                end
                if rolls then
                    local n = tonumber(rolls.Value) or 0
                    miniRolls.Text = "🎲 Rolls: " .. string.format("%d", n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                end
            end
            miniTickets.Text = "🎟️ Tickets: " .. tostring(getTickets())
        end)
        main.Visible = false
        miniFrame.Visible = true
        dailyRewardButton.Visible = false
    else
        miniFrame.Visible = false
        main.Visible = true
        dailyRewardButton.Visible = true
    end
end)

miniRestore.MouseButton1Click:Connect(function()
    minimized = false
    miniFrame.Visible = false
    main.Visible = true
    dailyRewardButton.Visible = true
end)

miniClose.MouseButton1Click:Connect(function()
    closed = true

    autoRollOn = false
    autoCollectOn = false
    autoDailyQuestOn = false
    autoWeeklyQuestOn = false
    autoQuestShopOn = false

    gui:Destroy()
end)

--==================================================
-- CLOSE
--==================================================

close.MouseButton1Click:Connect(function()
    closed = true

    autoRollOn = false
    autoCollectOn = false
    autoDailyQuestOn = false
    autoWeeklyQuestOn = false
    autoQuestShopOn = false
    gui:Destroy()

end)

print("========================================")
print("[DiceGachaHub] V17 TOWER METHOD: CONTROLLER ONLY")
print("[DiceGachaHub] 6 towers = EquipBestTowerTeam -> TowerController.startTower()")
print("========================================")

print("========================================")
print("[DiceGachaHub] Loaded successfully!")
print("[DiceGachaHub] Auto Roll uses RollDice")
print("[DiceGachaHub] SetAutoRoll removed")
print("[DiceGachaHub] Anti-AFK removed - V2")
print("[DiceGachaHub] Responsive UI enabled")
print("[DiceGachaHub] Compact columns enabled")
print("[DiceGachaHub] V16 horizontal minimize bar loaded")
print("[DiceGachaHub] Quest Auto-Detect enabled - no hardcoded quest token")
print("========================================")
