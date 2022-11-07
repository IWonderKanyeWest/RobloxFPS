game.ReplicatedStorage.Events.LoadSlot.OnServerEvent:Connect(function(player, SoundId, Volume)
	if player.Character then
		for i, v in pairs(player.Character.UpperTorso:GetChildren()) do
			if v.Name == "FireSound" then
				v:Destroy()
			end
		end
		
		local fireSound = Instance.new("Sound")
		fireSound.Parent = player.Character.UpperTorso
		fireSound.Name = "FireSound"
		fireSound.SoundId = SoundId 
		fireSound.Volume = Volume
		
	end
end)
game.ReplicatedStorage.Events.Shoot.OnServerEvent:Connect(function(player)
	if player.Character then
		local sound = player.Character.UpperTorso:FindFirstChild("FireSound")
		if sound then
			sound:Play()
		end
	end
end)
