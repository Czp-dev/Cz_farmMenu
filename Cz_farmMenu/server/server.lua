local isOpen = false
local farmList = {}
local farmData = {
    id = nil,
    name = nil,
    nameTraitement = nil,
    coords_recolte = nil,
    coords_traitement = nil,
    coords_vente = nil,
    vente_prix = nil
}

local function isAdmin(playerId)
    local xPlayer = BridgesGetPlayerFromId(playerId)
    if xPlayer then
        local group = xPlayer.getGroup()
        return group == 'admin' or group == 'superadmin'
    end
    return false
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS farms (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(50),
                nameTraitement VARCHAR(50),
                coords_recolte VARCHAR(255),
                coords_traitement VARCHAR(255),
                coords_vente VARCHAR(255),
                vente_prix INT
            );
        ]], {}, function(affectedRows)
            MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
                TriggerClientEvent('receiveFarms', -1, farms)
            end)
        end)
    end
end)

RegisterNetEvent('addFarm')
AddEventHandler('addFarm', function(farmData)
    local src = source
    if not isAdmin(src) then
        BridgesShowNotification(src, 'Erreur : Vous n\'avez pas la permission d\'ajouter un farm.')
        return
    end

    if farmData and farmData.name and farmData.coords_recolte and farmData.coords_traitement and farmData.coords_vente and farmData.vente_prix then
        MySQL.Async.execute('INSERT INTO farms (name, nameTraitement, coords_recolte, coords_traitement, coords_vente, vente_prix) VALUES (@name, @nameTraitement, @coords_recolte, @coords_traitement, @coords_vente, @vente_prix)', {
            ['@name'] = farmData.name,
            ['@nameTraitement'] = farmData.nameTraitement,
            ['@coords_recolte'] = json.encode(farmData.coords_recolte), 
            ['@coords_traitement'] = json.encode(farmData.coords_traitement),  
            ['@coords_vente'] = json.encode(farmData.coords_vente),  
            ['@vente_prix'] = farmData.vente_prix
        }, function(rowsChanged)
            if rowsChanged > 0 then
                BridgesShowNotification(src, 'Le farm a été ajouté avec succès.')
            end
        end)
    else
        BridgesShowNotification(src, 'Erreur : Données de farm invalides.')
    end
end)

RegisterNetEvent('getAllFarms')
AddEventHandler('getAllFarms', function()
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
        for i = 1, #farms do
            farms[i].coords_recolte = json.decode(farms[i].coords_recolte)
            farms[i].coords_traitement = json.decode(farms[i].coords_traitement)
            farms[i].coords_vente = json.decode(farms[i].coords_vente)
        end
        TriggerClientEvent('receiveFarms', _source, farms)
    end)
end)

