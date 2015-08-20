Available API Commands
======================

API Commands are organized hierachically, grouped together into sections.  Commands will not work outside of their parent section.

Note that this reference is not guaranteed to be up to date.  Information is pulled from [their wiki summary of the API][ch wiki] and their [PHP example][php example], as well as from poking their LitePanel.  If things in reality are not as they seem here, you may have to search for the most up to date documentation via CreeperHost's docs or via your favourite search engine.



General Structure of API Responses
----------------------------------

Assuming no network or API-server errors occur, you will receive a JSON response.  All responses from the Aries API server have a base response which more detailed responses extend.  That base response has only one property that is always present.

- `status` String indicating the whether or not the API command itself succeeded.  Can have one of two values: `"success"` or `"error"`.

The base response has an additional property if the `status` is `"error"`:

- `message` String with the error message.

An example of a successful API response.  The command here was `minecraft/readconsole`.

```json
{
	"status": "success",
	"log": "[09:25:03] [Info] Starting minecraft server version 1.7.10\n[09:27:02] ..."
}
```

An example of an API error responses.

```json
{
	"status": "error",
	"message": "Invalid API Keys."
}
```


Commands
--------

- Section `minecraft` (also usable as `mc`)
	- Command `readconsole` reads the current console log of the Minecraft Server.
		- Data object can have the following properties:
			- `lines` Optional Number indicating the number of lines that should be returned.  Default value is `500`.
			- `format` Boolean indicating whether or not to format the text.
			- `debug` Number indicating ... something.  `1` is true, `0` is false.
		- Additional properties on success response:
			- `log` String with the current Minecraft Server Console log, containing the last 500 or less lines.
			- `count` Number indicating how many lines `log` contains
			- `debug` No idea, but usually `0`.
	- Command `writeconsole` sends a command to the Minecraft Server's console.
		- Data object can have the following properties:
			- `command` String with the command line to execute.  Commands do not have slashes in the server console because you can't say things without explicitly using the `say` server command.
		- **No** Additional properties on success response.
	- Command `startserver`
		- Data object takes no additional properties for this command.
		- **No** Additional properties on success response.  A success indicates that the server was launched without error and is in the process of loading.
	- Command `restartserver`
		- Data object takes no additional properties for this command.
		- **No** Additional properties on success response.  A success indicates that the server may have been shut down, but was definitely launched without error and is in the process of loading.
	- Command `stopserver`
		- Data object takes no additional properties for this command.
		- **No** Additional properties on success response.  A success indicates that the server was shut down without issue.
- Section `os`
	- Command `getram`
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- `free` Number indicating how much RAM is currently free.
			- `used` Number indicating how much RAM is currently in use.  Add to `free` to get the total.
	- Command `getcpu`
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- `free` Number indicating relatively how much CPU time is currently free.
			- `used` Number indicating relatively how much CPU time is currently in use.  Add to `free` to get the total.
	- Command `gethdd`
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- `free` Number indicating how much HDD space is currently free.
			- `used` Number indicating how much HDD space is currently in use.  Add to `free` to get the total.
	- Command `getConfig` gets miscellaneous CH related config attached to this instance.  Note that this is mostly for internal use and isn't so useful outside of CH.  Use of `getConfig`/`setConfig` is doable, but does not seem openly supported as of writing, and use is not recommended.
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- `config` Array of Objects, each of which has the following properties:
				- `key` String with a key used identify a config entry.
				- `value` A value of probably any type that is stored at the given `key`.
	- Command `setConfig` sets a config value.  Note that this is mostly for internal use and isn't so useful outside of CH.  Use of `getConfig`/`setConfig` is doable, but does not seem openly supported as of writing, and use is not recommended.
		- Data object takes the following additional properties:
			- `key` String key used to identify this config entry.  Should be namespaced using colons, EG `litepanel:option` or `narfpanel:foo`, `narfpanel:bar`, etc.
		- **No** Additional properties on success response.
	- Command `listservices` gets a list of services which are currently active.
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- `services` Object whose properties represent services that are active. (Or inactive?)  Each has at least the following properties:
				- `active` Boolean indicating the service is active (`true`) or inactive. (`false`)
- Section `billing` (Note: Currently the only real info I found on this section is in their [PHP example][php example].  It may be that this section is in flux, more so than the others.)
	- Command `spinupMinigame` tries to download (using wget) and subsequently start up a minigame you specify on CreeperHost's cloud.
		- Data object can have the following properties:
			- `game` String indicating what game type this is.  In this case, it's (always?) `"custom"`.
			- `ram` Number indicating how many gigabytes of ram to allot to the game.
			- `time` Number indicating how many hours the game should be run for.
			- `custom` String, a URL to a minigame zip archive that can be downloaded using wget.
			- `callback` Optional string, an URL accessible via plain HTTP that CreeperHost's API will send a request to with the UUID if the minigame is successfully started.  the UUID is appended to the end of the string provided, so if you pass `http://example.com/game-started?uuid=` CreeperHost's API will try to send a request to `http://example.com/game-started?uuid={UUID_HERE}`.  Note it does not matter if it is a URL with `uuid` param at the end or anything else, the UUID will be appended to the end regardless.
		- Additional properties on success response:
			- `uuid` String containing the UUID of the minigame that was spun up.  This is used for adding time extensions and for spinning down the game when you're done with it.
			- ..?
	- Command `spindownMinigame` Stops the specified minigame, causing a partial refund for how much time was not used.
		- Data object can have the following properties:
			- `uuid` String containing the UUID returned by the `spinupMinigame` command.
		- Additional properties on success response:
			- ..?
	- Command `extendMinigame` Adds another hour to the specified minigame's time.
		- Data object can have the following properties:
			- `uuid` String containing the UUID returned by the `spinupMinigame` command.
		- Additional properties on success response:
			- ..?
	- Command `timerMinigame` Gets the seconds of run time remaining for the specified minigame.
		- Data object can have the following properties:
			- `uuid` String containing the UUID returned by the `spinupMinigame` command.
		- Additional properties on success response:
			- ..? (A number indicating how many seconds of run time the minigame has left.  Property name?)
	- Command `listMinigames` Lists the minigames you currently have active, if any.
		- Data object takes no additional properties for this command.
		- Additional properties on success response:
			- ..? (Presumably a list of games running, or empty list if you have no games running)
	- Command `spinupProxy`
		- ... (similar to `spinupMinigame` but for a proxy.)
	- Command `spindownProxy`
		- ... (similar to `spindownMinigame` but for a proxy.)
	- Command `extendProxy`
		- ... (similar to `extendMinigame` but for a proxy.)
	- Command `timerProxy`
		- ... (similar to `timerMinigame` but for a proxy.)
	- Command `listProxies`
		- ... (similar to `listMinigame` but for a proxy.)



[php example]: https://cp.creeperhost.net/Aries/
[ch wiki]: http://wiki.creeperlabs.com/index.php/ElasticCreeper_API
