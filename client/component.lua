AddEventHandler("Blackmarket:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Logger = exports["mythic-base"]:FetchComponent("Logger")
    Fetch = exports["mythic-base"]:FetchComponent("Fetch")
    Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
    Notification = exports["mythic-base"]:FetchComponent("Notification")
    Utils = exports["mythic-base"]:FetchComponent("Utils")
    Polyzone = exports["mythic-base"]:FetchComponent("Polyzone")
    ListMenu = exports["mythic-base"]:FetchComponent("ListMenu")
    Action = exports["mythic-base"]:FetchComponent("Action")
    Blips = exports["mythic-base"]:FetchComponent("Blips")
    Keybinds = exports["mythic-base"]:FetchComponent("Keybinds")
    Inventory = exports["mythic-base"]:FetchComponent("Inventory")
    HUD = exports["mythic-base"]:FetchComponent("Hud")
end

function RegisterComponents()
    exports["mythic-base"]:RequestDependencies("Blackmarket", {
        "Logger",
        "Fetch",
        "Callbacks",
        "Notification",
        "Utils",
        "Polyzone",
        "ListMenu",
        "Action",
        "Blips",
        "Keybinds",
        "Inventory",
        "Hud",
    }, function(error)
        if #error > 0 then return; end
        RetrieveComponents()
        
        Callbacks:RegisterClientCallback("Blackmarket:Van:MarkVan", function(data, cb)
            local location = GlobalState["BlackmarketVan"]
        
            if location then
                local blip = AddBlipForCoord(location.x, location.y, location.z)
                SetBlipSprite(blip, 225)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.8)
                SetBlipColour(blip, 5)
                SetBlipAsShortRange(blip, true)
                SetBlipCategory(blip, 2)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Van Location")
                EndTextCommandSetBlipName(blip)

                SetTimeout((1000 * 5) * 10, function()
                    RemoveBlip(blip)
                end)

                cb(true)
            else
                cb(false)
            end
        end)
    end)
end

AddEventHandler("Core:Shared:Ready", RegisterComponents)

-- RegisterCommand('forcevan', function()
--     if LocalPlayer.state.loggedIn then 
--         TriggerEvent('Blackmarket:Client:ForceCleanUp')
--         characterLoaded = true
--         SpawnVan()
--     end
-- end)

-- AddEventHandler('onResourceStart', function(resource)
--     if resource == GetCurrentResourceName() then
--         RegisterComponents()
--     end
-- end)