-- ═══════════════════════════════════════════════════════
--  🎲 Dice Gacha Hub GUI
--  Auto: Roll, EquipBest, Collect, Sell, BuyDice
--  GUI: Draggable, Minimize, Close, Stats Display
-- ═══════════════════════════════════════════════════════

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
--  NETWORK HELPERS
-- ═══════════════════════════════════════════════════════

local function getNetwork()
    return ReplicatedStorage:WaitForChild("Network", 9e9)
end

local function fireRE(serviceName, remoteName, ...)
    getNetwork():WaitForChild(serviceName, 9e9)
        :WaitForChild("RE", 9e9)
        :WaitForChild(remoteName, 9e9)
        :FireServer(...)
end

local function invokeRF(serviceName, remoteName, ...)
    return getNetwork():WaitForChild(serviceName, 9e9)
        :WaitForChild("RF", 9e9)
        :WaitForChild(remoteName, 9e9)
        :InvokeServer(...)
end

-- ═══════════════════════════════════════════════════════
--  DESTROY OLD GUI
-- ═══════════════════════════════════════════════════════

if player.PlayerGui:FindFirstChild("DiceGachaGUI") then
    player.PlayerGui:FindFirstChild("DiceGachaGUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiceGachaGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- ═══════════════════════════════════════════════════════
--  COLORS & STYLE
-- ═══════════════════════════════════════════════════════

local C = {
    BG          = Color3.fromRGB(20, 20, 30),
    BAR         = Color3.fromRGB(30, 30, 45),
    ACCENT      = Color3.fromRGB(88, 101, 242),
    BTN         = Color3.fromRGB(40, 40, 58),
    BTN_HOVER   = Color3.fromRGB(55, 55, 78),
    BTN_ON      = Color3.fromRGB(46, 160, 87),
    BTN_ON_HVR  = Color3.fromRGB(56, 180, 100),
    RED         = Color3.fromRGB(210, 55, 55),
    YELLOW      = Color3.fromRGB(220, 170, 40),
    GREEN       = Color3.fromRGB(46, 160, 87),
    TEXT        = Color3.fromRGB(225, 225, 235),
    TEXT_DIM    = Color3.fromRGB(120, 120, 145),
    SECTION     = Color3.fromRGB(140, 160, 255),
    SEP         = Color3.fromRGB(45, 45, 65),
    STATS_BG    = Color3.fromRGB(30, 32, 48),
}

local FONT_B = Enum.Font.GothamBold
local FONT = Enum.Font.GothamMedium
local TWEEN = 0.22

-- ═══════════════════════════════════════════════════════
--  MAIN FRAME
-- ═══════════════════════════════════════════════════════

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = C.ACCENT
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- ═══════════════════════════════════════════════════════
--  TITLE BAR
-- ═══════════════════════════════════════════════════════

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = C.BAR
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

-- Fix bottom corners
local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 12)
fix.Position = UDim2.new(0, 0, 1, -12)
fix.BackgroundColor3 = C.BAR
fix.BorderSizePixel = 0
fix.Parent = TitleBar

-- Accent underline
local accent = Instance.new("Frame")
accent.Name = "AccentLine"
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 1, 0)
accent.BackgroundColor3 = C.ACCENT
accent.BorderSizePixel = 0
accent.Parent = TitleBar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎲 Dice Gacha Hub"
title.TextSize = 14
title.Font = FONT_B
title.TextColor3 = C.TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = TitleBar

-- ═══════════════════════════════════════════════════════
--  TITLE BAR BUTTONS
-- ═══════════════════════════════════════════════════════

local function makeTitleBtn(name, text, color, px)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 28, 0, 22)
    b.Position = UDim2.new(1, px, 0.5, -11)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextSize = 13
    b.Font = FONT_B
    b.TextColor3 = C.TEXT
    b.AutoButtonColor = false
    b.Parent = TitleBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(color.R*255+35, 255),
                math.min(color.G*255+35, 255),
                math.min(color.B*255+35, 255))
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = color}):Play()
    end)
    return b
end

local MinBtn = makeTitleBtn("Min", "—", C.YELLOW, -66)
local ClsBtn = makeTitleBtn("Cls", "✕", C.RED, -34)

