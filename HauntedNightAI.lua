-- HauntedNightAI.lua | Halloween Hub
-- Dice.lua remains untouched. Combined GUI + Haunted Night loop + potion tier manager.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
if not player then return end

shared.__HauntedNightAIRunId = (shared.__HauntedNightAIRunId or 0) + 1
local runId = shared.__HauntedNightAIRunId
local function alive() return shared.__HauntedNightAIRunId == runId end
local network = ReplicatedStorage:WaitForChild("Network")
local pumpkinRoll = network:WaitForChild("PumpkinDiceService"):WaitForChild("RF"):WaitForChild("Roll")
local boostUse = network:WaitForChild("BoostService"):WaitForChild("RE"):WaitForChild("Use")
local questClaim = network:WaitForChild("HalloweenQuestService"):WaitForChild("RE"):WaitForChild("Claim")

local state = {haunted=false, pumpkin=false, candy=false, damage=false, hourly=false, daily=false, candyFarm=false, antiAfk=false, fps=false, hideBases=false}
local closed, eventActive, countdownSeen, potionUsed = false, false, false, false
local eventStarted, lastRoll, antiBusy = 0, 0, false
local savedProps, savedLighting = {}, {}
local function log(s) print("[HauntedNightAI] "..s) end
local function status(s) if statusLabel and statusLabel.Parent then statusLabel.Text = s end end
local function firePotion(name)
  local ok,err=pcall(function() boostUse:FireServer(name) end)
  if ok then log("Used "..name); status("Used "..name) else warn("[HauntedNightAI] "..name..": "..tostring(err)) end
  return ok
end

-- GUI
pcall(function() local old=player.PlayerGui:FindFirstChild("HauntedNightHub"); if old then old:Destroy() end end)
local gui=Instance.new("ScreenGui"); gui.Name="HauntedNightHub"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local main=Instance.new("Frame",gui); main.Size=UDim2.fromOffset(420,520); main.Position=UDim2.new(.5,-210,.5,-260); main.BackgroundColor3=Color3.fromRGB(25,25,32); main.BorderSizePixel=0; main.Active=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
local title=Instance.new("TextLabel",main); title.Size=UDim2.new(1,-70,0,38); title.Position=UDim2.fromOffset(12,0); title.BackgroundTransparency=1; title.Text="🎃 Haunted Night Hub"; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.GothamBold; title.TextSize=17; title.TextXAlignment=Enum.TextXAlignment.Left
local close=Instance.new("TextButton",main); close.Size=UDim2.fromOffset(32,28); close.Position=UDim2.new(1,-38,0,5); close.Text="X"; close.TextColor3=Color3.new(1,1,1); close.BackgroundColor3=Color3.fromRGB(170,55,55)
local minimize=Instance.new("TextButton",main); minimize.Size=UDim2.fromOffset(28,28); minimize.Position=UDim2.new(1,-70,0,5); minimize.Text="–"; minimize.TextColor3=Color3.new(1,1,1); minimize.BackgroundColor3=Color3.fromRGB(70,70,85)
statusLabel=Instance.new("TextLabel",main); statusLabel.Size=UDim2.new(1,-20,0,18); statusLabel.Position=UDim2.fromOffset(10,37); statusLabel.BackgroundTransparency=1; statusLabel.Text="Ready"; statusLabel.TextColor3=Color3.fromRGB(120,205,255); statusLabel.TextSize=12; statusLabel.Font=Enum.Font.Gotham; statusLabel.TextXAlignment=Enum.TextXAlignment.Left
local pumpkinStatus=Instance.new("TextLabel",main); pumpkinStatus.Size=UDim2.new(1,-20,0,15); pumpkinStatus.Position=UDim2.fromOffset(10,54); pumpkinStatus.BackgroundTransparency=1; pumpkinStatus.Text="Pumpkin: idle"; pumpkinStatus.TextColor3=Color3.fromRGB(255,190,90); pumpkinStatus.TextSize=11; pumpkinStatus.Font=Enum.Font.Gotham; pumpkinStatus.TextXAlignment=Enum.TextXAlignment.Left
local candyStatus=Instance.new("TextLabel",main); candyStatus.Size=UDim2.new(1,-20,0,15); candyStatus.Position=UDim2.fromOffset(10,69); candyStatus.BackgroundTransparency=1; candyStatus.Text="Candy: idle"; candyStatus.TextColor3=Color3.fromRGB(255,150,210); candyStatus.TextSize=11; candyStatus.Font=Enum.Font.Gotham; candyStatus.TextXAlignment=Enum.TextXAlignment.Left
local damageStatus=Instance.new("TextLabel",main); damageStatus.Size=UDim2.new(1,-20,0,15); damageStatus.Position=UDim2.fromOffset(10,84); damageStatus.BackgroundTransparency=1; damageStatus.Text="Damage: idle"; damageStatus.TextColor3=Color3.fromRGB(170,210,255); damageStatus.TextSize=11; damageStatus.Font=Enum.Font.Gotham; damageStatus.TextXAlignment=Enum.TextXAlignment.Left
local function potionStatus(category, message)
 local target = category == "Pumpkin" and pumpkinStatus or category == "Candy" and candyStatus or damageStatus
 if target and target.Parent then target.Text = category .. ": " .. message end
