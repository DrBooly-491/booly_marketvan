local vanModel = `speedo4`
local pedModels = {
    `s_m_m_armoured_01`,
    `s_m_y_cop_01`,
    `s_m_y_dealer_01`,
    `s_m_y_marine_01`
}
local propModel = `xm3_prop_xm3_crate_ammo_01a`

local actionMsg = "{keybind}primary_action{/keybind} Talk" 

local spawnedVan, spawnedPed, vanBlip, spawnedProp, weaponObject
local playerGreeted, inZone, _usingMenu = false, false, false

local _weaponsMenuList = {}
local _itemsMenuList = {}

local function dprint(msg)
    if not Config.Debug then return end
    print(msg)
end

--[[local function getGroundLevel(x, y, z)
    local groundZ
    RequestCollisionAtCoord(x, y, z)
    while not GetGroundZFor_3dCoord(x, y, x, groundZ, false) do
        Wait(0)
    end
    return groundZ
end]]

local function greetPlayer()
    local playerPed = PlayerPedId()
    local pedCoords = GetEntityCoords(spawnedPed)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(pedCoords - playerCoords)

    if distance <= 5.0 and not playerGreeted then
        dprint("Ped is greeting the player.")
        
        PlayPedAmbientSpeechNative(spawnedPed, "GENERIC_HOWS_IT_GOING", "SPEECH_PARAMS_FORCE")
        
        playerGreeted = true
    end
end

local function sayGoodbye()
    if playerGreeted then
        PlayPedAmbientSpeechNative(spawnedPed, "GENERIC_BYE", "SPEECH_PARAMS_FORCE")

        dprint("Ped is saying goodbye to the player.")
        playerGreeted = false
    end
end

function greetPlayerThread()
    while true do
        Wait(500)
        if spawnedPed and spawnedVan then
            local pedCoords = GetEntityCoords(spawnedPed)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(pedCoords - playerCoords)

            if distance <= 5.0 and inZone then
                greetPlayer()
            else
                sayGoodbye()
                if not inZone and not playerGreeted then
                    dprint("Ending greetPlayerThread.")
                    return
                end
            end
        end
    end
end

