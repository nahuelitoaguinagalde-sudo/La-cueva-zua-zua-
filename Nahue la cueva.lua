-- =====================================================
-- ZuaZua Hub V9 - Ultimate Fixed Edition 💖⚽⚠️
-- Creado por: Nahue-dev (Optimizado con base en tus imágenes)
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ZuaZuaBaseHub") then
	playerGui.ZuaZuaBaseHub:Destroy()
end

--===================== CONFIGURACIÓN Y ESTADO =====================
local Config = {
	-- Botones Flotantes (Visibilidad)
	ShowAim = false,
	ShowAngulo = false,
	ShowPase = false,
	-- MC (Medio)
	Magnetismo = false,
	RecepcionAerea = false,
	AntiRobo = false,
	-- DEF (Defensa)
	FriccionAire = false,
	RoboAnticipado = false,
	AutoTackle = false,
	FrenadoSeco = false,
	-- DEL (Ataque)
	Topspin = false,
	AutoCabezazo = false,
	Prediccion = false,
	-- GK (Portero)
	GKAura = false,
	AutoDive = false,
	-- RIESGO (Exploits)
	Noclip = false,
	InfJump = false,
	SpeedHack = false,
	WalkSpeed = 16
}

local scriptStartTime = tick()
local processedBalls = {}
local dropIndicator = nil

--===================== FUNCIONES MATEMÁTICAS =====================
local function getNearestGoal(ballPos)
	local bestPos = nil
	local minDist = 250 
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local name = obj.Name:lower()
			if name:find("goal") or name:find("arco") or name:find("net") or name:find("porteria") then
				local dist = (obj.Position - ballPos).Magnitude
				if dist < minDist then
					minDist = dist
					bestPos = obj.Position
				end
			end
		end
	end
	return bestPos
end

local function getNearestTeammate(myPos)
	local bestPlayer = nil
	local minDist = 150
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player.Team == LocalPlayer.Team or not LocalPlayer.Team then
				local dist = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
				if dist < minDist and dist > 10 then
					minDist = dist
					bestPlayer = player.Character.HumanoidRootPart
				end
			end
		end
	end
	return bestPlayer
end

local function createDropIndicator()
	local part = Instance.new("Part")
	part.Size = Vector3.new(3.5, 0.2, 3.5)
	part.Shape = Enum.PartType.Cylinder
	part.Color = Color3.fromRGB(255, 50, 50)
	part.Material = Enum.Material.Neon
	part.Transparency = 0.5
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Parent = Workspace
	return part
end

--===================== INTERFAZ GRÁFICA (UI) =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZuaZuaBaseHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- BOTONES FLOTANTES DE ACCIÓN (Se muestran según config)
local btnAim = Instance.new("TextButton")
btnAim.Size = UDim2.new(0, 55, 0, 55)
btnAim.Position = UDim2.new(0.83, 0, 0.35, 0)
btnAim.BackgroundColor3 = Color3.fromRGB(45, 210, 100)
btnAim.Text = "AIM"
btnAim.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAim.Font = Enum.Font.GothamBold
btnAim.TextSize = 14
btnAim.Visible = false
btnAim.Parent = screenGui
Instance.new("UICorner", btnAim).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", btnAim).Thickness = 2

local btnAngulo = Instance.new("TextButton")
btnAngulo.Size = UDim2.new(0, 55, 0, 55)
btnAngulo.Position = UDim2.new(0.83, 0, 0.47, 0)
btnAngulo.BackgroundColor3 = Color3.fromRGB(210, 45, 100)
btnAngulo.Text = "ÁNGULO"
btnAngulo.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAngulo.Font = Enum.Font.GothamBold
btnAngulo.TextSize = 11
btnAngulo.Visible = false
btnAngulo.Parent = screenGui
Instance.new("UICorner", btnAngulo).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", btnAngulo).Thickness = 2

local btnPase = Instance.new("TextButton")
btnPase.Size = UDim2.new(0, 55, 0, 55)
btnPase.Position = UDim2.new(0.83, 0, 0.59, 0)
btnPase.BackgroundColor3 = Color3.fromRGB(45, 100, 210)
btnPase.Text = "PASE"
btnPase.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPase.Font = Enum.Font.GothamBold
btnPase.TextSize = 12
btnPase.Visible = false
btnPase.Parent = screenGui
Instance.new("UICorner", btnPase).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", btnPase).Thickness = 2

