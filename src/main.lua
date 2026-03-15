--[[
    Tha Bronx 3 - Synapse-Xenon Premium
    Self-contained UI matching original design
    Compatible with all executors
]]

------------------------------------------------------------
-- Compatibility
------------------------------------------------------------
if not task then
    task = {
        wait = function(t) return wait(t or 0) end,
        spawn = function(f, ...) return coroutine.wrap(f)(...) end,
        defer = function(f, ...) return coroutine.wrap(f)(...) end,
        delay = function(t, f) return delay(t, f) end,
    }
end
if not firetouchinterest then
    firetouchinterest = function(p1, p2, t)
        if t == 0 then local o = p1.CFrame; p1.CFrame = p2.CFrame; task.wait(); p1.CFrame = o end
    end
end
local DrawOK = pcall(function() local _ = Drawing.new("Circle") end)
if not DrawOK then Drawing = Drawing or {}; Drawing.new = Drawing.new or function() return setmetatable({},{__index=function(s,k) return rawget(s,k) end, __newindex=function(s,k,v) rawset(s,k,v) end}) end end
if not isfile then isfile = function() return false end end
if not readfile then readfile = function() return "{}" end end
if not writefile then writefile = function() end end
if not makefolder then makefolder = function() end end
if not isfolder then isfolder = function() return false end end
if not setclipboard then setclipboard = function() end end
if not getgenv then getgenv = function() return _G end end
if not hookmetamethod then hookmetamethod = function() end end
if not newcclosure then newcclosure = function(f) return f end end

------------------------------------------------------------
-- Anti-Cheat
------------------------------------------------------------
local function rng(l) local c="abcdefghijklmnopqrstuvwxyz0123456789"; local n=""; for i=1,(l or 12) do local x=math.random(1,#c); n=n..c:sub(x,x) end; return n end

pcall(function()
    if typeof(hookmetamethod)=="function" then
        local oi; oi=hookmetamethod(game,"__index",newcclosure(function(s,k)
            if not checkcaller() then
                if k=="WalkSpeed" and s:IsA("Humanoid") then return 16 end
                if k=="JumpPower" and s:IsA("Humanoid") then return 50 end
            end
            return oi(s,k)
        end))
    end
end)

pcall(function()
    if typeof(hookmetamethod)=="function" then
        local on; on=hookmetamethod(game,"__namecall",newcclosure(function(s,...)
            local m=getnamecallmethod()
            if (s:IsA("RemoteEvent") or s:IsA("RemoteFunction")) then
                local nm=s.Name:lower()
                if nm:find("anticheat") or nm:find("detect") or nm:find("exploit") or nm:find("kick") or nm:find("ban") then
                    if m=="FireServer" or m=="InvokeServer" then return nil end
                end
            end
            return on(s,...)
        end))
    end
end)

pcall(function() task.spawn(function() for _,o in ipairs(game:GetDescendants()) do pcall(function() if (o:IsA("LocalScript") or o:IsA("ModuleScript")) then local nm=o.Name:lower(); if nm:find("anticheat") or nm:find("anti_cheat") or nm:find("detect") then o.Disabled=true; o:Destroy() end end end) end end) end)

------------------------------------------------------------
-- Services & Vars
------------------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WS = game:GetService("Workspace")
local RepStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

------------------------------------------------------------
-- Config
------------------------------------------------------------
local Cfg = {
    Main={SelectedPlayer=nil,NoClip=false,Speed=false,SpeedAmt=0,Fly=false,FlySpeed=7,JumpPower=false,JumpAmt=100},
    Money={AutoFarmConstruction=false,AutoFarmBank=false,AutoFarmHouse=false,AutoFarmStudio=false,AutoFarmDumpsters=false,MoneyAmt=0,BankAction="Deposit",AutoDeposit=false,AutoWithdraw=false,AutoDrop=false,AutoIllegal=false},
    Misc={InfStamina=false,InstantRespawn=false,InfSleep=false,InfHunger=false,InstantInteract=false,AutoPickup=false,DisableBlood=false,UnlockCars=false,NoRent=false,NoFallDmg=false,RespawnDied=false,TpLocation="Basketball Court",Outfit="Amiri Outfit"},
    Combat={Enabled=false,Target="Head",MaxDist=50,Smooth=50,FOV=false,FOVRadius=50},
    Visuals={ESP=false,Chams=false,Dist=false,MaxDist=2000,FillT=50,OutT=50},
}

------------------------------------------------------------
-- Teleport Locations (The Bronx 3 coordinates)
------------------------------------------------------------
local TeleportLocations = {
    ["Basketball Court"] = CFrame.new(-183, 18, -340),
    ["Gun Store"] = CFrame.new(245, 18, -115),
    ["Bank"] = CFrame.new(-72, 18, 168),
    ["Hospital"] = CFrame.new(310, 18, 75),
    ["Police Station"] = CFrame.new(-215, 18, 125),
    ["Car Dealer"] = CFrame.new(155, 18, -280),
    ["Studio"] = CFrame.new(-50, 18, -450),
    ["Apartments"] = CFrame.new(85, 18, 260),
    ["Gas Station"] = CFrame.new(-290, 18, -80),
    ["Clothing Store"] = CFrame.new(190, 18, 180),
    ["Barber Shop"] = CFrame.new(-140, 18, 55),
}

------------------------------------------------------------
-- Remote Helpers
------------------------------------------------------------
local function allRemotes()
    local r={}; for _,o in ipairs(RepStorage:GetDescendants()) do if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then r[o.Name]=o end end; return r
end

local function fireR(remote,...) if not remote then return end; pcall(function() if remote:IsA("RemoteEvent") then remote:FireServer(...) else remote:InvokeServer(...) end end) end

local function duplicateItem()
    task.spawn(function()
        local rm=allRemotes()
        for n,r in pairs(rm) do local l=n:lower(); if l:find("drop") or l:find("equip") or l:find("item") then for i=1,5 do pcall(function() r:FireServer() end); task.wait(0.05) end end end
        pcall(function()
            local bp=LP:FindFirstChild("Backpack"); local ch=LP.Character
            if bp and ch then local hum=ch:FindFirstChild("Humanoid"); if hum then
                for _,t in ipairs(ch:GetChildren()) do if t:IsA("Tool") then local tn=t.Name; hum:UnequipTools(); task.wait(0.1)
                    for rn,r in pairs(rm) do if rn:lower():find("drop") then pcall(function() r:FireServer(tn) end) end end
                    task.wait(0.1); pcall(function() local tt=bp:FindFirstChild(tn); if tt then hum:EquipTool(tt) end end); break
                end end
            end end
        end)
    end)
end

local function genMoney(auto)
    task.spawn(function()
        local rm=allRemotes()
        for n,r in pairs(rm) do local l=n:lower(); if l:find("money") or l:find("cash") or l:find("sell") or l:find("illegal") or l:find("drug") then pcall(function() r:FireServer(); r:FireServer(999999); r:FireServer("sell") end) end end
        if auto then while Cfg.Money.AutoIllegal do for n,r in pairs(rm) do local l=n:lower(); if l:find("sell") or l:find("money") or l:find("illegal") then pcall(function() r:FireServer() end) end end; task.wait(0.5) end end
    end)
end

local function bankAction(act,amt)
    task.spawn(function()
        local rm=allRemotes()
        for n,r in pairs(rm) do local l=n:lower(); if l:find("bank") or l:find("atm") or l:find("deposit") or l:find("withdraw") then pcall(function() r:FireServer(act,amt); r:FireServer(act:lower(),tonumber(amt)) end) end end
    end)
end

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local SG = Instance.new("ScreenGui")
SG.Name = rng(16); SG.ResetOnSpawn = false; SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(SG) end end)
pcall(function() if gethui then SG.Parent = gethui(); return end end)
if not SG.Parent then pcall(function() SG.Parent = game:GetService("CoreGui") end) end
if not SG.Parent then SG.Parent = LP:WaitForChild("PlayerGui") end

