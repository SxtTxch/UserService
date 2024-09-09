# UserService for Roblox

**UserService** is a Roblox module for managing player profiles with session locking and data reconciliation.

## Features

- **Data Reconciliation:** Synchronizes player data with a predefined template.
- **Session Locking:** Prevents concurrent session conflicts.
- **Easy Integration:** Simple setup for Roblox projects.

## Installation

1. **Clone the repository:**

   `git clone https://github.com/yourusername/UserService.git`

2. **Integrate UserService:**

   Require the `UserService` module in your Roblox project.
   
### Basic Usage

1. **Setup:**

   Place the `UserService` module in your game’s `ServerScriptService` and require it in your scripts.

2. **Creating a User Object:**

   To create a new `User` object:
   ```lua
   local UserService = require(game.ServerScriptService.UserService.UserObject.User)
   local Players = game:GetService("Players")

   local function onPlayerAdded(player)
       local playerUserStore = UserService.new(player)
       -- Load user data
       playerUserStore:load()
       -- Use playerUserStore for further operations
   end

   game.Players.PlayerAdded:Connect(onPlayerAdded)
   ```

3. **Managing User Data:**

   - **Load User Data:**
     Call the `:load()` method to load user data from the DataStore.

     local success = playerUserStore:load()

   - **Save User Data:**
     Call the `:save()` method to save user data to the DataStore.

     local success = playerUserStore:save()

   - **Reconcile User Data:**
     Call the `:reconcile()` method to synchronize user data with the predefined template.
      ```lua
     playerUserStore:reconcile()
      ```

   - **Locking and Unlocking:**
     - **Acquire Lock:** Use `:acquireLock()` to prevent concurrent access.
       ```lua
       local success = playerUserStore:acquireLock()
       ```
       
     - **Release Lock:** Use `:releaseLock()` to release the lock.
       ```lua
       playerUserStore:releaseLock()
       ```
### Notes

- Ensure that you handle locking and unlocking properly to avoid data conflicts.
- The `UserService` module relies on Roblox's DataStore service for data persistence.

### Main Module

- Manages user profile data with locking and saving features.
- Uses `DataStoreService` to store user data.

## License

MIT License. See [LICENSE](LICENSE) for details.
