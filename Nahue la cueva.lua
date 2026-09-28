-- =====================================================
-- ZuaZua Hub v22 - Basado en v21 (UI estable) + Más opciones
-- Botones flotantes SOLO si los activás desde el menú
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)

-- Limpieza (igual que v21)
if playerGui:FindFirstChild("ZuaZuaCardboardHub") then
	playerGui.ZuaZuaCardboardHub:Destroy()
end
pcall(function()
	if CoreGui:FindFirstChild("ZuaZuaCardboardHub") then
		CoreGui.ZuaZuaCardboardHub:Destroy()
	end
end)

--===================== CONFIG =====================
local Config = {
	-- Visuales
	ESPCompaneros = false,
	ESPEnemigos = false,

	-- Control (legit)
	Magnetismo = false,
	Topspin = false,
	AutoAimSuave = false,
	AntiRobo = false,
	SoftTouch = false,

	-- Movimiento
	SpeedHack = false,
	WalkSpeed = 18,
	InfJump = false,
	Noclip = false,

	-- Botones flotantes (OFF por defecto)
	ShowPower = false,
	ShowAim = false,
	ShowAngulo = false,
	ShowPase = false,

	-- Potentes / riesgo
	ForceCatch = false,
	ImanAbsoluto = false,
	TiroNuke = false,
	AuraRepulsora = false,

	-- Power Shot
	PowerMultiplier = 1.55,
}

local activeConnections = {}
local teamHighlights = {}
local enemyHighlights = {}
local lastBoostTime = 0
local lastRemote = 0
local activeModifier = nil
local modifierEndTime = 0

--===================== UTILIDADES =====================
local function isTeammate(p)
	if p == LocalPlayer then return false end
	if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
	if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

local function findBall()
	for _, name in ipairs({"TPS", "Ball", "Football", "SoccerBall"}) do
		local b = Workspace:FindFirstChild(name)
		if b and b:IsA("BasePart") then return b end
	end
	return nil
end

local function getNearestGoal(pos)
	local best, minD = nil, 300
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = obj.Name:lower()
			if n:find("goal") or n:find("arco") or n:find("porteria") or n:find("net") then
				local d = (obj.Position - pos).Magnitude
				if d < minD then
					minD = d
					best = obj.Position
				end
			end
		end
	end
	return best
end

local function getRemote(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if v.Name == name and v:IsA("RemoteEvent") then return v end
	end
	return nil
end

local CatchBall = getRemote("CatchBall")
local ChangeOwner = getRemote("ChangeOwner")

--===================== UI CARTÓN (igual que v21) =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZuaZuaCardboardHub"
screenGui.ResetOnSpawn = false
pcall(function()
	if gethui then screenGui.Parent = gethui() else screenGui.Parent = playerGui end
end)
if not screenGui.Parent then screenGui.Parent = playerGui end

-- Botón menú
local toggleMenu = Instance.new("TextButton")
toggleMenu.Size = UDim2.new(0, 50, 0, 50)
toggleMenu.Position = UDim2.new(0.02, 0, 0.28, 0)
toggleMenu.BackgroundColor3 = Color3.fromRGB(193, 154, 107)
toggleMenu.Text = "📦"
toggleMenu.TextSize = 24
toggleMenu.Font = Enum.Font.GothamBold
toggleMenu.Parent = screenGui
Instance.new("UICorner", toggleMenu).CornerRadius = UDim.new(0.2, 0)

-- Panel principal
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 480, 0, 380)
mainPanel.Position = UDim2.new(0.5, -240, 0.5, -190)
mainPanel.BackgroundColor3 = Color3.fromRGB(181, 136, 92)
mainPanel.Visible = false
mainPanel.Parent = screenGui
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 6)

-- Rayas de cartón
for i = 0, 90 do
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 2)
	stripe.Position = UDim2.new(0, 0, 0, i * 6)
	stripe.BackgroundColor3 = Color3.fromRGB(158, 116, 76)
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 0
	stripe.Parent = mainPanel
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 38)
titleLabel.Position = UDim2.new(0, 0, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZuaZua Hub - Magic Box v22"
titleLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.Font = Enum.Font.PatrickHand
titleLabel.TextSize = 26
titleLabel.ZIndex = 2
titleLabel.Parent = mainPanel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 2
closeBtn.Parent = mainPanel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
	mainPanel.Visible = false
end)
toggleMenu.MouseButton1Click:Connect(function()
	mainPanel.Visible = not mainPanel.Visible
end)

-- Área de opciones
local paperArea = Instance.new("ScrollingFrame")
paperArea.Size = UDim2.new(0.9, 0, 0.80, 0)
paperArea.Position = UDim2.new(0.05, 0, 0.14, 0)
paperArea.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
paperArea.ScrollBarThickness = 4
paperArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
paperArea.CanvasSize = UDim2.new(0, 0, 0, 0)
paperArea.ZIndex = 2
paperArea.Parent = mainPanel
Instance.new("UICorner", paperArea).CornerRadius = UDim.new(0, 5)

