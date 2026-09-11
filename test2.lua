-- ═══════════════════════════════════════════════════════════════
-- 🎲 DICE GACHA HUB
-- 2 COLUMN VERSION
--
-- LEFT  : Gacha / Equip / Sell / Collect / Rebirth / Automation
-- RIGHT : Buy Dice
--
-- AUTOMATION:
-- Roll → Equip Best → Collect 1-8 → Sell Inventory → Repeat
--
-- AUTO EQUIP BEST : Every 10 seconds
-- AUTO COLLECT    : Every 2 minutes
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- ANTI AFK
-- ═══════════════════════════════════════════════════════════════

pcall(function()

    player.Idled:Connect(function()

        pcall(function()

            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))

            print("[AntiAFK] Idle input sent")

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

-- ═══════════════════════════════════════════════════════════════
-- NETWORK
-- ═══════════════════════════════════════════════════════════════

local function getNetwork()

    return ReplicatedStorage:WaitForChild(
        "Network",
        9e9
    )

end

-- RemoteEvent
-- Network > Service > RE > RemoteEvent
local function fireRE(serviceName, remoteName, ...)

    local network = getNetwork()

    local service =
        network:WaitForChild(
            serviceName,
            9e9
        )

    local folder =
        service:WaitForChild(
            "RE",
            9e9
        )

    local remote =
        folder:WaitForChild(
            remoteName,
            9e9
        )

    if not remote:IsA("RemoteEvent") then

        error(
            remote:GetFullName()
            .. " is "
            .. remote.ClassName
            .. ", expected RemoteEvent"
        )

    end

    return remote:FireServer(...)

end

-- RemoteFunction
-- Network > Service > RF > RemoteFunction
local function invokeRF(serviceName, remoteName, ...)

    local network = getNetwork()

    local service =
        network:WaitForChild(
            serviceName,
            9e9
        )

    local folder =
        service:WaitForChild(
            "RF",
            9e9
        )

    local remote =
        folder:WaitForChild(
            remoteName,
            9e9
        )

    if not remote:IsA("RemoteFunction") then

        error(
            remote:GetFullName()
            .. " is "
            .. remote.ClassName
            .. ", expected RemoteFunction"
        )

    end

    return remote:InvokeServer(...)

end

-- ═══════════════════════════════════════════════════════════════
-- REMOVE OLD GUI
-- ═══════════════════════════════════════════════════════════════

local oldGui =
    PlayerGui:FindFirstChild(
        "DiceGachaGUI"
    )

if oldGui then
    oldGui:Destroy()
end

-- ═══════════════════════════════════════════════════════════════
-- GUI
-- ═══════════════════════════════════════════════════════════════

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "DiceGachaGUI"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    PlayerGui

-- ═══════════════════════════════════════════════════════════════
-- COLORS
-- ═══════════════════════════════════════════════════════════════

local C = {

    BG =
        Color3.fromRGB(
            20,
            20,
            30
        ),

    BAR =
        Color3.fromRGB(
            30,
            30,
            45
        ),

    ACCENT =
        Color3.fromRGB(
            88,
            101,
            242
        ),

    BTN =
        Color3.fromRGB(
            40,
            40,
            58
        ),

    BTN_HOVER =
        Color3.fromRGB(
            55,
            55,
            78
        ),

    BTN_ON =
        Color3.fromRGB(
            46,
            160,
            87
        ),

    RED =
        Color3.fromRGB(
            210,
            55,
            55
        ),

    YELLOW =
        Color3.fromRGB(
            220,
            170,
            40
        ),

    GREEN =
        Color3.fromRGB(
            46,
            160,
            87
        ),

    TEXT =
        Color3.fromRGB(
            225,
            225,
            235
        ),

    TEXT_DIM =
        Color3.fromRGB(
            120,
            120,
            145
        ),

    SECTION =
        Color3.fromRGB(
            140,
            160,
            255
        ),

    SEP =
        Color3.fromRGB(
            45,
            45,
            65
        ),

    STATS_BG =
        Color3.fromRGB(
            30,
            32,
            48
        )
}

local FONT_B =
    Enum.Font.GothamBold

local FONT =
    Enum.Font.GothamMedium

local TWEEN =
    0.22

-- ═══════════════════════════════════════════════════════════════
-- MAIN FRAME
-- ═══════════════════════════════════════════════════════════════

local MainFrame =
    Instance.new("Frame")

MainFrame.Name =
    "MainFrame"

MainFrame.Size =
    UDim2.new(
        0,
        680,
        0,
        540
    )

MainFrame.Position =
    UDim2.new(
        0.5,
        -340,
        0.5,
        -270
    )

MainFrame.BackgroundColor3 =
    C.BG

MainFrame.BorderSizePixel =
    0

MainFrame.ClipsDescendants =
    true

MainFrame.Parent =
    ScreenGui

Instance.new(
    "UICorner",
    MainFrame
).CornerRadius =
    UDim.new(
        0,
        10
    )

local stroke =
    Instance.new(
        "UIStroke",
        MainFrame
    )

stroke.Color =
    C.ACCENT

stroke.Thickness =
    1.5

stroke.Transparency =
    0.3

-- ═══════════════════════════════════════════════════════════════
-- TITLE BAR
-- ═══════════════════════════════════════════════════════════════

local TitleBar =
    Instance.new("Frame")

TitleBar.Size =
    UDim2.new(
        1,
        0,
        0,
        40
    )

TitleBar.BackgroundColor3 =
    C.BAR

TitleBar.BorderSizePixel =
    0

TitleBar.Parent =
    MainFrame

Instance.new(
    "UICorner",
    TitleBar
).CornerRadius =
    UDim.new(
        0,
        10
    )

local titleFix =
    Instance.new("Frame")

titleFix.Size =
    UDim2.new(
        1,
        0,
        0,
        12
    )

titleFix.Position =
    UDim2.new(
        0,
        0,
        1,
        -12
    )

titleFix.BackgroundColor3 =
    C.BAR

titleFix.BorderSizePixel =
    0

titleFix.Parent =
    TitleBar

local accentLine =
    Instance.new("Frame")

accentLine.Size =
    UDim2.new(
        1,
        0,
        0,
        2
    )

accentLine.Position =
    UDim2.new(
        0,
        0,
        1,
        0
    )

accentLine.BackgroundColor3 =
    C.ACCENT

accentLine.BorderSizePixel =
    0

accentLine.Parent =
    TitleBar

local title =
    Instance.new("TextLabel")

title.Size =
    UDim2.new(
        1,
        -110,
        1,
        0
    )

title.Position =
    UDim2.new(
        0,
        14,
        0,
        0
    )

title.BackgroundTransparency =
    1

title.Text =
    "🎲 Dice Gacha Hub"

title.TextSize =
    14

title.Font =
    FONT_B

title.TextColor3 =
    C.TEXT

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent =
    TitleBar

-- ═══════════════════════════════════════════════════════════════
-- TITLE BUTTON
-- ═══════════════════════════════════════════════════════════════

local function makeTitleBtn(
    name,
    textValue,
    color,
    x
)

    local b =
        Instance.new("TextButton")

    b.Name =
        name

    b.Size =
        UDim2.new(
            0,
            28,
            0,
            22
        )

    b.Position =
        UDim2.new(
            1,
            x,
            0.5,
            -11
        )

    b.BackgroundColor3 =
        color

    b.BorderSizePixel =
        0

    b.Text =
        textValue

    b.TextSize =
        13

    b.Font =
        FONT_B

    b.TextColor3 =
        C.TEXT

    b.AutoButtonColor =
        false

    b.Parent =
        TitleBar

    Instance.new(
        "UICorner",
        b
    ).CornerRadius =
        UDim.new(
            0,
            6
        )

    b.MouseEnter:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        math.min(
                            color.R * 255 + 35,
                            255
                        ),
                        math.min(
                            color.G * 255 + 35,
                            255
                        ),
                        math.min(
                            color.B * 255 + 35,
                            255
                        )
                    )
            }
        ):Play()

    end)

    b.MouseLeave:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    color
            }
        ):Play()

    end)

    return b

