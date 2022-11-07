local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = game.Workspace.CurrentCamera

local aimCF = CFrame.new()

local mouse = player:GetMouse()

local isAiming = false
local isShooting = false
local isReloading = false
local debounce = false 
local canShoot = true

local swayAMT = -.3
local currentSwayAMT = -.3
local aimSwayAMT = .2
local swayCF = CFrame.new()
local lastCameraCF = CFrame.new()

local fireAnim = nil

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
			
			if framework.viewmodel and framework.module and character then
				fireAnim = Instance.new("Animation")
				fireAnim.Parent = framework.viewmodel
				fireAnim.Name = "Fire"
				fireAnim.AnimationId = framework.module.fireAnim
				fireAnim = framework.viewmodel.AnimationController.Animator:LoadAnimation(fireAnim)
				
				game.ReplicatedStorage.Events.LoadSlot:FireServer(framework.module.fireSound.SoundId, framework.module.fireSound.Volume)
			end
		end
	end
end

local hud = player.PlayerGui:WaitForChild("HUD")

RunService.RenderStepped:Connect(function()
	
	local humanoid = character:WaitForChild("Humanoid")
	
	local rot = camera.CFrame:ToObjectSpace(lastCameraCF)
	local X,Y,Z = rot:ToOrientation()
	swayCF = swayCF:Lerp(CFrame.Angles(math.sin(X) * currentSwayAMT, math.sin(Y) * currentSwayAMT, 0), .1)
	lastCameraCF = camera.CFrame
	
	if framework.viewmodel and framework.module then
		hud.ImageLabel.Frame.GunName.Text = framework.inventory[framework.currentSlot]
		hud.ImageLabel.Frame.AmmoAMT.Text = framework.module.maxAmmo
		hud.ImageLabel.Frame.AmmoInMag.Text = framework.module.ammo
		hud.ImageLabel.Select.Text = framework.module.fireMode
	end
	
	if humanoid then
		local bobOffset = CFrame.new()
		
		if humanoid.MoveDirection.Magnitude > 0 then
			if humanoid.WalkSpeed == 20 then
				bobOffset = bobOffset:Lerp(CFrame.new(math.cos(tick() * 5) * .125, -humanoid.CameraOffset.Y/6, -humanoid.CameraOffset.Z/6) * CFrame.Angles(math.cos(tick() * 2) * .025, math.sin(tick() * 4) * .05, 0), 1)
			elseif humanoid.WalkSpeed == 35 then
				bobOffset = bobOffset:Lerp(CFrame.new(math.cos(tick() * 7.5) * .2, -humanoid.CameraOffset.Y/6, -humanoid.CameraOffset.Z/6) * CFrame.Angles(math.cos(tick() * 1) * .025, math.sin(tick() * 2) * .025, 0) * framework.module.sprintCF, 1)
			elseif humanoid.WalkSpeed == 10 and isAiming ~= true then
				bobOffset = bobOffset:Lerp(CFrame.new(math.cos(tick() * 2.5) * .125/2, -humanoid.CameraOffset.Y/6, -humanoid.CameraOffset.Z/6) * CFrame.Angles(math.cos(tick() * 1) * .025, math.sin(tick() * 2) * .025, 0), 1)
			end
			
		else
			bobOffset = bobOffset:Lerp(CFrame.new(0, -humanoid.CameraOffset.Y/6, 0), .1)
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
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if character and framework.viewmodel and framework.module and framework.module.ammo ~= 0 and debounce == false and isReloading ~= true and canShoot == true then
			if framework.module.fireMode == "Semi" then
				fireAnim:Play()
				framework.module.ammo -= 1
				game.ReplicatedStorage.Events.Shoot:FireServer()
				debounce = true
				wait(framework.module.debounce)
				debounce = false 
			end
			
			if framework.module.fireMode == "Full Auto" then
				isShooting = true
			end
		end
	end
	
	if input.KeyCode == Enum.KeyCode.R then
		canShoot = false
		isReloading = true
		humanoid.WalkSpeed = 10
		
		wait(framework.module.reloadTime)
		
		humanoid.WalkSpeed = 20
		framework.module.ammo = framework.module.maxAmmo
		canShoot = true
		isReloading = false
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and humanoid then
		isAiming = false
		humanoid.WalkSpeed = 20
	end
end)

while wait() do
	if isShooting and framework.module.ammo > 0 and isReloading ~= true and canShoot == true then
		fireAnim:Play()
		framework.module.ammo -= 1
		game.ReplicatedStorage.Events.Shoot:FireServer()
		
		debounce = true
		wait(framework.module.debounce)
		debounce = false

		mouse.Button1Up:Connect(function()
			isShooting = false
		end)

		wait(framework.module.fireRate)
	end
end 
