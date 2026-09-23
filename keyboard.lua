--// LIME - FULL ON-SCREEN KEYBOARD
--// Touch keyboard untuk Roblox Cloud Android
--// Drag + Minimize + Close

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- HAPUS KEYBOARD LAMA
--==================================================

local old = playerGui:FindFirstChild("LimeKeyboard")
if old then
    old:Destroy()
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "LimeKeyboard"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = playerGui

--==================================================
-- INPUT ENGINE
--==================================================

local VIM

pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local function sendKey(key)

    if not key then
        return false
    end

    -- Method 1: executor keypress API
    local ok = pcall(function()

        if type(keypress) == "function"
        and type(keyrelease) == "function" then

            keypress(key.Value)
            task.wait(0.04)
            keyrelease(key.Value)

            return
        end

        error("keypress unavailable")

    end)

    if ok then
        return true
    end

    -- Method 2: VirtualInputManager
    if VIM then

        local success = pcall(function()

            VIM:SendKeyEvent(
                true,
                key,
                false,
                game
            )

            task.wait(0.04)

            VIM:SendKeyEvent(
                false,
                key,
                false,
                game
            )

        end)

        if success then
            return true
        end
    end

    return false
end

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")

main.Name = "Keyboard"
main.Size = UDim2.new(0.97,0,0.48,0)
main.Position = UDim2.new(0.015,0,0.50,0)

main.BackgroundColor3 = Color3.fromRGB(22,22,25)
main.BorderSizePixel = 0

main.Parent = gui

Instance.new("UICorner",main).CornerRadius =
    UDim.new(0,10)

--==================================================
-- TITLE BAR
--==================================================

local title = Instance.new("TextLabel")

title.Size = UDim2.new(1,-85,0,30)
title.BackgroundTransparency = 1

title.Text = "  LIME KEYBOARD"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14

title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = main

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimize = Instance.new("TextButton")

minimize.Size = UDim2.fromOffset(38,30)
minimize.Position = UDim2.new(1,-78,0,0)

minimize.BackgroundTransparency = 1

minimize.Text = "−"
minimize.TextColor3 = Color3.new(1,1,1)
minimize.TextSize = 22

minimize.Font = Enum.Font.GothamBold

minimize.Parent = main

--==================================================
-- CLOSE BUTTON
--==================================================

local close = Instance.new("TextButton")

close.Size = UDim2.fromOffset(38,30)
close.Position = UDim2.new(1,-40,0,0)

close.BackgroundTransparency = 1

close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 22

close.Font = Enum.Font.GothamBold

close.Parent = main

--==================================================
-- MINIMIZE / RESTORE
--==================================================

local minimized = false

local normalSize = main.Size

minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    if minimized then

        -- Simpan ukuran normal
        normalSize = main.Size

        -- Sembunyikan semua isi keyboard
        for _,obj in ipairs(main:GetChildren()) do

            if obj ~= title
            and obj ~= minimize
            and obj ~= close then

                if obj:IsA("GuiObject") then
                    obj.Visible = false
                end

            end
        end

        -- Kecilkan frame
        main.Size = UDim2.fromOffset(180,30)

        minimize.Text = "+"

    else

        -- Kembalikan ukuran
        main.Size = normalSize

        -- Tampilkan keyboard lagi
        for _,obj in ipairs(main:GetChildren()) do

            if obj ~= title
            and obj ~= minimize
            and obj ~= close then

                if obj:IsA("GuiObject") then
                    obj.Visible = true
                end

            end
        end

        minimize.Text = "−"

    end
end)

--==================================================
-- CLOSE
--==================================================

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")

status.Size = UDim2.new(1,-50,0,20)
status.Position = UDim2.new(0,10,1,-22)

status.BackgroundTransparency = 1

status.Text = "Input: detecting..."
status.TextColor3 = Color3.fromRGB(170,170,170)
status.TextSize = 11

status.TextXAlignment = Enum.TextXAlignment.Left

status.Parent = main

--==================================================
-- KEY CREATOR
--==================================================

