code = r'''--[[
    SoulHero.lua
    IDLE Soul Hero
    Features:
      - Auto Farm
      - Auto M1
      - Anti AFK

    Simple / executor-friendly version.
]]

local function TRACE(tag, fn)
    local ok, err = xpcall(fn, function(e)
        return debug.traceback("[SoulHero][" .. tag .. "] " .. tostring(e), 2)
    end)
    if not ok then
        warn(err)
    end
    return ok
end

TRACE("INIT", function()

    if game.PlaceId ~= 99388466709359 then
        warn("[SoulHero] Wrong game. PlaceId: " .. tostring(game.PlaceId))
        return
    end

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")

    local LP = Players.LocalPlayer
    local WS = workspace

    --========================================================
    -- Network helpers
    --========================================================

    local Network = WS:FindFirstChild("Network")
    if not Network then
        warn("[SoulHero] Network not found.")
    end

    local function fireRemote(name, ...)
        if not Network then return false end

        local r = Network:FindFirstChild(name)
        if not r or not r:IsA("RemoteEvent") then
            return false
        end

        local ok, err = pcall(function()
            r:FireServer(...)
        end)

        if not ok then
            warn("[SoulHero] Remote failed: " .. tostring(err))
        end

        return ok
    end

    --========================================================
    -- Character helpers
    --========================================================

    local function getCharacter()
        local chars = WS:FindFirstChild("Characters")
        if chars then
            local custom = chars:FindFirstChild(LP.Name)
            if custom then
                return custom
            end
        end

        return LP.Character
    end

    local function getHRP()
        local char = getCharacter()
        if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function getHumanoid()
        local char = getCharacter()
        if not char then return nil end
        return char:FindFirstChildOfClass("Humanoid")
    end

    local function equipSword()
        local char = getCharacter()
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local backpack = LP:FindFirstChild("Backpack")

        local sword = char:FindFirstChild("Sword")

        if not sword and backpack then
            sword = backpack:FindFirstChild("Sword")
        end

        if sword and sword:IsA("Tool") and sword.Parent ~= char then
            pcall(function()
                hum:EquipTool(sword)
            end)
        end
    end

    --========================================================
    -- Enemy helpers
    --========================================================

    local function getEnemies()
        local gameFolder = WS:FindFirstChild("Game")
        if not gameFolder then return nil end
        return gameFolder:FindFirstChild("Enemies")
    end

    local function getNearestEnemy()
        local enemies = getEnemies()
        local hrp = getHRP()

        if not enemies or not hrp then
            return nil
        end

        local nearest = nil
        local nearestDistance = math.huge

        for _, enemy in ipairs(enemies:GetChildren()) do
            if enemy:IsA("Model") then
                local part = enemy:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    local distance = (part.Position - hrp.Position).Magnitude

                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearest = part
                    end
                end
            end
        end

        return nearest
    end

    --========================================================
    -- GUI
    --========================================================

    local oldGui = nil

    pcall(function()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            oldGui = pg:FindFirstChild("SoulHeroGUI")
            if oldGui then oldGui:Destroy() end
        end
    end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "SoulHeroGUI"
    Gui.ResetOnSpawn = false
    Gui.IgnoreGuiInset = true

    -- PlayerGui is used first for compatibility.
    local parented = false

    pcall(function()
        Gui.Parent = LP:WaitForChild("PlayerGui")
        parented = true
    end)

    if not parented then
        pcall(function()
            Gui.Parent = game:GetService("CoreGui")
            parented = Gui.Parent ~= nil
        end)
    end

    if not parented then
        warn("[SoulHero] Could not create GUI.")
        return
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 280, 0, 210)
    Main.Position = UDim2.new(0.5, -140, 0.5, -105)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = Gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 38)
    Bar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Bar.BorderSizePixel = 0
    Bar.Active = true
    Bar.Parent = Main

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 8)
    BarCorner.Parent = Bar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SoulHero"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Bar

    local Min = Instance.new("TextButton")
    Min.Size = UDim2.new(0, 30, 0, 28)
    Min.Position = UDim2.new(1, -65, 0, 5)
    Min.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Min.Text = "-"
    Min.TextColor3 = Color3.fromRGB(255, 255, 255)
    Min.TextSize = 18
    Min.Font = Enum.Font.GothamBold
    Min.BorderSizePixel = 0
    Min.Parent = Bar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 5)
    MinCorner.Parent = Min

    local X = Instance.new("TextButton")
    X.Size = UDim2.new(0, 30, 0, 28)
    X.Position = UDim2.new(1, -32, 0, 5)
    X.BackgroundColor3 = Color3.fromRGB(130, 45, 45)
    X.Text = "X"
    X.TextColor3 = Color3.fromRGB(255, 255, 255)
    X.TextSize = 14
    X.Font = Enum.Font.GothamBold
    X.BorderSizePixel = 0
    X.Parent = Bar

    local XCorner = Instance.new("UICorner")
    XCorner.CornerRadius = UDim.new(0, 5)
    XCorner.Parent = X

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -20, 1, -48)
    Body.Position = UDim2.new(0, 10, 0, 43)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 25)
    Status.BackgroundTransparency = 1
    Status.Text = "Ready"
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 13
    Status.Font = Enum.Font.Gotham
    Status.Parent = Body

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 7)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    List.Parent = Body

    -- UIListLayout controls Body children; status is intentionally first.

    local function makeButton(label)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 38)
        b.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        b.BorderSizePixel = 0
        b.Text = label .. " [OFF]"
        b.TextColor3 = Color3.fromRGB(235, 235, 235)
        b.TextSize = 13
        b.Font = Enum.Font.GothamMedium
        b.AutoButtonColor = false
        b.Parent = Body

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = b

        return b
    end

    local FarmButton = makeButton("Auto Farm")
    local M1Button = makeButton("Auto M1")
    local AFKButton = makeButton("Anti AFK")

    local FarmOn = false
    local M1On = false
    local AFKOn = true
    local Dead = false
    local Minimized = false

    local function setButton(button, label, on)
        button.Text = label .. (on and " [ON]" or " [OFF]")

        if on then
            button.BackgroundColor3 = Color3.fromRGB(50, 90, 60)
        else
            button.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        end
    end

    setButton(AFKButton, "Anti AFK", true)

    FarmButton.Activated:Connect(function()
        FarmOn = not FarmOn
        setButton(FarmButton, "Auto Farm", FarmOn)
        Status.Text = FarmOn and "Auto Farm: ON" or "Auto Farm: OFF"
    end)

    M1Button.Activated:Connect(function()
        M1On = not M1On
        setButton(M1Button, "Auto M1", M1On)
        Status.Text = M1On and "Auto M1: ON" or "Auto M1: OFF"
    end)

    AFKButton.Activated:Connect(function()
        AFKOn = not AFKOn
        setButton(AFKButton, "Anti AFK", AFKOn)
        Status.Text = AFKOn and "Anti AFK: ON" or "Anti AFK: OFF"
    end)

    --========================================================
    -- Drag
    --========================================================

    local dragging = false
    local dragStart = nil
    local startPosition = nil

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

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
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    --========================================================
    -- Minimize
    --========================================================

    Min.Activated:Connect(function()
        Minimized = not Minimized
        Body.Visible = not Minimized

        if Minimized then
            Main.Size = UDim2.new(0, 280, 0, 38)
            Min.Text = "+"
        else
            Main.Size = UDim2.new(0, 280, 0, 210)
            Min.Text = "-"
        end
    end)

    --========================================================
    -- Close
    --========================================================

    X.Activated:Connect(function()
        Dead = true
        FarmOn = false
        M1On = false
        AFKOn = false

        pcall(function()
            Gui:Destroy()
        end)
    end)

    --========================================================
    -- Auto Farm
    --========================================================

    task.spawn(function()
        while not Dead do
            if FarmOn then
                TRACE("AutoFarm", function()
                    equipSword()

                    local target = getNearestEnemy()
                    local hrp = getHRP()
                    local hum = getHumanoid()

                    if target and hrp then
                        pcall(function()
                            hrp.CanCollide = false
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            hrp.CFrame = target.CFrame + Vector3.new(0, 8, 0)

                            if hum then
                                hum.PlatformStand = false
                            end
                        end)

                        local char = getCharacter()
                        local sword = char and char:FindFirstChild("Sword")

                        if sword and sword:IsA("Tool") then
                            pcall(function()
                                sword:Activate()
                            end)
                        end

                        fireRemote("PlayerWeaponSwingRequested-RemoteEvent")
                        fireRemote("PlayerWeaponAttackRequested-RemoteEvent")
                    end
                end)
            end

            task.wait(1)
        end
    end)

    --========================================================
    -- Auto M1
    --========================================================

    task.spawn(function()
        while not Dead do
            if M1On then
                TRACE("AutoM1", function()
                    equipSword()

                    local char = getCharacter()
                    local sword = char and char:FindFirstChild("Sword")

                    if sword and sword:IsA("Tool") then
                        pcall(function()
                            sword:Activate()
                        end)
                    end

                    fireRemote("PlayerWeaponSwingRequested-RemoteEvent")
                    fireRemote("PlayerWeaponAttackRequested-RemoteEvent")
                end)
            end

            task.wait(1)
        end
    end)

    --========================================================
    -- Anti AFK
    --========================================================

    LP.Idled:Connect(function()
        if Dead or not AFKOn then return end

        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)

    print("[SoulHero] Loaded.")
end)
'''
path = "/mnt/data/soulhero.lua"
with open(path, "w", encoding="utf-8") as f:
    f.write(code)
print(path)
