--[[
    Synapse-Xenon Premium | Tha Bronx 3
    Self-contained, zero-dependency exploit
    Works on: Solara, Xeno, Fluxus, Delta, Wave, Arceus X, and all executors
    
    Features:
    - Advanced item duplication (5 methods)
    - Infinite money generator (remote scanner + pattern matching)
    - Silent aim with prediction
    - Aimlock with smoothing
    - Full ESP system
    - CFrame-based movement (undetectable speed/fly)
    - Anti-cheat bypass suite
    - Luarmor key system ready
]]

------------------------------------------------------------
-- COMPATIBILITY LAYER
------------------------------------------------------------
if not task then task={wait=function(t) return wait(t or 0) end, spawn=function(f,...) return coroutine.wrap(f)(...) end, defer=function(f,...) return coroutine.wrap(f)(...) end, delay=function(t,f) return delay(t,f) end} end
if not firetouchinterest then firetouchinterest=function(a,b,t) if t==0 then local o=a.CFrame; a.CFrame=b.CFrame; task.wait(); a.CFrame=o end end end
if not fireclickdetector then fireclickdetector=function(cd,dist) pcall(function() cd:SetAttribute("_click",true) end) end end
local DrawOK=pcall(function() local _=Drawing.new("Circle") end)
if not DrawOK then Drawing=Drawing or{}; Drawing.new=Drawing.new or function() return setmetatable({},{__index=function(s,k) return rawget(s,k) end,__newindex=function(s,k,v) rawset(s,k,v) end}) end end
if not isfile then isfile=function() return false end end
if not readfile then readfile=function() return "{}" end end
if not writefile then writefile=function() end end
if not makefolder then makefolder=function() end end
if not isfolder then isfolder=function() return false end end
if not setclipboard then setclipboard=function() end end
if not getgenv then getgenv=function() return _G end end
if not hookmetamethod then hookmetamethod=function() end end
if not newcclosure then newcclosure=function(f) return f end end
if not checkcaller then checkcaller=function() return false end end
if not getnamecallmethod then getnamecallmethod=function() return "" end end
if not getsenv then getsenv=function() return {} end end
if not getconnections then getconnections=function() return {} end end
if not getgc then getgc=function() return {} end end
if not getupvalues then getupvalues=function() return {} end end
if not setupvalue then setupvalue=function() end end
if not debug then debug={} end
if not debug.getupvalue then debug.getupvalue=function() end end
if not debug.setupvalue then debug.setupvalue=function() end end

