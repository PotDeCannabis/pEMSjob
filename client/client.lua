ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end

  while ESX.GetPlayerData().job == nil do
    Citizen.Wait(10)
  end

  ESX.PlayerData = ESX.GetPlayerData()
end)

-- Appel

local AppelPris = false
local AppelDejaPris = false
local AppelEnAttente = false 
local AppelCoords = nil
local tableBlip = {}

RegisterNetEvent("AppelemsGetCoords")
AddEventHandler("AppelemsGetCoords", function()
  ped = GetPlayerPed(-1)
  coords = GetEntityCoords(ped, true)
  ESX.TriggerServerCallback('EMS:GetID', function(idJoueur)
    TriggerServerEvent("Server:emsAppel", coords, idJoueur)
  end)

end)

RegisterNetEvent("AppelemsTropBien")
AddEventHandler("AppelemsTropBien", function(coords, id)
  AppelEnAttente = true
  AppelCoords = coords
  AppelID = id
  ESX.ShowAdvancedNotification("EMS", "~b~Demande d'ambulance", "Quelqu'un à besoin d'un ems !\n~g~Y~w~ pour prendre l'appel\n~r~X~w~ pour refuser", "CHAR_MICHAEL", 10)
end)


Keys.Register('Y', 'PriseAppelServeur', 'Ouvrir le menu PriseAppelServeur', function()
  if AppelEnAttente then
  if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
    TriggerServerEvent('EMS:PriseAppelServeur')
    TriggerServerEvent("EMS:AjoutAppelTotalServeur")
    TriggerEvent('emsAppelPris', AppelID, AppelCoords)
  end
  else
    if IsControlJustPressed(1, 246) and AppelDejaPris == true then
    ESX.ShowAdvancedNotification("EMS", "~b~Demande d'ambulance", "L'appel à déja été pris, désolé.", "CHAR_MICHAEL", 10)
  end
  end
end)

Keys.Register('X', 'AppelEnAttente', 'Ouvrir le menu AppelEnAttente', function()
  if AppelEnAttente then
  if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
    ESX.ShowAdvancedNotification("EMS", "~b~Demande d'ambulance", "Vous avez refuser l'appel.", "CHAR_MICHAEL", 10)
    AppelEnAttente = false
    attente = false
    AppelDejaPris = false
  end
  end
end)

RegisterNetEvent("EMS:AppelDejaPris")
AddEventHandler("EMS:AppelDejaPris", function(name)
  AppelEnAttente = false
  AppelDejaPris = true
  TriggerEvent("EMS:DernierAppel", name)
  Citizen.Wait(10000)
  AppelDejaPris = false
end)

RegisterNetEvent("emsAppelPris")
AddEventHandler("emsAppelPris", function(Xid, XAppelCoords)
  ESX.ShowAdvancedNotification("EMS", "~b~Demande d'ambulance", "Vous avez pris l'appel, suivez la route GPS.", "CHAR_MICHAEL", 8)   
     afficherTextVolant(XAppelCoords, Xid)
end)

function afficherTextVolant(XAcoords, XAid)
  emsBlip = AddBlipForCoord(XAcoords)
   SetBlipShrink(emsBlip, true)
   SetBlipScale(emsBlip, 0.9)
   SetBlipPriority(emsBlio, 150)
   BeginTextCommandSetBlipName("STRING")
   AddTextComponentSubstringPlayerName("~b~[EMS] Appel en cours")
   EndTextCommandSetBlipName(emsBlip)
  SetBlipRoute(emsBlip, true)
  SetThisScriptCanRemoveBlipsCreatedByAnyScript(true)
  table.insert(tableBlip, emsBlip)
  rea = true
  while rea do
  if GetDistanceBetweenCoords(XAcoords, GetEntityCoords(GetPlayerPed(-1))) < 10.0 then
     ESX.ShowAdvancedNotification("EMS", "~b~GPS d'EMS", "Vous êtes arrivé !", "CHAR_MICHAEL", 2)   
     TriggerEvent("EMS:ClearAppel")
end
Wait(1)
end
end

RegisterNetEvent("EMS:ClearAppel")
AddEventHandler("EMS:ClearAppel", function()
  for k, v in pairs(tableBlip) do
    RemoveBlip(v)
  end
  rea = false
  tableBlip = {}
end)

-- Menu Patron

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

local open = false 
local mainMenu = RageUI.CreateMenu('Patron', 'Actions Patron')
mainMenu.Display.Header = true 
mainMenu.Closed = function()
  open = false
end

