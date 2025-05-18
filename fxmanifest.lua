fx_version 'adamant'
games { 'rdr3' }
author 'Heros & afoolasfallen'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependency 'rsg-core'
dependency 'ox_lib'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua',
    'config.lua'
}

server_scripts {
    'server.lua',
    'config.lua'
}
