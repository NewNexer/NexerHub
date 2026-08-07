-- Auto slap orb
workspace.ChildAdded:Connect(function(c)
if c.Name=="StaticOrb" then
local args = {
	c,
	vector.create(-0.5, -0.5, -0.5)
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SlapPest"):FireServer(unpack(args))
end
end)
-- Remove Fall Damage
if game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("ArenaFallDamage") then
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ArenaFallDamage"):Destroy()
end
-- Slap Eyes, Lamps and orb and regen mana
while task.wait(.05) do
if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool"):Activate()
end
if workspace:FindFirstChild("StartCorridor") and workspace:WaitForChild("StartCorridor"):FindFirstChild("FinalRing") then
for i,v in next, workspace:WaitForChild("StartCorridor"):WaitForChild("FinalRing"):GetChildren() do
if v and v:FindFirstChild("RotatingBloomingLight") and v:WaitForChild("RotatingBloomingLight"):FindFirstChild("RotatingModel") and v:WaitForChild("RotatingBloomingLight"):WaitForChild("RotatingModel"):FindFirstChild("MidPedastal") then
local args = {
	v:WaitForChild("RotatingBloomingLight"):WaitForChild("RotatingModel"):WaitForChild("MidPedastal"),
	vector.create(-0.5, -0.5, -0.5)
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SlapPest"):FireServer(unpack(args))
end
end
end
if workspace:FindFirstChild("LaserEye") and workspace:WaitForChild("LaserEye"):FindFirstChild("Base") then
local args = {
	workspace:WaitForChild("LaserEye"):WaitForChild("Base"),
	vector.create(-0.5, -0.5, -0.5)
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SlapPest"):FireServer(unpack(args))
end
if workspace:FindFirstChild("ChomperEye") and workspace:WaitForChild("ChomperEye"):FindFirstChild("Base") then
local args = {
	workspace:WaitForChild("ChomperEye"):WaitForChild("Base"),
	vector.create(-0.5, -0.5, -0.5)
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SlapPest"):FireServer(unpack(args))
end
if workspace:FindFirstChild("LightOrb") then
local args = {
	workspace:WaitForChild("LightOrb"),
	vector.create(-0.5, -0.5, -0.5)
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SlapPest"):FireServer(unpack(args))
end
game:GetService("ReplicatedStorage").Remotes.ManaSpend:FireServer(-math.huge)
end
