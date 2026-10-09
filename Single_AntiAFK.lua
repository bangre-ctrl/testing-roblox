--[[
    SINGLE ANTI-AFK
    Toggle ON/OFF. Attempts to jump every 5 seconds.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.fromOffset(8, 4)
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
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 7)

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

    if not enabled then return end

    task.spawn(function()
        while antiAfkOn and not closed do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if humanoid and root and humanoid.Health > 0 then
                local state = humanoid:GetState()
                local onGround = humanoid.FloorMaterial ~= Enum.Material.Air
                local canJump = state ~= Enum.HumanoidStateType.Seated
                    and state ~= Enum.HumanoidStateType.Dead

                if onGround and canJump then
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end

            -- Check frequently so OFF/close stops promptly.
            for _ = 1, 50 do
                if not antiAfkOn or closed then break end
                task.wait(0.1)
            end
        end
    end)
end

toggleButton.Activated:Connect(function()
