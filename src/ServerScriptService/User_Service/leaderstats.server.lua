local Players = game:GetService("Players")

local User_Handler = require(script.Parent.User_Handler)

local function onPlayerAdded(player : Player)		
	local playerUserStore = User_Handler.getUser(player)
	
	if not playerUserStore then return end
	
	local leaderstatsFolder = Instance.new("Folder")
	leaderstatsFolder.Name = "leaderstats"
	leaderstatsFolder.Parent = player
	
	for dataKey, value in playerUserStore.data do
		local newValue = Instance.new("NumberValue")
		newValue.Name = dataKey
		newValue.Value = value
		newValue.Parent = leaderstatsFolder
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
