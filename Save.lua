--========================================================
-- Save.lua | Dice Hub - Quirk UUID Manager
-- Standalone GUI for Delta / compatible executors
--========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local FILE = "DiceQuirkUUIDs.json"

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("SaveQuirkUUIDGui")
if oldGui then oldGui:Destroy() end

local savedUUIDs = { Prodigy = {}, FortuneFavor = {}, MidasTouch = {} }
local lastDetectedUUID = nil
local scannerEnabled = false
local hookInstalled = false
local oldNamecall = nil

local function normalizeList(list)
    local result, seen = {}, {}
    if type(list) ~= "table" then return result end
    for _, uuid in ipairs(list) do
        if type(uuid) == "string" and uuid ~= "" and not seen[uuid] then
            seen[uuid] = true
            table.insert(result, uuid)
        end
    end
    return result
end

local function saveToFile()
    if type(writefile) ~= "function" then return false, "writefile is unavailable" end
    local ok, err = pcall(function() writefile(FILE, HttpService:JSONEncode(savedUUIDs)) end)
    return ok, err
end

local function loadFromFile()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return false, "isfile/readfile is unavailable" end
    if not isfile(FILE) then return true, "No save file yet" end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE)) end)
    if not ok or type(decoded) ~= "table" then return false, "Could not decode " .. FILE end
    savedUUIDs.Prodigy = normalizeList(decoded.Prodigy)
    savedUUIDs.FortuneFavor = normalizeList(decoded.FortuneFavor)
    savedUUIDs.MidasTouch = normalizeList(decoded.MidasTouch)
    return true, "Loaded saved UUIDs"
end

local gui = Instance.new("ScreenGui")
gui.Name = "SaveQuirkUUIDGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(300, 402)
main.Position = UDim2.new(0.5, -150, 0.5, -201)
main.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(75, 82, 110)
stroke.Thickness = 1
local titleBar = Instance.new("TextButton")
titleBar.Name = "Title"
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(42, 46, 62)
titleBar.BorderSizePixel = 0
titleBar.Text = "SAVE.LUA  |  QUIRK UUIDS"
titleBar.TextColor3 = Color3.fromRGB(245, 245, 255)
titleBar.TextSize = 14
titleBar.Font = Enum.Font.GothamBold
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromOffset(12, 45)
status.Size = UDim2.new(1, -24, 0, 38)
status.BackgroundTransparency = 1
status.Text = "Scanner: OFF\nUUID terakhir: belum ada"
status.TextColor3 = Color3.fromRGB(190, 200, 220)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main
local function makeButton(name, text, y, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.fromOffset(12, y)
    button.Size = UDim2.new(1, -24, 0, 34)
    button.BackgroundColor3 = color or Color3.fromRGB(68, 83, 135)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamSemibold
    button.Parent = main
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end
local counts = Instance.new("TextLabel")
counts.Name = "Counts"
counts.Position = UDim2.fromOffset(12, 88)
counts.Size = UDim2.new(1, -24, 0, 25)
counts.BackgroundTransparency = 1
counts.Text = "Prodigy: 0  |  Fortune: 0  |  Midas: 0"
counts.TextColor3 = Color3.fromRGB(180, 220, 255)
counts.TextSize = 10
counts.Font = Enum.Font.Gotham
counts.Parent = main
local scanButton = makeButton("ScanToggle", "START SCANNER", 118, Color3.fromRGB(54, 125, 96))
local saveProdigy = makeButton("SaveProdigy", "SAVE UUID — PRODIGY", 160)
local saveFortune = makeButton("SaveFortune", "SAVE UUID — FORTUNE'S FAVOR", 202)
local saveMidas = makeButton("SaveMidas", "SAVE UUID — MIDAS TOUCH", 244)
local autoProdigyButton = makeButton("AutoEquipProdigy", "AUTO EQUIP PRODIGY", 286, Color3.fromRGB(126, 91, 54))
local loadButton = makeButton("Load", "LOAD SAVED UUIDS", 328, Color3.fromRGB(83, 91, 108))
local closeButton = makeButton("Close", "CLOSE GUI", 370, Color3.fromRGB(130, 62, 70))
local autoEquipRunning = false
local function updateUI(message)
    status.Text = ("Scanner: %s\nUUID terakhir: %s"):format(scannerEnabled and "ON" or "OFF", lastDetectedUUID or "belum ada")
    counts.Text = ("Prodigy: %d  |  Fortune: %d  |  Midas: %d"):format(#savedUUIDs.Prodigy, #savedUUIDs.FortuneFavor, #savedUUIDs.MidasTouch)
    if message then print("[Save.lua] " .. message) end
end
local function saveSelectedQuirk(key, label)
    if not lastDetectedUUID then updateUI("Save batal: equip unit manual dulu agar UUID tertangkap."); return end
    local list = savedUUIDs[key]
    for _, uuid in ipairs(list) do if uuid == lastDetectedUUID then updateUI("UUID ini sudah ada di daftar " .. label .. "."); return end end
    table.insert(list, lastDetectedUUID)
    local ok, err = saveToFile()
    if not ok then table.remove(list); updateUI("Save gagal: " .. tostring(err)); return end
    local saved = lastDetectedUUID
    lastDetectedUUID = nil
    updateUI("UUID disimpan untuk " .. label .. ": " .. saved)
end
local function installScanner()
    if hookInstalled then return true end
    local equipRemote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("UnitService"):WaitForChild("RF"):WaitForChild("Equip")
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" or type(newcclosure) ~= "function" then return false, "Hook functions unavailable" end
    if _G.SaveLuaQuirkScannerInstalled then return false, "Scanner hook already installed in this executor session; restart executor before reinstalling." end
    _G.SaveLuaQuirkScannerInstalled = true
    local ok, result = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if scannerEnabled and self == equipRemote and method == "InvokeServer" then
                local args = {...}
                if type(args[1]) == "string" then lastDetectedUUID = args[1]; updateUI("UUID terdeteksi: " .. args[1]) end
            end
            return oldNamecall(self, ...)
        end))
    end)
    if not ok then _G.SaveLuaQuirkScannerInstalled = nil; return false, tostring(result) end
    hookInstalled = true
    return true
