-- HauntedNightAI.lua
-- Starts ONLY after the "Haunted Night has started" notification.
-- Uses Haunted Potion once, rolls Pumpkin Dice x1, and stops at countdown end.
-- Includes a standalone Anti-AFK loop based on Dice.lua (W tap every 10s).
-- Does not modify or load Dice.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
if not player then
    warn("[HauntedNightAI] LocalPlayer tidak ditemukan.")
    return
end

local CONFIG = {
    ScanInterval = 0.2,
    RollInterval = 1.0,
    CountdownGracePeriod = 15,
    AntiAFKInterval = 10,
    AntiAFKKeyHold = 0.12,
    UsePotion = true,
    AntiAFK = true,
    Debug = true,
}

-- Invalidate loops from an older HauntedNightAI execution.
shared.__HauntedNightAIRunId = (shared.__HauntedNightAIRunId or 0) + 1
local thisRunId = shared.__HauntedNightAIRunId
local stopped = false

local network = ReplicatedStorage:WaitForChild("Network")
local pumpkinRoll = network:WaitForChild("PumpkinDiceService"):WaitForChild("RF"):WaitForChild("Roll")
local boostUse = network:WaitForChild("BoostService"):WaitForChild("RE"):WaitForChild("Use")

local eventActive = false
local countdownSeen = false
local eventStartedAt = 0
local potionUsedThisEvent = false
local lastRollAt = 0
local lastSeenNotification = ""
local antiAfkBusy = false

local function log(...)
    if CONFIG.Debug then
        print("[HauntedNightAI]", ...)
    end
end

local function isCurrentRun()
    return not stopped and shared.__HauntedNightAIRunId == thisRunId
end

local function isHauntedStartMessage(value)
    if type(value) ~= "string" then
        return false
    end
    return string.lower(value):find("haunted night has started", 1, true) ~= nil
end

local function beginEvent(message)
    if eventActive or not isCurrentRun() then
        return
    end

    eventActive = true
    countdownSeen = false
    eventStartedAt = os.clock()
    potionUsedThisEvent = false
    lastRollAt = 0
    lastSeenNotification = message or ""

    log("Notifikasi Haunted Night terdeteksi:", message or "(teks tidak tersedia)")

    if CONFIG.UsePotion and not potionUsedThisEvent then
        potionUsedThisEvent = true
        local ok, err = pcall(function()
            boostUse:FireServer("Haunted Potion")
        end)
        if ok then
            log("Haunted Potion digunakan.")
        else
            warn("[HauntedNightAI] Gagal menggunakan Haunted Potion:", err)
        end
    end
end

local function watchTextObject(obj, checkInitialText)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return
    end

    local function checkText()
        if not isCurrentRun() then
            return
        end
        local value = obj.Text
        if isHauntedStartMessage(value) and not eventActive then
            beginEvent(value)
        end
    end

    obj:GetPropertyChangedSignal("Text"):Connect(checkText)
    if checkInitialText then
        checkText()
    end
end

local function connectNotificationWatcher()
    local playerGui = player:WaitForChild("PlayerGui")
    local root = playerGui:WaitForChild("Root", 15)
    local notifications = root and root:WaitForChild("Notifications", 15)
    local textNotifications = notifications and notifications:WaitForChild("TextNotifications", 15)

    if not textNotifications then
        warn("[HauntedNightAI] UI Notifications.TextNotifications tidak ditemukan.")
        return
    end

    -- Watch existing text elements for future text changes; don't trigger from
    -- a template's initial/default text at startup.
    for _, obj in ipairs(textNotifications:GetDescendants()) do
        watchTextObject(obj, false)
    end

    textNotifications.DescendantAdded:Connect(function(obj)
        watchTextObject(obj, true)
    end)

    log("Pemantau notifikasi aktif.")
end

local function getWeatherCountdownLabel()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    local root = playerGui and playerGui:FindFirstChild("Root")
    local menus = root and root:FindFirstChild("Menus")
    local boosts = menus and menus:FindFirstChild("Boosts")
    local content = boosts and boosts:FindFirstChild("Content")
    local scrolling = content and content:FindFirstChild("ScrollingFrame")
    local weatherEvent = scrolling and scrolling:FindFirstChild("__WeatherEvent")
    local label = weatherEvent and weatherEvent:FindFirstChild("TextLabel")

    if label and label:IsA("TextLabel") then
        return label
    end
    return nil
end

local function parseCountdown(value)
    if type(value) ~= "string" then
        return nil
    end

    local minutes = tonumber(value:match("(%d+)%s*m"))
    local seconds = tonumber(value:match("(%d+)%s*s"))
    if minutes or seconds then
        return (minutes or 0) * 60 + (seconds or 0)
    end

    return tonumber(value:match("^%s*(%d+)%s*$"))
end

local function rollPumpkinDiceX1()
    local ok, err = pcall(function()
        pumpkinRoll:InvokeServer(1)
    end)
    if not ok then
        warn("[HauntedNightAI] Roll Pumpkin Dice x1 gagal:", err)
    else
        log("Pumpkin Dice x1")
    end
end

-- Standalone Anti-AFK copied in behavior from Dice.lua:
-- send a short W key tap every 10 seconds, with safe key release.
task.spawn(function()
    if not CONFIG.AntiAFK then
        return
    end

    log("Anti-AFK aktif (tap W setiap " .. tostring(CONFIG.AntiAFKInterval) .. " detik).")

    while isCurrentRun() do
        if not antiAfkBusy then
            antiAfkBusy = true
            local ok, err = pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(CONFIG.AntiAFKKeyHold)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
            if not ok then
                warn("[HauntedNightAI] Anti-AFK gagal:", err)
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                end)
            end
            antiAfkBusy = false
        end

        for _ = 1, CONFIG.AntiAFKInterval * 10 do
            if not isCurrentRun() then
                break
            end
            task.wait(0.1)
        end
    end
end)

task.spawn(connectNotificationWatcher)
log("Aktif. Menunggu notifikasi Haunted Night has started...")

while isCurrentRun() do
    if eventActive then
        local label = getWeatherCountdownLabel()
        local secondsLeft = label and parseCountdown(label.Text) or nil

        if secondsLeft and secondsLeft > 1 then
            countdownSeen = true
            if os.clock() - lastRollAt >= CONFIG.RollInterval then
                lastRollAt = os.clock()
                rollPumpkinDiceX1()
            end
        elseif countdownSeen then
            log("Countdown mencapai 1s atau hilang. Roll dihentikan.")
            eventActive = false
            countdownSeen = false
            potionUsedThisEvent = false
            lastRollAt = 0
        elseif os.clock() - eventStartedAt > CONFIG.CountdownGracePeriod then
            log("Countdown tidak muncul setelah notifikasi; event dibatalkan agar tidak roll pada weather lain.")
            eventActive = false
            countdownSeen = false
            potionUsedThisEvent = false
            lastRollAt = 0
        end
    end

    task.wait(CONFIG.ScanInterval)
end