end
local scroll=Instance.new("ScrollingFrame",main); scroll.Position=UDim2.fromOffset(10,102); scroll.Size=UDim2.new(1,-20,1,-112); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=5; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new()
local layout=Instance.new("UIListLayout",scroll); layout.Padding=UDim.new(0,5); layout.SortOrder=Enum.SortOrder.LayoutOrder
local pad=Instance.new("UIPadding",scroll); pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,8)
local function section(s)
 local l=Instance.new("TextLabel",scroll); l.Size=UDim2.new(1,-8,0,25); l.BackgroundTransparency=1; l.Text=s; l.TextColor3=Color3.fromRGB(180,210,255); l.Font=Enum.Font.GothamBold; l.TextSize=14; l.TextXAlignment=Enum.TextXAlignment.Left
end
local buttons={}
local function toggle(label,key,callback)
 local b=Instance.new("TextButton",scroll); b.Size=UDim2.new(1,-8,0,34); b.BackgroundColor3=Color3.fromRGB(55,55,68); b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=12
 local function paint() b.Text=label.." : "..(state[key] and "ON" or "OFF"); b.BackgroundColor3=state[key] and Color3.fromRGB(55,120,80) or Color3.fromRGB(55,55,68) end
 b.Activated:Connect(function() state[key]=not state[key]; paint(); callback(state[key]) end); paint(); buttons[key]=b
end
section("📜 AUTO HALLOWEEN QUEST")
toggle("Hourly Quest","hourly",function(on) status("Hourly Quest "..(on and "ON" or "OFF")) end)
toggle("Daily Quest","daily",function(on) status("Daily Quest "..(on and "ON" or "OFF")) end)
section("🍬 CANDY FARM")
toggle("Auto Farm Candy","candyFarm",function(on) status("Candy Farm "..(on and "ON" or "OFF")) end)
section("🌙 HAUNTED NIGHT AI")
toggle("Haunted Night AI","haunted",function(on)
 if not on then eventActive=false; countdownSeen=false; potionUsed=false; status("Haunted Night AI OFF — no new rolls/potions")
 else status("Haunted Night AI ON — waiting for event") end
end)
section("🧪 AUTO HALLOWEEN POTIONS — highest tier first")
toggle("Auto Pumpkin Potion III → II → I","pumpkin",function(on) status("Pumpkin Auto Potion "..(on and "ON" or "OFF")) end)
toggle("Auto Candy Potion III → II → I","candy",function(on) status("Candy Auto Potion "..(on and "ON" or "OFF")) end)
toggle("Auto Damage Potion III → II → I","damage",function(on) status("Damage Auto Potion "..(on and "ON" or "OFF")) end)
section("⚙️ SETTINGS")
toggle("Anti-AFK (W every 10s)","antiAfk",function(on) status("Anti-AFK "..(on and "ON" or "OFF")) end)
toggle("FPS Boost","fps",function(on)
 if on then pcall(function() Lighting.GlobalShadows=false end) else pcall(function() Lighting.GlobalShadows=true end) end
 status("FPS Boost "..(on and "ON" or "OFF"))
end)
toggle("Hide All Bases", "hideBases", function(on)
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, object in ipairs(plots:GetDescendants()) do
            pcall(function()
                if object:IsA("BasePart") then
                    object.LocalTransparencyModifier = on and 1 or 0
                elseif object:IsA("Decal") or object:IsA("Texture") then
                    object.Transparency = on and 1 or 0
                end
            end)
        end
    end
    status("Hide All Bases " .. (on and "ON" or "OFF"))
end)