function MenuPatron()
  if open then 
    open = false
    RageUI.Visible(mainMenu, false)
    return
  else
    open = true 
    RageUI.Visible(mainMenu, true)
    CreateThread(function()
    RefreshMoney()
    while open do 
       RageUI.IsVisible(mainMenu,function() 
            
            if societyems ~= nil then
                RageUI.Button('Argent société:', nil, {RightLabel = "~g~"..societyems.."$"}, true, {onSelected = function()end});   
            end

            RageUI.Button('Déposer de l\'argent.', nil, {RightLabel = "→"}, true, {onSelected = function()
                local money = KeyboardInput('Combien voulez vous déposer ?', '', 10)
                TriggerServerEvent("pEMSjob:depositMoney","society_ems" ,money)
                RefreshMoney()
                RefreshMoney()
            end});  

            RageUI.Button('Retirer de l\'argent.', nil, {RightLabel = "→"}, true, {onSelected = function()
                local money = KeyboardInput('Combien voulez vous retirer ?', '', 10)
                TriggerServerEvent("pEMSjob:withdrawMoney","society_ems" ,money)
                RefreshMoney()
                RefreshMoney()
            end});   

       end)
     Wait(0)
    end
   end)
  end
end

function RefreshMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('pEMSjob:getSocietyMoney', function(money)
            societyems = money
        end, "society_ems")
    end
end

function Updatessocietyambulancemoney(money)
    societyambulance = ESX.Math.GroupDigits(money)
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLength)

  AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
  DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
  blockinput = true

  while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
    Citizen.Wait(0)
  end

  if UpdateOnscreenKeyboard() ~= 2 then
    local result = GetOnscreenKeyboardResult()
    Citizen.Wait(500)
    blockinput = false
    return result
  else
    Citizen.Wait(500)
    blockinput = false
    return nil
  end
end

Citizen.CreateThread(function()
    while true do
        local wait = 750
        if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
            for k in pairs(Config.Position.Boss) do
                local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local pos = Config.Position.Boss
                local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

                if dist <= 5.0 then
                    wait = 0
                    DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
                end

                if dist <= 2.0 then
                    wait = 0
                    Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour pour accèder au ~y~actions patron ~s~!", 1)
                    if IsControlJustPressed(1,51) then
                        MenuPatron()
                    end
                end
            end
        end
    Citizen.Wait(wait)
    end
end)

-- MenuCoffre

local mainMenu = RageUI.CreateMenu("Coffre", "Coffre entreprise")
local PutMenu = RageUI.CreateSubMenu(mainMenu,"Coffre", "Coffre entreprise")
local GetMenu = RageUI.CreateSubMenu(mainMenu,"Coffre", "Coffre entreprise")

local open = false

mainMenu:DisplayGlare(false)
mainMenu.Closed = function()
    open = false
end

all_items = {}

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    
    blockinput = true 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "Somme", ExampleText, "", "", "", MaxStringLenght) 
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end 
         
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

function MenuCoffre() 
    if open then 
    open = false
    RageUI.Visible(mainMenu, false)
    return
  else
    open = true 
    RageUI.Visible(mainMenu, true)
    CreateThread(function()
    while open do 
        RageUI.IsVisible(mainMenu, function()

            RageUI.Button("Déposer un objet", nil, {RightLabel = "→"}, true, {onSelected = function()
                getInventory()
            end},PutMenu);
            
            RageUI.Button("Prendre un objet", nil, {RightLabel = "→"}, true, {onSelected = function()
                getStock()
            end},GetMenu);

        end)

        RageUI.IsVisible(GetMenu, function()
            
            for k,v in pairs(all_items) do
                RageUI.Button(v.label, nil, {RightLabel = "~g~x"..v.nb}, true, {onSelected = function()
                    local count = KeyboardInput("Combien voulez vous en prendre ?",nil,4)
                    count = tonumber(count)
                    if count <= v.nb then
                        TriggerServerEvent("pEMSjob:takeStockItems",v.item, count)
                    else
                        ESX.ShowNotification("~r~Vous n'avez pas cette quantité.")
                    end
                    getStock()
                end});
            end

        end)

        RageUI.IsVisible(PutMenu, function()
            
            for k,v in pairs(all_items) do
                RageUI.Button(v.label, nil, {RightLabel = "~g~x"..v.nb}, true, {onSelected = function()
                    local count = KeyboardInput("Combien voulez vous en déposer ?",nil,4)
                    count = tonumber(count)
                    TriggerServerEvent("pEMSjob:putStockItems",v.item, count)
                    getInventory()
                end});
            end

       end)
        Wait(0)
    end
 end)
 end
 end

