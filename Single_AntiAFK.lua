-- SINGLE ANTI-AFK (Delta-friendly simple GUI)
-- Toggle ON/OFF. Attempts to jump every 5 seconds.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = false
local stopped = false

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 78)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 24)
title.Position = UDim2.new(0, 6, 0, 2)
title.BackgroundTransparency = 1
title.Text = "ANTI-AFK | JUMP 5S"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -25, 0, 0)
close.Text = "X"
close.TextSize = 14
close.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -12, 0, 34)
toggle.Position = UDim2.new(0, 6, 0, 34)
toggle.BackgroundColor3 = Color3.fromRGB(50, 130, 70)
toggle.Text = "Anti-AFK: OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 14
toggle.Parent = frame

local function setEnabled(value)
    enabled = value
    toggle.Text = value and "Anti-AFK: ON" or "Anti-AFK: OFF"
    toggle.BackgroundColor3 = value
        and Color3.fromRGB(170, 95, 40)
        or Color3.fromRGB(50, 130, 70)

    if not value then
        return
    end

    task.spawn(function()
        while enabled and not stopped do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0
                and humanoid.FloorMaterial ~= Enum.Material.Air then
                pcall(function()
                    humanoid.Jump = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end

            for _ = 1, 50 do
                if not enabled or stopped then
                    break
                end
                task.wait(0.1)
            end
        end
    end)
end

toggle.Activated:Connect(function()
    setEnabled(not enabled)
end)

close.Activated:Connect(function()
    stopped = true
    enabled = false
    gui:Destroy()
end)

-- Drag GUI by holding the title.
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
