local _blackMarketItems = SvConfig.Items
local _blackMarketWeapons = SvConfig.Weapons

AddEventHandler("Blackmarket:Server:Startup", function()
    GlobalState["BlackmarketVan"] = Config.Locations[math.random(#Config.Locations)]

    RegisterServerCallback("Blackmarket:Van:GetItems", function(source, data, cb)
        local bmItems = {}

        local char = GetCharacterData(source)

        if not char then return end
        local hasVpn = HasVpn(char)

        for k, v in ipairs(_blackMarketItems) do
            _blackMarketItems[v.item] = _blackMarketItems[v.item] or {}
            if (not v.vpn or hasVpn) then
                bmItems[#bmItems+1] = v
            end
        end

        cb(bmItems)
    end)

    RegisterServerCallback("Blackmarket:Van:GetWeapons", function(source, data, cb)
        local bkWeapons = {}

        local char = GetCharacterData(source)

        if not char then return end
        local hasVpn = HasVpn(char)

        for k, v in ipairs(_blackMarketWeapons) do
           _blackMarketWeapons[v.weapon] =_blackMarketWeapons[v.weapon] or {}
            if (not v.vpn or hasVpn) then
                bkWeapons[#bkWeapons+1] = v
            end
        end

        cb(bkWeapons)
    end)

    RegisterServerCallback("Blackmarket:Van:BuyItem", function(source, data, cb)
        local char = GetCharacterData(source)

        if not char then return end
        local hasVpn = HasVpn(char)

        for k, v in ipairs(_blackMarketItems) do
            if v.id == data then
                local coinData = GetCryptoCoin(v.coin)
                if CryptoExchangeRemove(v.coin, char:GetData("CryptoWallet"), v.price) then
                    InvAdd(char:GetData("SID"), v.item, 1, {}, 1)
                    v.qty = v.qty - 1
                else
                    Notify(source, {
                        type = "Error", 
                        msg = string.format("Not Enough %s", coinData.Name), 
                        length = 6000
                    })
                end
            end
        end
    end)

    RegisterServerCallback("Blackmarket:Van:BuyWeapon", function(source, data, cb)
        local char = GetCharacterData(source)

        if not char then return end
        local hasVpn = HasVpn(char)

        for k, v in ipairs(_blackMarketWeapons) do
            if v.id == data then
                local coinData = GetCryptoCoin(v.coin)
                if CryptoExchangeRemove(v.coin, char:GetData("CryptoWallet"), v.price) then
                    InvAdd(char:GetData("SID"), v.weapon, 1, { ammo = 450, clip = 0, Scratched = "1" }, 1)
                    v.qty = v.qty - 1
                else
                    Notify(source, {
                        type = "Error", 
                        msg = string.format("Not Enough %s", coinData.Name), 
                        length = 6000
                    })
                end
            end
        end
    end)

	InvRegister("bkvan_tracker", "Blackmarket", function(source, slot, itemData)
        local char = GetCharacterData(source)
        if not char then return end
        local pState = Player(source).state

        Notify(source, {
            type = "Info", 
            msg = 'Locating Van...', 
            length = 6000
        })

        Wait(math.random(2, 15) * 1000) -- 2 -15 second search time

        FWLog("Blackmarket", string.format("%s %s (%s) Used Blackmarked Van GPS Tracker", char:GetData("First"), char:GetData("Last"), char:GetData("SID")))
        ClientCallback(source, "Blackmarket:Van:MarkVan", nil, function(r) 
            if r then
                InvRemove(source, slot, 1)
                Notify(source, {
                    type = "Success", 
                    msg = 'A Van Has Been Marked On Your GPS', 
                    length = 6000
                })
            end
        end)
	end)
end)