-- Colors
local BG = Color3.fromRGB(18,18,24)
local SB = Color3.fromRGB(22,22,30)
local CARD = Color3.fromRGB(28,28,38)
local ACC = Color3.fromRGB(0,110,255)
local TXT = Color3.fromRGB(210,210,220)
local DIM = Color3.fromRGB(120,120,135)
local TOG_OFF = Color3.fromRGB(45,45,55)
local INP = Color3.fromRGB(35,35,45)

-- Main Window
local W = Instance.new("Frame"); W.Name=rng(8); W.Size=UDim2.new(0,660,0,440); W.Position=UDim2.new(0.5,-330,0.5,-220); W.BackgroundColor3=BG; W.BorderSizePixel=0; W.Active=true; W.Draggable=true; W.Parent=SG
Instance.new("UICorner",W).CornerRadius=UDim.new(0,10)

-- Header
local HD = Instance.new("Frame"); HD.Size=UDim2.new(1,0,0,45); HD.BackgroundColor3=SB; HD.BorderSizePixel=0; HD.Parent=W
Instance.new("UICorner",HD).CornerRadius=UDim.new(0,10)

-- Logo + Title
local Logo = Instance.new("TextLabel"); Logo.Size=UDim2.new(0,30,0,30); Logo.Position=UDim2.new(0,12,0,8); Logo.BackgroundColor3=ACC; Logo.TextColor3=Color3.new(1,1,1); Logo.Font=Enum.Font.GothamBold; Logo.TextSize=16; Logo.Text="SX"; Logo.Parent=HD
Instance.new("UICorner",Logo).CornerRadius=UDim.new(0,8)

local TL = Instance.new("TextLabel"); TL.Size=UDim2.new(0,120,0,16); TL.Position=UDim2.new(0,50,0,6); TL.BackgroundTransparency=1; TL.Text="Synapse-Xenon"; TL.TextColor3=ACC; TL.Font=Enum.Font.GothamBold; TL.TextSize=13; TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=HD
local TL2 = Instance.new("TextLabel"); TL2.Size=UDim2.new(0,120,0,14); TL2.Position=UDim2.new(0,50,0,24); TL2.BackgroundTransparency=1; TL2.Text="Premium User!"; TL2.TextColor3=DIM; TL2.Font=Enum.Font.Gotham; TL2.TextSize=10; TL2.TextXAlignment=Enum.TextXAlignment.Left; TL2.Parent=HD