local layout = Instance.new("UIListLayout")
layout.Parent = paperArea
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createSection(title)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(0.95, 0, 0, 28)
	lab.BackgroundColor3 = Color3.fromRGB(220, 200, 160)
	lab.Text = "  " .. title
	lab.TextColor3 = Color3.fromRGB(40, 30, 20)
	lab.Font = Enum.Font.PatrickHand
	lab.TextSize = 18
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.ZIndex = 2
	lab.Parent = paperArea
	Instance.new("UICorner", lab).CornerRadius = UDim.new(0, 4)
end

local function createToggle(text, key, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
	btn.Text = "☐  " .. text
	btn.TextColor3 = Color3.fromRGB(30, 30, 30)
	btn.Font = Enum.Font.PatrickHand
	btn.TextSize = 18
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 2
	btn.Parent = paperArea

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		if Config[key] then
			btn.Text = "☑  " .. text
			btn.TextColor3 = Color3.fromRGB(20, 120, 20)
		else
			btn.Text = "☐  " .. text
			btn.TextColor3 = Color3.fromRGB(30, 30, 30)
		end
		if callback then callback(Config[key]) end
	end)
end

--===================== BOTONES FLOTANTES (ocultos por defecto) =====================
local function makeFloat(text, color, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 64, 0, 64)
	b.Position = UDim2.new(0.82, 0, y, 0)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Visible = false
	b.Parent = screenGui
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	return b
end

local powerBtn = makeFloat("POWER", Color3.fromRGB(40, 40, 45), 0.52)
local powerStroke = Instance.new("UIStroke")
powerStroke.Color = Color3.fromRGB(0, 200, 255)
powerStroke.Thickness = 2.5
powerStroke.Parent = powerBtn

local chargeBarBg = Instance.new("Frame")
chargeBarBg.Size = UDim2.new(0, 64, 0, 8)
chargeBarBg.Position = UDim2.new(0, 0, 1, 6)
chargeBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
chargeBarBg.BorderSizePixel = 0
chargeBarBg.Parent = powerBtn
Instance.new("UICorner", chargeBarBg).CornerRadius = UDim.new(0, 4)

local chargeBar = Instance.new("Frame")
chargeBar.Size = UDim2.new(0, 0, 1, 0)
chargeBar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
chargeBar.BorderSizePixel = 0
chargeBar.Parent = chargeBarBg
Instance.new("UICorner", chargeBar).CornerRadius = UDim.new(0, 4)

local btnAim = makeFloat("AIM", Color3.fromRGB(45, 180, 90), 0.28)
local btnAngulo = makeFloat("ÁNG", Color3.fromRGB(210, 55, 110), 0.38)
local btnPase = makeFloat("PASE", Color3.fromRGB(55, 110, 220), 0.48)

-- Lógica Power Shot (igual que v21)
local isCharging = false
local chargeAmount = 0
local maxCharge = 1.0

powerBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isCharging = true
		chargeAmount = 0
	end
end)

powerBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if isCharging and chargeAmount > 0.25 then
			local char = LocalPlayer.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				local ball = findBall()
				if root and ball then
					local dist = (ball.Position - root.Position).Magnitude
					if dist < 12 then
						local look = root.CFrame.LookVector
						local power = 55 + (chargeAmount * 55) * Config.PowerMultiplier
						local up = 8 + (chargeAmount * 12)
						local finalVel = (look * power) + Vector3.new(0, up, 0)

						local bv = ball:FindFirstChildOfClass("BodyVelocity")
						if bv then
							bv.Velocity = finalVel
						else
							ball.AssemblyLinearVelocity = finalVel
						end
						lastBoostTime = tick()
					end
				end
			end
		end
		isCharging = false
		chargeAmount = 0
		chargeBar.Size = UDim2.new(0, 0, 1, 0)
		powerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	end
end)

btnAim.MouseButton1Click:Connect(function()
	activeModifier = "aim"
	modifierEndTime = tick() + 1.5
end)
btnAngulo.MouseButton1Click:Connect(function()
	activeModifier = "angulo"
	modifierEndTime = tick() + 1.5
end)
btnPase.MouseButton1Click:Connect(function()
	activeModifier = "pase"
	modifierEndTime = tick() + 1.5
end)

--===================== MENÚ (secciones) =====================
createSection("— Botones flotantes —")
createToggle("Mostrar botón POWER (carga)", "ShowPower", function(v) powerBtn.Visible = v end)
createToggle("Mostrar botón AIM", "ShowAim", function(v) btnAim.Visible = v end)
createToggle("Mostrar botón ÁNGULO", "ShowAngulo", function(v) btnAngulo.Visible = v end)
createToggle("Mostrar botón PASE", "ShowPase", function(v) btnPase.Visible = v end)