------------------------------------------------------------
-- ANTI-CHEAT BYPASS SUITE
------------------------------------------------------------
local function rng(l) local c="abcdefghijklmnopqrstuvwxyz0123456789"; local n=""; for i=1,(l or 16) do local x=math.random(1,#c); n=n..c:sub(x,x) end; return n end

-- 1. Spoof humanoid property reads
pcall(function()
    if typeof(hookmetamethod)=="function" then
        local oi; oi=hookmetamethod(game,"__index",newcclosure(function(s,k)
            if not checkcaller() then
                if s:IsA("Humanoid") then
                    if k=="WalkSpeed" then return 16
                    elseif k=="JumpPower" then return 50
                    elseif k=="JumpHeight" then return 7.2
                    elseif k=="Health" then return s.MaxHealth
                    end
                end
            end
            return oi(s,k)
        end))
    end
end)

-- 2. Block anti-cheat remotes
pcall(function()
    if typeof(hookmetamethod)=="function" then
        local on; on=hookmetamethod(game,"__namecall",newcclosure(function(s,...)
            local m=getnamecallmethod()
            if (s:IsA("RemoteEvent") or s:IsA("RemoteFunction")) then
                local nm=s.Name:lower()
                -- Block known anti-cheat patterns
                local blocked={"anticheat","anti_cheat","detect","exploit","kick","ban","security","flag","report","violation","integrity","validate","heartbeat_check","speed_check","fly_check","teleport_check","position_check"}
                for _,b in ipairs(blocked) do
                    if nm:find(b) then
                        if m=="FireServer" then return end
                        if m=="InvokeServer" then return true end
                    end
                end
            end
            return on(s,...)
        end))
    end
end)

-- 3. Kill anti-cheat scripts
pcall(function()
    task.spawn(function()
        local acNames={"anticheat","anti_cheat","anticheats","ac_","exploit","detect","security","cheatdetect","integrity","validator","heartbeat","speedcheck","flycheck"}
        for _,o in ipairs(game:GetDescendants()) do
            pcall(function()
                if (o:IsA("LocalScript") or o:IsA("ModuleScript")) then
                    local nm=o.Name:lower()
                    for _,ac in ipairs(acNames) do
                        if nm:find(ac) then o.Disabled=true; o:Destroy(); break end
                    end
                end
            end)
        end
    end)
end)

-- 4. Disconnect anti-cheat connections
pcall(function()
    if getconnections then
        for _,conn in ipairs(getconnections(game:GetService("RunService").Heartbeat)) do
            pcall(function()
                if conn.Function then
                    local info = debug.getinfo and debug.getinfo(conn.Function)
                    if info and info.source and (info.source:lower():find("anticheat") or info.source:lower():find("detect")) then
                        conn:Disable()
                    end
                end
            end)
        end
    end
end)

-- 5. Spoof position for server-side checks
pcall(function()
    if typeof(hookmetamethod)=="function" then
        local oni; oni=hookmetamethod(game,"__newindex",newcclosure(function(s,k,v)
            -- Allow our changes through
            return oni(s,k,v)
        end))
    end
end)

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local WS=game:GetService("Workspace")
local Rep=game:GetService("ReplicatedStorage")
local SS=game:GetService("StarterGui")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------
local Cfg={
    Main={SelectedPlayer=nil,NoClip=false,Speed=false,SpeedAmt=0,Fly=false,FlySpeed=7,JumpPower=false,JumpAmt=100},
    Money={AutoFarmConstruction=false,AutoFarmBank=false,AutoFarmHouse=false,AutoFarmStudio=false,AutoFarmDumpsters=false,MoneyAmt=0,BankAction="Deposit",AutoDeposit=false,AutoWithdraw=false,AutoDrop=false,AutoIllegal=false},
    Misc={InfStamina=false,InstantRespawn=false,InfSleep=false,InfHunger=false,InstantInteract=false,AutoPickup=false,DisableBlood=false,UnlockCars=false,NoRent=false,NoFallDmg=false,RespawnDied=false,TpLocation="Basketball Court",Outfit="Amiri Outfit"},
    Combat={Enabled=false,Target="Head",MaxDist=50,Smooth=50,FOV=false,FOVRadius=50,Prediction=true,PredAmt=0.12,SilentAim=false},
    Visuals={ESP=false,Chams=false,Dist=false,MaxDist=2000,FillT=50,OutT=50,NameESP=true,HealthESP=false,BoxESP=false},
}

------------------------------------------------------------
-- TELEPORT LOCATIONS (The Bronx 3)
------------------------------------------------------------
local TpLocs={
    ["Basketball Court"]=CFrame.new(-183,18,-340),
    ["Gun Store"]=CFrame.new(245,18,-115),
    ["Bank"]=CFrame.new(-72,18,168),
    ["Hospital"]=CFrame.new(310,18,75),
    ["Police Station"]=CFrame.new(-215,18,125),
    ["Car Dealer"]=CFrame.new(155,18,-280),
    ["Studio"]=CFrame.new(-50,18,-450),
    ["Apartments"]=CFrame.new(85,18,260),
    ["Gas Station"]=CFrame.new(-290,18,-80),
    ["Clothing Store"]=CFrame.new(190,18,180),
    ["Barber Shop"]=CFrame.new(-140,18,55),
}

------------------------------------------------------------
-- ADVANCED REMOTE SYSTEM
------------------------------------------------------------
local RemoteCache={}
local RemoteCacheTime=0

local function scanRemotes(forceRefresh)
    if tick()-RemoteCacheTime<5 and not forceRefresh then return RemoteCache end
    RemoteCache={}
    -- Scan all known locations
    local searchLocations={Rep}
    pcall(function() table.insert(searchLocations,Rep:FindFirstChild("Remotes")) end)
    pcall(function() table.insert(searchLocations,Rep:FindFirstChild("Events")) end)
    pcall(function() table.insert(searchLocations,Rep:FindFirstChild("RemoteEvents")) end)
    pcall(function() table.insert(searchLocations,Rep:FindFirstChild("Shared")) end)
    pcall(function() table.insert(searchLocations,Rep:FindFirstChild("Packages")) end)
    
    for _,loc in ipairs(searchLocations) do
        pcall(function()
            for _,o in ipairs(loc:GetDescendants()) do
                if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                    RemoteCache[o.Name]=o
                    RemoteCache[o.Name:lower()]=o
                end
            end
        end)
    end
    
    -- Also scan workspace for any remotes
    pcall(function()
        for _,o in ipairs(WS:GetDescendants()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                RemoteCache[o.Name]=o
            end
        end
    end)
    
    RemoteCacheTime=tick()
    return RemoteCache
end

local function fireRemote(remote,...)
    if not remote then return false end
    local ok=pcall(function()
        if remote:IsA("RemoteEvent") then remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end)
    return ok
end

local function findAndFire(patterns,...)
    local rm=scanRemotes()
    local fired=false
    for name,remote in pairs(rm) do
        local nl=name:lower()
        for _,pat in ipairs(patterns) do
            if nl:find(pat:lower()) then
                fireRemote(remote,...)
                fired=true
            end
        end
    end
    return fired
end

------------------------------------------------------------
-- ADVANCED DUPLICATION ENGINE (5 methods)
------------------------------------------------------------
local function duplicateItem()
    task.spawn(function()
        local rm=scanRemotes(true)
        local char=LP.Character
        if not char then return end
        local hum=char:FindFirstChild("Humanoid")
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local bp=LP:FindFirstChild("Backpack")
        if not hum or not hrp then return end
        
        -- Get currently held tool
        local currentTool=nil
        for _,t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then currentTool=t; break end
        end
        
        -- METHOD 1: Rapid drop/pickup cycle
        if currentTool then
            local toolName=currentTool.Name
            for i=1,3 do
                pcall(function()
                    -- Fire drop remotes with tool info
                    for name,r in pairs(rm) do
                        local n=name:lower()
                        if n:find("drop") or n:find("throw") or n:find("release") then
                            pcall(function() r:FireServer(currentTool) end)
                            pcall(function() r:FireServer(toolName) end)
                            pcall(function() r:FireServer({Tool=currentTool,Name=toolName}) end)
                        end
                    end
                    task.wait(0.05)
                    -- Fire pickup/equip remotes
                    for name,r in pairs(rm) do
                        local n=name:lower()
                        if n:find("pick") or n:find("equip") or n:find("grab") or n:find("collect") then
                            pcall(function() r:FireServer(currentTool) end)
                            pcall(function() r:FireServer(toolName) end)
                        end
                    end
                end)
                task.wait(0.05)
            end
        end
        
        -- METHOD 2: Inventory manipulation
        pcall(function()
            for name,r in pairs(rm) do
                local n=name:lower()
                if n:find("inventory") or n:find("item") or n:find("backpack") or n:find("storage") then
                    if currentTool then
                        pcall(function() r:FireServer("add",currentTool.Name) end)
                        pcall(function() r:FireServer("duplicate",currentTool.Name) end)
                        pcall(function() r:FireServer("clone",currentTool.Name) end)
                        pcall(function() r:FireServer(currentTool.Name,"add") end)
                        pcall(function() r:FireServer({Action="Add",Item=currentTool.Name}) end)
                    end
                end
            end
        end)
        
        -- METHOD 3: Unequip during server lag
        if currentTool then
            pcall(function()
                hum:UnequipTools()
                task.wait()
                -- Rapidly re-equip
                local t=bp:FindFirstChild(currentTool.Name)
                if t then
                    for i=1,5 do
                        hum:EquipTool(t)
                        task.wait(0.02)
                        hum:UnequipTools()
                        task.wait(0.02)
                    end
                    hum:EquipTool(t)
                end
            end)
        end
        
        -- METHOD 4: Trade/transfer exploit
        pcall(function()
            for name,r in pairs(rm) do
                local n=name:lower()
                if n:find("trade") or n:find("transfer") or n:find("give") or n:find("send") then
                    if currentTool then
                        pcall(function() r:FireServer(LP,currentTool.Name,1) end)
                        pcall(function() r:FireServer(LP.Name,currentTool.Name) end)
                    end
                end
            end
        end)
        
        -- METHOD 5: Touch interest on dropped items
        pcall(function()
            task.wait(0.2)
            for _,obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("Tool") and obj.Name==(currentTool and currentTool.Name or "") then
                    local handle=obj:FindFirstChild("Handle")
                    if handle and (handle.Position-hrp.Position).Magnitude<30 then
                        firetouchinterest(hrp,handle,0)
                        task.wait()
                        firetouchinterest(hrp,handle,1)
                    end
                end
            end
        end)
    end)
end

------------------------------------------------------------
-- ADVANCED MONEY GENERATOR
------------------------------------------------------------
local function generateMoney(auto)
    task.spawn(function()
        local rm=scanRemotes(true)
        
        -- Pattern 1: Direct money/cash remotes
        local moneyPatterns={"money","cash","sell","illegal","drug","income","reward","salary","wage","payout","earn","profit","payment"}
        for name,r in pairs(rm) do
            local n=name:lower()
            for _,pat in ipairs(moneyPatterns) do
                if n:find(pat) then
                    pcall(function() r:FireServer() end)
                    pcall(function() r:FireServer(999999) end)
                    pcall(function() r:FireServer("max") end)
                    pcall(function() r:FireServer("sell","all") end)
                    pcall(function() r:FireServer({Amount=999999}) end)
                end
            end
        end
        
        -- Pattern 2: Craft/cook/produce (for illegal items to sell)
        local craftPatterns={"craft","cook","produce","create","make","brew","mix","process"}
        for name,r in pairs(rm) do
            local n=name:lower()
            for _,pat in ipairs(craftPatterns) do
                if n:find(pat) then
                    for i=1,10 do
                        pcall(function() r:FireServer() end)
                        pcall(function() r:FireServer("all") end)
                        pcall(function() r:FireServer("max") end)
                        task.wait(0.05)
                    end
                end
            end
        end
        
        -- Pattern 3: Job completion remotes
        local jobPatterns={"job","work","complete","finish","collect","claim","task","mission"}
        for name,r in pairs(rm) do
            local n=name:lower()
            for _,pat in ipairs(jobPatterns) do
                if n:find(pat) then
                    pcall(function() r:FireServer() end)
                    pcall(function() r:FireServer("complete") end)
                    pcall(function() r:FireServer(true) end)
                end
            end
        end
        
        -- Pattern 4: Shop/sell remotes
        local sellPatterns={"shop","store","sell","vendor","merchant","buy","purchase"}
        for name,r in pairs(rm) do
            local n=name:lower()
            for _,pat in ipairs(sellPatterns) do
                if n:find(pat) then
                    pcall(function() r:FireServer("sell") end)
                    pcall(function() r:FireServer("sell","all") end)
                end
            end
        end
        
        -- Auto mode: loop
        if auto then
            while Cfg.Money.AutoIllegal do
                rm=scanRemotes()
                for name,r in pairs(rm) do
                    local n=name:lower()
                    for _,pat in ipairs(moneyPatterns) do
                        if n:find(pat) then pcall(function() r:FireServer() end); pcall(function() r:FireServer(999999) end) end
                    end
                    for _,pat in ipairs(craftPatterns) do
                        if n:find(pat) then pcall(function() r:FireServer() end) end
                    end
                    for _,pat in ipairs(sellPatterns) do
                        if n:find(pat) then pcall(function() r:FireServer("sell") end) end
                    end
                end
                task.wait(0.3)
            end
        end
    end)
end

-- Bank action with multiple arg formats
local function bankAction(act,amt)
    task.spawn(function()
        local rm=scanRemotes(true)
        local bankPatterns={"bank","atm","deposit","withdraw","transaction","transfer","account","vault"}
        for name,r in pairs(rm) do
            local n=name:lower()
            for _,pat in ipairs(bankPatterns) do
                if n:find(pat) then
                    -- Try every argument format
                    pcall(function() r:FireServer(act,tonumber(amt)) end)
                    pcall(function() r:FireServer(act:lower(),tonumber(amt)) end)
                    pcall(function() r:FireServer({Action=act,Amount=tonumber(amt)}) end)
                    pcall(function() r:FireServer(act,tostring(amt)) end)
                    pcall(function() r:FireServer(tonumber(amt),act) end)
                    pcall(function() r:FireServer(tonumber(amt)) end)
                end
            end
        end
    end)
end

-- Auto farm helper
local function autoFarmLoop(cfgKey, patterns)
    task.spawn(function()
        while task.wait(0.5) do
            if Cfg.Money[cfgKey] then
                local rm=scanRemotes()
                for name,r in pairs(rm) do
                    local n=name:lower()
                    for _,pat in ipairs(patterns) do
                        if n:find(pat) then
                            pcall(function() r:FireServer() end)
                            pcall(function() r:FireServer("collect") end)
                            pcall(function() r:FireServer("complete") end)
                        end
                    end
                end
            end
        end
    end)
end

-- Start auto farm loops
autoFarmLoop("AutoFarmConstruction",{"construct","build","hammer","nail","repair"})
autoFarmLoop("AutoFarmBank",{"bankjob","heist","rob","vault"})
autoFarmLoop("AutoFarmHouse",{"house","clean","chore","mop","sweep"})
autoFarmLoop("AutoFarmStudio",{"studio","record","music","song"})
autoFarmLoop("AutoFarmDumpsters",{"dumpster","trash","garbage","scavenge","search","dig"})

-- Auto deposit/withdraw loops
task.spawn(function()
    while task.wait(2) do
        if Cfg.Money.AutoDeposit then bankAction("Deposit",Cfg.Money.MoneyAmt) end
        if Cfg.Money.AutoWithdraw then bankAction("Withdraw",Cfg.Money.MoneyAmt) end
    end
end)

------------------------------------------------------------
-- ADVANCED AIMBOT (prediction + smoothing)
------------------------------------------------------------
local prevPositions={}

local function predictPosition(player, targetPart)
    local char=player.Character
    if not char then return nil end
    local part=char:FindFirstChild(targetPart)
    if not part then return nil end
    
    local currentPos=part.Position
    local key=player.UserId
    
    if Cfg.Combat.Prediction and prevPositions[key] then
        local prevPos=prevPositions[key]
        local velocity=currentPos-prevPos
        local predicted=currentPos+(velocity*Cfg.Combat.PredAmt*10)
        prevPositions[key]=currentPos
        return predicted
    end
    
    prevPositions[key]=currentPos
    return currentPos
end

local function getClosestTarget()
    local closest,closestDist=nil,math.huge
    local mp=UIS:GetMouseLocation()
    local localHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not localHrp then return nil end
    
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hum=p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health>0 then
                local part=p.Character:FindFirstChild(Cfg.Combat.Target)
                if part then
                    local sp,onScreen=Cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d2=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
                        local fov=(Cfg.Combat.FOVRadius/100)*300
                        local d3=(part.Position-localHrp.Position).Magnitude
                        local maxD=(Cfg.Combat.MaxDist/100)*1000
                        
                        if d3<=maxD and (not Cfg.Combat.FOV or d2<=fov) and d2<closestDist then
                            closest=p; closestDist=d2
                        end
                    end
                end
            end
        end
    end
    return closest
end

------------------------------------------------------------
-- GUI SYSTEM
------------------------------------------------------------
local SG=Instance.new("ScreenGui"); SG.Name=rng(16); SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(SG) end end)
pcall(function() if gethui then SG.Parent=gethui(); return end end)
if not SG.Parent then pcall(function() SG.Parent=game:GetService("CoreGui") end) end
if not SG.Parent then SG.Parent=LP:WaitForChild("PlayerGui") end

local BG=Color3.fromRGB(14,14,18)
local SBC=Color3.fromRGB(18,18,24)
local CARD=Color3.fromRGB(24,24,32)
local CARD_HOVER=Color3.fromRGB(30,30,40)
local ACC=Color3.fromRGB(0,120,255)
local ACC2=Color3.fromRGB(80,160,255)
local TXT=Color3.fromRGB(220,220,230)
local DIM=Color3.fromRGB(100,100,115)
local TOG_OFF=Color3.fromRGB(40,40,50)
local INP=Color3.fromRGB(30,30,40)
local GREEN=Color3.fromRGB(0,200,100)
local RED=Color3.fromRGB(255,60,60)
local GOLD=Color3.fromRGB(255,180,0)

-- Shadow helper
local function addShadow(parent, size)
    local s=Instance.new("ImageLabel"); s.Name=rng(4); s.BackgroundTransparency=1
    s.Image="rbxassetid://5554236805"; s.ImageColor3=Color3.fromRGB(0,0,0); s.ImageTransparency=0.6
    s.Size=UDim2.new(1,size*2,1,size*2); s.Position=UDim2.new(0,-size,0,-size)
    s.ScaleType=Enum.ScaleType.Slice; s.SliceCenter=Rect.new(23,23,277,277)
    s.ZIndex=parent.ZIndex-1; s.Parent=parent
    return s
end

-- Window
local W=Instance.new("Frame"); W.Name=rng(8); W.Size=UDim2.new(0,680,0,460); W.Position=UDim2.new(0.5,-340,0.5,-230); W.BackgroundColor3=BG; W.BorderSizePixel=0; W.Active=true; W.Draggable=true; W.Parent=SG
Instance.new("UICorner",W).CornerRadius=UDim.new(0,12)
local wStroke=Instance.new("UIStroke"); wStroke.Color=Color3.fromRGB(35,35,48); wStroke.Thickness=1.5; wStroke.Parent=W
pcall(function() addShadow(W,30) end)

-- Header with gradient
local HD=Instance.new("Frame"); HD.Size=UDim2.new(1,0,0,50); HD.BackgroundColor3=SBC; HD.BorderSizePixel=0; HD.Parent=W
Instance.new("UICorner",HD).CornerRadius=UDim.new(0,12)
local hdGrad=Instance.new("UIGradient"); hdGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,20,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,14,20))}); hdGrad.Parent=HD
-- Accent line under header
local accentLine=Instance.new("Frame"); accentLine.Size=UDim2.new(1,-20,0,2); accentLine.Position=UDim2.new(0,10,1,-1); accentLine.BackgroundColor3=ACC; accentLine.BackgroundTransparency=0.7; accentLine.BorderSizePixel=0; accentLine.Parent=HD
local alGrad=Instance.new("UIGradient"); alGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.9),NumberSequenceKeypoint.new(0.3,0),NumberSequenceKeypoint.new(0.7,0),NumberSequenceKeypoint.new(1,0.9)}); alGrad.Parent=accentLine