-- Sidebar
local SBR = Instance.new("Frame"); SBR.Size=UDim2.new(0,130,1,-45); SBR.Position=UDim2.new(0,0,0,45); SBR.BackgroundColor3=SB; SBR.BorderSizePixel=0; SBR.Parent=W

-- Content
local CT = Instance.new("Frame"); CT.Size=UDim2.new(1,-130,1,-45); CT.Position=UDim2.new(0,130,0,45); CT.BackgroundTransparency=1; CT.ClipsDescendants=true; CT.Parent=W

-- Tab system
local pages = {}
local sidebtns = {}
local subpages = {}

local function mkSideBtn(name, icon, idx)
    local b = Instance.new("TextButton"); b.Size=UDim2.new(1,-12,0,34); b.Position=UDim2.new(0,6,0,8+(idx-1)*38); b.BackgroundColor3=CARD; b.BackgroundTransparency=1; b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.Parent=SBR
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local ic = Instance.new("TextLabel"); ic.Size=UDim2.new(0,20,0,20); ic.Position=UDim2.new(0,10,0.5,-10); ic.BackgroundTransparency=1; ic.Text=icon; ic.TextColor3=DIM; ic.Font=Enum.Font.GothamBold; ic.TextSize=14; ic.Parent=b
    local lb = Instance.new("TextLabel"); lb.Size=UDim2.new(1,-40,1,0); lb.Position=UDim2.new(0,36,0,0); lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=DIM; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=b
    sidebtns[name] = {btn=b, icon=ic, label=lb}
    return b
end

local function mkPage()
    local f = Instance.new("Frame"); f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1; f.Visible=false; f.Parent=CT
    return f
end

local function mkSubTabBar(parent, tabNames)
    local bar = Instance.new("Frame"); bar.Size=UDim2.new(1,0,0,30); bar.BackgroundTransparency=1; bar.Parent=parent
    local btns = {}
    for i, name in ipairs(tabNames) do
        local b = Instance.new("TextButton"); b.Size=UDim2.new(0,90,0,26); b.Position=UDim2.new(0,5+(i-1)*95,0,2); b.BackgroundColor3=ACC; b.BackgroundTransparency=1; b.Text=name; b.TextColor3=DIM; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=bar
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        btns[name] = b
    end
    return bar, btns
end

local function mkScroll(parent, yOff)
    local s = Instance.new("ScrollingFrame"); s.Size=UDim2.new(1,-10,1,-(yOff+5)); s.Position=UDim2.new(0,5,0,yOff); s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ScrollBarThickness=3; s.ScrollBarImageColor3=ACC; s.CanvasSize=UDim2.new(0,0,0,0); s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.Visible=false; s.Parent=parent
    local l = Instance.new("UIListLayout"); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,4); l.Parent=s
    Instance.new("UIPadding",s).PaddingTop=UDim.new(0,4)
    return s
end

-- Two-column scroll
local function mkTwoCol(parent, yOff)
    local wrap = Instance.new("Frame"); wrap.Size=UDim2.new(1,0,1,-(yOff+5)); wrap.Position=UDim2.new(0,0,0,yOff); wrap.BackgroundTransparency=1; wrap.Visible=false; wrap.Parent=parent

    local left = Instance.new("ScrollingFrame"); left.Size=UDim2.new(0.5,-8,1,0); left.Position=UDim2.new(0,5,0,0); left.BackgroundTransparency=1; left.BorderSizePixel=0; left.ScrollBarThickness=3; left.ScrollBarImageColor3=ACC; left.CanvasSize=UDim2.new(0,0,0,0); left.AutomaticCanvasSize=Enum.AutomaticSize.Y; left.Parent=wrap
    local ll = Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,4); ll.Parent=left
    Instance.new("UIPadding",left).PaddingTop=UDim.new(0,4)

    local right = Instance.new("ScrollingFrame"); right.Size=UDim2.new(0.5,-8,1,0); right.Position=UDim2.new(0.5,3,0,0); right.BackgroundTransparency=1; right.BorderSizePixel=0; right.ScrollBarThickness=3; right.ScrollBarImageColor3=ACC; right.CanvasSize=UDim2.new(0,0,0,0); right.AutomaticCanvasSize=Enum.AutomaticSize.Y; right.Parent=wrap
    local rl = Instance.new("UIListLayout"); rl.SortOrder=Enum.SortOrder.LayoutOrder; rl.Padding=UDim.new(0,4); rl.Parent=right
    Instance.new("UIPadding",right).PaddingTop=UDim.new(0,4)

    return wrap, left, right
end

-- UI Elements
local ord = 0
local function no() ord=ord+1; return ord end
local function resetOrd() ord=0 end

