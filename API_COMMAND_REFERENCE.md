Available API Commands
======================

API Commands are organized hierachically, grouped together into sections.  Commands will not work outside of their parent section.

Note that this reference is not guaranteed to be up to date.  Information is pulled from [their wiki summary of the API][ch wiki] and their [PHP example][php example], as well as from poking their LitePanel.  If things in reality are not as they seem here, you may have to search for the most up to date documentation via CreeperHost's docs or via your favourite search engine.



General Structure of API Responses
----------------------------------

Assuming no network or API-server errors occur, you will receive a JSON response.  All responses from the Aries API server have a base response which more detailed responses extend.  That base response has only a few properties that are always present.

- `status` String indicating the whether or not the API command itself succeeded.  Can have one of two values: `"success"` or `"error"`.
- `endPoint` String naming which physical API endpoint was connected to.

The base response has an additional property if the `status` is `"error"`:

- `message` String with the error message.

An example of a successful API response.  The command here was `minecraft/readconsole`.

```json
{
	"status": "success",
	"log": "[09:25:03] [Info] Starting minecraft server version 1.7.10\n[09:27:02] ...",
	"endPoint": "atlanta-api"
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

> Commands are listed here in `<section>/<command>` form.  To call `minecraft/readconsole`, use `api.exec( 'minecraft', 'console', ... );`.

- `minecraft/readconsole`
	- Parameters
		- `lines` Optional Number indicating the number of lines that should be returned.  Default value is `500`.
		- `format` Boolean indicating whether or not to format the text, `true` indicating the inclusion of HTML formatting, `false` indicating just raw text.  Default is `false`.
		- `debug` Number indicating ... something.  `1` is true, `0` is false.
	- Response Values on Success
		- `log` String with the current Minecraft Server Console log, containing the last 500 or less lines.
		- `count` Number indicating how many lines `log` contains
		- `debug` No idea, but usually `0`.
- `minecraft/writeconsole`
	- Parameters
		- `command` String with the command line to execute.  Commands do not have slashes in the server console because you can't say things without explicitly using the `say` server command.
	- No additional response values on Success.
- `minecraft/players`
	- No additional parameters.
	- Response Values on Success
		- `method` String indicating the method used to determine the current player list.  Usually `"logScrape"`.
		- `players` Array of Objects with the following properties:
			- `name` The name of the player!
			- `minecraftId` This has been blank every time I've seen it.  Perhaps I just don't have a minecraftId, or else it's obselete.
			- `style` No idea.
- `minecraft/startserver`
	- No additional parameters, nor additional response values on success.
- `minecraft/stopserver`
	- No additional parameters, nor additional response values on success.
- `minecraft/restartserver`
	- No additional parameters, nor additional response values on success.
- `os/getram`
	- No additional parameters.
	- Response Values on Success
		- `free` String or Number, the amount of RAM still free, expressed in megabytes.
		- `used` String or Number, the amount of RAM currently used, expressed in megabytes.
- `os/gethdd`
	- No additional parameters.
	- Response Values on Success
		- `free` String or Number, the amount of HD Space still free, expressed in kilobytes.
		- `used` String or Number, the amount of HD Space currently used, expressed in kilobytes.
- `os/getcpu`
	- No additional parameters.
	- Response Values on Success
		- `free` String or Number, the amount of CPU clock still free, expressed as a percentage value. (value out of 100)
		- `used` String or Number, the amount of CPU clock currently used, expressed as a percentage value. (value out of 100)
- `os/listservices` Gets a list of services which are currently active.
	- No additional parameters.
	- Response Values on Success
		- `services` Object whose properties each represent a service, the property name being that service's ID.  For instance, to get the `csgo` service's info, you'd access `response.services.csgo`.  Each such service object has the following properties:
			- `id` The id of this service; the same as the property name it's attached to on the `services` value.
			- `active` Boolean indicating whether or not the service is currently active on your account.
			- `Icon` (uppercase `I`) data-URI with the icon image for that service.
			- `displayDescriptios` String with a description of the service.
			- `displayName` String with the name of the service.
			- `displayVersion` String with the version of the service.  Typical values include `"Release"`, `"Beta"`, and so on.
			- `installCount` String of a number which might indicate how many instances are globally installed.
			- `purchaseUrl` Optional String probably indicating the URL at which the user may purchase this service.  `null` in all responses I've so far seen, though.
			- `requireWipe` Boolean indicating whether activation of this service would require wiping ... something.
			- `updateTime` String with a date indicating when this service was last updated. (what aspect I don't know.)
- `billing/spinupMinigame`
	- Parameters
		- `game` String indicating what game type this is.  In this case, it's (always?) `"custom"`.
		- `ram` Number indicating how many gigabytes of ram to allot to the game.
		- `time` Number indicating how many hours the game should be run for.
		- `custom` String, a URL to a minigame zip archive that can be downloaded using wget.
		- `callback` Optional string, an URL accessible via plain HTTP that CreeperHost's API will send a request to with the UUID if the minigame is successfully started.  the UUID is appended to the end of the string provided, so if you pass `http://example.com/game-started?uuid=` CreeperHost's API will try to send a request to `http://example.com/game-started?uuid={UUID_HERE}`.  Note it does not matter if it is a URL with `uuid` param at the end or anything else, the UUID will be appended to the end regardless.
	- Response Values on Success
		- `uuid` String containing the UUID of the minigame that was spun up.  This is used for adding time extensions and for spinning down the game when you're done with it.
		- Possibly others...
