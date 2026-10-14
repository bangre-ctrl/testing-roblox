local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

for _, gui in ipairs(playerGui:GetChildren()) do
    if gui.Name == "DiceGachaHub" then
        gui:Destroy()
    end
end

print("Dice Hub lama dibersihkan")