local function sec(p,txt,o)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-4,0,22); l.BackgroundColor3=CARD; l.Text="  "..txt; l.TextColor3=ACC; l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=o; l.BorderSizePixel=0; l.Parent=p
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,5)
end

local function tog(p,txt,def,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,28); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-55,1,0); lb.Position=UDim2.new(0,10,0,0); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(0,34,0,17); bg.Position=UDim2.new(1,-42,0.5,-8); bg.BackgroundColor3=def and ACC or TOG_OFF; bg.BorderSizePixel=0; bg.Parent=f
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local ci=Instance.new("Frame"); ci.Size=UDim2.new(0,13,0,13); ci.Position=def and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6); ci.BackgroundColor3=Color3.new(1,1,1); ci.BorderSizePixel=0; ci.Parent=bg
    Instance.new("UICorner",ci).CornerRadius=UDim.new(1,0)
    local st=def or false
    local bt=Instance.new("TextButton"); bt.Size=UDim2.new(1,0,1,0); bt.BackgroundTransparency=1; bt.Text=""; bt.Parent=f
    bt.MouseButton1Click:Connect(function()
        st=not st; bg.BackgroundColor3=st and ACC or TOG_OFF
        TS:Create(ci,TweenInfo.new(0.12),{Position=st and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6)}):Play()
        if cb then cb(st) end
    end)
end

local function sld(p,txt,mn,mx,df,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,40); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-55,0,18); lb.Position=UDim2.new(0,10,0,2); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(0,45,0,18); vl.Position=UDim2.new(1,-50,0,2); vl.BackgroundTransparency=1; vl.Text=tostring(df); vl.TextColor3=ACC; vl.Font=Enum.Font.GothamBold; vl.TextSize=11; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=f
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(1,-20,0,5); tr.Position=UDim2.new(0,10,0,28); tr.BackgroundColor3=TOG_OFF; tr.BorderSizePixel=0; tr.Parent=f
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fl=Instance.new("Frame"); fl.Size=UDim2.new(math.clamp((df-mn)/(mx-mn),0,1),0,1,0); fl.BackgroundColor3=ACC; fl.BorderSizePixel=0; fl.Parent=tr
    Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local dr=false
    local sb=Instance.new("TextButton"); sb.Size=UDim2.new(1,0,0,18); sb.Position=UDim2.new(0,0,0,22); sb.BackgroundTransparency=1; sb.Text=""; sb.Parent=f
    sb.MouseButton1Down:Connect(function() dr=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UIS.InputChanged:Connect(function(i)
        if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
            local mp=UIS:GetMouseLocation(); local ap=tr.AbsolutePosition.X; local as=tr.AbsoluteSize.X
            local pct=math.clamp((mp.X-ap)/as,0,1); local v=math.floor(mn+(mx-mn)*pct)
            fl.Size=UDim2.new(pct,0,1,0); vl.Text=tostring(v); if cb then cb(v) end
        end
    end)
end

local function btn(p,txt,desc,cb,o)
    local h=desc~="" and 36 or 28
    local f=Instance.new("TextButton"); f.Size=UDim2.new(1,-4,0,h); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.Text=""; f.LayoutOrder=o; f.AutoButtonColor=false; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-14,0,18); lb.Position=UDim2.new(0,10,0,desc~="" and 2 or 5); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    if desc~="" then
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,-14,0,12); dl.Position=UDim2.new(0,10,0,20); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=DIM; dl.Font=Enum.Font.Gotham; dl.TextSize=9; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.Parent=f
    end
    f.MouseButton1Click:Connect(function()
        f.BackgroundColor3=ACC; task.delay(0.12,function() f.BackgroundColor3=CARD end)
        if cb then cb() end
    end)
end