end

local MinBtn =
    makeTitleBtn(
        "Min",
        "—",
        C.YELLOW,
        -66
    )

local ClsBtn =
    makeTitleBtn(
        "Cls",
        "✕",
        C.RED,
        -34
    )

-- ═══════════════════════════════════════════════════════════════
-- STATS
-- ═══════════════════════════════════════════════════════════════

local StatsBar =
    Instance.new("Frame")

StatsBar.Size =
    UDim2.new(
        1,
        -16,
        0,
        34
    )

StatsBar.Position =
    UDim2.new(
        0,
        8,
        0,
        45
    )

StatsBar.BackgroundColor3 =
    C.STATS_BG

StatsBar.BorderSizePixel =
    0

StatsBar.Parent =
    MainFrame

Instance.new(
    "UICorner",
    StatsBar
).CornerRadius =
    UDim.new(
        0,
        8
    )

local MoneyLabel =
    Instance.new("TextLabel")

MoneyLabel.Size =
    UDim2.new(
        0.5,
        0,
        1,
        0
    )

MoneyLabel.BackgroundTransparency =
    1

MoneyLabel.Text =
    "💰 Money: ---"

MoneyLabel.TextSize =
    12

MoneyLabel.Font =
    FONT_B

MoneyLabel.TextColor3 =
    C.YELLOW