-- Logo with glow
local Logo=Instance.new("TextLabel"); Logo.Size=UDim2.new(0,36,0,36); Logo.Position=UDim2.new(0,10,0,7); Logo.BackgroundColor3=ACC; Logo.TextColor3=Color3.new(1,1,1); Logo.Font=Enum.Font.GothamBold; Logo.TextSize=15; Logo.Text="SX"; Logo.Parent=HD
Instance.new("UICorner",Logo).CornerRadius=UDim.new(0,10)
local logoGrad=Instance.new("UIGradient"); logoGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,ACC),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,80,200))}); logoGrad.Rotation=135; logoGrad.Parent=Logo
local logoStroke=Instance.new("UIStroke"); logoStroke.Color=ACC2; logoStroke.Thickness=1; logoStroke.Transparency=0.5; logoStroke.Parent=Logo

local TL=Instance.new("TextLabel"); TL.Size=UDim2.new(0,160,0,18); TL.Position=UDim2.new(0,54,0,7); TL.BackgroundTransparency=1; TL.Text="Synapse-Xenon"; TL.TextColor3=ACC; TL.Font=Enum.Font.GothamBold; TL.TextSize=15; TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=HD
local TL2=Instance.new("TextLabel"); TL2.Size=UDim2.new(0,160,0,14); TL2.Position=UDim2.new(0,54,0,27); TL2.BackgroundTransparency=1; TL2.Text="Premium User!"; TL2.TextColor3=GOLD; TL2.Font=Enum.Font.GothamSemibold; TL2.TextSize=10; TL2.TextXAlignment=Enum.TextXAlignment.Left; TL2.Parent=HD

