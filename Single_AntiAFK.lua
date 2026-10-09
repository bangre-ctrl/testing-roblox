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