MoneyLabel.Parent =
    StatsBar

local RollsLabel =
    Instance.new("TextLabel")

RollsLabel.Size =
    UDim2.new(
        0.5,
        0,
        1,
        0
    )

RollsLabel.Position =
    UDim2.new(
        0.5,
        0,
        0,
        0
    )

RollsLabel.BackgroundTransparency =
    1

RollsLabel.Text =
    "🎲 Rolls: ---"

RollsLabel.TextSize =
    12

RollsLabel.Font =
    FONT_B

RollsLabel.TextColor3 =
    C.SECTION

RollsLabel.Parent =
    StatsBar

local function updateStats()

    pcall(function()

        local ls =
            player:FindFirstChild(
                "leaderstats"
            )

        if not ls then
            return
        end

        local money =
            ls:FindFirstChild(
                "Money"
            )

        local rolls =
            ls:FindFirstChild(
                "Rolls"
            )

        if money then

            MoneyLabel.Text =
                "💰 Money: "
                .. tostring(
                    money.Value
                )

        end

        if rolls then

            RollsLabel.Text =
                "🎲 Rolls: "
                .. tostring(
                    rolls.Value
                )

        end

    end)

end

task.spawn(function()

    while ScreenGui
        and ScreenGui.Parent do

        updateStats()

        task.wait(1)

    end

end)

-- ═══════════════════════════════════════════════════════════════
-- STATUS
-- ═══════════════════════════════════════════════════════════════

local StatusLabel =
    Instance.new("TextLabel")

StatusLabel.Size =
    UDim2.new(
        1,
        -20,
        0,
        22
    )

StatusLabel.Position =
    UDim2.new(
        0,
        10,
        1,
        -26
    )

StatusLabel.BackgroundTransparency =
    1

StatusLabel.Text =
    "⏺ Ready"

StatusLabel.TextSize =
    10

StatusLabel.Font =
    FONT

StatusLabel.TextColor3 =
    C.TEXT_DIM

StatusLabel.TextXAlignment =
    Enum.TextXAlignment.Left

StatusLabel.Parent =
    MainFrame

local function status(msg)

    if not StatusLabel
        or not StatusLabel.Parent then
        return
    end

    StatusLabel.Text =
        "⏺ " .. msg

end

-- ═══════════════════════════════════════════════════════════════
-- TWO COLUMN CONTAINER
-- ═══════════════════════════════════════════════════════════════

local Columns =
    Instance.new("Frame")

Columns.Size =
    UDim2.new(
        1,
        -16,
        1,
        -113
    )

Columns.Position =
    UDim2.new(
        0,
        8,
        0,
        85
    )

Columns.BackgroundTransparency =
    1

Columns.Parent =
    MainFrame

-- LEFT
local Left =
    Instance.new("ScrollingFrame")

Left.Name =
    "LeftColumn"

Left.Size =
    UDim2.new(
        0.5,
        -6,
        1,
        0
    )

Left.Position =
    UDim2.new(
        0,
        0,
        0,
        0
    )

Left.BackgroundTransparency =
    1

Left.BorderSizePixel =
    0

Left.ScrollBarThickness =
    3

Left.ScrollBarImageColor3 =
    C.ACCENT

Left.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

Left.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        0
    )

Left.Parent =
    Columns

-- RIGHT
local Right =
    Instance.new("ScrollingFrame")

