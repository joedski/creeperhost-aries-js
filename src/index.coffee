###
A sort of straight port of the Aries PHP class.
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

addCompleteListener = ( requestStream, listenerCallback ) ->
	rawResponseData = ''

	appendData = ( chunk ) -> rawResponseData += chunk

	emitData = ( response ) ->
		responseData = if rawResponseData? then (try JSON.parse rawResponseData catch e then null) else null
		listenerCallback responseData, response, rawResponseData

	requestStream.on 'response', ( response ) ->
		response.on 'data', appendData
		response.on 'end', -> emitData response

	requestStream

module.exports = class Aries
	key: null
	secret: null

	constructor: ( @key, @secret ) ->
		# Nothing else, really...

	# PHP arrays most closely resemble JS objects.
	exec: ( service, command, data = {}, callback = null ) ->
		if typeof data is 'function'
			callback = data
			data = {}

		postData = @getPostData data
		url = @getPostRequestOptions service, command, postData
		request = @execRequest url, postData
		if callback? then addCompleteListener request, callback else request

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
		path: '/' + [ service, command ].join( '/' )
		headers:
			'Content-Type': 'application/x-www-form-urlencoded'
			'Content-Length': Buffer.byteLength postData, 'utf8'
		rejectUnauthorized: false # covers CURLOPT_SSL_VERIFYPEER and CURLOPT_SSL_VERIFYHOST.

	execRequest: ( urlOpts, postData ) ->
		request = https.request urlOpts
		request.write postData
		request.end()
		request