createSection("— Control / Legit —")
createToggle("ESP Compañeros", "ESPCompaneros")
createToggle("ESP Enemigos", "ESPEnemigos")
createToggle("Magnetismo Suave (pie)", "Magnetismo")
createToggle("Topspin Ligero", "Topspin")
createToggle("AutoAim Suave (tus tiros)", "AutoAimSuave")
createToggle("Anti-Robo pasivo", "AntiRobo")
createToggle("Soft Touch (recepción)", "SoftTouch")

createSection("— Movimiento —")
createToggle("Correr un poco más rápido", "SpeedHack")
createToggle("Infinite Jump", "InfJump")
createToggle("Noclip", "Noclip")

createSection("— Potentes / Riesgo —")
createToggle("Force Catch (remote)", "ForceCatch")
createToggle("Imán Absoluto", "ImanAbsoluto")
createToggle("Tiro Nuke", "TiroNuke")
createToggle("Aura Repulsora", "AuraRepulsora")

-- Multiplicador
local mulBtn = Instance.new("TextButton")
mulBtn.Size = UDim2.new(0.95, 0, 0, 36)
mulBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 150)
mulBtn.Text = "💥 Potencia POWER: x1.55 (tocar)"
mulBtn.TextColor3 = Color3.fromRGB(120, 50, 0)
mulBtn.Font = Enum.Font.PatrickHand
mulBtn.TextSize = 17
mulBtn.ZIndex = 2
mulBtn.Parent = paperArea
Instance.new("UICorner", mulBtn).CornerRadius = UDim.new(0, 4)
mulBtn.MouseButton1Click:Connect(function()
	Config.PowerMultiplier = Config.PowerMultiplier + 0.25
	if Config.PowerMultiplier > 3.5 then Config.PowerMultiplier = 1.0 end
	mulBtn.Text = "💥 Potencia POWER: x" .. string.format("%.2f", Config.PowerMultiplier) .. " (tocar)"
end)

--===================== ARRASTRE =====================
local function makeDraggable(gui)
	local dragging, dragStart, startPos = false, nil, nil
	table.insert(activeConnections, gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
		end
	end))
	table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	table.insert(activeConnections, UserInputService.InputEnded:Connect(function()
		dragging = false
	end))
end

makeDraggable(mainPanel)
makeDraggable(toggleMenu)
makeDraggable(powerBtn)
makeDraggable(btnAim)
makeDraggable(btnAngulo)
makeDraggable(btnPase)

