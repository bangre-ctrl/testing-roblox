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
    setEnabled(not antiAfkOn)
end)

closeButton.Activated:Connect(function()
    closed = true
    antiAfkOn = false
    gui:Destroy()
end)

-- Drag the GUI by its title.
local dragging = false
local dragStart
local startPosition

title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
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
        dragging = false
    end
end)
