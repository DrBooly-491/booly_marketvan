Fetch = nil
Logger = nil
Callbacks = nil
Middleware = nil
Execute = nil
Chat = nil
Inventory = nil
Crypto = nil

AddEventHandler("Blackmarket:Shared:DependencyUpdate", RetrieveComponents)
function RetrieveComponents()
	if Config.Framework ~= 'mythic' and GetResourceState('mythic-base') ~= 'started' then return end
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
	if Config.Framework ~= 'mythic' and GetResourceState('mythic-base') ~= 'started' then return end
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

function GetCharacterData(source)
	local src = source

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return Fetch:Source(src):GetData("Character")
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-characters') == 'started' then
		return exports['sandbox-characters']:FetchCharacterSource(src)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-characters') == 'started' then
		return exports['pulsar-characters']:FetchCharacterSource(src)
	else
		print('[GetCharacterData] Config not set up correctly..')
	end

	return false
end

function Notify(source, data)
	local src = source
	local msg = data.msg or '#opps no message'
	local duration = data.length or 2500
	local nType = string.lower(data.type) or 'inform'

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Execute:Client(src, "Notification", data.type, data.msg, data.length or 2500)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-hud') == 'started' then
		exports['sandbox-hud']:Notification(src, nType, msg, duration)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-hud') == 'started' then
		exports['pulsar-hud']:Notification(src, nType, msg, duration)
	else
		print('[Notify] Config not set up correctly..')
	end
end

function FWLog(label, msg)
	local src = source

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Logger:Info(label, msg)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then
		exports['sandbox-base']:LoggerInfo(label, msg)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then
		exports['pulsar-core']:LoggerInfo(label, msg)
	else
		print('[FWLog] Config not set up correctly..')
	end
end

function ClientCallback(source, name, data, cb)
	local src = source

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Callbacks:ClientCallback(src, name, data, cb)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then
		exports["sandbox-base"]:ClientCallback(src, name, data, cb)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then
		exports["pulsar-core"]:ClientCallback(src, name, data, cb)
	else
		print('[ClientCallback] Config not set up correctly..')
	end
end

function RegisterServerCallback(source, name, data, cb)
	local src = source

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Callbacks:RegisterServerCallback(src, name, data, cb)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then
		exports["sandbox-base"]:RegisterServerCallback(src, name, data, cb)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then
		exports["pulsar-core"]:RegisterServerCallback(src, name, data, cb)
	else
		print('[RegisterServerCallback] Config not set up correctly..')
	end
end

function HasVpn(char)
	if not char then return print('char not found?') end

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return hasValue(char:GetData("States"), "PHONE_VPN")
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		return exports.ox_inventory:ItemsHas(char:GetData("SID"), 1, Config.VpnItem, 1)
	else
		print('[HasVpn] Config not set up correctly..')
	end
end

function InvRegister(name, category, cb)
	local src = source

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Inventory.Items:RegisterUse(name, category, cb)
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		exports.ox_inventory:registerUseItem(name, function(source, item, inventory, slot, data)
			local slotData = {
				Name = item.name,
				Slot = slot, 
				Owner = source
			}
			
			cb(source, slotData, data)
		end)
	else
		print('[InvRegister] Config not set up correctly..')
	end
end

function InvAdd(owner, name, amount, metadata, invType)
	amount = amount or 1
	metadata = metadata or {}

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Inventory:AddItem(owner, name, amount, metadata, invType)
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		exports.ox_inventory:AddItem(owner, name, amount, metadata, invType)
	else
		print('[InvAdd] Config not set up correctly..')
	end
end

function InvRemove(source, slot, amount)
	amount = amount or 1

	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		Inventory.Items:RemoveSlot(slot.Owner, slot.Name, amount, slot.Slot, 1)
	elseif (Config.Framework == 'sandbox' or Config.Framework == 'pulsar') and GetResourceState('ox_inventory') == 'started' then
		exports.ox_inventory:RemoveSlot(slot.Owner, slot.Name, amount, slot.Slot, 1)
	else
		print('[InvRemove] Config not set up correctly..')
	end
end

function GetCryptoCoin(coin)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return Crypto.Coin:Get(coin)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-finance') == 'started' then
		return exports['sandbox-finance']:CryptoCoinGet(coin)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-finance') == 'started' then
		return exports['pulsar-finance']:CryptoCoinGet(coin)
	else
		print('[GetCryptoCoin] Config not set up correctly..')
	end

	return nil
end

function CryptoExchangeRemove(coin, wallet, amount, skipAlert)
	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then
		return Crypto.Exchange:Remove(coin, wallet, amount, skipAlert)
	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-finance') == 'started' then
		return exports['sandbox-finance']:CryptoExchangeRemove(coin, wallet, amount, skipAlert)
	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-finance') == 'started' then
		return exports['pulsar-finance']:CryptoExchangeRemove(coin, wallet, amount, skipAlert)
	else
		print('[sample] Config not set up correctly..')
	end

	return nil
end

-- function sample(source, name, data, cb)
-- 	local src = source

-- 	if Config.Framework == 'mythic' and GetResourceState('mythic-base') == 'started' then

-- 	elseif Config.Framework == 'sandbox' and GetResourceState('sandbox-base') == 'started' then

-- 	elseif Config.Framework == 'pulsar' and GetResourceState('pulsar-core') == 'started' then

-- 	else
-- 		print('[sample] Config not set up correctly..')
-- 	end
-- end
