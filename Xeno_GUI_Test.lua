--// FULL ON-SCREEN KEYBOARD
--// Roblox / Executor
--// Includes: F1-F12, arrows, Insert/Home/End/Page, Numpad, modifiers, etc.

local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local parent = (gethui and gethui()) or game:GetService("CoreGui")

local old = parent:FindFirstChild("FullKeyboard")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FullKeyboard"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = parent

-- Main window
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(1050, 410)
main.Position = UDim2.new(0.5, -525, 1, -430)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

--==================================================
-- TITLE BAR
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 35)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "  FULL KEYBOARD"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(40, 30)
close.Position = UDim2.new(1, -45, 0, 3)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 25
close.Parent = main

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--==================================================
-- KEY FUNCTION
--==================================================

local held = {}

local function pressKey(key)
    if not key then return end

    task.spawn(function()
        pcall(function()
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.035)
            VIM:SendKeyEvent(false, key, false, game)
        end)
    end)
end

local function createKey(text, key, x, y, w, h)
    local b = Instance.new("TextButton")

    b.Size = UDim2.fromOffset(w or 48, h or 38)
    b.Position = UDim2.fromOffset(x, y)

    b.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    b.BorderSizePixel = 0

    b.Text = text
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.TextSize = 13
    b.Font = Enum.Font.GothamMedium

    b.AutoButtonColor = true
    b.Parent = main

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Down:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(75, 115, 190)
        pressKey(key)
    end)

    b.MouseButton1Up:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    end)

    return b
end

--==================================================
-- FUNCTION KEY ROW
--==================================================

local function KC(name)
    return Enum.KeyCode[name]
end

local y = 42
local x = 10

createKey("ESC", KC("Escape"), x, y, 55)
x += 61

for i = 1, 12 do
    createKey(
        "F"..i,
        KC("F"..i),
        x,
        y,
        55
    )
    x += 61

    if i == 4 or i == 8 then
        x += 12
    end
end

--==================================================
-- NUMBER ROW
--==================================================

y = 88
x = 10

local numberKeys = {
    {"~", "Backquote"},
    {"1", "One"},
    {"2", "Two"},
    {"3", "Three"},
    {"4", "Four"},
    {"5", "Five"},
    {"6", "Six"},
    {"7", "Seven"},
    {"8", "Eight"},
    {"9", "Nine"},
    {"0", "Zero"},
    {"-", "Minus"},
    {"=", "Equals"},
}

for _, v in ipairs(numberKeys) do
    createKey(v[1], KC(v[2]), x, y, 55)
    x += 61
end

createKey("BACKSPACE", KC("Backspace"), x, y, 105)

--==================================================
-- QWERTY ROW
--==================================================

y = 134
x = 10

createKey("TAB", KC("Tab"), x, y, 70)
x += 76

local qrow = {
    {"Q","Q"}, {"W","W"}, {"E","E"}, {"R","R"},
    {"T","T"}, {"Y","Y"}, {"U","U"}, {"I","I"},
    {"O","O"}, {"P","P"},
    {"[","LeftBracket"},
    {"]","RightBracket"},
    {"\\","BackSlash"},
}

for _, v in ipairs(qrow) do
    createKey(v[1], KC(v[2]), x, y, 55)
    x += 61
end

--==================================================
-- ASDF ROW
--==================================================

y = 180
x = 10

createKey("CAPS", KC("CapsLock"), x, y, 82)
x += 88

local arow = {
    {"A","A"}, {"S","S"}, {"D","D"}, {"F","F"},
    {"G","G"}, {"H","H"}, {"J","J"}, {"K","K"},
    {"L","L"},
    {";","Semicolon"},
    {"'","Quote"},
}

for _, v in ipairs(arow) do
    createKey(v[1], KC(v[2]), x, y, 55)
    x += 61
end

createKey("ENTER", KC("Return"), x, y, 110)

--==================================================
-- ZXCV ROW
--==================================================

y = 226
x = 10

createKey("SHIFT", KC("LeftShift"), x, y, 105)
x += 111

local zrow = {
    {"Z","Z"}, {"X","X"}, {"C","C"}, {"V","V"},
    {"B","B"}, {"N","N"}, {"M","M"},
    {",","Comma"},
    {".","Period"},
    {"/","Slash"},
}

for _, v in ipairs(zrow) do
    createKey(v[1], KC(v[2]), x, y, 55)
    x += 61
end

createKey("SHIFT", KC("RightShift"), x, y, 105)

--==================================================
-- BOTTOM ROW
--==================================================

y = 272
x = 10

createKey("CTRL", KC("LeftControl"), x, y, 70)
x += 76

createKey("WIN", KC("LeftSuper"), x, y, 70)
x += 76

createKey("ALT", KC("LeftAlt"), x, y, 70)
x += 76

createKey("SPACE", KC("Space"), x, y, 390)
x += 396

createKey("ALT", KC("RightAlt"), x, y, 70)
x += 76

createKey("FN", nil, x, y, 70)
x += 76

createKey("MENU", KC("Menu"), x, y, 70)
x += 76

createKey("CTRL", KC("RightControl"), x, y, 70)

--==================================================
-- NAVIGATION CLUSTER
--==================================================

local nx = 770
local ny = 88

createKey("INS", KC("Insert"), nx, ny, 65)
createKey("HOME", KC("Home"), nx+70, ny, 65)
createKey("PGUP", KC("PageUp"), nx+140, ny, 65)

createKey("DEL", KC("Delete"), nx, ny+45, 65)
createKey("END", KC("End"), nx+70, ny+45, 65)
createKey("PGDN", KC("PageDown"), nx+140, ny+45, 65)

--==================================================
-- ARROWS
--==================================================

createKey("↑", KC("Up"), 840, 180, 65)
createKey("←", KC("Left"), 770, 225, 65)
createKey("↓", KC("Down"), 840, 225, 65)
createKey("→", KC("Right"), 910, 225, 65)

--==================================================
-- NUMPAD
--==================================================

local px = 770
local py = 280

createKey("NUM", KC("NumLock"), px, py, 55)
createKey("/", KC("KeypadDivide"), px+60, py, 55)
createKey("*", KC("KeypadMultiply"), px+120, py, 55)
createKey("-", KC("KeypadSubtract"), px+180, py, 55)

createKey("7", KC("KeypadSeven"), px, py+45, 55)
createKey("8", KC("KeypadEight"), px+60, py+45, 55)
createKey("9", KC("KeypadNine"), px+120, py+45, 55)
createKey("+", KC("KeypadAdd"), px+180, py+45, 55)

createKey("4", KC("KeypadFour"), px, py+90, 55)
createKey("5", KC("KeypadFive"), px+60, py+90, 55)
createKey("6", KC("KeypadSix"), px+120, py+90, 55)

createKey("1", KC("KeypadOne"), px, py+135, 55)
createKey("2", KC("KeypadTwo"), px+60, py+135, 55)
createKey("3", KC("KeypadThree"), px+120, py+135, 55)
createKey("ENTER", KC("KeypadEnter"), px+180, py+90, 55, 100)

createKey("0", KC("KeypadZero"), px, py+180, 115)
createKey(".", KC("KeypadPeriod"), px+120, py+180, 55)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)