local function dd(p,txt,opts,df,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,28); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.ClipsDescendants=true; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.48,0,0,28); lb.Position=UDim2.new(0,10,0,0); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local sel=Instance.new("TextButton"); sel.Size=UDim2.new(0.48,-5,0,22); sel.Position=UDim2.new(0.5,2,0,3); sel.BackgroundColor3=INP; sel.BorderSizePixel=0; sel.Text=df or opts[1] or ""; sel.TextColor3=ACC; sel.Font=Enum.Font.Gotham; sel.TextSize=11; sel.Parent=f
    Instance.new("UICorner",sel).CornerRadius=UDim.new(0,4)
    local open=false
    sel.MouseButton1Click:Connect(function()
        open=not open
        if open then
            f.Size=UDim2.new(1,-4,0,28+#opts*24)
            for i,opt in ipairs(opts) do
                local ob=Instance.new("TextButton"); ob.Name="o"..i; ob.Size=UDim2.new(0.48,-5,0,22); ob.Position=UDim2.new(0.5,2,0,2+i*24); ob.BackgroundColor3=INP; ob.BorderSizePixel=0; ob.Text=opt; ob.TextColor3=TXT; ob.Font=Enum.Font.Gotham; ob.TextSize=11; ob.Parent=f
                Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
                ob.MouseButton1Click:Connect(function()
                    sel.Text=opt; open=false; f.Size=UDim2.new(1,-4,0,28)
                    for _,c in ipairs(f:GetChildren()) do if c.Name:sub(1,1)=="o" then c:Destroy() end end
                    if cb then cb(opt) end
                end)
            end
        else
            f.Size=UDim2.new(1,-4,0,28)
            for _,c in ipairs(f:GetChildren()) do if c.Name:sub(1,1)=="o" then c:Destroy() end end
        end
    end)
end

------------------------------------------------------------
-- Create Pages
------------------------------------------------------------

-- Side tabs
local sideTabNames = {"Tha Bronx 3", "Combat", "Visuals", "Settings"}
local sideIcons = {"B", "C", "V", "S"} -- simple letter icons

for i, name in ipairs(sideTabNames) do
    pages[name] = mkPage()
    mkSideBtn(name, sideIcons[i], i)
end

local function switchSide(name)
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    for n, d in pairs(sidebtns) do
        if n == name then
            d.btn.BackgroundTransparency = 0; d.btn.BackgroundColor3 = CARD
            d.icon.TextColor3 = ACC; d.label.TextColor3 = TXT
        else
            d.btn.BackgroundTransparency = 1
            d.icon.TextColor3 = DIM; d.label.TextColor3 = DIM
        end
    end
end

for n, d in pairs(sidebtns) do
    d.btn.MouseButton1Click:Connect(function() switchSide(n) end)
end

------------------------------------------------------------
-- THA BRONX 3 TAB (with sub-tabs: Main, Money, Miscellaneous)
------------------------------------------------------------
local tbPage = pages["Tha Bronx 3"]
local subBar, subBtns = mkSubTabBar(tbPage, {"Main", "Money", "Miscellaneous"})

-- Main sub-tab (two columns)
local mainWrap, mainL, mainR = mkTwoCol(tbPage, 32)
-- Money sub-tab
local moneyWrap, moneyL, moneyR = mkTwoCol(tbPage, 32)
-- Misc sub-tab
local miscWrap, miscL, miscR = mkTwoCol(tbPage, 32)

local subPageMap = {Main=mainWrap, Money=moneyWrap, Miscellaneous=miscWrap}

local function switchSub(name)
    for n, w in pairs(subPageMap) do w.Visible = (n == name) end
    for n, b in pairs(subBtns) do
        if n == name then b.BackgroundTransparency = 0; b.BackgroundColor3 = ACC; b.TextColor3 = Color3.new(1,1,1)
        else b.BackgroundTransparency = 1; b.TextColor3 = DIM end
    end
end

for n, b in pairs(subBtns) do b.MouseButton1Click:Connect(function() switchSub(n) end) end
switchSub("Main")

-- MAIN sub-tab content
resetOrd()
local pn = {}; for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then table.insert(pn,pl.Name) end end

sec(mainL,"Select Player",no())
dd(mainL,"Selected Player",pn,nil,function(v) Cfg.Main.SelectedPlayer=v end,no())

sec(mainL,"Player Options",no())
btn(mainL,"Spectate Player","",function()
    local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("Humanoid") then Cam.CameraSubject=p.Character.Humanoid end end
end,no())
btn(mainL,"Bring Player","",function()
    local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame=LP.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-5) end end
end,no())
btn(mainL,"Bug / Kill Player - Car","",function() end,no())
btn(mainL,"Auto Kill Player - Gun","",function() end,no())
btn(mainL,"Auto Ragdoll Player - Gun","",function() end,no())
btn(mainL,"Teleport To Player","",function()
    local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame=p.Character.HumanoidRootPart.CFrame end end
end,no())
btn(mainL,"Down Player - Hold Gun","",function() end,no())
btn(mainL,"Kill Player - Hold Gun","",function() end,no())

-- Right column
resetOrd()
tog(mainR,"No Clip",false,function(v) Cfg.Main.NoClip=v end,no())
tog(mainR,"Speed",false,function(v) Cfg.Main.Speed=v end,no())
sld(mainR,"Speed Amount",0,100,0,function(v) Cfg.Main.SpeedAmt=v end,no())
tog(mainR,"Fly",false,function(v) Cfg.Main.Fly=v end,no())
sld(mainR,"Fly Speed Amount",0,50,7,function(v) Cfg.Main.FlySpeed=v end,no())
tog(mainR,"Jump Power",false,function(v) Cfg.Main.JumpPower=v end,no())
sld(mainR,"Jump Power Amount",0,500,100,function(v) Cfg.Main.JumpAmt=v end,no())

-- MONEY sub-tab content
resetOrd()
sec(moneyL,"Farming",no())
tog(moneyL,"Auto Farm Construction",false,function(v) Cfg.Money.AutoFarmConstruction=v end,no())
tog(moneyL,"Auto Farm Bank",false,function(v) Cfg.Money.AutoFarmBank=v end,no())
tog(moneyL,"Auto Farm House",false,function(v) Cfg.Money.AutoFarmHouse=v end,no())
tog(moneyL,"Auto Farm Studio",false,function(v) Cfg.Money.AutoFarmStudio=v end,no())
tog(moneyL,"Auto Farm Dumpsters",false,function(v) Cfg.Money.AutoFarmDumpsters=v end,no())

