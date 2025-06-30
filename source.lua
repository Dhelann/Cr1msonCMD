if not _G.CR1MSON_LOADED then _G.CR1MSON_LOADED=true
if typeof(task)~="table"or not task.wait then task={}task.wait=wait task.spawn=function(f)coroutine.wrap(f)()end end
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/Dhelann/Cr1msonCMD/refs/heads/main/loader.lua"))()end)
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local TeleportService=game:GetService("TeleportService")
local HttpService=game:GetService("HttpService")
local cr1mFlyStates={wasdfly={active=false,bg=nil,bv=nil,conn1=nil,conn2=nil},mfly={active=false,bv=nil,bg=nil,renderConn=nil}}
local cr1mNoclipConn
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local function split(txt)
local args={}for word in txt:gmatch("%S+")do table.insert(args,word)end
return args
end
local commandHandlers={}
commandHandlers.fly=function(args)
if cr1mFlyStates.fly and cr1mFlyStates.fly.active then return end
local state={active=true,bg=nil,bv=nil,renderConn=nil,conn1=nil,conn2=nil}
cr1mFlyStates.fly=state
local SPEED=1
local lp=Players.LocalPlayer
local cam=workspace.CurrentCamera
local root=lp.Character and (lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso"))
if not root then repeat task.wait() until lp.Character and (lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso")) root=lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso")end
state.bg=Instance.new("BodyGyro",root)
state.bg.P=9e4
state.bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
state.bg.CFrame=root.CFrame
state.bv=Instance.new("BodyVelocity",root)
state.bv.Velocity=Vector3.zero
state.bv.MaxForce=Vector3.new(9e9,9e9,9e9)
local control={F=0,B=0,L=0,R=0,Q=0,E=0}
state.conn1=UIS.InputBegan:Connect(function(input,gpe)
if gpe then return end
if input.KeyCode==Enum.KeyCode.W then control.F=SPEED end
if input.KeyCode==Enum.KeyCode.S then control.B=-SPEED end
if input.KeyCode==Enum.KeyCode.A then control.L=-SPEED end
if input.KeyCode==Enum.KeyCode.D then control.R=SPEED end
if input.KeyCode==Enum.KeyCode.Q then control.E=-SPEED*2 end
if input.KeyCode==Enum.KeyCode.E then control.Q=SPEED*2 end
end)
state.conn2=UIS.InputEnded:Connect(function(input)
if input.KeyCode==Enum.KeyCode.W then control.F=0 end
if input.KeyCode==Enum.KeyCode.S then control.B=0 end
if input.KeyCode==Enum.KeyCode.A then control.L=0 end
if input.KeyCode==Enum.KeyCode.D then control.R=0 end
if input.KeyCode==Enum.KeyCode.Q then control.E=0 end
if input.KeyCode==Enum.KeyCode.E then control.Q=0 end
end)
local ctrlMod
pcall(function()
ctrlMod=require(lp.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
end)
state.renderConn=RunService.RenderStepped:Connect(function()
if not state.active then return end
local moveVec=Vector3.zero
if ctrlMod then moveVec=ctrlMod:GetMoveVector()end
local joyDir=Vector3.zero
if moveVec.Magnitude>0 then joyDir=cam.CFrame.RightVector*moveVec.X+cam.CFrame.LookVector*-moveVec.Z end
local keyDir=Vector3.zero
keyDir=keyDir+cam.CFrame.LookVector*(control.F+control.B)
keyDir=keyDir+cam.CFrame.RightVector*(control.L+control.R)
keyDir=keyDir+cam.CFrame.UpVector*((control.Q+control.E)*0.5)
local dir=joyDir+keyDir
local mag=dir.Magnitude
local flySpeed=(mag>0)and 50 or 0
if mag>0 then dir=dir.Unit end
state.bv.Velocity=dir*flySpeed
state.bg.CFrame=cam.CFrame
local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=state.active end
end)
end
commandHandlers.unfly=function(args)
local state=cr1mFlyStates.fly
if state and state.active then
state.active=false
if state.bv then state.bv:Destroy()state.bv=nil end
if state.bg then state.bg:Destroy()state.bg=nil end
if state.renderConn then state.renderConn:Disconnect()state.renderConn=nil end
if state.conn1 then state.conn1:Disconnect()state.conn1=nil end
if state.conn2 then state.conn2:Disconnect()state.conn2=nil end
local hum=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=false end
end
end
commandHandlers.infjump=function(args)
local plyr=game:GetService("Players").LocalPlayer
local chr=plyr.Character or plyr.CharacterAdded:Wait()
local root=chr:WaitForChild("HumanoidRootPart")
local AirWalkPart=Instance.new("Part")
AirWalkPart.Size=Vector3.new(7,1,3)
AirWalkPart.Transparency=1
AirWalkPart.Anchored=true
AirWalkPart.CanCollide=true
AirWalkPart.Name="Fuck gravity to the moon we go"
AirWalkPart.Parent=workspace
game:GetService("RunService").RenderStepped:Connect(function()
AirWalkPart.CFrame=root.CFrame*CFrame.new(0,-4,0)
end)
end
commandHandlers.uninfjump=function(args)
for i,v in pairs(workspace:GetChildren())do
if tostring(v)=="Fuck gravity to the moon we go"then
v:Destroy()
end
end
end
commandHandlers.lay=function(args)
local layPlr=Players.LocalPlayer
local layChar=layPlr.Character or layPlr.CharacterAdded:Wait()
local layHum=layChar:WaitForChild("Humanoid")
local layHrp=layChar:WaitForChild("HumanoidRootPart")
local laying=true
local layResult=workspace:Raycast(layHrp.Position,Vector3.new(0,-20,0),RaycastParams.new())
if layResult then
local groundY=layResult.Position.Y
local hrpY=layHrp.Size.Y/2
layHrp.CFrame=CFrame.new(layHrp.Position.X,groundY+hrpY+0.05,layHrp.Position.Z)*CFrame.Angles(math.rad(90),0,0)
end
layHum.PlatformStand=true
game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
if laying and not gpe and (input.UserInputType==Enum.UserInputType.Touch or input.KeyCode==Enum.KeyCode.Space)then laying=false end end)
task.spawn(function()
while laying do if not layHum.PlatformStand then layHum.PlatformStand=true end task.wait()end
layHum.PlatformStand=false end)
end
commandHandlers.speed=function(args)
local spdVal=tonumber(args[2])
if spdVal then
spdVal=math.clamp(spdVal,1,1000)
local spdChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local spdHum=spdChar:FindFirstChildOfClass("Humanoid")
if spdHum then spdHum.WalkSpeed=spdVal end
end
end
commandHandlers.remotespy=function(args)local function cr1mFetch(url)local s,r=pcall(function()return game:HttpGet(url)end)if s and r then pcall(function()loadstring(r)()end)end end cr1mFetch("https://raw.githubusercontent.com/Upbolt/RemoteSpy/main/Main.lua")end
commandHandlers.dex=function(args)local function cr1mFetch(url)local s,r=pcall(function()return game:HttpGet(url)end)if s and r then pcall(function()loadstring(r)()end)end end cr1mFetch("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua")end
commandHandlers.chatadmin=function(args)local function cr1mFetch(url)local s,r=pcall(function()return game:HttpGet(url)end)if s and r then pcall(function()loadstring(r)()end)end end cr1mFetch("https://raw.githubusercontent.com/Dhelann/chat-admin/main/source")end
commandHandlers.reset=function(args)
local rstChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
rstChar:BreakJoints()
end
commandHandlers.rejoin=function(args)TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer)end
commandHandlers.serverhop=function(args)
local cr1mSrv=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
for _,v in pairs(HttpService:JSONDecode(cr1mSrv).data)do
if v.playing<v.maxPlayers and v.id~=game.JobId then
TeleportService:TeleportToPlaceInstance(game.PlaceId,v.id,LocalPlayer)
break end end
end
commandHandlers.goto=function(args)
local tgtName=args[2]
if tgtName then
local function findTgt(name)
name=name:lower()
for _,p in ipairs(Players:GetPlayers())do
if p~=LocalPlayer then
local uname=p.Name:lower()
local dname=p.DisplayName:lower()
if uname:find(name)or dname:find(name)then return p end end end
return nil
end
local tgt=findTgt(tgtName)
if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart")then
local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame=tgt.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)end end end
end
commandHandlers.antifling=function(args)
local afChar=LocalPlayer.Character
if afChar then
for _,v in pairs(afChar:GetDescendants())do
if v:IsA("BasePart")and v.Name~="HumanoidRootPart"then v.CustomPhysicalProperties=PhysicalProperties.new(0,0,0)end end
end
end
commandHandlers.unantifling=function(args)
local uafChar=LocalPlayer.Character
if uafChar then
for _,v in pairs(uafChar:GetDescendants())do
if v:IsA("BasePart")and v.Name~="HumanoidRootPart"then v.CustomPhysicalProperties=PhysicalProperties.new(1,0.3,0.5)end end
end
end
commandHandlers.sit=function(args)
local sitPlr=Players.LocalPlayer
local sitChar=sitPlr.Character or sitPlr.CharacterAdded:Wait()
local sitHum=sitChar:WaitForChild("Humanoid")
sitHum.Sit=true
local sitting=true
sitHum.StateChanged:Connect(function(_,new)
if sitting and new==Enum.HumanoidStateType.Jumping then sitting=false end end)
task.spawn(function()
while sitting and sitHum and sitHum.Parent do
if not sitHum.Sit then sitHum.Sit=true end task.wait(0.1)end end)
end
commandHandlers.leave=function(args)Players.LocalPlayer:Kick("Cr1m Face has kicked you.")end
commandHandlers.godmode=function(args)
local gmChar=LocalPlayer.Character
if gmChar then
for _,v in pairs(gmChar:GetDescendants())do
if v:IsA("BasePart")then v.Anchored=false v.CanCollide=true v.Massless=false end end
gmChar:BreakJoints()
end
end
commandHandlers.fireremotes=function(args)
local remotesList={}
for _,obj in ipairs(game:GetDescendants())do
if obj:IsA("RemoteEvent")or obj:IsA("RemoteFunction")then table.insert(remotesList,obj)end end
for _,remote in ipairs(remotesList)do
pcall(function()
if remote:IsA("RemoteEvent")then remote:FireServer()elseif remote:IsA("RemoteFunction")then remote:InvokeServer()end end)end
end
commandHandlers.firetouchinterests=function(args)
local ftChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ftHrp=ftChar and ftChar:FindFirstChild("HumanoidRootPart")
if ftHrp and firetouchinterest then
for _,part in ipairs(workspace:GetDescendants())do
if part:IsA("BasePart")and part:FindFirstChildWhichIsA("TouchTransmitter")then
firetouchinterest(ftHrp,part,0)
firetouchinterest(ftHrp,part,1)end end end
end
commandHandlers.hitbox=function(args)
local size=tonumber(args[2])or 10
for _,player in ipairs(Players:GetPlayers())do
if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")then
local hrp=player.Character.HumanoidRootPart
hrp.Size=Vector3.new(size,size,size)
hrp.Transparency=0.7
hrp.BrickColor=BrickColor.new("Really red")
hrp.Material=Enum.Material.Neon
hrp.CanCollide=false end end
end
commandHandlers.noclip=function(args)
if cr1mNoclipConn then cr1mNoclipConn:Disconnect()cr1mNoclipConn=nil end
cr1mNoclipConn=RunService.Stepped:Connect(function()
if LocalPlayer.Character then
for _,v in pairs(LocalPlayer.Character:GetDescendants())do
if v:IsA("BasePart")then v.CanCollide=false end end end end)
end
commandHandlers.clip=function(args)
if cr1mNoclipConn then cr1mNoclipConn:Disconnect()cr1mNoclipConn=nil end
if LocalPlayer.Character then
for _,v in pairs(LocalPlayer.Character:GetDescendants())do
if v:IsA("BasePart")then v.CanCollide=true end end end
end
commandHandlers.spin=function(args)
local spd=tonumber(args[2])or 10
local spinChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local spinHrp=spinChar:FindFirstChild("HumanoidRootPart")
if spinHrp then spawn(function()
while wait()do spinHrp.CFrame=spinHrp.CFrame*CFrame.Angles(0,math.rad(spd),0)end end)end
end
commandHandlers.view=function(args)
local viewName=args[2]
for _,p in ipairs(Players:GetPlayers())do
if p~=LocalPlayer and p.Name:lower():find(viewName:lower())then
workspace.CurrentCamera.CameraSubject=p.Character and p.Character:FindFirstChild("Humanoid")end end
end
commandHandlers.fixcam=function(args)workspace.CurrentCamera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")end
commandHandlers.fullbright=function(args)Lighting.Brightness=10 Lighting.ClockTime=12 Lighting.FogEnd=1e10 Lighting.GlobalShadows=false Lighting.OutdoorAmbient=Color3.new(1,1,1)end
commandHandlers.unfullbright=function(args)Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=1000 Lighting.GlobalShadows=true Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)end
commandHandlers.esp=function(args)getgenv().Cr1msonESP()end
commandHandlers.unesp=function(args)getgenv().unCr1msonESP()end
commandHandlers.antiafk=function(args)for _,v in pairs(getconnections(Players.LocalPlayer.Idled))do v:Disable()end end