Right.Name =
    "DiceColumn"

Right.Size =
    UDim2.new(
        0.5,
        -6,
        1,
        0
    )

Right.Position =
    UDim2.new(
        0.5,
        6,
        0,
        0
    )

Right.BackgroundTransparency =
    1

Right.BorderSizePixel =
    0

Right.ScrollBarThickness =
    3

Right.ScrollBarImageColor3 =
    C.ACCENT

Right.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

Right.CanvasSize =
    UDim2.new(
        0,
        0,
        0,
        0
    )

Right.Parent =
    Columns

local leftLayout =
    Instance.new(
        "UIListLayout",
        Left
    )

leftLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

leftLayout.Padding =
    UDim.new(
        0,
        5
    )

local rightLayout =
    Instance.new(
        "UIListLayout",
        Right
    )

rightLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

rightLayout.Padding =
    UDim.new(
        0,
        5
    )

-- ═══════════════════════════════════════════════════════════════
-- BUILDERS
-- ═══════════════════════════════════════════════════════════════

local leftOrder = 0
local rightOrder = 0

local function nextLeft()

    leftOrder += 1

    return leftOrder

end

local function nextRight()

    rightOrder += 1

    return rightOrder

end

local function sectionLeft(text)

    local l =
        Instance.new("TextLabel")

    l.Size =
        UDim2.new(
            1,
            0,
            0,
            25
        )

    l.BackgroundTransparency =
        1

    l.Text =
        "  " .. text

    l.TextSize =
        11

    l.Font =
        FONT_B

    l.TextColor3 =
        C.SECTION

    l.TextXAlignment =
        Enum.TextXAlignment.Left

    l.LayoutOrder =
        nextLeft()

    l.Parent =
        Left

end

local function sectionRight(text)

    local l =
        Instance.new("TextLabel")

    l.Size =
        UDim2.new(
            1,
            0,
            0,
            25
        )

    l.BackgroundTransparency =
        1

    l.Text =
        "  " .. text

    l.TextSize =
        11

    l.Font =
        FONT_B

    l.TextColor3 =
        C.SECTION

    l.TextXAlignment =
        Enum.TextXAlignment.Left

    l.LayoutOrder =
        nextRight()

    l.Parent =
        Right

end

local function separator(parent, order)

    local s =
        Instance.new("Frame")

    s.Size =
        UDim2.new(
            1,
            -8,
            0,
            1
        )

    s.BackgroundColor3 =
        C.SEP

    s.BorderSizePixel =
        0

    s.LayoutOrder =
        order

    s.Parent =
        parent

end

local function button(
    parent,
    textValue,
    order,
    callback
)

    local b =
        Instance.new("TextButton")

    b.Size =
        UDim2.new(
            1,
            -2,
            0,
            34
        )

    b.BackgroundColor3 =
        C.BTN

    b.BorderSizePixel =
        0

    b.Text =
        ""

    b.AutoButtonColor =
        false

    b.LayoutOrder =
        order

    b.Parent =
        parent

    Instance.new(
        "UICorner",
        b
    ).CornerRadius =
        UDim.new(
            0,
            8
        )

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -20,
            1,
            0
        )

    label.Position =
        UDim2.new(
            0,
            12,
            0,
            0
        )

    label.BackgroundTransparency =
        1

    label.Text =
        textValue

    label.TextSize =
        12

    label.Font =
        FONT

    label.TextColor3 =
        C.TEXT

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        b

    b.MouseEnter:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    C.BTN_HOVER
            }
        ):Play()

    end)

    b.MouseLeave:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 =
                    C.BTN
            }
        ):Play()

    end)

    b.MouseButton1Click:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.06),
            {
                BackgroundColor3 =
                    C.ACCENT
            }
        ):Play()

        task.delay(
            0.08,
            function()

                if b and b.Parent then

                    TweenService:Create(
                        b,
                        TweenInfo.new(0.12),
                        {
                            BackgroundColor3 =
                                C.BTN
                        }
                    ):Play()

                end

            end
        )

        if callback then

            local ok, err =
                pcall(callback)

            if not ok then

                warn(
                    "[GUI ERROR]",
                    tostring(err)
                )

                status(
                    "Error: "
                    .. tostring(err)
                )

            end

        end

    end)

    return b

end