--===================== RIESGO BÁSICO =====================
RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if Config.InfJump then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--===================== MOTOR PRINCIPAL =====================
table.insert(activeConnections, RunService.Heartbeat:Connect(function(dt)
	-- Carga del botón Power
	if isCharging and powerBtn.Visible then
		chargeAmount = math.min(chargeAmount + dt * 1.4, maxCharge)
		chargeBar.Size = UDim2.new(chargeAmount, 0, 1, 0)
		powerBtn.BackgroundColor3 = Color3.fromRGB(30, 120 + chargeAmount * 80, 50)
	end

	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	if Config.SpeedHack then
		hum.WalkSpeed = Config.WalkSpeed
	else
		if hum.WalkSpeed > 20 then hum.WalkSpeed = 16 end
	end

	-- ESP Compañeros
	if Config.ESPCompaneros then
		for _, p in ipairs(Players:GetPlayers()) do
			if isTeammate(p) and p.Character and not p.Character:FindFirstChild("ZuaTeamCham") then
				local hl = Instance.new("Highlight")
				hl.Name = "ZuaTeamCham"
				hl.FillColor = Color3.fromRGB(50, 255, 100)
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.FillTransparency = 0.55
				hl.Parent = p.Character
				table.insert(teamHighlights, hl)
			end
		end
	else
		for _, hl in ipairs(teamHighlights) do
			if hl and hl.Parent then hl:Destroy() end
		end
		table.clear(teamHighlights)
	end

	-- ESP Enemigos
	if Config.ESPEnemigos then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and not p.Character:FindFirstChild("ZuaEnemyCham") then
				local hl = Instance.new("Highlight")
				hl.Name = "ZuaEnemyCham"
				hl.FillColor = Color3.fromRGB(255, 70, 70)
				hl.OutlineColor = Color3.fromRGB(255, 200, 200)
				hl.FillTransparency = 0.6
				hl.Parent = p.Character
				table.insert(enemyHighlights, hl)
			end
		end
	else
		for _, hl in ipairs(enemyHighlights) do
			if hl and hl.Parent then hl:Destroy() end
		end
		table.clear(enemyHighlights)
	end

	-- Aura
	if Config.AuraRepulsora then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local eRoot = p.Character.HumanoidRootPart
				if (eRoot.Position - root.Position).Magnitude < 7 then
					eRoot.AssemblyLinearVelocity = (eRoot.Position - root.Position).Unit * 45 + Vector3.new(0, 16, 0)
				end
			end
		end
	end

	local ball = findBall()
	if not ball then return end

	local dist = (ball.Position - root.Position).Magnitude
	local vel = ball.AssemblyLinearVelocity

	-- AIM / ÁNG / PASE
	if activeModifier and tick() < modifierEndTime and dist < 30 then
		local goal = getNearestGoal(ball.Position)
		if activeModifier == "aim" and goal then
			ball.AssemblyLinearVelocity = (goal + Vector3.new(0, 1.5, 0) - ball.Position).Unit * (58 * Config.PowerMultiplier)
		elseif activeModifier == "angulo" and goal then
			local side = (math.random() > 0.5) and 8 or -8
			ball.AssemblyLinearVelocity = (goal + Vector3.new(side, 5.5, 0) - ball.Position).Unit * (62 * Config.PowerMultiplier)
		elseif activeModifier == "pase" then
			for _, p in ipairs(Players:GetPlayers()) do
				if isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
					if d > 10 and d < 90 then
						ball.AssemblyLinearVelocity = (p.Character.HumanoidRootPart.Position - ball.Position).Unit * 50
						break
					end
				end
			end
		end
	else
		activeModifier = nil
	end

	-- Force Catch
	if Config.ForceCatch and dist < 12 and tick() - lastRemote > 0.55 then
		if CatchBall then pcall(function() CatchBall:FireServer(ball) end) end
		if ChangeOwner then pcall(function() ChangeOwner:FireServer(ball) end) end
		lastRemote = tick()
	end

	-- Magnetismo (v21)
	if Config.Magnetismo and dist < 5.2 and root.AssemblyLinearVelocity.Magnitude > 3 and vel.Magnitude < 18 then
		local target = root.Position + root.CFrame.LookVector * 2.0 - Vector3.new(0, 1.1, 0)
		local pull = (target - ball.Position) * 2.8
		ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity:Lerp(root.AssemblyLinearVelocity + pull, 0.22)
	end

	-- Topspin (v21)
	if Config.Topspin and dist > 10 and dist < 65 and vel.Magnitude > 30 and ball.Position.Y > root.Position.Y + 2 then
		ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity + Vector3.new(0, -1.8, 0)
	end

	-- AutoAim suave (v21)
	if Config.AutoAimSuave and dist < 9 and vel.Magnitude > 28 and tick() - lastBoostTime < 0.6 then
		local goal = getNearestGoal(ball.Position)
		if goal then
			local desired = (goal + Vector3.new(0, 1.6, 0) - ball.Position).Unit
			local current = vel.Unit
			local blended = (current * 0.72 + desired * 0.28).Unit
			ball.AssemblyLinearVelocity = blended * vel.Magnitude
		end
	end

	-- Soft Touch
	if Config.SoftTouch and dist < 10 and vel.Y < -14 then
		ball.AssemblyLinearVelocity = Vector3.new(vel.X * 0.4, 5, vel.Z * 0.4)
	end

	-- Anti-Robo
	if Config.AntiRobo and dist < 5.5 then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				if (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 5 then
					local push = (ball.Position - p.Character.HumanoidRootPart.Position).Unit
					ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity + Vector3.new(push.X * 10, 0, push.Z * 10)
				end
			end
		end
	end

	-- Imán Absoluto
	if Config.ImanAbsoluto and dist < 11 and root.AssemblyLinearVelocity.Magnitude > 2 then
		ball.CFrame = root.CFrame * CFrame.new(0, -1.1, -2.3)
		ball.AssemblyLinearVelocity = root.AssemblyLinearVelocity
	end

	-- Tiro Nuke
	if Config.TiroNuke and dist < 6 and vel.Magnitude > 8 then
		local goal = getNearestGoal(ball.Position)
		if goal then
			ball.AssemblyLinearVelocity = (goal - ball.Position).Unit * 900
		end
	end
end))

Workspace.ChildAdded:Connect(function(obj)
	if obj.Name == "TPS" or obj.Name == "Ball" then
		obj.ChildAdded:Connect(function(child)
			if child:IsA("BodyVelocity") then
				lastBoostTime = tick()
			end
		end)
	end
end)

print("ZuaZua Hub v22 - v21 estable + botones ocultos + más opciones")-- =====================================================
-- ZuaZua Hub v22 - Basado en v21 (UI estable) + Más opciones
-- Botones flotantes SOLO si los activás desde el menú
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)

