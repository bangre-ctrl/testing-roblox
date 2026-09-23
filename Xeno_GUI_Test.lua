local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")

gui.Name = "FullKeyboard"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999

-- PlayerGui pasti tersedia di Roblox
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0.96, 0, 0.48, 0)
main.Position = UDim2.new(0.02, 0, 0.50, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,28)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-45,0,30)
title.BackgroundTransparency = 1
title.Text = "FULL KEYBOARD"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 15
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35,30)
close.Position = UDim2.new(1,-38,0,0)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 24
close.Parent = main

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local function key(text,x,y,w)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(
        w or 0.055,
        0,
        0.13,
        0
    )

    b.Position = UDim2.new(x,y,0,0)

    b.BackgroundColor3 = Color3.fromRGB(55,55,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextScaled = true
    b.BorderSizePixel = 0

    b.Parent = main

    Instance.new("UICorner",b).CornerRadius =
        UDim.new(0,5)

    return b
end

-- F keys
local x = 0.01

key("ESC",x,0.10,0.065)
x += 0.072

for i=1,12 do

    key(
        "F"..i,
        x,
        0.10,
        0.055
    )

    x += 0.060
end

-- Number row
x = 0.01

local nums = {
    "~","1","2","3","4","5","6","7",
    "8","9","0","-","=","BACK"
}

for i,v in ipairs(nums) do

    local w = v == "BACK" and 0.085 or 0.055

    key(
        v,
        x,
        0.27,
        w
    )

    x += w + 0.006
end

-- QWERTY
local rows = {
    {"TAB","Q","W","E","R","T","Y","U","I","O","P","[","]","\\"},
    {"CAPS","A","S","D","F","G","H","J","K","L",";","'","ENTER"},
    {"SHIFT","Z","X","C","V","B","N","M",",",".","/","SHIFT"},
}

local ypos = {
    0.43,
    0.59,
    0.75
}

for r,row in ipairs(rows) do

    local pos = 0.01

    for _,v in ipairs(row) do

        local w = 0.055

        if v == "TAB" then
            w = 0.075
        elseif v == "CAPS" then
            w = 0.085
        elseif v == "ENTER" then
            w = 0.085
        elseif v == "SHIFT" then
            w = 0.105
        end

        key(
            v,
            pos,
            ypos[r],
            w
        )

        pos += w + 0.006
    end
end

-- Bottom
key("CTRL",0.01,0.91,0.07)
key("WIN",0.087,0.91,0.07)
key("ALT",0.164,0.91,0.07)
key("SPACE",0.241,0.91,0.38)
key("ALT",0.628,0.91,0.07)
key("CTRL",0.705,0.91,0.07)

print("FULL KEYBOARD GUI LOADED")
