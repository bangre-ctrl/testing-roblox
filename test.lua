--// REBIRTH TESTER

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local enabled = false

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RebirthTester"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240, 130)
frame.Position = UDim2.new(0, 30, 0.5, -65)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

--// Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "REBIRTH TEST"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

--// Toggle
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -30, 0, 45)
button.Position = UDim2.fromOffset(15, 55)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
button.Text = "Auto Rebirth : OFF"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = button

--// Rebirth function
local function testRebirth()
    local network = workspace:FindFirstChild("Network")

    if not network then
        warn("[Rebirth Test] Network tidak ditemukan")
        return
    end

    local remote = network:FindFirstChild("AttemptRebirth-RemoteFunction")

    if not remote then
        warn("[Rebirth Test] AttemptRebirth-RemoteFunction tidak ditemukan")
        return
    end

    local success, result = pcall(function()
        return remote:InvokeServer()
    end)

    if success then
        print("[Rebirth Test] AttemptRebirth berhasil dipanggil")
        print("[Rebirth Test] Result:", result)
    else
        warn("[Rebirth Test] Gagal:", result)
    end
end

--// Toggle
button.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        button.Text = "Auto Rebirth : ON"
        button.BackgroundColor3 = Color3.fromRGB(40, 150, 70)

        print("[Rebirth Test] ENABLED")

        -- Test satu kali
        testRebirth()

    else
        button.Text = "Auto Rebirth : OFF"
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)

        print("[Rebirth Test] DISABLED")
    end
end)