- `billing/spindownMinigame`
	- Parameters
		- `uuid` String containing the UUID returned by the `spinupMinigame` command.
	- Response Values on Success
		- ?
- `billing/extendMinigame`
	- Parameters
		- `uuid` String containing the UUID returned by the `spinupMinigame` command.
	- Response Values on Success
		- ?
- `billing/timerMinigame`
	- Parameters
		- `uuid` String containing the UUID returned by the `spinupMinigame` command.
	- Response Values on Success
		- (property name?) Number or String indicating how many seconds of run time nemain on this minigame.
- `billing/listMinigames`
	- Parameters
		- `uuid` String containing the UUID returned by the `spinupMinigame` command.
	- Response Values on Success
		- ..? (Presumably a list of games running, or empty list if you have no games running)
- `billing/spinupProxy`
	- ... (similar to `spinupMinigame` but for a proxy of some sort.)
- `billing/spindownProxy`
	- ... (similar to `spindownMinigame` but for a proxy of some sort.)
- `billing/extendProxy`
	- ... (similar to `extendMinigame` but for a proxy of some sort.)
- `billing/timerProxy`
	- ... (similar to `timerMinigame` but for a proxy of some sort.)
- `billing/listProxies`
	- ... (similar to `listMinigame` but for a proxy of some sort.)




Undocumented Commands
---------------------

Use of these commands was observed in CreeperHost's own panel.  Use at your own risk.  (Risk can include messing up your CH account or causing things they cannot/will not help you with!)

- `minecraft/currentinstance` gets the MC instance which all `minecraft/` scoped API comands will refer to.
	- No additional parameters.
	- Response Values on Success
		- Note: does not have `status` property.  Curious.
		- `argType` String indicating something, probably the desired server performance tuning.  Usually `"balanced"`.
		- `displayName` String indicating the name to show to the User.
		- `id` String indicating the id of this instance.
		- `jar` String indicating ... something about the Minecraft server JAR.  Usually `"Auto-Detect"`.
		- `memory` String indicating how to budget the memory this instance can use.  Usually `"adaptive"`.
		- `path` String indicating where on your VM the server is located.  The default instance that CreeperHost initially creates has a path of `/home/minecraft/`.
		- `port` Optional String or Number indicating what port number the MC server is using, if different from the default.  Default is `null`.
