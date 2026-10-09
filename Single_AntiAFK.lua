-- Single_AntiAFK.lua | FPS Boost + Performance Mode + Hide Other Bases
-- Built on the minimal GUI that was confirmed to work in Delta.
-- Visual changes are local and saved values are restored when each mode is disabled.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("SingleAntiAFK")
if oldGui then
    oldGui:Destroy()
end

local fpsOn = false
local performanceOn = false
local hideBasesOn = false
local closed = false

local savedLighting = {}
local savedProperties = {}
local savedBaseParts = {}

local function saveProperty(object, property)
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

local function restoreProperties()
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

    for object, value in pairs(savedBaseParts) do
        if object and object.Parent then
            pcall(function()
                object.LocalTransparencyModifier = value
            end)
        end
    end
    table.clear(savedBaseParts)

    for property, value in pairs(savedLighting) do
        pcall(function()
            Lighting[property] = value
        end)
    end
    table.clear(savedLighting)
end

local function saveLighting(property)
    if savedLighting[property] == nil then
        local ok, value = pcall(function()
            return Lighting[property]
        end)
        if ok then
            savedLighting[property] = value
        end
    end
end

local function isVisualEffect(object)
    return object:IsA("ParticleEmitter")
        or object:IsA("Trail")
        or object:IsA("Beam")
        or object:IsA("Smoke")
        or object:IsA("Fire")
        or object:IsA("Sparkles")
        or object:IsA("PostEffect")
end

local function applyVisuals()
    restoreProperties()

    if not fpsOn and not performanceOn then
        return
    end

    saveLighting("GlobalShadows")