-- LÓGICA DE LOS BOTONES FLOTANTES
local function executeShotModifier(type)
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, ball in pairs(workspace:GetChildren()) do
		if ball.Name == "TPS" and ball:IsA("BasePart") then
			local dist = (ball.Position - root.Position).Magnitude
			local vel = ball.AssemblyLinearVelocity
			
			if dist < 30 and vel.Magnitude > 8 then
				if type == "aim" or type == "angulo" then
					local targetGoal = getNearestGoal(ball.Position)
					if targetGoal then
						local aimPos = targetGoal + Vector3.new(0, 1.5, 0)
						if type == "angulo" then
							local sideOffset = (math.random() > 0.5) and 8.5 or -8.5
							aimPos = targetGoal + Vector3.new(sideOffset, 5.5, 0) 
						end
						local directVector = (aimPos - ball.Position).Unit
						ball.AssemblyLinearVelocity = directVector * vel.Magnitude
					end
				elseif type == "pase" then
					local targetTeammate = getNearestTeammate(root.Position)
					if targetTeammate then
						local predictPos = targetTeammate.Position + (targetTeammate.AssemblyLinearVelocity * 0.5)
						local directVector = (predictPos - ball.Position).Unit
						ball.AssemblyLinearVelocity = directVector * vel.Magnitude
					end
				end
			end
		end
	end
end

btnAim.MouseButton1Click:Connect(function() executeShotModifier("aim") end)
btnAngulo.MouseButton1Click:Connect(function() executeShotModifier("angulo") end)
btnPase.MouseButton1Click:Connect(function() executeShotModifier("pase") end)

-- UI PRINCIPAL (MENÚ FLOTANTE)
local toggleMenu = Instance.new("TextButton")
toggleMenu.Size = UDim2.new(0, 45, 0, 45)
toggleMenu.Position = UDim2.new(0.02, 0, 0.3, 0)
toggleMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
toggleMenu.Text = "⚙️"
toggleMenu.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenu.Font = Enum.Font.GothamBold
toggleMenu.TextSize = 20
toggleMenu.Parent = screenGui
Instance.new("UICorner", toggleMenu).CornerRadius = UDim.new(1, 0)

local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 540, 0, 380)
mainPanel.Position = UDim2.new(0.5, -270, 0.5, -190)
mainPanel.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
mainPanel.Visible = false
mainPanel.Parent = screenGui
Instance.new("UICorner", mainPanel).CornerRadius = UDim.new(0, 10)
local stroke2 = Instance.new("UIStroke", mainPanel)
stroke2.Color = Color3.fromRGB(40, 60, 90)
stroke2.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
titleBar.Parent = mainPanel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🛡️ ZuaZua Hub v9 - God Mode & Control"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() mainPanel.Visible = false end)
toggleMenu.MouseButton1Click:Connect(function() mainPanel.Visible = not mainPanel.Visible end)

local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 130, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
sidebar.ScrollBarThickness = 2
sidebar.Parent = mainPanel
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Parent = sidebar
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.Padding = UDim.new(0, 6)

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -140, 1, -45)
contentArea.Position = UDim2.new(0, 135, 0, 40)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainPanel

-- SISTEMA DE PÁGINAS
local pages = {}
local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
	page.Visible = false
	page.Parent = contentArea
	
	local layout = Instance.new("UIListLayout")
	layout.Parent = page
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	pages[name] = page
	return page
end

local pageInfo = createPage("Inicio")
local pageAtaque = createPage("Ataque")
local pageMedio = createPage("Medio")
local pageDefensa = createPage("Defensa")
local pageGK = createPage("GK")
local pageRiesgo = createPage("Riesgo")
pages["Inicio"].Visible = true

