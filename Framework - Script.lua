local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = game.Workspace.CurrentCamera

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
	for i, v in pairs(camera:GetChildren()) do
		if v:IsA("Model") then
			v:SetPrimaryPartCFrame(camera.CFrame )
		end
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
end)