function getInventory()
    ESX.TriggerServerCallback('pEMSjob:playerinventory', function(inventory)               
                
        all_items = inventory
        
    end)
end

function getStock()
    ESX.TriggerServerCallback('pEMSjob:getStockItems', function(inventory)               
                
        all_items = inventory
        
    end)
end

Citizen.CreateThread(function()
    while true do
    local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
        for k in pairs(Config.Position.Coffre) do
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local pos = Config.Position.Coffre
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

        if dist <= 5.0 then
          wait = 0
          DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
        end

        if dist <= 2.0 then
          wait = 0
          Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour accèder au ~y~coffre ~s~!", 1)
          if IsControlJustPressed(1,51) then
            MenuCoffre()
          end
        end
      end
    end
    Citizen.Wait(wait)
    end
end)

-- Function

local FirstSpawn, PlayerLoaded = true, false

IsDead = false
ESX = nil
Nombreinter = 0
ReaFaite = false

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Normal()
    Citizen.Wait(0)
  end

  while ESX.GetPlayerData().job == nil do
    Citizen.Wait(100)
  end

  PlayerLoaded = true
  ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
  PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

AddEventHandler('playerSpawned', function()
  IsDead = false

  if FirstSpawn then
    exports.spawnmanager:setAutoSpawn(false) -- disable respawn
    FirstSpawn = false

    ESX.TriggerServerCallback('pEMSjob:getDeathStatus', function(isDead)
      if isDead and Config.AntiCombatLog then
        while not PlayerLoaded do
          Citizen.Wait(1000)
        end

        ESX.ShowNotification(_U('combatlog_message'))
        RemoveItemsAfterRPDeath()
      end
    end)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if IsDead then
      DisableAllControlActions(0)
      EnableControlAction(0, Keys['G'], true)
      EnableControlAction(0, Keys['T'], true)
      EnableControlAction(0, Keys['E'], true)
    else
      Citizen.Wait(500)
    end
  end
end)

function OnPlayerDeath()
  
  IsDead = true
  ESX.UI.Menu.CloseAll()
  TriggerServerEvent('pEMSjob:setDeathStatus', true)

  StartDeathTimer()
  StartDistressSignal()

  StartScreenEffect('DeathFailOut', 0, false)
  
end

RegisterNetEvent('pEMSjob:useItem')
AddEventHandler('pEMSjob:useItem', function(itemName)
  ESX.UI.Menu.CloseAll()

  if itemName == 'medikit' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

      Citizen.Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Citizen.Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('pEMSjob:heal', 'big', true)
      ESX.ShowNotification(_U('used_medikit'))
    end)

  elseif itemName == 'bandage' then
    local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(lib, function()
      TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

      Citizen.Wait(500)
      while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
        Citizen.Wait(0)
        DisableAllControlActions(0)
      end

      TriggerEvent('pEMSjob:heal', 'small', true)
      ESX.ShowNotification(_U('used_bandage'))
    end)
  end
end)

function StartDistressSignal()
  Citizen.CreateThread(function()
    local timer = Config.BleedoutTimer

    while timer > 0 and IsDead do
      Citizen.Wait(2)
      timer = timer - 30

      SetTextFont(4)
      SetTextScale(0.45, 0.45)
      SetTextColour(185, 185, 185, 255)
      SetTextDropshadow(0, 0, 0, 0, 255)
      SetTextEdge(1, 0, 0, 0, 255)
      SetTextDropShadow()
      SetTextOutline()
      BeginTextCommandDisplayText('STRING')
      AddTextComponentSubstringPlayerName(_U('distress_send'))
      EndTextCommandDisplayText(0.175, 0.805)

      if IsControlPressed(0, Keys['G']) then
        ESX.ShowAdvancedNotification("EMS", "~b~Demande d'ambulance", "Votre requête a bien été envoyée à l'équipe des ambulanciers.", "CHAR_MICHAEL", 10)
        TriggerEvent("AppelemsGetCoords")

        Citizen.CreateThread(function()
          Citizen.Wait(1000 * 60 * 5)
          if IsDead then
            StartDistressSignal()
          end
        end)

        break
      end
    end
  end)
end

RegisterNetEvent('pEMSjob:notif')
AddEventHandler('pEMSjob:notif', function()
  Nombreinter = Nombreinter - 1
  if Nombreinter < 0 then
    Nombreinter = 0
  end
  ReaFaite = true
  ESX.ShowAdvancedNotification('EMS INFO', 'EMS CENTRAL', 'Réanimation effectué.\n~g~'..Nombreinter..' intervention en cours.', 'CHAR_MICHAEL', 3)
end)