local function toggle(
    parent,
    textValue,
    order,
    onCallback,
    offCallback
)

    local state = false

    local b =
        Instance.new("TextButton")

    b.Size =
        UDim2.new(
            1,
            -2,
            0,
            34
        )

    b.BackgroundColor3 =
        C.BTN

    b.BorderSizePixel =
        0

    b.Text =
        ""

    b.AutoButtonColor =
        false

    b.LayoutOrder =
        order

    b.Parent =
        parent

    Instance.new(
        "UICorner",
        b
    ).CornerRadius =
        UDim.new(
            0,
            8
        )

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -65,
            1,
            0
        )

    label.Position =
        UDim2.new(
            0,
            12,
            0,
            0
        )

    label.BackgroundTransparency =
        1

    label.Text =
        textValue

    label.TextSize =
        12

    label.Font =
        FONT

    label.TextColor3 =
        C.TEXT

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        b

    local indicator =
        Instance.new("TextLabel")

    indicator.Size =
        UDim2.new(
            0,
            48,
            0,
            22
        )

    indicator.Position =
        UDim2.new(
            1,
            -58,
            0.5,
            -11
        )

    indicator.BackgroundColor3 =
        C.RED

    indicator.Text =
        "OFF"

    indicator.TextSize =
        10

    indicator.Font =
        FONT_B

    indicator.TextColor3 =
        C.TEXT

    indicator.Parent =
        b

    Instance.new(
        "UICorner",
        indicator
    ).CornerRadius =
        UDim.new(
            0,
            6
        )

    b.MouseButton1Click:Connect(function()

        state =
            not state

        if state then

            indicator.Text =
                "ON"

            TweenService:Create(
                indicator,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        C.GREEN
                }
            ):Play()

            TweenService:Create(
                b,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        C.BTN_ON
                }
            ):Play()

            if onCallback then
                pcall(onCallback)
            end

        else

            indicator.Text =
                "OFF"

            TweenService:Create(
                indicator,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        C.RED
                }
            ):Play()

            TweenService:Create(
                b,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        C.BTN
                }
            ):Play()

            if offCallback then
                pcall(offCallback)
            end

        end

    end)

    return b

end

-- ═══════════════════════════════════════════════════════════════
-- SELL
-- ═══════════════════════════════════════════════════════════════