-- drag / minimize
local dragging, dragStart, startPos=false,nil,nil
title.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; dragStart=i.Position; startPos=main.Position; i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dragStart; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)
local minimized=false
minimize.Activated:Connect(function() minimized=not minimized; scroll.Visible=not minimized; main.Size=minimized and UDim2.fromOffset(420,66) or UDim2.fromOffset(420,520) end)
close.Activated:Connect(function() closed=true; state.haunted=false; state.antiAfk=false; shared.__HauntedNightAIRunId=shared.__HauntedNightAIRunId+1; gui:Destroy() end)

-- Timer parsing and potion UI paths confirmed from PlayerGui.
-- Halloween potion timer parser. Supports formats such as "7h 55m", "2h 4m", "4m 30s", "55s", and "1s".
local function parseTimer(v)
    if type(v) ~= "string" then return nil end
    local textValue = string.lower(v)
    local h = tonumber(textValue:match("(%d+)%s*h")) or 0
    local m = tonumber(textValue:match("(%d+)%s*m")) or 0
    local s = tonumber(textValue:match("(%d+)%s*s")) or 0
    if textValue:match("%d+%s*h") or textValue:match("%d+%s*m") or textValue:match("%d+%s*s") then
        return h * 3600 + m * 60 + s
    end
    return tonumber(textValue:match("^%s*(%d+)%s*$"))
end

local function timerFor(name)
    local pg = player:FindFirstChildOfClass("PlayerGui")
    local root = pg and pg:FindFirstChild("Root")
    local menus = root and root:FindFirstChild("Menus")
    local boosts = menus and menus:FindFirstChild("Boosts")
    local content = boosts and boosts:FindFirstChild("Content")
    local sf = content and content:FindFirstChild("ScrollingFrame")
    local card = sf and sf:FindFirstChild("Boost_" .. name)
    local label = card and card:FindFirstChild("TextLabel")
    if label and label:IsA("TextLabel") then
        return label
    end
    return nil
end

local function tierCycle(enabled, tiers, category)
    task.spawn(function()
        local pendingName = nil
        local pendingSince = 0
        while alive() and not closed do
            if state[enabled] then
                local activeName, activeSeconds = nil, nil
                local timerUnknown = false

                -- If any potion in this category has a live countdown, do not use another.
                for _, name in ipairs(tiers) do
                    local label = timerFor(name)
                    if label then
                        local seconds = parseTimer(label.Text)
                        if seconds == nil then
                            timerUnknown = true
                        elseif seconds > 1 then
                            activeName = name
                            activeSeconds = seconds
                            break
                        end
                    end
                end

                if activeName then
                    pendingName = nil
                    potionStatus(category, activeName .. " active — " .. tostring(math.floor(activeSeconds / 3600)) .. "h " .. tostring(math.floor((activeSeconds % 3600) / 60)) .. "m remaining")
                elseif timerUnknown then
                    -- Fail closed: don't consume more potions if a visible timer can't be parsed.
                    pendingName = nil
                    potionStatus(category, "timer unreadable; waiting")
                elseif pendingName then
                    -- Give the UI time to show the new countdown. If it never appears,
                    -- assume that tier may be unavailable and try the next lower tier.
                    if os.clock() - pendingSince >= 8 then
                        local nextIndex = table.find(tiers, pendingName)
                        if nextIndex and nextIndex < #tiers then
                            local nextName = tiers[nextIndex + 1]
                            log(category .. " timer did not appear for " .. pendingName .. "; trying " .. nextName)
                            if firePotion(nextName) then
                                pendingName = nextName
                                pendingSince = os.clock()
                            else
                                pendingName = nil
                            end
                        else
                            pendingName = nil
                            potionStatus(category, "no active timer detected")
                        end
                    end
                else
                    -- No timer is active: try the highest tier first.
                    local firstName = tiers[1]
                    if firePotion(firstName) then
                        pendingName = firstName
                        pendingSince = os.clock()
                    end
                end
            else
                pendingName = nil
            end
            task.wait(0.5)
        end
    end)
end

tierCycle("pumpkin", {"Pumpkin Pot III", "Pumpkin Pot II", "Pumpkin Pot I"}, "Pumpkin")
tierCycle("candy", {"Candy Pot III", "Candy Pot II", "Candy Pot I"}, "Candy")
tierCycle("damage", {"Damage III", "Damage II", "Damage I"}, "Damage")

-- Haunted Night notification watcher and event loop; event automation is gated by toggle.
local function isStart(s) return type(s)=="string" and string.lower(s):find("haunted night has started",1,true)~=nil end
local function beginEvent(msg)
 if not state.haunted or eventActive or not alive() then return end
 eventActive=true; countdownSeen=false; eventStarted=os.clock(); potionUsed=false; lastRoll=0
 log("Haunted Night detected: "..msg)
 if not potionUsed then potionUsed=true; firePotion("Haunted Potion") end