-- Limpieza (igual que v21)
if playerGui:FindFirstChild("ZuaZuaCardboardHub") then
	playerGui.ZuaZuaCardboardHub:Destroy()
end
pcall(function()
	if CoreGui:FindFirstChild("ZuaZuaCardboardHub") then
		CoreGui.ZuaZuaCardboardHub:Destroy()
	end
end)

--===================== CONFIG =====================
local Config = {
	-- Visuales
	ESPCompaneros = false,
	ESPEnemigos = false,

	-- Control (legit)
	Magnetismo = false,
	Topspin = false,
	AutoAimSuave = false,
	AntiRobo = false,
	SoftTouch = false,

	-- Movimiento
	SpeedHack = false,
	WalkSpeed = 18,
	InfJump = false,
	Noclip = false,

	-- Botones flotantes (OFF por defecto)
	ShowPower = false,
	ShowAim = false,
	ShowAngulo = false,
	ShowPase = false,

	-- Potentes / riesgo
	ForceCatch = false,
	ImanAbsoluto = false,
	TiroNuke = false,
	AuraRepulsora = false,

	-- Power Shot
	PowerMultiplier = 1.55,
}

local activeConnections = {}
local teamHighlights = {}
local enemyHighlights = {}
local lastBoostTime = 0
local lastRemote = 0
local activeModifier = nil
local modifierEndTime = 0

--===================== UTILIDADES =====================
local function isTeammate(p)
	if p == LocalPlayer then return false end
	if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
	if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor == LocalPlayer.TeamColor then return true end
	return false
end

local function findBall()
	for _, name in ipairs({"TPS", "Ball", "Football", "SoccerBall"}) do
		local b = Workspace:FindFirstChild(name)
		if b and b:IsA("BasePart") then return b end
	end
	return nil
end

local function getNearestGoal(pos)
	local best, minD = nil, 300
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = obj.Name:lower()
			if n:find("goal") or n:find("arco") or n:find("porteria") or n:find("net") then
				local d = (obj.Position - pos).Magnitude
				if d < minD then
					minD = d
					best = obj.Position
				end
			end
		end
	end
	return best
end

local function getRemote(name)
	local r = ReplicatedStorage:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	for _, v in pairs(ReplicatedStorage:GetDescendants()) do
		if v.Name == name and v:IsA("RemoteEvent") then return v end
	end
	return nil
end

local CatchBall = getRemote("CatchBall")
local ChangeOwner = getRemote("ChangeOwner")

--===================== UI CARTÓN (igual que v21) =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZuaZuaCardboardHub"
screenGui.ResetOnSpawn = false
pcall(function()
	if gethui then screenGui.Parent = gethui() else screenGui.Parent = playerGui end
end)
if not screenGui.Parent then screenGui.Parent = playerGui end

-- Botón menú
local toggleMenu = Instance.new("TextButton")
toggleMenu.Size = UDim2.new(0, 50, 0, 50)
toggleMenu.Position = UDim2.new(0.02, 0, 0.28, 0)
toggleMenu.BackgroundColor3 = Color3.fromRGB(193, 154, 107)
toggleMenu.Text = "📦"
toggleMenu.TextSize = 24
toggleMenu.Font = Enum.Font.GothamBold
toggleMenu.Parent = screenGui
Instance.new("UICorner", toggleMenu).CornerRadius = UDim.new(0.2, 0)

-- Panel principal
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 480, 0, 380)
mainPanel.Position = UDim2.new(0.5, -240, 0.5, -190)
mainPanel.BackgroundColor3 = Color3.fromRGB(181, 136, 92)
mainPanel.Visible = false
mainPanel.Parent = screenGui
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 6)

-- Rayas de cartón
for i = 0, 90 do
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 2)
	stripe.Position = UDim2.new(0, 0, 0, i * 6)
	stripe.BackgroundColor3 = Color3.fromRGB(158, 116, 76)
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 0
	stripe.Parent = mainPanel
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 38)
titleLabel.Position = UDim2.new(0, 0, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZuaZua Hub - Magic Box v22"
titleLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.Font = Enum.Font.PatrickHand
titleLabel.TextSize = 26
titleLabel.ZIndex = 2
titleLabel.Parent = mainPanel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 2
closeBtn.Parent = mainPanel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
	mainPanel.Visible = false
end)
toggleMenu.MouseButton1Click:Connect(function()
	mainPanel.Visible = not mainPanel.Visible
end)

-- Área de opciones
local paperArea = Instance.new("ScrollingFrame")
paperArea.Size = UDim2.new(0.9, 0, 0.80, 0)
paperArea.Position = UDim2.new(0.05, 0, 0.14, 0)
paperArea.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
paperArea.ScrollBarThickness = 4
paperArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
paperArea.CanvasSize = UDim2.new(0, 0, 0, 0)
paperArea.ZIndex = 2
paperArea.Parent = mainPanel
Instance.new("UICorner", paperArea).CornerRadius = UDim.new(0, 5)

