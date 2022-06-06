local second = 1000
local minute = 60 * second

EarlyRespawnTimer          = 8 * minute -- Temps avant respawn (En étant Coma)

Config = {
    Locale                     = 'fr',
    RespawnPoint = { coords = vector3(-808.56, -1224.44, 7.33), heading = 231.06 }, -- L'endroit ou tu respawn après la mort
    BleedoutTimer              = 10 * minute, 
    ReviveReward               = 150,
    AntiCombatLog              = true,
    EarlyRespawnFine           = false, 
    EarlyRespawnFineAmount     = 5000, 
    GcPhone = false,
	
    VehiculeEMS = { 
    	{buttoname = "Ambulance", rightlabel = "→", spawnname = "ambulance", spawnzone = vector3(-852.17, -1224.46, 6.56), headingspawn = 330.14},

    },

    HelicoEMS = { 
    	{buttonameheli = "Hélicoptère", rightlabel = "→", spawnnameheli = "supervolito", spawnzoneheli = vector3(-842.41, -1244.82, 14.83), headingspawnheli = 53.01},
    },

    Pharmacie = {
        {Nom = "Medikit", Item = "medikit"},
        {Nom = "Bandage", Item = "bandage"},
    },

    Position = {
    	    Boss = {vector3(-784.97, -1245.10, 7.33)},
    	    Coffre = {vector3(-820.23, -1242.52, 7.33)},
            Pharmacie = {vector3(-802.78, -1209.02, 7.33)},
            Vestaire = {vector3(-826.11, -1236.89, 7.33)}, 
            GarageVehicule = {vector3(-852.17, -1224.46, 6.56)},
    	    GarageHeli = {vector3(-842.41, -1244.82, 14.83)},
            Blips = {x = -822.08, y = -1223.47, z = 7.33},
        }
    }

    AmbuCloak = {
    	clothes = {
            grades = {
                [0] = {
                    label = "Tenue Personnel",
                    minimum_grade = 0,
                    variations = {male = {}, female = {}},
                    onEquip = function()
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin) TriggerEvent('skinchanger:loadSkin', skin) end)
                        SetPedArmour(PlayerPedId(), 0)
                    end
                },
                [1] = {
                    label = "Tenue d'Ambulancier",
                    minimum_grade = 0,
                    variations = {
                    male = {
                        bags_1 = 0, bags_2 = 0,
                        tshirt_1 = 129, tshirt_2 = 0,
                        torso_1 = 75, torso_2 = 6,
                        arms = 86,
                        pants_1 = 33, pants_2 = 0,
                        shoes_1 = 25, shoes_2 = 0,
                        mask_1 = 0, mask_2 = 0,
                        bproof_1 = 14, bproof_2 = 0,
                        helmet_1 = -1, helmet_2 = 0,
                        chain_1 = 0, chain_2 = 0,
                        decals_1 = 0, decals_2 = 0,
                    },
                    female = {
                        bags_1 = 0, bags_2 = 0,
                        tshirt_1 = 129, tshirt_2 = 0,
                        torso_1 = 75, torso_2 = 6,
                        arms = 86,
                        pants_1 = 33, pants_2 = 0,
                        shoes_1 = 25, shoes_2 = 0,
                        mask_1 = 0, mask_2 = 0,
                        bproof_1 = 14, bproof_2 = 0,
                        helmet_1 = -1, helmet_2 = 0,
                        chain_1 = 0, chain_2 = 0,
                        decals_1 = 0, decals_2 = 0
                    }
                },
                onEquip = function()
                end
            },
                [2] = {
                    minimum_grade = 0,
                    label = "Tenue Médecin",
                    variations = {
                    male = {
                        tshirt_1 = 59,  tshirt_2 = 1,
                        torso_1 = 55,   torso_2 = 0,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 41,
                        pants_1 = 25,   pants_2 = 0,
                        shoes_1 = 25,   shoes_2 = 0,
                        helmet_1 = 46,  helmet_2 = 0,
                        chain_1 = 0,    chain_2 = 0,
                        ears_1 = 2,     ears_2 = 0
                    },
                    female = {
                        tshirt_1 = 36,  tshirt_2 = 1,
                        torso_1 = 48,   torso_2 = 0,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 44,
                        pants_1 = 34,   pants_2 = 0,
                        shoes_1 = 27,   shoes_2 = 0,
                        helmet_1 = 45,  helmet_2 = 0,
                        chain_1 = 0,    chain_2 = 0,
                        ears_1 = 2,     ears_2 = 0
                    }
                },
                onEquip = function()
                end
            },
                [3] = {
                    minimum_grade = 0,
                    label = "Tenue d'Opération",
                    variations = {
                    male = {
                        tshirt_1 = 46,  tshirt_2 = 0,
                        torso_1 = 29,   torso_2 = 5,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 6,
                        pants_1 = 8,   pants_2 = 14,
                        shoes_1 = 8,   shoes_2 = 0,
                        helmet_1 = -1,  helmet_2 = 0,
                        chain_1 = 34,    chain_2 = 2,
                        ears_1 = 0,     ears_2 = 0
                    },
                    female = {
                        tshirt_1 = 36,  tshirt_2 = 1,
                        torso_1 = 48,   torso_2 = 0,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 44,
                        pants_1 = 34,   pants_2 = 0,
                        shoes_1 = 27,   shoes_2 = 0,
                        helmet_1 = 45,  helmet_2 = 0,
                        chain_1 = 0,    chain_2 = 0,
                        ears_1 = 2,     ears_2 = 0
                    }
                },
                onEquip = function()
                end
            },
                [4] = {
                    minimum_grade = 3,
                    label = "Tenue de Directeur",
                    variations = {
                    male = {
                        tshirt_1 = 46,  tshirt_2 = 0,
                        torso_1 = 29,   torso_2 = 5,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 6,
                        pants_1 = 8,   pants_2 = 14,
                        shoes_1 = 8,   shoes_2 = 0,
                        helmet_1 = -1,  helmet_2 = 0,
                        chain_1 = 34,    chain_2 = 2,
                        ears_1 = 0,     ears_2 = 0
                    },
                    female = {
                        tshirt_1 = 36,  tshirt_2 = 1,
                        torso_1 = 48,   torso_2 = 0,
                        decals_1 = 0,   decals_2 = 0,
                        arms = 44,
                        pants_1 = 34,   pants_2 = 0,
                        shoes_1 = 27,   shoes_2 = 0,
                        helmet_1 = 45,  helmet_2 = 0,
                        chain_1 = 0,    chain_2 = 0,
                        ears_1 = 2,     ears_2 = 0
                    }
                },
                onEquip = function()
                end
            },
        }
    }
}