-- ═══════════════════════════════════════════════════════
--  STATS BAR (Money & Rolls)
-- ═══════════════════════════════════════════════════════

local StatsBar = Instance.new("Frame")
StatsBar.Name = "StatsBar"
StatsBar.Size = UDim2.new(1, -16, 0, 32)
StatsBar.Position = UDim2.new(0, 8, 0, 42)
StatsBar.BackgroundColor3 = C.STATS_BG
StatsBar.BorderSizePixel = 0
StatsBar.Parent = MainFrame
Instance.new("UICorner", StatsBar).CornerRadius = UDim.new(0, 8)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(0.5, 0, 1, 0)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "💰 Money: ---"
MoneyLabel.TextSize = 12
MoneyLabel.Font = FONT_B
MoneyLabel.TextColor3 = C.YELLOW
MoneyLabel.Parent = StatsBar

local RollsLabel = Instance.new("TextLabel")
RollsLabel.Size = UDim2.new(0.5, 0, 1, 0)
RollsLabel.Position = UDim2.new(0.5, 0, 0, 0)
RollsLabel.BackgroundTransparency = 1
RollsLabel.Text = "🎲 Rolls: ---"
RollsLabel.TextSize = 12
RollsLabel.Font = FONT_B
RollsLabel.TextColor3 = C.SECTION
RollsLabel.Parent = StatsBar

-- Update stats from leaderstats
local function updateStats()
    pcall(function()
        local ls = player:WaitForChild("leaderstats", 5)
        if ls then
            local money = ls:FindFirstChild("Money")
            local rolls = ls:FindFirstChild("Rolls")
            if money then MoneyLabel.Text = "💰 Money: " .. tostring(money.Value) end
            if rolls then RollsLabel.Text = "🎲 Rolls: " .. tostring(rolls.Value) end
        end
    end)
end

-- Auto update stats every 1 second
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        updateStats()
        task.wait(1)
    end
end)

-- ═══════════════════════════════════════════════════════
--  CONTENT SCROLL
-- ═══════════════════════════════════════════════════════

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -16, 1, -84)
Content.Position = UDim2.new(0, 8, 0, 78)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = C.ACCENT
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local layout = Instance.new("UIListLayout", Content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- ═══════════════════════════════════════════════════════
--  UI BUILDERS
-- ═══════════════════════════════════════════════════════

local order = 0
local function nextO() order += 1 return order end

local function section(text, o)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 24)
    l.BackgroundTransparency = 1
    l.Text = "  " .. text
    l.TextSize = 11
    l.Font = FONT_B
    l.TextColor3 = C.SECTION
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = o
    l.Parent = Content
end

local function sep(o)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -10, 0, 1)
    s.BackgroundColor3 = C.SEP
    s.BorderSizePixel = 0
    s.LayoutOrder = o
    s.Parent = Content
end

local function btn(text, o, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = C.BTN
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = o
    b.Parent = Content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local pad = Instance.new("UIPadding", b)
    pad.PaddingLeft = UDim.new(0, 12)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -12, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextSize = 12
    tl.Font = FONT
    tl.TextColor3 = C.TEXT
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.BTN_HOVER}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.BTN}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.06), {BackgroundColor3 = C.ACCENT}):Play()
        task.wait(0.06)
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.BTN}):Play()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[GUI] " .. tostring(err)) end
        end
    end)
    return b
end

local function toggle(text, o, onCb, offCb)
    local isOn = false
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = C.BTN
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = o
    b.Parent = Content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local pad = Instance.new("UIPadding", b)
    pad.PaddingLeft = UDim.new(0, 12)

    local tl = Instance.new("TextLabel")
    tl.Name = "Label"
    tl.Size = UDim2.new(1, -60, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextSize = 12
    tl.Font = FONT
    tl.TextColor3 = C.TEXT
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = b

    -- Toggle indicator
    local ind = Instance.new("TextLabel")
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 40, 0, 20)
    ind.Position = UDim2.new(1, -52, 0.5, -10)
    ind.BackgroundColor3 = C.RED
    ind.Text = "OFF"
    ind.TextSize = 10
    ind.Font = FONT_B
    ind.TextColor3 = C.TEXT
    ind.Parent = b
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 6)

    b.MouseEnter:Connect(function()
        if not isOn then
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.BTN_HOVER}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if not isOn then
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.BTN}):Play()
        end
    end)

    b.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            ind.Text = "ON"
            TweenService:Create(ind, TweenInfo.new(0.15), {BackgroundColor3 = C.GREEN}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.BTN_ON}):Play()
            if onCb then pcall(onCb) end
        else
            ind.Text = "OFF"
            TweenService:Create(ind, TweenInfo.new(0.15), {BackgroundColor3 = C.RED}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C.BTN}):Play()
            if offCb then pcall(offCb) end
        end
    end)
    return b, function() return isOn end
