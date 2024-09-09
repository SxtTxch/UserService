local MarketplaceService = game:GetService("MarketplaceService")

return {
	["Version"] = "1.0.0",
	["ServerInfo"] = MarketplaceService:GetProductInfo(game.PlaceId).Updated
}