local function createTabButton(text, pageName, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.85, 0, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
	btn.Text = text
	btn.TextColor3 = color or Color3.fromRGB(180, 190, 220)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 12
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		pages[pageName].Visible = true
		for _, v in pairs(sidebar:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
	end)
end

createTabButton("🏠 Inicio", "Inicio")
createTabButton("🎯 Ataque", "Ataque")
createTabButton("🧲 Medio", "Medio")
createTabButton("🛡️ Defensa", "Defensa")
createTabButton("🧤 Portero", "GK")
createTabButton("⚠️ RIESGO", "Riesgo", Color3.fromRGB(255, 60, 60))

-- CREADOR DE OPCIONES CON DESCRIPCIÓN
local function createToggleInfo(page, text, desc, configKey, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0.95, 0, 0, 65)
	container.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	container.Parent = page
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 30)
	btn.Position = UDim2.new(0.025, 0, 0, 5)
	btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
	btn.Text = text .. "   [ OFF ]"
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local strk = Instance.new("UIStroke", btn)
	strk.Color = Color3.fromRGB(210, 45, 45)
	strk.Thickness = 1.5

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.95, 0, 0, 25)
	descLabel.Position = UDim2.new(0.025, 0, 0, 38)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 10
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = container

	btn.MouseButton1Click:Connect(function()
		Config[configKey] = not Config[configKey]
		if Config[configKey] then
			btn.Text = text .. "   [ ON ]"
			strk.Color = Color3.fromRGB(45, 210, 100)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			btn.Text = text .. "   [ OFF ]"
			strk.Color = Color3.fromRGB(210, 45, 45)
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		if callback then callback(Config[configKey]) end
	end)
end

-- ================= PÁGINA INICIO =================
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0.95, 0, 0, 150)
infoFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
infoFrame.Parent = pageInfo
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", infoFrame).Color = Color3.fromRGB(50, 60, 80)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -20)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Cargando info..."
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 13
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = infoFrame

task.spawn(function()
	while task.wait(1) do
		local uptime = math.floor(tick() - scriptStartTime)
		local mins = math.floor(uptime / 60)
		local secs = uptime % 60
		local players = #Players:GetPlayers()
		infoLabel.Text = string.format("👑 Creador: Nahue-dev\n\n🌐 Estado: Conectado a Imágenes Pro\n👥 Jugadores: %d/30\n⏱️ Sesión: %02d:%02d\n🛡️ Cero Lag Activado", players, mins, secs)
	end
end)

-- ================= LLENADO DE OPCIONES =================
-- ATAQUE (DEL)
createToggleInfo(pageAtaque, "🎯 Activar Botón AIM", "Muestra el botón flotante AIM en pantalla para disparar al arco sin fallo.", "ShowAim", function(val) btnAim.Visible = val end)
createToggleInfo(pageAtaque, "📐 Activar Botón ÁNGULO", "Muestra el botón ÁNGULO para mandar la pelota directo a las escuadras.", "ShowAngulo", function(val) btnAngulo.Visible = val end)
createToggleInfo(pageAtaque, "🦅 Auto-Cabezazo Automático", "Remata de cabeza directo al arco cuando un centro alto pasa cerca tuyo.", "AutoCabezazo")
createToggleInfo(pageAtaque, "📉 Topspin (Caída Rápida)", "Efecto de gravedad artificial para que tus tiros bajen de golpe al arco.", "Topspin")
createToggleInfo(pageAtaque, "🔮 Predicción de Balón (ESP)", "Muestra un círculo rojo en el suelo indicando dónde caerá la pelota.", "Prediccion")

-- MEDIO (MC)
createToggleInfo(pageMedio, "🎯 Activar Botón PASE Láser", "Muestra el botón PASE para conectar asistencias perfectas a tus compañeros.", "ShowPase", function(val) btnPase.Visible = val end)
createToggleInfo(pageMedio, "🧲 Dribbling Sutil al Pie", "Mantiene la pelota pegada a tus pies al conducir sin tirones raros.", "Magnetismo")
createToggleInfo(pageMedio, "🛡️ Protección Anti-Robo", "Aleja sutilmente la pelota si un rival se te viene muy encimado.", "AntiRobo")
createToggleInfo(pageMedio, "🪂 Recepción Aérea Suave", "Amortigua los pases altos para bajarlos al instante en el pie.", "RecepcionAerea")

