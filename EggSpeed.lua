-- EggSpeed.lua
-- Local speed GUI with draggable speed slider and ON/OFF toggle.
-- Intended for testing in your own Roblox experience / a LocalScript environment.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then
    warn("EggSpeed: LocalPlayer was not found.")
    return
end

local oldGui = CoreGui:FindFirstChild("EggSpeedGUI")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "EggSpeedGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(250, 170)
frame.Position = UDim2.new(0.5, -125, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 36)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ EggSpeed"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -34, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(190, 65, 75)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -24, 0, 24)
valueLabel.Position = UDim2.fromOffset(12, 42)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "Speed: 50"
valueLabel.TextColor3 = Color3.fromRGB(225, 230, 245)
valueLabel.TextSize = 14
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.Parent = frame

local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, -24, 0, 12)
slider.Position = UDim2.fromOffset(12, 72)
slider.BackgroundColor3 = Color3.fromRGB(65, 69, 85)
slider.BorderSizePixel = 0
slider.Parent = frame
Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new((50 - 16) / (200 - 16), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 195, 145)
fill.BorderSizePixel = 0
fill.Parent = slider
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame")
knob.Size = UDim2.fromOffset(16, 16)
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Position = UDim2.new((50 - 16) / (200 - 16), 0, 0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
knob.Parent = slider
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -24, 0, 36)
toggle.Position = UDim2.fromOffset(12, 112)
toggle.BackgroundColor3 = Color3.fromRGB(0, 155, 115)
toggle.Text = "SPEED: OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 14
toggle.Font = Enum.Font.GothamBold
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local MIN_SPEED, MAX_SPEED = 16, 200
local speed = 50
local enabled = false
local draggingSlider = false
local originalSpeed = 16

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
    local humanoid = getHumanoid()
    if not humanoid then return end
    if enabled then
        humanoid.WalkSpeed = speed
    else
        humanoid.WalkSpeed = originalSpeed
    end
end

local function updateSlider(screenX)
    local width = slider.AbsoluteSize.X
    if width <= 0 then return end
    local percent = math.clamp((screenX - slider.AbsolutePosition.X) / width, 0, 1)
    speed = math.floor(MIN_SPEED + percent * (MAX_SPEED - MIN_SPEED) + 0.5)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    knob.Position = UDim2.new(percent, 0, 0.5, 0)
    valueLabel.Text = "Speed: " .. speed
    if enabled then applySpeed() end
end

slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSlider(input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        local humanoid = getHumanoid()
        if humanoid then originalSpeed = humanoid.WalkSpeed end
        toggle.Text = "SPEED: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(200, 65, 75)
    else
        toggle.Text = "SPEED: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(0, 155, 115)
    end
    applySpeed()
end)

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        originalSpeed = 16
        task.wait(0.2)
        applySpeed()
    end
end)

-- Make the window draggable by dragging its title area.
local draggingWindow = false
local dragStart, startPosition
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)

close.MouseButton1Click:Connect(function()
    local humanoid = getHumanoid()
    if humanoid and enabled then humanoid.WalkSpeed = originalSpeed end
    gui:Destroy()
end)
