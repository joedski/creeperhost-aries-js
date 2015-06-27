CreeperHost Aries API for Node JS
=================================

This is a simple port of [CreeperHost][1]'s [Aries API][2] to Node JS or IO JS.  It's useful if you're writing a Node based CreeperHost frontend or [NW.js][4] app.



Usage
-----

> Note: Due to CORS headers, this cannot be used in the browser unless CreeperHost themselves allow any source to pull such content.

Basic usage is largely similar to their normal API, but dealing with the response is Nodish and async, using Node's own http module rather than cURL.

### Class: Aries

Methods:

- `exec( section :String, command :String ) :http.ClientRequest`
	- Generates a request and sends it to CreeperHost's server, returning the request object so you can listen to it.  For the most part, you'll just listen for a 'response' event, though you should probably handle timeouts and such as well.

There are some other helper methods, but they are not so useful in isolation.

### Example Use

```js
var Aries = require( 'creeperhost-aries' );
var api = new Aries( appKey, appSecret );

function getConsole( callback ) {
	var responseData = '';

	function appendData( chunk ) { responseData += chunk; }
	function returnData() { callback( null, responseData ); }

	// Note that exec returns a Request object which signals a response with the 'response' event.
	api.exec( 'minecraft', 'readconsole' ).on( 'response', function( response ) {
		if( response.statusCode !== 200 ) {
			callback( "Server returned non-OK status: " + String( response.statusCode ) );
			return;
		}
		
		response.on( 'data', appendData );
		response.on( 'end', returnData );
	});
}
```



Legal
-----

This code specifically is copyright the author(s) of this project, however this should not be construed to imply ownship of any kind of any APIs, marks, or other properties of CreeperHost.

All contents of the `phpjs` directory are functions or other items pulled from [php.js][3] and are not owned by the author(s) of this project in any manner.

See [LISCENSE](LISCENSE) for the text of the ISC Liscense which governs the code by the author(s).



[1]: http://www.creeperhost.net/
[2]: https://github.com/lesander/creeperhost-api
[3]: http://phpjs.org/
[4]: https://github.com/nwjs/nw.js/