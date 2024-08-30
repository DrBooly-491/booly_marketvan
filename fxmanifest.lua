fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DrBooly'
description 'Blackmarket Van Script for mythic framework'
version '1.0.0'

client_scripts {
    'client/cl_main.lua',
    'client/component.lua',
}

server_scripts {
    'server/sv_main.lua',
    'server/component.lua',
}

shared_scripts {
    'config.lua',
    'utils.lua'
}