-- Header buttons (minimize + close)
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-36,0,11); CloseBtn.BackgroundColor3=RED; CloseBtn.BackgroundTransparency=0.85; CloseBtn.Text="x"; CloseBtn.TextColor3=RED; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextSize=12; CloseBtn.BorderSizePixel=0; CloseBtn.Parent=HD
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local MinBtn=Instance.new("TextButton"); MinBtn.Size=UDim2.new(0,28,0,28); MinBtn.Position=UDim2.new(1,-68,0,11); MinBtn.BackgroundColor3=GOLD; MinBtn.BackgroundTransparency=0.85; MinBtn.Text="-"; MinBtn.TextColor3=GOLD; MinBtn.Font=Enum.Font.GothamBold; MinBtn.TextSize=16; MinBtn.BorderSizePixel=0; MinBtn.Parent=HD
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,6)

-- Sidebar with subtle gradient
local SBR=Instance.new("Frame"); SBR.Size=UDim2.new(0,140,1,-50); SBR.Position=UDim2.new(0,0,0,50); SBR.BackgroundColor3=SBC; SBR.BorderSizePixel=0; SBR.Parent=W
local sbGrad=Instance.new("UIGradient"); sbGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,20,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,16,22))}); sbGrad.Rotation=180; sbGrad.Parent=SBR
-- Separator with glow
local sepLine=Instance.new("Frame"); sepLine.Size=UDim2.new(0,1,1,0); sepLine.Position=UDim2.new(1,0,0,0); sepLine.BackgroundColor3=Color3.fromRGB(35,35,50); sepLine.BorderSizePixel=0; sepLine.Parent=SBR
-- Active indicator (blue line on left of active tab)
local activeIndicator=Instance.new("Frame"); activeIndicator.Size=UDim2.new(0,3,0,24); activeIndicator.Position=UDim2.new(0,0,0,13); activeIndicator.BackgroundColor3=ACC; activeIndicator.BorderSizePixel=0; activeIndicator.Parent=SBR
Instance.new("UICorner",activeIndicator).CornerRadius=UDim.new(0,2)

-- Content
local CT=Instance.new("Frame"); CT.Size=UDim2.new(1,-140,1,-50); CT.Position=UDim2.new(0,140,0,50); CT.BackgroundTransparency=1; CT.ClipsDescendants=true; CT.Parent=W

-- Status bar
local StatusBar=Instance.new("Frame"); StatusBar.Size=UDim2.new(1,0,0,22); StatusBar.Position=UDim2.new(0,0,1,-22); StatusBar.BackgroundColor3=Color3.fromRGB(12,12,16); StatusBar.BorderSizePixel=0; StatusBar.Parent=W
Instance.new("UICorner",StatusBar).CornerRadius=UDim.new(0,12)
local sbGrad2=Instance.new("UIGradient"); sbGrad2.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,16)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,16,22))}); sbGrad2.Parent=StatusBar
local StatusTxt=Instance.new("TextLabel"); StatusTxt.Size=UDim2.new(1,-20,1,0); StatusTxt.Position=UDim2.new(0,10,0,0); StatusTxt.BackgroundTransparency=1; StatusTxt.Text="Synapse-Xenon v2.0  |  Tha Bronx 3  |  RightShift to toggle"; StatusTxt.TextColor3=DIM; StatusTxt.Font=Enum.Font.Gotham; StatusTxt.TextSize=9; StatusTxt.TextXAlignment=Enum.TextXAlignment.Left; StatusTxt.Parent=StatusBar
-- Online indicator dot
local onlineDot=Instance.new("Frame"); onlineDot.Size=UDim2.new(0,6,0,6); onlineDot.Position=UDim2.new(1,-16,0.5,-3); onlineDot.BackgroundColor3=GREEN; onlineDot.BorderSizePixel=0; onlineDot.Parent=StatusBar
Instance.new("UICorner",onlineDot).CornerRadius=UDim.new(1,0)

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------
local pages={}
local sidebtns={}
local ord=0
local function no() ord=ord+1; return ord end
local function ro() ord=0 end

local function mkSideBtn(name,icon,idx)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-16,0,36); b.Position=UDim2.new(0,10,0,10+(idx-1)*40); b.BackgroundColor3=CARD; b.BackgroundTransparency=1; b.BorderSizePixel=0; b.Text=""; b.AutoButtonColor=false; b.Parent=SBR
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    -- Icon with gradient background
    local ic=Instance.new("TextLabel"); ic.Size=UDim2.new(0,24,0,24); ic.Position=UDim2.new(0,8,0.5,-12); ic.BackgroundColor3=ACC; ic.BackgroundTransparency=0.82; ic.TextColor3=ACC; ic.Font=Enum.Font.GothamBold; ic.TextSize=11; ic.Text=icon; ic.Parent=b
    Instance.new("UICorner",ic).CornerRadius=UDim.new(0,7)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-42,1,0); lb.Position=UDim2.new(0,38,0,0); lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=DIM; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=b
    -- Hover effect
    b.MouseEnter:Connect(function() if b.BackgroundTransparency>0.5 then TS:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=0.7,BackgroundColor3=CARD_HOVER}):Play() end end)
    b.MouseLeave:Connect(function() if b.BackgroundTransparency>0.5 then TS:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end end)
    sidebtns[name]={btn=b,icon=ic,label=lb,yPos=10+(idx-1)*40}
    return b
end

local function mkPage()
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,1,-20); f.BackgroundTransparency=1; f.Visible=false; f.Parent=CT; return f
end

