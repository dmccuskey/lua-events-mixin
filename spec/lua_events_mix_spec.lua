--====================================================================--
-- spec/lua_events_mix_spec.lua
--
-- Testing for lua-events-mixin using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
--== Test: Lua Events Mix
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local EventsMixModule = require 'lua_events_mix'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local EventsMix = EventsMixModule.EventsMix
local patch = EventsMixModule.patch
local dmcEventFunc = EventsMixModule.dmcEventFunc



--====================================================================--
--== Testing Setup
--====================================================================--


describe( "Module Test: test inheritance", function()

	local obj

	before_each( function()

		obj = {}

		local mt = {
			__index = EventsMix,
		}
		setmetatable( obj, mt )

		EventsMix.__init__( obj )

	end)

	after_each( function()
		obj = nil
	end)


	describe( "Test: check inherited elements", function()

		it( "has event properties", function()
			assert( type( obj.__event_listeners ) == 'table' )
			assert( type( obj.__debug_on ) == 'boolean' )
		end)

		it( "has event methods", function()
			assert( type( obj.setDebug ) == 'function' )

			assert( type( obj.addEventListener ) == 'function' )
			assert( type( obj.dispatchEvent ) == 'function' )
			assert( type( obj.removeEventListener ) == 'function' )
		end)

		it( "can set debug flag", function()
			obj:setDebug( true )
			assert( obj.__debug_on == true )

			obj:setDebug( false )
			assert( obj.__debug_on == false )
		end)

		it( "can set debug flag", function()
			assert( obj.__event_func == dmcEventFunc )

			local f = function() end
			obj:setEventFunc( f )
			assert( obj.__event_func == f )
		end)

	end)

end)


describe( "Module Test: test patch function", function()

	local obj

	before_each( function()
		obj = {}
		patch( obj )
	end)

	after_each( function()
		obj = nil
	end)


	describe( "Test: check patched elements", function()

		it( "has event properties", function()
			assert( type( obj.__event_listeners ) == 'table' )
			assert( type( obj.__debug_on ) == 'boolean' )
		end)

		it( "has event methods", function()
			assert( type( obj.setDebug ) == 'function' )

			assert( type( obj.addEventListener ) == 'function' )
			assert( type( obj.dispatchEvent ) == 'function' )
			assert( type( obj.removeEventListener ) == 'function' )
		end)

		it( "can set debug flag", function()
			obj:setDebug( true )
			assert( obj.__debug_on == true )

			obj:setDebug( false )
			assert( obj.__debug_on == false )
		end)

	end)

end)


