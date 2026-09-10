--// REBIRTH TEST
--// LocalScript - untuk testing game milik sendiri

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- NETWORK
--==================================================

local Network = workspace:WaitForChild("Network", 9e9)

local GetRebirthState = Network:WaitForChild(
    "GetRebirthState-RemoteFunction",
    9e9
)

local TutorialUiAction = Network:WaitForChild(
    "TutorialUiAction-RemoteEvent",
    9e9
)

local AttemptRebirth = Network:WaitForChild(
    "AttemptRebirth-RemoteFunction",
    9e9
)

local ContinueBossResult = Network:WaitForChild(
    "ContinueBossResult-RemoteEvent",
    9e9
)

--==================================================
-- GUI
--==================================================

local oldGui = playerGui:FindFirstChild("RebirthTest")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RebirthTest"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 260, 0, 150)
Main.Position = UDim2.new(0.5, -130, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

--==================================================
-- TITLE BAR
--==================================================

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Rebirth Test"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

--==================================================
-- MINIMIZE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Position = UDim2.new(1, -65, 0, 2)
Minimize.BackgroundTransparency = 1
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = TitleBar

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -32, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 90, 90)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.Parent = TitleBar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main

local RebirthButton = Instance.new("TextButton")
RebirthButton.Size = UDim2.new(0, 220, 0, 50)
RebirthButton.Position = UDim2.new(0.5, -110, 0, 25)
RebirthButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
RebirthButton.BorderSizePixel = 0
RebirthButton.Text = "Rebirth : OFF"
RebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthButton.TextSize = 17
RebirthButton.Font = Enum.Font.GothamBold
RebirthButton.Parent = Content

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 7)
ButtonCorner.Parent = RebirthButton

--==================================================
-- STATE
--==================================================

local RebirthEnabled = false
local Minimized = false
local Closed = false

--==================================================
-- REBIRTH FUNCTION
--==================================================

local function DoRebirth()
    if Closed or not RebirthEnabled then
        return
    end

    -- GetRebirthState
    pcall(function()
        local args = {}

        GetRebirthState:InvokeServer(unpack(args))
    end)

    task.wait(0.2)

    if Closed or not RebirthEnabled then
        return
    end

    -- tekan YES rebirth
    pcall(function()
        local args = {
            [1] = {
                ["actionId"] = "contextual_rebirth_opened";
            };
        }

        TutorialUiAction:FireServer(unpack(args))
    end)

    task.wait(0.2)

    if Closed or not RebirthEnabled then
        return
    end

    -- Attempt Rebirth
    pcall(function()
        local args = {}

        AttemptRebirth:InvokeServer(unpack(args))
    end)
end

--==================================================
-- RETURN TO PREVIOUS WAVE
--==================================================

local function ReturnPreviousWave()
    if Closed or not RebirthEnabled then
        return
    end

    pcall(function()
        local args = {
            [1] = 7;
        }

        ContinueBossResult:FireServer(unpack(args))
    end)
end

--==================================================
-- AUTO LOOP
--==================================================

task.spawn(function()

    while not Closed do

        if RebirthEnabled then

            -- Tunggu sampai defeat.
            -- Script mencari beberapa indikator defeat
            -- dari GUI/player state.

            local defeated = false

            while RebirthEnabled and not Closed and not defeated do

                task.wait(0.5)

                -- Cek GUI defeat secara umum
                local defeatGui =
                    playerGui:FindFirstChild("Defeat", true)
                    or playerGui:FindFirstChild("Defeated", true)
                    or playerGui:FindFirstChild("VictoryDefeat", true)

                if defeatGui and defeatGui:IsDescendantOf(playerGui) then
                    defeated = true
                end

                -- Cek karakter mati
                local character = player.Character

                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    if humanoid and humanoid.Health <= 0 then
                        defeated = true
                    end
                end
            end

            if defeated and RebirthEnabled and not Closed then

                task.wait(0.5)

                -- Return to previous wave
                ReturnPreviousWave()

                task.wait(1)

                -- Auto rebirth
                DoRebirth()

                task.wait(1)
            end

        else
            task.wait(0.2)
        end
    end
end)

--==================================================
-- ON / OFF
--==================================================

RebirthButton.MouseButton1Click:Connect(function()

    RebirthEnabled = not RebirthEnabled

    if RebirthEnabled then
        RebirthButton.Text = "Rebirth : ON"
        RebirthButton.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
    else
        RebirthButton.Text = "Rebirth : OFF"
        RebirthButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    end

end)

--==================================================
-- MINIMIZE
--==================================================

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    if Minimized then
        Content.Visible = false
        Main.Size = UDim2.new(0, 260, 0, 35)
        Minimize.Text = "+"
    else
        Content.Visible = true
        Main.Size = UDim2.new(0, 260, 0, 150)
        Minimize.Text = "—"
    end

end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()

    Closed = true
    RebirthEnabled = false

    ScreenGui:Destroy()

end)

--==================================================
-- DRAG WINDOW
--==================================================

local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPosition

TitleBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end

end)