local function KC(name)

    local ok,result = pcall(function()
        return Enum.KeyCode[name]
    end)

    if ok then
        return result
    end

    return nil
end

local function makeKey(text,key,x,y,w)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(
        w or 0.055,
        0,
        0,
        34
    )

    b.Position = UDim2.new(
        x,
        0,
        0,
        y
    )

    b.BackgroundColor3 =
        Color3.fromRGB(48,48,53)

    b.BorderSizePixel = 0

    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)

    b.TextScaled = true
    b.Font = Enum.Font.GothamMedium

    b.Parent = main

    Instance.new("UICorner",b).CornerRadius =
        UDim.new(0,5)

    b.MouseButton1Down:Connect(function()

        b.BackgroundColor3 =
            Color3.fromRGB(70,110,190)

        local worked = sendKey(key)

        if worked then

            status.Text =
                "Input: OK  |  "..text

            status.TextColor3 =
                Color3.fromRGB(120,220,140)

        else

            status.Text =
                "Input API unavailable: "..text

            status.TextColor3 =
                Color3.fromRGB(255,120,120)

        end

    end)

    b.MouseButton1Up:Connect(function()

        b.BackgroundColor3 =
            Color3.fromRGB(48,48,53)

    end)

    return b
end

--==================================================
-- FUNCTION ROW
--==================================================

local x = 0.008
local y = 35

makeKey(
    "ESC",
    KC("Escape"),
    x,
    y,
    0.065
)

x += 0.072

for i = 1,12 do

    makeKey(
        "F"..i,
        KC("F"..i),
        x,
        y,
        0.052
    )

    x += 0.057

    if i == 4 or i == 8 then
        x += 0.012
    end

end

--==================================================
-- NUMBER ROW
--==================================================

x = 0.008
y = 75

local nums = {

    {"~","Backquote"},

    {"1","One"},
    {"2","Two"},
    {"3","Three"},
    {"4","Four"},
    {"5","Five"},
    {"6","Six"},
    {"7","Seven"},
    {"8","Eight"},
    {"9","Nine"},
    {"0","Zero"},

    {"-","Minus"},
    {"=","Equals"}
}

for _,v in ipairs(nums) do

    makeKey(
        v[1],
        KC(v[2]),
        x,
        y,
        0.052
    )

    x += 0.057

end

makeKey(
    "BACK",
    KC("Backspace"),
    x,
    y,
    0.09
)

--==================================================
-- QWERTY
--==================================================

local rows = {

    {
        {"TAB","Tab",0.075},

        {"Q","Q",.052},
        {"W","W",.052},
        {"E","E",.052},
        {"R","R",.052},
        {"T","T",.052},
        {"Y","Y",.052},
        {"U","U",.052},
        {"I","I",.052},
        {"O","O",.052},
        {"P","P",.052},

        {"[","LeftBracket",.052},
        {"]","RightBracket",.052}
    },

    {
        {"CAPS","CapsLock",.085},

        {"A","A",.052},
        {"S","S",.052},
        {"D","D",.052},
        {"F","F",.052},
        {"G","G",.052},
        {"H","H",.052},
        {"J","J",.052},
        {"K","K",.052},
        {"L","L",.052},

        {";","Semicolon",.052},
        {"'","Quote",.052},

        {"ENTER","Return",.085}
    },

    {
        {"SHIFT","LeftShift",.105},

        {"Z","Z",.052},
        {"X","X",.052},
        {"C","C",.052},
        {"V","V",.052},
        {"B","B",.052},
        {"N","N",.052},
        {"M","M",.052},

        {",","Comma",.052},
        {".","Period",.052},
        {"/","Slash",.052},

        {"SHIFT","RightShift",.105}
    }
}

for rowIndex,row in ipairs(rows) do

    local rx = 0.008

    local ry =
        115 + ((rowIndex-1)*40)

    for _,v in ipairs(row) do

        makeKey(
            v[1],
            KC(v[2]),
            rx,
            ry,
            v[3]
        )

        rx += v[3] + 0.005

    end
