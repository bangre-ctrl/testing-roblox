-- Dice Gacha Hub
-- Auto Roll Dice uses RollService > RF > RollDice
-- Auto Roll UI (SetAutoRoll) removed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

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
    {name = "Normal", price = 0, luck = 1, emoji = "⚪"},
    {name = "Bronze", price = 1000, luck = 1.1, emoji = "🟤"},
    {name = "Silver", price = 5000, luck = 1.25, emoji = "⚪"},
    {name = "Gold", price = 25000, luck = 1.5, emoji = "🟡"},
    {name = "Platinum", price = 100000, luck = 2, emoji = "💠"},
    {name = "Diamond", price = 500000, luck = 3, emoji = "💎"},
    {name = "Emerald", price = 2500000, luck = 4, emoji = "🟢"},
    {name = "Ruby", price = 10000000, luck = 5, emoji = "🔴"},
    {name = "Void", price = 50000000, luck = 7, emoji = "🟣"},
    {name = "Celestial", price = 250000000, luck = 10, emoji = "🌌"},
    {name = "Chrono", price = 1000000000, luck = 15, emoji = "⏳"},
}

--==================================================
-- STATE
--==================================================

local autoRollOn = false
local autoFarmOn = false
local autoCollectOn = false
local autoEquipBestOn = false
local autoSellOn = false
local autoBuyBestOn = false
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
main.Size = UDim2.new(0, 680, 0, 540)
main.Position = UDim2.new(0.5, -340, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
main.BorderSizePixel = 0
main.Parent = gui

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
minimize.Text = "—"
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
left.Size = UDim2.new(0, 326, 0, 405)
left.Position = UDim2.new(0, 12, 0, 125)
left.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
left.BorderSizePixel = 0
left.ScrollBarThickness = 5
left.CanvasSize = UDim2.new(0, 0, 0, 0)
left.Parent = main

Instance.new("UICorner", left).CornerRadius = UDim.new(0, 9)

local right = Instance.new("ScrollingFrame")
right.Name = "Right"
right.Size = UDim2.new(0, 318, 0, 405)
right.Position = UDim2.new(0, 350, 0, 125)
right.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
right.BorderSizePixel = 0
right.ScrollBarThickness = 5
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
leftPad.Parent = left

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 8)
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Parent = right

local rightPad = Instance.new("UIPadding")
rightPad.PaddingTop = UDim.new(0, 10)
rightPad.PaddingBottom = UDim.new(0, 10)
rightPad.Parent = right

leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    left.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 20)
end)

rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    right.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 20)
end)

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
    label.Size = UDim2.new(1, -20, 0, 28)
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
    b.Size = UDim2.new(1, -20, 0, 40)
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
    b.Size = UDim2.new(1, -20, 0, 42)
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

section(left, "🎲 GACHA")

button(left, "🎲 Roll Dice", function()
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

section(left, "⚔️ EQUIP")

button(left, "🎒 Buka Tas", function()
    fireRE("OnboardingService", "Advance", 2)
    status("Buka Tas")
end)

button(left, "⚔️ Equip Best", function()
    fireRE("PlotService", "EquipBest")
    status("Equip Best")
end)

toggle(
    left,
    "⚔️ Auto Equip Best",
    nextLeft(),
    function()
        autoEquipBestOn = true
        status("Auto Equip Best: ON")

        task.spawn(function()
            while autoEquipBestOn and not closed do
                pcall(function()
                    fireRE("PlotService", "EquipBest")
                end)

                task.wait(10)
            end
        end)
    end,
    function()
        autoEquipBestOn = false
        status("Auto Equip Best: OFF")
    end
)

section(left, "💰 SELL")

button(left, "🗑️ Sell Inventory", function()
    local ok, result = sellInventory()

    if ok then
        status("Sell Inventory: Success")
    else
        status("Sell Inventory: Failed")
        warn("[SELL]", result)
    end
end)

button(left, "🗑️ Sell Equipped", function()
    local ok, result = sellEquipped()

    if ok then
        status("Sell Equipped: Success")
    else
        status("Sell Equipped: Failed")
        warn("[SELL EQUIPPED]", result)
    end
end)

toggle(
    left,
    "🗑️ Auto Sell",
    nextLeft(),
    function()
        autoSellOn = true
        status("Auto Sell: ON")

        task.spawn(function()
            while autoSellOn and not closed do
                pcall(function()
                    sellInventory()
                end)

                task.wait(3)
            end
        end)
    end,
    function()
        autoSellOn = false
        status("Auto Sell: OFF")
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

                task.wait(120)
            end
        end)
    end,
    function()
        autoCollectOn = false
        status("Auto Collect: OFF")
    end
)

section(left, "♻️ REBIRTH")

button(left, "♻️ Rebirth", function()
    fireRE("RebirthService", "Rebirth")
    status("Rebirth")
end)

