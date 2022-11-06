local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = game.Workspace.CurrentCamera

local aimCF = CFrame.new()

local isAiming = false

local swayAMT = -.3
local currentSwayAMT = -.3
local aimSwayAMT = .2
local swayCF = CFrame.new()
local lastCameraCF = CFrame.new()

local framework = {
	inventory = {
		"M4A1";
		"M9";
		"Knife";
		"Frag";
	};
	
	module = nil;
	viewmodel = nil;
	currentSlot = 1;
	
}

function loadSlot(Item)
	local viewmodelFolder = game.ReplicatedStorage.ViewModels
	local moduleFolder = game.ReplicatedStorage.Modules
	
	for i, v in pairs(camera:GetChildren()) do
		if v:IsA("Model") then
			v:Destroy()
		end
	end
	
	if moduleFolder:FindFirstChild(Item) then
		framework.module = require(moduleFolder:FindFirstChild(Item))
		
		if viewmodelFolder:FindFirstChild(Item) then
			framework.viewmodel = viewmodelFolder:FindFirstChild(Item):Clone()
			framework.viewmodel.Parent = camera
		end
	end
end

RunService.RenderStepped:Connect(function()
	
	local humanoid = character:WaitForChild("Humanoid")
	
	local rot = camera.CFrame:ToObjectSpace(lastCameraCF)
	local X,Y,Z = rot:ToOrientation()
	swayCF = swayCF:Lerp(CFrame.Angles(math.sin(X) * currentSwayAMT, math.sin(Y) * currentSwayAMT, 0), .1)
	lastCameraCF = camera.CFrame
	
	if humanoid then
		local bobOffset = CFrame.new()
		
		if humanoid.MoveDirection.Magnitude > 0 then
			if humanoid.WalkSpeed == 20 then
				bobOffset = CFrame.new(math.cos(tick() * 5) * .125, -humanoid.CameraOffset.Y/6, -humanoid.CameraOffset.Z/6) * CFrame.Angles(math.cos(tick() * 2) * .025, math.sin(tick() * 4) * .05, 0)
			elseif humanoid.WalkSpeed == 35 then
				bobOffset = CFrame.new(math.cos(tick() * 7.5) * .2, -humanoid.CameraOffset.Y/6, -humanoid.CameraOffset.Z/6) * CFrame.Angles(math.cos(tick() * 4) * .05, math.sin(tick() * 8) * .1, 0)
			end
		else
			bobOffset = CFrame.new(0, -humanoid.CameraOffset.Y/6, 0)
		end
		
		for i, v in pairs(camera:GetChildren()) do
			if v:IsA("Model") then
				v:SetPrimaryPartCFrame(camera.CFrame * swayCF * aimCF * bobOffset)
			end
		end
	end
	
	if isAiming and framework.viewmodel ~= nil and framework.module.canAim == true then
		local offset = framework.viewmodel.AimPart.CFrame:ToObjectSpace(framework.viewmodel.PrimaryPart.CFrame)
		aimCF = aimCF:Lerp(offset, framework.module.aimSmooth)
		currentSwayAMT = aimSwayAMT
	else
		local offset = CFrame.new()
		aimCF = aimCF:Lerp(offset, framework.module.aimSmooth)
		currentSwayAMT = swayAMT
	end
end)

loadSlot((framework.inventory[1]))

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.One then
		if framework.currentSlot ~= 1 then
			loadSlot(framework.inventory[1])
			framework.currentSlot = 1
		end
	end
	
	if input.KeyCode == Enum.KeyCode.Two then
		if framework.currentSlot ~= 2 then
			loadSlot(framework.inventory[2])
			framework.currentSlot = 2
		end
	end
	
	if input.KeyCode == Enum.KeyCode.Three then
		if framework.currentSlot ~= 3 then
			loadSlot(framework.inventory[3])
			framework.currentSlot = 3
		end
	end
	
	if input.KeyCode == Enum.KeyCode.Four then
		if framework.currentSlot ~= 4 then
			loadSlot(framework.inventory[4])
			framework.currentSlot = 4
		end
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 and humanoid then
		isAiming = true
		humanoid.WalkSpeed = 10
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and humanoid then
		isAiming = false
		humanoid.WalkSpeed = 20
	end
end)