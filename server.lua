ESX = nil
local playersHealing, deadPlayers = {}, {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.GcPhone == true then
	TriggerEvent('esx_phone:registerNumber', 'ems', 'alerte ambulance', true, true)
end

TriggerEvent('esx_society:registerSociety', 'ems', 'ems', 'society_ems', 'society_ems', 'society_ems', {type = 'public'})

---- Ambulance

RegisterServerEvent('pEMSjob:revive')
AddEventHandler('pEMSjob:revive', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

	if xPlayer.job.name == 'ems' then
		local societyAccount = nil
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_ems', function(account)
			societyAccount = account
		end)
		if societyAccount ~= nil then
			xPlayer.addMoney(Config.ReviveReward)
			TriggerClientEvent('pEMSjob:revive', target)
			societyAccount.addMoney(300)
		end
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'ems' then
				TriggerClientEvent('pEMSjob:notif', xPlayers[i])
			end
		end
	else
		print(('esx_ambulancejob: %s attempted to revive!'):format(xPlayer.identifier))
	end
end)

ESX.RegisterServerCallback('pEMSjob:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.RemoveCashAfterRPDeath then
		if xPlayer.getMoney() > 0 then
			xPlayer.removeMoney(xPlayer.getMoney())
		end

		if xPlayer.getAccount('black_money').money > 0 then
			xPlayer.setAccountMoney('black_money', 0)
		end
	end

	if Config.RemoveItemsAfterRPDeath then
		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
	end

	local playerLoadout = {}
	if Config.RemoveWeaponsAfterRPDeath then
		for i=1, #xPlayer.loadout, 1 do
			xPlayer.removeWeapon(xPlayer.loadout[i].name)
		end
	else -- save weapons & restore em' since spawnmanager removes them
		for i=1, #xPlayer.loadout, 1 do
			table.insert(playerLoadout, xPlayer.loadout[i])
		end

		-- give back wepaons after a couple of seconds
		Citizen.CreateThread(function()
			Citizen.Wait(5000)
			for i=1, #playerLoadout, 1 do
				if playerLoadout[i].label ~= nil then
					xPlayer.addWeapon(playerLoadout[i].name, playerLoadout[i].ammo)
				end
			end
		end)
	end

	cb()
end)

if EarlyRespawnTimer then
	ESX.RegisterServerCallback('pEMSjob:checkBalance', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= EarlyRespawnFineAmount)
	end)

	RegisterNetEvent('pEMSjob:payFine')
	AddEventHandler('pEMSjob:payFine', function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local fineAmount = EarlyRespawnFineAmount

		TriggerClientEvent("esx:showAdvancedNotification", source, "vous avez payé" ..ESX.Math.GroupDigits(fineAmount) " pour être réanimer.")
		xPlayer.removeAccountMoney('bank', fineAmount)
	end)
end


ESX.RegisterServerCallback('pEMSjob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count

	cb(quantity)
end)

RegisterServerEvent('pEMSjob:removeItem')
AddEventHandler('pEMSjob:removeItem', function(item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	xPlayer.removeInventoryItem(item, 1)

	if item == 'bandage' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
	elseif item == 'medikit' then
		TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
	end
end)


TriggerEvent('es:addGroupCommand', 'revive', 'mod', function(source, args, user)
	if args[1] ~= nil then
		if GetPlayerName(tonumber(args[1])) ~= nil then
			TriggerClientEvent('pEMSjob:revive', tonumber(args[1]))
		end
	else
		TriggerClientEvent('pEMSjob:revive', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = ('Réanimer un joueur'), params = {{name = 'id'}}})

TriggerEvent('es:addGroupCommand', 'reviveall', 'mod', function(source, args, user)
    TriggerClientEvent('pEMSjob:revive', -1)
end, function(source, args, user)
    TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = ('Réanimer tout les joueurs'), params = {{name = 'id'}}})

ESX.RegisterUsableItem('medikit', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('medikit', 1)

		playersHealing[source] = true
		TriggerClientEvent('pEMSjob:useItem', source, 'medikit')

		Citizen.Wait(7000)
		playersHealing[source] = nil
	end
end)

ESX.RegisterUsableItem('bandage', function(source)
	if not playersHealing[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem('bandage', 1)

		playersHealing[source] = true
		TriggerClientEvent('pEMSjob:useItem', source, 'bandage')

		Citizen.Wait(7000)
		playersHealing[source] = nil
	end
end)

ESX.RegisterServerCallback('pEMSjob:getDeathStatus', function(source, cb)
	local identifier = GetPlayerIdentifiers(source)[1]

	MySQL.Async.fetchScalar('SELECT is_dead FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(isDead)
		if isDead then
			print(('pEMSjob: %s attempted combat logging!'):format(identifier))
		end

		cb(isDead)
	end)
end)

RegisterServerEvent('pEMSjob:setDeathStatus')
AddEventHandler('pEMSjob:setDeathStatus', function(isDead)
	local identifier = GetPlayerIdentifiers(source)[1]

	if type(isDead) ~= 'boolean' then
		print(('pEMSjob: %s attempted to parse something else than a boolean to setDeathStatus!'):format(identifier))
		return
	end

	MySQL.Sync.execute('UPDATE users SET is_dead = @isDead WHERE identifier = @identifier', {
		['@identifier'] = identifier,
		['@isDead'] = isDead
	})
end)


-- Notification appel ems pour tout les ems

RegisterServerEvent("Server:emsAppel")
AddEventHandler("Server:emsAppel", function(coords, id)
	--local xPlayer = ESX.GetPlayerFromId(source)
	local _coords = coords
	local xPlayers	= ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
          if xPlayer.job.name == 'ems' then
               TriggerClientEvent("AppelemsTropBien", xPlayers[i], _coords, id)
		end
	end
end)


-- Prise d'appel ems
RegisterServerEvent('EMS:PriseAppelServeur')
AddEventHandler('EMS:PriseAppelServeur', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local name = xPlayer.getName(source)
	local xPlayers = ESX.GetPlayers()

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'ems' then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'EMS', '~b~Information', 'L\'ambulancier ~b~'..name..'~s~ a pris l\'appel ', 'CHAR_MICHAEL', 2)
			TriggerClientEvent('EMS:AppelDejaPris', xPlayers[i], name)
		end
	end
end)

