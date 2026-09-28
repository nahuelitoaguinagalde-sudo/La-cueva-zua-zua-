-- ZuaZua Hub (GitHub)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ZuaZuaHub") then
	playerGui.ZuaZuaHub:Destroy()
end

local Config = {
	ESP = false,
	Magnetismo = false,
	Topspin = false,
	AutoAim = false,
	Speed = false,
	ShowPower = false,
	AntiRobo = false,
	Iman = false,
	Mul = 1.55,
}

local highlights = {}
local lastBoost = 0
local charging = false
local charge = 0

local function teammate(p)
	if p == LocalPlayer then return false end
	if p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then return true end
	return false
end

local function getBall()
	local b = Workspace:FindFirstChild("TPS") or Workspace:FindFirstChild("Ball")
	if b and b:IsA("BasePart") then return b end
	return nil
end

local function getGoal(pos)
	local best, d = nil, 300
	for _, o in ipairs(Workspace:GetDescendants()) do
		if o:IsA("BasePart") then
			local n = o.Name:lower()
			if n:find("goal") or n:find("arco") or n:find("porteria") then
				local dist = (o.Position - pos).Magnitude
				if dist < d then
					d = dist
					best = o.Position
				end
			end
		end
	end
	return best
end

local gui = Instance.new("ScreenGui")
gui.Name = "ZuaZuaHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 55, 0, 55)
menuBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
menuBtn.BackgroundColor3 = Color3.fromRGB(193, 154, 107)
menuBtn.Text = "📦"
menuBtn.TextSize = 24
menuBtn.Font = Enum.Font.GothamBold
menuBtn.Parent = gui
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0.2, 0)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 340)
panel.Position = UDim2.new(0.5, -150, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(181, 136, 92)
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

for i = 0, 60 do
	local s = Instance.new("Frame")
	s.Size = UDim2.new(1, 0, 0, 2)
	s.Position = UDim2.new(0, 0, 0, i * 6)
	s.BackgroundColor3 = Color3.fromRGB(158, 116, 76)
	s.BorderSizePixel = 0
	s.ZIndex = 0
	s.Parent = panel
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 34)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "ZuaZua Hub"
title.TextColor3 = Color3.fromRGB(30, 30, 30)
title.Font = Enum.Font.PatrickHand
title.TextSize = 22
title.ZIndex = 2
title.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -34, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.ZIndex = 2
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

close.MouseButton1Click:Connect(function()
	panel.Visible = false
end)
menuBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.92, 0, 0.82, 0)
scroll.Position = UDim2.new(0.04, 0, 0.14, 0)
scroll.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
scroll.ZIndex = 2
scroll.Parent = panel
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 5)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 5)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

local power = Instance.new("TextButton")
power.Size = UDim2.new(0, 64, 0, 64)
power.Position = UDim2.new(0.82, 0, 0.55, 0)
power.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
power.Text = "POWER"
power.TextColor3 = Color3.fromRGB(255, 255, 255)
power.Font = Enum.Font.GothamBold
power.TextSize = 12
power.Visible = false
power.Parent = gui
Instance.new("UICorner", power).CornerRadius = UDim.new(1, 0)

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 64, 0, 8)
barBg.Position = UDim2.new(0, 0, 1, 5)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBg.BorderSizePixel = 0
barBg.Parent = power
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 220, 100)
bar.BorderSizePixel = 0
bar.Parent = barBg
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

power.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		charging = true
		charge = 0
	end
end)

power.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		if charging and charge > 0.25 then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local b = getBall()
			if root and b and (b.Position - root.Position).Magnitude < 12 then
				local look = root.CFrame.LookVector
				local pwr = 55 + (charge * 55) * Config.Mul
				local vel = look * pwr + Vector3.new(0, 8 + charge * 12, 0)
				local bv = b:FindFirstChildOfClass("BodyVelocity")
				if bv then
					bv.Velocity = vel
				else
					b.AssemblyLinearVelocity = vel
				end
				lastBoost = tick()
			end
		end
		charging = false
		charge = 0
		bar.Size = UDim2.new(0, 0, 1, 0)
		power.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	end
end)