local layout = Instance.new("UIListLayout")
layout.Parent = paperArea
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createSection(title)
	local lab = Instance.new("TextLabel")
	lab.Size = UDim2.new(0.95, 0, 0, 28)
	lab.BackgroundColor3 = Color3.fromRGB(220, 200, 160)
	lab.Text = "  " .. title
	lab.TextColor3 = Color3.fromRGB(40, 30, 20)
	lab.Font = Enum.Font.PatrickHand
	lab.TextSize = 18
	lab.TextXAlignment = Enum.TextXAlignment.Left
	lab.ZIndex = 2
	lab.Parent = paperArea
	Instance.new("UICorner", lab).CornerRadius = UDim.new(0, 4)
end

local function createToggle(text, key, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
	btn.Text = "☐  " .. text
	btn.TextColor3 = Color3.fromRGB(30, 30, 30)
	btn.Font = Enum.Font.PatrickHand
	btn.TextSize = 18
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 2
	btn.Parent = paperArea

	btn.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		if Config[key] then
			btn.Text = "☑  " .. text
			btn.TextColor3 = Color3.fromRGB(20, 120, 20)
		else
			btn.Text = "☐  " .. text
			btn.TextColor3 = Color3.fromRGB(30, 30, 30)
		end
		if callback then callback(Config[key]) end
	end)
end

--===================== BOTONES FLOTANTES (ocultos por defecto) =====================
local function makeFloat(text, color, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 64, 0, 64)
	b.Position = UDim2.new(0.82, 0, y, 0)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Visible = false
	b.Parent = screenGui
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	return b
end

local powerBtn = makeFloat("POWER", Color3.fromRGB(40, 40, 45), 0.52)
local powerStroke = Instance.new("UIStroke")
powerStroke.Color = Color3.fromRGB(0, 200, 255)
powerStroke.Thickness = 2.5
powerStroke.Parent = powerBtn

local chargeBarBg = Instance.new("Frame")
chargeBarBg.Size = UDim2.new(0, 64, 0, 8)
chargeBarBg.Position = UDim2.new(0, 0, 1, 6)
chargeBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
chargeBarBg.BorderSizePixel = 0
chargeBarBg.Parent = powerBtn
Instance.new("UICorner", chargeBarBg).CornerRadius = UDim.new(0, 4)

local chargeBar = Instance.new("Frame")
chargeBar.Size = UDim2.new(0, 0, 1, 0)
chargeBar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
chargeBar.BorderSizePixel = 0
chargeBar.Parent = chargeBarBg
Instance.new("UICorner", chargeBar).CornerRadius = UDim.new(0, 4)

local btnAim = makeFloat("AIM", Color3.fromRGB(45, 180, 90), 0.28)
local btnAngulo = makeFloat("ÁNG", Color3.fromRGB(210, 55, 110), 0.38)
local btnPase = makeFloat("PASE", Color3.fromRGB(55, 110, 220), 0.48)

-- Lógica Power Shot (igual que v21)
local isCharging = false
local chargeAmount = 0
local maxCharge = 1.0

powerBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isCharging = true
		chargeAmount = 0
	end
end)

powerBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if isCharging and chargeAmount > 0.25 then
			local char = LocalPlayer.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				local ball = findBall()
				if root and ball then
					local dist = (ball.Position - root.Position).Magnitude
					if dist < 12 then
						local look = root.CFrame.LookVector
						local power = 55 + (chargeAmount * 55) * Config.PowerMultiplier
						local up = 8 + (chargeAmount * 12)
						local finalVel = (look * power) + Vector3.new(0, up, 0)

						local bv = ball:FindFirstChildOfClass("BodyVelocity")
						if bv then
							bv.Velocity = finalVel
						else
							ball.AssemblyLinearVelocity = finalVel
						end
						lastBoostTime = tick()
					end
				end
			end
		end
		isCharging = false
		chargeAmount = 0
		chargeBar.Size = UDim2.new(0, 0, 1, 0)
		powerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	end
end)

btnAim.MouseButton1Click:Connect(function()
	activeModifier = "aim"
	modifierEndTime = tick() + 1.5
end)
btnAngulo.MouseButton1Click:Connect(function()
	activeModifier = "angulo"
	modifierEndTime = tick() + 1.5
end)
btnPase.MouseButton1Click:Connect(function()
	activeModifier = "pase"
	modifierEndTime = tick() + 1.5
end)