function DrawGenericTextThisFrame()
  SetTextFont(4)
  SetTextScale(0.0, 0.5)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(true)
end

function secondsToClock(seconds)
  local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

  if seconds <= 0 then
    return 0, 0
  else
    local hours = string.format("%02.f", math.floor(seconds / 3600))
    local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
    local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

    return mins, secs
  end
end

function StartDeathTimer()
  local canPayFine = false

  if Config.EarlyRespawnFine then
    ESX.TriggerServerCallback('pEMSjob:checkBalance', function(canPay)
      canPayFine = canPay
    end)
  end

  local earlySpawnTimer = ESX.Math.Round(EarlyRespawnTimer / 1000)
  local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)

  Citizen.CreateThread(function()
    while earlySpawnTimer > 0 and IsDead do
      Citizen.Wait(1000)

      if earlySpawnTimer > 0 then
        earlySpawnTimer = earlySpawnTimer - 1
      end
    end

    while bleedoutTimer > 0 and IsDead do
      Citizen.Wait(1000)

      if bleedoutTimer > 0 then
        bleedoutTimer = bleedoutTimer - 1
      end
    end
  end)

  Citizen.CreateThread(function()
    local text, timeHeld

    while earlySpawnTimer > 0 and IsDead do
      Citizen.Wait(0)
      text = _U('respawn_available_in', secondsToClock(earlySpawnTimer))

      DrawGenericTextThisFrame()

      SetTextEntry("STRING")
      AddTextComponentString(text)
      DrawText(0.5, 0.8)
    end

    while bleedoutTimer > 0 and IsDead do
      Citizen.Wait(0)
      text = _U('respawn_bleedout_in', secondsToClock(bleedoutTimer))

      if not Config.EarlyRespawnFine then
        text = text .. _U('respawn_bleedout_prompt')

        if IsControlPressed(0, Keys['E']) and timeHeld > 60 then
          RemoveItemsAfterRPDeath()
          break
        end
      elseif Config.EarlyRespawnFine and canPayFine then
        text = text .. _U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

        if IsControlPressed(0, Keys['E']) and timeHeld > 60 then
          TriggerServerEvent('pEMSjob:payFine')
          RemoveItemsAfterRPDeath()
          break
        end
      end

      if IsControlPressed(0, Keys['E']) then
        timeHeld = timeHeld + 1
      else
        timeHeld = 0
      end

      DrawGenericTextThisFrame()

      SetTextEntry("STRING")
      AddTextComponentString(text)
      DrawText(0.5, 0.8)
    end
      
    if bleedoutTimer < 1 and IsDead then
      RemoveItemsAfterRPDeath()
    end
  end)
end

function Normal()
    local playerPed = GetPlayerPed(-1)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    SetPedMotionBlur(playerPed, false)
end

function RemoveItemsAfterRPDeath()
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)
  TriggerServerEvent('pEMSjob:setDeathStatus', false)

  Citizen.CreateThread(function()
    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
      Citizen.Wait(10)
    end

    local formattedCoords = {
      x = Config.RespawnPoint.coords.x,
      y = Config.RespawnPoint.coords.y,
      z = Config.RespawnPoint.coords.z
    }

    ESX.SetPlayerData('lastPosition', formattedCoords)

    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

    RespawnPed(playerPed, formattedCoords, 0.0)

    StopScreenEffect('DeathFailOut')
    DoScreenFadeIn(800)
    Citizen.Wait(10)
    ClearPedTasksImmediately(playerPed)
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(playerPed, true)
    RequestAnimSet("move_injured_generic")
      while not HasAnimSetLoaded("move_injured_generic") do
        Citizen.Wait(0)
      end
    SetPedMovementClipset(playerPed, "move_injured_generic", true)
    PlaySoundFrontend(-1, "1st_Person_Transition", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 0)
    PlaySoundFrontend(-1, "1st_Person_Transition", "PLAYER_SWITCH_CUSTOM_SOUNDSET", 0)
    ESX.ShowAdvancedNotification('REANIMATION X', 'Unité X réanimation', 'Vous avez été réanimé par l\'unité X.', 'CHAR_MICHAEL', 1)
    local ped = GetPlayerPed(PlayerId())
    local coords = GetEntityCoords(ped, false)
    local name = GetPlayerName(PlayerId())
    local x, y, z = table.unpack(GetEntityCoords(ped, false))
    TriggerServerEvent('pEMSjob:NotificationBlipsX', x, y, z, name)
    Citizen.Wait(60*1000) -- Effets de la réanmation pendant 1 minute ( 60 seconde )
    Normal()

  end)
