local _blackMarketItems = {
	{ id = 1, item = "meth_table", coin = "PLEB", price = 400, qty = 5, vpn = true },
}
local _blackMarketWeapons = {    
    {
        id = 1,
        label = 'Crowbar',
        coin = 'PLEB',
        price = 5,
        qty = 5,
        weapon = 'WEAPON_CROWBAR',
        upgrades = {},
        vpn = true
    },
    {
        id = 2,
        label = 'Combat Pistol',
        coin = 'PLEB',
        price = 69,
        qty = 5,
        weapon = 'WEAPON_COMBATPISTOL',
        upgrades = {}, -- not done yet
        vpn = true
    },
    {
        id = 3,
        label = 'Revolver',
        coin = 'PLEB',
        price = 750,
        qty = 5,
        weapon = 'WEAPON_REVOLVER',
        upgrades = {},
        vpn = true
    },
    {
        id = 4,
        label = 'Carbine Rifle (PD .556)',
        coin = 'PLEB',
        price = 1200,
        qty = 5,
        weapon = 'WEAPON_CARBINERIFLE',
        upgrades = {},
        vpn = true
    },
}

AddEventHandler("Blackmarket:Server:Startup", function()
    GlobalState["BlackmarketVan"] = Config.Locations[math.random(#Config.Locations)]

    Callbacks:RegisterServerCallback("Blackmarket:Van:GetItems", function(source, data, cb)
        local bmItems = {}

        local char = Fetch:Source(source):GetData("Character")
        local hasVpn = hasValue(char:GetData("States"), "PHONE_VPN")

        for k, v in ipairs(_blackMarketItems) do
            _blackMarketItems[v.item] = _blackMarketItems[v.item] or {}
            if (not v.vpn or hasVpn) --[[and not _toolsForSale[v.item][char:GetData("SID")]] then
                bmItems[#bmItems+1] = v
            end
        end

        cb(bmItems)
    end)

    Callbacks:RegisterServerCallback("Blackmarket:Van:GetWeapons", function(source, data, cb)
        local bkWeapons = {}

        local char = Fetch:Source(source):GetData("Character")
        local hasVpn = hasValue(char:GetData("States"), "PHONE_VPN")

        for k, v in ipairs(_blackMarketWeapons) do
           _blackMarketWeapons[v.weapon] =_blackMarketWeapons[v.weapon] or {}
            if (not v.vpn or hasVpn) then
                bkWeapons[#bkWeapons+1] = v
            end
        end

        cb(bkWeapons)
    end)

    Callbacks:RegisterServerCallback("Blackmarket:Van:BuyItem", function(source, data, cb)
        local char = Fetch:Source(source):GetData("Character")
        local hasVpn = hasValue(char:GetData("States"), "PHONE_VPN")

        for k, v in ipairs(_blackMarketItems) do
            if v.id == data then
                local coinData = Crypto.Coin:Get(v.coin)
                if Crypto.Exchange:Remove(v.coin, char:GetData("CryptoWallet"), v.price) then
                    Inventory:AddItem(char:GetData("SID"), v.item, 1, {}, 1)
                    v.qty = v.qty - 1
                    -- _blackMarketItems[v.item][char:GetData("SID")] = true
                else
                    Execute:Client(source, "Notification", "Error", string.format("Not Enough %s", coinData.Name), 6000)
                end
            end
        end
    end)

    Callbacks:RegisterServerCallback("Blackmarket:Van:BuyWeapon", function(source, data, cb)
        local char = Fetch:Source(source):GetData("Character")
        local hasVpn = hasValue(char:GetData("States"), "PHONE_VPN")

        for k, v in ipairs(_blackMarketWeapons) do
            if v.id == data then
                local coinData = Crypto.Coin:Get(v.coin)
                if Crypto.Exchange:Remove(v.coin, char:GetData("CryptoWallet"), v.price) then
                    Inventory:AddItem(char:GetData("SID"), v.weapon, 1, { ammo = 450, clip = 0, Scratched = "1" }, 1)
                    v.qty = v.qty - 1
                    --_blackMarketWeapons[v.weapon][char:GetData("SID")] = true
                else
                    Execute:Client(source, "Notification", "Error", string.format("Not Enough %s", coinData.Name), 6000)
                end
            end
        end
    end)

	Inventory.Items:RegisterUse("bkvan_tracker", "Blackmarket", function(source, slot, itemData)
        local plyr = Fetch:Source(source)
        if plyr ~= nil then
            local char = plyr:GetData("Character")
            if char ~= nil then
                local pState = Player(source).state

                Execute:Client(source, "Notification", "Info", "Locating Van...", 6000)
        
                Wait(math.random(2, 15) * 1000) -- 2 -15 second search time

                Logger:Info("Blackmarket", string.format("%s %s (%s) Used Blackmarked Van GPS Tracker", char:GetData("First"), char:GetData("Last"), char:GetData("SID")))
                Callbacks:ClientCallback(source, "Blackmarket:Van:MarkVan", nil, function(r) 
                    if r then
                        Inventory.Items:RemoveSlot(slot.Owner, slot.Name, 1, slot.Slot, 1)
                        Execute:Client(
                            source,
                            "Notification",
                            "Success",
                            "A Van Has Been Marked On Your GPS",
                            6000
                        )
                    end
                end)
            end
        end
	end)
end)