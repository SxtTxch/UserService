local Players = game:GetService("Players")

local DataStoreService = game:GetService("DataStoreService")
local LockStore = DataStoreService:GetDataStore("LockDataStore")
local UserStore = DataStoreService:GetDataStore("UserStore")

local User_ObjectFolder = script.Parent
local UserTemplate = require(User_ObjectFolder.UserTemplate)

local getSessionId = require(script.getSessionId)

export type UserData = {
	coins: number,
	experience: number,
	level: number,
}

export type User = {
	__index : User,
	userId: string,
	sessionId: string,
	data: UserData?,
	isLocked: boolean,

	acquireLock: (self: User) -> boolean,
	releaseLock: (self: User) -> boolean,
	load: (self: User) -> boolean,
	save: (self: User) -> boolean,
	reconcile: (self: User) -> (),
}

local User = {} :: User
User.__index = User

local loadedUsers = {}

function User.new(player)
	local self: User = setmetatable({}, User)
	
	self.userId = tostring(player.UserId)
	self.sessionId = getSessionId(player)
	self.data = nil
	self.isLocked = false
	
	return self
end

function User:reconcile(): ()
	if not self.data then
		self.data = {}
	end

	for key, value in UserTemplate do
		if self.data[key] == nil then
			print(`Adding missing key: {key} with default value: {value}`)
			self.data[key] = value
		end
	end

	for key in pairs(self.data) do
		if UserTemplate[key] == nil then
			print(`Removing obsolete key: {key}`)
			self.data[key] = nil
		end
	end
end

function User:acquireLock() : boolean
	local player = Players:GetPlayerByUserId(self.userId)
	
	local lockKey = `Lock_{self.userId}`

	local currentSessionId = self.sessionId

	local success, currentLock = pcall(function()
		return LockStore:GetAsync(lockKey)
	end)

	if success then
		if not currentLock then
			local successfulSet = pcall(function()
				LockStore:SetAsync(lockKey, currentSessionId)
			end)
			return successfulSet
		elseif currentLock == currentSessionId then
			return true
		else
			player:Kick("Session Locked.")
			return false
		end
	else
		warn(`Failed to acquire session lock for user {self.userId} with Lock Key: {lockKey}`)
		player:Kick(`Failed to acquire session lock for user {self.userId} with Lock Key: {lockKey}`)
	end
end

function User:releaseLock()
	local lockKey = `Lock_{self.userId}`

	local currentSessionId = self.sessionId

	local success, currentLock = pcall(function()
		return LockStore:GetAsync(lockKey)
	end)

	if success and currentLock == currentSessionId then
		local successfulRemove = pcall(function()
			LockStore:RemoveAsync(lockKey)
		end)
		if successfulRemove then
			self.isLocked = false
		end
		return successfulRemove
	else
		warn("Failed to release lock or lock is owned by another session.")
		return false
	end
end

function User:load(): boolean
	if not self:acquireLock() then
		return false
	end
	
	self.isLocked = true
	
	if loadedUsers[self.userId] then return true end
	
	local success, userData = pcall(function()
		return UserStore:GetAsync(self.userId)
	end)
	
	if success then
		if userData then
			self.data = userData
			self:reconcile()
		else
			self.data = UserTemplate
			print(`No user data saved for userId: {self.userId}. Copying over from the UserTemplate module.`)
		end
		loadedUsers[self.userId] = self
		return true
	else
		warn(`Failed to load user data: {userData}`)
		return false
	end
end

function User:save(): boolean
	if not self.isLocked then
		warn(`Attempted to save data without a lock for user: {self.userId}`)
		return false
	end

	local success, errorMsg = pcall(function()
		UserStore:SetAsync(self.userId, self.data)
	end)
	
	if success then
		return true
	else
		warn("Failed to save profile data:", errorMsg)
		return false
	end
end

return User