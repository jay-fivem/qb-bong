fx_version 'bodacious'
game 'gta5'
lua54 'yes'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_script 'client/main.lua'
shared_script 'config.lua'