end

-- ═══════════════════════════════════════════════════════
--  STATUS BAR
-- ═══════════════════════════════════════════════════════

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⏺ Ready"
StatusLabel.TextSize = 10
StatusLabel.Font = FONT
StatusLabel.TextColor3 = C.TEXT_DIM
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.LayoutOrder = 9999
StatusLabel.Parent = Content

local function status(msg)
    StatusLabel.Text = "⏺ " .. msg
    task.delay(4, function()
        if StatusLabel.Text == "⏺ " .. msg then
            StatusLabel.Text = "⏺ Ready"
        end
    end)
end

-- ═══════════════════════════════════════════════════════
--  MENU: GACHA / ROLL
-- ═══════════════════════════════════════════════════════

section("🎰  GACHA / ROLL", nextO())

btn("🎲  Roll Dice", nextO(), function()
    status("Rolling dice...")
    invokeRF("RollService", "RollDice")
    status("Dice rolled!")
end)

toggle("🔄  Auto Roll", nextO(),
    function()
        status("Auto Roll: ON")
        fireRE("RollService", "SetAutoRoll", true)
    end,
    function()
        status("Auto Roll: OFF")
        fireRE("RollService", "SetAutoRoll", false)
    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  MENU: EQUIP
-- ═══════════════════════════════════════════════════════

section("⚔️  EQUIP", nextO())

btn("📦  Buka Tas (Equip 1 per 1)", nextO(), function()
    status("Opening bag...")
    fireRE("OnboardingService", "Advance", 2)
    status("Bag opened!")
end)

btn("⚡  Equip Best → Slot Tanam", nextO(), function()
    status("Equipping best to slots...")
    fireRE("PlotService", "EquipBest")
    status("All slots filled!")
end)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  MENU: SELL
-- ═══════════════════════════════════════════════════════

section("💰  SELL", nextO())

btn("🗑️  Sell Equipped (Tangan)", nextO(), function()
    status("Selling equipped...")
    invokeRF("SellService", "SellEquipped")
    status("Equipped sold!")
end)

toggle("🔄  Auto Sell", nextO(),
    function()
        status("Auto Sell: ON")
        fireRE("SellService", "UpdateAutoSell", true)
    end,
    function()
        status("Auto Sell: OFF")
        fireRE("SellService", "UpdateAutoSell", false)
    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  MENU: COLLECT BALANCE
-- ═══════════════════════════════════════════════════════

section("💎  COLLECT BALANCE", nextO())

btn("💵  Collect ALL Slots (1-8)", nextO(), function()
    status("Collecting all slots...")
    for i = 1, 8 do
        pcall(function() fireRE("PlotService", "CollectBalance", i) end)
        task.wait(0.08)
    end
    status("All 8 slots collected!")
end)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  MENU: BUY DICE
-- ═══════════════════════════════════════════════════════

section("🛒  BUY DICE", nextO())

-- Read dice types from game if available, fallback to known ones
local diceList = {}
pcall(function()
    local unitsFolder = ReplicatedStorage:FindFirstChild("Assets")
        and ReplicatedStorage.Assets:FindFirstChild("Models")
        and ReplicatedStorage.Assets.Models:FindFirstChild("Units")
    -- Also check DiceShop in Zones
    local zones = game.Workspace:FindFirstChild("Zones")
    local diceShop = zones and zones:FindFirstChild("DiceShop")
    if diceShop then
        for _, child in ipairs(diceShop:GetChildren()) do
            table.insert(diceList, child.Name)
        end
    end
end)

-- Fallback dice types if can't read from game
if #diceList == 0 then
    diceList = {"Normal", "Fire"}
end

-- Emoji map
local emojiMap = {
    Normal = "🎲", Fire = "🔥", Ice = "❄️", Electric = "⚡",
    Wind = "🌪️", Dark = "🌑", Light = "✨", Poison = "☠️",
    Nature = "🌿", Crystal = "💠", Water = "💧", Earth = "🪨",
    Shadow = "👤", Holy = "😇", Thunder = "⛈️", Lava = "🌋",
}

for _, dice in ipairs(diceList) do
    local emoji = emojiMap[dice] or "🎲"
    btn(emoji .. "  Buy " .. dice .. " Dice", nextO(), function()
        status("Buying " .. dice .. " Dice...")
        fireRE("DiceShopService", "BuyDice", dice)
        status(dice .. " Dice purchased!")
    end)
end

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  MENU: AUTOMATION
-- ═══════════════════════════════════════════════════════

section("🤖  AUTOMATION", nextO())

local autoFarmOn = false

toggle("🔁  Auto Farm Loop", nextO(),
    function()
        autoFarmOn = true
        status("Auto Farm STARTED")
        task.spawn(function()
            while autoFarmOn do
                -- 1. Roll Dice
                pcall(function() invokeRF("RollService", "RollDice") end)
                task.wait(0.3)

                -- 2. Equip Best → slot tanam
                pcall(function() fireRE("PlotService", "EquipBest") end)
                task.wait(0.2)

                -- 3. Collect all balance
                for i = 1, 8 do
                    pcall(function() fireRE("PlotService", "CollectBalance", i) end)
                    task.wait(0.05)
                end
                task.wait(0.2)

                -- 4. Sell Equipped (tangan)
                pcall(function() invokeRF("SellService", "SellEquipped") end)
                task.wait(0.8)
            end
            status("Auto Farm STOPPED")
        end)
    end,
    function()
        autoFarmOn = false
        status("Auto Farm STOPPING...")
    end
)

local autoCollectOn = false

toggle("💰  Auto Collect Loop", nextO(),
    function()
        autoCollectOn = true
        status("Auto Collect STARTED")
        task.spawn(function()
            while autoCollectOn do
                for i = 1, 8 do
                    pcall(function() fireRE("PlotService", "CollectBalance", i) end)
                    task.wait(0.05)
                end
                task.wait(3) -- collect every 3 seconds
            end
            status("Auto Collect STOPPED")
        end)
    end,
    function()
        autoCollectOn = false
        status("Auto Collect STOPPING...")
    end
)

local autoRollBuyOn = false

toggle("🎰  Auto Roll + Buy Normal", nextO(),
    function()
        autoRollBuyOn = true
        status("Auto Roll+Buy STARTED")
        task.spawn(function()
            while autoRollBuyOn do
                pcall(function() invokeRF("RollService", "RollDice") end)
                task.wait(0.2)
                pcall(function() fireRE("DiceShopService", "BuyDice", "Normal") end)
                task.wait(0.5)
            end
            status("Auto Roll+Buy STOPPED")
        end)
    end,
    function()
        autoRollBuyOn = false
        status("Auto Roll+Buy STOPPING...")
    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  DRAGGING
-- ═══════════════════════════════════════════════════════

local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

-- ═══════════════════════════════════════════════════════
--  MINIMIZE / CLOSE
-- ═══════════════════════════════════════════════════════

local minimized = false
local fullSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Collapse → hanya title bar
        Content.Visible = false
        StatsBar.Visible = false
        accent.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(TWEEN, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 300, 0, 38)
        }):Play()
        MinBtn.Text = "+"
    else
        -- Restore → full size
        TweenService:Create(MainFrame, TweenInfo.new(TWEEN, Enum.EasingStyle.Quart), {
            Size = fullSize
        }):Play()
        task.delay(TWEEN, function()
            Content.Visible = true
            StatsBar.Visible = true
            accent.Visible = true
        end)
        MinBtn.Text = "—"
    end
end)

ClsBtn.MouseButton1Click:Connect(function()
    -- Stop all loops
    autoFarmOn = false
    autoCollectOn = false
    autoRollBuyOn = false

    -- Animate close
    TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, 300, 0, 0)
    }):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════
--  DONE
-- ═══════════════════════════════════════════════════════
status("GUI Loaded! 🎲")
print("[DiceGachaHub] Loaded successfully!")