-- DEFENSA (DEF)
createToggleInfo(pageDefensa, "💨 Fricción de Pases", "Frena la velocidad de los pases contrarios que pasan cerca tuyo.", "FriccionAire")
createToggleInfo(pageDefensa, "⚡ Sombra de Intercepción", "Te da un micro-impulso automático para cortar líneas de pase.", "RoboAnticipado")
createToggleInfo(pageDefensa, "🛡️ Tackle Asistido", "Mejora tus barridas en el suelo para ganar siempre el balón.", "AutoTackle")
createToggleInfo(pageDefensa, "🛑 Frenado en Seco", "Detiene tu inercia al soltar las teclas para giros de 360 grados sin patinar.", "FrenadoSeco")

-- PORTERO (GK)
createToggleInfo(pageGK, "🧤 Auto-Dive (Salto de Arquero)", "Salta automáticamente hacia los remates fuertes si vas al arco.", "AutoDive")
createToggleInfo(pageGK, "✨ Aura Bloqueadora", "Frena los tiros que pasen rozando tu cuerpo para evitar goles hechos.", "GKAura")

-- RIESGO (EXPLOITS)
createToggleInfo(pageRiesgo, "👻 Noclip (Atravesar Todo)", "Permite caminar a través de paredes, redes y rivales.", "Noclip")
createToggleInfo(pageRiesgo, "🚀 Infinite Jump", "Salta infinitas veces en el aire presionando la barra espaciadora.", "InfJump")
createToggleInfo(pageRiesgo, "⚡ SpeedHack Agresivo", "Aumenta drásticamente tu velocidad base en la cancha.", "SpeedHack")

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0.95, 0, 0, 45)
speedFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
speedFrame.Parent = pageRiesgo
Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, 0, 1, 0)
speedBtn.BackgroundTransparency = 1
speedBtn.Text = "⚡ Vel. Actual: 16 (Toca para +10)"
speedBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 13
speedBtn.Parent = speedFrame

speedBtn.MouseButton1Click:Connect(function()
	Config.WalkSpeed = Config.WalkSpeed + 10
	if Config.WalkSpeed > 60 then Config.WalkSpeed = 16 end
	speedBtn.Text = "⚡ Vel. Actual: " .. Config.WalkSpeed .. " (Toca para +10)"
end)

--===================== SISTEMA DE ARRASTRE =====================
local function makeDraggable(guiObject)
	local dragging, dragStart, startPos, dragInput
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = guiObject.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end
makeDraggable(mainPanel)
makeDraggable(toggleMenu)
makeDraggable(btnAim)
makeDraggable(btnAngulo)
makeDraggable(btnPase)