function SpawnVan()
    RequestModel(vanModel)
    while not HasModelLoaded(vanModel) do
        Wait(0)
    end

    local pedModel = pedModels[math.random(#pedModels)]
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end

    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(0)
    end

    local location = GlobalState["BlackmarketVan"]--Config.Locations[math.random(#Config.Locations)]

    spawnedVan = CreateVehicle(vanModel, location.x, location.y, location.z, location.w, true, false)
    SetEntityAsMissionEntity(spawnedVan, true, true)

    SetVehicleUndriveable(spawnedVan, true)
    SetVehicleWindowTint(spawnedVan, 2)

    local rollCageModIndex = 5
    local lightArmorPlatingModValue = 1
    SetVehicleMod(spawnedVan, rollCageModIndex, lightArmorPlatingModValue, false)
    
    local primaryColor = Config.Vehicle.color.primary
    local secondaryColor = Config.Vehicle.color.secondary
    local plateText = Config.Vehicle.plate
    
    SetVehicleColours(spawnedVan, primaryColor, secondaryColor)
    SetVehicleNumberPlateText(spawnedVan, plateText)

    spawnedPed = CreatePed(4, pedModel, location.x, location.y, location.z, location.w, true, false)
    SetEntityAsMissionEntity(spawnedPed, true, true)

    SetEntityInvincible(spawnedPed, true)
    SetPedCanRagdoll(spawnedPed, false)
    SetPedCanBeShotInVehicle(spawnedPed, false)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)

    local pedOffset = vector3(-0.4, -2.15, 0.85)
    local xRot, yRot, zRot = 0.0, 0.0, 220.0

    AttachEntityToEntity(spawnedPed, spawnedVan, 0, pedOffset.x, pedOffset.y, pedOffset.z, xRot, yRot, zRot, false, false, false, true, 2, true)

    RequestAnimDict("timetable@ron@ig_3_couch")
    while not HasAnimDictLoaded("timetable@ron@ig_3_couch") do
        Wait(0)
    end
    TaskPlayAnim(spawnedPed, "timetable@ron@ig_3_couch", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

    SetVehicleDoorsLockedForAllPlayers(spawnedVan, true)

    local propOffset = vector3(0.0, -1.15, -0.15)
    spawnedProp = CreateObject(propModel, location.x + propOffset.x, location.y + propOffset.y, location.z + propOffset.z, true, true, true)
    SetEntityAsMissionEntity(spawnedProp, true, true)
    AttachEntityToEntity(spawnedProp, spawnedVan, 0, propOffset.x, propOffset.y, propOffset.z, 0.0, 0.0, 0.0, false, false, false, true, 2, true)

    Polyzone.Create:Box('vanZone', vector3(location.x, location.y, location.z), 15.0, 10.0, {
        heading = location.w,
        minZ = location.z - 1.0,
        maxZ = location.z + 2.0,
    }, {
        minH = location.w - 240.0,
        maxH = location.w + 240.0,
    })

    if Config.UseBlip or Config.Debug then
        vanBlip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(vanBlip, 225)
        SetBlipDisplay(vanBlip, 4)
        SetBlipScale(vanBlip, 0.8)
        SetBlipColour(vanBlip, 5)
        SetBlipAsShortRange(vanBlip, true)
        SetBlipCategory(vanBlip, 2)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Van Location")
        EndTextCommandSetBlipName(vanBlip)
    end

    dprint("Van spawned at: " .. tostring(location.x) .. ", " .. tostring(location.y) .. ", " .. tostring(location.z))

    -- had this for testing
    --[[if Config.Debug then 
        local playerPed = PlayerPedId()
        local spawnOffset = vector3(-15.0, -10.0, 0.0)
        local groundZ = getGroundLevel(location.x + spawnOffset.x, location.y + spawnOffset.y, location.z)
        SetEntityCoordsNoOffset(playerPed, location.x + spawnOffset.x, location.y + spawnOffset.y, groundZ, true, true, true)
        dprint("Moved player outside the PolyZone to: " .. tostring(location.x + spawnOffset.x) .. ", " .. tostring(location.y + spawnOffset.y) .. ", " .. tostring(groundZ))
    end]]
end

local function cleanupWeapon()
    if DoesEntityExist(weaponObject) then DeleteEntity(weaponObject) deleteWeaponCam() end
end

local function cleanup()
    Action:Hide()
    ListMenu:Close()
    _usingMenu = false

    if spawnedVan then
        DeleteVehicle(spawnedVan)
        spawnedVan = nil
    end
    if spawnedPed then
        DeletePed(spawnedPed)
        spawnedPed = nil
    end
    if spawnedProp then
        DeleteObject(spawnedProp)
        spawnedProp = nil
    end
    if vanBlip then
        RemoveBlip(vanBlip)
        vanBlip = nil
    end

    if weaponObject then cleanupWeapon() end
end

RegisterNetEvent('Blackmarket:Client:ForceCleanUp', cleanup)

local isSpotlightActive = false

local function getSpotlight()
    if not Config.EnableSpotlight then return end
    while isSpotlightActive do
        local coords = GetEntityCoords(weaponObject)
        local forward = GetEntityForwardVector(weaponObject)
        DrawSpotLight(coords.x + forward.x, coords.y + forward.y, coords.z + 3.0, 0.0, 90.0, -180.0, 255, 255, 255, 5.0, 1.0, 1.0, 100.0, 1.0)
        Wait(0)
    end
end

function spawnWeaponWithComponents(weapon, components)
    dprint("Trying to spawn weapon")
    local playerPed = PlayerPedId()
    
    local offsetX, offsetY, offsetZ = 0.0, -1.5, 0.75
    local coords = GetOffsetFromEntityInWorldCoords(spawnedVan, offsetX, offsetY, offsetZ)
    
    local x = Round(coords.x, 2)
    local y = Round(coords.y, 2)
    local z = Round(coords.z, 2)
    local spawnPos = vec3(x, y, z)

    if DoesEntityExist(weaponObject) then DeleteEntity(weaponObject) end
    local weaponAsset = GetHashKey(weapon)
    
    RequestWeaponAsset(weaponAsset, 31, 0)
    while not HasWeaponAssetLoaded(weaponAsset) do
        Wait(0)
    end
    
    weaponObject = CreateWeaponObject(weaponAsset, 0, spawnPos, true, 0, 0)
    AttachEntityToEntity(weaponObject, spawnedVan, 0, offsetX, offsetY, offsetZ, 0.0, 0.0, 0.0, false, false, false, true, 2, true)

    CreateCamera()
end

function CreateCamera()
    local camOffsetX, camOffsetY, camOffsetZ = 0.45, -3.25, 1.15
    local camCoords = GetOffsetFromEntityInWorldCoords(spawnedVan, camOffsetX, camOffsetY, camOffsetZ)
    weaponCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(weaponCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(weaponCam, weaponObject)
    SetCamActive(weaponCam, true)
    RenderScriptCams(true, false, 0, true, true)
    isSpotlightActive = true
    getSpotlight()
    
    dprint("Camera set up off-center to the spawned weapon.")
end

function deleteWeaponCam()
    if DoesCamExist(weaponCam) then
        SetCamActive(weaponCam, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(weaponCam, false)
        weaponCam = nil
        isSpotlightActive = false
        dprint("Camera deleted.")
    else
        dprint("No camera to delete.")
    end
end

function RegisterWeaponsMenu()
    local WeaponsList = {}
    local hasVpn = Inventory.Check.Player:HasItem('vpn', 1)

    Callbacks:ServerCallback("Blackmarket:Van:GetWeapons", {}, function(Weapons)
        for _, weapon in pairs(Weapons) do
            WeaponsList[#WeaponsList+1] = {
                label = ('View %s'):format(weapon.label),
                description = string.format("Stock: %s | %s $%s", weapon.qty, formatDollars(weapon.price), weapon.coin),
                event = 'Blackmarket:Van:PreviewWeapon',
                data = {
                    title = 'Black Market Van',
                    weaponData = weapon
                }
            } 
        end

        if #WeaponsList == 0 then
            WeaponsList[#WeaponsList+1] = {
                label = hasVpn and 'Out of stock bud' or 'Nothing to see here',
                icon = 'skull-crossbones',
                readOnly = true
            }
        end

        GetWeaponsList(WeaponsList)     
    end)
end

RegisterNetEvent('Blackmarket:Van:PreviewWeapon', function(data)
    local weapon = data.weaponData
    
    _usingMenu = true

    ListMenu:Show({
        main = {
            label = data.title,
            items = {
                {
                    label = ('Buy %s'):format(weapon.label),
                    description = string.format("Stock: %s | %s $%s", weapon.qty, formatDollars(weapon.price), weapon.coin),
                    event = 'Blackmarket:Client:Van:BuyWeapon',
                    data = weapon.id
                },
                {
                    label = 'Never Mind',
                    description = 'I Don\'t want this.',
                    event = 'Blackmarket:Van:CleanWeaponUp'
                },
            }
        },
    })
    spawnWeaponWithComponents(weapon.weapon, weapon.upgrades, data.title)
end)

RegisterNetEvent('Blackmarket:Van:CleanWeaponUp', function()
    cleanupWeapon()
end)

function RegisterItemsMenu()
    local itemList = {}
    local hasVpn = Inventory.Check.Player:HasItem('vpn', 1)
    
    Callbacks:ServerCallback("Blackmarket:Van:GetItems", {}, function(items)

        for k, v in ipairs(items) do
            local itemData = Inventory.Items:GetData(v.item)
            if v.qty > 0 then
                itemList[#itemList+1] = {
                    label = ('Buy %s'):format(itemData.label),
                    description = string.format("Stock: %s | %s $%s", v.qty, formatDollars(v.price), v.coin),
                    event = "Blackmarket:Client:Van:BuyItem",
                    data = v.id,
                }
            else
                itemList[#itemList+1] = {
                    label = itemData.label,
                    description = 'Sold Out',
                }
            end
        end

        if #itemList == 0 then
            itemList[#itemList+1] = {
                label = hasVpn and 'Out of stock bud' or 'Nothing to see here',
            }
        end
  
        GetItemsListdata(itemList)     
	end)
end

function GetWeaponsList(data)
    _weaponsMenuList = data
end

function GetItemsListdata(data)
    _itemsMenuList = data
end

RegisterNetEvent('Characters:Client:Spawn')
AddEventHandler('Characters:Client:Spawn', function()
    SpawnVan()
end)

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    cleanup()
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
    if id == 'vanZone' then
        local h = GetEntityHeading(PlayerPedId())
        if h >= data.minH and h <= data.maxH then
            inZone = true
            Action:Show(actionMsg)
            SetVehicleDoorOpen(spawnedVan, 2, false, false)
            SetVehicleDoorOpen(spawnedVan, 3, false, false)
            Citizen.CreateThread(greetPlayerThread)
        end
    end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
    if id == 'vanZone' then
        inZone = false
        SetVehicleDoorShut(spawnedVan, 2, false)
        SetVehicleDoorShut(spawnedVan, 3, false)
        sayGoodbye()
        Action:Hide()
		ListMenu:Close()
    end
end)

AddEventHandler("Blackmarket:Client:Van:BuyItem", function(data)
	Callbacks:ServerCallback("Blackmarket:Van:BuyItem", data)
end)

AddEventHandler("Blackmarket:Client:Van:BuyWeapon", function(data)
    cleanupWeapon()
	Callbacks:ServerCallback("Blackmarket:Van:BuyWeapon", data)
end)

AddEventHandler('Keybinds:Client:KeyUp:primary_action', function()
    RegisterWeaponsMenu()
    RegisterItemsMenu()

    local MenuItems = {}
    local hasVpn = Inventory.Check.Player:HasItem('vpn', 1)

    Wait(150)

    if inZone then
        local weaponsMenu = _weaponsMenuList
        local itemsMenu = _itemsMenuList
        PlayPedAmbientSpeechNative(spawnedPed, hasVpn and "GENERIC_SHOCKED_MED" or "GENERIC_INSULT_HIGH", "SPEECH_PARAMS_FORCE")

        if hasVpn then
            MenuItems = {
                {
                    label = 'View Weapons',
                    submenu = 'blackmarket_van_weapons'
                },
                {
                    label = 'View Items',
                    submenu = 'blackmarket_van_items'
                }
            }
        else
            Notification:Error('I Don\'t wanna talk to you..')
            return
        end
        
        _usingMenu = true

        ListMenu:Show({
            main = {
                label = hasVpn and 'Black Market Van' or 'Treys Van',
                items = MenuItems
            },
            blackmarket_van_weapons = {
                label = hasVpn and 'Black Market Van' or 'Treys Van',
                items = weaponsMenu
            },
            blackmarket_van_items = {
                label = hasVpn and 'Black Market Van' or 'Treys Van',
                items = itemsMenu
            },
        })
	end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanup()
    end
end)

AddEventHandler('ListMenu:Close', function()
    if not _usingMenu then return end

    cleanupWeapon()
end)
