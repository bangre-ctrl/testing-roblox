--//====================================================
--// REBIRTH TEST
--// Boss Win  -> Next Wave (27)
--// Boss Time -> Previous Wave (7) -> Rebirth
--//====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--====================================================
-- CLEAN OLD GUI
--====================================================

local OldGui = PlayerGui:FindFirstChild("RebirthTest")

if OldGui then
    OldGui:Destroy()
end

--====================================================
-- NETWORK
--====================================================

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

--====================================================
-- VARIABLES
--====================================================

local Enabled = false
local Closed = false
local Minimized = false

--====================================================
-- GUI
--====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RebirthTest"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--====================================================
-- MAIN
--====================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 165)
Main.Position = UDim2.new(0.5, -140, 0.5, -82)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

--====================================================
-- TITLE BAR
--====================================================

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Rebirth Test"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

--====================================================
-- MINIMIZE
--====================================================

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Position = UDim2.new(1, -65, 0, 2)
Minimize.BackgroundTransparency = 1
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = TitleBar

--====================================================
-- CLOSE
--====================================================

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -32, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.Parent = TitleBar

--====================================================
-- CONTENT
--====================================================

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main

--====================================================
-- REBIRTH BUTTON
--====================================================

local RebirthButton = Instance.new("TextButton")
RebirthButton.Name = "RebirthButton"
RebirthButton.Size = UDim2.new(0, 230, 0, 48)
RebirthButton.Position = UDim2.new(0.5, -115, 0, 18)
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

--====================================================
-- STATUS
--====================================================

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 76)
Status.BackgroundTransparency = 1
Status.Text = "Status : OFF"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.Parent = Content

--====================================================
-- STATUS FUNCTION
--====================================================

local function SetStatus(Text)

    if not Closed and Status then
        Status.Text = "Status : " .. Text
    end

end

--====================================================
-- GET COUNTDOWN
--====================================================

local function GetBossTimer()

    local TimerValue = nil

    for _, Object in ipairs(PlayerGui:GetDescendants()) do

        if Object:IsA("TextLabel")
        or Object:IsA("TextButton") then

            local Text = Object.Text

            if typeof(Text) == "string" then

                -- Format:
                -- 01:00
                -- 00:59
                -- 00:10
                -- 00:01
                -- 00:00

                local Minutes, Seconds =
                    string.match(Text, "^(%d%d):(%d%d)$")

                if Minutes and Seconds then

                    Minutes = tonumber(Minutes)
                    Seconds = tonumber(Seconds)

                    local Total =
                        (Minutes * 60) + Seconds

                    -- Hanya timer 0-60 detik
                    if Total >= 0 and Total <= 60 then

                        TimerValue = Total
                        break
                    end
                end
            end
        end
    end

    return TimerValue
end

--====================================================
-- SEND NEXT WAVE
--====================================================

local function NextWave()

    if not Enabled or Closed then
        return
    end

    SetStatus("Boss Won → Next Wave")

    pcall(function()

        local args = {
            [1] = 27;
        }

        ContinueBossResult:FireServer(unpack(args))

    end)

end

--====================================================
-- SEND PREVIOUS WAVE
--====================================================

local function PreviousWave()

    if not Enabled or Closed then
        return
    end

    SetStatus("Timeout → Previous Wave")

    pcall(function()

        local args = {
            [1] = 7;
        }

        ContinueBossResult:FireServer(unpack(args))

    end)

end

--====================================================
-- REBIRTH
--====================================================

local function DoRebirth()

    if not Enabled or Closed then
        return
    end

    -------------------------------------------------
    -- GET REBIRTH STATE
    -------------------------------------------------

    SetStatus("Getting Rebirth State...")

    pcall(function()

        local args = {}

        GetRebirthState:InvokeServer(unpack(args))

    end)

    task.wait(0.3)

    if not Enabled or Closed then
        return
    end

    -------------------------------------------------
    -- YES REBIRTH
    -------------------------------------------------

    SetStatus("Confirming Rebirth...")

    pcall(function()

        local args = {
            [1] = {
                ["actionId"] = "contextual_rebirth_opened";
            };
        }

        TutorialUiAction:FireServer(unpack(args))

    end)

    task.wait(0.3)

    if not Enabled or Closed then
        return
    end

    -------------------------------------------------
    -- ATTEMPT REBIRTH
    -------------------------------------------------

    SetStatus("Attempting Rebirth...")

    pcall(function()

        local args = {}

        AttemptRebirth:InvokeServer(unpack(args))

    end)

    task.wait(1)

    if Enabled and not Closed then
        SetStatus("Waiting Boss...")
    end