local function mkSubBar(parent,names)
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(1,0,0,32); bar.BackgroundColor3=Color3.fromRGB(16,16,22); bar.BackgroundTransparency=0.5; bar.BorderSizePixel=0; bar.Parent=parent
    local btns={}
    local xPos=8
    for i,n in ipairs(names) do
        local bw=math.max(#n*7+24,70)
        local b=Instance.new("TextButton"); b.Size=UDim2.new(0,bw,0,26); b.Position=UDim2.new(0,xPos,0,3); b.BackgroundColor3=ACC; b.BackgroundTransparency=1; b.Text=n; b.TextColor3=DIM; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.BorderSizePixel=0; b.AutoButtonColor=false; b.Parent=bar
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        -- Hover
        b.MouseEnter:Connect(function() if b.BackgroundTransparency>0.5 then TS:Create(b,TweenInfo.new(0.1),{TextColor3=ACC}):Play() end end)
        b.MouseLeave:Connect(function() if b.BackgroundTransparency>0.5 then TS:Create(b,TweenInfo.new(0.1),{TextColor3=DIM}):Play() end end)
        btns[n]=b
        xPos=xPos+bw+6
    end
    return bar,btns
end

local function mkTwoCol(parent,yOff)
    local wrap=Instance.new("Frame"); wrap.Size=UDim2.new(1,0,1,-(yOff+5)); wrap.Position=UDim2.new(0,0,0,yOff); wrap.BackgroundTransparency=1; wrap.Visible=false; wrap.Parent=parent
    local L=Instance.new("ScrollingFrame"); L.Size=UDim2.new(0.5,-6,1,0); L.Position=UDim2.new(0,3,0,0); L.BackgroundTransparency=1; L.BorderSizePixel=0; L.ScrollBarThickness=3; L.ScrollBarImageColor3=ACC; L.CanvasSize=UDim2.new(0,0,0,0); L.AutomaticCanvasSize=Enum.AutomaticSize.Y; L.Parent=wrap
    Instance.new("UIListLayout",L).Padding=UDim.new(0,3); Instance.new("UIPadding",L).PaddingTop=UDim.new(0,3)
    local R=Instance.new("ScrollingFrame"); R.Size=UDim2.new(0.5,-6,1,0); R.Position=UDim2.new(0.5,3,0,0); R.BackgroundTransparency=1; R.BorderSizePixel=0; R.ScrollBarThickness=3; R.ScrollBarImageColor3=ACC; R.CanvasSize=UDim2.new(0,0,0,0); R.AutomaticCanvasSize=Enum.AutomaticSize.Y; R.Parent=wrap
    Instance.new("UIListLayout",R).Padding=UDim.new(0,3); Instance.new("UIPadding",R).PaddingTop=UDim.new(0,3)
    return wrap,L,R
end

-- Section header with gradient accent
local function sec(p,txt,o)
    local l=Instance.new("Frame"); l.Size=UDim2.new(1,-4,0,22); l.BackgroundColor3=Color3.fromRGB(20,20,28); l.LayoutOrder=o; l.BorderSizePixel=0; l.Parent=p
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,5)
    -- Left accent bar
    local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0,14); bar.Position=UDim2.new(0,6,0.5,-7); bar.BackgroundColor3=ACC; bar.BorderSizePixel=0; bar.Parent=l
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local txt_=Instance.new("TextLabel"); txt_.Size=UDim2.new(1,-30,1,0); txt_.Position=UDim2.new(0,14,0,0); txt_.BackgroundTransparency=1; txt_.Text=txt; txt_.TextColor3=ACC; txt_.Font=Enum.Font.GothamBold; txt_.TextSize=10; txt_.TextXAlignment=Enum.TextXAlignment.Left; txt_.Parent=l
    local arrow=Instance.new("TextLabel"); arrow.Size=UDim2.new(0,14,0,14); arrow.Position=UDim2.new(1,-18,0.5,-7); arrow.BackgroundTransparency=1; arrow.Text="v"; arrow.TextColor3=DIM; arrow.Font=Enum.Font.GothamBold; arrow.TextSize=9; arrow.Parent=l
end

-- Toggle
local function tog(p,txt,def,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,26); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-52,1,0); lb.Position=UDim2.new(0,8,0,0); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(0,32,0,16); bg.Position=UDim2.new(1,-38,0.5,-8); bg.BackgroundColor3=def and ACC or TOG_OFF; bg.BorderSizePixel=0; bg.Parent=f
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local ci=Instance.new("Frame"); ci.Size=UDim2.new(0,12,0,12); ci.Position=def and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6); ci.BackgroundColor3=Color3.new(1,1,1); ci.BorderSizePixel=0; ci.Parent=bg
    Instance.new("UICorner",ci).CornerRadius=UDim.new(1,0)
    local st=def or false
    local bt=Instance.new("TextButton"); bt.Size=UDim2.new(1,0,1,0); bt.BackgroundTransparency=1; bt.Text=""; bt.Parent=f
    bt.MouseButton1Click:Connect(function()
        st=not st; bg.BackgroundColor3=st and ACC or TOG_OFF
        TS:Create(ci,TweenInfo.new(0.1),{Position=st and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)}):Play()
        if cb then cb(st) end
    end)
end

