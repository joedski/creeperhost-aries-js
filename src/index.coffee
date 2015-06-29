###
A sort of straight port of the Aries PHP class.

The way it is called is basically the same, but the response is handled nodishly.
	api = new Aries appName, appSecret
	request = api.exec "minecraft", "readconsole"
	request.on 'response', ( response ) ->
		responseData = ''

		response.on 'data', ( chunk ) ->
			responseData += chunk

		# the 'end' event probably works, too.
		response.on 'close', () ->
			handleResponseData responseData

or slightly more succinctly
	api.exec( "minecraft", "readconsole" ).on 'response', ( response ) ->
		...
###

https = require 'https'

# The CH Aries API uses PHP's urlencode function, so I'm going to assume their backend expucts its exact behavior.
urlencode = require '../phpjs/urlencode'

###
The cURL request had the following options:
- CURLOPT_URL = (the url)
- CURLOPT_SSL_VERIFYPEER = false
- CURLOPT_SSL_VERIFYHOST = false
- CURLOPT_POST = 1+
- CURLOPT_RETURNTRANSFER = true
    - This is not nodey, so we ignore this in favor of asyncish ways.  Listen for the 'response' event on the ClientRequest this method call returns.
- CURLOPT_POSTFIELDS = fieldsString
###

module.exports = class Aries
	# Confusingly, this is actually the api 'user' name. (app name.)
	key: null
	secret: null

	constructor: ( @key, @secret ) ->
		# Nothing else, really...

	# PHP arrays most closely resemble JS objects.
	exec: ( service, command, data = {} ) ->
		postData = @getPostData data
		url = @getPostRequestOptions service, command, postData

		# return the request object so controlling code can handle the response,
		# which is done by listening for the 'response' event.
		# See: https://nodejs.org/api/http.html#http_event_response
		@execRequest url, postData

	getPostData: ( data ) ->
		fields =
			key: @key
			secret: @secret

		if data? then fields.data = JSON.stringify data

		# TODO: There's probably a better way to do this, but for now I'm explicitly following the exact same method as their PHP implementation.
		("#{ name }=#{ urlencode value }" for name, value of fields).join '&'

	getPostRequestOptions: ( service, command, postData ) ->
		method: 'POST'
		hostname: "api.creeperhost.net"
		# hostname: 'httpbin.org'
		path: '/' + [ service, command ].join( '/' )
		# path: '/post'
		headers:
			'Content-Type': 'application/x-www-form-urlencoded'
			'Content-Length': Buffer.byteLength postData, 'utf8'
		rejectUnauthorized: false # covers CURLOPT_SSL_VERIFYPEER and CURLOPT_SSL_VERIFYHOST.

	execRequest: ( urlOpts, postData ) ->
		request = https.request urlOpts
		request.write postData
		request.end()
		request