end

function RespawnPed(ped, coords, heading)

  SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
  NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
  SetPlayerInvincible(ped, false)
  TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
  ClearPedBloodDamage(ped)

  ESX.UI.Menu.CloseAll()
end

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
  local specialContact = {
    name       = 'EMS',
    number     = 'ems',
    base64Icon = 'data:image/png;base64,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'
  }

  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  OnPlayerDeath()
end)

RegisterNetEvent('pEMSjob:revive')
AddEventHandler('pEMSjob:revive', function()
  Nombreinter = Nombreinter - 1
  local playerPed = PlayerPedId()
  local coords = GetEntityCoords(playerPed)

  TriggerServerEvent('pEMSjob:setDeathStatus', false)
  Citizen.CreateThread(function()
    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
      Citizen.Wait(50)
    end

    local formattedCoords = {
      x = ESX.Math.Round(coords.x, 1),
      y = ESX.Math.Round(coords.y, 1),
      z = ESX.Math.Round(coords.z, 1)
    }

    ESX.SetPlayerData('lastPosition', formattedCoords)

    TriggerServerEvent('esx:updateLastPosition', formattedCoords)

    RespawnPed(playerPed, formattedCoords, 0.0)

    StopScreenEffect('DeathFailOut')
    DoScreenFadeIn(800)
    
  end)
end)

RegisterNetEvent('pEMSjob:heal')
AddEventHandler('pEMSjob:heal', function(healType, quiet)
  local playerPed = PlayerPedId()
  local maxHealth = GetEntityMaxHealth(playerPed)

  if healType == 'small' then
    local health = GetEntityHealth(playerPed)
    local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
    SetEntityHealth(playerPed, newHealth)
  elseif healType == 'big' then
    SetEntityHealth(playerPed, maxHealth)
  end

  if not quiet then
    ESX.ShowNotification('Vous avez été soigner.')
  end
end)
 
RegisterNetEvent('pEMSjob:putInVehicle')
AddEventHandler('pEMSjob:putInVehicle', function()
  
  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)
  
  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
  
    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)
  
    if DoesEntityExist(vehicle) then
  
      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil
  
      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end
  
      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end
    end
  end
end)
  
RegisterNetEvent("pEMSjob:OutVehicle")
AddEventHandler("pEMSjob:OutVehicle", function()
  TaskLeaveAnyVehicle(GetPlayerPed(-1), 0, 0)
end)

-- Menu EMS

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

local AppelTotal = 0
local NomAppel = "~r~Personne"

RegisterNetEvent("EMS:AjoutUnAppel")
AddEventHandler("EMS:AjoutUnAppel", function(Appel)
  AppelTotal = Appel
end)

RegisterNetEvent("EMS:DernierAppel")
AddEventHandler("EMS:DernierAppel", function(Appel)
  NomAppel = Appel
end)

local open = false 
local mainMenu8 = RageUI.CreateMenu('Secouriste', 'Interaction')
local subMenu9 = RageUI.CreateSubMenu(mainMenu8, "Secouriste", "Interaction")
mainMenu8.Display.Header = true 
mainMenu8.Closed = function()
  open = false
end