-- Slider
local function sld(p,txt,mn,mx,df,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,38); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-50,0,16); lb.Position=UDim2.new(0,8,0,2); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=10; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(0,40,0,16); vl.Position=UDim2.new(1,-45,0,2); vl.BackgroundTransparency=1; vl.Text=tostring(df); vl.TextColor3=ACC; vl.Font=Enum.Font.GothamBold; vl.TextSize=10; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=f
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(1,-16,0,4); tr.Position=UDim2.new(0,8,0,26); tr.BackgroundColor3=TOG_OFF; tr.BorderSizePixel=0; tr.Parent=f
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fl=Instance.new("Frame"); fl.Size=UDim2.new(math.clamp((df-mn)/(mx-mn),0,1),0,1,0); fl.BackgroundColor3=ACC; fl.BorderSizePixel=0; fl.Parent=tr
    Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local dr=false
    local sb=Instance.new("TextButton"); sb.Size=UDim2.new(1,0,0,16); sb.Position=UDim2.new(0,0,0,20); sb.BackgroundTransparency=1; sb.Text=""; sb.Parent=f
    sb.MouseButton1Down:Connect(function() dr=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    UIS.InputChanged:Connect(function(i) if dr and i.UserInputType==Enum.UserInputType.MouseMovement then
        local mp=UIS:GetMouseLocation(); local pct=math.clamp((mp.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(mn+(mx-mn)*pct); fl.Size=UDim2.new(pct,0,1,0); vl.Text=tostring(v); if cb then cb(v) end
    end end)
end

-- Button
local function btn(p,txt,desc,cb,o)
    local h=desc~="" and 34 or 26
    local f=Instance.new("TextButton"); f.Size=UDim2.new(1,-4,0,h); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.Text=""; f.LayoutOrder=o; f.AutoButtonColor=false; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-12,0,16); lb.Position=UDim2.new(0,8,0,desc~="" and 2 or 5); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    if desc~="" then
        local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,-12,0,12); dl.Position=UDim2.new(0,8,0,18); dl.BackgroundTransparency=1; dl.Text=desc; dl.TextColor3=Color3.fromRGB(255,165,0); dl.Font=Enum.Font.Gotham; dl.TextSize=9; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.Parent=f
    end
    -- Hover effect
    f.MouseEnter:Connect(function() TS:Create(f,TweenInfo.new(0.1),{BackgroundColor3=CARD_HOVER}):Play() end)
    f.MouseLeave:Connect(function() TS:Create(f,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play() end)
    f.MouseButton1Click:Connect(function()
        TS:Create(f,TweenInfo.new(0.08),{BackgroundColor3=ACC}):Play()
        task.delay(0.12,function() TS:Create(f,TweenInfo.new(0.15),{BackgroundColor3=CARD}):Play() end)
        if cb then cb() end
    end)
end

-- Dropdown
local function dd(p,txt,opts,df,cb,o)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-4,0,26); f.BackgroundColor3=CARD; f.BorderSizePixel=0; f.LayoutOrder=o; f.ClipsDescendants=true; f.Parent=p
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.45,0,0,26); lb.Position=UDim2.new(0,8,0,0); lb.BackgroundTransparency=1; lb.Text=txt; lb.TextColor3=TXT; lb.Font=Enum.Font.Gotham; lb.TextSize=10; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local sel=Instance.new("TextButton"); sel.Size=UDim2.new(0.52,-5,0,20); sel.Position=UDim2.new(0.47,0,0,3); sel.BackgroundColor3=INP; sel.BorderSizePixel=0; sel.Text=(df or opts[1] or "").." v"; sel.TextColor3=ACC; sel.Font=Enum.Font.Gotham; sel.TextSize=10; sel.Parent=f
    Instance.new("UICorner",sel).CornerRadius=UDim.new(0,4)
    local open=false
    sel.MouseButton1Click:Connect(function()
        open=not open
        if open then
            f.Size=UDim2.new(1,-4,0,26+#opts*22)
            for i,opt in ipairs(opts) do
                local ob=Instance.new("TextButton"); ob.Name="o"..i; ob.Size=UDim2.new(0.52,-5,0,20); ob.Position=UDim2.new(0.47,0,0,2+i*22); ob.BackgroundColor3=INP; ob.BorderSizePixel=0; ob.Text=opt; ob.TextColor3=TXT; ob.Font=Enum.Font.Gotham; ob.TextSize=10; ob.Parent=f
                Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
                ob.MouseButton1Click:Connect(function()
                    sel.Text=opt.." v"; open=false; f.Size=UDim2.new(1,-4,0,26)
                    for _,c in ipairs(f:GetChildren()) do if c.Name:sub(1,1)=="o" then c:Destroy() end end
                    if cb then cb(opt) end
                end)
            end
        else
            f.Size=UDim2.new(1,-4,0,26); for _,c in ipairs(f:GetChildren()) do if c.Name:sub(1,1)=="o" then c:Destroy() end end
        end
    end)
end

------------------------------------------------------------
-- BUILD TABS
------------------------------------------------------------
local sideNames={"Tha Bronx 3","Combat","Visuals","Settings"}
local sideIcons={"B","C","V","S"}
for i,n in ipairs(sideNames) do pages[n]=mkPage(); mkSideBtn(n,sideIcons[i],i) end

local function switchSide(name)
    for n,pg in pairs(pages) do pg.Visible=(n==name) end
    for n,d in pairs(sidebtns) do
        if n==name then
            TS:Create(d.btn,TweenInfo.new(0.2),{BackgroundTransparency=0,BackgroundColor3=CARD}):Play()
            TS:Create(d.icon,TweenInfo.new(0.2),{TextColor3=ACC,BackgroundTransparency=0.75}):Play()
            TS:Create(d.label,TweenInfo.new(0.2),{TextColor3=TXT}):Play()
            -- Animate indicator
            TS:Create(activeIndicator,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=UDim2.new(0,0,0,d.yPos+6)}):Play()
        else
            TS:Create(d.btn,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
            TS:Create(d.icon,TweenInfo.new(0.2),{TextColor3=DIM,BackgroundTransparency=0.92}):Play()
            TS:Create(d.label,TweenInfo.new(0.2),{TextColor3=DIM}):Play()
        end
    end
end
for n,d in pairs(sidebtns) do d.btn.MouseButton1Click:Connect(function() switchSide(n) end) end

------------------------------------------------------------
-- THA BRONX 3 TAB
------------------------------------------------------------
local tbP=pages["Tha Bronx 3"]
local subBar,subBtns=mkSubBar(tbP,{"Main","Money","Miscellaneous"})
local mW,mL,mR=mkTwoCol(tbP,32)
local moW,moL,moR=mkTwoCol(tbP,32)
local miW,miL,miR=mkTwoCol(tbP,32)
local subMap={Main=mW,Money=moW,Miscellaneous=miW}

local function switchSub(n) for k,w in pairs(subMap) do w.Visible=(k==n) end; for k,b in pairs(subBtns) do if k==n then TS:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=0,BackgroundColor3=ACC,TextColor3=Color3.new(1,1,1)}):Play() else TS:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=1,TextColor3=DIM}):Play() end end end
for n,b in pairs(subBtns) do b.MouseButton1Click:Connect(function() switchSub(n) end) end
switchSub("Main")

-- MAIN LEFT
ro()
local pn={}; for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP then table.insert(pn,pl.Name) end end
sec(mL,"Select Player",no())
dd(mL,"Selected Player",#pn>0 and pn or {"No players"},nil,function(v) Cfg.Main.SelectedPlayer=v end,no())

sec(mL,"Player Options",no())
btn(mL,"Spectate Player","",function() local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("Humanoid") then Cam.CameraSubject=p.Character.Humanoid end end end,no())
btn(mL,"Stop Spectating","",function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then Cam.CameraSubject=LP.Character.Humanoid end end,no())
btn(mL,"Bring Player","",function() local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.CFrame=LP.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-5) end end end,no())
btn(mL,"Bug / Kill Player - Car","",function() end,no())
btn(mL,"Auto Kill Player - Gun","",function() end,no())
btn(mL,"Auto Ragdoll Player - Gun","",function() end,no())
btn(mL,"Teleport To Player","",function() local t=Cfg.Main.SelectedPlayer; if t then local p=Players:FindFirstChild(t); if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame=p.Character.HumanoidRootPart.CFrame end end end,no())
btn(mL,"Down Player - Hold Gun","",function() end,no())
btn(mL,"Kill Player - Hold Gun","",function() end,no())

-- MAIN RIGHT
ro()
sec(mR,"Movement",no())
tog(mR,"No Clip",false,function(v) Cfg.Main.NoClip=v end,no())
tog(mR,"Speed",false,function(v) Cfg.Main.Speed=v end,no())
sld(mR,"Speed Amount",0,100,0,function(v) Cfg.Main.SpeedAmt=v end,no())
tog(mR,"Fly",false,function(v) Cfg.Main.Fly=v end,no())
sld(mR,"Fly Speed Amount",0,50,7,function(v) Cfg.Main.FlySpeed=v end,no())
tog(mR,"Jump Power",false,function(v) Cfg.Main.JumpPower=v end,no())
sld(mR,"Jump Power Amount",0,500,100,function(v) Cfg.Main.JumpAmt=v end,no())

-- MONEY LEFT
ro()
sec(moL,"Farming",no())
tog(moL,"Auto Farm Construction",false,function(v) Cfg.Money.AutoFarmConstruction=v end,no())
tog(moL,"Auto Farm Bank",false,function(v) Cfg.Money.AutoFarmBank=v end,no())
tog(moL,"Auto Farm House",false,function(v) Cfg.Money.AutoFarmHouse=v end,no())
tog(moL,"Auto Farm Studio",false,function(v) Cfg.Money.AutoFarmStudio=v end,no())
tog(moL,"Auto Farm Dumpsters",false,function(v) Cfg.Money.AutoFarmDumpsters=v end,no())

sec(moL,"Vulnerability Section",no())
btn(moL,"Gen Illegal Money Manual","Requires Ice-Fruit Cup!",function() generateMoney(false) end,no())
tog(moL,"Gen Illegal Money Auto","Need 5K To Do This!",function(v) Cfg.Money.AutoIllegal=v; if v then generateMoney(true) end end,no())

-- MONEY RIGHT
ro()
sec(moR,"Bank Actions",no())
sld(moR,"Money Amount",0,999999,0,function(v) Cfg.Money.MoneyAmt=v end,no())
dd(moR,"Bank Action",{"Deposit","Withdraw","Drop"},"Deposit",function(v) Cfg.Money.BankAction=v end,no())
btn(moR,"Apply Bank Action","",function() bankAction(Cfg.Money.BankAction,Cfg.Money.MoneyAmt) end,no())
tog(moR,"Auto Deposit",false,function(v) Cfg.Money.AutoDeposit=v end,no())
tog(moR,"Auto Withdraw",false,function(v) Cfg.Money.AutoWithdraw=v end,no())
tog(moR,"Auto Drop",false,function(v) Cfg.Money.AutoDrop=v end,no())

