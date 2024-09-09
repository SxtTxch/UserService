local User_Handler = {}

--// Services:

local PS = game:GetService("Players")

--// Modules:

local User = require(script.Parent.User_Object.User)
local Service_Info = require(script.Parent.Service_Info)

--// Variables:

User_Handler.User_Data = {}

--// Functions:

function User_Handler.Player_Added(player)
	local playerUserStore = User.new(player)

	if playerUserStore:load() then
		print(`UserStore has succesfully loaded for: {player.Name}`)
		User_Handler.User_Data[player] = playerUserStore
	else
		warn(`An error occured while trying to load in the UserStore of: {player.Name}`)
		User_Handler.User_Data[player] = false
	end
end

function User_Handler.Player_Removed(player)
	local playerUserStore = User_Handler.User_Data[player] :: User

	if playerUserStore then
		if playerUserStore:save() then
			print(`UserStore successfully saved for: {player.Name}`)
		else
			warn(`An error occured while trying to save the UserStore of: {player.Name}`)
		end

		playerUserStore:releaseLock()
	end
end

function User_Handler.On_Shutdown(player)
	for _, player in PS:GetPlayers() do
		local playerUserStore = User_Handler.User_Data[player] :: User
		if playerUserStore then
			playerUserStore:releaseLock()
		end
	end
end

function User_Handler.On_Server()
	print(`User_Service Version: {Service_Info.Version}, Place Version: {Service_Info.ServerInfo}`)
end

function User_Handler.getUser(player : Player) -- Yields the current thread until the players userstore has been successfully loaded, or returns false if an error occured while trying to retrieve it.
	if User_Handler.User_Data[player] ~= nil then return User_Handler.User_Data[player] end
	
	repeat until User_Handler.User_Data[player] ~= nil
	return User_Handler.User_Data[player]
end

return User_Handler
