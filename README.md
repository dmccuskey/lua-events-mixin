## lua-events-mixin ##

Add event capability to your Lua objects (event dispatch/listeners)


This module can add Event capability to any of your objects. It can be used either as a mixin class or monkey-patching your object. It was designed to work with [lua-objects](https://github.com/dmccuskey/dmc-objects). It has been integrated in [dmc-objects](https://github.com/dmccuskey/dmc-objects) as a mixin. 


### Features ###

* addEventListener
* removeEventListener
* dipatchEvent
* custom events
* unit tested


#### Examples ####

The project [dmc-objects](https://github.com/dmccuskey/dmc-objects) contains the `ObjectBase` sub-class which shows how to use this module as a mixin with multiple inheritance.


### Monkey Patching ###


```lua
--== Import module

local EventsMixModule = require 'dmc_lua.lua_events_mix'


--== Setup aliases, cleaner code

local EventsMix = EventsMixModule.EventsMix



--== Patch an object ==--

-- create one for yourself (eg, with OOP library)

local obj = {}  -- empty or create one from your OOP library
obj = EventsMix.patch( obj ) -- returns object


-- or have patch() create one for you

local obj = EventsMix.patch()  -- returns a new object



--== Methods

-- obj.EVENT is automatically added. can be changed
--
obj:addEventListener( obj.EVENT, callback )
obj:removeEventListener( obj.EVENT, callback )

obj.EVENT_NAME = 'my_custom_event_name' -- add this
obj:dispatchEvent( obj.EVENT_NAME, data )



--== Misc Methods

-- set a function to turn on/off debug output (per object)
obj:setDebug( boolean )

-- set a function to create custom events
obj:setEventFunc( func )


```

