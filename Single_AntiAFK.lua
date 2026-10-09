--[[
    SINGLE ANTI-AFK
    Makes the character jump every 5 seconds while enabled.
    Toggle ON/OFF with the GUI button.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local antiAfkOn = false
local closed = false

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(220, 105)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.fromOffset(6, 4)
title.BackgroundTransparency = 1
title.Text = "SINGLE ANTI-AFK"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 32)
toggleButton.Position = UDim2.fromOffset(10, 36)
toggleButton.BackgroundColor3 = Color3.fromRGB(55, 125, 80)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Anti-AFK: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 13
toggleButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 7)
buttonCorner.Parent = toggleButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(22, 22)
closeButton.Position = UDim2.new(1, -26, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = frame

local function setEnabled(enabled)
    antiAfkOn = enabled
    toggleButton.Text = enabled and "Anti-AFK: ON" or "Anti-AFK: OFF"
    toggleButton.BackgroundColor3 = enabled
        and Color3.fromRGB(170, 100, 45)
        or Color3.fromRGB(55, 125, 80)

    if enabled then
        task.spawn(function()
            while antiAfkOn and not closed do
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if humanoid and humanoid.Health > 0 then
                    pcall(function()
                        humanoid.Jump = true
                    end)
                end

                -- Wait 5 seconds, but allow OFF/close to stop quickly.
                for _ = 1, 50 do
                    if not antiAfkOn or closed then
                        break
                    end
                    task.wait(0.1)
                end
            end
        end)
    end
end

toggleButton.Activated:Connect(function()
    setEnabled(not antiAfkOn)
end)

closeButton.Activated:Connect(function()
    closed = true
    antiAfkOn = false
    gui:Destroy()
end)

-- Drag the small GUI using its title area.
title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local startInput = input.Position
        local startPosition = frame.Position
        local inputChangedConnection
        inputChangedConnection = game:GetService("UserInputService").InputChanged:Connect(function(changedInput)
            if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                local delta = changedInput.Position - startInput
                frame.Position = UDim2.new(
                    startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
                )
            end
        end)

        local endedConnection
        endedConnection = game:GetService("UserInputService").InputEnded:Connect(function(endedInput)
            if endedInput == input then
                if inputChangedConnection then inputChangedConnection:Disconnect() end
                if endedConnection then endedConnection:Disconnect() end
            end
        end)
    end
end)
