-- Single_AntiAFK.lua | Diagnostic build
-- Purpose: test whether a minimal GUI runs in Delta without nil-call errors.
-- This build intentionally has no Anti-AFK or graphics modifications yet.
-- If this GUI works cleanly, features can be added back one at a time.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove an earlier copy of this diagnostic GUI, if present.
local old = playerGui:FindFirstChild("SingleAntiAFK")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0, 230, 0, 104)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 28)
title.Position = UDim2.new(0, 8, 0, 3)
title.BackgroundTransparency = 1
title.Text = "SINGLE ANTI-AFK | DEBUG"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.TextSize = 14
close.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 24)
status.Position = UDim2.new(0, 8, 0, 35)
status.BackgroundTransparency = 1
status.Text = "GUI loaded successfully"
status.TextColor3 = Color3.fromRGB(120, 230, 140)
status.TextSize = 13
status.Parent = frame

local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(1, -16, 0, 28)
testButton.Position = UDim2.new(0, 8, 0, 65)
testButton.Text = "Test Button"
testButton.TextSize = 13
testButton.Parent = frame

testButton.Activated:Connect(function()
    status.Text = "Button event works"
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Drag panel by title bar.
local dragging = false
local dragStart
local frameStart

title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
