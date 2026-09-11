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
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════
--  ANTI-AFK SYSTEM
-- ═══════════════════════════════════════════════════════

pcall(function()
    player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            print("[AntiAFK] Idle detected - input sent")
        end)
    end)
end)

task.spawn(function()
    while player and player.Parent do
        task.wait(60)

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

print("[AntiAFK] Enabled")

-- ═══════════════════════════════════════════════════════
--  NETWORK HELPERS
-- ═══════════════════════════════════════════════════════

local function getNetwork()
    return ReplicatedStorage:WaitForChild("Network", 9e9)
end

-- Network > Service > RE > RemoteEvent
local function fireRE(serviceName, remoteName, ...)
    local network = getNetwork()
    local service = network:WaitForChild(serviceName, 9e9)
    local reFolder = service:WaitForChild("RE", 9e9)
    local remote = reFolder:WaitForChild(remoteName, 9e9)

    if not remote:IsA("RemoteEvent") then
        error(
            remote:GetFullName()
            .. " bukan RemoteEvent ("
            .. remote.ClassName
            .. ")"
        )
    end

    return remote:FireServer(...)
end

-- Network > Service > RF > RemoteFunction
local function invokeRF(serviceName, remoteName, ...)
    local network = getNetwork()
    local service = network:WaitForChild(serviceName, 9e9)
    local rfFolder = service:WaitForChild("RF", 9e9)
    local remote = rfFolder:WaitForChild(remoteName, 9e9)

    if not remote:IsA("RemoteFunction") then
        error(
            remote:GetFullName()
            .. " bukan RemoteFunction ("
            .. remote.ClassName
            .. ")"
        )
    end

    return remote:InvokeServer(...)
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

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 12)
fix.Position = UDim2.new(0, 0, 1, -12)
fix.BackgroundColor3 = C.BAR
fix.BorderSizePixel = 0
fix.Parent = TitleBar

local accent = Instance.new("Frame")
accent.Name = "AccentLine"
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 1, 0)
accent.BackgroundColor3 = C.ACCENT
accent.BorderSizePixel = 0
accent.Parent = TitleBar

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
                math.min(color.R * 255 + 35, 255),
                math.min(color.G * 255 + 35, 255),
                math.min(color.B * 255 + 35, 255)
            )
        }):Play()
    end)

    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = color
        }):Play()
    end)

    return b
end

local MinBtn = makeTitleBtn("Min", "—", C.YELLOW, -66)
local ClsBtn = makeTitleBtn("Cls", "✕", C.RED, -34)

-- ═══════════════════════════════════════════════════════
--  STATS BAR
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

local function updateStats()
    pcall(function()

        local ls = player:WaitForChild(
            "leaderstats",
            5
        )

        if ls then

            local money = ls:FindFirstChild("Money")
            local rolls = ls:FindFirstChild("Rolls")

            if money then
                MoneyLabel.Text =
                    "💰 Money: "
                    .. tostring(money.Value)
            end

            if rolls then
                RollsLabel.Text =
                    "🎲 Rolls: "
                    .. tostring(rolls.Value)
            end
        end
    end)
end

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

local layout = Instance.new(
    "UIListLayout",
    Content
)

layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- ═══════════════════════════════════════════════════════
--  UI BUILDERS
-- ═══════════════════════════════════════════════════════

local order = 0

local function nextO()
    order += 1
    return order
end

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

        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = C.BTN_HOVER
        }):Play()

    end)

    b.MouseLeave:Connect(function()

        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = C.BTN
        }):Play()

    end)

    b.MouseButton1Click:Connect(function()

        TweenService:Create(b, TweenInfo.new(0.06), {
            BackgroundColor3 = C.ACCENT
        }):Play()

        task.wait(0.06)

        TweenService:Create(b, TweenInfo.new(0.12), {
            BackgroundColor3 = C.BTN
        }):Play()

        if callback then

            local ok, err = pcall(callback)

            if not ok then

                warn(
                    "[GUI ERROR]",
                    tostring(err)
                )

                if StatusLabel then
                    status(
                        "Error: "
                        .. tostring(err)
                    )
                end
            end
        end
    end)

    return b
end