function Menu()
  if open then 
    open = false
    RageUI.Visible(mainMenu8, false)
    return
  else
    open = true 
    RageUI.Visible(mainMenu8, true)
    CreateThread(function()
    while open do 
       RageUI.IsVisible(mainMenu8,function()
      RageUI.Checkbox("Prendre son service", nil, serviceAmbulance, {}, {
                onChecked = function(index, items)
                    serviceAmbulance = true
          ESX.ShowNotification("~g~Vous avez pris votre service !")
                end,
                onUnChecked = function(index, items)
                    serviceAmbulance = false
          ESX.ShowNotification("~r~Vous avez fini votre service !")
                end
            })

      if serviceAmbulance then

            RageUI.Separator("~y~↓ Interaction Citoyen ↓")

            RageUI.Button("Interaction Citoyen", nil, {RightLabel = "→→"}, true , {
              onSelected = function()
                end
            }, subMenu9)    

            RageUI.Button("Faire une Facture", nil, {RightLabel = "→→"}, true , {
                onSelected = function()
                    amount = KeyboardInput("Quel est le montant de la facture ?",nil,5)
                    amount = tonumber(amount)
                    local player, distance = ESX.Game.GetClosestPlayer()
    
                    if player ~= -1 and distance <= 3.0 then
            
                    if amount == nil then
                        ESX.ShowNotification("~r~Problèmes~s~: Montant invalide")
                    else
                        local playerPed        = GetPlayerPed(-1)
                        Citizen.Wait(5000)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_ems', ('EMS'), amount)
                        Citizen.Wait(100)
                        ESX.ShowNotification("~g~Vous avez bien envoyer la facture")
                    end
            
                    else
                    ESX.ShowNotification("~r~Problèmes~s~: Aucune personne à proximitée")
                    end
                end
            });


        end
    end)

   RageUI.IsVisible(subMenu9,function() 

    RageUI.Button("Réanimer la Personne", nil, {RightLabel = "→"}, true , {
        onSelected = function()
            revivePlayer(closestPlayer)    
        end
        })

        RageUI.Button("Soigner une petite blessure", nil, {RightLabel = "→"}, true , {
            onSelected = function()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestPlayer == -1 or closestDistance > 1.0 then
                    ESX.ShowNotification('Aucune personne à proximité')
                else
                    ESX.TriggerServerCallback('pEMSjob:getItemAmount', function(quantity)
                        if quantity > 0 then
                            local closestPlayerPed = GetPlayerPed(closestPlayer)
                            local health = GetEntityHealth(closestPlayerPed)
        
                            if health > 0 then
                                local playerPed = PlayerPedId()
        
                                IsBusy = true
                                TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                                Citizen.Wait(10000)
                                ClearPedTasks(playerPed)
        
                                TriggerServerEvent('pEMSjob:removeItem', 'bandage')
                                TriggerServerEvent('pEMSjob:heal', GetPlayerServerId(closestPlayer), 'small')
                                ESX.ShowNotification('vous avez soigné ~y~%s~s~', GetPlayerName(closestPlayer))
                                IsBusy = false
                            else
                                ESX.ShowNotification('Cette personne est inconsciente!')
                            end
                        else
                            ESX.ShowNotification('Vous n\'avez pas de ~b~bandage~s~.')
                        end
                    end, 'bandage')
                end
            end
            })

        
    RageUI.Button("Soigner une plus grande blessure", nil, {RightLabel = "→"}, true , {
        onSelected = function()
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
            if closestPlayer == -1 or closestDistance > 1.0 then
                ESX.ShowNotification('Aucune personne à proximité')
            else
                ESX.TriggerServerCallback('pEMSjob:getItemAmount', function(quantity)
                    if quantity > 0 then
                        local closestPlayerPed = GetPlayerPed(closestPlayer)
                        local health = GetEntityHealth(closestPlayerPed)

                        if health > 0 then
                            local playerPed = PlayerPedId()

                            IsBusy = true
                            TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                            Citizen.Wait(10000)
                            ClearPedTasks(playerPed)

                            TriggerServerEvent('pEMSjob:removeItem', 'medikit')
                            TriggerServerEvent('pEMSjob:heal', GetPlayerServerId(closestPlayer), 'big')
                            ESX.ShowNotification('Vous avez soigné ~y~%s~s~', GetPlayerName(closestPlayer))
                            IsBusy = false
                        else
                            ESX.ShowNotification('Cette personne est inconsciente!')
                        end
                    else
                        ESX.ShowNotification('Vous n\'avez pas de ~b~kit de soin~s~.')
                    end
                end, 'medikit')
            end
        end
        })

end)

Wait(0)
end
end)
end
end

-- Key

Keys.Register('F6', 'EMS', 'Ouvrir le menu EMS', function()
  if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
        Menu()
  end
end)

-- Function revive

function revivePlayer(closestPlayer)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer == -1 or closestDistance > 3.0 then
      ESX.ShowNotification("Aucune personne à proximité.")
    else
        ESX.TriggerServerCallback('pEMSjob:getItemAmount', function(qtty)
        if qtty > 0 then
            local closestPlayerPed = GetPlayerPed(closestPlayer)
            local health = GetEntityHealth(closestPlayerPed)
            if health == 0 then
                local playerPed = GetPlayerPed(-1)
                Citizen.CreateThread(function()
                ESX.ShowNotification(_U('revive_inprogress'))
                TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                Wait(10000)
                ClearPedTasks(playerPed)
                if GetEntityHealth(closestPlayerPed) == 0 then
                    TriggerServerEvent('pEMSjob:removeItem', 'medikit')
                    TriggerServerEvent('pEMSjob:revive', GetPlayerServerId(closestPlayer))
                else
                    ESX.ShowNotification(_U('isdead'))
                end
            end)
        else
            exports['cNotif']:Alert("Information", "Cette personne est inconciente.", 5000, 'info')
        end
    else
        exports['cNotif']:Alert("Information", "Vous n'avez pas de kit de soin.", 5000, 'error')
    end
   end, 'medikit')
