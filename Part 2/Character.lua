local UserInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local camera = game.Workspace.Camera

UserInputService.InputBegan:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.LeftShift then
		if humanoid then
			humanoid.WalkSpeed = 35
		end
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.LeftShift then
		if humanoid then
			humanoid.WalkSpeed = 20
		end	
	end
end)

runService.RenderStepped:Connect(function()
	if humanoid  then
		if humanoid.MoveDirection.Magnitude > 0 then
			local headBobY = math.sin(tick() * 10) * .3
			
			if humanoid.WalkSpeed == 20 then
				headBobY = math.sin(tick() * 10) * .3
				
			elseif humanoid.WalkSpeed == 35 then
				headBobY = math.sin(tick() * 15) * .4
			end
			
			local bob = Vector3.new(0, headBobY, 0)
			
			humanoid.CameraOffset = humanoid.CameraOffset:Lerp(bob, 1)
			
		else
			humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.new(), 1)
		end
	end
end)