toggle(
    left,
    "♻️ Auto Rebirth",
    nextLeft(),
    function()
        autoRebirthOn = true
        status("Auto Rebirth: ON")

        task.spawn(function()
            while autoRebirthOn and not closed do
                local delay = math.random(60, 300)
                local elapsed = 0

                while elapsed < delay and autoRebirthOn and not closed do
                    task.wait(1)
                    elapsed += 1
                end

                if autoRebirthOn and not closed then
                    pcall(function()
                        fireRE("RebirthService", "Rebirth")
                    end)
                end
            end
        end)
    end,
    function()
        autoRebirthOn = false
        status("Auto Rebirth: OFF")
    end
)

section(left, "🤖 AUTOMATION")

toggle(
    left,
    "🤖 Auto Farm",
    nextLeft(),
    function()
        autoFarmOn = true
        status("Auto Farm: ON")

        task.spawn(function()
            while autoFarmOn and not closed do

                -- Roll
                pcall(function()
                    invokeRF("RollService", "RollDice")
                end)
                task.wait(0.3)

                if not autoFarmOn or closed then
                    break
                end

                -- Equip
                pcall(function()
                    fireRE("PlotService", "EquipBest")
                end)
                task.wait(0.2)

                if not autoFarmOn or closed then
                    break
                end

                -- Collect
                for i = 1, 8 do
                    if not autoFarmOn or closed then
                        break
                    end

                    pcall(function()
                        fireRE("PlotService", "CollectBalance", i)
                    end)

                    task.wait(0.05)
                end

                if not autoFarmOn or closed then
                    break
                end

                task.wait(0.2)

                -- Sell
                pcall(function()
                    sellInventory()
                end)

                task.wait(0.8)
            end

            if not closed then
                status("Auto Farm: OFF")
            end
        end)
    end,
    function()
        autoFarmOn = false
        status("Auto Farm: STOPPING...")
    end
)

--==================================================
-- RIGHT: DICE SHOP
--==================================================

section(right, "🛒 DICE SHOP")

local diceStatus = Instance.new("TextLabel")
diceStatus.Size = UDim2.new(1, -20, 0, 28)
diceStatus.BackgroundTransparency = 1
diceStatus.Text = "Auto Buy Best: OFF"
diceStatus.TextColor3 = Color3.fromRGB(180, 210, 255)
diceStatus.TextSize = 13
diceStatus.Font = Enum.Font.GothamBold
diceStatus.TextXAlignment = Enum.TextXAlignment.Left
diceStatus.LayoutOrder = #right:GetChildren()
diceStatus.Parent = right

local function getMoney()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return 0
    end

    local money = leaderstats:FindFirstChild("Money")
    if not money then
        return 0
    end

    return tonumber(money.Value) or 0
end

local function buyDice(name)
    local ok, result = pcall(function()
        return fireRE("DiceShopService", "BuyDice", name)
    end)

    if ok then
        status("Bought dice: " .. name)
    else
        warn("[BUY DICE]", result)
        status("Buy failed: " .. name)
    end

    return ok, result
end

for i = #ALL_DICES, 1, -1 do
    local d = ALL_DICES[i]

    button(right, string.format(
        "%s  %s  | $%s  | Luck x%s",
        d.emoji,
        d.name,
        tostring(d.price),
        tostring(d.luck)
    ), function()
        buyDice(d.name)
    end)
end

toggle(
    right,
    "🛒 Auto Buy Best Dice",
    nextRight(),
    function()
        autoBuyBestOn = true
        diceStatus.Text = "Auto Buy Best: ON"

        task.spawn(function()
            while autoBuyBestOn and not closed do
                local money = getMoney()

                for i = #ALL_DICES, 1, -1 do
                    local d = ALL_DICES[i]

                    if money >= d.price then
                        pcall(function()
                            buyDice(d.name)
                        end)
                        break
                    end
                end

                task.wait(60)
            end
        end)
    end,
    function()
        autoBuyBestOn = false
        diceStatus.Text = "Auto Buy Best: OFF"
    end
)

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
                    moneyLabel.Text = "💰 Money: " .. tostring(money.Value)
                end

                if rolls then
                    rollsLabel.Text = "🎲 Rolls: " .. tostring(rolls.Value)
                end
            end
        end)

        task.wait(1)
    end
end)

--==================================================
-- ANTI AFK
--==================================================

pcall(function()
    player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

task.spawn(function()
    while not closed do
        task.wait(60)

        if not closed then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
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
-- MINIMIZE
--==================================================

local minimized = false
local normalSize = main.Size

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        stats.Visible = false
        statusLabel.Visible = false
        left.Visible = false
        right.Visible = false

        main.Size = UDim2.new(0, 680, 0, 48)
        minimize.Text = "□"
    else
        stats.Visible = true
        statusLabel.Visible = true
        left.Visible = true
        right.Visible = true

        main.Size = normalSize
        minimize.Text = "—"
    end
end)

--==================================================
-- CLOSE
--==================================================

close.MouseButton1Click:Connect(function()
    closed = true

    autoRollOn = false
    autoFarmOn = false
    autoCollectOn = false
    autoEquipBestOn = false
    autoSellOn = false
    autoBuyBestOn = false
    autoRebirthOn = false

    gui:Destroy()
end)

print("========================================")
print("[DiceGachaHub] Loaded successfully!")
print("[DiceGachaHub] Auto Roll uses RollDice")
print("[DiceGachaHub] SetAutoRoll removed")
print("========================================")