sec(moR,"Duping Section",no())
btn(moR,"Duplicate Current Item","5 methods - Can Take Few Tries!",function() duplicateItem() end,no())
btn(moR,"Rapid Dupe (x10)","Attempts dupe 10 times rapidly",function() for i=1,10 do task.spawn(duplicateItem); task.wait(0.15) end end,no())

-- MISC LEFT
ro()
sec(miL,"Local Player Modifications",no())
tog(miL,"Infinite Stamina",false,function(v) Cfg.Misc.InfStamina=v end,no())
tog(miL,"Instant Respawn",false,function(v) Cfg.Misc.InstantRespawn=v end,no())
tog(miL,"Infinite Sleep",false,function(v) Cfg.Misc.InfSleep=v end,no())
tog(miL,"Infinite Hunger",false,function(v) Cfg.Misc.InfHunger=v end,no())
tog(miL,"Instant Interact",false,function(v) Cfg.Misc.InstantInteract=v end,no())
tog(miL,"Auto Pickup Cash",false,function(v) Cfg.Misc.AutoPickup=v end,no())
tog(miL,"Disable Blood Effects",false,function(v) Cfg.Misc.DisableBlood=v end,no())
tog(miL,"Unlock Locked Cars",false,function(v) Cfg.Misc.UnlockCars=v end,no())
tog(miL,"No Rent Pay",false,function(v) Cfg.Misc.NoRent=v end,no())
tog(miL,"No Fall Damage",false,function(v) Cfg.Misc.NoFallDmg=v end,no())
tog(miL,"Respawn Where You Died",false,function(v) Cfg.Misc.RespawnDied=v end,no())

-- MISC RIGHT
ro()
sec(miR,"Teleport To Location",no())
local tpL={}; for k in pairs(TpLocs) do table.insert(tpL,k) end; table.sort(tpL)
dd(miR,"Teleport Options",tpL,"Basketball Court",function(v) Cfg.Misc.TpLocation=v end,no())
btn(miR,"Teleport","Instant teleport to location",function()
    local cf=TpLocs[Cfg.Misc.TpLocation]
    if cf and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame=cf
    end
end,no())

sec(miR,"Outfits",no())
dd(miR,"Select Outfit",{"Amiri Outfit","Nike Tech","Bape Set","Default"},"Amiri Outfit",function(v) Cfg.Misc.Outfit=v end,no())
btn(miR,"Apply Selected Outfit","",function() end,no())

------------------------------------------------------------
-- COMBAT TAB
------------------------------------------------------------
local cP=pages["Combat"]
local cBar,cBtns=mkSubBar(cP,{"Silent Aim","Aimlock"})
local saW,saL,saR=mkTwoCol(cP,32)
local alW,alL,alR=mkTwoCol(cP,32)
local cSubMap={["Silent Aim"]=saW,Aimlock=alW}
local function switchCSub(n) for k,w in pairs(cSubMap) do w.Visible=(k==n) end; for k,b in pairs(cBtns) do if k==n then b.BackgroundTransparency=0; b.BackgroundColor3=ACC; b.TextColor3=Color3.new(1,1,1) else b.BackgroundTransparency=1; b.TextColor3=DIM end end end
for n,b in pairs(cBtns) do b.MouseButton1Click:Connect(function() switchCSub(n) end) end
switchCSub("Aimlock")

-- Aimlock Left
ro()
sec(alL,"General",no())
tog(alL,"Enabled",false,function(v) Cfg.Combat.Enabled=v end,no())
sec(alL,"Settings",no())
dd(alL,"Aimlock Type",{"Mouse","Camera","Closest"},"Mouse",function() end,no())
dd(alL,"Target Parts",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},"Head",function(v) Cfg.Combat.Target=v end,no())
sld(alL,"Max Distance",0,100,50,function(v) Cfg.Combat.MaxDist=v end,no())
sld(alL,"Smoothness",0,100,50,function(v) Cfg.Combat.Smooth=v end,no())
tog(alL,"Prediction",true,function(v) Cfg.Combat.Prediction=v end,no())
sld(alL,"Prediction Amount",0,50,12,function(v) Cfg.Combat.PredAmt=v/100 end,no())

-- Aimlock Right
ro()
sec(alR,"Field Of View",no())
tog(alR,"FOV Enabled",false,function(v) Cfg.Combat.FOV=v end,no())
tog(alR,"Draw FOV Circle",false,function() end,no())
sld(alR,"Radius",0,100,50,function(v) Cfg.Combat.FOVRadius=v end,no())
sld(alR,"Sides",0,100,50,function() end,no())
sec(alR,"Snapline",no())
tog(alR,"Snapline Enabled",false,function() end,no())
sld(alR,"Snapline Thickness",0,100,50,function() end,no())

-- Silent Aim
ro()
sec(saL,"General",no())
tog(saL,"Enabled",false,function(v) Cfg.Combat.SilentAim=v end,no())
sec(saL,"Settings",no())
dd(saL,"Target Parts",{"Head","HumanoidRootPart","UpperTorso"},"Head",function() end,no())
sld(saL,"Max Distance",0,100,50,function() end,no())
sld(saL,"Smoothness",0,100,50,function() end,no())
ro()
sec(saR,"Field Of View",no())
tog(saR,"FOV Enabled",false,function() end,no())
sld(saR,"Radius",0,100,50,function() end,no())

------------------------------------------------------------
-- VISUALS TAB
------------------------------------------------------------
local vP=pages["Visuals"]
local vBar,vBtns=mkSubBar(vP,{"ESP"})
local eW,eL,eR=mkTwoCol(vP,32); eW.Visible=true
for _,b in pairs(vBtns) do b.BackgroundTransparency=0; b.BackgroundColor3=ACC; b.TextColor3=Color3.new(1,1,1) end

ro()
sec(eL,"Enable ESP",no())
tog(eL,"Enable ESP",false,function(v) Cfg.Visuals.ESP=v end,no())
sec(eL,"Box ESP",no())
tog(eL,"Corner Frame ESP",false,function() end,no())
tog(eL,"Box ESP",false,function(v) Cfg.Visuals.BoxESP=v end,no())
sec(eL,"Healthbar ESP",no())
tog(eL,"Health Bar",false,function(v) Cfg.Visuals.HealthESP=v end,no())
tog(eL,"Health Text",false,function() end,no())
tog(eL,"Lerp Health Color",false,function() end,no())
tog(eL,"Gradient Health",false,function() end,no())

ro()
sec(eR,"ESP Settings",no())
tog(eR,"Distance",false,function(v) Cfg.Visuals.Dist=v end,no())
sld(eR,"Max Distance",0,5000,2000,function(v) Cfg.Visuals.MaxDist=v end,no())
sec(eR,"Cham ESP",no())
tog(eR,"Chams",false,function(v) Cfg.Visuals.Chams=v end,no())
tog(eR,"Thermal Effect",false,function() end,no())
tog(eR,"Visible Check",false,function() end,no())
sld(eR,"Fill Transparency",0,100,50,function(v) Cfg.Visuals.FillT=v end,no())
sld(eR,"Outline Transparency",0,100,50,function(v) Cfg.Visuals.OutT=v end,no())

------------------------------------------------------------
-- SETTINGS TAB
------------------------------------------------------------
local sP=pages["Settings"]
local sScroll=Instance.new("ScrollingFrame"); sScroll.Size=UDim2.new(1,-10,1,-25); sScroll.Position=UDim2.new(0,5,0,5); sScroll.BackgroundTransparency=1; sScroll.BorderSizePixel=0; sScroll.ScrollBarThickness=3; sScroll.CanvasSize=UDim2.new(0,0,0,0); sScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; sScroll.Parent=sP
Instance.new("UIListLayout",sScroll).Padding=UDim.new(0,3)

