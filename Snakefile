# lua-events-mixin

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-events-mixin"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-events-mixin",
	"module": {
		"files": [
				"lua_events_mix.lua"
		],
		"requires": [
		]
	},
	"tests": {
		"files": [
		],
		"requires": [
		]
	}
}

register( "lua-events-mixin", module_config )