local function toggle(
    text,
    o,
    onCb,
    offCb
)

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

            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = C.BTN_HOVER
            }):Play()

        end

    end)

    b.MouseLeave:Connect(function()

        if not isOn then

            TweenService:Create(b, TweenInfo.new(0.12), {
                BackgroundColor3 = C.BTN
            }):Play()

        end

    end)

    b.MouseButton1Click:Connect(function()

        isOn = not isOn

        if isOn then

            ind.Text = "ON"

            TweenService:Create(ind, TweenInfo.new(0.15), {
                BackgroundColor3 = C.GREEN
            }):Play()

            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = C.BTN_ON
            }):Play()

            if onCb then
                pcall(onCb)
            end

        else

            ind.Text = "OFF"

            TweenService:Create(ind, TweenInfo.new(0.15), {
                BackgroundColor3 = C.RED
            }):Play()

            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = C.BTN
            }):Play()

            if offCb then
                pcall(offCb)
            end

        end
    end)

    return b, function()
        return isOn
    end
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

function status(msg)

    if not StatusLabel
        or not StatusLabel.Parent then
        return
    end

    StatusLabel.Text = "⏺ " .. msg

    task.delay(4, function()

        if StatusLabel
            and StatusLabel.Parent
            and StatusLabel.Text
                == "⏺ " .. msg then

            StatusLabel.Text = "⏺ Ready"
        end

    end)
end

-- ═══════════════════════════════════════════════════════
--  GACHA / ROLL
-- ═══════════════════════════════════════════════════════

section(
    "🎰  GACHA / ROLL",
    nextO()
)

btn(
    "🎲  Roll Dice",
    nextO(),
    function()

        status("Rolling dice...")

        local ok, result = pcall(function()

            return invokeRF(
                "RollService",
                "RollDice"
            )

        end)

        if ok then
            status("Dice rolled!")
        else
            status("Roll failed!")
            warn(
                "[ROLL ERROR]",
                tostring(result)
            )
        end
    end
)

