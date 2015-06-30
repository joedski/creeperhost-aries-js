CreeperHost Aries API for Node JS
=================================

> Note: Due to not actually setting the version to 0 before publishing, the 1.x versions are being treated as the unstable version.  Sorry about that.

This is a simple port of [CreeperHost][1]'s [Aries API][2] to Node JS or IO JS.  It's useful if you're writing a Node based CreeperHost frontend or [NW.js][4] app.

Note that the Aries API is a low level API, and should probably be wrapped by a helper.



Usage
-----

> Note: Due to CORS headers, this cannot be used in the browser unless CreeperHost themselves allow any source to pull such content.

Basic usage is largely similar to their normal API, but dealing with the response is Nodish and async, using Node's own `https` module rather than cURL.

### Class: Aries

Methods:

- `exec( section :String, command :String, data :Object = {}, [ callback :Function ] ) :http.ClientRequest`
	- Generates a request and sends it to CreeperHost's server, returning the request object so you can listen to it.  For the most part, you'll just listen for a 'response' event, though you should probably handle timeouts and such as well.
	- If a callback is passed as the last argument then exec will automatically listen for the response to arrive, slurp the data together, and call the callback with that response and its data in the following form:
		- `callback( parsedResponse :Object | Null, responseStream :http.IncomingMessage, rawResponse :String )`
			- `parsedResponse` - If the response is formatted as JSON, this will be the object parsed from that formatted string, otherwise it will be `null`.
			- `responseStream` - This is the message stream representing the response from CreeperHost's server.  It is useful for checking the response statusCode among other things, although is probably safely ignored most of the time.
			- `rawResponse` - The raw body recieved through this response.  Probably not useful most of the time.

### Example Use

```js
var Aries = require( 'creeperhost-aries' );
var api = new Aries( appKey, appSecret );

api.exec( 'minecraft', 'readconsole', function( parsedResponse, responseStream, rawResponse ) {
	if( responseStream.statusCode !== 200 ) {
		console.warn( "Server returned non-OK status!", "Status code was", responseStream.statusCode );
		return;
	}

	if( parsedResponse.status !== "success" ) {
		console.warn( "API returned non-successful status:", parsedResponse.status );
		console.warn( "Message:", parsedResponse.message );
		return;
	}

	// JSON returned by readconsole has a 'log' property which has the current console log.
	console.log( parsedResponse.log );
});
```



Legal
-----

Use of the names CreeperHost and Aries do not indicate endorsement by CreeperHost of this project.

This code specifically is copyright the author(s) of this project, however this should not be construed to imply ownship of any kind of any APIs, marks, or other properties of CreeperHost.

All contents of the `phpjs` directory are functions or other items pulled from [php.js][3] and are not owned by the author(s) of this project in any manner.

See [LISCENSE](LISCENSE) for the text of the ISC Liscense which governs the code by the author(s).



[1]: http://www.creeperhost.net/
[2]: https://github.com/lesander/creeperhost-api
[3]: http://phpjs.org/
[4]: https://github.com/nwjs/nw.js/