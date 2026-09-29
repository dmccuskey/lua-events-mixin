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

		it( "has createEvent and createCallback", function()
			assert( type( obj.createEvent ) == 'function' )
			assert( type( obj.createCallback ) == 'function' )
			local e = obj:createEvent( 'changed', 5 )
			assert.is.equal( obj.EVENT, e.name )
			assert.is.equal( 'changed', e.type )
		end)

	end)

end)


describe( "Module Test: version", function()

	it( "exports its version", function()
		assert.is.equal( 'string', type( EventsMixModule.__version ) )
	end)

end)


describe( "Module Test: dispatch", function()

	local obj, EVENT

	before_each( function()
		obj = patch( {} )
		EVENT = obj.EVENT
	end)

	it( "calls a function listener with the event", function()
		local got
		obj:addEventListener( EVENT, function( e ) got = e end )
		obj:dispatchEvent( 'changed', 42 )
		assert.is.equal( EVENT, got.name )
		assert.is.equal( 'changed', got.type )
		assert.is.equal( obj, got.target )
		assert.is.equal( 42, got.data )
	end)

	it( "calls an object listener's method named for the event", function()
		local listener = {}
		function listener:event_mix_event( e ) self.got = e end
		obj:addEventListener( EVENT, listener )
		obj:dispatchEvent( 'changed' )
		assert.is.equal( 'changed', listener.got.type )
	end)

	it( "merges table data into the event when asked", function()
		local got
		obj:addEventListener( EVENT, function( e ) got = e end )
		obj:dispatchEvent( 'changed', { value=3 }, { merge=true } )
		assert.is.equal( 3, got.value )
		assert.is_nil( got.data )
	end)

	it( "dispatches a raw event", function()
		local got
		obj:addEventListener( 'raw', function( e ) got = e end )
		obj:dispatchRawEvent( { name='raw', x=1 } )
		assert.is.equal( 1, got.x )
	end)

	it( "stops calling a removed listener", function()
		local count = 0
		local f = function() count = count + 1 end
		obj:addEventListener( EVENT, f )
		obj:dispatchEvent( 'changed' )
		obj:removeEventListener( EVENT, f )
		obj:dispatchEvent( 'changed' )
		assert.is.equal( 1, count )
	end)

	it( "adds a listener only once", function()
		local count = 0
		local f = function() count = count + 1 end
		obj:addEventListener( EVENT, f )
		obj:addEventListener( EVENT, f )
		obj:dispatchEvent( 'changed' )
		assert.is.equal( 1, count )
	end)

	it( "removes a listener nobody added without an error", function()
		assert.has_no.errors( function()
			obj:removeEventListener( EVENT, function() end )
		end)
		obj:addEventListener( EVENT, function() end )
		assert.has_no.errors( function()
			obj:removeEventListener( EVENT, function() end )
		end)
	end)

	it( "keeps objects with the same tostring() apart", function()
		local mt = { __tostring=function() return 'same' end }
		local a, b = setmetatable( {}, mt ), setmetatable( {}, mt )
		function a:event_mix_event() self.called = true end
		function b:event_mix_event() self.called = true end
		obj:addEventListener( EVENT, a )
		obj:addEventListener( EVENT, b )
		obj:dispatchEvent( 'changed' )
		assert.is_true( a.called )
		assert.is_true( b.called )
		obj:removeEventListener( EVENT, a )
		a.called, b.called = nil, nil
		obj:dispatchEvent( 'changed' )
		assert.is_nil( a.called )
		assert.is_true( b.called )
	end)

	it( "doesn't call a listener added during the dispatch", function()
		local count = 0
		local late = function() count = count + 1 end
		for i = 1, 20 do
			obj:addEventListener( EVENT, function()
				obj:addEventListener( EVENT, late )
			end)
		end
		obj:dispatchEvent( 'changed' )
		assert.is.equal( 0, count )
		obj:dispatchEvent( 'changed' )
		assert.is.equal( 1, count )
	end)

	it( "doesn't call a listener removed during the dispatch", function()
		local called = {}
		local fs = {}
		for i = 1, 20 do
			fs[i] = function()
				called[i] = true
				for j = 1, 20 do
					if j ~= i then obj:removeEventListener( EVENT, fs[j] ) end
				end
			end
			obj:addEventListener( EVENT, fs[i] )
		end
		obj:dispatchEvent( 'changed' )
		local count = 0
		for _ in pairs( called ) do count = count + 1 end
		assert.is.equal( 1, count )
	end)

	it( "prints each dispatch when debug is on", function()
		local lines = {}
		local _print = _G.print
		_G.print = function( ... ) lines[#lines+1] = table.concat( { ... }, ' ' ) end
		obj:setDebug( true )
		obj:dispatchEvent( 'changed' )
		obj:setDebug( false )
		obj:dispatchEvent( 'changed' )
		_G.print = _print
		assert.is.equal( 1, #lines )
		assert.truthy( lines[1]:find( EVENT, 1, true ) )
	end)

end)


