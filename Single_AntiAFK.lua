-- Single_AntiAFK.lua | Step 2: FPS Boost + Performance Mode (hide other players' bases)
-- Local-only visual changes. Turn toggles OFF or close the GUI to restore saved properties.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SingleAntiAFK")
if oldGui then oldGui:Destroy() end

local fpsOn, performanceOn, hideBasesOn = false, false, false
local savedProperties, savedLighting = {}, {}
local scanBusy = false

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

local function isOtherPlayerBase(root)
    -- Best-effort matching for common tycoon/base layouts: model/folder named after
    -- another player's username/display name, or a base/plot model with an owner value.
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            names[string.lower(p.Name)] = true
            names[string.lower(p.DisplayName)] = true
        end
    end

    local rootName = string.lower(root.Name)
    for name in pairs(names) do
        if name ~= "" and (rootName == name or string.find(rootName, name, 1, true)) then
            return true
        end
    end

    local rootLooksLikeBase = string.find(rootName, "base", 1, true)
        or string.find(rootName, "plot", 1, true)
        or string.find(rootName, "tycoon", 1, true)
    if not rootLooksLikeBase then return false end

    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ObjectValue") and string.find(string.lower(d.Name), "owner", 1, true) then
            local v = d.Value
            if v and v:IsA("Player") and v ~= player then return true end
        elseif (d:IsA("StringValue") or d:IsA("IntValue") or d:IsA("NumberValue"))
            and (string.find(string.lower(d.Name), "owner", 1, true)
                or string.find(string.lower(d.Name), "player", 1, true)) then
            local val = string.lower(tostring(d.Value))
            for name in pairs(names) do
                if name ~= "" and (val == name or string.find(val, name, 1, true)) then return true end
            end
        end
    end
    for attribute, value in pairs(root:GetAttributes()) do
        if string.find(string.lower(attribute), "owner", 1, true)
            or string.find(string.lower(attribute), "player", 1, true) then
            local val = string.lower(tostring(value))
            for name in pairs(names) do
                if name ~= "" and (val == name or string.find(val, name, 1, true)) then return true end
            end
        end
    end
    return false
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

local function applyPerformance()
    if not performanceOn or scanBusy then return end
    scanBusy = true
    local ok, err = pcall(function()
        for _, root in ipairs(Workspace:GetChildren()) do
            if (root:IsA("Model") or root:IsA("Folder")) and isOtherPlayerBase(root) then
                hideBase(root)
            end
        end
    end)
    scanBusy = false
    if not ok then warn("[Single Anti-AFK] Performance Mode scan error:", err) end
end

-- Hide every claimed base locally, including the local player's own base.
-- Uses the game's confirmed Workspace.Plots.Claimed layout; no server objects are deleted.
local function applyClaimedBases()
    if not hideBasesOn then return end
    local plots = Workspace:FindFirstChild("Plots")
    local claimed = plots and plots:FindFirstChild("Claimed")
    if not claimed then
        warn("[Single Anti-AFK] Workspace.Plots.Claimed not found")
        return
    end

    for _, base in ipairs(claimed:GetChildren()) do
        if base:IsA("Model") or base:IsA("Folder") then
            hideBase(base)
        end
    end
end

local function reapply()
    restoreAll()
    applyFPS()
    applyPerformance()
    applyClaimedBases()
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
title.Text = "SINGLE ANTI-AFK | STEP 3"
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

local fpsButton = makeButton("FPS Boost: OFF", 58)
local perfButton = makeButton("Performance Mode: OFF", 96)
local hideBasesButton = makeButton("Hide All Bases: OFF", 134)

local function updateButton(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(160, 90, 35) or Color3.fromRGB(55, 110, 70)
end

fpsButton.Activated:Connect(function()
    fpsOn = not fpsOn
    updateButton(fpsButton, "FPS Boost", fpsOn)
    reapply()
    status.Text = fpsOn and "FPS optimization enabled" or (hideBasesOn and "Hide All Bases enabled" or "Visuals restored")
end)

perfButton.Activated:Connect(function()
    performanceOn = not performanceOn
    updateButton(perfButton, "Performance Mode", performanceOn)
    reapply()
    status.Text = performanceOn and "Hiding detected other bases" or (fpsOn and "FPS optimization enabled" or (hideBasesOn and "Hide All Bases enabled" or "Visuals restored"))
end)

hideBasesButton.Activated:Connect(function()
    hideBasesOn = not hideBasesOn
    updateButton(hideBasesButton, "Hide All Bases", hideBasesOn)
    reapply()
    status.Text = hideBasesOn and "All claimed bases hidden locally" or (fpsOn and "FPS optimization enabled" or (performanceOn and "Performance Mode enabled" or "Visuals restored"))
end)

close.Activated:Connect(function()
    fpsOn, performanceOn, hideBasesOn = false, false, false
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
        if performanceOn then applyPerformance() end
        if hideBasesOn then applyClaimedBases() end
        if fpsOn then applyFPS() end
    end
end)
