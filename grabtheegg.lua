local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local existingGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CustomPlayerGui")
if existingGui then
	existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomPlayerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function makeDraggable(guiObject)
	local dragging = false
	local dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(1, -65, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 18
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "OPEN"
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Parent = ScreenGui

makeDraggable(OpenButton)

local OpenUICorner = Instance.new("UICorner")
OpenUICorner.CornerRadius = UDim.new(0, 10)
OpenUICorner.Parent = OpenButton

local OpenUIStroke = Instance.new("UIStroke")
OpenUIStroke.Thickness = 2
OpenUIStroke.Color = Color3.fromRGB(80, 80, 110)
OpenUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
OpenUIStroke.Parent = OpenButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 130)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

makeDraggable(MainFrame)

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 12)
MainUICorner.Parent = MainFrame

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Thickness = 2
MainUIStroke.Color = Color3.fromRGB(80, 80, 110)
MainUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainUIStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -50, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 5)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Text = "Auto Move Sequence"
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -38, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.Parent = MainFrame

local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(0, 8)
CloseUICorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenButton.Visible = false
end)

local ActionBtn = Instance.new("TextButton")
ActionBtn.Name = "ActionBtn"
ActionBtn.Size = UDim2.new(1, -30, 0, 45)
ActionBtn.Position = UDim2.new(0, 15, 0, 55)
ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 155)
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.TextSize = 13
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.Text = "Capture The Egg"
ActionBtn.Parent = MainFrame

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 8)
ActionCorner.Parent = ActionBtn

local isRunning = false

local function findSpawnPart()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj.Name == "CaptureTheEggSpawn" and obj:IsA("BasePart") then
			return obj
		end
	end
	return nil
end

local function getNearestPromptToPart(part)
	if not part then return nil end
	
	local nearestPrompt = nil
	local shortestDistance = math.huge

	for _, prompt in pairs(workspace:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") and prompt.Enabled then
			local parentPart = prompt.Parent
			if parentPart and parentPart:IsA("BasePart") then
				local dist = (part.Position - parentPart.Position).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					nearestPrompt = prompt
				end
			end
		end
	end
	return nearestPrompt
end

local function moveToTarget(targetCFrame)
	local step = 7

	while isRunning do
		local char = LocalPlayer.Character
		if not char then 
			task.wait(0.02)
			continue
		end

		local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
		if not hrp then 
			task.wait(0.02)
			continue
		end

		local currentPos = hrp.Position
		local targetPos = targetCFrame.Position
		local fixedY = targetPos.Y

		local startPos2D = Vector3.new(currentPos.X, 0, currentPos.Z)
		local endPos2D = Vector3.new(targetPos.X, 0, targetPos.Z)
		local distance = (endPos2D - startPos2D).Magnitude

		if distance <= step then
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = CFrame.new(targetPos.X, fixedY, targetPos.Z)
			break
		else
			local direction = (endPos2D - startPos2D).Unit
			local nextX = currentPos.X + (direction.X * step)
			local nextZ = currentPos.Z + (direction.Z * step)

			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
			hrp.CFrame = CFrame.new(Vector3.new(nextX, fixedY, nextZ), Vector3.new(targetPos.X, fixedY, targetPos.Z))
		end

		task.wait(0.02)
	end
end

ActionBtn.MouseButton1Click:Connect(function()
	if isRunning then
		isRunning = false
		ActionBtn.Text = "Capture The Egg"
		ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 155)
		return
	end

	isRunning = true
	ActionBtn.Text = "Stop Loop"
	ActionBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

	task.spawn(function()
		local spawnPart = findSpawnPart()
		local spawnCFrame
		
		if spawnPart then
			spawnCFrame = spawnPart.CFrame
		else
			spawnCFrame = CFrame.new(1751.584, 70.576, -364.664)
		end

		moveToTarget(spawnCFrame)

		if not isRunning then return end

		local promptTarget = spawnPart or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if promptTarget then
			local prompt = getNearestPromptToPart(promptTarget)
			if prompt and fireproximityprompt then
				fireproximityprompt(prompt)
			end
		end

		task.wait(0.2)

		local pos1 = CFrame.new(1697.894, 70.276, -364.254)
		local pos2 = CFrame.new(1804.879, 70.276, -364.417)

		while isRunning do
			moveToTarget(pos1)
			if not isRunning then break end
			moveToTarget(pos2)
		end

		ActionBtn.Text = "Capture The Egg"
		ActionBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 155)
		isRunning = false
	end)
end)