- `minecraft/listinstance`
	- No additional parameters.
	- Response Values on Success
		- `age` Number indicating the age of something.
		- `instances` Array of Objects with the following properties:
			- `id` String with the id of the instance.
			- `displayName` String with the name to show the user.
			- `jar` String indicating something about the JAR.  Usually `"Auto-Detect"`.
			- `memory` String indicating how to budget memory for this instance.  Default is probably `"adaptive"`, but in such cases it may end up coming as `null'.
			- `path` String indicating where on your VM the server is located.  The default instance that CreeperHost initially creates has a path of `/home/minecraft/`.
			- `port` Optional String or Number indicating what port number the MC server is using, if different from the default.  Default is `null`.
- `minecraft/setinstance`
	- Parameters
		- `id` String with the id of the desired instance to inspect.
	- Response Values on Success
		- `instance` Object with the following properties:
			- `id` String with the id of the instance.
			- `displayName` String with the name to show the user.
			- `jar` String indicating something about the JAR.  Usually `"Auto-Detect"`.
			- `memory` String indicating how to budget memory for this instance.  Default is probably `"adaptive"`, but in such cases it may end up coming as `null'.
			- `path` String indicating where on your VM the server is located.  The default instance that CreeperHost initially creates has a path of `/home/minecraft/`.
			- `port` Optional String or Number indicating what port number the MC server is using, if different from the default.  Default is `null`.
- `os/getConfig` gets miscellaneous CreeperHost related configuration.  Use of this command is not recommended.
	- No additional parameters.
	- Response Values on Success
		- `config` Array of Objects with the following properties
			- `key` String key used to identify a config entry.
			- `value` Value of any type for a given config entry.
- `os/setConfig` sets a single miscellaneous CreeperHost related configuration option.  Use of this command is not recommended; any configuration you wish to store for your app should be stored on your server, in the user's browser, or otherwise not at CreeperHost.
	- Parameters
		- `key` String key used to identify a config entry.
		- `value` Value of any type for a given config entry.
	- No additional response values on Success.
- `os/availableservices` Gets a list of available services you can activate on your CH account, including icons for them.
	- No additional parameters.
	- Response Values on Success
		- `services` Object whose properties each represent a service, the property name being that service's ID.  For instance, to get the `csgo` service's info, you'd access `response.services.csgo`.  Each such service object has the following properties:
			- `id` The id of this service; the same as the property name it's attached to on the `services` value.
			- `Icon` (uppercase `I`) data-URI with the icon image for that service.
			- `displayDescriptios` String with a description of the service.
			- `displayName` String with the name of the service.
			- `displayVersion` String with the version of the service.  Typical values include `"Release"`, `"Beta"`, and so on.
			- `installCount` String of a number which might indicate how many instances are globally installed.
			- `purchaseUrl` Optional String probably indicating the URL at which the user may purchase this service.  `null` in all responses I've so far seen, though.
			- `requireWipe` Boolean indicating whether activation of this service would require wiping ... something.
			- `updateTime` String with a date indicating when this service was last updated. (what aspect I don't know.)
- `api/alerts` retrieves a list of current alerts to show to the user.
	- No additional parameters.
	- Response Values on Success
		- `alerts` Array of Objects with the following properties
			- (unknown)
- `mc/countrunning` Counts the number of running minecraft instances.
	- No additional parameters.
	- Response Values on Success
		- `count` Number indicating how many instances are running.
- `chat/readconsole` Reads the current CreeperHost Chat Log.
	- Parameters
		- `lines` Number indicating the number of lines to fetch.
		- `format` Boolean indicating whether or not HTML formatting tags should be included.
		- `debug` Number indicating whether or not to include debug information.  `1` for yes, `0` for no.
	- Response Values on Success
		- `count` Actual number of lines returned, not necessarily the same as the `lines` parameter.
		- `log` String with the current chat log.

[php example]: https://cp.creeperhost.net/Aries/
[ch wiki]: http://wiki.creeperlabs.com/index.php/ElasticCreeper_API