local function getSellableUUIDs()

    local success, result =
        pcall(function()

            local dataCtrl =
                require(
                    ReplicatedStorage.Framework.Features.Data.DataController
                )

            local sellUtil =
                require(
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

    return {}

end

local function sellInventory()

    local uuids =
        getSellableUUIDs()

    print(
        "[SELL] Sellable:",
        #uuids
    )

    if #uuids <= 0 then

        status(
            "No sellable heroes"
        )

        return

    end

    status(
        "Selling "
        .. #uuids
        .. " heroes..."
    )

    local ok, result =
        pcall(function()

            return invokeRF(
                "SellService",
                "SellInventory",
                uuids
            )

        end)

    if ok then

        status(
            "Sold "
            .. #uuids
            .. " heroes!"
        )

        print(
            "[SELL] Success:",
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

-- ═══════════════════════════════════════════════════════════════
-- LEFT MENU
-- ═══════════════════════════════════════════════════════════════

-- GACHA
sectionLeft(
    "🎰  GACHA / ROLL"
)

button(
    Left,
    "🎲  Roll Dice",
    nextLeft(),
    function()

        status(
            "Rolling dice..."
        )

        local ok, result =
            pcall(function()

                return invokeRF(
                    "RollService",
                    "RollDice"
                )

            end)

        if ok then

            status(
                "Dice rolled!"
            )

        else

            status(
                "Roll failed!"
            )

            warn(
                "[ROLL ERROR]",
                tostring(result)
            )

        end

    end
)

toggle(
    Left,
    "🔄  Auto Roll",
    nextLeft(),

    function()

        status(
            "Auto Roll: ON"
        )

        pcall(function()

            fireRE(
                "RollService",
                "SetAutoRoll",
                true
            )

        end)

    end,

    function()

        status(
            "Auto Roll: OFF"
        )

        pcall(function()

            fireRE(
                "RollService",
                "SetAutoRoll",
                false
            )

        end)

    end
)

separator(
    Left,
    nextLeft()
)

-- EQUIP
sectionLeft(
    "⚔️  EQUIP"
)

button(
    Left,
    "📦  Buka Tas (Equip 1 per 1)",
    nextLeft(),
    function()

        fireRE(
            "OnboardingService",
            "Advance",
            2
        )

        status(
            "Bag opened!"
        )

    end
)

button(
    Left,
    "⚡  Equip Best",
    nextLeft(),
    function()

        fireRE(
            "PlotService",
            "EquipBest"
        )

        status(
            "Equip Best fired!"
        )

    end
)

-- AUTO EQUIP
local autoEquipBestOn =
    false

toggle(
    Left,
    "⚡  Auto Equip Best (10s)",
    nextLeft(),

    function()

        autoEquipBestOn =
            true

        status(
            "Auto Equip Best: ON (10s)"
        )

        task.spawn(function()

            while autoEquipBestOn do

                pcall(function()

                    fireRE(
                        "PlotService",
                        "EquipBest"
                    )

                end)

                task.wait(10)

            end

        end)

    end,

    function()

        autoEquipBestOn =
            false

        status(
            "Auto Equip Best: OFF"
        )

    end
)

separator(
    Left,
    nextLeft()
)

-- SELL
sectionLeft(
    "💰  SELL"
)

button(
    Left,
    "🎒  Sell Inventory",
    nextLeft(),
    function()

        sellInventory()

    end
)

button(
    Left,
    "🗑️  Sell Equipped",
    nextLeft(),
    function()

        status(
            "Selling equipped..."
        )

        local ok, result =
            pcall(function()

                return invokeRF(
                    "SellService",
                    "SellEquipped"
                )

            end)

        if ok then

            status(
                "Equipped sold!"
            )

        else

            status(
                "Sell equipped failed!"
            )

            warn(
                "[SELL EQUIPPED]",
                tostring(result)
            )

        end

    end
)

-- AUTO SELL
local autoSellOn =
    false

toggle(
    Left,
    "🔄  Auto Sell Inventory",
    nextLeft(),

    function()

        autoSellOn =
            true

        status(
            "Auto Sell: ON"
        )

        task.spawn(function()

            while autoSellOn do

                pcall(function()

                    sellInventory()

                end)

                task.wait(3)

            end

        end)

    end,

    function()

        autoSellOn =
            false

        status(
            "Auto Sell: OFF"
        )

    end
)

separator(
    Left,
    nextLeft()
)

-- COLLECT
sectionLeft(
    "💎  COLLECT BALANCE"
)

local function collectAll()

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

end

button(
    Left,
    "💵  Collect ALL Slots (1-8)",
    nextLeft(),
    function()

        status(
            "Collecting..."
        )

        collectAll()

        status(
            "All 8 slots collected!"
        )

    end
)

-- AUTO COLLECT 2 MIN
local autoCollectOn =
    false

toggle(
    Left,
    "💰  Auto Collect (2 Minutes)",
    nextLeft(),

    function()

        autoCollectOn =
            true

        status(
            "Auto Collect: ON (2m)"
        )

        task.spawn(function()

            while autoCollectOn do

                collectAll()

                status(
                    "Collected! Next in 2 minutes"
                )

                local elapsed =
                    0

                while autoCollectOn
                    and elapsed < 120 do

                    task.wait(1)

                    elapsed += 1

                end

            end

        end)

    end,

    function()

        autoCollectOn =
            false

        status(
            "Auto Collect: OFF"
        )

    end
)

separator(
    Left,
    nextLeft()
)

-- REBIRTH
sectionLeft(
    "🌟  REBIRTH"
)

button(
    Left,
    "♻️  Rebirth (1x)",
    nextLeft(),
    function()

        status(
            "Rebirth..."
        )

        pcall(function()

            fireRE(
                "RebirthService",
                "Rebirth"
            )

        end)

        status(
            "Rebirth request sent!"
        )

    end
)

-- AUTO REBIRTH
local autoRebirthOn =
    false

toggle(
    Left,
    "🔄  Auto Rebirth",
    nextLeft(),

    function()

        autoRebirthOn =
            true

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

                local elapsed =
                    0

                local delayTime =
                    math.random(
                        60,
                        300
                    )

                while autoRebirthOn
                    and elapsed < delayTime do

                    task.wait(1)

                    elapsed += 1

                end

            end

        end)

    end,

    function()

        autoRebirthOn =
            false

        status(
            "Auto Rebirth: OFF"
        )

    end
)

separator(
    Left,
    nextLeft()
)

-- ═══════════════════════════════════════════════════════════════
-- AUTOMATION
-- ═══════════════════════════════════════════════════════════════

sectionLeft(
    "🤖  AUTOMATION"
)

local autoFarmOn =
    false

toggle(
    Left,
    "🤖  Auto Farm",
    nextLeft(),

    function()

        autoFarmOn =
            true

        status(
            "Auto Farm: ON"
        )

        task.spawn(function()

            while autoFarmOn do

                -- ─────────────────────────
                -- 1. ROLL
                -- ─────────────────────────

                pcall(function()

                    invokeRF(
                        "RollService",
                        "RollDice"
                    )

                end)

                task.wait(0.3)

                if not autoFarmOn then
                    break
                end

                -- ─────────────────────────
                -- 2. EQUIP BEST
                -- ─────────────────────────

                pcall(function()

                    fireRE(
                        "PlotService",
                        "EquipBest"
                    )

                end)

                task.wait(0.2)

                if not autoFarmOn then
                    break
                end

                -- ─────────────────────────
                -- 3. COLLECT 1-8
                -- ─────────────────────────

                for i = 1, 8 do

                    if not autoFarmOn then
                        break
                    end

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

                if not autoFarmOn then
                    break
                end

                -- ─────────────────────────
                -- 4. SELL
                -- ─────────────────────────

                pcall(function()

                    sellInventory()

                end)

                -- ─────────────────────────
                -- LOOP DELAY
                -- ─────────────────────────

                task.wait(0.8)

            end

            status(
                "Auto Farm: OFF"
            )

        end)

    end,

    function()

        autoFarmOn =
            false

        status(
            "Auto Farm: STOPPING..."
        )

    end
)

-- ═══════════════════════════════════════════════════════════════
-- RIGHT SIDE : DICE SHOP
-- ═══════════════════════════════════════════════════════════════

sectionRight(
    "🛒  DICE SHOP"
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
    }
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

-- ═══════════════════════════════════════════════════════════════
-- AUTO BUY BEST
-- ═══════════════════════════════════════════════════════════════

local autoBuyBestOn =
    false

toggle(
    Right,
    "🎯  Auto Buy Best Dice",
    nextRight(),

    function()

        autoBuyBestOn =
            true

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

                            warn(
                                "[AUTO BUY] Money not found"
                            )

                            return

                        end

                        local money =
                            tonumber(
                                moneyVal.Value
                            )

                        if not money then

                            warn(
                                "[AUTO BUY] Invalid money:",
                                moneyVal.Value
                            )

                            return

                        end

                        local selectedDice

                        -- termahal -> termurah
                        for i =
                            #ALL_DICES,
                            1,
                            -1 do

                            local d =
                                ALL_DICES[i]

                            if money >= d.price then

                                selectedDice =
                                    d

                                break

                            end

                        end

                        if not selectedDice then

                            status(
                                "Money belum cukup!"
                            )

                            return

                        end

                        print(
                            "[AUTO BUY]",
                            "Money:",
                            money,
                            "Selected:",
                            selectedDice.name,
                            "Price:",
                            selectedDice.price
                        )

                        status(
                            "Buying "
                            .. selectedDice.name
                            .. "..."
                        )

                        -- BuyDice:
                        -- DiceShopService > RE > BuyDice
                        fireRE(
                            "DiceShopService",
                            "BuyDice",
                            selectedDice.name
                        )

                        print(
                            "[AUTO BUY] BuyDice fired:",
                            selectedDice.name
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

                -- check every 60 seconds
                local elapsed =
                    0

                while autoBuyBestOn
                    and elapsed < 60 do

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

        autoBuyBestOn =
            false

        status(
            "Auto Buy Best: OFF"
        )

    end
)

separator(
    Right,
    nextRight()
)

-- ═══════════════════════════════════════════════════════════════
-- INDIVIDUAL DICE
-- ═══════════════════════════════════════════════════════════════

for _, d in ipairs(
    ALL_DICES
) do

    local text =
        string.format(
            "%s  %s  •  $%s",
            d.emoji,
            d.name,
            formatNumber(
                d.price
            )
        )

    button(
        Right,
        text,
        nextRight(),
        function()

            status(
                "Buying "
                .. d.name
                .. "..."
            )

            local ok, result =
                pcall(function()

                    return fireRE(
                        "DiceShopService",
                        "BuyDice",
                        d.name
                    )

                end)

            if ok then

                status(
                    d.name
                    .. " purchase sent!"
                )

                print(
                    "[BUY] BuyDice fired:",
                    d.name
                )

            else

                status(
                    "Buy failed!"
                )

                warn(
                    "[BUY ERROR]",
                    tostring(result)
                )

            end

        end
    )

end

-- ═══════════════════════════════════════════════════════════════
-- DRAGGING
-- ═══════════════════════════════════════════════════════════════

local dragging =
    false

local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)

    if input.UserInputType
        == Enum.UserInputType.MouseButton1
        or input.UserInputType
        == Enum.UserInputType.Touch then

        dragging =
            true

        dragStart =
            input.Position

        startPos =
            MainFrame.Position

        input.Changed:Connect(function()

            if input.UserInputState
                == Enum.UserInputState.End then

                dragging =
                    false

            end

        end)

    end

end)

TitleBar.InputChanged:Connect(function(input)

    if input.UserInputType
        == Enum.UserInputType.MouseMovement
        or input.UserInputType
        == Enum.UserInputType.Touch then

        dragInput =
            input

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if input == dragInput
        and dragging then

        local delta =
            input.Position
            - dragStart

        MainFrame.Position =
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset
                    + delta.X,

                startPos.Y.Scale,
                startPos.Y.Offset
                    + delta.Y
            )

    end

end)

