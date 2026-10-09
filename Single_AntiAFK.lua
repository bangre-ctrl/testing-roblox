-- Single_AntiAFK.lua | FPS Boost + Hide All Bases
-- Local-only visual changes. Turn toggles OFF or close the GUI to restore saved properties.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SingleAntiAFK")
if oldGui then oldGui:Destroy() end

local antiAfkOn, fpsOn, hideBasesOn = false, false, false
local antiAfkBusy = false
local savedProperties, savedLighting = {}, {}

local function remember(object, property)
    if not savedProperties[object] then savedProperties[object] = {} end
    if savedProperties[object][property] == nil then
        local ok, value = pcall(function() return object[property] end)
        if ok then savedProperties[object][property] = value end
    end
end

local function setSaved(object, property, value)
    remember(object, property)
    pcall(function() object[property] = value end)
end

local function rememberLight(property)
    if savedLighting[property] == nil then
        local ok, value = pcall(function() return Lighting[property] end)
        if ok then savedLighting[property] = value end
    end
end

local function restoreAll()
    for object, properties in pairs(savedProperties) do
        if object and object.Parent then
            for property, value in pairs(properties) do
                pcall(function() object[property] = value end)
            end
        end
    end
    table.clear(savedProperties)
    for property, value in pairs(savedLighting) do
        pcall(function() Lighting[property] = value end)
    end
    table.clear(savedLighting)
end

local function applyFPS()
    if not fpsOn then return end
    rememberLight("GlobalShadows")
    pcall(function() Lighting.GlobalShadows = false end)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
            or obj:IsA("PostEffect") then
            setSaved(obj, "Enabled", false)
        end
    end
end

local function hideBase(root)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("BasePart") then
            setSaved(obj, "LocalTransparencyModifier", 1)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            setSaved(obj, "Transparency", 1)
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ProximityPrompt") then
            setSaved(obj, "Enabled", false)
        end
    end
end

-- Hide all plot visuals locally, including claimed and unclaimed plots.
local function applyAllBases()
    if not hideBasesOn then return end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then
        warn("[Single Anti-AFK] Workspace.Plots not found")
        return
    end
    hideBase(plots)
end

local function reapply()
    restoreAll()
    applyFPS()
    applyAllBases()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0, 270, 0, 183)
frame.Position = UDim2.new(0, 20, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -36, 0, 28)
title.Position = UDim2.new(0, 8, 0, 3)
title.BackgroundTransparency = 1
title.Text = "SINGLE ANTI-AFK"
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
status.Size = UDim2.new(1, -16, 0, 22)
status.Position = UDim2.new(0, 8, 0, 32)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(120, 230, 140)
status.TextSize = 13
status.Parent = frame

local function makeButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 32)
    b.Position = UDim2.new(0, 8, 0, y)
    b.Text = text
    b.TextSize = 13
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = Color3.fromRGB(55, 110, 70)
    b.Parent = frame
    return b
end

local antiAfkButton = makeButton("Anti-AFK: OFF", 58)
local fpsButton = makeButton("FPS Boost: OFF", 96)
local hideBasesButton = makeButton("Hide All Bases: OFF", 134)

local function updateButton(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(160, 90, 35) or Color3.fromRGB(55, 110, 70)
end

-- Anti-idle input helper. Triggered by Roblox's Idled event and a slow fallback loop.
local function pulseAntiAfk()
    if not antiAfkOn or antiAfkBusy then return end
    antiAfkBusy = true
    pcall(function()
        VirtualUser:CaptureController()
        local camera = Workspace.CurrentCamera
        local cameraCFrame = camera and camera.CFrame or CFrame.new()
        VirtualUser:Button2Down(Vector2.new(0, 0), cameraCFrame)
        task.wait(0.25)
        VirtualUser:Button2Up(Vector2.new(0, 0), cameraCFrame)
    end)
    antiAfkBusy = false
end

player.Idled:Connect(function()
    if antiAfkOn then
        pulseAntiAfk()
    end
end)

antiAfkButton.Activated:Connect(function()
    antiAfkOn = not antiAfkOn
    updateButton(antiAfkButton, "Anti-AFK", antiAfkOn)
    status.Text = antiAfkOn and "Anti-AFK enabled" or "Anti-AFK disabled"
end)

fpsButton.Activated:Connect(function()
    fpsOn = not fpsOn
    updateButton(fpsButton, "FPS Boost", fpsOn)
    reapply()
    status.Text = fpsOn and "FPS optimization enabled" or (hideBasesOn and "Hide All Bases enabled" or "Visuals restored")
end)

hideBasesButton.Activated:Connect(function()
    hideBasesOn = not hideBasesOn
    updateButton(hideBasesButton, "Hide All Bases", hideBasesOn)
    reapply()
    status.Text = hideBasesOn and "All plots hidden locally" or (fpsOn and "FPS optimization enabled" or "Visuals restored")
end)

close.Activated:Connect(function()
    antiAfkOn, fpsOn, hideBasesOn = false, false, false
    restoreAll()
    gui:Destroy()
end)

-- Drag by title bar.
local dragging, dragStart, frameStart = false, nil, nil
title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, frameStart = true, input.Position, frame.Position
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

-- Repeat scans to catch bases streamed/created after the toggle is enabled.
task.spawn(function()
    while gui.Parent do
        task.wait(3)
        if hideBasesOn then applyAllBases() end
        if fpsOn then applyFPS() end
        if antiAfkOn then pulseAntiAfk() end
    end
end)