end

--==================================================
-- BOTTOM
--==================================================

local by = 235

makeKey(
    "CTRL",
    KC("LeftControl"),
    .008,
    by,
    .07
)

makeKey(
    "WIN",
    KC("LeftSuper"),
    .083,
    by,
    .07
)

makeKey(
    "ALT",
    KC("LeftAlt"),
    .158,
    by,
    .07
)

makeKey(
    "SPACE",
    KC("Space"),
    .233,
    by,
    .36
)

makeKey(
    "ALT",
    KC("RightAlt"),
    .598,
    by,
    .07
)

makeKey(
    "CTRL",
    KC("RightControl"),
    .673,
    by,
    .07
)

--==================================================
-- NAVIGATION
--==================================================

local nx = .76

makeKey(
    "INS",
    KC("Insert"),
    nx,
    75,
    .065
)

makeKey(
    "HOME",
    KC("Home"),
    nx+.07,
    75,
    .065
)

makeKey(
    "PGUP",
    KC("PageUp"),
    nx+.14,
    75,
    .065
)

makeKey(
    "DEL",
    KC("Delete"),
    nx,
    115,
    .065
)

makeKey(
    "END",
    KC("End"),
    nx+.07,
    115,
    .065
)

makeKey(
    "PGDN",
    KC("PageDown"),
    nx+.14,
    115,
    .065
)

--==================================================
-- ARROWS
--==================================================

makeKey(
    "↑",
    KC("Up"),
    nx+.07,
    155,
    .065
)

makeKey(
    "←",
    KC("Left"),
    nx,
    195,
    .065
)

makeKey(
    "↓",
    KC("Down"),
    nx+.07,
    195,
    .065
)

makeKey(
    "→",
    KC("Right"),
    nx+.14,
    195,
    .065
)

--==================================================
-- NUMPAD
--==================================================

local px = .76
local py = 235

makeKey(
    "NUM",
    KC("NumLock"),
    px,
    py,
    .055
)

makeKey(
    "/",
    KC("KeypadDivide"),
    px+.06,
    py,
    .055
)

makeKey(
    "*",
    KC("KeypadMultiply"),
    px+.12,
    py,
    .055
)

makeKey(
    "-",
    KC("KeypadSubtract"),
    px+.18,
    py,
    .055
)

makeKey(
    "7",
    KC("KeypadSeven"),
    px,
    py+38,
    .055
)

makeKey(
    "8",
    KC("KeypadEight"),
    px+.06,
    py+38,
    .055
)

makeKey(
    "9",
    KC("KeypadNine"),
    px+.12,
    py+38,
    .055
)

makeKey(
    "+",
    KC("KeypadAdd"),
    px+.18,
    py+38,
    .055
)

makeKey(
    "4",
    KC("KeypadFour"),
    px,
    py+76,
    .055
)

makeKey(
    "5",
    KC("KeypadFive"),
    px+.06,
    py+76,
    .055
)

makeKey(
    "6",
    KC("KeypadSix"),
    px+.12,
    py+76,
    .055
)

makeKey(
    "1",
    KC("KeypadOne"),
    px,
    py+114,
    .055
)

makeKey(
    "2",
    KC("KeypadTwo"),
    px+.06,
    py+114,
    .055
)

makeKey(
    "3",
    KC("KeypadThree"),
    px+.12,
    py+114,
    .055
)

makeKey(
    "0",
    KC("KeypadZero"),
    px,
    py+152,
    .115
)

makeKey(
    ".",
    KC("KeypadPeriod"),
    px+.12,
    py+152,
    .055
)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPosition = main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position - dragStart

        main.Position = UDim2.new(

            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = false

    end

end)

--==================================================
-- DETECT INPUT METHOD
--==================================================

if type(keypress) == "function" then

    status.Text =
        "Input: keypress API detected"

elseif VIM then

    status.Text =
        "Input: VirtualInputManager detected"

else

    status.Text =
        "Input: no injection API detected"

end

print("LIME KEYBOARD LOADED")