end
end

-- Blips

local pos = vector3(Config.Position.Blips.x, Config.Position.Blips.y,Config.Position.Blips.z)
Citizen.CreateThread(function()
  local blip = AddBlipForCoord(pos)

  SetBlipSprite (blip, 61)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 0.8)
  SetBlipColour (blip, 2)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName('STRING')
  AddTextComponentSubstringPlayerName('Hôpital')
  EndTextCommandSetBlipName(blip)
end)

-- Menu Pharmacie

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

local open = false 
local mainMenu = RageUI.CreateMenu('Pharmacie', 'Pharmacie entreprise') 
mainMenu.Display.Header = true 
mainMenu.Closed = function()
  open = false
end

function MenuPharmacie() 
    if open then 
    open = false
    RageUI.Visible(mainMenu, false)
    return
  else
    open = true 
    RageUI.Visible(mainMenu, true)
    CreateThread(function()
    while open do 
        RageUI.IsVisible(mainMenu, function()

      for k, v in pairs(Config.Pharmacie) do
      RageUI.Button(v.Nom, nil, {RightLabel = "(x1)"}, true, {
        onSelected = function()
          TriggerServerEvent('pEMSjob:giveItem', v.Nom, v.Item)
        end
      }) 
    end
    end)      
    Wait(0)
     end
  end)
 end
end

Citizen.CreateThread(function()
    while true do
    local wait = 750
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
      for k in pairs(Config.Position.Pharmacie) do
                local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                local pos = Config.Position.Pharmacie
                local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

                if dist <= 5.0 then
                    wait = 0
                    DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
                end

                if dist <= 2.0 then
                    wait = 0
                    Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour accèder a la ~y~pharmacie ~s~!", 1)
                    if IsControlJustPressed(1,51) then
                        MenuPharmacie()
                    end
                end
            end
    end
    Citizen.Wait(wait)
    end
end)

-- Menu Vestiaire

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

function applySkinSpecific(infos)
  TriggerEvent('skinchanger:getSkin', function(skin)
    local uniformObject
    if skin.sex == 0 then
      uniformObject = infos.variations.male
    else
      uniformObject = infos.variations.female
    end
    if uniformObject then
      TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
    end

    infos.onEquip()
  end)
end

local open = false 
local mainMenu6 = RageUI.CreateMenu('Vestiaire', 'Votre vestiaire')
mainMenu6.Display.Header = true 
mainMenu6.Closed = function()
  open = false
end

function MenuVestiaire()
     if open then 
         open = false
         RageUI.Visible(mainMenu6, false)
         return
     else
         open = true 
         RageUI.Visible(mainMenu6, true)
         CreateThread(function()
         while open do 
            RageUI.IsVisible(mainMenu6,function() 

                RageUI.Separator("↓ ~y~Vos Tenues ~s~↓")
                for index,infos in pairs(AmbuCloak.clothes.grades) do
                  RageUI.Button(infos.label, nil, {RightLabel = ">"}, ESX.PlayerData.job.grade >= infos.minimum_grade, {
                    onSelected = function()
                        applySkinSpecific(infos)
                      end
                    })
              end
            end)
          Wait(0)
         end
      end)
   end
end

Citizen.CreateThread(function()
  while true do
  local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
    for k in pairs(Config.Position.Vestaire) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.Position.Vestaire
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= 5.0  then
                  wait = 0
                  DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
              end

              if dist <= 2.0 then
                  wait = 0
                  Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour pour accèder au ~y~vestaire ~s~!", 1)
                  if IsControlJustPressed(1,51) then
                    MenuVestiaire()
                  end
              end
          end
  end
  Citizen.Wait(wait)
  end
end)

-- Menu Garage Véhicule

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  ESX.PlayerData.job = job
end)

local open = false 
local mainMenu6 = RageUI.CreateMenu('Garage', 'Garage entreprise')
mainMenu6.Display.Header = true 
mainMenu6.Closed = function()
  open = false
end

