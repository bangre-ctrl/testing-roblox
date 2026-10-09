    if not running or stopped then return end
    triggers += 1
    counter.Text = "Idle triggers: " .. tostring(triggers)
    local ok, err = pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    if not ok then
        counter.Text = "VirtualUser error"
        warn("[SingleAntiAFK] VirtualUser failed: " .. tostring(err))
    end
end)

toggle.Activated:Connect(function() setEnabled(not running) end)
close.Activated:Connect(function()
    stopped = true
    running = false
    gui:Destroy()
end)

local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, frameStart = false, nil, nil
title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
