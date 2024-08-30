AddEventHandler("Blackmarket:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
    Logger = exports["mythic-base"]:FetchComponent("Logger")
    Fetch = exports["mythic-base"]:FetchComponent("Fetch")
    Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
    Menu = exports["mythic-base"]:FetchComponent("Menu")
    Notification = exports["mythic-base"]:FetchComponent("Notification")
    Utils = exports["mythic-base"]:FetchComponent("Utils")
    Animations = exports["mythic-base"]:FetchComponent("Animations")
    Polyzone = exports["mythic-base"]:FetchComponent("Polyzone")
    Progress = exports["mythic-base"]:FetchComponent("Progress")
    Vehicles = exports["mythic-base"]:FetchComponent("Vehicles")
    Targeting = exports["mythic-base"]:FetchComponent("Targeting")
    ListMenu = exports["mythic-base"]:FetchComponent("ListMenu")
    Action = exports["mythic-base"]:FetchComponent("Action")
    Sounds = exports["mythic-base"]:FetchComponent("Sounds")
    PedInteraction = exports["mythic-base"]:FetchComponent("PedInteraction")
    Blips = exports["mythic-base"]:FetchComponent("Blips")
    Keybinds = exports["mythic-base"]:FetchComponent("Keybinds")
    Interaction = exports["mythic-base"]:FetchComponent("Interaction")
    Inventory = exports["mythic-base"]:FetchComponent("Inventory")
    HUD = exports["mythic-base"]:FetchComponent("Hud")
end

function RegisterComponents()
    exports["mythic-base"]:RequestDependencies("Blackmarket", {
        "Logger",
        "Fetch",
        "Callbacks",
        "Menu",
        "Notification",
        "Utils",
        "Animations",
        "Polyzone",
        "Progress",
        "Vehicles",
        "Targeting",
        "ListMenu",
        "Action",
        "Sounds",
        "PedInteraction",
        "Blips",
        "Keybinds",
        "Interaction",
        "Inventory",
        "Hud",
    }, function(error)
        if #error > 0 then return; end
        RetrieveComponents()
    end)
end

AddEventHandler("Core:Shared:Ready", RegisterComponents)

-- RegisterCommand('forcevan', function()
--     if LocalPlayer.state.loggedIn then 
--         characterLoaded = true
--         SpawnVan()
--     end
-- end)

-- AddEventHandler('onResourceStart', function(resource)
--     if resource == GetCurrentResourceName() then
--         RegisterComponents()
--     end
-- end)