local function toggle(text, key, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.94, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(245, 240, 230)
	b.Text = "☐  " .. text
	b.TextColor3 = Color3.fromRGB(30, 30, 30)
	b.Font = Enum.Font.PatrickHand
	b.TextSize = 16
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.ZIndex = 2
	b.Parent = scroll
	b.MouseButton1Click:Connect(function()
		Config[key] = not Config[key]
		if Config[key] then
			b.Text = "☑  " .. text
			b.TextColor3 = Color3.fromRGB(20, 120, 20)
		else
			b.Text = "☐  " .. text
			b.TextColor3 = Color3.fromRGB(30, 30, 30)
		end
		if cb then
			cb(Config[key])
		end
	end)
end

toggle("Mostrar POWER", "ShowPower", function(v)
	power.Visible = v
end)
toggle("ESP Compañeros", "ESP")
toggle("Magnetismo", "Magnetismo")
toggle("Topspin", "Topspin")
toggle("AutoAim Suave", "AutoAim")
toggle("Anti-Robo", "AntiRobo")
toggle("Imán Absoluto", "Iman")
toggle("Speed", "Speed")

local function drag(g)
	local d, s, sp
	g.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true
			s = i.Position
			sp = g.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - s
			g.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function()
		d = false
	end)
end
drag(menuBtn)
drag(panel)
drag(power)

RunService.Heartbeat:Connect(function(dt)
	if charging and power.Visible then
		charge = math.min(charge + dt * 1.4, 1)
		bar.Size = UDim2.new(charge, 0, 1, 0)
		power.BackgroundColor3 = Color3.fromRGB(30, 120 + charge * 80, 50)
	end

	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	if Config.Speed then
		hum.WalkSpeed = 20
	elseif hum.WalkSpeed > 18 then
		hum.WalkSpeed = 16
	end

	if Config.ESP then
		for _, p in ipairs(Players:GetPlayers()) do
			if teammate(p) and p.Character and not p.Character:FindFirstChild("ZuaESP") then
				local h = Instance.new("Highlight")
				h.Name = "ZuaESP"
				h.FillColor = Color3.fromRGB(50, 255, 100)
				h.OutlineColor = Color3.fromRGB(255, 255, 255)
				h.FillTransparency = 0.55
				h.Parent = p.Character
				table.insert(highlights, h)
			end
		end
	else
		for _, h in ipairs(highlights) do
			if h then h:Destroy() end
		end
		highlights = {}
	end

	local b = getBall()
	if not b then return end
	local dist = (b.Position - root.Position).Magnitude
	local vel = b.AssemblyLinearVelocity

	if Config.Magnetismo and dist < 5.2 and root.AssemblyLinearVelocity.Magnitude > 3 and vel.Magnitude < 18 then
		local t = root.Position + root.CFrame.LookVector * 2 - Vector3.new(0, 1.1, 0)
		b.AssemblyLinearVelocity = b.AssemblyLinearVelocity:Lerp(root.AssemblyLinearVelocity + (t - b.Position) * 2.8, 0.22)
	end

	if Config.Topspin and dist > 10 and dist < 65 and vel.Magnitude > 30 and b.Position.Y > root.Position.Y + 2 then
		b.AssemblyLinearVelocity = vel + Vector3.new(0, -1.8, 0)
	end

	if Config.AutoAim and dist < 9 and vel.Magnitude > 28 and tick() - lastBoost < 0.6 then
		local g = getGoal(b.Position)
		if g then
			local des = (g + Vector3.new(0, 1.6, 0) - b.Position).Unit
			b.AssemblyLinearVelocity = (vel.Unit * 0.72 + des * 0.28).Unit * vel.Magnitude
		end
	end

	if Config.AntiRobo and dist < 5.5 then
		for _, p in ipairs(Players:GetPlayers()) do
			if p \~= LocalPlayer and not teammate(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				if (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 5 then
					local push = (b.Position - p.Character.HumanoidRootPart.Position).Unit
					b.AssemblyLinearVelocity = vel + Vector3.new(push.X * 10, 0, push.Z * 10)
				end
			end
		end
	end

	if Config.Iman and dist < 11 and root.AssemblyLinearVelocity.Magnitude > 2 then
		b.CFrame = root.CFrame * CFrame.new(0, -1.1, -2.3)
		b.AssemblyLinearVelocity = root.AssemblyLinearVelocity
	end
end)

print("ZuaZua Hub cargado por GitHub")