-- FLING COMMAND (CRIMSON FLING / SKIDFLING)
local function crimsonFling(targetPlayer)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = humanoid and humanoid.RootPart

    local oldPos
    local savedFPDH

    local tChar = targetPlayer.Character
    local tHumanoid = tChar and tChar:FindFirstChildOfClass("Humanoid")
    local tRootPart = tHumanoid and tHumanoid.RootPart
    local tHead = tChar and tChar:FindFirstChild("Head")
    local accessory = tChar and tChar:FindFirstChildOfClass("Accessory")
    local handle = accessory and accessory:FindFirstChild("Handle")

    if character and humanoid and rootPart then
        if rootPart.Velocity.Magnitude < 50 then
            oldPos = rootPart.CFrame
        end
        if tRootPart and tRootPart:IsGrounded() then
            return -- Target is grounded
        end

        -- Camera focus
        if tHead then
            workspace.CurrentCamera.CameraSubject = tHead
        elseif handle then
            workspace.CurrentCamera.CameraSubject = handle
        elseif tHumanoid and tRootPart then
            workspace.CurrentCamera.CameraSubject = tHumanoid
        end

        if not tChar:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local function setFlingPos(basePart, pos, ang)
            rootPart.CFrame = CFrame.new(basePart.Position) * pos * ang
            character:SetPrimaryPartCFrame(CFrame.new(basePart.Position) * pos * ang)
            rootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            rootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function flingBasePart(basePart)
            local waitTime = 3
            local startTick = tick()
            local angle = 0

            repeat
                if rootPart and tHumanoid then
                    if basePart.Velocity.Magnitude < 50 then
                        angle = angle + 100

                        setFlingPos(basePart, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(2.25, 1.5, -2.25) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(-2.25, -1.5, 2.25) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                        task.wait()
                    else
                        setFlingPos(basePart, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, -tHumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, 1.5, tRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, -tRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, 1.5, tRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        setFlingPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until basePart.Velocity.Magnitude > 500 or basePart.Parent ~= tChar or targetPlayer.Parent ~= Players or not targetPlayer.Character == tChar or tRootPart:IsGrounded() or humanoid.Health <= 0 or tick() > startTick + waitTime
        end

        savedFPDH = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0

        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "CrimsonVel"
        bodyVel.Parent = rootPart
        bodyVel.Velocity = Vector3.new(9e8, 9e8, 9e8)
        bodyVel.MaxForce = Vector3.new(1/0, 1/0, 1/0)

        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if tRootPart and tHead then
            if (tRootPart.CFrame.Position - tHead.CFrame.Position).Magnitude > 5 then
                flingBasePart(tHead)
            else
                flingBasePart(tRootPart)
            end
        elseif tRootPart and not tHead then
            flingBasePart(tRootPart)
        elseif not tRootPart and tHead then
            flingBasePart(tHead)
        elseif not tRootPart and not tHead and accessory and handle then
            flingBasePart(handle)
        else
            return
        end

        bodyVel:Destroy()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = humanoid

        repeat
            rootPart.CFrame = oldPos * CFrame.new(0, 0.5, 0)
            character:PivotTo(oldPos * CFrame.new(0, 0.5, 0))
            humanoid:ChangeState("GettingUp")
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (rootPart.Position - oldPos.Position).Magnitude < 25

        workspace.FallenPartsDestroyHeight = savedFPDH
    end
end

commandHandlers.fling = function(args)
    local tgtName = args[2]
    if not tgtName then return end
    tgtName = tgtName:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local uname = player.Name:lower()
            local dname = player.DisplayName:lower()
            if uname:find(tgtName) or dname:find(tgtName) then
                crimsonFling(player)
                break
            end
        end
    end
end

local function runCommand(txt)
if txt==""then return end
local args=split(txt)
local cmd=args[1]and args[1]:lower()or""
local handler=commandHandlers[cmd]
if handler then
pcall(function()handler(args)end)
else
local s,f=pcall(function()return loadstring(txt)end)
if s and typeof(f)=="function"then pcall(f)end
end
end
Players.LocalPlayer.Chatted:Connect(function(msg)if msg:sub(1,1)==";"then runCommand(msg:sub(2))end end)
local function onChat(msg)
if msg:sub(1,1)==";" then runCommand(msg:sub(2)) end
end
if Players.LocalPlayer.Chatted then
Players.LocalPlayer.Chatted:Connect(onChat)
end
local TextChatService = game:GetService("TextChatService")
if TextChatService and TextChatService.OnIncomingMessage then
TextChatService.OnIncomingMessage:Connect(function(message)
if message.TextSource and message.TextSource.UserId == Players.LocalPlayer.UserId then
onChat(message.Text)
end
end)
end
end