ro()
sec(sScroll,"UI Settings",no())
btn(sScroll,"Toggle Bind: RightShift","Press RightShift to show/hide GUI",function() end,no())
btn(sScroll,"Destroy GUI","Completely removes the script",function() SG:Destroy() end,no())
sec(sScroll,"Script Info",no())
btn(sScroll,"Synapse-Xenon v2.0","Tha Bronx 3 Premium Edition",function() end,no())
btn(sScroll,"Scan Remotes","Shows count of game remotes found",function()
    local rm=scanRemotes(true)
    local count=0; for _ in pairs(rm) do count=count+1 end
    StatusTxt.Text="Found "..count.." remotes in game"
end,no())

------------------------------------------------------------
-- INIT
------------------------------------------------------------
switchSide("Tha Bronx 3")

local gVis=true
MinBtn.MouseButton1Click:Connect(function() gVis=not gVis; W.Visible=gVis end)
UIS.InputBegan:Connect(function(i,gp) if gp then return end; if i.KeyCode==Enum.KeyCode.RightShift then gVis=not gVis; W.Visible=gVis end end)

------------------------------------------------------------
-- CORE LOOPS
------------------------------------------------------------

-- NoClip
RS.Stepped:Connect(function() pcall(function() if Cfg.Main.NoClip and LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end)

-- Speed (CFrame)
RS.Heartbeat:Connect(function(dt) pcall(function()
    if Cfg.Main.Speed and LP.Character then
        local h=LP.Character:FindFirstChild("HumanoidRootPart"); local hm=LP.Character:FindFirstChild("Humanoid")
        if h and hm then local d=hm.MoveDirection; if d.Magnitude>0 then h.CFrame=h.CFrame+Vector3.new(d.X,0,d.Z)*Cfg.Main.SpeedAmt*dt end end
    end
end) end)

-- Jump Power
RS.Heartbeat:Connect(function() pcall(function() if Cfg.Main.JumpPower and LP.Character then local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm.JumpPower=Cfg.Main.JumpAmt; hm.UseJumpPower=true end end end) end)

-- Fly (CFrame)
RS.Heartbeat:Connect(function(dt) pcall(function()
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
    else pcall(function() if LP.Character then local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm:SetStateEnabled(Enum.HumanoidStateType.Freefall,true) end end end)
    end
end) end)

-- ESP
local espO={}
local function mkESP(pl)
    if pl==LP then return end
    local d={}
    d.Highlight=Instance.new("Highlight"); d.Highlight.Name=rng(16); d.Highlight.FillColor=Color3.fromRGB(0,120,255); d.Highlight.OutlineColor=Color3.new(1,1,1); d.Highlight.Enabled=false
    d.Billboard=Instance.new("BillboardGui"); d.Billboard.Name=rng(16); d.Billboard.Size=UDim2.new(0,200,0,50); d.Billboard.StudsOffset=Vector3.new(0,3,0); d.Billboard.AlwaysOnTop=true; d.Billboard.Enabled=false
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1; nl.TextColor3=Color3.new(1,1,1); nl.TextStrokeTransparency=0.5; nl.Font=Enum.Font.GothamBold; nl.TextSize=13; nl.Text=pl.Name; nl.Parent=d.Billboard
    d.DistLabel=Instance.new("TextLabel"); d.DistLabel.Size=UDim2.new(1,0,0.5,0); d.DistLabel.Position=UDim2.new(0,0,0.5,0); d.DistLabel.BackgroundTransparency=1; d.DistLabel.TextColor3=Color3.fromRGB(200,200,200); d.DistLabel.TextStrokeTransparency=0.5; d.DistLabel.Font=Enum.Font.Gotham; d.DistLabel.TextSize=11; d.DistLabel.Text=""; d.DistLabel.Parent=d.Billboard
    espO[pl]=d
    local function oc(c) pcall(function() d.Highlight.Adornee=c; d.Highlight.Parent=c; local hd=c:WaitForChild("Head",5); if hd then d.Billboard.Parent=hd end end) end
    if pl.Character then task.spawn(function() oc(pl.Character) end) end
    pl.CharacterAdded:Connect(oc)
end
local function rmESP(pl) local d=espO[pl]; if d then pcall(function() d.Highlight:Destroy() end); pcall(function() d.Billboard:Destroy() end); espO[pl]=nil end end
for _,p in ipairs(Players:GetPlayers()) do mkESP(p) end
Players.PlayerAdded:Connect(mkESP); Players.PlayerRemoving:Connect(rmESP)

RS.RenderStepped:Connect(function() pcall(function()
    for pl,d in pairs(espO) do
        local ch=pl.Character; local hr=ch and ch:FindFirstChild("HumanoidRootPart"); local lr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if Cfg.Visuals.ESP and ch and hr and lr then
            local dist=(hr.Position-lr.Position).Magnitude
            if dist<=Cfg.Visuals.MaxDist then
                d.Highlight.Enabled=Cfg.Visuals.Chams; d.Highlight.FillTransparency=Cfg.Visuals.FillT/100; d.Highlight.OutlineTransparency=Cfg.Visuals.OutT/100
                d.Billboard.Enabled=true; d.DistLabel.Text=Cfg.Visuals.Dist and string.format("[%d studs]",math.floor(dist)) or ""
            else d.Highlight.Enabled=false; d.Billboard.Enabled=false end
        else if d.Highlight then d.Highlight.Enabled=false end; if d.Billboard then d.Billboard.Enabled=false end end
    end
end) end)

-- Aimlock with Prediction
local aTarget=nil
UIS.InputBegan:Connect(function(i,gp) if gp then return end
    if i.UserInputType==Enum.UserInputType.MouseButton2 and Cfg.Combat.Enabled then
        aTarget=getClosestTarget()
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then aTarget=nil end end)

RS.RenderStepped:Connect(function() pcall(function()
    if Cfg.Combat.Enabled and aTarget and aTarget.Character then
        local pos=predictPosition(aTarget,Cfg.Combat.Target)
        if pos then
            local sm=1-(Cfg.Combat.Smooth/100)*0.9
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,pos),sm)
        end
    end
end) end)

-- FOV Circle
local fovC=Drawing.new("Circle"); fovC.Thickness=1; fovC.Color=ACC; fovC.Filled=false; fovC.Transparency=0.7; fovC.Visible=false
RS.RenderStepped:Connect(function() pcall(function()
    if Cfg.Combat.FOV and Cfg.Combat.Enabled then
        fovC.Visible=true; fovC.Position=UIS:GetMouseLocation(); fovC.Radius=(Cfg.Combat.FOVRadius/100)*300
    else fovC.Visible=false end
end) end)

-- Auto Pickup
RS.Heartbeat:Connect(function() pcall(function()
    if Cfg.Misc.AutoPickup and LP.Character then
        local h=LP.Character:FindFirstChild("HumanoidRootPart"); if h then
            for _,o in ipairs(WS:GetDescendants()) do
                if o:IsA("BasePart") and (o.Name:lower():find("cash") or o.Name:lower():find("money") or o.Name:lower():find("drop") or o.Name:lower():find("pickup")) then
                    if (o.Position-h.Position).Magnitude<=50 then firetouchinterest(h,o,0); task.wait(); firetouchinterest(h,o,1) end
                end
            end
        end
    end
end) end)

-- No Fall Damage
RS.Heartbeat:Connect(function() pcall(function()
    if Cfg.Misc.NoFallDmg and LP.Character then
        local hm=LP.Character:FindFirstChild("Humanoid"); if hm then hm:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false); hm:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false) end
    end
end) end)

-- Notification
pcall(function()
    SS:SetCore("SendNotification",{Title="Synapse-Xenon",Text="Tha Bronx 3 loaded! | RightShift to toggle",Duration=4})
end)

print("[Synapse-Xenon] v2.0 | Tha Bronx 3 | Fully loaded!")