sec(moneyL,"Vulnerability Section",no())
btn(moneyL,"Gen Max Illegal Money Manual","Requires Ice-Fruit Cup!",function() genMoney(false) end,no())
tog(moneyL,"Gen Max Illegal Money Auto",false,function(v) Cfg.Money.AutoIllegal=v; if v then genMoney(true) end end,no())

resetOrd()
sec(moneyR,"Bank Actions",no())
sld(moneyR,"Money Amount",0,999999,0,function(v) Cfg.Money.MoneyAmt=v end,no())
dd(moneyR,"Select Bank Action",{"Deposit","Withdraw","Drop"},"Deposit",function(v) Cfg.Money.BankAction=v end,no())
btn(moneyR,"Apply Selected Bank Action","",function() bankAction(Cfg.Money.BankAction,Cfg.Money.MoneyAmt) end,no())
tog(moneyR,"Auto Deposit",false,function(v) Cfg.Money.AutoDeposit=v end,no())
tog(moneyR,"Auto Withdraw",false,function(v) Cfg.Money.AutoWithdraw=v end,no())
tog(moneyR,"Auto Drop",false,function(v) Cfg.Money.AutoDrop=v end,no())

sec(moneyR,"Duping Section",no())
btn(moneyR,"Duplicate Current Item","Can Take Few Tries!",function() duplicateItem() end,no())

-- MISCELLANEOUS sub-tab content
resetOrd()
sec(miscL,"Local Player Modifications",no())
tog(miscL,"Infinite Stamina",false,function(v) Cfg.Misc.InfStamina=v end,no())
tog(miscL,"Instant Respawn",false,function(v) Cfg.Misc.InstantRespawn=v end,no())
tog(miscL,"Infinite Sleep",false,function(v) Cfg.Misc.InfSleep=v end,no())
tog(miscL,"Infinite Hunger",false,function(v) Cfg.Misc.InfHunger=v end,no())
tog(miscL,"Instant Interact",false,function(v) Cfg.Misc.InstantInteract=v end,no())
tog(miscL,"Auto Pickup Cash",false,function(v) Cfg.Misc.AutoPickup=v end,no())
tog(miscL,"Disable Blood Effects",false,function(v) Cfg.Misc.DisableBlood=v end,no())
tog(miscL,"Unlock Locked Cars",false,function(v) Cfg.Misc.UnlockCars=v end,no())
tog(miscL,"No Rent Pay",false,function(v) Cfg.Misc.NoRent=v end,no())
tog(miscL,"No Fall Damage",false,function(v) Cfg.Misc.NoFallDmg=v end,no())
tog(miscL,"Respawn Where You Died",false,function(v) Cfg.Misc.RespawnDied=v end,no())

resetOrd()
sec(miscR,"Teleport To Location",no())
local tpLocs = {}; for k in pairs(TeleportLocations) do table.insert(tpLocs, k) end; table.sort(tpLocs)
dd(miscR,"Teleport Options",tpLocs,"Basketball Court",function(v) Cfg.Misc.TpLocation=v end,no())
btn(miscR,"Teleport","",function()
    local cf = TeleportLocations[Cfg.Misc.TpLocation]
    if cf and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = cf
    end
end,no())

sec(miscR,"Outfits",no())
dd(miscR,"Select Outfit",{"Amiri Outfit","Nike Tech","Bape Set","Default"},"Amiri Outfit",function(v) Cfg.Misc.Outfit=v end,no())
btn(miscR,"Apply Selected Outfit","",function() end,no())

------------------------------------------------------------
-- COMBAT TAB (two columns)
------------------------------------------------------------
local combatPage = pages["Combat"]
local combatBar, combatSubBtns = mkSubTabBar(combatPage, {"Silent Aim", "Aimlock"})
local aimlockWrap, aimlockL, aimlockR = mkTwoCol(combatPage, 32)
local silentWrap, silentL, silentR = mkTwoCol(combatPage, 32)

local combatSubMap = {["Silent Aim"]=silentWrap, Aimlock=aimlockWrap}
local function switchCombatSub(n)
    for k,w in pairs(combatSubMap) do w.Visible=(k==n) end
    for k,b in pairs(combatSubBtns) do
        if k==n then b.BackgroundTransparency=0; b.BackgroundColor3=ACC; b.TextColor3=Color3.new(1,1,1)
        else b.BackgroundTransparency=1; b.TextColor3=DIM end
    end
end
for n,b in pairs(combatSubBtns) do b.MouseButton1Click:Connect(function() switchCombatSub(n) end) end
switchCombatSub("Aimlock")

-- Aimlock
resetOrd()
sec(aimlockL,"General",no())
tog(aimlockL,"Enabled",false,function(v) Cfg.Combat.Enabled=v end,no())