RegisterServerEvent('collectItem')
AddEventHandler('collectItem', function(farmName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("xPlayer introuvable pour le joueur ID: " .. tostring(source))
        return
    end

    if not farmName or farmName == "" then
        print("farmName est invalide ou vide")
        return
    end

    BridgesAddInventoryItem(xPlayer, farmName, 1) 
    BridgesShowNotification(source, 'Vous avez récolté 1 ' .. farmName)
end)

RegisterServerEvent('processItem')
AddEventHandler('processItem', function(farmData, farmName)
    local xPlayer = BridgesGetPlayerFromId(source)

    if farmData then
        local itemName = farmName
        local itemProcessedName = farmData.nameTraitement

        if not itemProcessedName then
            BridgesShowNotification(source, "Erreur : Données de traitement manquantes.")
            return
        end

        local itemCount = xPlayer.getInventoryItem(itemName).count

        if itemCount > 0 then
            BridgesRemoveInventoryItem(xPlayer, itemName, 1)
            BridgesAddInventoryItem(xPlayer, itemProcessedName, 1) 
            BridgesShowNotification(source, 'Vous avez traité 1 ' .. itemName .. ' et obtenu 1 ' .. itemProcessedName)
        else
            BridgesShowNotification(source, 'Vous n\'avez pas assez de ' .. itemName)
        end
    else
        BridgesShowNotification(source, 'Erreur : données de farm invalides.')
    end
end)


RegisterServerEvent('sellItem')
AddEventHandler('sellItem', function(farmData)
    local xPlayer = BridgesGetPlayerFromId(source)
    local itemProcessedName = farmData.nameTraitement
    local ventePrix = farmData.vente_prix

    if xPlayer.getInventoryItem(itemProcessedName).count > 0 then
        BridgesRemoveInventoryItem(xPlayer, itemProcessedName, 1)
        BridgesAddMoney(xPlayer, ventePrix)
        BridgesShowNotification(source, 'Vous avez vendu 1 ' .. itemProcessedName .. ' pour ' .. ventePrix .. '$')
    else
        BridgesShowNotification(source, 'Vous n\'avez pas assez de ' .. itemProcessedName)
    end
end)

RegisterNetEvent('updateFarm')
AddEventHandler('updateFarm', function(farmData)
    local src = source
    if not isAdmin(src) then
        BridgesShowNotification(src, 'Erreur : Vous n\'avez pas la permission de modifier un farm.')
        return
    end

    if farmData and farmData.id then
        MySQL.Async.execute('UPDATE farms SET name = @name, nameTraitement = @nameTraitement, coords_recolte = @coords_recolte, coords_traitement = @coords_traitement, coords_vente = @coords_vente, vente_prix = @vente_prix WHERE id = @id', {
            ['@id'] = farmData.id,
            ['@name'] = farmData.name,
            ['@nameTraitement'] = farmData.nameTraitement,
            ['@coords_recolte'] = json.encode(farmData.coords_recolte),
            ['@coords_traitement'] = json.encode(farmData.coords_traitement),
            ['@coords_vente'] = json.encode(farmData.coords_vente),
            ['@vente_prix'] = farmData.vente_prix
        }, function(rowsChanged)
            if rowsChanged > 0 then
                BridgesShowNotification(src, 'Le farm a été mis à jour avec succès.')
            else
                BridgesShowNotification(src, 'Erreur : Échec de la mise à jour du farm.')
            end
        end)
    else
        BridgesShowNotification(src, 'Erreur : Données de farm invalides.')
    end
end)

RegisterNetEvent('createItem')
AddEventHandler('createItem', function(item)
    local src = source
    if not isAdmin(src) then
        BridgesShowNotification(src, 'Erreur : Vous n\'avez pas la permission de créer un item.')
        return
    end

    if item and item.name and item.label then
        MySQL.Async.execute('INSERT INTO items (name, label) VALUES (@name, @label)', {
            ['@name'] = item.name,
            ['@label'] = item.label
        }, function(affectedRows)
            if affectedRows > 0 then
                ESX.RegisterUsableItem(item.name, function(source)
                    local xPlayer = ESX.GetPlayerFromId(source)
                    xPlayer.removeInventoryItem(item.name, 1)
                    xPlayer.showNotification("Vous avez utilisé " .. item.label)
                end)
                BridgesShowNotification(src, 'L\'item a été créé avec succès.')

                TriggerClientEvent('itemCreated', -1, { name = item.name, label = item.label })
            else
                BridgesShowNotification(src, 'Erreur : Échec de la création de l\'item.')
            end
        end)
    else
        BridgesShowNotification(src, 'Erreur : Données de l\'item invalides.')
    end
end)

RegisterNetEvent('deleteFarm')
AddEventHandler('deleteFarm', function(farmId)
    local src = source
    if not isAdmin(src) then
        BridgesShowNotification(src, 'Erreur : Vous n\'avez pas la permission de supprimer un farm.')
        return
    end

    if farmId then
        MySQL.Async.execute('DELETE FROM farms WHERE id = @id', {
            ['@id'] = farmId
        }, function(rowsChanged)
            if rowsChanged > 0 then
                BridgesShowNotification(src, 'Le farm a été supprimé avec succès.')
                MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
                    TriggerClientEvent('receiveFarms', -1, farms)
                end)
            else
                BridgesShowNotification(src, 'Erreur : Échec de la suppression du farm.')
            end
        end)
    else
        BridgesShowNotification(src, 'Erreur : ID de farm invalide.')
    end
end)