fx_version 'cerulean'
games { 'gta5' };

shared_scripts {
    "config.lua",
}

client_scripts {
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/fr.lua',
    'client.lua'
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/fr.lua',
    'server.lua'
}