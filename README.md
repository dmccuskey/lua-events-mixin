# lua-events-mixin

Give any Lua object `addEventListener()`, `removeEventListener()` and `dispatchEvent()`, in the style of Solar2D (formerly Corona SDK) display objects.

Add it to an object in one call, or mix it into a class. It was written for the DMC Solar2D libraries (it's the event half of [lua-objects](https://github.com/dmccuskey/lua-objects)' `ObjectBase`), but it's plain Lua 5.1 and runs anywhere:

```lua
local EventsMixModule = require 'lua_events_mix'

local obj = EventsMixModule.patch()
obj:addEventListener( obj.EVENT, function( event ) print( event.type ) end )
obj:dispatchEvent( 'ready' )  --> ready
```

## Features

- Listeners are functions, or objects with a method named after the event
- Events carry a `type`, the sending object and your data, or are any table you build
- Patch an existing object, or use the mixin as a parent class (lua-objects, or a plain metatable)
- Pure Lua 5.1, one file, no dependencies; MIT licensed

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will make an object that sends events and listen to them.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-events-mixin.git
```

The module is `lua-events-mixin/dmc_lua/lua_events_mix.lua`.

### 2. Use It

Create `main.lua` in the same folder:

```lua
package.path = './lua-events-mixin/dmc_lua/?.lua;' .. package.path
local EventsMixModule = require 'lua_events_mix'

local downloader = EventsMixModule.patch()
downloader.EVENT = 'downloader_event'
downloader.PROGRESS = 'progress'
downloader.DONE = 'done'

local function onDownload( event )
	if event.type == downloader.PROGRESS then
		print( "progress", event.data.percent )
	elseif event.type == downloader.DONE then
		print( "done", event.target == downloader )
	end
end

downloader:addEventListener( downloader.EVENT, onDownload )

downloader:dispatchEvent( downloader.PROGRESS, { percent=50 } )
downloader:dispatchEvent( downloader.DONE )

downloader:removeEventListener( downloader.EVENT, onDownload )
downloader:dispatchEvent( downloader.DONE )  -- no listener, nothing printed
```

Run it:

```sh
lua main.lua
```

```text
progress	50
done	true
```

If it shows `module 'lua_events_mix' not found`, run it from the folder that holds `lua-events-mixin/`.

To update, pull the repository again (`git -C lua-events-mixin pull`).

## How Events Work

An object sends every event under one name, its `EVENT` property (`'event_mix_event'` unless you set it), and tells events apart by their `type`. You listen to the name and check the type, as `onDownload()` does above. The event table that `dispatchEvent( type, data )` builds is:

| field | holds |
|---|---|
| `name` | the object's `EVENT` |
| `type` | the first argument of `dispatchEvent()` |
| `target` | the object that sent it |
| `data` | the second argument |

With `dispatchEvent( type, data, { merge=true } )` and a table as `data`, the event is `data` itself, with `name`, `type` and `target` set on it (the table is changed).

A listener is a function, called as `listener( event )`, or an object (table) with a method named after the event, called as `listener:<name>( event )`:

```lua
local display = {}
function display:downloader_event( event ) print( "display got", event.type ) end
downloader:addEventListener( downloader.EVENT, display )
```

To send events of your own shape, set an event function with `setEventFunc()`, or send a table you built with `dispatchRawEvent()`. The module's `coronaEventFunc` passes its argument through unchanged, so after `setEventFunc( EventsMixModule.coronaEventFunc )`, `dispatchEvent( { name='tap', x=5 } )` works as in Solar2D.

## Reference

### The Module

| member | is |
|---|---|
| `patch( [obj] )` | Adds the event properties and methods to `obj` (or a new table) and returns it. Keeps `obj.EVENT` if it's set. |
| `EventsMix` | The mixin: a table of the methods, to use as a parent class (below). |
| `dmcEventFunc` | The default event function: builds the table above. |
| `coronaEventFunc` | An event function that returns its argument as the event. |

### Methods

On a patched object, or an instance of a class that mixes in `EventsMix`:

| method | does |
|---|---|
| `addEventListener( name, listener )` | Adds a function or object listener for events named `name`. Adding the same one twice prints a warning and keeps one. |
| `removeEventListener( name, listener )` | Removes it. Prints a warning when it isn't there. |
| `dispatchEvent( ... )` | Builds an event with the event function (by default from `( type, data, params )`, above) and calls the listeners for its `name`. |
| `dispatchRawEvent( event )` | Calls the listeners for `event.name` with `event` as is. It must be a table with a `name`. |
| `setEventFunc( func )` | Sets the event function, called as `func( obj, ... )` with `dispatchEvent()`'s arguments. |
| `setDebug( bool )` | Stores a debug flag; nothing reads it. |
| `createEvent( ... )` | Mixin only: returns the event `dispatchEvent( ... )` would send. |
| `createCallback( method )` | Mixin only: returns a function that calls `method( obj, ... )`. |

Listeners are called in no set order.

### As a Mixin

`EventsMix` holds the methods and `EVENT`; its `__init__( self, params )` sets up an object's listener list, and `__undoInit__( self )` clears it. `params.event_func` sets the event function. With lua-objects (lua-class), mix it in with multiple inheritance, as `ObjectBase` does:

```lua
local ObjectBase = newClass( { Class, EventsMix } )

function ObjectBase:__init__( ... )
	self:superCall( EventsMix, '__init__', ... )
end

function ObjectBase:__undoInit__()
	self:superCall( EventsMix, '__undoInit__' )
end
```

Without a class library, inherit from `EventsMix` with a metatable and call `__init__` for each object:

```lua
local EventsMix = EventsMixModule.EventsMix

local obj = setmetatable( {}, { __index=EventsMix } )
EventsMix.__init__( obj )
```

## In Solar2D

[dmc-events-mixin](https://github.com/dmccuskey/dmc-events-mixin) is the Solar2D package of this module. The DMC Solar2D libraries load it as `lib.dmc_lua.lua_events_mix` from their `dmc_corona/lib/dmc_lua/` folder, part of [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library); most use it through the objects of [dmc-objects](https://github.com/dmccuskey/dmc-objects).

## Known Issues

- **`removeEventListener()` errors when nothing listens to that name**: after the warning `no listeners found` it raises `attempt to index local 'listeners' (a nil value)`.
- A patched object gets neither `createEvent()` nor `createCallback()`.
- A listener added from inside a listener, during a dispatch, may or may not be called in that dispatch (Lua leaves adding keys during `pairs()` undefined).
- An object listener without the event's method is skipped with `WARNING: Events dispatchEvent <name>`.
- Listeners are keyed by `tostring( listener )`, so objects whose `__tostring` returns the same string replace each other.
- `setDebug()` does nothing. `addEventListener()` has a second, unreachable check that calls a missing `Utils.propertyIn`.
- The version, `0.2.2`, isn't exported: it's a local in the file.

## Development

Only `dmc_lua/lua_events_mix.lua` is written here. [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers it), and the DMC Solar2D libraries copy it from there into `dmc_corona/lib/dmc_lua/`.

The tests are in `spec/lua_events_mix_spec.lua`, for [busted](https://lunarmodules.github.io/busted/) under Lua 5.1. From the repository's root folder:

```sh
busted spec
```

It ends with:

```text
7 successes / 0 failures / 0 errors / 0 pending : 0.001437 seconds
```

The tests check that the mixin and `patch()` add the methods and properties, not that events reach listeners.

## License

lua-events-mixin is released under the [MIT License](LICENSE).