-- ═══════════════════════════════════════════════════════════════
-- MINIMIZE
-- ═══════════════════════════════════════════════════════════════

local minimized =
    false

local fullSize =
    MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()

    minimized =
        not minimized

    if minimized then

        Columns.Visible =
            false

        StatsBar.Visible =
            false

        StatusLabel.Visible =
            false

        accentLine.Visible =
            false

        TweenService:Create(
            MainFrame,
            TweenInfo.new(
                TWEEN,
                Enum.EasingStyle.Quart
            ),
            {
                Size =
                    UDim2.new(
                        0,
                        680,
                        0,
                        40
                    )
            }
        ):Play()

        MinBtn.Text =
            "+"

    else

        TweenService:Create(
            MainFrame,
            TweenInfo.new(
                TWEEN,
                Enum.EasingStyle.Quart
            ),
            {
                Size =
                    fullSize
            }
        ):Play()

        task.delay(
            TWEEN,
            function()

                if MainFrame
                    and MainFrame.Parent then

                    Columns.Visible =
                        true

                    StatsBar.Visible =
                        true

                    StatusLabel.Visible =
                        true

                    accentLine.Visible =
                        true

                end

            end
        )

        MinBtn.Text =
            "—"

    end

end)

-- ═══════════════════════════════════════════════════════════════
-- CLOSE
-- ═══════════════════════════════════════════════════════════════

ClsBtn.MouseButton1Click:Connect(function()

    -- stop all automation
    autoFarmOn =
        false

    autoCollectOn =
        false

    autoEquipBestOn =
        false

    autoSellOn =
        false

    autoBuyBestOn =
        false

    autoRebirthOn =
        false

    -- animation
    TweenService:Create(
        MainFrame,
        TweenInfo.new(
            0.18,
            Enum.EasingStyle.Quart
        ),
        {
            Size =
                UDim2.new(
                    0,
                    680,
                    0,
                    0
                )
        }
    ):Play()

    task.wait(0.2)

    if ScreenGui then
        ScreenGui:Destroy()
    end

end)

-- ═══════════════════════════════════════════════════════════════
-- DONE
-- ═══════════════════════════════════════════════════════════════

status(
    "GUI Loaded! 🎲"
)

print(
    "════════════════════════════════════"
)

print(
    "[DiceGachaHub] Loaded successfully!"
)

print(
    "[AntiAFK] Active"
)

print(
    "[AutoEquip] 10 seconds"
)

print(
    "[AutoCollect] 2 minutes"
)

print(
    "[Automation] Roll > Equip > Collect > Sell"
)

print(
    "════════════════════════════════════"
)