--===================== MENÚ (secciones) =====================
createSection("— Botones flotantes —")
createToggle("Mostrar botón POWER (carga)", "ShowPower", function(v) powerBtn.Visible = v end)
createToggle("Mostrar botón AIM", "ShowAim", function(v) btnAim.Visible = v end)
createToggle("Mostrar botón ÁNGULO", "ShowAngulo", function(v) btnAngulo.Visible = v end)
createToggle("Mostrar botón PASE", "ShowPase", function(v) btnPase.Visible = v end)

createSection("— Control / Legit —")
createToggle("ESP Compañeros", "ESPCompaneros")
createToggle("ESP Enemigos", "ESPEnemigos")
createToggle("Magnetismo Suave (pie)", "Magnetismo")
createToggle("Topspin Ligero", "Topspin")
createToggle("AutoAim Suave (tus tiros)", "AutoAimSuave")
createToggle("Anti-Robo pasivo", "AntiRobo")
createToggle("Soft Touch (recepción)", "SoftTouch")

createSection("— Movimiento —")
createToggle("Correr un poco más rápido", "SpeedHack")
createToggle("Infinite Jump", "InfJump")
createToggle("Noclip", "Noclip")

createSection("— Potentes / Riesgo —")
createToggle("Force Catch (remote)", "ForceCatch")
createToggle("Imán Absoluto", "ImanAbsoluto")
createToggle("Tiro Nuke", "TiroNuke")
createToggle("Aura Repulsora", "AuraRepulsora")

-- Multiplicador
local mulBtn = Instance.new("TextButton")
mulBtn.Size = UDim2.new(0.95, 0, 0, 36)
mulBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 150)
mulBtn.Text = "💥 Potencia POWER: x1.55 (tocar)"
mulBtn.TextColor3 = Color3.fromRGB(120, 50, 0)
mulBtn.Font = Enum.Font.PatrickHand
mulBtn.TextSize = 17
mulBtn.ZIndex = 2
mulBtn.Parent = paperArea
Instance.new("UICorner", mulBtn).CornerRadius = UDim.new(0, 4)
mulBtn.MouseButton1Click:Connect(function()
	Config.PowerMultiplier = Config.PowerMultiplier + 0.25
	if Config.PowerMultiplier > 3.5 then Config.PowerMultiplier = 1.0 end
	mulBtn.Text = "💥 Potencia POWER: x" .. string.format("%.2f", Config.PowerMultiplier) .. " (tocar)"
end)

