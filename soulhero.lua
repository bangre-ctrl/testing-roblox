--[[
    SoulHero.lua
    IDLE Soul Hero
    Features:
    - Auto Farm
    - Auto M1
    - Anti AFK

    GUI:
    - Draggable
    - Minimize
    - Close
]]

if game.PlaceId ~= 99388466709359 then
    warn("[SoulHero] Wrong game.")
    return
end

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local WS = workspace

--// Network
local Network = WS:WaitForChild("Network")

local function remote(name)
    return Network:FindFirstChild(name)
end

local function fireRemote(name, ...)
    local r = remote(name)

    if r and r:IsA("RemoteEvent") then
        pcall(function()
            r:FireServer(...)
        end)
    end
end

--// Character
local function getCharacter()
    local chars = WS:FindFirstChild("Characters")

    return (chars and chars:FindFirstChild(LocalPlayer.Name))
        or LocalPlayer.Character
end

local function playerHrp()
    local char = getCharacter()

    if char and char:IsA("Model") then
        return char:FindFirstChild("HumanoidRootPart")
    end

    return nil
end

local function playerHumanoid()
    local char = getCharacter()

    if char and char:IsA("Model") then
        return char:FindFirstChildOfClass("Humanoid")
    end

    return nil
end

--// Sword
local function equipSword()
    local char = getCharacter()

    if not char then
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    local sword =
        char:FindFirstChild("Sword")
        or (backpack and backpack:FindFirstChild("Sword"))

    if hum and sword and sword:IsA("Tool") and sword.Parent ~= char then
        pcall(function()
            hum:EquipTool(sword)
        end)
    end
end

--// Enemies
local function enemiesFolder()
    local gameFolder = WS:FindFirstChild("Game")

    if gameFolder then
        return gameFolder:FindFirstChild("Enemies")
    end

    return nil
end

local function nearestEnemy()
    local folder = enemiesFolder()
    local hrp = playerHrp()

    if not folder or not hrp then
        return nil, nil
    end

    local bestEnemy = nil
    local bestPart = nil
    local bestDistance = math.huge

    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy:IsA("Model") then
            local part = enemy:FindFirstChildWhichIsA("BasePart", true)

            if part then
                local distance =
                    (part.Position - hrp.Position).Magnitude

                if distance < bestDistance then
                    bestDistance = distance
                    bestEnemy = enemy
                    bestPart = part
                end
            end
        end
    end

    return bestEnemy, bestPart
end

--// States
local AutoFarm = false
local AutoM1 = false
local AntiAFK = true
local Destroyed = false

local Connections = {}

--// =========================================================
--// GUI
--// =========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoulHeroGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 230)
Main.Position = UDim2.new(0.5, -150, 0.5, -115)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- Fix bottom corners of topbar
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔ SoulHero"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Minimize
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(35, 30)
Minimize.Position = UDim2.new(1, -75, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.BorderSizePixel = 0
Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = Minimize

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 30)
Close.Position = UDim2.new(1, -37, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.fromOffset(10, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Content

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "SoulHero | Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.Parent = Content

--// Toggle creator
local function createToggle(text, callback)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.BorderSizePixel = 0
    Button.Text = text .. "  [OFF]"
    Button.TextColor3 = Color3.fromRGB(220, 220, 220)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local enabled = false

    Button.MouseButton1Click:Connect(function()
        enabled = not enabled

        Button.Text = text .. (enabled and "  [ON]" or "  [OFF]")

        if enabled then
            Button.BackgroundColor3 = Color3.fromRGB(55, 95, 65)
        else
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end

        callback(enabled)
    end)

    return Button
end

--// Auto Farm
createToggle("⚔ Auto Farm", function(value)
    AutoFarm = value

    Status.Text = value
        and "Auto Farm: ON"
        or "Auto Farm: OFF"
end)

--// Auto M1
createToggle("🗡 Auto M1", function(value)
    AutoM1 = value

    Status.Text = value
        and "Auto M1: ON"
        or "Auto M1: OFF"
end)

--// Anti AFK
local AntiButton = createToggle("💤 Anti AFK", function(value)
    AntiAFK = value

    Status.Text = value
        and "Anti AFK: ON"
        or "Anti AFK: OFF"
end)

-- Default ON visual
AntiButton.Text = "💤 Anti AFK  [ON]"
AntiButton.BackgroundColor3 = Color3.fromRGB(55, 95, 65)

--// =========================================================
--// DRAG SYSTEM
--// =========================================================

local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end)

--// =========================================================
--// MINIMIZE
--// =========================================================

local minimized = false

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    Content.Visible = not minimized

    if minimized then
        Main.Size = UDim2.fromOffset(300, 40)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.fromOffset(300, 230)
        Minimize.Text = "-"
    end
end)

--// =========================================================
--// CLOSE
--// =========================================================

Close.MouseButton1Click:Connect(function()
    Destroyed = true

    AutoFarm = false
    AutoM1 = false
    AntiAFK = false

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    ScreenGui:Destroy()
end)

--// =========================================================
--// AUTO FARM LOOP
--// =========================================================

task.spawn(function()
    while not Destroyed do
        if AutoFarm then
            pcall(function()
                equipSword()

                local _, enemyPart = nearestEnemy()
                local hrp = playerHrp()
                local hum = playerHumanoid()

                if enemyPart and hrp then

                    hrp.CanCollide = false

                    if hum then
                        hum.PlatformStand = false
                    end

                    hrp.CFrame =
                        enemyPart.CFrame
                        + Vector3.new(0, 8, 0)

                    hrp.AssemblyLinearVelocity =
                        Vector3.zero

                    local char = hum and hum.Parent
                    local sword =
                        char and char:FindFirstChild("Sword")

                    if sword and sword:IsA("Tool") then
                        sword:Activate()
                    end

                    fireRemote(
                        "PlayerWeaponSwingRequested-RemoteEvent"
                    )

                    fireRemote(
                        "PlayerWeaponAttackRequested-RemoteEvent"
                    )
                end
            end)
        end

        task.wait(1)
    end
end)

--// =========================================================
--// AUTO M1 LOOP
--// =========================================================

task.spawn(function()
    while not Destroyed do
        if AutoM1 then
            pcall(function()
                equipSword()

                local hum = playerHumanoid()

                if hum then
                    local char = hum.Parent
                    local sword =
                        char and char:FindFirstChild("Sword")

                    if sword and sword:IsA("Tool") then
                        sword:Activate()
                    end
                end

                fireRemote(
                    "PlayerWeaponSwingRequested-RemoteEvent"
                )

                fireRemote(
                    "PlayerWeaponAttackRequested-RemoteEvent"
                )
            end)
        end

        task.wait(1)
    end
end)

--// =========================================================
--// ANTI AFK
--// =========================================================

local AFKConnection

AFKConnection = LocalPlayer.Idled:Connect(function()
    if Destroyed or not AntiAFK then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

table.insert(Connections, AFKConnection)

print("[SoulHero] Loaded successfully.")
