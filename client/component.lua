Logger = nil
Fetch = nil
Callbacks = nil
Notification = nil
Utils = nil
Polyzone = nil
ListMenu = nil
Action = nil
Blips = nil
Keybinds = nil
Inventory = nil
HUD = nil

AddEventHandler("Blackmarket:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	if Config.Framework ~= 'mythic' and GetResourceState('mythic-base') ~= 'started' then return end
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

function RegisterMarketCallback()
    RegisterClientCallback("Blackmarket:Van:MarkVan", function(data, cb)
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
end

function RegisterComponents()
	if Config.Framework ~= 'mythic' and GetResourceState('mythic-base') ~= 'started' then return end
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
        RegisterMarketCallback()
    end)
end

AddEventHandler("Core:Shared:Ready", RegisterComponents)

AddEventHandler('onClientResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then return end    
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then return end
    Wait(1000)
    RegisterMarketCallback()
end)

function Notify(data)
	local msg = data.msg or '#opps no message'
	local duration = data.length or 2500
	local nType = data.type or 'inform'

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		if type == 'inform' then
            Notification:Info(msg, duration)
        elseif type == 'error' then
            Notification:Error(msg, duration)
        elseif type == 'success' then
            Notification:Success(msg, duration)
        elseif type == 'warning' then
            Notification:Warn(msg, duration)
        end
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:Notification(nType, msg, duration)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:Notification(nType, msg, duration)
	else
		print('[Notify] Config not set up correctly..')
	end
end

function ListMenuShow(data)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		ListMenu:Show(data)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:ListMenuShow('marketvan', data)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:ListMenuShow('marketvan', data)
	else
		print('[ListMenuShow] Config not set up correctly..')
	end
end

function ListMenuClose()
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		ListMenu:Close()
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:ListMenuClose('marketvan', action)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:ListMenuClose('marketvan', action)
	else
		print('[ListMenuClose] Config not set up correctly..')
	end
end

function ActionShow(action)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Action:Show(action)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:ActionShow('marketvan', action)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:ActionShow('marketvan', action)
	else
		print('[ActionShow] Config not set up correctly..')
	end
end

function ActionHide()
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Action:Hide()
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:ActionHide('marketvan')
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:ActionHide('marketvan')
	else
		print('[ActionHide] Config not set up correctly..')
	end
end

function HasVpn()
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return Inventory.Check.Player:HasItem(Config.VpnItem, 1)
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		return exports.ox_inventory:Search('count', Config.VpnItem, 1)
	else
		print('[HasVpn] Config not set up correctly..')
	end

    return false
end

function GetInvData(item)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return Inventory.Items:GetData(item)
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		return exports.ox_inventory:ItemsGetData(Config.VpnItem, 1)
	else
		print('[GetInvData] Config not set up correctly..')
	end

    return false
end

function ServerCallback(name, data, cb)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Callbacks:ServerCallback(name, data, cb)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then
		exports["sandbox-base"]:ServerCallback(name, data, cb)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then
		exports["pulsar-core"]:ServerCallback(name, data, cb)
	else
		print('[ServerCallback] Config not set up correctly..')
	end
end

function RegisterClientCallback(name, data, cb)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Callbacks:RegisterClientCallback(name, data, cb)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then
		exports["sandbox-base"]:RegisterClientCallback(name, data, cb)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then
		exports["pulsar-core"]:RegisterClientCallback(name, data, cb)
	else
		print('[RegisterClientCallback] Config not set up correctly..')
	end
end