sec(aimlockL,"Settings",no())
dd(aimlockL,"Aimlock Type",{"Mouse","Camera","Closest"},"Mouse",function() end,no())
dd(aimlockL,"Target Parts",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},"Head",function(v) Cfg.Combat.Target=v end,no())
sld(aimlockL,"Max Distance",0,100,50,function(v) Cfg.Combat.MaxDist=v end,no())
sld(aimlockL,"Smoothness",0,100,50,function(v) Cfg.Combat.Smooth=v end,no())

resetOrd()
sec(aimlockR,"Field Of View",no())
tog(aimlockR,"Enabled",false,function(v) Cfg.Combat.FOV=v end,no())
sld(aimlockR,"Radius",0,100,50,function(v) Cfg.Combat.FOVRadius=v end,no())

sec(aimlockR,"Snapline",no())
tog(aimlockR,"Enabled",false,function() end,no())
sld(aimlockR,"Snapline Thickness",0,100,50,function() end,no())

-- Silent Aim (same layout)
resetOrd()
sec(silentL,"General",no())
tog(silentL,"Enabled",false,function() end,no())
sec(silentL,"Settings",no())
dd(silentL,"Target Parts",{"Head","HumanoidRootPart","UpperTorso"},"Head",function() end,no())
sld(silentL,"Max Distance",0,100,50,function() end,no())
sld(silentL,"Smoothness",0,100,50,function() end,no())
resetOrd()
sec(silentR,"Field Of View",no())
tog(silentR,"Enabled",false,function() end,no())
sld(silentR,"Radius",0,100,50,function() end,no())

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
local visualsPage = pages["Visuals"]
local visBar, visBtns = mkSubTabBar(visualsPage, {"ESP"})
local espWrap, espL, espR = mkTwoCol(visualsPage, 32)
espWrap.Visible = true
for _,b in pairs(visBtns) do b.BackgroundTransparency=0; b.BackgroundColor3=ACC; b.TextColor3=Color3.new(1,1,1) end

resetOrd()
sec(espL,"Enable ESP",no())
tog(espL,"Enable ESP",false,function(v) Cfg.Visuals.ESP=v end,no())
sec(espL,"Box ESP",no())
tog(espL,"Corner Frame ESP",false,function() end,no())
tog(espL,"Box ESP",false,function() end,no())
sec(espL,"Healthbar ESP",no())
tog(espL,"Health Bar",false,function() end,no())
tog(espL,"Health Text",false,function() end,no())

resetOrd()
sec(espR,"ESP Settings",no())
tog(espR,"Distance",false,function(v) Cfg.Visuals.Dist=v end,no())
sld(espR,"Max Distance",0,5000,2000,function(v) Cfg.Visuals.MaxDist=v end,no())
sec(espR,"Cham ESP",no())
tog(espR,"Chams",false,function(v) Cfg.Visuals.Chams=v end,no())
tog(espR,"Thermal Effect",false,function() end,no())
sld(espR,"Fill Transparency",0,100,50,function(v) Cfg.Visuals.FillT=v end,no())
sld(espR,"Outline Transparency",0,100,50,function(v) Cfg.Visuals.OutT=v end,no())

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
local setPage = pages["Settings"]
local setScroll = mkScroll(setPage, 5); setScroll.Visible = true
resetOrd()
sec(setScroll,"UI Settings",no())
btn(setScroll,"Toggle Bind: RightShift","Press RightShift to show/hide GUI",function() end,no())
btn(setScroll,"Destroy GUI","Completely removes the script",function() SG:Destroy() end,no())

------------------------------------------------------------
-- Init
------------------------------------------------------------
switchSide("Tha Bronx 3")

-- Toggle GUI
local gVis = true
UIS.InputBegan:Connect(function(i,gp) if gp then return end; if i.KeyCode==Enum.KeyCode.RightShift then gVis=not gVis; W.Visible=gVis end end)

------------------------------------------------------------
-- CORE LOOPS
------------------------------------------------------------

RS.Stepped:Connect(function()
    pcall(function() if Cfg.Main.NoClip and LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)
end)

RS.Heartbeat:Connect(function(dt)
    pcall(function()
        if Cfg.Main.Speed and LP.Character then
            local h=LP.Character:FindFirstChild("HumanoidRootPart"); local hm=LP.Character:FindFirstChild("Humanoid")
            if h and hm then local d=hm.MoveDirection; if d.Magnitude>0 then h.CFrame=h.CFrame+Vector3.new(d.X,0,d.Z)*Cfg.Main.SpeedAmt*dt end end
        end
    end)
end)

RS.Heartbeat:Connect(function()
    pcall(function() if Cfg.Main.JumpPower and LP.Character then local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm.JumpPower=Cfg.Main.JumpAmt; hm.UseJumpPower=true end end end)
end)

RS.Heartbeat:Connect(function(dt)
    pcall(function()
        if Cfg.Main.Fly and LP.Character then
            local h=LP.Character:FindFirstChild("HumanoidRootPart"); local hm=LP.Character:FindFirstChild("Humanoid")
            if h and hm then
                hm:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
                local sp=Cfg.Main.FlySpeed*10; local d=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
                if d.Magnitude>0 then h.CFrame=h.CFrame+(d.Unit*sp*dt) end
                h.Velocity=Vector3.new(0,0,0)
            end
        else
            pcall(function() if LP.Character then local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm:SetStateEnabled(Enum.HumanoidStateType.Freefall,true) end end end)
        end
    end)
end)