ESX.RegisterServerCallback('EMS:GetID', function(source, cb)
	local idJoueur = source
	cb(idJoueur)
end)

local AppelTotal = 0
RegisterServerEvent('EMS:AjoutAppelTotalServeur')
AddEventHandler('EMS:AjoutAppelTotalServeur', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local name = xPlayer.getName(source)
	local xPlayers = ESX.GetPlayers()
	AppelTotal = AppelTotal + 1

	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'ems' then
			TriggerClientEvent('EMS:AjoutUnAppel', xPlayers[i], AppelTotal)
		end
	end

end)

-- Coffre

ESX.RegisterServerCallback('pEMSjob:playerinventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory
	local all_items = {}
	
	for k,v in pairs(items) do
		if v.count > 0 then
			table.insert(all_items, {label = v.label, item = v.name,nb = v.count})
		end
	end

	cb(all_items)

	
end)

ESX.RegisterServerCallback('pEMSjob:getStockItems', function(source, cb)
	local all_items = {}
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
		for k,v in pairs(inventory.items) do
			if v.count > 0 then
				table.insert(all_items, {label = v.label,item = v.name, nb = v.count})
			end
		end

	end)
	cb(all_items)
end)

RegisterServerEvent('pEMSjob:putStockItems')
AddEventHandler('pEMSjob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local item_in_inventory = xPlayer.getInventoryItem(itemName).count

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
		if item_in_inventory >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez déposer ~y~"..itemName.."~s~ au nombre de ~y~"..count.."~s~.")
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, "~r~Vous n'avez pas cette quantité.")
		end
	end)
end)

RegisterServerEvent('pEMSjob:takeStockItems')
AddEventHandler('pEMSjob:takeStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ems', function(inventory)
			xPlayer.addInventoryItem(itemName, count)
			inventory.removeItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez retirer ~y~"..itemName.."~s~ au nombre de ~y~"..count.."~s~.")
	end)
end)


-- Pharamacie 


RegisterServerEvent('pEMSjob:giveItem')
AddEventHandler('pEMSjob:giveItem', function(Nom, Item)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local qtty = xPlayer.getInventoryItem(Item).count

		if qtty < 10 then
			xPlayer.addInventoryItem(Item, 1)
			TriggerClientEvent('esx:showNotification', _source, 'Tu as recu des bandages (~g~+1~s~)')
		else
			TriggerClientEvent('esx:showNotification', _source, "~r~Vous avez atteints la limite !")
		end
	end)

-- Boss

RegisterServerEvent('pEMSjob:withdrawMoney')
AddEventHandler('pEMSjob:withdrawMoney', function(society, amount, money_soc)
	local xPlayer = ESX.GetPlayerFromId(source)
	local src = source
  
	TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
	  if account.money >= tonumber(amount) then
		  xPlayer.addMoney(amount)
		  account.removeMoney(amount)
		  TriggerClientEvent("esx:showNotification", src, "Vous avez retirer~g~ "..amount.."$")
	  else
		  TriggerClientEvent("esx:showNotification", src, "~rL'entreprise n'as pas asser d'argent.")
	  end
	end)
	  
  end)

RegisterServerEvent('pEMSjob:depositMoney')
AddEventHandler('pEMSjob:depositMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)
	local money = xPlayer.getMoney()
	local src = source
  
	TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
	  if money >= tonumber(amount) then
		  xPlayer.removeMoney(amount)
		  account.addMoney(amount)
		  TriggerClientEvent("esx:showNotification", src, "Vous avez déposer~r~ "..amount.."$")
	  else
		  TriggerClientEvent("esx:showNotification", src, "~rVous n'avez pas asser d'argent.")
	  end
	end)
	
end)

ESX.RegisterServerCallback('pEMSjob:getSocietyMoney', function(source, cb, soc)
	local money = nil
		MySQL.Async.fetchAll('SELECT * FROM addon_account_data WHERE account_name = @society ', {
			['@society'] = soc,
		}, function(data)
			for _,v in pairs(data) do
				money = v.money
			end
			cb(money)
		end)
end)

-- Autre

RegisterNetEvent('pEMSjob:heal')
AddEventHandler('pEMSjob:heal', function(target, type)
  TriggerClientEvent('pEMSjob:heal', target, type)
end)