toggle(
    "🔄  Auto Roll",
    nextO(),

    function()

        status("Auto Roll: ON")

        local ok, err = pcall(function()

            fireRE(
                "RollService",
                "SetAutoRoll",
                true
            )

        end)

        if not ok then
            status("Auto Roll error!")
            warn(
                "[AUTO ROLL ERROR]",
                tostring(err)
            )
        end

    end,

    function()

        status("Auto Roll: OFF")

        pcall(function()

            fireRE(
                "RollService",
                "SetAutoRoll",
                false
            )

        end)

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  EQUIP
-- ═══════════════════════════════════════════════════════

section(
    "⚔️  EQUIP",
    nextO()
)

btn(
    "📦  Buka Tas (Equip 1 per 1)",
    nextO(),
    function()

        status("Opening bag...")

        fireRE(
            "OnboardingService",
            "Advance",
            2
        )

        status("Bag opened!")

    end
)

btn(
    "⚡  Equip Best → Slot Tanam",
    nextO(),
    function()

        status(
            "Equipping best to slots..."
        )

        fireRE(
            "PlotService",
            "EquipBest"
        )

        status("All slots filled!")

    end
)

local autoEquipBestOn = false

toggle(
    "🔄  Auto Equip Best",
    nextO(),

    function()

        autoEquipBestOn = true
        status("Auto Equip Best: ON")

        task.spawn(function()

            while autoEquipBestOn do

                pcall(function()

                    fireRE(
                        "PlotService",
                        "EquipBest"
                    )

                end)

                local nextDelay =
                    math.random(60, 300)

                local minutes =
                    math.floor(
                        nextDelay / 60
                    )

                local seconds =
                    nextDelay % 60

                status(string.format(
                    "Equip Best fired! Next in: %dm %ds",
                    minutes,
                    seconds
                ))

                local elapsed = 0

                while autoEquipBestOn
                    and elapsed < nextDelay do

                    task.wait(1)
                    elapsed += 1

                end
            end

            status(
                "Auto Equip Best: OFF"
            )

        end)
    end,

    function()

        autoEquipBestOn = false
        status(
            "Auto Equip Best: OFF"
        )

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  SELL
-- ═══════════════════════════════════════════════════════

section(
    "💰  SELL",
    nextO()
)

local function getSellableUUIDs()

    local success, result = pcall(function()

        local dataCtrl = require(
            ReplicatedStorage.Framework.Features.Data.DataController
        )

        local sellUtil = require(
            ReplicatedStorage.Framework.Features.Selling.SellUtil
        )

        local inventory =
            dataCtrl.Inventory()

        local slots =
            dataCtrl.Slots()

        if not inventory then
            error(
                "Inventory data tidak ditemukan"
            )
        end

        local summary =
            sellUtil.CreateSummary(
                inventory,
                slots
            )

        if not summary then
            error(
                "SellUtil.CreateSummary gagal"
            )
        end

        local uuids = {}

        if summary.sales then

            for _, sale in ipairs(
                summary.sales
            ) do

                if sale.key then

                    table.insert(
                        uuids,
                        sale.key
                    )

                end
            end
        end

        return uuids

    end)

    if success then
        return result or {}
    end

    warn(
        "[SELL SCAN ERROR]",
        tostring(result)
    )

    status(
        "Sell scan error!"
    )

    return {}
end

local function sellInventory()

    status(
        "Scanning inventory..."
    )

    local uuids =
        getSellableUUIDs()

    print(
        "[SELL] Sellable items:",
        #uuids
    )

    if #uuids == 0 then

        status(
            "Tidak ada hero yang bisa dijual!"
        )

        return
    end

    status(
        "Selling "
        .. #uuids
        .. " heroes..."
    )

    local success, result =
        pcall(function()

            return invokeRF(
                "SellService",
                "SellInventory",
                uuids
            )

        end)

    if success then

        status(
            "Sold "
            .. #uuids
            .. " heroes!"
        )

        print(
            "[SELL] SellInventory success:",
            result
        )

    else

        status(
            "Sell failed!"
        )

        warn(
            "[SELL ERROR]",
            tostring(result)
        )

    end
end

btn(
    "🎒  Sell Inventory (All Heroes)",
    nextO(),
    function()
        sellInventory()
    end
)

btn(
    "🗑️  Sell Equipped (Tangan)",
    nextO(),
    function()

        status(
            "Selling equipped..."
        )

        local success, result =
            pcall(function()

                return invokeRF(
                    "SellService",
                    "SellEquipped"
                )

            end)

        if success then

            status(
                "Equipped sold!"
            )

            print(
                "[SELL] SellEquipped success:",
                result
            )

        else

            status(
                "Sell equipped failed!"
            )

            warn(
                "[SELL EQUIPPED ERROR]",
                tostring(result)
            )

        end
    end
)

local autoSellInvOn = false

toggle(
    "🔄  Auto Sell Inventory",
    nextO(),

    function()

        autoSellInvOn = true
        status(
            "Auto Sell Inv: ON"
        )

        task.spawn(function()

            while autoSellInvOn do

                pcall(function()

                    local uuids =
                        getSellableUUIDs()

                    if #uuids > 0 then

                        local success, result =
                            pcall(function()

                                return invokeRF(
                                    "SellService",
                                    "SellInventory",
                                    uuids
                                )

                            end)

                        if success then

                            status(
                                "Auto Sold: "
                                .. #uuids
                                .. " units"
                            )

                        else

                            warn(
                                "[AUTO SELL ERROR]",
                                tostring(result)
                            )

                            status(
                                "Auto Sell failed!"
                            )

                        end
                    end

                end)

                task.wait(3)
            end

            status(
                "Auto Sell Inv: OFF"
            )

        end)
    end,

    function()

        autoSellInvOn = false

        status(
            "Auto Sell Inv: OFF"
        )

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  COLLECT BALANCE
-- ═══════════════════════════════════════════════════════

section(
    "💎  COLLECT BALANCE",
    nextO()
)

btn(
    "💵  Collect ALL Slots (1-8)",
    nextO(),
    function()

        status(
            "Collecting all slots..."
        )

        for i = 1, 8 do

            pcall(function()

                fireRE(
                    "PlotService",
                    "CollectBalance",
                    i
                )

            end)

            task.wait(0.08)
        end

        status(
            "All 8 slots collected!"
        )

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  REBIRTH
-- ═══════════════════════════════════════════════════════

section(
    "🌟  REBIRTH",
    nextO()
)

btn(
    "♻️  Rebirth (1x)",
    nextO(),
    function()

        status(
            "Attempting Rebirth..."
        )

        local success, result =
            pcall(function()

                return fireRE(
                    "RebirthService",
                    "Rebirth"
                )

            end)

        if success then

            status(
                "Rebirth request sent!"
            )

        else

            status(
                "Rebirth failed!"
            )

            warn(
                "[REBIRTH ERROR]",
                tostring(result)
            )

        end

    end
)

local autoRebirthOn = false

toggle(
    "🔄  Auto Rebirth",
    nextO(),

    function()

        autoRebirthOn = true
        status(
            "Auto Rebirth: ON"
        )

        task.spawn(function()

            while autoRebirthOn do

                pcall(function()

                    fireRE(
                        "RebirthService",
                        "Rebirth"
                    )

                end)

                local nextDelay =
                    math.random(60, 300)

                local minutes =
                    math.floor(
                        nextDelay / 60
                    )

                local seconds =
                    nextDelay % 60

                status(string.format(
                    "Rebirth fired! Next in: %dm %ds",
                    minutes,
                    seconds
                ))

                local elapsed = 0

                while autoRebirthOn
                    and elapsed < nextDelay do

                    task.wait(1)
                    elapsed += 1

                end

            end

            status(
                "Auto Rebirth: OFF"
            )

        end)
    end,

    function()

        autoRebirthOn = false

        status(
            "Auto Rebirth: OFF"
        )

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  BUY DICE
-- ═══════════════════════════════════════════════════════

section(
    "🛒  BUY DICE",
    nextO()
)

local ALL_DICES = {

    {
        name = "Normal",
        price = 1,
        luck = 2,
        emoji = "🎲"
    },

    {
        name = "Fire",
        price = 2500,
        luck = 5,
        emoji = "🔥"
    },

    {
        name = "Water",
        price = 10000,
        luck = 10,
        emoji = "💧"
    },

    {
        name = "Nature",
        price = 75000,
        luck = 20,
        emoji = "🌿"
    },

    {
        name = "Lightning",
        price = 500000,
        luck = 42.5,
        emoji = "⚡"
    },

    {
        name = "Ice",
        price = 4000000,
        luck = 100,
        emoji = "❄️"
    },

    {
        name = "Magma",
        price = 30000000,
        luck = 200,
        emoji = "🌋"
    },

    {
        name = "Storm",
        price = 200000000,
        luck = 400,
        emoji = "🌪️"
    },

    {
        name = "Light",
        price = 1200000000,
        luck = 1500,
        emoji = "✨"
    },

    {
        name = "Shadow",
        price = 1500000000,
        luck = 750,
        emoji = "🌑"
    },

    {
        name = "Blood Moon",
        price = 10000000000,
        luck = 3000,
        emoji = "🔴"
    },

    {
        name = "Void",
        price = 75000000000,
        luck = 6000,
        emoji = "🕳️"
    },

    {
        name = "Solar",
        price = 500000000000,
        luck = 12500,
        luckStr = "12.5k",
        emoji = "☀️"
    },

    {
        name = "Lunar",
        price = 3750000000000,
        luck = 25000,
        emoji = "🌙"
    },

    {
        name = "Galaxy",
        price = 15000000000000,
        luck = 50000,
        emoji = "🌌"
    },

    {
        name = "Black Hole",
        price = 100000000000000,
        luck = 100000,
        emoji = "⚫"
    },

    {
        name = "Dragon",
        price = 850000000000000,
        luck = 200000,
        emoji = "🐉"
    },

    {
        name = "Royal",
        price = 10000000000000000,
        luck = 400000,
        emoji = "👑"
    },

    {
        name = "Prismatic",
        price = 100000000000000000,
        luck = 1000000,
        emoji = "🌈"
    },

    {
        name = "Arcane",
        price = 1.25e18,
        luck = 2000000,
        emoji = "🔮"
    },

    {
        name = "Corrupted",
        price = 1.5e19,
        luck = 5000000,
        emoji = "☣️"
    },

    {
        name = "Titan",
        price = 1e21,
        luck = 10000000,
        emoji = "🗿"
    },

    {
        name = "Chrono",
        price = 1.5e22,
        luck = 25000000,
        emoji = "⏳"
    },
}

local function formatNumber(n)

    if not n then
        return "0"
    end

    if n >= 1e21 then

        return string.format(
            "%.1fSx",
            n / 1e21
        )

    elseif n >= 1e18 then

        return string.format(
            "%.1fQi",
            n / 1e18
        )

    elseif n >= 1e15 then

        return string.format(
            "%.1fQa",
            n / 1e15
        )

    elseif n >= 1e12 then

        return string.format(
            "%.1fT",
            n / 1e12
        )

    elseif n >= 1e9 then

        return string.format(
            "%.1fB",
            n / 1e9
        )

    elseif n >= 1e6 then

        return string.format(
            "%.1fM",
            n / 1e6
        )

    elseif n >= 1e3 then

        return string.format(
            "%.1fK",
            n / 1e3
        )

    else

        return tostring(n)

    end
end

-- ═══════════════════════════════════════════════════════
--  AUTO BUY BEST DICE
-- ═══════════════════════════════════════════════════════

local autoBuyBestOn = false

toggle(
    "🎯  Auto Buy Best Dice",
    nextO(),

    function()

        autoBuyBestOn = true

        status(
            "Auto Buy Best: ON"
        )

        task.spawn(function()

            while autoBuyBestOn do

                local success, err =
                    pcall(function()

                        local ls =
                            player:FindFirstChild(
                                "leaderstats"
                            )

                        local moneyVal =
                            ls
                            and ls:FindFirstChild(
                                "Money"
                            )

                        if not moneyVal then

                            status(
                                "Money tidak ditemukan!"
                            )

                            warn(
                                "[AUTO BUY] Money tidak ditemukan"
                            )

                            return
                        end

                        local money =
                            tonumber(
                                moneyVal.Value
                            )

                        print(
                            "[AUTO BUY] Money:",
                            moneyVal.Value,
                            "=>",
                            money
                        )

                        if not money then

                            status(
                                "Money bukan angka!"
                            )

                            warn(
                                "[AUTO BUY] Invalid Money:",
                                moneyVal.Value
                            )

                            return
                        end

                        local selectedDice = nil

                        -- Cari dice TERMAHAL
                        -- yang mampu dibeli
                        for i = #ALL_DICES, 1, -1 do

                            local d =
                                ALL_DICES[i]

                            if money >= d.price then

                                selectedDice = d
                                break

                            end
                        end

                        if not selectedDice then

                            status(
                                "Money kurang untuk dice!"
                            )

                            return
                        end

                        print(
                            "[AUTO BUY] Selected:",
                            selectedDice.name,
                            "| Price:",
                            selectedDice.price,
                            "| Money:",
                            money
                        )

                        status(
                            "Buying "
                            .. selectedDice.name
                            .. " ($"
                            .. formatNumber(
                                selectedDice.price
                            )
                            .. ")..."
                        )

                        -- BuyDice terbukti berada di:
                        -- Network > DiceShopService
                        -- > RE > BuyDice
                        fireRE(
                            "DiceShopService",
                            "BuyDice",
                            selectedDice.name
                        )

                        print(
                            "[AUTO BUY] BuyDice fired:",
                            selectedDice.name
                        )

                        status(
                            "BuyDice fired: "
                            .. selectedDice.name
                        )

                    end)

                if not success then

                    warn(
                        "[AUTO BUY ERROR]",
                        tostring(err)
                    )

                    status(
                        "Auto Buy error!"
                    )

                end

                -- Cek kembali setiap 60 detik
                local elapsed = 0
                local nextDelay = 60

                while autoBuyBestOn
                    and elapsed < nextDelay do

                    task.wait(1)
                    elapsed += 1

                end

            end

            status(
                "Auto Buy Best: OFF"
            )

        end)
    end,

    function()

        autoBuyBestOn = false

        status(
            "Auto Buy Best: OFF"
        )

    end
)

-- ═══════════════════════════════════════════════════════
--  INDIVIDUAL DICE BUTTONS
-- ═══════════════════════════════════════════════════════

for _, d in ipairs(ALL_DICES) do

    local text = string.format(
        "%s  Buy %s ($%s)",
        d.emoji,
        d.name,
        formatNumber(d.price)
    )

    btn(
        text,
        nextO(),
        function()

            status(
                "Buying "
                .. d.name
                .. "..."
            )

            local success, result =
                pcall(function()

                    return fireRE(
                        "DiceShopService",
                        "BuyDice",
                        d.name
                    )

                end)

            if success then

                status(
                    d.name
                    .. " purchased!"
                )

                print(
                    "[BUY] BuyDice fired:",
                    d.name
                )

            else

                status(
                    "Buy "
                    .. d.name
                    .. " failed!"
                )

                warn(
                    "[BUY ERROR]",
                    tostring(result)
                )

            end

        end
    )
end

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  AUTOMATION
-- ═══════════════════════════════════════════════════════

section(
    "🤖  AUTOMATION",
    nextO()
)

local autoFarmOn = false

toggle(
    "🔁  Auto Farm Loop",
    nextO(),

    function()

        autoFarmOn = true

        status(
            "Auto Farm STARTED"
        )

        task.spawn(function()

            while autoFarmOn do

                -- 1. Roll
                pcall(function()

                    invokeRF(
                        "RollService",
                        "RollDice"
                    )

                end)

                task.wait(0.3)

                -- 2. Equip Best
                pcall(function()

                    fireRE(
                        "PlotService",
                        "EquipBest"
                    )

                end)

                task.wait(0.2)

                -- 3. Collect
                for i = 1, 8 do

                    pcall(function()

                        fireRE(
                            "PlotService",
                            "CollectBalance",
                            i
                        )

                    end)

                    task.wait(0.05)
                end

                task.wait(0.2)

                -- 4. Sell Inventory
                pcall(function()

                    local uuids =
                        getSellableUUIDs()

                    if #uuids > 0 then

                        invokeRF(
                            "SellService",
                            "SellInventory",
                            uuids
                        )

                    end

                end)

                task.wait(0.8)

            end

            status(
                "Auto Farm STOPPED"
            )

        end)
    end,

    function()

        autoFarmOn = false

        status(
            "Auto Farm STOPPING..."
        )

    end
)

local autoCollectOn = false

toggle(
    "💰  Auto Collect Loop",
    nextO(),

    function()

        autoCollectOn = true

        status(
            "Auto Collect STARTED"
        )

        task.spawn(function()

            while autoCollectOn do

                for i = 1, 8 do

                    pcall(function()

                        fireRE(
                            "PlotService",
                            "CollectBalance",
                            i
                        )

                    end)

                    task.wait(0.05)

                end

                task.wait(3)

            end

            status(
                "Auto Collect STOPPED"
            )

        end)
    end,

    function()

        autoCollectOn = false

        status(
            "Auto Collect STOPPING..."
        )

    end
)

local autoRollBuyOn = false

toggle(
    "🎰  Auto Roll + Buy Normal",
    nextO(),

    function()

        autoRollBuyOn = true

        status(
            "Auto Roll+Buy STARTED"
        )

        task.spawn(function()

            while autoRollBuyOn do

                pcall(function()

                    invokeRF(
                        "RollService",
                        "RollDice"
                    )

                end)

                task.wait(0.2)

                pcall(function()

                    fireRE(
                        "DiceShopService",
                        "BuyDice",
                        "Normal"
                    )

                end)

                task.wait(0.5)

            end

            status(
                "Auto Roll+Buy STOPPED"
            )

        end)
    end,

    function()

        autoRollBuyOn = false

        status(
            "Auto Roll+Buy STOPPING..."
        )

    end
)

sep(nextO())

-- ═══════════════════════════════════════════════════════
--  DRAGGING
-- ═══════════════════════════════════════════════════════

local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)

    if input.UserInputType
        == Enum.UserInputType.MouseButton1
        or input.UserInputType
        == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()

            if input.UserInputState
                == Enum.UserInputState.End then

                dragging = false

            end

        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)

    if input.UserInputType
        == Enum.UserInputType.MouseMovement
        or input.UserInputType
        == Enum.UserInputType.Touch then

        dragInput = input

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if input == dragInput
        and dragging then

        local d =
            input.Position - dragStart

        MainFrame.Position =
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + d.X,
                startPos.Y.Scale,
                startPos.Y.Offset + d.Y
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

        Content.Visible = false
        StatsBar.Visible = false
        accent.Visible = false

        TweenService:Create(
            MainFrame,
            TweenInfo.new(
                TWEEN,
                Enum.EasingStyle.Quart
            ),
            {
                Size = UDim2.new(
                    0,
                    300,
                    0,
                    38
                )
            }
        ):Play()

        MinBtn.Text = "+"

    else

        TweenService:Create(
            MainFrame,
            TweenInfo.new(
                TWEEN,
                Enum.EasingStyle.Quart
            ),
            {
                Size = fullSize
            }
        ):Play()

        task.delay(TWEEN, function()

            if MainFrame
                and MainFrame.Parent then

                Content.Visible = true
                StatsBar.Visible = true
                accent.Visible = true

            end

        end)

        MinBtn.Text = "—"

    end

end)

ClsBtn.MouseButton1Click:Connect(function()

    -- Stop all loops
    autoFarmOn = false
    autoCollectOn = false
    autoBuyBestOn = false
    autoSellInvOn = false
    autoRebirthOn = false
    autoEquipBestOn = false
    autoRollBuyOn = false

    TweenService:Create(
        MainFrame,
        TweenInfo.new(
            0.18,
            Enum.EasingStyle.Quart
        ),
        {
            Size = UDim2.new(
                0,
                300,
                0,
                0
            )
        }
    ):Play()

    task.wait(0.2)

    ScreenGui:Destroy()

end)

-- ═══════════════════════════════════════════════════════
--  DONE
-- ═══════════════════════════════════════════════════════

status(
    "GUI Loaded! 🎲"
)

print(
    "[DiceGachaHub] Loaded successfully!"
)

print(
    "[AntiAFK] Active"
)
