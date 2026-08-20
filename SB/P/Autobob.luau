local LocalPlayer, LP = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer
local Character, Char
local HumanoidRootPart, HRP
local Humanoid, Hum
local headconn
pcall(function()
Character, Char = LocalPlayer.Character, LocalPlayer.Character
end)
pcall(function()
HumanoidRootPart, HRP = Character.HumanoidRootPart, Character.HumanoidRootPart
end)
pcall(function()
Humanoid, Hum = Character.Humanoid, Character.Humanoid
end)

local SelectGlove = function(g) repeat task.wait(.1) fireclickdetector(workspace.Lobby[g]:FindFirstChildWhichIsA("ClickDetector",true)) until LocalPlayer.leaderstats.Glove.Value==g task.wait(.1) end

local msghint = Instance.new("Hint")
msghint.Parent = game:GetService("CoreGui")
msghint.Text = "Getting ready... (1/4)"
if workspace:FindFirstChild("ÅBOB_"..LocalPlayer.Name) then
workspace["ÅBOB_"..LocalPlayer.Name]:Destroy()
end
task.spawn(function()
repeat task.wait()
HumanoidRootPart:PivotTo(CFrame.new(-125, -5, 121))
task.wait()
until Humanoid.Health==0
end)
task.wait(2.5) -- Waiting so that player gets locked here ( very important btw )
msghint.Text = "Getting ready... (2/4)"
SelectGlove("Counter")
game:GetService("ReplicatedStorage").Counter:FireServer() -- This can set isinarena to true
repeat task.wait() until Character.isInArena.Value==true
msghint.Text = "Getting ready... (3/4)"
SelectGlove("Screwdriver")
game:GetService("ReplicatedStorage").GeneralAbility:FireServer() -- This anchors humanoidrootpart
task.wait(1)
msghint.Text = "Getting ready... (4/4)"
SelectGlove("Replica")
local msghint = Instance.new("Hint")
msghint.Parent = game:GetService("CoreGui")
msghint.Text = "Waiting for bob... ( Just wait, can take 30+ seconds )"
game:GetService("RunService").RenderStepped:Connect(function()
game:GetService("GuiService"):ClearError()
pcall(function()
game:GetService("CoreGui").RobloxLoadingGUI:Destroy()
end)
end)
for i=1,200000 do
game:GetService("ReplicatedStorage").Duplicate:FireServer(true) -- Replica can't spawn with anchored humanoidrootpart
end
repeat task.wait() until workspace:FindFirstChild("ÅBOB_"..LocalPlayer.Name) -- But bob can :)))
msghint.Text = "Bob appeared. Rejoining to revert lags..."
task.wait(3)
while task.wait(.05) do
task.spawn(function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)
end
