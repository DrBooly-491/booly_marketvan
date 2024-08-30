AddEventHandler("Blackmarket:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	Fetch = exports["mythic-base"]:FetchComponent("Fetch")
	Logger = exports["mythic-base"]:FetchComponent("Logger")
	Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
	Middleware = exports["mythic-base"]:FetchComponent("Middleware")
	Execute = exports["mythic-base"]:FetchComponent("Execute")
	Chat = exports["mythic-base"]:FetchComponent("Chat")
	Inventory = exports["mythic-base"]:FetchComponent("Inventory")
	Crypto = exports["mythic-base"]:FetchComponent("Crypto")
end

function RegisterComponents()
	exports["mythic-base"]:RequestDependencies("Blackmarket", {
        "Fetch",
        "Logger",
        "Callbacks",
        "Middleware",
        "Execute",
        "Chat",
        "Inventory",
        "Crypto",
	}, function(error)
		if #error > 0 then 
			return
		end
		RetrieveComponents()

        TriggerEvent('Blackmarket:Server:Startup')
	end)
end

AddEventHandler("Core:Shared:Ready", RegisterComponents)

-- AddEventHandler('onResourceStart', function(resource)
--     if resource == GetCurrentResourceName() then
--         RegisterComponents()
--     end
-- end)