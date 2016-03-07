CreeperHost Aries API for Node JS
=================================

> Note: v1.x did not pass errors to the user-provided callback.  v2 now passes the error or null as the first argument.

This is a simple port of [CreeperHost][1]'s [Aries API][2] to Node JS or IO JS.  It's useful if you're writing a Node based CreeperHost frontend or [NW.js][4] app.

Note that the Aries API is a low level API, and should probably be wrapped by a helper.



Usage
-----

> Note: Due to CORS headers, this cannot be used in the browser unless CreeperHost themselves allow any source to pull such content.

Basic usage is largely similar to their normal API, but dealing with the response is Nodish and async, using Node's own `https` module rather than cURL.

### Class: Aries

#### Statics

- `ERROR_HTTP :string` Indicates the server sent a non-OK HTTP status code as its response.
- `ERROR_ARIES :string` Indicates the Aries API itself responded successfully but the API call returned an error.
- `errorOnCommonErrors :Function( Function( error :?Error, parsedResponse :Object | Null, responseStream :http.IncomingMessage, rawResponse :string ) ) => Function`
	- Converts some common cases of higher-level errors into Error callbacks, such as an HTTP Server Error (as opposed to an error actually connecting over HTTP) or API Errors.
	- This allows switching the error behavior based on the Error object that is handed to your callback rather than having to check for certain error cases yourslef.
	- Exact Behavior:
		- If the Request itself has an error while trying to initiate an HTTPS connection to the API server, it calls your callback with that error as normal.
		- If the API Server's response has a status code that is outside of the range of `200 <= statusCode < 400` then it calls your callback with an error object with the following additional properties:
			- `apiErrorType :string = Aries.ERROR_HTTP`
			- `apiResponse :http.IncomingMessage` This is the [Response object][node response] that a [Request Stream][node request] emits on its `response` event.
			- `apiResponseStatusCode :number` The HTTP Status as an integer.
		- If the API Server responds OKish, but the API call itself results in an error (Cannot access console, etc.) then it calls your callback with an error object with the following additional properties:
			- `apiErrorType :string = Aries.ERROR_ARIES`
			- `apiResponseData :object` The response data that the API Server sent back, parsed from JSON into an object.
			- `apiResponseStatus :string = apiResponseData.status` The exact status the API Server Call returned.  Usually `error`.
			- `apiResponseMessage :string = apiResponseData.message` The status message the API Server Call returned.
			- `apiResponseCode :number = apiResponseData.code` An error number probably only useful to Creeperhost Devs.
		- If none of the above cases occur, calls your callback with no error, just the response, request stream, and raw response string as detailed in __Methods: `exec`__.

#### Methods

- `exec( section :string, command :string, data :Object = {}, [ callback :Function ] ) :http.ClientRequest`
	- Generates a request and sends it to CreeperHost's server, returning the request object so you can listen to it.  For the most part, you'll just listen for a 'response' event, though you should probably handle timeouts and such as well.
	- If a callback is passed as the last argument then exec will automatically listen for the response to arrive, slurp the data together, and call the callback with that response and its data in the following form:
		- `callback( error :?Error, parsedResponse :?object, responseStream :?http.IncomingMessage, rawResponse :?string )`
			- `error` - An error if one is encountered when sending the Request.  Does not count HTTP Server Errors (status codes less than 200 or greater than or equal to 400) nor API errors (`apiResponse.status != 'success'`)
			- `parsedResponse` - If the response is formatted as JSON, this will be the object parsed from that formatted string, otherwise it will be `null`.
			- `responseStream` - This is the message stream representing the response from CreeperHost's server.  It is useful for checking the response statusCode among other things, although is probably safely ignored most of the time.
			- `rawResponse` - The raw body recieved through this response.  Probably not useful most of the time.

### Example Use

```js
var Aries = require( 'creeperhost-aries' );
var api = new Aries( appKey, appSecret );

api.exec( 'minecraft', 'readconsole', function( error, parsedResponse, responseStream, rawResponse ) {
	if( error ) {
		console.error( `Error occurred trying to initiate https connection: ${ error.message }` );
		console.error( error );
		return;
	}

	if( ! (200 <= responseStream.statusCode && responseStream.statusCode < 400) ) {
		console.warn( "Server returned non-OKish status!", "Status code was", responseStream.statusCode );
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

api.exec( 'minecraft', 'readconsole', Aries.wrapCommonErrors( function( error, parsedResponse, responseStream, rawResponse ) {
	// Now, common errors are prebundled for us.
	if( error ) {
		switch( error.apiErrorType ) {
			case Aries.ERROR_HTTP:
				console.warn( `Server returned non-OKish status!  Status code was ${ responseStream.statusCode }` );
				return;

			case Aries.ERROR_ARIES:
				console.warn( `API returned non-successful status: ${ parsedResponse.status }` );
				console.warn( "Message:", parsedResponse.message );
				return;

			default:
				console.error( `Error trying to exec API call: ${ error.message }` );
				console.error( error );
				return;
		}
	}

	// Edge cases?

	console.log( parsedResponse.log );
}));
```



Summary of Available API Commands
---------------------------------

The available commands can be found in the [API Command Reference](API_COMMAND_REFERENCE.md).



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
[php example]: https://cp.creeperhost.net/Aries/
[ch wiki]: http://wiki.creeperlabs.com/index.php/ElasticCreeper_API
[node response]: https://nodejs.org/api/http.html#http_class_http_incomingmessage
[node request]: https://nodejs.org/api/http.html#http_class_http_clientrequest
