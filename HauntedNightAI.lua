-- HauntedNightAI.lua
-- Starts ONLY after the "Haunted Night has started" notification.
-- Uses Haunted Potion once, rolls Pumpkin Dice x1, and stops at 1s/countdown disappearance.
-- Separate file; does not modify Dice.lua.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
    warn("[HauntedNightAI] LocalPlayer tidak ditemukan.")
    return
end

local CONFIG = {
    ScanInterval = 0.2,
    RollInterval = 1.0,
    CountdownGracePeriod = 15,
    UsePotion = true,
    Debug = true,
}

local network = ReplicatedStorage:WaitForChild("Network")
local pumpkinRoll = network:WaitForChild("PumpkinDiceService"):WaitForChild("RF"):WaitForChild("Roll")
local boostUse = network:WaitForChild("BoostService"):WaitForChild("RE"):WaitForChild("Use")

local eventActive = false
local countdownSeen = false
local eventStartedAt = 0
local potionUsedThisEvent = false
local lastRollAt = 0
local lastSeenNotification = ""

local function log(...)
    if CONFIG.Debug then
        print("[HauntedNightAI]", ...)
    end
end

local function isHauntedStartMessage(value)
    if type(value) ~= "string" then
        return false
    end
    local normalized = string.lower(value)
    return normalized:find("haunted night has started", 1, true) ~= nil
end

local function beginEvent(message)
    if eventActive then
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

local function inspectTextObject(obj, checkInitialText)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return
    end

    local function checkText()
        local value = obj.Text
        if isHauntedStartMessage(value) and value ~= lastSeenNotification then
            beginEvent(value)
        elseif isHauntedStartMessage(value) and not eventActive then
            -- Allows a fresh notification clone with the same message text.
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

    -- Existing template labels are watched for text changes, but not scanned at startup
    -- to avoid treating a template's default text as a new event.
    for _, obj in ipairs(textNotifications:GetDescendants()) do
        inspectTextObject(obj, false)
    end

    textNotifications.DescendantAdded:Connect(function(obj)
        inspectTextObject(obj, true)
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

task.spawn(connectNotificationWatcher)
log("Aktif. Menunggu notifikasi Haunted Night has started...")

while true do
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
            log("Countdown tidak muncul setelah notifikasi; event dibatalkan untuk menghindari roll yang salah.")
            eventActive = false
            countdownSeen = false
            potionUsedThisEvent = false
            lastRollAt = 0
        end
    end

    task.wait(CONFIG.ScanInterval)
end
