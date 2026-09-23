--// FULL RESPONSIVE ON-SCREEN KEYBOARD
--// Roblox

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- PARENT
--==================================================

local parent

pcall(function()
    if gethui then
        parent = gethui()
    end
end)

if not parent then
    parent = player:WaitForChild("PlayerGui")
end

-- Remove old
pcall(function()
    local old = parent:FindFirstChild("FullKeyboard")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "FullKeyboard"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = parent

-- Scale according to screen
local screen = workspace.CurrentCamera.ViewportSize

local scale = math.clamp(
    math.min(screen.X / 900, screen.Y / 500),
    0.55,
    1
)

local mainW = 880 * scale
local mainH = 350 * scale

local main = Instance.new("Frame")
main.Name = "Keyboard"
main.Size = UDim2.fromOffset(mainW, mainH)
main.Position = UDim2.new(
    0.5,
    -mainW / 2,
    1,
    -mainH - 15
)
main.BackgroundColor3 = Color3.fromRGB(25,25,28)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-45,0,28 * scale)
title.Position = UDim2.fromOffset(8,0)
title.BackgroundTransparency = 1
title.Text = "FULL KEYBOARD"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 14 * scale
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35 * scale,28 * scale)
close.Position = UDim2.new(1,-38 * scale,0,0)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 22 * scale
close.Parent = main

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--==================================================
-- KEY
--==================================================

local function keyCode(name)
    local ok, result = pcall(function()
        return Enum.KeyCode[name]
    end)

    if ok then
        return result
    end

    return nil
end

local function press(key)
    if not key then
        return
    end

    -- Try executor input
    pcall(function()
        if keypress and keyrelease then
            keypress(key.Value)
            task.wait(0.04)
            keyrelease(key.Value)
            return
        end
    end)

    -- Try VirtualInputManager
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")

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
end

local function makeKey(text, key, x, y, w, h)

    local b = Instance.new("TextButton")

    b.Size = UDim2.fromOffset(
        w * scale,
        (h or 34) * scale
    )

    b.Position = UDim2.fromOffset(
        x * scale,
        y * scale
    )

    b.BackgroundColor3 = Color3.fromRGB(50,50,55)
    b.BorderSizePixel = 0

    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12 * scale
    b.Font = Enum.Font.GothamMedium

    b.Parent = main

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0,5)

    b.MouseButton1Down:Connect(function()

        b.BackgroundColor3 =
            Color3.fromRGB(80,120,200)

        press(key)
    end)

    b.MouseButton1Up:Connect(function()

        b.BackgroundColor3 =
            Color3.fromRGB(50,50,55)
    end)

    return b
end

--==================================================
-- FUNCTION KEYS
--==================================================

local x = 8

makeKey("ESC",keyCode("Escape"),x,32,48)
x += 53

for i = 1,12 do

    makeKey(
        "F"..i,
        keyCode("F"..i),
        x,
        32,
        48
    )

    x += 52

    if i == 4 or i == 8 then
        x += 8
    end
end

--==================================================
-- NUMBER ROW
--==================================================

local numbers = {
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

x = 8

for _,v in ipairs(numbers) do

    makeKey(
        v[1],
        keyCode(v[2]),
        x,
        72,
        48
    )

    x += 52
end

makeKey(
    "BACK",
    keyCode("Backspace"),
    x,
    72,
    82
)

--==================================================
-- Q ROW
--==================================================

x = 8

makeKey("TAB",keyCode("Tab"),x,112,62)
x += 67

local q = {
    {"Q","Q"},{"W","W"},{"E","E"},{"R","R"},
    {"T","T"},{"Y","Y"},{"U","U"},{"I","I"},
    {"O","O"},{"P","P"},
    {"[","LeftBracket"},
    {"]","RightBracket"},
    {"\\","BackSlash"}
}

for _,v in ipairs(q) do

    makeKey(
        v[1],
        keyCode(v[2]),
        x,
        112,
        48
    )

    x += 52
end

--==================================================
-- A ROW
--==================================================

x = 8

makeKey("CAPS",keyCode("CapsLock"),x,152,75)
x += 80

local a = {
    {"A","A"},{"S","S"},{"D","D"},{"F","F"},
    {"G","G"},{"H","H"},{"J","J"},{"K","K"},
    {"L","L"},{";","Semicolon"},{"'","Quote"}
}

for _,v in ipairs(a) do

    makeKey(
        v[1],
        keyCode(v[2]),
        x,
        152,
        48
    )

    x += 52
end

makeKey(
    "ENTER",
    keyCode("Return"),
    x,
    152,
    80
)

--==================================================
-- Z ROW
--==================================================

x = 8

makeKey("SHIFT",keyCode("LeftShift"),x,192,95)
x += 100

local z = {
    {"Z","Z"},{"X","X"},{"C","C"},{"V","V"},
    {"B","B"},{"N","N"},{"M","M"},
    {",","Comma"},{".","Period"},{"/","Slash"}
}

for _,v in ipairs(z) do

    makeKey(
        v[1],
        keyCode(v[2]),
        x,
        192,
        48
    )

    x += 52
end

makeKey(
    "SHIFT",
    keyCode("RightShift"),
    x,
    192,
    95
)

--==================================================
-- BOTTOM
--==================================================

x = 8

makeKey("CTRL",keyCode("LeftControl"),x,232,65)
x += 70

makeKey("WIN",keyCode("LeftSuper"),x,232,65)
x += 70

makeKey("ALT",keyCode("LeftAlt"),x,232,65)
x += 70

makeKey("SPACE",keyCode("Space"),x,232,300)
x += 305

makeKey("ALT",keyCode("RightAlt"),x,232,65)
x += 70

makeKey("CTRL",keyCode("RightControl"),x,232,65)

--==================================================
-- NAVIGATION
--==================================================

local nx = 650

makeKey("INS",keyCode("Insert"),nx,112,65)
makeKey("HOME",keyCode("Home"),nx+70,112,65)
makeKey("PGUP",keyCode("PageUp"),nx+140,112,65)

makeKey("DEL",keyCode("Delete"),nx,152,65)
makeKey("END",keyCode("End"),nx+70,152,65)
makeKey("PGDN",keyCode("PageDown"),nx+140,152,65)

-- arrows

makeKey("↑",keyCode("Up"),nx+70,192,65)
makeKey("←",keyCode("Left"),nx,232,65)
makeKey("↓",keyCode("Down"),nx+70,232,65)
makeKey("→",keyCode("Right"),nx+140,232,65)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPos = main.Position
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
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
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

print("FULL KEYBOARD LOADED")