--===================== EVENTOS DE RIESGO =====================
RunService.Stepped:Connect(function()
	if Config.Noclip then
		local char = LocalPlayer.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
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

--===================== MOTOR CENTRAL (HEARTBEAT) =====================
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	if Config.SpeedHack then
		hum.WalkSpeed = Config.WalkSpeed
	else
		if hum.WalkSpeed > 25 then hum.WalkSpeed = 16 end 
	end

	if Config.FrenadoSeco and hum.MoveDirection.Magnitude == 0 then
		root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
	end

	for _, ball in pairs(workspace:GetChildren()) do
		if ball.Name == "TPS" and ball:IsA("BasePart") then
			local dist = (ball.Position - root.Position).Magnitude
			local vel = ball.AssemblyLinearVelocity
			local isMoving = root.AssemblyLinearVelocity.Magnitude > 2

			-- Magnetismo
			if Config.Magnetismo and dist < 7 and isMoving and vel.Magnitude < 25 then
				local targetPos = root.Position + (root.CFrame.LookVector * 2.5) - Vector3.new(0, 1.2, 0)
				local pullVector = (targetPos - ball.Position)
				ball.AssemblyLinearVelocity = root.AssemblyLinearVelocity + (pullVector * 5)
			end

			-- Anti-Robo
			if Config.AntiRobo and dist < 6 and vel.Magnitude < 20 then
				for _, enemy in pairs(Players:GetPlayers()) do
					if enemy ~= LocalPlayer and enemy.Team ~= LocalPlayer.Team and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
						local enemyDist = (enemy.Character.HumanoidRootPart.Position - root.Position).Magnitude
						if enemyDist < 5.5 then
							local pushDir = (ball.Position - enemy.Character.HumanoidRootPart.Position).Unit
							ball.AssemblyLinearVelocity += Vector3.new(pushDir.X * 10, 0, pushDir.Z * 10)
						end
					end
				end
			end

			-- Recepción Aérea
			if Config.RecepcionAerea and dist < 12 and not processedBalls[ball] then
				if vel.Y < -15 and ball.Position.Y > root.Position.Y then
					processedBalls[ball] = true
					ball.AssemblyLinearVelocity = Vector3.new(vel.X * 0.3, 5, vel.Z * 0.3)
					task.delay(1, function() processedBalls[ball] = nil end)
				end
			end

			-- Topspin
			if Config.Topspin and dist > 10 and dist < 60 and vel.Magnitude > 40 and not processedBalls[ball] then
				ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity - Vector3.new(0, 1.5, 0)
			end

			-- Predicción ESP
			if Config.Prediccion then
				if vel.Magnitude > 15 and ball.Position.Y > root.Position.Y + 5 then
					if not dropIndicator then dropIndicator = createDropIndicator() end
					dropIndicator.Parent = Workspace
					local timeToGround = math.abs(vel.Y) / workspace.Gravity + math.sqrt(2 * ball.Position.Y / workspace.Gravity)
					local predictedX = ball.Position.X + (vel.X * timeToGround)
					local predictedZ = ball.Position.Z + (vel.Z * timeToGround)
					dropIndicator.Position = Vector3.new(predictedX, root.Position.Y - 2.5, predictedZ)
				else
					if dropIndicator then dropIndicator.Parent = nil end
				end
			else
				if dropIndicator then dropIndicator:Destroy() dropIndicator = nil end
			end

			-- Fricción de Aire
			if Config.FriccionAire and dist < 22 and vel.Magnitude > 15 then
				local dot = root.CFrame.LookVector:Dot(vel.Unit)
				if dot < 0.2 then
					ball.AssemblyLinearVelocity = vel * 0.90
				end
			end

			-- Robo Anticipado
			if Config.RoboAnticipado and dist < 30 and vel.Magnitude > 25 then
				local dot = root.CFrame.LookVector:Dot(vel.Unit)
				if dot < 0.1 then 
					local interceptDir = (ball.Position - root.Position).Unit
					root.AssemblyLinearVelocity += Vector3.new(interceptDir.X * 2, 0, interceptDir.Z * 2)
				end
			end

			-- Auto Tackle
			if Config.AutoTackle and dist < 15 and dist > 3 and vel.Magnitude < 30 then
				local distDot = (ball.Position - root.Position).Unit:Dot(root.CFrame.LookVector)
				if distDot > 0.6 then
					root.AssemblyLinearVelocity += (ball.Position - root.Position).Unit * 2.5
				end
			end

			-- GK Aura
			if Config.GKAura and dist < 7.5 and vel.Magnitude > 20 then
				ball.AssemblyLinearVelocity = vel * 0.4
			end

			-- Auto Cabezazo
			if Config.AutoCabezazo and dist < 10 and ball.Position.Y > root.Position.Y + 3.5 and vel.Magnitude > 10 and not processedBalls[ball] then
				local targetGoal = getNearestGoal(ball.Position)
				if targetGoal then
					processedBalls[ball] = true
					local aimPos = targetGoal + Vector3.new(0, 1.5, 0)
					local directVector = (aimPos - ball.Position).Unit
					ball.AssemblyLinearVelocity = directVector * (vel.Magnitude * 1.2)
					task.delay(1.5, function() processedBalls[ball] = nil end)
				end
			end

			-- Auto Dive
			if Config.AutoDive and dist < 35 and vel.Magnitude > 25 and not processedBalls[ball] then
				local towardsMe = (root.Position - ball.Position).Unit:Dot(vel.Unit)
				if towardsMe > 0.6 then
					processedBalls[ball] = true
					local jumpDir = (ball.Position - root.Position).Unit
					root.AssemblyLinearVelocity = Vector3.new(jumpDir.X * 40, 18, jumpDir.Z * 40)
					task.delay(2, function() processedBalls[ball] = nil end)
				end
			end

		end
	end
end)

print("ZuaZua Hub V9 (Final Corregido) Cargado 💖⚽⚠️")
