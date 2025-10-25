--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local PetsService = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetsService")

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoPetTeamUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Position = UDim2.new(0.5, -150, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Auto Pet Team"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local GetButton = Instance.new("TextButton", Frame)
GetButton.Position = UDim2.new(0.1, 0, 0.2, 0)
GetButton.Size = UDim2.new(0.8, 0, 0, 35)
GetButton.Text = "Get All Pet IDs"
GetButton.Font = Enum.Font.SourceSansBold
GetButton.TextSize = 20
GetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GetButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local StatusText = Instance.new("TextLabel", Frame)
StatusText.Position = UDim2.new(0, 0, 0.35, 0)
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Status: Not Ready"
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusText.TextSize = 18
StatusText.Font = Enum.Font.SourceSans

local DelayLabel = Instance.new("TextLabel", Frame)
DelayLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
DelayLabel.Size = UDim2.new(0.8, 0, 0, 20)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Loop Delay (seconds):"
DelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayLabel.TextSize = 18
DelayLabel.Font = Enum.Font.SourceSans

local DelayBox = Instance.new("TextBox", Frame)
DelayBox.Position = UDim2.new(0.1, 0, 0.52, 0)
DelayBox.Size = UDim2.new(0.8, 0, 0, 30)
DelayBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.Text = "7" -- Default delay
DelayBox.TextSize = 18
DelayBox.Font = Enum.Font.SourceSans
DelayBox.ClearTextOnFocus = false

local Toggle = Instance.new("TextButton", Frame)
Toggle.Position = UDim2.new(0.1, 0, 0.65, 0)
Toggle.Size = UDim2.new(0.8, 0, 0, 35)
Toggle.Text = "Auto: OFF"
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 20
Toggle.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)

--// New Button: Clear Bugged Pets
local ClearButton = Instance.new("TextButton", Frame)
ClearButton.Position = UDim2.new(0.1, 0, 0.8, 0)
ClearButton.Size = UDim2.new(0.8, 0, 0, 35)
ClearButton.Text = "Clear Bugged Pets"
ClearButton.Font = Enum.Font.SourceSansBold
ClearButton.TextSize = 20
ClearButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Variables
local petIDs = {}
local autoRunning = false

--// Get All Pet IDs
GetButton.MouseButton1Click:Connect(function()
    petIDs = {}
    for _, pet in ipairs(workspace:WaitForChild("PetsPhysical"):GetChildren()) do
        if pet:GetAttribute("OWNER") == LP.Name then
            local id = pet:GetAttribute("UUID")
            if id then
                table.insert(petIDs, tostring(id))
            end
        end
    end
    if #petIDs > 0 then
        StatusText.Text = "Status: Ready (" .. #petIDs .. " pets)"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusText.Text = "Status: No Pets Found"
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

--// Auto Loop Function
task.spawn(function()
    while task.wait(0.1) do
        if autoRunning and #petIDs > 0 then
            for _, id in ipairs(petIDs) do
                PetsService:FireServer("UnequipPet", id)
            end
            task.wait(0.3)
            for _, id in ipairs(petIDs) do
                PetsService:FireServer("EquipPet", id)
            end
            local delayTime = tonumber(DelayBox.Text) or 7
            task.wait(delayTime)
        end
    end
end)

--// Toggle Button
Toggle.MouseButton1Click:Connect(function()
    autoRunning = not autoRunning
    if autoRunning then
        Toggle.Text = "Auto: ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        Toggle.Text = "Auto: OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    end
end)

--// Clear Bugged Pets Function
local function clearBuggedPets()
    local deleted = 0
    for _, pet in ipairs(workspace:WaitForChild("PetsPhysical"):GetChildren()) do
        local delete = true
        for _, sub in ipairs(pet:GetChildren()) do
            local subChildren = sub:GetChildren()
            if not ((#subChildren == 1 and subChildren[1]:IsA("Weld")) or #subChildren == 0) then
                delete = false
                break
            end
        end
        if delete then
            pet:Destroy()
            deleted += 1
        end
    end
    return deleted
end

--// Button Logic for Clearing Pets
ClearButton.MouseButton1Click:Connect(function()
    ClearButton.Text = "Clearing..."
    ClearButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)

    local count = clearBuggedPets()

    ClearButton.Text = "Clear Success! (" .. count .. ")"
    ClearButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    task.wait(1)

    ClearButton.Text = "Clear Bugged Pets"
    ClearButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)