end
scanButton.MouseButton1Click:Connect(function()
    if not hookInstalled then local ok, err = installScanner(); if not ok then updateUI("Scanner gagal dipasang: " .. tostring(err)); return end end
    scannerEnabled = not scannerEnabled
    scanButton.Text = scannerEnabled and "STOP SCANNER" or "START SCANNER"
    scanButton.BackgroundColor3 = scannerEnabled and Color3.fromRGB(150, 85, 55) or Color3.fromRGB(54, 125, 96)
    updateUI(scannerEnabled and "Scanner aktif. Equip unit manual sekarang." or "Scanner dijeda.")
end)
saveProdigy.MouseButton1Click:Connect(function() saveSelectedQuirk("Prodigy", "Prodigy") end)
saveFortune.MouseButton1Click:Connect(function() saveSelectedQuirk("FortuneFavor", "Fortune's Favor") end)
saveMidas.MouseButton1Click:Connect(function() saveSelectedQuirk("MidasTouch", "Midas Touch") end)
autoProdigyButton.MouseButton1Click:Connect(function()
    if autoEquipRunning then
        updateUI("Auto equip masih berjalan.")
        return
    end
    if #savedUUIDs.Prodigy == 0 then
        updateUI("Daftar Prodigy kosong. Tekan LOAD SAVED UUIDS dulu.")
        return
    end

    local network = ReplicatedStorage:WaitForChild("Network")
    local equipRemote = network:WaitForChild("UnitService"):WaitForChild("RF"):WaitForChild("Equip")
    local interactSlotRemote = network:WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("InteractSlot")

    autoEquipRunning = true
    autoProdigyButton.Text = "EQUIPPING TO PODIUM..."
    task.spawn(function()
        local total = math.min(#savedUUIDs.Prodigy, 18)
        local completed = 0
        for index = 1, total do
            if not gui.Parent then break end
            local uuid = savedUUIDs.Prodigy[index]
            local equipped, equipErr = pcall(function()
                return equipRemote:InvokeServer(uuid)
            end)
            if equipped then
                task.wait(0.5)
                local placed, slotErr = pcall(function()
                    interactSlotRemote:FireServer(index)
                end)
                if placed then
                    completed += 1
                    updateUI(("Prodigy %d/%d dipasang ke podium"):format(index, total))
                else
                    updateUI(("Gagal pasang UUID %d ke podium: %s"):format(index, tostring(slotErr)))
                end
            else
                updateUI(("Equip gagal pada UUID %d: %s"):format(index, tostring(equipErr)))
            end
            if index < total then task.wait(0.5) end
        end
        autoEquipRunning = false
        if autoProdigyButton.Parent then autoProdigyButton.Text = "AUTO EQUIP PRODIGY" end
        updateUI(("Selesai. Request podium berhasil: %d/%d"):format(completed, total))
    end)
end)
loadButton.MouseButton1Click:Connect(function() local ok, message = loadFromFile(); updateUI(ok and message or ("Load gagal: " .. tostring(message))) end)
closeButton.MouseButton1Click:Connect(function() scannerEnabled = false; gui:Destroy() end)
do
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = main.Position end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
local ok, message = loadFromFile()
updateUI(ok and message or ("Load warning: " .. tostring(message)))
print("[Save.lua] GUI loaded. Click START SCANNER, equip a unit, then click the matching Save button.")