end

--====================================================
-- WAIT FOR BOSS TIMER
--====================================================

local function WaitForBossTimer()

    SetStatus("Waiting Boss Timer...")

    while Enabled and not Closed do

        local Timer = GetBossTimer()

        if Timer ~= nil then
            return Timer
        end

        task.wait(0.2)
    end

    return nil
end

--====================================================
-- WAIT FOR BOSS RESULT
--====================================================

local function WaitForBossResult()

    local LastTimer = nil
    local TimerStarted = false

    while Enabled and not Closed do

        local Timer = GetBossTimer()

        if Timer ~= nil then

            TimerStarted = true

            if LastTimer == nil then
                LastTimer = Timer
            end

            -- Update timer
            if Timer < LastTimer then
                LastTimer = Timer
            end

            SetStatus(
                string.format(
                    "Boss Timer : %02d:%02d",
                    math.floor(Timer / 60),
                    Timer % 60
                )
            )

            --========================================
            -- TIMEOUT
            --========================================

            if Timer <= 0 then
                return "TIMEOUT"
            end

        elseif TimerStarted then

            -- Timer hilang setelah sebelumnya berjalan.
            -- Beri waktu GUI result muncul.

            task.wait(0.5)

            local CheckTimer = GetBossTimer()

            if CheckTimer == nil then
                return "TIMEOUT"
            end

        end

        task.wait(0.15)
    end

    return nil
end

--====================================================
-- MAIN LOOP
--====================================================

task.spawn(function()

    while not Closed do

        if Enabled then

            --========================================
            -- TUNGGU BOSS
            --========================================

            local Timer = WaitForBossTimer()

            if not Timer then
                task.wait(0.2)
                continue
            end

            if not Enabled or Closed then
                break
            end

            --========================================
            -- TUNGGU HASIL BOSS
            --========================================

            local Result = WaitForBossResult()

            if not Enabled or Closed then
                break
            end

            --========================================
            -- TIMEOUT / KALAH
            --========================================

            if Result == "TIMEOUT" then

                -- 1. PREVIOUS WAVE
                PreviousWave()

                -- Tunggu server memproses
                task.wait(2)

                if not Enabled or Closed then
                    break
                end

                -- 2. BARU REBIRTH
                DoRebirth()

                task.wait(1)

            end

            --========================================
            -- MENANG
            --========================================
            --
            -- Catatan:
            -- Kemenangan tidak bisa dibedakan hanya
            -- dari countdown. Karena saat menang timer
            -- bisa berhenti/hilang sebelum 00:00.
            --
            -- Untuk Next Wave kita perlu mendeteksi
            -- result kemenangan dari GUI/event game.
            --
        else

            task.wait(0.2)

        end

    end

end)

--====================================================
-- ON / OFF
--====================================================

RebirthButton.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        RebirthButton.Text = "Rebirth : ON"

        RebirthButton.BackgroundColor3 =
            Color3.fromRGB(40, 150, 70)

        SetStatus("Waiting Boss Timer...")

    else

        RebirthButton.Text = "Rebirth : OFF"

        RebirthButton.BackgroundColor3 =
            Color3.fromRGB(55, 55, 55)

        SetStatus("OFF")

    end

end)

--====================================================
-- MINIMIZE
--====================================================

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    if Minimized then

        Content.Visible = false

        Main.Size =
            UDim2.new(0, 280, 0, 35)

        Minimize.Text = "+"

    else

        Content.Visible = true

        Main.Size =
            UDim2.new(0, 280, 0, 165)

        Minimize.Text = "—"

    end

end)

--====================================================
-- CLOSE
--====================================================

Close.MouseButton1Click:Connect(function()

    Closed = true
    Enabled = false

    ScreenGui:Destroy()

end)

--====================================================
-- DRAG
--====================================================

local Dragging = false
local DragStart
local StartPosition

TitleBar.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()

            if Input.UserInputState ==
                Enum.UserInputState.End then

                Dragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if Dragging
    and Input.UserInputType ==
        Enum.UserInputType.MouseMovement then

        local Delta =
            Input.Position - DragStart

        Main.Position = UDim2.new(

            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y

        )

    end

end)
