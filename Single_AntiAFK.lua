-- Single_AntiAFK.lua | Step 1: working debug GUI + FPS Boost only
-- This staged build intentionally includes only FPS Boost so errors can be isolated.
-- Turn FPS Boost OFF or close the GUI to restore saved visual properties.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local previous = playerGui:FindFirstChild("SingleAntiAFK")
if previous then
    previous:Destroy()
end

local fpsOn = false
local closed = false
local savedLighting = {}
local savedProperties = {}

local function remember(object, property)
    if not savedProperties[object] then
        savedProperties[object] = {}
    end
    if savedProperties[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)
        if ok then
            savedProperties[object][property] = value
        end
    end
end

local function rememberLighting(property)
    if savedLighting[property] == nil then
        local ok, value = pcall(function()
            return Lighting[property]
        end)
        if ok then
            savedLighting[property] = value
        end
    end
end

local function restore()
    for object, properties in pairs(savedProperties) do
        if object and object.Parent then
            for property, value in pairs(properties) do
                pcall(function()
                    object[property] = value
                end)
            end
        end
    end
    table.clear(savedProperties)

    for property, value in pairs(savedLighting) do
        pcall(function()
            Lighting[property] = value
        end)
    end
    table.clear(savedLighting)
end

local function applyFPSBoost()
    restore()
    if not fpsOn then
        return
    end

    rememberLighting("GlobalShadows")
    pcall(function()
        Lighting.GlobalShadows = false
    end)

    for _, object in ipairs(game:GetDescendants()) do
        if object:IsA("ParticleEmitter")
            or object:IsA("Trail")
            or object:IsA("Beam")
            or object:IsA("Smoke")
            or object:IsA("Fire")
            or object:IsA("Sparkles")
            or object:IsA("PostEffect") then
            remember(object, "Enabled")
            pcall(function()
                object.Enabled = false
            end)
        end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0, 230, 0, 104)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 28)
title.Position = UDim2.new(0, 8, 0, 3)
title.BackgroundTransparency = 1
title.Text = "SINGLE ANTI-AFK | STEP 1"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.TextSize = 14
close.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 24)
status.Position = UDim2.new(0, 8, 0, 34)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(120, 230, 140)
status.TextSize = 13
status.Parent = frame

local fpsButton = Instance.new("TextButton")
fpsButton.Size = UDim2.new(1, -16, 0, 30)
fpsButton.Position = UDim2.new(0, 8, 0, 65)
fpsButton.Text = "FPS Boost: OFF"
fpsButton.TextSize = 13
fpsButton.TextColor3 = Color3.new(1, 1, 1)
fpsButton.BackgroundColor3 = Color3.fromRGB(55, 110, 70)
fpsButton.Parent = frame

fpsButton.Activated:Connect(function()
    fpsOn = not fpsOn
    fpsButton.Text = "FPS Boost: " .. (fpsOn and "ON" or "OFF")
    fpsButton.BackgroundColor3 = fpsOn
        and Color3.fromRGB(160, 90, 35)
        or Color3.fromRGB(55, 110, 70)
    applyFPSBoost()
    status.Text = fpsOn and "FPS optimization enabled" or "Visuals restored"
end)

close.Activated:Connect(function()
    closed = true
    fpsOn = false
    restore()
    gui:Destroy()
end)

-- Drag by title bar.
local dragging = false
local dragStart
local frameStart

title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
