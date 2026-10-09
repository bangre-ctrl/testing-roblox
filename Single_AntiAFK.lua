-- Single_AntiAFK.lua | Delta-friendly GUI + visual optimization
-- Features: Anti-AFK, FPS Boost, Performance Mode, Hide Other Bases.
-- Restore behavior: saved visual properties are restored when toggles turn OFF.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local running, stopped, triggers = false, false, 0
local fpsBoostOn, performanceOn, hideBasesOn = false, false, false
local original = { globalShadows = Lighting.GlobalShadows, effects = {}, parts = {}, hiddenBases = {} }
local qualityOk, originalQuality = pcall(function() return settings().Rendering.QualityLevel end)
local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 228)
frame.Position = UDim2.new(0, 20, 0.32, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
frame.BorderSizePixel = 0
frame.Parent = gui

local function label(text, y, h)
    local o = Instance.new("TextLabel")
    o.Size = UDim2.new(1, -16, 0, h or 24)
    o.Position = UDim2.fromOffset(8, y)
    o.BackgroundTransparency = 1
    o.Text = text
    o.TextColor3 = Color3.new(1, 1, 1)
    o.TextSize = 14
    o.Parent = frame
    return o
end

local title = label("SINGLE ANTI-AFK", 5, 24)
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(24, 24)
close.Position = UDim2.new(1, -28, 0, 4)
close.Text = "X"
close.TextSize = 14
close.Parent = frame

local function button(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 28)
    b.Position = UDim2.fromOffset(8, y)
    b.Text = text
    b.TextSize = 13
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = Color3.fromRGB(55, 110, 70)
    b.Parent = frame
    return b
end

local afk = button("Anti-AFK: OFF", 34)
local fps = button("FPS Boost: OFF", 66)
local perf = button("Performance Mode: OFF", 98)
local bases = button("Hide Other Bases: OFF", 130)
local status = label("Idle triggers: 0", 164, 22)
label("Visual changes restore when OFF", 188, 24).TextSize = 10

local function remember(obj, prop)
    if original.effects[obj] == nil then original.effects[obj] = {} end
    if original.effects[obj][prop] == nil then
        pcall(function() original.effects[obj][prop] = obj[prop] end)
    end
end

local function rememberPart(obj, prop)
    if original.parts[obj] == nil then original.parts[obj] = {} end
    if original.parts[obj][prop] == nil then
        pcall(function() original.parts[obj][prop] = obj[prop] end)
    end
end

local function restoreVisuals()
    pcall(function() Lighting.GlobalShadows = original.globalShadows end)
    for obj, props in pairs(original.effects) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do pcall(function() obj[prop] = value end) end
        end
    end
    for obj, props in pairs(original.parts) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do pcall(function() obj[prop] = value end) end
        end
    end
    for obj, value in pairs(original.hiddenBases) do
        if obj and obj.Parent then pcall(function() obj.LocalTransparencyModifier = value end) end