-- ESP
local espO = {}
local function mkESP(pl)
    if pl==LP then return end
    local d={}
    local hl=Instance.new("Highlight"); hl.Name=rng(16); hl.FillColor=Color3.fromRGB(0,120,255); hl.OutlineColor=Color3.new(1,1,1); hl.Enabled=false; d.Highlight=hl
    local bb=Instance.new("BillboardGui"); bb.Name=rng(16); bb.Size=UDim2.new(0,200,0,50); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Enabled=false
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1; nl.TextColor3=Color3.new(1,1,1); nl.TextStrokeTransparency=0.5; nl.Font=Enum.Font.GothamBold; nl.TextSize=13; nl.Text=pl.Name; nl.Parent=bb
    local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0.5,0); dl.Position=UDim2.new(0,0,0.5,0); dl.BackgroundTransparency=1; dl.TextColor3=Color3.fromRGB(200,200,200); dl.TextStrokeTransparency=0.5; dl.Font=Enum.Font.Gotham; dl.TextSize=11; dl.Text=""; dl.Parent=bb
    d.Billboard=bb; d.DistLabel=dl; espO[pl]=d
    local function oc(c) pcall(function() hl.Adornee=c; hl.Parent=c; local hd=c:WaitForChild("Head",5); if hd then bb.Parent=hd end end) end
    if pl.Character then task.spawn(function() oc(pl.Character) end) end
    pl.CharacterAdded:Connect(oc)
end
local function rmESP(pl) local d=espO[pl]; if d then pcall(function() d.Highlight:Destroy() end); pcall(function() d.Billboard:Destroy() end); espO[pl]=nil end end
for _,p in ipairs(Players:GetPlayers()) do mkESP(p) end
Players.PlayerAdded:Connect(mkESP); Players.PlayerRemoving:Connect(rmESP)

RS.RenderStepped:Connect(function()
    pcall(function()
        for pl,d in pairs(espO) do
            local ch=pl.Character; local hr=ch and ch:FindFirstChild("HumanoidRootPart"); local lr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if Cfg.Visuals.ESP and ch and hr and lr then
                local dist=(hr.Position-lr.Position).Magnitude
                if dist<=Cfg.Visuals.MaxDist then
                    d.Highlight.Enabled=Cfg.Visuals.Chams; d.Highlight.FillTransparency=Cfg.Visuals.FillT/100; d.Highlight.OutlineTransparency=Cfg.Visuals.OutT/100
                    d.Billboard.Enabled=true; d.DistLabel.Text=Cfg.Visuals.Dist and string.format("[%d]",math.floor(dist)) or ""
                else d.Highlight.Enabled=false; d.Billboard.Enabled=false end
            else if d.Highlight then d.Highlight.Enabled=false end; if d.Billboard then d.Billboard.Enabled=false end end
        end
    end)
end)

-- Aimlock
local aTarget=nil
UIS.InputBegan:Connect(function(i,gp) if gp then return end; if i.UserInputType==Enum.UserInputType.MouseButton2 and Cfg.Combat.Enabled then
    local cl,cd=nil,math.huge; local mp=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local pt=p.Character:FindFirstChild(Cfg.Combat.Target); if pt then
        local sp,on=Cam:WorldToViewportPoint(pt.Position); if on then local d2=(Vector2.new(sp.X,sp.Y)-mp).Magnitude; local fv=(Cfg.Combat.FOVRadius/100)*300
            if (not Cfg.Combat.FOV or d2<=fv) and d2<cd then local lr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if lr then local d3=(pt.Position-lr.Position).Magnitude; if d3<=(Cfg.Combat.MaxDist/100)*1000 then cl=p; cd=d2 end end end
        end end end end; aTarget=cl
end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aTarget=nil end end)
RS.RenderStepped:Connect(function() pcall(function() if Cfg.Combat.Enabled and aTarget then local ch=aTarget.Character; if ch then local pt=ch:FindFirstChild(Cfg.Combat.Target); if pt then local sm=1-(Cfg.Combat.Smooth/100)*0.9; Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,pt.Position),sm) end end end end) end)

-- Auto Pickup
RS.Heartbeat:Connect(function() pcall(function() if Cfg.Misc.AutoPickup and LP.Character then local h=LP.Character:FindFirstChild("HumanoidRootPart"); if h then for _,o in ipairs(WS:GetDescendants()) do if o:IsA("BasePart") and (o.Name:lower():find("cash") or o.Name:lower():find("money")) then if (o.Position-h.Position).Magnitude<=50 then firetouchinterest(h,o,0); task.wait(); firetouchinterest(h,o,1) end end end end end end) end)

-- No Fall Damage
RS.Heartbeat:Connect(function() pcall(function() if Cfg.Misc.NoFallDmg and LP.Character then local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false); hm:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false) end end end) end)

print("[Synapse-Xenon] Tha Bronx 3 loaded!")