end
local function watchText(obj, initial)
 if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
 local function check() if alive() and state.haunted and not eventActive and isStart(obj.Text) then beginEvent(obj.Text) end end
 obj:GetPropertyChangedSignal("Text"):Connect(check); if initial then check() end
end
task.spawn(function()
 local pg=player:WaitForChild("PlayerGui"); local root=pg:WaitForChild("Root",15); local n=root and root:WaitForChild("Notifications",15); local texts=n and n:WaitForChild("TextNotifications",15)
 if not texts then warn("[HauntedNightAI] Notifications path missing"); return end
 for _,o in ipairs(texts:GetDescendants()) do watchText(o,false) end
 texts.DescendantAdded:Connect(function(o) watchText(o,true) end)
 log("Notification watcher ready")
end)
local function weatherLabel()
 local pg=player:FindFirstChildOfClass("PlayerGui"); local root=pg and pg:FindFirstChild("Root"); local menus=root and root:FindFirstChild("Menus"); local boosts=menus and menus:FindFirstChild("Boosts"); local content=boosts and boosts:FindFirstChild("Content"); local sf=content and content:FindFirstChild("ScrollingFrame"); local card=sf and sf:FindFirstChild("__WeatherEvent"); local l=card and card:FindFirstChild("TextLabel")
 return l
end
task.spawn(function()
 while alive() and not closed do
  if state.haunted and eventActive then
   local l=weatherLabel(); local seconds=l and parseTimer(l.Text)
   if seconds and seconds>1 then countdownSeen=true
    if os.clock()-lastRoll>=1 then lastRoll=os.clock(); local ok,err=pcall(function() pumpkinRoll:InvokeServer(5) end); if not ok then warn("[HauntedNightAI] Roll failed: "..tostring(err)) end end
   elseif countdownSeen then
    log("Event ended; roll stopped. Waiting next Haunted Night."); eventActive=false; countdownSeen=false; potionUsed=false
   elseif os.clock()-eventStarted>15 then
    log("Countdown missing; cancel session."); eventActive=false; countdownSeen=false; potionUsed=false
   end
  end
  task.wait(.2)
 end
end)

-- Auto quest claim loop.
local function questLoop(key, questName, types)
 task.spawn(function()
  while alive() and not closed do
   if state[key] then
    for _,typ in ipairs(types) do
     if not state[key] or not alive() then break end
     pcall(function() questClaim:FireServer(questName,typ) end); task.wait(1)
    end
    for _=1,29 do if not state[key] then break end; task.wait(1) end
   else task.wait(.25) end
  end
 end)
end
questLoop("hourly","Hourly",{"Doors","Floors","PumpkinRolls","Rolls","Potion"})
questLoop("daily","Daily",{"Floors","Doors","PumpkinRolls"})

-- Candy farm loop: use the seven known house coordinates from Dice.lua.
local halloweenHousePositions = {
    Vector3.new(-1918.9908447265625, -18.525264739990234, 11269.607421875),
    Vector3.new(-1874.678955078125, -18.52757453918457, 11318.90625),
    Vector3.new(-1872.4171142578125, -18.5252742767334, 11360.30859375),
    Vector3.new(-1806.24169921875, -18.522422790527344, 11321.392578125),
    Vector3.new(-1800.51025390625, -18.514902114868164, 11360.6962890625),
    Vector3.new(-1993.9033203125, -18.54891586303711, 11360.33203125),
    Vector3.new(-2076.938720703125, -18.637426376342773, 11351.5859375),
}
task.spawn(function()
 while alive() and not closed do
  if state.candyFarm then
   for i,pos in ipairs(halloweenHousePositions) do
    if not state.candyFarm then break end
    local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp.CFrame=CFrame.new(pos) end) end
    for _=1,50 do if not state.candyFarm then break end; task.wait(.1) end
   end
  else task.wait(.25) end
 end
end)

task.spawn(function()
 while alive() and not closed do
  if state.antiAfk and not antiBusy then
   antiBusy=true; pcall(function() VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.W,false,game); task.wait(.12); VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.W,false,game) end); antiBusy=false
  end
  for _=1,100 do if not alive() then break end; task.wait(.1) end
 end
end)
log("GUI loaded. Enable Haunted Night AI and potion toggles as desired.")
