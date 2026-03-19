loadstring(game:HttpGet('https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/webhook.txt'))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local correctKey = "Winter"

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
gui.Name = "DK_HUB_GUI"
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
prem.Text = "Don’t want to wait? Purchase Premium!"
prem.TextColor3 = Color3.fromRGB(255, 255, 255)
prem.TextSize = 14
prem.Font = Enum.Font.GothamSemibold
prem.Parent = frame
prem.MouseEnter:Connect(function() prem.TextColor3 = Color3.fromRGB(0, 255, 0) end)
prem.MouseLeave:Connect(function() prem.TextColor3 = Color3.fromRGB(255, 255, 255) end)

local function typeTitle(t, s)
    s = s or 0.1
    title.Text = ""
    for i = 1, #t do
        title.Text = t:sub(1, i)
        task.wait(s)
    end
end

task.spawn(function()
    while true do
        typeTitle("DK's HUB")
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

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -40, 0, 35)
box.Position = UDim2.new(0, 20, 0, 70)
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.PlaceholderText = "Enter your key..."
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = box

local buttonHolder = Instance.new("Frame")
buttonHolder.Size = UDim2.new(1, -40, 0, 35)
buttonHolder.Position = UDim2.new(0, 20, 0, 115)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = frame

local function createButton(text, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.48, 0, 1, 0)
    b.Position = UDim2.new(pos, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextSize = 14
    b.Parent = buttonHolder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = b
    return b
end

local checkBtn = createButton("Check Key", 0)
local getKeyBtn = createButton("Get Key!", 0.52)

getKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/rcb2A7Jc")
        StarterGui:SetCore("SendNotification", {
            Title = "Discord Link Copied!",
            Text = "Head over to the #Key channel to get the key.",
            Duration = 4
        })
    end
end)

local rememberFrame = Instance.new("Frame")
rememberFrame.Size = UDim2.new(1, -40, 0, 25)
rememberFrame.Position = UDim2.new(0, 20, 0, 155)
rememberFrame.BackgroundTransparency = 1
rememberFrame.Parent = frame

local rememberLabel = Instance.new("TextLabel")
rememberLabel.Size = UDim2.new(0.8, 0, 1, 0)
rememberLabel.BackgroundTransparency = 1
rememberLabel.Text = "Remember Key"
rememberLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rememberLabel.Font = Enum.Font.Gotham
rememberLabel.TextSize = 14
rememberLabel.TextXAlignment = Enum.TextXAlignment.Left
rememberLabel.Parent = rememberFrame

local checkbox = Instance.new("Frame")
checkbox.Size = UDim2.new(0, 20, 0, 20)
checkbox.Position = UDim2.new(0.8, 0, 0, 2)
checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
checkbox.Parent = rememberFrame

local checkboxCorner = Instance.new("UICorner")
checkboxCorner.CornerRadius = UDim.new(0, 4)
checkboxCorner.Parent = checkbox

local tick = Instance.new("Frame")
tick.Size = UDim2.new(0, 0, 0, 0)
tick.Position = UDim2.new(0, 2, 0, 2)
tick.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
tick.Parent = checkbox

local tickCorner = Instance.new("UICorner")
tickCorner.CornerRadius = UDim.new(0, 2)
tickCorner.Parent = tick

local checkboxBtn = Instance.new("TextButton")
checkboxBtn.Size = UDim2.new(1, 0, 1, 0)
checkboxBtn.BackgroundTransparency = 1
checkboxBtn.Text = ""
checkboxBtn.Parent = checkbox

local rememberState = false
local savedKey = player:GetAttribute("SavedKey")

if savedKey then
    box.Text = savedKey
    rememberState = true
    tick:TweenSize(UDim2.new(1, -4, 1, -4), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
end

checkboxBtn.MouseButton1Click:Connect(function()
    rememberState = not rememberState
    if rememberState then
        tick:TweenSize(UDim2.new(1, -4, 1, -4), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        tick:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end)

local function checkKey()
    if box.Text ~= correctKey then
        StarterGui:SetCore("SendNotification", {
            Title = "Invalid Key",
            Text = "Please enter the correct key.",
            Duration = 3
        })
        return
    end

    if rememberState then
        player:SetAttribute("SavedKey", box.Text)
    else
        player:SetAttribute("SavedKey", nil)
    end

    local scriptUrl = AllowedGames[game.PlaceId]

    if scriptUrl then
        StarterGui:SetCore("SendNotification", {
            Title = "Key Accepted",
            Text = "Loading script...",
            Duration = 3
        })
        gui:Destroy()
        blur:Destroy()
        loadstring(game:HttpGet(scriptUrl))()
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Wrong Game",
            Text = "This script cannot run here.",
            Duration = 4
        })
    end
end

checkBtn.MouseButton1Click:Connect(checkKey)
