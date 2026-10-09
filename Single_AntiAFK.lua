-- Single_AntiAFK.lua | Delta-friendly GUI + basic visual optimization
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local running, stopped, triggers = false, false, 0
local fpsBoostOn, performanceOn = false, false
local original = { globalShadows = Lighting.GlobalShadows, effects = {}, parts = {} }
local qualityOk, originalQuality = pcall(function() return settings().Rendering.QualityLevel end)
local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local gui = Instance.new("ScreenGui")
gui.Name = "SingleAntiAFK"
gui.ResetOnSpawn = false
gui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(230, 190)
frame.Position = UDim2.new(0, 20, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
frame.BorderSizePixel = 0
frame.Parent = gui
local function label(text, y, h)
 local o=Instance.new("TextLabel"); o.Size=UDim2.new(1,-16,0,h or 24); o.Position=UDim2.fromOffset(8,y); o.BackgroundTransparency=1; o.Text=text; o.TextColor3=Color3.new(1,1,1); o.TextSize=14; o.Parent=frame; return o
end
local title=label("SINGLE ANTI-AFK",5,24)
local close=Instance.new("TextButton"); close.Size=UDim2.fromOffset(24,24); close.Position=UDim2.new(1,-28,0,4); close.Text="X"; close.TextSize=14; close.Parent=frame
local function button(text,y)
 local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-16,0,28); b.Position=UDim2.fromOffset(8,y); b.Text=text; b.TextSize=13; b.TextColor3=Color3.new(1,1,1); b.BackgroundColor3=Color3.fromRGB(55,110,70); b.Parent=frame; return b
end
local afk=button("Anti-AFK: OFF",34)
local fps=button("FPS Boost: OFF",66)
local perf=button("Performance Mode: OFF",98)
local status=label("Idle triggers: 0",132,24)
label("Visual settings restore when both modes are OFF",156,28).TextSize=10

local function remember(obj, prop)
 if original.effects[obj] == nil then original.effects[obj] = {} end
 if original.effects[obj][prop] == nil then pcall(function() original.effects[obj][prop] = obj[prop] end) end
end
local function restoreVisuals()
 pcall(function() Lighting.GlobalShadows = original.globalShadows end)
 for obj, props in pairs(original.effects) do
  if obj and obj.Parent then for prop, value in pairs(props) do pcall(function() obj[prop]=value end) end end
 end
 for obj, props in pairs(original.parts) do
  if obj and obj.Parent then for prop, value in pairs(props) do pcall(function() obj[prop]=value end) end end
 end
 if qualityOk then pcall(function() settings().Rendering.QualityLevel = originalQuality end) end
end
local function optimize()
 restoreVisuals()
 if not fpsBoostOn and not performanceOn then return end
 pcall(function() Lighting.GlobalShadows = false end)
 if qualityOk then pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end) end
 for _, obj in ipairs(game:GetDescendants()) do
  if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
   remember(obj,"Enabled"); pcall(function() obj.Enabled=false end)
  elseif performanceOn and obj:IsA("BasePart") then
   remember(obj,"Material"); remember(obj,"Reflectance"); pcall(function() obj.Material=Enum.Material.SmoothPlastic; obj.Reflectance=0 end)
  elseif obj:IsA("PostEffect") then
   remember(obj,"Enabled"); pcall(function() obj.Enabled=false end)
  end
 end
end
local function setAFK(v)
 running=v; afk.Text=v and "Anti-AFK: ON" or "Anti-AFK: OFF"; afk.BackgroundColor3=v and Color3.fromRGB(160,90,35) or Color3.fromRGB(55,110,70)
end
player.Idled:Connect(function()
 if not running or stopped then return end
 triggers += 1; status.Text="Idle triggers: "..triggers
 if VirtualUser then
  local ok, err = pcall(function()
   if type(VirtualUser.CaptureController) == "function" then VirtualUser:CaptureController() end
   if type(VirtualUser.ClickButton2) == "function" then VirtualUser:ClickButton2(Vector2.new(0,0)) end
  end)
  if not ok then status.Text="Idle event: VirtualUser unsupported"; warn("[Single_AntiAFK] "..tostring(err)) end
 else
  status.Text="Idle event: VirtualUser unavailable"
 end
end)
afk.Activated:Connect(function() setAFK(not running) end)
fps.Activated:Connect(function() fpsBoostOn=not fpsBoostOn; fps.Text="FPS Boost: "..(fpsBoostOn and "ON" or "OFF"); optimize() end)
perf.Activated:Connect(function() performanceOn=not performanceOn; perf.Text="Performance Mode: "..(performanceOn and "ON" or "OFF"); optimize() end)
close.Activated:Connect(function() stopped=true; running=false; restoreVisuals(); gui:Destroy() end)

local dragging, dragStart, frameStart = false, nil, nil
title.Active=true
title.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=input.Position; frameStart=frame.Position end
end)
UserInputService.InputChanged:Connect(function(input)
 if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
  local d=input.Position-dragStart; frame.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+d.X,frameStart.Y.Scale,frameStart.Y.Offset+d.Y)
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
