--madebyTherobloxscripter19!(on yt)
--// Services
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local mouse = Players.LocalPlayer:GetMouse()

--// Variables
local player = Players.LocalPlayer
local cameraLockEnabled = false
local silentAimEnabled = true
local triggerBotEnabled = false
local lockedTarget = nil
local smoothingFactor = 0.1
local prediction = 0.115
local aimPart = "Head"  -- Aim for the head
local predictionOffset = 0.1  -- Used for predicting target movement

--// GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

--// Create Loading Screen
local loadingFrame = Instance.new("Frame")
loadingFrame.Parent = screenGui
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingFrame.Position = UDim2.new(0, 0, 0, 0)
loadingFrame.Visible = true

local loadingText = Instance.new("TextLabel")
loadingText.Parent = loadingFrame
loadingText.Size = UDim2.new(1, 0, 0.1, 0)
loadingText.Position = UDim2.new(0, 0, 0.45, 0)
loadingText.Text = "Loading... Please Wait"
loadingText.TextColor3 = Color3.fromRGB(0, 255, 0)
loadingText.TextSize = 36
loadingText.Font = Enum.Font.SourceSansBold
loadingText.TextTransparency = 0

-- Create Loading Animation
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
local tween = TweenService:Create(loadingText, tweenInfo, {TextTransparency = 0.8})
tween:Play()

--// Simulate Loading Time
wait(3)  -- Customize wait time as needed

--// Hide Loading Screen and Show Main GUI
loadingFrame.Visible = false

--// Create GUI Buttons
local toggleButton = Instance.new("TextButton")
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 200, 0, 60)
toggleButton.Position = UDim2.new(0.85, 0, 0.1, 0)
toggleButton.Text = "Lock Off"
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 24

-- Silent Aim Toggle
local silentAimButton = Instance.new("TextButton")
silentAimButton.Parent = screenGui
silentAimButton.Size = UDim2.new(0, 200, 0, 60)
silentAimButton.Position = UDim2.new(0.85, 0, 0.2, 0)
silentAimButton.Text = "Silent Aim On"
silentAimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
silentAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimButton.Font = Enum.Font.SourceSansBold
silentAimButton.TextSize = 24

-- Trigger Bot Toggle
local triggerBotButton = Instance.new("TextButton")
triggerBotButton.Parent = screenGui
triggerBotButton.Size = UDim2.new(0, 200, 0, 60)
triggerBotButton.Position = UDim2.new(0.85, 0, 0.3, 0)
triggerBotButton.Text = "Trigger Off"
triggerBotButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
triggerBotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerBotButton.Font = Enum.Font.SourceSansBold
triggerBotButton.TextSize = 24

--// Advanced Target Prediction
local function predictTargetPosition(target, predictionOffset)
    local targetVel = target.HumanoidRootPart.Velocity
    return target.HumanoidRootPart.Position + (targetVel * predictionOffset)
end

--// Smooth Camera Lock with Advanced Rotation
local function smoothCameraLock(targetPos)
    local cameraCFrame = Camera.CFrame
    local desiredCFrame = CFrame.new(cameraCFrame.Position, targetPos)
    local smoothedCFrame = cameraCFrame:Lerp(desiredCFrame, smoothingFactor)
    Camera.CFrame = smoothedCFrame
end

--// Get Closest Target
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = p.Character.HumanoidRootPart.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
            if onScreen and distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = p
            end
        end
    end
    return closestPlayer
end

--// Camera Lock with Target Prediction
RunService.RenderStepped:Connect(function()
    if cameraLockEnabled then
        if not lockedTarget or not lockedTarget.Character or not lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            lockedTarget = getClosestPlayer()
        end
        if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local predictedPos = predictTargetPosition(lockedTarget.Character, predictionOffset)
            smoothCameraLock(predictedPos)
        end
    end
end)

--// Silent Aim with Advanced Prediction
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index

mt.__index = function(t, k)
    if k == "Hit" and silentAimEnabled and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild(aimPart) then
        local targetPos = lockedTarget.Character[aimPart].Position
        local predictedPos = targetPos + (lockedTarget.Character.HumanoidRootPart.Velocity * prediction)
        return predictedPos
    end
    return oldIndex(t, k)
end

--// Trigger Bot with Delay
local function triggerBot()
    if triggerBotEnabled and mouse.Target and mouse.Target.Parent and mouse.Target.Parent:FindFirstChild("Humanoid") then
        local targetPlayer = Players:GetPlayerFromCharacter(mouse.Target.Parent)
        if targetPlayer and targetPlayer ~= player then
            mouse1click()  -- Trigger the shot automatically
        end
    end
end

mouse.Button1Down:Connect(triggerBot)

--// Matrix Effect on Button Press
local function applyMatrixEffects()
    game:GetService("Lighting").TimeOfDay = "20:00:00"
    game:GetService("Lighting").Brightness = 0.3
    game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(0, 0, 0)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://12345678"  -- Example sound, replace with Matrix-like sound
    sound.Parent = workspace
    sound:Play()
end

--// Button Event Handlers
toggleButton.MouseButton1Click:Connect(function()
    cameraLockEnabled = not cameraLockEnabled
    toggleButton.Text = cameraLockEnabled and "Lock On" or "Lock Off"
    toggleButton.BackgroundColor3 = cameraLockEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

silentAimButton.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    silentAimButton.Text = silentAimEnabled and "Silent Aim On" or "Silent Aim Off"
    silentAimButton.BackgroundColor3 = silentAimEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

triggerBotButton.MouseButton1Click:Connect(function()
    triggerBotEnabled = not triggerBotEnabled
    triggerBotButton.Text = triggerBotEnabled and "Trigger On" or "Trigger Off"
    triggerBotButton.BackgroundColor3 = triggerBotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    if triggerBotEnabled then
        applyMatrixEffects()
    end
end)

--// Advanced Matrix Loading Effect
local function advancedMatrixLoading()
    loadingText.Text = "Matrix System Initializing"
    tween:Play()
    wait(2)  -- Hold the Matrix theme
    loadingFrame.Visible = false
end

advancedMatrixLoading()