function MenuGarageVehicule()
     if open then 
         open = false
         RageUI.Visible(mainMenu6, false)
         return
     else
         open = true 
         RageUI.Visible(mainMenu6, true)
         CreateThread(function()
         while open do 
            RageUI.IsVisible(mainMenu6,function() 

              RageUI.Button("Ranger votre véhicule", nil, {RightLabel = "→→"}, true , {
                onSelected = function()
                  local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                  if dist4 < 4 then
                      DeleteEntity(veh)
                      RageUI.CloseAll()
                  end
                 end
             })

              RageUI.Separator("↓ ~y~Véhicules de serice ~s~↓")

                for k,v in pairs(Config.VehiculeEMS) do
                RageUI.Button(v.buttoname, nil, {RightLabel = "→→"}, true , {
                    onSelected = function()
                        if not ESX.Game.IsSpawnPointClear(vector3(v.spawnzone.x, v.spawnzone.y, v.spawnzone.z), 10.0) then
                        ESX.ShowNotification("~r~La sortie du garage est bloquer.")
                        else
                        local model = GetHashKey(v.spawnname)
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(10) end
                        local ambuveh = CreateVehicle(model, v.spawnzone.x, v.spawnzone.y, v.spawnzone.z, v.headingspawn, true, false)
                        SetVehicleNumberPlateText(ambuveh, "ems"..math.random(50, 999))
                        SetVehicleFixed(ambuveh)
                        TaskWarpPedIntoVehicle(PlayerPedId(),  ambuveh,  -1)
                        SetVehRadioStation(ambuveh, 0)
                        RageUI.CloseAll()
                        end
                    end
                })


              end
            end)
          Wait(0)
         end
      end)
   end
end

Citizen.CreateThread(function()
  while true do 
      local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
          for k in pairs(Config.Position.GarageVehicule) do 
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.Position.GarageVehicule
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= 5.0 then 
                  wait = 0
                  DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
              end

              if dist <= 2.0 then 
                  wait = 0
                  Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour accèder au ~y~garage ~s~!", 1)
                  if IsControlJustPressed(1,51) then
                      MenuGarageVehicule()
                  end
              end
          end
      end
  Citizen.Wait(wait)
  end
end)

-- Garage Helicoptère

local open = false 
local mainMenu6 = RageUI.CreateMenu('Garage', 'Garage entreprise')
mainMenu6.Display.Header = true 
mainMenu6.Closed = function()
  open = false
end

function MenuGarageHelicoptere()
     if open then 
         open = false
         RageUI.Visible(mainMenu6, false)
         return
     else
         open = true 
         RageUI.Visible(mainMenu6, true)
         CreateThread(function()
         while open do 
            RageUI.IsVisible(mainMenu6,function() 

              RageUI.Button("Ranger votre véhicule", nil, {RightLabel = "→"}, true , {
                onSelected = function()
                  local veh,dist4 = ESX.Game.GetClosestVehicle(playerCoords)
                  if dist4 < 4 then
                      DeleteEntity(veh)
                      RageUI.CloseAll()
                  end
                    end
                  })

              RageUI.Separator("↓ ~y~Véhicules de serice ~s~↓")

                for k,v in pairs(Config.HelicoEMS) do
                RageUI.Button(v.buttonameheli, nil, {RightLabel = "→"}, true , {
                    onSelected = function()
                        if not ESX.Game.IsSpawnPointClear(vector3(v.spawnzoneheli.x, v.spawnzoneheli.y, v.spawnzoneheli.z), 10.0) then
                        ESX.ShowNotification("~g~Ambulance\n~r~Point de spawn bloquée")
                        else
                        local model = GetHashKey(v.spawnnameheli)
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(10) end
                        local ambuheli = CreateVehicle(model, v.spawnzoneheli.x, v.spawnzoneheli.y, v.spawnzoneheli.z, v.headingspawnheli, true, false)
                        SetVehicleNumberPlateText(ambuheli, "ems"..math.random(50, 999))
                        SetVehicleFixed(ambuheli)
                        TaskWarpPedIntoVehicle(PlayerPedId(),  ambuheli,  -1)
                        SetVehRadioStation(ambuheli, 0)
                        RageUI.CloseAll()
                        end
                    end
                })


              end
            end)
          Wait(0)
         end
      end)
   end
end


Citizen.CreateThread(function()
  while true do 
      local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ems' then
          for k in pairs(Config.Position.GarageHeli) do 
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.Position.GarageHeli
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= 5.0 then 
                  wait = 0
                  DrawMarker(6, pos[k].x, pos[k].y, pos[k].z-0.99, nil, nil, nil, -90, nil, nil, 1.0, 1.0, 1.0, 230, 230, 0 , 120)
              end

              if dist <= 2.0 then 
                  wait = 0
                  Visual.Subtitle("Appuyez sur ~y~[E] ~s~pour accèder au ~y~garage ~s~!", 1)
                  if IsControlJustPressed(1,51) then
                      MenuGarageHelicoptere()
                  end
              end
          end
      end
  Citizen.Wait(wait)
  end
end)