--===================== ARRASTRE =====================
local function makeDraggable(gui)
	local dragging, dragStart, startPos = false, nil, nil
	table.insert(activeConnections, gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
		end
	end))
	table.insert(activeConnections, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	table.insert(activeConnections, UserInputService.InputEnded:Connect(function()
		dragging = false
	end))
end

makeDraggable(mainPanel)
makeDraggable(toggleMenu)
makeDraggable(powerBtn)
makeDraggable(btnAim)
makeDraggable(btnAngulo)
makeDraggable(btnPase)

--===================== RIESGO BÁSICO =====================
RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if Config.InfJump then
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--===================== MOTOR PRINCIPAL =====================
table.insert(activeConnections, RunService.Heartbeat:Connect(function(dt)
	-- Carga del botón Power
	if isCharging and powerBtn.Visible then
		chargeAmount = math.min(chargeAmount + dt * 1.4, maxCharge)
		chargeBar.Size = UDim2.new(chargeAmount, 0, 1, 0)
		powerBtn.BackgroundColor3 = Color3.fromRGB(30, 120 + chargeAmount * 80, 50)
	end

	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	if Config.SpeedHack then
		hum.WalkSpeed = Config.WalkSpeed
	else
		if hum.WalkSpeed > 20 then hum.WalkSpeed = 16 end
	end

	-- ESP Compañeros
	if Config.ESPCompaneros then
		for _, p in ipairs(Players:GetPlayers()) do
			if isTeammate(p) and p.Character and not p.Character:FindFirstChild("ZuaTeamCham") then
				local hl = Instance.new("Highlight")
				hl.Name = "ZuaTeamCham"
				hl.FillColor = Color3.fromRGB(50, 255, 100)
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.FillTransparency = 0.55
				hl.Parent = p.Character
				table.insert(teamHighlights, hl)
			end
		end
	else
		for _, hl in ipairs(teamHighlights) do
			if hl and hl.Parent then hl:Destroy() end
		end
		table.clear(teamHighlights)
	end

	-- ESP Enemigos
	if Config.ESPEnemigos then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and not p.Character:FindFirstChild("ZuaEnemyCham") then
				local hl = Instance.new("Highlight")
				hl.Name = "ZuaEnemyCham"
				hl.FillColor = Color3.fromRGB(255, 70, 70)
				hl.OutlineColor = Color3.fromRGB(255, 200, 200)
				hl.FillTransparency = 0.6
				hl.Parent = p.Character
				table.insert(enemyHighlights, hl)
			end
		end
	else
		for _, hl in ipairs(enemyHighlights) do
			if hl and hl.Parent then hl:Destroy() end
		end
		table.clear(enemyHighlights)
	end

	-- Aura
	if Config.AuraRepulsora then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local eRoot = p.Character.HumanoidRootPart
				if (eRoot.Position - root.Position).Magnitude < 7 then
					eRoot.AssemblyLinearVelocity = (eRoot.Position - root.Position).Unit * 45 + Vector3.new(0, 16, 0)
				end
			end
		end
	end

	local ball = findBall()
	if not ball then return end

	local dist = (ball.Position - root.Position).Magnitude
	local vel = ball.AssemblyLinearVelocity

	-- AIM / ÁNG / PASE
	if activeModifier and tick() < modifierEndTime and dist < 30 then
		local goal = getNearestGoal(ball.Position)
		if activeModifier == "aim" and goal then
			ball.AssemblyLinearVelocity = (goal + Vector3.new(0, 1.5, 0) - ball.Position).Unit * (58 * Config.PowerMultiplier)
		elseif activeModifier == "angulo" and goal then
			local side = (math.random() > 0.5) and 8 or -8
			ball.AssemblyLinearVelocity = (goal + Vector3.new(side, 5.5, 0) - ball.Position).Unit * (62 * Config.PowerMultiplier)
		elseif activeModifier == "pase" then
			for _, p in ipairs(Players:GetPlayers()) do
				if isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
					if d > 10 and d < 90 then
						ball.AssemblyLinearVelocity = (p.Character.HumanoidRootPart.Position - ball.Position).Unit * 50
						break
					end
				end
			end
		end
	else
		activeModifier = nil
	end

	-- Force Catch
	if Config.ForceCatch and dist < 12 and tick() - lastRemote > 0.55 then
		if CatchBall then pcall(function() CatchBall:FireServer(ball) end) end
		if ChangeOwner then pcall(function() ChangeOwner:FireServer(ball) end) end
		lastRemote = tick()
	end

	-- Magnetismo (v21)
	if Config.Magnetismo and dist < 5.2 and root.AssemblyLinearVelocity.Magnitude > 3 and vel.Magnitude < 18 then
		local target = root.Position + root.CFrame.LookVector * 2.0 - Vector3.new(0, 1.1, 0)
		local pull = (target - ball.Position) * 2.8
		ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity:Lerp(root.AssemblyLinearVelocity + pull, 0.22)
	end

	-- Topspin (v21)
	if Config.Topspin and dist > 10 and dist < 65 and vel.Magnitude > 30 and ball.Position.Y > root.Position.Y + 2 then
		ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity + Vector3.new(0, -1.8, 0)
	end

	-- AutoAim suave (v21)
	if Config.AutoAimSuave and dist < 9 and vel.Magnitude > 28 and tick() - lastBoostTime < 0.6 then
		local goal = getNearestGoal(ball.Position)
		if goal then
			local desired = (goal + Vector3.new(0, 1.6, 0) - ball.Position).Unit
			local current = vel.Unit
			local blended = (current * 0.72 + desired * 0.28).Unit
			ball.AssemblyLinearVelocity = blended * vel.Magnitude
		end
	end

	-- Soft Touch
	if Config.SoftTouch and dist < 10 and vel.Y < -14 then
		ball.AssemblyLinearVelocity = Vector3.new(vel.X * 0.4, 5, vel.Z * 0.4)
	end

	-- Anti-Robo
	if Config.AntiRobo and dist < 5.5 then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not isTeammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				if (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 5 then
					local push = (ball.Position - p.Character.HumanoidRootPart.Position).Unit
					ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity + Vector3.new(push.X * 10, 0, push.Z * 10)
				end
			end
		end
	end

	-- Imán Absoluto
	if Config.ImanAbsoluto and dist < 11 and root.AssemblyLinearVelocity.Magnitude > 2 then
		ball.CFrame = root.CFrame * CFrame.new(0, -1.1, -2.3)
		ball.AssemblyLinearVelocity = root.AssemblyLinearVelocity
	end

	-- Tiro Nuke
	if Config.TiroNuke and dist < 6 and vel.Magnitude > 8 then
		local goal = getNearestGoal(ball.Position)
		if goal then
			ball.AssemblyLinearVelocity = (goal - ball.Position).Unit * 900
		end
	end
end))

Workspace.ChildAdded:Connect(function(obj)
	if obj.Name == "TPS" or obj.Name == "Ball" then
		obj.ChildAdded:Connect(function(child)
			if child:IsA("BodyVelocity") then
				lastBoostTime = tick()
			end
		end)
	end
end)

print("ZuaZua Hub v22 - v21 estable + botones ocultos + más opciones")
