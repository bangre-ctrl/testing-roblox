-- Grade Hub Standalone
-- GUI prototype: grade toggles + Start/Stop
-- Auto-roll cycles through podium slots 1 and 2 using the shared grade toggles.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local grades = {
    {name = "D",  color = Color3.fromRGB(175, 175, 175)},
    {name = "C",  color = Color3.fromRGB(60, 255, 20)},
    {name = "B",  color = Color3.fromRGB(45, 145, 255)},
    {name = "A",  color = Color3.fromRGB(145, 20, 255)},
    {name = "A+", color = Color3.fromRGB(255, 190, 20)},
    {name = "S",  color = Color3.fromRGB(255, 45, 45)},
    {name = "S+", color = Color3.fromRGB(40, 60, 255)},
    {name = "Z",  color = Color3.fromRGB(40, 255, 190)},
    {name = "Z+", color = Color3.fromRGB(255, 50, 180)},
    {name = "神", color = Color3.fromRGB(255, 45, 35)},
    {name = "∞",  color = Color3.fromRGB(150, 255, 110)},
    {name = "Ω",  color = Color3.fromRGB(205, 145, 255)},
}

local enabled = {}
for _, grade in ipairs(grades) do
    enabled[grade.name] = false
end

local old = playerGui:FindFirstChild("GradeHubStandalone")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GradeHubStandalone"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(430, 390)
main.Position = UDim2.new(0.5, -215, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(25, 27, 32)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(85, 90, 100)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 38)
title.Position = UDim2.fromOffset(12, 4)
title.BackgroundTransparency = 1
title.Text = "GRADE HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

-- Drag the window by holding the title bar.
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput
local dragStart
local startPosition

title.Active = true
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(30, 30)
minimize.Position = UDim2.new(1, -72, 0, 7)
minimize.Text = "_"
minimize.TextSize = 22
minimize.ZIndex = 5
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.BackgroundColor3 = Color3.fromRGB(65, 75, 95)
minimize.Parent = main
minimize.Visible = true
minimize.Active = true
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -36, 0, 7)
close.Text = "X"
close.TextSize = 16
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(160, 45, 45)
close.Parent = main
close.ZIndex = 5
close.Visible = true
close.Active = true
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize hides the panel but leaves a small restore button.
local restore = Instance.new("TextButton")
restore.Name = "RestoreGradeHub"
restore.Size = UDim2.fromOffset(118, 34)
restore.Position = UDim2.new(0, 18, 0.5, -17)
restore.Text = "GRADE HUB  +"
restore.TextSize = 13
restore.Font = Enum.Font.GothamBold
restore.TextColor3 = Color3.new(1, 1, 1)
restore.BackgroundColor3 = Color3.fromRGB(35, 145, 70)
restore.Visible = false
restore.Parent = gui
Instance.new("UICorner", restore).CornerRadius = UDim.new(0, 8)

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    restore.Visible = true
end)

restore.MouseButton1Click:Connect(function()
    main.Visible = true
    restore.Visible = false
end)

local grid = Instance.new("Frame")
grid.Position = UDim2.fromOffset(12, 47)
grid.Size = UDim2.new(1, -24, 0, 220)
grid.BackgroundTransparency = 1
grid.Parent = main

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(1/3, -6, 0, 49)
layout.CellPadding = UDim2.fromOffset(6, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(12, 273)
status.Size = UDim2.new(1, -24, 0, 24)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(205, 205, 215)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Parent = main

local running = false
local cycleToken = 0

-- Podium slot UUIDs supplied by the user.
local targetUnits = {
    {slot = "1", uuid = "15055a2b-ba16-487d-b26e-950b2ab3401e"},
    {slot = "2", uuid = "23cd0f57-a5a2-4765-a0ab-1cc57613e375"},
}

local function getGradeRemotes()
    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local gradeService = network:WaitForChild("GradeService")
    local re = gradeService:WaitForChild("RE")
    return re:WaitForChild("Roll")
end

local function getCurrentGrade()
    local root = playerGui:FindFirstChild("Root")
    local menus = root and root:FindFirstChild("Menus")
    local gradeMenu = menus and menus:FindFirstChild("Grades")
    local display = gradeMenu and gradeMenu:FindFirstChild("GradeDisplay")
    local label = display and display:FindFirstChild("Grade")
    if label and label:IsA("TextLabel") then
        return label.Text
    end
    return nil
end

local function clickDialogChoice(dialog, choiceName)
    local options = dialog:FindFirstChild("Options")
    local button = options and options:FindFirstChild(choiceName)
    if button and button:IsA("GuiButton") and button.Visible and button.Active then
        button:Activate()
        return true
    end
    return false
end

local function waitUntil(predicate, timeout, token)
    local started = os.clock()
    while os.clock() - started < timeout do
        if not running or cycleToken ~= token then
            return false
        end
        local ok, result = pcall(predicate)
        if ok and result then return result end
        task.wait(0.1)
    end
    return false
end

local function refreshButton(button, grade)
    if enabled[grade.name] then
        button.BackgroundColor3 = Color3.fromRGB(45, 105, 45)
        button.TextColor3 = grade.color
    else
        button.BackgroundColor3 = Color3.fromRGB(35, 36, 41)
        button.TextColor3 = grade.color
    end
end

for index, grade in ipairs(grades) do
    local button = Instance.new("TextButton")
    button.Name = "Grade_" .. grade.name
    button.LayoutOrder = index
    button.Text = grade.name
    button.TextSize = 29
    button.Font = Enum.Font.GothamBlack
    button.AutoButtonColor = true
    button.BackgroundColor3 = Color3.fromRGB(35, 36, 41)
    button.TextColor3 = grade.color
    button.Parent = grid

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

    local outline = Instance.new("UIStroke")
    outline.Color = grade.color
    outline.Thickness = 2
    outline.Parent = button

    button.MouseButton1Click:Connect(function()
        enabled[grade.name] = not enabled[grade.name]
        refreshButton(button, grade)

        -- Sync the selected grade protection setting with the game.
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Network")
                :WaitForChild("GradeService")
                :WaitForChild("RE")
                :WaitForChild("SetGradeProtected")
                :FireServer(grade.name, enabled[grade.name])
        end)

        if success then
            status.Text = "Status: " .. grade.name .. (enabled[grade.name] and " ON" or " OFF")
        else
            status.Text = "Status: Gagal mengubah " .. grade.name
            warn("[Grade Hub] SetGradeProtected error:", err)
        end
    end)
