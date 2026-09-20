local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("XenoGUITest")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "XenoGUITest"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320,190)
main.Position = UDim2.new(.5,-160,.5,-95)
main.BackgroundColor3 = Color3.fromRGB(30,30,35)
main.Active = true
main.Parent = gui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,42)
titleBar.BackgroundColor3 = Color3.fromRGB(50,50,60)
titleBar.Active = true
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.fromOffset(10,0)
title.BackgroundTransparency = 1
title.Text = "Xeno GUI Test"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local min = Instance.new("TextButton")
min.Size = UDim2.fromOffset(34,32)
min.Position = UDim2.new(1,-76,0,5)
min.Text = "□"
min.TextSize = 18
min.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34,32)
close.Position = UDim2.new(1,-38,0,5)
close.Text = "X"
close.TextSize = 16
close.Parent = titleBar

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-55)
content.Position = UDim2.fromOffset(10,50)
content.BackgroundTransparency = 1
content.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,40)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.new(1,1,1)
status.TextSize = 16
status.Parent = content

local test = Instance.new("TextButton")
test.Size = UDim2.new(1,0,0,45)
test.Position = UDim2.fromOffset(0,50)
test.Text = "TEST CLICK"
test.TextSize = 16
test.Parent = content

test.MouseButton1Click:Connect(function()
    status.Text = "Status: CLICK WORKS"
end)

local normalSize = main.Size
local minimized = false

min.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        content.Visible = false
        main.Size = UDim2.fromOffset(180,44)
        titleBar.Size = UDim2.new(1,0,1,0)
        title.Text = "🧪 Test"
        title.TextSize = 15
        min.Position = UDim2.new(1,-72,0,6)
        close.Position = UDim2.new(1,-38,0,6)
    else
        content.Visible = true
        main.Size = normalSize
        titleBar.Size = UDim2.new(1,0,0,42)
        title.Text = "Xeno GUI Test"
        title.TextSize = 18
        min.Position = UDim2.new(1,-76,0,5)
        close.Position = UDim2.new(1,-38,0,5)
    end
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local dragging, dragStart, startPos, dragInput = false,nil,nil,nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        dragInput = input
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                  startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("[XenoGUITest] Loaded")