end

local start = Instance.new("TextButton")
start.Position = UDim2.fromOffset(12, 308)
start.Size = UDim2.new(0.5, -15, 0, 38)
start.Text = "AUTO ROLL"
start.Font = Enum.Font.GothamBold
start.TextSize = 14
start.TextColor3 = Color3.new(1, 1, 1)
start.BackgroundColor3 = Color3.fromRGB(35, 145, 70)
start.Parent = main
Instance.new("UICorner", start).CornerRadius = UDim.new(0, 8)

local stop = Instance.new("TextButton")
stop.Position = UDim2.new(0.5, 3, 0, 308)
stop.Size = UDim2.new(0.5, -15, 0, 38)
stop.Text = "STOP"
stop.Font = Enum.Font.GothamBold
stop.TextSize = 14
stop.TextColor3 = Color3.new(1, 1, 1)
stop.BackgroundColor3 = Color3.fromRGB(165, 45, 45)
stop.Parent = main
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 8)

start.MouseButton1Click:Connect(function()
    if running then return end

    local selected = 0
    for _, grade in ipairs(grades) do
        if enabled[grade.name] then
            selected += 1
        end
    end

    if selected == 0 then
        status.Text = "Status: Aktifkan minimal 1 grade!"
        return
    end

    running = true
    cycleToken += 1
    local token = cycleToken
    status.Text = "Status: Auto Roll aktif — Slot 1"
    task.spawn(function()
        local ok, rollRemote = pcall(getGradeRemotes)
        if not ok then
            running = false
            status.Text = "Status: Remote Roll tidak ditemukan"
            warn("[Grade Hub] Remote Roll error:", rollRemote)
            return
        end

        local root = playerGui:WaitForChild("Root")
        local gradeMenu = root:WaitForChild("Menus"):WaitForChild("Grades")
        local dialog = gradeMenu:WaitForChild("ConfirmGrade")
        local display = gradeMenu:WaitForChild("GradeDisplay")
        local gradeLabel = display:WaitForChild("Grade")

        local targetIndex = 1
        while running and cycleToken == token do
            local target = targetUnits[targetIndex]
            status.Text = "Status: Roll Slot " .. target.slot

            -- Wait for any previous confirmation to close before sending another roll.
            local closed = waitUntil(function()
                return not dialog.Visible
            end, 20, token)
            if not closed then
                if running and cycleToken == token then
                    status.Text = "Status: Dialog belum tertutup — dihentikan"
                    running = false
                end
                break
            end

            local beforeGrade = gradeLabel.Text
            local sent, sendErr = pcall(function()
                rollRemote:FireServer(target.uuid)
            end)
            if not sent then
                status.Text = "Status: Roll gagal"
                warn("[Grade Hub] Roll error:", sendErr)
                running = false
                break
            end

            -- Wait for the confirmation dialog or a grade change.
            local result = waitUntil(function()
                if dialog.Visible then return "dialog" end
                if gradeLabel.Text ~= beforeGrade then return "grade" end
                return false
            end, 15, token)

            if not result then
                if running and cycleToken == token then
                    status.Text = "Status: Hasil tidak terdeteksi — dihentikan"
                    running = false
                end
                break
            end

            local resultGrade = gradeLabel.Text
            if result == "dialog" then
                -- The game's displayed grade is the result currently awaiting Keep/Skip.
                resultGrade = gradeLabel.Text
                local keep = enabled[resultGrade] == true
                local choice = keep and "Keep" or "Skip"
                local clicked = clickDialogChoice(dialog, choice)
                if not clicked then
                    status.Text = "Status: Tombol " .. choice .. " tidak aktif — dihentikan"
                    running = false
                    break
                end

                status.Text = "Status: Slot " .. target.slot .. " grade " .. resultGrade .. " → " .. choice

                if keep then
                    -- Target grade reached for this slot; move to the other unit.
                    targetIndex = (targetIndex % #targetUnits) + 1
                    task.wait(0.5)
                else
                    -- Give the game time to process Skip before rerolling the same unit.
                    local closedAfterSkip = waitUntil(function()
                        return not dialog.Visible
                    end, 15, token)
                    if not closedAfterSkip then
                        status.Text = "Status: Dialog Skip tidak tertutup — dihentikan"
                        running = false
                        break
                    end
                    task.wait(0.35)
                end
            else
                -- Some game versions update the grade without opening a confirmation dialog.
                status.Text = "Status: Grade berubah ke " .. resultGrade .. " tanpa dialog"
                task.wait(0.5)
            end
        end
    end)
end)

stop.MouseButton1Click:Connect(function()
    running = false
    cycleToken += 1
    status.Text = "Status: Stopped"
end)
